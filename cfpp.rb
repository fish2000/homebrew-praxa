
class Cfpp < Formula
  homepage "https://github.com/macmade/CFPP"
  url "https://github.com/macmade/CFPP.git", :using => :git
  version "0.1.0"
  
  depends_on :xcode => :build
  
  def install
    xcodebuild 'SYMROOT=build',
               '-target', 'CF++ Example',
               '-scheme', 'CF++ Example'
    
    frameworks.install  'build/Debug/CF++.framework'
    lib.install         'build/Debug/libCF++.a'
    lib.install         'build/Debug/libCF++.dylib'
    bin.install         'build/Debug/CFPPExample'
    include.install Dir['build/Debug/usr/local/include/*.h']
  end
end

