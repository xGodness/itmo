class Solution:
    _col_cnt: int
    _val_len: int
    _template_start: str
    _template_header: str
    _template_row: str
    _template_sep: str

    def __init__(self, point_cnt: int,
                 x_arr: list[float],
                 y_arr: list[float],
                 exact_y_arr: list[float],
                 f_arr: list[float] = None) -> None:
        self.point_cnt = point_cnt
        self.x_arr = x_arr[:point_cnt]
        self.y_arr = y_arr[:point_cnt]
        self.exact_y_arr = exact_y_arr[:point_cnt]
        self.f_arr = f_arr

        self._generate_templates()

    def _generate_templates(self):
        self._col_cnt = 4 if self.f_arr is None else 5
        self._val_len = 9

        self._template_start = '_' * ((self._val_len + 3) * self._col_cnt + 1)
        self._template_header = "| {:^9s} " * self._col_cnt + '|'
        self._template_row = "| {:^9.0f} " + "| {:^9.5f} " * (self._col_cnt - 1) + '|'
        self._template_sep = ('|' + '_' * (self._val_len + 2)) * self._col_cnt + '|'

    @staticmethod
    def _format_template(template: str, i, x, y, exact_y, f=None):
        if f is None:
            return template.format(i, x, y, exact_y)
        return template.format(i, x, y, f, exact_y)

    def print(self) -> None:
        f_val = "f(x, y)" if not self.f_arr is None else None

        print(self._template_start)
        print(self._format_template(self._template_header, 'i', 'x', 'y', "Exact y", f_val))

        print(self._template_sep)
        for i in range(self.point_cnt):
            f_val = self.f_arr[i] if not self.f_arr is None else None
            print(self._format_template(
                self._template_row, i, self.x_arr[i], self.y_arr[i], self.exact_y_arr[i], f_val))
        print(self._template_sep)
        print()
