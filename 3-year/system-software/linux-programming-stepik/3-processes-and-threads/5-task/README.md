## Создание демона
Разработать программу  `solution`, которая при запуске "демонизирует" себя и остается в памяти. Перед закрытием стандартного потока вывода `stdout`, унаследованного от родителя, программа должна вывести в него `pid` процесса-демона.

**Пример вызова**

```
./solution
13221
```

**Представление решения**

Решение предоставляется в виде файла `solution.c`, содержащего исходный код вашего приложения.

**Вывод**

Программа выводит в стандартный поток вывода число в отдельную строку (вывод должен оканчиваться символом перевода строки `\n`) перед его закрытием.