//
//  ViewController.m
//  网易标题demo
//
//  Created by qishang on 16/1/22.
//  Copyright © 2016年 Rocky. All rights reserved.
//

#import "ViewController.h"

#import "TopViewController.h"
#import "HotViewController.h"
#import "VideoViewController.h"
#import "SocietyViewController.h"
#import "ReadViewController.h"
#import "ScienceViewController.h"

static CGFloat const NAVBar  = 64;
static CGFloat const TitleH = 44;
static CGFloat const maxTitleScale = 1.3;

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *titleScrollView;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) NSMutableArray * buttons;
@property (nonatomic, strong) UIButton *selectBtn;
@end


@implementation ViewController

- (NSMutableArray *)buttons {

    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTitleScrollView];
    [self setupContentScrollView];
    [self addChildViewConteoller];
    [self setupTitle];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.contentScrollView.contentSize = CGSizeMake(SCREEN_WIDTH *self.childViewControllers.count, 0);
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.delegate = self;

}

#pragma  mark - 设置头部标题栏

- (void)setupTitleScrollView {

    CGFloat y = self.navigationController ? NAVBar : 0;
    
    UIScrollView *titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, TitleH)];
    titleScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:titleScrollView];
    
    self.titleScrollView = titleScrollView;
}

#pragma mark - 设置内容
- (void)setupContentScrollView {
    
    CGFloat y = CGRectGetMaxY(self.titleScrollView.frame);
    UIScrollView *contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBar - TitleH)];
    [self.view addSubview:contentScrollView];
    self.contentScrollView = contentScrollView;

}

#pragma mark - 添加字视图控制器
- (void)addChildViewConteoller {

    TopViewController *topVC = [[TopViewController alloc] init];
    topVC.title = @"头条";
    [self addChildViewController:topVC];
    
    HotViewController *hotVC = [[HotViewController alloc] init];
    hotVC.title = @"热点";
    [self addChildViewController:hotVC];
    
    VideoViewController *videoVC = [[VideoViewController alloc] init];
    videoVC.title = @"视频";
    [self addChildViewController:videoVC];
    
    SocietyViewController *societyVC = [[SocietyViewController alloc] init];
    societyVC.title = @"社会";
    [self addChildViewController:societyVC];
    
    ReadViewController *readVC = [[ReadViewController alloc] init];
    readVC.title = @"订阅";
    [self addChildViewController:readVC];
    
    ScienceViewController *scienceVC = [[ScienceViewController alloc] init];
    scienceVC.title = @"科技";
    [self addChildViewController:scienceVC];
    
    
}

#pragma mark - 设置标题
- (void)setupTitle {

    NSInteger count = self.childViewControllers.count;
    CGFloat w = 100;
    CGFloat h = TitleH;
    
    for (int i = 0; i < count; i ++) {
        
        UIViewController *vc = self.childViewControllers[i];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(i *w, 0, w, h);
        btn.tag = i;
        [btn setTitle:vc.title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            
            [self btnClick:btn];
        }
        [self.buttons addObject:btn];
        [self.titleScrollView addSubview:btn];
    }
    self.titleScrollView.contentSize = CGSizeMake(w * count, 0);
}


#pragma mark - 点击btn
//按钮点击
- (void)btnClick:(UIButton *)sender {

    [self selectTitleBtn:sender];
    NSUInteger i = sender.tag;
    CGFloat x = i *SCREEN_WIDTH;
    [self setUpOneChildViewController:i];
    self.contentScrollView.contentOffset = CGPointMake(x, 0);
}

//选中按钮
- (void)selectTitleBtn:(UIButton *)btn {

    [self.selectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]
    ;
    self.selectBtn.transform = CGAffineTransformIdentity;
    
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.transform = CGAffineTransformMakeScale(maxTitleScale, maxTitleScale);

    self.selectBtn = btn;
    [self setTitleBtnCenetr:btn];
    
}

- (void)setTitleBtnCenetr:(UIButton *)btn {

    CGFloat offSet = btn.center.x - SCREEN_WIDTH * 0.5;
    
    if (offSet < 0) {
        
        offSet = 0;
    }
    
    CGFloat maxOfSet = self.titleScrollView.contentSize.width - SCREEN_WIDTH;
    if (offSet > maxOfSet) {
        
        offSet = maxOfSet;
    }
    
    self.titleScrollView.contentOffset = CGPointMake(offSet, 0);
}

- (void)setUpOneChildViewController:(NSUInteger)i {

    UIViewController *vc = self.childViewControllers[i];
    if (vc.view.superview) {
        return;
    }
    vc.view.frame = CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT - self.contentScrollView.frame.origin.y);
    [self.contentScrollView addSubview:vc.view];
    
}

#pragma mark - UISCrollViewDelegate 

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    NSUInteger i  = scrollView.contentOffset.x / SCREEN_WIDTH;
    [self setUpOneChildViewController:i];
    [self selectTitleBtn:self.buttons[i]];
    
}

//只要滚动scrollView就会调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat offSetX = self.contentScrollView.contentOffset.x;
    NSInteger leftIndex = offSetX / SCREEN_WIDTH;
    NSInteger rightIndex = leftIndex + 1;

    UIButton *leftBtn = self.buttons[leftIndex];
    UIButton *rightBtn = nil;
    
    if (rightIndex < self.buttons.count) {
        
        rightBtn = self.buttons[rightIndex];
    }
    
    CGFloat scaleR = offSetX / SCREEN_WIDTH - leftIndex;
    CGFloat scaleL = 1 - scaleR;
    CGFloat transScale = maxTitleScale - 1;
    leftBtn.transform = CGAffineTransformMakeScale(scaleL * transScale + 1, scaleL*transScale + 1);
    
    rightBtn.transform = CGAffineTransformMakeScale(scaleR *transScale + 1, scaleR *transScale + 1);
    
    UIColor *leftColor = [UIColor colorWithRed:scaleL green:0 blue:0 alpha:1];
    UIColor *rightColor = [UIColor colorWithRed:scaleR green:0 blue:0 alpha:1];
    [leftBtn setTitleColor:leftColor forState:UIControlStateNormal];
    [rightBtn setTitleColor:rightColor forState:UIControlStateNormal];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
