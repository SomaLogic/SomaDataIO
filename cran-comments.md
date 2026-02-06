
# Submission 6.5.0

- This is a submission to an existing CRAN package.

- It contains minor updates to existing functions and
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
Col.Meta	          0.28	0.09	0.38	
SeqId	              0.05	0.01	0.06	
SomaDataIO-package	0.16	0.00	0.16	
SomaScanObjects	    0.42	0.00	0.42	
adat-helpers	      0.10	0.00	0.09	
adat2eSet	          0.52	0.01	0.54	
addClass	          0.00	0.00	0.00	
calcOutlierMap	    4.52	0.48	5.03	
calc_eLOD	          0.03	0.00	0.03	
cleanNames	        0.00	0.00	0.00	
diffAdats	          0.49	0.00	0.50	
getAnalyteInfo	    0.19	0.05	0.30	
getAnalytes	        0.03	0.00	0.03	
getOutlierIds	      1.82	0.14	2.01	
groupGenerics	      0.43	0.01	0.47	
is_intact_attr	    0.01	0.00	0.01	
is_seqFormat	      0.00	0.00	0.00	
lift_adat	          0.41	0.00	0.47	
loadAdatsAsList	    1.70	0.02	1.75	
merge_clin	        0.11	0.00	0.11	
parseHeader	        0.13	0.00	0.12	
pivotExpressionSet	0.07	0.02	0.08	
plot.Map	          2.00	0.09	2.17	
preProcessAdat	    2.06	0.08	2.16	
read_adat	          1.59	0.00	1.63	
read_annotations	  0.00	0.00	0.00	
rownames	          0.00	0.01	0.02	
soma_adat	          0.36	0.02	0.38	
transform	          0.00	0.00	0.00	
updateColMeta	      0.00	0.00	0.00	
write_adat	        0.48	0.01	0.50	
```
