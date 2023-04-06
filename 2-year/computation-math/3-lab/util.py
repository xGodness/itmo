from enum import Enum


class Result:
    def __init__(self):
        self.is_error = False
        self.error_msg = None
        self.answer = -1
        self.partition_cnt = 0
        self.accuracy = 0

    def to_string(self):
        return f'Answer: {self.answer}\nPartition count: {self.partition_cnt}\nAccuracy: {self.accuracy}'


class RectangleMethodType(Enum):
    LEFT = "left"
    RIGHT = "right"
    MIDDLE = "centre"
