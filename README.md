A benchmark for implementations of the function (or related functions):
``` haskell
runningTotals :: Num a => [a] -> ([a], a)
```
```haskell
>>> runningTotals [1,2,3]
    ([1,3,6], 6)
>>> runningTotals [2,-2,10,5]
    ([2,0,10,15], 15)
``` haskell

Current state of play:
```
Scan Benchmarks:

benchmarking scan versions/scanl1 (+)
time                 1.102 ms   (1.083 ms .. 1.128 ms)
                     0.995 R²   (0.990 R² .. 0.998 R²)
mean                 1.118 ms   (1.101 ms .. 1.145 ms)
std dev              72.89 μs   (50.33 μs .. 114.3 μs)
variance introduced by outliers: 52% (severely inflated)

benchmarking scan versions/scanMPlus
time                 1.028 ms   (977.5 μs .. 1.073 ms)
                     0.988 R²   (0.982 R² .. 0.996 R²)
mean                 1.039 ms   (1.016 ms .. 1.091 ms)
std dev              118.1 μs   (65.48 μs .. 215.6 μs)
variance introduced by outliers: 78% (severely inflated)

benchmarking scan versions/naive
time                 1.443 ms   (1.373 ms .. 1.512 ms)
                     0.985 R²   (0.978 R² .. 0.993 R²)
mean                 1.368 ms   (1.338 ms .. 1.415 ms)
std dev              131.5 μs   (89.82 μs .. 208.3 μs)
variance introduced by outliers: 69% (severely inflated)

benchmarking scan versions/scan_recurs
time                 3.216 ms   (3.087 ms .. 3.448 ms)
                     0.974 R²   (0.945 R² .. 0.996 R²)
mean                 3.289 ms   (3.223 ms .. 3.414 ms)
std dev              300.0 μs   (195.8 μs .. 475.0 μs)
variance introduced by outliers: 61% (severely inflated)

benchmarking scan versions/scanr1 (+)
time                 17.96 ms   (16.89 ms .. 18.92 ms)
                     0.989 R²   (0.983 R² .. 0.996 R²)
mean                 16.43 ms   (16.09 ms .. 16.92 ms)
std dev              955.4 μs   (673.7 μs .. 1.258 ms)
variance introduced by outliers: 25% (moderately inflated)

benchmarking scan versions/runningSums
time                 4.399 ms   (4.301 ms .. 4.509 ms)
                     0.995 R²   (0.992 R² .. 0.997 R²)
mean                 4.574 ms   (4.509 ms .. 4.653 ms)
std dev              233.3 μs   (193.9 μs .. 280.3 μs)
variance introduced by outliers: 29% (moderately inflated)

benchmarking scan versions/foldl'_ver
time                 13.33 ms   (13.11 ms .. 13.67 ms)
                     0.998 R²   (0.994 R² .. 1.000 R²)
mean                 13.21 ms   (13.06 ms .. 13.35 ms)
std dev              341.3 μs   (167.6 μs .. 591.2 μs)

benchmarking scan versions/foldl_ver
time                 18.70 ms   (18.41 ms .. 19.10 ms)
                     0.999 R²   (0.997 R² .. 1.000 R²)
mean                 18.46 ms   (18.26 ms .. 18.71 ms)
std dev              510.9 μs   (389.3 μs .. 689.9 μs)

benchmarking scan versions/foldr_ver
time                 11.98 ms   (11.76 ms .. 12.16 ms)
                     0.999 R²   (0.998 R² .. 0.999 R²)
mean                 11.80 ms   (11.63 ms .. 11.93 ms)
std dev              390.4 μs   (241.8 μs .. 649.8 μs)
variance introduced by outliers: 10% (moderately inflated)

benchmarking scan versions/foldl_lib_ver
time                 9.884 ms   (9.643 ms .. 10.24 ms)
                     0.990 R²   (0.979 R² .. 0.998 R²)
mean                 10.23 ms   (10.03 ms .. 10.48 ms)
std dev              628.2 μs   (470.5 μs .. 814.9 μs)
variance introduced by outliers: 32% (moderately inflated)
```

```
Strictness/unboxing benchmarks:
benchmarking recursions/unboxed (case)
time                 9.845 ms   (9.767 ms .. 9.948 ms)
                     0.999 R²   (0.997 R² .. 1.000 R²)
mean                 9.792 ms   (9.722 ms .. 9.873 ms)
std dev              204.8 μs   (150.3 μs .. 299.5 μs)

benchmarking recursions/unboxed (let)
time                 3.030 ms   (3.013 ms .. 3.047 ms)
                     0.999 R²   (0.997 R² .. 1.000 R²)
mean                 3.055 ms   (3.037 ms .. 3.130 ms)
std dev              102.9 μs   (29.49 μs .. 225.5 μs)
variance introduced by outliers: 17% (moderately inflated)

benchmarking recursions/strict (case)
time                 11.88 ms   (11.73 ms .. 12.02 ms)
                     0.999 R²   (0.998 R² .. 1.000 R²)
mean                 11.75 ms   (11.69 ms .. 11.84 ms)
std dev              196.2 μs   (141.8 μs .. 259.5 μs)

benchmarking recursions/strict (let)
time                 11.88 ms   (11.60 ms .. 12.17 ms)
                     0.997 R²   (0.995 R² .. 0.999 R²)
mean                 11.81 ms   (11.71 ms .. 11.97 ms)
std dev              312.3 μs   (196.7 μs .. 447.3 μs)

benchmarking recursions/non-strict (case)
time                 9.628 ms   (9.506 ms .. 9.762 ms)
                     0.999 R²   (0.998 R² .. 0.999 R²)
mean                 10.02 ms   (9.904 ms .. 10.22 ms)
std dev              398.8 μs   (275.8 μs .. 570.0 μs)
variance introduced by outliers: 16% (moderately inflated)

benchmarking recursions/non-strict (let)
time                 3.042 ms   (3.026 ms .. 3.058 ms)
                     1.000 R²   (1.000 R² .. 1.000 R²)
mean                 3.047 ms   (3.037 ms .. 3.065 ms)
std dev              40.67 μs   (24.09 μs .. 75.99 μs)

benchmarking recursions/lazy (case)
time                 3.060 ms   (3.021 ms .. 3.132 ms)
                     0.996 R²   (0.990 R² .. 0.999 R²)
mean                 3.085 ms   (3.056 ms .. 3.146 ms)
std dev              133.0 μs   (65.29 μs .. 218.5 μs)
variance introduced by outliers: 25% (moderately inflated)

benchmarking recursions/lazy (let)
time                 3.035 ms   (3.010 ms .. 3.064 ms)
                     0.999 R²   (0.998 R² .. 1.000 R²)
mean                 3.082 ms   (3.057 ms .. 3.121 ms)
std dev              99.83 μs   (62.93 μs .. 144.0 μs)
variance introduced by outliers: 17% (moderately inflated)
```
