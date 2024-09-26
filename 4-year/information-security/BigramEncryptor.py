from utils import factors_except_one

MAX_KEY_VALUE = 1_000_000


class BigramEncryptor:
    _alphabet = ("АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя"
                "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
                "0123456789.,?!:;\'\"-—()@#%*&№+= ")
    _alph_len = len(_alphabet)
    _alph_len_factors = factors_except_one(_alph_len)
    _char_to_numeric_map = {}

    def __init__(self, key_1: int, key_2: int):
        if key_1 <= 0 or key_2 <= 0:
            raise ValueError("Keys must be positive")
        if key_1 > MAX_KEY_VALUE or key_2 > MAX_KEY_VALUE:
            raise ValueError(f'Keys must be less or equal to {MAX_KEY_VALUE}')
        if (len(factors_except_one(key_1).intersection(self._alph_len_factors)) != 0
                or len(factors_except_one(key_2).intersection(self._alph_len_factors)) != 0):
            raise ValueError(f'Keys must not have dividers from set: {self._alph_len_factors}')

        self._key_1 = key_1
        self._key_2 = key_2
        for i, e in enumerate(self._alphabet):
            self._char_to_numeric_map[e] = i

    def _char_to_numeric(self, char: str) -> int:
        try:
            return self._char_to_numeric_map[char]
        except KeyError:
            raise ValueError(f'Character {repr(char)} is not supported')

    def encrypt(self, text) -> str:
        if len(text) % 2 != 0:
            text += ' '

        encrypted = ""
        for i in range(0, len(text) - 1, 2):
            p = self._char_to_numeric(text[i]) * self._alph_len + self._char_to_numeric(text[i + 1])
            c = (p * self._key_1 + self._key_2) % (self._alph_len ** 2)

            result_num_1 = c // self._alph_len
            result_num_2 = c % self._alph_len
            encrypted += self._alphabet[result_num_1] + self._alphabet[result_num_2]

        return encrypted

    def decrypt(self, text) -> str:
        decrypted = ""
        for i in range(0, len(text) - 1, 2):
            result_num_1 = self._char_to_numeric(text[i])
            result_num_2 = self._char_to_numeric(text[i + 1])
            c = result_num_1 * self._alph_len + result_num_2

            p = 0
            while (self._key_1 * p + self._key_2) % (self._alph_len ** 2) != c:
                p += 1

            num_1 = p // self._alph_len
            num_2 = p % self._alph_len
            decrypted += self._alphabet[num_1] + self._alphabet[num_2]

        return decrypted
