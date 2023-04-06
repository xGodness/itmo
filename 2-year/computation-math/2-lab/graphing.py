from matplotlib import pyplot as plt
from numpy import linspace, arange
from sympy import plot_implicit

plt.rcParams["figure.figsize"] = [7.50, 3.50]
plt.rcParams["figure.autolayout"] = True


def draw_plot(func, left, right):
    x = linspace(left - 10, right + 10, 100)

    plt.axvline(x=0, c="black")
    plt.axhline(y=0, c="black")

    plt.xticks(arange(left - 10, right + 10, 1))

    plt.plot(x, func(x))

    plt.show()


def draw_system_graph(system):
    p1 = plot_implicit(system.sympy_eq[0], aspect_ratio=(1, 1), line_color="blue", show=False)

    p2 = plot_implicit(system.sympy_eq[1], aspect_ratio=(1, 1), line_color="red", show=False)

    p1.append(p2[0])

    p1.show()
