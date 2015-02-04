
class Dige < Formula
  homepage "https://github.com/matt-42/dige"
  url "https://github.com/matt-42/dige/archive/master.zip"
  sha1 "a6acf5863768e26f900f1dc33194942c5dd37ff1"
  version "0.1.0"
  head "https://github.com/matt-42/dige.git", :using => :git
  
  option "with-examples", "Build examples"
  #option "with-tests", "Build and run tests"
  
  depends_on "cmake"  => :build
  depends_on "llvm"   => :build
  depends_on "ffmpeg" => :recommended
  depends_on "olena"  => :optional
  depends_on "boost"
  depends_on "qt"
  
  patch :DATA
  
  def install
    # Use brewed clang
    ENV['CC'] = Formula['llvm'].opt_prefix/"bin/clang"
    ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    
    # modify the args
    cargs = std_cmake_args
    cargs << "-DWITH_FFMPEG=#{build.with? 'ffmpeg' and "ON" or "OFF"}"
    cargs << "-DCMAKE_INSTALL_PREFIX=#{prefix}"
    
    # build static
    ohai "Building static library..."
    mkdir "build-static" do
      system "cmake", "..", *cargs
      system "make"
      system "make", "install"
    end
    rm_rf "build-static"
    
    # build dynamic
    ohai "Building dynamic library..."
    cargs << "-DBUILD_SHARED_LIBS:BOOL=ON"
    cargs << "-DCMAKE_MACOSX_RPATH=#{lib}"
    mkdir "build-dynamic" do
      system "cmake", "..", *cargs
      system "make"
      system "make", "install"
    end
    rm_rf "build-dynamic"
    
    # examples: cmakify all the things, recursively
    # N.B. Only 'hello world seems to work; I do not
    # currently recommend this
    if build.with? "examples"
      # customize cmake args
      ex_cmake_args = [
        "-DCMAKE_INSTALL_PREFIX=#{share}/examples",
        "-DCMAKE_BUILD_TYPE=None",
        "-DCMAKE_FIND_FRAMEWORK=LAST",
        "-DCMAKE_VERBOSE_MAKEFILE=#{ARGV.verbose? and "ON" or "OFF"}",
        "-Wno-dev"]
      
      cd "examples" do
        exdir = Dir.pwd
        Dir.foreach(exdir) do |example|
          next if example == '.' \
               or example == '..' \
               or example == 'rgb_image.h' \
               or example == 'random' \
               or example == 'record_random' \
               or example == 'events'
          cd example do
            mkdir "build" do
              system "cmake", exdir+"/"+example, *ex_cmake_args
              system "make"
              (share/"examples").install example
            end
          end
        end
      end
    end
    
  end
end

__END__
From eb1876c90719c7050ed2c76c3ebded47b940e5ce Mon Sep 17 00:00:00 2001
From: =?UTF-8?q?Alexander=20Bo=CC=88hn?= <fish2000@gmail.com>
Date: Wed, 4 Feb 2015 15:32:18 -0500
Subject: [PATCH] Updates

---
 CMakeLists.txt          | 18 ++++++++++++++----
 dige/abstract_texture.h |  2 +-
 dige/error.h            |  2 +-
 dige/internal_texture.h |  2 +-
 dige/is_texture_type.h  |  2 +-
 dige/texture.h          |  2 +-
 6 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/CMakeLists.txt b/CMakeLists.txt
index db3b8fe..c7db306 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -9,13 +9,19 @@ find_package(Boost REQUIRED)
 
 include(${QT_USE_FILE})
 
-SET(CMAKE_VERBOSE_MAKEFILE off)
+SET(CMAKE_VERBOSE_MAKEFILE on)
 
 include_directories(${CMAKE_CURRENT_SOURCE_DIR}
-                    $ENV{HOME}/local/include
-                    ${Boost_INCLUDE_DIRS})
+                    /usr/local/include
+                    ${Boost_INCLUDE_DIRS}
+                ${Qt4_INCLUDE_DIRS})
 
-link_directories($ENV{HOME}/local/lib)
+link_directories(/usr/local/lib)
+
+IF(APPLE)
+    find_library(OPENGL_LIBRARY OpenGL)
+    mark_as_advanced(OPENGL_LIBRARY)
+ENDIF(APPLE)
 
 IF(EXISTS $ENV{INSTALL_PREFIX})
   set(CMAKE_INSTALL_PREFIX $ENV{INSTALL_PREFIX} CACHE PATH "Install prefix")
@@ -78,6 +84,10 @@ add_library(dige
   dige/panzoom_control.cpp
   ${RECORDING_SRC})
 
+IF(BUILD_SHARED_LIBS)
+    target_link_libraries(dige swscale avformat avcodec avutil ${QT_LIBRARIES} ${OPENGL_LIBRARY})
+ENDIF(BUILD_SHARED_LIBS)
+
 install(TARGETS dige DESTINATION lib/)
 install(TARGETS dige DESTINATION lib/Debug CONFIGURATIONS Debug)
 install(TARGETS dige DESTINATION lib/Release CONFIGURATIONS Release)
diff --git a/dige/abstract_texture.h b/dige/abstract_texture.h
index 3eef9c1..6b7a76c 100644
--- a/dige/abstract_texture.h
+++ b/dige/abstract_texture.h
@@ -32,7 +32,7 @@
 #  include <windows.h>
 # endif
 
-# include <GL/gl.h>
+# include <OpenGL/gl.h>
 
 namespace dg
 {
diff --git a/dige/error.h b/dige/error.h
index 8d4f772..b51f4ee 100644
--- a/dige/error.h
+++ b/dige/error.h
@@ -29,7 +29,7 @@
 # define DIGE_ERROR
 
 # include <iostream>
-# include <GL/glu.h>
+# include <OpenGL/glu.h>
 
 namespace dg
 {
diff --git a/dige/internal_texture.h b/dige/internal_texture.h
index 46a7aba..42570c3 100644
--- a/dige/internal_texture.h
+++ b/dige/internal_texture.h
@@ -33,7 +33,7 @@
 #  include <windows.h>
 # endif
 
-# include <GL/gl.h>
+# include <OpenGL/gl.h>
 
 # include <dige/abstract_texture.h>
 
diff --git a/dige/is_texture_type.h b/dige/is_texture_type.h
index 3e8ae31..11ea543 100644
--- a/dige/is_texture_type.h
+++ b/dige/is_texture_type.h
@@ -28,7 +28,7 @@
 #ifndef DIGE_IS_TEXTURE_TYPE
 # define DIGE_IS_TEXTURE_TYPE
 
-# include <GL/glu.h>
+# include <OpenGL/glu.h>
 
 namespace dg
 {
diff --git a/dige/texture.h b/dige/texture.h
index 5d77b8c..2a034f4 100644
--- a/dige/texture.h
+++ b/dige/texture.h
@@ -32,7 +32,7 @@
 #  include <windows.h>
 # endif
 
-# include <GL/gl.h>
+# include <OpenGL/gl.h>
 
 namespace dg
 {
-- 
2.2.2


