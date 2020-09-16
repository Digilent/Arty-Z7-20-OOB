
#ifndef HDMI_LOOPBACK_LOGIC_H
#define HDMI_LOOPBACK_LOGIC_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xil_io.h"
#include "xstatus.h"

#define HDMI_LOOPBACK_LOGIC_CSR_OFFSET 0 // Control/status register
#define HDMI_LOOPBACK_LOGIC_ID_OFFSET 4 //ID register

#define CSR_RST_MASK 0x80000000
#define CSR_DONE_MASK 0x1
#define CSR_ERROR_MASK 0x2
#define CSR_STATUS_MASK 0x3C
#define CSR_STATUS_SHIFT 2

/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a HDMI_LOOPBACK_LOGIC register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the HDMI_LOOPBACK_LOGICdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void HDMILoopbackTest_WriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define HDMILoopbackTest_WriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a HDMI_LOOPBACK_LOGIC register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the HDMI_LOOPBACK_LOGIC device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 HDMILoopbackTest_ReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define HDMILoopbackTest_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the HDMI_LOOPBACK_LOGIC instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus HDMILoopbackLogic_SelfTest(u32 BaseAddress);
XStatus HDMILoopbackTest(u32 LogicBaseAddress, u32 IicBaseAddress, u32 TimerBaseAddress, u32 timerFrequency);
XStatus fnDDCTest(u32 IicBaseAddress);
XStatus fnHDMITest(u32 LogicBaseAddress, u32 TimerBaseAddress, u32 timerFrequency);

#endif // HDMI_LOOPBACK_LOGIC_H
