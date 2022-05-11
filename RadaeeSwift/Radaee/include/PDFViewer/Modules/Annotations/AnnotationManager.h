//
//  AnnotationManager.h
//  RadaeePDF-Cordova
//
//  Created by Emanuele Bortolami on 26/09/17.
//

#import <Foundation/Foundation.h>
#import "RDUtils.h"

#define ANNOT_MANAGER_ENABLED
#define ANNOT_MANAGER_FOLDER [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"AnnotationManager"]

@interface AnnotationManager : NSObject

#pragma mark - Export
+ (NSString *)exportAnnots:(NSString *)pdfPath password:(NSString *)password lastModifyDate:(NSString *)lastModifyDate exportAnnotFile:(NSString *)exportAnnotFile;
+ (NSString *)createAnnotStruct:(PDFAnnot *)annot pdfid:(NSString *)pdfid pdfname:(NSString *)pdfname index:(int)index; // Export single annotation

#pragma mark - Import
+ (BOOL)importAnnots:(NSString *)pdfPath password:(NSString *)password annotsToImport:(NSString *)annotsToImport forceImport:(BOOL)forceImport;
+ (BOOL)importAnnotsFromDoc:(PDFDoc *)doc pdfPath:(NSString *)pdfPath password:(NSString *)password annotsToImport:(NSString *)annotsToImport forceImport:(BOOL)forceImport;

@end
