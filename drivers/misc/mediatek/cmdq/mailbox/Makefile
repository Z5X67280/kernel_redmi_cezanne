# SPDX-License-Identifier: GPL-2.0
#
# Copyright (c) 2019 MediaTek Inc.
# Copyright (C) 2020 XiaoMi, Inc.
#

ccflags-y += -I$(srctree)/drivers/misc/mediatek/mach/$(MTK_PLATFORM)/include \
             -I$(srctree)/drivers/misc/mediatek/smi/ \
             -I$(srctree)/drivers/misc/mediatek/mdp/$(MTK_PLATFORM) \
             -I$(srctree)/drivers/misc/mediatek/mmp/

ifeq ($(or $(strip $(CONFIG_MTK_SEC_VIDEO_PATH_SUPPORT)), $(strip $(CONFIG_MTK_CAM_SECURITY_SUPPORT))),y)

ifeq ($(CONFIG_MICROTRUST_TEE_SUPPORT),y)
include $(srctree)/drivers/misc/mediatek/teei/Makefile.include
endif

ifeq ($(CONFIG_TRUSTONIC_TEE_SUPPORT),y)
include $(srctree)/drivers/misc/mediatek/gud/Makefile.include
endif

ccflags-y += -DCMDQ_SECURE_SUPPORT
ccflags-y += -DCMDQ_LATE_INIT_SUPPORT

obj-y += cmdq-sec-gp.o
obj-y += cmdq-sec-helper.o
obj-y += cmdq-sec-mailbox.o

endif # $(CONFIG_MTK_SEC_VIDEO_PATH_SUPPORT) or $(CONFIG_MTK_CAM_SECURITY_SUPPORT)

obj-y += cmdq-test.o
obj-y += cmdq-util.o
obj-y += $(subst ",,$(MTK_PLATFORM))/cmdq-platform.o
obj-y += cmdq-bw-mon.o
