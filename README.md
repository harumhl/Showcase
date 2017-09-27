CSCE 482 Senior Capstone Project
# Showcase

Showcase is an iOS application that will allow you to take a picture of a textbook (or
possibly other purchasable items) and be able to view the same book on Amazon with reviews,
ratings, and availability to purchase it. The focus on the application is to store cookie information
that will include what bookstore the user was in when they took this picture so when the user
purchases it on Amazon we will be able to transfer a percentage of the funds to the local brick
and mortar store as a “thank you” for advertising the book and helping the user find it.

## Team Members
* Brandon Ellis
* Haru Myunghoon Lee
* Guillermo Lopez
* Brian Ta

## Development Information

What things you need to do to setup stuff
* To develop, open the workspace instead of the XCode project.
```
open Showcase.xcworkspace \
```
* Browser script to remove users from Firebase DB
```
var intervalId;
var clearFunction = function() {
  if ($('[aria-label="Delete account"]').size() == 0) {
    console.log("interval cleared")
    clearInterval(intervalId)
    return
  }
  $('[aria-label="Delete account"]')[0].click();
  setTimeout(function () {
     $(".md-raised:contains(Delete)").click()
  }, 1000);
};
intervalId = setInterval(clearFunction, 3000)
```

## Built With

* Pods
	* Firebase - Google Cloud Database Platform
	* IQKeyboardManager - easily manages all typical keybaord functions
	* ImageTextField - easily place an image icon in a textfield
* ...

## Debugging
* if given thread error after pulling project and building. Clean it using CMD+SHIFT+K or Product->Clean, then Build the application.

## Acknowledgments

* A simple Barcode reader was implemented thanks to, As of now we believe it only reads UPC
	* https://www.hackingwithswift.com/example-code/media/how-to-scan-a-barcode
* Reverse Geocoding used in application - !!!! BRANDON ADD THIS SOURCE IN SWIFT FILE !!!!!!
	* http://mhorga.org/2015/08/14/geocoding-in-ios.html
* Hat tip to anyone who's code was used
* Inspiration
* etc
