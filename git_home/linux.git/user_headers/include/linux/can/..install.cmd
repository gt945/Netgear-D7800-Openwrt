cmd_/home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/can/.install := perl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/sourcecode/scripts/headers_install.pl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/sourcecode/include/linux/can /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/can arm bcm.h error.h gw.h netlink.h raw.h; perl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/sourcecode/scripts/headers_install.pl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/include/linux/can /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/can arm ; perl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/sourcecode/scripts/headers_install.pl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/include/generated/linux/can /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/can arm ; for F in ; do echo "\#include <asm-generic/$$F>" > /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/can/$$F; done; touch /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/can/.install
