
class Bazel < Formula
  desc "Scalable build system"
  homepage "http://bazel.io/"
  url "https://github.com/bazelbuild/bazel/releases/download/0.1.0/bazel-0.1.0-installer-darwin-x86_64.sh",
      :using => :nounzip
  version "0.1.1"
  sha256 "df24443c1d1c2361684f7e59550a7da8d89f496c36af88b0aa4f3b4935114231"
  
  depends_on :xcode
  depends_on :java => "1.8"

  def install
    system "chmod", "+x", "./bazel-0.1.0-installer-darwin-x86_64.sh"
    system "./bazel-0.1.0-installer-darwin-x86_64.sh",
           "--prefix=#{prefix}",
           "--bazelrc=#{ENV['HOME']}/.bazelrc"
  end
  
  def test
    system "bazel"
  end

end
