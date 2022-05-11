//
//  UIIconView.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/13.
//  Copyright © 2020 Radaee. All rights reserved.
//
#import <UIKit/UIKit.h>
@class PDFDIB;
typedef void(^func_icon)(int);
@class PDFPopupCtrl;
@class PDFAnnot;
@interface UIIconBtn : UIImageView
{
    int m_atype;
    int m_icon;
    UIViewController *m_vc;
    PDFDIB *m_dib;
    PDFPopupCtrl *m_popup;
    NSMutableArray *m_dibs;
    UIView *m_view;
}
-(id)initWithCoder:(NSCoder *)aDecoder;
-(id)initWithFrame:(CGRect)frame;
-(void)setIcon:(PDFAnnot *)annot :(UIViewController *)vc;
-(int)icon;
@end
