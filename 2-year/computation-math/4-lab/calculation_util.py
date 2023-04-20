def calculate_pearson_corr(exact_values, approx_values):
    n = min(len(exact_values), len(approx_values))
    exact_values = exact_values[:n]
    approx_values = approx_values[:n]
    x_mean = sum(exact_values) / n
    y_mean = sum(approx_values) / n

    sum_prod = 0
    sum_sq_x = 0
    sum_sq_y = 0
    for i in range(n):
        dx = exact_values[i] - x_mean
        dy = approx_values[i] - y_mean
        sum_prod += dx * dy
        sum_sq_x += dx ** 2
        sum_sq_y += dy ** 2

    return sum_prod / (sum_sq_x * sum_sq_y) ** 0.5
