from numpy import log, sin, abs, pi, linspace

from graphing import graph
from interpolation_methods import lagrange, newton, stirling, bessel
from interpolation_util import Point, InterpolationData
from io_util import read_int_until_success, read_map_float_until_success, select_option_until_success, \
    get_file_until_success, print_warn, print_res

func_define_opts = ["With points", "With formula"]
input_src_select_opts = ["Keyboard", "File"]
func_select_opt = ["x*sin*(4*ln|x|)", "|sin(3*pi*x / 5) / ln(|x/7| + 1)|"]

functions = {
    0: lambda x: x * sin(4 * log(abs(x))),
    1: lambda x: abs(sin(3 * pi * x / 5) / log(abs(x / 7) + 1))
}

filename = None
target_x = None


def is_x_distances_valid(arr: list[Point]):
    h = round(arr[1].x - arr[0].x, 5)
    for i in range(1, len(arr) - 1):
        if round(abs(arr[i + 1].x - arr[i].x - h), 5) > 1e-8:
            return False
    return True


def main():
    global filename, target_x
    interpolation = InterpolationData()

    func_def = select_option_until_success(func_define_opts, "Select the function define method:")

    if func_def == 0:
        points_cnt = read_int_until_success("How many points will be provided?", True)

        input_src = select_option_until_success(input_src_select_opts, "Select the input source:")
        filename = get_file_until_success() if input_src == 1 else None

        coords = read_map_float_until_success(msg="Specify the points' x and y coordinates:",
                                              float_cnt=2, iter_cnt=points_cnt)
        for c in coords:
            interpolation.add_point(Point(round(c[0], 5), round(c[1], 5)))
    else:
        func = functions[select_option_until_success(func_select_opt, "Select the function:")]
        boundaries = sorted(read_map_float_until_success("Specify the segment boundaries:", iter_cnt=1, float_cnt=2)[0])
        if abs(boundaries[0] - boundaries[1]) < 1e-4:
            print_warn("Nothing to interpolate with a such inappropriate request... Aborting")
            return

        node_cnt = read_int_until_success("Specify the number of initial points:", positive_only=True)
        if node_cnt < 2:
            print_warn("Nothing to interpolate with a such inappropriate request... Aborting")
            return

        x_space = list(linspace(boundaries[0], boundaries[1], node_cnt))
        for x in x_space:
            interpolation.add_point(Point(x, func(x)))

    target_valid = False
    interpolation.sort()

    if not is_x_distances_valid(interpolation.point_arr):
        print_warn("Distances between neighbouring x-es must be the same to calculate finite differences. Aborting")
        return

    while not target_valid:
        target_x = read_map_float_until_success(msg="Specify point to interpolate at:", float_cnt=1)[0][0]
        target_valid = interpolation.min_x < target_x < interpolation.max_x
        if not target_valid:
            print_warn("Point's to be interpolated x coordinate must be inside interval "
                       f"({interpolation.min_x}, {interpolation.max_x})")

    interpolation.target_x = target_x
    interpolation.x_step = interpolation.point_arr[1].x - interpolation.min_x
    interpolation.calculate_differences()

    interpolation.print_diff()

    val_newton = newton(interpolation, interpolation.target_x)
    val_lagrange = lagrange(interpolation, interpolation.target_x)
    val_stirling = stirling(interpolation, interpolation.target_x)
    val_bessel = bessel(interpolation, interpolation.target_x)

    print_res("{:20s}: {:^10.4f}".format("Newton's method", val_newton))
    print_res("{:20s}: {:^10.4f}".format("Lagrange's method", val_lagrange))
    print_res("{:20s}: {:^10.4f}".format("Stirling's method", val_stirling))
    print_res("{:20s}: {:^10.4f}".format("Bessel's method", val_bessel))

    graph(interpolation, target_x, val_newton, newton, "Newton")
    graph(interpolation, target_x, val_lagrange, lagrange, "Lagrange")


if __name__ == "__main__":
    main()
