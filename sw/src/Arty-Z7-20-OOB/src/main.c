/******************************************************************************
 * @file main.c
 * This is the main function's definition file for the Arty Z7 -Z20 demo.
 *
 * @authors Elod Gyorgy
 *
 * @date 2016-Dec-21
 *
 * @copyright
 * (c) 2016 Copyright Digilent Incorporated
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
 * It is a simple demo that controls the LEDs to make sure Zynq boots up. Buttons,
 * switches modify the behavior of the LEDs.
 * HDMI input will be forwarded unchanged to HDMI output.
 * Audio output plays a pre-recorded soundtrack loaded from the boot image.
 *
 * @note
 *
 * UART setup:		In order to successfully communicate you must set your
 * 					terminal to 115200 Baud, 8 data bits, 1 stop bit, no parity.
 *
 * <pre>
 * MODIFICATION HISTORY:
 *
 * Ver   Who          Date        Changes
 * ----- ------------ ----------- --------------------------------------------
 * 1.00  Elod Gyorgy 2016-Dec-21 First release
 * 1.01  Arthur Brown 2018-Dec-4 Clean up for Github Release (pre-recorded soundtrack not included in repo)
 *
 * </pre>
 *
 *****************************************************************************/

/***************************** Include Files *********************************/
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <xstatus.h>
#include "xparameters.h"
#include "xil_cache.h"
#include "xil_exception.h"

#include "verbose/verbose.h"
#include "platform/platform.h"
#include "intc/intc.h"
#include "user_io/user_io.h"
#include "AudioPWM/audiopwm.h"
#include "dma/dma.h"

/************************** Constant Definitions *****************************/

/********************* Global Variable Definitions ***************************/
static XAxiDma sAxiDma;


/****************** Static Global Variable Definitions ***********************/

const ivt_t ivt[] =
{
	//{XPAR_XQSPIPS_0_INTR, (Xil_InterruptHandler)XQspiPs_InterruptHandler, &sQSpi},
	{XPAR_FABRIC_AXI_DMA_0_MM2S_INTROUT_INTR, (XInterruptHandler)fnMM2SInterruptHandler, &sAxiDma}
};

/************************** Function Prototypes ******************************/

/************************** Function Definitions *****************************/
int main() {
	XStatus Status, fInitSuccess;
	static XScuGic sIntc;
	u8 btn;

	init_platform();

	CLR_VERBOSE_FLAG();

	//This might not be printed properly, if CmdInit below uses the same UART as stdout
	VERBOSE("Initializing...");
	fInitSuccess = XST_SUCCESS;

	{
		// Initialize the interrupt controller
		Status = fnInitInterruptController(&sIntc);
		if(Status != XST_SUCCESS) {
			VERBOSE("err:irpt");
			fInitSuccess = XST_FAILURE;
			goto endinit;
		}

		//Initialise Audio
		{
			// Initialize DMA
			Status = fnConfigDma(&sAxiDma);
			if (Status != XST_SUCCESS)
			{
				xil_printf("err:dma\r\n");
				return XST_FAILURE;
			}

			//set Audio address and number of samples
			AudioSetNrOfSamples(AUD_NR_SAMPLES);

		}

		//Init rest of drivers here
		USER_IO_RGB_INIT();

		// Enable all interrupts in our interrupt vector table
		// Make sure all driver instances using this IVT are initialized first
		fnEnableInterrupts(&sIntc, &ivt[0], sizeof(ivt)/sizeof(ivt[0]));

		VERBOSE("init:done");

endinit:
		fInitSuccess = fInitSuccess; //Have to add an instruction for the label
	}

	xil_printf("Starting Arty Z7-20 Rev. B Out-of-Box Demo\r\n");

	USER_IO_BTN_EN(1);
	USER_IO_SW_EN(1);

	while(1) {
		USER_IO_RGB_AUTOTEST();
		btn = u8BTN_Val();
		if (btn)
		{
			// Play C4 (261 Hz Sine Wave) over AUDIO OUT at sampling rate of 48KHz, arbitrary amplitude < 0x7FFF
			// ArtVVB: higher amplitudes have some distortion present, unsure why
			SinGenerator((u32*)AUDIO_MEM_ADDR, AUD_NR_SAMPLES, 261, 48000, 256);
			xil_printf("Button press detected. Starting audio playback.\r\n");
			AudioDmaPlayBack(&sAxiDma, AUD_NR_SAMPLES, AUDIO_MEM_ADDR);
			xil_printf("Audio playback complete.");
		}
	}

	cleanup_platform();
	return 0;
}
