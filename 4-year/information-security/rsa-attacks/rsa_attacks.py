from enum import Enum


def to_text(data: int) -> str:
    return data.to_bytes(length=4, byteorder="big").decode("cp1251")


def fermat(modulo: int, exponent: int, ciphertext: list[int]):
    n = int(modulo ** 0.5) + 1

    t = n
    w = t ** 2 - modulo

    if n ** 2 != modulo:
        while w != int(w ** 0.5) ** 2:
            t += 1
            w = t ** 2 - modulo

    p = int(t + w ** 0.5)
    q = int(t - w ** 0.5)

    phi = int((p - 1) * (q - 1))
    d = pow(exponent, -1, phi)

    print("Fermat method parameters:\n"
          f"t   = {t}\n"
          f"w   = {w}\n"
          f"p   = {p}\n"
          f"q   = {q}\n"
          f"phi = {phi}\n"
          f"d   = {d}\n")

    result = ""

    for element in ciphertext:
        msg = pow(element, d, modulo)
        result += to_text(msg)

    return result


def recipher(modulo: int, exponent: int, ciphertext: list[int]) -> str:
    result = ""
    exp_order = 1

    entry = ciphertext[0]
    cur = pow(entry, exponent, modulo)
    prev = cur

    while cur != entry:
        prev = cur
        cur = pow(cur, exponent, modulo)
        exp_order += 1

    print(f"Order of the exponent: {exp_order}\n")

    result += to_text(prev)

    for element in ciphertext[1:]:
        result += to_text(pow(element, pow(exponent, exp_order - 1), modulo))

    return result


class Method(Enum):
    FERMAT = 0,
    RECIPHER = 1


def read_data(filename: str) -> tuple[int, int, list[int]]:
    with open(filename) as file:
        modulo = int(file.readline())
        exponent = int(file.readline())
        ciphertext = []
        line = file.readline()
        while line:
            ciphertext.append(int(line))
            line = file.readline()

    return modulo, exponent, ciphertext


def attack(input_filename: str, method: Method):
    modulo, exponent, ciphertext = read_data(input_filename)
    match method:
        case Method.FERMAT:
            return fermat(modulo, exponent, ciphertext)
        case Method.RECIPHER:
            return recipher(modulo, exponent, ciphertext)


def main():
    print("Decrypted text: " + attack("lab_1_in.txt", Method.FERMAT))
    print("Decrypted text: " + attack("lab_2_in.txt", Method.RECIPHER))


if __name__ == "__main__":
    main()
