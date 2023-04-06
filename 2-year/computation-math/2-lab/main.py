from sympy import Eq

from equation_systems import x, y, sys_1_eq_1, sys_1_eq_2, sys_2_eq_2, sys_3_eq_2, sys_3_eq_1, sys_2_eq_1, EqSystem, \
    system_fixed_point_iteration
from linear_functions import func_1, func_2, func_3, func_4
from lab_io import function_selection, input_source_selection, method_selection, float_parameter_selection, \
    linear_or_system_selection, system_selection, initial_approximation
from methods import bisection, secant, fixed_point_iteration
from graphing import draw_plot, draw_system_graph

func_list = {
    1: func_1,
    2: func_2,
    3: func_3,
    4: func_4
}

methods_list = {
    1: bisection,
    2: secant,
    3: fixed_point_iteration
}

systems = [
    EqSystem([sys_1_eq_1, sys_1_eq_2], [Eq(x ** 2 + y ** 3, 2), Eq(x ** 2 + y ** 2, 10)]),
    EqSystem([sys_2_eq_1, sys_2_eq_2], [Eq(x ** 3 + y ** 2, 9), Eq(x ** 3 - y ** 3, 1)]),
    EqSystem([sys_3_eq_1, sys_3_eq_2], [Eq(x ** 3 - y ** 2, 13), Eq(x ** 3 + y ** 3, 12)])
]


def calculate(func, method, left_boundary, right_boundary, epsilon):
    if method == bisection:
        return bisection(func, left_boundary, right_boundary, epsilon)
    if method == secant:
        return secant(func, left_boundary, right_boundary, epsilon)
    if method == fixed_point_iteration:
        return fixed_point_iteration(func, left_boundary, right_boundary, epsilon)


def main():
    global func_list
    global methods_list
    global systems

    task_part = linear_or_system_selection()
    filename_opt = input_source_selection()

    if task_part == 1:
        func = function_selection(func_list)
        method = method_selection(methods_list)

        left = float_parameter_selection("left boundary", filename_opt)
        right = float_parameter_selection("right boundary", filename_opt)
        eps = float_parameter_selection("epsilon", filename_opt)

        print(calculate(func, method, left, right, eps))
        draw_plot(func, left, right)

    if task_part == 2:
        system = system_selection(systems, filename_opt)

        x, y = initial_approximation(filename_opt)
        eps = float_parameter_selection("epsilon", filename_opt)

        print(system_fixed_point_iteration(system, x, y, eps))

        draw_system_graph(system)


if __name__ == "__main__":
    main()
