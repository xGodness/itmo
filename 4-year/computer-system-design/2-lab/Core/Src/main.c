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
#include "usart.h"
#include "gpio.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "stdio.h"
#include "stdbool.h"
#include "string.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */
typedef enum {
	DEFAULT = 0,
	PASS_CHANGE,
	CONFIRMATION
} InputMode;

typedef struct {
	bool is_pressed;
	bool signaled;
	uint32_t press_start_time;
} ButtonState;

#define BUF_SIZE 				1024

typedef struct RingBuffer {
	char data[BUF_SIZE];
	uint8_t head;
	uint8_t tail;
	bool is_empty;
} RingBuffer;
/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
#define BUTTON_PIN				GPIO_PIN_15
#define GREEN_LED_PIN			GPIO_PIN_13
#define YELLOW_LED_PIN			GPIO_PIN_14
#define RED_LED_PIN				GPIO_PIN_15
#define RESET_ALL_TIMEOUT_MS	1500
#define ENTER_ASCII				'\r'
#define ASCII_LATIN_CASE_DIFF	32
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */
char newline[] = "\r\n";
char confirmation_message[] = "Confirm password change? 'y' for yes: ";
char interruptions_on_message[] = "Interruptions on";
char interruptions_off_message[] = "Interruptions off";

char last_received_char[2] = {'\0', '\0'};

char code[8] = "pass";
uint8_t code_ptr = 0;
uint8_t code_length = 4;
char new_code[8];
uint8_t new_code_ptr = 0;

uint8_t failed_attempts_cnt = 0;
uint32_t last_input_time = 0;
char cur_char = '\0';

ButtonState button_state = {.press_start_time = 0, .signaled = false, .is_pressed = false};

bool interruptions_enabled = false;

bool transmit_busy = false;
bool receive_busy = false;

RingBuffer receive_buffer;
RingBuffer transmit_buffer;

char buf_char[2] = {'\0', '\0'};

InputMode mode = DEFAULT;

void buf_init(RingBuffer *buf) {
	buf->head = 0;
	buf->tail = 0;
	buf->is_empty = true;
}

void buf_write(RingBuffer *buf, char *in) {
	uint32_t pmask = __get_PRIMASK();
	__disable_irq();

	uint64_t size = strlen(in);

	if (buf->head + size + 1 > BUF_SIZE)
		buf->head = 0;

	strcpy(&buf->data[buf->head], in);
	buf->head += size + 1;

	if (buf->head == BUF_SIZE)
		buf->head = 0;

	buf->is_empty = false;

	__set_PRIMASK(pmask);
}

bool buf_read(RingBuffer *buf, char *out) {
	uint32_t pmask = __get_PRIMASK();
	__disable_irq();

	if (buf->is_empty){
		__set_PRIMASK(pmask);
		return false;
	}

	uint64_t size = strlen(&buf->data[buf->tail]);

	strcpy(out, &buf->data[buf->tail]);
	buf->tail += size + 1;

	if (buf->tail == BUF_SIZE || buf->tail == '\0')
		buf->tail = 0;

	if (buf->tail == buf->head)
		buf->is_empty = true;

	__set_PRIMASK(pmask);
	return true;
}
/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
extern void initialise_monitor_handles(void);

GPIO_PinState read_button(void) {
	return HAL_GPIO_ReadPin(GPIOC, BUTTON_PIN);
}

void enable_interruptions(void) {
	HAL_NVIC_EnableIRQ(USART6_IRQn);
	interruptions_enabled = true;
}

void disable_interruptions(void) {
	while (transmit_busy) ; // wait until everything from transmit_buffer is sent to the UART
	HAL_UART_AbortReceive(&huart6);
	HAL_NVIC_DisableIRQ(USART6_IRQn);
	interruptions_enabled = false;
}

void light_led(uint16_t led_pin, uint8_t blink_cnt, uint8_t time) {
	while (blink_cnt--) {
		HAL_GPIO_WritePin(GPIOD, led_pin, GPIO_PIN_SET);
		HAL_Delay(time);
		HAL_GPIO_WritePin(GPIOD, led_pin, GPIO_PIN_RESET);
		HAL_Delay(time);
	}
}

void uart_write(char *data) {
	uint16_t size = strlen(data);
	if (interruptions_enabled) {
		if (transmit_busy) {
			buf_write(&transmit_buffer, data);
		} else {
			transmit_busy = true;
			HAL_UART_Transmit_IT(&huart6, (uint8_t *) data, size);
		}
	} else HAL_UART_Transmit(&huart6, (uint8_t *) data, size, 100);
}

void uart_write_newline(void) {
	uart_write(newline);
}

void HAL_UART_TxCpltCallback(UART_HandleTypeDef *huart) {
	char buf[BUF_SIZE];
	if (buf_read(&transmit_buffer, buf))
		HAL_UART_Transmit_IT(&huart6, (uint8_t *) &buf, strlen(buf));
	else transmit_busy = false;
}

bool process_char(char *c) {
	if ('A' <= c[0] && c[0] <= 'Z') {
		c[0] += ASCII_LATIN_CASE_DIFF;
		return true;
	}
	if ('a' <= c[0] && c[0] <= 'z') {
		return true;
	}
	if (c[0] == ENTER_ASCII && PASS_CHANGE == mode) {
		return true;
	}
	if (c[0] == '+' && DEFAULT == mode) {
		return true;
	}
	c[0] = '\0';
	return false;
}

void uart_read_char(void) {
	if (interruptions_enabled) {
		if (receive_busy) return;
		receive_busy = true;
		HAL_UART_Receive_IT(&huart6, (uint8_t *) buf_char, sizeof(char));
		return;
	}
	HAL_StatusTypeDef status = HAL_UART_Receive(&huart6, (uint8_t *) buf_char, sizeof(char), 100);
	if (HAL_OK == status && process_char(buf_char)) {
		uart_write(buf_char);
		buf_write(&receive_buffer, buf_char);
	}
}

void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart) {
	receive_busy = false;
	if (process_char(buf_char)) {
		buf_write(&receive_buffer, buf_char);
		uart_write(buf_char);
	}
}

bool update_button_state(void) {
	if (button_state.is_pressed) {
		button_state.is_pressed = read_button() == GPIO_PIN_RESET;
		if (button_state.signaled) return false;
		if ((HAL_GetTick() - button_state.press_start_time) > 20) {
			button_state.signaled = true;
			return true;
		}
		return false;
	}
	if (read_button() == GPIO_PIN_RESET) {
		button_state.press_start_time = HAL_GetTick();
		button_state.is_pressed = true;
		button_state.signaled = false;
	}
	return false;
}

void set_mode(InputMode new_mode) {
	uart_write_newline();
	mode = new_mode;
	switch (mode) {
		case DEFAULT:
			code_ptr = 0;
			break;
	  case CONFIRMATION:
		  if (new_code_ptr == 0) {
			  set_mode(DEFAULT);
			  break;
		  }
		  uart_write(confirmation_message);
		  break;
	  default:
		  break;
	}
}
/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{
  /* USER CODE BEGIN 1 */
	initialise_monitor_handles();
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
  MX_USART6_UART_Init();
  /* USER CODE BEGIN 2 */

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */

  disable_interruptions();
  uart_write(interruptions_off_message);
  uart_write_newline();

  buf_init(&receive_buffer);
  buf_init(&transmit_buffer);

  char tmp[2];
  while (1)
  {
	  if (update_button_state()) {
		  if (interruptions_enabled) {
			  disable_interruptions();
			  uart_write(interruptions_off_message);
			  uart_write_newline();
		  } else {
			  enable_interruptions();
			  uart_write(interruptions_on_message);
			  uart_write_newline();
		  }
	  }

	  if (DEFAULT == mode && code_ptr != 0 && HAL_GetTick() - last_input_time >= RESET_ALL_TIMEOUT_MS) {
		  code_ptr = 0;
		  failed_attempts_cnt = 0;
		  uart_write_newline();
		  light_led(RED_LED_PIN | GREEN_LED_PIN, 5, 25);
		  last_input_time = HAL_GetTick();
		  continue;
	  }

	  uart_read_char();

	  if (!buf_read(&receive_buffer, tmp))
		  continue;

	  last_input_time = HAL_GetTick();
	  cur_char = tmp[0];

	  switch (mode) {
	  	  case DEFAULT:
	  		  if (cur_char == '+') {
	  			  set_mode(PASS_CHANGE);
	  			  continue;
	  		  }

	  		  if (code[code_ptr++] == cur_char) {
	  			  light_led(YELLOW_LED_PIN, 1, 100);
	  			  if (code_ptr == code_length) {
	  				  uart_write_newline();
	  				  light_led(GREEN_LED_PIN, 3, 50);
	  				  code_ptr = 0;
	  				  failed_attempts_cnt = 0;
	  			  }
	  		  } else {
	  			  uart_write_newline();
	  			  light_led(RED_LED_PIN, 1, 100);
				  code_ptr = 0;
				  if (++failed_attempts_cnt == 3) {
					  failed_attempts_cnt = 0;
					  light_led(RED_LED_PIN, 3, 50);
				  }
	  		  }
	  		  continue;

	  	  case PASS_CHANGE:
	  		  if (cur_char == ENTER_ASCII) {
	  			  set_mode(CONFIRMATION);
	  			  continue;
	  		  }

	  		  new_code[new_code_ptr++] = cur_char;
	  		  if (new_code_ptr == 8) set_mode(CONFIRMATION);
	  		  continue;

	  	  case CONFIRMATION:
	  		  if (cur_char == 'y') {
	  			  code_length = new_code_ptr;
	  			  for (uint8_t i = 0; i < code_length; i++)
	  				  code[i] = new_code[i];
	  		  }
	  		  new_code_ptr = 0;
	  		  set_mode(DEFAULT);
	  		  continue;
	  }


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
