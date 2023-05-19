import sys
from math import isnan
from numpy import exp, seterr

from io_util import read_float, read_interval_and_point, select_function, print_header, print_warn
from function_util import Function, DiffEqSolver, SolutionMethod
from solution import Solution
from graphing import draw_plot

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
        if isnan(y) or abs(y) > 1e8:
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
        draw_plot(sol.x_arr, sol.y_arr, sol.exact_y_arr, method.value)


if __name__ == "__main__":
    seterr(all="ignore")
    sep = "\n\n--------------------------------------------\n\n"
    cnt = 0
    while True:
        try:
            main()
        except OverflowError:
            if cnt == 0:
                print_warn(
                    "Whoops... it seems you aren't using a quantum pc. "
                    "You should have at least 1TB RAM and 128-core CPU. "
                    "Your ambitions are too high unfortunately, maybe try to lower them?"
                )
            elif cnt == 1:
                print_warn(
                    "You really shouldn't do this to me, dawg. I can't handle this. For real. I'm not joking."
                )
            elif cnt == 2:
                print_warn("Dude, really? Enough. Please. Stop.")
            elif cnt == 3:
                print_warn("I SAID STOP!!! I'm not liking this! What's the stop word? Cucumber? CUCUMBER!!!")
            elif cnt == 4:
                print_warn("HEEEEEELP!!! I'M BEING RAPED... OH JESUS CHRIST STOP PLEASE I BEG YOU")
            else:
                print_warn("You're a sick maniac. I'm out of this. Get the hell outta here. You're not welcome anymore.")
                sys.exit(0b0110011001110101011000110110101100100000011110010110111101110101)
            cnt += 1
            
