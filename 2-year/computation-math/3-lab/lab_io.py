class bcolors:
    HEADER = "\033[95m"
    OKBLUE = "\033[94m"
    OKGREEN = "\033[92m"
    WARNING = "\033[93m"
    FAIL = "\033[91m"
    ENDC = "\033[0m"


def newline():
    print()


def print_err(msg):
    print(bcolors.FAIL + msg + bcolors.ENDC + "\nAborting")


def print_warning(msg):
    print(bcolors.WARNING + msg + bcolors.ENDC + "\nAborting")


def get_line(msg):
    return input(msg)


def get_int(msg):
    try:
        s = get_line(msg)
        if s is None:
            return None
        return int(s)
    except ValueError:
        print_err("Could not proceed input, integer expected")
        return None


def get_float(msg):
    try:
        return float(get_line(msg))
    except ValueError:
        print_err("Could not proceed input, float expected")
        return None


def function_selection(func_list):
    func_idx = -1
    while func_idx not in [j + 1 for j in range(len(func_list))]:
        print("Select function:")
        for i, f in enumerate(func_list):
            print("[{}] {}".format(i + 1, f.to_string()))
        func_idx = get_int("Your choice: ")
        newline()
    return func_list[func_idx - 1]


def method_selection():
    method_idx = -1
    while method_idx not in [j + 1 for j in range(5)]:
        print("Select method:")
        print("[{}] {}".format(1, "Rectangles Left"))
        print("[{}] {}".format(2, "Rectangles Right"))
        print("[{}] {}".format(3, "Rectangles Middle"))
        print("[{}] {}".format(4, "Trapezoids"))
        print("[{}] {}".format(5, "Simpson's"))
        method_idx = get_int("Your choice: ")
        newline()
    return method_idx


def float_parameter_selection(parameter_name):
    result = None
    msg = "Specify {}: ".format(parameter_name)

    while result is None:
        result = get_float(msg)
        newline()

    return result
