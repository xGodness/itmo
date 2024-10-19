from util.io_tools import read_str_param, write_to_file
from encryptor.stream_cipher_encryptor import StreamCipherEncryptor


def init_encryptor() -> StreamCipherEncryptor:
    print("You will need to supply three keywords")
    keywords = [read_str_param("keyword") for _ in range(3)]
    return StreamCipherEncryptor(keywords[0], keywords[1], keywords[2])


def main():
    stream_cipher_encryptor = init_encryptor()
    message = read_str_param("message to encrypt")

    encrypted = stream_cipher_encryptor.encrypt(message)
    encrypted_filename = "out/stream_cipher_encrypted.txt"
    write_to_file(encrypted_filename, encrypted, write_format="w")
    print(f"Successfully encrypted data. Saved to: {encrypted_filename}")

    decrypted = stream_cipher_encryptor.decrypt(encrypted)

    decrypted_filename = "out/stream_cipher_decrypted.txt"
    write_to_file(decrypted_filename, decrypted, write_format="w")
    print(f"Successfully decrypted data. Saved to: {decrypted_filename}")


if __name__ == "__main__":
    main()
