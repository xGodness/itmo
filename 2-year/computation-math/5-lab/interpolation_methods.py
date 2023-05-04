from math import factorial

from interpolation_util import InterpolationData
from io_util import print_warn


def lagrange(data: InterpolationData, target_x):
    points = data.point_arr
    n = data.points_cnt

    val = 0
    for i in range(n):
        multiplier = 1
        for j in range(n):
            if i == j:
                continue
            multiplier *= (target_x - points[j].x) / (points[i].x - points[j].x)
        val += multiplier * points[i].y

    return val


def newton(data: InterpolationData, target_x):
    t: float
    is_backwards: bool
    if target_x < (data.max_x + data.min_x) / 2:
        is_backwards = False
        t = (target_x - data.min_x) / data.x_step
    else:
        is_backwards = True
        t = (target_x - data.max_x) / data.x_step

    val = 0
    t_multiplier = 1
    diff = data.differences

    idx = -1 if is_backwards else 0
    t_delta = 1 if is_backwards else -1
    for i in range(data.points_cnt):
        val += diff[i][idx] * t_multiplier
        t_multiplier = t_multiplier * (t + t_delta * i) / (i + 1)

    return val


def stirling(data: InterpolationData, target_x):
    n = data.points_cnt // 2
    t = (target_x - data.point_arr[n].x) / data.x_step

    if abs(t) > 0.25:
        print_warn(f"|t| = {round(abs(t), 4)} > 0.25, Stirling's interpolation may work improperly")

    diff = data.differences

    val = diff[0][n] + t * (diff[1][n] + diff[1][n - 1]) / 2 + t ** 2 / 2 * diff[2][n - 1]
    t_multiplier = t * (t ** 2 - 1) / 6
    iter_odd = True

    i = 3
    for j in range(1, n):
        if iter_odd:
            dy = (diff[i][n - j - 1] + diff[i][n - j - 2]) / 2
        else:
            dy = diff[i][n - j - 1]

        val += dy * t_multiplier
        if iter_odd:
            t_multiplier *= t / i
        else:
            t_multiplier *= t ** 2 - (i + 1) ** 2 / i
        iter_odd = not iter_odd
        i += 1

    return val


def bessel_calc(u, n):
    if n == 0:
        return 1

    var = u
    for i in range(1, n // 2 + 1):
        var *= u - i

    for i in range(1, n // 2):
        var *= u + i

    return var


def bessel(data: InterpolationData, target_x):
    t = (target_x - data.point_arr[data.points_cnt // 2].x) / data.x_step

    if not 0.25 <= abs(t) <= 0.75:
        print_warn(f"|t| = {round(abs(t), 4)} not in [0.25, 0.75], Bessel's interpolation may work improperly")

    n = data.points_cnt
    x = [p.x for p in data.point_arr]

    y = [[0 for _ in range(n)] for _ in range(n)]

    for i in range(n):
        y[i][0] = data.point_arr[i].y

    for i in range(1, n):
        for j in range(n - i):
            y[j][i] = y[j + 1][i - 1] - y[j][i - 1]

    val = (y[2][0] + y[3][0]) / 2

    if n % 2 == 1:
        k = n // 2
    else:
        k = n // 2 - 1

    u = (target_x - x[k]) / (x[1] - x[0])

    for i in range(1, n):
        if i % 2 == 1:
            val += ((u - 0.5) * bessel_calc(u, i - 1) * y[k][i]) / factorial(i)
        else:
            val += (bessel_calc(u, i) * (y[k][i] + y[k - 1][i]) / (factorial(i) * 2))
            k -= 1

    return val
