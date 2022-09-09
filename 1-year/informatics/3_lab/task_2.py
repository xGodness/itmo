import re

print("  _________Task 2________")

for i in range(1, 6):
	test_path = "tests_2/test_" + str(i) + ".txt"
	ans_path = "tests_2/ans_" + str(i) + ".txt"
	
	s = open(test_path, "r", encoding="utf-8").read()
	ans = open(ans_path, "r", encoding="utf-8").read()
	
	res = re.findall(r'[А-Я][а-я]+(?=\b\s*[А-Я][.][А-Я][.][\s$\W])', s)
	res.sort()
	
	if '\n'.join(res) == ans: print(" |  Test " + str(i) + ": Test passed  |")
	else: print(" |  Test " + str(i) + ": Wrong answer |")

print(" |_________Done__________|")