from enum import Enum

from solution import Solution

STEP_MIN = 1e-3


class Function:
    def __init__(self, name, func, exact_func) -> None:
        self.name = name
        self.func = func
        self.exact_func = exact_func

    def value_at(self, x: float, y: float) -> float:
        return self.func(x, y)

    def exact_value_at(self, x: float) -> float:
        return self.exact_func(x)

    def to_string(self) -> str:
        return self.name


def step_euler(f: Function, h: float, x: float, y: float, twice=False) -> float:
    for i in range(2 if twice else 1):
        y += h * f.value_at(x, y)
        x += h
    return y


def step_runge_kutta(f: Function, h: float, x: float, y: float, twice=False) -> float:
    for i in range(2 if twice else 1):
        k1 = h * f.value_at(x, y)
        k2 = h * f.value_at(x + h / 2, y + k1 / 2)
        k3 = h * f.value_at(x + h / 2, y + k2 / 2)
        k4 = h * f.value_at(x + h, y + k3)
        y += (k1 + 2 * k2 + 2 * k3 + k4) / 6
        x += h
    return y


def milne_predict(f: Function, h: float, x_arr: list[float], y_arr: list[float]) -> float:
    return 4 * h / 3 * (2 * f.value_at(x_arr[-1], y_arr[-1]) - f.value_at(x_arr[-2], y_arr[-2])
                        + 2 * f.value_at(x_arr[-3], y_arr[-3])) + y_arr[-4]


def milne_correct(f: Function, h: float, x_arr: list[float], y_arr: list[float], pred_y: float) -> float:
    return h / 3 * (f.value_at(x_arr[-1] + h / 2, pred_y) + 4 * f.value_at(x_arr[-1], y_arr[-1])
                    + f.value_at(x_arr[-2], y_arr[-2])) + y_arr[-2]


class SolutionMethod(Enum):
    EULER = "Euler's method"
    RUNGE_KUTTA = "Runge-Kutta's method"
    MILNE = "Milne's method"


def get_method_params(method: SolutionMethod) -> dict:
    res = {"function": None, "order": None}
    if method == SolutionMethod.EULER:
        res["function"] = step_euler
        res["order"] = 1
    elif method == SolutionMethod.RUNGE_KUTTA:
        res["function"] = step_runge_kutta
        res["order"] = 4
    return res


class DiffEqSolver:
    def __init__(self,
                 functions: tuple[Function, Function, Function, Function],
                 h: float,
                 y0: float,
                 x0: float,
                 xn: float,
                 eps: float) -> None:
        self.functions = functions
        self.h = h
        self.y0 = y0
        self.x0 = x0
        self.xn = xn
        self.eps = eps

    def solve(self, func_idx: int, method_name: SolutionMethod) -> Solution:
        if method_name == SolutionMethod.MILNE:
            return self._solve_milne(func_idx)
        params = get_method_params(method_name)
        return self._solve_single_step(func_idx, params["order"], params["function"])

    def _solve_single_step(self, func_idx: int, order: int, step_method) -> Solution:
        f: Function
        f = self.functions[func_idx]

        cur_h = self.h

        x = self.x0
        y = self.y0

        exact_y_arr = [y]
        x_arr = [x]
        y_arr = [y]
        f_arr = []

        while x <= self.xn:
            y_halved_step = step_method(f, cur_h / 2, x, y, True)

            f_val = f.value_at(x, y)
            y = step_method(f, cur_h, x, y)
            x += cur_h

            if abs(y - y_halved_step) / (2 ** order - 1) > self.eps and cur_h > STEP_MIN:
                exact_y_arr = [f.exact_value_at(self.x0)]
                x_arr = [self.x0]
                y_arr = [self.y0]
                f_arr = []
                y = self.y0
                x = self.x0
                cur_h /= 2
                continue

            x_arr.append(x)
            y_arr.append(y)
            f_arr.append(f_val)
            exact_y_arr.append(f.exact_value_at(x))

        f_arr.append(0)
        return Solution(len(exact_y_arr), x_arr, y_arr, exact_y_arr, f_arr)

    def _solve_milne(self, func_idx: int) -> Solution:
        f: Function
        f = self.functions[func_idx]

        x = self.x0
        y = self.y0

        exact_y_arr = [f.exact_value_at(x)]
        x_arr = [x]
        y_arr = [y]

        for i in range(3):
            k1 = self.h * f.value_at(x, y)
            k2 = self.h * f.value_at(x + self.h / 2, y + k1 / 2)
            k3 = self.h * f.value_at(x + self.h / 2, y + k2 / 2)
            k4 = self.h * f.value_at(x + self.h, y + k3)

            y += (k1 + 2 * k2 + 2 * k3 + k4) / 6
            x += self.h
            exact_y_arr.append(f.exact_value_at(x))
            y_arr.append(y)
            x_arr.append(x)

        while x <= self.xn:
            eps = max([abs(y_arr[i] - exact_y_arr[i]) for i in range(len(y_arr))])

            pred_y = milne_predict(f, self.h, x_arr, y_arr)
            corr_y = milne_correct(f, self.h, x_arr, y_arr, pred_y)
            while abs(pred_y - corr_y) > eps > STEP_MIN:
                pred_y = corr_y
                corr_y = milne_correct(f, self.h, x_arr, y_arr, pred_y)

            x += self.h
            exact_y_arr.append(f.exact_value_at(x))
            y_arr.append(corr_y)
            x_arr.append(x)

        return Solution(len(exact_y_arr), x_arr, y_arr, exact_y_arr)
