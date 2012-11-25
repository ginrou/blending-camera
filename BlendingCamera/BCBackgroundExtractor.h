//
//  BCBackgroundExtractor.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/11/24.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#ifndef __BlendingCamera__BCBackgroundExtractor__
#define __BlendingCamera__BCBackgroundExtractor__

#include <iostream>
#include <opencv2/opencv.hpp>

namespace backgroundExtractor{

    static const float extractedColor[] = {147, 20, 255};

    class BCBackgroundExtractor
    {
    private:
        cv::Mat _original, _extracted;
        void setBGColor();

    public:
        float bgColor[3];

        BCBackgroundExtractor(){};
        BCBackgroundExtractor(cv::Mat original);
        ~BCBackgroundExtractor(){
            _original.release();
        };
        void setImage(cv::Mat original) {
            CV_Assert(original.channels() == 4);
            _original = cv::Mat(original);
            this->setBGColor();
            _extracted = original.clone();
        };

        cv::Mat extract(float norm); // 各画素がnormとどれだけ離れているかを渡して、背景を除去した画像を返す
    };
}
#endif /* defined(__BlendingCamera__BCBackgroundExtractor__) */
