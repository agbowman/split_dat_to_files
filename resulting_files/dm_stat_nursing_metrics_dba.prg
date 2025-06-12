CREATE PROGRAM dm_stat_nursing_metrics:dba
 IF ( NOT (validate(dsr,0)))
  RECORD dsr(
    1 qual[*]
      2 stat_snap_dt_tm = dq8
      2 snapshot_type = c100
      2 client_mnemonic = c10
      2 domain_name = c20
      2 node_name = c30
      2 qual[*]
        3 stat_name = vc
        3 stat_seq = i4
        3 stat_str_val = vc
        3 stat_type = i4
        3 stat_number_val = f8
        3 stat_date_val = dq8
        3 stat_clob_val = vc
  )
 ENDIF
 DECLARE esmerror(msg=vc,ret=i2) = i2
 DECLARE esmcheckccl(z=vc) = i2
 DECLARE esmdate = f8
 DECLARE esmmsg = c196
 DECLARE esmcategory = c128
 DECLARE esmerrorcnt = i2
 SET esmexit = 0
 SET esmreturn = 1
 SET esmerrorcnt = 0
 SUBROUTINE esmerror(msg,ret)
   SET esmerrorcnt = (esmerrorcnt+ 1)
   IF (esmerrorcnt <= 3)
    SET esmdate = cnvtdatetime(curdate,curtime3)
    SET esmmsg = fillstring(196," ")
    SET esmmsg = substring(1,195,msg)
    SET esmcategory = fillstring(128," ")
    SET esmcategory = curprog
    EXECUTE dm_stat_error esmdate, esmmsg, esmcategory
    CALL echo(msg)
    CALL esmcheckccl("x")
   ELSE
    GO TO exit_program
   ENDIF
   IF (ret=esmexit)
    GO TO exit_program
   ENDIF
   SET esmerrorcnt = 0
   RETURN(esmreturn)
 END ;Subroutine
 SUBROUTINE esmcheckccl(z)
   SET cclerrmsg = fillstring(132," ")
   SET cclerrcode = error(cclerrmsg,0)
   IF (cclerrcode != 0)
    SET execrc = 1
    CALL esmerror(cclerrmsg,esmexit)
   ENDIF
   RETURN(esmreturn)
 END ;Subroutine
 DECLARE qualcnt = i4
 DECLARE ds_begin_snapshot = f8
 DECLARE ds_end_snapshot = f8
 DECLARE ds_cnt = i4 WITH protect, noconstant(0)
 DECLARE row_cnt = i4 WITH protect, noconstant(0)
 DECLARE dfa_total_cnt = i4 WITH protect, noconstant(0)
 DECLARE dfa_taskid_cnt = i4 WITH protect, noconstant(0)
 DECLARE num_backcharts = i4 WITH protect, noconstant(0)
 DECLARE num_futurecharts = i4 WITH protect, noconstant(0)
 DECLARE chart_mins = i4 WITH protect, constant(60)
 DECLARE bolus_cnt = i4 WITH protect, noconstant(0)
 DECLARE cont_cnt = i4 WITH protect, noconstant(0)
 DECLARE violator_fnd = i1 WITH protect, noconstant(0)
 DECLARE solution_name = vc WITH protect, noconstant("")
 DECLARE one_day_cnt = i4 WITH protect, noconstant(0)
 DECLARE two_day_cnt = i4 WITH protect, noconstant(0)
 DECLARE clob_value = vc WITH protect, noconstant
 DECLARE solution_recorded = i2 WITH protect, noconstant
 DECLARE dsvm_error(msg=vc) = null
 DECLARE complete_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"COMPLETE"))
 DECLARE ce_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",18189,"CLINCALEVENT"))
 DECLARE inprogress_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE unauth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"UNAUTH")), protect
 DECLARE altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE scheduled_cd = f8 WITH constant(uar_get_code_by("MEANING",6025,"SCH")), protect
 DECLARE perform_cd = f8 WITH constant(uar_get_code_by("MEANING",21,"PERFORM")), protect
 DECLARE inerror = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR")), protect
 DECLARE working_view = f8 WITH constant(uar_get_code_by("MEANING",29520,"WORKING_VIEW")), protect
 DECLARE bolus_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"BOLUS")), protect
 DECLARE med_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"MED")), protect
 DECLARE immun_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"IMMUN")), protect
 DECLARE order_type_int = f8 WITH constant(uar_get_code_by("MEANING",18309,"INTERMITTENT")), protect
 DECLARE inerrnoview = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOVIEW")), protect
 DECLARE inerrnomut = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOMUT")), protect
 DECLARE grp_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"GRP"))
 SET ds_begin_snapshot = cnvtdatetime((curdate - 1),0)
 SET ds_end_snapshot = cnvtdatetime((curdate - 1),235959)
 SUBROUTINE dsvm_error(msg)
  DECLARE dsvm_err_msg = c132
  IF (error(dsvm_err_msg,0) > 0)
   ROLLBACK
   CALL esmerror(concat("Error: ",msg," ",dsvm_err_msg),esmreturn)
  ENDIF
 END ;Subroutine
 INSERT  FROM shared_value_gttd cetemp
  (cetemp.source_entity_value, cetemp.source_entity_name)(SELECT
   ce.clinical_event_id, "DM_STAT_NURSING_METRICS"
   FROM clinical_event ce
   WHERE ce.updt_dt_tm >= cnvtdatetime((curdate - 1),000000)
    AND ce.updt_dt_tm < cnvtdatetime(curdate,0)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ((performed_prsnl_id+ 0) > 0))
  WITH nocounter
 ;end insert
 CALL dsvm_error("SHARED_VALUE_GTTD INSERT")
 SET ds_cnt = 0
 SELECT INTO "nl:"
  p.person_id, p.username, p.name_last,
  p.name_first, p.name_full_formatted, p.email,
  p.physician_ind, p.position_cd, dvsm_ret = count(*)
  FROM dcp_forms_activity dfa,
   task_activity ta,
   prsnl p,
   dcp_forms_activity_prsnl dfap
  PLAN (dfa
   WHERE ((dfa.task_id+ 0) > 0)
    AND dfa.active_ind=1
    AND dfa.updt_dt_tm >= cnvtdatetime((curdate - 1),0)
    AND dfa.form_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
   JOIN (ta
   WHERE ta.task_id=dfa.task_id
    AND ((ta.order_id+ 0)=0))
   JOIN (dfap
   WHERE dfa.dcp_forms_activity_id=dfap.dcp_forms_activity_id)
   JOIN (p
   WHERE p.person_id=dfap.prsnl_id)
  GROUP BY p.person_id, p.username, p.name_last,
   p.name_first, p.name_full_formatted, p.email,
   p.physician_ind, p.position_cd
  HEAD REPORT
   qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm =
   cnvtdatetime(ds_begin_snapshot),
   dsr->qual[qualcnt].snapshot_type = "UE_NURSING_ASSESSMENTS", row_cnt = 0
  DETAIL
   row_cnt = (row_cnt+ 1), ds_cnt = (ds_cnt+ 1)
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "ADHOC_ASSESSMENTS", dsr->qual[qualcnt].qual[ds_cnt].
   stat_number_val = dvsm_ret, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = row_cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(trim(p.username),"||",trim(p.name_last),"||",
    trim(p.name_first),
    "||",trim(p.name_full_formatted),"||",trim(p.email),"||",
    p.physician_ind,"||",uar_get_code_display(p.position_cd),"||",cnvtstring(p.person_id,11,2))
  FOOT REPORT
   IF (row_cnt=0)
    ds_cnt = (ds_cnt+ 1)
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "ADHOC_ASSESSMENTS", dsr->qual[qualcnt].qual[ds_cnt].
    stat_str_val = "NO_NEW_DATA"
   ENDIF
  WITH nocounter, nullreport
 ;end select
 CALL dsvm_error("UE_NURSING_ASSESSMENTS - ADHOC_ASSESSMENTS")
 IF (inprogress_cd > 0.0
  AND ce_comp_cd > 0.0)
  SELECT INTO "nl:"
   p.person_id, p.username, p.name_last,
   p.name_first, p.name_full_formatted, p.email,
   p.physician_ind, p.position_cd
   FROM dcp_forms_activity dfa,
    dcp_forms_activity_comp dfac,
    clinical_event ce,
    prsnl p
   PLAN (dfa
    WHERE dfa.active_ind=1
     AND dfa.form_dt_tm BETWEEN cnvtdatetime((curdate - 2),0) AND cnvtdatetime(ds_end_snapshot)
     AND dfa.updt_dt_tm >= cnvtdatetime((curdate - 2),0))
    JOIN (dfac
    WHERE dfac.dcp_forms_activity_id=dfa.dcp_forms_activity_id
     AND dfac.component_cd=ce_comp_cd
     AND dfac.parent_entity_name="CLINICAL_EVENT")
    JOIN (ce
    WHERE ce.event_id=dfac.parent_entity_id
     AND ce.result_status_cd=inprogress_cd
     AND ((ce.performed_prsnl_id+ 0) > 0)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
    JOIN (p
    WHERE p.person_id=ce.performed_prsnl_id)
   ORDER BY p.person_id
   HEAD REPORT
    row_cnt = 0
   HEAD p.person_id
    one_day_cnt = 0, two_day_cnt = 0, ds_cnt = (ds_cnt+ 2),
    row_cnt = (row_cnt+ 1)
    IF (((mod(ds_cnt,10)=2) OR (mod(ds_cnt,10)=1)) )
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ (10 - mod(ds_cnt,10))))
    ENDIF
   DETAIL
    IF (dfa.form_dt_tm < cnvtdatetime((curdate - 1),0))
     two_day_cnt = (two_day_cnt+ 1)
    ELSE
     one_day_cnt = (one_day_cnt+ 1)
    ENDIF
   FOOT  p.person_id
    clob_value = build(trim(p.username),"||",trim(p.name_last),"||",trim(p.name_first),
     "||",trim(p.name_full_formatted),"||",trim(p.email),"||",
     p.physician_ind,"||",uar_get_code_display(p.position_cd),"||",cnvtstring(p.person_id,11,2)), dsr
    ->qual[qualcnt].qual[(ds_cnt - 1)].stat_name = "UNFINISHED_ASSESSMENTS_DAY1", dsr->qual[qualcnt].
    qual[(ds_cnt - 1)].stat_seq = row_cnt,
    dsr->qual[qualcnt].qual[(ds_cnt - 1)].stat_number_val = one_day_cnt, dsr->qual[qualcnt].qual[(
    ds_cnt - 1)].stat_clob_val = clob_value, dsr->qual[qualcnt].qual[ds_cnt].stat_name =
    "UNFINISHED_ASSESSMENTS_DAY2",
    dsr->qual[qualcnt].qual[ds_cnt].stat_seq = row_cnt, dsr->qual[qualcnt].qual[ds_cnt].
    stat_number_val = two_day_cnt, dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = clob_value
   FOOT REPORT
    IF (row_cnt=0)
     ds_cnt = (ds_cnt+ 1)
     IF (mod(ds_cnt,10)=1)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
     ENDIF
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNFINISHED_ASSESSMENTS", dsr->qual[qualcnt].qual[
     ds_cnt].stat_str_val = "NO_NEW_DATA"
    ENDIF
   WITH nocounter, nullreport
  ;end select
 ENDIF
 CALL dsvm_error("UE_NURSING_ASSESSMENTS - UNFINISHED_ASSESSMENTS")
 SET stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt)
 SET ds_cnt = 0
 SELECT INTO "nl:"
  p.person_id, p.username, p.name_last,
  p.name_first, p.name_full_formatted, p.email,
  p.physician_ind, p.position_cd, dfa.task_id
  FROM dcp_forms_activity dfa,
   prsnl p,
   dcp_forms_activity_prsnl dfap
  PLAN (dfa
   WHERE dfa.active_ind=1
    AND dfa.updt_dt_tm >= cnvtdatetime((curdate - 1),0)
    AND dfa.form_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
   JOIN (dfap
   WHERE dfap.dcp_forms_activity_id=dfa.dcp_forms_activity_id)
   JOIN (p
   WHERE p.person_id=dfap.prsnl_id)
  ORDER BY p.person_id
  HEAD REPORT
   qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm =
   cnvtdatetime(ds_begin_snapshot),
   dsr->qual[qualcnt].snapshot_type = "UE_NURSING_TASKS.2", row_cnt = 0
  HEAD p.person_id
   ds_cnt = (ds_cnt+ 2), row_cnt = (row_cnt+ 1), dfa_taskid_cnt = 0,
   dfa_total_cnt = 0
   IF (((mod(ds_cnt,10)=2) OR (mod(ds_cnt,10)=1)) )
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ (10 - mod(ds_cnt,10))))
   ENDIF
  DETAIL
   IF (dfa.task_id > 0)
    dfa_taskid_cnt = (dfa_taskid_cnt+ 1)
   ENDIF
   dfa_total_cnt = (dfa_total_cnt+ 1)
  FOOT  p.person_id
   clob_value = build(trim(p.username),"||",trim(p.name_last),"||",trim(p.name_first),
    "||",trim(p.name_full_formatted),"||",trim(p.email),"||",
    p.physician_ind,"||",uar_get_code_display(p.position_cd),"||",cnvtstring(p.person_id,11,2)), dsr
   ->qual[qualcnt].qual[(ds_cnt - 1)].stat_name = "TASKS_WITH_POWERFORMS", dsr->qual[qualcnt].qual[(
   ds_cnt - 1)].stat_seq = row_cnt,
   dsr->qual[qualcnt].qual[(ds_cnt - 1)].stat_number_val = dfa_taskid_cnt, dsr->qual[qualcnt].qual[(
   ds_cnt - 1)].stat_clob_val = clob_value, dsr->qual[qualcnt].qual[ds_cnt].stat_name =
   "TOTAL_POWERFORMS",
   dsr->qual[qualcnt].qual[ds_cnt].stat_seq = row_cnt, dsr->qual[qualcnt].qual[ds_cnt].
   stat_number_val = dfa_total_cnt, dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = clob_value
  FOOT REPORT
   IF (row_cnt=0)
    ds_cnt = (ds_cnt+ 2)
    IF (mod(ds_cnt,10)=2)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ (10 - mod(ds_cnt,10))))
    ENDIF
    dsr->qual[qualcnt].qual[(ds_cnt - 1)].stat_name = "TASKS_WITH_POWERFORMS", dsr->qual[qualcnt].
    qual[(ds_cnt - 1)].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_name =
    "TOTAL_POWERFORMS",
    dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA"
   ENDIF
  WITH nocounter, nullreport
 ;end select
 CALL dsvm_error("UE_NURSING_TASKS - TASKS_WITH_POWERFORMS, TOTAL_POWERFORMS")
 IF (complete_cd > 0.0)
  SELECT INTO "nl"
   p.person_id, p.username, p.name_last,
   p.name_first, p.name_full_formatted, p.email,
   p.physician_ind, p.position_cd, dvsm_ret = count(*)
   FROM task_activity ta,
    prsnl p
   PLAN (ta
    WHERE ta.task_status_cd=complete_cd
     AND ta.active_ind=1
     AND ta.task_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
    JOIN (p
    WHERE ta.updt_id=p.person_id)
   GROUP BY p.person_id, p.username, p.name_last,
    p.name_first, p.name_full_formatted, p.email,
    p.physician_ind, p.position_cd
   HEAD REPORT
    row_cnt = 0
   DETAIL
    row_cnt = (row_cnt+ 1), ds_cnt = (ds_cnt+ 1)
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "COMPLETED_TASKS", dsr->qual[qualcnt].qual[ds_cnt].
    stat_number_val = dvsm_ret, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = row_cnt,
    dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(trim(p.username),"||",trim(p.name_last),
     "||",trim(p.name_first),
     "||",trim(p.name_full_formatted),"||",trim(p.email),"||",
     p.physician_ind,"||",uar_get_code_display(p.position_cd),"||",cnvtstring(p.person_id,11,2))
   FOOT REPORT
    IF (row_cnt=0)
     ds_cnt = (ds_cnt+ 1)
     IF (mod(ds_cnt,10)=1)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
     ENDIF
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = "COMPLETED_TASKS", dsr->qual[qualcnt].qual[ds_cnt].
     stat_str_val = "NO_NEW_DATA"
    ENDIF
   WITH nocounter, nullreport
  ;end select
 ENDIF
 CALL dsvm_error("UE_NURSING_TASKS - COMPLETED_TASKS")
 SET stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt)
 SET ds_cnt = 0
 IF (auth_cd > 0.0
  AND modified_cd > 0.0
  AND altered_cd > 0.0
  AND bolus_cd > 0.0)
  SELECT INTO "nl:"
   p.person_id, p.username, p.name_last,
   p.name_first, p.name_full_formatted, p.email,
   p.physician_ind, p.position_cd, cmr.iv_event_cd,
   dvsm_ret = count(DISTINCT ce.parent_event_id)
   FROM shared_value_gttd cetemp,
    clinical_event ce,
    ce_med_result cmr,
    prsnl p
   PLAN (cetemp
    WHERE cetemp.source_entity_name="DM_STAT_NURSING_METRICS")
    JOIN (ce
    WHERE ce.clinical_event_id=cetemp.source_entity_value
     AND ce.result_status_cd IN (auth_cd, modified_cd, altered_cd)
     AND ce.event_end_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    )
    JOIN (cmr
    WHERE cmr.event_id=ce.event_id
     AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND cmr.iv_event_cd > 0)
    JOIN (p
    WHERE p.person_id=ce.performed_prsnl_id)
   GROUP BY p.person_id, p.username, p.name_last,
    p.name_first, p.name_full_formatted, p.email,
    p.physician_ind, p.position_cd, cmr.iv_event_cd
   ORDER BY p.person_id
   HEAD REPORT
    IF (ds_cnt=0)
     qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
      = cnvtdatetime(ds_begin_snapshot),
     dsr->qual[qualcnt].snapshot_type = "UE_NURSING_MEDS"
    ENDIF
    row_cnt = 0
   HEAD p.person_id
    ds_cnt = (ds_cnt+ 2), row_cnt = (row_cnt+ 1), bolus_cnt = 0,
    cont_cnt = 0
    IF (((mod(ds_cnt,10)=2) OR (mod(ds_cnt,10)=1)) )
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ (10 - mod(ds_cnt,10))))
    ENDIF
   DETAIL
    IF (cmr.iv_event_cd=bolus_cd)
     bolus_cnt = (bolus_cnt+ dvsm_ret)
    ENDIF
    cont_cnt = (cont_cnt+ dvsm_ret)
   FOOT  p.person_id
    clob_value = build(trim(p.username),"||",trim(p.name_last),"||",trim(p.name_first),
     "||",trim(p.name_full_formatted),"||",trim(p.email),"||",
     p.physician_ind,"||",uar_get_code_display(p.position_cd),"||",cnvtstring(p.person_id,11,2)), dsr
    ->qual[qualcnt].qual[(ds_cnt - 1)].stat_name = "BOLUS_EVENTS", dsr->qual[qualcnt].qual[(ds_cnt -
    1)].stat_seq = row_cnt,
    dsr->qual[qualcnt].qual[(ds_cnt - 1)].stat_number_val = bolus_cnt, dsr->qual[qualcnt].qual[(
    ds_cnt - 1)].stat_clob_val = clob_value, dsr->qual[qualcnt].qual[ds_cnt].stat_name =
    "IV_INFUSION_EVENTS",
    dsr->qual[qualcnt].qual[ds_cnt].stat_seq = row_cnt, dsr->qual[qualcnt].qual[ds_cnt].
    stat_number_val = cont_cnt, dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = clob_value
   FOOT REPORT
    IF (row_cnt=0)
     ds_cnt = (ds_cnt+ 2)
     IF (mod(ds_cnt,10)=2)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ (10 - mod(ds_cnt,10))))
     ENDIF
     dsr->qual[qualcnt].qual[(ds_cnt - 1)].stat_name = "BOLUS_EVENTS", dsr->qual[qualcnt].qual[(
     ds_cnt - 1)].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_name =
     "IV_INFUSION_EVENTS",
     dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA"
    ENDIF
   WITH nocounter, nullreport
  ;end select
 ENDIF
 CALL dsvm_error(" UE_NURSING_MEDS_MANAGEMENT - BOLUS_EVENTS, IV_INFUSION_EVENTS")
 IF (auth_cd > 0.0
  AND unauth_cd > 0.0
  AND altered_cd > 0.0
  AND modified_cd > 0.0)
  SELECT INTO "nl:"
   p.person_id, p.username, p.name_last,
   p.name_first, p.name_full_formatted, p.email,
   p.physician_ind, p.position_cd, dvsm_ret = count(DISTINCT ce.parent_event_id)
   FROM shared_value_gttd cetemp,
    clinical_event ce,
    ce_med_result cmr,
    prsnl p
   PLAN (cetemp
    WHERE cetemp.source_entity_name="DM_STAT_NURSING_METRICS")
    JOIN (ce
    WHERE cetemp.source_entity_value=ce.clinical_event_id
     AND ce.event_end_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
     AND ce.result_status_cd IN (auth_cd, unauth_cd, altered_cd, modified_cd))
    JOIN (cmr
    WHERE cmr.event_id=ce.event_id
     AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
    JOIN (p
    WHERE p.person_id=ce.performed_prsnl_id)
   GROUP BY p.person_id, p.username, p.name_last,
    p.name_first, p.name_full_formatted, p.email,
    p.physician_ind, p.position_cd
   HEAD REPORT
    IF (ds_cnt=0)
     qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
      = cnvtdatetime(ds_begin_snapshot),
     dsr->qual[qualcnt].snapshot_type = "UE_NURSING_MEDS"
    ENDIF
    row_cnt = 0
   DETAIL
    row_cnt = (row_cnt+ 1), ds_cnt = (ds_cnt+ 1)
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "MEDS_ADMINISTERED", dsr->qual[qualcnt].qual[ds_cnt].
    stat_number_val = dvsm_ret, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = row_cnt,
    dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(trim(p.username),"||",trim(p.name_last),
     "||",trim(p.name_first),
     "||",trim(p.name_full_formatted),"||",trim(p.email),"||",
     p.physician_ind,"||",uar_get_code_display(p.position_cd),"||",cnvtstring(p.person_id,11,2))
   FOOT REPORT
    IF (row_cnt=0)
     ds_cnt = (ds_cnt+ 1)
     IF (mod(ds_cnt,10)=1)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
     ENDIF
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = "MEDS_ADMINISTERED", dsr->qual[qualcnt].qual[ds_cnt]
     .stat_str_val = "NO_NEW_DATA"
    ENDIF
   WITH nocounter, nullreport
  ;end select
 ENDIF
 CALL dsvm_error(" UE_NURSING_MEDS_MANAGEMENT - MEDS_ADMINISTERED")
 IF (auth_cd > 0.0
  AND modified_cd > 0.0
  AND med_cd > 0.0
  AND immun_cd > 0.0
  AND order_type_int > 0.0)
  SELECT INTO "nl:"
   p.person_id, p.username, p.name_last,
   p.name_first, p.name_full_formatted, p.email,
   p.physician_ind, p.position_cd, dvsm_ret = count(DISTINCT ce.parent_event_id)
   FROM clinical_event ce,
    orders o,
    prsnl p,
    shared_value_gttd cetemp
   PLAN (cetemp
    WHERE cetemp.source_entity_name="DM_STAT_NURSING_METRICS")
    JOIN (ce
    WHERE ce.clinical_event_id=cetemp.source_entity_value
     AND ce.event_end_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
     AND ce.event_class_cd IN (med_cd, immun_cd)
     AND ce.result_status_cd IN (auth_cd, modified_cd))
    JOIN (o
    WHERE o.order_id=ce.order_id
     AND o.med_order_type_cd=order_type_int)
    JOIN (p
    WHERE ce.performed_prsnl_id=p.person_id)
   GROUP BY p.person_id, p.username, p.name_last,
    p.name_first, p.name_full_formatted, p.email,
    p.physician_ind, p.position_cd
   HEAD REPORT
    IF (ds_cnt=0)
     qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
      = cnvtdatetime(ds_begin_snapshot),
     dsr->qual[qualcnt].snapshot_type = "UE_NURSING_MEDS"
    ENDIF
    row_cnt = 0
   DETAIL
    row_cnt = (row_cnt+ 1), ds_cnt = (ds_cnt+ 1)
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "INTERMITTENT_MEDS", dsr->qual[qualcnt].qual[ds_cnt].
    stat_number_val = dvsm_ret, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = row_cnt,
    dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(trim(p.username),"||",trim(p.name_last),
     "||",trim(p.name_first),
     "||",trim(p.name_full_formatted),"||",trim(p.email),"||",
     p.physician_ind,"||",uar_get_code_display(p.position_cd),"||",cnvtstring(p.person_id,11,2))
   FOOT REPORT
    IF (row_cnt=0)
     ds_cnt = (ds_cnt+ 1)
     IF (mod(ds_cnt,10)=1)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
     ENDIF
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = "INTERMITTENT_MEDS", dsr->qual[qualcnt].qual[ds_cnt]
     .stat_str_val = "NO_NEW_DATA"
    ENDIF
   WITH nocounter, nullreport
  ;end select
 ENDIF
 CALL dsvm_error(" UE_NURSING_MEDS_MANAGEMENT - INTERMITTENT_MEDS")
 IF (inerror > 0.0
  AND inerrnoview > 0.0
  AND inerrnomut > 0.0)
  SELECT INTO "nl:"
   p.person_id, p.username, p.name_last,
   p.name_first, p.name_full_formatted, p.email,
   p.physician_ind, p.position_cd, dvsm_ret = count(DISTINCT ce.parent_event_id)
   FROM shared_value_gttd cetemp,
    clinical_event ce,
    ce_med_result cmr,
    prsnl p
   PLAN (cetemp
    WHERE cetemp.source_entity_name="DM_STAT_NURSING_METRICS")
    JOIN (ce
    WHERE cetemp.source_entity_value=ce.clinical_event_id
     AND ce.result_status_cd IN (inerror, inerrnoview, inerrnomut)
     AND ce.event_end_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    )
    JOIN (cmr
    WHERE cmr.event_id=ce.event_id
     AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
    JOIN (p
    WHERE p.person_id=ce.performed_prsnl_id)
   GROUP BY p.person_id, p.username, p.name_last,
    p.name_first, p.name_full_formatted, p.email,
    p.physician_ind, p.position_cd
   HEAD REPORT
    IF (ds_cnt=0)
     qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
      = cnvtdatetime(ds_begin_snapshot),
     dsr->qual[qualcnt].snapshot_type = "UE_NURSING_MEDS"
    ENDIF
    row_cnt = 0
   DETAIL
    row_cnt = (row_cnt+ 1), ds_cnt = (ds_cnt+ 1)
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "MEDS_UNCHARTED_INERROR", dsr->qual[qualcnt].qual[
    ds_cnt].stat_number_val = dvsm_ret, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = row_cnt,
    dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(trim(p.username),"||",trim(p.name_last),
     "||",trim(p.name_first),
     "||",trim(p.name_full_formatted),"||",trim(p.email),"||",
     p.physician_ind,"||",uar_get_code_display(p.position_cd),"||",cnvtstring(p.person_id,11,2))
   FOOT REPORT
    IF (row_cnt=0)
     ds_cnt = (ds_cnt+ 1)
     IF (mod(ds_cnt,10)=1)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
     ENDIF
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = "MEDS_UNCHARTED_INERROR", dsr->qual[qualcnt].qual[
     ds_cnt].stat_str_val = "NO_NEW_DATA"
    ENDIF
   WITH nocounter, nullreport
  ;end select
 ENDIF
 CALL dsvm_error(" UE_NURSING_MEDS_MANAGEMENT - UNCHARTED_INERROR")
 SET stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt)
 SET ds_cnt = 0
 IF (inerror > 0.0
  AND inerrnomut > 0.0
  AND inerrnoview > 0.0
  AND med_cd > 0.0
  AND immun_cd > 0.0
  AND grp_cd > 0.0)
  SELECT INTO "nl:"
   p.person_id, p.username, p.name_last,
   p.name_first, p.name_full_formatted, p.email,
   p.physician_ind, p.position_cd
   FROM shared_value_gttd cetemp,
    clinical_event ce,
    prsnl p,
    task_activity ta
   PLAN (cetemp
    WHERE cetemp.source_entity_name="DM_STAT_NURSING_METRICS")
    JOIN (ce
    WHERE cetemp.source_entity_value=ce.clinical_event_id
     AND  NOT (ce.result_status_cd IN (inerror, inerrnomut, inerrnoview))
     AND  NOT (ce.event_class_cd IN (med_cd, immun_cd))
     AND ((ce.event_class_cd != grp_cd) OR ( NOT ( EXISTS (
    (SELECT
     1
     FROM clinical_event ce2
     WHERE ce2.parent_event_id=ce.event_id
      AND  NOT (ce2.event_class_cd IN (med_cd, immun_cd)))))))
     AND ce.performed_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.order_id > 0)
    JOIN (p
    WHERE ce.performed_prsnl_id=p.person_id)
    JOIN (ta
    WHERE ta.order_id=ce.order_id
     AND ta.task_class_cd=scheduled_cd)
   ORDER BY p.person_id, ce.entry_mode_cd, ce.parent_event_id
   HEAD REPORT
    IF (ds_cnt=0)
     qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
      = cnvtdatetime(ds_begin_snapshot),
     dsr->qual[qualcnt].snapshot_type = "UE_NURSING_CHARTING-NON_MEDS"
    ENDIF
    row_cnt = 0, solution_recorded = 0
   HEAD p.person_id
    solution_recorded = 0
   HEAD ce.entry_mode_cd
    num_backcharts = 0, num_futurecharts = 0, solution_recorded = 0
   HEAD ce.parent_event_id
    violator_fnd = 0
   DETAIL
    IF (violator_fnd=0)
     IF (abs(datetimediff(ta.scheduled_dt_tm,ce.performed_dt_tm,4)) > chart_mins)
      IF (ta.scheduled_dt_tm < ce.performed_dt_tm)
       num_backcharts = (num_backcharts+ 1), violator_fnd = 1
      ELSE
       num_futurecharts = (num_futurecharts+ 1), violator_fnd = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  ce.entry_mode_cd
    IF (((num_backcharts > 0) OR (num_futurecharts > 0)) )
     ds_cnt = (ds_cnt+ 2), row_cnt = (row_cnt+ 1)
     IF (((mod(ds_cnt,10)=2) OR (mod(ds_cnt,10)=1)) )
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ (10 - mod(ds_cnt,10))))
     ENDIF
     solution_name = trim(cnvtupper(uar_get_code_display(ce.entry_mode_cd)))
     IF (solution_name="")
      solution_name = "UNKNOWN"
     ENDIF
     clob_value = build(trim(p.username),"||",trim(p.name_last),"||",trim(p.name_first),
      "||",trim(p.name_full_formatted),"||",trim(p.email),"||",
      p.physician_ind,"||",uar_get_code_display(p.position_cd),"||",cnvtstring(p.person_id,11,2)),
     dsr->qual[qualcnt].qual[(ds_cnt - 1)].stat_name = build("BACK_CHARTS||",solution_name), dsr->
     qual[qualcnt].qual[(ds_cnt - 1)].stat_seq = row_cnt,
     dsr->qual[qualcnt].qual[(ds_cnt - 1)].stat_number_val = num_backcharts, dsr->qual[qualcnt].qual[
     (ds_cnt - 1)].stat_clob_val = clob_value, dsr->qual[qualcnt].qual[ds_cnt].stat_name = build(
      "FUTURE_CHARTS||",solution_name),
     dsr->qual[qualcnt].qual[ds_cnt].stat_seq = row_cnt, dsr->qual[qualcnt].qual[ds_cnt].
     stat_number_val = num_futurecharts, dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = clob_value
    ENDIF
    solution_recorded = 1
   FOOT  p.person_id
    IF (solution_recorded=0)
     IF (((num_backcharts > 0) OR (num_futurecharts > 0)) )
      ds_cnt = (ds_cnt+ 2), row_cnt = (row_cnt+ 1)
      IF (((mod(ds_cnt,10)=2) OR (mod(ds_cnt,10)=1)) )
       stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ (10 - mod(ds_cnt,10))))
      ENDIF
      solution_name = trim(cnvtupper(uar_get_code_display(ce.entry_mode_cd)))
      IF (solution_name="")
       solution_name = "UNKNOWN"
      ENDIF
      clob_value = build(trim(p.username),"||",trim(p.name_last),"||",trim(p.name_first),
       "||",trim(p.name_full_formatted),"||",trim(p.email),"||",
       p.physician_ind,"||",uar_get_code_display(p.position_cd),"||",cnvtstring(p.person_id,11,2)),
      dsr->qual[qualcnt].qual[(ds_cnt - 1)].stat_name = build("BACK_CHARTS||",solution_name), dsr->
      qual[qualcnt].qual[(ds_cnt - 1)].stat_seq = row_cnt,
      dsr->qual[qualcnt].qual[(ds_cnt - 1)].stat_number_val = num_backcharts, dsr->qual[qualcnt].
      qual[(ds_cnt - 1)].stat_clob_val = clob_value, dsr->qual[qualcnt].qual[ds_cnt].stat_name =
      build("FUTURE_CHARTS||",solution_name),
      dsr->qual[qualcnt].qual[ds_cnt].stat_seq = row_cnt, dsr->qual[qualcnt].qual[ds_cnt].
      stat_number_val = num_futurecharts, dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = clob_value
     ENDIF
    ENDIF
   FOOT REPORT
    IF (row_cnt=0)
     ds_cnt = (ds_cnt+ 2)
     IF (mod(ds_cnt,10)=2)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ (10 - mod(ds_cnt,10))))
     ENDIF
     dsr->qual[qualcnt].qual[(ds_cnt - 1)].stat_name = "BACK_CHARTS", dsr->qual[qualcnt].qual[(ds_cnt
      - 1)].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_name = "FUTURE_CHARTS",
     dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA"
    ENDIF
   WITH nocounter, nullreport
  ;end select
  SET stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt)
 ENDIF
 CALL dsvm_error("UE_NURSING_CHARTING-NON_MEDS")
 SET ds_cnt = 0
 IF (auth_cd > 0.0
  AND unauth_cd > 0.0
  AND altered_cd > 0.0
  AND modified_cd > 0.0
  AND immun_cd > 0.0
  AND med_cd > 0.0
  AND scheduled_cd > 0.0)
  SELECT INTO "nl:"
   p.person_id, ce.parent_event_id, ce.event_id
   FROM clinical_event ce,
    ce_med_result cmr,
    task_activity ta,
    prsnl p,
    shared_value_gttd cetemp
   PLAN (cetemp
    WHERE cetemp.source_entity_name="DM_STAT_NURSING_METRICS")
    JOIN (ce
    WHERE cetemp.source_entity_value=ce.clinical_event_id
     AND ce.result_status_cd IN (auth_cd, unauth_cd, altered_cd, modified_cd)
     AND ce.event_class_cd IN (immun_cd, med_cd)
     AND ce.performed_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
     AND ce.order_id > 0)
    JOIN (cmr
    WHERE cmr.event_id=ce.event_id
     AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
    JOIN (ta
    WHERE ta.order_id=ce.order_id
     AND ta.task_class_cd=scheduled_cd)
    JOIN (p
    WHERE p.person_id=ce.performed_prsnl_id)
   ORDER BY p.person_id, ce.parent_event_id
   HEAD REPORT
    IF (ds_cnt=0)
     qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
      = cnvtdatetime(ds_begin_snapshot),
     dsr->qual[qualcnt].snapshot_type = "UE_NURSING_CHARTING-MEDS"
    ENDIF
    row_cnt = 0
   HEAD p.person_id
    num_backcharts = 0, num_futurecharts = 0
   HEAD ce.parent_event_id
    violator_fnd = 0
   DETAIL
    IF (violator_fnd=0)
     IF (abs(datetimediff(ta.scheduled_dt_tm,ce.performed_dt_tm,4)) > chart_mins)
      IF (ta.scheduled_dt_tm > ce.performed_dt_tm)
       num_futurecharts = (num_futurecharts+ 1)
      ELSE
       num_backcharts = (num_backcharts+ 1)
      ENDIF
      violator_fnd = 1
     ENDIF
    ENDIF
   FOOT  p.person_id
    IF (((num_backcharts > 0) OR (num_futurecharts > 0)) )
     ds_cnt = (ds_cnt+ 2), row_cnt = (row_cnt+ 1)
     IF (((mod(ds_cnt,10)=2) OR (mod(ds_cnt,10)=1)) )
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ (10 - mod(ds_cnt,10))))
     ENDIF
     clob_value = build(trim(p.username),"||",trim(p.name_last),"||",trim(p.name_first),
      "||",trim(p.name_full_formatted),"||",trim(p.email),"||",
      p.physician_ind,"||",uar_get_code_display(p.position_cd),"||",cnvtstring(p.person_id,11,2)),
     dsr->qual[qualcnt].qual[(ds_cnt - 1)].stat_name = build("BACK_CHARTS"), dsr->qual[qualcnt].qual[
     (ds_cnt - 1)].stat_seq = row_cnt,
     dsr->qual[qualcnt].qual[(ds_cnt - 1)].stat_number_val = num_backcharts, dsr->qual[qualcnt].qual[
     (ds_cnt - 1)].stat_clob_val = clob_value, dsr->qual[qualcnt].qual[ds_cnt].stat_name = build(
      "FUTURE_CHARTS"),
     dsr->qual[qualcnt].qual[ds_cnt].stat_seq = row_cnt, dsr->qual[qualcnt].qual[ds_cnt].
     stat_number_val = num_futurecharts, dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = clob_value
    ENDIF
   FOOT REPORT
    IF (row_cnt=0)
     ds_cnt = (ds_cnt+ 2)
     IF (((mod(ds_cnt,10)=2) OR (mod(ds_cnt,10)=1)) )
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ (10 - mod(ds_cnt,10))))
     ENDIF
     dsr->qual[qualcnt].qual[(ds_cnt - 1)].stat_name = "BACK_CHARTS", dsr->qual[qualcnt].qual[(ds_cnt
      - 1)].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_name = "FUTURE_CHARTS",
     dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA"
    ENDIF
   WITH nocounter, nullreport
  ;end select
  SET stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt)
 ENDIF
 CALL dsvm_error(" UE_NURSING_CHARTING-MEDS")
 EXECUTE dm_stat_snaps_load
END GO
