from results import Results

ROUND_CONST = 3


def gauss_solve(matrix):
    matrix.sort()
    matrix.triangularize()

    n = matrix.size
    data = matrix.data

    solutions = [0] * n
    for i in range(n - 1, -1, -1):
        s = 0
        for j in range(i + 1, n):
            s -= data[i][j] * solutions[j]
        s += data[i][n]
        if data[i][i] != 0:
            solutions[i] = round(s / data[i][i], ROUND_CONST)
        else:
            solutions[i] = 0

    return Results(False, "OK", solutions)
