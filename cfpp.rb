
class Cfpp < Formula
  homepage "https://github.com/macmade/CFPP"
  url "https://github.com/macmade/CFPP.git", :using => :git
  version "0.2.0"
  
  depends_on :xcode => :build
  depends_on "git" => :build
  
  def install
    system 'git',
           'submodule', 'update', '--init'
    
    # xcodebuild 'SYMROOT=build',
    #            '-configuration',  'Release',
    #            '-target',         'CF++ Mac Framework (C++11)',
    #            '-scheme',         'CF++ Mac Framework (C++11)'
    #
    # xcodebuild 'SYMROOT=build',
    #            '-configuration',  'Release',
    #            '-target',         'CF++ Mac Static Library (C++11)',
    #            '-scheme',         'CF++ Mac Static Library (C++11)'
    #
    # xcodebuild 'SYMROOT=build',
    #            '-configuration',  'Release',
    #            '-target',         'CF++ Mac Dynamic Library (C++11)',
    #            '-scheme',         'CF++ Mac Dynamic Library (C++11)'
    
    xcodebuild 'SYMROOT=build',
               '-configuration',  'Release',
               '-target',         'CF++ (C++11)',
               '-scheme',         'CF++ (C++11)'
    
    # bin.install       'build/Release/Unit-Tests' <=== errors out
    frameworks.install  'build/Release/CF++.framework'
    lib.install         'build/Release/libCF++.a'
    lib.install         'build/Release/libCF++.dylib'
    include.install Dir['build/Release/usr/local/include/*.hpp']
  end
end

