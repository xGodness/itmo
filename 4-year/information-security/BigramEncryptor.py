from utils import factors_except_one

MAX_KEY_VALUE = 1_000_000


class BigramEncryptor:
    alphabet = ("АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя"
                "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
                "0123456789.,?!:;\'\"-—()@#%*&№+= ")
    alph_len = len(alphabet)
    alph_len_factors = factors_except_one(alph_len)
    char_to_numeric_map = {}

    def __init__(self, key_1: int, key_2: int):
        if key_1 <= 0 or key_2 <= 0:
            raise ValueError("Keys must be positive")
        if key_1 > MAX_KEY_VALUE or key_2 > MAX_KEY_VALUE:
            raise ValueError(f'Keys must be less or equal to {MAX_KEY_VALUE}')
        if (len(factors_except_one(key_1).intersection(self.alph_len_factors)) != 0
                or len(factors_except_one(key_2).intersection(self.alph_len_factors)) != 0):
            raise ValueError(f'Keys must not have dividers from set: {self.alph_len_factors}')

        self.key_1 = key_1
        self.key_2 = key_2
        for i, e in enumerate(self.alphabet):
            self.char_to_numeric_map[e] = i

    def __char_to_numeric(self, char: str) -> int:
        try:
            return self.char_to_numeric_map[char]
        except KeyError:
            raise ValueError(f'Character {repr(char)} is not supported')

    def encrypt(self, text) -> str:
        if len(text) % 2 != 0:
            text += ' '

        encrypted = ""
        for i in range(0, len(text) - 1, 2):
            p = self.__char_to_numeric(text[i]) * self.alph_len + self.__char_to_numeric(text[i + 1])
            c = (p * self.key_1 + self.key_2) % (self.alph_len ** 2)

            result_num_1 = c // self.alph_len
            result_num_2 = c % self.alph_len
            encrypted += self.alphabet[result_num_1] + self.alphabet[result_num_2]

        return encrypted

    def decrypt(self, text) -> str:
        decrypted = ""
        for i in range(0, len(text) - 1, 2):
            result_num_1 = self.__char_to_numeric(text[i])
            result_num_2 = self.__char_to_numeric(text[i + 1])
            c = result_num_1 * self.alph_len + result_num_2

            p = 0
            while (self.key_1 * p + self.key_2) % (self.alph_len ** 2) != c:
                p += 1

            num_1 = p // self.alph_len
            num_2 = p % self.alph_len
            decrypted += self.alphabet[num_1] + self.alphabet[num_2]

        return decrypted
