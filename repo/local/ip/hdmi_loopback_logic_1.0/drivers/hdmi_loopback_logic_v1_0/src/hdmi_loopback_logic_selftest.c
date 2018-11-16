
/***************************** Include Files *******************************/
#include "hdmi_loopback_logic.h"
#include "xil_io.h"
#include "xiic_l.h"
#include "xtmrctr_l.h"

/************************** Constant Definitions ***************************/

/************************** Function Definitions ***************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the HDMI_LOOPBACK_LOGICinstance to be worked on.
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
XStatus HDMILoopbackLogic_SelfTest(u32 BaseAddress)
{
	u32 id;

	// Read ID register
	id = HDMILoopbackTest_ReadReg(BaseAddress, HDMI_LOOPBACK_LOGIC_ID_OFFSET);

	if (id != 0x55AA0100)
		return XST_FAILURE;

	return XST_SUCCESS;
}
