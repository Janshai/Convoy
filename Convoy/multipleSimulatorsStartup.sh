#!/bin/sh

#  multipleSimulatorsStartup.sh
#  Convoy
#
#  Created by Jack Adams on 05/05/2020.
#  Copyright © 2020 Jack Adams. All rights reserved.
xcrun simctl shutdown all

path=$(find ~/Library/Developer/Xcode/DerivedData/Convoy-*/Build/Products/Debug-iphonesimulator -name "Convoy.app" | head -n 1)
echo "${path}"

filename=SimulatorsList.txt
grep -v '^#' $filename | while read -r line
do
xcrun simctl boot "$line" # Boot the simulator with identifier hold by $line var
xcrun simctl install "$line" "$path" # Install the .app file located at location hold by $path var at booted simulator with identifier hold by $line var
xcrun simctl launch "$line" com.gmail.adams.s.r.jack.Convoy # Launch .app using its bundle at simulator with identifier hold by $line var
done
