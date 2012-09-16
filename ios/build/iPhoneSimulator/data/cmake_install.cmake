# Install script for directory: /Users/ginrou799/Development/iphone/BlendingCamera/opencv/data

# Set the install prefix
IF(NOT DEFINED CMAKE_INSTALL_PREFIX)
  SET(CMAKE_INSTALL_PREFIX "/Users/ginrou799/Development/iphone/BlendingCamera/ios/build/iPhoneSimulator/install")
ENDIF(NOT DEFINED CMAKE_INSTALL_PREFIX)
STRING(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
IF(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  IF(BUILD_TYPE)
    STRING(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  ELSE(BUILD_TYPE)
    SET(CMAKE_INSTALL_CONFIG_NAME "Release")
  ENDIF(BUILD_TYPE)
  MESSAGE(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
ENDIF(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)

# Set the component getting installed.
IF(NOT CMAKE_INSTALL_COMPONENT)
  IF(COMPONENT)
    MESSAGE(STATUS "Install component: \"${COMPONENT}\"")
    SET(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  ELSE(COMPONENT)
    SET(CMAKE_INSTALL_COMPONENT)
  ENDIF(COMPONENT)
ENDIF(NOT CMAKE_INSTALL_COMPONENT)

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "main")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/OpenCV/haarcascades" TYPE FILE FILES
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_eye.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_eye_tree_eyeglasses.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_frontalface_alt.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_frontalface_alt2.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_frontalface_alt_tree.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_frontalface_default.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_fullbody.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_lefteye_2splits.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_lowerbody.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_mcs_eyepair_big.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_mcs_eyepair_small.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_mcs_leftear.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_mcs_lefteye.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_mcs_mouth.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_mcs_nose.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_mcs_rightear.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_mcs_righteye.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_mcs_upperbody.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_profileface.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_righteye_2splits.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/haarcascades/haarcascade_upperbody.xml"
    )
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "main")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "main")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/OpenCV/lbpcascades" TYPE FILE FILES
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/lbpcascades/lbpcascade_frontalface.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/lbpcascades/lbpcascade_profileface.xml"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/data/lbpcascades/lbpcascade_silverware.xml"
    )
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "main")

