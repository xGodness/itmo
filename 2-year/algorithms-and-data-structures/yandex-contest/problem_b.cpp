#include <bits/stdc++.h>

using namespace std;

#define ASCII_CASE_DIFFERENCE 32


int mainB() {
    string line;
    cin >> line;

    size_t sz = line.size();

    stack<size_t> animalIdxStack;
    stack<size_t> trapIdxStack;
    stack<char> valueStack;

    size_t trapMapping[sz / 2 + 1];

    char cur;
    size_t animalsCnt = 0;

    for (size_t i = 0; i < sz; i++) {
        cur = line[i];

        if (islower(cur)) {
            animalIdxStack.push(++animalsCnt);
        } else {
            trapIdxStack.push(i - animalsCnt + 1);
        }

        if (valueStack.empty() || abs(valueStack.top() - cur) != ASCII_CASE_DIFFERENCE) valueStack.push(cur);
        else {
            trapMapping[trapIdxStack.top()] = animalIdxStack.top();
            trapIdxStack.pop();
            animalIdxStack.pop();
            valueStack.pop();
        }

    }

    if (valueStack.empty()) {
        cout << "Possible" << '\n';
        for (size_t i = 1; i < sz / 2 + 1; i++) {
            cout << trapMapping[i] << ' ';
        }
        cout << '\n';
        return 0;
    }

    cout << "Impossible" << '\n';
    return 0;
}
