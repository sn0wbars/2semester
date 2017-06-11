#include <stdio.h>
extern "C" int roots(double a,double b,double c,double* root1,double* root2);




int main()
{
        double a,b,c,root1,root2;
        printf("Enter coefficients: ");
        scanf("%lf %lf %lf",&a,&b,&c);
        if(roots(a,b,c,&root1,&root2))
                printf("Root1 = %lf and root2 = %lf\n", root1, root2);
        else
                printf("No real roots", root1, root2);
        return 0;
}
