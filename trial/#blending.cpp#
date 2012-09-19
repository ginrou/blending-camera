#include <cv.h>
#include <highgui.h>

#include <iostream>
#include "Eigen/Dense"


#include "poissonBlending2.hpp"

using namespace std;


void show_usage()
{
  std::cout << "./pb source_image target_image mask_image offset_x offset_y mix" << std::endl;
}
 
int main(int argc, char* argv[])
{
  if(argc < 7) {
    show_usage();
    return -1;
  }
  std::string src_file = argv[1];
  std::string target_file = argv[2];
  std::string mask_file = argv[3];
  int offx = atoi(argv[4]);
  int offy = atoi(argv[5]);
  bool mix = (argv[6]=="true" || atoi(argv[6])>0) ? true : false;
 
  cv::Mat src_img = cv::imread(src_file, 1);
  if(!src_img.data) return -1;
   
  cv::Mat target_img = cv::imread(target_file, 1);
  if(!target_img.data) return -1;
 
  cv::Mat mask_img = cv::imread(mask_file, 0);
  if(mask_img.empty()) return -1;
 
  Blend::PoissonBlender pb = Blend::PoissonBlender(src_img, target_img, mask_img);
   
  cv::Mat dst_img;
  double f = 1000.0/cv::getTickFrequency();
  int64 time = cv::getTickCount();
  pb.seamlessClone(dst_img, offx, offy, mix);
  std::cout<<(cv::getTickCount()-time)*f<<" [ms]"<<std::endl;
  cv::imwrite("test.png", dst_img);
 
  return 0;
}
