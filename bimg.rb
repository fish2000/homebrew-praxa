
class Bimg < Formula
  homepage "https://github.com/bkaradzic/bimg"
  head "https://github.com/bkaradzic/bimg.git", :using => :git
  
  depends_on "fish2000/praxa/bx"
  depends_on "make" => :build
  depends_on "lua"  => :build
  
  def install
    # Deparallelize
    ENV.deparallelize
    
    # Make target directories
    bin.mkdir
    lib.mkdir
    include.mkdir
    (include/"bimg").mkdir
    
    # Build project
    system "gmake", "osx"
    
    # Install include files
    (include/"bimg").install Dir["include/bimg/*"]
    
    # Copy build artifacts
    artifacts = buildpath/".build/osx64_clang/bin/"
    
    cp artifacts/"libbimgDebug.a",          lib/"libbimgDebug.a"
    cp artifacts/"libbimg_decodeDebug.a",   lib/"libbimg_decodeDebug.a"
    cp artifacts/"libbimg_encodeDebug.a",   lib/"libbimg_encodeDebug.a"
    cp artifacts/"libbxDebug.a",            lib/"libbxDebug.a"
    
    cp artifacts/"libbimgRelease.a",        lib/"libbimg.a"
    cp artifacts/"libbimg_decodeRelease.a", lib/"libbimg_decode.a"
    cp artifacts/"libbimg_encodeRelease.a", lib/"libbimg_encode.a"
    cp artifacts/"libbxRelease.a",          lib/"libbx.a"
    
    cp artifacts/"texturecDebug",           bin/"texturecDebug"
    cp artifacts/"texturecRelease",         bin/"texturec"
  end
end

