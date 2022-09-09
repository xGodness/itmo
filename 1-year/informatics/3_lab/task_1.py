import re

print("  _________Task 1________")

tests = open("tests_1/tests_1.txt", "r", encoding="utf-8")
answers = open("tests_1/ans_1.txt", "r", encoding="utf-8")

s = tests.readline()[:-1]
ans = answers.readline()[:-1]

i = 1

while s:
	result = re.findall(r';<{/', s)
	
	if len(result) == int(ans): print(" |  Test " + str(i) + ": Test passed  |")
	else: print(" |  Test " + str(i) + ": Wrong answer |")
	
	s = tests.readline()[:-1]
	ans = answers.readline()[:-1]
	i += 1
	
print(" |_________Done__________|")