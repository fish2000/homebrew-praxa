
class Bx < Formula
  homepage "https://github.com/bkaradzic/bx"
  head "https://github.com/bkaradzic/bx.git", :using => :git
  
  depends_on "make" => :build
  depends_on "lua"  => :build
  
  def install
    # Deparallelize
    ENV.deparallelize
    
    # Make target directories
    bin.mkdir
    lib.mkdir
    include.mkdir
    (include/"bx").mkdir
    (include/"compat").mkdir
    (include/"tinystl").mkdir
    
    # Copy include files
    (include/"bx").install      Dir["include/bx/*"]
    (include/"compat").install  Dir["include/compat/*"]
    (include/"tinystl").install Dir["include/tinystl/*"]
    
    # Build project
    system "gmake", "test", "tools"
    
    # Copy build artifacts
    artifacts = buildpath/".build/osx64_clang/bin/"
    cp artifacts/"bin2cRelease",    bin/"bin2c"
    cp artifacts/"libbxRelease.a",  lib/"libbxRelease.a"
    cp artifacts/"libbxRelease.a",  lib/"libbx.a"
  end
end

