CONFIG_QCA_SINGLE_IMG_TREEISH = 883ac088aad2f6bfef50becb7e81fc3eac01298c

export CONFIG_QCA_SINGLE_IMG_TREEISH

single_img_dep = $(obj)u-boot.mbn tools/pack.py

define BuildSingleImg
	$(MAKE) -C tools/qca_single_img/ patch_clean
	cp -R board/"$(BOARDDIR)"/qca_single_img/./ \
			$(obj)tools/qca_single_img/
	$(MAKE) -C tools/qca_single_img/

	@ ### Steps described in QSDK release notes ###
	cp $(obj)u-boot.mbn \
			$(obj)tools/qca_single_img/qsdk-chipcode/common/build/ipq/
	cp $(src)tools/pack.py \
			$(obj)tools/qca_single_img/qsdk-chipcode/apss_proc/out/
	cd $(obj)tools/qca_single_img/qsdk-chipcode/common/build && \
			python update_common_info.py

	cp $(obj)tools/qca_single_img/qsdk-chipcode/common/build/bin/nand-ipq806x-single.img $@
endef
