#include <stdio.h>

int main(int argc, char *argv[])
{


    return 0;
}

#if 0
/* gcc -finstrument-functions */
void __cyg_profile_func_enter (void *, void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit (void *, void *) __attribute__((no_instrument_function));

int depth = -1;

void __cyg_profile_func_enter (void *func,  void *caller)
{
    int n;
    depth++;
    for (n = 0; n < depth; n++)
        printf (" ");
    printf ("-> %p\n", func);
}

void __cyg_profile_func_exit (void *func, void *caller)
{
    int n;

    for (n = 0; n < depth; n++)
        printf (" ");
    printf ("<- %p\n", func);
    depth--;
}
#endif
