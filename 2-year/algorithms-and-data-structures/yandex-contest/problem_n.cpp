#include <iostream>
#include <vector>

using namespace std;

struct node {
    bool isVisited = false;
    vector<ushort> children;
    ushort parent = 0;
};

void traverse(node graph[], ushort v, bool traverseParent) {

    if (graph[v].isVisited) return;

    graph[v].isVisited = true;

    if (traverseParent && graph[v].parent) traverse(graph, graph[v].parent, true);

    for (auto &i: graph[v].children) {
        if (!graph[i].isVisited) traverse(graph, i, false);
    }

}

int mainN() {
    ushort n;
    cin >> n;

    node graph[n + 1];

    ushort idx;
    for (ushort i = 1; i <= n; i++) {
        cin >> idx;
        graph[idx].isVisited = false;
        graph[idx].children.push_back(i);
        graph[i].parent = idx;
    }

    ushort componentCnt = 0;
    for (ushort i = 1; i <= n; i++) {
        if (!graph[i].isVisited) {
            traverse(graph, i, true);
            componentCnt++;
        }
    }

    cout << componentCnt << '\n';

    return 0;
}
