SWIFTC := swiftc
# CLT 26.6 currently pairs Swift 6.3.3 with a 6.3.2 SDK interface.
SWIFTFLAGS := -warnings-as-errors \
	-module-cache-path /private/tmp/mouse-scroll-switcher-module-cache \
	-Xfrontend -downgrade-typecheck-interface-error
APP := MouseScrollSwitcher.app
BINARY := $(APP)/Contents/MacOS/MouseScrollSwitcher
ICON := assets/AppIcon.icns
SOURCES := main.swift Notification.swift Core.swift

.PHONY: all test clean

all: $(BINARY)

$(BINARY): $(SOURCES) Info.plist $(ICON)
	mkdir -p $(APP)/Contents/MacOS $(APP)/Contents/Resources
	cp Info.plist $(APP)/Contents/Info.plist
	cp $(ICON) $(APP)/Contents/Resources/AppIcon.icns
	$(SWIFTC) $(SWIFTFLAGS) -o $@ $(SOURCES)
	codesign --force --sign - $(APP)

tests: tests.swift Core.swift
	$(SWIFTC) $(SWIFTFLAGS) -o $@ Core.swift tests.swift

test: tests
	./tests

clean:
	rm -rf $(APP)
	rm -f tests
