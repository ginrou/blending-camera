//
//  Blender.cpp
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/19.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#include "Blender.h"

using namespace Blend;
using namespace cv;

PoissonBlender::PoissonBlender(){}

void PoissonBlender::copyTo(PoissonBlender &b) const
{
	b.setImages(_src, _target, _mask);
}

inline PoissonBlender PoissonBlender::clone() const
{
	PoissonBlender b;
	copyTo(b);
	return b;
}

PoissonBlender::PoissonBlender(const cv::Mat &src,
							   const cv::Mat &target,
							   const cv::Mat &mask)
: _src(src), _target(target), _mask(mask)
{
	CV_Assert(_mask.channels()==1);
	CV_Assert(_src.cols==_mask.cols && _src.rows==_mask.rows);
}

// set source, tareget and destination images
bool PoissonBlender::setImages(const cv::Mat &src, const cv::Mat &target, const cv::Mat &mask=cv::Mat())
{
	_src = src;
	_target = target;
	_mask = mask;
	
	CV_Assert(_mask.channels()==1);
	CV_Assert(_src.cols==_mask.cols && _src.rows==_mask.rows);
	
	return true;
}

// solver sparse linear system
template <typename T>
bool PoissonBlender::solve(const Eigen::SparseMatrix<T> &A, const Eigen::Matrix<T, Eigen::Dynamic, 1> &b,
                           Eigen::Matrix<T, Eigen::Dynamic, 1> &u)
{
	Eigen::SimplicialLDLT<Eigen::SparseMatrix<T> > lldt_of_A(A);
	u = lldt_of_A.solve(b);	
	return true;
}

// build matrix as linear system
template <typename T>
bool PoissonBlender::buildMatrix(Eigen::SparseMatrix<T> &A, Eigen::Matrix<T, Eigen::Dynamic,1> &b,
                                 Eigen::Matrix<T, Eigen::Dynamic, 1> &u)
{
	int w = mask_roi1.width;
	int h = mask_roi1.height;
	int nz=0;
	for(int y=0; y<h-1; ++y) {
		uchar *p = mask1.ptr(y);
		for(int x=0; x<w-1; ++x, ++p) {
			if(*p==0) continue;
			
			int idx = y*(w*ch)+(x*ch);
			mp[idx] = nz++;   // r
			mp[++idx] = nz++; // g
			mp[++idx] = nz++; // b
		}
	}
	
	A = Eigen::SparseMatrix<double>(nz, nz);
	b = Eigen::VectorXd(nz);
	u = Eigen::VectorXd(nz);
	int rowA = 0;
	
	A.reserve(5*nz);
	for(int y=1; y<h-1; ++y) {
		uchar *p = mask1.ptr(y)+1;
		cv::Vec3d *drv = drvxy.ptr<cv::Vec3d>(y)+1;
		for(int x=1; x<w-1; ++x, ++p, ++drv) {
			if(*p==0) continue;
			
			int idx = y*(w*ch)+(x*ch);
			int tidx=idx-ch*w, lidx=idx-ch, ridx=idx+ch, bidx=idx+ch*w;
			
			// to omtimize insertion
			uchar tlrb = 15; // 0b1111
			if(mask1.at<uchar>(y-1,x)==0) {
				*drv -= target1.at<cv::Vec3b>(y-1,x);
				tlrb &= 7; //0b0111
			}
			if(mask1.at<uchar>(y,x-1)==0) {
				*drv -= target1.at<cv::Vec3b>(y,x-1);
				tlrb &= 11; //0b1011
			}
			if(mask1.at<uchar>(y,x+1)==0) {
				*drv -= target1.at<cv::Vec3b>(y,x+1);
				tlrb &= 13; //0b1101
			}
			if(mask1.at<uchar>(y+1,x)==0) {
				*drv -= target1.at<cv::Vec3b>(y+1,x);
				tlrb &= 14; //0b1110
			}
			for(int k=0; k<ch; ++k) {
				A.startVec(rowA+k);
				if(tlrb&8) A.insertBack(mp[tidx+k], rowA+k) = 1.0; // top
				if(tlrb&4) A.insertBack(mp[lidx+k], rowA+k) = 1.0; // left
				A.insertBack(mp[idx  +k], rowA+k) = -4.0;// center
				if(tlrb&2) A.insertBack(mp[ridx+k], rowA+k) = 1.0; // right
				if(tlrb&1) A.insertBack(mp[bidx+k], rowA+k) = 1.0; // bottom
			}
			b(rowA+0) = cv::saturate_cast<double>((*drv)[0]);
			b(rowA+1) = cv::saturate_cast<double>((*drv)[1]);
			b(rowA+2) = cv::saturate_cast<double>((*drv)[2]);
			rowA+=ch;
		}
	}
	A.finalize();
	CV_Assert(nz==rowA);
	
	return true;
}

template <typename T>
bool PoissonBlender::copyResult(Eigen::Matrix<T, Eigen::Dynamic, 1> &u)
{
	int w = mask_roi1.width;
	int h = mask_roi1.height;
	for(int y=1; y<h-1; ++y) {
		uchar *pd = dst1.ptr(y);
		uchar *pm = mask1.ptr(y)+1;
		for(int x=1; x<w-1; ++x, ++pm) {
			if(*pm==0) {
				pd += 3;
			} else {
				int idx = mp[y*(w*ch)+(x*ch)];
				*pd++ = cv::saturate_cast<uchar>(u[idx+0]);
				*pd++ = cv::saturate_cast<uchar>(u[idx+1]);
				*pd++ = cv::saturate_cast<uchar>(u[idx+2]);
			}
		}
	}
	
	return true;
}

bool
PoissonBlender::seamlessClone(cv::Mat &_dst, const int offx, const int offy, const bool mix=false)
{
	// crop images;
    cv::Scalar scalar(0);
    if (offx < 0) { // 左過ぎ
        Range x_range(-offx, _mask.cols-1), y_range(0, _mask.rows-1);
        Mat maskCropped = _mask( y_range, x_range);
        Mat srcCropped = _src( y_range, x_range);
        _mask.release();
        _src.release();
        cv::copyMakeBorder(maskCropped, _mask, 0, 0, 1, 0, cv::BORDER_CONSTANT, scalar);
        cv::copyMakeBorder(srcCropped, _src, 0, 0, 1, 0, cv::BORDER_REPLICATE);
    }

    if (offy < 0) { // 上過ぎ
        Range x_range(0, _mask.cols-1), y_range(-offy, _mask.rows-1);
        Mat maskCropped = _mask( y_range, x_range);
        Mat srcCropped = _src( y_range, x_range);
        _mask.release();
        _src.release();
        cv::copyMakeBorder(maskCropped, _mask, 1, 0, 0, 0, cv::BORDER_CONSTANT, scalar);
        cv::copyMakeBorder(srcCropped, _src, 1, 0, 0, 0, cv::BORDER_REPLICATE);
    }

    if (offx + _mask.cols >= _target.cols) { // 右過ぎ
        Range x_range(0, _target.cols - offx ), y_range(0, _mask.rows);
        Mat maskCropped = _mask( y_range, x_range);
        Mat srcCropped = _src( y_range, x_range);
        _mask.release();
        _src.release();
        cv::copyMakeBorder(maskCropped, _mask, 0, 0, 0, 1, cv::BORDER_CONSTANT, scalar);
        cv::copyMakeBorder(srcCropped, _src, 0, 0, 0, 1, cv::BORDER_REPLICATE);
    }

    if (offy + _mask.rows >= _target.rows) { // 下過ぎ
        Range x_range(0, _mask.cols), y_range(0, _target.rows - offy );
        Mat maskCropped = _mask( y_range, x_range);
        Mat srcCropped = _src( y_range, x_range);
        _mask.release();
        _src.release();
        cv::copyMakeBorder(maskCropped, _mask, 0, 1, 0, 0, cv::BORDER_CONSTANT, scalar);
        cv::copyMakeBorder(srcCropped, _src, 0, 1, 0, 0, cv::BORDER_REPLICATE);
    }


	//
	ch = _target.channels();
	cv::Point offset(offx, offy);
	cv::Point tl(_mask.size()), br(-1,-1);
	
	// calc bounding box
	for(int y=0; y<_mask.rows; ++y) {
		uchar *p = _mask.ptr(y);
		for(int x=0; x<_mask.cols; ++x,++p) {
			if(*p==0) continue;
			if(tl.x>x) tl.x=x;
			if(tl.y>y) tl.y=y;
			if(br.x<x) br.x=x;
			if(br.y<y) br.y=y;
		}
	}
	br.x += 1;
	br.y += 1;
	
	// add borders
	cv::Rect mask_roi(tl, br);
	cv::Rect mask_roi2(tl-cv::Point(2,2), br+cv::Point(2,2));
	cv::Mat _srcUp, _targetUp, _maskUp, _dstUp;
	cv::copyMakeBorder(_src, _srcUp, 2,2,2,2, cv::BORDER_REPLICATE);
	cv::copyMakeBorder(_target, _targetUp, 2,2,2,2, cv::BORDER_REPLICATE);
	cv::copyMakeBorder(_mask, _maskUp, 1,1,1,1, cv::BORDER_CONSTANT);
	
	// allocate destination image
	_dstUp = _targetUp.clone();
	_dst = cv::Mat(_dstUp, cv::Rect(2,2,_dstUp.cols-2, _dstUp.rows-2));
	
	mask_roi1 = cv::Rect(tl-cv::Point(1,1), br+cv::Point(1,1));
	mask1 = cv::Mat(_mask, mask_roi1);
	target1 = cv::Mat(_targetUp, mask_roi1+offset-cv::Point(1,1));
	dst1 = cv::Mat(_dstUp, mask_roi1+offset-cv::Point(1,1));
	
	cv::Mat src(_srcUp, mask_roi2);
	cv::Mat target(_targetUp, mask_roi2+offset-cv::Point(2,2));
	cv::Mat mask(_mask, mask_roi2);
	cv::Mat dst(_dstUp, mask_roi2+offset-cv::Point(2,2));
	CV_Assert(src.cols==dst.cols && src.rows==dst.rows);
	
	// calc differential image
	cv::Mat src64, target64;
	int pw = mask_roi2.width-1, ph = mask_roi2.height-1;
	src.convertTo(src64, CV_64F);
	target.convertTo(target64, CV_64F);
	cv::Rect roi00(0,0,pw,ph), roi10(1,0,pw,ph), roi01(0,1,pw,ph);
	cv::Mat _src64_00(src64, roi00), _target64_00(target64, roi00);
	cv::Mat src_dx = cv::Mat(src64, roi10) - _src64_00;
	cv::Mat src_dy = cv::Mat(src64, roi01) - _src64_00;
	cv::Mat target_dx = cv::Mat(target64,roi10) - _target64_00;
	cv::Mat target_dy = cv::Mat(target64,roi01) - _target64_00;
	
	// gradient mixture
	cv::Mat Dx;
	cv::Mat Dy;
	if(mix) {   // with gradient mixture
		cv::Mat pdx_src[3], pdy_src[3], pdx_target[3], pdy_target[3];
		cv::split(src_dx, pdx_src);
		cv::split(src_dy, pdy_src);
		cv::split(target_dx, pdx_target);
		cv::split(target_dy, pdy_target);
		
		cv::Mat _masks_dx, _masks_dy;
		for(int i=0; i<ch; i++) {
			_masks_dx = cv::abs(pdx_src[i]) < cv::abs(pdx_target[i]);
			_masks_dy = cv::abs(pdy_src[i]) < cv::abs(pdy_target[i]);
			pdx_target[i].copyTo(pdx_src[i], _masks_dx);
			pdy_target[i].copyTo(pdy_src[i], _masks_dy);
		}
		cv::merge(pdx_src, ch, Dx);
		cv::merge(pdy_src, ch, Dy);
	} else {   // without gradient mixture
		Dx = src_dx;
		Dy = src_dy;
	}
	
	// lapilacian
	int w = pw-1, h = ph-1;
	drvxy = cv::Mat(Dx,cv::Rect(1,0,w,h)) - cv::Mat(Dx,cv::Rect(0,0,w,h))
    + cv::Mat(Dy,cv::Rect(0,1,w,h)) - cv::Mat(Dy,cv::Rect(0,0,w,h));
	
	//
	// solve an poisson's equation
	//
	
	Eigen::SparseMatrix<double> A;
	Eigen::VectorXd b;
	Eigen::VectorXd u;
	
	// build right-hand and left-hand matrix
	buildMatrix<double>(A, b, u);
	
	// solve sparse linear system
	solve<double>(A, b, u);
	
	// copy computed result to destination image
	copyResult<double>(u);
	
	return true;
}








