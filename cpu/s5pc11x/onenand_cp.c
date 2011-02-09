#include <common.h>
#include <linux/mtd/onenand_regs.h>
#include <asm/io.h>

/* This code support ONLY 4KB OneNAND!!!!! - djpark */

/* jsgood: temporary */
#ifdef CONFIG_BOOT_ONENAND_IROM

//void ONENAND_WriteReg()

//#define ONENAND_ReadPage_4burst(a,b,c)	(((int(*)(uint, uint, uint *))(*((uint *)(0x0c004010))))(a,b,c))

#define ONENAND_BASE		0xB0000000
#define ONENAND_WRITESIZE	0x1000

void ONENAND_ReadPage(
	void* base, unsigned int block, unsigned int page)
{
	int len;
	int ret;
	short* dest = (short *)base;
	const short* src = (void *)ONENAND_BASE + 0x400;

	// Block Number Set
	writew(block, ONENAND_BASE + ONENAND_REG_START_ADDRESS1);
	// Page (Sector) Number Set: FPA, FSA
	writew((page << ONENAND_FPA_SHIFT),
			ONENAND_BASE + ONENAND_REG_START_ADDRESS8);
	// BSA, BSC
	writew(0, ONENAND_BASE + ONENAND_REG_START_BUFFER);

	// Interrupt clear
	writew(ONENAND_INT_CLEAR, ONENAND_BASE + ONENAND_REG_INTERRUPT);

	writew(ONENAND_CMD_READ, ONENAND_BASE + ONENAND_REG_COMMAND);

	while(1)
	{
		ret = readw(ONENAND_BASE + ONENAND_REG_INTERRUPT);
		if (ret & ONENAND_REG_CTRL_STATUS)
			break;
	}

	len = ONENAND_WRITESIZE >> 1;
	while (len-- > 0)
	{
		*dest++ = *src++;
	}
}

void onenand_bl2_copy(void)
{
	int block, page;
	//volatile unsigned int base = 0x27e00000;
	volatile unsigned int base = 0x33e00000;

	for (block = 0; block < 2; block++) {
		for (page = 0; page < 64; page++) {
			ONENAND_ReadPage((void *)base, block, page);
			base += ONENAND_WRITESIZE;
		}
	}
}

#endif /* CONFIG_BOOT_ONENAND */

