CREATE PROGRAM cv_frpt_referral_ltr_drv:dba
 PROMPT
  "output to file/printer/mine" = "MINE",
  "Starting Date (DD-MMM-YYYY)" = "CURDATE",
  "Ending Date (DD-MMM-YYYY)" = "CURDATE",
  "Physician ID" = 0.0,
  "Activity Sub-type" = 0.0,
  "Procedure Status" = "",
  "Organization" = 0.0
  WITH outdev, startdate, enddate,
  physicianid, activitysubtype, procedurestatus,
  org_id
 IF (validate(reply) != 1)
  RECORD reply(
    1 referral_rep[*]
      2 primary_phy = vc
      2 description = vc
      2 proc_disp = vc
      2 status_disp = vc
      2 proc_date = dq8
      2 gen_date = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_msg(cv_error,"Reply doesn't contain status block2")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 FREE SET stepstatus
 RECORD stepstatus(
   1 step[*]
     2 step_status_cd = f8
 )
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 DECLARE qrlstartdate = q8 WITH protect
 DECLARE qrlenddate = q8 WITH protect
 SET qrlstartdate = cnvtdatetime(cnvtdate2( $STARTDATE,"DD-MMM-YYYY"),0)
 SET qrlenddate = datetimeadd(cnvtdatetime(cnvtdate2( $ENDDATE,"DD-MMM-YYYY"),0),1)
 IF (qrlstartdate > qrlenddate)
  GO TO exit_script
 ENDIF
 DECLARE nrlrefcnt = i4 WITH noconstant(0), protect
 DECLARE g_parse_txt = vc WITH noconstant(nullterm(trim( $PROCEDURESTATUS)))
 DECLARE g_parse_sep = c1 WITH noconstant("|")
 DECLARE nparsedone = i2 WITH protect
 DECLARE nparampos = i2 WITH protect
 DECLARE ncurpos = i4 WITH protect
 DECLARE nitemcnt = i4 WITH protect
 DECLARE dcodevalue = f8 WITH protect
 DECLARE struartext = vc WITH protect
 DECLARE dphysicianid = f8 WITH protect
 DECLARE dactivitysubtype = f8 WITH protect
 DECLARE nrlstatusidx = i4 WITH noconstant(0), protect
 DECLARE nrlstatussize = i4 WITH noconstant(0), protect
 DECLARE nrlstatuspad = i4 WITH noconstant(4), protect
 DECLARE org_sec_ind = f8 WITH protect, noconstant(0)
 IF (( $PHYSICIANID > 0.0))
  SET dphysicianid =  $PHYSICIANID
 ENDIF
 IF (( $ACTIVITYSUBTYPE > 0.0))
  SET dactivitysubtype =  $ACTIVITYSUBTYPE
 ENDIF
 DECLARE c_steptype_refletter = f8 WITH constant(uar_get_code_by("MEANING",4001923,"REFLETTER")),
 protect
 DECLARE getorgsecurityind(dummy) = null WITH protect
 IF (size(g_parse_txt) > 0)
  CALL parse_status(g_parse_sep,g_parse_txt)
 ENDIF
 SET nrlstatussize = size(stepstatus->step,5)
 IF (nrlstatussize > nrlstatuspad)
  SET nrlstatuspad = nrlstatussize
 ELSEIF (nrlstatussize > 0)
  SET stat = alterlist(stepstatus->step,nrlstatuspad)
  FOR (nrlstatusidx = (nrlstatussize+ 1) TO nrlstatuspad)
    SET stepstatus->step[nrlstatusidx].step_status_cd = stepstatus->step[nrlstatussize].
    step_status_cd
  ENDFOR
 ENDIF
 CALL getorgsecurityind(0)
 SELECT
  IF (dphysicianid <= 0
   AND nrlstatussize > 0
   AND ( $ORG_ID=0.0)
   AND org_sec_ind=0.0)
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(qrlstartdate)
     AND c.action_dt_tm < cnvtdatetime(qrlenddate)
     AND c.activity_subtype_cd=evaluate(dactivitysubtype,0.0,c.activity_subtype_cd,dactivitysubtype))
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id
     AND expand(nrlstatusidx,1,nrlstatuspad,cs.step_status_cd,stepstatus->step[nrlstatusidx].
     step_status_cd))
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd
     AND csr.step_type_cd=c_steptype_refletter)
    JOIN (p
    WHERE p.person_id=c.prim_physician_id)
    JOIN (e
    WHERE e.encntr_id=c.encntr_id)
  ELSEIF (dphysicianid <= 0
   AND nrlstatussize > 0
   AND ( $ORG_ID=0.0)
   AND org_sec_ind=1.0)
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(qrlstartdate)
     AND c.action_dt_tm < cnvtdatetime(qrlenddate)
     AND c.activity_subtype_cd=evaluate(dactivitysubtype,0.0,c.activity_subtype_cd,dactivitysubtype))
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id
     AND expand(nrlstatusidx,1,nrlstatuspad,cs.step_status_cd,stepstatus->step[nrlstatusidx].
     step_status_cd))
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd
     AND csr.step_type_cd=c_steptype_refletter)
    JOIN (p
    WHERE p.person_id=c.prim_physician_id)
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND e.organization_id IN (
    (SELECT DISTINCT
     p.organization_id
     FROM prsnl_org_reltn p
     WHERE (p.person_id=reqinfo->updt_id))))
  ELSEIF (dphysicianid <= 0
   AND nrlstatussize > 0
   AND ( $ORG_ID > 0.0))
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(qrlstartdate)
     AND c.action_dt_tm < cnvtdatetime(qrlenddate)
     AND c.activity_subtype_cd=evaluate(dactivitysubtype,0.0,c.activity_subtype_cd,dactivitysubtype))
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id
     AND expand(nrlstatusidx,1,nrlstatuspad,cs.step_status_cd,stepstatus->step[nrlstatusidx].
     step_status_cd))
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd
     AND csr.step_type_cd=c_steptype_refletter)
    JOIN (p
    WHERE p.person_id=c.prim_physician_id)
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND (e.organization_id= $ORG_ID))
  ELSEIF (dphysicianid > 0
   AND nrlstatussize <= 0
   AND ( $ORG_ID=0.0)
   AND org_sec_ind=0.0)
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(qrlstartdate)
     AND c.action_dt_tm < cnvtdatetime(qrlenddate)
     AND c.prim_physician_id=dphysicianid
     AND c.activity_subtype_cd=evaluate(dactivitysubtype,0.0,c.activity_subtype_cd,dactivitysubtype))
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id)
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd
     AND csr.step_type_cd=c_steptype_refletter)
    JOIN (p
    WHERE p.person_id=c.prim_physician_id)
    JOIN (e
    WHERE e.encntr_id=c.encntr_id)
  ELSEIF (dphysicianid > 0
   AND nrlstatussize <= 0
   AND ( $ORG_ID=0.0)
   AND org_sec_ind=1.0)
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(qrlstartdate)
     AND c.action_dt_tm < cnvtdatetime(qrlenddate)
     AND c.prim_physician_id=dphysicianid
     AND c.activity_subtype_cd=evaluate(dactivitysubtype,0.0,c.activity_subtype_cd,dactivitysubtype))
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id)
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd
     AND csr.step_type_cd=c_steptype_refletter)
    JOIN (p
    WHERE p.person_id=c.prim_physician_id)
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND e.organization_id IN (
    (SELECT DISTINCT
     p.organization_id
     FROM prsnl_org_reltn p
     WHERE (p.person_id=reqinfo->updt_id))))
  ELSEIF (dphysicianid > 0
   AND nrlstatussize <= 0
   AND ( $ORG_ID > 0.0))
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(qrlstartdate)
     AND c.action_dt_tm < cnvtdatetime(qrlenddate)
     AND c.prim_physician_id=dphysicianid
     AND c.activity_subtype_cd=evaluate(dactivitysubtype,0.0,c.activity_subtype_cd,dactivitysubtype))
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id)
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd
     AND csr.step_type_cd=c_steptype_refletter)
    JOIN (p
    WHERE p.person_id=c.prim_physician_id)
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND (e.organization_id= $ORG_ID))
  ELSEIF (dphysicianid > 0
   AND nrlstatussize > 0
   AND ( $ORG_ID=0.0)
   AND org_sec_ind=0.0)
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(qrlstartdate)
     AND c.action_dt_tm < cnvtdatetime(qrlenddate)
     AND c.prim_physician_id=dphysicianid
     AND c.activity_subtype_cd=evaluate(dactivitysubtype,0.0,c.activity_subtype_cd,dactivitysubtype))
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id
     AND expand(nrlstatusidx,1,nrlstatuspad,cs.step_status_cd,stepstatus->step[nrlstatusidx].
     step_status_cd))
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd
     AND csr.step_type_cd=c_steptype_refletter)
    JOIN (p
    WHERE p.person_id=c.prim_physician_id)
    JOIN (e
    WHERE e.encntr_id=c.encntr_id)
  ELSEIF (dphysicianid > 0
   AND nrlstatussize > 0
   AND ( $ORG_ID=0.0)
   AND org_sec_ind=1.0)
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(qrlstartdate)
     AND c.action_dt_tm < cnvtdatetime(qrlenddate)
     AND c.prim_physician_id=dphysicianid
     AND c.activity_subtype_cd=evaluate(dactivitysubtype,0.0,c.activity_subtype_cd,dactivitysubtype))
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id
     AND expand(nrlstatusidx,1,nrlstatuspad,cs.step_status_cd,stepstatus->step[nrlstatusidx].
     step_status_cd))
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd
     AND csr.step_type_cd=c_steptype_refletter)
    JOIN (p
    WHERE p.person_id=c.prim_physician_id)
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND e.organization_id IN (
    (SELECT DISTINCT
     p.organization_id
     FROM prsnl_org_reltn p
     WHERE (p.person_id=reqinfo->updt_id))))
  ELSEIF (dphysicianid > 0
   AND nrlstatussize > 0
   AND ( $ORG_ID > 0.0))
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(qrlstartdate)
     AND c.action_dt_tm < cnvtdatetime(qrlenddate)
     AND c.prim_physician_id=dphysicianid
     AND c.activity_subtype_cd=evaluate(dactivitysubtype,0.0,c.activity_subtype_cd,dactivitysubtype))
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id
     AND expand(nrlstatusidx,1,nrlstatuspad,cs.step_status_cd,stepstatus->step[nrlstatusidx].
     step_status_cd))
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd
     AND csr.step_type_cd=c_steptype_refletter)
    JOIN (p
    WHERE p.person_id=c.prim_physician_id)
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND (e.organization_id= $ORG_ID))
  ELSEIF (dphysicianid <= 0
   AND nrlstatussize <= 0
   AND ( $ORG_ID=0.0)
   AND org_sec_ind=0.0)
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(qrlstartdate)
     AND c.action_dt_tm < cnvtdatetime(qrlenddate)
     AND c.activity_subtype_cd=evaluate(dactivitysubtype,0.0,c.activity_subtype_cd,dactivitysubtype))
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id)
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd
     AND csr.step_type_cd=c_steptype_refletter)
    JOIN (p
    WHERE p.person_id=c.prim_physician_id)
    JOIN (e
    WHERE e.encntr_id=c.encntr_id)
  ELSEIF (dphysicianid <= 0
   AND nrlstatussize <= 0
   AND ( $ORG_ID=0.0)
   AND org_sec_ind=1.0)
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(qrlstartdate)
     AND c.action_dt_tm < cnvtdatetime(qrlenddate)
     AND c.activity_subtype_cd=evaluate(dactivitysubtype,0.0,c.activity_subtype_cd,dactivitysubtype))
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id)
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd
     AND csr.step_type_cd=c_steptype_refletter)
    JOIN (p
    WHERE p.person_id=c.prim_physician_id)
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND e.organization_id IN (
    (SELECT DISTINCT
     p.organization_id
     FROM prsnl_org_reltn p
     WHERE (p.person_id=reqinfo->updt_id))))
  ELSEIF (dphysicianid <= 0
   AND nrlstatussize <= 0
   AND ( $ORG_ID > 0.0))
   PLAN (c
    WHERE c.action_dt_tm >= cnvtdatetime(qrlstartdate)
     AND c.action_dt_tm < cnvtdatetime(qrlenddate)
     AND c.activity_subtype_cd=evaluate(dactivitysubtype,0.0,c.activity_subtype_cd,dactivitysubtype))
    JOIN (cs
    WHERE cs.cv_proc_id=c.cv_proc_id)
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd
     AND csr.step_type_cd=c_steptype_refletter)
    JOIN (p
    WHERE p.person_id=c.prim_physician_id)
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND (e.organization_id= $ORG_ID))
  ELSE
  ENDIF
  INTO "NL:"
  FROM cv_proc c,
   cv_step cs,
   cv_step_ref csr,
   prsnl p,
   encounter e
  PLAN (c
   WHERE c.action_dt_tm >= cnvtdatetime(qrlstartdate)
    AND c.action_dt_tm < cnvtdatetime(qrlenddate)
    AND c.activity_subtype_cd=evaluate(dactivitysubtype,0.0,c.activity_subtype_cd,dactivitysubtype))
   JOIN (cs
   WHERE cs.cv_proc_id=c.cv_proc_id)
   JOIN (csr
   WHERE csr.task_assay_cd=cs.task_assay_cd
    AND csr.step_type_cd=c_steptype_refletter)
   JOIN (p
   WHERE p.person_id=c.prim_physician_id)
   JOIN (e
   WHERE e.encntr_id=c.encntr_id
    AND (e.organization_id= $ORG_ID))
  HEAD REPORT
   nrlrefcnt = 0
  DETAIL
   nrlrefcnt += 1
   IF (mod(nrlrefcnt,10)=1)
    stat = alterlist(reply->referral_rep,(nrlrefcnt+ 9))
   ENDIF
   reply->referral_rep[nrlrefcnt].primary_phy = trim(p.name_full_formatted), reply->referral_rep[
   nrlrefcnt].description = trim(uar_get_code_display(cs.task_assay_cd)), reply->referral_rep[
   nrlrefcnt].proc_disp = trim(uar_get_code_display(c.catalog_cd)),
   reply->referral_rep[nrlrefcnt].status_disp = trim(uar_get_code_display(cs.step_status_cd)), reply
   ->referral_rep[nrlrefcnt].proc_date = c.action_dt_tm, reply->referral_rep[nrlrefcnt].gen_date = cs
   .perf_start_dt_tm
  FOOT REPORT
   stat = alterlist(reply->referral_rep,nrlrefcnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SUBROUTINE (parse_status(param_sep=vc(ref),param_string=vc(ref)) =null)
   SET nparsedone = 0
   SET nparampos = 1
   SET nitemcnt = 0
   WHILE (nparsedone=0)
     SET ncurpos = findstring(param_sep,param_string,nparampos)
     IF (ncurpos=0)
      SET ncurpos = (size(param_string,1)+ 1)
      SET nparsedone = 1
     ENDIF
     SET struartext = trim(substring(nparampos,(ncurpos - nparampos),param_string),3)
     IF (size(struartext) > 0)
      SET dcodevalue = uar_get_code_by("MEANING",4000440,nullterm(trim(struartext)))
      IF (dcodevalue > 0.0)
       SET nitemcnt += 1
       SET stat = alterlist(stepstatus->step,nitemcnt)
       SET stepstatus->step[nitemcnt].step_status_cd = dcodevalue
      ENDIF
     ENDIF
     SET nparampos = (ncurpos+ size(param_sep,1))
   ENDWHILE
 END ;Subroutine
 SUBROUTINE getorgsecurityind(dummy)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="SECURITY"
     AND di.info_name="SEC_ORG_RELTN"
    DETAIL
     org_sec_ind = di.info_number
   ;end select
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="Z"))
  CALL cv_log_msg(cv_info,"CV_FRPT_REFERRAL_LTR_DRV returned status = Z ")
 ELSEIF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_FRPT_REFERRAL_LTR_DRV FAILED!")
  CALL echorecord(reply)
 ENDIF
 CALL cv_log_msg_post("MOD 003 12/29/2010 DB019235")
END GO
