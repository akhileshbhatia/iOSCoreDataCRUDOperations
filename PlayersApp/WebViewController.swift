//
//  WebViewController.swift
//  PlayersApp
//
//  Created by Akhilesh Bhatia on 03/03/2019.
//  Copyright © 2019 Akhilesh Bhatia. All rights reserved.
//

import UIKit
import WebKit
class WebViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var urlText: UITextField!
    
    @IBOutlet weak var webView: WKWebView!
    
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    var playerUrl : String!;
    var webViewLoadComplete : Bool!;
    var myTimer : Timer!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Player Web Info";
        urlText.text = playerUrl;
        
        let url = URL(string: playerUrl);
        let request = URLRequest(url: url!);
        webView.navigationDelegate = self;
        webView.load(request);
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        initializeTimerParameters();
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        endTimer();
    }
    
    func initializeTimerParameters(){
        self.progressBar.progress = 0.0;
        self.progressBar.isHidden = false;
        self.webViewLoadComplete = false;
        self.myTimer = Timer.scheduledTimer(timeInterval: 0.01667, target: self, selector:#selector(timerCallBack), userInfo: nil, repeats: true)
    }
    func timerCallBack(){
        if (self.webViewLoadComplete){
            if(self.progressBar.progress >= 1){ //load complete
                self.progressBar.isHidden = true;
                self.myTimer.invalidate(); //stop timer
            }
            else{
                //increment loader by 10 percent
                self.progressBar.progress += 0.1;
            }
        }
        
        else{
            //increment loader by 5 percent
            self.progressBar.progress += 0.05;
            if (self.progressBar.progress >= 0.8){
                self.progressBar.progress = 0.8; //keep loader at 95% until page load is complete
            }
        }
    }
    func endTimer(){
        self.webViewLoadComplete = true;
    }


}
