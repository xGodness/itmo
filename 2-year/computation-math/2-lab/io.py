class bcolors:
    HEADER = "\033[95m"
    OKBLUE = "\033[94m"
    OKGREEN = "\033[92m"
    WARNING = "\033[93m"
    FAIL = "\033[91m"
    ENDC = "\033[0m"


def print_err(msg):
    print(bcolors.FAIL + msg + bcolors.ENDC + "\n Aborting")


def print_warning(msg):
    print(bcolors.WARNING + msg + bcolors.ENDC + "\n Aborting")


def get_line(source, msg):
    if source:
        try:
            return source.readline()
        except FileNotFoundError:
            print_err("File with such name does not exist")
            return None
    return input(msg)


def get_float(source, msg):
    try:
        return float(get_line(source, msg))
    except ValueError:
        print_err("Could not proceed input, number expected")
        return None


def validate_borders(left, right):
    if right - left > 50:
        print_warning("Provided interval's length must not surpass 50")
        return False
    return True


def validate_eps(eps):
    if eps < 0.00001:
        print("Provided epsilon must not be lower than 0.00001")
        return False
    return True
