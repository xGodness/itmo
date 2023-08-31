#include <iostream>
#include <queue>
#include <unordered_set>

#define INF 2.14748364e9

using namespace std;

int queue_getAndPop(queue<int> *q) {
    int val = q->front();
    q->pop();
    return val;
}

pair<int, int> priority_queue_getAndPop(priority_queue<pair<int, int>> *pq) {
    auto val = pq->top();
    pq->pop();
    return val;
}

int mainI() {
    int n, k, p;
    cin >> n >> k >> p;

    queue<int> carSequence;

    // key is a car id, value is a sequence of iteration indices when this car is needed
    queue<int> carsIterIndices[n];

    int curCar;
    for (int i = 0; i < p; i++) {
        cin >> curCar;
        curCar--;
        carSequence.push(curCar);
        carsIterIndices[curCar].push(i);
    }

    // pairs of <idx, car> where car is present on the floor
    // and idx is an index of the next iteration when this car is needed
    priority_queue<pair<int, int>> carsPriorities;

    // set of cars that are currently present on the floor
    unordered_set<int> carsOnFloor;

    int cnt = 0;
    while (p--) {
        curCar = queue_getAndPop(&carSequence);
        carsIterIndices[curCar].pop();

        if (carsOnFloor.find(curCar) == carsOnFloor.end()) {

            cnt++;

            if (carsOnFloor.size() == k) {
                carsOnFloor.erase(
                        priority_queue_getAndPop(&carsPriorities).second
                );
            }

            carsOnFloor.insert(curCar);
        }

        carsPriorities.emplace(
            carsIterIndices[curCar].empty() ? INF : carsIterIndices[curCar].front(),
            curCar
        );
    }

    cout << cnt << '\n';

    return 0;
}
