//
//  ViewController.m
//  WebViewTest001
//
//  Created by Nate Jang on 2017. 7. 8..
//  Copyright © 2017년 Nate Jang. All rights reserved.
//

#import "ViewController.h"

@import JavaScriptCore;

@interface ViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /**
     * No.2-1 JavaScript 통신
     * JavaScript ==> iOS
     *
     * 이벤트 Callback 형식 등록
     *
     * 설명 : 
     *  1. 초기 구동 시 Javascript Console Log 가 찍히는 것을 볼 수 있다.
     *
     * test.html
     * <script>
     * console.log('=== Java Script Start ===>');
     * console.log('<=== Java Script End ===');
     * </script>
     *
     *  2017-07-09 00:02:57.438880+0900 WebViewTest001[709:167807] <JSContext: 0x170048a30> log message: === Java Script Start ===>
     *  2017-07-09 00:02:57.440108+0900 WebViewTest001[709:167807] <JSContext: 0x170048a30> log message: <=== Java Script End ===
     * 
     */
    self.webView.delegate = self;
    JSContext *ctx = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    ctx[@"console"][@"log"] = ^(JSValue * msg) {
        NSLog(@"%@ log message: %@", [JSContext currentContext], msg);
    };
    /**
     *  2. 비동기 호출 확인
     *  http://fmtest.globepoint.co.kr:8080/test.mrn 페이지 안의 "iOS로 callbackToiOSFromJavaScript 호출하기" 를 클릭하면 아래와 같은 로그가 쌓임.
     2017-07-09 00:05:57.654723+0900 WebViewTest001[709:167807] <JSContext: 0x17005c380>: "JavaScript" ==> "iOS" 로 이 메세지를 보냄!!!
     2017-07-09 00:05:58.972583+0900 WebViewTest001[709:167807] <JSContext: 0x17005b6f0>: "JavaScript" ==> "iOS" 로 이 메세지를 보냄!!!
     2017-07-09 00:06:00.474934+0900 WebViewTest001[709:167807] <JSContext: 0x170059920>: "JavaScript" ==> "iOS" 로 이 메세지를 보냄!!!
     */
    ctx[@"callbackToiOSFromJavaScript"] = ^(JSValue * msg) {
        NSLog(@"%@: %@", [JSContext currentContext], msg);
    };

    // [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://fmtest.globepoint.co.kr:8080/test.mrn"]]];
    [self loadExamplePage:_webView];
}


- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

/**
 * No.2-2 JavaScript 통신
 * iOS ===> JavaScript
 *
 * 설명 : 
 * 앱의 Send 버튼을 클릭 할때 마다 test.html 상단에 "First Arg : first, Second Arg : second" 글자가 찍히는 게 보인다.
 * NSLog 로 JavaScript Function의 return 값 인 "ok!" 가 보이는 것을 확인 할 수 있다.
 */
- (IBAction)clickedSendButton:(id)sender {
    NSString *jscbString = [NSString stringWithFormat:@"commandFromiOSToJavaScript('first', 'second')"];
    NSLog(@"------> jscbString : [%@]", jscbString);
    NSString *result = [_webView stringByEvaluatingJavaScriptFromString:jscbString];
    NSLog(@"------> result : [%@]", result);
}

@end
