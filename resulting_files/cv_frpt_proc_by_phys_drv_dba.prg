CREATE PROGRAM cv_frpt_proc_by_phys_drv:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Organization" = 0.0
  WITH outdev, start_date, end_date,
  org_id
 IF (cnvtdatetime(cnvtdate2( $START_DATE,"DD-MMM-YYYY"),0) > cnvtdatetime(cnvtdate2( $END_DATE,
   "DD-MMM-YYYY"),0))
  GO TO exit_script
 ENDIF
 DECLARE auditsize = i4 WITH protect, noconstant(0)
 DECLARE auditcnt = i4 WITH protect, noconstant(0)
 DECLARE auditmode = i4 WITH protect, noconstant(0)
 RECORD audit_record(
   1 qual[*]
     2 order_id = f8
 ) WITH protect
 SUBROUTINE (auditevent(event_name=vc,event_type=vc,event_string=vc) =null WITH protect)
  SET auditsize = size(audit_record->qual,5)
  IF (auditsize=1)
   EXECUTE cclaudit 0, event_name, event_type,
   "Person", "Patient", "Order",
   "View", audit_record->qual[1].order_id, event_string
  ELSE
   FOR (auditcnt = 1 TO auditsize)
    IF (auditcnt=1)
     SET auditmode = 1
    ELSEIF (auditcnt < auditsize)
     SET auditmode = 2
    ELSEIF (auditcnt=auditsize)
     SET auditmode = 3
    ENDIF
    EXECUTE cclaudit auditmode, event_name, event_type,
    "Person", "Patient", "Order",
    "View", audit_record->qual[auditcnt].order_id, event_string
   ENDFOR
  ENDIF
 END ;Subroutine
 DECLARE list_cnt = i2 WITH protect
 DECLARE org_sec_ind = f8 WITH protect, noconstant(0)
 DECLARE proc_status_cancelled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000341,
   "CANCELLED"))
 DECLARE proc_status_discontinued_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000341,
   "DISCONTINUED"))
 DECLARE getorgsecurityind(dummy) = null WITH protect
 IF (validate(reply_obj)=0)
  RECORD reply_obj(
    1 cv_list[*]
      2 rpl_catalog_disp = vc
      2 rpl_provider_name = vc
  )
 ENDIF
 SUBROUTINE getorgsecurityind(dummy)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="SECURITY"
     AND di.info_name="SEC_ORG_RELTN"
    DETAIL
     org_sec_ind = di.info_number
   ;end select
 END ;Subroutine
 CALL getorgsecurityind(0)
 SELECT
  IF (org_sec_ind=0.0)
   FROM person p,
    cv_proc c
   PLAN (c
    WHERE c.action_dt_tm BETWEEN cnvtdatetime(cnvtdate2( $START_DATE,"DD-MMM-YYYY"),0) AND
    cnvtdatetime(cnvtdate2( $END_DATE,"DD-MMM-YYYY"),235959)
     AND c.prim_physician_id > 0.0
     AND  NOT (c.proc_status_cd IN (proc_status_cancelled_cd, proc_status_discontinued_cd)))
    JOIN (p
    WHERE c.prim_physician_id=p.person_id)
  ELSEIF (( $ORG_ID=0.0)
   AND org_sec_ind=1.0)
   FROM person p,
    cv_proc c,
    encounter e
   PLAN (c
    WHERE c.action_dt_tm BETWEEN cnvtdatetime(cnvtdate2( $START_DATE,"DD-MMM-YYYY"),0) AND
    cnvtdatetime(cnvtdate2( $END_DATE,"DD-MMM-YYYY"),235959)
     AND c.prim_physician_id > 0.0
     AND  NOT (c.proc_status_cd IN (proc_status_cancelled_cd, proc_status_discontinued_cd)))
    JOIN (p
    WHERE c.prim_physician_id=p.person_id)
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND e.organization_id IN (
    (SELECT
     p.organization_id
     FROM prsnl_org_reltn p
     WHERE (p.person_id=reqinfo->updt_id))))
  ELSE
   FROM person p,
    cv_proc c,
    encounter e
   PLAN (c
    WHERE c.action_dt_tm BETWEEN cnvtdatetime(cnvtdate2( $START_DATE,"DD-MMM-YYYY"),0) AND
    cnvtdatetime(cnvtdate2( $END_DATE,"DD-MMM-YYYY"),235959)
     AND c.prim_physician_id > 0.0
     AND  NOT (c.proc_status_cd IN (proc_status_cancelled_cd, proc_status_discontinued_cd)))
    JOIN (p
    WHERE c.prim_physician_id=p.person_id)
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND (e.organization_id= $ORG_ID))
  ENDIF
  INTO "NL:"
  HEAD REPORT
   list_cnt = 0, stat = alterlist(audit_record->qual,100)
  DETAIL
   list_cnt += 1
   IF (mod(list_cnt,10)=1)
    stat = alterlist(reply_obj->cv_list,(list_cnt+ 9)), stat = alterlist(audit_record->qual,(list_cnt
     + 9))
   ENDIF
   reply_obj->cv_list[list_cnt].rpl_catalog_disp = trim(uar_get_code_display(c.catalog_cd)),
   reply_obj->cv_list[list_cnt].rpl_provider_name = trim(p.name_full_formatted), audit_record->qual[
   list_cnt].order_id = c.order_id
  FOOT REPORT
   stat = alterlist(reply_obj->cv_list,list_cnt), stat = alterlist(audit_record->qual,list_cnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(audit_record->qual,list_cnt)
 CALL auditevent("CVWFM View Results","Viewed Admin Reports","User Viewed/Printed the admin reports")
 IF (curqual > 0)
  SET reply_obj->status_data.status = "S"
 ELSEIF (curqual=0)
  SET reply_obj->status_data.status = "Z"
 ELSE
  SET reply_obj->status_data.status = "F"
 ENDIF
#exit_script
 CALL echo("Please enter a valid date range!")
 DECLARE cv_frpt_proc_by_phys_drv_vrsn = vc WITH private, constant("MOD 004 02/MAR/2020 AP067478")
END GO
