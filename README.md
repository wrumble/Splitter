# Splitter iOS App

The main point of Splitter is to display my skills as a developer and help me continue learning the vast chasm that is the world of programming.

Splitter, is designed to speed up service in a restaurant or any payment situation with a printed bill that needs to be split in a customised fashion for each person. You will be able to photograph your bill and allow the text recoginition to pick up the name, quantity and price of each item. These items can them be assigned to one or multiple people. The app works out each persons total and then alows them to pay the phone owner using Stripe and Card.io who then pays the whole bill total to the restaurant server.

Its certainly not a revolutionary app, but will speed up payment for both the diners and the servers. When paying with stripe it will take 2.9% + £0.30 of each payment after the Splitter account has had £50,000 pass through it. Before this Splitter will take 2%. Payment to me for building the app ;). Im unsure i will put it on the app store anytime soon due to the important details that are passed around when taking and receiving payment.


Now runs end to end on simulator without failing but because the simulator doesn't have cameras the profile picture functionality is gone.

When running on an actual phone it runs fine apart from getting an index out of range error when adding or editing a BillSplitter(this may be fixed but only tested on the phones i have available in the house), i think this is due to a multi threading issue but haven't resolved it yet, lord help me.

The above error should be fixed now but i don't have enough devices to test it on to be sure. App should run end to end seamlessly apart from loading splitter carousel twice in a stuterred fashion? From here there is a lot of code to be extracted from the controllers and refactoring.

There are plenty of edge cases and error handling responses to be dealt with. A final terms and conditions needs to be added  on the end payment screen. From here i can start localising the app for other countries and languages, this may prove to be a little tricky as Stripe has different sign up requirements for different countries.

To run:

-download the most recent version of xcode(https://developer.apple.com/xcode/)

-git clone git@github.com:wrumble/Splitter.git

-cd Splitter

-gem install cocoapods

-pod install

-open Splitter.xcworkspace

-run on whatever simulator you want :)

-or run on phone for (possible)disappointment when adding Bill Splitters

When testing a payment the card number must be 4242 4242 4242 4242, as long as other entries follow the standard format(account number: 8 digits, email: word@word.something, postcode: sw65ab etc) they will be accepted in test mode using Stripe.
