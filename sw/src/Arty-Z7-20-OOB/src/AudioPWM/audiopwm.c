/******************************************************************************
 * @file audiopwm.c
 * Function used to set the AudioPWM core registers and to initialize the
 * Memory map to stream transfer
 *
 * @authors Hegbeli Ciprian
 *
 * @date 2015-Dec-29
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
 * Sets the AudioPWM core registres and starts the DMA transfer
 *
 * @note
 *
 * <pre>
 * MODIFICATION HISTORY:
 *
 * Ver   Who             Date        Changes
 * ----- --------------- ----------- --------------------------------------------
 * 1.00  Hegbeli Ciprian 2015-Dec-29 First release
 *
 * </pre>
 *
 *****************************************************************************/

/***************************** Include Files *********************************/

#include <math.h>
#include "audiopwm.h"
#include "xparameters.h"
#include "xil_printf.h"
#include "xil_io.h"

/************************** Constant Definitions *****************************/

/************************** Variable Definitions *****************************/

/************************** Function Prototypes ******************************/

/************************** Function Definitions *****************************/

/******************************************************************************
 * Generates a Sine wave table and stores it in to an array give as a parameter.
 * It will generate on the half of duration a sine signal on the first channel
 * and on the second half on the second channel.
 *
 * @param	pu32SinArray pointer to an array which stores the Sine table.
 * @param	u32NrSamples is the number of samples to store.
 * @param	u32SinFreq frequency of the generated sine wave
 * @param	u32SamplingFreq sampling frequency of the generated sine wave
 * @param	u32Amplitude multiplication factor of the generated sine wave
 *
 * @return	returns the number of samples in one period
 *****************************************************************************/
u32 SinGenerator(u32 *pu32SinArray, u32 u32NrSamples,
		u32 u32SinFreq, u32 u32SamplingFreq, u32 u32Amplitude)
{
	double t, sample;
	u32 i;

    sample = 0;

    // fill first channel
	for (i=0; i<u32NrSamples; i++)
	{
		t = (double)i/(double)u32SamplingFreq;
		sample = ((double)u32Amplitude * sin(2 * M_PI * (double)u32SinFreq * t));
		*(pu32SinArray + i) = (int)sample;
	};
	return i;
}

/******************************************************************************
 * Sets the enable bit and deactivates the software reset bit of the AudioPWM
 * core.
 *
 * @param	none
 *
 * @return	none
 *****************************************************************************/
XStatus AudioStart()
{
	Audio_BitField.bit.u32bit0 = 1;//en bit (on)
	Audio_BitField.bit.u32bit31 = 1;//soft_resetn bit (off)
	Xil_Out32(AUDIO_BASE_ADDR, Audio_BitField.l);
	return XST_SUCCESS;
}

/******************************************************************************
 * Deactivates the enable bit of the AudioPWM core
 *
 * @param	none
 *
 * @return	XST_SUCCESS
 *****************************************************************************/
XStatus AudioStop()
{
	Audio_BitField.bit.u32bit0 = 0;//en bit(on);
	Xil_Out32(AUDIO_BASE_ADDR, Audio_BitField.l);
	return XST_SUCCESS;
}

/******************************************************************************
 * Sets the number of samples which will be transfered trough the Stream
 * Interface
 *
 * @param	u32NrSamples represents the number of 32 bits which will be sent
 * 			trough the stream to the Audio core.
 *
 * @return	XST_SUCCESS
 *****************************************************************************/
XStatus AudioSetNrOfSamples(u32 u32NrSamples)
{
	Xil_Out32(AUDIO_BASE_ADDR+4, u32NrSamples);
	return XST_SUCCESS;
}

/******************************************************************************
 * Starts the Audio and the DMA transfer.
 *
 * @param	sAxiDma pointer to the DMA Instance
 * @param	u32NrSamples represents the number of 32 bits which will be sent
 * 			trough the stream to the Audio core.
 * @param	The address where the Audio samples are stored
 *
 * @return	XST_SUCCESS when the Audio transfer is finished
 * 			XST_FAILURE if the DMA transfer could not be executed
 *****************************************************************************/
XStatus AudioDmaPlayBack(XAxiDma *DMAInstPtr, u32 u32NrSamples, u32 SampleAddr)
{
	u32 Status;

	DmaMM2SFlag = 0;
	Status = XAxiDma_SimpleTransfer(DMAInstPtr, SampleAddr, 4*u32NrSamples, XAXIDMA_DMA_TO_DEVICE);
	if (Status != XST_SUCCESS)
	{
		xil_printf("\n fail @ play; ERROR: %d", Status);
		return XST_FAILURE;
	}

	//Set the direction and start the transactions
	AudioStart();
	while(DmaMM2SFlag == 0);
	AudioStop();
	return XST_SUCCESS;
}

