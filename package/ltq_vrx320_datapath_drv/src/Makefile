
ifndef STAGING_DIR
  export TOPDIR:=$(shell echo $(PWD)/../../../*/qsdk)
  export CFLAGS=
  export OPENWRT_VERBOSE=s
  include $(TOPDIR)/rules.mk
  include $(INCLUDE_DIR)/kernel.mk
  THISMODULE=$(PWD)
  export CONFIG_DEBUG_SECTION_MISMATCH=1
all:
	make ARCH=$(LINUX_KARCH) $(TARGET_CONFIGURE_OPTS) -C $(LINUX_DIR) M=$(THISMODULE) modules
clean:
	make ARCH=$(LINUX_KARCH) $(TARGET_CONFIGURE_OPTS) -C $(LINUX_DIR) M=$(THISMODULE) clean
endif
ifndef OPENWRTVERSION
  -include $(TOPDIR)/.config
endif


EXTRA_CFLAGS += \
	$(if $(CONFIG_VRX320_PTM_QCA_NSS_REDIRECT), -DQCA_NSS_REDIRECT -I$(STAGING_DIR)/usr/include/qca-nss-drv) \
	$(if $(CONFIG_VRX320_DEBUG), -DVRX320_DEBUG) -DCONFIG_LTQ_PPA_QOS

obj-m += lantiq_vrx320_e1.o
obj-m += lantiq_vrx320_a1.o
obj-m += vectoring/

lantiq_vrx320_e1-objs = vrx320_ptm_main.o vrx320_common.o vrx320_ppe_ptm_init.o vrx320_ptm_datapath.o vrx320_api_qos.o vrx320_ptm_qos.o vrx320_drv_wrapper.o
lantiq_vrx320_a1-objs = vrx320_atm_main.o vrx320_common.o vrx320_ppe_atm_init.o vrx320_atm_datapath.o

