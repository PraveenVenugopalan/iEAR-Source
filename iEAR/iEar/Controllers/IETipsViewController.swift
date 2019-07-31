//
//  IETipsViewController.swift
//  iEar
//
//  Created by developer on 03/11/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit
import WebKit

class IETipsViewController: UIViewController {
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "https://www.wikihow.com/Communicate-With-Deaf-People")!
        webView.load(URLRequest(url: url))
      }
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
