from RC6Encryptor import RC6Encryptor
from io_tools import read_str_keyword, read_file, write_to_file


def main():
    rc6_encryptor = RC6Encryptor(keyword=read_str_keyword())

    plaintext = read_file(read_format="rb")

    encrypted_data = rc6_encryptor.pcbc_encrypt(plaintext)
    encrypted_filename = "out/rc6_pcbc_encrypted.bin"
    write_to_file(encrypted_filename, encrypted_data, write_format="wb")
    print(f"Successfully encrypted data. Saved to: {encrypted_filename}")

    decrypted_data = rc6_encryptor.pcbc_decrypt(encrypted_data)
    decrypted_filename = "out/rc6_pcbc_decrypted.txt"
    write_to_file(decrypted_filename, decrypted_data, write_format="wb")
    print(f"Successfully decrypted data. Saved to: {decrypted_filename}")


if __name__ == "__main__":
    main()
