#include <iostream>

#define uint unsigned int

using namespace std;

struct goblinNode {
    uint idx;
    goblinNode *next;

    goblinNode() = default;
};

goblinNode *getGoblinNode(uint idx) {
    auto *node = new goblinNode();
    node->idx = idx;
    node->next = nullptr;
    return node;
}

goblinNode *getRootNode() {
    return getGoblinNode(0);
}

struct goblinQueue {
    goblinNode rootNode = *getRootNode();
    goblinNode *end = &rootNode;
    goblinNode *middle = &rootNode;
    bool isLengthEven = true;
};

void goblinQueue_updateMiddle(goblinQueue *queue) {
    queue->isLengthEven = !queue->isLengthEven;
    if (!queue->isLengthEven) {
        queue->middle = queue->middle->next;
    }
}

void goblinQueue_pushBack(goblinQueue *queue, uint idx) {
    auto node = getGoblinNode(idx);
    queue->end->next = node;
    queue->end = queue->end->next;
    goblinQueue_updateMiddle(queue);
}

void goblinQueue_insertMiddle(goblinQueue *queue, uint idx) {
    bool midIsEnd = queue->middle == queue->end;

    auto node = getGoblinNode(idx);
    node->next = queue->middle->next;
    queue->middle->next = node;

    if (midIsEnd) queue->end = queue->end->next;
    goblinQueue_updateMiddle(queue);
}

goblinNode goblinQueue_popFirst(goblinQueue *queue) {
    goblinNode node = *queue->rootNode.next;
    queue->rootNode.next = node.next;

    if (queue->rootNode.next == nullptr) {
        queue->end = &queue->rootNode;
        queue->middle = &queue->rootNode;
        queue->isLengthEven = true;
    } else {
        goblinQueue_updateMiddle(queue);
    }

    return node;
}

int mainJ() {
    uint n;
    cin >> n;

    char opCode;
    goblinQueue queue;
    while (n--) {
        cin >> opCode;
        uint idx;
        switch (opCode) {
            case '+':
                cin >> idx;
                goblinQueue_pushBack(&queue, idx);
                break;
            case '*':
                cin >> idx;
                goblinQueue_insertMiddle(&queue, idx);
                break;
            case '-':
                cout << goblinQueue_popFirst(&queue).idx << '\n';
            default:
                break;
        }
    }

    return 0;
}