CREATE PROGRAM bbt_audit_person_aborh:dba
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
 RECORD aborh_list(
   1 aborhs[*]
     2 person_aborh_id = f8
     2 person_id = f8
     2 contributor_cd = f8
     2 active_status_dt_tm = dq8
 )
 RECORD error_status(
   1 statuslist[*]
     2 status = i4
     2 module_name = c40
     2 errnum = i4
     2 errmsg = c132
 )
 RECORD captions(
   1 rpt_title = vc
   1 aborh_id_header = vc
   1 name_header = vc
   1 aborh_dt_tm_header = vc
   1 contributor_header = vc
   1 inactivate_message_1 = vc
   1 inactivate_message_2 = vc
   1 none_message = vc
   1 update_error = vc
   1 lock_error = vc
   1 row_status_error = vc
 )
 DECLARE pa_count = i2 WITH noconstant(0)
 DECLARE count = i2 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE hold_person_aborh_id = f8 WITH noconstant(0.0)
 DECLARE hold_person_id = f8 WITH noconstant(0.0)
 DECLARE hold_contributor_cd = f8 WITH noconstant(0.0)
 DECLARE hold_active_status_dt_tm = q8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE inactive_status_cd = f8 WITH noconstant(0.0)
 DECLARE row_status_cdf = c12 WITH noconstant(fillstring(12," "))
 DECLARE error_msg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(error_msg,1))
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE success_count = i4 WITH noconstant(0)
 DECLARE index = i2 WITH noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "Multiple Active PERSON_ABORH Rows")
 SET captions->aborh_id_header = uar_i18ngetmessage(i18nhandle,"aborh_id_header","Person ABO/Rh ID")
 SET captions->name_header = uar_i18ngetmessage(i18nhandle,"name_header","Person Name")
 SET captions->aborh_dt_tm_header = uar_i18ngetmessage(i18nhandle,"aborh_dt_tm_header",
  "ABO/Rh Date/Time")
 SET captions->contributor_header = uar_i18ngetmessage(i18nhandle,"contributor_header",
  "Contributor System")
 SET captions->inactivate_message_1 = uar_i18ngetmessage(i18nhandle,"inactivate_message_1",
  "The following persons have multiple active ABO/Rh rows found on the")
 SET captions->inactivate_message_2 = uar_i18ngetmessage(i18nhandle,"inactivate_message_2",
  "PERSON_ABORH table.  All rows displayed will be inactivated on the table.")
 SET captions->none_message = uar_i18ngetmessage(i18nhandle,"none_message",
  "There were no multiple active person ABO/Rh's found.")
 SET captions->update_error = uar_i18ngetmessage(i18nhandle,"update_error",
  "Update count doesn't match number of records updated.")
 SET captions->lock_error = uar_i18ngetmessage(i18nhandle,"lock_error",
  "There was an error locking the rows for updating.")
 SET captions->row_status_error = uar_i18ngetmessage(i18nhandle,"row_status_error",
  "There was an error retrieving the row status code value from code set 48.")
 SET row_status_cdf = "INACTIVE"
 SET stat = uar_get_meaning_by_codeset(48,row_status_cdf,1,inactive_status_cd)
 IF (stat=1)
  CALL clear(1,1)
  CALL echo(captions->row_status_error)
  CALL echo("")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pa.person_aborh_id, pa.person_id, pa.active_status_dt_tm,
  pa.contributor_system_cd
  FROM person_aborh pa
  WHERE pa.active_ind=1
  ORDER BY pa.person_id
  HEAD REPORT
   count = 0, stat = alterlist(aborh_list->aborhs,10)
  HEAD pa.person_id
   pa_count = 0, hold_person_aborh_id = 0.0, hold_person_id = 0.0
  DETAIL
   pa_count += 1
   IF (pa_count > 1)
    count += 1
    IF (mod(count,10)=1
     AND count != 1)
     stat = alterlist(aborh_list->aborhs,(count+ 9))
    ENDIF
    aborh_list->aborhs[count].person_aborh_id = pa.person_aborh_id, aborh_list->aborhs[count].
    person_id = pa.person_id, aborh_list->aborhs[count].contributor_cd = pa.contributor_system_cd,
    aborh_list->aborhs[count].active_status_dt_tm = pa.active_status_dt_tm
   ELSE
    hold_person_aborh_id = pa.person_aborh_id, hold_person_id = pa.person_id, hold_contributor_cd =
    pa.contributor_system_cd,
    hold_active_status_dt_tm = pa.active_status_dt_tm
   ENDIF
  FOOT  pa.person_id
   IF (pa_count > 1)
    count += 1
    IF (mod(count,10)=1
     AND count != 1)
     stat = alterlist(aborh_list->aborhs,(count+ 9))
    ENDIF
    aborh_list->aborhs[count].person_aborh_id = hold_person_aborh_id, aborh_list->aborhs[count].
    person_id = hold_person_id, aborh_list->aborhs[count].contributor_cd = pa.contributor_system_cd,
    aborh_list->aborhs[count].active_status_dt_tm = pa.active_status_dt_tm
   ENDIF
  FOOT REPORT
   stat = alterlist(aborh_list->aborhs,count)
  WITH nocounter
 ;end select
 SET error_check = error(error_msg,0)
 IF (error_check != 0)
  CALL clear(1,1)
  CALL echo(error_msg)
  CALL echo("")
  GO TO exit_script
 ENDIF
 IF (count=0)
  CALL clear(1,1)
  CALL echo(captions->none_message)
  CALL echo("")
  CALL echo("")
 ELSE
  SELECT INTO "nl:"
   pa.*
   FROM person_aborh pa,
    (dummyt d1  WITH seq = value(size(aborh_list->aborhs,5)))
   PLAN (d1)
    JOIN (pa
    WHERE (pa.person_aborh_id=aborh_list->aborhs[d1.seq].person_aborh_id)
     AND (pa.person_id=aborh_list->aborhs[d1.seq].person_id))
   WITH nocounter, forupdate(pa)
  ;end select
  SET error_check = error(error_msg,0)
  IF (error_check=0)
   IF (count != curqual)
    CALL clear(1,1)
    CALL echo(captions->lock_error)
    CALL echo("")
    GO TO exit_script
   ENDIF
  ELSE
   CALL clear(1,1)
   CALL echo(error_msg)
   CALL echo("")
   GO TO exit_script
  ENDIF
  SET stat = alterlist(error_status->statuslist,0)
  SET stat = alterlist(error_status->statuslist,count)
  UPDATE  FROM person_aborh pa,
    (dummyt d  WITH seq = value(size(aborh_list->aborhs,5)))
   SET pa.active_ind = 0, pa.updt_id = - (1.0), pa.updt_dt_tm = cnvtdatetime(sysdate),
    pa.updt_cnt = (pa.updt_cnt+ 1), pa.updt_applctx = 0, pa.updt_task = 0,
    pa.active_status_cd = inactive_status_cd, pa.end_effective_dt_tm = cnvtdatetime(sysdate)
   PLAN (d)
    JOIN (pa
    WHERE (pa.person_aborh_id=aborh_list->aborhs[d.seq].person_aborh_id)
     AND (pa.person_id=aborh_list->aborhs[d.seq].person_id))
   WITH nocounter, status(error_status->statuslist[d.seq].status)
  ;end update
  SET error_check = error(error_msg,0)
  IF (error_check=0)
   SET success_count = 0
   FOR (index = 1 TO size(error_status->statuslist,5))
     IF ((error_status->statuslist[index].status=1))
      SET success_count += 1
     ENDIF
   ENDFOR
   IF (success_count != count)
    CALL clear(1,1)
    CALL echo(captions->update_error)
    CALL echo("")
    ROLLBACK
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ELSE
   CALL clear(1,1)
   CALL echo(error_msg)
   CALL echo("")
   ROLLBACK
   GO TO exit_script
  ENDIF
  SET stat = alterlist(error_status->statuslist,0)
  SELECT
   p.name_full_formatted, person_aborh = aborh_list->aborhs[d1.seq].person_aborh_id, active_dt_tm =
   aborh_list->aborhs[d1.seq].active_status_dt_tm"@MEDIUMDATETIME",
   contributor = uar_get_code_display(aborh_list->aborhs[d1.seq].contributor_cd)
   FROM person p,
    (dummyt d1  WITH seq = value(size(aborh_list->aborhs,5)))
   PLAN (d1)
    JOIN (p
    WHERE (p.person_id=aborh_list->aborhs[d1.seq].person_id))
   HEAD REPORT
    CALL center(captions->rpt_title,1,132), row + 2, col 0,
    captions->inactivate_message_1, row + 1, col 0,
    captions->inactivate_message_2
   HEAD PAGE
    row + 2, col 0, captions->aborh_id_header,
    col 18, captions->name_header, col 60,
    captions->aborh_dt_tm_header, col 80, captions->contributor_header,
    row + 1, col 0, "----------------",
    col 18, "----------------------------------------", col 60,
    "------------------", col 80, "----------------------------------------"
   DETAIL
    row + 1, col 0, aborh_list->aborhs[d1.seq].person_aborh_id"################",
    col 18, p.name_full_formatted"########################################", col 60,
    active_dt_tm, col 80, contributor"########################################"
   FOOT REPORT
    row + 0
   FOOT PAGE
    row + 0
   WITH nocounter
  ;end select
  SET error_check = error(error_msg,0)
  IF (error_check != 0)
   CALL clear(1,1)
   CALL echo(error_msg)
   CALL echo("")
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 FREE RECORD aborh_list
 FREE RECORD error_status
 FREE RECORD captions
END GO
