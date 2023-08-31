#include <iostream>
#include <vector>

using namespace std;

#define ushort unsigned short

struct exchange {
    ushort src;
    ushort target;
    double rate;
    double commission;

    exchange() {
        rate = 0;
        commission = 0;
        src = 0;
        target = 0;
    }

    exchange(ushort src, ushort target, double rate, double commission) {
        this->src = src;
        this->target = target;
        this->rate = rate;
        this->commission = commission;
    }
};

int main1162() {
    ushort currencyCnt, exPointCnt, startCurrency;
    double startQuantity;
    cin >> currencyCnt >> exPointCnt >> startCurrency >> startQuantity;

    double quantityMax[currencyCnt];

    for (ushort i = 0; i < currencyCnt; i++) {
        quantityMax[i] = 0;
    }

    quantityMax[--startCurrency] = startQuantity;

    ushort a, b;
    double rateAB, commissionAB, rateBA, commissionBA;

    vector<struct exchange> exchangePointArr(exPointCnt);
    for (ushort i = 0; i < exPointCnt; i++) {
        cin >> a >> b >> rateAB >> commissionAB >> rateBA >> commissionBA;
        exchangePointArr.emplace_back(--a, --b, rateAB, commissionAB);
        exchangePointArr.emplace_back(b, a, rateBA, commissionBA);
    }

    while (currencyCnt--) {
        for (auto &exPoint: exchangePointArr) {
            a = exPoint.src;
            b = exPoint.target;
            quantityMax[b] = max(quantityMax[b], (quantityMax[a] - exPoint.commission) * exPoint.rate);
        }
    }

    for (auto &exPoint: exchangePointArr) {
        if ((quantityMax[exPoint.src] - exPoint.commission) * exPoint.rate > quantityMax[exPoint.target]) {
            cout << "YES" << '\n';
            return 0;
        }
    }
    cout << "NO" << '\n';
    return 0;
}
