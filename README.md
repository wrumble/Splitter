# Splitter iOS App

Rebuilding the Web app in RoR and Angular in swift for iOS.

Most up to date branch is `update_alert_views` which now runs end to end on simulator without failing but because the simulator doesnt have cameras the profile picture functionality is gone.

When running on an actual phone it runs fine apart from getting an index out of range error when adding or editing a BillSplitter(this may be fixed but only tested on the phones i have available in the house), i think this is due to a multi threading issue but havent resolved it yet, lord help me.

The above errors should be fixed now but i dont have enough devices to test it on to be sure. App should run end to end seemlessly apart from loading splitter carousel twice? From here there is a lot of code to be extracted from the controllers and refactoring. There are also plenty of edge cases and error handling responses to be dealt with.

To run:

-clone the repo

-cd into repo

-gem install cocoapods

-pod install

-open Splitter.xcworkspace

-run on whatever simulator you want :)

-or run on phone for (possible)dissapointment when adding Bill Splitters
