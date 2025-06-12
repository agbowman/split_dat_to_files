CREATE PROGRAM dcp_ops_pw_cleanup_proposed:dba
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
 FREE RECORD withdraw
 RECORD withdraw(
   1 patient[*]
     2 patient_id = f8
     2 plan_count = i4
     2 plans[*]
       3 pw_group_nbr = f8
       3 pw_cat_group_id = f8
       3 pw_cat_version = i4
       3 pw_group_desc = vc
       3 pathway_type_cd = f8
       3 phase_count = i4
       3 phases[*]
         4 pathway_id = f8
         4 encntr_id = f8
         4 updt_cnt = i4
         4 type_mean = vc
         4 description = vc
         4 pathway_catalog_id = f8
         4 display_method_cd = f8
         4 pathway_group_id = f8
         4 parent_phase_desc = vc
         4 start_dt_tm = dq8
         4 start_estimated_ind = i2
         4 calc_end_dt_tm = dq8
         4 calc_end_estimated_ind = i2
 )
 FREE RECORD phase_ids
 RECORD phase_ids(
   1 phases[*]
     2 pathway_id = f8
     2 patientindex = i4
     2 planindex = i4
 )
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE cexpiretypemean = c12 WITH constant("EXPIREPROP"), protect
 DECLARE ccareplantypemean = c12 WITH constant("CAREPLAN"), protect
 DECLARE cphasetypemean = c12 WITH constant("PHASE"), protect
 DECLARE csubphasetypemean = c12 WITH constant("SUBPHASE"), protect
 DECLARE cdottypemean = c12 WITH constant("DOT"), protect
 DECLARE icareplantypeflag = i2 WITH constant(1), protect
 DECLARE iphasetypeflag = i2 WITH constant(2), protect
 DECLARE isubphasetypeflag = i2 WITH constant(3), protect
 DECLARE idottypeflag = i2 WITH constant(4), protect
 DECLARE ireviewtypeflag = i2 WITH constant(2), protect
 DECLARE ireviewstatusflag = i2 WITH constant(6), protect
 DECLARE dplanproposedstatuscd = f8 WITH constant(uar_get_code_by("MEANING",16769,"PLANPROPOSE")),
 protect
 DECLARE dfutureproposedstatuscd = f8 WITH constant(uar_get_code_by("MEANING",16769,"FUTURPROPOSE")),
 protect
 DECLARE dinitproposedstatuscd = f8 WITH constant(uar_get_code_by("MEANING",16769,"INITPROPOSE")),
 protect
 DECLARE dproposedstatuscd = f8 WITH constant(uar_get_code_by("MEANING",16769,"PROPOSED")), protect
 DECLARE dhourscd = f8 WITH constant(uar_get_code_by("MEANING",340,"HOURS")), protect
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE exception_size = i4 WITH protect, noconstant(0)
 DECLARE phase_size = i4 WITH protect, noconstant(0)
 DECLARE plan_size = i4 WITH protect, noconstant(0)
 DECLARE patient_size = i4 WITH protect, noconstant(0)
 DECLARE current_plan_phase_size = i4 WITH protect, noconstant(0)
 DECLARE icriteriacnt = i4 WITH noconstant(0), protect
 DECLARE iglobalphasecnt = i4 WITH noconstant(0), protect
 DECLARE iphasecnt = i4 WITH noconstant(0), protect
 DECLARE iplancnt = i4 WITH noconstant(0), protect
 DECLARE ipatientcnt = i4 WITH noconstant(0), protect
 DECLARE iindex = i4 WITH noconstant(0), protect
 DECLARE iplanindex = i4 WITH noconstant(0), protect
 DECLARE ipatientindex = i4 WITH noconstant(0), protect
 DECLARE stat = i2 WITH noconstant(0), protect
 DECLARE iphasetype = i2 WITH noconstant(0), protect
 DECLARE loop_cnt = i4 WITH noconstant(0), protect
 DECLARE itimeqty = i4 WITH noconstant(0), protect
 DECLARE iglobaltimeqty = i4 WITH noconstant(0), protect
 DECLARE dtimeunitcd = f8 WITH noconstant(0.0), protect
 DECLARE dcurrentplanid = f8 WITH noconstant(0.0), protect
 DECLARE dcurrentpatientid = f8 WITH noconstant(0.0), protect
 DECLARE dglobaltimeunitcd = f8 WITH noconstant(dhourscd), protect
 DECLARE ddate = dq8
 DECLARE dcurrentdate = dq8
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE ddatedifference = f8 WITH noconstant(0.0), protect
 SET parameter_value = parameter(1,0)
 IF (parameter_value=" ")
  SET imaxphasestowithdraw = 500
 ELSE
  SET imaxphasestowithdraw = cnvtint(parameter_value)
  IF (imaxphasestowithdraw < batch_size)
   SET imaxphasestowithdraw = batch_size
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
  CALL report_failure("LOAD_GLOBAL_EXPIRATION_CRITERIA","F","DCP_OPS_PW_CLEANUP_PROPOSED",
   "Unable to find PW_MAINTENANCE_CRITERIA global expiration record")
  SET cstatus = "F"
  GO TO exit_script
 ELSEIF (curqual > 1)
  CALL report_failure("LOAD_GLOBAL_EXPIRATION_CRITERIA","F","DCP_OPS_PW_CLEANUP_PROPOSED",
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
  PLAN (p
   WHERE p.pw_status_cd IN (dproposedstatuscd, dplanproposedstatuscd, dfutureproposedstatuscd,
   dinitproposedstatuscd)
    AND ((p.type_mean=ccareplantypemean) OR (((p.type_mean=cphasetypemean) OR (p.type_mean=
   cdottypemean)) ))
    AND p.pw_cat_group_id != 0)
  ORDER BY p.person_id, p.pw_cat_group_id, p.pw_group_nbr,
   p.pathway_id
  HEAD REPORT
   stat = alterlist(withdraw->patient,batch_size), stat = alterlist(phase_ids->phases,batch_size),
   loop_cnt = 1,
   phase_size = batch_size, patient_size = batch_size, current_plan_phase_size = batch_size,
   dcurrentdate = cnvtdatetime(sysdate)
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
   IF ((imaxphasestowithdraw <= (iglobalphasecnt+ 1)))
    CALL cancel(1)
   ENDIF
  DETAIL
   ddate = cnvtdatetime(p.order_dt_tm), ddate = cnvtlookahead(build(itimeqty,",H"),cnvtdatetime(ddate
     )), ddatedifference = datetimediff(cnvtdatetime(ddate),cnvtdatetime(dcurrentdate))
   IF (ddatedifference <= 0)
    IF (dcurrentpatientid != p.person_id)
     dcurrentpatientid = p.person_id, ipatientcnt += 1, iplancnt = 0,
     plan_size = 0, dcurrentplanid = 0.0
     IF (ipatientcnt > patient_size)
      stat = alterlist(withdraw->patient,(ipatientcnt+ (batch_size - 1))), patient_size = (
      ipatientcnt+ (batch_size - 1))
     ENDIF
     withdraw->patient[ipatientcnt].patient_id = p.person_id
    ENDIF
    IF (dcurrentpatientid > 0)
     IF (dcurrentplanid != p.pw_group_nbr)
      dcurrentplanid = p.pw_group_nbr, iplancnt += 1, iphasecnt = 0,
      current_plan_phase_size = 0
      IF (iplancnt > plan_size)
       stat = alterlist(withdraw->patient[ipatientcnt].plans,(iplancnt+ (batch_size - 1))), plan_size
        = (iplancnt+ (batch_size - 1))
      ENDIF
      withdraw->patient[ipatientcnt].plan_count = iplancnt, withdraw->patient[ipatientcnt].plans[
      iplancnt].pw_group_nbr = p.pw_group_nbr, withdraw->patient[ipatientcnt].plans[iplancnt].
      pw_cat_group_id = p.pw_cat_group_id,
      withdraw->patient[ipatientcnt].plans[iplancnt].pw_cat_version = p.pw_cat_version, withdraw->
      patient[ipatientcnt].plans[iplancnt].pw_group_desc = trim(p.pw_group_desc), withdraw->patient[
      ipatientcnt].plans[iplancnt].pathway_type_cd = p.pathway_type_cd
     ENDIF
     IF (dcurrentplanid > 0)
      iphasecnt += 1, iglobalphasecnt += 1, withdraw->patient[ipatientcnt].plans[iplancnt].
      phase_count = iphasecnt
      IF (iglobalphasecnt > phase_size)
       stat = alterlist(phase_ids->phases,(iglobalphasecnt+ (batch_size - 1))), loop_cnt += 1,
       phase_size = (iglobalphasecnt+ (batch_size - 1))
      ENDIF
      phase_ids->phases[iglobalphasecnt].pathway_id = p.pathway_id, phase_ids->phases[iglobalphasecnt
      ].patientindex = ipatientcnt, phase_ids->phases[iglobalphasecnt].planindex = iplancnt
      IF (iphasecnt > current_plan_phase_size)
       stat = alterlist(withdraw->patient[ipatientcnt].plans[iplancnt].phases,(iphasecnt+ (batch_size
         - 1))), current_plan_phase_size = (iphasecnt+ (batch_size - 1))
      ENDIF
      withdraw->patient[ipatientcnt].plans[iplancnt].phases[iphasecnt].pathway_id = p.pathway_id,
      withdraw->patient[ipatientcnt].plans[iplancnt].phases[iphasecnt].encntr_id = p.encntr_id,
      withdraw->patient[ipatientcnt].plans[iplancnt].phases[iphasecnt].updt_cnt = p.updt_cnt,
      withdraw->patient[ipatientcnt].plans[iplancnt].phases[iphasecnt].type_mean = trim(p.type_mean),
      withdraw->patient[ipatientcnt].plans[iplancnt].phases[iphasecnt].pathway_group_id = p
      .pathway_group_id, withdraw->patient[ipatientcnt].plans[iplancnt].phases[iphasecnt].description
       = trim(p.description),
      withdraw->patient[ipatientcnt].plans[iplancnt].phases[iphasecnt].pathway_catalog_id = p
      .pathway_catalog_id, withdraw->patient[ipatientcnt].plans[iplancnt].phases[iphasecnt].
      display_method_cd = p.display_method_cd, withdraw->patient[ipatientcnt].plans[iplancnt].phases[
      iphasecnt].start_dt_tm = p.start_dt_tm,
      withdraw->patient[ipatientcnt].plans[iplancnt].phases[iphasecnt].start_estimated_ind = p
      .start_estimated_ind, withdraw->patient[ipatientcnt].plans[iplancnt].phases[iphasecnt].
      calc_end_dt_tm = p.calc_end_dt_tm, withdraw->patient[ipatientcnt].plans[iplancnt].phases[
      iphasecnt].calc_end_estimated_ind = p.calc_end_estimated_ind
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (iglobalphasecnt <= 0)
  CALL report_failure("LOAD_PHASES TO WITHDRAW","F","DCP_OPS_PW_CLEANUP_PROPOSED",
   "Unable to find careplans and phases to withdraw")
  SET cstatus = "F"
  GO TO exit_script
 ENDIF
 SET iindex = 0
 SET iplanindex = 0
 SET ipatientindex = 0
 SET start = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   pathway_reltn pr,
   pathway p
  PLAN (d1
   WHERE initarray(start,evaluate(d1.seq,1,1,(start+ batch_size))))
   JOIN (pr
   WHERE expand(iindex,start,(start+ (batch_size - 1)),pr.pathway_s_id,phase_ids->phases[iindex].
    pathway_id)
    AND pr.type_mean=csubphasetypemean)
   JOIN (p
   WHERE p.pathway_id=pr.pathway_t_id
    AND p.pw_status_cd IN (dproposedstatuscd, dplanproposedstatuscd, dfutureproposedstatuscd,
   dinitproposedstatuscd))
  DETAIL
   ipatientindex = locateval(ipatientindex,1,value(size(withdraw->patient,5)),p.person_id,withdraw->
    patient[ipatientindex].patient_id)
   IF (ipatientindex > 0)
    iplanindex = locateval(iplanindex,1,value(size(withdraw->patient[ipatientindex].plans,5)),p
     .pw_group_nbr,withdraw->patient[ipatientindex].plans[iplanindex].pw_group_nbr)
    IF (iplanindex > 0)
     iphasecnt = (withdraw->patient[ipatientindex].plans[iplanindex].phase_count+ 1)
     IF (iphasecnt >= size(withdraw->patient[ipatientindex].plans[iplanindex].phases,5))
      stat = alterlist(withdraw->patient[ipatientindex].plans[iplanindex].phases,(iphasecnt+ (
       batch_size - 1)))
     ENDIF
     withdraw->patient[ipatientindex].plans[iplanindex].phase_count = iphasecnt, withdraw->patient[
     ipatientindex].plans[iplanindex].phases[iphasecnt].pathway_id = p.pathway_id, withdraw->patient[
     ipatientindex].plans[iplanindex].phases[iphasecnt].encntr_id = p.encntr_id,
     withdraw->patient[ipatientindex].plans[iplanindex].phases[iphasecnt].updt_cnt = p.updt_cnt,
     withdraw->patient[ipatientindex].plans[iplanindex].phases[iphasecnt].type_mean = trim(p
      .type_mean), withdraw->patient[ipatientindex].plans[iplanindex].phases[iphasecnt].
     pathway_group_id = p.pathway_group_id,
     withdraw->patient[ipatientindex].plans[iplanindex].phases[iphasecnt].description = trim(p
      .description), withdraw->patient[ipatientindex].plans[iplanindex].phases[iphasecnt].
     pathway_catalog_id = p.pathway_catalog_id, withdraw->patient[ipatientindex].plans[iplanindex].
     phases[iphasecnt].display_method_cd = p.display_method_cd,
     withdraw->patient[ipatientindex].plans[iplanindex].phases[iphasecnt].parent_phase_desc = trim(p
      .parent_phase_desc)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 DECLARE l_application = i4 WITH protect, noconstant(600005)
 DECLARE l_task = i4 WITH protect, noconstant(3202004)
 DECLARE l_step = i4 WITH protect, noconstant(601401)
 DECLARE happlication = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hpatientcriteria = i4 WITH public, noconstant(0)
 DECLARE husercriteria = i4 WITH public, noconstant(0)
 DECLARE hplan = i4 WITH public, noconstant(0)
 DECLARE hplanbasic = i4 WITH public, noconstant(0)
 DECLARE hphase = i4 WITH public, noconstant(0)
 DECLARE hphasebasic = i4 WITH public, noconstant(0)
 DECLARE hphasedatetime = i4 WITH public, noconstant(0)
 DECLARE hreviewitem = i4 WITH public, noconstant(0)
 DECLARE hrequest = i4 WITH public, noconstant(0)
 EXECUTE crmrtl
 EXECUTE srvrtl
 FOR (ipatientindex = 1 TO ipatientcnt)
   IF (uar_crmbeginapp(l_application,happlication) != 0)
    CALL report_failure("CREATE_APPLICATION_HANDLE","F","DCP_OPS_PW_CLEANUP_PROPOSED",
     "Unable to create application handle when calling ManagePlans")
    SET cstatus = "F"
   ENDIF
   IF (uar_crmbegintask(happlication,l_task,htask) != 0)
    CALL report_failure("CREATE_TASK_HANDLE","F","DCP_OPS_PW_CLEANUP_PROPOSED",
     "Unable to create task handle when calling ManagePlans")
    SET cstatus = "F"
   ENDIF
   IF (uar_crmbeginreq(htask,"",l_step,hstep) != 0)
    CALL report_failure("CREATE_STEP_HANDLE","F","DCP_OPS_PW_CLEANUP_PROPOSED",
     "Unable to create step handle when calling ManagePlans")
    SET cstatus = "F"
   ENDIF
   SET hrequest = uar_crmgetrequest(hstep)
   IF (hrequest <= 0)
    CALL report_failure("CREATE_REQUEST_HANDLE","F","DCP_OPS_PW_CLEANUP_PROPOSED",
     "Unable to create request handle when calling ManagePlans")
    SET cstatus = "F"
   ENDIF
   SET hpatientcriteria = uar_srvgetstruct(hrequest,"patient_criteria")
   IF (hpatientcriteria <= 0)
    CALL report_failure("CREATE_ITEM_HANDLE","F","DCP_OPS_PW_CLEANUP_PROPOSED",
     "Unable to create item handle for request when calling ManagePlans")
   ELSE
    SET l_stat = uar_srvsetdouble(hpatientcriteria,"patient_id",withdraw->patient[ipatientindex].
     patient_id)
   ENDIF
   SET husercriteria = uar_srvgetstruct(hrequest,"user_criteria")
   IF (husercriteria <= 0)
    CALL report_failure("CREATE_ITEM_HANDLE","F","DCP_OPS_PW_CLEANUP_PROPOSED",
     "Unable to create item handle for request when calling ManagePlans")
   ELSE
    SET l_stat = uar_srvsetdouble(husercriteria,"provider_id",reqinfo->updt_id)
    SET l_stat = uar_srvsetdouble(husercriteria,"position_cd",reqinfo->position_cd)
   ENDIF
   FOR (iplanindex = 1 TO withdraw->patient[ipatientindex].plan_count)
     SET hplan = uar_srvadditem(hrequest,"plans")
     IF (hplan <= 0)
      CALL report_failure("CREATE_ITEM_HANDLE","F","DCP_OPS_PW_CLEANUP_PROPOSED",
       "Unable to create item handle for request when calling ManagePlans")
     ELSE
      SET l_stat = uar_srvsetdouble(hplan,"plan_id",withdraw->patient[ipatientindex].plans[iplanindex
       ].pw_group_nbr)
      SET l_stat = uar_srvsetdouble(hplan,"plan_catalog_id",withdraw->patient[ipatientindex].plans[
       iplanindex].pw_cat_group_id)
      SET hplanbasic = uar_srvadditem(hplan,"basic")
      IF (hplanbasic <= 0)
       CALL report_failure("CREATE_ITEM_HANDLE","F","DCP_OPS_PW_CLEANUP_PROPOSED",
        "Unable to create item handle for request when calling ManagePlans")
      ELSE
       SET l_stat = uar_srvsetstring(hplanbasic,"name",nullterm(trim(withdraw->patient[ipatientindex]
          .plans[iplanindex].pw_group_desc)))
       SET l_stat = uar_srvsetlong(hplanbasic,"version_number",withdraw->patient[ipatientindex].
        plans[iplanindex].pw_cat_version)
       SET l_stat = uar_srvsetdouble(hplanbasic,"type_cd",withdraw->patient[ipatientindex].plans[
        iplanindex].pathway_type_cd)
      ENDIF
     ENDIF
     FOR (iphaseindex = 1 TO withdraw->patient[ipatientindex].plans[iplanindex].phase_count)
       SET hphase = uar_srvadditem(hplan,"phases")
       IF (hphase <= 0)
        CALL report_failure("CREATE_ITEM_HANDLE","F","DCP_OPS_PW_CLEANUP_PROPOSED",
         "Unable to create item handle for request when calling ManagePlans")
       ELSE
        SET l_stat = uar_srvsetdouble(hphase,"phase_id",withdraw->patient[ipatientindex].plans[
         iplanindex].phases[iphaseindex].pathway_id)
        SET l_stat = uar_srvsetdouble(hphase,"phase_catalog_id",withdraw->patient[ipatientindex].
         plans[iplanindex].phases[iphaseindex].pathway_catalog_id)
        SET l_stat = uar_srvsetlong(hphase,"update_count",withdraw->patient[ipatientindex].plans[
         iplanindex].phases[iphaseindex].updt_cnt)
       ENDIF
       SET hphasebasic = uar_srvadditem(hphase,"basic")
       IF (hphasebasic <= 0)
        CALL report_failure("CREATE_ITEM_HANDLE","F","DCP_OPS_PW_CLEANUP_PROPOSED",
         "Unable to create item handle for request when calling ManagePlans")
       ELSE
        SET l_stat = uar_srvsetstring(hphasebasic,"name",nullterm(trim(withdraw->patient[
           ipatientindex].plans[iplanindex].phases[iphaseindex].description)))
        SET iphasetype = icareplantypeflag
        CASE (withdraw->patient[ipatientindex].plans[iplanindex].phases[iphaseindex].type_mean)
         OF ccareplantypemean:
          SET iphasetype = icareplantypeflag
         OF cphasetypemean:
          SET iphasetype = iphasetypeflag
         OF csubphasetypemean:
          SET iphasetype = isubphasetypeflag
         OF cdottypemean:
          SET iphasetype = idottypeflag
         ELSE
          CALL report_failure("CREATE_PHASE_BASIC_TYPE_FLAG","F","DCP_OPS_PW_CLEANUP_PROPOSED",
           "Unable to covert phase type_mean to flag value")
          SET cstatus = "F"
        ENDCASE
        SET l_stat = uar_srvsetshort(hphasebasic,"type_flag",iphasetype)
        SET l_stat = uar_srvsetdouble(hphasebasic,"encounter_id",withdraw->patient[ipatientindex].
         plans[iplanindex].phases[iphaseindex].encntr_id)
        SET l_stat = uar_srvsetdouble(hphasebasic,"display_method_cd",withdraw->patient[ipatientindex
         ].plans[iplanindex].phases[iphaseindex].display_method_cd)
       ENDIF
       SET hphasedatetime = uar_srvadditem(hphase,"date_time")
       IF (hphasedatetime <= 0)
        CALL report_failure("CREATE_ITEM_HANDLE","F","DCP_OPS_PW_CLEANUP_PROPOSED",
         "Unable to create item handle for request when calling ManagePlans")
       ELSE
        SET l_stat = uar_srvsetdate(hphasedatetime,"start_dt_tm",withdraw->patient[ipatientindex].
         plans[iplanindex].phases[iphaseindex].start_dt_tm)
        SET l_stat = uar_srvsetshort(hphasedatetime,"start_estimated_ind",withdraw->patient[
         ipatientindex].plans[iplanindex].phases[iphaseindex].start_estimated_ind)
        SET l_stat = uar_srvsetdate(hphasedatetime,"end_dt_tm",withdraw->patient[ipatientindex].
         plans[iplanindex].phases[iphaseindex].calc_end_dt_tm)
        SET l_stat = uar_srvsetshort(hphasedatetime,"end_estimated_ind",withdraw->patient[
         ipatientindex].plans[iplanindex].phases[iphaseindex].calc_end_estimated_ind)
       ENDIF
       SET hreviewitem = uar_srvadditem(hphase,"review_information")
       IF (hreviewitem <= 0)
        CALL report_failure("CREATE_ITEM_HANDLE","F","DCP_OPS_PW_CLEANUP_PROPOSED",
         "Unable to create item handle for request when calling ManagePlans")
        SET iindex = iphasecnt
       ELSE
        SET l_stat = uar_srvsetshort(hreviewitem,"type_flag",ireviewtypeflag)
        SET l_stat = uar_srvsetshort(hreviewitem,"pending_status_flag",ireviewstatusflag)
       ENDIF
     ENDFOR
   ENDFOR
   IF (uar_crmperform(hstep) != 0)
    CALL report_failure("PERFORM REQUEST","F","DCP_OPS_PW_CLEANUP_PROPOSED",
     "Unable to perform request when calling ManagePlans")
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
 ENDFOR
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
 SET last_mod = "004"
 SET mod_date = "Feb 07, 2020"
END GO
