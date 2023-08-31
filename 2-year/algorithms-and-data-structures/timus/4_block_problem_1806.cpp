#include <iostream>
#include <set>
#include <vector>
#include <queue>
#include <unordered_map>

#define ushort unsigned short
#define TEL_NUM_LEN 10
#define COST_INF SIZE_MAX

using namespace std;

struct node {
    ushort id;
    string num;
    size_t minCost;
    int pathAncestorId;
    // pair of the cost to deliver and neighbour id
    set<pair<ushort, ushort>> neighbours;
};

struct nodeCompare {
    bool operator()(node const *a, node const *b) const {
        return a->minCost > b->minCost;
    }
};

ushort getMaxPrefix(string &a, string &b) {
    ushort cnt = 0;
    for (ushort i = 0; i < TEL_NUM_LEN; i++) {
        if (a[i] != b[i]) return cnt;
        cnt++;
    }
    return cnt;
}

int main1806() {
    ushort n;
    cin >> n;

    ushort deliveryCostArr[TEL_NUM_LEN];
    for (ushort &i: deliveryCostArr) cin >> i;

    vector<node *> graph(n);
    unordered_map<string, ushort> nodeNumbers;

    for (ushort i = 0; i < n; i++) {
        graph[i] = new node();
        cin >> graph[i]->num;
        graph[i]->id = i;
        graph[i]->minCost = COST_INF;
        graph[i]->pathAncestorId = -1;

        nodeNumbers.insert({graph[i]->num, i});
    }

    graph[0]->minCost = 0;

    priority_queue<node *, vector<node *>, nodeCompare> processQueue;
    processQueue.push(graph[0]);
    while (!processQueue.empty()) {
        auto curNode = processQueue.top();
        processQueue.pop();

        if (curNode->id == n - 1) break;

        /*
         * Here we'll try to guess the number of possible neighbour.
         * We're searching number that can be obtained either
         * from replacing single character or by swapping two of them
         * in the current string.
         */
        set<pair<ushort, ushort>> neighboursCostIdPairSet;

        string curNum = curNode->num;

        for (ushort i = 0; i < TEL_NUM_LEN; i++) {
            char oldChar = curNum[i];

            for (ushort j = 0; j < TEL_NUM_LEN; j++) {
                char newChar = (char) ('0' + j);
                if (newChar == oldChar) continue;

                string nextNum = curNum;
                nextNum.replace(i, 1, string(1, newChar));
                auto it = nodeNumbers.find(nextNum);
                if (it != nodeNumbers.end())
                    neighboursCostIdPairSet.insert({
                        deliveryCostArr[getMaxPrefix(nextNum, curNum)],
                        it->second
                    });
            }

            for (ushort j = i + 1; j < TEL_NUM_LEN; j++) {
                string nextNum = curNum;
                swap(nextNum[i], nextNum[j]);
                auto it = nodeNumbers.find(nextNum);
                if (it != nodeNumbers.end())
                    neighboursCostIdPairSet.insert({
                       deliveryCostArr[getMaxPrefix(nextNum, curNum)],
                       it->second
                   });
            }
        }

        for (auto costIdPair: neighboursCostIdPairSet) {
            auto newCost = curNode->minCost + costIdPair.first;
            if (graph[costIdPair.second]->minCost > newCost) {
                graph[costIdPair.second]->minCost = newCost;
                graph[costIdPair.second]->pathAncestorId = curNode->id;
                processQueue.push(graph[costIdPair.second]);
            }
        }
    }

    if (graph[n - 1]->pathAncestorId == -1) {
        cout << -1 << '\n';
        return 0;
    }

    vector<ushort> pathIds;
    auto curNode = graph[n - 1];
    while (curNode->id != 0) {
        pathIds.push_back(curNode->id);
        curNode = graph[curNode->pathAncestorId];
    }

    cout << graph[n - 1]->minCost << '\n';
    cout << pathIds.size() + 1 << '\n';
    cout << 1 << ' ';
    for (auto it = pathIds.end() - 1; it >= pathIds.begin(); it--) cout << *it + 1 << ' ';
    cout << '\n';

    return 0;
}
