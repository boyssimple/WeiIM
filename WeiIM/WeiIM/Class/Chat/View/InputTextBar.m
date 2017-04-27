//
//  InputTextBar.m
//  WeiIM
//
//  Created by zhouMR on 2017/4/26.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "InputTextBar.h"
#define View_Height 200

@implementation InputTextBar

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = NONE;
        CGFloat height = 30;
        [self setBackgroundColor:RGB3(248)];
        
        UIView *line = [UIView new];
        [line setBackgroundColor:RGB(218, 220, 220)];
        line.frame = CGRectMake(0, 0, self.width, 1);
        [self addSubview:line];
        
        self.recordImg = [UIButton new];
        [self.recordImg setImage:[UIImage imageNamed:@"ChatRecordIcon"] forState:UIControlStateNormal];
        self.recordImg.frame = CGRectMake(5, (self.height-height)/2.0, height, height);
        [self.recordImg addTarget:self action:@selector(recordKeyboardChange) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.recordImg];
        
        faceView = [[FaceView alloc]initWithFrame:CGRectMake(0, [InputTextBar calHeight], self.width, View_Height)];
        faceView.hidden = YES;
//        faceView.delegate = self;
        [self addSubview:faceView];
        
        funcView = [[FunctionView alloc]initWithFrame:CGRectMake(0, [InputTextBar calHeight], self.width, View_Height)];
        funcView.hidden = YES;
        funcView.delegate = self;
        [self addSubview:funcView];
        
        inputText = [UITextView new];
        inputText.frame = CGRectMake(self.recordImg.right+5, (self.height-height)/2.0, self.width-(self.recordImg.right+5)-75, height);
        inputText.layer.borderColor = RGB(218, 220, 220).CGColor;
        inputText.layer.borderWidth = 1;
        inputText.returnKeyType  = UIReturnKeySend;
        inputText.layer.cornerRadius = 6;
        inputText.delegate = self;
        [self addSubview:inputText];
        
        self.btnRecord = [UIButton new];
        [self.btnRecord setTitle:@"按住说话" forState:UIControlStateNormal];
        [self.btnRecord setTitle:@"松开结束" forState:UIControlStateHighlighted];
        self.btnRecord.frame = CGRectMake(inputText.x, inputText.y, inputText.width, inputText.height);
        self.btnRecord.layer.borderColor = RGB(218, 220, 220).CGColor;
        self.btnRecord.layer.borderWidth = 1;
        self.btnRecord.layer.cornerRadius = 6;
        self.btnRecord.hidden = TRUE;
        [self.btnRecord setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.btnRecord addTarget:self action:@selector(recordUpAction) forControlEvents:UIControlEventTouchUpInside];
        [self.btnRecord addTarget:self action:@selector(recordDownAction) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.btnRecord];
        
        UIImageView *faceImg = [UIImageView new];
        [faceImg setImage:[UIImage imageNamed:@"ChatFaceIcon"]];
        faceImg.frame = CGRectMake(inputText.right+5, (self.height-height)/2.0, height, height);
        faceImg.userInteractionEnabled = TRUE;
        UITapGestureRecognizer *faceTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFaceAction)];
        [faceImg addGestureRecognizer:faceTap];
        [self addSubview:faceImg];
        
        UIImageView *addImg = [UIImageView new];
        [addImg setImage:[UIImage imageNamed:@"ChatAddIcon"]];
        addImg.frame = CGRectMake(faceImg.right+5, (self.height-height)/2.0, height, height);
        addImg.userInteractionEnabled = TRUE;
        UITapGestureRecognizer *addImgTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectImgAction)];
        [addImg addGestureRecognizer:addImgTap];
        [self addSubview:addImg];
    }
    return self;
}

- (void)recordDownAction{
    if ([self.delegate respondsToSelector:@selector(inputText:clickedButtonAtIndex:withType:)]) {
        [self.delegate inputText:self clickedButtonAtIndex:1 withType:2];
    }
}

- (void)recordUpAction{
    if ([self.delegate respondsToSelector:@selector(inputText:clickedButtonAtIndex:withType:)]) {
        [self.delegate inputText:self clickedButtonAtIndex:2 withType:2];
    }
}


- (void)recordKeyboardChange{
    if (self.type == RECORD) {
        [self setKeyboard];
        [inputText becomeFirstResponder];
        self.type = TEXT;
    }else{
        [self setRecord];
        if (self.type == TEXT) {
            [inputText endEditing:YES];
        }else{
            [self hideFaceAndFunc];
        }
        self.type = RECORD;
    }
}

-(void)showFaceAction{
    if (self.type == TEXT) {
        [inputText endEditing:YES];
    }
    funcView.hidden = YES;
    faceView.hidden = NO;
    [self showFaceAnimation];
    self.type = FACE;
}

- (void)selectImgAction{
    if (self.type == TEXT) {
        [inputText endEditing:YES];
    }
    funcView.hidden = NO;
    faceView.hidden = YES;
    [self showFuncAnimation];
    self.type = FUNC;
}

-(void)showFaceAnimation{
    [self setKeyboard];
    CGRect f = self.frame;
    f.size.height += faceView.height;
    self.frame = f;
    
//    if ([self.delegate respondsToSelector:@selector(handleHeight:)]) {
//        [self.delegate handleHeight:faceView.height];
//    }
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, -faceView.height);
    }completion:^(BOOL finished) {
    }];
}

- (void)showFuncAnimation{
    [self setKeyboard];
    CGRect f = self.frame;
    f.size.height += funcView.height;
    self.frame = f;
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, -funcView.height);
    }completion:^(BOOL finished) {
    }];
}

- (void)hideFaceAndFunc{
    CGRect f = self.frame;
    f.size.height = [InputTextBar calHeight];
    self.frame = f;
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        funcView.hidden = YES;
        faceView.hidden = YES;
    }];
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if(self.type == FACE || self.type == FUNC){
        [self hideFaceAndFunc];
    }
    self.type = TEXT;
    return  TRUE;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [self sendMessage];
        return NO;
    }
    
    return YES;
}

- (void)sendMessage{
    if ([self.delegate respondsToSelector:@selector(sendMessage:)]) {
        [self.delegate sendMessage:inputText.text];
        inputText.text = @"";
    }
}

-(void)setKeyboard{
    [self.recordImg setImage:[UIImage imageNamed:@"ChatRecordIcon"] forState:UIControlStateNormal];
    self.btnRecord.hidden = TRUE;
    inputText.hidden = FALSE;
}

- (void)setRecord{
    [self.recordImg setImage:[UIImage imageNamed:@"ChatKeyboardIcon"] forState:UIControlStateNormal];
    self.btnRecord.hidden = FALSE;
    inputText.hidden = TRUE;
}

- (void)functionView:(FunctionView *)functionView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([self.delegate respondsToSelector:@selector(inputText:clickedButtonAtIndex:withType:)]) {
        [self.delegate inputText:self clickedButtonAtIndex:buttonIndex withType:3];
    }
}

+ (CGFloat)calHeight{
    return 50;
}

@end
