/*
 * user_io.c
 *
 *  Created on: Jul 11, 2016
 *      Author: cignat
 */

#include "user_io.h"
#include <math.h>

XStatus USER_IO_BTN_EN(int bool_val)
{
	u32 rd_en;

	rd_en = USER_IO_mReadReg(USER_IO_SW_BTN_EN_OFFSET);
	sleep();

	if(bool_val > 0)
		USER_IO_mWriteReg(USER_IO_SW_BTN_EN_OFFSET, rd_en | 1);
	else
	{
		USER_IO_mWriteReg(USER_IO_SW_BTN_EN_OFFSET, rd_en & 0xFFFE);
	}

	return XST_SUCCESS;
}

XStatus USER_IO_SW_EN(int bool_val)
{
	u32 rd_en;

	rd_en = USER_IO_mReadReg(USER_IO_SW_BTN_EN_OFFSET);
	sleep();

	if(bool_val > 0)
		USER_IO_mWriteReg(USER_IO_SW_BTN_EN_OFFSET, rd_en | 2);
	else
	{
		USER_IO_mWriteReg(USER_IO_SW_BTN_EN_OFFSET, rd_en & 0xFFFD);
	}

	return XST_SUCCESS;
}

static u32 u32Pow(u32 d, u32 p)
{
	u32 retVal = 1;
	while(p > 0)
	{
		retVal = retVal * d;
		p--;
	}
	return retVal;
}

u32 convChar2U32(char const * arg0)
{
	u32 retVal;
	u8 i, u8Var;

	retVal = 0;
	for (i = 0; i < 10; i++)
	{
		if(*(arg0 + i) >= '0' && *(arg0 + i) <= '9')
		{
			u8Var = *(arg0 + i) - '0';
			retVal = (retVal * (u32Pow(10, i))) + u8Var;
		}
	}

	return (u32) retVal;
}

XStatus Write_leds(u8 val)
{
	USER_IO_mWriteReg(USER_IO_LED_OFFSET, val);

	return XST_SUCCESS;
}

u8 u8SW_Val(void)
{
	return (u8) USER_IO_mReadReg(USER_IO_SW_VAL_OFFSET);
}

u8 u8BTN_Val(void)
{
	return (u8) USER_IO_mReadReg(USER_IO_BTN_VAL_OFFSET);
}

XStatus USER_IO_RGB_INIT()
{
	RGB_mWriteReg(RGB_EN_OFFSET, 0xF);
	RGB_mWriteReg(RGB_PWM_DUTY_OFFSET, 0x2);
	RGB_mWriteReg(RGB_PWM_PERIOD_OFFSET, 0xF);
	RGB_mWriteReg(RGB_AUTO_DELAY_OFFSET, 0XF);
	RGB_mWriteReg(RGB_LED_SEL_OFFSET, 0x1); // initialize with LD4 active
	sleep();
	RGB_mWriteReg(RGB_EN_OFFSET, 0x0);
	sleep();

	return XST_SUCCESS;
}

void USER_IO_RGB_AUTOTEST()
{
	static u32 counter = 0;
	u32 led_sel;
	u32 en;

//	RGB_mWriteReg(RGB_EN_OFFSET, 0x8);

	led_sel = RGB_mReadReg(RGB_LED_SEL_OFFSET);
	RGB_mWriteReg(RGB_LED_SEL_OFFSET, 0x0);
	RGB_mWriteReg(RGB_EN_OFFSET, 0x8);

	switch ((counter >> 4) % 4) {
	case 0:
		en = 0b100;
		break;
	case 1:
		en = 0b010;
		break;
	case 2:
		en = 0b001;
		break;
	case 3:
		en = 0b111;
		break;
	}

	if (counter == 0) {
		led_sel ^= 0b11;
	}

	if (counter >= 63) {
		counter = 0;
		// toggle both LEDs
	} else {
		counter++;
	}

	RGB_mWriteReg(RGB_EN_OFFSET, 0x8 | en);
	RGB_mWriteReg(RGB_PWM_DUTY_OFFSET, 0x2FF);
	RGB_mWriteReg(RGB_PWM_PERIOD_OFFSET, 0xFFF);
	RGB_mWriteReg(RGB_AUTO_DELAY_OFFSET, 0X3FFF);
	RGB_mWriteReg(RGB_LED_SEL_OFFSET, led_sel);

	sleep();
	RGB_mWriteReg(RGB_EN_OFFSET, 0x0);

}

/******************************************************************************
 * This function check if a transition occured on each switch and button.
 *
 * @param	none
 *
 * @return	XST_SUCCESS - transition occured on each switch and button.
 * 			XST_FAILURE - Failure
 *****************************************************************************/
XStatus fnUserIOTest(u8* sw_value, u8* pb_value)
{
	USER_IO_RGB_AUTOTEST();

	USER_IO_BTN_EN(1);
	USER_IO_SW_EN(1);

	*sw_value = u8SW_Val();
	*pb_value = u8BTN_Val();

	return XST_SUCCESS;
}
