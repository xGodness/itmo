from numpy import arctan, sqrt, log, sin, cos

log10 = 2.30258509299


def get_derivative(func):
    if func == func_1:
        return func_1_dx
    if func == func_1_dx:
        return func_1_dxdx
    if func == func_2:
        return func_2_dx
    if func == func_2_dx:
        return func_2_dxdx
    if func == func_3:
        return func_3_dx
    if func == func_3_dx:
        return func_3_dxdx
    if func == func_4:
        return func_4_dx
    if func == func_4_dx:
        return func_4_dxdx
    return None


def get_phi(func):
    if func == func_1:
        return phi_1
    if func == func_2:
        return phi_2
    if func == func_3:
        return phi_3
    if func == func_4:
        return phi_4
    return None


def func_1(x):
    return -x ** 3 + 10 * x ** 2 + 13 * x - 42


def func_1_dx(x):
    return -3 * x ** 2 + 20 * x + 13


def func_1_dxdx(x):
    return -6 * x + 20


def phi_1(x, lmd):
    return lmd * (-x ** 3 + 10 * x ** 2 + 13 * x - 42) + x


def func_2(x):
    return x ** 5 + 21 * x ** 4 - 256 * x ** 3 + 4 * x ** 2 - 8 * x + 16


def func_2_dx(x):
    return 5 * x ** 4 + 84 * x ** 3 - 768 * x ** 2 + 8 * x - 8


def func_2_dxdx(x):
    return 20 * x ** 3 + 252 * x ** 2 - 1536 * x + 8


def phi_2(x, lmd):
    return lmd * (x ** 5 + 21 * x ** 4 - 256 * x ** 3 + 4 * x ** 2 - 8 * x + 16) + x


def func_3(x):
    return x ** log(x, 10) + x * cos(x)


def func_3_dx(x):
    return cos(x) + (2 * x ** (-1 + log(x) / log10) * log(x)) / log10 - x * sin(x)


def func_3_dxdx(x):
    return -x * cos(x) + (x ** (-2 + log(x) / log10) * (log(100) - 2 * log10 * log(x) + 4 * log(x) ** 2)) / (
            log10 ** 2) - 2 * sin(x)


def phi_3(lmd, x):
    return lmd * (x ** log(x, 10) + x * cos(x)) + x


def func_4(x):
    return arctan(x) * sqrt(cos(sin(x))) - 2 * cos(2 * x)


def func_4_dx(x):
    return sqrt(cos(sin(x))) / (1 + x ** 2) + 4 * sin(2 * x) - (arctan(x) * cos(x) * sin(sin(x))) / (
            2 * sqrt(cos(sin(x))))


# damn boy... that's huge
def func_4_dxdx(x):
    return -(sin(sin(x)) * cos(x)) / ((1 + x ** 2) * sqrt(cos(sin(x)))) - (2 * x * sqrt(cos(sin(x)))) / (
            1 + x ** 2) ** 2 + 8 * cos(2 * x) - 0.5 * (cos(x)) ** 2 * arctan(x) * sqrt(cos(sin(x))) - (
            sin(sin(x)) ** 2 * cos(x) ** 2 * arctan(x)) / (4 * cos(sin(x)) ** 1.5) + (
            sin(x) * sin(sin(x)) * arctan(x)) / (2 * sqrt(cos(sin(x))))


def phi_4(x, lmd):
    return lmd * (arctan(x) * sqrt(cos(sin(x))) - 2 * cos(2 * x)) + x


def func_to_string(func_idx):
    if func_idx == 1:
        return "-x^3 + 10x^2 + 13x - 42"
    if func_idx == 2:
        return "x^5 + 21x^4 - 256x^3 + 4x^2 - 8x + 16"
    if func_idx == 3:
        return "x^log(10, x) + xcos(x)"
    if func_idx == 4:
        return "atan(x) * sqrt(cos(sin(x))) - 2cos(2x)"
    return "Invalid index"
