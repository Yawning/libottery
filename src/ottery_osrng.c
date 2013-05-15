#include "ottery-internal.h"
#include "ottery.h"
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int
ottery_os_randbytes_(uint8_t *out, size_t outlen)
{
#ifdef _WIN32
  /* On Windows, CryptGenRandom is supposed to be a well-seeded
   * cryptographically strong random number generator. */
  HCRYPTPROV provider;
  int retval = 0;
  if (0 == CryptAcquireContext(&provider, NULL, NULL, PROV_RSA_FULL,
                               CRYPT_VERIFYCONTEXT))
    return OTTERY_ERR_INIT_STRONG_RNG;

  if (0 == CryptGenRandom(provider, outlen, out))
    retval = OTTERY_ERR_ACCESS_STRONG_RNG;

  CryptReleaseContext(provider, 0);
  return retval;
#else
  /* On most unixes these days, you can get strong random numbers from
   * /dev/urandom.
   *
   * That's assuming that /dev/urandom is seeded.  For most applications,
   * that won't be a problem. But for stuff that starts close to system
   * startup, before the operating system has added any entropy to the pool,
   * it can be pretty bad.
   *
   * You could use /dev/random instead, if you want, but that has another
   * problem.  It will block if the OS PRNG has received less entropy than
   * it has emitted.  If we assume that the OS PRNG isn't cryptographically
   * weak, blocking in that case is simple overkill.
   *
   * It would be best if there were an alternative that blocked if the PRNG
   * had _never_ been seeded.  But most operating systems don't have that.
   */
  int fd;
  ssize_t n;
#ifndef O_CLOEXEC
#define O_CLOEXEC 0
#endif
  fd = open("/dev/urandom", O_RDONLY|O_CLOEXEC);
  if (fd < 0)
    return OTTERY_ERR_INIT_STRONG_RNG;
  if ((n = read(fd, out, outlen)) < 0 || (size_t)n != outlen)
    return OTTERY_ERR_ACCESS_STRONG_RNG;
  close(fd);
  return 0;
#endif
}
