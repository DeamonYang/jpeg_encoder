#include "stdio.h"
int main(void)
{
	int data[8] = {83720,83538,82719,83174,84175,84266,83629,83902};
	int tot = 0;
	for(int i = 0;i < 8;i ++)
	{
		tot = tot + data[i]*91;
		printf("sum[%d] = %d  add %d\r\n",i,tot,data[i]*91);
	}

	return 0;

}




