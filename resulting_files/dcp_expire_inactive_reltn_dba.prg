CREATE PROGRAM dcp_expire_inactive_reltn:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE count = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE currentdatetime = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE continue = i2 WITH noconstant(1)
 DECLARE totalcount = i4 WITH noconstant(0)
 DECLARE expireinactivereltn(null) = null
 DECLARE displayreport(null) = null
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
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE i18n_report_title = vc WITH constant(uar_i18ngetmessage(i18nhandle,"HEADER",
   "DCP_EXPIRE_INACTIVE_RELTN SCRIPT REPORT"))
 DECLARE i18n_end_of_report = vc WITH constant(uar_i18ngetmessage(i18nhandle,"END_OF_REPORT",
   "END_OF_REPORT"))
 DECLARE i18n_update_start = vc WITH constant(uar_i18ngetmessage(i18nhandle,"UPDATE START",
   "Update start:"))
 DECLARE i18n_update_end = vc WITH constant(uar_i18ngetmessage(i18nhandle,"UPDATE END","Update end: "
   ))
 DECLARE i18n_remark = vc WITH constant(uar_i18ngetmessage(i18nhandle,"REMARK",
   "Numbers of rows sucessfully updated :"))
 CALL expireinactivereltn(null)
 CALL displayreport(null)
 SUBROUTINE expireinactivereltn(null)
   WHILE (continue=1)
     UPDATE  FROM encntr_prsnl_reltn epr
      SET epr.expire_dt_tm = cnvtdatetime(currentdatetime), epr.expiration_ind = 1, epr.updt_cnt = (
       epr.updt_cnt+ 1),
       epr.updt_dt_tm = cnvtdatetime(curdate,curtime3), epr.updt_id = 3811820, epr.updt_applctx =
       reqinfo->updt_applctx,
       epr.updt_task = reqinfo->updt_task
      WHERE epr.expiration_ind=0
       AND epr.active_ind=1
       AND epr.encntr_prsnl_r_cd IN (
      (SELECT
       cv.code_value
       FROM code_value cv
       WHERE  NOT (cv.code_value=0)
        AND cv.code_set=333
        AND cv.active_ind=0))
      WITH nocounter, maxqual(epr,10000)
     ;end update
     CALL echo(build("LOG::Updated and Committed: ",curqual,"rows"))
     COMMIT
     IF (curqual=0)
      SET continue = 0
      CALL echo("LOG::This was the last batch.")
      SET totalcount = (totalcount+ curqual)
      CALL echo(build("LOG::Total rows committed: ",totalcount))
     ELSE
      SET totalcount = (totalcount+ curqual)
      CALL echo(build("LOG::Total rows committed so far: ",totalcount))
      CALL echo("LOG::Start next batch")
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE displayreport(null)
   SELECT INTO  $OUTDEV
    FROM dummyt d1
    PLAN (d1)
    HEAD REPORT
     col 40, i18n_report_title, row + 2,
     col 10, i18n_update_start, curdate"DDMMMYY;;D",
     "/", curtime"HH:MM;;M", row + 1
    FOOT REPORT
     col 10, i18n_update_end, curdate"DDMMMYY;;D",
     "/", curtime"HH:MM;;M", row + 1,
     col 10, i18n_remark, totalcount,
     row + 2, col 50, i18n_end_of_report,
     row + 2
    WITH nocounter, separator = " ", format
   ;end select
 END ;Subroutine
END GO
