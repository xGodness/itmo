import pandas as pd

with open("timetable.json", 'r', encoding="utf-8") as jsonFile:
    with open("timetable.csv", 'w', encoding="utf-8") as csvFile:
        pd.read_json(jsonFile).to_csv(csvFile, encoding="utf-8")