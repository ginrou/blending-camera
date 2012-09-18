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

private:
  Vector<KeyPoint> kpt;
  int height;
  int width;
  Mat fund_mat;

};


int main(int argc, char* argv[] ){

  Mat left = imread( argv[1], 0 );
  Mat right = imread( argv[2], 0 );
  Stereo *stereo = new Stereo( &left, &right );

  stereo->find_and_match_key_points();

  return 0;

}


Stereo::Stereo( Mat *left, Mat *right ) {
  leftImage = left->clone();
  rightImage = right->clone();
  
  printf("size of left = %d, %d\n", leftImage.rows, leftImage.cols);
  printf("size of right = %d, %d\n", rightImage.rows, rightImage.cols);

}

void Stereo::find_and_match_key_points() {

  //StarFeatureDetector detector;
  Ptr<FeatureDetector> detector = FeatureDetector::create("FAST");
  vector<KeyPoint> kptLeft, kptRight;
  detector->detect(leftImage, kptLeft);
  detector->detect(rightImage, kptRight);

  


}
