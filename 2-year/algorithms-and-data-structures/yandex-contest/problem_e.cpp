#include <iostream>
#include <vector>

using namespace std;


bool isPlaceable(vector<int> *coords, int m, int k) {
    int placedCnt = 1;
    int placedLast = (*coords)[0];

    for (int i = 1; i < coords->size(); i++) {
        if ((*coords)[i] - placedLast >= m) {
            if (++placedCnt == k) return true;
            placedLast = ((*coords)[i]);
        }
    }

    return false;
}


int mainE() {
    int n, k;
    cin >> n >> k;

    vector<int> coords(n);
    for (int i = 0; i < n; i++) {
        cin >> coords[i];
    }

    int left = 0;
    int right = coords[n - 1] - coords[0] + 1;
    int middle;
    while (right - left > 1) {
        middle = (right + left) / 2;
        if (isPlaceable(&coords, middle, k)) {
            left = middle;
        } else {
            right = middle;
        }
    }

    cout << left << '\n';
}
