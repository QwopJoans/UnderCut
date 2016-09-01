include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = UnderCut
UnderCut_FILES = udcRootListController.m
UnderCut_INSTALL_PATH = /Library/PreferenceBundles
UnderCut_FRAMEWORKS = UIKit
UnderCut_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/UnderCut.plist$(ECHO_END)
