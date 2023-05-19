from matplotlib import pyplot as plt


def draw_plot(x_arr: list[float], y_arr: list[float], exact_y_arr: list[float], title: str) -> None:
    alpha = 0.75
    plt.title(title)
    plt.plot(x_arr, exact_y_arr, label="Exact values", alpha=alpha, lw=3)
    plt.plot(x_arr, y_arr, label="Solution", alpha=alpha, lw=2)
    plt.grid()
    plt.legend()
    plt.show()
