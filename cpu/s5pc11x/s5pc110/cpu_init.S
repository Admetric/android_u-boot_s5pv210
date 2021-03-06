#include <config.h>
#include <s5pc110.h>

#define SH_TEST 1

	.globl mem_ctrl_asm_init
mem_ctrl_asm_init:

	ldr	r0, =ASYNC_MSYS_DMC0_BASE

	ldr     r1, =0x0
	str     r1, [r0, #0x0]			/* Enable full synchronizer instead of half synchronization */
	
@	ldr	r1, =0x0
@	str	r1, [r0, #0xC]				/* this is a register at 0xF1E0_000C, which does not exist in S5PV210 */
	
#ifdef CONFIG_MCP_SINGLE

#ifdef SH_TEST
	ldr	r2, =ELFIN_UART_CONSOLE_BASE
	ldr	r1, =0x43434343
	str	r1, [r2, #UTXH_OFFSET]		@'C'  Transmit one character
#endif @SH_TEST

	/* DMC0 Drive Strength (Setting 2X) */
	
	ldr	r0, =ELFIN_GPIO_BASE			/* 0xE020_0000 */

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_0DRV_SR_OFFSET]	/* All DDR2 I/O drivers at one from maximum driving strainght except SDIO */

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_1DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_2DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_3DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_4DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_5DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_6DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_7DRV_SR_OFFSET]

	ldr	r1, =0x00002AAA
	str	r1, [r0, #MP1_8DRV_SR_OFFSET]


	/* DMC1 Drive Strength (Setting 2X) */
	
	ldr	r0, =ELFIN_GPIO_BASE
	
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_0DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_1DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_2DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_3DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_4DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_5DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_6DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_7DRV_SR_OFFSET]

	ldr	r1, =0x00002AAA
	str	r1, [r0, #MP2_8DRV_SR_OFFSET]
	
	/* DMC0 initialization at single Type*/
	ldr	r0, =APB_DMC_0_BASE

	ldr	r1, =0x00101000				@PhyControl0 DLL parameter setting, manual 0x00101000
	str	r1, [r0, #DMC_PHYCONTROL0]

	ldr	r1, =0x00000086				@PhyControl1 DLL parameter setting, LPDDR/LPDDR2 Case /* WARNING the lsbs 6 is the value suggested for DDR2 @ 200MHz */
	str	r1, [r0, #DMC_PHYCONTROL1]

	ldr	r1, =0x00101002				@PhyControl0 DLL on
	str	r1, [r0, #DMC_PHYCONTROL0]

	ldr	r1, =0x00101003				@PhyControl0 DLL start  ??ZZZ why not using Differential DQS
	str	r1, [r0, #DMC_PHYCONTROL0]

find_lock_val:
	ldr	r1, [r0, #DMC_PHYSTATUS]		@Load Phystatus register value
	and	r2, r1, #0x7
	cmp	r2, #0x7				@Loop until DLL is locked
	bne	find_lock_val

	and	r1, #0x3fc0 
	mov	r2, r1, LSL #18
	orr	r2, r2, #0x100000
	orr	r2 ,r2, #0x1000	
		
	orr	r1, r2, #0x3				@Force Value locking
	str	r1, [r0, #DMC_PHYCONTROL0]

#if 0	/* Memory margin test 10.01.05 */
	orr	r1, r2, #0x1				@DLL off
	str	r1, [r0, #DMC_PHYCONTROL0]
#endif

	/* setting DDR2 */
	ldr	r1, =0x0FFF1010				@ConControl auto refresh off
	str	r1, [r0, #DMC_CONCONTROL]

	ldr	r1, =DMC0_MEMCONTROL				@MemControl BL=4, 2 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	str	r1, [r0, #DMC_MEMCONTROL]
	
	ldr	r1, =DMC0_MEMCONFIG_0			@MemConfig0 512MB config, 8 banks,Mapping Method[12:15]0:linear, 1:linterleaved, 2:Mixed
	str	r1, [r0, #DMC_MEMCONFIG0]

	ldr	r1, =DMC0_MEMCONFIG_1			@MemConfig1
	str	r1, [r0, #DMC_MEMCONFIG1]

	ldr	r1, =0xFF000000				@PrechConfig
	str	r1, [r0, #DMC_PRECHCONFIG]
	
	ldr	r1, =DMC0_TIMINGA_REF			@TimingAref	7.8us*133MHz=1038(0x40E), 100MHz=780(0x30C), 20MHz=156(0x9C), 10MHz=78(0x4E)
	str	r1, [r0, #DMC_TIMINGAREF]
	
	ldr	r1, =DMC0_TIMING_ROW			@TimingRow	for @200MHz
	str	r1, [r0, #DMC_TIMINGROW]

	ldr	r1, =DMC0_TIMING_DATA			@TimingData	CL=3
	str	r1, [r0, #DMC_TIMINGDATA]
	
	ldr	r1, =DMC0_TIMING_PWR			@TimingPower
	str	r1, [r0, #DMC_TIMINGPOWER]

	ldr	r1, =0x07000000				@DirectCmd	chip0 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]

#ifdef SH_TEST
	ldr	r2, =ELFIN_UART_CONSOLE_BASE
	ldr	r1, =0x41414141
	str	r1, [r2, #UTXH_OFFSET]		@'A'  Transmit one character
#endif @SH_TEST
	  
	ldr       r2, =0x28				@ 400ns delay per JEDEC DDR2 spec. 
loop400ns:
    subs     r2, r2, #0x1
    beq     loop400ns

#ifdef SH_TEST
	ldr	r2, =ELFIN_UART_CONSOLE_BASE
	ldr	r1, =0x42424242
	str	r1, [r2, #UTXH_OFFSET]		@'B'  Transmit one character
#endif @SH_TEST

	ldr	r1, =0x01000000				@DirectCmd	chip0 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00020000				@DirectCmd	chip0 EMRS2
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00030000				@DirectCmd	chip0 EMRS3
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00010400			@DirectCmd	chip0 EMRS1 (MEM DLL on, DQS# disable)
@o	ldr	r1, =0x00010001			@DirectCmd	chip0 EMRS1 (MEM DLL on, DQS# disable)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00001532				@DirectCmd	chip0 MRS (MEM DLL reset) CL=3, BL=4
@o	ldr	r1, =0x00000532				@DirectCmd	chip0 MRS (MEM DLL reset) CL=3, BL=4
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01000000				@DirectCmd	chip0 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05000000				@DirectCmd	chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05000000				@DirectCmd	chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00000432				@DirectCmd	chip0 MRS (MEM DLL unreset)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00010780				@DirectCmd	chip0 EMRS1 (OCD default)
@o	ldr	r1, =0x00010381				@DirectCmd	chip0 EMRS1 (OCD default)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00010400				@DirectCmd	chip0 EMRS1 (OCD exit)
@o	ldr	r1, =0x00010001				@DirectCmd	chip0 EMRS1 (OCD exit)
	str	r1, [r0, #DMC_DIRECTCMD]
	
;	ldr	r1, =0x07100000				@DirectCmd	chip1 Deselect
;	str	r1, [r0, #DMC_DIRECTCMD]

;	ldr	r1, =0x01100000				@DirectCmd	chip1 PALL
;	str	r1, [r0, #DMC_DIRECTCMD]
	
;	ldr	r1, =0x00120000				@DirectCmd	chip1 EMRS2
;	str	r1, [r0, #DMC_DIRECTCMD]
	
;	ldr	r1, =0x00130000				@DirectCmd	chip1 EMRS3
;	str	r1, [r0, #DMC_DIRECTCMD]
	
;	ldr	r1, =0x00110400				@DirectCmd	chip1 EMRS1 (MEM DLL on, DQS# disable)
;	str	r1, [r0, #DMC_DIRECTCMD]
	
;	ldr	r1, =0x00100542				@DirectCmd	chip1 MRS (MEM DLL reset) CL=4, BL=4
;	str	r1, [r0, #DMC_DIRECTCMD]
	
;	ldr	r1, =0x01100000				@DirectCmd	chip1 PALL
;	str	r1, [r0, #DMC_DIRECTCMD]
	
;	ldr	r1, =0x05100000				@DirectCmd	chip1 REFA
;	str	r1, [r0, #DMC_DIRECTCMD]
	
;	ldr	r1, =0x05100000				@DirectCmd	chip1 REFA
;	str	r1, [r0, #DMC_DIRECTCMD]
	
;	ldr	r1, =0x00100442				@DirectCmd	chip1 MRS (MEM DLL unreset)
;	str	r1, [r0, #DMC_DIRECTCMD]
	
;	ldr	r1, =0x00110780				@DirectCmd	chip1 EMRS1 (OCD default)
;	str	r1, [r0, #DMC_DIRECTCMD]
		
;	ldr	r1, =0x00110400				@DirectCmd	chip1 EMRS1 (OCD exit)
;	str	r1, [r0, #DMC_DIRECTCMD]
		
	ldr	r1, =0x0FF01030				@ConControl	auto refresh on
	str	r1, [r0, #DMC_CONCONTROL]
		
	ldr	r1, =0xFFFF00FF				@PwrdnConfig
	str	r1, [r0, #DMC_PWRDNCONFIG]
		
	ldr	r1, =DMC0_MEMCONTROL				@MemControl	BL=4, 2 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	str	r1, [r0, #DMC_MEMCONTROL]

	/* DMC1 initialization */
	ldr	r0, =APB_DMC_1_BASE

	ldr	r1, =0x00101000				@Phycontrol0 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL0]

	ldr	r1, =0x00000086				@Phycontrol1 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL1]

	ldr	r1, =0x00101002				@PhyControl0 DLL on
	str	r1, [r0, #DMC_PHYCONTROL0]

	ldr	r1, =0x00101003				@PhyControl0 DLL start
	str	r1, [r0, #DMC_PHYCONTROL0]
find_lock_val1:
	ldr	r1, [r0, #DMC_PHYSTATUS]		@Load Phystatus register value
	and	r2, r1, #0x7
	cmp	r2, #0x7				@Loop until DLL is locked
	bne	find_lock_val1
	
	and	r1, #0x3fc0 
	mov	r2, r1, LSL #18
	orr	r2, r2, #0x100000
	orr	r2, r2, #0x1000
		
	orr	r1, r2, #0x3				@Force Value locking
	str	r1, [r0, #DMC_PHYCONTROL0]

#if 0	/* Memory margin test 10.01.05 */
	orr	r1, r2, #0x1				@DLL off
	str	r1, [r0, #DMC_PHYCONTROL0]
#endif

	/* settinf fot DDR2 */
	ldr	r0, =APB_DMC_1_BASE

	ldr	r1, =0x0FFF1010				@auto refresh off
	str	r1, [r0, #DMC_CONCONTROL]

	ldr	r1, =DMC1_MEMCONTROL			@MemControl	BL=4, 2 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	str	r1, [r0, #DMC_MEMCONTROL]

	ldr	r1, =DMC1_MEMCONFIG_0			@MemConfig0	512MB config, 8 banks,Mapping Method[12:15]0:linear, 1:linterleaved, 2:Mixed
	str	r1, [r0, #DMC_MEMCONFIG0]

	ldr	r1, =DMC1_MEMCONFIG_1			@MemConfig1
	str	r1, [r0, #DMC_MEMCONFIG1]

	ldr	r1, =0xFF000000
	str	r1, [r0, #DMC_PRECHCONFIG]

	ldr	r1, =DMC1_TIMINGA_REF			@TimingAref	7.8us*133MHz=1038(0x40E), 100MHz=780(0x30C), 20MHz=156(0x9C), 10MHz=78(0x4
	str	r1, [r0, #DMC_TIMINGAREF]

	ldr	r1, =DMC1_TIMING_ROW			@TimingRow	for @200MHz
	str	r1, [r0, #DMC_TIMINGROW]

	ldr	r1, =DMC1_TIMING_DATA			@TimingData	CL=3
	str	r1, [r0, #DMC_TIMINGDATA]

	ldr	r1, =DMC1_TIMING_PWR			@TimingPower
	str	r1, [r0, #DMC_TIMINGPOWER]


	ldr	r1, =0x07000000				@DirectCmd	chip0 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]
	  
#ifdef SH_TEST
	ldr	r2, =ELFIN_UART_CONSOLE_BASE
	ldr	r1, =0x43434343
	str	r1, [r2, #UTXH_OFFSET]		@'C'  Transmit one character
#endif @SH_TEST

	ldr       r2, =0x28				@ 400ns delay per JEDEC DDR2 spec. 
loop400ns_2:
    subs     r2, r2, #0x1
    beq     loop400ns_2
    
#ifdef SH_TEST
	ldr	r2, =ELFIN_UART_CONSOLE_BASE
	ldr	r1, =0x44444444
	str	r1, [r2, #UTXH_OFFSET]		@'D'  Transmit one character
#endif @SH_TEST

	ldr	r1, =0x01000000				@DirectCmd	chip0 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00020000				@DirectCmd	chip0 EMRS2
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00030000				@DirectCmd	chip0 EMRS3
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00010400				@DirectCmd	chip0 EMRS1 (MEM DLL on, DQS# disable)
@o	ldr	r1, =0x00010001				@DirectCmd	chip0 EMRS1 (MEM DLL on, DQS# disable)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00001532				@DirectCmd	chip0 MRS (MEM DLL reset) CL=3, BL=4
@o	ldr	r1, =0x00000532				@DirectCmd	chip0 MRS (MEM DLL reset) CL=3, BL=4
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01000000				@DirectCmd	chip0 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05000000				@DirectCmd	chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05000000				@DirectCmd	chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00000432				@DirectCmd	chip0 MRS (MEM DLL unreset)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00010780				@DirectCmd	chip0 EMRS1 (OCD default)
@o	ldr	r1, =0x00010381				@DirectCmd	chip0 EMRS1 (OCD default)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00010400				@DirectCmd	chip0 EMRS1 (OCD exit)
@o	ldr	r1, =0x00010001				@DirectCmd	chip0 EMRS1 (OCD exit)
	str	r1, [r0, #DMC_DIRECTCMD]

;	ldr	r1, =0x07100000				@DirectCmd	chip1 Deselect
;	str	r1, [r0, #DMC_DIRECTCMD]

;	ldr	r1, =0x01100000				@DirectCmd	chip1 PALL
;	str	r1, [r0, #DMC_DIRECTCMD]

;	ldr	r1, =0x00120000				@DirectCmd	chip1 EMRS2
;	str	r1, [r0, #DMC_DIRECTCMD]

;	ldr	r1, =0x00130000				@DirectCmd	chip1 EMRS3
;	str	r1, [r0, #DMC_DIRECTCMD]

;	ldr	r1, =0x00110440				@DirectCmd	chip1 EMRS1 (MEM DLL on, DQS# disable)
;	str	r1, [r0, #DMC_DIRECTCMD]

;	ldr	r1, =0x00100542				@DirectCmd	chip1 MRS (MEM DLL reset) CL=4, BL=4
;	str	r1, [r0, #DMC_DIRECTCMD]

;	ldr	r1, =0x01100000				@DirectCmd	chip1 PALL
;	str	r1, [r0, #DMC_DIRECTCMD]

;	ldr	r1, =0x05100000				@DirectCmd	chip1 REFA
;	str	r1, [r0, #DMC_DIRECTCMD]

;	ldr	r1, =0x05100000				@DirectCmd	chip1 REFA
;	str	r1, [r0, #DMC_DIRECTCMD]

;	ldr	r1, =0x00100442				@DirectCmd	chip1 MRS (MEM DLL unreset)
;	str	r1, [r0, #DMC_DIRECTCMD]

;	ldr	r1, =0x00110780				@DirectCmd	chip1 EMRS1 (OCD default)
;	str	r1, [r0, #DMC_DIRECTCMD]

;	ldr	r1, =0x00110400				@DirectCmd	chip1 EMRS1 (OCD exit)
;	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x0FF01030				@ConControl	auto refresh on
	str	r1, [r0, #DMC_CONCONTROL]

	ldr	r1, =0xFFFF00FF				@PwrdnConfig	
	str	r1, [r0, #DMC_PWRDNCONFIG]

	ldr	r1, =DMC1_MEMCONTROL			@MemControl	BL=4, 2 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	str	r1, [r0, #DMC_MEMCONTROL]
	
#else	// CONFIG_MCP_AC / CONFIG_MCP_H / CONFIG_MCP_B / CONFIG_MCP_D

	/* DMC0 initialization */
	ldr	r0, =APB_DMC_0_BASE

	ldr	r1, =0x00101000				@Phycontrol0 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL0]

	ldr	r1, =0x00000084				@Phycontrol1 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL1]

	ldr	r1, =0x00101002				@Phycontrol2 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL0]

	ldr	r1, =0x00101003				@Dll on
	str	r1, [r0, #DMC_PHYCONTROL0]

find_lock_val:
	ldr	r1, [r0, #DMC_PHYSTATUS]		@Load Phystatus register value
	and 	r2, r1, #0x7
	cmp	r2, #0x7				@Loop until DLL is locked
	bne	find_lock_val
	
	and	r1, #0x3fc0 
	mov	r2, r1, LSL #18
	orr	r2, r2, #0x100000
	orr	r2, r2, #0x1000
			
	orr	r1, r2, #0x3				@Force Value locking
	str	r1, [r0, #DMC_PHYCONTROL0]
#if 1 /* DRAM margin test 10.01.06 */
	orr	r1, r2, #0x1				@DLL off
	str	r1, [r0, #DMC_PHYCONTROL0]
#endif
	ldr	r1, =0x0fff1010				@auto refresh off
	str	r1, [r0, #DMC_CONCONTROL]

	ldr	r1, =0x00212100				
	str	r1, [r0, #DMC_MEMCONTROL]

	ldr	r1, =DMC0_MEMCONFIG_0
	str	r1, [r0, #DMC_MEMCONFIG0]

	ldr	r1, =DMC0_MEMCONFIG_1
	str	r1, [r0, #DMC_MEMCONFIG1]

	ldr	r1, =0xff000000
	str	r1, [r0, #DMC_PRECHCONFIG]

	ldr	r1, =DMC0_TIMINGA_REF
	str	r1, [r0, #DMC_TIMINGAREF]

	ldr	r1, =DMC0_TIMING_ROW			@TimingRow	@133MHz
	str	r1, [r0, #DMC_TIMINGROW]

	ldr	r1, =DMC0_TIMING_DATA
	str	r1, [r0, #DMC_TIMINGDATA]

	ldr	r1, =DMC0_TIMING_PWR			@Timing Power
	str	r1, [r0, #DMC_TIMINGPOWER]

	ldr	r1, =0x07000000				@chip0 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01000000				@chip0 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05000000				@chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05000000				@chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00000032				@chip0 MRS
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x07100000				@chip1 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01100000				@chip1 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05100000				@chip1 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05100000				@chip1 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00100032				@chip1 MRS
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x0FFF20B0			@ConControl auto refresh on
	str	r1, [r0, #DMC_CONCONTROL]

	ldr	r1, =0xFFFF00FF				@PwrdnConfig
	str	r1, [r0, #DMC_PWRDNCONFIG]

	#if defined CONFIG_MCP_AC
	ldr	r1, =0x00212113				@MemControl
	str	r1, [r0, #DMC_MEMCONTROL]
	#elif defined CONFIG_MCP_H
	ldr	r1, =0x00212113				@MemControl
	str	r1, [r0, #DMC_MEMCONTROL]
	#elif defined CONFIG_MCP_B
	ldr	r1, =0x00212113				@MemControl
	str	r1, [r0, #DMC_MEMCONTROL]	
	#elif defined CONFIG_MCP_D
	ldr	r1, =0x00212113				@MemControl
	str	r1, [r0, #DMC_MEMCONTROL]	
	#elif defined CONFIG_MCP_SINGLE
	ldr	r1, =0x00212113				@MemControl
	str	r1, [r0, #DMC_MEMCONTROL]	
	#else

	#error "You should define memory type (AC type or H type)"

	#endif	

	/* DMC1 initialization */
	ldr	r0, =APB_DMC_1_BASE

	ldr	r1, =0x00101000				@Phycontrol0 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL0]

	ldr	r1, =0x00000084				@Phycontrol1 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL1]

	ldr	r1, =0x00101002				@Phycontrol2 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL0]

	ldr	r1, =0x00101003				@Dll on
	str	r1, [r0, #DMC_PHYCONTROL0]

find_lock_val1:
	ldr	r1, [r0, #DMC_PHYSTATUS]		@Load Phystatus register value
	and 	r2, r1, #0x7	
	cmp	r2, #0x7				@Loop until DLL is locked
	bne	find_lock_val1
	
	and	r1, #0x3fc0 
	mov	r2, r1, LSL #18
	orr	r2, r2, #0x100000
	orr	r2, r2, #0x1000
	
	orr	r1, r2, #0x3				@Force Value locking
	str	r1, [r0, #DMC_PHYCONTROL0]

#if 1	/* Memory margin test 10.01.05 */
	orr	r1, r2, #0x1				@DLL off
	str	r1, [r0, #DMC_PHYCONTROL0]
#endif
	ldr	r0, =APB_DMC_1_BASE

	ldr	r1, =0x0FFF1010				@auto refresh off
	str	r1, [r0, #DMC_CONCONTROL]

	ldr	r1, =0x00212100				
	str	r1, [r0, #DMC_MEMCONTROL]

	ldr	r1, =DMC1_MEMCONFIG_0
	str	r1, [r0, #DMC_MEMCONFIG0]

	ldr	r1, =DMC1_MEMCONFIG_1
	str	r1, [r0, #DMC_MEMCONFIG1]

	ldr	r1, =0xff000000
	str	r1, [r0, #DMC_PRECHCONFIG]

	ldr	r1, =DMC1_TIMINGA_REF
	str	r1, [r0, #DMC_TIMINGAREF]

	ldr	r1, =DMC1_TIMING_ROW			@TimingRow	@133MHz
	str	r1, [r0, #DMC_TIMINGROW]

	ldr	r1, =DMC1_TIMING_DATA
	str	r1, [r0, #DMC_TIMINGDATA]

	ldr	r1, =DMC1_TIMING_PWR			@Timing Power
	str	r1, [r0, #DMC_TIMINGPOWER]

	ldr	r1, =0x07000000				@chip0 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01000000				@chip0 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05000000				@chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05000000				@chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00000032				@chip0 MRS
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x07100000				@chip1 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01100000				@chip1 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05100000				@chip1 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05100000				@chip1 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00100032				@chip1 MRS
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x0FFF10B0				@ConControl auto refresh on
	str	r1, [r0, #DMC_CONCONTROL]

	ldr	r1, =0xFFFF00FF				@PwrdnConfig
	str	r1, [r0, #DMC_PWRDNCONFIG]

	ldr	r1, =0x00212113				@MemControl
	str	r1, [r0, #DMC_MEMCONTROL]

#endif
	mov	pc, lr


/* Below code is for ARM926EJS and ARM1026EJS */
	.globl cleanDCache
cleanDCache:
	mrc	p15, 0, pc, c7, c10, 3	/* test/clean D-Cache */
	bne	cleanDCache
	mov	pc, lr

	.globl cleanFlushDCache
cleanFlushDCache:
	mrc	p15, 0, pc, c7, c14, 3	/* test/cleanflush D-Cache */
	bne	cleanFlushDCache
	mov	pc, lr

	.globl cleanFlushCache
cleanFlushCache:
	mrc	p15, 0, pc, c7, c14, 3	/* test/cleanflush D-Cache */
	bne	cleanFlushCache
	mcr	p15, 0, r0, c7, c5, 0	/* flush I-Cache */
	mov	pc, lr

	.ltorg

