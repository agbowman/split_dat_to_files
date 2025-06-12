CREATE PROGRAM dcp_ops_pw_cleanup_expire:dba
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
 FREE RECORD exception_criteria
 RECORD exception_criteria(
   1 criteria[*]
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
     2 add_to_request_ind = i2
     2 type_mean = vc
     2 pathway_group_id = f8
 )
 FREE RECORD outcome
 RECORD outcome(
   1 outcomes[*]
     2 outcomeactid = f8
     2 outcomestatuscd = f8
     2 updtcnt = i4
 )
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE cexpiretypemean = c12 WITH constant("EXPIRATION"), protect
 DECLARE ccareplantypemean = c12 WITH constant("CAREPLAN"), protect
 DECLARE cphasetypemean = c12 WITH constant("PHASE"), protect
 DECLARE csubphasetypemean = c12 WITH constant("SUBPHASE"), protect
 DECLARE cdottypemean = c12 WITH constant("DOT"), protect
 DECLARE stat = i2 WITH noconstant(0), protect
 DECLARE icriteriacnt = i4 WITH noconstant(0), protect
 DECLARE dplannedstatuscd = f8 WITH constant(uar_get_code_by("MEANING",16769,"PLANNED")), protect
 DECLARE dfuturestatuscd = f8 WITH constant(uar_get_code_by("MEANING",16769,"FUTURE")), protect
 DECLARE dhourscd = f8 WITH constant(uar_get_code_by("MEANING",340,"HOURS")), protect
 DECLARE iindex = i4 WITH noconstant(0), protect
 DECLARE itimeqty = i4 WITH noconstant(0), protect
 DECLARE dtimeunitcd = f8 WITH noconstant(0.0), protect
 DECLARE iglobaltimeqty = i4 WITH noconstant(0), protect
 DECLARE dglobaltimeunitcd = f8 WITH noconstant(dhourscd), protect
 DECLARE parameter_value = vc
 DECLARE imaxphasestodisc = i4 WITH noconstant(0), protect
 DECLARE ddate = dq8
 DECLARE dcurrentdate = dq8
 DECLARE iphasecnt = i4 WITH noconstant(0), protect
 DECLARE inumberofphasesbeingdiscontinued = i4 WITH noconstant(0), protect
 DECLARE bmaxphasecountmet = i2 WITH protect, noconstant(0)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE exception_size = i4 WITH protect, noconstant(0)
 DECLARE phase_size = i4 WITH protect, noconstant(0)
 DECLARE dactivatedoutcomecd = f8 WITH constant(uar_get_code_by("MEANING",30182,"ACTIVATED"))
 DECLARE dfutureoutcomecd = f8 WITH constant(uar_get_code_by("MEANING",30182,"FUTURE"))
 DECLARE ddiscontinueoutcomecd = f8 WITH constant(uar_get_code_by("MEANING",30182,"DISCONTINUED"))
 DECLARE dresoutcometypecd = f8 WITH constant(uar_get_code_by("MEANING",16750,"RESULT OUTCO"))
 DECLARE outcome_cnt = i4 WITH protect, noconstant(0)
 DECLARE outcome_size = i4 WITH protect, noconstant(0)
 DECLARE outcome_add = i4 WITH protect, noconstant(0)
 DECLARE datediff = f8 WITH noconstant(0.0), protect
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
   AND pmc.type_mean=cexpiretypemean
  DETAIL
   iglobaltimeqty = pmc.time_qty, dglobaltimeunitcd = pmc.time_unit_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL report_failure("LOAD_GLOBAL_EXPIRATION_CRITERIA","F","DCP_OPS_PW_CLEANUP_EXPIRE",
   "Unable to find PW_MAINTENANCE_CRITERIA global expiration record")
  SET cstatus = "F"
  GO TO exit_script
 ELSEIF (curqual > 1)
  CALL report_failure("LOAD_GLOBAL_EXPIRATION_CRITERIA","F","DCP_OPS_PW_CLEANUP_EXPIRE",
   "Found invalid number of PW_MAINTENANCE_CRITERIA global expiration records")
  SET cstatus = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM pw_maintenance_criteria pmc,
   pathway_catalog pc
  PLAN (pmc
   WHERE pmc.type_mean=cexpiretypemean
    AND pmc.version_pw_cat_id != 0)
   JOIN (pc
   WHERE (pmc.version_pw_cat_id= Outerjoin(pc.version_pw_cat_id)) )
  ORDER BY pc.pathway_catalog_id
  HEAD REPORT
   icriteriacnt = 0, stat = alterlist(exception_criteria->criteria,5), exception_size = 5
  DETAIL
   icriteriacnt += 1
   IF (icriteriacnt > exception_size)
    stat = alterlist(exception_criteria->criteria,(icriteriacnt+ 4)), exception_size = (icriteriacnt
    + 4)
   ENDIF
   exception_criteria->criteria[icriteriacnt].pathway_catalog_id = pc.pathway_catalog_id,
   exception_criteria->criteria[icriteriacnt].time_qty = pmc.time_qty, exception_criteria->criteria[
   icriteriacnt].time_unit_cd = pmc.time_unit_cd
  FOOT REPORT
   stat = alterlist(exception_criteria->criteria,icriteriacnt), exception_size = icriteriacnt
  WITH nocounter
 ;end select
 SELECT INTO "n1:"
  FROM pathway p
  WHERE ((p.pw_status_cd=dplannedstatuscd) OR (p.pw_status_cd=dfuturestatuscd))
   AND ((p.type_mean=ccareplantypemean) OR (((p.type_mean=cphasetypemean) OR (p.type_mean=
  cdottypemean)) ))
   AND p.pw_cat_group_id != 0
  ORDER BY p.pw_cat_group_id, p.pw_group_nbr, p.pathway_group_id,
   p.pathway_id
  HEAD REPORT
   bmaxphasecountmet = 0, iphasecnt = 0, inumberofphasesbeingdiscontinued = 0,
   stat = alterlist(discontinue->phases,batch_size), loop_cnt = 1, phase_size = batch_size,
   bexpireddot = 0, ifirstphase = 0, idiscontinueindex = 0,
   dcurrentdate = cnvtdatetime(sysdate), dcurrentdate = cnvtdatetimeutc(dcurrentdate,3)
  HEAD p.pw_cat_group_id
   iindex = locatevalsort(iindex,1,value(size(exception_criteria->criteria,5)),p.pw_cat_group_id,
    exception_criteria->criteria[iindex].pathway_catalog_id)
   IF (iindex > 0)
    itimeqty = exception_criteria->criteria[iindex].time_qty, dtimeunitcd = exception_criteria->
    criteria[iindex].time_unit_cd
   ELSE
    itimeqty = iglobaltimeqty, dtimeunitcd = dglobaltimeunitcd
   ENDIF
  HEAD p.pw_group_nbr
   ifirstphase = 0, idiscontinueindex = 0
  HEAD p.pathway_group_id
   bexpireddot = 0
   IF (inumberofphasesbeingdiscontinued >= imaxphasestodisc)
    bmaxphasecountmet = 1
   ENDIF
  DETAIL
   IF (bmaxphasecountmet=0)
    IF (((p.pathway_group_id <= 0.0) OR (p.type_mean=cdottypemean)) )
     IF (p.start_dt_tm)
      ddate = cnvtdatetimeutc(p.start_dt_tm,3,p.start_tz)
     ELSE
      ddate = cnvtdatetimeutc(p.order_dt_tm,3,p.order_tz)
     ENDIF
     ddate = cnvtlookahead(build(itimeqty,",H"),cnvtdatetime(ddate)), datediff = datetimediff(
      cnvtdatetime(ddate),cnvtdatetime(dcurrentdate))
     IF (((datediff <= 0.0) OR (p.type_mean=cdottypemean)) )
      iphasecnt += 1
      IF (iphasecnt > phase_size)
       stat = alterlist(discontinue->phases,(iphasecnt+ (batch_size - 1))), loop_cnt += 1, phase_size
        = (iphasecnt+ (batch_size - 1))
      ENDIF
      discontinue->phases[iphasecnt].pathway_id = p.pathway_id, discontinue->phases[iphasecnt].
      pw_group_nbr = p.pw_group_nbr, discontinue->phases[iphasecnt].encntr_id = p.encntr_id,
      discontinue->phases[iphasecnt].updt_cnt = p.updt_cnt, discontinue->phases[iphasecnt].type_mean
       = trim(p.type_mean), discontinue->phases[iphasecnt].pathway_group_id = p.pathway_group_id
      IF (ifirstphase=0)
       ifirstphase = iphasecnt
      ENDIF
      IF (((datediff <= 0.0) OR (bexpireddot=1
       AND p.type_mean=cdottypemean)) )
       discontinue->phases[iphasecnt].add_to_request_ind = 1, inumberofphasesbeingdiscontinued += 1
       IF (bexpireddot=0
        AND p.type_mean=cdottypemean)
        bexpireddot = 1
        IF (ifirstphase > 0)
         FOR (idiscontinueindex = ifirstphase TO iphasecnt)
           IF ((discontinue->phases[idiscontinueindex].type_mean=cdottypemean)
            AND (discontinue->phases[idiscontinueindex].pathway_group_id=p.pathway_group_id))
            IF ((discontinue->phases[idiscontinueindex].add_to_request_ind=0))
             discontinue->phases[idiscontinueindex].add_to_request_ind = 1,
             inumberofphasesbeingdiscontinued += 1
            ENDIF
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (iphasecnt <= 0)
  CALL report_failure("LOAD_PHASES TO DISCONTINUE","F","DCP_OPS_MAINT_PW_CLEANUP_EXPIRE",
   "Unable to find careplans and phases to discontinue")
  SET cstatus = "F"
  GO TO exit_script
 ENDIF
 FOR (iindex = (iphasecnt+ 1) TO phase_size)
   SET discontinue->phases[iindex].pathway_id = discontinue->phases[iphasecnt].pathway_id
   SET discontinue->phases[iindex].pw_group_nbr = discontinue->phases[iphasecnt].pw_group_nbr
   SET discontinue->phases[iindex].encntr_id = discontinue->phases[iphasecnt].encntr_id
   SET discontinue->phases[iindex].updt_cnt = discontinue->phases[iphasecnt].updt_cnt
   SET discontinue->phases[iindex].add_to_request_ind = discontinue->phases[iphasecnt].
   add_to_request_ind
 ENDFOR
 SET iindex = 0
 SET start = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
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
    AND ((p.pw_status_cd=dplannedstatuscd) OR (p.pw_status_cd=dfuturestatuscd)) )
  DETAIL
   iphasecnt += 1
   IF (iphasecnt > phase_size)
    stat = alterlist(discontinue->phases,(iphasecnt+ (batch_size - 1))), phase_size = (iphasecnt+ (
    batch_size - 1)), loop_cnt += 1
   ENDIF
   discontinue->phases[iphasecnt].pathway_id = p.pathway_id, discontinue->phases[iphasecnt].
   pw_group_nbr = p.pw_group_nbr, discontinue->phases[iphasecnt].encntr_id = p.encntr_id,
   discontinue->phases[iphasecnt].updt_cnt = p.updt_cnt, discontinue->phases[iphasecnt].
   add_to_request_ind = 1
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
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   act_pw_comp apc,
   outcome_activity oa
  PLAN (d1
   WHERE initarray(start,evaluate(d1.seq,1,1,(start+ batch_size))))
   JOIN (apc
   WHERE expand(iindex,start,(start+ (batch_size - 1)),apc.pathway_id,discontinue->phases[iindex].
    pathway_id,
    1,discontinue->phases[iindex].add_to_request_ind)
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
    outcome_cnt += 1
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
  CALL report_failure("CREATE_APPLICATION_HANDLE","F","DCP_OPS_PW_CLEANUP_EXPIRE",
   "Unable to create application handle when calling DCP.PwDiscontinuePhases")
  SET cstatus = "F"
 ENDIF
 IF (uar_crmbegintask(happlication,l_task,htask) != 0)
  CALL report_failure("CREATE_TASK_HANDLE","F","DCP_OPS_PW_CLEANUP_EXPIRE",
   "Unable to create task handle when calling DCP.PwDiscontinuePhases")
  SET cstatus = "F"
 ENDIF
 IF (uar_crmbeginreq(htask,"",l_step,hstep) != 0)
  CALL report_failure("CREATE_STEP_HANDLE","F","DCP_OPS_PW_CLEANUP_EXPIRE",
   "Unable to create step handle when calling DCP.PwDiscontinuePhases")
  SET cstatus = "F"
 ENDIF
 SET hrequest = uar_crmgetrequest(hstep)
 IF (hrequest <= 0)
  CALL report_failure("CREATE_REQUEST_HANDLE","F","DCP_OPS_PW_CLEANUP_EXPIRE",
   "Unable to create request handle when calling DCP.PwDiscontinuePhases")
  SET cstatus = "F"
 ENDIF
 FOR (iindex = 1 TO iphasecnt)
   IF ((discontinue->phases[iindex].add_to_request_ind=1))
    SET hitem = uar_srvadditem(hrequest,"phases")
    IF (hitem <= 0)
     CALL report_failure("CREATE_ITEM_HANDLE","F","DCP_OPS_PW_CLEANUP_EXPIRE",
      "Unable to create item handle for request when calling DCP.PwDiscontinuePhases")
     SET iindex = iphasecnt
    ELSE
     SET l_stat = uar_srvsetdouble(hitem,"pw_group_nbr",discontinue->phases[iindex].pw_group_nbr)
     SET l_stat = uar_srvsetdouble(hitem,"pathway_id",discontinue->phases[iindex].pathway_id)
     SET l_stat = uar_srvsetdouble(hitem,"encntr_id",discontinue->phases[iindex].encntr_id)
     SET l_stat = uar_srvsetlong(hitem,"updt_cnt",discontinue->phases[iindex].updt_cnt)
    ENDIF
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
 SUBROUTINE (report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) =null)
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt += 1
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
