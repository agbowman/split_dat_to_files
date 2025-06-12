CREATE PROGRAM cpmsrsrtl:dba
 IF (validate(cpmsrsrtl_def,999)=999)
  CALL echo("Declaring cpmsrsrtl_def")
  DECLARE cpmsrsrtl_def = i2 WITH persist
  SET cpmsrsrtl_def = 1
  DECLARE uar_srsprsnlhasaccess(p1=f8(value),p2=f8(value),p3=f8(value)) = i4 WITH image_axp =
  "cpmsrsrtl", image_aix = "libcpmsrs.a(libcpmsrs.o)", uar = "SrsPrsnlHasAccess",
  persist
 ENDIF
END GO
