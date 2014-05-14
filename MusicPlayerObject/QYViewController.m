//
//  QYViewController.m
//  MusicPlayerObject
//
//  Created by qingyun on 14-5-6.
//  Copyright (c) 2014年 HNqingyun. All rights reserved.
//

#import "QYViewController.h"

static NSString *kCellRightIndifier = @"cellRightIndifier";

enum musicModelName{
    randomModel,
    singleModel,
    allModel,
    circleModel
};

@interface QYViewController ()

{
    UIImageView* imageView;
}

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIButton *musicModel;
@property (nonatomic,assign)NSInteger modelName;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeCurrent;
@property (weak, nonatomic) IBOutlet UILabel *timeDurtion;
@property (weak, nonatomic) IBOutlet UISlider *musicProgress;
@property (weak, nonatomic) IBOutlet UISlider *sliderVolumChange;


@property (nonatomic,retain)NSMutableArray *musicDate;
@property (nonatomic,retain)NSArray *nameFormusic;
@property (nonatomic,retain)NSURL *musicNamePath;
@property (nonatomic,retain)AVAudioPlayer *player;
@property (nonatomic,assign)NSInteger musicNumber;
@property (nonatomic,assign)BOOL stateBool;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewBackground;

@property (nonatomic,retain)UITableView *tableViewLyric;
@property (nonatomic,retain)UILabel *lyricNOView;

@property (nonatomic,retain)NSMutableDictionary *dictionaryLyric;
@property (nonatomic,retain)NSMutableArray *arrayTimer;
@property (nonatomic,assign)NSUInteger lyricNumber;
@property (nonatomic,assign)NSUInteger lyricLineNum;



@property (nonatomic,retain)UITableView *tableViewNaList;


@end

@implementation QYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    数据初始化
    self.musicNumber = 0;
    self.stateBool = NO;
    [self initMusicDate];
    
//    初次播放前准备
    
    
    self.nameFormusic = @[@"梁静茹-偶阵雨",@"林俊杰-背对背拥抱",@"情非得已",@"倩女幽魂"];
    [self beforePlayChange];
    
    
    self.nameLabel.text = self.nameFormusic[_musicNumber];
    self.sliderVolumChange.value = 0.4;
    self.modelName = randomModel;
    
//    右边的tableView初始化
   self.tableViewNaList = [[UITableView alloc]initWithFrame:CGRectMake(320, 0, 280, 568)
                                                      style:UITableViewStylePlain];
    self.tableViewNaList.tag = 1010;
    self.tableViewNaList.alpha = 0.6;
    self.tableViewNaList.delegate = self;
    self.tableViewNaList.dataSource  = self;
    [self.view addSubview:self.tableViewNaList];
//    注册cell
    [self.tableViewNaList registerClass:[UITableViewCell class]
                 forCellReuseIdentifier:kCellRightIndifier];
    
//    歌词tableView初始化
    self.tableViewLyric = [[UITableView alloc]
                           initWithFrame:CGRectMake(15, 100, 280, 330)
                                   style:UITableViewStylePlain];
    
    self.tableViewLyric.backgroundColor = [UIColor clearColor];
    self.tableViewLyric.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableViewLyric.dataSource = self;
    self.tableViewLyric.delegate = self;
    self.tableViewLyric.tag = 1011;
    [self.view addSubview:self.tableViewLyric];
    [self.tableViewLyric registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellRightIndifier];
    
    self.lyricNOView = [[UILabel alloc]initWithFrame:CGRectMake(20, 100, 280, 330)];
    self.lyricNOView.backgroundColor = [UIColor clearColor];
    self.lyricNOView.text = @"对不起，你还没有加载歌词";
    self.lyricNOView.hidden = YES;
    self.lyricNOView.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.lyricNOView];
    
//    self.dictionaryLyric = [[NSMutableDictionary alloc]initWithCapacity:21];
//    self.arrayTimer = [[NSMutableArray alloc]initWithCapacity:21];
//    [self analysicLyrics];
    
//    添加手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(singleTapDone:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    self.ImageViewBackground.userInteractionEnabled = YES;
    [self.ImageViewBackground addGestureRecognizer:singleTap];
    
    self.lyricNumber = 0;
    

	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}

//  //   隐藏状态栏
//-(BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

#pragma mark - musicDate INIT
-(void)initMusicDate
{
    self.musicDate = [[NSMutableArray alloc]initWithCapacity:20];
    NSURL *musicOne = [[NSBundle mainBundle] URLForResource:@"梁静茹-偶阵雨"
                                              withExtension:@"mp3"];
    [self.musicDate addObject:musicOne];
    NSURL *musicTwo = [[NSBundle mainBundle] URLForResource:@"林俊杰-背对背拥抱"
                                              withExtension:@"mp3"];
    [self.musicDate addObject:musicTwo];
    NSURL *musicThree = [[NSBundle mainBundle]URLForResource:@"情非得已"
                                               withExtension:@"mp3"];
    [self.musicDate addObject:musicThree];
    NSURL *musicFour = [[NSBundle mainBundle]URLForResource:@"倩女幽魂"
                                              withExtension:@"mp3"];
    [self.musicDate addObject:musicFour];

    
}

//播放更新加载歌曲
-(void)beforePlayChange
{
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self
                                   selector:@selector(onTimer:)
                                   userInfo:nil repeats:YES];
   
    NSError *error = nil;
    
    self.player = [[AVAudioPlayer alloc]
                   initWithContentsOfURL:[self.musicDate objectAtIndex:self.musicNumber]
                                   error:&error];
    
    if (error != nil) {
        NSLog(@"INIT audioPlay error:%@",error);
    }
    self.player.currentTime = 0;
    self.nameLabel.text = self.nameFormusic[_musicNumber];
    
    self.dictionaryLyric = [[NSMutableDictionary alloc]initWithCapacity:21];
    self.arrayTimer = [[NSMutableArray alloc]initWithCapacity:21];
    [self analysicLyrics];
    if (self.arrayTimer.count == 0) {
        self.tableViewLyric.hidden = YES;
        self.lyricNOView.hidden = NO;
        
    }else
    {
        self.tableViewLyric.hidden  = NO;
        self.lyricNOView.hidden = YES;
         self.lyricNumber= 0;
    }
   
    [self.tableViewLyric reloadData];
    
    

    [self.player prepareToPlay];
     self.player.delegate = self;
    
    
    
    
}

//更新总时间和当前时间
-(void)onTimer:(NSTimer *)timer
{
//    当前时间及其格式处理
    int secondCurrent = (int)self.player.currentTime % 60;
    int minuteCurrent = (int)self.player.currentTime /60;
    if (secondCurrent < 10)
    {
        self.timeCurrent.text = [NSString stringWithFormat:@"0%d:0%d",minuteCurrent,secondCurrent];
    }else
    {
        self.timeCurrent.text= [NSString stringWithFormat:@"0%d:%d",minuteCurrent,secondCurrent];
    }
    
//    总时间及格式处理
    int secondDuration = (int)self.player.duration % 60;
    int minuteDuration = (int)self.player.duration / 60;
    if (secondDuration < 10)
    {
        self.timeDurtion.text = [NSString stringWithFormat:@"0%d:0%d",minuteDuration,secondDuration];
    }else
    {
        self.timeDurtion.text = [NSString stringWithFormat:@"0%d:%d",minuteDuration,secondDuration];
    }
    
//    更新进度条
    self.musicProgress.value = self.player.currentTime / self.player.duration;
    [self acquireLyricNumber:self.player.currentTime];
    
    
}

//播放和暂停
- (IBAction)onPlayer:(UIButton *)sender
{
    if ([self.player isPlaying])
    {
        [self.playButton setImage:[UIImage imageNamed:@"play"]
                                   forState:UIControlStateNormal];
        self.stateBool = NO ;
        [self.player pause];
    }else
    {
        [self.playButton setImage:[UIImage imageNamed:@"stop"]
                                   forState:UIControlStateNormal];
        self.stateBool = YES;
//        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
//                                       selector:@selector(snow)
//                                       userInfo:nil repeats:YES];
        [self.player play];
        
    }
}

//下一曲
- (IBAction)onRightButton:(id)sender
{
    if (self.musicNumber == (self.musicDate.count -1)) {
        self.musicNumber = 0;
    } else
    {
        self.musicNumber ++;
    }
    [self beforePlayChange];
    
//    如果下一曲时正在播放则播放，否则不播放
   if (self.stateBool) {
       [self.player play];
   }
    
}

//上一曲
- (IBAction)onLeftButton:(UIButton *)sender
{
    if (self.musicNumber == 0) {
        self.musicNumber = self.musicDate.count - 1;
    }else
    {
        self.musicNumber --;
    }
    [self beforePlayChange];
    if (self.stateBool) {
        [self.player play];
    }
    
}

//歌曲进度
- (IBAction)onMusicProgress:(id)sender
{
    self.player.currentTime = self.musicProgress.value * self.player.duration;
}

//声音大小
- (IBAction)onSliderVlm:(id)sender {
    self.player.volume = self.sliderVolumChange.value;
}

//播放模式
- (IBAction)onMusicModel:(id)sender
{
    if (self.modelName == randomModel) {
        [self.musicModel setBackgroundImage:[UIImage imageNamed:@"single" ]
                                   forState:UIControlStateNormal];
        self.modelName = singleModel;
    }
    else if(self.modelName == singleModel)
    {
        [self.musicModel setBackgroundImage:[UIImage imageNamed:@"all"]
                                   forState:UIControlStateNormal];
        self.modelName = allModel;
    }else if(self.modelName == allModel)
    {
        [self.musicModel setBackgroundImage:[UIImage imageNamed:@"circle"]
                                   forState:UIControlStateNormal];
        self.modelName = circleModel;
    }else
    {
        [self.musicModel setBackgroundImage:[UIImage imageNamed:@"random"]
                                   forState:UIControlStateNormal];
        self.modelName = randomModel;
        
    }
}


#pragma mark - AVAudioPlayerDelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.modelName == randomModel)
    {
        self.musicNumber = rand()%((int)self.musicDate.count);
        [self beforePlayChange];
        [self.player play];
        
      }else if(self.modelName == singleModel)
      {
          [self beforePlayChange];
          [self.player play];
      }else if (self.modelName == allModel)
      {
          if (self.musicNumber == self.musicDate.count -1)
          {
              [self.player stop];
              self.musicNumber = 0;
              [self.playButton setImage:[UIImage imageNamed:@"play"]
                               forState:UIControlStateNormal];
              [self beforePlayChange];
          }else
          {
              self.musicNumber ++;
              [self beforePlayChange];
              [self.player play];
          }
      }else
      {
          if (self.musicNumber == self.musicDate.count -1) {
              self.musicNumber = 0;
              [self beforePlayChange];
              [self.player play];
          }else
          {
              self.musicNumber ++;
              [self beforePlayChange];
              [self.player play];
          }
      }
}


- (IBAction)onMenuButton:(id)sender
{
    self.tableViewLyric.hidden = YES;
    self.tableViewNaList.frame = CGRectMake(60, 0, 260, 568);
    CATransition *animation = [CATransition animation];
    animation.duration = 0.7;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromRight;
    [self.tableViewNaList.layer addAnimation:animation forKey:@"zhao"];
}

// 手势回调方法
-(void)singleTapDone:(UITapGestureRecognizer *)single
{
    self.tableViewNaList.frame = CGRectMake(320, 0, 260, 568);
    self.tableViewLyric.hidden = NO;
    
}
/*
-(void)snow
{
    int startX= random()%320;
    int endX= random()%320;
    int width= random()%25;
    CGFloat time= (random()%100)/10+5;
    CGFloat alp= (random()%9)/10.0+0.1;
    
    //    CGFloat red= (random()%10)/10.0;
    //    CGFloat green= (random()%10)/10.0;
    //    CGFloat blue= (random()%10)/10.0;
    
    UIImage* image= [UIImage imageNamed:@"snow.png"];
    imageView = [[UIImageView alloc] initWithImage:image];
    //    imageView.backgroundColor= [UIColor colorWithRed:red green:green blue:blue alpha:1];
    imageView.frame= CGRectMake(startX,-1*width,width,width);
    imageView.alpha=alp;
    
    [self.view addSubview:imageView];
    
    
    [UIView beginAnimations:nil context:@"imageView"];
    [UIView setAnimationDuration:time];
    
    if(endX>50&&endX<270)
    {
        imageView.frame= CGRectMake(endX, 270-width/2, width, width);
        
    }
    else if((endX>10&&endX<50)||(endX>270&&endX<310))
        imageView.frame= CGRectMake(endX, 400-width/2, width, width);
    else
        imageView.frame= CGRectMake(endX, 480, width, width);
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(onAnimationComplete:)];
    
    [UIView commitAnimations];
    
    
}
-(void)onAnimationComplete:(NSString*)animationID
{
//    UIImageView* snowView=imageView;
    [imageView removeFromSuperview];
    
}
*/

#pragma mark -  Lyric 
-(void)analysicLyrics
{
    NSString *lyricPath = [[NSBundle mainBundle]pathForResource:self.nameFormusic[_musicNumber]
                                                         ofType:@"lrc"];
    
    NSString *currentStr =[NSString stringWithContentsOfFile:lyricPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    
    NSArray *arrayTimeStr = [currentStr componentsSeparatedByString:@"\n"];
    int a= 0;
    for ( a = 0; a < arrayTimeStr.count; a++)
    {
        NSArray *arraySepaTimStr =[arrayTimeStr[a] componentsSeparatedByString:@"]"];
        
        if ([arraySepaTimStr[0] length] == 9)
        {
            NSString *firstPoint = [arrayTimeStr[a] substringWithRange:NSMakeRange(3, 1)];
            NSString *secondPoint = [arrayTimeStr[a] substringWithRange:NSMakeRange(6, 1)];
            
            if ([firstPoint isEqualToString:@":"] && [secondPoint isEqualToString:@"."])
            {
                NSString *resultTimer = [arraySepaTimStr[0] substringWithRange:NSMakeRange(1, 8)];
                [self.dictionaryLyric setObject:arraySepaTimStr[1] forKey:resultTimer];
                [self.arrayTimer addObject:resultTimer];
            }
        }
        
    }
    
    NSLog(@"%@",self.dictionaryLyric);
    
}

-(void)acquireLyricNumber:(NSInteger)curTime
{
    NSString *timeStrOne = [self.arrayTimer[_lyricNumber] substringWithRange:NSMakeRange(0, 2)];
    NSString *timeStrTwo = [self.arrayTimer[_lyricNumber] substringWithRange:NSMakeRange(3, 5)];
    NSInteger currentTime = [timeStrOne intValue]*60 +[timeStrTwo intValue];
    
    NSString *beginTimeOne = [self.arrayTimer[0] substringWithRange:NSMakeRange(0, 2)];
    NSString *beginTimeTwo = [self.arrayTimer[0] substringWithRange:NSMakeRange(3, 5)];
    NSInteger beginTime = [beginTimeOne intValue]*60 +[beginTimeTwo intValue];
    
    if (currentTime < beginTime)
    {
        self.lyricNumber = 0;
    }else if (currentTime < curTime)
      {
        NSInteger numberLyric = self.lyricNumber;
         [self updateLyric:self.lyricNumber];
        
        if (self.lyricLineNum < self.arrayTimer.count-1)
        {
            numberLyric ++;
            
        }else
        {
            numberLyric = self.arrayTimer.count-1;
        }
        
        self.lyricNumber = numberLyric;
        
    }
//    for (int i = 0; i < [self.arrayTimer count]; i++) {
//        
//        NSArray *array = [self.arrayTimer[i] componentsSeparatedByString:@":"];//把时间转换成秒
//        NSUInteger currentTime = [array[0] intValue] * 60 + [array[1] intValue];
//        if (i == [self.arrayTimer count]-1) {
//            //求最后一句歌词的时间点
//            NSArray *array1 = [self.arrayTimer[self.arrayTimer.count-1] componentsSeparatedByString:@":"];
//            NSUInteger currentTime1 = [array1[0] intValue] * 60 + [array1[1] intValue];
//            if (curTime > currentTime1) {
//                [self updateLyric:i];
//                break;
//            }
//        } else {
//            //求出第一句的时间点，在第一句显示前的时间内一直加载第一句
//            NSArray *array2 = [self.arrayTimer[0] componentsSeparatedByString:@":"];
//            NSUInteger currentTime2 = [array2[0] intValue] * 60 + [array2[1] intValue];
//            if (curTime < currentTime2) {
//                [self updateLyric:0];
//                break;
//            }
//            //求出下一步的歌词时间点，然后计算区间
//            NSArray *array3 = [self.arrayTimer[i+1] componentsSeparatedByString:@":"];
//            NSUInteger currentTime3 = [array3[0] intValue] * 60 + [array3[1] intValue];
//            if (curTime >= currentTime && curTime <= currentTime3) {
//                [self updateLyric:i];
//                break;
//            }
//            
//        }
//    }
//
}

//更新歌词
-(void)updateLyric:(NSInteger)lineNum
{
    self.lyricLineNum = lineNum;
    [self.tableViewLyric reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.lyricLineNum inSection:0];
    [self.tableViewLyric selectRowAtIndexPath:indexPath
                                     animated:YES
                               scrollPosition:UITableViewScrollPositionMiddle];
}


#pragma mark - tableView DateSourse and Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (tableView.tag == 1010) {
       count = self.musicDate.count;
    }else if(tableView.tag == 1011)
    {
        count = self.arrayTimer.count;
    }
    
    return count;
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellRightIndifier];
    
    if (tableView.tag == 1010)
    {
    cell.textLabel.text = self.nameFormusic[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Noteworthy" size:14.0];
//    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blueColor];
        
    } else if(tableView.tag == 1011)
    {
        NSString *stringLyric = [self.dictionaryLyric objectForKey:self.arrayTimer[indexPath.row]];
        cell.textLabel.text = stringLyric;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        if (self.lyricLineNum == indexPath.row)
        {
            cell.textLabel.font = [UIFont systemFontOfSize:17.0];
            cell.textLabel.textColor = [UIColor blackColor];
        }else
        {
            cell.textLabel.font = [UIFont systemFontOfSize:14.0];
            cell.textLabel.textColor = [UIColor colorWithRed:27/255.0
                                                   green:224/255.0
                                                    blue:239/255.0
                                                   alpha:0.8];
        }
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return cell;
        
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1010)
    {
        self.musicNumber = indexPath.row;
        [self beforePlayChange];
        [self.playButton setImage:[UIImage imageNamed:@"stop"]
                         forState:UIControlStateNormal];
        self.stateBool = YES;
        [self.player play];

        
    }
}

//设置cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

@end
