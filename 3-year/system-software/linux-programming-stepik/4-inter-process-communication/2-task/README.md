## Мультиплексированный ввод
В текущем каталоге есть 2 канала, `in1` и `in2`, в которые в случайном порядке поступают числа, которые необходимо просуммировать и вывести окончательную сумму на экран. Сумма выводится в отдельной строке, завершающейся символом конца строки. Признаком окончания подачи символов в каналы является закрытие этих каналов посылающей стороной.

_Подсказка_: для неблокирующего чтения использовать `select`.

_Замечание:_ ﻿протокол обмена по каналу текстовый, то есть числа представлены строками.

**Пример вызова**

```
./solution
795
```

**Представление решения**

Решение предоставляется в виде двух файлов `solution.c` и `Makefile`, в последнем предполагается цель по умолчанию, которая приводит к сборке вашего приложения. Бинарный файл вашего решения должен иметь имя  `solution`.

**Вывод**

Программа выводит в стандартный поток вывода число (в отдельной строке).
