from util import Result


def validate_boundaries_and_epsilon(left, right, eps):
    res = Result()

    if left >= right:
        res.is_error = True
        res.error_msg = "Right boundary must be greater than left boundary"
        return res

    if eps <= 0:
        res.is_error = True
        res.error_msg = "Epsilon must be positive"
        return res

    if eps < 0.000001:
        res.is_error = True
        res.error_msg = "Epsilon must not be lower than 0.000001 (1e-6)"

    return res
