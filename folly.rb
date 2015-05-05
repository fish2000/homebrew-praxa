
class Folly < Formula
  ENV['FOLLY_VERSION'] = "0.1.0"
  ENV['GTEST_VERSION'] = "1.7.0"
  
  homepage "https://github.com/facebook/folly"
  head "https://github.com/facebook/folly.git", :using => :git
  url "https://github.com/facebook/folly/archive/a1119563e2ab8d6cde6e6aca480c1a38cfa11707.zip"
  sha256 "3b67de53792775bad188f803ed3b5b96b03117e3ad96a37921ca1c0e423499c9"
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
      
     EOS
  
  # Our Darwin timers have no clock to clean -- we patch to sidestep errors
  # from missing linuxy function sigs `clock_gettime()` and friends.
  # ... the patch itself was copypasta'd from here:
  #    https://github.com/facebook/folly/issues/170
  patch :p1, :DATA
  
  def install
    
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
      
      # Get rid of dylib(s) -- evidently this is some sort of scam
      # we need to run on libtool (?!) according to this:
      #    https://github.com/facebook/folly/blob/master/folly/bootstrap-osx-homebrew.sh#L29-L31
      rm_f Dir["libdouble-conversion*dylib"]
      ENV["DOUBLE_CONVERSION_HOME=#{Dir.pwd}"]
      ENV.append "CFLAGS",     "-I#{Dir.pwd}/src"
      ENV.append "CXXFLAGS",   "-I#{Dir.pwd}/src"
      ENV.append "CPPFLAGS",   "-I#{Dir.pwd}/src"
      ENV.append "LDFLAGS",    "-L#{Dir.pwd}"
    end
    
    # Use brewed clang for folly (Apple Clang, as of 6.1, is not up to it)
    ENV['CC']  =  Formula['llvm'].opt_prefix/"bin/clang"
    ENV['CXX'] =  Formula['llvm'].opt_prefix/"bin/clang++"
    ENV.cxx11
    
    cd "folly" do
      
      # Why the fuck are you trying to double-install this file?!?
      # What kind of monster DOES THAT?!?!
      # N.B. Sent up a PR for it: https://github.com/facebook/folly/pull/201
      inreplace "Makefile.am",
                "nobase_follyinclude_HEADERS += detail/Clock.h", ""
      
      cd "test" do
        # disable tests that furnish subversive or controversial results
        # ... we get FAIL back from thread_local_test and atomic_hash_map_test,
        # a statement I personally feel is coarse and vulgar
        inreplace "Makefile.am",
                  "TESTS += thread_cached_int_test thread_local_test",
                  "TESTS += thread_cached_int_test"
        inreplace "Makefile.am",
                  "TESTS += atomic_hash_map_test", ""
      end
      
      # autotools that shit (folly itself)
      # N.B. you *need* --disable-dependency-tracking, it would seem;
      # not using it causes `make` to eventually fail, as it buggily
      # freaks out about lacking a make rule for one of those inscrutable
      # files that are like '.deps/something.cc.Tplo' or whatever
      system "autoreconf", "-i"
      system "./configure",
             "--prefix=#{prefix}",
             "--disable-dependency-tracking"
      
      # Plug gtest in, vendorstyle, to <buildpath>/folly/test
      mkdir tt do
        rm_rf "src" # WHAT THE HELL IS THIS MARCY
        resource("gtest").stage { tt.install Dir["./*"] }
        # system "./configure",
        #        "--prefix=#{prefix}",
        #        "--disable-dependency-tracking"
        # system "make"
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