def validate_boundaries(left, right):
    result = {
        "is_error": False,
        "message": None
    }

    if right <= left:
        result["is_error"] = True
        result["message"] = "Left boundary must be lower than right boundary"

    if right - left > 50:
        result["is_error"] = True
        result["message"] = "Provided interval's length must not surpass 50"

    return result


def validate_eps_handle_msg(eps):
    result = {
        "is_error": False,
        "message": None
    }

    if eps <= 0:
        result["is_error"] = True
        result["is_error"] = "Provided epsilon must be positive"

    if eps < 0.00001:
        result["is_error"] = True
        result["is_error"] = "Provided epsilon must not be lower than 0.00001"

    return result
