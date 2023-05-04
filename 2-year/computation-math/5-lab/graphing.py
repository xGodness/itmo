from matplotlib import pyplot as plt
from numpy import linspace


def graph(data, target_x, target_y, method, title: str):
    data_x = [i.x for i in data.point_arr]
    data_y = [i.y for i in data.point_arr]

    plt.figure()
    plt.title = title
    plt.grid(True)

    plt.scatter(data_x, data_y, s=20, label="Initial data", zorder=10)

    x_linspace = linspace(data_x[0], data_x[-1], 100)
    interpolated_y = [method(data, x) for x in x_linspace]
    plt.plot(x_linspace, interpolated_y, zorder=5, label=title)

    plt.plot(target_x, target_y, 'o', markersize=5, zorder=10, label="Point of the interpolation")

    plt.legend(fontsize="x-small")
    plt.show()
