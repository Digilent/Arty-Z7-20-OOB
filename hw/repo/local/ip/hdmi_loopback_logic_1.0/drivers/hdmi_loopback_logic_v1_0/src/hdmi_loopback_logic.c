/***************************** Include Files *******************************/
#include "hdmi_loopback_logic.h"
#include "xiic_l.h"
#include "xtmrctr_l.h"

#define RETRY 10
#define RETRY_I2C 100
#define TOUT_SECONDS 20
#define RETURN_ON_FAILURE(x) if(XST_SUCCESS != (x)) return XST_FAILURE;

const uint8_t dgl_edid[] = {0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x10, 0xEC};

unsigned XIic_NoBlockSend(u32 BaseAddress, u8 Address,
		   u8 *BufferPtr, unsigned ByteCount, u8 Option);
static unsigned SendData(u32 BaseAddress, u8 *BufferPtr,
			 unsigned ByteCount, u8 Option);
XStatus fnDDCTest(u32 IicBaseAddress);
XStatus fnHDMITest(u32 LogicBaseAddress, u32 TimerBaseAddress, u32 timerFrequency);

/************************** Function Definitions ***************************/

XStatus HDMILoopbackTest(u32 LogicBaseAddress, u32 IicBaseAddress, u32 TimerBaseAddress, u32 timerFrequency)
{
	RETURN_ON_FAILURE(fnDDCTest(IicBaseAddress));
	RETURN_ON_FAILURE(fnHDMITest(LogicBaseAddress, TimerBaseAddress, timerFrequency));
	return XST_SUCCESS;
}

XStatus fnDDCTest(u32 IicBaseAddress)
{
	//AXI IIC reset
	XIic_WriteReg(IicBaseAddress, XIIC_RESETR_OFFSET, XIIC_RESET_MASK);

	uint8_t rgbBuf[sizeof(dgl_edid)];
	rgbBuf[0] = 0;
	volatile unsigned ReceivedByteCount;
	u16 StatusReg;
	int timeout = RETRY;
	do {
		StatusReg = XIic_ReadReg(IicBaseAddress, XIIC_SR_REG_OFFSET);
		if(!(StatusReg & XIIC_SR_BUS_BUSY_MASK)) {
			ReceivedByteCount = XIic_NoBlockSend(IicBaseAddress, 0xA0 >> 1, rgbBuf, 1, XIIC_REPEATED_START);
			if (ReceivedByteCount != 1) {
				/* Send is aborted so reset Tx FIFO */
				XIic_WriteReg(IicBaseAddress,
						XIIC_CR_REG_OFFSET,
						XIIC_CR_TX_FIFO_RESET_MASK);
				XIic_WriteReg(IicBaseAddress,
						XIIC_CR_REG_OFFSET,
						XIIC_CR_ENABLE_DEVICE_MASK);
			}
		}
	} while (ReceivedByteCount != 1 && timeout--);

	if (ReceivedByteCount != 1)
		return XST_FAILURE;

	if (sizeof(rgbBuf) != XIic_Recv(IicBaseAddress, 0xA0 >> 1, rgbBuf, sizeof(rgbBuf), XIIC_STOP))
		return XST_FAILURE;

	int i=0;
	for (;i<sizeof(rgbBuf);++i)
	{
		if (rgbBuf[i] != dgl_edid[i]) {
			return XST_FAILURE;
		}
	}

	return XST_SUCCESS;
}

XStatus fnHDMITest(u32 LogicBaseAddress, u32 TimerBaseAddress, u32 timerFrequency)
{
	u32 dwControl;

	//Reset
	HDMILoopbackTest_WriteReg(LogicBaseAddress, HDMI_LOOPBACK_LOGIC_CSR_OFFSET, CSR_RST_MASK);

	//Configure timout counter
	XTmrCtr_SetControlStatusReg(TimerBaseAddress, 0, 0x0);
	XTmrCtr_SetLoadReg(TimerBaseAddress, 0, timerFrequency*TOUT_SECONDS);
	XTmrCtr_LoadTimerCounterReg(TimerBaseAddress, 0);
	dwControl = XTmrCtr_GetControlStatusReg(TimerBaseAddress, 0);
	dwControl |= XTC_CSR_DOWN_COUNT_MASK;
	dwControl &= ~XTC_CSR_LOAD_MASK;
	XTmrCtr_SetControlStatusReg(TimerBaseAddress, 0, dwControl);

	//Start test by taking out of reset
	HDMILoopbackTest_WriteReg(LogicBaseAddress, HDMI_LOOPBACK_LOGIC_CSR_OFFSET, 0x0);

	//Enable timer
	XTmrCtr_Enable(TimerBaseAddress, 0);

	do
	{
		dwControl = HDMILoopbackTest_ReadReg(LogicBaseAddress, HDMI_LOOPBACK_LOGIC_CSR_OFFSET);
	} while (!((dwControl & CSR_DONE_MASK) || XTmrCtr_HasEventOccurred(TimerBaseAddress, 0)));

	if (!(dwControl & CSR_DONE_MASK) || dwControl & CSR_ERROR_MASK)
		return XST_FAILURE;

	return XST_SUCCESS;
}

/****************************************************************************/
/**
* Send data as a master on the IIC bus.  This function sends the data
* using polled I/O and blocks until the data has been sent. It only supports
* 7 bit addressing mode of operation.  The user is responsible for ensuring
* the bus is not busy if multiple masters are present on the bus.
*
* @param	BaseAddress contains the base address of the IIC device.
* @param	Address contains the 7 bit IIC address of the device to send the
*		specified data to.
* @param	BufferPtr points to the data to be sent.
* @param	ByteCount is the number of bytes to be sent.
* @param	Option indicates whether to hold or free the bus after
* 		transmitting the data.
*
* @return	The number of bytes sent.
*
* @note		None.
*
******************************************************************************/
unsigned XIic_NoBlockSend(u32 BaseAddress, u8 Address,
		   u8 *BufferPtr, unsigned ByteCount, u8 Option)
{
	unsigned RemainingByteCount;
	u32 ControlReg;
	volatile u32 StatusReg;
	u32 retryCount = 0;

	/* Check to see if already Master on the Bus.
	 * If Repeated Start bit is not set send Start bit by setting
	 * MSMS bit else Send the address.
	 */
	ControlReg = XIic_ReadReg(BaseAddress,  XIIC_CR_REG_OFFSET);
	if ((ControlReg & XIIC_CR_REPEATED_START_MASK) == 0) {
		/*
		 * Put the address into the FIFO to be sent and indicate
		 * that the operation to be performed on the bus is a
		 * write operation
		 */
		XIic_Send7BitAddress(BaseAddress, Address,
					XIIC_WRITE_OPERATION);
		/* Clear the latched interrupt status so that it will
		 * be updated with the new state when it changes, this
		 * must be done after the address is put in the FIFO
		 */
		XIic_ClearIisr(BaseAddress, XIIC_INTR_TX_EMPTY_MASK |
				XIIC_INTR_TX_ERROR_MASK |
				XIIC_INTR_ARB_LOST_MASK);

		/*
		 * MSMS must be set after putting data into transmit FIFO,
		 * indicate the direction is transmit, this device is master
		 * and enable the IIC device
		 */
		XIic_WriteReg(BaseAddress,  XIIC_CR_REG_OFFSET,
			 XIIC_CR_MSMS_MASK | XIIC_CR_DIR_IS_TX_MASK |
			 XIIC_CR_ENABLE_DEVICE_MASK);

		/*
		 * Clear the latched interrupt
		 * status for the bus not busy bit which must be done while
		 * the bus is busy
		 */
		StatusReg = XIic_ReadReg(BaseAddress,  XIIC_SR_REG_OFFSET);
		retryCount = 0;
		while ((StatusReg & XIIC_SR_BUS_BUSY_MASK) == 0 && retryCount++ < RETRY_I2C) {
			StatusReg = XIic_ReadReg(BaseAddress,
						  XIIC_SR_REG_OFFSET);
		}

		XIic_ClearIisr(BaseAddress, XIIC_INTR_BNB_MASK);
	}
	else {
		/*
		 * Already owns the Bus indicating that its a Repeated Start
		 * call. 7 bit slave address, send the address for a write
		 * operation and set the state to indicate the address has
		 * been sent.
		 */
		XIic_Send7BitAddress(BaseAddress, Address,
					XIIC_WRITE_OPERATION);
	}

	/* Send the specified data to the device on the IIC bus specified by the
	 * the address
	 */
	RemainingByteCount = SendData(BaseAddress, BufferPtr,
					ByteCount, Option);

	ControlReg = XIic_ReadReg(BaseAddress,  XIIC_CR_REG_OFFSET);
	if ((ControlReg & XIIC_CR_REPEATED_START_MASK) == 0) {
		/*
		 * The Transmission is completed, disable the IIC device if
		 * the Option is to release the Bus after transmission of data
		 * and return the number of bytes that was received. Only wait
		 * if master, if addressed as slave just reset to release
		 * the bus.
		 */
		if ((ControlReg & XIIC_CR_MSMS_MASK) != 0) {
			XIic_WriteReg(BaseAddress,  XIIC_CR_REG_OFFSET,
				 (ControlReg & ~XIIC_CR_MSMS_MASK));
			StatusReg = XIic_ReadReg(BaseAddress,
					XIIC_SR_REG_OFFSET);
			while ((StatusReg & XIIC_SR_BUS_BUSY_MASK) != 0) {
				StatusReg = XIic_ReadReg(BaseAddress,
						XIIC_SR_REG_OFFSET);
			}
		}

		if ((XIic_ReadReg(BaseAddress, XIIC_SR_REG_OFFSET) &
		    XIIC_SR_ADDR_AS_SLAVE_MASK) != 0) {
			XIic_WriteReg(BaseAddress,  XIIC_CR_REG_OFFSET, 0);
		}
	}

	return ByteCount - RemainingByteCount;
}

static unsigned SendData(u32 BaseAddress, u8 *BufferPtr,
			 unsigned ByteCount, u8 Option)
{
	u32 IntrStatus;

	/*
	 * Send the specified number of bytes in the specified buffer by polling
	 * the device registers and blocking until complete
	 */
	while (ByteCount > 0) {
		/*
		 * Wait for the transmit to be empty before sending any more
		 * data by polling the interrupt status register
		 */
		while (1) {
			IntrStatus = XIic_ReadIisr(BaseAddress);

			if (IntrStatus & (XIIC_INTR_TX_ERROR_MASK |
					  XIIC_INTR_ARB_LOST_MASK |
					  XIIC_INTR_BNB_MASK)) {
				return ByteCount;
			}

			if (IntrStatus & XIIC_INTR_TX_EMPTY_MASK) {
				break;
			}
		}
		/* If there is more than one byte to send then put the
		 * next byte to send into the transmit FIFO
		 */
		if (ByteCount > 1) {
			XIic_WriteReg(BaseAddress,  XIIC_DTR_REG_OFFSET,
				 *BufferPtr++);
		}
		else {
			if (Option == XIIC_STOP) {
				/*
				 * If the Option is to release the bus after
				 * the last data byte, Set the stop Option
				 * before sending the last byte of data so
				 * that the stop Option will be generated
				 * immediately following the data. This is
				 * done by clearing the MSMS bit in the
				 * control register.
				 */
				XIic_WriteReg(BaseAddress,  XIIC_CR_REG_OFFSET,
					 XIIC_CR_ENABLE_DEVICE_MASK |
					 XIIC_CR_DIR_IS_TX_MASK);
			}

			/*
			 * Put the last byte to send in the transmit FIFO
			 */
			XIic_WriteReg(BaseAddress,  XIIC_DTR_REG_OFFSET,
				 *BufferPtr++);

			if (Option == XIIC_REPEATED_START) {
				XIic_ClearIisr(BaseAddress,
						XIIC_INTR_TX_EMPTY_MASK);
				/*
				 * Wait for the transmit to be empty before
				 * setting RSTA bit.
				 */
				while (1) {
					IntrStatus =
						XIic_ReadIisr(BaseAddress);
					if (IntrStatus &
						XIIC_INTR_TX_EMPTY_MASK) {
						/*
						 * RSTA bit should be set only
						 * when the FIFO is completely
						 * Empty.
						 */
						XIic_WriteReg(BaseAddress,
							 XIIC_CR_REG_OFFSET,
						   XIIC_CR_REPEATED_START_MASK |
						   XIIC_CR_ENABLE_DEVICE_MASK |
						   XIIC_CR_DIR_IS_TX_MASK |
						   XIIC_CR_MSMS_MASK);
						break;
					}
				}
			}
		}

		/*
		 * Clear the latched interrupt status register and this must be
		 * done after the transmit FIFO has been written to or it won't
		 * clear
		 */
		XIic_ClearIisr(BaseAddress, XIIC_INTR_TX_EMPTY_MASK);

		/*
		 * Update the byte count to reflect the byte sent and clear
		 * the latched interrupt status so it will be updated for the
		 * new state
		 */
		ByteCount--;
	}

	if (Option == XIIC_STOP) {
		/*
		 * If the Option is to release the bus after transmission of
		 * data, Wait for the bus to transition to not busy before
		 * returning, the IIC device cannot be disabled until this
		 * occurs. Note that this is different from a receive operation
		 * because the stop Option causes the bus to go not busy.
		 */
		while (1) {
			if (XIic_ReadIisr(BaseAddress) &
				XIIC_INTR_BNB_MASK) {
				break;
			}
		}
	}

	return ByteCount;
}
