
class BoostNumpy < Formula
  homepage "https://github.com/ndarray/Boost.NumPy"
  url "https://github.com/ndarray/Boost.NumPy/archive/master.zip"
  head "https://github.com/ndarray/Boost.NumPy.git",
    :using => :git
  version "0.5.0"
  
  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "boost-python"
  cxxstdlib_check :skip
  
  def install
    
    ENV['BOOST_ROOT'] = ENV['BOOST_DIR'] = Formula['boost'].opt_prefix
    ENV.cxx11
    
    cargs = std_cmake_args + %W[
      -DBoost_NO_BOOST_CMAKE=ON
    ]
    cargs.keep_if { |v| v !~ /DCMAKE_VERBOSE_MAKEFILE/ }
    
    mkdir "build" do
      system "cmake", "..", *cargs
      system "make", "install"
    end
    
  end
end
