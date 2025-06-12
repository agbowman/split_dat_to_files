CREATE PROGRAM datertl:dba
 IF (validate(datertl_def,999)=999)
  CALL echo("Declaring datertl_def")
  DECLARE datertl_def = i2 WITH persist
  SET datertl_def = 1
  DECLARE uar_dategetutc(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateGetUtc",
  persist
  DECLARE uar_dategetlocal(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateGetLocal",
  persist
  DECLARE uar_dateutctolocal(p1=vc(ref),p2=vc(ref)) = i1 WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateUtcToLocal",
  persist
  DECLARE uar_datelocaltoutc(p1=vc(ref),p2=vc(ref)) = i1 WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateLocalToUtc",
  persist
  DECLARE uar_dategetutcpure(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateGetUtcPure",
  persist
  DECLARE uar_dateutctolocalpure(p1=vc(ref),p2=vc(ref)) = i1 WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateUtcToLocalPure",
  persist
  DECLARE uar_dateutctolocalzonepure(p1=vc(ref),p2=vc(ref),p3=vc(ref)) = i1 WITH image_axp =
  "datertl", image_aix = "libdate.a(libdate.o)", uar = "DateUtcToLocalZonePure",
  persist
  DECLARE uar_datelocaltoutcpure(p1=vc(ref),p2=vc(ref)) = i1 WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateLocalToUtcPure",
  persist
  DECLARE uar_datelocalzonetoutcpure(p1=vc(ref),p2=vc(ref),p3=vc(ref)) = i1 WITH image_axp =
  "datertl", image_aix = "libdate.a(libdate.o)", uar = "DateLocalZoneToUtcPure",
  persist
  DECLARE uar_datecalcdiff(p1=vc(ref),p2=vc(ref),p3=f8(ref)) = i1 WITH image_axp = "datertl",
  image_aix = "libdate.a(libdate.o)", uar = "DateCalcDiff",
  persist
  DECLARE uar_datesettimezone(p1=vc(ref)) = i1 WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateSetTimeZone",
  persist
  DECLARE uar_dategetsystemtimezone(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateGetSystemTimeZone",
  persist
  DECLARE uar_dategetsyncadjust() = i4 WITH image_axp = "datertl", image_aix = "libdate.a(libdate.o)",
  uar = "DateGetSyncAdjust",
  persist
  DECLARE uar_datesetsyncadjust(p1=i4(value)) = null WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateSetSyncAdjust",
  persist
  DECLARE uar_dategetcompatmode() = i1 WITH image_axp = "datertl", image_aix = "libdate.a(libdate.o)",
  uar = "DateGetCompatMode",
  persist
  DECLARE uar_dategetcurrent(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateGetCurrent",
  persist
  DECLARE uar_dateinitialize(p1=vc(ref),p2=i4(value)) = null WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateInitialize",
  persist
  DECLARE uar_datecompare(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateCompare",
  persist
  DECLARE uar_datemakeempty(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateMakeEmpty",
  persist
  DECLARE uar_dateisempty(p1=vc(ref)) = i1 WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateIsEmpty",
  persist
  IF (validate(cursysbit,32)=32)
   DECLARE uar_dateformatstring(p1=vc(ref),p2=i4(value),p3=vc(ref),p4=vc(ref)) = i1 WITH image_axp =
   "datertl", image_aix = "libdate.a(libdate.o)", uar = "DateFormatString",
   persist
   DECLARE uar_dateconverttostring(p1=vc(ref),p2=i4(value),p3=vc(ref),p4=vc(ref)) = null WITH
   image_axp = "datertl", image_aix = "libdate.a(libdate.o)", uar = "DateConvertToString",
   persist
   DECLARE uar_datefirsttimezone(p1=i4(ref),p2=vc(ref)) = i1 WITH image_axp = "datertl", image_aix =
   "libdate.a(libdate.o)", uar = "DateFirstTimeZone",
   persist
   DECLARE uar_datenexttimezone(p1=i4(ref),p2=vc(ref)) = i1 WITH image_axp = "datertl", image_aix =
   "libdate.a(libdate.o)", uar = "DateNextTimeZone",
   persist
  ELSE
   DECLARE uar_dateformatstring(p1=vc(ref),p2=h(value),p3=vc(ref),p4=vc(ref)) = i1 WITH image_axp =
   "datertl", image_aix = "libdate.a(libdate.o)", uar = "DateFormatString",
   persist
   DECLARE uar_dateconverttostring(p1=vc(ref),p2=h(value),p3=vc(ref),p4=vc(ref)) = null WITH
   image_axp = "datertl", image_aix = "libdate.a(libdate.o)", uar = "DateConvertToString",
   persist
   DECLARE uar_datefirsttimezone(p1=h(ref),p2=vc(ref)) = i1 WITH image_axp = "datertl", image_aix =
   "libdate.a(libdate.o)", uar = "DateFirstTimeZone",
   persist
   DECLARE uar_datenexttimezone(p1=h(ref),p2=vc(ref)) = i1 WITH image_axp = "datertl", image_aix =
   "libdate.a(libdate.o)", uar = "DateNextTimeZone",
   persist
  ENDIF
  IF (cursys="WIN")
   DECLARE uar_datetowin(p1=vc(ref),p2=vc(ref)) = i1 WITH image_axp = "datertl", image_aix =
   "libdate.a(libdate.o)", uar = "DateToWin",
   persist
   DECLARE uar_datefromwin(p1=vc(ref),p2=vc(ref)) = i1 WITH image_axp = "datertl", image_aix =
   "libdate.a(libdate.o)", uar = "DateFromWin ",
   persist
  ENDIF
 ENDIF
END GO
