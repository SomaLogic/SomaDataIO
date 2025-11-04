# `medianNormalize` produces expected verbose output

    Code
      result <- medianNormalize(test_data, verbose = TRUE)
    Message
      > Normalization scale factors already exist: "NormScale_20, NormScale_0_005, NormScale_0_5" - they will be replaced with new scale factors
      > Building internal reference from field: "SampleType" with values: "QC" and "Sample"
      > Performing grouped median normalization by: "SampleType" (2 groups)
      > Processing group: "Sample" (12 samples)
      v Processing dilution '0_005' with 173 analytes
      v Processing dilution '0_5' with 828 analytes
      v Processing dilution '20' with 4271 analytes
      > Processing group: "QC" (4 samples)
      v Processing dilution '0_005' with 173 analytes
      v Processing dilution '0_5' with 828 analytes
      v Processing dilution '20' with 4271 analytes

