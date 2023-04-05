from io import *


def has_single_root(f, left, right, eps):
    sign_change_cnt = 0
    prev_sign = f(left) >= 0
    for x in range(left + eps, right + eps, eps):
        cur_sign = f(x) >= 0
        if cur_sign != prev_sign:
            prev_sign = cur_sign
            sign_change_cnt += 1
            if sign_change_cnt > 1:
                return False
    return sign_change_cnt == 1


def bisection(f, left, right, eps):
    if not (validate_borders(left, right) and validate_eps(eps)):
        return None

    if not has_single_root(f, left, right, eps):
        print_warning("Function does not have exactly one root on the provided interval")
        return None

    mid = (left + right) / 2
    
