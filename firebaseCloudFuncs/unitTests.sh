#!/bin/bash
cd ../Convoy
xcodebuild -workspace Convoy.xcworkspace -scheme Travis -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 11,OS=13.2.2' build test | xcpretty
