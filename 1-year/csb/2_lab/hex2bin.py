f = open('task.txt', 'r')
w = open('res.txt', 'w')
l = f.readline()
while l:
	w.write(l[:-1] + ' ')
	l = bin(int(hex(int(l.split()[1], 16)), 16))[2:]
	d = 16 - len(l)
	for i in range(d): l = '0' + l
	l = ' '.join([l[:4], l[4:8], l[8:12], l[12:]])
	w.write(l)
	w.write('\n')
	l = f.readline()
	