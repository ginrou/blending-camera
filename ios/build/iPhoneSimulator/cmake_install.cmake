# Install script for directory: /Users/ginrou799/Development/iphone/BlendingCamera/opencv

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
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/opencv2" TYPE FILE FILES "/Users/ginrou799/Development/iphone/BlendingCamera/ios/build/iPhoneSimulator/opencv2/opencv_modules.hpp")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "main")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig" TYPE FILE FILES "/Users/ginrou799/Development/iphone/BlendingCamera/ios/build/iPhoneSimulator/unix-install/opencv.pc")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/OpenCV" TYPE FILE FILES "/Users/ginrou799/Development/iphone/BlendingCamera/ios/build/iPhoneSimulator/unix-install/OpenCVConfig.cmake")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/OpenCV" TYPE FILE FILES "/Users/ginrou799/Development/iphone/BlendingCamera/ios/build/iPhoneSimulator/unix-install/OpenCVConfig-version.cmake")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")

IF(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  INCLUDE("/Users/ginrou799/Development/iphone/BlendingCamera/ios/build/iPhoneSimulator/3rdparty/zlib/cmake_install.cmake")
  INCLUDE("/Users/ginrou799/Development/iphone/BlendingCamera/ios/build/iPhoneSimulator/include/cmake_install.cmake")
  INCLUDE("/Users/ginrou799/Development/iphone/BlendingCamera/ios/build/iPhoneSimulator/modules/cmake_install.cmake")
  INCLUDE("/Users/ginrou799/Development/iphone/BlendingCamera/ios/build/iPhoneSimulator/doc/cmake_install.cmake")
  INCLUDE("/Users/ginrou799/Development/iphone/BlendingCamera/ios/build/iPhoneSimulator/data/cmake_install.cmake")
  INCLUDE("/Users/ginrou799/Development/iphone/BlendingCamera/ios/build/iPhoneSimulator/apps/cmake_install.cmake")

ENDIF(NOT CMAKE_INSTALL_LOCAL_ONLY)

IF(CMAKE_INSTALL_COMPONENT)
  SET(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
ELSE(CMAKE_INSTALL_COMPONENT)
  SET(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
ENDIF(CMAKE_INSTALL_COMPONENT)

FILE(WRITE "/Users/ginrou799/Development/iphone/BlendingCamera/ios/build/iPhoneSimulator/${CMAKE_INSTALL_MANIFEST}" "")
FOREACH(file ${CMAKE_INSTALL_MANIFEST_FILES})
  FILE(APPEND "/Users/ginrou799/Development/iphone/BlendingCamera/ios/build/iPhoneSimulator/${CMAKE_INSTALL_MANIFEST}" "${file}\n")
ENDFOREACH(file)
