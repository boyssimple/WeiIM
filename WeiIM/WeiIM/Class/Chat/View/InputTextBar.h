//
//  InputTextBar.h
//  WeiIM
//
//  Created by zhouMR on 2017/4/26.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceView.h"
#import "FunctionView.h"


typedef enum{
    TEXT = 0,
    RECORD,
    FACE,
    FUNC,
    NONE
} InputType;

@protocol InputTextBarDelegate;
@interface InputTextBar : UIView<FunctionViewDelegate>
{
    UITextView *inputText;
    FaceView *faceView;
    FunctionView *funcView;
    BOOL showFace;
    BOOL isKeyboard;
    NSArray* faceData;
}
@property (nonatomic, strong) UIButton *recordImg;
@property (nonatomic, strong) UIButton *btnRecord;
@property (nonatomic, assign) InputType type;
@property (nonatomic, weak) id<InputTextBarDelegate> delegate;

+ (CGFloat)calHeight;
@end

@protocol InputTextBarDelegate <NSObject>

- (void)inputText:(InputTextBar *)bar clickedButtonAtIndex:(NSInteger)buttonIndex withType:(NSInteger)type;  //1-表情   2-语音   3-功能
- (void)clickChatCell:(InputTextBar *)bar withOpen:(BOOL)open;
- (void)sendMessage:(NSString*)message;
@end
