
# Submission 6.3.0

- This is a submission to an existing CRAN package.

- It contains new functionality, a new vignette article and
  improved documentation.


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
❯ checking CRAN incoming feasibility ... [7s/28s] NOTE
  Maintainer: ‘Caleb Scheidel <calebjscheidel@gmail.com>’

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
Col.Meta	          0.34	0.00	  0.34	
SeqId	              0.03	0.02	  0.05	
SomaDataIO-package	0.12	0.00	  0.12	
SomaScanObjects	    0.36	0.00	  0.36	
adat-helpers	      0.06	0.00	  0.08	
adat2eSet	          0.58	0.06	  0.64	
addClass	          0   	0   	  0	
calcOutlierMap	    4.49	0.29	  4.78	
calc_eLOD	          0.03	0.00	  0.03	
cleanNames	        0	    0	      0	
diffAdats	          0.47	0.05	  0.51	
getAnalyteInfo	    0.17	0.00	  0.17	
getAnalytes	        0.01	0.00	  0.01	
getOutlierIds	      2.03	0.09	  2.14	
groupGenerics	      0.49	0.00	  0.49	
is_intact_attr	    0.01	0.00	  0.02	
is_seqFormat	      0.02	0.00	  0.02	
lift_adat	          0.44	0.00	  0.44	
loadAdatsAsList	    1.67	0.02	  1.69	
merge_clin	        0.12	0.01	  0.14	
parseHeader	        0.14	0.02	  0.15	
pivotExpressionSet	0.11	0.00	  0.11	
plot.Map	          1.78	0.06	  1.84	
preProcessAdat	    1.88	0.03	  1.91	
read_adat	          1.44	0.03	  1.47	
read_annotations	  0 	  0   	  0	
rownames	          0.01	0.00	  0.01	
soma_adat	          0.29	0.00	  0.29	
transform	          0	    0	      0	
write_adat	        0.40	0.01	  0.42
```

