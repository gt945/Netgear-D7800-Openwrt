cmd_/home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/hdlc/.install := perl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/sourcecode/scripts/headers_install.pl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/sourcecode/include/linux/hdlc /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/hdlc arm ioctl.h; perl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/sourcecode/scripts/headers_install.pl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/include/linux/hdlc /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/hdlc arm ; perl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/sourcecode/scripts/headers_install.pl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/include/generated/linux/hdlc /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/hdlc arm ; for F in ; do echo "\#include <asm-generic/$$F>" > /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/hdlc/$$F; done; touch /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/hdlc/.install
