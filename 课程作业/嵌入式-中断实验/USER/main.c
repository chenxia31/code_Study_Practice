#include "led.h"
#include "delay.h"
#include "key.h"
#include "sys.h"
#include "lcd.h"
#include "usart.h"	 	 
#include "dac.h"
#include "adc.h"
#include "usmart.h"
#include "beep.h"
#include "string.h"
#include "timer.h"
//ALIENTEK战舰STM32开发板实验19
//DAC 实验  
//技术支持：www.openedv.com
//广州市星翼电子科技有限公司  
 int main(void)
 {	 
	u8 len;
	char c[200]; 
	 u8 t;
	delay_init();	    	 //延时函数初始化	  
	NVIC_Configuration(); 	 //设置NVIC中断分组2:2位抢占优先级，2位响应优先级
	uart_init(9600);	 	//串口初始化为9600
	KEY_Init();			  //初始化按键程序
 	LED_Init();			     //LED端口初始化
	usmart_dev.init(72);	//初始化USMART	
	Dac1_Init();				//DAC初始化
	printf("\r\n定时器中断实验\r\n");
	printf("\r\n何志杨、谢远翔、徐晨龙组合\r\n");  
TIM3_Int_Init(999,7199);//10Khz的计数频率，计数到5000为500ms  	
TIM4_Int_Init(249,1);
	while(1)
	 {
		if(USART_RX_STA&0x8000)
		     {		   
			       len=USART_RX_STA&0x3fff;
						 for(t=0;t<len;t++)
			      {
			        c[t]=USART_RX_BUF[t];
							USART_SendData(USART1, USART_RX_BUF[t]);//???1????
							while(USART_GetFlagStatus(USART1,USART_FLAG_TC)!=SET);//??????
						}
						USART_RX_STA=0;
						USART_ClearFlag(USART1, USART_FLAG_RXNE); 
						memset(c,0,200);
				}
		else
				{
					
				}
 }
}
