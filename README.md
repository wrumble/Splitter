# Splitter iOS App

Rebuilding the Web app in RoR and Angular in swift for iOS.

 Now runs end to end on simulator without failing but because the simulator doesn't have cameras the profile picture functionality is gone.

When running on an actual phone it runs fine apart from getting an index out of range error when adding or editing a BillSplitter(this may be fixed but only tested on the phones i have available in the house), i think this is due to a multi threading issue but haven't resolved it yet, lord help me.

The above errors should be fixed now but i don't have enough devices to test it on to be sure. App should run end to end seamlessly apart from loading splitter carousel twice? From here there is a lot of code to be extracted from the controllers and refactoring. There are also plenty of edge cases and error handling responses to be dealt with.

To run:

-download the most recent version of xcode(https://developer.apple.com/xcode/)

-git clone git@github.com:wrumble/Splitter.git

-cd Splitter

-gem install cocoapods

-pod install

-open Splitter.xcworkspace

-run on whatever simulator you want :)

-or run on phone for (possible)disappointment when adding Bill Splitters
