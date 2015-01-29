
class Dige < Formula
  homepage "https://github.com/matt-42/dige"
  head "https://github.com/matt-42/dige.git", :using => :git

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "ffmpeg"
  depends_on "qt"
  
  depends_on "olena" => :optional

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
