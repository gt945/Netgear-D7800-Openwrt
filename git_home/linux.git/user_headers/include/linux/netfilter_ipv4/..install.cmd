cmd_/home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/netfilter_ipv4/.install := perl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/sourcecode/scripts/headers_install.pl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/sourcecode/include/linux/netfilter_ipv4 /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/netfilter_ipv4 arm ip_queue.h ip_tables.h ipt_CLUSTERIP.h ipt_ECN.h ipt_LOG.h ipt_REJECT.h ipt_TTL.h ipt_ULOG.h ipt_addrtype.h ipt_ah.h ipt_ecn.h ipt_ttl.h; perl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/sourcecode/scripts/headers_install.pl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/include/linux/netfilter_ipv4 /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/netfilter_ipv4 arm ; perl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/sourcecode/scripts/headers_install.pl /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/include/generated/linux/netfilter_ipv4 /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/netfilter_ipv4 arm ; for F in ; do echo "\#include <asm-generic/$$F>" > /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/netfilter_ipv4/$$F; done; touch /home/tianqing.liu/projects/d7800-stage2-froje.git/build_dir/linux-ipq806x/linux-3.4.103/user_headers/include/linux/netfilter_ipv4/.install
