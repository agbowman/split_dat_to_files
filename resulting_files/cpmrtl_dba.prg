CREATE PROGRAM cpmrtl:dba
 IF (validate(cpmrtl_def,999)=999)
  CALL echo("Declaring cpmrtl_def")
  DECLARE cpmrtl_def = i2 WITH persist
  SET cpmrtl_def = 1
  DECLARE codequery_getcodevalue = i1 WITH persist
  DECLARE codequery_getcodeset = i1 WITH persist
  DECLARE codequery_getcodevalueex = i1 WITH persist
  DECLARE codequery_getcodesetex = i1 WITH persist
  DECLARE codequery_getcodesetfilter = i1 WITH persist
  DECLARE codequery_getcki = i1 WITH persist
  DECLARE codequery_getckiex = i1 WITH persist
  SET codequery_getcodevalue = 0
  SET codequery_getcodeset = 1
  SET codequery_getcodevalueex = 2
  SET codequery_getcodesetex = 3
  SET codequery_getcodesetfilter = 4
  SET codequery_getcki = 5
  SET codequery_getckiex = 6
  DECLARE uar_codemanagercreate(p1=vc(ref)) = i4 WITH image_axp = "cpmrtl", image_aix =
  "libcpm.a(libcpm.o)", uar = codemanagercreate,
  persist
  DECLARE uar_codemanagerdestroy(p1=i4(value)) = i2 WITH image_axp = "cpmrtl", image_aix =
  "libcpm.a(libcpm.o)", uar = codemanagerdestroy,
  persist
  DECLARE uar_codemanagerselect(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "cpmrtl", image_aix
   = "libcpm.a(libcpm.o)", uar = codemanagerselect,
  persist
  DECLARE uar_codequerycreate() = i4 WITH image_axp = "cpmrtl", image_aix = "libcpm.a(libcpm.o)", uar
   = codequerycreate,
  persist
  DECLARE uar_codequeryselect(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "cpmrtl", image_aix =
  "libcpm.a(libcpm.o)", uar = codequeryselect,
  persist
  DECLARE uar_codequerydestroy(p1=i4(value)) = i2 WITH image_axp = "cpmrtl", image_aix =
  "libcpm.a(libcpm.o)", uar = codequerydestroy,
  persist
 ENDIF
END GO
