
class Sprout < Formula
  homepage "https://github.com/bolero-MURAKAMI/Sprout"
  head "https://github.com/bolero-MURAKAMI/Sprout.git", :using => :git
  url "https://github.com/bolero-MURAKAMI/Sprout/archive/844e8a1fc29ab72e27b5165f92c0762177afd096.zip"
  sha256 "d541986992638a5f2b1b1d84fe1ec6562b25f38c4e90dfb1df9e5abd9628a27f"
  version "0.1.0"
  
  option "without-cxx11", "Build without C++11 support"
  
  depends_on "llvm"  => [:build, :optional]
  depends_on "cmake" =>  :build
  depends_on "opencv"
  
  # WHY DOESNT THIS PATCH WORK I ASK YOU.
  # patch :p0, :DATA
  
  def install
    if build.with? "llvm"
      # Use brewed clang
      ENV['CC'] = Formula['llvm'].opt_prefix/"bin/clang"
      ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    end
    if not build.without? "cxx11"
      ENV.cxx11
      inreplace "CMakeLists.txt", "-std=c++0x",
                                  "-std=c++14 -stdlib=libc++ -fconstexpr-steps=9999999"
    end
    
    cargs = std_cmake_args
    cargs.keep_if { |v| v !~ /DCMAKE_VERBOSE_MAKEFILE/ }
    
    mkdir "build" do
      system "cmake", "..", *cargs
      system "make", "install"
    end
    
  end
end

__END__
diff --git CMakeLists.txt CMakeLists.txt
index 2653d45..4f10f0c 100644
--- CMakeLists.txt
+++ CMakeLists.txt
@@ -10,13 +10,13 @@ include(CheckCXXSourceCompiles)
 
 # build type
 set(CMAKE_BUILD_TYPE Debug)
 
 
-set(CMAKE_CXX_FLAGS_DEBUG "-W -Wall -Wextra -Wno-unused-parameter -Werror -std=c++0x -O0 -g")
+set(CMAKE_CXX_FLAGS_DEBUG "-W -Wall -Wextra -Wno-unused-parameter -Werror -std=c++14 -stdlib=libc++ -fconstexpr-steps=9999999 -O0 -g")
 set(CMAKE_C_FLAGS_DEBUG "-W -Wall -Wextra -Wno-unused-parameter -Werror -O0 -g")
-set(CMAKE_CXX_FLAGS_RELEASE "-W -Wall -Wextra -Wno-unused-parameter -Werror -std=c++0x -O2")
+set(CMAKE_CXX_FLAGS_RELEASE "-W -Wall -Wextra -Wno-unused-parameter -Werror -std=c++14 -stdlib=libc++ -fconstexpr-steps=9999999 -O2")
 set(CMAKE_C_FLAGS_RELEASE "-W -Wall -Wextra -Wno-unused-parameter -Werror -O2")
 
 #if you don't want the full compiler output, remove the following line
 if( NOT DEFINED CMAKE_VERBOSE_MAKEFILE )
   set(CMAKE_VERBOSE_MAKEFILE OFF)
@@ -29,11 +29,16 @@ endif( NOT DEFINED Boost_USE_MULTITHREADED )
 find_package( Boost 1.49.0 REQUIRED )
 if( NOT Boost_FOUND )
   message( SEND_ERROR "Required package Boost was not detected." )
 endif (NOT Boost_FOUND)
 
+find_package( OpenGL REQUIRED )
+if( NOT OPENGL_FOUND )
+  message( SEND_ERROR "Required package OpenGL was not detected." )
+endif (NOT Boost_FOUND)
+
 pkg_check_modules(OpenCV opencv)
 
-INCLUDE_DIRECTORIES( ${CMAKE_CURRENT_SOURCE_DIR} ${Boost_INCLUDE_DIRS} )
-link_directories( ${Boost_LIBRARY_DIRS} )
+INCLUDE_DIRECTORIES( ${CMAKE_CURRENT_SOURCE_DIR} ${Boost_INCLUDE_DIRS} ${OPENGL_INCLUDE_DIR} )
+link_directories( ${Boost_LIBRARY_DIRS} ${OPENGL_LIBRARIES} )
 subdirs( sprout libs tools cmake )
 
