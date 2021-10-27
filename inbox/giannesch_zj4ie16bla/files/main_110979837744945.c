


/*
 * GccApplication1.c
 *
 * Created: 19/05/2021 17:40:27
 * Author : giann
 */ 

#include <avr/io.h>
#include <stdio.h>
#include <stdlib.h>


#include <avr/io.h>
#include <avr/interrupt.h>

int interrWrite = 0;
int interrRead = 0;

	
	int Ram [32] ;
	int counter = 0;
	int address = 0 ;
    int value =0;
	
int main(){
	

	//clock for write 
	PORTD.DIR |= PIN1_bm; //PIN is output
	
	//prescaler=1024
	TCA0.SINGLE.CTRLA= TCA_SINGLE_CLKSEL_DIV1024_gc;
	TCA0.SINGLE.PER = 100; //select the resolution
	TCA0.SINGLE.CMP0 = 80; //select the duty cycle
	TCA0.SINGLE.CMP1 = 40; //select the duty cycle
	//select Single_Slope_PWM
	TCA0.SINGLE.CTRLB |= TCA_SINGLE_WGMODE_SINGLESLOPE_gc;
	//enable interrupt Overflow
	TCA0.SINGLE.INTCTRL = TCA_SINGLE_OVF_bm;
	//enable interrupt COMP0
	TCA0.SINGLE.INTCTRL |= TCA_SINGLE_CMP0_bm;
	TCA0.SINGLE.INTCTRL |= TCA_SINGLE_CMP1_bm;
	
	TCA0.SINGLE.CTRLA |= TCA_SINGLE_ENABLE_bm; //EnablTCA_Se
	

	
	PORTF.PIN5CTRL |= PORT_PULLUPEN_bm | PORT_ISC_BOTHEDGES_gc;
    PORTF.PIN6CTRL |= PORT_PULLUPEN_bm | PORT_ISC_BOTHEDGES_gc;

	sei();
	
	while (counter< 32){
		
			address = rand() % 16;
	}
}

ISR(TCA0_OVF_vect){
	//clear the interrupt flag
	int intflags = TCA0.SINGLE.INTFLAGS;
	TCA0.SINGLE.INTFLAGS = intflags;
	PORTD.OUT |= PIN1_bm; //PIN is off
	//if write
	
	if(interrWrite == 1){
		Ram[counter] = address;
		counter++;
	}
	interrWrite = 0;
	
}


ISR(TCA0_CMP0_vect){
	//clear the interrupt flag
	int intflags = TCA0.SINGLE.INTFLAGS;
	TCA0.SINGLE.INTFLAGS = intflags;
	PORTD.OUTCLR |= PIN4_bm; //PIN is off
	
	if(interrWrite == 1){
		Ram[counter] = address;
		counter++;
	}
	interrWrite = 0;

}

ISR(TCA0_CMP1_vect){
	//clear the interrupt flag
	int intflags = TCA0.SINGLE.INTFLAGS;
	TCA0.SINGLE.INTFLAGS = intflags;
	PORTD.OUTCLR |= PIN2_bm; //PIN is off
	
	if(interrRead == 1){
		value = Ram[counter-1];
		PORTD.OUT = value;
	}
	interrRead =0;
	
}




ISR(PORTF_PORT_vect){
//clear the interrupt flag
int intflags = PORTF.INTFLAGS;
PORTF.INTFLAGS=intflags;

if(intflags == 0x20 )
interrWrite=1;

if(intflags == 0x40 )
interrRead = 1;

}