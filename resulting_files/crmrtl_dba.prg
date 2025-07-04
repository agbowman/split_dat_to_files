CREATE PROGRAM crmrtl:dba
 IF (validate(crmrtl_def,999)=999)
  CALL echo("Declaring crmrtl_def")
  DECLARE crmrtl_def = i2 WITH persist
  SET crmrtl_def = 1
  IF (validate(cursysbit,32)=32)
   DECLARE uar_crmgetproperty(p1=i4(value),p2=vc(ref),p3=vc(ref),p4=i4(value)) = null WITH image_axp
    = "crmrtl", image_aix = "libcrm.a(libcrm.o)", uar = "CrmGetProperty",
   persist
   DECLARE uar_crmgetpropertylen(p1=i4(value),p2=vc(ref)) = i4 WITH image_axp = "crmrtl", image_aix
    = "libcrm.a(libcrm.o)", uar = "CrmGetPropertyLen",
   persist
   DECLARE uar_crmgetperformcount(p1=i4(value)) = i4 WITH image_axp = "crmrtl", image_aix =
   "libcrm.a(libcrm.o)", uar = "CrmGetPerformCount",
   persist
  ELSE
   DECLARE uar_crmgetproperty(p1=i4(value),p2=vc(ref),p3=vc(ref),p4=h(value)) = null WITH image_axp
    = "crmrtl", image_aix = "libcrm.a(libcrm.o)", uar = "CrmGetProperty",
   persist
   DECLARE uar_crmgetpropertylen(p1=i4(value),p2=vc(ref)) = h WITH image_axp = "crmrtl", image_aix =
   "libcrm.a(libcrm.o)", uar = "CrmGetPropertyLen",
   persist
   DECLARE uar_crmgetperformcount(p1=i4(value)) = h WITH image_axp = "crmrtl", image_aix =
   "libcrm.a(libcrm.o)", uar = "CrmGetPerformCount",
   persist
  ENDIF
  DECLARE uar_crmlogmessage(p1=i4(value),p2=vc(ref)) = null WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmLogMessage",
  persist
  DECLARE uar_crmbeginapp(p1=i4(value),p2=i4(ref)) = i4 WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmBeginApp",
  persist
  DECLARE uar_crmbegintask(p1=i4(value),p2=i4(value),p3=i4(ref)) = i4 WITH image_axp = "crmrtl",
  image_aix = "libcrm.a(libcrm.o)", uar = "CrmBeginTask",
  persist
  DECLARE uar_crmbeginreq(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(ref)) = i4 WITH image_axp =
  "crmrtl", image_aix = "libcrm.a(libcrm.o)", uar = "CrmBeginReq",
  persist
  DECLARE uar_crmendreq(p1=i4(value)) = null WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmEndReq",
  persist
  DECLARE uar_crmendtask(p1=i4(value)) = null WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmEndTask",
  persist
  DECLARE uar_crmendapp(p1=i4(value)) = null WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmEndApp",
  persist
  DECLARE uar_crmperform(p1=i4(value)) = i4 WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmPerform",
  persist
  DECLARE uar_crmgetrequest(p1=i4(value)) = i4 WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmGetRequest",
  persist
  DECLARE uar_crmgetreply(p1=i4(value)) = i4 WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmGetReply",
  persist
  DECLARE uar_crmgetmeta(p1=i4(value)) = i4 WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmGetMeta",
  persist
  DECLARE uar_crmsetproperty(p1=i4(value),p2=vc(ref),p3=vc(ref)) = null WITH image_axp = "crmrtl",
  image_aix = "libcrm.a(libcrm.o)", uar = "CrmSetProperty",
  persist
  DECLARE uar_crmgetpropertyptr(p1=i4(value),p2=vc(ref)) = vc WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmGetPropertyPtr",
  persist
  DECLARE uar_crmtaskvalid(p1=i4(value),p2=i4(value)) = i1 WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmTaskValid",
  persist
  DECLARE uar_crmmoredata(p1=i4(value)) = i1 WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmMoreData",
  persist
  DECLARE uar_crmgetappinfo(p1=i4(value)) = i4 WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmGetAppInfo",
  persist
  DECLARE uar_crmgetappprefptr(p1=i4(value),p2=vc(ref),p3=vc(ref),p4=vc(ref)) = vc WITH image_axp =
  "crmrtl", image_aix = "libcrm.a(libcrm.o)", uar = "CrmGetAppPrefPtr",
  persist
  DECLARE uar_crmsetapppref(p1=i4(value),p2=vc(ref),p3=vc(ref),p4=vc(ref)) = null WITH image_axp =
  "crmrtl", image_aix = "libcrm.a(libcrm.o)", uar = "CrmSetAppPref",
  persist
  DECLARE uar_crmsaveappprefs(p1=i4(value)) = i4 WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmSaveAppPrefs",
  persist
  DECLARE uar_crmdeleteapppref(p1=i4(value),p2=vc(ref),p3=vc(ref)) = null WITH image_axp = "crmrtl",
  image_aix = "libcrm.a(libcrm.o)", uar = "CrmDeleteAppPref",
  persist
  DECLARE uar_crmgetapphandle() = i4 WITH image_axp = "crmrtl", image_aix = "libcrm.a(libcrm.o)", uar
   = "CrmGetAppHandle",
  persist
  DECLARE uar_crmperformpeek(p1=i4(value)) = i4 WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmPerformPeek",
  persist
  DECLARE uar_crmbeginappasync(p1=i4(value),p2=i4(ref)) = null WITH image_axp = "crmrtl", image_aix
   = "libcrm.a(libcrm.o)", uar = "CrmBeginAppAsync",
  persist
  DECLARE uar_crmsynch(p1=i4(value)) = i4 WITH image_axp = "crmrtl", image_aix = "libcrm.a(libcrm.o)",
  uar = "CrmSynch",
  persist
  DECLARE uar_crmperformas(p1=i4(value),p2=vc(ref)) = i4 WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmPerformAs",
  persist
  DECLARE uar_crmperformasasync(p1=i4(value),p2=vc(ref)) = null WITH image_axp = "crmrtl", image_aix
   = "libcrm.a(libcrm.o)", uar = "CrmPerformAsAsync",
  persist
  DECLARE uar_crmdecode(p1=i4(value)) = i1 WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmDecode",
  persist
  DECLARE uar_reauthorize(p1=i4(value)) = i4 WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmReAuthorize",
  persist
  DECLARE uar_crmstarttimefunction(p1=vc(ref)) = i4 WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmStartTimeFunction",
  persist
  DECLARE uar_crmendtimefunction(p1=i4(value)) = null WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmEndTimeFunction",
  persist
  DECLARE uar_crmperformpeekwait(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "crmrtl", image_aix
   = "libcrm.a(libcrm.o)", uar = "CrmPerformPeekWait",
  persist
  DECLARE uar_crmbeginappex(p1=i4(value),p2=i4(ref),p3=vc(ref),p4=vc(ref),p5=vc(ref)) = i4 WITH
  image_axp = "crmrtl", image_aix = "libcrm.a(libcrm.o)", uar = "CrmBeginAppEx",
  persist
  DECLARE uar_crmprocess(p1=i4(value)) = i4 WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmProcess",
  persist
  DECLARE uar_crmgetdomain(p1=i4(value)) = vc WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmGetDomain",
  persist
  DECLARE uar_crmkeephandle(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "crmrtl", image_aix =
  "libcrm.a(libcrm.o)", uar = "CrmKeepHandle",
  persist
 ENDIF
END GO
