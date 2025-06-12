CREATE PROGRAM ccluarxrtl:dba
 IF (validate(ccluarxrtl_def,999)=999)
  CALL echo("Declaring ccluarxrtl_def")
  DECLARE ccluarxrtl_def = i2 WITH persist
  SET ccluarxrtl_def = 1
  DECLARE uar_createuuid(p1=i4) = vc WITH image_axp = "shrccluarx", image_aix =
  "libshrccluarx(libshrccluarx.o)", image_win = "shrccluarx",
  uar = "UAR_CREATE_UUID", persist
  DECLARE uar_compareuuids(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "shrccluarx", image_aix =
  "libshrccluarx(libshrccluarx.o)", image_win = "shrccluarx",
  uar = "UAR_COMPARE_UUIDS", persist
  DECLARE uar_createuuidfromname(p1=vc(ref),p2=vc(ref)) = vc WITH image_axp = "shrccluarx", image_aix
   = "libshrccluarx(libshrccluarx.o)", image_win = "shrccluarx",
  uar = "UAR_CREATE_UUID_FROM_NAME", persist
 ENDIF
END GO
