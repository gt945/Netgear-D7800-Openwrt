
#ifndef __UNIFIED_QOS_DS_BE_H_
#define __UNIFIED_QOS_DS_BE_H_

    typedef struct {

        unsigned int enq_mbox_addr;

        unsigned int enq_mbox_int_q0_val;

        unsigned int deq_mbox_addr;

        unsigned int deq_mbox_int_q0_val;

    } qosq_event_mbox_int_cfg_t;

    typedef struct {

#if defined(__LITTLE_ENDIAN_BITFIELD)
	unsigned int qos_en:1;
        unsigned int _res0:7;
        unsigned int qosq_num:8;
        unsigned int time_tick:16;
#elif defined (__BIG_ENDIAN_BITFIELD)
        unsigned int time_tick:16;
        unsigned int qosq_num:8;
        unsigned int _res0:7;
        unsigned int qos_en:1;
#else
#error  "Please fix <asm/byteorder.h>"
#endif

    } qos_cfg_t;

    typedef struct {

#if defined(__LITTLE_ENDIAN_BITFIELD)
        unsigned int qosq_shaper_enable_map:16;
        unsigned int outq_shaper_enable_map:4;
        unsigned int port_shaper_enable_map:1;
        unsigned int _res0:11;
#elif defined (__BIG_ENDIAN_BITFIELD)
        unsigned int _res0:11;
        unsigned int port_shaper_enable_map:1;
        unsigned int outq_shaper_enable_map:4;
        unsigned int qosq_shaper_enable_map:16;
#else
#error  "Please fix <asm/byteorder.h>"
#endif

    } shaping_cfg_t;

    typedef struct {

#if defined(__LITTLE_ENDIAN_BITFIELD)
        unsigned int wfq_reload_enable_map:16;
        unsigned int wfq_force_reload_map:16;
#elif defined (__BIG_ENDIAN_BITFIELD)
        unsigned int wfq_force_reload_map:16;
        unsigned int wfq_reload_enable_map:16;
#else
#error  "Please fix <asm/byteorder.h>"
#endif

    } wfq_cfg_t;

    typedef struct {

#if defined(__LITTLE_ENDIAN_BITFIELD)
        unsigned int wfq_en:1;
        unsigned int shape_en:1;
        unsigned int eth1_qss:1;
        unsigned int _res0:1;
        unsigned int eth1_eg_qnum:4;
        unsigned int overhd_bytes:8;
        unsigned int time_tick:16;
#elif defined (__BIG_ENDIAN_BITFIELD)
        unsigned int time_tick:16;
        unsigned int overhd_bytes:8;
        unsigned int eth1_eg_qnum:4;
        unsigned int _res0:1;
        unsigned int eth1_qss:1;
        unsigned int shape_en:1;
        unsigned int wfq_en:1;
#else
#error  "Please fix <asm/byteorder.h>"
#endif

    } tx_qos_cfg_t;

    typedef struct {

        unsigned int mailbox_int_addr;

        unsigned int mailbox_value;

    } desq_mbox_int_cfg_t;

    typedef struct {

#if defined(__LITTLE_ENDIAN_BITFIELD)
        unsigned int des_base_addr:16;
        unsigned int des_num:8;
        unsigned int _res1:5;
        unsigned int mbox_int_en:1;
        unsigned int _res0:1;
        unsigned int des_in_own_val:1;


        unsigned int enq_idx:16;
        unsigned int mbox_int_cfg_ptr:16;
#elif defined (__BIG_ENDIAN_BITFIELD)
        unsigned int des_in_own_val:1;
        unsigned int _res0:1;
        unsigned int mbox_int_en:1;
        unsigned int _res1:5;
        unsigned int des_num:8;
        unsigned int des_base_addr:16;

        unsigned int mbox_int_cfg_ptr:16;
        unsigned int enq_idx:16;
#else
#error  "Please fix <asm/byteorder.h>"
#endif
    } swapq_cfg_ctxt_t;

    typedef struct {

#if defined(__LITTLE_ENDIAN_BITFIELD)
        unsigned int des_base_addr:16;
        unsigned int des_num:8;
        unsigned int gif_id:3;
        unsigned int _res0:1;
        unsigned int des_sync_needed:1;
        unsigned int mbox_int_en:1;
        unsigned int fast_path:1;
        unsigned int des_in_own_val:1;

        unsigned int bp_des_base_addr:16;
        unsigned int mbox_int_cfg_ptr:16;

        unsigned int enq_idx:16;
        unsigned int deq_idx:16;
#elif defined (__BIG_ENDIAN_BITFIELD)
        unsigned int des_in_own_val:1;
        unsigned int fast_path:1;
        unsigned int mbox_int_en:1;
        unsigned int des_sync_needed:1;
        unsigned int _res0:1;
        unsigned int gif_id:3;
        unsigned int des_num:8;
        unsigned int des_base_addr:16;

        unsigned int mbox_int_cfg_ptr:16;
        unsigned int bp_des_base_addr:16;

        unsigned int deq_idx:16;
        unsigned int enq_idx:16;
#else
#error  "Please fix <asm/byteorder.h>"
#endif

        unsigned int _dw_res0;

        unsigned int enq_pkt_cnt;

        unsigned int enq_byte_cnt;

        unsigned int deq_pkt_cnt;

        unsigned int deq_byte_cnt;

    } desq_cfg_ctxt_t;

    typedef struct {

#if defined(__LITTLE_ENDIAN_BITFIELD)
        unsigned int desq_cfg_ctxt:16;
        unsigned int qosq_base_qid:4;
        unsigned int qid_mask:4;
        unsigned int _res0:7;
        unsigned int qos_en:1;
#elif defined (__BIG_ENDIAN_BITFIELD)
        unsigned int qos_en:1;
        unsigned int _res0:7;
        unsigned int qid_mask:4;
        unsigned int qosq_base_qid:4;
        unsigned int desq_cfg_ctxt:16;
#else
#error  "Please fix <asm/byteorder.h>"
#endif

    } inq_qos_cfg_t;

    typedef struct {

#if defined(__LITTLE_ENDIAN_BITFIELD)
        unsigned int des_base_addr:16;
        unsigned int des_num:8;
        unsigned int threshold:8;

        unsigned int enq_idx:16;
        unsigned int deq_idx:16;

#elif defined (__BIG_ENDIAN_BITFIELD)
        unsigned int threshold:8;
        unsigned int des_num:8;
        unsigned int des_base_addr:16;

        unsigned int deq_idx:16;
        unsigned int enq_idx:16;
#else
#error  "Please fix <asm/byteorder.h>"
#endif

    } qosq_cfg_ctxt_t;

    typedef struct {

#if defined(__LITTLE_ENDIAN_BITFIELD)

        unsigned int qos_en:1;
        unsigned int shape_en:1;
        unsigned int wfq_en:1;
        unsigned int weight_reload:1;
        unsigned int _res0:4;
        unsigned int overhd_bytes:8;
        unsigned int qmap:16;


        unsigned int l3_shaping_cfg_ptr:16;
        unsigned int l2_shaping_cfg_ptr:16;

        unsigned int desq_cfg_ctxt:16;
        unsigned int _res2:4;
        unsigned int l3_shaping_cfg_idx:5;
        unsigned int l2_shaping_cfg_idx:5;
        unsigned int _res1:2;

        unsigned int shaping_done_qmap:16;
        unsigned int weight_negative_qmap:16;

#elif defined (__BIG_ENDIAN_BITFIELD)
        unsigned int qmap:16;
        unsigned int overhd_bytes:8;
        unsigned int _res0:4;
        unsigned int weight_reload:1;
        unsigned int wfq_en:1;
        unsigned int shape_en:1;
        unsigned int qos_en:1;

        unsigned int l2_shaping_cfg_ptr:16;
        unsigned int l3_shaping_cfg_ptr:16;

        unsigned int _res1:2;
        unsigned int l2_shaping_cfg_idx:5;
        unsigned int l3_shaping_cfg_idx:5;
        unsigned int _res2:4;
        unsigned int desq_cfg_ctxt:16;

        unsigned int weight_negative_qmap:16;
        unsigned int shaping_done_qmap:16;
#else
#error  "Please fix <asm/byteorder.h>"
#endif

    } outq_qos_cfg_ctxt_t;

    typedef struct {

#if defined(__LITTLE_ENDIAN_BITFIELD)
        unsigned int w:24;
        unsigned int t:8;

        unsigned int r:16;
        unsigned int s:16;

        unsigned int d:24;
        unsigned int _res0:8;

        unsigned int b:16;
        unsigned int tick_cnt:8;
        unsigned int _res1:6;
        unsigned int shaping_min_b_check:1;
        unsigned int q_off:1;
#elif defined (__BIG_ENDIAN_BITFIELD)
        unsigned int t:8;
        unsigned int w:24;

        unsigned int s:16;
        unsigned int r:16;

        unsigned int _res0:8;
        unsigned int d:24;

        unsigned int q_off:1;
        unsigned int shaping_min_b_check:1;
        unsigned int _res1:6;
        unsigned int tick_cnt:8;
        unsigned int b:16;

#else
#error  "Please fix <asm/byteorder.h>"
#endif
    } shaping_wfq_cfg_t;

    typedef struct {

        unsigned int rx_pkt_cnt;

        unsigned int rx_byte_cnt;

        unsigned int tx_pkt_cnt;

        unsigned int tx_byte_cnt;

        unsigned int small_pkt_drop_cnt;

        unsigned int small_pkt_drop_byte_cnt;

        unsigned int large_pkt_drop_cnt;

        unsigned int large_pkt_drop_byte_cnt;

    } qosq_mib_t;

    typedef struct {

#if defined(__LITTLE_ENDIAN_BITFIELD)
        unsigned int large_frame_size:16;
        unsigned int large_frame_drop_th:16;
#elif defined (__BIG_ENDIAN_BITFIELD)
        unsigned int large_frame_drop_th:16;
        unsigned int large_frame_size:16;
#else
#error  "Please fix <asm/byteorder.h>"
#endif

    } qosq_flow_ctrl_cfg_t;

    typedef struct {
#if defined(__LITTLE_ENDIAN_BITFIELD)
        unsigned int data_len:16;
        unsigned int byte_off:2;
        unsigned int _res0:14;
#elif defined (__BIG_ENDIAN_BITFIELD)
        unsigned int _res0:14;
        unsigned int byte_off:2;
        unsigned int data_len:16;
#else
#error  "Please fix <asm/byteorder.h>"
#endif
    } std_des_cfg_t;

    typedef struct {

#if defined(__LITTLE_ENDIAN_BITFIELD)
        unsigned int data_len:14;
        unsigned int small:1;
        unsigned int pdu_type:1;
        unsigned int mpoa_type:2;
        unsigned int mpoa_pt:1;
        unsigned int qos:4;
        unsigned int byte_off:5;
        unsigned int eop:1;
        unsigned int sop:1;
        unsigned int c:1;
        unsigned int own:1;


	union {
        	unsigned int data_ptr:29;
        	unsigned int _res0:3;
		unsigned int dataptr;
	};
#elif defined (__BIG_ENDIAN_BITFIELD)
        unsigned int own:1;
        unsigned int c:1;
        unsigned int sop:1;
        unsigned int eop:1;
        unsigned int byte_off:5;
        unsigned int qos:4;
        unsigned int mpoa_pt:1;
        unsigned int mpoa_type:2;
        unsigned int pdu_type:1;
        unsigned int small:1;
        unsigned int data_len:14;

      	unsigned int _res0:3;
       	unsigned int data_ptr:29;

#else
#error  "Please fix <asm/byteorder.h>"
#endif

    } tx_descriptor_t;

    typedef struct {

#if defined(__LITTLE_ENDIAN_BITFIELD)
        unsigned int data_len:16;
        unsigned int _res1:5;
        unsigned int gid:2;
        unsigned int byte_off:2;
        unsigned int _res0:3;
        unsigned int eop:1;
        unsigned int sop:1;
        unsigned int c:1;
        unsigned int own:1;

	union {
        	unsigned int data_ptr:29;
        	unsigned int _res2:3;
		unsigned int dataptr;
	};
#elif defined (__BIG_ENDIAN_BITFIELD)
        unsigned int own:1;
        unsigned int c:1;
        unsigned int sop:1;
        unsigned int eop:1;
        unsigned int _res0:3;
        unsigned int byte_off:2;
        unsigned int gid:2;
        unsigned int _res1:5;
        unsigned int data_len:16;

        unsigned int _res2:3;
        unsigned int data_ptr:29;
#else
#error  "Please fix <asm/byteorder.h>"
#endif
    } rx_descriptor_t;

    typedef struct {

#if defined(__LITTLE_ENDIAN_BITFIELD)
        unsigned int non_overflow_state_threshold:8;
        unsigned int overflow_state_threshold:8;
        unsigned int _res0:16;
#elif defined (__BIG_ENDIAN_BITFIELD)
        unsigned int _res0:16;
        unsigned int overflow_state_threshold:8;
        unsigned int non_overflow_state_threshold:8;
#else
#error  "Please fix <asm/byteorder.h>"
#endif
    } flow_control_cfg_t;

#endif

