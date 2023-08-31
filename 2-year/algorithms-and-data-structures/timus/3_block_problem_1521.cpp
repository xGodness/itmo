#include <iostream>

using namespace std;

struct treeNode {
    size_t segmentSum;
    size_t index;
};

void tree_build(treeNode *tree, size_t vertex, size_t left, size_t right) {
    if (left == right) {
        tree[vertex].segmentSum = 1;
        tree[vertex].index = left + 1;
        return;
    }

    size_t middle = (left + right) / 2;
    tree_build(tree, vertex * 2, left, middle);
    tree_build(tree, vertex * 2 + 1, middle + 1, right);
    tree[vertex].segmentSum = tree[vertex * 2].segmentSum + tree[vertex * 2 + 1].segmentSum;
}

size_t tree_slaughterMercilessly(treeNode *tree, size_t vertex, size_t left, size_t right, size_t position) {
    while (left != right) {
        tree[vertex].segmentSum--;

        if (tree[vertex * 2].segmentSum >= position) {
            right = (left + right) / 2;
            vertex = vertex * 2;
            continue;
        }

        position -= tree[vertex * 2].segmentSum;
        left = (left + right) / 2 + 1;
        vertex = vertex * 2 + 1;
    }

    tree[vertex].segmentSum--;
    return tree[vertex].index;
}

int main1521() {
    size_t n, k;
    cin >> n >> k;

    treeNode tree[4 * n];
    tree_build(tree, 1, 0, n - 1);

    size_t position = k;
    for (size_t i = 0; i < n; i++) {
        cout << tree_slaughterMercilessly(tree, 1, 1, n, position) << ' ';
        if (i == n - 1) break;

        position = (position + k - 1) % (n - i - 1);
        if (position == 0) position = n - i - 1;
    }

    cout << '\n';
    return 0;
}