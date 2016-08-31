/*
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License version 2 as published
 *  by the Free Software Foundation.
 *
 *  Copyright (C) 2010 John Crispin <blogic@openwrt.org>
 *  Copyright (C) 2013 Lei Chuanhua <chuanhua.lei@lantiq.com>
 */
#ifndef _LTQ_WRAPPER_H__
#define _LTQ_WRAPPER_H__

#include <linux/irq.h>
#include <linux/device.h>
#include <linux/clk.h>

/* generic reg access functions */
#define ltq_r32(reg)            __raw_readl(reg)
#define ltq_w32(val, reg)       __raw_writel(val, reg)

#define ltq_r16(reg)            __raw_readw(reg)
#define ltq_w16(val, reg)       __raw_writew(val, reg)

#define ltq_w32_mask(clear, set, reg)   \
        ltq_w32((ltq_r32(reg) & ~(clear)) | (set), reg)
#define ltq_r8(reg)             __raw_readb(reg)
#define ltq_w8(val, reg)        __raw_writeb(val, reg)

#endif
