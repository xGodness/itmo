import sys
from enum import Enum
from os.path import isfile

MAX_NODE_CNT = 20


class ASCIIColors:
    HEADER = "\033[95m"
    OKBLUE = "\033[94m"
    OKGREEN = "\033[92m"
    WARNING = "\033[93m"
    FAIL = "\033[91m"
    ENDC = "\033[0m"


class ReadResult:
    is_success: bool
    data: any

    def __init__(self, is_success, data):
        self.is_success = is_success
        self.data = data


class ErrorMsgTemplates(Enum):
    FILE_NOT_FOUND = "File with such name does not exist"
    FLOAT_EXPECTED = "Could not proceed input, float expected"
    INT_EXPECTED = "Could not proceed input, integer expected"
    MORE_VALUES_EXPECTED = "Could not proceed input, at least {} and 100 at most value(s) were expected"
    POSITIVE_EXPECTED = "Could not proceed input, positive number expected",
    INTEGER_TOO_LARGE = f"Too large, value must not be larger than {MAX_NODE_CNT}"

    def stringify(self, msg=""):
        return self.value.format(msg)


rd_res_dummy = ReadResult(False, "")
file = None


# ----------------------- Printing functions ----------------------- #


def print_newline():
    print()


def print_err(msg):
    print(f'{ASCIIColors.FAIL}{msg}{ASCIIColors.ENDC}')


def print_warn(msg):
    print(f"{ASCIIColors.WARNING}{msg}{ASCIIColors.ENDC}")


def print_res(msg, end="\n"):
    print(f"{ASCIIColors.OKBLUE}{msg}{ASCIIColors.ENDC}", end=end)


# ----------------------- Reading functions ----------------------- #


def read_line(msg, end_newline=True, sep="\n") -> ReadResult:
    global file
    if not file:
        res = ReadResult(True, input(f"{msg}{sep}>> "))
    else:
        try:
            res = ReadResult(True, file.readline())
        except FileNotFoundError:
            err_msg = ErrorMsgTemplates.FILE_NOT_FOUND.stringify()
            print_err(err_msg)
            res = ReadResult(False, err_msg)

    if end_newline:
        print_newline()
    return res


def read_map_float(msg, float_cnt=1, end_newline=True, sep="\n") -> ReadResult:
    line_rd_res = read_line(msg, end_newline=end_newline, sep=sep)
    if not line_rd_res.is_success:
        return line_rd_res

    try:
        rd_res = ReadResult(True, [float(i) for i in line_rd_res.data.replace("\t", ' ').split(" ")])
    except ValueError:
        err_msg = ErrorMsgTemplates.FLOAT_EXPECTED.stringify()
        print_err(err_msg)
        return ReadResult(False, err_msg)

    if not rd_res.is_success:
        return rd_res
    if float_cnt <= len(rd_res.data) <= 100:
        rd_res.data = rd_res.data[:float_cnt]
        return rd_res
    err_msg = ErrorMsgTemplates.MORE_VALUES_EXPECTED.stringify(float_cnt)
    print_err(err_msg)
    return ReadResult(False, err_msg)


def read_int(msg="", positive_only=False) -> ReadResult:
    line_rd_res = read_line(msg)
    if not line_rd_res.is_success:
        return line_rd_res

    try:
        val = int(line_rd_res.data)
        if val > MAX_NODE_CNT:
            err_msg = ErrorMsgTemplates.INTEGER_TOO_LARGE.stringify()
            print_err(err_msg)
            return ReadResult(False, err_msg)

        if val > 0 or not positive_only:
            return ReadResult(True, val)

        err_msg = ErrorMsgTemplates.POSITIVE_EXPECTED.stringify()
        print_err(err_msg)
        return ReadResult(False, err_msg)

    except ValueError:
        err_msg = ErrorMsgTemplates.INT_EXPECTED.stringify()
        print_err(err_msg)
        return ReadResult(False, err_msg)


# ----------------------- Until success functions ----------------------- #


def read_map_float_until_success(msg="", iter_cnt=1, float_cnt=1) -> list[list[float]]:
    if not file:
        print(msg)

    err_cnt = 0
    result = []

    while iter_cnt:
        rd_res = rd_res_dummy
        while not rd_res.is_success and err_cnt < 20:
            rd_res = read_map_float(msg="", float_cnt=float_cnt, end_newline=(iter_cnt == 1), sep="")
            if not rd_res.is_success:
                err_cnt += 1

        if err_cnt >= 20:
            print_err("Too many failures. Aborting")
            sys.exit(13)

        iter_cnt -= 1
        result.append(rd_res.data)

    return result


def read_int_until_success(msg="", positive_only=False) -> int:
    rd_res = rd_res_dummy
    while not rd_res.is_success:
        rd_res = read_int(msg, positive_only)
    return rd_res.data


def select_option_until_success(options, msg="") -> int:
    choice = 0
    while not 0 < choice <= len(options):
        if not file:
            print(msg)
            for idx, opt in enumerate(options):
                print(f"[{idx + 1}] {opt}", end=("\n" if idx + 1 < len(options) else ''))
        rd_res = read_int()
        if rd_res.is_success:
            choice = rd_res.data
    return choice - 1


def get_file_until_success() -> str:
    file_exists = False
    rd_res = None
    while not file_exists:
        rd_res = read_line("Specify file name:")
        if rd_res.is_success:
            file_exists = isfile(rd_res.data)

    global file
    file = open(rd_res.data)
    return rd_res.data
