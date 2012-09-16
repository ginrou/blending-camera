# Install script for directory: /Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc

# Set the install prefix
IF(NOT DEFINED CMAKE_INSTALL_PREFIX)
  SET(CMAKE_INSTALL_PREFIX "/Users/ginrou799/Development/iphone/BlendingCamera/ios/build/iPhoneOS/install")
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
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/OpenCV/doc" TYPE FILE FILES
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/haartraining.htm"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/check_docs_whitelist.txt"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/CMakeLists.txt"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/license.txt"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/packaging.txt"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/opencv.jpg"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/acircles_pattern.png"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/opencv-logo-white.png"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/opencv-logo.png"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/opencv-logo2.png"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/pattern.png"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/opencv2refman.pdf"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/opencv_cheatsheet.pdf"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/opencv_tutorials.pdf"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/opencv_user.pdf"
    )
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "main")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "main")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/OpenCV/doc/vidsurv" TYPE FILE FILES
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/vidsurv/Blob_Tracking_Modules.doc"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/vidsurv/Blob_Tracking_Tests.doc"
    "/Users/ginrou799/Development/iphone/BlendingCamera/opencv/doc/vidsurv/TestSeq.doc"
    )
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "main")

