//
//  MLSActivityLoading.m
//  Meilishuo4iOS
//
//  Created by kongkong_macpro on 16/5/25.
//  Copyright © 2016年 Kongkong. All rights reserved.
//

#import "MLSActivityLoading.h"
#import <ImageIO/ImageIO.h>

@implementation MLSActivityLoading

-(void)start{
    if (self.isAnimating) {
        return;
    }
    [self startAnimating];
}

-(void)stop{
    if (self.isAnimating) {
        [self stopAnimating];
    }
}

-(BOOL)doingAnimation{
    return self.isAnimating;
}

-(instancetype)initWithSupereViewFrame:(CGRect)supreViewFrame{
    CGFloat image_width = 40;//[(NSNumber *)self.viewStyle[@"image_width"] floatValue];
    CGFloat image_height = 40;//[(NSNumber *)self.viewStyle[@"image_height"] floatValue];
    CGRect frame = CGRectMake(supreViewFrame.size.width/2-image_width/2.f, supreViewFrame.size.height/2-image_height/2.f, image_width, image_height);

    
    return [[MLSActivityLoading alloc]initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadContent];
    }
    return self;
}

-(void)loadContent{
    NSMutableArray* images = [NSMutableArray array];
    
    for (ushort i = 0; i < 35; ++i) {
        UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"page_loading_000%02d",i]];
        [images addObject:image];
    }
    
    self.animationRepeatCount = [(__bridge NSString*)kCGImagePropertyGIFLoopCount integerValue];
    
    self.image = nil;
    self.animationImages = images;
    self.animationDuration = 1;
    [self startAnimating];

}
@end
