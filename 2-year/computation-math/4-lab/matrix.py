from results import Results


class Matrix:
    def __init__(self, size, data):
        self.size = size
        self.data = data

    def sort(self):
        for i, row in enumerate(self.data):
            if row[i] == 0:
                swapped = False
                for j in range(i + 1, self.size):
                    if self.data[j][i] != 0:
                        self.data[i], self.data[j] = self.data[j], self.data[i]
                        swapped = True
                        break
                if not swapped:
                    return Results(
                        True,
                        "The determinant equals to zero. Matrix has an infinite number of solutions or has not any",
                        None
                    )
        return Results(False, "OK", None)

    def triangularize(self):
        for i in range(self.size):
            for j in range(self.size, i - 1, -1):
                if self.data[i][i] != 0:
                    self.data[i][j] /= self.data[i][i]

            for k in range(i + 1, self.size):
                for m in range(self.size, i - 1, -1):
                    self.data[k][m] -= self.data[k][i] * self.data[i][m]

        return Results(False, "OK", None)
