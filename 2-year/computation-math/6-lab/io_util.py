ACCURACY = 1e-8


class ASCIIColors:
    HEADER = "\033[95m"
    OKBLUE = "\033[94m"
    OKGREEN = "\033[92m"
    WARNING = "\033[93m"
    FAIL = "\033[91m"
    ENDC = "\033[0m"


def print_newline():
    print()


def print_header(msg: str):
    print(f"\n{ASCIIColors.HEADER}{msg}{ASCIIColors.ENDC}")


def print_msg(msg: str, newline=True):
    end = "\n" if newline else ''
    print(f"{ASCIIColors.OKBLUE}{msg}{ASCIIColors.ENDC}", end=end)

def print_warn(msg: str, newline=True):
    end = "\n" if newline else ''
    print(f"{ASCIIColors.WARNING}{msg}{ASCIIColors.ENDC}", end=end)

def print_err(msg: str):
    print(f"{ASCIIColors.FAIL}{msg}{ASCIIColors.ENDC}")


def read(pre_msg=">> "):
    return input(pre_msg)


def read_interval_and_point() -> {float, float, float}:
    print_msg("Specify [x0, xn] interval and y0 = y(x0) value (format: 'y0 x0 xn'): ")

    while True:
        try:
            y0, x0, xn = map(float, read().split(' '))
            if abs(x0 - xn) < ACCURACY:
                print_err(f"Interval must not have length less than {ACCURACY}")
            elif x0 > xn:
                print_err(f"Interval's left boundary must not be greater than right boundary")
            else:
                return y0, x0, xn
        except ValueError:
            print_err("Value error: float expected")


def read_float(var_name: str, zero_allowed=True, positive_only=False) -> float:
    print_msg(f"Specify {var_name} value: ")

    while True:
        try:
            val = float(read())
            if not zero_allowed and abs(val) < ACCURACY:
                print_err(f"Absolute value must not be less than {ACCURACY}")
            elif positive_only and val < 0:
                print_err(f"Absolute value must be positive")
            else:
                return val
        except ValueError:
            print_err("Value error: float expected")


def select_function(func_tuple: tuple[str, str, str, str]) -> int:
    print_msg(f"Select function")
    for i, name in enumerate(func_tuple):
        print_msg(f"[{i + 1}] {name}")

    while True:
        try:
            choice = int(read())
            if choice < 1 or choice > len(func_tuple):
                print_err("Invalid input: select one of the listed options")
            else:
                return choice - 1
        except ValueError:
            print_err("Value error: integer expected")
