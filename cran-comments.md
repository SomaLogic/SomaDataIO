
# Submission 6.1.0

- This is a submission to an existing CRAN package.

- It contains feature upgrades, minor internal bug-fixes,
  much improved documentation, and expanded vignettes.


## Reverse Dependencies

- There are no reverse dependencies.

- One package, `SomaScan.db`, has a reverse *Suggests*.

- It is an associated `BioConductor` package which we also maintain.


## R CMD check results
```
0 errors | 0 warnings | 3 notes
```

### Notes

The following 3 `notes` were displayed during `rhub::check_for_cran()`:

```
* checking HTML version of manual ... NOTE
Skipping checking math rendering: package 'V8' unavailable

* checking for non-standard things in the check directory ... NOTE
Found the following files/directories:
  ''NULL''

* checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
```

We do not believe these are issues under our control.


## Package Size

- Package tarball from `R CMD build` is 4.2Mb


## Example Timings from Win-builder

```
name                user    system   elapsed
Col.Meta            0.28    0.02     0.29    
SeqId               0.05    0.00     0.04    
SomaDataIO-package  0.09    0.00     0.09    
SomaScanObjects     0.25    0.02     0.26    
adat-helpers        0.05    0.00     0.05    
adat2eSet           0.31    0.04     0.36    
addClass            0       0        0    
cleanNames          0       0        0    
diffAdats           0.18    0.11     0.30    
getAnalyteInfo      0.12    0.00     0.13    
getAnalytes         0.02    0.00     0.01    
groupGenerics       0.23    0.03     0.27    
is_intact_attr      0.02    0.00     0.01    
is_seqFormat        0.02    0.00     0.02    
lift_adat           0.26    0.00     0.27    
loadAdatsAsList     1.27    0.02     1.28    
merge_clin          0.08    0.00     0.08    
parseHeader         0.46    0.19     0.65    
pivotExpressionSet  0.06    0.00     0.06    
read_adat           1.22    0.01     1.23    
read_annotations    0       0        0    
rownames            0.01    0.00     0.02    
soma_adat           0.19    0.00     0.18    
transform           0       0        0    
write_adat          0.22    0.03     0.25    
```

