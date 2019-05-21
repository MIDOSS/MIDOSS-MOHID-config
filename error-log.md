# ERRORS from running the model

##  Could not read solution from HDF5 file
I got this error in stdout when I ran the model using def-allen instead of rrg-allen.  The output looked like this:
```
Please Wait...
 -------------------------- MODEL -------------------------

 Constructing      :
 ID                :            1

 OPENMP: Max number of threads available is            1
 OPENMP: Number of threads requested is           12
 <Compilation Options Warning>
 OPENMP: Number of threads implemented is            1

 Could not read solution from HDF5 file
 Last instant in file lower than simulation ending time
 Matrix name: mean wave period

```


# ERRORS from formatting of Lagrangian.dat file

## A no warning crash that has this characteristic:

In STDOUT:
```
...
 ---Assimilation     :            0

Ended run at Wed May 15 13:38:27 PDT 2019
Results hdf5 to netCDF4 conversion started at Wed May 15 13:38:27 PDT 2019
```
In STDERR: "CheckOriginInLandCell - ModuleLagrangianGlobal - ERR30"

Cause of error: I changed the Lagrangian.dat file to look as follows
```
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
<BeginOrigin>
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

POSITION_COORDINATES       : -123.67 49.21  ! Spill Longitude (Ã‚ÂºE) Latitude (Ã‚ÂºN)
ORIGIN_NAME               : OilSpill
GROUP_ID                  : 1             ! [1] (integer) Group to which belong Origin
NBR_PARTIC                : 2000          ! [-] Number of particles.  Values greater than 500 seem to work best.
EMISSION_SPATIAL          : Accident      ! [-] Spatial emission type: Point/Accident/Box
EMISSION_TEMPORAL         : Instantaneous ! [ ] Temporal emission type: Instantaneous or Continuous.
                                          !     Instantaneous: All oil spills at once.
                                          !     Continuous: Oil is released gradually.
```

What works is this: 
```
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
<BeginOrigin>
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

POSITION_COORDINATES       : -123.67 49.21
ORIGIN_NAME               : OilSpill

GROUP_ID                  : 1

NBR_PARTIC                : 2000
EMISSION_SPATIAL          : Accident
EMISSION_TEMPORAL         : Instantaneous
```

After a lot of trial and error with these settings, toggling on/off different lines, I came to a new error when I toggled off
```
EMISSION_TEMPORAL         : Instantaneous
```
and toggled on 
```
EMISSION_TEMPORAL         : Instantaneous ! [ ] Temporal emission type: Instantaneous or Continuous.
                                          !     Instantaneous: All oil spills at once.
                                          !     Continuous: Oil is released gradually.


 ---Assimilation     :            0
 
 Unknown Temporal Emission type 
 Instantaneous ! [ ] Temporal emission type: Instantaneous or Continuous.
 Valid option [1] :Continuous
 Valid option [2] :Instantaneous
 Origin           :OilSpill
```
I tried the following, but it didn't work:
```
EMISSION_TEMPORAL         : Instantaneous ! [ ] Temporal emission type: Instantaneous or Continuous.
!                                               Instantaneous: All oil spills at once.
!                                               Continuous: Oil is released gradually.
```
This is the solution that worked:
```
! EMISSION_TEMPORAL [ ] Temporal emission type: Instantaneous or Continuous.
!                                               Instantaneous: All oil spills at once.
!                                               Continuous: Oil is released gradually.
EMISSION_TEMPORAL         : Instantaneous
```
I re-wrote this section as follows, and MOHID is happy. YAY! :-)
```
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
<BeginOrigin>
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

! POSITION_COORDINATES  Spill Longitude (Ã‚ÂºE) Latitude (Ã‚ÂºN)
! GROUP_ID   [1] (integer) Group to which belong Origin
! NBR_PARTIC [-] Number of particles.  Values greater than 500 seem to work best.
! EMISSION_SPATIAL  [-] Spatial emission type: Point/Accident/Box
! EMISSION_TEMPORAL [ ] Temporal emission type: Instantaneous or Continuous.
!                                               Instantaneous: All oil spills at once.
!                                               Continuous: Oil is released gradually.

POSITION_COORDINATES       : -123.67 49.21
ORIGIN_NAME               : OilSpill
GROUP_ID                  : 1
NBR_PARTIC                : 2000
EMISSION_SPATIAL          : Accident
EMISSION_TEMPORAL         : Instantaneous
```
I then got the same error, i.e., in stdout:

 ---Assimilation     :            0

Ended run at Thu May 16 11:44:34 PDT 2019
```
when I introduced: 
```
POINT_VOLUME              : 1000          ! Volume of oil spilled in m^3
ACCIDENT_METHOD           : Fay           ! [Fay] Way to calculate initial area of accident: Fay or Thickness
DEPTH_FROM_FREE_SURFACE   : 0

But this time the error was NOT fixed by making a similar change:

! POINT_VOLUME     [] Volume of oil spilled in m^3
! ACCIDENT_METHOD  [Fay] Way to calculate initial area of accident: Fay or Thickness
! DEPTH_FROM_FREE_SURFACE   Use 0 for surface spills
POINT_VOLUME              : 1000
ACCIDENT_METHOD           : Fay
DEPTH_FROM_FREE_SURFACE   : 0
```
I resolved the error with the following
```
! POINT_VOLUME     [] Volume of oil spilled in m^3
! ACCIDENT_METHOD  [Fay] Way to calculate initial area of accident: Fay or Thickness
! DEPTH_FROM_FREE_SURFACE   Use 0 for surface spills
POINT_VOLUME              : 1000
ACCIDENT_METHOD           : 1
DEPTH_FROM_FREE_SURFACE   : 0
```
i.e. ACCIDENT_METHOD :1; unfortunately, Shihan says the value we ought to use is "Fay"
```
## In STDOUT: "FATAL; KEYWORD; Subroutine OilOptions - ModuleOil_0D. ERR70."

This was caused by a comment in Lagrangian.dat file.  The line is was as follows.
```
EVAPORATIONMETHOD         : EvaporativeExposure ! EVAPORATIONMETHOD [EvaporativeExposure] Options: EvaporativeExposure/PseudoComponents/Fingas
```
I tried changeing "/" to "," but the error persisted.  It's not too long a line because if it were too long of a line then I would get this error: 
```
"Maximum of          256  characters is supported."
```
Whatever the cause, I fixed it by moving the comment to a new line so that it now reads as follows.
```
! EVAPORATIONMETHOD [EvaporativeExposure] Options: EvaporativeExposure/PseudoComponents/Fingas
EVAPORATIONMETHOD         : EvaporativeExposure
```

I ran into this problem again with this code addition:
```
!!! ** OIL_EMULSIFICATION [1] **
EMULSIFICATIONMETHOD      : Mackay        ! Shihan says to see MOHID docs for refs
EMULSPARAMETER            : 1.6E-6        ! Water Uptake Parameter for Mackay's emulsification method [1.6E-6]
CEMULS                    : 1.5E-6        ! Percent of evaporated oil before emulsification begins [1.0E-6 -- 2.0E-6] (%)
MAXVWATERCONTENT          : 62            ! Maximum Volume Water Content [null_real] (%)

   ! the following 4 are required if OIL_EMULSIFICATION: Fingas or Rasmussen
   !ASPHALTENECONTENT         : 1.27
   !WAXCONTENT                : 2.9
   !RESINCONTENT              : 6.1
   !SATURATECONTENT           : 75.0
```

The code ran when I changed the above to: 
```
!!! ** OIL_EMULSIFICATION [1] **
! EMULSIFICATIONMETHOD [] Shihan says to see MOHID docs for refs
! EMULSPARAMETER       [1.6E-6]           Water Uptake Parameter for Mackay's emulsification method
! CEMULS               [1.0E-6 -- 2.0E-6] % Percent of evaporated oil before emulsification begins
! MAXVWATERCONTENT     [null_real]          Maximum % Volume Water Content

EMULSIFICATIONMETHOD      : Mackay
EMULSPARAMETER            : 1.6E-6
CEMULS                    : 1.5E-6
MAXVWATERCONTENT          : 62

   ! the following 4 are required if OIL_EMULSIFICATION: Fingas or Rasmussen
   !ASPHALTENECONTENT         : 1.27
   !WAXCONTENT                : 2.9
   !RESINCONTENT              : 6.1
   !SATURATECONTENT           : 75.0
```


