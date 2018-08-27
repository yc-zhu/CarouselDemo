//
//  CustomCarouselView.swift
//  CarouselDemo
//
//  Created by zyc on 08/08/2018.
//  Copyright © 2018 zyc. All rights reserved.
//

import UIKit
import Kingfisher
@objc protocol CustomCarouselViewDelegate {
    @objc optional func  customCarouselView(_ customCarouselView: CustomCarouselView, didSelect index: NSInteger, selectData data: AnyObject)
}

enum CarouselImageType: Int {
    case local = 0
    case network
}

class CustomCarouselView: UIView {
    private var images: Array<String>!
    private var topImageView: UIImageView!
    private var middleImageView: UIImageView!
    private var bottomImageView: UIImageView!
    private var topFrame = CGRect.zero
    private var middleFrame = CGRect.zero
    private var bottomFrame = CGRect.zero
    private var type: CarouselImageType = .local
    private var oriImages: Array<String>!
    private var timer: Timer?
    private var count: Int = 0
    private var refresh = true
    private var startPoint: CGPoint?
    private let bottomHeightMargin: CGFloat = 8
    weak var delegate: CustomCarouselViewDelegate?
    //MARK: Initial UI
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.setUp()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUp()
    }
    private func setUp(){
        self.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        
        bottomImageView = UIImageView()
        bottomImageView.layer.cornerRadius = 8
        bottomImageView.layer.masksToBounds = true
        self.addSubview(bottomImageView)
        
        middleImageView = UIImageView()
        middleImageView.layer.cornerRadius = 8
        middleImageView.layer.masksToBounds = true
        self.addSubview(middleImageView)
        
        topImageView = UIImageView()
        topImageView.layer.cornerRadius = 8
        topImageView.layer.masksToBounds = true
        topImageView.isUserInteractionEnabled = true
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(panAction(ges:)))
        topImageView.addGestureRecognizer(panGes)
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapAction(ges:)))
        topImageView.addGestureRecognizer(tapGes)
        self.addSubview(topImageView)
        
        timer = TimerWeakTarget.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .commonModes)
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if refresh {
            let width = self.bounds.size.width
            let height = self.bounds.size.height
            let topXMargin: CGFloat = 20;
            let middleXMargin: CGFloat = 30;
            let bottomXMargin: CGFloat = 40;
            let topYMargin: CGFloat = 0;
            let middleYMargin: CGFloat = 10;
            let bottomYMargin: CGFloat = 20;
            let imageViewHeight = height - topYMargin - 2 * bottomHeightMargin;
            topImageView.frame = CGRect(x: topXMargin, y: topYMargin, width: width - topXMargin * 2, height: imageViewHeight);
            topFrame = topImageView.frame
            middleImageView.frame = CGRect(x: middleXMargin, y: middleYMargin, width: width - middleXMargin * 2, height: imageViewHeight - (middleYMargin - topYMargin) + bottomHeightMargin);
            middleFrame = middleImageView.frame
            bottomImageView.frame = CGRect(x: bottomXMargin, y: bottomYMargin, width: width - bottomXMargin * 2, height: middleImageView.bounds.height - (bottomYMargin - middleYMargin) + bottomHeightMargin)
            bottomFrame = bottomImageView.frame
        }
    }
    //MARK: Transmit parameter
    func prepareForImages(images: Array<String>, type: CarouselImageType){
        self.oriImages = images
        self.type = type;
        self.images = self.createImageNameArray(existImages:  images);
        self.setImageViewImage()
    }
    @objc func tapAction(ges: UITapGestureRecognizer){
        let image = self.images[0]
        var tempIndex = 0
        for (index,value) in self.oriImages.enumerated() {
            if image  == value {
                tempIndex = index;
                break;
            }
        }
        self.delegate?.customCarouselView?(self, didSelect: tempIndex, selectData: image as AnyObject)
    }
    //MARK: UIPanGestureRecognizer
    @objc func panAction(ges: UIPanGestureRecognizer){
        let point = ges.location(in: self)
        if ges.state == .began{
            self.startPoint = point
            self.timerStop()
        }else if ges.state == .changed{
            self.refresh = false
            self.moveImageViewByPanGes(startPoint: self.startPoint!, currentPoint: point)
        }else if ges.state == .ended{
            let xMoveDistance = point.x - startPoint!.x
            if (fabs(xMoveDistance) - self.bounds.size.width / 4) < 0{
                self.resetDefaultFrameWithAnimation()
            }else{
                self.moveImageViewWithAnimation()
            }
        }else if ges.state == .cancelled{
            self.resetDefaultFrameWithAnimation()
        }
    }
    private func moveImageViewByPanGes(startPoint: CGPoint, currentPoint: CGPoint){
        let xMoveDistance = currentPoint.x - startPoint.x
        var scale = fabs(xMoveDistance) / (self.topFrame.width / 3 * 2);
        if scale > 0.95 {
            scale = 0.95
        }
        let middleXMoveDistance = (self.middleFrame.origin.x - self.topFrame.origin.x)  * scale;
        let middleYMoveDistance = (self.middleFrame.origin.y - self.topFrame.origin.y) * scale;
        let bottomXMoveDistance = (self.bottomFrame.origin.x - self.middleFrame.origin.x) * scale
        topImageView.frame = CGRect(x: self.topFrame.origin.x + xMoveDistance, y: self.topFrame.origin.y, width: self.topFrame.width, height: self.topFrame.height)
        middleImageView.frame = CGRect(x: self.middleFrame.origin.x - middleXMoveDistance, y: self.middleFrame.origin.y - middleYMoveDistance, width: self.middleFrame.width + middleXMoveDistance * 2, height: self.middleFrame.height + middleYMoveDistance - bottomHeightMargin * scale);
        bottomImageView.frame = CGRect(x: self.bottomFrame.origin.x - bottomXMoveDistance, y: self.bottomFrame.origin.y - middleYMoveDistance, width: self.bottomFrame.width + bottomXMoveDistance * 2, height: self.bottomFrame.height + middleYMoveDistance - bottomHeightMargin * scale);
        
    }
    private func resetDefaultFrameWithAnimation(){
        UIView.animate(withDuration: 0.5, animations: {
            self.refresh = false
            self.topImageView.frame = self.topFrame
            self.middleImageView.frame = self.middleFrame
            self.bottomImageView.frame = self.bottomFrame
        }) { (success) in
            if success {
                self.refresh = true
                self.timerStart()
            }
        }
    }
    private func moveImageViewWithAnimation(){
        UIView.animate(withDuration: 0.5, animations: {
            self.refresh = false
            self.moveImageView(letf: self.topImageView.frame.origin.x < 0)
        }) { (success) in
            if success {
                self.resetImageViewFrame()
                self.topImageView.alpha = 1
                self.refresh = true
                self.timerStart()
            }
        }
    }
    private func moveImageView(letf: Bool){
        if letf {
            self.topImageView.frame = CGRect(x: -self.topFrame.size.width, y: self.topFrame.origin.y, width: self.topFrame.size.width, height: self.topFrame.size.height)
        }else{
            self.topImageView.frame = CGRect(x: self.topFrame.size.width * 2, y: self.topFrame.origin.y, width: self.topFrame.size.width, height: self.topFrame.size.height)
        }
        self.topImageView.alpha = 0
        self.middleImageView.frame = self.topFrame;
        self.bottomImageView.frame = self.middleFrame;
    }
    private func resetImageViewFrame(){
        self.removeFirstImageAndInsertLast()
        self.setImageViewImage()
        self.topImageView.frame = self.topFrame;
        self.middleImageView.frame = self.middleFrame;
        self.bottomImageView.frame = self.bottomFrame;
    }
    //MARK: Timer function
    @objc func timerAction(){
        print(self.count)
        UIView.animate(withDuration: 0.5, animations: {
            self.refresh = false
            self.moveImageView(letf: (self.count % 2 == 0))
        }) { (success) in
            if success {
                self.resetImageViewFrame()
                self.topImageView.alpha = 1
                self.count += 1
                if self.count == 10{
                    self.count = 0
                }
                self.refresh = true
            }
        }
    }
    private func timerStop(){
        timer?.invalidate()
        timer = nil;
    }
    private func timerStart(){
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true);
    }
    //MARK: Util function
    private func setImageViewImage(){
        if self.type == .local {
            topImageView.image = UIImage(named: self.images[0] )
            middleImageView.image = UIImage(named: self.images[1] )
            bottomImageView.image = UIImage(named: self.images[2] )
        }else{
            //TODO: download image from network
            topImageView.kf.setImage(with: URL(string: self.images[0]))
            middleImageView.kf.setImage(with: URL(string: self.images[1]))
            bottomImageView.kf.setImage(with: URL(string: self.images[2]))
        }
    }
    private func removeFirstImageAndInsertLast(){
        let firstImage = self.images.first;
        self.images.remove(at: 0)
        self.images.append(firstImage!)
    }
    private func createImageNameArray(existImages: Array<String>) -> Array<String>{
        var tempArray = Array<String>()
        if existImages.count >= 3 {
            tempArray = existImages;
        }else if existImages.count == 2{
            tempArray = existImages;
            tempArray.append(existImages.first!)
            tempArray.append(existImages.last!)
        }else if existImages.count == 1{
            tempArray = existImages;
            tempArray.append(existImages.first!)
            tempArray.append(existImages.first!)
        }
        return tempArray;
    }
}
