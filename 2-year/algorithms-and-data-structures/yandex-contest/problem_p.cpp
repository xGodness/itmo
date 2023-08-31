#include <iostream>

#define INF SIZE_MAX

using namespace std;

void calculateAccess(size_t val, size_t n, bool **matrix, size_t **costs) {
    for (size_t i = 0; i < n; i++) {
        for (size_t j = 0; j < n; j++) {
            matrix[i][j] = costs[i][j] <= val;
        }
    }
}

void resetVisited(bool *isVisited, size_t n) {
    for (size_t i = 0; i < n; i++) isVisited[i] = false;
}

void checkConnectivity(size_t v, size_t n, bool **accessMatrix, bool *isVisited, bool reverseEdges) {
    isVisited[v] = true;
    for (size_t i = 0; i < n; i++) {
        if (i == v || isVisited[i]) continue;
        if (reverseEdges ? accessMatrix[i][v] : accessMatrix[v][i])
            checkConnectivity(i, n, accessMatrix, isVisited, reverseEdges);
    }
}

bool allWasVisited(const bool *isVisited, size_t n) {
    for (size_t i = 0; i < n; i++) {
        if (isVisited[i]) continue;
        return false;
    }
    return true;
}

int mainP() {
    size_t n;
    cin >> n;

    if (n == 1) {
        cin >> n; // stub second input
        cout << 0 << '\n';
        return 0;
    }

    size_t *costMatrix[n];
    bool *accessMatrix[n];

    size_t left = INF;
    size_t right = 0;

    for (size_t i = 0; i < n; i++) {
        costMatrix[i] = new size_t[n];
        accessMatrix[i] = new bool[n];

        for (size_t j = 0; j < n; j++) {
            cin >> costMatrix[i][j];
            if (i != j) {
                left = min(costMatrix[i][j], left);
                right = max(costMatrix[i][j], right);
            }
        }
    }

    bool isVisited[n];
    bool hasConnectivity;
    size_t middle;
    while (left < right) {
        middle = (left + right) / 2;

        calculateAccess(middle, n, accessMatrix, costMatrix);
        resetVisited(isVisited, n);

        checkConnectivity(0, n, accessMatrix, isVisited, false);
        if (allWasVisited(isVisited, n)) {
            resetVisited(isVisited, n);
            checkConnectivity(0, n, accessMatrix, isVisited, true);
            hasConnectivity = allWasVisited(isVisited, n);
        } else hasConnectivity = false;

        if (hasConnectivity)
            right = middle;
        else
            left = middle + 1;
    }

    cout << left << '\n';

    return 0;
}
