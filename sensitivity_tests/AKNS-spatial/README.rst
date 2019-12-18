*****************************
AKNS-spatial Sensitivity Test
*****************************

This directory contains the files for running sensitivity test #4::

  4. Salish Sea Cast spill sensitivity using a 5x5 spill patch with a spill every 500 m (i.e. in every cell within a 1500 m x 1500 m patch)  Note: this test using a 2x2 patch is another way of testing the sensitivity of the 1x1 km geotiff grid

The test assumes that HDF5 forcing files for the 15jun17-22jun17 period exist.

The test is prepared and executed from this directory with the command::

  mohid monte-carlo AKNS-spatial.yaml AKNS-spatial.csv
