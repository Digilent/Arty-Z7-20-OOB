/******************************************************************************
 * @file dma.c
 * Functions used foe DMA transfer, it can be used as a simple template if the
 * functions which are mainly thought to be used for audio transfers are eliminated
 * from the handlers
 *
 * @authors Hegbeli Ciprian
 *
 * @date 2015-Jan-20
 *
 * @copyright
 * (c) 2015 Copyright Digilent Incorporated
 * All Rights Reserved
 *
 * This program is free software; distributed under the terms of BSD 3-clause
 * license ("Revised BSD License", "New BSD License", or "Modified BSD License")
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name(s) of the above-listed copyright holder(s) nor the names
 *    of its contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 * @desciption
 * The file contains the DMA handlers for both transfers types, S2MM and MM2S,
 * along with a configuration function for non scatter-gather use
 *
 * @note
 *
 * <pre>
 * MODIFICATION HISTORY:
 *
 * Ver   Who             Date        Changes
 * ----- --------------- ----------- --------------------------------------------
 * 1.00  Hegbeli Ciprian 2015-Jan-20 First release
 *
 * </pre>
 *
 *****************************************************************************/

/***************************** Include Files *********************************/

#include "dma.h"
#include "../AudioPWM/audiopwm.h"

/************************** Constant Definitions *****************************/

/************************** Variable Definitions *****************************/
volatile u8 DmaS2MMFlag;
volatile u8 DmaMM2SFlag;

/************************** Function Prototypes ******************************/

/************************** Function Definitions *****************************/

/******************************************************************************
 * This is the Interrupt Handler from the Stream to the MemoryMap. It is called
 * when an interrupt is trigger by the DMA
 *
 * @param	Callback is a pointer to S2MM channel of the DMA engine.
 *
 * @return	none
 *
 *****************************************************************************/
void fnS2MMInterruptHandler (void *Callback)
{
	u32 IrqStatus;
	int TimeOut;
	XAxiDma *AxiDmaInst = (XAxiDma *)Callback;

	//Read all the pending DMA interrupts
	IrqStatus = XAxiDma_IntrGetIrq(AxiDmaInst, XAXIDMA_DEVICE_TO_DMA);

	//Acknowledge pending interrupts
	XAxiDma_IntrAckIrq(AxiDmaInst, IrqStatus, XAXIDMA_DEVICE_TO_DMA);

	//If there are no interrupts we exit the Handler
	if (!(IrqStatus & XAXIDMA_IRQ_ALL_MASK))
	{
		return;
	}

	// If error interrupt is asserted, raise error flag, reset the
	// hardware to recover from the error, and return with no further
	// processing.
	if (IrqStatus & XAXIDMA_IRQ_ERROR_MASK)
	{
		XAxiDma_Reset(AxiDmaInst);
		TimeOut = 100;
		while (TimeOut)
		{
			if(XAxiDma_ResetIsDone(AxiDmaInst))
			{
				break;
			}
			TimeOut -= 1;
		}
		return;
	}

	if ((IrqStatus & XAXIDMA_IRQ_IOC_MASK))
	{
		DmaS2MMFlag = 1;

	}
}

/******************************************************************************
 * This is the Interrupt Handler from the MemoryMap to the Stream. It is called
 * when an interrupt is trigger by the DMA
 *
 * @param	Callback is a pointer to MM2S channel of the DMA engine.
 *
 * @return	none
 *
 *****************************************************************************/
void fnMM2SInterruptHandler (void *Callback)
{
	u32 IrqStatus;
	int TimeOut;
	XAxiDma *AxiDmaInst = (XAxiDma *)Callback;

	//Read all the pending DMA interrupts
	IrqStatus = XAxiDma_IntrGetIrq(AxiDmaInst, XAXIDMA_DMA_TO_DEVICE);

	//Acknowledge pending interrupts
	XAxiDma_IntrAckIrq(AxiDmaInst, IrqStatus, XAXIDMA_DMA_TO_DEVICE);

	//If there are no interrupts we exit the Handler
	if (!(IrqStatus & XAXIDMA_IRQ_ALL_MASK))
	{
		return;
	}

	// If error interrupt is asserted, raise error flag, reset the
	// hardware to recover from the error, and return with no further
	// processing.
	if (IrqStatus & XAXIDMA_IRQ_ERROR_MASK)
	{
		XAxiDma_Reset(AxiDmaInst);
		TimeOut = 100;
		while (TimeOut)
		{
			if(XAxiDma_ResetIsDone(AxiDmaInst))
			{
				break;
			}
			TimeOut -= 1;
		}
		return;
	}

	if ((IrqStatus & XAXIDMA_IRQ_IOC_MASK))
	{
		DmaMM2SFlag = 1;
//		AudioStop();
	}
}

/******************************************************************************
 * Function to configure the DMA in Interrupt mode, this implies that the scatter
 * gather function is disabled. Prior to calling this function, the user must
 * make sure that the Interrupts and the Interrupt Handlers have been configured
 *
 * @return	XST_SUCCESS - if configuration was successful
 * 			XST_FAILURE - when the specification are not met
 *****************************************************************************/
XStatus fnConfigDma(XAxiDma *AxiDma)
{
	int Status;
	XAxiDma_Config *pCfgPtr;

	//Make sure the DMA hardware is present in the project
	//Ensures that the DMA hardware has been loaded
	pCfgPtr = XAxiDma_LookupConfig(XPAR_AXIDMA_0_DEVICE_ID);
	if (!pCfgPtr)
	{
		xil_printf("\r\nNo config found for %d", XPAR_AXIDMA_0_DEVICE_ID);
		return XST_FAILURE;
	}

	//Initialize DMA
	//Reads and sets all the available information
	//about the DMA to the AxiDma variable
	Status = XAxiDma_CfgInitialize(AxiDma, pCfgPtr);
	if (Status != XST_SUCCESS)
	{
		xil_printf("\r\nInitialization failed %d");
		return XST_FAILURE;
	}

	//Ensures that the Scatter Gather mode is not active
	if(XAxiDma_HasSg(AxiDma))
	{
		xil_printf("\r\nDevice configured as SG mode");
		return XST_FAILURE;
	}

	//Disable all the DMA related Interrupts
	XAxiDma_IntrDisable(AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

	//Enable all the DMA Interrupts
	XAxiDma_IntrEnable(AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrEnable(AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

	return XST_SUCCESS;
}
