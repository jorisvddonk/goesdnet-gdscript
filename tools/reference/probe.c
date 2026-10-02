#include "libc/stdio/stdio.h"
#include "libc/str/str.h"
#include "libc/calls/calls.h"
#include "libc/fmt/conv.h"

#define main dl_module_main
#include "dl.c"
#undef main

int main(int argc, char **argv)
{
	if (argc >= 4 && strcmp(argv[1], "--isthere") == 0) {
		field_amplificator = atoi(argv[2]);
		int r = isthere(atof(argv[3]));
		printf("res=%d x=%.0f y=%.0f z=%.0f\n", r, laststar_x, laststar_y, laststar_z);
		return 0;
	}
	if (argc < 4)
		return 2;
	ap_target_x = atof(argv[1]);
	ap_target_y = atof(argv[2]);
	ap_target_z = atof(argv[3]);
	extract_ap_target_infos();
	prepare_nearstar();
	printf("class=%d\n", ap_target_class);
	printf("spin=%d\n", ap_target_spin);
	printf("r=%d\n", ap_target_r);
	printf("g=%d\n", ap_target_g);
	printf("b=%d\n", ap_target_b);
	printf("nop=%d\n", nearstar_nop);
	printf("nob=%d\n", nearstar_nob);
	for (int i = 0; i < nearstar_nob; i++)
		printf("t%d=%d\n", i, nearstar_p_type[i]);
	for (int i = 0; i < nearstar_nob; i++)
		printf("o%d=%d\n", i, nearstar_p_owner[i]);
	for (int i = 0; i < nearstar_nob; i++)
		printf("m%d=%d\n", i, nearstar_p_moonid[i]);
	return 0;
}
