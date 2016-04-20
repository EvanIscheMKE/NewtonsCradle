//
//  HDPendulumView.m
//  NewtonsCradle
//
//  Created by Evan Ische on 5/20/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDPendulumView.h"
#import "UIColor+ColorAdditions.h"

const NSUInteger kNumberOfBalls = 5;
@interface HDNewtonsBall : UIView
@end

@implementation HDNewtonsBall

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = CGRectGetMidX(frame);
        self.backgroundColor = [UIColor blueColor];
    }
    return self;
}

@end

@implementation HDPendulumView {
    NSArray *_newtonsBalls;
    NSArray *_newtonsAnchors;
    UIDynamicAnimator *_animator;
    UIPushBehavior *_pushBehavior;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor flatSTDarkBlueColor];
        self.layer.cornerRadius = 10.0f;
        self.layer.masksToBounds = YES;
        
        [self _layoutNewtonsBalls];
        
        UIDynamicBehavior *behavior = [[UIDynamicBehavior alloc] init];
        [behavior addChildBehavior:[self _createCollisionBehaviorForObjects:_newtonsBalls]];
        [behavior addChildBehavior:[self _createGravityBehaviorForObjects:_newtonsBalls]];
        [behavior addChildBehavior:[self _createItemBehaviorForObjects:_newtonsBalls]];
        [self _addAnchorsToBehavior:behavior];
        
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        [_animator addBehavior:behavior];
        
        _pushBehavior = [[UIPushBehavior alloc] initWithItems:@[[_newtonsBalls firstObject]] mode:UIPushBehaviorModeInstantaneous];
        _pushBehavior.pushDirection = CGVectorMake(-.6f, 0);
        [_animator addBehavior:_pushBehavior];
    }
    return self;
}

- (void)_layoutNewtonsBalls {
    
    const CGSize kBallSize = CGSizeMake(22.0f, 22.0f);
    
    const CGFloat startPositionX = CGRectGetMidX(self.bounds) - ((kNumberOfBalls - 1.0) / 2.0f * (kBallSize.width));
    const CGFloat kStringDistance = CGRectGetHeight(self.bounds)/4.0f;
    
    NSMutableArray *newtonsBalls = [NSMutableArray array];
    NSMutableArray *newtonsAnchors = [NSMutableArray array];
    for (NSUInteger i = 0; i < kNumberOfBalls; i++) {
        
        CGRect bounds = CGRectMake(0.0f, 0.0f, kBallSize.width, kBallSize.height);
        HDNewtonsBall *newBall = [[HDNewtonsBall alloc] initWithFrame:bounds];
        newBall.backgroundColor = [UIColor flatSTLightBlueColor];
        [newBall addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
        newBall.center = CGPointMake(startPositionX + (i * (kBallSize.width)), CGRectGetMidY(self.bounds) + kStringDistance/2);
        [self addSubview:newBall];
        [newtonsBalls addObject:newBall];
        
        CGPoint anchor = newBall.center;
        anchor.y -= kStringDistance;
        
        UIView *anchorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6.0f, 6.0f)];
        anchorView.backgroundColor = [UIColor flatSTEmeraldColor];
        anchorView.center = anchor;
        [self addSubview:anchorView];
        [newtonsAnchors addObject:anchorView];
        
    }
    _newtonsBalls = newtonsBalls;
    _newtonsAnchors = newtonsAnchors;
}

- (void)_addAnchorsToBehavior:(UIDynamicBehavior *)behavior {
    
    for(id<UIDynamicItem> newtonsBall in _newtonsBalls) {
        NSUInteger index = [_newtonsBalls indexOfObjectIdenticalTo:newtonsBall];
        UIView *anchorView = _newtonsAnchors[index];
        UIDynamicBehavior *attachmentBehavior = [self createAttachmentBehaviorFromBall:newtonsBall toAnchor:anchorView];
        [behavior addChildBehavior:attachmentBehavior];
    }
}

- (UIDynamicBehavior *)createAttachmentBehaviorFromBall:(id<UIDynamicItem>)newtonsBall toAnchor:(id<UIDynamicItem>)anchorPoint {
    return [[UIAttachmentBehavior alloc] initWithItem:newtonsBall attachedToAnchor:[anchorPoint center]];
}

- (UIDynamicItemBehavior *)_createItemBehaviorForObjects:(NSArray *)objects {
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:objects];
    itemBehavior.elasticity = 1.0;
    itemBehavior.allowsRotation = NO;
    itemBehavior.resistance = 0.0f;
    return itemBehavior;
}

- (UIDynamicBehavior *)_createGravityBehaviorForObjects:(NSArray *)objects {
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:objects];
    gravity.magnitude = 10;
    return gravity;
}

- (UIDynamicBehavior *)_createCollisionBehaviorForObjects:(NSArray *)objects {
    return [[UICollisionBehavior alloc] initWithItems:objects];
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    for(id<UIDynamicItem> ball in _newtonsBalls){
        CGPoint anchor = [[_newtonsAnchors objectAtIndex:[_newtonsBalls indexOfObject:ball]] center];
        CGPoint ballCenter = [ball center];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), anchor.x, anchor.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), ballCenter.x, ballCenter.y);
        CGContextSetLineWidth(context, 1.0f);
        [[UIColor whiteColor] setStroke];
        CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);
    }
}

- (void)dealloc {
    for (HDNewtonsBall *ball in _newtonsBalls) {
        [ball removeObserver:self forKeyPath:@"center"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self setNeedsDisplay];
}

@end
