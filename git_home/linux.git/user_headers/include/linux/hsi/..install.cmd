cmd_/home/roger.luo/auto-gpl/tmp/linux/linux-3.4.103/user_headers/include/linux/hsi/.install := perl /home/roger.luo/auto-gpl/tmp/linux/linux-3.4.103/sourcecode/scripts/headers_install.pl /home/roger.luo/auto-gpl/tmp/linux/linux-3.4.103/sourcecode/include/linux/hsi /home/roger.luo/auto-gpl/tmp/linux/linux-3.4.103/user_headers/include/linux/hsi arm hsi_char.h; perl /home/roger.luo/auto-gpl/tmp/linux/linux-3.4.103/sourcecode/scripts/headers_install.pl /home/roger.luo/auto-gpl/tmp/linux/linux-3.4.103/include/linux/hsi /home/roger.luo/auto-gpl/tmp/linux/linux-3.4.103/user_headers/include/linux/hsi arm ; perl /home/roger.luo/auto-gpl/tmp/linux/linux-3.4.103/sourcecode/scripts/headers_install.pl /home/roger.luo/auto-gpl/tmp/linux/linux-3.4.103/include/generated/linux/hsi /home/roger.luo/auto-gpl/tmp/linux/linux-3.4.103/user_headers/include/linux/hsi arm ; for F in ; do echo "\#include <asm-generic/$$F>" > /home/roger.luo/auto-gpl/tmp/linux/linux-3.4.103/user_headers/include/linux/hsi/$$F; done; touch /home/roger.luo/auto-gpl/tmp/linux/linux-3.4.103/user_headers/include/linux/hsi/.install
