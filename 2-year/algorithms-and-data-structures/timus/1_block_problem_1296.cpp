#include <iostream>

using namespace std;


int main1296() {
    size_t n;
    cin >> n;

    int bestSum = 0;
    int curSum = 0;

    int cur = 0;
    while (n--) {
        cin >> cur;
        curSum += cur;
        bestSum = max(bestSum, curSum);
        if (curSum < 0) {
            curSum = 0;
        }
    }

    cout << max(bestSum, curSum) << '\n';
    return 0;
}
