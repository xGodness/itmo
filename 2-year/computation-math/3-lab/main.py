from functions import Function
from lab_io import function_selection, method_selection, float_parameter_selection
from methods import rectangles, trapezoids, simpson
from util import RectangleMethodType

func_list = [
    Function([26, 7, -2, 3]),
    Function([-34, 11, -4, 5]),
    Function([-40, 6, -4, 2]),
    Function([-19, 6, -3, 1])
]


def main():
    func = function_selection(func_list)
    method_idx = method_selection()
    left_boundary = float_parameter_selection("left boundary")
    right_boundary = float_parameter_selection("right boundary")
    epsilon = float_parameter_selection("epsilon")

    res = None
    if method_idx == 1:
        res = rectangles(RectangleMethodType.LEFT, func, left_boundary, right_boundary, epsilon)
    elif method_idx == 2:
        res = rectangles(RectangleMethodType.RIGHT, func, left_boundary, right_boundary, epsilon)
    elif method_idx == 3:
        res = rectangles(RectangleMethodType.MIDDLE, func, left_boundary, right_boundary, epsilon)
    elif method_idx == 4:
        res = trapezoids(func, left_boundary, right_boundary, epsilon)
    elif method_idx == 5:
        res = simpson(func, left_boundary, right_boundary, epsilon)

    print(res.to_string())


if __name__ == "__main__":
    main()
