from enum import Enum

from calculation_util import calculate_pearson_corr

HEADER = "\033[95m"
ENDC = "\033[0m"


class ApproximationType(Enum):
    LINEAR = "Linear"
    POLY_SQUARE = "Square polynomial"
    POLY_CUBIC = "Cubic polynomial"
    EXPONENTIAL = "Exponential"
    LOGARITHMIC = "Logarithmic"
    POWER = "Power"


class ApproximationData:
    def __init__(self, approx_type, x, exact_y, approx_y, coeffs):
        self.n = min(len(x), len(exact_y), len(approx_y))

        self.approx_type = approx_type
        self.x = x[:self.n]
        self.exact_y = exact_y[:self.n]
        self.approx_y = approx_y[:self.n]
        self.coeffs = coeffs

        self.eps = [self.approx_y[i] - self.exact_y[i] for i in range(self.n)]

        self.deviation_measure = sum([(self.approx_y[i] - self.exact_y[i]) ** 2 for i in range(self.n)])
        self.standard_deviation = (self.deviation_measure / self.n) ** 0.5

        self.pearson_corr = None
        if approx_type == ApproximationType.LINEAR:
            self.pearson_corr = calculate_pearson_corr(exact_y, approx_y)

    def print(self):
        print(HEADER + f'\n\n{self.approx_type.value} approximation' + ENDC)
        print("|\n| Coefficients:\n|\n \\\n  |\t{}".format(', '.join([str(round(i, 3)) for i in self.coeffs])))
        print("  |\n /")
        print("|\n| Standard deviation:\n|\n \\\n  |\t{:.2e}".format(self.standard_deviation))
        if self.approx_type == ApproximationType.LINEAR:
            print("  |\n /\n|\n| Pearson correlation coefficient:\n|\n \\\n  |\t{:.2e}".format(self.pearson_corr))
        print("  |\n /\n|\n|")
        print("")
        print('_' * 53)
        print("| {:^10s} | {:^10s} | {:^10s} | {:^10s} |".format("x", "y", "f(x)", "eps"))
        print(('|' + '_' * 12) * 4 + '|')
        for i in range(self.n):
            print("| {:10.2e} | {:10.2e} | {:10.2e} | {:10.2e} |"
                  .format(self.x[i], self.exact_y[i], self.approx_y[i], self.eps[i]))
        print(('|' + '_' * 12) * 4 + "|\n")
