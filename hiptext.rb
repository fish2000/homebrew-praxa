
class Hiptext < Formula
  desc "Turn images into text better than caca/aalib"
  homepage "https://github.com/fish2000/hiptext"
  url "https://github.com/fish2000/hiptext/archive/0.5.0.zip"
  sha256 "8f704b1e4ba8e641a8b31ec669d6802c5819d04a952db8e078d0c0de6e27a89d"
  head "https://github.com/fish2000/hiptext.git", :using => :git
  
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
    ENV.cxx11
    cargs = std_cmake_args
    cargs.keep_if { |v| v !~ /DCMAKE_VERBOSE_MAKEFILE/ }
    
    mkdir "build" do
      system "cmake", "..", *cargs
      system "make", "install"
    end
    
  end
end

