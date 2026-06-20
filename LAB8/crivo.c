#include <stdio.h>

int main(){
	int primos[33];
	for (int i = 1; i<33; i++) primos[i]=i;
	
	for(int i = 2; i<33; i++){
		for(int j = i;j+i<33;j+=i){
			primos[i+j] = 0;
		}		
	}
	for (int i = 2; i<33; i++){
		if(primos[i] != 0)
			printf("%d \n", primos[i]);
	}
}
