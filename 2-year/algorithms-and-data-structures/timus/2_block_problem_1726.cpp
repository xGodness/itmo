#include <iostream>
#include <algorithm>

#define llong long long

using namespace std;

// Default quicksort implementation is not enough, so we have to use <algorithm> std::sort
// (which is hybrid of several others sorting algorithms) instead
/*llong partition(llong arr[], llong left, llong right) {
    swap(arr[right], arr[(right + left) / 2]);
    llong ptr = left - 1;
    for (llong i = left; i <= right; i++) {
        if (arr[i] < arr[right]) {
            swap(arr[++ptr], arr[i]);
        }
    }
    swap(arr[++ptr], arr[right]);
    return ptr;
}

void quicksort(llong arr[], llong left, llong right) {
    llong pivotIdx;
    if (left < right) {
        pivotIdx = partition(arr, left, right);
        quicksort(arr, left, pivotIdx - 1);
        quicksort(arr, pivotIdx + 1, right);
    }
}*/

int main1726() {
    llong n;
    cin >> n;
    llong arrX[n];
    llong arrY[n];

    for (llong i = 0; i < n; i++) {
        cin >> arrX[i] >> arrY[i];
    }

    sort(arrX, arrX + n);
    sort(arrY, arrY + n);

    llong ttlSum = (arrX[n - 1] + arrY[n - 1]) * (n - 1);
    for (llong i = 0; i < n - 1; i++) {
        ttlSum += (arrX[i] + arrY[i]) * (2 * i - n + 1);
    }

    cout << ttlSum * 2 / n / (n - 1) << '\n';
    return 0;
}