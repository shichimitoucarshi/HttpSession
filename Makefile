build_config:
	bundle install

debug-build:
	xcodebuild \
	-sdk iphoneos \
	-configuration Debug \
	-project HttpSessionSample.xcodeproj \
	-scheme HttpSessionSample \
	build CODE_SIGNING_ALLOWED=NO

debug-lib-build:
	xcodebuild \
	-sdk iphoneos \
	-configuration Debug \
	-project HttpSessionSample.xcodeproj \
	-scheme HttpSession \
	build CODE_SIGNING_ALLOWED=NO

test:
	xcodebuild \
	-sdk iphoneos \
	-configuration Debug \
	-project HttpSessionSample.xcodeproj \
	-scheme HttpSessionSample \
	-destination 'platform=iOS Simulator,name=iPhone 12 Pro,OS=14.4' \
	clean test CODE_SIGNING_ALLOWED=NO

code-coverage:
	 slather coverage -s --scheme HttpSession --configuration debug HttpSessionSample.xcodeproj