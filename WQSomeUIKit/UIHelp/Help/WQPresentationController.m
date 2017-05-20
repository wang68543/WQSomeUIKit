//
//  WQPresentationController.m
//  SomeUIKit
//
//  Created by WangQiang on 2017/5/1.
//  Copyright © 2017年 WangQiang. All rights reserved.
//

#import "WQPresentationController.h"
@interface WQPresentationController()
//<UITabBarControllerDelegate,CAAnimationDelegate>{
//    id <UIViewControllerContextTransitioning> _transitionContext;
//}
@property (nonatomic,strong) UIVisualEffectView *visualView;
@end
@implementation WQPresentationController
#pragma mark - 重写UIPresentationController个别方法
- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    
    if (self) {
        // 必须设置 presentedViewController 的 modalPresentationStyle
        // 在自定义动画效果的情况下，苹果强烈建议设置为 UIModalPresentationCustom
        presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
        [self defaultCommonInit];
    }
    
    return self;
}

#pragma mark -- 子View转场初始化方式

-(void)defaultCommonInit{
//    _duration = 0.5;
}

//presentationTransitionWillBegin 是在呈现过渡即将开始的时候被调用的。我们在这个方法中把半透明黑色背景 View 加入到 containerView 中，并且做一个 alpha 从0到1的渐变过渡动画。
- (void)presentationTransitionWillBegin{
    
    // 使用UIVisualEffectView实现模糊效果
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _visualView = [[UIVisualEffectView alloc] initWithEffect:blur];
    _visualView.frame = self.containerView.bounds;
//    _visualView.alpha = 0.4;
    _visualView.backgroundColor = [UIColor blackColor];
    
    [self.containerView addSubview:_visualView];
    
    // 获取presentingViewController 的转换协调器，应该动画期间的一个类？上下文？之类的，负责动画的一个东西
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    
    // 动画期间，背景View的动画方式
    _visualView.alpha = 0.f;
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        _visualView.alpha = 0.4f;
    } completion:NULL];

    
}

//presentationTransitionDidEnd: 是在呈现过渡结束时被调用的，并且该方法提供一个布尔变量来判断过渡效果是否完成。在我们的例子中，我们可以使用它在过渡效果已结束但没有完成时移除半透明的黑色背景 View。
- (void)presentationTransitionDidEnd:(BOOL)completed{
    
    // 如果呈现没有完成，那就移除背景 View
    if (!completed) {
        [_visualView removeFromSuperview];
    }
}

//以上就涵盖了我们的背景 View 的呈现部分，我们现在需要给它添加淡出动画并且在它消失后移除它。正如你预料的那样，dismissalTransitionWillBegin 正是我们把它的 alpha 重新设回0的地方。
- (void)dismissalTransitionWillBegin{
    _visualView.alpha = 0.0;
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        _visualView.alpha = 0.f;
    } completion:NULL];
}

//我们还需要在消失完成后移除背景 View。做法与上面 presentationTransitionDidEnd: 类似，我们重载 dismissalTransitionDidEnd: 方法
- (void)dismissalTransitionDidEnd:(BOOL)completed{
    if (completed) {
        [_visualView removeFromSuperview];
    }
}

//在我们的自定义呈现中，被呈现的 view 并没有完全完全填充整个屏幕，
//被呈现的 view 的过渡动画之后的最终位置，是由 UIPresentationViewController 来负责定义的。
//我们重载 frameOfPresentedViewInContainerView 方法来定义这个最终位置

//还有最后一个方法需要重载。在我们的自定义呈现中，被呈现的 view 并没有完全完全填充整个屏幕，而是很小的一个矩形。被呈现的 view 的过渡动画之后的最终位置，是由 UIPresentationViewController 来负责定义的。我们重载 frameOfPresentedViewInContainerView 方法来定义这个最终位置这个位置要和PresentVC里面内容位置一致
- (CGRect)frameOfPresentedViewInContainerView{
    
//    CGFloat windowH = [UIScreen mainScreen].bounds.size.height;
//    CGFloat windowW = [UIScreen mainScreen].bounds.size.width;
//    
//    self.presentedView.frame = CGRectMake(0, windowH - 300, windowW, 300);
//    
//    return self.presentedView.frame;
    CGRect containerViewBounds = self.containerView.bounds;
    CGSize presentedViewContentSize = [self sizeForChildContentContainer:self.presentedViewController withParentContainerSize:containerViewBounds.size];
    
    // The presented view extends presentedViewContentSize.height points from
    // the bottom edge of the screen.
    CGRect presentedViewControllerFrame = containerViewBounds;
    presentedViewControllerFrame.size.height = presentedViewContentSize.height;
    presentedViewControllerFrame.origin.y = CGRectGetMaxY(containerViewBounds) - presentedViewContentSize.height;
    return presentedViewControllerFrame;
}
#pragma mark -- ViewController Transitioning Delegate

/*
 * 来告诉控制器，谁是动画主管(UIPresentationController)，因为此类继承了UIPresentationController，就返回了self
 */
- (UIPresentationController* )presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return self;
}

// MARK: - UIViewControllerTransitioningDelegate
// 该方法用于返回一个负责转场动画的对象
// 可以在该对象中控制弹出视图的尺寸等

//这里下面可以自定义一个类 遵守UIViewControllerAnimatedTransitioning协议可以在其中实现UIViewControllerInteractiveTransitioning协议的方法进行自定义动画
//- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
//    _present = YES;
//    return self;
//}
//
//- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
//    _present = NO;
//    return self;
//}
//
//
//#pragma mark -- ViewController Interactive Transitioning
//
//- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
//    return [transitionContext isAnimated]?self.duration:0.0;
//}
//
//// 核心，动画效果的实现
//- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
//{
//    // 1.获取源控制器、目标控制器、动画容器View
//    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    __unused UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    
//    UIView *containerView = transitionContext.containerView;
//    
//    // 2. 获取源控制器、目标控制器 的View，但是注意二者在开始动画，消失动画，身份是不一样的：
//    // 也可以直接通过上面获取控制器获取，比如：toViewController.view
//    // For a Presentation:
//    //      fromView = The presenting view.
//    //      toView   = The presented view.
//    // For a Dismissal:
//    //      fromView = The presented view.
//    //      toView   = The presenting view.
//    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
//    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
//    
//    [containerView addSubview:toView];  //必须添加到动画容器View上。
//    
//    // 判断是present 还是 dismiss
//    BOOL isPresenting = (fromViewController == self.presentingViewController);
//    
//    CGFloat screenW = CGRectGetWidth(containerView.bounds);
//    CGFloat screenH = CGRectGetHeight(containerView.bounds);
//    
//    // 左右留35
//    // 上下留80
//    
//    // 屏幕顶部：
//    CGFloat x = 35.f;
//    CGFloat y = -1 * screenH;
//    CGFloat w = screenW - x * 2;
//    CGFloat h = screenH - 80.f * 2;
//    CGRect topFrame = CGRectMake(x, y, w, h);
//    
//    // 屏幕中间：
//    CGRect centerFrame = CGRectMake(x, 80.0, w, h);
//    
//    // 屏幕底部
//    CGRect bottomFrame = CGRectMake(x, screenH + 10, w, h);  //加10是因为动画果冻效果，会露出屏幕一点
//    
//    if (isPresenting) {
//        toView.frame = topFrame;
//    }
//    
//    NSTimeInterval duration = [self transitionDuration:transitionContext];
//    // duration： 动画时长
//    // delay： 决定了动画在延迟多久之后执行
//    // damping：速度衰减比例。取值范围0 ~ 1，值越低震动越强
//    // velocity：初始化速度，值越高则物品的速度越快
//    // UIViewAnimationOptionCurveEaseInOut 加速，后减速
//    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.7f initialSpringVelocity:0.3f options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        if (isPresenting)
//            toView.frame = centerFrame;
//        else
//            fromView.frame = bottomFrame;
//    } completion:^(BOOL finished) {
//        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//    }];
//    
//}
- (void)containerViewWillLayoutSubviews
{
    [super containerViewWillLayoutSubviews];
}

//| --------以下四个方法，是按照苹果官方Demo里的，都是为了计算目标控制器View的frame的----------------
//  当 presentation controller 接收到
//  -viewWillTransitionToSize:withTransitionCoordinator: message it calls this
//  method to retrieve the new size for the presentedViewController's view.
//  The presentation controller then sends a
//  -viewWillTransitionToSize:withTransitionCoordinator: message to the
//  presentedViewController with this size as the first argument.
//
//  Note that it is up to the presentation controller to adjust the frame
//  of the presented view controller's view to match this promised size.
//  We do this in -containerViewWillLayoutSubviews.
//
- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize
{
    if (container == self.presentedViewController)
        return ((UIViewController*)container).preferredContentSize;
    else
        return [super sizeForChildContentContainer:container withParentContainerSize:parentSize];
}

//  建议就这样重写就行，这个应该是控制器内容大小变化时，就会调用这个方法， 比如适配横竖屏幕时，翻转屏幕时

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container
{
    [super preferredContentSizeDidChangeForChildContentContainer:container];
    
    if (container == self.presentedViewController)
        [self.containerView setNeedsLayout];
}

@end
