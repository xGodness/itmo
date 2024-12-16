from sympy import symbols, Piecewise, plot
from math import log10
from matplotlib import pyplot as plt


def plot_show(intervals):
    x = symbols('x')
    f = Piecewise(
        *[(i[2], (i[0] < x) & (x <= i[1])) for i in intervals]
    )
    plot(f)


def hist_show(x_hist, y, h):
    plt.bar(x_hist, y, width=h, fill=False)
    plt.xlabel("Value")
    plt.ylabel("Density frequency")
    # plt.show()


def polygon_show(x_polygon, y):
    plt.plot(x_polygon, y, c="red")
    plt.show()


def print_results(data, series, data_extreme_values, data_range, series_expected_value, series_standard_deviation):
    print(f'\nData:\n  |\t{", ".join([str(i) for i in data])}\n')

    print("   " + '_' * 15 + ' ' + "\n  | {:^5s} | {:^5s} |"
          .format("X", "P"))
    print('  |' + '_' * 15 + '|')
    for k in series:
        print("  | {:5.2f} | {:5.2f} |"
              .format(k, series[k]))
    print("  |" + '_' * 15 + "|\n")

    print("Extreme values:\n  |\tmin: {}\n  |\tmax: {}\n"
          .format(data_extreme_values[0], data_extreme_values[1]))

    print("Data range:\n  |\t{:5.2f}\n"
          .format(data_range))

    print("Expected value:\n  |\t{:5.2f}\n"
          .format(series_expected_value))

    print("Standard deviation:\n  |\t{:5.2f}\n"
          .format(series_standard_deviation))


def print_function(intervals):
    print("F(x) =\n   ___\n  |")
    for i in intervals:
        print("  |\t{:5.2f}\tIF\t{:5.2f} < x <= {:4.2f}".format(i[2], i[0], i[1]))
    print("  |___\n")


def main():
    data = [-0.03, 0.73, -0.59, -1.59, 0.38, 1.49, 0.14, -0.62, -1.59, 1.45, -0.38, -1.49, -0.15, 0.63, 0.06, -1.59,
            0.61, 0.62, -0.05, 1.56]
    size = len(data)

    data.sort()

    data_set = sorted(set(data))

    data_map = {}
    series = {}
    series_expected_value = 0
    series_squared_expected_value = 0
    for n in data_set:
        data_map[n] = data.count(n)
        series[n] = data_map[n] / size

        series_expected_value += n * series[n]
        series_squared_expected_value += n ** 2 * series[n]

    data_extreme_values = [data[0], data[-1]]
    data_range = data_extreme_values[1] - data_extreme_values[0]

    series_variance = (series_squared_expected_value - series_expected_value ** 2) * n / (n - 1)

    series_standard_deviation = series_variance ** 0.5

    intervals = [[float("-inf"), data_set[0], 0]]
    for i in range(len(data_set) - 1):
        p = series[data_set[i]] + intervals[i][2]

        intervals.append([data_set[i], data_set[i + 1], p])

    intervals.append([data_set[-1], float("+inf"), 1])

    print_results(data, series, data_extreme_values, data_range, series_expected_value, series_standard_deviation)
    print_function(intervals)
    plot_show(intervals)

    # ____________________________________________________________________________________________________________________

    k = int(1 + 3.322 * log10(size))
    h = data_range / k
    offset = data_extreme_values[0]
    hist_intervals = []
    for i in range(k):
        hist_intervals.append([])

    int_idx = 1
    ceil = offset + int_idx * h
    for i in data:
        if i >= ceil:
            int_idx += 1
            ceil += h
        hist_intervals[int_idx - 1].append(i)

    hist_data = []
    for i, e in enumerate(hist_intervals):
        hist_data.append(
            {
                "interval": e,
                "density_frequency": len(e) / size / h,
                "floor": offset + i * h,
                "pivot": offset + i * h + h / 2
            }
        )

    x_hist = [i["floor"] + h / 2 for i in hist_data]
    x_polygon = [i["floor"] + h / 2 for i in hist_data]
    y = [i["density_frequency"] for i in hist_data]

    hist_show(x_hist, y, h)
    polygon_show(x_polygon, y)


if __name__ == "__main__":
    main()
    
