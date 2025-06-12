CREATE PROGRAM dcp_ops_pw_cleanup_discharge:dba
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD global_criteria
 RECORD global_criteria(
   1 criteria[*]
     2 encounter_type_flag = i2
     2 time_qty = i4
     2 time_unit_cd = f8
 )
 FREE RECORD exception_criteria
 RECORD exception_criteria(
   1 criteria[*]
     2 encounter_type_flag = i2
     2 pathway_catalog_id = f8
     2 time_qty = i4
     2 time_unit_cd = f8
 )
 FREE RECORD discontinue
 RECORD discontinue(
   1 phases[*]
     2 pw_group_nbr = f8
     2 pathway_id = f8
     2 encntr_id = f8
     2 updt_cnt = i4
 )
 FREE RECORD outcome
 RECORD outcome(
   1 outcomes[*]
     2 outcomeactid = f8
     2 outcomestatuscd = f8
     2 updtcnt = i4
 )
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE cdischargetypemean = c12 WITH constant("DISCHARGE"), protect
 DECLARE ccareplantypemean = c12 WITH constant("CAREPLAN"), protect
 DECLARE cphasetypemean = c12 WITH constant("PHASE"), protect
 DECLARE csubphasetypemean = c12 WITH constant("SUBPHASE"), protect
 DECLARE cdottypemean = c12 WITH constant("DOT"), protect
 DECLARE stat = i2 WITH noconstant(0), protect
 DECLARE icriteriacnt = i4 WITH noconstant(0), protect
 DECLARE iphasecnt = i4 WITH noconstant(0), protect
 DECLARE dplannedstatuscd = f8 WITH constant(uar_get_code_by("MEANING",16769,"PLANNED")), protect
 DECLARE dfuturestatuscd = f8 WITH constant(uar_get_code_by("MEANING",16769,"FUTURE")), protect
 DECLARE dinitiatedstatuscd = f8 WITH constant(uar_get_code_by("MEANING",16769,"INITIATED")), protect
 DECLARE ddiscontinuedstatuscd = f8 WITH constant(uar_get_code_by("MEANING",16769,"DISCONTINUED")),
 protect
 DECLARE dvoidstatuscd = f8 WITH constant(uar_get_code_by("MEANING",16769,"VOID")), protect
 DECLARE dcompletedstatuscd = f8 WITH constant(uar_get_code_by("MEANING",16769,"COMPLETED")), protect
 DECLARE dskippedstatuscd = f8 WITH constant(uar_get_code_by("MEANING",16769,"SKIPPED")), protect
 DECLARE dinitreviewedstatuscd = f8 WITH constant(uar_get_code_by("MEANING",16769,"INITREVIEW")),
 protect
 DECLARE dinpatientenctrcd = f8 WITH constant(uar_get_code_by("MEANING",69,"INPATIENT")), protect
 DECLARE ddischargedstatuscd = f8 WITH constant(uar_get_code_by("MEANING",261,"DISCHARGED")), protect
 DECLARE dhourscd = f8 WITH constant(uar_get_code_by("MEANING",340,"HOURS")), protect
 DECLARE dfuturereviewstatuscd = f8 WITH constant(uar_get_code_by("MEANING",16769,"FUTUREREVIEW")),
 protect
 DECLARE parameter_value = vc
 DECLARE imaxphasestodisc = i4 WITH noconstant(0), protect
 DECLARE iinpttimeqty = i4 WITH noconstant(0), protect
 DECLARE dinpttimeunitcd = f8 WITH noconstant(dhourscd), protect
 DECLARE iothertimeqty = i4 WITH noconstant(0), protect
 DECLARE dothertimeunitcd = f8 WITH noconstant(dhourscd), protect
 DECLARE itimeqty = i4 WITH noconstant(0), protect
 DECLARE dtimeunitcd = f8 WITH noconstant(0.0), protect
 DECLARE iindex = i4 WITH noconstant(0), protect
 DECLARE start = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE ddate = dq8
 DECLARE dcurrentdate = dq8
 DECLARE phase_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE sib_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE exception_size = i4 WITH protect, noconstant(0)
 DECLARE phase_size = i4 WITH protect, noconstant(0)
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 DECLARE dactivatedoutcomecd = f8 WITH constant(uar_get_code_by("MEANING",30182,"ACTIVATED"))
 DECLARE dfutureoutcomecd = f8 WITH constant(uar_get_code_by("MEANING",30182,"FUTURE"))
 DECLARE ddiscontinueoutcomecd = f8 WITH constant(uar_get_code_by("MEANING",30182,"DISCONTINUED"))
 DECLARE dresoutcometypecd = f8 WITH constant(uar_get_code_by("MEANING",16750,"RESULT OUTCO"))
 DECLARE outcome_cnt = i4 WITH protect, noconstant(0)
 DECLARE outcome_size = i4 WITH protect, noconstant(0)
 DECLARE outcome_add = i4 WITH protect, noconstant(0)
 SET parameter_value = parameter(1,0)
 IF (parameter_value=" ")
  SET imaxphasestodisc = 500
 ELSE
  SET imaxphasestodisc = cnvtint(parameter_value)
  IF (imaxphasestodisc < batch_size)
   SET imaxphasestodisc = batch_size
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM pw_maintenance_criteria pmc
  WHERE pmc.version_pw_cat_id=0
   AND pmc.type_mean=cdischargetypemean
  ORDER BY pmc.encounter_type_flag
  HEAD REPORT
   icriteriacnt = 0, stat = alterlist(global_criteria->criteria,2)
  DETAIL
   IF (pmc.encounter_type_flag=1)
    iinpttimeqty = pmc.time_qty, dinpttimeunitcd = pmc.time_unit_cd
   ELSEIF (pmc.encounter_type_flag=2)
    iothertimeqty = pmc.time_qty, dothertimeunitcd = pmc.time_unit_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 2)
  CALL report_failure("LOAD_GLOBAL_DISCHARGE_CRITERIA","F","DCP_OPS_PW_CLEANUP_DISCHARGE",
   "Found invalid number of PW_MAINTENANCE_CRITERIA global discharge records")
  SET cstatus = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM pw_maintenance_criteria pmc,
   pathway_catalog pc
  PLAN (pmc
   WHERE pmc.type_mean=cdischargetypemean
    AND pmc.version_pw_cat_id != 0)
   JOIN (pc
   WHERE pmc.version_pw_cat_id=outerjoin(pc.version_pw_cat_id))
  ORDER BY pmc.encounter_type_flag, pc.pathway_catalog_id
  HEAD REPORT
   icriteriacnt = 0, stat = alterlist(exception_criteria->criteria,5), exception_size = 5
  DETAIL
   icriteriacnt = (icriteriacnt+ 1)
   IF (icriteriacnt > exception_size)
    stat = alterlist(exception_criteria->criteria,(icriteriacnt+ 4)), exception_size = (icriteriacnt
    + 4)
   ENDIF
   exception_criteria->criteria[icriteriacnt].encounter_type_flag = pmc.encounter_type_flag,
   exception_criteria->criteria[icriteriacnt].pathway_catalog_id = pc.pathway_catalog_id,
   exception_criteria->criteria[icriteriacnt].time_qty = pmc.time_qty,
   exception_criteria->criteria[icriteriacnt].time_unit_cd = pmc.time_unit_cd
  FOOT REPORT
   stat = alterlist(exception_criteria->criteria,icriteriacnt), exception_size = icriteriacnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  iencountertypeflag = evaluate(e.encntr_type_class_cd,dinpatientenctrcd,1,2)
  FROM pathway p,
   encounter e,
   pathway p2
  PLAN (p
   WHERE p.pw_status_cd IN (dplannedstatuscd, dfuturestatuscd, dinitiatedstatuscd,
   dinitreviewedstatuscd, dfuturereviewstatuscd)
    AND ((p.type_mean=ccareplantypemean) OR (((p.type_mean=cphasetypemean) OR (p.type_mean=
   cdottypemean)) )) )
   JOIN (p2
   WHERE p2.pw_group_nbr=p.pw_group_nbr
    AND p2.pw_status_cd IN (dinitiatedstatuscd, ddiscontinuedstatuscd, dcompletedstatuscd,
   dvoidstatuscd, dskippedstatuscd)
    AND p2.started_ind=1
    AND p2.encntr_id=p.encntr_id
    AND p2.pw_cat_group_id != 0)
   JOIN (e
   WHERE e.encntr_id=p2.encntr_id
    AND e.encntr_status_cd=ddischargedstatuscd)
  ORDER BY iencountertypeflag, p.pw_cat_group_id, p.pw_group_nbr,
   p.pathway_id
  HEAD REPORT
   iphasecnt = 0, phase_loop_cnt = 1, sib_loop_cnt = 1,
   stat = alterlist(discontinue->phases,batch_size), phase_size = batch_size, dcurrentdate =
   cnvtdatetime(curdate,curtime3),
   dcurrentdate = cnvtdatetimeutc(dcurrentdate,3)
  HEAD iencountertypeflag
   dummyt = 0
  HEAD p.pw_cat_group_id
   iindex = locatevalsort(iindex,1,exception_size,iencountertypeflag,exception_criteria->criteria[
    iindex].encounter_type_flag,
    p.pw_cat_group_id,exception_criteria->criteria[iindex].pathway_catalog_id)
   IF (iindex > 0)
    itimeqty = exception_criteria->criteria[iindex].time_qty, dtimeunitcd = exception_criteria->
    criteria[iindex].time_unit_cd
   ELSE
    IF (iencountertypeflag=1)
     itimeqty = iinpttimeqty, dtimeunitcd = dinpttimeunitcd
    ELSE
     itimeqty = iothertimeqty, dtimeunitcd = dothertimeunitcd
    ENDIF
   ENDIF
  HEAD p.pw_group_nbr
   IF ((imaxphasestodisc <= (iphasecnt+ 1)))
    CALL cancel(1)
   ENDIF
  HEAD p.pathway_id
   IF (((p.pathway_group_id <= 0.0) OR (p.type_mean=cdottypemean)) )
    IF (e.disch_dt_tm)
     ddate = cnvtdatetimeutc(e.disch_dt_tm,3)
    ELSE
     ddate = dcurrentdate
    ENDIF
    ddate = cnvtlookahead(build(itimeqty,",H"),cnvtdatetime(ddate))
    IF (cnvtdatetime(ddate) <= cnvtdatetime(dcurrentdate)
     AND ((p.pw_status_cd=dinitiatedstatuscd) OR (p.cross_encntr_ind=0
     AND p.type_mean != ccareplantypemean)) )
     iphasecnt = (iphasecnt+ 1)
     IF (iphasecnt > phase_size)
      stat = alterlist(discontinue->phases,(iphasecnt+ (batch_size - 1))), phase_size = (iphasecnt+ (
      batch_size - 1)), phase_loop_cnt = (phase_loop_cnt+ 1)
     ENDIF
     discontinue->phases[iphasecnt].pathway_id = p.pathway_id, discontinue->phases[iphasecnt].
     pw_group_nbr = p.pw_group_nbr, discontinue->phases[iphasecnt].encntr_id = p.encntr_id,
     discontinue->phases[iphasecnt].updt_cnt = p.updt_cnt
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (iphasecnt <= 0)
  CALL report_failure("LOAD_PHASES TO DISCONTINUE","F","DCP_OPS_MAINT_PW_CLEANUP_EXPIRE",
   "Unable to find and careplans and phases to discontinue")
  SET cstatus = "Z"
  GO TO exit_script
 ENDIF
 FOR (iindex = (iphasecnt+ 1) TO phase_size)
   SET discontinue->phases[iindex].pathway_id = discontinue->phases[iphasecnt].pathway_id
   SET discontinue->phases[iindex].pw_group_nbr = discontinue->phases[iphasecnt].pw_group_nbr
   SET discontinue->phases[iindex].encntr_id = discontinue->phases[iphasecnt].encntr_id
   SET discontinue->phases[iindex].updt_cnt = discontinue->phases[iphasecnt].updt_cnt
 ENDFOR
 SET iindex = 0
 SET start = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(phase_loop_cnt)),
   pathway_reltn pr,
   pathway p
  PLAN (d1
   WHERE initarray(start,evaluate(d1.seq,1,1,(start+ batch_size))))
   JOIN (pr
   WHERE expand(iindex,start,(start+ (batch_size - 1)),pr.pathway_s_id,discontinue->phases[iindex].
    pathway_id)
    AND pr.type_mean=csubphasetypemean)
   JOIN (p
   WHERE p.pathway_id=pr.pathway_t_id
    AND ((p.pw_status_cd=dplannedstatuscd) OR (((p.pw_status_cd=dfuturestatuscd) OR (p.pw_status_cd=
   dinitiatedstatuscd)) )) )
  DETAIL
   iphasecnt = (iphasecnt+ 1)
   IF (iphasecnt > phase_size)
    stat = alterlist(discontinue->phases,(iphasecnt+ (batch_size - 1))), phase_size = (iphasecnt+ (
    batch_size - 1)), phase_loop_cnt = (phase_loop_cnt+ 1)
   ENDIF
   discontinue->phases[iphasecnt].pathway_id = p.pathway_id, discontinue->phases[iphasecnt].
   pw_group_nbr = p.pw_group_nbr, discontinue->phases[iphasecnt].encntr_id = p.encntr_id,
   discontinue->phases[iphasecnt].updt_cnt = p.updt_cnt
  WITH nocounter
 ;end select
 FOR (iindex = (iphasecnt+ 1) TO phase_size)
   SET discontinue->phases[iindex].pathway_id = discontinue->phases[iphasecnt].pathway_id
   SET discontinue->phases[iindex].pw_group_nbr = discontinue->phases[iphasecnt].pw_group_nbr
   SET discontinue->phases[iindex].encntr_id = discontinue->phases[iphasecnt].encntr_id
   SET discontinue->phases[iindex].updt_cnt = discontinue->phases[iphasecnt].updt_cnt
 ENDFOR
 SET stat = alterlist(outcome->outcomes,batch_size)
 SET outcome_size = batch_size
 SET iindex = 0
 SET start = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(phase_loop_cnt)),
   act_pw_comp apc,
   outcome_activity oa
  PLAN (d1
   WHERE initarray(start,evaluate(d1.seq,1,1,(start+ batch_size))))
   JOIN (apc
   WHERE expand(iindex,start,(start+ (batch_size - 1)),apc.pathway_id,discontinue->phases[iindex].
    pathway_id)
    AND apc.comp_type_cd=dresoutcometypecd
    AND apc.parent_entity_name="OUTCOME_ACTIVITY"
    AND apc.active_ind=1
    AND apc.parent_entity_id > 0)
   JOIN (oa
   WHERE oa.outcome_activity_id=apc.parent_entity_id
    AND ((oa.outcome_status_cd=dactivatedoutcomecd) OR (oa.outcome_status_cd=dfutureoutcomecd)) )
  DETAIL
   IF (oa.end_dt_tm
    AND oa.outcome_status_cd=dactivatedoutcomecd)
    ddate = cnvtdatetimeutc(oa.end_dt_tm,3)
    IF (cnvtdatetime(ddate) > cnvtdatetime(dcurrentdate))
     outcome_add = 1
    ENDIF
   ELSE
    outcome_add = 1
   ENDIF
   IF (outcome_add=1)
    outcome_cnt = (outcome_cnt+ 1)
    IF (outcome_cnt > outcome_size)
     stat = alterlist(outcome->outcomes,(outcome_cnt+ (batch_size - 1))), outcome_size = (outcome_cnt
     + (batch_size - 1))
    ENDIF
    outcome->outcomes[outcome_cnt].outcomeactid = oa.outcome_activity_id, outcome->outcomes[
    outcome_cnt].outcomestatuscd = ddiscontinueoutcomecd, outcome->outcomes[outcome_cnt].updtcnt = oa
    .updt_cnt,
    outcome_add = 0
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(discontinue->phases,iphasecnt)
 SET phase_size = iphasecnt
 SET stat = alterlist(outcome->outcomes,outcome_cnt)
 SET outcome_size = outcome_cnt
 DECLARE l_application = i4 WITH protect, noconstant(600005)
 DECLARE l_task = i4 WITH protect, noconstant(601500)
 DECLARE l_step = i4 WITH protect, noconstant(601504)
 DECLARE happlication = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hitem = i4 WITH public, noconstant(0)
 DECLARE hrequest = i4 WITH public, noconstant(0)
 EXECUTE crmrtl
 EXECUTE srvrtl
 IF (uar_crmbeginapp(l_application,happlication) != 0)
  CALL report_failure("CREATE_APPLICATION_HANDLE","F","DCP_OPS_PW_CLEANUP_DISCHARGE",
   "Unable to create application handle when calling DCP.PwDiscontinuePhases")
  SET cstatus = "F"
 ENDIF
 IF (uar_crmbegintask(happlication,l_task,htask) != 0)
  CALL report_failure("CREATE_TASK_HANDLE","F","DCP_OPS_PW_CLEANUP_DISCHARGE",
   "Unable to create task handle when calling DCP.PwDiscontinuePhases")
  SET cstatus = "F"
 ENDIF
 IF (uar_crmbeginreq(htask,"",l_step,hstep) != 0)
  CALL report_failure("CREATE_STEP_HANDLE","F","DCP_OPS_PW_CLEANUP_DISCHARGE",
   "Unable to create step handle when calling DCP.PwDiscontinuePhases")
  SET cstatus = "F"
 ENDIF
 SET hrequest = uar_crmgetrequest(hstep)
 IF (hrequest <= 0)
  CALL report_failure("CREATE_REQUEST_HANDLE","F","DCP_OPS_PW_CLEANUP_DISCHARGE",
   "Unable to create request handle when calling DCP.PwDiscontinuePhases")
  SET cstatus = "F"
 ENDIF
 FOR (iindex = 1 TO iphasecnt)
  SET hitem = uar_srvadditem(hrequest,"phases")
  IF (hitem <= 0)
   CALL report_failure("CREATE_ITEM_HANDLE","F","DCP_OPS_PW_CLEANUP_DISCHARGE",
    "Unable to create item handle for request when calling DCP.PwDiscontinuePhases")
   SET iindex = iphasecnt
  ELSE
   SET l_stat = uar_srvsetdouble(hitem,"pw_group_nbr",discontinue->phases[iindex].pw_group_nbr)
   SET l_stat = uar_srvsetdouble(hitem,"pathway_id",discontinue->phases[iindex].pathway_id)
   SET l_stat = uar_srvsetdouble(hitem,"encntr_id",discontinue->phases[iindex].encntr_id)
   SET l_stat = uar_srvsetlong(hitem,"updt_cnt",discontinue->phases[iindex].updt_cnt)
  ENDIF
 ENDFOR
 IF (uar_crmperform(hstep) != 0)
  CALL report_failure("PERFORM REQUEST","F","DCP_OPS_PW_CLEANUP_DISCHARGE",
   "Unable to perform request when calling DCP.PwDiscontinuePhases")
  SET cstatus = "F"
 ENDIF
 IF (hrequest > 0)
  CALL uar_crmendreq(hrequest)
 ENDIF
 IF (htask > 0)
  CALL uar_crmendtask(htask)
 ENDIF
 IF (happlication > 0)
  CALL uar_crmendapp(happlication)
 ENDIF
 SET l_application = 600005
 SET l_task = 601520
 SET l_step = 601520
 SET happlication = 0
 SET htask = 0
 SET hstep = 0
 SET hitem = 0
 SET hrequest = 0
 IF (uar_crmbeginapp(l_application,happlication) != 0)
  CALL report_failure("CREATE_APPLICATION_HANDLE","F","DCP_OPS_PW_CLEANUP_DISCHARGE",
   "Unable to create application handle when calling dcp_s601520")
  SET cstatus = "F"
 ENDIF
 IF (uar_crmbegintask(happlication,l_task,htask) != 0)
  CALL report_failure("CREATE_TASK_HANDLE","F","DCP_OPS_PW_CLEANUP_DISCHARGE",
   "Unable to create task handle when calling dcp_s601520")
  SET cstatus = "F"
 ENDIF
 IF (uar_crmbeginreq(htask,"",l_step,hstep) != 0)
  CALL report_failure("CREATE_STEP_HANDLE","F","DCP_OPS_PW_CLEANUP_DISCHARGE",
   "Unable to create step handle when calling dcp_s601520")
  SET cstatus = "F"
 ENDIF
 SET hrequest = uar_crmgetrequest(hstep)
 IF (hrequest <= 0)
  CALL report_failure("CREATE_REQUEST_HANDLE","F","DCP_OPS_PW_CLEANUP_DISCHARGE",
   "Unable to create request handle when calling dcp_s601520")
  SET cstatus = "F"
 ENDIF
 FOR (iindex = 1 TO outcome_cnt)
  SET hitem = uar_srvadditem(hrequest,"outcomes")
  IF (hitem <= 0)
   CALL report_failure("CREATE_ITEM_HANDLE","F","DCP_OPS_PW_CLEANUP_DISCHARGE",
    "Unable to create item handle for request when calling dcp_s601520")
   SET iindex = outcome_cnt
  ELSE
   SET l_stat = uar_srvsetstring(hitem,"action","DISCHARGE")
   SET l_stat = uar_srvsetdouble(hitem,"outcomeActId",outcome->outcomes[iindex].outcomeactid)
   SET l_stat = uar_srvsetdouble(hitem,"outcomeStatusCd",outcome->outcomes[iindex].outcomestatuscd)
   SET l_stat = uar_srvsetlong(hitem,"updtCnt",outcome->outcomes[iindex].updtcnt)
  ENDIF
 ENDFOR
 IF (uar_crmperform(hstep) != 0)
  CALL report_failure("PERFORM REQUEST","F","DCP_OPS_PW_CLEANUP_DISCHARGE",
   "Unable to perform request when calling dcp_s601520")
  SET cstatus = "F"
 ENDIF
 IF (hrequest > 0)
  CALL uar_crmendreq(hrequest)
 ENDIF
 IF (htask > 0)
  CALL uar_crmendtask(htask)
 ENDIF
 IF (happlication > 0)
  CALL uar_crmendapp(happlication)
 ENDIF
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt = (cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
 SET cstatus = "S"
#exit_script
 SET reply->status_data.status = cstatus
END GO
