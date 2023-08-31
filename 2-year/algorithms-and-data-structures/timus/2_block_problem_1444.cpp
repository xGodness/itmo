#define _USE_MATH_DEFINES

#include <iostream>
#include <cmath>
#include <vector>
#include <algorithm>

#define ushort unsigned short

const double PI = M_PI;
const double PI_OVER_2 = M_PI_2;
const double PI_TIMES_3_OVER_2 = 3.0 * M_PI_2;
const double EPS = 1e-10;

using namespace std;

struct point {
    ushort idx;
    double dist;
    double angle;
};

double distance(const short *x1, const short *y1, const short *x2, const short *y2) {
    return sqrt(pow((*x1 - *x2), 2) + pow((*y1 - *y2), 2));
}

bool point_compare(const point &a, const point &b) {
    double angleDiff = a.angle - b.angle;
    if (angleDiff < -EPS) return true;
    if (angleDiff > EPS) return false;
    return a.dist < b.dist;
}

double calculateAngle(const short *x1, const short *y1, const short *x2, const short *y2) {
    if (*x2 == *x1) {
        if (*y2 > *y1) return PI;
        return 0;
    }
    if (*y2 == *y1) {
        if (*x2 < *x1) return PI_TIMES_3_OVER_2;
        return PI_OVER_2;
    }

    double shift = (*x2 > *x1) ? PI_OVER_2 : PI_TIMES_3_OVER_2;
    double t = atan(((double) (*y2 - *y1)) / ((double) (*x2 - *x1)));
    return t + shift;
}

int main1444() {
    ushort n;
    cin >> n;

    short startX;
    short startY;
    cin >> startX >> startY;
    ushort idx = 2;

    short x;
    short y;
    vector<point> vec;
    while (idx <= n) {
        cin >> x >> y;
        struct point p{
                .idx = idx,
                .dist = distance(&startX, &startY, &x, &y),
                .angle = calculateAngle(&startX, &startY, &x, &y)
        };
        vec.push_back(p);
        idx++;
    }

    sort(vec.begin(), vec.end(), point_compare);

    ushort begin = 0;
    double maxAngleDiff = 2.0 * PI - (vec[n - 2].angle - vec[0].angle);
    double diff;
    for (ushort i = 0; i < n - 2; i++) {
        diff = vec[i + 1].angle - vec[i].angle;
        if (diff > maxAngleDiff) {
            begin = i + 1;
            maxAngleDiff = diff;
        }
    }

    cout << n << '\n' << 1 << '\n';
    for (ushort i = begin; i < n - 1; i++) {
        cout << vec[i].idx << '\n';
    }
    for (ushort i = 0; i < begin; i++) {
        cout << vec[i].idx << '\n';
    }

    return 0;
}