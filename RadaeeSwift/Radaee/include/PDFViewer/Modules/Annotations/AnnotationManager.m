//
//  AnnotationManager.m
//  RadaeePDF-Cordova
//
//  Created by Emanuele Bortolami on 26/09/17.
//

#import "AnnotationManager.h"
#import "PDFObjc.h"

@implementation AnnotationManager

#pragma mark - Export
+ (NSString *)exportAnnots:(NSString *)pdfPath password:(NSString *)password lastModifyDate:(NSString *)lastModifyDate exportAnnotFile:(NSString *)exportAnnotFile
{
    if (exportAnnotFile.length == 0) {
        exportAnnotFile = [ANNOT_MANAGER_FOLDER stringByAppendingPathComponent:@"temp.json"];
        [[NSFileManager defaultManager] createDirectoryAtPath:ANNOT_MANAGER_FOLDER withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    [[NSFileManager defaultManager] createFileAtPath:exportAnnotFile contents:nil attributes:nil];
    
    PDFDoc *doc = [[PDFDoc alloc] init];
    
    // Open document
    if ([doc open:pdfPath :password] == 0) {
        
        // Get the PDF ID
        NSString *pdfId = [RDUtils getPDFIDForDoc:doc];
        
        NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:exportAnnotFile];
        [fileHandler seekToEndOfFile];
        [fileHandler writeData:[@"[" dataUsingEncoding:NSUTF8StringEncoding]];
        
        for (int i = 0; i < doc.pageCount; i++) {
            @autoreleasepool
            {
                // Get the page
                PDFPage *page = [doc page:i];
                [page objsStart];
                
                // Iterate annotations
                for (int c = 0; c < page.annotCount; c++) {
                    
                    if (!(i == 0 && c == 0)) {
                        [fileHandler writeData:[@"," dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                    
                    // Get the annotation
                    PDFAnnot *annot = [page annotAtIndex:c];
                    
                    [fileHandler writeData:[[AnnotationManager createAnnotStruct:annot pdfid:pdfId pdfname:[pdfPath lastPathComponent] index:i] dataUsingEncoding:NSUTF8StringEncoding]];
                }
            }
        }
        
        // Save the document to keep the annotation names
        [doc save];
        
        [fileHandler writeData:[@"]" dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandler closeFile];
    }
    
    doc = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:ANNOT_MANAGER_FOLDER]) {
        
        NSString *tempString = [NSString stringWithContentsOfFile:exportAnnotFile encoding:NSUTF8StringEncoding error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:ANNOT_MANAGER_FOLDER error:nil];
        
        return tempString;
    }
    
    return @"";
}
             
+ (NSString *)createAnnotStruct:(PDFAnnot *)annot pdfid:(NSString *)pdfid pdfname:(NSString *)pdfname index:(int)index
{
    NSMutableDictionary *annotDict = [NSMutableDictionary dictionary];
    
    NSString *base64Annot = [AnnotationManager getAnnotData:annot];
    NSString *annotName = [annot getName];
    NSString *author = [annot getPopupLabel];
    NSString *modDate = [annot getModDate];
    
    if (annotName.length == 0) {
        annotName = [base64Annot MD5];
        [annot setName:annotName];
        
        // Get the data again after name set
        base64Annot = [AnnotationManager getAnnotData:annot];
    }
    
    // Avoid nil value
    if (!author) author = @"";
    if (!base64Annot) base64Annot = @"";
    if (!annotName) annotName = @"";
    if (!modDate) modDate = @"";
    
    PDF_RECT annotRect;
    [annot getRect:&annotRect];
    
    [annotDict setObject:pdfid forKey:@"doc_id"];
    [annotDict setObject:pdfname forKey:@"doc_name"];
    [annotDict setObject:[NSNumber numberWithInt:index] forKey:@"page_index"];
    [annotDict setObject:annotName forKey:@"annot_name"];
    [annotDict setObject:modDate forKey:@"annot_modify_date"];
    [annotDict setObject:base64Annot forKey:@"annot_data"];
    [annotDict setObject:author forKey:@"annot_author"];
    [annotDict setObject:[NSNumber numberWithFloat:annotRect.left] forKey:@"annot_rect_left"];
    [annotDict setObject:[NSNumber numberWithFloat:annotRect.top] forKey:@"annot_rect_top"];
    [annotDict setObject:[NSNumber numberWithFloat:annotRect.right] forKey:@"annot_rect_right"];
    [annotDict setObject:[NSNumber numberWithFloat:annotRect.bottom] forKey:@"annot_rect_bottom"];
    
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:annotDict options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
}

#pragma mark - Import

+ (BOOL)importAnnots:(NSString *)pdfPath password:(NSString *)password annotsToImport:(NSString *)annotsToImport forceImport:(BOOL)forceImport
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:pdfPath]) {

        PDFDoc *doc = [[PDFDoc alloc] init];
        
        // Open document
        if ([doc open:pdfPath :password] == 0) {
            return [AnnotationManager importAnnotsFromDoc:doc pdfPath:pdfPath password:password annotsToImport:annotsToImport forceImport:forceImport];
        }
    }
    
    return NO;
}

+ (BOOL)importAnnotsFromDoc:(PDFDoc *)doc pdfPath:(NSString *)pdfPath password:(NSString *)password annotsToImport:(NSString *)annotsToImport forceImport:(BOOL)forceImport
{
    NSArray *annots = [NSArray array];
    
    // Check if it's a path
    if ([[NSFileManager defaultManager] isReadableFileAtPath:annotsToImport]) {
        annots = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:annotsToImport options:NSDataReadingMappedAlways|NSDataReadingUncached error:nil] options:NSJSONReadingAllowFragments error:nil];
    } else {
        annots = [NSJSONSerialization JSONObjectWithData:[annotsToImport dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    }
    
    for (NSDictionary *dict in annots) {
        // Get annot info and import
        if (![AnnotationManager parseAnnotDict:dict inDoc:doc force:forceImport]) {
            return NO;
        }
    }
    
    [doc save];
    return YES;
}

+ (BOOL)parseAnnotDict:(NSDictionary *)dict inDoc:(PDFDoc *)doc force:(BOOL)force
{
    if (doc) {
        NSString *documentId = [dict objectForKey:@"doc_id"];
        NSString *annotName = [dict objectForKey:@"annot_name"];
        NSString *modifyDate = [dict objectForKey:@"annot_modify_date"];
        NSString *base64Annot = [dict objectForKey:@"annot_data"];
        int page_index = [[dict objectForKey:@"page_index"] intValue];
        
        if (!force) {
            // Check if documentId matches
            if (![documentId isEqualToString:[RDUtils getPDFIDForDoc:doc]]) {
                return NO;
            }
        }
        
        PDFPage *page = [doc page:page_index];
        [page objsStart];
        
        // Check if annot already exists
        PDFAnnot *annot = [page annotByName:annotName];
        PDF_RECT rect;
        
        if (annot) {
            // check date
            // remove old and add new
            
            NSDate *oldAnnotDate = [RDUtils dateFromPdfDate:[annot getModDate]];
            NSDate *newAnnotDate = [RDUtils dateFromPdfDate:modifyDate];
            
            if ([oldAnnotDate compare:newAnnotDate] == NSOrderedDescending)
                return YES;
            
            [annot removeFromPage];
            
        }
        
        rect.left = [[dict objectForKey:@"annot_rect_left"] floatValue];
        rect.top = [[dict objectForKey:@"annot_rect_top"] floatValue];
        rect.right = [[dict objectForKey:@"annot_rect_right"] floatValue];
        rect.bottom = [[dict objectForKey:@"annot_rect_bottom"] floatValue];
        
        [AnnotationManager importNewAnnot:base64Annot inRect:rect page:page];
    }
    
    return YES;
}

+ (void)importNewAnnot:(NSString *)annot inRect:(PDF_RECT)rect page:(PDFPage *)page
{
    NSData *annotData = [[NSData alloc] initWithBase64EncodedString:annot options:0];
    [page importAnnot:&rect :[annotData bytes] :(int)[annotData length]];
}

#pragma mark - Others

+ (NSString *)getAnnotData:(PDFAnnot *)annot
{
    unsigned char buf[1024];
    [annot export:buf :sizeof(buf)];
    
    return [[NSData dataWithBytes:buf length:sizeof(buf)] base64EncodedStringWithOptions:0];
}

@end
