
class Itktools < Formula
  homepage "https://github.com/ITKTools/ITKTools"
  url "https://github.com/ITKTools/ITKTools.git", :using => :git
  version "0.8.0"
  
  depends_on "cmake"          =>  :build
  depends_on "insighttoolkit"
  
  def install
    ENV.cxx11
    
    cargs = std_cmake_args
    cargs.keep_if { |v| v !~ /DCMAKE_VERBOSE_MAKEFILE/ }
    
    mkdir "build" do
      system "cmake", "../src", *cargs
      system "make", "install"
    end
    
  end # install
  
end
