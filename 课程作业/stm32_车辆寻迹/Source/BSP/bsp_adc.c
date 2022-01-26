/**
* @par Copyright (C): 2010-2019, Shenzhen Yahboom Tech
* @file         bsp_adc.c
* @author       liusen
* @version      V1.0
* @date         2017.08.17
* @brief        ADC
* @details      
* @par History  见如下说明
*                 
* version:		liusen_20170817
*/

#include "bsp_adc.h"
#include "stm32f10x_adc.h"
#include "delay.h"
# include "app_motor.h"

#define	ADC_x								ADC1

int ADC_Convert_Value=0;

// ADC GPIO 设置
 void ADCx_GPIO_Config(void)
{  //?PA1??
	GPIO_InitTypeDef GPIO_InitStruct;
	//??GPIO??
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA | RCC_APB2Periph_ADC1 , ENABLE ); //使能 ADC1 通道时钟
		RCC_ADCCLKConfig(RCC_PCLK2_Div6); //设置 ADC 分频因子 6

	//??????
	GPIO_InitStruct.GPIO_Pin =GPIO_Pin_0;
	GPIO_InitStruct.GPIO_Mode = GPIO_Mode_AIN;//模拟输入
	GPIO_Init(GPIOA, &GPIO_InitStruct); //初始化 GPIOA.1
}

// ADC设置
void ADCx_Config(void)
{  //ADC1  Channel_1
	ADC_InitTypeDef ADC_InitStruct;
	//??ADC??
		RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA | RCC_APB2Periph_ADC1 , ENABLE ); //使能 ADC1 通道时钟


	ADC_DeInit(ADC1); //复位 ADC1,将外设 ADC1 的全部寄存器重设为缺省值
	
	ADC_InitStruct.ADC_Mode = ADC_Mode_Independent;		// ?????ADC,?????
	ADC_InitStruct.ADC_ScanConvMode = DISABLE;  		//单通道模式
	ADC_InitStruct.ADC_ContinuousConvMode = ENABLE;		// 重复转换模式
	ADC_InitStruct.ADC_ExternalTrigConv = ADC_ExternalTrigConv_None;// 转换由软件而不是外部出发启动
	ADC_InitStruct.ADC_DataAlign = ADC_DataAlign_Right;	// 右对齐
	ADC_InitStruct.ADC_NbrOfChannel = 1;   // 顺序进行规则转换的ADC通道的数目
	ADC_Init(ADC1,&ADC_InitStruct);// 根据参数初始化外设
	

	
		//设置指定 ADC 的规则组通道，设置它们的转化顺序和采样时间
	ADC_RegularChannelConfig(ADC1,ADC_Channel_1,1,ADC_SampleTime_239Cycles5);
	
	// ADC转换产生中断，在中断服务程序中毒去转换值
	ADC_ITConfig(ADC1, ADC_IT_EOC, ENABLE);

	ADC_Cmd(ADC1, ENABLE); //使能指定的 ADC1
	ADC_ResetCalibration(ADC1); //开启复位校准
	while(ADC_GetResetCalibrationStatus(ADC1)); //等待复位校准结束
	ADC_StartCalibration(ADC1); //开启 AD 校准
	while(ADC_GetCalibrationStatus(ADC1)); //等待校准结束
	
	// 由于没有采用外部出发，所以使用软件出发ADC转换;使用软件转换功能
	ADC_SoftwareStartConvCmd(ADC1,ENABLE);
}

void ADC_NVIC_Config(void)
{
  NVIC_InitTypeDef NVIC_InitStructure;
	// ?????
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);

  // ???????
  NVIC_InitStructure.NVIC_IRQChannel = ADC1_2_IRQn;
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 2;
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 4;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);
}

int count=0;
int adc_value_temp=0;
int adc_value;
int temp;
int adc_delta=0;
void ADC1_2_IRQHandler(void)
{	
	

	if (ADC_GetITStatus(ADC_x,ADC_IT_EOC)==SET) 
	{
		 //??ADC????
		temp=ADC_Convert_Value;
  	ADC_Convert_Value =(float)ADC_GetConversionValue(ADC_x);
		
		if(count<3)
		{
			adc_value_temp+=ADC_Convert_Value;
			adc_delta=temp-ADC_Convert_Value;
			count+=1;
		}
		else
		{
			count=0;
			adc_value=adc_value_temp/3;
			adc_value_temp=0;
			adc_delta=0;
		}
		ADC_ClearITPendingBit(ADC_x,ADC_IT_EOC); //删除中断位置
	}
}

/**
* Function       Adc_Init
* @author        liusen
* @date          2017.08.17    
* @brief         ADC初始化接口
* @param[in]     void
* @param[out]    void
* @retval        void
* @par History   这里我们仅以规则通道为例	 我们默认将开启通道 0~3
*/



/*
* ADC中断中配置NVIC
*/


/**
* Function       Get_Adc
* @author        liusen
* @date          2017.08.17     
* @brief         获得 ADC 值
* @param[in]     ch:通道值 0~3
* @param[out]    void
* @retval        void
* @par History   这里我们仅以规则通道为例	 我们默认将开启通道 0~3
*/

static u16 Get_Adc(u8 ch)
{
	//设置指定 ADC 的规则组通道，设置它们的转化顺序和采样时间
	ADC_RegularChannelConfig(ADC1, ch, 1, ADC_SampleTime_239Cycles5 );
	//通道 1,规则采样顺序值为 1,采样时间为 239.5 周期
	ADC_SoftwareStartConvCmd(ADC1, ENABLE); //使能软件转换功能
	while(!ADC_GetFlagStatus(ADC1, ADC_FLAG_EOC ));//等待转换结束
	return ADC_GetConversionValue(ADC1); //返回最近一次 ADC1 规则组的转换结果
}


/**
* Function       Get_Adc_Average
* @author        liusen
* @date          2017.08.17    
* @brief         获得 ADC 多次测量平均值
* @param[in]     ch:通道值 0~3 ; times:测量次数
* @param[out]    void
* @retval        void
* @par History   
*/

static u16 Get_Adc_Average(u8 ch, u8 times)
{
	u32 temp_val=0;
	u8 t;
	for(t=0;t<times;t++)
	{ 
		temp_val+=Get_Adc(ch);
		delay_ms(2);
	}
	return temp_val/times;
}

/**
* Function       Get_Measure_Volotage
* @author        liusen
* @date          2017.08.17  
* @brief         获得测得原始电压值
* @param[in]     ch:通道值 0~3 ; times:测量次数
* @param[out]    void
* @retval        void
* @par History   
*/
float Get_Measure_Volotage(void)
{
	u16 adcx;
	float temp;

	adcx=Get_Adc_Average(ADC_Channel_0, 10);
	temp=(float)adcx*(3.3/4096);
	return temp;
}

/**
* Function       Get_Battery_Volotage
* @author        liusen
* @date          2017.08.18    
* @brief         获得实际电池分压前电压
* @param[in]     void
* @param[out]    void
* @retval        float 电压值
* @par History   
*/
float Get_Battery_Volotage(void)
{
	float temp;

	temp = Get_Measure_Volotage();
	temp = temp * 2.827f; //temp*(20+10)/10;  3：误差调节到2.827
	return temp;
}
