import time
import json2yaml_no_lib
import json2yaml_regex
import json2yaml_lib

print("\n\n\n\n")
start = time.process_time()
for i in range(100):
    open("timetable.yaml", 'w').close()
    json2yaml_no_lib.main()
print(f'No libs, no regex: {time.process_time() - start}')

start = time.process_time()
for i in range(100):
    open("task1.yaml", 'w').close()
    json2yaml_regex.main()
print(f'No libs, with regex: {time.process_time() - start}')

start = time.process_time()
for i in range(100):
    open("task2.yaml", 'w').close()
    json2yaml_lib.main()
print(f'With lib: {time.process_time() - start}')
