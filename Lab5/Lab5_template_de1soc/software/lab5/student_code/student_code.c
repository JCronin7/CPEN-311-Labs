/*
 * student_code.c
 *
 *  Created on: Mar 7, 2017
 *      Author: user
 */

#include <system.h>
#include <io.h>
#include "sys/alt_irq.h"
#include "student_code.h"
#include "altera_avalon_pio_regs.h"

#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
void handle_lfsr_interrupts(void* context)
#else
void handle_lfsr_interrupts(void* context, alt_u32 id)
void handle_color_interrupts(void* context, alt_u32 id)
#endif
{
	#ifdef LFSR_VAL_BASE
	#ifdef LFSR_CLK_INTERRUPT_GEN_BASE
	#ifdef DDS_INCREMENT_BASE
	
	volatile int lfsr_val = IORD_ALTERA_AVALON_PIO_DATA(LFSR_VAL_BASE);

	if (lfsr_val == 1)
		IOWR_ALTERA_AVALON_PIO_DATA(DDS_INCREMENT_BASE, 430); //  5Hz
	else
		IOWR_ALTERA_AVALON_PIO_DATA(DDS_INCREMENT_BASE, 86); //  1Hz

	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(LFSR_CLK_INTERRUPT_GEN_BASE, 0);
	IORD_ALTERA_AVALON_PIO_EDGE_CAP(LFSR_CLK_INTERRUPT_GEN_BASE);

	#endif
	#endif
	#endif
}
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
void handle_CC_interrupts(void* context)
#else
void handle_CC_interrupts(void* context, alt_u32 id)
#endif
{
	#ifdef COLOR_CHANGE_DATA_BASE
	#ifdef COLOR_CHANGE_INTERRUPT_BASE
	#ifdef COLOR_CHANGE_OUT_BASE

	volatile int key_val,
				 red,
				 blue,
				 green,
				 new_RBG,
				 sw,
				 inc,
				 r_flag, g_flag, b_flag,
				 startup,
				 strobe;
	key_val = IORD_ALTERA_AVALON_PIO_DATA(COLOR_CHANGE_DATA_BASE);
	strobe = (key_val >> 3) % 2;
	startup = (key_val >> 30) % 2;
	sw = (key_val >> 28) % 4;
	red = (key_val >> 20);
	red = red % 256;
	green = (key_val >> 12);
	green = green % 256;
	blue = (key_val >> 4);
	blue = blue % 256;
	key_val = key_val % 8;

	r_flag = (key_val >> 2) % 2;
	g_flag = (key_val >> 1) % 2;
	b_flag = key_val % 2;

	if (startup == 0)
	{
		red = 127;
		blue = 127;
		green = 127;
		startup = 1;
	}

	switch (sw)
	{
	case 0: inc = 1;
			break;
	case 1: inc = 16;
			break;
	case 2: inc = -1;
			break;
	case 3: inc = -16;
			break;
	}

	if (strobe == 0){
		if (r_flag == 1)
			if ((inc == 1 && red < 255) ||
					(inc == -1 && red > 0) ||
						(inc == 16 && red < 240) ||
							(inc == -16 && red > 15))
				red = (red + inc) % 256;
		if (g_flag == 1)
			if ((inc == 1 && green < 255) ||
					(inc == -1 && green > 0) ||
						(inc == 16 && green < 240) ||
							(inc == -16 && green > 15))
				green = (green + inc) % 256;
		if (b_flag == 1)
			if ((inc == 1 && blue < 255) ||
					(inc == -1 && blue > 0) ||
						(inc == 16 && blue < 240) ||
							(inc == -16 && blue > 15))
				blue = (blue + inc) % 256;
	} else {
		if (r_flag == 1)
			red = (red + inc) % 256;
		if (g_flag == 1)
			green = (green + inc) % 256;
		if (b_flag == 1)
			blue = (blue + inc) % 256;
	}

	new_RBG = (startup << 24) + (red << 16) + (green << 8) + blue;
	IOWR_ALTERA_AVALON_PIO_DATA(COLOR_CHANGE_OUT_BASE, new_RBG); //  5Hz

	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(COLOR_CHANGE_INTERRUPT_BASE, 0);
	IORD_ALTERA_AVALON_PIO_EDGE_CAP(COLOR_CHANGE_INTERRUPT_BASE);

	#endif
	#endif
	#endif
}

/* Initialize the button_pio. */

void init_lfsr_interrupt()
{
	#ifdef LFSR_VAL_BASE
	#ifdef LFSR_CLK_INTERRUPT_GEN_BASE
	#ifdef DDS_INCREMENT_BASE
	
	/* Enable interrupts */
	IOWR_ALTERA_AVALON_PIO_IRQ_MASK(LFSR_CLK_INTERRUPT_GEN_BASE, 0x1);
	/* Reset the edge capture register. */
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(LFSR_CLK_INTERRUPT_GEN_BASE, 0x0);
	/* Register the interrupt handler. */
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
	alt_ic_isr_register(LFSR_CLK_INTERRUPT_GEN_IRQ_INTERRUPT_CONTROLLER_ID, LFSR_CLK_INTERRUPT_GEN_IRQ, handle_lfsr_interrupts, 0x0, 0x0);
#else
	alt_irq_register( LFSR_CLK_INTERRUPT_GEN_IRQ, NULL,	handle_button_interrupts);
#endif
	
	#endif
	#endif
	#endif
}
void init_color_change_interrupt()
{
	#ifdef COLOR_CHANGE_DATA_BASE
	#ifdef COLOR_CHANGE_INTERRUPT_BASE
	#ifdef COLOR_CHANGE_OUT_BASE

	/* Enable interrupts */
	IOWR_ALTERA_AVALON_PIO_IRQ_MASK(COLOR_CHANGE_INTERRUPT_BASE, 0x1);
	/* Reset the edge capture register. */
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(COLOR_CHANGE_INTERRUPT_BASE, 0x0);
	/* Register the interrupt handler. */
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
	alt_ic_isr_register(COLOR_CHANGE_INTERRUPT_IRQ_INTERRUPT_CONTROLLER_ID, COLOR_CHANGE_INTERRUPT_IRQ, handle_CC_interrupts, 0x0, 0x0);
#else
	alt_irq_register( COLOR_CHANGE_INTERRUPT_IRQ, NULL,	handle_button_interrupts);
#endif

	#endif
	#endif
	#endif
}

