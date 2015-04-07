
class Xcm < Formula
  homepage "https://github.com/oyranos-cms/xcm"
  head "https://github.com/oyranos-cms/xcm.git", :using => :git
  
  depends_on :x11
  depends_on "fish2000/praxa/libxcm"
  
  def install
    system "./configure", "--prefix=#{prefix}", "--with-x11"
    system "make"
    system "make install"
  end
end

