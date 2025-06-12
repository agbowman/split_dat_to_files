CREATE PROGRAM apachertl:dba
 IF (validate(apachertl_def,999)=999)
  CALL echo("Declaring apachertl_def")
  DECLARE apachertl_def = i2 WITH persist
  SET apachertl_def = 1
  DECLARE uar_amsapscalculate(p1=vc(ref)) = i2 WITH image_axp = "amspredictionsrtl", image_aix =
  "libamspredictions.a(shobjamspredictions.o)", uar = "AmsApsCalculate",
  persist
  DECLARE uar_amscalculatepredictions(p1=vc(ref),p2=vc(ref)) = i2 WITH image_axp =
  "amspredictionsrtl", image_aix = "libamspredictions.a(shobjamspredictions.o)", uar =
  "AmsCalculatePredictions",
  persist
  DECLARE uar_amsraprinterror(p1=i4(value)) = vc WITH image_axp = "amspredictionsrtl", image_aix =
  "libamspredictions.a(shobjamspredictions.o)", uar = "RaPrintError",
  persist
 ENDIF
END GO
