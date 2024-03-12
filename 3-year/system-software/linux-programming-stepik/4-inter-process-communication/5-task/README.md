## Разделяемая память
В системе существуют 2 региона разделяемой памяти, заполненной некоторыми числами (типа `int`). Каждый из регионов имеет размер 1000 байт. Вам требуется разработать приложение, которое попарно суммирует первые 100 чисел в этих регионах и помещает суммы в новый (созданный вашим приложением) регион памяти размером 1000 байт. Таким образом, после завершения работы вашего приложения в памяти должен существовать регион разделяемой памяти размером 1000 байт, содержащий в начале 100 сумм. Перед завершением работы приложение выводит в стандартный поток ввода-вывода ключ созданного региона, завершающийся символом конца строки. На вход ваше приложение принимает ключи существующих регионов памяти.

**Пример вызова**

```
./solution 456764 456768
512997
```

**Представление решения**

Решение предоставляется в виде двух файлов `solution.c` и `Makefile`, в последнем предполагается цель по умолчанию, которая приводит к сборке вашего приложения. Бинарный файл вашего решения должен иметь имя  `solution`.

**Вывод**

Программа выводит в стандартный поток вывода ключ созданного региона памяти (строка завершается символом конца строки).