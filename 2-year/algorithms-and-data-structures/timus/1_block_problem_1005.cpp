#include <iostream>
#include <vector>

using namespace std;


int iterate(int fstPile, int sndPile, vector<int> *v, size_t pos) {
    if (pos == v->size()) {
        return abs(fstPile - sndPile);
    }

    int curValue = (*v)[pos];
    return min(
            iterate(fstPile + curValue, sndPile, v, pos + 1),
            iterate(fstPile, sndPile + curValue, v, pos + 1)
    );
}

int main1005() {
    size_t n;
    cin >> n;

    vector<int> stones;
    stones.resize(n);
    for (size_t i = 0; i < n; i++) {
        cin >> stones[i];
    }

    cout << iterate(0, 0, &stones, 0) << '\n';
    return 0;
}
