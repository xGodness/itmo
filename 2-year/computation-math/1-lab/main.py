def read_file():
    filename = input("Provide file name: ")
    print()
    matrix = []
    with open(filename) as f:
        n = int(f.readline())
        for i in range(n):
            matrix.append(list(map(float, f.readline().split(' '))))
    return matrix


def read_keyboard():
    n = int(input("Amount of rows: "))
    matrix = []
    print("Define matrix: ")
    for i in range(n):
        matrix.append(list(map(float, input().split(' '))))
    return matrix


def matrix_print(matrix, caption):
    n = len(matrix)
    print(" __\t\t{}:\n|".format(caption))
    for i in range(n):
        print("|", end=' ')
        for j in range(n):
            print("{:5.2f}".format(matrix[i][j]), end=' ')
        print("| {:5.2f}".format(matrix[i][n]))
    print("|__\n")


def vector_print(vector, name):
    print("_________________")
    print("|{:^15s}|".format(name))
    print("|_______________|")
    print("| Index | Value |")
    print("|_______|_______|")
    for i, val in enumerate(vector):
        print("| {:5d} | {:5.2f} |".format(i + 1, val))
    print("|_______|_______|\n")


def matrix_sort(matrix):
    n = len(matrix)
    for i, row in enumerate(matrix):
        if row[i] == 0:
            swapped = False
            for j in range(i + 1, n):
                if matrix[j][i] != 0:
                    matrix[i], matrix[j] = matrix[j], matrix[i]
                    swapped = True
                    break
            if not swapped:
                raise Exception("The determinant equals to zero. Matrix has an infinite number of solutions or has "
                                "not any.\n")
    return matrix


def matrix_to_triangular(matrix):
    n = len(matrix)

    for i in range(n):
        for j in range(n, i - 1, -1):
            matrix[i][j] /= matrix[i][i]

        for k in range(i + 1, n):
            for m in range(n, i - 1, -1):
                matrix[k][m] -= matrix[k][i] * matrix[i][m]

    return matrix


def matrix_gauss_reverse(matrix):
    n = len(matrix)
    x = [0] * n
    for i in range(n - 1, -1, -1):
        s = 0
        for j in range(i + 1, n):
            s -= matrix[i][j] * x[j]
        s += matrix[i][n]
        x[i] = s / matrix[i][i]
    return x


def matrix_gauss_inaccuracy(matrix, solutions):
    n = len(matrix)
    errors = []
    for row in matrix:
        s = 0
        for i in range(n):
            s += row[i] * solutions[i]

        errors.append(s - row[n])

    return errors


def main():
    cmd = ''
    while cmd != '3':
        print("Choose input source:")
        print("[1] Keyboard")
        print("[2] File")
        print("[3] Quit")
        cmd = input()

        if cmd == '1':
            matrix = read_keyboard()
        elif cmd == '2':
            matrix = read_file()
        else:
            continue

        matrix_print(matrix, "Provided matrix")

        try:
            matrix = matrix_sort(matrix)
        except Exception as ex:
            print(str(ex))
            cmd = ''
            continue

        matrix = matrix_to_triangular(matrix)
        matrix_print(matrix, "Triangular matrix")

        solution = matrix_gauss_reverse(matrix)
        vector_print(solution, "Solution")

        inaccuracy = matrix_gauss_inaccuracy(matrix, solution)
        vector_print(inaccuracy, "Inaccuracy")


if __name__ == "__main__":
    main()
