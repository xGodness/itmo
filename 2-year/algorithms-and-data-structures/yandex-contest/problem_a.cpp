#include <iostream>

using namespace std;

int mainA() {
    int n;
    cin >> n;

    int ansLeft = 0;
    int ansRight = 0;
    int maxDist = 0;
    int curDist;

    // last three elements
    int c;
    int b = -1;
    int a = -1;

    // left and right pointers
    int left = 0;
    int right = 0;

    while (n--) {
        c = b;
        b = a;
        cin >> a;

        if (a == b && b == c) {
            curDist = right - left;
            if (curDist > maxDist) {
                maxDist = curDist;
                ansLeft = left;
                ansRight = right - 1;
            }

            left = right - 1;
        }

        right++;
    }
    right--;

    curDist = right - left + 1;
    if (curDist > maxDist) {
        ansLeft = left;
        ansRight = right;
    }

    cout << ++ansLeft << ' ' << ++ansRight << '\n';

    return 0;
}
