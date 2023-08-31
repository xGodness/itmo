#include <iostream>
#include <map>
#include <vector>

using namespace std;

const string DELIMITER = "\\";

struct fileNode {
    string filename;
    map<string, fileNode *> children;

    fileNode(string filename) {
        this->filename = std::move(filename);
    }
};

vector<string> string_split(const string *s, const string *delimiter) {
    vector<string> split;
    size_t last = 0;
    size_t next = s->find(*delimiter, last);

    while (next != string::npos) {
        split.push_back(s->substr(last, next - last));
        last = ++next;
        next = s->find(*delimiter, last);
    }

    split.push_back(s->substr(last, s->size() - last));

    return split;
}

void fileNode_add(fileNode *root, vector<string> *tokens) {
    fileNode *cur = root;
    auto tokenIter = tokens->begin();
    map<string, fileNode *>::iterator mapIter;

    while (tokenIter != tokens->end()) {
        mapIter = cur->children.find(*tokenIter);
        if (mapIter != cur->children.end()) {
            cur = mapIter->second;
        } else {
            cur->children.insert({*tokenIter, new fileNode(*tokenIter)});
            cur = cur->children[*tokenIter];
        }
        tokenIter = next(tokenIter);
    }
}

void fileNode_print(fileNode *node, const string &offset) {
    for (auto const &child: node->children) {
        cout << offset << child.first << '\n';
        fileNode_print(child.second, offset + " ");
    }
}

int main1067() {
    unsigned short n;
    cin >> n;

    auto root = new fileNode("");

    string path;
    vector<string> tokens;
    while (n--) {
        cin >> path;
        tokens = string_split(&path, &DELIMITER);
        fileNode_add(root, &tokens);
    }

    fileNode_print(root, "");

    return 0;
}
