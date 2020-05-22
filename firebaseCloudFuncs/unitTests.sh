#!/bin/bash
cd ../Convoy
xcodebuild -workspace Convoy.xcworkspace -scheme Travis -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone X,OS=12.1' build test | xcpretty
