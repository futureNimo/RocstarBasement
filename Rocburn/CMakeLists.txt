cmake_minimum_required (VERSION 2.8)
project(Rocburn)
enable_language(C CXX Fortran)
load_cache(../)
set (ROCSTAR TRUE CACHE BOOL "Build as Rocstar Module")
IF(NOT ENABLE_MPI)
  add_definitions( -DDUMMY_MPI )
ELSE()
  FIND_PACKAGE(MPI REQUIRED)
  add_definitions( -DMPICH_IGNORE_CXX_SEEK -DMPI)
#  IF(MPI_CXX_COMPILER)
#    set (CMAKE_CXX_COMPILER ${MPI_CXX_COMPILER})
#  ENDIF(MPI_CXX_COMPILER)
ENDIF()
find_library(HDF4_LIB df HINTS /usr/lib/hdf /usr/lib64/hdf)
find_library(MFHDF_LIB mfhdf HINTS /usr/lib/hdf /usr/lib64/hdf)
find_library(ZLIB z)
find_library(JPEG_LIB jpeg)
find_path(HDF4_INC hdf.h HINTS /usr/include/hdf)
find_library(BLOCKSOLVE_LIBRARY blocksolve95)
find_path(BLOCKSOLVE_INC blocksolve95.h)
find_library(METIS_LIB metis)
find_path(METIS_INC metis.h)

#INCLUDE(CTest)
find_path(ROCCOM_INC roccom.h HINTS ../../Roccom/include) 
find_path(ROCMAN_INC rocman.h HINTS ../../Rocman/include)

FILE (GLOB CORE_SRCS ./*.f90)
FILE (GLOB APN_SRCS  ./Rocburn_APN/*.f90)
FILE (GLOB ZN_SRCS   ./Rocburn_ZN/*.f90)
FILE (GLOB PY9_SRCS  ./Rocburn_PY/*.f90)
FILE (GLOB PYF_SRCS  ./Rocburn_PY/*.f)
SET(LIB_SRCS ${CORE_SRCS} ${APN_SRCS} ${ZN_SRCS} ${PY9_SRCS} ${PYF_SRCS})
SET(ALL_SRCS ${LIB_SRCS})
set_source_files_properties(${ALL_SRCS} PROPERTIES COMPILE_FLAGS "-fPIC" )
#set(TEST_SRCS src/MANTest.C)

# rpath settings
SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

include_directories(${ROCCOM_INC} ${ROCMAN_INC} ${HDF4_INC} ${METIS_INC})
add_definitions(-DUSE_HDF=1)

IF(NOT BUILD_STATIC)
  add_library(Rocburn SHARED ${LIB_SRCS})
ELSE()
  add_library(Rocburn STATIC ${LIB_SRCS})
  add_definitions( -DSTATIC_LINK )
ENDIF()
target_link_libraries(Rocburn Rocout Rocin Roccomf Roccom)

INSTALL(TARGETS Rocburn RUNTIME DESTINATION bin LIBRARY DESTINATION lib ARCHIVE DESTINATION lib)
