#include <iostream>
extern "C" int summ(int a, int b);
int main()
{
	int a = 0, b = 0;
	std::cin >> a >> b;
	int c = summ(a, b);
	std::cout << c;
	return 0;
}
