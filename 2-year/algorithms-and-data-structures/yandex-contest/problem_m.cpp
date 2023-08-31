#include <iostream>
#include <queue>
#include <set>

#define INF INT32_MAX
#define coords pair<int, int>

using namespace std;

struct mapCell {
    int x;
    int y;
    int id;
    int moveCost;
    int dist;
    int pathAncestorId;
};

struct cellCompareDist {
    bool operator()(mapCell const *cell1, mapCell const *cell2) const {
        return cell1->dist > cell2->dist;
    }
};

struct cellCompareMoveCost {
    bool operator()(mapCell const *cell1, mapCell const *cell2) const {
        return cell1->moveCost < cell2->moveCost;
    }
};

int getEnteringEdgeWeight(const char *cellType) {
    switch (*cellType) {
        case '.':
            return 1;
        case 'W':
            return 2;
        default:
            return 0;
    }
}

void pathfindShortest(mapCell cellArray[], int &n, int &m, int &startId, int &endId) {
    cellArray[startId].dist = 0;
    cellArray[startId].moveCost = 0;

    priority_queue<mapCell *, vector<mapCell *>, cellCompareDist> cellProcessQueue;
    cellProcessQueue.push(&cellArray[startId]);

    multiset<mapCell *, cellCompareMoveCost> reachableNeighbours;

    while (!cellProcessQueue.empty()) {
        auto curCell = cellProcessQueue.top();
        cellProcessQueue.pop();

        if (curCell->id == endId) return;

        reachableNeighbours.clear();
        if (curCell->x < n && cellArray[curCell->id + m].moveCost)
            reachableNeighbours.insert(&cellArray[curCell->id + m]);
        if (curCell->x > 1 && cellArray[curCell->id - m].moveCost)
            reachableNeighbours.insert(&cellArray[curCell->id - m]);
        if (curCell->y < m && cellArray[curCell->id + 1].moveCost)
            reachableNeighbours.insert(&cellArray[curCell->id + 1]);
        if (curCell->y < m && cellArray[curCell->id + 1].moveCost)
            reachableNeighbours.insert(&cellArray[curCell->id + 1]);
        if (curCell->y > 1 && cellArray[curCell->id - 1].moveCost)
            reachableNeighbours.insert(&cellArray[curCell->id - 1]);

        for (auto neighbour: reachableNeighbours) {

            if (!neighbour->moveCost) continue;

            int newDist = curCell->dist + neighbour->moveCost;

            if (neighbour->dist > newDist) {
                neighbour->dist = newDist;
                neighbour->pathAncestorId = curCell->id;
                cellProcessQueue.push(neighbour);
            }
        }
    }
}


int mainM() {
    int n, m;
    coords startPoint, endPoint;
    cin >> n >> m >> startPoint.first >> startPoint.second >> endPoint.first >> endPoint.second;

    int startId = (startPoint.first - 1) * m + startPoint.second;
    int endId = (endPoint.first - 1) * m + endPoint.second;

    int cellCnt = n * m;
    mapCell cellArray[cellCnt + 1];

    char cellType;
    for (int i = 0; i < cellCnt; i++) {
        cin >> cellType;
        cellArray[i + 1].x = i / m + 1;
        cellArray[i + 1].y = i % m + 1;
        cellArray[i + 1].id = i + 1;
        cellArray[i + 1].moveCost = getEnteringEdgeWeight(&cellType);
        cellArray[i + 1].dist = INF;
        cellArray[i + 1].pathAncestorId = 0;
    }

    pathfindShortest(cellArray, n, m, startId, endId);

    auto cell = cellArray[endId];
    if (!cell.pathAncestorId) {
        cout << -1 << '\n';
        return 0;
    }

    cout << cell.dist << '\n';
    string path;
    while (cell.id != startId) {
        auto ancestor = cellArray[cell.pathAncestorId];
        int diff = ancestor.id - cell.id;
        if (diff == 1)
            path += 'W';
        else if (diff == -1)
            path += 'E';
        else if (diff == m)
            path += 'N';
        else if (diff == -m)
            path += 'S';

        cell = ancestor;
    }

    for (auto it = path.end() - 1; it >= path.begin(); it--) cout << *it;
    cout << '\n';

    return 0;
}
