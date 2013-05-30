{-
   This software has been dedicated to the public domain under the CC0
   public domain dedication.

   To the extent possible under law, the person who associated CC0 with
   libottery has waived all copyright and related or neighboring rights
   to libottery.

   You should have received a copy of the CC0 legalcode along with this
   work in doc/cc0.txt.  If not, see
      <http://creativecommons.org/publicdomain/zero/1.0/>.
-}

import Data.Word
import Control.Monad.State

import qualified Ottery as O

{-
  Use some monads to make this testable.
-}

type PRNGState = StateT O.ChaChaPRNG IO ()

io = liftIO

u32 :: PRNGState
u32 = do prng <- get
         let (prng', result) = O.getU32 prng
	 put prng'
	 io $ print result

u64 :: PRNGState
u64 = do prng <- get
         let (prng', result) = O.getU64 prng
	 put prng'
	 io $ print result

nBytes n = do prng <- get
              let (prng', result) = O.getBytes prng n
	      put prng'
	      io $ print (O.toHex result)

addSeed seed =
    do
       prng <- get
       let prng' = O.addSeed prng seed
       put prng'

addHexSeed = addSeed . O.fromHex


-- An arbitrary initial key for testing.
-- grep -i '^[abcdefoilsz]*$' /usr/share/dict/words

initialKey = O.fromHex (
   "0b501e5ce5ceba5e1e55ba0b0b0fff0c51e10de5" ++
   "c01055a1defaceab1eacc01adedcab00d1ed00d5")

demo = do
	u32
	u32
	u32
	addHexSeed ("f00d")
	nBytes (256)
	u64
	u32
	nBytes (1)
	u64
        replicateM_ (33) $ nBytes (31)
	u64
        addHexSeed ("b3da221ed5011d1f1ab1ef1dd1efaced10ca112e" ++
                    "f1eece1e55d1ab011ca150c1a151111caf100d52" ++
		    "0ff00d")
        u64
	nBytes (1)
	replicateM_ (130) u64
        addHexSeed ("00")
        nBytes (99)
        nBytes (17777)
	u64

-- XXXX The '16' here needs to be parameterized, since it's only right
-- for BPI==4 in test_krovetz.c.  Also, this whole thing breaks hard
-- on big-endian boxes.

main = runStateT demo (O.initChaCha8PRNG 16 initialKey)