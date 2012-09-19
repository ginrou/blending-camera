#include <iostream>
#include <string>

#include <cv.h>
#include <highgui.h>

using namespace std;
using namespace cv;

class Stereo {
public:
  Mat leftImage;
  Mat rightImage;
  Mat disparityMap;

  // constructor
  Stereo( Mat *left, Mat *right);
  
  // methods
  void find_and_match_key_points();
  void compute_fundamental_mat();
  void compute_stereo_correspondence();

  //private:
  vector<DMatch> matches;
  vector<KeyPoint> kpt_left;
  vector<KeyPoint> kpt_right;
  int height;
  int width;
  Mat fund_mat;

};

void printMat( Mat m );

int main(int argc, char* argv[] ){

  Mat left = imread( argv[1], 0 );
  Mat right = imread( argv[2], 0 );
  Stereo *stereo = new Stereo( &left, &right );

  stereo->find_and_match_key_points();
  // vector<DMatch> matches = stereo->matches;
  // for( int i = 0; i < matches.size(); ++i ){
  //   Point2f pt_left = stereo->kpt_left[matches[i].queryIdx].pt;
  //   Point2f pt_right = stereo->kpt_right[matches[i].trainIdx].pt;
  //   printf("%.1f, %.1f  --> %.1f, %.1f\n", pt_left.x, pt_left.y, pt_right.x, pt_right.y);
  // }

  stereo->compute_fundamental_mat();

  return 0;

}


Stereo::Stereo( Mat *left, Mat *right ) {
  leftImage = left->clone();
  rightImage = right->clone();
  
  printf("size of left = %d, %d\n", leftImage.rows, leftImage.cols);
  printf("size of right = %d, %d\n", rightImage.rows, rightImage.cols);

}

void Stereo::find_and_match_key_points() {

  GoodFeaturesToTrackDetector detector(200, 0.25, 1, 4, true, 0.1);
  detector.detect(leftImage, kpt_left);
  detector.detect(rightImage, kpt_right);
  printf("extraction done %zd, %zd\n", kpt_left.size(), kpt_right.size());

  // computing descriptors
  Ptr<DescriptorExtractor> extractor = DescriptorExtractor::create("BRIEF");
  Mat descriptorLeft, descriptorRight;
  extractor->compute(leftImage, kpt_left, descriptorLeft);
  extractor->compute(rightImage, kpt_right, descriptorRight);
  printf("computing descriptors done\n");

  // matching descripors
  Ptr<DescriptorMatcher> matcher = DescriptorMatcher::create("BruteForce");
  matcher->match( descriptorLeft, descriptorRight, matches );
  printf("matching done\n");

  Mat img_matches;
  drawMatches( leftImage, kpt_left, rightImage, kpt_right, matches, img_matches);
  imwrite( "mathes.png", img_matches);

}


void Stereo::compute_fundamental_mat() {
  
  vector<Point2f> ptLeft, ptRight;
  for( int i = 0; i < matches.size(); ++i ){
    ptLeft.push_back( kpt_left[matches[i].queryIdx].pt );
    ptRight.push_back( kpt_right[matches[i].trainIdx].pt );
  }

  fund_mat = findFundamentalMat( ptLeft, ptRight, FM_RANSAC, 3.0, 0.99, noArray() );
  
  Size sz( leftImage.rows, leftImage.cols );
  Mat h_left, h_right;
  stereoRectifyUncalibrated( ptLeft, ptRight, fund_mat, sz, h_left, h_right, 5.0);

  printf("left\n");
  printMat( h_left );
  printf("right\n");
  printMat( h_right );

}


void printMat( Mat m ){
    for( int h = 0; h < m.rows; ++h ){
      for( int w = 0; w < m.cols; ++w ){
	printf("\t%e", m.at<double>(h, w) );
      }
      printf("\n");
    }
}
