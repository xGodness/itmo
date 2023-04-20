class Results:
    def __init__(self, is_error, message, data):
        self.is_error = is_error
        self.message = message
        self.data = data

    def __str__(self):
        return "(\n\tis_error: {},\n\tmessage: {},\n\tdata: {}\n)".format(self.is_error, self.message, self.data)
