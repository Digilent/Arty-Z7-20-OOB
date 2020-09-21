/*
 * user_io.h
 *
 *  Created on: Jul 11, 2016
 *      Author: cignat
 */

#ifndef USER_IO_H_
#define USER_IO_H_



/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"
#include "xparameters.h"
#include "xil_io.h"
#include "sleep.h"

#define sleep()					usleep(40000)

// Workaround for 2015.4 bug of base addresses not getting properly propagated to xparameters.h
//#define USER_IO_BASEADDR 	XPAR_USER_IO_0_0
#define USER_IO_BASEADDR 			0x43C20000
#define RGB_BASEADDR 				0x43C40000

#define USER_IO_SW_BTN_EN_OFFSET 	0
#define USER_IO_LED_OFFSET 			4
#define USER_IO_BTN_VAL_OFFSET 		8
#define USER_IO_SW_VAL_OFFSET 		12


#define RGB_PWM_DUTY_OFFSET 	0
#define RGB_PWM_PERIOD_OFFSET 	4
#define RGB_EN_OFFSET 			8
#define RGB_LED_SEL_OFFSET 		12
#define RGB_AUTO_DELAY_OFFSET 	16


XStatus USER_IO_BTN_EN(int bool_val);
XStatus USER_IO_SW_EN(int bool_val);
XStatus Write_leds(u8 val);
u8 u8SW_Val(void);
u8 u8BTN_Val(void);
u32 convChar2U32(char const * arg0);
void USER_IO_RGB_AUTOTEST();
XStatus USER_IO_RGB_INIT();
XStatus fnUserIOTest(u8* sw_value, u8* pb_value);


/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a RGB register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the RGBdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void RGB_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define RGB_mWriteReg(RegOffset, Data) \
  	Xil_Out32((RGB_BASEADDR) + (RegOffset), (u32)(Data))

/**************************** Type Definitions *****************************/
/**
 *
 * Read a value to a RGB register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the RGBdevice.
 * @param   RegOffset is the register offset from the base to read from.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	u32 RGB_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define RGB_mReadReg(RegOffset) \
  	Xil_In32((RGB_BASEADDR) + (RegOffset))

/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a USER_IO register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the USER_IOdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void USER_IO_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define USER_IO_mWriteReg(RegOffset, Data) \
  	Xil_Out32((USER_IO_BASEADDR) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a USER_IO register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the USER_IO device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 USER_IO_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define USER_IO_mReadReg(RegOffset) \
    Xil_In32((USER_IO_BASEADDR) + (RegOffset))

#endif /* USER_IO_H_ */
