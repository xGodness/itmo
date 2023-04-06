from sympy import symbols

from graphing import draw_system_graph


class Equation:
    def __init__(self, string_view, func, dx=None, phi=None, dphi=None):
        self.string_repr = string_view
        self.func = func
        self.dx = dx
        self.phi = phi
        self.dphi = dphi


class EqSystem:
    def __init__(self, eq_array, sympy_eq):
        self.eq_arr = eq_array
        self.sympy_eq = sympy_eq

    def to_string(self):
        return " | ".join([eq.string_repr for eq in self.eq_arr])


x = symbols('x')
y = symbols('y')

sys_1_eq_1 = Equation(
    "x^2 + y^3 = -2",
    lambda x, y: x * x + y * y * y + 2,
    phi=lambda x, y: x * x + y * y * y + 2 + x
)

sys_1_eq_2 = Equation(
    "x^2 + y^2 = 10",
    lambda x, y: x * x - y * y - 10,
    phi=lambda x, y: x * x - y * y - 10 + y
)

sys_2_eq_1 = Equation(
    "x^3 + y^2 = 9",
    lambda x, y: x * x * x + y * y - 9,
    phi=lambda x, y: x * x * x + y * y - 9 + x
)

sys_2_eq_2 = Equation(
    "x^3 - y^3 = 1",
    lambda x, y: x * x * x - y * y * y - 1,
    phi=lambda x, y: x * x * x - y * y * y - 1 + y
)

sys_3_eq_1 = Equation(
    "x^3 - y^2 = 13",
    lambda x, y: x * x * x - y * y - 13,
    phi=lambda x, y: x * x * x - y * y - 13 + x
)

sys_3_eq_2 = Equation(
    "x^3 + y^3 = 12",
    lambda x, y: x * x * x + y * y * y - 12,
    phi=lambda x, y: x * x * x + y * y * y - 12 + y
)


def system_fixed_point_iteration(system, x_val, y_val, eps):
    result = {
        "root_x": None,
        "root_y": None,
        "value": None,
        "iterations": 0,
        "error_msg": None
    }

    iter_cnt = 0
    max_iter = 1000
    max_value = 1e+10

    while abs(system.eq_arr[0].func(x_val, y_val)) > eps:
        x_val = system.eq_arr[0].phi(x_val, y_val)
        y_val = system.eq_arr[1].phi(x_val, y_val)

        iter_cnt += 1

        if iter_cnt > max_iter or x_val > max_value or y_val > max_value:
            result["error_msg"] = "Does not converge"
            return result

    result["root_x"] = x_val
    result["root_y"] = y_val
    result["value"] = system.eq_arr[0].func(x_val, y_val)
    result["iterations"] = iter_cnt

    return result
