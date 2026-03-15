THEOS_PACKAGE_SCHEME = rootless
ARCHS = arm64 arm64e
TARGET = iphone:clang:16.5:14.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CamSpoofPrefs
CamSpoofPrefs_FILES = CamSpoofPrefsListController.m
CamSpoofPrefs_INSTALL_PATH = /Library/PreferenceBundles
CamSpoofPrefs_CFLAGS = -fobjc-arc
CamSpoofPrefs_FRAMEWORKS = UIKit Photos PhotosUI
# Preferences.framework is a private framework - must go here, not in FRAMEWORKS
CamSpoofPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk
