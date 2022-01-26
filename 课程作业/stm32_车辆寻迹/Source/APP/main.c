/**
* @par Copyright (C): 2010-2019, Shenzhen Yahboom Tech
* @file         main.c	
* @author       liusen
* @version      V1.0
* @date         2017.07.17
* @brief        Ö÷º¯Êý
* @details      
* @par History  
*                 
* version:		liusen_20170717
*/
#include "stm32f10x.h"
#include "app_motor.h"
#include "app_linewalking.h"
#include "bsp.h"
#include "bsp_adc.h"
#include "bsp_gs.h"
#include "bsp_timer.h"
#include "sys.h"



int main(void)
{	
	bsp_init();

	while (1)
	{
		extern int ADC_Convert_Value;
		extern int Status;
		extern int adc_value;
		extern int adc_delta;

			if (adc_value>1530 &&adc_value<1600)
			{
				
				Car_Stop();
			}
			else{
				app_LineWalking();
		}			
	}
 								    
}
