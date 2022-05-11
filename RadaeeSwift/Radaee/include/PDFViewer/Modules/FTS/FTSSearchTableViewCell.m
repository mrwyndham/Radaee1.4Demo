//
//  FTSSearchTableViewCell.m
//  MobileReplica
//
//  Created by Emanuele Bortolami on 18/09/17.
//  Copyright © 2017 GEAR.it S.r.l. All rights reserved.
//

#import "FTSSearchTableViewCell.h"

@implementation FTSSearchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithOccurrence:(FTSOccurrence *)occurrence
{
    self.snippetLabel.attributedText = [self boldSearchedString:occurrence.text];
    self.numberLabel.text = [NSString stringWithFormat:@"%i", (occurrence.page + 1)];
}

- (NSAttributedString *)boldSearchedString:(NSString *)string
{
    // FTS Search
    string = [NSString stringWithFormat:@"<font face ='Helvetica' size='4'>%@</font>", string];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[string dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    return attrStr;
}

@end
