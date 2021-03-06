#  Libottery by Nick Mathewson.
#
#  This software has been dedicated to the public domain under the CC0
#  public domain dedication.
#
#  To the extent possible under law, the person who associated CC0 with
#  libottery has waived all copyright and related or neighboring rights
#  to libottery.
#
#  You should have received a copy of the CC0 legalcode along with this
#  work in doc/cc0.txt.  If not, see
#  <http://creativecommons.org/publicdomain/zero/1.0/>.

dnl Tested with this version of Autoconf; older might be feasible.
AC_PREREQ([2.63])

# Preliminaries.
AC_INIT([ottery], [0.0.0-dev])
OTTERY_VERSION="0x00000001"
OTTERY_VERSION_STRING="$PACKAGE_VERSION"
AC_CONFIG_SRCDIR([src/ottery.c])
AC_CONFIG_MACRO_DIR([m4])

# config.status creates these files.
AC_CONFIG_FILES([Makefile libottery.pc])
AC_CONFIG_HEADERS([src/ottery-config.h src/ottery_version.h])

# Automake initialization.
AM_INIT_AUTOMAKE

# AM_SILENT_RULES was added in automake 1.11.
# Silent rules are off by default, but can be enabled at configure time
# with --enable-silent-rules, or at make time with "make V=0".
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES])

# Configuration options.
# TODO: Remove as many of these as practical.  (Many reduce safety in
# the name of speed.)
OTTERY_ARG_DISABLE([pid-check],
  [checks to see if the process has forked. Dangerous!])
OTTERY_ARG_DISABLE([init-check],
  [checks to make sure that the PRNG is initialized. Dangerous!])
OTTERY_ARG_DISABLE([simd],
  [optimized cryptographic primitives that use SIMD instructions.])
OTTERY_ARG_DISABLE([locks],
  [internal locking for thread safety.])
OTTERY_ARG_DISABLE([spinlocks],
  [use of spinlocks for thread safety.])
OTTERY_ARG_DISABLE([clear-after-yield],
  [automatic clearing of internal buffers.])
OTTERY_ARG_DISABLE([wipe-stack],
  [erasure of stack memory that may retain secret information.])
OTTERY_ARG_DISABLE([haskell-tests],
  [run haskell-based unit tests.])

#
# C compiler configuration.
#

AC_PROG_CC
dnl This is necessary if using automake older than 1.14.
AM_PROG_CC_C_O
dnl This has to appear before any compilation checks.
dnl AC_USE_SYSTEM_EXTENSIONS is reliably available since autoconf 2.59.
AC_USE_SYSTEM_EXTENSIONS

# Autoconf defaults to -O2 for gcc, but we want -O3 for this library.
CFLAGS="$[](AS_ECHO(["$[]CFLAGS"]) | sed s/-O2/-O3/)"

# Determine whether and how to compile chacha_krovetz.c.
OTTERY_USE_SIMD

# Initialize libtool.  Must be done after the compiler is set up.
dnl Some systems still ship a libtool.m4 that predates the change to LT_INIT.
AC_PROG_LIBTOOL

# Check out what we need to do to build with pthreads (if anything)
AX_PTHREAD()
CC="$PTHREAD_CC"
AC_SUBST(PTHREAD_CFLAGS)
AC_SUBST(PTHREAD_LIBS)

#
# Tests for headers and functions.
#

AC_CHECK_FUNCS_ONCE([arc4random arc4random_buf])

# We need to build things a bit differently on Windows.
AC_CACHE_CHECK([whether we are building for Windows], [ottery_cv_win32],
 AC_COMPILE_IFELSE([AC_LANG_SOURCE([[
#ifdef _WIN32
 the last platform on earth that doesnt act like unix
#endif]])], [ottery_cv_win32=no], [ottery_cv_win32=yes]))

AM_CONDITIONAL(WINDOWS, [test "x$ottery_cv_win32" = xyes])

# Python and Haskell are used in the test suite.
# Do these checks last so the warnings don't scroll off the user's terminal.

AC_ARG_VAR(PYTHON)
AC_CHECK_PROGS(PYTHON, [python python2 python3])
if test "x$PYTHON" = "x"; then
  AC_MSG_WARN([Python unavailable; some tests will not be run.])
fi
AM_CONDITIONAL(USEPYTHON, [test "x$PYTHON" != "x"])

AC_ARG_VAR(GHC)
AC_SUBST(GHC_MTL)
GHC_MTL=no
AC_CHECK_PROGS(GHC, [ghc])
if test "x$GHC" = "x" || test "$enable_haskell_tests" = "no"; then
  AC_MSG_WARN([GHC unavailable/disabled; some tests will not be run.])
else
  # In addition to the base Haskell compiler, the "Control.Monad.State"
  # library is required (from the mtl package).
  AC_CACHE_CHECK([for Control.Monad.State], ac_cv_ghc_control_monad_state, [
    cat <<\EOF > conftest.hs
import Control.Monad.State
main = undefined
EOF
    $GHC -c conftest.hs 1>&AS_MESSAGE_LOG_FD 2>&AS_MESSAGE_LOG_FD
    if test $? -eq 0; then
      ac_cv_ghc_control_monad_state=yes
    else
      ac_cv_ghc_control_monad_state=no
    fi
    rm -f conftest.*
  ])
  if test $ac_cv_ghc_control_monad_state = yes; then
    GHC_MTL=yes
  else
    AC_MSG_WARN([Control.Monad.State unavailable; some tests will not be run.])
    AC_MSG_WARN([Control.Monad.State is in the Haskell package 'mtl'.])
  fi
fi
AM_CONDITIONAL(USEGHC, [test "x$GHC" != "x" && test "$GHC_MTL" = "yes"])

# Set up version numbers
AC_DEFINE_UNQUOTED([OTTERY_VERSION], [$OTTERY_VERSION],
    [Version of libottery])
AC_DEFINE_UNQUOTED([OTTERY_VERSION_STRING], ["$OTTERY_VERSION_STRING"],
    [Human-readable version of libottery])

# Done.
AC_OUTPUT
