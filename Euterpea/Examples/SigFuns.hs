{-# LINE 8 "SigFuns.lhs" #-}
--  This code was automatically generated by lhs2tex --code, from the file 
--  HSoM/SigFuns.lhs.  (See HSoM/MakeCode.bat.)
{-# LINE 18 "SigFuns.lhs" #-}
{-#  LANGUAGE Arrows  #-}

module Euterpea.Examples.SigFuns where

import Euterpea
import Control.Arrow ((>>>),(<<<),arr)
{-# LINE 461 "SigFuns.lhs" #-}
s1 :: Clock c => SigFun c () Double
s1 = proc () -> do
       s <- oscFixed 440 -< ()
       outA -< s
{-# LINE 480 "SigFuns.lhs" #-}
tab1 :: Table
tab1 = tableSinesN 4096 [1]
{-# LINE 487 "SigFuns.lhs" #-}
s2 :: Clock c => SigFun c () Double
s2 = proc () -> do
       osc tab1 0 -< 440
{-# LINE 570 "SigFuns.lhs" #-}
tab2 = tableSinesN 4096 [1.0,0.5,0.33]
{-# LINE 577 "SigFuns.lhs" #-}
s3 :: Clock c => SigFun c () Double
s3 = proc () -> do
       osc tab2 0 -< 440
{-# LINE 583 "SigFuns.lhs" #-}
s4 :: Clock c => SigFun c () Double
s4 = proc () -> do
       f0  <- oscFixed 440   -< ()
       f1  <- oscFixed 880   -< ()
       f2  <- oscFixed 1320  -< ()
       outA -< (f0 + 0.5*f1 + 0.33*f2) / 1.83
{-# LINE 622 "SigFuns.lhs" #-}
vibrato ::   Clock c =>
             Double -> Double -> SigFun c Double Double
vibrato vfrq dep = proc afrq -> do
  vib  <- osc tab1  0 -< vfrq
  aud  <- osc tab2  0 -< afrq + vib * dep
  outA -< aud
{-# LINE 635 "SigFuns.lhs" #-}
s5 :: AudSF () Double
s5 = constA 1000 >>> vibrato 5 20
{-# LINE 712 "SigFuns.lhs" #-}
simpleClip :: Clock c => SigFun c Double Double
simpleClip = arr f where
  f x = if abs x <= 1.0 then x else signum x
{-# LINE 734 "SigFuns.lhs" #-}
time :: Clock c => SigFun c () Double
time = integral <<< constA 1
{-# LINE 787 "SigFuns.lhs" #-}
simpleInstr :: InstrumentName
simpleInstr = Custom "Simple Instrument"
{-# LINE 828 "SigFuns.lhs" #-}
myInstr :: Instr (AudSF () Double)
  -- Dur -> AbsPitch -> Volume -> [Double] -> (AudSF () Double)
myInstr dur ap vol [vfrq,dep] =
  proc () -> do
       vib  <- osc tab1  0 -< vfrq
       aud  <- osc tab2  0 -< apToHz ap + vib * dep
       outA -< aud
{-# LINE 851 "SigFuns.lhs" #-}
myInstrMap :: InstrMap (AudSF () Double)
myInstrMap = [(simpleInstr, myInstr)]
{-# LINE 875 "SigFuns.lhs" #-}
(dr, sf)  = renderSF mel myInstrMap
main      = outFile "simple.wav" dr sf
{-# LINE 884 "SigFuns.lhs" #-}
mel :: Music1
mel =  
  let  m = Euterpea.line [  na1 (c 4 en),   na1 (ef 4 en),  na1 (f 4 en), 
                     na2 (af 4 qn),  na1 (f 4 en),   na1 (af 4 en), 
                     na2 (bf 4 qn),  na1 (af 4 en),  na1 (bf 4 en),
                     na1 (c 5 en),   na1 (ef 5 en),  na1 (f 5 en),
                     na3 (af 5 wn) ]
       na1 (Prim (Note d p))  = Prim (Note d (p,[Params [0, 0]]))
       na2 (Prim (Note d p))  = Prim (Note d (p,[Params [5,10]]))
       na3 (Prim (Note d p))  = Prim (Note d (p,[Params [5,20]]))
  in instrument simpleInstr m
