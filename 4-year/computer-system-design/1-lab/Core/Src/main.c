/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2024 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "gpio.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */
typedef enum {
	SHORT = 0,
	LONG
} ButtonPressType;
/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
#define BUTTON_PIN				GPIO_PIN_15
#define GREEN_LED_PIN			GPIO_PIN_13
#define YELLOW_LED_PIN			GPIO_PIN_14
#define RED_LED_PIN				GPIO_PIN_15
#define SHORT_PRESS_MAX_MS 		500
#define RESET_ALL_TIMEOUT_MS	3000
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{
  /* USER CODE BEGIN 1 */
  GPIO_PinState read_button() {
	  return HAL_GPIO_ReadPin(GPIOC, BUTTON_PIN);
  }

  uint32_t max(uint32_t a, uint32_t b) {
	  return a > b ? a : b;
  }

  void light_led(uint16_t led_pin, uint8_t blink_cnt, uint8_t time) {
	  while (blink_cnt--) {
		  HAL_GPIO_WritePin(GPIOD, led_pin, GPIO_PIN_SET);
		  HAL_Delay(time);
		  HAL_GPIO_WritePin(GPIOD, led_pin, GPIO_PIN_RESET);
		  HAL_Delay(100);
	  }
  }
  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */
    GPIO_InitTypeDef GPIO_InitStruct = {0};

    /* GPIO Ports Clock Enable */
    __HAL_RCC_GPIOC_CLK_ENABLE();
    __HAL_RCC_GPIOH_CLK_ENABLE();
    __HAL_RCC_GPIOD_CLK_ENABLE();
    __HAL_RCC_GPIOA_CLK_ENABLE();
    __HAL_RCC_GPIOB_CLK_ENABLE();

    /*Configure GPIO pin Output Level */
    HAL_GPIO_WritePin(GPIOD, GPIO_PIN_13|GPIO_PIN_14|GPIO_PIN_15, GPIO_PIN_RESET);

    /*Configure GPIO pin : PC15 */
    GPIO_InitStruct.Pin = GPIO_PIN_15;
    GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

    /*Configure GPIO pins : PD13 PD14 PD15 */
    GPIO_InitStruct.Pin = GPIO_PIN_13|GPIO_PIN_14|GPIO_PIN_15;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(GPIOD, &GPIO_InitStruct);
  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  /* USER CODE BEGIN 2 */
  uint32_t start_time = 0;
  uint32_t press_time;
  ButtonPressType button_press_type;
  ButtonPressType code[] = {SHORT, SHORT, SHORT, SHORT, LONG, LONG, LONG, LONG};
  uint8_t code_length = sizeof(code) / sizeof(code[0]);
  uint8_t ptr = 0;
  uint8_t failed_attempts_cnt = 0;
  uint32_t last_pressed_time = 0;
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
	  // if password input has started, terminate input process (reset state) if button was pressed last time more than `RESET_ALL_TIMEOUT_MS` ago
	  if (ptr != 0 && HAL_GetTick() - last_pressed_time >= RESET_ALL_TIMEOUT_MS) {
		  ptr = 0;
		  failed_attempts_cnt = 0;
		  light_led(RED_LED_PIN | GREEN_LED_PIN, 5, 200);
		  last_pressed_time = HAL_GetTick();
		  continue;
	  }

	  GPIO_PinState button_state = read_button();

	  // if button was just pressed, start counting time
	  if (button_state == GPIO_PIN_RESET) {
		  if (start_time == 0) start_time = max(HAL_GetTick(), 1);
		  continue;
	  }

	  // if button is not pressed now and was not pressed one iteration ago, just continue
	  if (start_time == 0) continue;
	  press_time = HAL_GetTick() - start_time;

	  // contact bounce protection
	  if (press_time <= 20) continue;

	  // if button is pressed and it's not a contact bounce, update `last_pressed_time`
	  last_pressed_time = HAL_GetTick();

	  // check whether press was short or long
	  if (press_time <= SHORT_PRESS_MAX_MS) button_press_type = SHORT;
	  else button_press_type = LONG;

	  // check whether `button_press_type` is correct
	  if (code[ptr] == button_press_type) {
		  light_led(YELLOW_LED_PIN, 1, 200);
		  if (++ptr >= code_length) {
			  light_led(GREEN_LED_PIN, 3, 200);
			  ptr = 0;
			  failed_attempts_cnt = 0;
		  }
	  } else {
		  light_led(RED_LED_PIN, 1, 200);
		  ptr = 0;
		  if (++failed_attempts_cnt == 3) {
			  failed_attempts_cnt = 0;
			  light_led(RED_LED_PIN, 5, 200);
		  }
	  }

	  start_time = 0;
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Configure the main internal regulator output voltage
  */
  __HAL_RCC_PWR_CLK_ENABLE();
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 15;
  RCC_OscInitStruct.PLL.PLLN = 216;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 4;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Activate the Over-Drive mode
  */
  if (HAL_PWREx_EnableOverDrive() != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_5) != HAL_OK)
  {
    Error_Handler();
  }
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
