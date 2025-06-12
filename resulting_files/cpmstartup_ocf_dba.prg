CREATE PROGRAM cpmstartup_ocf:dba
 SET trace = callecho
 CALL echo("executing cpmstartup_ocf...")
 RECORD daterec(
   1 date
     2 cen = i1
     2 year = i1
     2 mon = i1
     2 day = i1
     2 hour = i1
     2 min = i1
     2 sec = i1
     2 hsec = i1
 ) WITH persist
 DECLARE srv_char = i4 WITH persist
 DECLARE srv_short = i4 WITH persist
 DECLARE srv_long = i4 WITH persist
 DECLARE srv_float = i4 WITH persist
 DECLARE srv_double = i4 WITH persist
 DECLARE srv_string = i4 WITH persist
 DECLARE srv_asis = i4 WITH persist
 DECLARE srv_uchar = i4 WITH persist
 DECLARE srv_ushort = i4 WITH persist
 DECLARE srv_ulong = i4 WITH persist
 DECLARE srv_date = i4 WITH persist
 DECLARE srv_dynlist = i4 WITH persist
 DECLARE srv_pointer = i4 WITH persist
 DECLARE srv_maxtype = i4 WITH persist
 SET srv_char = 1
 SET srv_short = 2
 SET srv_long = 3
 SET srv_float = 4
 SET srv_double = 5
 SET srv_string = 6
 SET srv_asis = 7
 SET srv_uchar = 8
 SET srv_ushort = 9
 SET srv_ulong = 10
 SET srv_date = 11
 SET srv_dynlist = 12
 SET srv_pointer = 13
 SET srv_maxtype = 13
 DECLARE uar_ocfsrvcreatestructtype() = vc WITH image_axp = "libocf", uar_axp =
 "ocf_SrvCreateStructType", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvCreateStructType", persist
 DECLARE uar_ocfsrvcreatelisttype(p1=vc(ref)) = vc WITH image_axp = "libocf", uar_axp =
 "ocf_SrvCreateListType", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvCreateListType", persist
 DECLARE uar_ocfsrvcreatestringtype(p1=i2(value)) = vc WITH image_axp = "libocf", uar_axp =
 "ocf_SrvCreateStringType", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvCreateStringType", persist
 DECLARE uar_ocfsrvcreatechartype() = vc WITH image_axp = "libocf", uar_axp = "ocf_SrvCreateCharType",
 image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvCreateCharType", persist
 DECLARE uar_ocfsrvcreateshorttype() = vc WITH image_axp = "libocf", uar_axp =
 "ocf_SrvCreateShortType", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvCreateShortType", persist
 DECLARE uar_ocfsrvcreatelongtype() = vc WITH image_axp = "libocf", uar_axp = "ocf_SrvCreateLongType",
 image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvCreateLongType", persist
 DECLARE uar_ocfsrvcreateulongtype() = vc WITH image_axp = "libocf", uar_axp =
 "ocf_SrvCreateULongType", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvCreateULongType", persist
 DECLARE uar_ocfsrvcreatedoubletype() = vc WITH image_axp = "libocf", uar_axp =
 "ocf_SrvCreateDoubleType", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvCreateDoubleType", persist
 DECLARE uar_ocfsrvcreateasistype() = vc WITH image_axp = "libocf", uar_axp = "ocf_SrvCreateAsIsType",
 image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvCreateAsIsType", persist
 DECLARE uar_ocfsrvcreatedatetype() = vc WITH image_axp = "libocf", uar_axp = "ocf_SrvCreateDateType",
 image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvCreateDateType", persist
 DECLARE uar_ocfsrvcreatedynlisttype() = vc WITH image_axp = "libocf", uar_axp =
 "ocf_SrvCreateDynListType", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvCreateDynListType", persist
 DECLARE uar_ocfsrvcreatepointertype() = vc WITH image_axp = "libocf", uar_axp =
 "ocf_SrvCreatePointerType", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvCreatePointerType", persist
 DECLARE uar_ocfsrvcreatetypefrom(p1=vc(ref),p2=vc(ref)) = vc WITH image_axp = "libocf", uar_axp =
 "ocf_SrvCreateTypeFrom", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvCreateTypeFrom", persist
 DECLARE uar_ocfsrvduptype(p1=vc(ref)) = vc WITH image_axp = "libocf", uar_axp = "ocf_SrvDupType",
 image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvDupType", persist
 DECLARE uar_ocfsrvaddfield(p1=vc(ref),p2=vc(ref),p3=vc(ref),p4=i2(value)) = i4 WITH image_axp =
 "libocf", uar_axp = "ocf_SrvAddField", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvAddField", persist
 DECLARE uar_ocfsrvdestroytype(p1=vc(ref)) = i4 WITH image_axp = "libocf", uar_axp =
 "ocf_SrvDestroyType", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvDestroyType", persist
 DECLARE uar_ocfsrvgettypecount(p1=vc(ref)) = i2 WITH image_axp = "libocf", uar_axp =
 "ocf_SrvGetTypeCount", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetTypeCount", persist
 DECLARE uar_ocfsrvlookuptype(p1=vc(ref),p2=vc(ref)) = vc WITH image_axp = "libocf", uar_axp =
 "ocf_SrvLookupType", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvLookupType", persist
 DECLARE uar_ocfsrvinspecttype(p1=vc(ref)) = vc WITH image_axp = "libocf", uar_axp =
 "ocf_SrvInspectType", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvInspectType", persist
 DECLARE uar_ocfsrvgetlisttypeitem(p1=vc(ref)) = vc WITH image_axp = "libocf", uar_axp =
 "ocf_SrvGetListTypeItem", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetListTypeItem", persist
 DECLARE uar_ocfsrvgetstringtypemax(p1=vc(ref)) = i2 WITH image_axp = "libocf", uar_axp =
 "ocf_SrvGetStringTypeMax", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetStringTypeMax", persist
 DECLARE uar_ocfsrvcreateinstance(p1=vc(ref)) = vc WITH image_axp = "libocf", uar_axp =
 "ocf_SrvCreateInstance", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvCreateInstance", persist
 DECLARE uar_ocfsrvrecreateinstance(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "libocf", uar_axp =
 "ocf_SrvReCreateInstance", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvReCreateInstance", persist
 DECLARE uar_ocfsrvdupinstance(p1=vc(ref)) = vc WITH image_axp = "libocf", uar_axp =
 "ocf_SrvDupInstance", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvDupInstance", persist
 DECLARE uar_ocfsrvdestroyinstance(p1=vc(ref)) = i4 WITH image_axp = "libocf", uar_axp =
 "ocf_SrvDestroyInstance", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvDestroyInstance", persist
 DECLARE uar_ocfsrvsetlong(p1=vc(ref),p2=vc(ref),p3=i4(value)) = i4 WITH image_axp = "libocf",
 uar_axp = "ocf_SrvSetLong", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvSetLong", persist
 DECLARE uar_ocfsrvsetulong(p1=vc(ref),p2=vc(ref),p3=i4(value)) = i4 WITH image_axp = "libocf",
 uar_axp = "ocf_SrvSetULong", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvSetULong", persist
 DECLARE uar_ocfsrvsetshort(p1=vc(ref),p2=vc(ref),p3=i2(value)) = i4 WITH image_axp = "libocf",
 uar_axp = "ocf_SrvSetShort", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvSetShort", persist
 DECLARE uar_ocfsrvsetdouble(p1=vc(ref),p2=vc(ref),p3=f8(value)) = i4 WITH image_axp = "libocf",
 uar_axp = "ocf_SrvSetDouble", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvSetDouble", persist
 DECLARE uar_ocfsrvsetstring(p1=vc(ref),p2=vc(ref),p3=vc(ref)) = i4 WITH image_axp = "libocf",
 uar_axp = "ocf_SrvSetString", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvSetString", persist
 DECLARE uar_ocfsrvsetasis(p1=vc(ref),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4 WITH image_axp =
 "libocf", uar_axp = "ocf_SrvSetAsIs", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvSetAsIs", persist
 DECLARE uar_ocfsrvsetdate(p1=vc(ref),p2=vc(ref),p3=c8(ref)) = i4 WITH image_axp = "libocf", uar_axp
  = "ocf_SrvSetDate", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvSetDate", persist
 DECLARE uar_ocfsrvgetstruct(p1=vc(ref),p2=vc(ref)) = vc WITH image_axp = "libocf", uar_axp =
 "ocf_SrvGetStruct", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetStruct", persist
 DECLARE uar_ocfsrvgetitem(p1=vc(ref),p2=vc(ref),p3=i2(value)) = vc WITH image_axp = "libocf",
 uar_axp = "ocf_SrvGetItem", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetItem", persist
 DECLARE uar_ocfsrvgetitemcount(p1=vc(ref),p2=vc(ref)) = i2 WITH image_axp = "libocf", uar_axp =
 "ocf_SrvGetItemCount", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetItemCount", persist
 DECLARE uar_ocfsrvgetlong(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "libocf", uar_axp =
 "ocf_SrvGetLong", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetLong", persist
 DECLARE uar_ocfsrvgetulong(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "libocf", uar_axp =
 "ocf_SrvGetLong", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetLong", persist
 DECLARE uar_ocfsrvgetshort(p1=vc(ref),p2=vc(ref)) = i2 WITH image_axp = "libocf", uar_axp =
 "ocf_SrvGetShort", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetShort", persist
 DECLARE uar_ocfsrvgetdouble(p1=vc(ref),p2=vc(ref)) = f8 WITH image_axp = "libocf", uar_axp =
 "ocf_SrvGetDouble", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetDouble", persist
 DECLARE uar_ocfsrvgetstring(p1=vc(ref),p2=vc(ref),p3=vc(ref),p4=i2(value)) = i4 WITH image_axp =
 "libocf", uar_axp = "ocf_SrvGetString", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetString", persist
 DECLARE uar_ocfsrvgetstringptr(p1=vc(ref),p2=vc(ref)) = vc WITH image_axp = "libocf", uar_axp =
 "ocf_SrvGetStringPtr", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetStringPtr", persist
 DECLARE uar_ocfsrvgetstringlen(p1=vc(ref),p2=vc(ref)) = i2 WITH image_axp = "libocf", uar_axp =
 "ocf_SrvGetStringLen", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetStringLen", persist
 DECLARE uar_ocfsrvgetasis(p1=vc(ref),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4 WITH image_axp =
 "libocf", uar_axp = "ocf_SrvGetAsIs", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetAsIs", persist
 DECLARE uar_ocfsrvgetasissize(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "libocf", uar_axp =
 "ocf_SrvGetAsIsSize", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetAsIsSize", persist
 DECLARE uar_ocfsrvgetdate(p1=vc(ref),p2=vc(ref),p3=c8(ref)) = i4 WITH image_axp = "libocf", uar_axp
  = "ocf_SrvGetDate", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetDate", persist
 DECLARE uar_ocfsrvgetdateptr(p1=vc(ref),p2=vc(ref)) = c8 WITH image_axp = "libocf", uar_axp =
 "ocf_SrvGetDatePtr", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_SrvGetDatePtr", persist
 DECLARE uar_ocfprintstruct(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "libocf", uar_axp =
 "ocf_printStruct", image_aix = "libocf.a(libocf.o)",
 uar_aix = "ocf_printStruct", persist
 DECLARE uar_ocfissrv(p1=vc(ref)) = i2 WITH image_axp = "libocf", uar_axp = "ocf_issrv", image_aix =
 "libocf.a(libocf.o)",
 uar_aix = "ocf_issrv", persist
END GO
