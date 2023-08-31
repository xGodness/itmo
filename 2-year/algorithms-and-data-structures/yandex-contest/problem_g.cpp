#include <iostream>
#include <vector>
#include <stack>

using namespace std;

const char A_CODE = 'a';

struct letter {
    char value{};
    int weight = -1;
    int count = 0;
};

void insertionSortDesc(vector<letter> *vec, int left, int right) {
    letter key;
    int j;
    for (int i = left + 1; i <= right; i++) {
        key = (*vec)[i];
        j = i - 1;
        while (key.weight > (*vec)[j].weight && j >= 0) {
            (*vec)[j + 1] = (*vec)[j];
            j--;
        }
        (*vec)[j + 1] = key;
    }
}

int mainG() {
    string s;
    cin >> s;

    vector<letter> vec(26, letter{});
    for (int i = 0; i < 26; i++) {
        vec[i] = letter{
                .value = (char) (i + A_CODE),
                .weight = -1,
                .count = 0
        };
        cin >> vec[i].weight;
    }

    for (char c: s) {
        vec[c - A_CODE].count++;
    }

    insertionSortDesc(&vec, 0, 26);

    size_t sz = s.size();
    char result[sz];
    char value;
    int count;
    int i = 0;
    stack<char> leftovers;

    for (const auto ltr: vec) {
        count = ltr.count;
        if (count == 0) continue;

        value = ltr.value;

        if (count >= 2) {
            result[i] = value;
            result[sz - i - 1] = value;
            i++;

            count -= 2;
            while (count--) leftovers.push(value);
            continue;
        }

        leftovers.push(value);
    }

    while (!leftovers.empty()) {
        result[i++] = leftovers.top();
        leftovers.pop();
    }

    for (char c: result) cout << c;
    cout << '\n';

    return 0;
}
