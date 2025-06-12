CREATE PROGRAM dpsrtl:dba
 DECLARE scp_addentry = i2 WITH persist
 DECLARE scp_removeentry = i2 WITH persist
 DECLARE scp_queryentry = i2 WITH persist
 DECLARE scp_modifyentry = i2 WITH persist
 DECLARE scp_modifyentrylogon = i2 WITH persist
 DECLARE scp_modifyentryprop = i2 WITH persist
 DECLARE scp_enumentries = i2 WITH persist
 DECLARE scp_enumprop = i2 WITH persist
 DECLARE scp_startserver = i2 WITH persist
 DECLARE scp_stopserver = i2 WITH persist
 DECLARE scp_killserver = i2 WITH persist
 DECLARE scp_queryserver = i2 WITH persist
 DECLARE scp_enumservers = i2 WITH persist
 DECLARE scp_queryservice = i2 WITH persist
 DECLARE scp_enumservices = i2 WITH persist
 DECLARE scp_getplatform = i2 WITH persist
 DECLARE scp_startdomain = i2 WITH persist
 DECLARE scp_stopdomain = i2 WITH persist
 DECLARE scp_killdomain = i2 WITH persist
 DECLARE scp_setprop = i2 WITH persist
 DECLARE scp_enumnodes = i2 WITH persist
 DECLARE scp_querydomain = i2 WITH persist
 DECLARE scp_fetchentry = i2 WITH persist
 DECLARE scp_fetchserver = i2 WITH persist
 DECLARE scp_fetchservice = i2 WITH persist
 DECLARE scp_setlogon = i2 WITH persist
 SET scp_addentry = 0
 SET scp_removeentry = 1
 SET scp_queryentry = 2
 SET scp_modifyentry = 3
 SET scp_modifyentrylogon = 4
 SET scp_modifyentryprop = 5
 SET scp_enumentries = 6
 SET scp_enumprop = 7
 SET scp_startserver = 8
 SET scp_stopserver = 9
 SET scp_killserver = 10
 SET scp_queryserver = 11
 SET scp_enumservers = 12
 SET scp_queryservice = 13
 SET scp_enumservices = 14
 SET scp_getplatform = 15
 SET scp_startdomain = 16
 SET scp_stopdomain = 17
 SET scp_killdomain = 18
 SET scp_setprop = 19
 SET scp_enumnodes = 20
 SET scp_querydomain = 21
 SET scp_fetchentry = 22
 SET scp_fetchserver = 23
 SET scp_fetchservice = 24
 SET scp_setlogon = 25
 IF (validate(dpsrtl_def,999)=999)
  CALL echo("Declaring dpsrtl_def")
  DECLARE dpsrtl_def = i2 WITH persist
  SET dpsrtl_def = 1
  DECLARE uar_tdbcreate(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "dpsrtl", image_aix =
  "libdps.a(libdps.o)", uar = "TdbCreate",
  persist
  DECLARE uar_tdbdestroy(p1=i4(value)) = null WITH image_axp = "dpsrtl", image_aix =
  "libdps.a(libdps.o)", uar = "TdbDestroy",
  persist
  DECLARE uar_tdbselect(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "dpsrtl", image_aix =
  "libdps.a(libdps.o)", uar = "TdbSelect",
  persist
  DECLARE uar_authcreate() = i4 WITH image_axp = "dpsrtl", image_aix = "libdps.a(libdps.o)", uar =
  "AuthCreate",
  persist
  DECLARE uar_authdestroy(p1=i4(value)) = null WITH image_axp = "dpsrtl", image_aix =
  "libdps.a(libdps.o)", uar = "AuthDestroy",
  persist
  DECLARE uar_authselect(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "dpsrtl", image_aix =
  "libdps.a(libdps.o)", uar = "AuthSelect",
  persist
  DECLARE uar__msgcreate(p1=vc(ref)) = i4 WITH image_axp = "dpsrtl", image_aix = "libdps.a(libdps.o)",
  uar = "_MsgCreate",
  persist
  DECLARE uar__msgdestroy(p1=i4(value)) = null WITH image_axp = "dpsrtl", image_aix =
  "libdps.a(libdps.o)", uar = "_MsgDestroy",
  persist
  DECLARE uar__msgselect(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "dpsrtl", image_aix =
  "libdps.a(libdps.o)", uar = "_MsgSelect",
  persist
  DECLARE uar_cmbenumhosts(p1=vc(ref),p2=i2(value),p3=vc(ref)) = i4 WITH image_axp = "dpsrtl",
  image_aix = "libdps.a(libdps.o)", uar = "CmbEnumHosts",
  persist
  DECLARE uar_cmblistend(p1=i4(value)) = null WITH image_axp = "dpsrtl", image_aix =
  "libdps.a(libdps.o)", uar = "CmbListEnd",
  persist
  DECLARE uar_scpcreate(p1=vc(ref)) = i4 WITH image_axp = "dpsrtl", image_aix = "libdps.a(libdps.o)",
  uar = "ScpCreate",
  persist
  DECLARE uar_scpdestroy(p1=i4(value)) = null WITH image_axp = "dpsrtl", image_aix =
  "libdps.a(libdps.o)", uar = "ScpDestroy",
  persist
  DECLARE uar_scpselect(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "dpsrtl", image_aix =
  "libdps.a(libdps.o)", uar = "ScpSelect",
  persist
 ENDIF
END GO
