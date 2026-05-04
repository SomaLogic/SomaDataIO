
# Submission 6.6.0

- This is a submission to an existing CRAN package.

- It contains new functions, minor updates to existing functions and
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
name	                  user	system	elapsed
Col.Meta	              0.33	0.01	0.34	
SeqId	                  0.03	0.02	0.05	
SomaDataIO-package	    0.13	0.00	0.13	
SomaScanObjects   	    0.44	0.00	0.44	
adat-helpers	          0.06	0.00	0.06	
adat2eSet	              0.56	0.06	0.62	
addClass	              0.00	0.00	0.00	
calcOutlierMap	        4.68	0.34	5.03	
calc_eLOD	              0.03	0.00	0.03	
cleanNames	            0.00  0.00	0.00	
diffAdats	              0.45	0.00	0.46	
getAnalyteInfo	        0.21	0.00	0.22	
getAnalytes	            0.01	0.00	0.01	
getOutlierIds	          2.20	0.08	2.28	
groupGenerics	          0.48	0.00	0.49	
is_intact_attr	        0.02	0.00	0.01	
is_seqFormat	          0.02	0.00	0.02	
lift_adat	              0.40	0.03	0.42	
loadAdatsAsList	        1.64	0.03	1.67	
medianNormalize	        0.00	0.00	0.00	
merge_clin	            0.14	0.01	0.16	
parseHeader	            0.16	0.02	0.17	
pivotExpressionSet	    0.14	0.00	0.14	
plot.Map	              2.03	0.11	2.14	
preProcessAdat	        2.00	0.03	2.03	
read_adat	              1.60	0.04	1.64	
read_annotations	      0.00  0.00	0.00	
reverseMedianNormalize	0.00	0.00	0.00	
rownames	              0.00	0.00	0.00	
soma_adat	              0.33	0.02	0.35	
transform	              0.00	0.00	0.00	
updateColMeta	          0.00	0.00	0.00	
write_adat	            0.41	0.01	0.42	
```
