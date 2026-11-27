
ARCHS = arm64
TARGET = iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = FFVN-MON

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VDUNGZKeyGate
VDUNGZKeyGate_FILES = Tweak.xm
VDUNGZKeyGate_FRAMEWORKS = UIKit Foundation
VDUNGZKeyGate_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk
