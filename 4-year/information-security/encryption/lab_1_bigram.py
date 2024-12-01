from encryptor.bigram_encryptor import BigramEncryptor
from util.io_tools import read_two_int_keys, read_file, write_to_file


def init_encryptor() -> BigramEncryptor:
    encryptor = None
    while encryptor is None:
        key_1, key_2 = read_two_int_keys()
        try:
            encryptor = BigramEncryptor(key_1, key_2)
        except ValueError as e:
            print(f'{e}\n')
    return encryptor


def main():
    bigram_encryptor = init_encryptor()

    plaintext_lines = read_file().split('\n')

    try:
        encrypted_lines = [bigram_encryptor.encrypt(line) for line in plaintext_lines]
    except ValueError as e:
        print(f'{e}\n')
        return

    encrypted_filename = "out/bigram_encrypted.txt"
    write_to_file(encrypted_filename, "\n".join(encrypted_lines))
    print(f"Successfully encrypted data. Saved to: {encrypted_filename}")

    decrypted_lines = [bigram_encryptor.decrypt(line) for line in encrypted_lines]
    decrypted_filename = "out/bigram_decrypted.txt"
    write_to_file(decrypted_filename, "\n".join(decrypted_lines))
    print(f"Successfully decrypted data. Saved to: {decrypted_filename}")


if __name__ == "__main__":
    main()
