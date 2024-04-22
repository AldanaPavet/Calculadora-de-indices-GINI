#include <stdio.h>

/*
int cFloatToInt(float f_gini){
    int i_gini = (int) f_gini;
    i_gini++;
    return i_gini;
};
*/

extern int asmFloatToInt(float);

int cFloatToInt(float f_gini){
    int i_gini = asmFloatToInt(f_gini);
    return i_gini;
};