# DJGeocoder

DJGeocoder is a simple way to get geocoding done on iOS.

## Uh, What's Geocoding?

It's the process of taking an address, and finding out what latitude and longitude it corresponds to.

## Why Should I Care?

If you have an app that need to do this, it takes a surprising amount of code. Not so much that you can't write it, but enough to make realize that you'd rather be writing code for other things.

## OK, How Do I Use It?

1. Copy the `DJGeocoder.h` and `DJGeocoder.m` into your project.

		#import "DJGeocoder.h"

2. In your code, make yourself a Geocoder, fill in some details, and fire off a request

		DJGeocoder *coder = [[DJGeocoder alloc] init]; // don't forget your memory management rules :)
		coder.delegate = self;
		coder.streetAddress = @"1 Infinite Loop, Cupertino, CA";
		[coder startAsynchronousRequest];

3. Implement the delegate methods. One of them will get called when something interesting happens. (DJGeocoder finds the latitude/longitude or fails.)

		- (void)geocoder:(DJGeocoder *)coder didSucceedWithLatitude:(NSNumber *)latitude 
		  Longitude:(NSNumber *)longitude Details:(NSDictionary *)details {
			// your awesome code here
			[coder release];
		}	
		- (void)geocoder:(DJGeocoder *)coder didFailWithError:(NSError *)error {
			// Oh No :(
			[coder release];
		}
		
## But I don't want to implement DJGeocoderDelegate protocol! Can't I just do it synchronously?

**NO!** Performing network requests on the main UI thread is a sin.

## Network Requests?! What's going on?
DJGeocoder uses the [Google Maps Web Services API](http://code.google.com/apis/maps/documentation/geocoding/). This is a good time to mention that you should adhere to Google's [terms of service](http://code.google.com/apis/maps/terms.html#section_10_12) when using this. In a nutshell:

> [...] the Geocoding API may only be used in conjunction with a Google map; geocoding results without displaying them on a map is prohibited.

## One more thing...
This isn't really done. There's a lot of work to do. It's quite useable, however. If you find anything wrong, submit an issue. Better yet, fork me and fix it! :)

## iOS 5.0 includes this natively
This code was written before iOS 5.0 was introduced. If you're targeting
iOS 5.0 or later, then just use [CLGeocoder](http://developer.apple.com/library/ios/#documentation/CoreLocation/Reference/CLGeocoder_class/Reference/Reference.html). 
