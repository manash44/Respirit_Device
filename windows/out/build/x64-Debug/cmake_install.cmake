# Install script for directory: C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Debug")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/build/x64-Debug/flutter/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/build/x64-Debug/runner/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/build/x64-Debug/plugins/flutter_libserialport/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/build/x64-Debug/plugins/printing/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/build/x64-Debug/plugins/share_plus/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/build/x64-Debug/plugins/url_launcher_windows/cmake_install.cmake")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug/respiritdeviceapp.exe")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug" TYPE EXECUTABLE FILES "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/build/x64-Debug/runner/respiritdeviceapp.exe")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug/data/icudtl.dat")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug/data" TYPE FILE FILES "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/flutter/ephemeral/icudtl.dat")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug/flutter_windows.dll")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug" TYPE FILE FILES "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/flutter/ephemeral/flutter_windows.dll")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug/flutter_libserialport_plugin.dll;C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug/serialport.dll;C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug/printing_plugin.dll;C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug/pdfium.dll;C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug/share_plus_plugin.dll;C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug/url_launcher_windows_plugin.dll")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug" TYPE FILE FILES
    "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/build/x64-Debug/plugins/flutter_libserialport/flutter_libserialport_plugin.dll"
    "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/build/x64-Debug/plugins/flutter_libserialport/libserialport/serialport.dll"
    "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/build/x64-Debug/plugins/printing/printing_plugin.dll"
    "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/build/x64-Debug/pdfium-src/bin/pdfium.dll"
    "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/build/x64-Debug/plugins/share_plus/share_plus_plugin.dll"
    "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/build/x64-Debug/plugins/url_launcher_windows/url_launcher_windows_plugin.dll"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug/")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug" TYPE DIRECTORY FILES "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/build/native_assets/windows/")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  
  file(REMOVE_RECURSE "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug/data/flutter_assets")
  
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug/data/flutter_assets")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug/data" TYPE DIRECTORY FILES "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/build//flutter_assets")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee]|[Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug/data/app.so")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/install/x64-Debug/data" TYPE FILE FILES "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/build/windows/app.so")
  endif()
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/build/x64-Debug/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
if(CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_COMPONENT MATCHES "^[a-zA-Z0-9_.+-]+$")
    set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
  else()
    string(MD5 CMAKE_INST_COMP_HASH "${CMAKE_INSTALL_COMPONENT}")
    set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INST_COMP_HASH}.txt")
    unset(CMAKE_INST_COMP_HASH)
  endif()
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "C:/Users/Manas/Documents/Arduino/Respirit_Device_app/respiritdeviceapp/windows/out/build/x64-Debug/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
