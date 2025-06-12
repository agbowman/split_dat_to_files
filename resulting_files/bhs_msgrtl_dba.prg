CREATE PROGRAM bhs_msgrtl:dba
 IF (validate(msgrtl_def,999)=999)
  CALL echo("Declaring msgrtl_def")
  DECLARE msgrtl_def = i2 WITH persist
  SET msgrtl_def = 1
  DECLARE uar_msgdefhandle() = i4 WITH image_axp = "msgrtl", image_aix = "libmsg.a(libmsg.o)", uar =
  "__MsgDefHandle",
  persist
  DECLARE uar_msgcreate(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "msgrtl", image_aix =
  "libmsg.a(libmsg.o)", uar = "MsgCreate",
  persist
  DECLARE uar_msgopen(p1=vc(ref)) = i4 WITH image_axp = "msgrtl", image_aix = "libmsg.a(libmsg.o)",
  uar = "MsgOpen",
  persist
  DECLARE uar_msgclose(p1=i4(value)) = i4 WITH image_axp = "msgrtl", image_aix = "libmsg.a(libmsg.o)",
  uar = "MsgClose",
  persist
  DECLARE uar_msgwrite(p1=i4(value),p2=i2(value),p3=vc(ref),p4=i2(value),p5=vc(ref)) = i4 WITH
  image_axp = "msgrtl", image_aix = "libmsg.a(libmsg.o)", uar = "MsgWrite",
  persist
  DECLARE uar_msgwritef(p1=i4(value),p2=i2(value),p3=vc(ref),p4=i2(value),p5=vc(ref),
   p6=vc(ref)) = i4 WITH image_axp = "msgrtl", image_aix = "libmsg.a(libmsg.o)", uar = "MsgWrite",
  persist
  DECLARE uar_msgwriteex(p1=i4(value),p2=i2(value),p3=vc(ref),p4=vc(ref),p5=vc(ref),
   p6=vc(ref),p7=vc(ref),p8=i2(value),p8=vc(ref)) = i4 WITH image_axp = "msgrtl", image_aix =
  "libmsg.a(libmsg.o)", uar = "MsgWriteEx",
  persist
  DECLARE uar_msgread(p1=i4(value),p2=vc(ref)) = i4 WITH image_axp = "msgrtl", image_aix =
  "libmsg.a(libmsg.o)", uar = "MsgRead",
  persist
  DECLARE uar_msggetinfo(p1=i4(value),p2=vc(ref)) = i4 WITH image_axp = "msgrtl", image_aix =
  "libmsg.a(libmsg.o)", uar = "MsgGetInfo",
  persist
  DECLARE uar_msggetinfoex(p1=i4(value),p2=vc(ref)) = i4 WITH image_axp = "msgrtl", image_aix =
  "libmsg.a(libmsg.o)", uar = "MsgGetInfoEx",
  persist
  DECLARE uar_msgsetsize(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "msgrtl", image_aix =
  "libmsg.a(libmsg.o)", uar = "MsgSetSize",
  persist
  DECLARE uar_msgsetdescrip(p1=i4(value),p2=i2(value)) = i4 WITH image_axp = "msgrtl", image_aix =
  "libmsg.a(libmsg.o)", uar = "MsgSetDescrip",
  persist
  DECLARE uar_msgsetlevel(p1=i4(value),p2=i4(value)) = i2 WITH image_axp = "msgrtl", image_aix =
  "libmsg.a(libmsg.o)", uar = "MsgSetLevel",
  persist
  DECLARE uar_msggetlevel(p1=i4(value)) = i2 WITH image_axp = "msgrtl", image_aix =
  "libmsg.a(libmsg.o)", uar = "MsgGetLevel",
  persist
  DECLARE uar_msgwritelevel(p1=i4(value)) = i2 WITH image_axp = "msgrtl", image_aix =
  "libmsg.a(libmsg.o)", uar = "MsgWriteLevel",
  persist
  DECLARE uar_msgpushframe(p1=i4(value)) = i4 WITH image_axp = "msgrtl", image_aix =
  "libmsg.a(libmsg.o)", uar = "MsgPushFrame",
  persist
  DECLARE uar_msgpopframe(p1=i4(value)) = i4 WITH image_axp = "msgrtl", image_aix =
  "libmsg.a(libmsg.o)", uar = "MsgPopFrame",
  persist
  DECLARE uar_msgunwindframes(p1=i4(value),p2=i2(value)) = i4 WITH image_axp = "msgrtl", image_aix =
  "libmsg.a(libmsg.o)", uar = "MsgUnwindFrames",
  persist
  DECLARE uar_msgflush(p1=i4(value),p2=i2(value)) = i4 WITH image_axp = "msgrtl", image_aix =
  "libmsg.a(libmsg.o)", uar = "MsgFlush",
  persist
  DECLARE uar_msgsetdefaultuser(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "msgrtl", image_aix =
  "libmsg.a(libmsg.o)", uar = "MsgSetDefaultUser",
  persist
  DECLARE uar_msgsetdefaultlocation(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "msgrtl", image_aix
   = "libmsg.a(libmsg.o)", uar = "MsgSetDefaultLocation",
  persist
  DECLARE uar_msgsetdefaultsource(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "msgrtl", image_aix =
  "libmsg.a(libmsg.o)", uar = "MsgSetDefaultSource",
  persist
  DECLARE uar_msgsetdefaultsourceref(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "msgrtl", image_aix
   = "libmsg.a(libmsg.o)", uar = "MsgSetDefaultSourceRef",
  persist
  DECLARE uar_msgfirst(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "msgrtl", image_aix
   = "libmsg.a(libmsg.o)", uar = "MsgFirst",
  persist
  DECLARE uar_msgnext(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "msgrtl", image_aix
   = "libmsg.a(libmsg.o)", uar = "MsgNext",
  persist
  DECLARE uar_msglast(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "msgrtl", image_aix
   = "libmsg.a(libmsg.o)", uar = "MsgLast",
  persist
  DECLARE uar_msgprev(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "msgrtl", image_aix
   = "libmsg.a(libmsg.o)", uar = "MsgPrev",
  persist
 ENDIF
END GO
