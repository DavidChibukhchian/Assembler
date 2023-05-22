#include "patcher.h"


//-----------------------------------------------------------------------------------------------------------


static size_t jump_address_1 = 63;
static size_t new_byte_1     = 41;

static size_t jump_address_2 = 93;
static size_t new_byte_2     = 11;


//-----------------------------------------------------------------------------------------------------------


static size_t get_file_size(FILE* filename)
{
	struct stat file_data = {};
	fstat(fileno(filename), &file_data);

	return file_data.st_size;
}


//-----------------------------------------------------------------------------------------------------------


int patch_hackme()
{
	FILE* target = fopen("HACKME.com", "r+b");
	if (target == nullptr)
	{
		return Failed_To_Open_Target_File;
	}

	size_t file_size = get_file_size(target);

	if (file_size == 0)
	{
		return Target_File_Is_Empty;
	}

	fseek(target, jump_address_1, SEEK_SET);
	fputc(new_byte_1, target);

	fseek(target, jump_address_2, SEEK_SET);
	fputc(new_byte_2, target);

	fclose(target);

	return 0;
}


//-----------------------------------------------------------------------------------------------------------