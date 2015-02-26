
class Syphon < Formula
  homepage "https://github.com/Syphon/Syphon-Framework"
  url "https://github.com/Syphon/Syphon-Framework.git", :using => :git
  version "0.1.0"
  
  option "with-docs", "Build documentation (seems error-prone)"
  
  depends_on :xcode => :build
  depends_on "doxygen" if build.with? "docs"
  
  def install
    if build.with? "docs"
      ENV['DOXYGEN_PATH'] = Formula['doxygen'].opt_prefix/"bin/doxygen"
      ENV['DOXYGEN_PATH'] << " -u" # 'upgrade' the doxygen config files, in place
    end
    xcodebuild 'SDKROOT=', 'SYMROOT=build'
    frameworks.install 'build/Release/Syphon.framework'
    prefix.install "Syphon SDK Read Me.rtf"
  end
end

