
class Halide < Formula
  homepage "http://halide-lang.org/"
  head "https://github.com/halide/Halide.git"
  url "https://github.com/halide/Halide/archive/release_2015_12_17.tar.gz"
  sha256 "8c9150fb04531fff02ae15138f9365fe2f5aafbf679ed28913d2192794bafb05"
  version "0.15.0"
  
  devel do
    url "https://github.com/halide/Halide/archive/64802d53498c953acb41a31a5bd5ec2bc175cdcb.zip" # busted
    #url "https://github.com/halide/Halide/archive/a6bffdfb9cd143e83ef2e66353b9a29d7ec365ff.zip" # head
    #url "https://github.com/halide/Halide/archive/4ab5c13cb74fe1a7b8e999296aef49e2c2a15933.zip" # 'missing file'
    #url "https://github.com/halide/Halide/archive/a6942340e740b36a2fa85176e963be890cc6abb3.zip" # pretty old
    version "0.15.0"
  end
  
  option "with-metal", "Enable Apple Metal codepaths"
  option "with-opencl", "Enable OpenCL codepaths"
  option "with-opengl", "Enable OpenGL/ES codepaths"
  option "with-opengl-compute", "Enable OpenGL Compute codepaths"
  
  option "without-extras", "Skip building tests, apps, and tutorial code"
  option "without-generator-tests", "Skip generator tests (see http://git.io/vvtMD)"
  
  depends_on "cmake"  => :build
  depends_on "llvm"   => :build
  depends_on :python3 => :recommended
  depends_on "libpng"             if build.with? :python3
  # depends_on "numpy"  => :python3 if build.with? :python3
  # depends_on "PIL"    => :python3 if build.with? :python3
  depends_on :x11
  
  patch :DATA if (build.with? :python3 and not build.head?)
  
  def install
    # Use brewed clang
    llvm = Formula['llvm'].opt_prefix
    ENV['LLVM_CONFIG'] = llvm/"bin/llvm-config"
    ENV['CC'] = ENV['CLANG'] = ENV['CXX'] = llvm/"bin/clang"
    ENV['CXX'] += "++"
    ENV['CXX11'] = "1"
    ENV.cxx11
    
    # Get LLVM version "MAJOR.MINOR.PATCH" and reduce it
    # to just "MAJORMINOR" e.g. "3.8.0svn" becomes "38"
    # ... as this format is expected by Halide's CMakeLists.txt
    llvm_version = %x[#{ENV['LLVM_CONFIG']} --version]
    llvm_version_short = llvm_version.gsub(/.(\w+)$/, "").gsub(/[.\n\s]+/m, "")
    
    # Extend cmake args
    cargs = std_cmake_args + %W[
      -DLLVM_BIN=#{llvm/"bin"}
      -DLLVM_INCLUDE=#{llvm/"include"}
      -DLLVM_LIB=#{llvm/"lib"}
      -DLLVM_VERSION=#{llvm_version_short}
      -DTARGET_NATIVE_CLIENT=OFF
      -DTARGET_AARCH64=ON
      -DTARGET_ARM=ON
      -DTARGET_METAL=#{build.with? "metal" and "ON" or "OFF"}
      -DTARGET_MIPS=ON
      -DTARGET_PTX=ON
      -DTARGET_X86=ON
      -DTARGET_OPENCL=#{build.with? "opencl" and "ON" or "OFF"}
      -DTARGET_OPENGL=#{build.with? "opengl" and "ON" or "OFF"}
      -DTARGET_OPENGLCOMPUTE=#{build.with? "opengl-compute" and "ON" or "OFF"}
      -DWITH_TUTORIALS=#{build.without? "extras" and "OFF" or "ON"}
      -DWITH_APPS=#{build.without? "extras" and "OFF" or "ON"}
      -DWITH_UTILS=#{build.without? "extras" and "OFF" or "ON"}
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
    if build.with? :python3
      cd "python_bindings" do
        # Set things up
        ENV.prepend_create_path "PYTHONPATH", lib/"python3.5/site-packages"
        ENV['HALIDE_ROOT'] = buildpath
        ENV['HALIDE_BUILD_PATH'] = buildpath/"build-static"
        
        # Build and install
        # system "python", "setup.py", "build_ext"
        # system "python", "setup.py", "install", "--prefix=#{prefix}"
        pcargs = std_cmake_args
        pcargs.keep_if { |v| v !~ /DCMAKE_VERBOSE_MAKEFILE/ }
        
        mkdir "build" do
          system "cmake", "..", *pcargs
          system "make"
        end
        
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
        bin.install "bin/HalideTraceViz"
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
