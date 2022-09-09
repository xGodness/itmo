#include <bits/stdc++.h>

using namespace std;

int main() {
	while (true) {
		string msg;
		cout << "Enter 7-digit binary message (or type \"q\" to quit): ";
		cin >> msg;
		if (msg == "q") return 0;
		if (msg.size() != 7) {
			cout << "Too long or too short." << '\n'; 
			continue;
		}
		for (char c : msg) if (c != '0' && c != '1') {
			cout << "Invalid symbols." << '\n'; 
			continue;
		}
		int r1 = msg[0] - '0', r2 = msg[1] - '0', r3 = msg[3] - '0', i1 = msg[2] - '0', i2 = msg[4] - '0', i3 = msg[5] - '0', i4 = msg[6] - '0';
		int s1 = r1 ^ i1 ^ i2 ^ i4, s2 = r2 ^ i1 ^ i3 ^ i4, s3 = r3 ^ i2 ^ i3 ^ i4;
		int S = s3 * 4 + s2 * 2 + s1;
		if (S == 0) {
			cout << "No errors. Decrypted message is " << msg[2] << msg[4] << msg[5] << msg[6] << '\n';
			continue;
		}
		cout << "Error in bit " << S << ". ";
		msg[S - 1] = (msg[S - 1] - '0') ^ 1 + '0';
		cout << "Decrypted message is " << msg[2] << msg[4] << msg[5] << msg[6] << '.' << '\n'; 
	}
}
