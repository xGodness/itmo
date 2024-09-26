def factors_except_one(n) -> set[int]:
    result = []
    for i in range(2, int(n ** 0.5 + 2)):
        if n % i == 0:
            result.extend([i, n // i])
    result.append(n)
    return set(result)


def round_to_odd(a: float) -> int:
    rounded = int(a)
    return rounded if rounded % 2 == 1 else rounded + 1


def rotate_bits_left(value: int, count: int, ttl_bits: int) -> int:
    mask = 2 ** ttl_bits - 1
    count %= ttl_bits
    return ((value << count) | (value >> (ttl_bits - count))) & mask


def rotate_bits_right(value: int, count: int, ttl_bits: int) -> int:
    mask = 2 ** ttl_bits - 1
    count %= ttl_bits
    return ((value >> count) | (value << (ttl_bits - count))) & mask
