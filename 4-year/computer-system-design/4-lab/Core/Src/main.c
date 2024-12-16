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
#include "i2c.h"
#include "tim.h"
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
	GREEN = 0,
	YELLOW,
	RED
} LED;

typedef enum {
	LOW = 20,
	MEDIUM = 50,
	HIGH = 100
} LEDBrightness;

typedef struct {
	LED led;
	LEDBrightness brightness;
	uint32_t frequency;
} Note;

typedef enum {
	INFO = 0,
	PLAY
} GameMode;

typedef enum {
	ALL = 0,
	LED_ONLY,
	SOUND_ONLY
} NoteMode;

typedef enum {
	EASY = 3,
	NORMAL = 2,
	HARD = 1
} Difficulty;
/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
#define CLOCK_SCALED_FREQUENCY	1000000		// frequency after scaling with PSC (supposed to be same on every timer in use)
#define LED_PWM_FREQUENCY		500
#define ENTER_ASCII				'\r'
#define	INPUT_PORT_REG			(0x00)
#define	OUTPUT_PORT_REG			(0x01)
#define	POLARITY_INV_REG		(0x02)
#define CONFIG_REG				(0x03)
#define KEYPAD_ADDRESS			(0xE2)
#define KEYPAD_WRITE_ADDRESS	((KEYPAD_ADDRESS) & ~1)
#define KEYPAD_READ_ADDRESS		((KEYPAD_ADDRESS) | 1)
#define COLUMN_MASK				0x7
#define CONTACT_BOUNCE_MS		20
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */
uint32_t last_pressed_time;
int last_pressed_key_index = -2;

uint16_t led_arr_value = CLOCK_SCALED_FREQUENCY / LED_PWM_FREQUENCY;

char newline[] = "\r\n";

char test_mode_msg[] = "\n\rCurrent mode: keypad test\n\r";
char main_mode_msg[] = "\n\rCurrent mode: main\n\r";

char game_started_msg[] = "\n\rGame started!\n\r";
char game_finished_msg[] = "\n\rGame finished\n\r";

char note_mode_all_msg[] = "\n\rCurrent note mode: all\n\r";
char note_mode_led_msg[] = "\n\rCurrent note mode: led only\n\r";
char note_mode_sound_msg[] = "\n\rCurrent note mode: sound only\n\r";

char difficulty_easy_msg[] = "\n\rCurrent difficulty: easy\n\r";
char difficulty_normal_msg[] = "\n\rCurrent difficulty: normal\n\r";
char difficulty_hard_msg[] = "\n\rCurrent difficulty: hard\n\r";

char countdown_prepare_msg[] = "\n\rPrepare yourself!\n\r";
char countdown_3_msg[] = "\n\rStarting in 3...\n\r";
char countdown_2_msg[] = "\n\rStarting in 2...\n\r";
char countdown_1_msg[] = "\n\rStarting in 1...\n\r";

char guess_note_msg[] = "Guess the note: ";

bool game_started = false;

Difficulty difficulty = EASY;

char buf_char[2] = {'\0', '\0'};

GameMode game_mode = INFO;
NoteMode note_mode = ALL;

Note notes[] = {
		{GREEN,		LOW,		100},
		{GREEN,		MEDIUM,		200},
		{GREEN,		HIGH,		300},
		{YELLOW,	LOW,		400},
		{YELLOW,	MEDIUM,		500},
		{YELLOW,	HIGH,		600},
		{RED,		LOW,		700},
		{RED,		MEDIUM,		800},
		{RED,		HIGH,		900}
};

uint8_t note_sequence_length = 20;
uint8_t note_sequence[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2};
bool guess_status[] = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false};
uint8_t cur_note_ptr = 0;
uint8_t cur_guess = 0;


void init_led_pwm(void) {
	htim4.Instance->ARR = led_arr_value;
}

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
extern void initialise_monitor_handles(void);

bool is_digit(char *c) {
	return '1' <= *c && *c <= '9';
}

bool is_button_pressed(void) {
	 return HAL_GPIO_ReadPin(GPIOC, GPIO_PIN_15) == 0;
 }

void uart_write(char *data) {
	uint16_t size = strlen(data);
	HAL_UART_Transmit(&huart6, (uint8_t *) data, size, 100);
}

void uart_write_newline(void) {
	uart_write(newline);
}

bool process_char(char *c) {
	if (is_digit(&c[0]) || ENTER_ASCII == c[0])
		return true;
	if (('a' == c[0] || '+' == c[0]) && game_mode == INFO)
		return true;
	c[0] = '\0';
	return false;
}

void uart_read_char(void) {
	HAL_StatusTypeDef status = HAL_UART_Receive(&huart6, (uint8_t *) buf_char, sizeof(char), 100);
	if (HAL_OK == status && process_char(buf_char))
		uart_write(buf_char);
}

void play_sound(uint32_t *frequency) {
	htim1.Instance->ARR = (1000000 / (*frequency)) - 1; // Set The PWM Frequency
	htim1.Instance->CCR1 = (htim1.Instance->ARR >> 1); // Set Duty Cycle 50%
}

void mute(void) {
	htim1.Instance->CCR1 = 0;
}

void disable_all_leds(void) {
	htim4.Instance->CCR2 = 0;
	htim4.Instance->CCR3 = 0;
	htim4.Instance->CCR4 = 0;
}

void light_led(LED *led, LEDBrightness *brightness) {
	disable_all_leds();
	uint16_t ccr_value = CLOCK_SCALED_FREQUENCY / LED_PWM_FREQUENCY * (*brightness) / 100;
	switch (*led) {
		case GREEN:
			htim4.Instance->CCR2 = ccr_value;
			break;
		case YELLOW:
			htim4.Instance->CCR3 = ccr_value;
			break;
		case RED:
			htim4.Instance->CCR4 = ccr_value;
			break;
	}
}

void play_note(Note *note) {
	switch (note_mode) {
		case ALL:
			play_sound(&note->frequency);
			light_led(&note->led, &note->brightness);
			break;
		case LED_ONLY:
			light_led(&note->led, &note->brightness);
			break;
		case SOUND_ONLY:
			play_sound(&note->frequency);
			break;
	}
}

void stop_note(void) {
	mute();
	disable_all_leds();
}

void uart_write_note_info(Note *note) {
	char buf[256];
	char *colour = note->led == GREEN ? "green" : (note->led == YELLOW ? "yellow" : "red");
	uint8_t brightness = note->brightness == LOW ? 20 : (note->brightness == MEDIUM ? 50 : 100);

	sprintf(buf, "\n\rNote colour: %s\n\rNote brightness: %d\n\rNote frequency: %lu\n\r", colour, brightness, note->frequency);

	uart_write(buf);
}

HAL_StatusTypeDef reset_keypad(void) {
	uint8_t buf = 0;
	HAL_StatusTypeDef status = HAL_I2C_Mem_Write(&hi2c1, KEYPAD_WRITE_ADDRESS, POLARITY_INV_REG, 1, &buf, 1, 100);
	if (status != HAL_OK)
		return status;
	status = HAL_I2C_Mem_Write(&hi2c1, KEYPAD_WRITE_ADDRESS, OUTPUT_PORT_REG, 1, &buf, 1, 100);
	return status;
}

int keypad_read_key_index(void) {
	uint32_t cur_time = HAL_GetTick();
	if (cur_time - last_pressed_time < CONTACT_BOUNCE_MS) return -1;

    int key_index = -1;
    uint8_t buf;
    uint16_t pressed_column;

    for (int row = 0; row < 4; row++) {
        buf = ~((uint8_t) (1 << row));
        pressed_column = 0x00;

        reset_keypad();

        HAL_I2C_Mem_Write(&hi2c1, KEYPAD_WRITE_ADDRESS, CONFIG_REG, 1, &buf, 1, 100);
        HAL_Delay(10);
        HAL_I2C_Mem_Read(&hi2c1, KEYPAD_READ_ADDRESS, INPUT_PORT_REG, 1, &buf, 1, 100);

        pressed_column = (~(buf >> 4)) & COLUMN_MASK;
        switch (pressed_column) {
            case 0x1:
                if (key_index != -1) return -1;
                key_index = row * 3;
                break;
            case 0x2:
                if (key_index != -1) return -1;
                key_index = (row * 3) + 1;
                break;
            case 0x4:
                if (key_index != -1) return -1;
                key_index = (row * 3) + 2;
                break;
        }
    }

    if (key_index != -1) last_pressed_time = cur_time;
    if (key_index == last_pressed_key_index)
    	return -1;
    last_pressed_key_index = key_index;
    return key_index;
}

void countdown_start_game(void) {
	uart_write(countdown_prepare_msg);
	uart_write(countdown_3_msg);
	HAL_Delay(1000);
	uart_write(countdown_2_msg);
	HAL_Delay(1000);
	uart_write(countdown_1_msg);
	HAL_Delay(1000);
}

void stop_timer(void) {
	HAL_TIM_Base_Stop_IT(&htim6);
	htim6.Instance->ARR = 0;
}

void set_timer_ms(uint32_t ms) {
	htim6.Instance->ARR = ms - 1;
	HAL_TIM_Base_Start_IT(&htim6);
}

void finish_game(void) {
	stop_timer();
	stop_note();

	uart_write_newline();
	uart_write(game_finished_msg);

	char buf[256];
	uint8_t points = 0;
	for (uint8_t i = 0; i < note_sequence_length; i++) {
		sprintf(buf, "Note %d: %s\n\r", i + 1, guess_status[i] ? "correct" : "wrong");
		uart_write(buf);
		points += (guess_status[i] * (4 - difficulty));

		guess_status[i] = false;
	}

	sprintf(buf, "Your score: %d\n\r", points);
	uart_write(buf);

	cur_note_ptr = 0;
	cur_guess = 0;
	game_started = false;
}

void switch_game_mode(void) {
	switch (game_mode) {
		case INFO:
			game_mode = PLAY;
			countdown_start_game();
			uart_write(game_started_msg);
			uart_write(guess_note_msg);
			play_note(&notes[note_sequence[cur_note_ptr] - 1]);
			set_timer_ms(difficulty * 1000);
			break;
		case PLAY:
			game_mode = INFO;
			if (cur_note_ptr < note_sequence_length && cur_guess == note_sequence[cur_note_ptr])
				guess_status[cur_note_ptr] = true;
			finish_game();
			break;
	}
}

void switch_note_mode(void) {
	stop_note();
	switch (note_mode) {
		case ALL:
			note_mode = LED_ONLY;
			uart_write(note_mode_led_msg);
			break;
		case LED_ONLY:
			note_mode = SOUND_ONLY;
			uart_write(note_mode_sound_msg);
			break;
		case SOUND_ONLY:
			note_mode = ALL;
			uart_write(note_mode_all_msg);
			break;
	}
}

void switch_difficulty(void) {
	switch (difficulty) {
		case EASY:
			difficulty= NORMAL;
			uart_write(difficulty_normal_msg);
			break;
		case NORMAL:
			difficulty= HARD;
			uart_write(difficulty_hard_msg);
			break;
		case HARD:
			difficulty= EASY;
			uart_write(difficulty_easy_msg);
			break;
	}
}

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim) {
	if (htim->Instance == TIM6) {
		if (game_mode == INFO) {
			stop_note();
			stop_timer();
			return;
		}

		if (!game_started) {
			game_started = true;
			return;
		}

		if (cur_guess == note_sequence[cur_note_ptr])
			guess_status[cur_note_ptr] = true;

		cur_guess = 0;
		cur_note_ptr++;

		if (cur_note_ptr == note_sequence_length) {
			switch_game_mode();
		} else {
			uart_write_newline();
			uart_write(guess_note_msg);
			play_note(&notes[note_sequence[cur_note_ptr] - 1]);
		}
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

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_TIM4_Init();
  MX_TIM6_Init();
  MX_USART6_UART_Init();
  MX_TIM1_Init();
  MX_I2C1_Init();
  /* USER CODE BEGIN 2 */

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */

  HAL_TIM_PWM_Start(&htim4, TIM_CHANNEL_2);
  HAL_TIM_PWM_Start(&htim4, TIM_CHANNEL_3);
  HAL_TIM_PWM_Start(&htim4, TIM_CHANNEL_4);

  HAL_TIM_Base_Start_IT(&htim1);
  HAL_TIM_PWM_Start(&htim1, TIM_CHANNEL_1);

  init_led_pwm();
  stop_timer();

  last_pressed_time = 0;
  bool button_pressed = false;
  bool is_test_mode = true;

  uart_write(is_test_mode ? test_mode_msg : main_mode_msg);

  int key_index;
  while (1)
  {
	  if (is_button_pressed() && button_pressed) continue;

	  button_pressed = is_button_pressed();

	  if (button_pressed) {
		  is_test_mode = !is_test_mode;
		  uart_write(is_test_mode ? test_mode_msg : main_mode_msg);
		  continue;
	  }

	  key_index = keypad_read_key_index();

	  if (key_index == -1)
		  continue;

	  if (is_test_mode) {
		  char buf[4];
		  sprintf(buf, "%d\n\r", key_index);
		  uart_write(buf);
		  continue;
	  }

	  if (key_index == 11) {
		  switch_game_mode();
		  continue;
	  }

	  if (0 <= key_index && key_index <= 8) {
		  if (game_mode == INFO) {
			  uint8_t id = key_index;
			  play_note(&notes[id]);
			  uart_write_note_info(&notes[id]);

			  set_timer_ms(1000);
		  } else {
			  cur_guess = key_index + 1;
			  char buf[4];
			  sprintf(buf, "%d", cur_guess);
			  uart_write(buf);
		  }
		  continue;
	  }

	  if (key_index == 9 && game_mode == INFO) {
		  switch_note_mode();
		  continue;
	  }

	  if (key_index == 10 && game_mode == INFO) {
		  switch_difficulty();
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
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE3);

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 15;
  RCC_OscInitStruct.PLL.PLLN = 72;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 4;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_1) != HAL_OK)
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
