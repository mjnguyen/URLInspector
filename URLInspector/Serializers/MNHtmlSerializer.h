//
//  MNHtmlSerializer.h
//  URLInspector
//
//  Created by Michael Nguyen on 1/26/15.
//
//  HTML Serializer to allow AFNetworking to accept "text/html" documents.  AFNetworking does not have shipped with it.
//  This serializer is barebones and doesn't do anything but return the data as-is.
//

#import "AFURLResponseSerialization.h"

@interface MNHtmlSerializer : AFHTTPResponseSerializer

@end
