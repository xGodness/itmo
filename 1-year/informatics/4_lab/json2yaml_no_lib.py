# json2yaml converter (no libs, no regexes)
import time

def main():
	out = ["---\n"]
	flagNewBlock = False
	with open("timetable.json", 'r', encoding="utf-8") as f_in:
		line = f_in.readline()
		while line:
			# format tabulation and dashes
			if flagNewBlock:
				flagNewBlock = False
				tabs = line.count('\t')
				line = line.replace('\t', '')
				spaces = ' ' * (tabs - 2)
				line = spaces + '- ' + line
			else:
				line = line.replace('\t', ' ')
				if '{' in line:
					flagNewBlock = True
			# format symbols
			for c in "\'\",{}[]":
				line = line.replace(c, '')
			# format colons
			line = line.split(' ')
			for idx, word in enumerate(line):
				if len(word) < 3:
					continue
				flagNewLine, flagColon = False, False
				if word[-1] == '\n':
					flagNewLine = True
					word = word[:-1]
				if word[-1] == ':':
					flagColon = True
					word = word[:-1]
				if ':' in word:
					word = '\'' + word + '\''
					if flagColon:
						word += ':'
					if flagNewLine:
						word += '\n'
					line[idx] = word
			line = ' '.join(line)

			out.append(line)
			line = f_in.readline()

	for line in out:
		s = line.split()
		if not s:
			out.remove(line)

	with open("timetable.yaml", 'w', encoding="utf-8") as f_out:
		f_out.write(''.join(out))