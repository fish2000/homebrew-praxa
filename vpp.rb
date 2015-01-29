
class Vpp < Formula
  homepage "https://github.com/matt-42/vpp"
  head "https://github.com/matt-42/vpp.git", :using => :git

  depends_on "cmake" => :build
  depends_on "fish2000/brew/iod"
  depends_on "fish2000/brew/dige"
  depends_on "opencv"
  depends_on "eigen"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
