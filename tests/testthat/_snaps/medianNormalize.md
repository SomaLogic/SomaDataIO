# `medianNormalize` produces expected verbose output

    Code
      result <- medianNormalize(test_data, verbose = TRUE)
    Output
      Data validation passed for median normalization.
      Standard deliverable checks:
        - Hybridization normalization: PASS 
        - Plate scale normalization: PASS 
        - No existing MedNorm/ANML: PASS 
      Three dilution setup detected (standard setup).
    Message
      > Normalization scale factors already exist: "NormScale_20, NormScale_0_005, NormScale_0_5" - they will be replaced with new scale factors
      > Building internal reference from field: "SampleType" with values: "QC" and "Sample"
      > Performing grouped median normalization by: "SampleType" (2 groups)
      > Processing group: "Sample" (2 samples)
      v Processing dilution '0_005' with 50 analytes
      v Processing dilution '0_5' with 50 analytes
      v Processing dilution '20' with 50 analytes
      > Processing group: "QC" (1 samples)
      v Processing dilution '0_005' with 50 analytes
      v Processing dilution '0_5' with 50 analytes
      v Processing dilution '20' with 50 analytes
    Output
      Recalculating RowCheck values based on normalization acceptance criteria...
      RowCheck values updated for 3 samples.
        - PASS: 3 samples
        - FLAG: 0 samples
        - Acceptance criteria: scale factors within [ 0.4 ,  2.5 ]

