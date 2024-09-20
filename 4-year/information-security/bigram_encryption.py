from typing import Tuple

from BigramEncryptor import BigramEncryptor


def read_keys() -> Tuple[int, int]:
    key_1 = None
    key_2 = None
    while key_1 is None or key_2 is None:
        try:
            key_1 = int(input("Provide first encryption key: "))
            key_2 = int(input("Provide second encryption key: "))
        except ValueError:
            print("Keys must be integer values. Try again\n")
    return key_1, key_2


def init_encryptor() -> BigramEncryptor:
    encryptor = None
    while encryptor is None:
        key_1, key_2 = read_keys()
        try:
            encryptor = BigramEncryptor(key_1, key_2)
        except ValueError as e:
            print(f'{e}\n')
    return encryptor


def read_file() -> str:
    text = None
    while text is None:
        filename = input("Provide file name: ")
        try:
            with open(filename, 'r') as f:
                text = f.read()
        except FileNotFoundError:
            print(f'File {filename} was not found\n')
        except PermissionError:
            print(f'Cannot read file {filename}\n')
    return text


def main():
    encryptor = init_encryptor()

    lines = read_file().split('\n')

    print("\nOriginal text:")
    for line in lines: print(line)
    print()

    try:
        encr_lines = [encryptor.encrypt(line) for line in lines]
    except ValueError as e:
        print(f'{e}\n')
        return

    print("Encrypted text:")
    for line in encr_lines: print(line)
    print()

    print("Decrypted text:")
    for line in encr_lines: print(encryptor.decrypt(line))


if __name__ == "__main__":
    main()
