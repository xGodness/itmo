from io_util import print_res


class Point:
    x: float
    y: float

    def __init__(self, x, y):
        self.x = x
        self.y = y


class InterpolationData:
    point_arr: list[Point]
    points_cnt: int
    min_x: float
    max_x: float
    target_x: float
    is_sorted: bool
    differences: list
    x_step: float

    def __init__(self, point_arr=None):
        if point_arr is None:
            point_arr = []
        self.point_arr = point_arr
        self.is_sorted = False
        self.points_cnt = 0
        self.x_step = 0

    def add_point(self, point: Point):
        self.point_arr.append(point)
        self.points_cnt += 1
        self.is_sorted = False

    def sort(self):
        if self.is_sorted:
            return
        self.point_arr = sorted(self.point_arr, key=lambda point: point.x)
        self.min_x = self.point_arr[0].x
        self.max_x = self.point_arr[-1].x
        self.is_sorted = True

    def calculate_differences(self):
        self.sort()

        self.differences = [[p.y for p in self.point_arr]]
        step = 1

        prev = self.differences[-1]
        while step < self.points_cnt:
            cur = []
            for i in range(self.points_cnt - step):
                cur.append(round(prev[i + 1] - prev[i], 5))
            self.differences.append(cur)
            step += 1
            prev = cur

    def print_diff(self):
        template = "| {:^13.3f} "
        print_res("Finite differences")
        print_res(7 * '_' + self.points_cnt * 16 * '_')
        print_res("|     |" + "               |" * self.points_cnt)
        print_res("| {:^3s} ".format("i"), end='')
        for i in range(0, self.points_cnt):
            header = f"d{i}yi" if i > 1 else ("dyi" if i > 0 else "yi")
            print_res("| {:^13s} ".format(header), end='')
        print_res("|\n" + "|_____|" + "_______________|" * self.points_cnt)
        for i in range(self.points_cnt):
            print_res("| {:^3.0f} ".format(i), end='')
            for j in range(len(self.differences[i])):
                print_res(template.format(self.differences[j][i]), end='')
            print_res("|")
        print()
