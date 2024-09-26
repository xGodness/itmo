from typing import Tuple


def read_file(read_format="r") -> str | bytes:
    text = None
    while text is None:
        filename = input("Provide file name: ")
        try:
            with open(filename, read_format) as f:
                text = f.read()
        except FileNotFoundError:
            print(f'File {filename} was not found\n')
        except PermissionError:
            print(f'Cannot read file {filename}\n')
    return text


def write_to_file(filename: str, data: str | bytes, write_format="w") -> None:
    with open(filename, write_format) as f:
        f.write(data)


def read_two_int_keys() -> Tuple[int, int]:
    key_1 = None
    key_2 = None
    while key_1 is None or key_2 is None:
        try:
            key_1 = int(input("Provide first encryption key: "))
            key_2 = int(input("Provide second encryption key: "))
        except ValueError:
            print("Keys must be integer values. Try again\n")
    return key_1, key_2


def read_str_keyword() -> str:
    keyword = None
    while keyword is None:
        keyword = input("Supply keyword: ")
        if len(keyword.strip()) == 0:
            print("Keyword must not be empty string\n")
            keyword = None
    return keyword
