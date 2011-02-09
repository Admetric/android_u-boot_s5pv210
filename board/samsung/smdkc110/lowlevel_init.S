/*
 * Memory Setup stuff - taken from blob memsetup.S
 *
 * Copyright (C) 1999 2000 2001 Erik Mouw (J.A.K.Mouw@its.tudelft.nl) and
 *                     Jan-Derk Bakker (J.D.Bakker@its.tudelft.nl)
 *
 * Modified for the Samsung SMDK2410 by
 * (C) Copyright 2002
 * David Mueller, ELSOFT AG, <d.mueller@elsoft.ch>
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */


#include <config.h>
#include <version.h>

#include <s5pc110.h>
#include "smdkc110_val.h"

_TEXT_BASE:
	.word	TEXT_BASE

	.globl lowlevel_init
lowlevel_init:
	push	{lr}

	/* IO Retention release */
	ldr	r0, =(ELFIN_CLOCK_POWER_BASE + OTHERS_OFFSET)
	ldr	r1, [r0]
	ldr	r2, =IO_RET_REL
	orr	r1, r1, r2
	str	r1, [r0]

	/* Disable Watchdog */
	ldr	r0, =ELFIN_WATCHDOG_BASE	/* 0xE2700000 */
	mov	r1, #0
	str	r1, [r0]

#if 0	/* SRAM(2MB) init for SMDKC110 */
	/* GPJ1 SROM_ADDR_16to21 */
	ldr	r0, =ELFIN_GPIO_BASE
	
	ldr	r1, [r0, #GPJ1CON_OFFSET]
	bic	r1, r1, #0xFFFFFF
	ldr	r2, =0x444444
	orr	r1, r1, r2
	str	r1, [r0, #GPJ1CON_OFFSET]

	ldr	r1, [r0, #GPJ1PUD_OFFSET]
	ldr	r2, =0x3ff
	bic	r1, r1, r2
	str	r1, [r0, #GPJ1PUD_OFFSET]

	/* GPJ4 SROM_ADDR_16to21 */
	ldr	r1, [r0, #GPJ4CON_OFFSET]
	bic	r1, r1, #(0xf<<16)
	ldr	r2, =(0x4<<16)
	orr	r1, r1, r2
	str	r1, [r0, #GPJ4CON_OFFSET]

	ldr	r1, [r0, #GPJ4PUD_OFFSET]
	ldr	r2, =(0x3<<8)
	bic	r1, r1, r2
	str	r1, [r0, #GPJ4PUD_OFFSET]


	/* CS0 - 16bit sram, enable nBE, Byte base address */
	ldr	r0, =ELFIN_SROM_BASE	/* 0xE8000000 */
	mov	r1, #0x1
	str	r1, [r0]
#endif

#if	0
	/* PS_HOLD pin(GPH0_0) set to high */
	ldr	r0, =(ELFIN_CLOCK_POWER_BASE + PS_HOLD_CONTROL_OFFSET)
	ldr	r1, [r0]
	orr	r1, r1, #0x300	
	orr	r1, r1, #0x1	
	str	r1, [r0]
#endif

	/* when we already run in ram, we don't need to relocate U-Boot.
	 * and actually, memory controller must be configured before U-Boot
	 * is running in ram.
	 */
	ldr	r0, =0xff000fff
	bic	r1, pc, r0		/* r0 <- current base addr of code */
	ldr	r2, _TEXT_BASE		/* r1 <- original base addr in ram */
	bic	r2, r2, r0		/* r0 <- current base addr of code */
	cmp     r1, r2                  /* compare r0, r1                  */
	beq     1f			/* r0 == r1 then skip sdram init   */



        ldr     r0, =ELFIN_GPIO_BASE    /* Set SYSPWRON 1 before setting PLL*/
        ldr     r1, =0x00000100
        str     r1, [r0, #GPH1CON_OFFSET]
        ldr     r1, =0x4
        str     r1, [r0, #GPH1DAT_OFFSET]
        ldr     r1, =0x5545
        str     r1, [r0, #GPH1PUD_OFFSET]


	/* init system clock */
	bl system_clock_init

	bl mem_ctrl_asm_init

	bl mxm_v210_gpio_init

1:
	/* for UART */
	bl uart_asm_init

	bl tzpc_init

#if defined(CONFIG_NAND)
	/* simple init for NAND */
	bl nand_asm_init
#endif

	/* should be reviewed by system part */
	
	ldr     r0, =(ELFIN_CLOCK_POWER_BASE+RST_STAT_OFFSET)
        ldr     r1, [r0]
        bic     r1, r1, #0xfff6ffff
        cmp     r1, #0x10000
        beq     wakeup_reset
	cmp	r1, #0x80000
	beq	wakeup_reset

	ldr	r0, =ELFIN_UART_CONSOLE_BASE
	ldr	r1, =0x4b4b4b4b
	str	r1, [r0, #UTXH_OFFSET]

	pop	{pc}

wakeup_reset:


	/*Load return address and jump to kernel*/
	ldr	r0, =(INF_REG_BASE+INF_REG0_OFFSET)
	ldr	r1, [r0]	/* r1 = physical address of s3c6400_cpu_resume function*/

	mov	pc, r1		/*Jump to kernel (sleep-s3c6400.S)*/
	nop
	nop

/*
 * system_clock_init: Initialize core clock and bus clock.
 * void system_clock_init(void)
 */
system_clock_init:

	ldr	r0, =ELFIN_CLOCK_POWER_BASE	@0xe0100000

	/* Set Mux to FIN */
	ldr	r1, =0x0
	str	r1, [r0, #CLK_SRC0_OFFSET]

	/* Disable PLL */
	ldr	r1, =0x0
	str	r1, [r0, #APLL_CON0_OFFSET]
	ldr	r1, =0x0
	str	r1, [r0, #MPLL_CON_OFFSET]

	ldr	r1, =0x0
	str	r1, [r0, #MPLL_CON_OFFSET]

	ldr   	r1, [r0, #CLK_DIV0_OFFSET]
	ldr	r2, =CLK_DIV0_MASK
	bic	r1, r1, r2

	ldr	r2, =CLK_DIV0_VAL
	orr	r1, r1, r2
	str	r1, [r0, #CLK_DIV0_OFFSET]

	ldr	r1, =APLL_VAL
	str	r1, [r0, #APLL_CON0_OFFSET]

	ldr	r1, =MPLL_VAL
	str	r1, [r0, #MPLL_CON_OFFSET]

	ldr	r1, =VPLL_VAL
	str	r1, [r0, #VPLL_CON_OFFSET]
#if defined(CONFIG_EVT1)
	ldr	r1, =AFC_ON
	str	r1, [r0, #APLL_CON1_OFFSET]
#endif
	mov	r1, #0x10000
1:	subs	r1, r1, #1
	bne	1b

	ldr	r1, [r0, #CLK_SRC0_OFFSET]
	ldr	r2, =0x10001111
	orr	r1, r1, r2
	str	r1, [r0, #CLK_SRC0_OFFSET]

#if defined(CONFIG_MCP_AC)

	/* CLK_SRC6[25:24] -> OneDRAM clock sel = MPLL */
	ldr	r1, [r0, #CLK_SRC6_OFFSET]
	bic	r1, r1, #(0x3<<24)
	orr	r1, r1, #0x01000000
	str	r1, [r0, #CLK_SRC6_OFFSET]

	/* CLK_DIV6[31:28] -> 4=1/5, 3=1/4(166MHZ@667MHz), 2=1/3 */
	ldr	r1, [r0, #CLK_DIV6_OFFSET]
	bic	r1, r1, #(0xF<<28)
	orr	r1, r1, #0x30000000
	str	r1, [r0, #CLK_DIV6_OFFSET]

#elif defined (CONFIG_MCP_H)

	/* CLK_SRC6[25:24] -> OneDRAM clock sel = 00:SCLKA2M, 01:SCLKMPLL */
	ldr	r1, [r0, #CLK_SRC6_OFFSET]
	bic	r1, r1, #(0x3<<24)
	orr	r1, r1, #0x00000000
	str	r1, [r0, #CLK_SRC6_OFFSET]

	/* CLK_DIV6[31:28] -> 4=1/5, 3=1/4(166MHZ@667MHz), 2=1/3 */
	ldr	r1, [r0, #CLK_DIV6_OFFSET]
	bic	r1, r1, #(0xF<<28)
	orr	r1, r1, #0x00000000
	str	r1, [r0, #CLK_DIV6_OFFSET]	

#elif defined (CONFIG_MCP_B) || defined (CONFIG_MCP_D)

	/* CLK_SRC6[25:24] -> OneDRAM clock sel = 00:SCLKA2M, 01:SCLKMPLL */
	ldr	r1, [r0, #CLK_SRC6_OFFSET]
	bic	r1, r1, #(0x3<<24)
	orr	r1, r1, #0x01000000
	str	r1, [r0, #CLK_SRC6_OFFSET]

	/* CLK_DIV6[31:28] -> 4=1/5, 3=1/4(166MHZ@667MHz), 2=1/3 */
	ldr	r1, [r0, #CLK_DIV6_OFFSET]
	bic	r1, r1, #(0xF<<28)
	orr	r1, r1, #0x30000000
	str	r1, [r0, #CLK_DIV6_OFFSET]

#endif	

	mov	pc, lr

/*
 * Setting MXM-V210 GPIO
 */

mxm_v210_gpio_init:

        ldr     r0, =ELFIN_GPIO_BASE
        ldr     r1, =0x22222222
        str     r1, [r0, #GPA0CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPA0DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPA0PUD_OFFSET]
        ldr     r1, =0x00002222
        str     r1, [r0, #GPA1CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPA1DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPA1PUD_OFFSET]
        ldr     r1, =0x11011111
        str     r1, [r0, #GPBCON_OFFSET]
        ldr     r1, =0x10
        str     r1, [r0, #GPBDAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPBPUD_OFFSET]
        ldr     r1, =0x00044444
        str     r1, [r0, #GPC0CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPC0DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPC0PUD_OFFSET]
        ldr     r1, =0x00022202
        str     r1, [r0, #GPC1CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPC1DAT_OFFSET]
        ldr     r1, =0x4
        str     r1, [r0, #GPC1PUD_OFFSET]
        ldr     r1, =0x00002220
        str     r1, [r0, #GPD0CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPD0DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPD0PUD_OFFSET]
        ldr     r1, =0x00222222
        str     r1, [r0, #GPD1CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPD1DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPD1PUD_OFFSET]
        ldr     r1, =0x22222222
        str     r1, [r0, #GPE0CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPE0DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPE0PUD_OFFSET]
        ldr     r1, =0x00022222
        str     r1, [r0, #GPE1CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPE1DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPE1PUD_OFFSET]
        ldr     r1, =0x22222222
        str     r1, [r0, #GPF0CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPF0DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPF0PUD_OFFSET]
        ldr     r1, =0x22222222
        str     r1, [r0, #GPF1CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPF1DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPF1PUD_OFFSET]
        ldr     r1, =0x22222222
        str     r1, [r0, #GPF2CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPF2DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPF2PUD_OFFSET]
        ldr     r1, =0x00002222
        str     r1, [r0, #GPF3CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPF3DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPF3PUD_OFFSET]
        ldr     r1, =0x02222222
        str     r1, [r0, #GPG0CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPG0DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPG0PUD_OFFSET]
        ldr     r1, =0x02222222
        str     r1, [r0, #GPG1CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPG1DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPG1PUD_OFFSET]
        ldr     r1, =0x02222222
        str     r1, [r0, #GPG2CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPG2DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPG2PUD_OFFSET]
        ldr     r1, =0x02222222
        str     r1, [r0, #GPG3CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPG3DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPG3PUD_OFFSET]
        ldr     r1, =0x00000000
        str     r1, [r0, #GPH0CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPH0DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPH0PUD_OFFSET]
        ldr     r1, =0x114411FF
        str     r1, [r0, #GPH1CON_OFFSET]
        ldr     r1, =0xCC
        str     r1, [r0, #GPH1DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPH1PUD_OFFSET]
        ldr     r1, =0x11110111
        str     r1, [r0, #GPH2CON_OFFSET]
        ldr     r1, =0x6
        str     r1, [r0, #GPH2DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPH2PUD_OFFSET]
        ldr     r1, =0x01101110
        str     r1, [r0, #GPH3CON_OFFSET]
        ldr     r1, =0x62
        str     r1, [r0, #GPH3DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPH3PUD_OFFSET]
        ldr     r1, =0x00000000
        str     r1, [r0, #GPICON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPIDAT_OFFSET]
        ldr     r1, =0x1555
        str     r1, [r0, #GPIPUD_OFFSET]
        ldr     r1, =0x22222222
        str     r1, [r0, #GPJ0CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPJ0DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPJ0PUD_OFFSET]
        ldr     r1, =0x00222222
        str     r1, [r0, #GPJ1CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPJ1DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPJ1PUD_OFFSET]
        ldr     r1, =0x22222222
        str     r1, [r0, #GPJ2CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPJ2DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPJ2PUD_OFFSET]
        ldr     r1, =0x22222222
        str     r1, [r0, #GPJ3CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPJ3DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPJ3PUD_OFFSET]
        ldr     r1, =0x22222222
        str     r1, [r0, #GPJ4CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPJ4DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #GPJ4PUD_OFFSET]
        ldr     r1, =0x22222322
        str     r1, [r0, #MP01CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #MP01DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #MP01PUD_OFFSET]
        ldr     r1, =0x00002222
        str     r1, [r0, #MP02CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #MP02DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #MP02PUD_OFFSET]
        ldr     r1, =0x00022222
        str     r1, [r0, #MP03CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #MP03DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #MP03PUD_OFFSET]
        ldr     r1, =0x22222222
        str     r1, [r0, #MP04CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #MP04DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #MP04PUD_OFFSET]
        ldr     r1, =0x22222222
        str     r1, [r0, #MP05CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #MP05DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #MP05PUD_OFFSET]
        ldr     r1, =0x22222222
        str     r1, [r0, #MP06CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #MP06DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #MP06PUD_OFFSET]
        ldr     r1, =0x22222222
        str     r1, [r0, #MP07CON_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #MP07DAT_OFFSET]
        ldr     r1, =0x0
        str     r1, [r0, #MP07PUD_OFFSET]
        ldr     r1, =0x6480
        str     r1, [r0, #ETC2PUD_OFFSET]


        ldr     r1, =0x4C
        str     r1, [r0, #GPH1DAT_OFFSET]

/*      wait 200us  reset  dm9000       */
        mov     r1, #0x10000
1:      subs    r1, r1, #1
        bne     1b

        ldr     r1, =0xCC
        str     r1, [r0, #GPH1DAT_OFFSET]

        mov     pc, lr



/*
 * uart_asm_init: Initialize UART in asm mode, 115200bps fixed.
 * void uart_asm_init(void)
 */
uart_asm_init:

	/* set GPIO(GPA) to enable UART */
	@ GPIO setting for UART
	ldr	r0, =ELFIN_GPIO_BASE
	ldr	r1, =0x22222222
	str   	r1, [r0, #GPA0CON_OFFSET]

	ldr     r1, =0x2222
	str     r1, [r0, #GPA1CON_OFFSET]

	// HP V210 use. SMDK not use.
#if defined(CONFIG_VOGUES)
	ldr    r1, =0x100
	str    r1, [r0, #GPC0CON_OFFSET]

	ldr    r1, =0x4
	str    r1, [r0, #GPC0DAT_OFFSET]
#endif

	ldr	r0, =ELFIN_UART_CONSOLE_BASE		@0xEC000000
	mov	r1, #0x0
	str	r1, [r0, #UFCON_OFFSET]
	str	r1, [r0, #UMCON_OFFSET]

	mov	r1, #0x3
	str	r1, [r0, #ULCON_OFFSET]

	ldr	r1, =0x3c5
	str	r1, [r0, #UCON_OFFSET]

	ldr	r1, =UART_UBRDIV_VAL
	str	r1, [r0, #UBRDIV_OFFSET]

	ldr	r1, =UART_UDIVSLOT_VAL
	str	r1, [r0, #UDIVSLOT_OFFSET]

	ldr	r1, =0x4f4f4f4f
	str	r1, [r0, #UTXH_OFFSET]		@'O'

	mov	pc, lr

/*
 * Nand Interface Init for SMDKC100
 */
nand_asm_init:

	/* Setting GPIO for NAND */
	/* This setting is NAND initialze code at booting time in iROM. */

	ldr	r0, =ELFIN_GPIO_BASE
	
	ldr	r1, [r0, #MP01CON_OFFSET]
	bic	r1, r1, #(0xf<<8)
	orr	r1, r1, #(0x3<<8)
	str	r1, [r0, #MP01CON_OFFSET]

	ldr	r1, [r0, #MP01PUD_OFFSET]
	bic	r1, r1, #(0x3<<4)
	str	r1, [r0, #MP01PUD_OFFSET]

	ldr	r1, [r0, #MP03CON_OFFSET]
	bic	r1, r1, #0xFFFFFF
	ldr	r2, =0x22222222
	orr	r1, r1, r2
	str	r1, [r0, #MP03CON_OFFSET]

	ldr	r1, [r0, #MP03PUD_OFFSET]
	ldr	r2, =0x3fff
	bic	r1, r1, r2
	str	r1, [r0, #MP03PUD_OFFSET]

	ldr	r0, =ELFIN_NAND_BASE

	ldr	r1, [r0, #NFCONF_OFFSET]
	ldr	r2, =0x777F
	bic	r1, r1, r2
	ldr	r2, =NFCONF_VAL
	orr	r1, r1, r2
	str	r1, [r0, #NFCONF_OFFSET]

	ldr	r1, [r0, #NFCONT_OFFSET]
	ldr	r2, =0x707C7
	bic	r1, r1, r2
	ldr	r2, =NFCONT_VAL
	orr	r1, r1, r2
	str	r1, [r0, #NFCONT_OFFSET]

	ldr	r1, [r0, #NFCONF_OFFSET]
	orr	r1, r1, #0x70
	orr	r1, r1, #0x7700
	str     r1, [r0, #NFCONF_OFFSET]

	ldr	r1, [r0, #NFCONT_OFFSET]
	orr	r1, r1, #0x03
	str     r1, [r0, #NFCONT_OFFSET]

	mov	pc, lr

/*
 * Setting TZPC[TrustZone Protection Controller]
 */

tzpc_init:

	ldr	r0, =ELFIN_TZPC0_BASE
 	mov	r1, #0x0
 	str	r1, [r0]
 	mov	r1, #0xff
 	str	r1, [r0, #TZPC_DECPROT0SET_OFFSET]
 	str	r1, [r0, #TZPC_DECPROT1SET_OFFSET]
	str	r1, [r0, #TZPC_DECPROT2SET_OFFSET] 	

 	ldr 	r0, =ELFIN_TZPC1_BASE
 	str	r1, [r0, #TZPC_DECPROT0SET_OFFSET]
 	str	r1, [r0, #TZPC_DECPROT1SET_OFFSET]
	str	r1, [r0, #TZPC_DECPROT2SET_OFFSET] 	

 	ldr	r0, =ELFIN_TZPC2_BASE
 	str	r1, [r0, #TZPC_DECPROT0SET_OFFSET]
 	str	r1, [r0, #TZPC_DECPROT1SET_OFFSET]
	str	r1, [r0, #TZPC_DECPROT2SET_OFFSET]
	str	r1, [r0, #TZPC_DECPROT3SET_OFFSET] 

 	ldr	r0, =ELFIN_TZPC3_BASE
 	str	r1, [r0, #TZPC_DECPROT0SET_OFFSET]
 	str	r1, [r0, #TZPC_DECPROT1SET_OFFSET]
	str	r1, [r0, #TZPC_DECPROT2SET_OFFSET] 	

 	mov	pc, lr


#ifdef CONFIG_ENABLE_MMU

	#ifdef CONFIG_MCP_SINGLE
/*
 * MMU Table for SMDKC110
 * 0x0000_0000 -- 0xBFFF_FFFF => Not Allowed
 * 0xB000_0000 -- 0xB7FF_FFFF => A:0xB000_0000 -- 0xB7FF_FFFF
 * 0xC000_0000 -- 0xC7FF_FFFF => A:0x3000_0000 -- 0x37FF_FFFF
 * 0xC800_0000 -- 0xDFFF_FFFF => Not Allowed
 * 0xE000_0000 -- 0xFFFF_FFFF => A:0xE000_0000 -- 0XFFFF_FFFF
 */

	/* form a first-level section entry */
.macro FL_SECTION_ENTRY base,ap,d,c,b
	.word (\base << 20) | (\ap << 10) | \
	      (\d << 5) | (1<<4) | (\c << 3) | (\b << 2) | (1<<1)
.endm
.section .mmudata, "a"
	.align 14
	// the following alignment creates the mmu table at address 0x4000.
	.globl mmu_table
mmu_table:
	.set __base,0
	// Access for iRAM
	.rept 0x100
	FL_SECTION_ENTRY __base,3,0,0,0
	.set __base,__base+1
	.endr

	// Not Allowed
	.rept 0x200 - 0x100
	.word 0x00000000
	.endr

	.set __base,0x200
	// should be accessed
	.rept 0x600 - 0x200
	FL_SECTION_ENTRY __base,3,0,1,1
	.set __base,__base+1
	.endr

	.rept 0x800 - 0x600
	.word 0x00000000
	.endr

	.set __base,0x800
	// should be accessed
	.rept 0xb00 - 0x800
	FL_SECTION_ENTRY __base,3,0,0,0
	.set __base,__base+1
	.endr

/*	.rept 0xc00 - 0xb00
	.word 0x00000000
	.endr */

	.set __base,0xB00
	.rept 0xc00 - 0xb00
	FL_SECTION_ENTRY __base,3,0,0,0
	.set __base,__base+1
	.endr

	.set __base,0x200
	// 256MB for SDRAM with cacheable
	.rept 0xD00 - 0xC00
	FL_SECTION_ENTRY __base,3,0,1,1
	.set __base,__base+1
	.endr

	// access is not allowed.
	@.rept 0xD00 - 0xC80
	@.word 0x00000000
	@.endr

	.set __base,0xD00
	// 1:1 mapping for debugging with non-cacheable
	.rept 0x1000 - 0xD00
	FL_SECTION_ENTRY __base,3,0,0,0
	.set __base,__base+1
	.endr	
	
	#else	// CONFIG_MCP_AC, CONFIG_MCP_H, CONFIG_MCP_B

/*
 * MMU Table for SMDKC110
 * 0x0000_0000 -- 0xBFFF_FFFF => Not Allowed
 * 0xB000_0000 -- 0xB7FF_FFFF => A:0xB000_0000 -- 0xB7FF_FFFF
 * 0xC000_0000 -- 0xC7FF_FFFF => A:0x3000_0000 -- 0x37FF_FFFF
 * 0xC800_0000 -- 0xDFFF_FFFF => Not Allowed
 * 0xE000_0000 -- 0xFFFF_FFFF => A:0xE000_0000 -- 0XFFFF_FFFF
 */

	/* form a first-level section entry */
.macro FL_SECTION_ENTRY base,ap,d,c,b
	.word (\base << 20) | (\ap << 10) | \
	      (\d << 5) | (1<<4) | (\c << 3) | (\b << 2) | (1<<1)
.endm
.section .mmudata, "a"
	.align 14
	// the following alignment creates the mmu table at address 0x4000.
	.globl mmu_table
mmu_table:
	.set __base,0
	// Access for iRAM
	.rept 0x100
	FL_SECTION_ENTRY __base,3,0,0,0
	.set __base,__base+1
	.endr

	// Not Allowed
	.rept 0x300 - 0x100
	.word 0x00000000
	.endr

	.set __base,0x300
	// should be accessed
	.rept 0x400 - 0x300
	FL_SECTION_ENTRY __base,3,0,1,1
	.set __base,__base+1
	.endr

	// DRAM - DMC1 area - used for STL_write : djpark (20090729)
	.set __base,0x400
	// should be accessed
	.rept 0x500 - 0x400
	FL_SECTION_ENTRY __base,3,0,1,1
	.set __base,__base+1
	.endr

	.rept 0x800 - 0x500
	.word 0x00000000
	.endr

	.set __base,0x800
	// should be accessed
	.rept 0xb00 - 0x800
	FL_SECTION_ENTRY __base,3,0,0,0
	.set __base,__base+1
	.endr

/*	.rept 0xc00 - 0xb00
	.word 0x00000000
	.endr */

	.set __base,0xB00
	.rept 0xc00 - 0xb00
	FL_SECTION_ENTRY __base,3,0,0,0
	.set __base,__base+1
	.endr

	.set __base,0x300
	// 256MB for SDRAM with cacheable
	.rept 0xD00 - 0xC00
	FL_SECTION_ENTRY __base,3,0,1,1
	.set __base,__base+1
	.endr

	// access is not allowed.
	@.rept 0xD00 - 0xC80
	@.word 0x00000000
	@.endr

	.set __base,0xD00
	// 1:1 mapping for debugging with non-cacheable
	.rept 0x1000 - 0xD00
	FL_SECTION_ENTRY __base,3,0,0,0
	.set __base,__base+1
	.endr
	#endif
#endif

