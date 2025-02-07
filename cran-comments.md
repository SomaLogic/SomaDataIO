
# Submission 6.2.0

- This is a submission to an existing CRAN package.

- It contains feature upgrades, minor internal bug-fixes,
  and improved documentation.


## Reverse Dependencies

- There are no reverse dependencies.

- One package, `SomaScan.db`, has a reverse *Suggests*.

- It is an associated `BioConductor` package which we also maintain.


## R CMD check results
```
0 errors | 0 warnings | 2 notes
```

### Notes

The following `notes` were displayed during
`devtools::check(remote = TRUE, manual = TRUE)`:

```
❯ checking CRAN incoming feasibility ... [7s/72s] NOTE
  Maintainer: ‘Caleb Scheidel <calebjscheidel@gmail.com>’
  
  New maintainer:
    Caleb Scheidel <calebjscheidel@gmail.com>
  Old maintainer(s):
    Stu Field <stu.g.field@gmail.com>

❯ checking installed package size ... NOTE
    installed size is  6.0Mb
    sub-directories of 1Mb or more:
      data      3.8Mb
      extdata   1.1Mb
```


## Package Size

- Package tarball from `R CMD build` is 4.2Mb


## Example Timings from Win-builder

```
name	              user	system	elapsed
Col.Meta	          0.23	0.01	0.25	
SeqId	              0.03	0.02	0.05	
SomaDataIO-package	  0.08	0.02	0.10	
SomaScanObjects	      0.25	0.00	0.25	
adat-helpers	      0.05	0.00	0.04	
adat2eSet	          0.31	0.04	0.36	
addClass	          0	    0	    0 	
calc_eLOD	          0.01	0.00	0.01	
cleanNames	          0	    0	    0	
diffAdats	          0.33	0.00	0.33	
getAnalyteInfo	      0.11	0.00	0.11	
getAnalytes	          0.02	0.00	0.01	
groupGenerics	      0.28	0.00	0.28	
is_intact_attr	      0	    0 	    0	
is_seqFormat	      0	    0	    0	
lift_adat	          0.25	0.02	0.26	
loadAdatsAsList	      1.36	0.00	1.36	
merge_clin	          0.08	0.00	0.08	
parseHeader	          0.08	0.01	0.09	
pivotExpressionSet	  0.07	0.00	0.06	
read_adat	          1.22	0.00	1.22	
read_annotations	  0	    0	    0	
rownames	          0	    0	    0	
soma_adat	          0.2 	0.0 	0.2	
transform	          0	    0	    0	
write_adat	          0.24	0.01	0.25
```

