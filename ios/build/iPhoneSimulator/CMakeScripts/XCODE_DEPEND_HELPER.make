# DO NOT EDIT
# This makefile makes sure all linkable targets are
# up-to-date with anything they link to
default:
	echo "Do not invoke directly"

# For each target create a dummy rule so the target does not have to exist


# Rules to remove targets that are older than anything to which they
# link.  This forces Xcode to relink the targets from scratch.  It
# does not seem to check these dependencies itself.
PostBuild.zlib.Debug:
PostBuild.opencv_core.Debug:
PostBuild.opencv_imgproc.Debug:
PostBuild.opencv_flann.Debug:
PostBuild.opencv_highgui.Debug:
PostBuild.opencv_features2d.Debug:
PostBuild.opencv_calib3d.Debug:
PostBuild.opencv_ml.Debug:
PostBuild.opencv_video.Debug:
PostBuild.opencv_objdetect.Debug:
PostBuild.opencv_contrib.Debug:
PostBuild.opencv_legacy.Debug:
PostBuild.opencv_nonfree.Debug:
PostBuild.opencv_photo.Debug:
PostBuild.opencv_stitching.Debug:
PostBuild.opencv_videostab.Debug:
PostBuild.opencv_world.Debug:
PostBuild.zlib.Release:
PostBuild.opencv_core.Release:
PostBuild.opencv_imgproc.Release:
PostBuild.opencv_flann.Release:
PostBuild.opencv_highgui.Release:
PostBuild.opencv_features2d.Release:
PostBuild.opencv_calib3d.Release:
PostBuild.opencv_ml.Release:
PostBuild.opencv_video.Release:
PostBuild.opencv_objdetect.Release:
PostBuild.opencv_contrib.Release:
PostBuild.opencv_legacy.Release:
PostBuild.opencv_nonfree.Release:
PostBuild.opencv_photo.Release:
PostBuild.opencv_stitching.Release:
PostBuild.opencv_videostab.Release:
PostBuild.opencv_world.Release:
