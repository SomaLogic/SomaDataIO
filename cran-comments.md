
# Submission 6.4.0

- This is a submission to an existing CRAN package.

- It contains new functionality, minor updates to existing functions and
  improved documentation in vignettes.


## Reverse Dependencies

- There are no reverse dependencies.

- One package, `SomaScan.db`, has a reverse *Suggests*.

- It is an associated `BioConductor` package which we also maintain.


## R CMD check results
```
0 errors | 0 warnings | 0 notes
```

### Notes

0 `notes` were displayed during
`devtools::check(remote = TRUE, manual = TRUE)`

## Package Size

- Package tarball from `R CMD build` is 4.2Mb


## Example Timings from Win-builder

```
name	              user	system	elapsed
Col.Meta	          0.19	0.05	0.23	
SeqId	              0.04	0.00	0.05	
SomaDataIO-package	0.09	0.00	0.09	
SomaScanObjects	    0.23	0.00	0.23	
adat-helpers      	0.05	0.00	0.04	
adat2eSet	          0.40	0.02	0.42	
addClass	          0	    0	    0	
calcOutlierMap	    3.46	0.15	3.61	
calc_eLOD	          0.03	0.00	0.03	
cleanNames	        0	    0	    0	
diffAdats	          0.36	0.01	0.37	
getAnalyteInfo	    0.13	0.02	0.14	
getAnalytes	        0.02	0.00	0.01	
getOutlierIds	      1.51	0.06	1.58	
groupGenerics	      0.29	0.02	0.30	
is_intact_attr	    0	    0	    0	
is_seqFormat	      0	    0	    0	
lift_adat	          0.28	0.00	0.28	
loadAdatsAsList	    1.3	  0.0	  1.3	
merge_clin	        0.08	0.00	0.08	
parseHeader	        0.08	0.00	0.08	
pivotExpressionSet	0.07	0.00	0.08	
plot.Map	          1.07	0.08	1.16	
preProcessAdat	    1.14	0.01	1.15	
read_adat	          1.16	0.03	1.19	
read_annotations	  0	    0	    0	
rownames	          0.01	0.00	0.01	
soma_adat	          0.2	  0.0	  0.2	
transform	          0	    0	    0	
updateColMeta	      0	    0	    0	
write_adat	        0.20	0.02	0.22	
```
