//
//  BCBackgroundExtractor.cpp
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/11/24.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#include "BCBackgroundExtractor.h"

#define POW(a) ( (a) * (a) )

using namespace cv;
using namespace backgroundExtractor;

BCBackgroundExtractor::BCBackgroundExtractor(Mat original)
:_original(original)
{
    CV_Assert(original.channels() == 4);
    this->setBGColor();
    _extracted = original.clone();
}

void BCBackgroundExtractor::setBGColor()
{
    // calc background mean
    bgColor[0] = bgColor[1] = bgColor[2] = 0.0;
    int bgPixels = 0;
    for (int h = 0; h < _original.rows; ++h) {
        uchar *buf = _original.ptr(h);
        for (int w = 0; w < _original.cols-1; ++w) {

            int idx = 4 * w;
            int idx_next = 4 * (w+1);

            if (buf[idx+3] == 0.0 && buf[idx_next+3] != 0.0) {
                bgColor[0] += buf[idx_next+0];
                bgColor[1] += buf[idx_next+1];
                bgColor[2] += buf[idx_next+2];
                bgPixels++;
            } else if (buf[idx+3] != 0.0 && buf[idx_next+3] == 0.0) {
                bgColor[0] += buf[idx+0];
                bgColor[1] += buf[idx+1];
                bgColor[2] += buf[idx+2];
                bgPixels++;
            }
        }
    }

    bgColor[0] /= (float)bgPixels;
    bgColor[1] /= (float)bgPixels;
    bgColor[2] /= (float)bgPixels;
    NSLog(@"%f, %f, %f", bgColor[0], bgColor[1], bgColor[2]);
}

cv::Mat BCBackgroundExtractor::extract(float norm)
{

    for (int h = 0; h < _extracted.rows; ++h) {
        uchar *buf = _extracted.ptr(h);
        uchar *buf_original = _original.ptr(h);
        for (int w = 0; w < _extracted.cols; ++w) {

            int idx = 4*w;

            float diff = POW(buf[idx+0] - bgColor[0])
                        + POW(buf[idx+1] - bgColor[1])
                        + POW(buf[idx+2] - bgColor[2]);
            diff /= 256.0 * 256.0;

            if (diff < norm) {
                buf[idx+0] = extractedColor[0];
                buf[idx+1] = extractedColor[1];
                buf[idx+2] = extractedColor[2];

            } else {
                buf[idx+0] = buf_original[idx+0];
                buf[idx+1] = buf_original[idx+1];
                buf[idx+2] = buf_original[idx+2];
            }

        }
    }

    return _extracted;
}

