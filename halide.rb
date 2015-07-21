
class Halide < Formula
  homepage "http://halide-lang.org/"
  url "https://github.com/halide/Halide/archive/release_2015_06_03.zip"
  version "0.12.0"
  sha256 "48379f783be6c563cc3e245e5508ea8f3a2c659c59087883f27fd1a361d493e6"
  #url "https://github.com/halide/Halide/archive/release_2015_04_22.zip"
  #version "0.11.0"
  #sha256 "403a8289c05295849f6b911945292e5d54ce8c82d9d2e8b9d2cbdbf71c4349a2"
  head "https://github.com/halide/Halide.git"
  
  devel do
    #sha256 "6d5a1624d2378415b7450208042812955a3a1909393c80811eab27b5cb8fd254"
    url "https://github.com/halide/Halide/archive/64802d53498c953acb41a31a5bd5ec2bc175cdcb.zip" # busted
    #url "https://github.com/halide/Halide/archive/a6bffdfb9cd143e83ef2e66353b9a29d7ec365ff.zip" # head
    #url "https://github.com/halide/Halide/archive/4ab5c13cb74fe1a7b8e999296aef49e2c2a15933.zip" # 'missing file'
    #url "https://github.com/halide/Halide/archive/a6942340e740b36a2fa85176e963be890cc6abb3.zip" # pretty old
    #url "https://github.com/halide/Halide/archive/master.zip"
    version "0.12.0"
  end
  
  option "with-opengl", "Enable OpenGL codepaths"
  option "with-opencl", "Enable OpenCL codepaths"
  
  option "without-extras", "Skip building tests, apps, and tutorial code"
  option "without-generator-tests", "Skip generator tests (see http://git.io/vvtMD)"
  
  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on :python => :recommended
  depends_on "swig" if build.with? :python
  depends_on "libpng" if build.with? :python
  depends_on "numpy" => :python if build.with? :python
  depends_on "PIL" => :python if build.with? :python
  
  patch :DATA if (build.with? :python and not build.head?)
  
  def install
    # Use brewed clang
    ENV['LLVM_CONFIG'] = Formula['llvm'].opt_prefix/"bin/llvm-config"
    ENV['CC'] = ENV['CLANG'] = Formula['llvm'].opt_prefix/"bin/clang"
    ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    
    ENV['CXX11'] = "1"
    ENV.cxx11
    # ENV.deparallelize
    
    # Extend cmake args
    cargs = std_cmake_args + %W[
      -DLLVM_BIN=#{Formula['llvm'].opt_prefix/"bin"}
      -DLLVM_INCLUDE=#{Formula['llvm'].opt_prefix/"include"}
      -DLLVM_LIB=#{Formula['llvm'].opt_prefix/"lib"}
      -DLLVM_VERSION=37
      -DTARGET_NATIVE_CLIENT=OFF
      -DTARGET_AARCH64=ON
      -DTARGET_ARM=ON
      -DTARGET_PTX=ON
      -DTARGET_X86=ON
      -DTARGET_OPENCL=#{build.with? "opencl" and "ON" or "OFF"}
      -DTARGET_OPENGL=#{build.with? "opengl" and "ON" or "OFF"}
      -DWITH_TUTORIALS=#{build.without? "extras" and "OFF" or "ON"}
      -DWITH_APPS=#{build.without? "extras" and "OFF" or "ON"}
    ]
    
    cargs.keep_if { |v| v !~ /DCMAKE_VERBOSE_MAKEFILE/ }
    
    sargs = cargs + %W[
      -DHALIDE_SHARED_LIBRARY=OFF
    ]
    
    dargs = cargs + %W[
      -DHALIDE_SHARED_LIBRARY=ON
    ]
    
    if build.without? "extras"
      inreplace "CMakeLists.txt", "add_subdirectory(test)", ""
      inreplace "CMakeLists.txt", "add_subdirectory(apps)", ""
      inreplace "CMakeLists.txt", "add_subdirectory(tutorial)", ""
    end
    
    if build.without? "generator-tests"
      sargs << "-DWITH_TEST_GENERATORS=OFF"
      dargs << "-DWITH_TEST_GENERATORS=OFF"
    end
    
    # build the library
    ohai "NOTE: There will likely be a long wait after executing cmake"
    mkdir "build-dynamic" do
      system "cmake", "..", *dargs
      system "make"
    end
    if not build.without? "extras"
      inreplace "CMakeLists.txt", "add_subdirectory(test)", ""
      inreplace "CMakeLists.txt", "add_subdirectory(apps)", ""
      inreplace "CMakeLists.txt", "add_subdirectory(tutorial)", ""
    end
    mkdir "build-static" do
      system "cmake", "..", *sargs
      system "make"
    end
    
    # Build python bindings
    if build.with? :python
      cd "python_bindings" do
        # Set things up
        ENV.prepend_create_path "PYTHONPATH", lib/"python2.7/site-packages"
        ENV['HALIDE_ROOT'] = buildpath
        ENV['HALIDE_BUILD_PATH'] = buildpath/"build-static"
        swig = Formula['swig'].opt_prefix/"bin/swig"
        
        # Run swig
        system swig, "-c++", "-python",
                     "-w362,325,314,389,381,382,361,401,503,509",
                     "-I#{buildpath}/build/include",
                     "halide/cHalide.i"
        
        # Build and install
        system "python", "setup.py", "build_ext"
        system "python", "setup.py", "install", "--prefix=#{prefix}"
      end
    end
    
    # There is no "make install" target, for some reason --
    # hence this DIY stuff here
    cd "build-static" do
      lib.install Dir["lib/*"]
    end
    cd "build-dynamic" do
      lib.install Dir["lib/*"]
      include.mkdir
      include.install Dir["include/*"]
      bin.mkdir
      bin.install "bin/bitcode2cpp"
      bin.install "bin/build_halide_h"
      if not build.without? "extras"
        (bin/"tests").mkdir
        (bin/"tests").install Dir["bin/correctness_*"]
        (bin/"tests").install Dir["bin/error_*"]
        (bin/"tests").install Dir["bin/exec_test_*"]
        (bin/"tests").install Dir["bin/generator_*"]
        (bin/"tests").install Dir["bin/opengl_*"]
        (bin/"tests").install Dir["bin/performance_*"]
        (bin/"tests").install Dir["bin/warning_*"]
      end
    end
    
  end

  test do
    if not build.without? "extras"
      ohai "Running correctness tests"
      Dir.glob('bin/correctness_*') do |test|
        ohai "Test: #{test}"
        system bin/test
      end
      ohai "Running error tests"
      Dir.glob('bin/error_*') do |test|
        ohai "Test: #{test}"
        system bin/test
      end
      ohai "Running exec tests"
      Dir.glob('bin/exec_test_*') do |test|
        ohai "Test: #{test}"
        system bin/test
      end
      ohai "Running generator tests"
      Dir.glob('bin/generator_*') do |test|
        ohai "Test: #{test}"
        system bin/test
      end
      ohai "Running OpenGL tests"
      Dir.glob('bin/opengl_*') do |test|
        ohai "Test: #{test}"
        system bin/test
      end
      ohai "Running performance tests"
      Dir.glob('bin/performance_*') do |test|
        ohai "Test: #{test}"
        system bin/test
      end
      ohai "Running warning tests"
      Dir.glob('bin/warning_*') do |test|
        ohai "Test: #{test}"
        system bin/test
      end
    end
  end
end

__END__
diff --git a/python_bindings/setup.py b/python_bindings/setup.py
index b7be7c4..5212776 100644
--- a/python_bindings/setup.py
+++ b/python_bindings/setup.py
@@ -1,6 +1,6 @@
 from distutils.core import setup
 from distutils.extension import Extension
-import os, os.path, sys
+import os, os.path
 import glob
 
 import subprocess
@@ -8,28 +8,28 @@ import shutil
 
 build_prefix = os.getenv('BUILD_PREFIX')
 if not build_prefix:
-    build_prefix = ''
-
-halide_root = os.getenv('HALIDE_ROOT')
+    build_prefix = 'build'
+    halide_root = os.getenv('HALIDE_ROOT')
 if not halide_root:
     halide_root = '..'
-include_path = os.path.join(halide_root, 'include')
-bin_path = os.path.join(halide_root, 'bin', build_prefix)
-bin_path = os.path.abspath(bin_path)
+include_path = os.path.join(halide_root, build_prefix, 'include')
+bin_path = os.path.abspath(os.path.join(halide_root, build_prefix, 'bin'))
+lib_path = os.path.abspath(os.path.join(halide_root, build_prefix, 'lib'))
 image_path = os.path.join(halide_root, 'apps', 'images')
 
 png_cflags  = subprocess.check_output('libpng-config --cflags',  shell=True).strip().decode()
 png_ldflags = subprocess.check_output('libpng-config --ldflags', shell=True).strip().decode()
 
-ext_modules = [Extension("halide/_cHalide", ["halide/cHalide_wrap.cxx", 'halide/py_util.cpp'],
-                         include_dirs=[include_path],
-                         extra_compile_args=('-ffast-math -O3 -msse -Wl,-dead_strip -fno-common' + ' ' + png_cflags).split() + ['-Wl,-rpath=%s' % bin_path],
-                         extra_link_args=[os.path.join(bin_path, 'libHalide.so'),
-                                          '-Wl,-rpath=%s' % bin_path,
-                                          '-ltinfo', '-lpthread',
-                                          '-ldl', '-lstdc++', '-lc'] + png_ldflags.split(),
-                         language='c++')]
-
+ext_modules = [Extension("halide/_cHalide",
+    ["halide/cHalide_wrap.cxx", 'halide/py_util.cpp'],
+        include_dirs=[include_path],
+        extra_compile_args=(
+            '-ffast-math -O3 -msse -std=c++11 -stdlib=libc++ -fno-common' + ' ' + png_cflags).split(),
+        extra_link_args=[os.path.join(lib_path, 'libHalide.dylib'),
+            '-lncurses', '-lpthread',
+            '-ldl', '-lc++', '-lc'] + png_ldflags.split(),
+        language='c++')]
+        
 if glob.glob('halide/data/*.png') == []:
     shutil.copytree(image_path, 'halide/data')
     
@@ -41,9 +41,7 @@ setup(
     classifiers=[
         "Topic :: Multimedia :: Graphics",
         "Programming Language :: Python :: 2.7"],
-    packages=['halide'],
-    package_dir={'halide': 'halide'},
-    package_data={'halide': ['data/*.png']},
-    ext_modules = ext_modules
-)
-
+        packages=['halide'],
+        package_dir={'halide': 'halide'},
+        package_data={'halide': ['data/*.png']},
+    ext_modules = ext_modules)
\ No newline at end of file
