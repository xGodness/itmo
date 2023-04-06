import sys

from linear_functions import func_to_string
from methods import method_to_string


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


def get_line(filename_opt, msg):
    if not filename_opt:
        return input(msg)
    try:
        with open(filename_opt, "r+") as f:
            return f.readline()
    except FileNotFoundError:
        print_err("File with such name does not exist")
        return None


def get_int(filename_opt, msg):
    try:
        s = get_line(filename_opt, msg)
        if s is None:
            return None
        return int(s)
    except ValueError:
        print_err("Could not proceed input, integer expected")
        return None


def get_float(filename_opt, msg):
    try:
        return float(get_line(filename_opt, msg))
    except ValueError:
        print_err("Could not proceed input, float expected")
        return None


def linear_or_system_selection():
    cmd = 0
    while cmd != 3:
        cmd = get_int(None, "Choose:\n[1] Linear equations\n[2] System of equations\n[3] Quit\nYour choice: ")
        if cmd == 1:
            return 1
        if cmd == 2:
            return 2
    sys.exit()


def function_selection(func_list):
    func_idx = 0
    while func_idx not in func_list.keys():
        print("Select function:")
        for i in func_list.keys():
            print("[{}] {}".format(i, func_to_string(i)))
        func_idx = get_int(None, "Your choice: ")
        newline()
    return func_list[func_idx]


def method_selection(methods_list):
    method_idx = 0
    while method_idx not in methods_list.keys():
        print("Select method: ")
        for i in methods_list.keys():
            print("[{}] {}".format(i, method_to_string(i)))
        method_idx = get_int(None, "Your choice: ")
        newline()
    return methods_list[method_idx]


def input_source_selection():
    cmd = ''
    while cmd != 3:
        print("Choose input source:")
        print("[1] Keyboard")
        print("[2] File")
        print("[3] Quit")
        cmd = get_int(None, "Your choice: ")

        if cmd == 1:
            return None
        if cmd == 2:
            return get_line(None, "Specify file name: ")
        elif cmd == 3:
            continue
    sys.exit()


def float_parameter_selection(parameter_name, filename_opt):
    result = None
    msg = "Specify {}: ".format(parameter_name) if not filename_opt else ""

    while result is None:
        result = get_float(filename_opt, msg)

    return result


def system_selection(systems, filename_opt):
    print("Select system:")
    system_idx = -1
    while system_idx not in [i for i in range(1, len(systems) + 1)]:
        for i, e in enumerate(systems):
            print("[{}] {}".format(i + 1, e.to_string()))
        system_idx = get_int(filename_opt, "Your choice: ")
    return systems[system_idx - 1]


def initial_approximation(filename_opt):
    x = get_float(filename_opt, "Specify x approximation: ")
    y = get_float(filename_opt, "Specify y approximation: ")
    return x, y
