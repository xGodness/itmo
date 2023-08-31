#include <iostream>
#include <tuple>

#define ushort unsigned short
#define TGET(a, b) get<a>(b)

using namespace std;

/*    0    1       2       3         */
/*    sum  maxSum  prefix  suffix    */
tuple<int, int, int, int> solve(short values[], ushort left, ushort right) {
    if (left == right) {
        ushort val = (values[left] > 0) ? values[left] : 0;
        return make_tuple(values[left], val, val, val);
    }

    ushort middle = (left + right) / 2;
    auto subLeft = solve(values, left, middle);
    auto subRight = solve(values, middle + 1, right);

    return make_tuple(TGET(0, subLeft) + TGET(0, subRight),
                      max(max(TGET(1, subLeft), TGET(1, subRight)), TGET(3, subLeft) + TGET(2, subRight)),
                      max(TGET(2, subLeft), TGET(0, subLeft) + TGET(2, subRight)),
                      max(TGET(3, subLeft) + TGET(0, subRight), TGET(3, subRight)));
}

int main1296_extra() {
    ushort n;
    cin >> n;

    if (!n) {
        cout << 0 << '\n';
        return 0;
    }

    short values[n];
    for (ushort i = 0; i < n; i++) {
        cin >> values[i];
    }

    cout << TGET(1, solve(values, 0, n - 1)) << '\n';

    return 0;
}
