
class Echelon < Formula
  desc "Modern C++11 wrappers for HDF5"
  homepage "https://github.com/qbb-project/echelon"
  head "https://github.com/qbb-project/echelon.git"
  url "https://github.com/qbb-project/echelon/archive/v0.7.0.tar.gz"
  version "0.7.0"
  sha256 "b34b6aa39defc39eb5e6faa85cb4ad2733230907ae1440e3a45372b7408d23f7"

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "hdf5"
  depends_on "boost"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end
  
end
