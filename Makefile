TARGET := iphone:clang:15.5:15.0
ARCHS = arm64
INSTALL_TARGET_PROCESSES = SpringBoard
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VanDungMenu
VanDungMenu_FILES = Tweak.xm
VanDungMenu_CFLAGS = -fobjc-arc
include $(THEOS_MAKE_PATH)/tweak.mk
