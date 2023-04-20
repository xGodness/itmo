from approximation_builder import ApproximationBuilder
from io_util import input_src_selection, get_points, print_err, print_warning
from approximation_data import ApproximationData
from graphing import draw


def main():
    filename_opt = input_src_selection()

    x_arr = None
    y_arr = None

    while None in [x_arr, y_arr]:
        x_arr, y_arr = get_points(filename_opt, "Specify x values: ", "Specify y values: ", 3, 12)

    if len(x_arr) != len(y_arr):
        print_err("Arrays of x and y values does not have the same length")
        return

    builder = ApproximationBuilder(x_arr, y_arr)

    building_results = [
        builder.linear(),
        builder.poly_square(),
        builder.poly_cubic(),
        builder.exponential(),
        builder.logarithmic(),
        builder.power()
    ]

    approximations = []
    for res in building_results:
        if res.is_error:
            print_warning(res.message)
            continue
        approximations.append(
            ApproximationData(res.data["type"], x_arr, y_arr, res.data["approx_y"], res.data["coeffs"])
        )

    min_deviation = float("inf")
    best_approx = None
    for approx in approximations:
        approx.print()

        if approx.standard_deviation <= min_deviation:
            min_deviation = approx.standard_deviation
            best_approx = approx.approx_type.value

    print('-' * 40 + f"\nBest approximation: {best_approx}\n" + '-' * 40)

    draw(x_arr, y_arr, approximations)


if __name__ == "__main__":
    main()
