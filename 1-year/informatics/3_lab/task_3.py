import re

print("  _________Task 3________")

for i in range(1, 6):
	test_path = "tests_3/test_" + str(i) + ".txt"
	ans_path = "tests_3/ans_" + str(i) + ".txt"
	
	s = open(test_path, "r", encoding="utf-8").read()
	ans = open(ans_path, "r", encoding="utf-8").read()
	
	s = re.sub(r'\s?[А-Я][а-я]+\s+([А-Я].)\1\s+P3119\b', '', s).strip('\n')
	
	if s == ans: print(" |  Test " + str(i) + ": Test passed  |")
	else: print(" |  Test " + str(i) + ": Wrong answer |")
	
print(" |_________Done__________|")