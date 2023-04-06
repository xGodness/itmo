from util import RectangleMethodType
from validation import validate_boundaries_and_epsilon


def rectangle_calculate(method_type, func, left, part_len, i):
    if method_type == RectangleMethodType.LEFT:
        return func.calculate(left + part_len * i) * part_len
    if method_type == RectangleMethodType.RIGHT:
        return func.calculate(left + part_len * (i + 1)) * part_len
    if method_type == RectangleMethodType.MIDDLE:
        return func.calculate(left + part_len * i + part_len / 2) * part_len


def rectangles(method_type, func, left, right, eps):
    res = validate_boundaries_and_epsilon(left, right, eps)
    if res.is_error:
        return res

    prev_int = 0
    partitions_cnt = 4
    interval_len = right - left
    part_len = interval_len / partitions_cnt
    cur_int = 0

    while True:
        for i in range(partitions_cnt):
            cur_int += rectangle_calculate(method_type, func, left, part_len, i)

        if abs(cur_int - prev_int) < eps:
            break

        prev_int = cur_int
        partitions_cnt *= 2
        part_len = interval_len / partitions_cnt
        cur_int = 0

    res.answer = cur_int
    res.partition_cnt = partitions_cnt
    res.accuracy = abs(cur_int - prev_int)

    return res


def trapezoid_calculate(func, left, part_len, i, j):
    return 0.5 * part_len * (func.calculate(left + i * part_len) + func.calculate(left + j * part_len))


def trapezoids(func, left, right, eps):
    res = validate_boundaries_and_epsilon(left, right, eps)
    if res.is_error:
        return res

    prev_int = 0
    partitions_cnt = 4
    interval_len = right - left
    part_len = interval_len / partitions_cnt
    cur_int = 0

    while True:
        for i in range(1, partitions_cnt):
            j = i - 1
            cur_int += trapezoid_calculate(func, left, part_len, i, j)

        if abs(cur_int - prev_int) < eps:
            break

        prev_int = cur_int
        partitions_cnt *= 2
        part_len = interval_len / partitions_cnt
        cur_int = 0

    res.answer = cur_int
    res.partition_cnt = partitions_cnt
    res.accuracy = abs(cur_int - prev_int)

    return res


def simpson_calculate(part_len, odd_y, even_y, y_n):
    return part_len / 3 * (even_y[0] + 4 * sum(odd_y) + 2 * sum(even_y[1:]) + y_n)


def simpson(func, left, right, eps):
    res = validate_boundaries_and_epsilon(left, right, eps)
    if res.is_error:
        return res

    prev_int = 0
    partitions_cnt = 4
    interval_len = right - left
    part_len = interval_len / partitions_cnt

    while True:
        y = [func.calculate(i * part_len + left) for i in range(partitions_cnt)]
        odd_y = [y[i] for i in range(1, partitions_cnt, 2)]
        even_y = [y[i] for i in range(2, partitions_cnt - 1, 2)]
        y_n = y[-1]

        cur_int = simpson_calculate(part_len, odd_y, even_y, y_n)

        if abs(cur_int - prev_int) < eps:
            break

        prev_int = cur_int
        partitions_cnt *= 2
        part_len = interval_len / partitions_cnt

    res.answer = cur_int
    res.partition_cnt = partitions_cnt
    res.accuracy = abs(cur_int - prev_int)

    return res
