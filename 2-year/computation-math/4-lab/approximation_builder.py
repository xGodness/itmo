from math import log, e

from matrix import Matrix
from matrix_solver import gauss_solve
from results import Results
from approximation_data import ApproximationType


class ApproximationBuilder:
    def __init__(self, x, y):
        self.n = min(len(x), len(y))
        self.x = x[:self.n]
        self.y = y[:self.n]

        self.sx = 0
        self.sx2 = 0
        self.sx3 = 0
        self.sx4 = 0
        self.sx5 = 0
        self.sx6 = 0
        self.sy = 0
        self.syx = 0
        self.syx2 = 0
        self.syx3 = 0

        for i in range(self.n):
            self.sx += x[i]
            self.sx2 += x[i] ** 2
            self.sx3 += x[i] ** 3
            self.sx4 += x[i] ** 4
            self.sx5 += x[i] ** 5
            self.sx6 += x[i] ** 6
            self.sy += y[i]
            self.syx += y[i] * x[i]
            self.syx2 += y[i] * x[i] ** 2
            self.syx3 += y[i] * x[i] ** 3

        self.slnx = 0
        self.slnx2 = 0
        self.sylnx = 0
        self.slny = 0
        self.sxlny = 0
        self.slnxlny = 0
        try:
            for i in range(self.n):
                self.slnx += log(self.x[i])
                self.slnx2 += log(self.x[i]) ** 2
                self.sylnx += log(self.x[i]) * self.y[i]
                self.slny += log(self.y[i])
                self.sxlny += log(self.y[i]) * self.x[i]
                self.slnxlny += log(self.y[i]) * log(self.x[i])
        except ValueError:
            self.slnx = None
            self.slnx2 = None
            self.sylnx = None
            self.slny = None
            self.sxlny = None
            self.slnxlny = None

    def linear(self):
        matrix = Matrix(2,
                        [
                            [self.sx, self.sx2, self.syx],
                            [self.n, self.sx, self.sy]
                        ])
        coeffs = gauss_solve(matrix).data
        approx_y = []
        for i in self.x:
            approx_y.append(coeffs[0] + coeffs[1] * i)
        return Results(False, "OK", {"coeffs": coeffs, "approx_y": approx_y, "type": ApproximationType.LINEAR})

    def poly_square(self):
        matrix = Matrix(3,
                        [
                            [self.n, self.sx, self.sx2, self.sy],
                            [self.sx, self.sx2, self.sx3, self.syx],
                            [self.sx2, self.sx3, self.sx4, self.syx2]
                        ])
        coeffs = gauss_solve(matrix).data
        approx_y = []
        for i in self.x:
            approx_y.append(coeffs[0] + coeffs[1] * i + coeffs[2] * i ** 2)
        return Results(False, "OK", {"coeffs": coeffs, "approx_y": approx_y, "type": ApproximationType.POLY_SQUARE})

    def poly_cubic(self):
        matrix = Matrix(4,
                        [
                            [self.n, self.sx, self.sx2, self.sx3, self.sy],
                            [self.sx, self.sx2, self.sx3, self.sx4, self.syx],
                            [self.sx2, self.sx3, self.sx4, self.sx5, self.syx2],
                            [self.sx3, self.sx4, self.sx5, self.sx6, self.syx3]
                        ])
        coeffs = gauss_solve(matrix).data
        approx_y = []
        for i in self.x:
            approx_y.append(coeffs[0] + coeffs[1] * i + coeffs[2] * i ** 2 + coeffs[3] * i ** 3)
        return Results(False, "OK", {"coeffs": coeffs, "approx_y": approx_y, "type": ApproximationType.POLY_CUBIC})

    def exponential(self):
        if None in [self.slny, self.sxlny]:
            return Results(True, "Cannot proceed exponential approximation for y < 0", {"coeffs": [], "approx_y": []})
        matrix = Matrix(2, [
            [self.n, self.sx, self.slny],
            [self.sx, self.sx2, self.sxlny]
        ])
        coeffs = gauss_solve(matrix).data
        coeffs[0] = e ** coeffs[0]

        approx_y = []
        for i in self.x:
            approx_y.append(coeffs[0] * e ** (coeffs[1] * i))
        return Results(False, "OK", {"coeffs": coeffs, "approx_y": approx_y, "type": ApproximationType.EXPONENTIAL})

    def logarithmic(self):
        if None in [self.slnx, self.slnx2, self.sylnx]:
            return Results(True, "Cannot proceed logarithmic approximation for x < 0", {"coeffs": [], "approx_y": []})

        matrix = Matrix(2, [
            [self.slnx2, self.slnx, self.sylnx],
            [self.slnx, self.n, self.sy]
        ])
        coeffs = gauss_solve(matrix).data

        approx_y = []
        for i in self.x:
            approx_y.append(coeffs[0] * log(i) + coeffs[1])
        return Results(False, "OK", {"coeffs": coeffs, "approx_y": approx_y, "type": ApproximationType.LOGARITHMIC})

    def power(self):
        if None in [self.slnx, self.slnx2, self.slny, self.slnxlny]:
            return Results(True, "Cannot proceed power approximation for x < 0 or y < 0", {"coeffs": [], "approx_y": []})

        matrix = Matrix(2, [
            [self.n, self.slnx, self.slny],
            [self.slnx, self.slnx2, self.slnxlny]
        ])
        coeffs = gauss_solve(matrix).data
        coeffs[0] = e ** coeffs[0]
        approx_y = []
        for i in self.x:
            approx_y.append(coeffs[0] * i ** coeffs[1])
        return Results(False, "OK", {"coeffs": coeffs, "approx_y": approx_y, "type": ApproximationType.POWER})
