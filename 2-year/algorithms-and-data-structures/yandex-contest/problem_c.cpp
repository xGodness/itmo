#include <bits/stdc++.h>

using namespace std;


stack<int> *mapGet(unordered_map<string, stack<int>> *map, string *key) {
    return &((*map)[*key]);
}


pair<string, string> parseLine(string *line) {
    pair<string, string> parsed;

    size_t pos = line->find('=');
    if (pos != string::npos) {
        parsed.first = line->substr(0, pos);
        parsed.second = line->substr(pos + 1, line->length());
        return parsed;
    }

    parsed.first = *line;
    parsed.second = string();
    return parsed;
}


int mainC() {
    unordered_map<string, stack<int>> valuesMap;

    stack<vector<string>> changedVarsVectorsStack;
    changedVarsVectorsStack.push(vector<string>());

    string line;
    char ch;
    int newVal;
    pair<string, string> parsed;
    stack<int> *curStack;

    while (getline(cin, line) && !line.empty()) {
        parsed = parseLine(&line);
        string var1 = parsed.first;

        if (var1 == "{") {
            changedVarsVectorsStack.push(vector<string>());
            continue;
        }

        if (var1 == "}") {
            for (const string &var: changedVarsVectorsStack.top()) {
                valuesMap[var].pop();
            }
            changedVarsVectorsStack.pop();
            continue;
        }

        changedVarsVectorsStack.top().push_back(var1);

        string var2 = parsed.second;
        ch = var2[0];
        if (ch == '-' || isdigit(ch)) {
            newVal = stoi(var2);
            valuesMap[var1].push(newVal);
            continue;
        }

        curStack = mapGet(&valuesMap, &var2);
        newVal = curStack->empty() ? 0 : curStack->top();
        valuesMap[var1].push(newVal);

        cout << newVal << '\n';
    }

    return 0;
}
