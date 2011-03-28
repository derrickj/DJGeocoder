//
//  DJGeocoder.h
//  
//
//  Created by Derrick Jones on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DJGeocoderDelegate;

@interface DJGeocoder : NSObject <NSXMLParserDelegate>{
	@private
	id <DJGeocoderDelegate> delegate;
	NSString *streetAddress;
	NSString *city;
	NSString *state;
	NSString *country;
	NSMutableData *xmlData; // holding place for data returned from google API
	NSNumber *theLat;
	NSNumber *theLng;
	// state variables to facilitate stream parsing
	NSMutableString *currentParseString;
	BOOL parsingStatus;
	BOOL parsingLocation;
	BOOL parsingLatitude;
	BOOL parsingLongitude;
}

@property (nonatomic, retain) NSString *streetAddress;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) id <DJGeocoderDelegate> delegate;

- (void)startAsynchronousRequest;
@end

@protocol DJGeocoderDelegate <NSObject>
@optional
- (void)geocoder:(DJGeocoder *)coder
didSucceedWithLatitude:(NSNumber *)latitude
	   Longitude:(NSNumber *)longitude Details:(NSDictionary *)details;

- (void)geocoder:(DJGeocoder *)coder didFailWithError:(NSError *)error;

@end