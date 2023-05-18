from io_util import read_float, read_interval_and_point, select_function, print_header, print_warn
from function_util import Function, DiffEqSolver, SolutionMethod
from solution import Solution
from numpy import exp

method_tuple = (SolutionMethod.EULER, SolutionMethod.RUNGE_KUTTA, SolutionMethod.MILNE)

function_names_tuple = (
    "y' = x - y",
    "y' = y + (1 + x) * y^2",
    "y' = x^2 - 2 * y",
    "y' = 3 * x^2 * y + x^2 * e^(x^3)"
)


def check_values(f: Function, x0: float, xn: float, h: float):
    x = x0
    while x <= xn:
        y = f.exact_value_at(x)
        if abs(y) > 1e8:
            return False
        x += h
    return True


def main():
    func_idx = select_function(function_names_tuple)
    y0, x0, xn = read_interval_and_point()
    h = read_float("step (h)", zero_allowed=False, positive_only=True)
    eps = read_float("accuracy (epsilon)", zero_allowed=False, positive_only=True)

    function_tuple = (
        Function(
            "y' = x - y",
            lambda x, y: x - y,
            lambda x: (-x0 + y0 + 1) * exp(x0 - x) + x - 1
        ),
        Function(
            "y' = y + (1 + x) * y^2",
            lambda x, y: y + (1 + x) * y ** 2,
            lambda x: y0 * exp(x) / (exp(x0) * (x0 * y0 + 1) - y0 * exp(x) * x),
        ),
        Function(
            "y' = x^2 - 2 * y",
            lambda x, y: x ** 2 - 2 * y,
            lambda x: (1 + (-1 + 2 * x0 - 2 * x0 ** 2 + 4 * y0) * exp(2 * x0 - 2 * x) - 2 * x + 2 * x ** 2) / 4
        ),
        Function(
            "y' = 3 * x^2 * y + x^2 * e^(x^3)",
            lambda x, y: 3 * x ** 2 * y + x ** 2 * exp(x ** 3),
            lambda x: exp(x ** 3) * (-x0 ** 3 + 3 * y0 * exp(-x0 ** 3) + x ** 3) / 3
        )
    )

    solver = DiffEqSolver(function_tuple, h, y0, x0, xn, eps)
    sol: Solution

    if not check_values(function_tuple[func_idx], x0, xn, h):
        print_warn("Function is too big on this interval. Probably you should try different one")
        return

    for method in method_tuple:
        sol = solver.solve(func_idx, method)
        print_header(method.value)
        sol.print()


if __name__ == "__main__":
    main()
