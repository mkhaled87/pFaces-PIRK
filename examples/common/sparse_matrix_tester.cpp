/******************************************************************************

                              Online C++ Compiler.
               Code, Compile, Run and Debug C++ program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <iostream>
#include <math.h>

using namespace std;

#include "growth_bound_matrix.cl"

int main()
{
    unsigned int i_from = 0;
    unsigned int i_to = 143;
    
    for(unsigned int i=i_from; i<=i_to; i++){
        unsigned int last_j=-1;
        unsigned int done=0;
        unsigned int new_j;
    	float dr = 0;
	    float c;
        
        cout << "For i="<<i<<":\t";
    	do {
    		c = getNextNonZeroGrouthBoundValue(i, last_j, &done, &new_j);
    		
    		// does this i have all zeros ?
    		if(new_j == -1 && done == 1){
    		    break;
    		}
    		
    	    cout<<"(j=" << new_j << " -> " << c << ")\t";
    		last_j = new_j;
    	} while (done == 0);    
    	cout << endl;
    }

    return 0;
}
