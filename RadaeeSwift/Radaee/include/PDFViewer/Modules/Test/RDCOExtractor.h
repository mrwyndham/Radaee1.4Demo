//
//  RDCOExtractor.h
//  PDFViewer
//
//  Created by Emanuele Bortolami on 11/08/17.
//
//

#import <Foundation/Foundation.h>

@class PDFDoc;
@interface RDCOExtractor : NSObject

- (void)getCORef:(PDFDoc *)m_doc;
- (BOOL)existOpenActionInDoc:(PDFDoc *)m_doc;
@end
