
class Folly < Formula
  ENV['FOLLY_VERSION'] = "0.1.0"
  ENV['GTEST_VERSION'] = "1.7.0"
  
  homepage "https://github.com/facebook/folly"
  head "https://github.com/facebook/folly.git", :using => :git
  url "https://github.com/facebook/folly/archive/a1119563e2ab8d6cde6e6aca480c1a38cfa11707.zip"
  version ENV['FOLLY_VERSION']
  
  devel do
    url "https://github.com/facebook/folly/archive/master.zip"
    version ENV['FOLLY_VERSION']
  end
  
  # The 'double-conversion' library needs to be fucked with a little,
  # it would appear (see conflicts_with note below)
  resource "double-conversion" do
    url "https://github.com/floitsch/double-conversion/archive/851a80b83d9b44a270844cf4e4c5ae63ec4ad741.zip"
    sha256 "6ca6ed1d195fec1d364fa72aa9b37cf885fa9094538adf870b2c840f8efaa27f"
  end
  
  # Homebrew gives you a curtly twatty message about how it's totally over
  # people who think it's cool to instal gtest systemwide, so we're doing
  # this to not have to listen to that type of shit right now goddamnit
  resource "gtest" do
    url "https://googletest.googlecode.com/files/gtest-#{ENV['GTEST_VERSION']}.zip"
    sha256 "247ca18dd83f53deb1328be17e4b1be31514cedfc1e3424f672bf11fd7e0d60d"
  end
  
  # Build necessities (double-conversion is the scons freak, specifically)
  depends_on "llvm"     => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool"  => :build
  depends_on "scons"    => :build
  
  depends_on "libevent"
  depends_on "jemalloc" => :recommended
  depends_on "snappy"   => :recommended
  
  depends_on "xz"
  depends_on "gflags"
  depends_on "glog"
  depends_on "boost"
  
  conflicts_with "double-conversion",
     :because => <<-EOS.undent
      The homebrew master-branch formula for double-conversion
      is apparently waaaay to normal and well-adjusted in the eyes
      of the beautiful and unique millenial snowflake that facebook
      hired to write its FLOSS build scripts:
       
           https://github.com/facebook/folly/blob/a1119563e2ab8d6cde6e6aca480c1a38cfa11707/folly/bootstrap-osx-homebrew.sh#L18-L34
      
      Or whatever… Feel free to contribute PRs to this formula with
      explinations of why they, the FB team of Fatal snowflake hackers,
      thought that their embarrasingly janky bootstrap bash script was
      preferable to writing an actual fucking Homebrew formula. I really
      don't get it. And look: I have written some extremely dumb-ass things
      all throughout my programming career. Most people would temporally
      qualify that statement with a restriction such as "back in the day";
      I am not saying that; for example LAST WEEK I thought calling a python
      script that generated CMake submodules from the parent CMake module
      itself was "definitely a great idea."
      
          https://github.com/fish2000/little-acorn/commit/46b9b463cd28e73270daae735240fc818b3e7d97
      
      See yeah, OK. That was dumb, but at least it was relateably dumb, in that
      it was an attempt to solve a fucking problem. It was dumb like Romeo and Juliet:
      tragic, entertaining in life but also in death, and we all learned something
      from its failure. This stupid script is mysteriously dumb; it is clearly
      a problem itself -- AND ALSO, it was created with effort that could have been
      so easily redirected in a productive way. It is a creation without empathy,
      it is a tincture of dumb with a drop of the blank anodyne taste of sociopathic
      fear -- you immediately know you are reading a program by someone who broke his
      neighbor's dog's neck in order to resolve an intermittent loud-barking issue.
      If it were human, this program would eat popcorn after it shot you to watch you die.
      It is dumb without fear, logic, understanding, or morality -- is the the dumb of
      Paul Blart: Mall Cop II.
      
          http://redlettermedia.com/half-in-the-bag-unfriended-and-paul-blart-mall-cop-2/
      
      See but so I am stepping up and writing this formula because actually it is
      UNBELIEVABLY FUCKING EASY to do so. It's like practically the same code,
      in fact the resulting file is actually SHORTER IN LENGTH and arguably SIMPLER,
      all while being less subject to breaking after the next OS update for no reason.
      Plus the formula then gets maintained by OTHER FUCKING PEOPLE, who have somehow
      tricked a whole slew of beta-nerds into COMPETING for the honor of doing all the
      trivial shit that the FATAL Mac OS build systems' maintenence requires, meeting
      pretty high standards of craftmanship while accepting autonomous responsibility
      for this work as well as for *whatever* the snowflakes deem push-worthy --
      which all of this is delivered voluntarily and expediently, ultimately costing
      Facebook neither money nor precious-snowflake cognitive load.
      
          https://github.com/Homebrew/homebrew/pull/39210
      
      But that ship has sailed -- now that I am putting this up, it's
      one of the excuses the increacingly overworked Homebrew maintainers need
      if they want to avoid accepting a new formula (spolers: they do) and
      since I am one guy who is doing this on a whim, with negligible knowledge and no
      interest in the Ruby language and no real incentive to formulate this shit
      according to any sort of reputable coding standards -- having chosen "get shit to work,
      once or twice, on the one computer I have and use" as my big goal here.
      
          https://github.com/fish2000/homebrew-praxa/commits/master
      
      THINK ABOUT THAT FACEBOOK. DONT MAKE THINGS LIKE THIS SO WEIRD DOGG
     EOS
  
  # Our Darwin timers have no clock to clean -- we patch to fix compile errors
  # on missing linuxy function sigs like `clock_gettime()` and friends.
  # ... the patch itself was copypasta'd from here:
  #    https://github.com/facebook/folly/issues/170
  patch :p1, :DATA
  
  def install
    # C++ Of The Future Past
    ENV.cxx11
    
    # Where to put our vendor shit? Here is where:
    dc = buildpath/"double-conversion"
    dcsrc = dc/"src"
    tt = buildpath/"folly/test/gtest-#{ENV['GTEST_VERSION']}"
    
    # Vend in double-conversion
    mkdir dc do
      # Stage double-conversion repo into our subdirectory and symlink
      resource("double-conversion").stage { dc.install Dir["*"] }
      cd dcsrc do
        ln_s Dir.pwd, dcsrc/"double-conversion"
      end
      
      # Run the actual build command
      system "scons"
      
      # Get rid of dylib(s), which evidently is some sort of scam
      # we have to run on libtool (?!) at least according to this:
      # https://github.com/facebook/folly/blob/master/folly/bootstrap-osx-homebrew.sh#L29-L31
      rm_f Dir["libdouble-conversion*dylib"]
      ENV["DOUBLE_CONVERSION_HOME=#{Dir.pwd}"]
      ENV.append "CFLAGS",     "-I#{Dir.pwd}/src"
      ENV.append "CXXFLAGS",   "-I#{Dir.pwd}/src"
      ENV.append "CPPFLAGS",   "-I#{Dir.pwd}/src"
      ENV.append "LDFLAGS",    "-L#{Dir.pwd}"
    end
    
    # Use brewed clang for folly
    ENV['CC']  =  Formula['llvm'].opt_prefix/"bin/clang"
    ENV['CXX'] =  Formula['llvm'].opt_prefix/"bin/clang++"
    
    cd "folly" do
      # autotools that shit (folly itself)
      system "autoreconf", "-i"
      system "./configure",
             "--prefix=#{prefix}",
             "--disable-dependency-tracking"
      
      # Plug gtest in, vendorstyle, to <buildpath>/folly/test
      mkdir tt do
        rm_rf "src" # WHAT THE HELL IS THIS MARCY
        resource("gtest").stage { tt.install Dir["./*"] }
        system "./configure",
               "--prefix=#{prefix}",
               "--disable-dependency-tracking"
        system "make"
      end
      
      # D'BUGG
      # system "open", tt
      
      # MAKING IT ALL UP THE WHOLE TIME
      system "make"
      system "make", "check"
      system "make", "install"
    end
  end
end

__END__
diff --git a/folly/experimental/FunctionScheduler.cpp b/folly/experimental/FunctionScheduler.cpp
index 78b0aee..6957b6d 100644
--- a/folly/experimental/FunctionScheduler.cpp
+++ b/folly/experimental/FunctionScheduler.cpp
@@ -29,6 +29,23 @@ using namespace std;
 using std::chrono::seconds;
 using std::chrono::milliseconds;

+#ifdef __MACH__
+
+#include <sys/time.h>
+
+#define CLOCK_MONOTONIC 0
+
+static int clock_gettime(int /*clk_id*/, struct timespec* t) {
+    struct timeval now;
+    int rv = gettimeofday(&now, NULL);
+    if (rv) return rv;
+    t->tv_sec  = now.tv_sec;
+    t->tv_nsec = now.tv_usec * 1000;
+    return 0;
+}
+
+#endif
+
 static milliseconds nowInMS() {
   struct timespec ts /*= void*/;
   if (clock_gettime(FOLLY_TIME_MONOTONIC_CLOCK, &ts)) {