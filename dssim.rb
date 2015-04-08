
class Dssim < Formula
  homepage "http://pornel.net/dssim"
  head "https://github.com/pornel/dssim.git", :using => :git
  
  depends_on "pkg-config" => :build
  depends_on "libpng" => :recommended
  
  def install
    if build.without? "libpng"
      ENV['USE_COCOA'] = 1
    end
    system "make"
    bin.install Dir[buildpath/"bin/*"]
  end
end

