#include <iostream>
#include <map>

#define uint unsigned int

using namespace std;

void addBlock(pair<uint, uint> idxSizePair,
              map<uint, uint> *blocksFreeIdx,
              multimap<uint, uint> *blocksFreeSize) {

    blocksFreeIdx->insert(idxSizePair);
    blocksFreeSize->insert({idxSizePair.second, idxSizePair.first});
}

void removeBlockSizeIdx(multimap<uint, uint>::iterator *sizeIdxIter,
                        map<uint, uint> *blocksFreeIdx,
                        multimap<uint, uint> *blocksFreeSize) {

    blocksFreeIdx->erase((*sizeIdxIter)->second);
    blocksFreeSize->erase(*sizeIdxIter);
}

void removeBlockIdxSize(map<uint, uint>::iterator *idxSizeIter,
                        map<uint, uint> *blocksFreeIdx,
                        multimap<uint, uint> *blocksFreeSize) {

    auto sameSizeIt = blocksFreeSize->find((*idxSizeIter)->second);
    while (sameSizeIt->second != (*idxSizeIter)->first) sameSizeIt = next(sameSizeIt);
    blocksFreeIdx->erase(*idxSizeIter);
    blocksFreeSize->erase(sameSizeIt);
}


int mainK() {
    map<uint, uint> blocksFreeIdx;
    multimap<uint, uint> blocksFreeSize;

    uint memSize, requestCnt;
    cin >> memSize >> requestCnt;

    // stores pairs of size requested and memory index
    pair<uint, uint> requests[requestCnt + 1];
    for (uint i = 0; i < requestCnt + 1; i++) requests[i] = {0, 0};

    addBlock({1, memSize}, &blocksFreeIdx, &blocksFreeSize);

    int req;
    uint beginIdx, size;
    pair<uint, uint> idxSizePair;
    multimap<uint, uint>::iterator iterBySize;
    map<uint, uint>::iterator iterByIdx, iterLeft, iterRight;
    for (uint reqIdx = 1; reqIdx <= requestCnt; reqIdx++) {
        cin >> req;

        if (req > 0) {
            iterBySize = blocksFreeSize.lower_bound(req);
            if (iterBySize == blocksFreeSize.end()) {
                cout << -1 << '\n';
                continue;
            }

            beginIdx = iterBySize->second;
            size = iterBySize->first;

            removeBlockSizeIdx(&iterBySize, &blocksFreeIdx, &blocksFreeSize);

            if (req < size) {
                idxSizePair = make_pair(beginIdx + req, size - req);
                addBlock(idxSizePair, &blocksFreeIdx, &blocksFreeSize);
            }

            requests[reqIdx] = {beginIdx, req};
            cout << beginIdx << '\n';
            continue;
        }

        req = abs(req);
        idxSizePair = requests[req];
        if (idxSizePair.first == 0 || idxSizePair.second == 0) continue;

        beginIdx = idxSizePair.first;
        size = idxSizePair.second;

        iterRight = blocksFreeIdx.upper_bound(beginIdx);
        iterLeft = iterRight == blocksFreeIdx.begin() ? blocksFreeIdx.end() : prev(iterRight);

        // merge right if possible
        if (iterRight != blocksFreeIdx.end() && iterRight->first == beginIdx + size) {
            size += iterRight->second;
            removeBlockIdxSize(&iterRight, &blocksFreeIdx, &blocksFreeSize);
        }

        // merge left if possible
        if (iterLeft != blocksFreeIdx.end() && iterLeft->first + iterLeft->second == beginIdx) {
            beginIdx = iterLeft->first;
            size += iterLeft->second;
            removeBlockIdxSize(&iterLeft, &blocksFreeIdx, &blocksFreeSize);
        }

        addBlock({beginIdx, size}, &blocksFreeIdx, &blocksFreeSize);
        requests[reqIdx] = {0, 0};
    }


    return 0;
}
