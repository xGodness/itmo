#include <iostream>
#include <vector>

using namespace std;

int stringCompare(string *s1, string *s2) {
    if (*s1 + *s2 > *s2 + *s1) {
        return 1;
    }
   return -1;
}

vector<string> sort_desc(vector<string> *vec, size_t left, size_t right) {
    size_t dist = right - left;
    if (dist == 0) {
        vector<string> subv{(*vec)[left]};
        return subv;
    }
    if (dist == 1) {
        vector<string> subv{(*vec)[left], (*vec)[left + 1]};
        if (stringCompare(
                &subv[0],
                &subv[1]) < 0) {
            swap(subv[0], subv[1]);
        }
        return subv;
    }

    size_t mid = (left + right) / 2;
    vector<string> subvLeft = sort_desc(vec, left, mid);
    vector<string> subvRight = sort_desc(vec, mid + 1, right);

    vector<string> sorted;
    auto leftIt = subvLeft.begin();
    auto leftEnd = subvLeft.end();
    auto rightIt = subvRight.begin();
    auto rightEnd = subvRight.end();
    while (leftIt < leftEnd && rightIt < rightEnd) {
        if (stringCompare(&(*leftIt), &(*rightIt)) > 0) {
            sorted.push_back(*leftIt);
            leftIt++;
        } else {
            sorted.push_back(*rightIt);
            rightIt++;
        }
    }

    while (leftIt < leftEnd) sorted.push_back(*(leftIt++));
    while (rightIt < rightEnd) sorted.push_back(*(rightIt++));

    return sorted;
}

int mainF() {
    string str;
    vector<string> v;
    while (cin >> str) {
        v.push_back(str);
    }

    vector<string> sorted = sort_desc(&v, 0, v.size() - 1);
    for (const string &s: sorted) cout << s;
    cout << '\n';

    return 0;
}
