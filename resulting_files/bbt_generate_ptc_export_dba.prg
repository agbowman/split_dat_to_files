CREATE PROGRAM bbt_generate_ptc_export:dba
 EXECUTE cclseclogin
 SET xloginck = validate(xxcclseclogin->loggedin,99)
 IF (xloginck != 1)
  GO TO exit_script
 ENDIF
 SET width = 132
 CALL video(n)
 DECLARE report_type_all = c1 WITH constant("A")
 DECLARE report_type_new = c1 WITH constant("N")
 DECLARE report_type_date = c1 WITH constant("D")
 DECLARE default_start_date = q8 WITH constant(cnvtdatetime("01-JAN-1800 00:00:00.00"))
 DECLARE dm_domain = vc WITH constant("PATHNET_BBT")
 DECLARE dm_name = vc WITH constant("LAST_PTC_DT_TM")
 RECORD recrequest(
   1 report_flag = c1
   1 update_end_date_ind = i2
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 facility_cd = f8
 )
 RECORD recreply(
   1 file_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE dtlastendrpt = q8 WITH noconstant(0)
 DECLARE dtlastrpt = q8 WITH noconstant(0)
 DECLARE slastrpttype = c1 WITH noconstant(" ")
 DECLARE dtbegindflt = q8 WITH noconstant(cnvtdatetime("01-JAN-1800 00:00:00.00"))
 DECLARE serrmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE ierrcode = i4 WITH noconstant(error(serrmsg,1))
 DECLARE istatusblkcnt = i4 WITH noconstant(0)
 DECLARE istat = i2 WITH noconstant(0)
 DECLARE i18nhandle = i4 WITH noconstant(0)
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
 SET istat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET recrequest->facility_cd = 0
 RECORD reccaptions(
   1 last_report = vc
   1 last_run = vc
   1 last_type = vc
   1 not_run = vc
   1 report_type = vc
   1 all_ind = vc
   1 new_ind = vc
   1 date_ind = vc
   1 start_date = vc
   1 rpt_start = vc
   1 end_date = vc
   1 rpt_end = vc
   1 use_date_end = vc
   1 yes_ind = vc
   1 no_ind = vc
   1 title = vc
   1 run_rpt = vc
   1 gen_rpt = vc
   1 rpt_comp = vc
   1 file = vc
   1 continue = vc
 )
 SET reccaptions->last_report = uar_i18ngetmessage(i18nhandle,"LAST_RPT",
  "Last export end date/time: ")
 SET reccaptions->last_run = uar_i18ngetmessage(i18nhandle,"LAST_RUN","Last ran on: ")
 SET reccaptions->last_type = uar_i18ngetmessage(i18nhandle,"LAST_TYPE","Last export type: ")
 SET reccaptions->not_run = uar_i18ngetmessage(i18nhandle,"NOT_RUN","Not run previously")
 SET reccaptions->report_type = uar_i18ngetmessage(i18nhandle,"REPORT_TYPE",
  "Enter export type : (A)ll, (N)ew, (D)ate")
 SET reccaptions->all_ind = uar_i18ngetmessage(i18nhandle,"ALL_INDICATOR","A")
 SET reccaptions->new_ind = uar_i18ngetmessage(i18nhandle,"NEW_INDICATOR","N")
 SET reccaptions->date_ind = uar_i18ngetmessage(i18nhandle,"DATE_RANGE_INDICATOR","D")
 SET reccaptions->start_date = uar_i18ngetmessage(i18nhandle,"START_DATE","Enter begin date:")
 SET reccaptions->rpt_start = uar_i18ngetmessage(i18nhandle,"RPT_START","Export Start Date:")
 SET reccaptions->end_date = uar_i18ngetmessage(i18nhandle,"END_DATE","Enter end date:")
 SET reccaptions->rpt_end = uar_i18ngetmessage(i18nhandle,"RPT_END","Export End Date:")
 SET reccaptions->use_date_end = uar_i18ngetmessage(i18nhandle,"USE_END",
  "Use end date as the last export end date/time (Y/N)?")
 SET reccaptions->yes_ind = uar_i18ngetmessage(i18nhandle,"YES_INDICATOR","Y")
 SET reccaptions->no_ind = uar_i18ngetmessage(i18nhandle,"NO_INDICATOR","N")
 SET reccaptions->title = uar_i18ngetmessage(i18nhandle,"TITLE","PATIENT TYPINGS/COMMENTS EXPORT")
 SET reccaptions->run_rpt = uar_i18ngetmessage(i18nhandle,"RUN_RPT","Run Export (Y/N)?")
 SET reccaptions->gen_rpt = uar_i18ngetmessage(i18nhandle,"GEN_RPT","Generating Export.......")
 SET reccaptions->rpt_comp = uar_i18ngetmessage(i18nhandle,"RPT_COMPLETE",
  "Export complete. Status : ")
 SET reccaptions->file = uar_i18ngetmessage(i18nhandle,"FILE","File name : ")
 SET reccaptions->continue = uar_i18ngetmessage(i18nhandle,"CAPTION","Continue (Y/N)?")
 DECLARE checkcclerror() = i2
 SUBROUTINE checkcclerror(null)
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode > 0)
    WHILE (ierrcode)
     CALL text(23,2,serrmsg)
     SET ierrcode = error(serrmsg,0)
    ENDWHILE
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (formatdttm(dtvalue=q8) =vc)
   RETURN(concat(format(dtvalue,cclfmt->mediumdate4yr)," ",format(dtvalue,cclfmt->timenoseconds)))
 END ;Subroutine
 SUBROUTINE (cnvtbegindttm(begindttm=q8) =q8)
   RETURN(cnvtdatetime(concat(format(cnvtdatetime(begindttm),"DD/MMM/YYYY HH:MM;;D"),":00.00")))
 END ;Subroutine
 SUBROUTINE (cnvtenddttm(enddttm=q8) =q8)
   RETURN(cnvtdatetime(concat(format(cnvtdatetime(enddttm),"DD/MMM/YYYY HH:MM;;D"),":59.99")))
 END ;Subroutine
 DECLARE readlastreportdate() = i2
 SUBROUTINE readlastreportdate(null)
  SELECT INTO "nl:"
   dm.info_date
   FROM dm_info dm
   PLAN (dm
    WHERE dm.info_domain=dm_domain
     AND dm.info_name=dm_name
     AND ((dm.info_number=0.0) OR (dm.info_number=null)) )
   DETAIL
    dtlastendrpt = dm.info_date, dtlastrpt = dm.updt_dt_tm, slastrpttype = dm.info_char
   WITH nocounter
  ;end select
  IF (checkcclerror(null))
   RETURN(0)
  ELSE
   RETURN(1)
  ENDIF
 END ;Subroutine
 DECLARE determinedaterangeinteractive(null) = null
 SUBROUTINE determinedaterangeinteractive(null)
   CALL text(4,3,reccaptions->last_report)
   IF (readlastreportdate(null))
    IF (dtlastendrpt=0)
     CALL text(4,33,reccaptions->not_run)
    ELSE
     SET dtbegindflt = cnvtdatetime(dtlastendrpt)
     CALL text(4,33,formatdttm(dtlastendrpt))
    ENDIF
   ENDIF
   CALL text(5,3,reccaptions->last_run)
   IF (dtlastrpt=0)
    CALL text(5,33,reccaptions->not_run)
   ELSE
    CALL text(5,33,formatdttm(dtlastrpt))
   ENDIF
   CALL text(6,3,reccaptions->last_type)
   IF (slastrpttype=" ")
    CALL text(6,33,reccaptions->not_run)
   ELSE
    CALL text(6,33,slastrpttype)
   ENDIF
   CALL text(10,5,reccaptions->report_type)
   CALL accept(10,60,"A;CU",recrequest->report_flag
    WHERE curaccept IN (reccaptions->all_ind, reccaptions->new_ind, reccaptions->date_ind))
   SET recrequest->report_flag = curaccept
   IF ((recrequest->report_flag=report_type_date))
    CALL text(12,5,reccaptions->start_date)
    CALL accept(12,29,"NNDPPPDNNNNDNNDNN;CSU",format(dtbegindflt,"DD/MMM/YYYY HH:MM;;D")
     WHERE format(cnvtdatetime(curaccept),"DD/MMM/YYYY HH:MM;;D")=curaccept
      AND cnvtdatetime(curaccept) <= cnvtdatetime(sysdate))
    IF (curscroll=0)
     SET recrequest->beg_dt_tm = cnvtbegindttm(cnvtdatetime(curaccept))
     IF ((recrequest->beg_dt_tm <= 0))
      SET recrequest->beg_dt_tm = cnvtdatetime(dtbegindflt)
     ENDIF
    ELSE
     SET recrequest->beg_dt_tm = cnvtdatetime(dtbegindflt)
    ENDIF
   ELSEIF ((((recrequest->report_flag=report_type_all)) OR (dtlastendrpt=0)) )
    SET recrequest->beg_dt_tm = cnvtdatetime(default_start_date)
    CALL text(12,5,reccaptions->rpt_start)
   ELSE
    SET recrequest->beg_dt_tm = cnvtbegindttm(dtlastendrpt)
    CALL text(12,5,reccaptions->rpt_start)
   ENDIF
   CALL text(12,29,formatdttm(recrequest->beg_dt_tm))
   IF ((recrequest->report_flag=report_type_date))
    CALL text(13,5,reccaptions->end_date)
    CALL accept(13,29,"NNDPPPDNNNNDNNDNN;CSU",format(cnvtdatetime(sysdate),"DD/MMM/YYYY HH:MM;;D")
     WHERE format(cnvtdatetime(curaccept),"DD/MMM/YYYY HH:MM;;D")=curaccept
      AND cnvtdatetime(curaccept) <= cnvtdatetime(sysdate)
      AND cnvtdatetime(curaccept) > cnvtdatetime(recrequest->beg_dt_tm))
    IF (curscroll=0)
     SET recrequest->end_dt_tm = cnvtenddttm(cnvtdatetime(curaccept))
     IF ((recrequest->end_dt_tm <= 0))
      SET recrequest->end_dt_tm = cnvtenddttm(cnvtdatetime(curdate,curtime))
     ENDIF
    ELSE
     SET recrequest->end_dt_tm = cnvtenddttm(cnvtdatetime(curdate,curtime))
    ENDIF
   ELSE
    CALL text(13,5,reccaptions->rpt_end)
    SET recrequest->end_dt_tm = cnvtenddttm(cnvtdatetime(curdate,curtime))
   ENDIF
   CALL text(13,29,formatdttm(recrequest->end_dt_tm))
   IF ((recrequest->report_flag=report_type_date))
    CALL text(14,5,reccaptions->use_date_end)
    CALL accept(14,58,"A;CU",reccaptions->no_ind
     WHERE curaccept IN (reccaptions->yes_ind, reccaptions->no_ind))
    IF ((curaccept=reccaptions->yes_ind))
     SET recrequest->update_end_date_ind = 1
    ELSE
     SET recrequest->update_end_date_ind = 0
    ENDIF
   ELSE
    SET recrequest->update_end_date_ind = 1
   ENDIF
 END ;Subroutine
#display_start
 CALL clear(1,23)
 CALL text(1,1,reccaptions->title,w)
 CALL box(2,1,8,132)
 CALL box(8,1,23,132)
 CALL determinedaterangeinteractive(null)
 CALL text(16,5,reccaptions->run_rpt)
 CALL accept(16,23,"A;CU",reccaptions->yes_ind
  WHERE curaccept IN (reccaptions->yes_ind, reccaptions->no_ind))
 IF ((curaccept=reccaptions->yes_ind))
  CALL text(16,5,reccaptions->gen_rpt)
  SET recreply->file_name = "INTERACTIVE"
  EXECUTE bbt_rpt_pat_typ_com_file  WITH replace(request,recrequest), replace(reply,recreply)
  CALL text(18,5,concat(reccaptions->rpt_comp," ",recreply->status_data.status))
  CALL text(19,5,concat(reccaptions->file," ",recreply->file_name))
  IF ((((recreply->status_data.status="S")) OR ((recreply->status_data.status="Z"))) )
   COMMIT
  ELSE
   ROLLBACK
  ENDIF
  CALL text(21,5,reccaptions->continue)
  CALL accept(21,22,"A;CU",reccaptions->yes_ind
   WHERE curaccept IN (reccaptions->yes_ind, reccaptions->no_ind))
  IF ((curaccept=reccaptions->yes_ind))
   GO TO display_start
  ENDIF
 ELSE
  CALL text(17,5,reccaptions->continue)
  CALL accept(17,22,"A;CU",reccaptions->yes_ind
   WHERE curaccept IN (reccaptions->yes_ind, reccaptions->no_ind))
  IF ((curaccept=reccaptions->yes_ind))
   GO TO display_start
  ENDIF
 ENDIF
 FREE SET recrequest
 FREE SET recreply
 FREE SET captions
#exit_script
END GO
