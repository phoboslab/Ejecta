//
//  MobClickGameAnalytics.h
//  MobClickGameAnalytics
//
//  Updated by Minghua on 2014-03-17.
//  Copyright (C) 2010-2014 Umeng.com . All rights reserved.
//  Version 2.3.2.0

@interface MobClickGameAnalytics : NSObject

#pragma mark -
#pragma mark user methods

///---------------------------------------------------------------------------------------
/// @name  玩家熟悉设置
///---------------------------------------------------------------------------------------

/** 设置玩家的等级、游戏中的唯一Id、性别、年龄和来源.
 */

/** 设置玩家等级属性.
 @param level 玩家等级
 @return void
 */
+ (void)setUserLevel:(NSString *)level;

/** 设置玩家等级属性.
 @param userId 玩家Id
 @param sex 性别
 @param age 年龄
 @param platform 来源
 @return void
 */
+ (void)setUserID:(NSString *)userId sex:(int)sex age:(int)age platform:(NSString *)platform;

#pragma mark -
#pragma mark GameLevel methods


///---------------------------------------------------------------------------------------
/// @name  关卡统计
///---------------------------------------------------------------------------------------

/** 记录玩家进入关卡，通过关卡及失败的情况.
 */


/** 进入关卡.
 @param level 关卡
 @return void
 */
+ (void)startLevel:(NSString *)level;

/** 通过关卡.
 @param level 关卡,如果level == nil 则为当前关卡
 @return void
 */
+ (void)finishLevel:(NSString *)level;

/** 未通过关卡.
 @param level 关卡,如果level == nil 则为当前关卡
 @return void
 */

+ (void)failLevel:(NSString *)level;


#pragma mark -
#pragma mark Pay methods

///---------------------------------------------------------------------------------------
/// @name  支付统计
///---------------------------------------------------------------------------------------

/** 记录玩家使用真实货币的消费情况
 */


/** 玩家支付货币兑换虚拟币.
 @param cash 真实货币数量
 @param source 支付渠道
 @param coin 虚拟币数量
 @return void
 */

+ (void)pay:(double)cash source:(int)source coin:(double)coin;

/** 玩家支付货币购买道具.
 @param cash 真实货币数量
 @param source 支付渠道
 @param item 道具名称
 @param amount 道具数量
 @param price 道具单价
 @return void
 */
+ (void)pay:(double)cash source:(int)source item:(NSString *)item amount:(int)amount price:(double)price;


#pragma mark -
#pragma mark Buy methods

///---------------------------------------------------------------------------------------
/// @name  虚拟币购买统计
///---------------------------------------------------------------------------------------

/** 记录玩家使用虚拟币的消费情况
 */


/** 玩家使用虚拟币购买道具
@param item 道具名称
@param amount 道具数量
@param price 道具单价
@return void
 */
+ (void)buy:(NSString *)item amount:(int)amount price:(double)price;


#pragma mark -
#pragma mark Use methods


///---------------------------------------------------------------------------------------
/// @name  道具消耗统计
///---------------------------------------------------------------------------------------

/** 记录玩家道具消费情况
 */


/** 玩家使用虚拟币购买道具
@param item 道具名称
@param amount 道具数量
@param price 道具单价
@return void
 */

+ (void)use:(NSString *)item amount:(int)amount price:(double)price;


#pragma mark -
#pragma mark Bonus methods


///---------------------------------------------------------------------------------------
/// @name  虚拟币及道具奖励统计
///---------------------------------------------------------------------------------------

/** 记录玩家获赠虚拟币及道具的情况
 */


/** 玩家获虚拟币奖励
@param coin 虚拟币数量
@param source 奖励方式
@return void
 */

+ (void)bonus:(double)coin source:(int)source;

/** 玩家获道具奖励
@param item 道具名称
@param amount 道具数量
@param price 道具单价
@param source 奖励方式
@return void
 */

+ (void)bonus:(NSString *)item amount:(int)amount price:(double)price source:(int)source;

@end
