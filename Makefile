include $(THEOS)/makefiles/common.mk

TWEAK_NAME = UnderCut
UnderCut_FILES = Tweak.xm
UnderCut_FRAMEWORKS = UIKit CoreGraphics QuartzCore
UnderCut_CFLAGS = -I../
UnderCut_LIBRARIES = applist

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += undercut
include $(THEOS_MAKE_PATH)/aggregate.mk
