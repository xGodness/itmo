#include <iostream>
#include <vector>

using namespace std;

bool colourGraph(pair<short, vector<ushort>> graph[], ushort v, short colour) {
    graph[v].first = colour;
    for (auto &j: graph[v].second) {
        if (graph[j].first == colour) return false;
        if (graph[j].first == 0) {
            if (!colourGraph(graph, j, -colour)) return false;
        }
    }
    return true;
}

int mainO() {
    ushort n;
    ushort m;
    cin >> n >> m;

    pair<short, vector<ushort>> graph[n];

    ushort a, b;
    for (ushort i = 0; i < m; i++) {
        cin >> a >> b;
        graph[--a].second.push_back(--b);
        graph[b].second.push_back(a);
    }

    for (ushort i = 0; i < n; i++) {
        if (graph[i].first) continue;
        if (!colourGraph(graph, i, 1)) {
            cout << "NO" << '\n';
            return 0;
        }
    }
    cout << "YES" << '\n';
    return 0;
}
