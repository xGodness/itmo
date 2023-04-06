def coefficient_to_string(c):
    if c == 1:
        return ''
    if c == -1:
        return '- '
    if c > 0:
        return f'+ {str(c)}'
    if c < 0:
        return f'- {str(-c)}'


class Function:
    def __init__(self, coeffs):
        self.coeffs = coeffs
        self.monomials = [str(coeffs[0])]
        for i in range(1, len(coeffs)):
            c_str = coefficient_to_string(coeffs[i])
            power = f'^{i}' if i != 1 else ''
            self.monomials.append("{}x{}".format(c_str, power))

    def calculate(self, x):
        res = 0
        for i, e in enumerate(self.coeffs):
            res += x ** i * e
        return res

    def to_string(self):
        return ' '.join(self.monomials)
