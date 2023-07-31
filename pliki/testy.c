#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define MAX_BUFFER 1024

#define SYSFS_FILE_A1 "/sys/kernel/sykt/djca1"
#define SYSFS_FILE_A2 "/sys/kernel/sykt/djca2"
#define SYSFS_FILE_W "/sys/kernel/sykt/djcw"
#define SYSFS_FILE_L "/sys/kernel/sykt/djcl"
#define SYSFS_FILE_B "/sys/kernel/sykt/djcb"
#define MAX_RETRIES 1000
#define WAIT_TIME 100


unsigned int file_read(char *filePath){
	int file = open(filePath, O_RDONLY);
	char buffer[MAX_BUFFER];

	if(file <= 0){
		printf("Open %s - cannot read number %d\n", filePath, errno);
		exit(2);
	}
	int n=read(file, buffer, MAX_BUFFER);
	close(file);
	return strtoul(buffer, NULL, 16);
}

int file_write(char *filePath, unsigned int input){
	char buffer[MAX_BUFFER];

	FILE *file=fopen(filePath, "w");
	if(file == NULL){
		printf("Open: %s - cannot write number: %d\n", filePath, errno);
		exit(2);
	}

	snprintf(buffer, MAX_BUFFER, "%x",input);
	fwrite(buffer, strlen(buffer), 1, file);
	fclose(file);
	return 0; 
}

int module_test(unsigned int a1, unsigned int a2){
	unsigned int result;
	unsigned int ones_coutnter;

	unsigned int status;
	

	file_write(SYSFS_FILE_A1, a1);
	file_write(SYSFS_FILE_A2, a2);


	int attempts = 0;
	do {
		status = file_read(SYSFS_FILE_B);
		if(status == 1){
			attempts++;
			if(attempts >= MAX_RETRIES){
				printf("Too many retries\n");
				break;
			}
			usleep(WAIT_TIME * 1000);
		}
		attempts++;
	} while (status == 1);


	printf("W: %x, L: %x, B: %x\n", file_read(SYSFS_FILE_W), file_read(SYSFS_FILE_L), file_read(SYSFS_FILE_B));

	return 0;
}

int main(void){
	
	printf("Test 1: 2*7 = 14 (0xE)\n");
	module_test(0x2, 0x7);

	printf("Test 2: 7*2 = 14 (0xE)\n");
	module_test(0x2, 0x7);

    printf("Test 3: 0*8 = 0 (0x0)\n");
	module_test(0x0, 0x8);

    printf("Test 4: 5*4 = 20 (0x14)\n");
	module_test(0x5, 0x4);

    printf("Test 5: 1*1 = 1 (0x1)\n");
	module_test(0x1, 0x1);

    printf("Test 6: 237*250 = 59250 (0xE772)\n");
	module_test(0xED, 0xFA);

	printf("Test 7: Overflow\n");
	module_test(0xFFFFFF, 0xFFFFFF);

	return 0;
}