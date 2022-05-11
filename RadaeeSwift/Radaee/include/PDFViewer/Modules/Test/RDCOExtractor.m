//
//  RDCOExtractor.m
//  PDFViewer
//
//  Created by Emanuele Bortolami on 11/08/17.
//
//

#import "RDCOExtractor.h"
#import "PDFObjc.h"

@interface RDCOExtractor () {
    
    BOOL done;
    NSMutableArray *vectorRefDoc;
    NSMutableArray *vectorRefAnnot;
    NSMutableArray *vectorRefPageno;
    NSMutableArray *vectorRefIndexInPage;
    
    NSMutableArray *vectorRefPagenoCO;
    NSMutableArray *vectorRefIndexInPageCO;
    
    NSArray *m_types;
}

@end

@implementation RDCOExtractor

- (void)getCORef:(PDFDoc *)m_doc
{
    // var init
    vectorRefDoc = [NSMutableArray array];
    vectorRefAnnot = [NSMutableArray array];
    vectorRefPageno = [NSMutableArray array];
    vectorRefIndexInPage = [NSMutableArray array];
    
    vectorRefPagenoCO = [NSMutableArray array];
    vectorRefIndexInPageCO = [NSMutableArray array];
    
    m_types = @[@"null", @"boolean", @"int", @"real", @"string", @"name", @"array", @"dictionary", @"reference", @"stream"];
    
    //load the vector that contains the CO ref taken from the AcroForm (get ref from the pdfDoc)
    
    //PDFObj *annotRef = [m_doc advanceGetObj:[[[m_doc page:0] annotAtIndex:6] advanceGetRef]];
    
    /*[self loadCOVector:[m_doc advanceGetObj:[m_doc advanceGetRef]] withDoc:m_doc];
    return;*/
    
    for (int i = 0; i < [m_doc pageCount]; i++) {
        PDFPage *page = [m_doc page:i];
        [page objsStart];
        NSLog(@"--ADV-- Page %i", i);
        for (int x = 0; x < page.annotCount; x++) {
            NSLog(@"--ADV-- Annot %i", x);
            [self loadCOVector:[m_doc advanceGetObj:[[page annotAtIndex:x] advanceGetRef]] withDoc:m_doc];
        }
        page = nil;
    }

    NSLog(@"--ADV-- vectorRefDoc %lu", (unsigned long)vectorRefDoc.count);
    
    done = NO;
    
    NSLog(@"--ADV-- vectorRefIndexInPageCO %lu", (unsigned long)vectorRefIndexInPageCO.count);
    
    
    // Sample: set some fields
    
    //PDFPage *page = [m_doc page:[[vectorRefPagenoCO objectAtIndex:0] intValue]];
    //PDFAnnot *annotation = [page annotAtIndex:[[vectorRefIndexInPageCO objectAtIndex:0] intValue]];
    
    /*
     PDFPage *page = [m_doc page:[[vectorRefPagenoCO objectAtIndex:1] intValue]];
     PDFAnnot *annotation = [page annotAtIndex:[[vectorRefIndexInPageCO objectAtIndex:1] intValue]];
     */
    
    //[annotation setEditText:@"1000"];
    
}

-(BOOL)existOpenActionInDoc:(PDFDoc *)m_doc
{
    NSString *viewMode = @"Fit";
    PDFObj *rootObj = [m_doc advanceGetObj:[m_doc advanceGetRef]];
    if (rootObj!=nil)
    {
        int count = [rootObj dictGetItemCount];
        for (int cur = 0; cur<count; cur++) {
            NSString *tag = [rootObj dictGetItemTag:cur];
            PDFObj *item = [rootObj dictGetItemByIndex:cur];
            if ([tag isEqualToString:@"OpenAction"] && item.getType == 8)
            {
                rootObj = [m_doc advanceGetObj:[item getReferenceVal]];
                if ([rootObj dictGetItemCount] > 0 && [[rootObj dictGetItemByIndex:0] getType] == 6)
                {
                    item = [rootObj dictGetItemByIndex:0];
                    int arrayCount = [item arrayGetItemCount];
                    if (arrayCount > 1)
                    {
                        viewMode = [[item arrayGetItem:1] getNameVal];
                        NSLog(@"%@", viewMode);
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

- (void)loadCOVector:(PDFObj *)obj withDoc:(PDFDoc *)m_doc
{
    if(done)
        return;
    
    @try {
        int type = [obj getType];
        NSString *type_name = [self get_type_name:type];
        
        //NSLog(@"--ADV-- %@: %i ->", type_name, type);
        
        switch (type) {
            case 1:
                NSLog(@"--ADV-- bool value = %i", [obj getBoolVal]);
                break;
            case 2:
                NSLog(@"--ADV-- int value = %i", [obj getIntVal]);
                break;
            case 3:
                NSLog(@"--ADV-- float value = %f", [obj getRealVal]);
                break;
            case 4:
                NSLog(@"--ADV-- string value = %@", [obj getTextStringVal]);
                break;
            case 5:
                NSLog(@"--ADV-- name value = %@", [obj getNameVal]);
                break;
            case 6:
            {
                int arraycount = [obj arrayGetItemCount];
                for(int k = 0; k < arraycount; k++) {
                    PDFObj *array_obj = [obj arrayGetItem:k];
                    [self loadCOVector:array_obj withDoc:m_doc];
                }
            }
            case 7:
            {
                NSLog(@"--ADV-- dictionary");
                int count = [obj dictGetItemCount];
                for (int cur = 0; cur < count; cur++) {
                    NSString *tag = [obj dictGetItemTag:cur];
                    PDFObj *item = [obj dictGetItemByIndex:cur];
                    NSLog(@"--ADV-- Tag: %@ --", tag);
                    [self loadCOVector:item withDoc:m_doc];
                    if ([tag isEqualToString:@"MediaBox"]) {
                        done = YES;
                    }
                }
                
            }
            case 8:
            {
                NSLog(@"--ADV-- reference");
                PDFObj *item_ref = [m_doc advanceGetObj:[obj getReferenceVal]];
                [self loadCOVector:item_ref withDoc:m_doc];
            }
            default:
            {
                
                
                break;
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"EXCEPTION: %@", exception.description);
    } @finally {
        
    }
}

- (NSString *)get_type_name:(int)type
{
    if(type >= 0 && type < m_types.count) return m_types[type];
    else return @"unknown";
}

@end
