# json2yaml (with libs, no regexes)
import json, yaml

def main():
    with open("timetable.json", 'r', encoding="utf-8") as jsonFile:
        jsonData = json.load(jsonFile)
    with open("task1.yaml", 'w', encoding="utf-8") as yamlFile:
        yamlData = yaml.dump(jsonData, allow_unicode=True)
        yamlFile.write(yamlData)
