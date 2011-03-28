//
//  DJGeocoder.m
//  
//
//  Created by Derrick Jones on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DJGeocoder.h"


@implementation DJGeocoder
@synthesize streetAddress, city, state, country, delegate;


- (NSString *)urlEncodedAddress {
	//build up string component by component, separated by commas.
	//This needs work
	NSMutableString *address = [[NSMutableString alloc] init];
	if (streetAddress) {
		[address appendString:[streetAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	if (city) {
		[address appendFormat:@",%@", [city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	if (state) {
		[address appendFormat:@",%@", [state stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	if (country) {
		[address appendFormat:@",%@", [country stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	return [address autorelease];
}

#pragma mark -
#pragma mark Public API

- (void)startAsynchronousRequest{
	// build URL for request with Address (pretend we have it for now)
	NSString *address = [self urlEncodedAddress];
	NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/xml?address=%@&sensor=true&",address];
	
	// now that we have a well-formed url string, let's get our request
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLConnection	*connection = [NSURLConnection connectionWithRequest:request delegate:self];
	[connection start];	
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if (!xmlData) {
		xmlData = [[NSMutableData alloc] init];
	}
	[xmlData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"%@", @"Failed!");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	// loading finished, now can parse xml
	NSString *xmlString = [[NSString alloc] initWithBytes:[xmlData bytes] length:[xmlData length] encoding:NSUTF8StringEncoding];
	[xmlString release];
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
	parser.delegate = self;
	[parser parse];
	
}

#pragma mark -
#pragma mark NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqual:@"status"]) {
		parsingStatus = YES;
	} else if ([elementName isEqual:@"location"]) {
		parsingLocation = YES;
	} else if ([elementName isEqual:@"lat"]) {
		parsingLatitude = YES;
	} else if ([elementName isEqual:@"lng"]) {
		parsingLongitude = YES;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqual:@"status"]) {
		parsingStatus = NO;
		NSLog(@"status: %@", currentParseString);
		// if status is not OK, probably need to abort parsing and send message
		
		[currentParseString release];
		currentParseString = nil;
	} else if ([elementName isEqual:@"location"]) {
		parsingLocation = NO;
		// never built string for location, so no need to reset it
	} else if (parsingLocation && [elementName isEqual:@"lat"]) {
		parsingLatitude = NO;
		NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
		theLat = [formatter numberFromString:currentParseString];
		[currentParseString release];
		currentParseString = nil;
	} else if (parsingLocation && [elementName isEqual:@"lng"]) {
		parsingLongitude = NO;
		NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
		theLng = [formatter numberFromString:currentParseString];
		[currentParseString release];
		currentParseString = nil;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	// only build up string when parsing one of the fields we are interested in
	// Interested in: Request status, as well as latitude/longitude, but only when child of location
	// http://code.google.com/apis/maps/documentation/geocoding/#XML
	if (parsingStatus || (parsingLocation && (parsingLatitude || parsingLongitude))) {
		if (!currentParseString) {
			currentParseString = [[NSMutableString alloc] init];
		}
		[currentParseString appendString:string];
	} 
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	// call delegate method with latitude and longitude.
	// probably use details NSDictionary to provide more info at some point
	if ([delegate respondsToSelector:@selector(geocoder:didSucceedWithLatitude:Longitude:Details:)]) {
		[delegate geocoder:self didSucceedWithLatitude:theLat Longitude:theLng Details:nil];
	}
	[parser release];
}

//FIXME: take care of parser errors
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
}

#pragma mark -
#pragma mark Memory Management
- (void)dealloc {
	[delegate release];
	[streetAddress release];
	[city release];
	[state release];
	[country release];
	[xmlData release];
	[theLat release];
	[theLng release];
	[currentParseString release];
	[super dealloc];
}
@end
