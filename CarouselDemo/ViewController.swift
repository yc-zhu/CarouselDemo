//
//  ViewController.swift
//  CarouselDemo
//
//  Created by zyc on 08/08/2018.
//  Copyright © 2018 zyc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CustomCarouselViewDelegate {
    @IBOutlet weak var xibCarouselView: CustomCarouselView!
    var carouselView: CustomCarouselView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let carouselView = CustomCarouselView(frame: CGRect(x: 0, y: 100, width: self.view.bounds.size.width, height: 200))
        carouselView.delegate = self
        carouselView.prepareForImages(images: ["Image","Image1","Image2","Image3"],type:  .local)
        self.view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        self.view.addSubview(carouselView);
        self.carouselView = carouselView;
        self.initialCarouseViewFromXib()
    }
    func initialCarouseViewFromXib(){
        // 因为http 请求，所以在infoPlist文件设置了Allow Arbitrary Loads 为 YES
        var tempArray = Array<String>()
        tempArray.append("http://img.zcool.cn/community/019c2958a2b760a801219c77a9d27f.jpg")
        tempArray.append("http://img03.tooopen.com/uploadfile/downs/images/20110714/sy_20110714135215645030.jpg")
        tempArray.append("http://img05.tooopen.com/images/20150820/tooopen_sy_139205349641.jpg")
        tempArray.append("http://txt22263.book118.com/2017/0509/book105460/105459445.jpg")
        xibCarouselView.prepareForImages(images: tempArray,type:  .network)
    }
    func customCarouselView(_ customCarouselView: CustomCarouselView, didSelect index: NSInteger, selectData data: AnyObject) {
        print(index)
        print(data)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

