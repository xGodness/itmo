#include <iostream>

using namespace std;


int mainD() {
    int a, b, c, d;
    long k;

    cin >> a >> b >> c >> d >> k;

    if (a * b - c == a) {
        cout << a << '\n';
        return 0;
    }

    while (k--) {
        a = a * b - c;

        if (a <= 0) {
            cout << 0 << '\n';
            return 0;
        }

        if (a >= d) {
            cout << d << '\n';
            return 0;
        }
    }

    cout << a << '\n';
    return 0;
}
