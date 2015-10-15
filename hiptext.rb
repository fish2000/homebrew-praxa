
class Hiptext < Formula
  desc "Turn images into text better than caca/aalib"
  homepage "https://github.com/fish2000/hiptext"
  url "https://github.com/fish2000/hiptext/archive/0.1.0.zip"
  sha256 "bfabc8db7c2c60f56e59e64c588c48cf1d7f4a15f7bab9f4ef75ea95be65bd14"
  head "https://github.com/fish2000/hiptext.git", :using => :git
  
  # depends_on "llvm" => :build
  depends_on "cmake" => :build
  depends_on "ragel"  => :build
  depends_on "gflags"
  depends_on "glog"

  depends_on "ffmpeg" => :recommended
  depends_on "freetype" => :recommended
  depends_on "libpng"
  depends_on "jpeg"
  depends_on "zlib"
  
  def install
    # Use brewed clang
    # ENV['CC'] = Formula['llvm'].opt_prefix/"bin/clang"
    # ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    ENV.cxx11
    
    cargs = std_cmake_args
    cargs.keep_if { |v| v !~ /DCMAKE_VERBOSE_MAKEFILE/ }
    
    mkdir "build" do
      system "cmake", "..", *cargs
      system "make", "install"
    end
    
  end
end

