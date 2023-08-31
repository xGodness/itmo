#include <iostream>
#include <deque>

using namespace std;

int mainL() {
    int n, k;
    cin >> n >> k;

    // pairs of <index, value>
    deque<pair<int, int>> suffixMinDeque;

    int val;
    for (int i = 0; i < n; i++) {
        if (
                !suffixMinDeque.empty()
                && i - suffixMinDeque.front().first == k
        ) suffixMinDeque.pop_front();

        cin >> val;
        while (!suffixMinDeque.empty() && suffixMinDeque.back().second >= val) suffixMinDeque.pop_back();
        suffixMinDeque.emplace_back(i, val);

        if (i >= k - 1) cout << suffixMinDeque.front().second << ' ';
    }
    cout << '\n';

    return 0;
}
