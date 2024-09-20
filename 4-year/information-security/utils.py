def factors_except_one(n) -> set[int]:
    result = []
    for i in range(2, int(n ** 0.5 + 2)):
        if n % i == 0:
            result.extend([i, n // i])
    result.append(n)
    return set(result)
