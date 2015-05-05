
class Fatal < Formula
  fatal_version = "0.1.0"
  # gtest_version = "1.7.0"
  
  homepage "https://github.com/facebook/fatal"
  head "https://github.com/facebook/fatal.git", :using => :git
  url "https://github.com/facebook/fatal/archive/22ca8f1807e69ca90938cf293bde2117f2295ced.zip"
  version fatal_version
  
  devel do
    url "https://github.com/facebook/fatal/archive/dev.zip"
    version fatal_version
  end
  
  # Homebrew gives you a curtly twatty message about how it's totally over
  # people who think it's cool to instal gtest systemwide, so we're doing
  # this to not have to listen to that type of shit right now goddamnit
  # resource "gtest" do
  #   url "https://googletest.googlecode.com/files/gtest-#{gtest_version}.zip"
  #   sha256 "247ca18dd83f53deb1328be17e4b1be31514cedfc1e3424f672bf11fd7e0d60d"
  # end
  
  # Tests need this stuff in theory; we are not actually
  # doing any of that yet tho
  # depends_on "folly"    => :recommended
  # depends_on "gflags"   => :recommended
  # depends_on "glog"     => :recommended
  
  def install
    # Just copy it over for now -- it's header-only
    # and building (demos|tests|benchmarks) requires libfolly
    include.mkdir
    (include/"fatal").mkdir
    (include/"fatal").install Dir["fatal/*"]
  end
end

