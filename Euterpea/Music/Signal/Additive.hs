-- This code was automatically generated by lhs2tex --code, from the file 
-- HSoM/Additive.lhs.  (See HSoM/MakeCode.bat.)

{-# LANGUAGE Arrows #-}

module Euterpea.Music.Signal.Additive where

import Euterpea
import Control.Arrow ((>>>),(<<<),arr)
constSF :: Clock c => a -> SigFun c a b -> SigFun c () b
constSF s sf = constA s >>> sf

foldSF ::  Clock c => 
           (a -> b -> b) -> b -> [SigFun c () a] -> SigFun c () b
foldSF f b sfs =
  foldr g (constA b) sfs where
    g sfa sfb =
      proc () -> do
        s1  <- sfa -< ()
        s2  <- sfb -< ()
        outA -< f s1 s2
bell1  :: Instr (Mono AudRate)
       -- Dur -> AbsPitch -> Volume -> AudSF () Double
bell1 dur ap vol [] = 
  let  f    = apToHz ap
       v    = fromIntegral vol / 100
       d    = fromRational dur
       sfs  = map  (\p-> constA (f*p) >>> osc tab1 0) 
                   [4.07, 3.76, 3, 2.74, 2, 1.71, 1.19, 0.92, 0.56]
  in proc () -> do
       aenv  <- envExponSeg [0,1,0.001] [0.003,d-0.003] -< ()
       a1    <- foldSF (+) 0 sfs -< ()
       outA -< a1*aenv*v/9

tab1 = tableSinesN 4096 [1]

test1 = outFile "bell1.wav" 6 (bell1 6 (absPitch (C,5)) 100 []) 
bell1'  :: Instr (Mono AudRate)
bell1' dur ap vol [] = 
  let  f    = apToHz ap
       v    = fromIntegral vol / 100
       d    = fromRational dur
  in proc () -> do
       aenv  <- envExponSeg [0,1,0.001] [0.003,d-0.003] -< ()
       a1    <- osc tab1' 0 -< f
       outA -< a1*aenv*v

tab1' = tableSines3N 4096 [(4.07,1,0), (3.76,1,0), (3,1,0),
  (2.74,1,0), (2,1,0), (1.71,1,0), (1.19,1,0), (0.92,1,0), (0.56,1,0)]

test1' = outFile "bell1'.wav" 6 (bell1' 6 (absPitch (C,5)) 100 []) 
bell2  :: Instr (Mono AudRate)
       -- Dur -> AbsPitch -> Volume -> AudSF () Double
bell2 dur ap vol [] = 
  let  f    = apToHz ap
       v    = fromIntegral vol / 100
       d    = fromRational dur
       sfs  = map  (mySF f d)
                   [4.07, 3.76, 3, 2.74, 2, 1.71, 1.19, 0.92, 0.56]
  in proc () -> do
       a1    <- foldSF (+) 0 sfs -< ()
       outA  -< a1*v/9

mySF f d p = proc () -> do
               s     <- osc tab1 0 <<< constA (f*p) -< ()
               aenv  <- envExponSeg [0,1,0.001] [0.003,d/p-0.003] -< ()
               outA  -< s*aenv

test2 = outFile "bell2.wav" 6 (bell2 6 (absPitch (C,5)) 100 []) 
tremolo ::   Clock c =>
             Double -> Double -> SigFun c () Double
tremolo tfrq dep = proc () -> do
     trem  <- osc tab1 0 -< tfrq
     outA  -< 1 + dep*trem
