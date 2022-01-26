#include "dac.h"
#include "delay.h"
#include "Beep.h"

//////////////////////////////////////////////////////////////////////////////////	 
//±¾³ÌÐòÖ»¹©Ñ§Ï°Ê¹ÓÃ£¬Î´¾­×÷ÕßÐí¿É£¬²»µÃÓÃÓÚÆäËüÈÎºÎÓÃÍ¾
//ALIENTEKÕ½½¢STM32¿ª·¢°å
//DAC ´úÂë	   
//ÕýµãÔ­×Ó@ALIENTEK
//¼¼ÊõÂÛÌ³:www.openedv.com
//ÐÞ¸ÄÈÕÆÚ:2012/9/8
//°æ±¾£ºV1.0
//°æÈ¨ËùÓÐ£¬µÁ°æ±Ø¾¿¡£
//Copyright(C) ¹ãÖÝÊÐÐÇÒíµç×Ó¿Æ¼¼ÓÐÏÞ¹«Ë¾ 2009-2019
//All rights reserved									  
//////////////////////////////////////////////////////////////////////////////////
//DACÍ¨µÀ1Êä³ö³õÊ¼»¯
void Dac1_Init(void)
{
  
	GPIO_InitTypeDef GPIO_InitStructure;
	DAC_InitTypeDef DAC_InitType;

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE );	  //Ê¹ÄÜPORTAÍ¨µÀÊ±ÖÓ
   	RCC_APB1PeriphClockCmd(RCC_APB1Periph_DAC, ENABLE );	  //Ê¹ÄÜDACÍ¨µÀÊ±ÖÓ 

	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_4;				 // ¶Ë¿ÚÅäÖÃ
 	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AIN; 		 //Ä£ÄâÊäÈë
 	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
 	GPIO_Init(GPIOA, &GPIO_InitStructure);
	GPIO_SetBits(GPIOA,GPIO_Pin_4)	;//PA.4 Êä³ö¸ß
					
	DAC_InitType.DAC_Trigger=DAC_Trigger_None;	//²»Ê¹ÓÃ´¥·¢¹¦ÄÜ TEN1=0
	DAC_InitType.DAC_WaveGeneration=DAC_WaveGeneration_None;//²»Ê¹ÓÃ²¨ÐÎ·¢Éú
	DAC_InitType.DAC_LFSRUnmask_TriangleAmplitude=DAC_LFSRUnmask_Bit0;//ÆÁ±Î¡¢·ùÖµÉèÖÃ
	DAC_InitType.DAC_OutputBuffer=DAC_OutputBuffer_Disable ;	//DAC1Êä³ö»º´æ¹Ø±Õ BOFF1=1
    DAC_Init(DAC_Channel_1,&DAC_InitType);	 //³õÊ¼»¯DACÍ¨µÀ1

	DAC_Cmd(DAC_Channel_1, ENABLE);  //Ê¹ÄÜDAC1
  
    DAC_SetChannel1Data(DAC_Align_12b_R, 0);  //12Î»ÓÒ¶ÔÆëÊý¾Ý¸ñÊ½ÉèÖÃDACÖµ

}

//ÉèÖÃÍ¨µÀ1Êä³öµçÑ¹
//vol:0~3300,´ú±í0~3.3V
void Dac1_Set_Vol(u16 vol)
{
	float temp=vol;
	temp/=1000;
	temp=temp*4096/3.3;
	DAC_SetChannel1Data(DAC_Align_12b_R,temp);//12Î»ÓÒ¶ÔÆëÊý¾Ý¸ñÊ½ÉèÖÃDACÖµ
}
//Ê¹µÃdacµÄÊä³öµçÑ¹²¨ÐÎÎªÕýÏÒ²¨
//u16 freÊÇ²¨ÐÎ·¢ÉúµÄÆµÂÊ
//u16 NÊÇ¹æ¶¨²¨ÐÎ·¢ÉúµÄ´ÎÊý
//u 16dacvalÊÇÖ¸¶¨µÄ³õÊ¼²¨ÐÎÁãµã£¬ÓÉÓÚÌâÄ¿1¹æ¶¨¸øµÄÎª1.65£¬¶ÔÓ¦µÄÈ¡2049
//*Sine12bit¹æ¶¨µÄÎªÒ»ÖÜÆÚµÄÕýÏÒ²¨µçÑ¹µÄ²ÉÑùÖµ£¬256
void Dac1_sine(u16 fre,u16 N,u16 dacval,int *Sine12bit,u8 on,u16 len)
{
	float T;
	int i=0;
	int j=0;
	int dt;
	T=1000000/fre;//Tµ¥Î»Îªus£¬¼ÆËãµÃµ½Ò»ÖÜÆÚµÄÊ±¼ä
	dt=T/len;//¼ÆËãµÃµ½Ò»ÖÜÆÚÀ´Ò»¸ö²ÉÑùÖµ±£³ÖµÄÊ±¼ä
		DAC->DHR12R1=dacval;//³õÊ¼ÖµÎª0£
		for(i=0;i<N;i++)
		{
			for(j=0;j<len;j++)
			{
			  DAC->DHR12R1=Sine12bit[j];		//Êä³ö£¬½«²ÉÑùÖµ¸ødac¼Ä´æÆ÷£¬ÊµÏÖµçÑ¹µÄ¸Ä±ä
				delay_us(dt);	
			}
		}	
}





















































