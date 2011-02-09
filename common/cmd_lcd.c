/*

 */

#include <common.h>
#include <command.h>


#define Outp32(addr, data)	(*(volatile u32 *)(addr) = (data))

int do_lcd_test ( cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
	u32 x,y;
	u32* pFb;

//	u32 uFb = 0x41000000;
	u32 uFb = 0x24000000;

	u32 uR = 0xff0000;
	u32 uG=0x00ff00;
	u32 uB=0x0000ff;
	
	Outp32(0xe0200040, 0x10000000);
	Outp32(0xe0200048, 0x1555);
	Outp32(0xe020004c, 0xc000);
	Outp32(0xe0200040, 0x10010000);
	Outp32(0xe0200048, 0x1455);
	Outp32(0xe020004c, 0xc300);
	Outp32(0xe0200040, 0x10110000);
	Outp32(0xe0200048, 0x1055);
	Outp32(0xe020004c, 0xcf00);
	Outp32(0xe02000c0, 0x1);
	Outp32(0xe02000c8, 0x54);
	Outp32(0xe02000cc, 0x3);
	Outp32(0xe02000c0, 0x11);
	Outp32(0xe02000c8, 0x50);
	Outp32(0xe02000cc, 0xf);
	Outp32(0xe02000a0, 0x1001);
	Outp32(0xe02000a8, 0x15);
	Outp32(0xe02000ac, 0xc0);
	Outp32(0xe0200c00, 0x1000010);
	Outp32(0xe0200c08, 0x4455);
	Outp32(0xe0200c0c, 0x3000);
	Outp32(0xe0200040, 0x11110000);
	Outp32(0xe0200048, 0x55);
	Outp32(0xe020004c, 0xff00);
	Outp32(0xe0200040, 0x11110100);
	Outp32(0xe0200048, 0x55);
	Outp32(0xe020004c, 0xff00);
	Outp32(0xe0200044, 0x80);
	Outp32(0xe0200044, 0x98);
	Outp32(0xe0200044, 0xb9);
	Outp32(0xe0200044, 0xbb);
	Outp32(0xe0200044, 0xbb);
	Outp32(0xe02000a4, 0xd);
	Outp32(0xe0200c04, 0xd1);
	Outp32(0xe0200044, 0xfb);
	Outp32(0xe0200044, 0xff);
	Outp32(0xe0200c04, 0x91);
	Outp32(0xe0200c04, 0xd1);
	Outp32(0xe0200c04, 0xd3);


	Outp32(0xe0200120, 0x22222222);	//set GPF0 as LVD_HSYNC,VSYNC,VCLK,VDEN,VD[3:0]
	Outp32(0xe0200128,0x0);			//set pull-up,down disable
	Outp32(0xe0200140, 0x22222222);	//set GPF1 as VD[11:4]
	Outp32(0xe0200148,0x0);			//set pull-up,down disable
	Outp32(0xe0200160, 0x22222222);	//set GPF2 as VD[19:12]
	Outp32(0xe0200168,0x0);			//set pull-up,down disable
	Outp32(0xe0200180, 0x00002222);	//set GPF3 as VD[23:20]
	Outp32(0xe0200188,0x0);			//set pull-up,down disable

	//--------- S5PC110 EVT0 needs MAX drive strength	---------//
	Outp32(0xe020012c,0xffffffff);			//set GPF0 drive strength max by WJ.KIM(09.07.17)
	Outp32(0xe020014c,0xffffffff);			//set GPF1 drive strength max by WJ.KIM(09.07.17)
	Outp32(0xe020016c,0xffffffff);			//set GPF2 drive strength max by WJ.KIM(09.07.17)
	Outp32(0xe020018c,0x3ff);					//set GPF3 drive strength max by WJ.KIM(09.07.17)

	Outp32(0xf8000004, 0x60);
	Outp32(0xf8000010, 0xe0e0305);
	Outp32(0xf8000014, 0x3103020);
	Outp32(0xf8000170, 0x0);
	Outp32(0xf8000018, 0x17fd55);
	Outp32(0xf8000000, 0x0);
	Outp32(0xf8000000, 0x254);
	Outp32(0xf8000130, 0x20);
	Outp32(0xf8000020, 0x0);
	Outp32(0xf8000024, 0x0);
	Outp32(0xf8000028, 0x0);
	Outp32(0xf800002c, 0x0);
	Outp32(0xf8000030, 0x0);
	Outp32(0xf8000034, 0x0);
	Outp32(0xf8000180, 0x0);
	Outp32(0xf8000184, 0x0);
	Outp32(0xf8000188, 0x0);
	Outp32(0xf800018c, 0x0);
	Outp32(0xf8000190, 0x0);
	Outp32(0xf8000140, 0x0);
	Outp32(0xf8000148, 0x0);
	Outp32(0xf8000150, 0x0);
	Outp32(0xf8000158, 0x0);
	Outp32(0xf8000058, 0x0);
	Outp32(0xf8000208, 0x0);
	Outp32(0xf800020c, 0x0);
	Outp32(0xf8000068, 0x0);
	Outp32(0xf8000210, 0x0);
	Outp32(0xf8000214, 0x0);
	Outp32(0xf8000078, 0x0);
	Outp32(0xf8000218, 0x0);
	Outp32(0xf800021c, 0x0);
	Outp32(0xf8000088, 0x0);
	Outp32(0xf8000220, 0x0);
	Outp32(0xf8000224, 0x0);
	Outp32(0xf8000260, 0x1);
	Outp32(0xf8000048, 0x100200);
	Outp32(0xf8000200, 0xffffff);
	Outp32(0xf8000204, 0xffffff);
	Outp32(0xf8000034, 0x0);
	Outp32(0xf8000020, 0x802c);
	Outp32(0xf80000a0, uFb+0x00000000);
	Outp32(0xf80000d0, uFb+0x00400800);
	Outp32(0xf80000a4, uFb+0x00000000);
	Outp32(0xf80000d4, uFb+0x00400800);
	Outp32(0xf80020a0, uFb+0x00000000);
	Outp32(0xf80020d0, uFb+0x00400800);
	Outp32(0xf8000100, 0x1558);
	Outp32(0xf8000040, 0x0);
	Outp32(0xf8000044, 0x2aaaff);
	Outp32(0xf8000020, 0x802d);
	Outp32(0xf8000034, 0x1);
	Outp32(0xf8000020, 0x802d);
	Outp32(0xf8000034, 0x1);
//	Outp32(0xf8000000, 0x257);
	Outp32(0xf8000000, 0x57); //===> MPLL should be 667 !!!!
	Outp32(0xf80001a4, 0x3);

	Outp32(0xe0107008,0x2); //syscon output path
	Outp32(0xe0100204,0x700000); //syscon fimdclk = mpll
	
	pFb = (u32*)uFb;
	for(y=0;y<768;y++)
	for(x=0;x<1366;x++)
	{
		if( (x/(1366/8) == 0))
			*pFb++ = uR;
		else if( (x/(1366/8) == 1))
			*pFb++ = uG;
		else if( (x/(1366/8) == 2))
			*pFb++ = uB;
		else if( (x/(1366/8) <= 3))
			*pFb++ = uR|uG;
		else if( (x/(1366/8) <= 4))
			*pFb++ = uR|uB;
		else if( (x/(1366/8) <= 5))
			*pFb++ = uG|uB;
		else if( (x/(1366/8) <= 6))
			*pFb++ = 0;
		else
			*pFb++ = 0xffffff;

	}
//	GLIB_InitInstance(CODEC_MEM_ST, 1366, 768, RGB24);
//	GLIB_DrawPattern(1366, 768);	

	return 0;
}

/***************************************************/

U_BOOT_CMD(
	lcd,	1,	1,	do_lcd_test,		\
	"test pattern \n",				\
);


