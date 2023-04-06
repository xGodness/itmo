from validaton import validate_boundaries, validate_eps_handle_msg
from linear_functions import get_derivative, get_phi


def method_to_string(method_idx):
    if method_idx == 1:
        return "Bisection"
    if method_idx == 2:
        return "Secant"
    if method_idx == 3:
        return "Fixed point iteration"

    return "Invalid index"


def has_single_root(f, left, right, eps):
    sign_change_cnt = 0
    prev_sign = f(left) >= 0
    x = left
    while x < right:
        x += eps
        cur_sign = f(x) >= 0
        if cur_sign != prev_sign:
            prev_sign = cur_sign
            sign_change_cnt += 1
            if sign_change_cnt > 1:
                return False
    return sign_change_cnt == 1


def validate_parameters(f, left, right, eps):
    result = {
        "root": None,
        "value": None,
        "iterations": 0,
        "error_msg": None
    }

    boundaries_validation_res = validate_boundaries(left, right)
    epsilon_validation_res = validate_eps_handle_msg(eps)

    if boundaries_validation_res["is_error"]:
        result["error_msg"] = boundaries_validation_res["message"]
        return result
    if epsilon_validation_res["is_error"]:
        result["error_msg"] = epsilon_validation_res["message"]
        return result

    try:
        if not has_single_root(f, left, right, eps):
            result["error_msg"] = "Function does not have exactly one root on the provided interval"
    except ValueError:
        result["error_msg"] = "Function is not defined on the entire interval"

    return result


def validate_derivatives_const_sign_and_get_init_value(f, left, right, eps):
    result = {
        "is_error": False,
        "start_left": None
    }

    f_dx = get_derivative(f)
    f_dxdx = get_derivative(f_dx)
    sign_dx = f_dx(left) >= 0
    sign_dxdx = f_dxdx(left) >= 0

    x = left
    while x < right:
        x += eps
        if (f_dx(x) >= 0) == sign_dx and (f_dxdx(x) >= 0) == sign_dxdx:
            continue
        result["is_error"] = True
        return result

    result["start_left"] = True if f(left) * f_dxdx(left) > 0 else False
    return result


def validate_func_max(f, left, right, eps):
    result = {
        "is_error": False,
        "max_val": -1
    }

    x = left
    mx = 0
    try:
        while x < right:
            x += eps
            mx = max(abs(f(x)), mx)
        result["max_value"] = mx
        return result

    except ValueError:
        result["is_error"] = True
        return result


def bisection(f, left, right, eps):
    result = validate_parameters(f, left, right, eps)
    if result["error_msg"] is not None:
        return result

    mid = (left + right) / 2

    val_left = f(left)
    val_right = f(right)
    val_mid = f(mid)

    # True  <=> (f(boundary) > 0)
    # False <=> (f(boundary) < 0)
    sign_left = val_left > 0
    sign_right = val_right > 0
    sign_mid = val_mid > 0

    iter_cnt = 0
    while (right - left) > eps:
        if sign_left == sign_mid:
            left = mid
            sign_left = sign_mid
        elif sign_mid == sign_right:
            right = mid
            sign_right = sign_mid
        else:
            print("wtf?")

        mid = (left + right) / 2
        val_mid = f(mid)
        sign_mid = val_mid > 0

        iter_cnt += 1

    result["root"] = mid
    result["value"] = val_mid
    result["iterations"] = iter_cnt
    return result


def secant(f, left, right, eps):
    result = validate_parameters(f, left, right, eps)
    if result["error_msg"] is not None:
        return result

    try:
        derivatives_res = validate_derivatives_const_sign_and_get_init_value(f, left, right, eps)
        if derivatives_res["is_error"]:
            result["error_msg"] = \
                "At least one of the functions derivatives does not have constant sign on the entire interval"
            return result
    except ValueError:
        result["error_msg"] = "At least one of the functions derivatives is not defined on the entire interval"
        return result

    if derivatives_res["start_left"]:
        x0 = left
        x1 = left + eps
    else:
        x0 = right
        x1 = right - eps

    iter_cnt = 0
    x2 = 0
    while abs(f(x1)) > eps:
        x2 = x1 - (x1 - x0) / (f(x1) - f(x0)) * f(x1)
        x0 = x1
        x1 = x2
        iter_cnt += 1

    result["root"] = x2
    result["value"] = f(x2)
    result["iterations"] = iter_cnt
    return result


def fixed_point_iteration(f, left, right, eps):
    result = validate_parameters(f, left, right, eps)
    if result["error_msg"] is not None:
        return result

    f_dx = get_derivative(f)
    f_dx_res = validate_func_max(f_dx, left, right, eps)
    if f_dx_res["is_error"]:
        result["error_msg"] = "Function's derivative is not defined on the entire interval"
        return result

    f_dx_max = f_dx_res["max_value"]
    lmd = -1 / f_dx_max
    phi = get_phi(f)

    x0 = left
    x1 = phi(x0, lmd)
    iter_cnt = 0
    while abs(x1 - x0) > eps:
        x0 = x1
        x1 = phi(x1, lmd)
        iter_cnt += 1

    result["root"] = x1
    result["value"] = f(x1)
    result["iterations"] = iter_cnt
    return result
