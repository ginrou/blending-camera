//
//  Blender.h
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/19.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#ifndef __BlendingCamera__Blender__
#define __BlendingCamera__Blender__

#include <iostream>
#include <map>

#include <opencv2/opencv.hpp>

#include "Eigen/Core"
#define EIGEN_YES_I_KNOW_SPARSE_MODULE_IS_NOT_STABLE_YET
#include "Eigen/Sparse"
#include "Eigen/SparseCholesky"

namespace Blend {
	class PoissonBlender
	{
	private:
		cv::Mat _src, _target, _mask;
		cv::Rect mask_roi1;
		cv::Mat mask1;
		cv::Mat dst1;
		cv::Mat target1;
		cv::Mat drvxy;
		
		int ch;
		
		std::map<int,int> mp;

		template <typename T>
		bool buildMatrix(Eigen::SparseMatrix<T> &A, Eigen::Matrix<T, Eigen::Dynamic, 1> &b,
						 Eigen::Matrix<T, Eigen::Dynamic, 1> &u);
		template <typename T>
		bool solve(const Eigen::SparseMatrix<T> &A, const Eigen::Matrix<T, Eigen::Dynamic, 1> &b,
				   Eigen::Matrix<T, Eigen::Dynamic, 1> &u);
		template <typename T>
		bool copyResult(Eigen::Matrix<T, Eigen::Dynamic, 1> &u);
	public:
		PoissonBlender();
		PoissonBlender(const cv::Mat &src, const cv::Mat &target, const cv::Mat &mask);
		~PoissonBlender() {};
		bool setImages(const cv::Mat &src, const cv::Mat &target, const cv::Mat &mask);
		void copyTo(PoissonBlender &b) const;
		PoissonBlender clone() const;
		bool seamlessClone(cv::Mat &dst, int offx, int offy, bool mix);
	};
}

#endif /* defined(__BlendingCamera__Blender__) */
