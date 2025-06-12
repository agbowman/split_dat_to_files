CREATE PROGRAM ccluarxhost:dba
 IF (validate(ccluarxhost_def,999)=999)
  CALL echo("Declaring ccluarxhost_def")
  DECLARE ccluarxhost_def = i2 WITH persist
  SET ccluarxhost_def = 1
  DECLARE uar_gethostnames(p1=vc(ref)) = vc WITH image_axp = "shrccluarx", image_aix =
  "libshrccluarx(libshrccluarx.o)", image_win = "shrccluarx",
  uar = "UAR_GET_HOSTNAMES", persist
 ENDIF
END GO
