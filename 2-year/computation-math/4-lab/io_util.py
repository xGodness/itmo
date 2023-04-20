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
    print(bcolors.FAIL + msg + bcolors.ENDC)


def print_warning(msg):
    print(bcolors.WARNING + msg + bcolors.ENDC)


def get_lines(filename_opt, msg_x, msg_y):
    if not filename_opt:
        return input(msg_x), input(msg_y)
    try:
        with open(filename_opt, "r+") as f:
            return f.readline(), f.readline()
    except FileNotFoundError:
        print_err("File with such name does not exist")
        return None


def get_points(filename_opt, msg_x, msg_y, cnt_floor, cnt_ceil):
    try:
        line_x, line_y = get_lines(filename_opt, msg_x, msg_y)
        data_x = [float(i) for i in line_x.split(' ')]
        if len(data_x) < cnt_floor or len(data_x) > cnt_ceil:
            print_err("Inappropriate input, number of points must be between 8 and 12 (including)")
            return None
        data_y = [float(i) for i in line_y.split(' ')]
        if len(data_y) < cnt_floor or len(data_y) > cnt_ceil:
            print_err("Inappropriate input, number of points must be between 8 and 12 (including)")
            return None
        return data_x, data_y
    except ValueError:
        print_err("Could not proceed input, floats expected")
        return None


def input_src_selection():
    print("Select input source:\n[1] Keyboard\n[2] File\n")
    cmd = None
    while cmd not in [1, 2]:
        try:
            cmd = int(input("Your choice: "))
        except ValueError:
            continue

    if cmd == 2:
        filename = input("Specify file name: ")
        while True:
            try:
                open(filename, "r+")
                return filename
            except FileNotFoundError:
                print_err("File with such name does not exist")

    return None
