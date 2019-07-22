--------------------------------------------------------------------------------
-- |
--
-- A benchmark for implementations of the function (or related functions):
-- @
-- runningTotals :: Num a => [a] -> ([a], a)
-- @
-- @
-- >>> runningTotals [1,2,3]
--     ([1,3,6], 6)
-- >>> runningTotals [2,-2,10,5]
--     ([2,0,10,15], 15)
-- @

{-# LANGUAGE BangPatterns        #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE UnboxedTuples       #-}

module Main where

import qualified Control.Foldl         as L
import           Control.Monad.ST
import           Control.Scanl
import qualified Criterion.Main        as C (bench, bgroup, defaultMain, nf)
import           Data.Functor.Identity
import           Data.List
import           Data.STRef


cumulative_Unboxed_Case :: forall a. Num a => [a] -> ([a], a)
cumulative_Unboxed_Case []       = ( [], 0 )
cumulative_Unboxed_Case (a : as) = case go a as of
  (# scans, tot #) -> ( scans, tot )
  where
    go :: a -> [a] -> (# [a], a #)
    go curr []       = (# [curr], curr #)
    go curr (x : xs) = case go (curr + x) xs of
      (# acc, tot #) ->
        (# curr : acc, tot #)

cumulative_Unboxed_Let :: forall a. Num a => [a] -> ([a], a)
cumulative_Unboxed_Let []       = ( [], 0 )
cumulative_Unboxed_Let (a : as) = case go a as of
  (# scans, tot #) -> ( scans, tot )
  where
    go :: a -> [a] -> (# [a], a #)
    go curr []       = (# [curr], curr #)
    go curr (x : xs) =
      let (# acc, tot #) = go (curr + x) xs in
        (# curr : acc, tot #)

cumulative_Strict_Case :: forall a. Num a => [a] -> ([a], a)
cumulative_Strict_Case [] = ( [], 0 )
cumulative_Strict_Case (a : as) = go a as
  where
    go :: a -> [a] -> ([a], a)
    go curr []       = ([curr], curr)
    go curr (x : xs) = case go (curr + x) xs of
      !( !acc, !tot) ->
        ( curr : acc, tot )

cumulative_Strict_Let :: forall a. Num a => [a] -> ([a], a)
cumulative_Strict_Let [] = ( [], 0 )
cumulative_Strict_Let (a : as) = go a as
  where
    go :: a -> [a] -> ([a], a)
    go curr []       = ([curr], curr)
    go curr (x : xs) =
      let !( !acc, !tot) = go (curr + x) xs in
        ( curr : acc, tot )

cumulative_NonStrict_Case :: forall a. Num a => [a] -> ([a], a)
cumulative_NonStrict_Case [] = ( [], 0 )
cumulative_NonStrict_Case (a : as) = go a as
  where
    go :: a -> [a] -> ([a], a)
    go curr []       = ([curr], curr)
    go curr (x : xs) = case go (curr + x) xs of
      ( acc, tot) ->
        ( curr : acc, tot )


cumulative_NonStrict_Let :: forall a. Num a => [a] -> ([a], a)
cumulative_NonStrict_Let [] = ( [], 0 )
cumulative_NonStrict_Let (a : as) = go a as
  where
    go :: a -> [a] -> ([a], a)
    go curr []       = ([curr], curr)
    go curr (x : xs) =
      let ( acc, tot) = go (curr + x) xs in
        ( curr : acc, tot )

cumulative_Lazy_Case :: forall a. Num a => [a] -> ([a], a)
cumulative_Lazy_Case [] = ( [], 0 )
cumulative_Lazy_Case (a : as) = go a as
  where
    go :: a -> [a] -> ([a], a)
    go curr []       = ([curr], curr)
    go curr (x : xs) = case go (curr + x) xs of
      ~( acc, tot) ->
        ( curr : acc, tot )

cumulative_Lazy_Let :: forall a. Num a => [a] -> ([a], a)
cumulative_Lazy_Let [] = ( [], 0 )
cumulative_Lazy_Let (a : as) = go a as
  where
    go :: a -> [a] -> ([a], a)
    go curr []       = ([curr], curr)
    go curr (x : xs) =
      let ~( acc, tot) = go (curr + x) xs in
        ( curr : acc, tot )


scan_recurs :: Num a => [a] -> ([a], a)
scan_recurs = cumulative_NonStrict_Let


scanl1_add :: Num a => [a] -> [a]
scanl1_add = scanl1 (+)


scanr1_add :: Num a => [a] -> [a]
scanr1_add = scanr1 (+)


naive :: Num a => [a] -> (a, [a])
naive xs = let adds = scanl1 (+) xs in (sum xs, adds)


runningSums :: Num a => [a] -> ([a],a)
runningSums []     = ([],0)
runningSums (x:xs) = (v0:vs,v0)
  where (vs,v) = runningSums xs; !v0 = x + v


foldl'_ver :: Num a => [a] -> ([a],a)
foldl_ver  :: Num a => [a] -> ([a],a)
foldr_ver  :: Num a => [a] -> ([a],a)
foldl'_ver = foldl' (\  (acc, tot) a -> let tot' = tot + a in (tot' : acc, tot')) ([] , 0)
foldl_ver   = foldl  (\ ~(acc, tot) a -> let tot' = tot + a in (tot' : acc, tot')) ([] , 0)
foldr_ver   = foldr  (\  a ~(acc, tot)-> let tot' = tot + a in (tot' : acc, tot')) ([] , 0)


foldl_lib_ver :: Num a => [a] -> [a]
foldl_lib_ver = scan (postscan L.sum)


{-# NOINLINE [1] scanlM #-}
scanlM :: forall m a b. Monad m => (b -> a -> m b) -> b -> [a] -> m [b]
scanlM = scanlMGo
  where
    scanlMGo :: (b -> a -> m b) -> b -> [a] -> m [b]
    scanlMGo f q ls = (q:) <$> case ls of
      []   -> pure []
      x:xs -> do
       b <- f q x
       scanlMGo f b xs


scanlMPlus :: forall a. Num a => [a] -> [a]
scanlMPlus = runIdentity . scanlM ( \x y -> pure (x + y) ) 0


testList :: [Int]
testList = [0..10^5]

main :: IO ()
main = C.defaultMain
     [ C.bgroup "scan versions"
        [ C.bench "scanl1 (+)"    $ C.nf scanl1_add    testList
        , C.bench "scanMPlus"     $ C.nf scanlMPlus    testList
        , C.bench "naive"         $ C.nf naive         testList
        , C.bench "scan_recurs"   $ C.nf scan_recurs   testList
        , C.bench "scanr1 (+)"    $ C.nf scanr1_add    testList
        , C.bench "runningSums"   $ C.nf runningSums   testList
        , C.bench "foldl'_ver"    $ C.nf foldl'_ver    testList
        , C.bench "foldl_ver"     $ C.nf foldl_ver     testList
        , C.bench "foldr_ver"     $ C.nf foldr_ver     testList
        , C.bench "foldl_lib_ver" $ C.nf foldl_lib_ver testList
        ]
      , C.bgroup "recursions"
          [
            C.bench "unboxed (case)"     $ C.nf cumulative_Unboxed_Case   testList
          , C.bench "unboxed (let)"      $ C.nf cumulative_Unboxed_Let    testList
          , C.bench "strict (case)"     $  C.nf cumulative_Strict_Case    testList
          , C.bench "strict (let)"      $  C.nf cumulative_Strict_Let     testList
          , C.bench "non-strict (case)" $  C.nf cumulative_NonStrict_Case testList
          , C.bench "non-strict (let)"  $  C.nf cumulative_NonStrict_Let  testList
          , C.bench "lazy (case)"       $  C.nf cumulative_Lazy_Case      testList
          , C.bench "lazy (let)"        $  C.nf cumulative_Lazy_Let       testList
          ]
      ]
