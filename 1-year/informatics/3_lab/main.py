print('\n')
import task_1
print('\n')
import task_2
print('\n')
import task_3
print('\n')

from tkinter import *

root = Tk()
root.title('Smile')
root.geometry('400x400')
c = Canvas(root, width=400, height=400, bg='orange')
c.pack()

c.create_oval(140, 60, 170, 90, fill='black')
c.create_arc(120, 60, 170, 90, start=200, extent=90, style=ARC, width=7)
c.create_oval(230, 60, 260, 90, fill='black')

c.create_line(200, 105, 150, 176.5, width=5)
c.create_line(200, 105, 250, 176.5, width=5)

c.create_arc(100, 230, 130, 260, start=90, extent=90, style=ARC, width=5)
c.create_arc(270, 230, 300, 260, start=0, extent=90, style=ARC, width=5)
c.create_line(115, 230, 178, 230, width=5)
c.create_line(223, 230, 287, 230, width=5)

c.create_arc(140, 170, 200, 230, start=270, extent=90, style=ARC, width=5)
c.create_arc(200, 170, 260, 230, start=180, extent=90, style=ARC, width=5)

c.create_line(110, 280, 290, 360, width=5)

root.mainloop()