#!/bin/bash
cd ../Convoy
n=0
until [ "$n" -ge 5 ]
do
   xcodebuild -workspace Convoy.xcworkspace -scheme Travis -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 11,OS=13.2.2' build test | xcpretty -t; test ${PIPESTATUS[0]} -eq 0 && break # substitute your command here
   n=$((n+1))
   sleep 15
done
