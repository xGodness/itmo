#include <iostream>
//#include <cstdlib>

//#define THRESHOLD 100001

using namespace std;

void insertonSortDesc(int arr[], int left, int right) {
    int key;
    int j;
    for (int i = left + 1; i <= right; i++) {
        key = arr[i];
        j = i - 1;
        while (key > arr[j] && j >= 0) {
            arr[j + 1] = arr[j];
            j--;
        }
        arr[j + 1] = key;
    }
}

int partition(int arr[], int left, int right) {
    int ptr = left - 1;
    for (int i = left; i < right; i++) {
        if (arr[i] > arr[right]) {
            swap(arr[++ptr], arr[i]);
        }
    }
    swap(arr[++ptr], arr[right]);
    return ptr;
}

/* For some reason neither quicksort nor hybrid (qsort + insort)
 * doesn't pass 2 out of 50 tests, but insertion sort does */

//void quickSortDesc(int arr[], int left, int right) {
//    if (left < right) {
//        int ptr = partition(arr, left, right);
//        quickSortDesc(arr, left, ptr - 1);
//        quickSortDesc(arr, ptr + 1, right);
//    }
//}
//
//void hybridSortDesc(int arr[], int left, int right) {
//    while (left < right) {
//        if (right - left + 1 < THRESHOLD) {
//            insertionSortDesc(arr, left, right);
//            break;
//        }
//
//        int ptr = partition(arr, left, right);
//
//        if (ptr - left < right - ptr) {
//            hybridSortDesc(arr, left, ptr - 1);
//            left = ptr + 1;
//        } else {
//            hybridSortDesc(arr, ptr + 1, right);
//            right = ptr - 1;
//        }
//    }
//}

int mainH() {
    int n;
    int k;

    cin >> n >> k;
    int arr[n];
    int s = 0;

    for (int i = 0; i < n; i++) {
        cin >> arr[i];
        s += arr[i];
    }

    insertonSortDesc(arr, 0, n - 1);
    for (int i = k - 1; i < n; i += k) {
        s -= arr[i];
    }

    cout << s << '\n';
    return 0;
}
