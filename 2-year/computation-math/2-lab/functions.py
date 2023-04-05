from math import atan, sqrt, log, sin, cos


def func_1(x):
    return - x ** 3 + 10 * x ** 2 + 13 * x - 42


def func_2(x):
    return x ** 5 + 21 * x ** 4 - 256 * x ** 3 + 4 * x ** 2 - 8 * x + 16


def func_3(x):
    return x ** log(x) - x * cos(x)


def func_4(x):
    return atan(x) * sqrt(cos(sin(x))) - 2 * cos(2 * x)
