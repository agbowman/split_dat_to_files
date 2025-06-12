CREATE PROGRAM aps_mmf_migration_status_rpt:dba
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE sinfophase = vc WITH protect, noconstant("START")
 DECLARE stmp = vc WITH protect, noconstant(" ")
 DECLARE sinfoentity = vc WITH protect, noconstant(" ")
 DECLARE dinfoid = f8 WITH protect, noconstant(0.0)
 DECLARE lcntmigrated = i4 WITH protect, noconstant(0)
 DECLARE lcntexceptions = i4 WITH protect, noconstant(0)
 DECLARE soutdev = vc WITH protect, noconstant("MINE")
 DECLARE sinfodomain = vc WITH protect, constant("ANATOMIC PATHOLOGY")
 DECLARE sinfostatusrow = vc WITH protect, constant("MMF MIGRATION STATUS")
 DECLARE sphasecbr = vc WITH protect, constant("CE_BLOB_RESULT")
 DECLARE sphaserdi = vc WITH protect, constant("REPORT_DETAIL_IMAGE")
 DECLARE sphasediscrete = vc WITH protect, constant("AP_DISCRETE_ENTITY")
 DECLARE sphaseexception = vc WITH protect, constant("EXCEPTION")
 DECLARE sphaseend = vc WITH protect, constant("COMPLETE")
 DECLARE sphasestart = vc WITH protect, constant("START")
 RECORD captions(
   1 smsghdr = vc
   1 smsgstatus = vc
   1 smsgmigcount = vc
   1 smsgxcptcount = vc
   1 smsgstep = vc
 )
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 SET i18nhandle = 0
 SET lstat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 IF (substring(1,1,reflect(parameter(1,0)))="C")
  SET soutdev = parameter(1,0)
 ENDIF
 SELECT INTO "nl:"
  dm.info_char, dm.info_number
  FROM dm_info dm
  WHERE dm.info_domain=sinfodomain
   AND dm.info_name=sinfostatusrow
  DETAIL
   sinfophase = dm.info_char, dinfoid = dm.info_number
  WITH nocounter
 ;end select
 SET sinfoentity = build(sinfophase,"|",dinfoid)
 SELECT INTO "nl:"
  migcount = count(*)
  FROM ap_image_migrated aim
  PLAN (aim)
  DETAIL
   lcntmigrated = migcount
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  xcptcount = count(*)
  FROM ap_img_migration_xcptn aimx
  PLAN (aimx
   WHERE aimx.ap_img_migration_xcptn_id != 0.0)
  DETAIL
   lcntexceptions = xcptcount
  WITH nocounter
 ;end select
 SET captions->smsghdr = uar_i18ngetmessage(i18nhandle,"HEADER","AP IMAGE MIGRATION STATUS")
 IF (sinfophase=sphasestart)
  SET captions->smsgstatus = uar_i18ngetmessage(i18nhandle,"STATSTART",
   "Migration has not been started")
 ELSEIF (sinfophase=sphaseend)
  SET captions->smsgstatus = uar_i18ngetmessage(i18nhandle,"STATEND","Migration is complete")
 ELSEIF (sinfophase=sphaseexception)
  SET captions->smsgstatus = uar_i18ngetmessage(i18nhandle,"STATXCPT",
   "Migration is processing exceptions")
 ELSE
  SET captions->smsgstatus = uar_i18ngetmessage(i18nhandle,"STATRUN","Migration is in progress")
 ENDIF
 SET captions->smsgmigcount = uar_i18ngetmessage(i18nhandle,"MIGCNT","Images Migrated:")
 SET captions->smsgxcptcount = uar_i18ngetmessage(i18nhandle,"XCPTCNT","Images Failed:")
 SET captions->smsgstep = uar_i18ngetmessage(i18nhandle,"XCPTCNT","Last Entity Migrated:")
 SELECT INTO value(soutdev)
  FROM (dummyt d  WITH seq = value(1))
  PLAN (d)
  HEAD REPORT
   captions->smsghdr, row + 2
  DETAIL
   col 5, captions->smsgstatus, row + 1,
   col 5, captions->smsgmigcount, col 40,
   lcntmigrated, row + 1, col 5,
   captions->smsgxcptcount, col 40, lcntexceptions,
   row + 1, col 5, captions->smsgstep,
   col 40, sinfoentity
  WITH nocounter
 ;end select
END GO
