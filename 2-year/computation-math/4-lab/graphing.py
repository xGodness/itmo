from matplotlib import pyplot as plt
from scipy.interpolate import make_interp_spline
from numpy import linspace

colors = ["blue", "green", "orange", "purple", "red", "pink"]


def smoothen(x, y, label, color, width):
    try:
        spline = make_interp_spline(x, y)
        x_smooth = linspace(min(x), max(x), 500)
        y_smooth = spline(x_smooth)
        plt.plot(x_smooth, y_smooth, c=color, label=label, linewidth=width)
    except ValueError:
        plt.plot(x, y, c=color, label=label, linewidth=width)


def draw(source_x, source_y, approximations):
    smoothen(source_x, source_y, "Function", "black", 4)

    color_idx = 0
    for approx in approximations:
        smoothen(source_x, approx.approx_y, approx.approx_type.value, colors[color_idx], 1)
        color_idx += 1
    plt.legend()
    plt.show()
