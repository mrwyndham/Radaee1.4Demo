//
//  UILStyleView.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#pragma once
#import <UIKit/UIKit.h>

typedef void(^func_lstyle)(const CGFloat *, int);
@interface UILStyleView : UIView
{
    CGFloat m_dashs[4];
    int m_dashs_cnt;
    func_lstyle m_callback;
}
-(id)init:(CGRect)frame :(func_lstyle)callback;
-(void)setDash:(const CGFloat *)dash :(int)dash_cnt;
@end

@interface UILStyleBtn : UIView
{
    CGFloat m_dashs[4];
    int m_dashs_cnt;
    UIViewController *m_vc;
}
-(id)initWithCoder:(NSCoder *)aDecoder;
-(id)initWithFrame:(CGRect)frame;
-(void)setDash:(const CGFloat *)dash :(int)dash_cnt :(UIViewController *)vc;
-(const CGFloat *)dash;
-(int)dashCnt;
@end
