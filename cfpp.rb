
class Cfpp < Formula
  homepage "https://github.com/macmade/CFPP"
  # head "https://github.com/macmade/CFPP.git", :using => :git
  # url "https://github.com/macmade/CFPP/archive/0.1.6.zip"
  # sha256 "882500a4c2ea6189448e64df49633e41d17be0c84f04af0067f51cf6816f568a"
  url "https://github.com/macmade/CFPP.git", :using => :git
  version "0.1.6"
  
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
    
    # bin.install                'build/Release/Unit-Tests' <=== errors out
    
    frameworks.install           'build/Release/CF++.framework'
    lib.install                  'build/Release/libCF++.a'
    lib.install                  'build/Release/libCF++.dylib'
    include.install              'build/Release/usr/local/include/CF++.hpp'
    
    (include/"CF++").mkdir
    (include/"CF++").install Dir['build/Release/usr/local/include/CFPP*.hpp']
    
  end
end

