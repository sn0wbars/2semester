#include <iostream>

using std::cout;
using std::endl;

extern "C" int sqeq(double a, double b, double c, double* x1, double* x2); 

int main()
{
    double x1;
    double x2;
    //cin >> a >> b >> c;
    int n = sqeq(1, 5, 6, &x1, &x2);
    cout << n << endl;
    if (n > 0)
        cout << x1 << endl;
    if (n > 1)
        cout << x2 << endl;
    return 0;
}
