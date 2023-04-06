from sympy import Eq
from numpy import linspace
from equation_systems import EqSystem, sys_1_eq_1, sys_2_eq_1, sys_3_eq_1, sys_3_eq_2, sys_2_eq_2, sys_1_eq_2, x, y, \
    system_fixed_point_iteration
from lab_io import system_selection

systems = [
    EqSystem([sys_1_eq_1, sys_1_eq_2], [Eq(x ** 2 + y ** 3, 2), Eq(x ** 2 + y ** 2, 10)]),
    EqSystem([sys_2_eq_1, sys_2_eq_2], [Eq(x ** 3 + y ** 2, 9), Eq(x ** 3 - y ** 3, 1)]),
    EqSystem([sys_3_eq_1, sys_3_eq_2], [Eq(x ** 3 - y ** 2, 13), Eq(x ** 3 + y ** 3, 12)])
]


def main():
    system = system_selection(systems, None)

    x = linspace(-5, 5, 1000)
    y = linspace(-5, 5, 1000)
    for i in x:
        for j in y:
            if system_fixed_point_iteration(system, i, j, 0.001)["error_msg"] is None:
                print(f"x: {i}, y:{j}")


if __name__ == "__main__":
    main()
