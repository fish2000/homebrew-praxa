
class Iod < Formula
  homepage "https://github.com/matt-42/iod"
  head "https://github.com/matt-42/iod.git", :using => :git

  depends_on "cmake" => :build
  depends_on "boost"
  #depends_on "opencv"
  #depends_on "eigen"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
    # link symbol-generator script
  end
end
