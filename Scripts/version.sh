INFOPLIST_FILE="$SRCROOT/Meilishuo4iOS/Info.plist"

if [ "${CONFIGURATION}" = "Release" ] || [ "${CONFIGURATION}" = "CI" ]; then

    BUILD_NUMBER=`curl http://www.mogujie.com/mobile/build/increase -F "identifier=5LDV722ABF.com.meilishuo.meilishuo" -F "sign=f41b3c980d33d9d51a0a0df685b20bb9"`

    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$INFOPLIST_FILE"
fi


VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFOPLIST_FILE")
BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFOPLIST_FILE")
