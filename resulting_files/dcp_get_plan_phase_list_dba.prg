CREATE PROGRAM dcp_get_plan_phase_list:dba
 SET modify = predeclare
 DECLARE n_processing_status_unknown = i2 WITH protect, constant(0)
 DECLARE n_processing_status_processing = i2 WITH protect, constant(1)
 DECLARE n_processing_status_failed_in_processing = i2 WITH protect, constant(2)
 DECLARE n_processing_status_not_processing = i2 WITH protect, constant(3)
 SUBROUTINE (getpwprocessingstatus(updatecount=i4,processingupdatecount=i4,processingdttm=dq8,
  staleinminutes=i4) =i2)
   DECLARE expiredttm = dq8 WITH private
   SET expiredttm = cnvtlookahead(build('"',staleinminutes,',MIN"'),cnvtdatetime(processingdttm))
   IF (expiredttm > cnvtdatetime(sysdate))
    IF (updatecount < processingupdatecount)
     RETURN(n_processing_status_processing)
    ELSE
     RETURN(n_processing_status_not_processing)
    ENDIF
   ELSE
    IF (updatecount >= processingupdatecount)
     RETURN(n_processing_status_not_processing)
    ELSE
     RETURN(n_processing_status_failed_in_processing)
    ENDIF
   ENDIF
 END ;Subroutine
 RECORD temp(
   1 planlist[*]
     2 pw_group_nbr = f8
     2 pw_group_desc = vc
     2 type_mean = c12
     2 cross_encntr_ind = i2
     2 version = i4
     2 version_pw_cat_id = f8
     2 newest_version = i4
     2 newest_version_active_ind = i2
     2 newest_version_pw_cat_id = f8
     2 pathway_catalog_id = f8
     2 pathway_type_cd = f8
     2 pathway_class_cd = f8
     2 focus_ind = i2
     2 status_ind = i2
     2 cycle_nbr = i4
     2 default_view_mean = c12
     2 diagnosis_capture_ind = i2
     2 allow_copy_forward_ind = i2
     2 ref_owner_person_id = f8
     2 facility_access_ind = i2
     2 init_encntr_id = f8
     2 cycle_label_cd = f8
     2 cycle_end_nbr = i4
     2 synonym_name = vc
     2 pathway_customized_plan_id = f8
     2 reference_plan_name = vc
     2 facility_access_pw_cat_id = f8
     2 phaselist[*]
       3 pathway_id = f8
       3 description = vc
       3 pw_status_cd = f8
       3 encntr_id = f8
       3 type_mean = c12
       3 duration_qty = i4
       3 duration_unit_cd = f8
       3 started_ind = i2
       3 updt_cnt = i4
       3 start_dt_tm = dq8
       3 calc_end_dt_tm = dq8
       3 order_dt_tm = dq8
       3 pathway_catalog_id = f8
       3 last_updt_dt_tm = dq8
       3 last_updt_prsnl_id = f8
       3 display_method_cd = f8
       3 parent_phase_desc = vc
       3 sub_sequence = i4
       3 start_tz = i4
       3 calc_end_tz = i4
       3 order_tz = i4
       3 last_updt_tz = i4
       3 alerts_on_plan_ind = i2
       3 alerts_on_plan_upd_ind = i2
       3 start_estimated_ind = i2
       3 calc_end_estimated_ind = i2
       3 future_ind = i2
       3 scheduled_facility_cd = f8
       3 scheduled_nursing_unit_cd = f8
       3 period_nbr = i4
       3 period_custom_label = vc
       3 review_status_flag = i2
       3 pathway_group_id = f8
       3 warning_level_bit = i4
       3 copy_source_pathway_id = f8
       3 review_required_sig_count = i4
       3 linked_phase_ind = i2
     2 restricted_actions_bitmask = i4
     2 override_mrd_on_plan_ind = i2
 )
 RECORD temp2(
   1 phaselist[*]
     2 plan_pathway_catalog_idx = i4
     2 phase_pathway_catalog_idx = i4
     2 pw_group_nbr = f8
     2 pw_group_desc = vc
     2 group_type_mean = c12
     2 cross_encntr_ind = i2
     2 version = i4
     2 version_pw_cat_id = f8
     2 newest_version = i4
     2 newest_version_active_ind = i2
     2 newest_version_pw_cat_id = f8
     2 pathway_type_cd = f8
     2 pathway_class_cd = f8
     2 display_method_cd = f8
     2 pathway_id = f8
     2 description = vc
     2 pw_status_cd = f8
     2 encntr_id = f8
     2 type_mean = c12
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 started_ind = i2
     2 updt_cnt = i4
     2 start_dt_tm = dq8
     2 calc_end_dt_tm = dq8
     2 order_dt_tm = dq8
     2 pathway_catalog_id = f8
     2 pw_cat_group_id = f8
     2 processing_ind = i2
     2 sub_phase_ind = i2
     2 last_updt_dt_tm = dq8
     2 last_updt_prsnl_id = f8
     2 last_updt_prsnl_name = vc
     2 parent_phase_desc = vc
     2 cycle_nbr = i4
     2 default_view_mean = c12
     2 diagnosis_capture_ind = i2
     2 allow_copy_forward_ind = i2
     2 facility_access_ind = i2
     2 start_tz = i4
     2 calc_end_tz = i4
     2 order_tz = i4
     2 last_updt_tz = i4
     2 ref_owner_person_id = f8
     2 sequence = i4
     2 included_ind = i2
     2 parent_pathway_id = f8
     2 alerts_on_plan_ind = i2
     2 alerts_on_plan_upd_ind = i2
     2 cycle_label_cd = f8
     2 cycle_end_nbr = i4
     2 scheduled_facility_cd = f8
     2 scheduled_nursing_unit_cd = f8
     2 synonym_name = vc
     2 processing_status_flag = i2
     2 processing_expired_date_time = dq8
     2 phasereltnlist[*]
       3 pathway_s_id = f8
       3 pathway_t_id = f8
       3 type_mean = c12
       3 sub_sequence = i4
       3 offset_qty = i4
       3 offset_unit_cd = f8
     2 planevidencelist[*]
       3 dcp_clin_cat_cd = f8
       3 dcp_clin_sub_cat_cd = f8
       3 pathway_comp_id = f8
       3 evidence_type_mean = c12
       3 pw_evidence_reltn_id = f8
       3 evidence_locator = vc
       3 pathway_catalog_id = f8
       3 evidence_sequence = i4
     2 nomenreltnlist[*]
       3 nomen_entity_reltn_id = f8
       3 nomenclature_id = f8
       3 priority = i4
       3 display = vc
       3 concept_cki = vc
       3 diagnosis_id = f8
       3 diag_type_cd = f8
       3 diag_type_disp = c40
       3 diag_type_mean = c12
       3 active_ind = i2
       3 source_vocab_cd = f8
       3 diagnosis_group = f8
       3 encntr_id = f8
     2 actions_count = i4
     2 last_upd_action_idx = i4
     2 last_alert_action_idx = i4
     2 actions[*]
       3 action_type_cd = f8
       3 action_dt_tm = dq8
       3 action_prsnl_id = f8
       3 prsnl_idx = i4
       3 pw_action_seq = i4
       3 pw_status_cd = f8
       3 action_tz = i4
       3 credential_idx = i4
       3 provider_id = f8
     2 compphasereltnlist[*]
       3 act_pw_comp_id = f8
       3 pathway_id = f8
       3 type_mean = vc
     2 start_estimated_ind = i2
     2 calc_end_estimated_ind = i2
     2 future_ind = i2
     2 period_nbr = i4
     2 period_custom_label = vc
     2 review_status_flag = i2
     2 protocol_review_info_count = i4
     2 protocolreviewinfolist[*]
       3 from_prsnl_idx = i4
       3 to_prsnl_idx = i4
       3 to_prsnl_group_id = f8
       3 to_prsnl_group_name = vc
       3 review_dt_tm = dq8
       3 review_tz = i4
     2 qualified_grouped_phase_count = i4
     2 hide_grouped_phases_ind = i2
     2 group_parent_temp2_idx = i4
     2 pathway_group_id = f8
     2 pathway_missing_reason_flag = i4
     2 do_not_load_phase = i2
     2 pathway_customized_plan_id = f8
     2 reference_plan_name = vc
     2 warning_level_bit = i4
     2 copy_source_pathway_id = f8
     2 review_required_sig_count = i4
     2 restricted_actions_bitmask = i4
     2 override_mrd_on_plan_ind = i2
     2 linked_phase_ind = i2
 )
 FREE RECORD plans
 RECORD plans(
   1 plan_id_list[*]
     2 plan_id = f8
 )
 FREE RECORD query
 RECORD query(
   1 query_list[*]
     2 value_count = i4
     2 value_size = i4
     2 value_loops = i4
     2 value_list[*]
       3 value = f8
       3 idx = i4
       3 sub_idx = i4
       3 exist_ind = i2
       3 index_count = i4
       3 index_list[*]
         4 idx = i4
         4 sub_idx = i4
         4 type = vc
 )
 FREE RECORD query_prsnl
 RECORD query_prsnl(
   1 batch_size = i4
   1 loop_count = i4
   1 count = i4
   1 size = i4
   1 list[*]
     2 prsnl_id = f8
     2 name_full_formatted = vc
     2 name_first = vc
     2 name_last = vc
 )
 FREE RECORD query_phase_action
 RECORD query_phase_action(
   1 batch_size = i4
   1 loop_count = i4
   1 count = i4
   1 size = i4
   1 phases[*]
     2 pathway_id = f8
     2 phase_idx = i4
 )
 FREE RECORD query_pathway_notification
 RECORD query_pathway_notification(
   1 batch_size = i4
   1 loop_count = i4
   1 count = i4
   1 size = i4
   1 phases[*]
     2 pathway_id = f8
     2 phase_idx = i4
 )
 FREE RECORD query_credential
 RECORD query_credential(
   1 batch_size = i4
   1 loop_count = i4
   1 count = i4
   1 size = i4
   1 personnel[*]
     2 prsnl_id = f8
     2 phase_idx = i4
     2 count = i4
     2 size = i4
     2 credential[*]
       3 credential_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
 )
 FREE RECORD query_pathway_catalog
 RECORD query_pathway_catalog(
   1 batch_size = i4
   1 loop_count = i4
   1 count = i4
   1 size = i4
   1 list[*]
     2 pathway_catalog_id = f8
     2 ref_text_ind = i2
     2 future_ind = i2
     2 route_for_review_ind = i2
     2 reschedule_reason_accept_flag = i2
     2 allow_activate_all_ind = i2
     2 evidence_list[*]
       3 dcp_clin_cat_cd = f8
       3 dcp_clin_sub_cat_cd = f8
       3 pathway_comp_id = f8
       3 evidence_type_mean = c12
       3 pw_evidence_reltn_id = f8
       3 evidence_locator = vc
       3 pathway_catalog_id = f8
       3 evidence_sequence = i4
 )
 FREE RECORD query_parent_phases
 RECORD query_parent_phases(
   1 batch_size = i4
   1 loop_count = i4
   1 count = i4
   1 size = i4
   1 phases[*]
     2 pathway_id = f8
     2 phase_idx = i4
 )
 DECLARE subidx = i4 WITH noconstant(0)
 DECLARE subhigh = i4 WITH noconstant(0)
 DECLARE i = i4 WITH noconstant(0)
 DECLARE j = i4 WITH noconstant(0)
 DECLARE k = i4 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE total = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE max = i4 WITH noconstant(0)
 DECLARE phasecnt = i4 WITH noconstant(0)
 DECLARE plancnt = i4 WITH noconstant(0)
 DECLARE cur_date_in_min = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE high = i4 WITH noconstant(0)
 DECLARE rhigh = i4 WITH noconstant(0)
 DECLARE start = i4 WITH noconstant(0)
 DECLARE stop = i4 WITH noconstant(0)
 DECLARE found = c1 WITH noconstant("N")
 DECLARE cur_dt_tm = dq8 WITH constant(cnvtdatetime(sysdate))
 DECLARE loadphasediagnosislinks = c1 WITH noconstant("N")
 DECLARE subphasecnt = i4 WITH noconstant(0)
 DECLARE planidxcnt = i4 WITH noconstant(0)
 DECLARE curplannbr = f8 WITH noconstant(0.0)
 DECLARE first = i4 WITH noconstant(0)
 DECLARE last = i4 WITH noconstant(0)
 DECLARE phasetotal = i4 WITH noconstant(0)
 DECLARE cursubphaseid = f8 WITH noconstant(0.0)
 DECLARE nincludecnt = i4 WITH constant(size(request->plantypeincludelist,5))
 DECLARE nexcludecnt = i4 WITH constant(size(request->plantypeexcludelist,5))
 DECLARE nplanidincludecnt = i4 WITH constant(size(request->planidincludelist,5))
 DECLARE ballowplan = i2 WITH noconstant(1)
 DECLARE prsnl_credential_idx = i4 WITH noconstant(0)
 DECLARE credential_idx = i4 WITH noconstant(0)
 DECLARE credential_list_size = i4 WITH noconstant(0)
 DECLARE b_processed_last_updated = i2 WITH protect, noconstant(0)
 DECLARE d_action_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE plan_pathway_catalog_idx = i4 WITH protect, noconstant(0)
 DECLARE phase_pathway_catalog_idx = i4 WITH protect, noconstant(0)
 DECLARE l_stale_in_min = i4 WITH protect, constant(evaluate(validate(request->stale_in_min,0),0,10,
   validate(request->stale_in_min,0)))
 DECLARE movedind = i2 WITH noconstant(0)
 DECLARE ivsequence_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30183,"IVSEQUENCE"))
 SET cur_date_in_min = cnvtmin2(cnvtdate(cur_dt_tm),cnvttime(cur_dt_tm))
 DECLARE cstatus = c1 WITH protect, noconstant("F")
 DECLARE person_id = f8 WITH protect, constant(validate(request->person_id,0.0))
 DECLARE debug = i2 WITH protect, constant(validate(request->debug,0))
 DECLARE query_list_exists = i2 WITH protect, constant(validate(request->querylist))
 DECLARE access_list_exists = i2 WITH protect, constant(validate(request->accesslist))
 IF (person_id <= 0.0
  AND access_list_exists=0)
  GO TO exit_script
 ENDIF
 DECLARE access_cnt = i4 WITH protect, constant(value(size(request->accesslist,5)))
 IF (person_id <= 0.0
  AND access_cnt <= 0)
  SET cstatus = "Z"
  GO TO exit_script
 ENDIF
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE facility_cd = f8 WITH protect, constant(validate(request->facility_cd,0.0))
 DECLARE load_tapers_only_ind = i2 WITH protect, constant(validate(request->load_tapers_only_ind,0))
 DECLARE query_cnt = i4 WITH protect, constant(value(size(request->querylist,5)))
 DECLARE code_set_pw_status = i4 WITH protect, constant(16769)
 DECLARE pw_planned_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",code_set_pw_status,
   "PLANNED"))
 DECLARE pw_dropped_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",code_set_pw_status,
   "DROPPED"))
 DECLARE pw_initiated_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",code_set_pw_status,
   "INITIATED"))
 DECLARE pw_future_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",code_set_pw_status,
   "FUTURE"))
 DECLARE pw_initiated_review_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",
   code_set_pw_status,"INITREVIEW"))
 DECLARE pw_future_review_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",code_set_pw_status,
   "FUTUREREVIEW"))
 DECLARE code_set_action_type = i4 WITH protect, constant(16809)
 DECLARE action_type_ran_alert_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",
   code_set_action_type,"RANALERT"))
 DECLARE notification_type_none = i2 WITH protect, constant(0)
 DECLARE notification_type_phase_protocol_review = i2 WITH protect, constant(1)
 DECLARE notification_status_none = i2 WITH protect, constant(0)
 DECLARE notification_status_pending = i2 WITH protect, constant(1)
 DECLARE notification_status_accepted = i2 WITH protect, constant(2)
 DECLARE notification_status_rejected = i2 WITH protect, constant(3)
 DECLARE notification_status_forwarded = i2 WITH protect, constant(4)
 DECLARE notification_status_no_longer_needed = i2 WITH protect, constant(5)
 DECLARE notification_status_planning = i2 WITH protect, constant(6)
 DECLARE review_status_none = i2 WITH protect, constant(0)
 DECLARE review_status_pending = i2 WITH protect, constant(1)
 DECLARE review_status_completed = i2 WITH protect, constant(2)
 DECLARE review_status_rejected = i2 WITH protect, constant(3)
 DECLARE review_status_opt_out = i2 WITH protect, constant(4)
 DECLARE review_status_planning = i2 WITH protect, constant(5)
 DECLARE batch_size_default = i4 WITH protect, constant(20)
 DECLARE encounter_batch_size = i4 WITH protect, constant(5)
 DECLARE plan_batch_size = i4 WITH protect, constant(10)
 DECLARE phase_batch_size = i4 WITH protect, constant(10)
 DECLARE l_action_idx_from = i4 WITH protect, noconstant(0)
 DECLARE l_action_idx_to = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE nfindidx = i4 WITH protect, noconstant(0)
 DECLARE nfoundidx = i4 WITH protect, noconstant(0)
 DECLARE nplanlistsize = i4 WITH protect, noconstant(0)
 DECLARE nplannewlistsize = i4 WITH protect, noconstant(0)
 DECLARE nphaselistsize = i4 WITH protect, noconstant(0)
 DECLARE nphasenewlistsize = i4 WITH protect, noconstant(0)
 DECLARE ntotalplans = i4 WITH protect, noconstant(0)
 DECLARE nbatchsize = i4 WITH protect, noconstant(0)
 DECLARE nloopcount = i4 WITH protect, noconstant(0)
 DECLARE nlistsize = i4 WITH protect, noconstant(0)
 DECLARE nnewlistsize = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE idx3 = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, noconstant(1)
 DECLARE lcount = i4 WITH protect, noconstant(0)
 DECLARE lsize = i4 WITH protect, noconstant(0)
 DECLARE lbatchsize = i4 WITH protect, noconstant(0)
 DECLARE lloopcount = i4 WITH protect, noconstant(0)
 DECLARE cntr = i4 WITH protect, noconstant(0)
 DECLARE plan_id_list_size = i4 WITH protect, noconstant(0)
 DECLARE lqueryindex = i4 WITH protect, noconstant(0)
 DECLARE query_act_pw_comp = i4 WITH protect, constant(increment(lqueryindex))
 DECLARE query_index_total = i4 WITH protect, constant(lqueryindex)
 SET stat = alterlist(query->query_list,query_index_total)
 IF (access_cnt > 0)
  SET nlistsize = access_cnt
  SET nbatchsize = encounter_batch_size
  SET nloopcount = ceil((cnvtreal(nlistsize)/ nbatchsize))
  SET nnewlistsize = (nloopcount * nbatchsize)
  SET nstart = 1
  SET stat = alterlist(request->accesslist,nnewlistsize)
  FOR (idx = (nlistsize+ 1) TO nnewlistsize)
    SET request->accesslist[idx].encntr_id = request->accesslist[nlistsize].encntr_id
  ENDFOR
 ENDIF
 IF (debug=1)
  CALL echorecord(request)
 ENDIF
 SELECT INTO "nl:"
  pw.pw_status_cd, pw.pw_group_nbr
  FROM pathway pw
  WHERE expand(num,nstart,access_cnt,pw.encntr_id,request->accesslist[num].encntr_id)
   AND ((query_cnt > 0
   AND (( NOT (pw.pw_status_cd IN (pw_planned_cd, pw_future_cd, pw_future_review_cd,
  pw_initiated_review_cd))
   AND (((pw.encntr_id=request->querylist[1].encntr_id)) OR (((pw.type_mean="TAPERPLAN") OR (pw
  .pathway_type_cd=ivsequence_cd)) )) ) OR (pw.pw_status_cd IN (pw_planned_cd, pw_future_cd,
  pw_future_review_cd, pw_initiated_review_cd)
   AND ((pw.cross_encntr_ind=1) OR (((pw.cross_encntr_ind=0
   AND pw.started_ind=0) OR (pw.cross_encntr_ind=0
   AND (pw.encntr_id=request->querylist[1].encntr_id))) )) )) ) OR (query_cnt=0))
  HEAD REPORT
   plan_id_list_size = 10, stat = alterlist(plans->plan_id_list,plan_id_list_size), cntr = 1
  HEAD pw.pw_group_nbr
   plans->plan_id_list[cntr].plan_id = pw.pw_group_nbr, cntr += 1
  FOOT  pw.pw_group_nbr
   IF (cntr > plan_id_list_size)
    plan_id_list_size += 10, stat = alterlist(plans->plan_id_list,plan_id_list_size)
   ENDIF
  FOOT REPORT
   stat = alterlist(plans->plan_id_list,(cntr - 1))
  WITH nocounter, expand = 2, orahintcbo(
    "Query to fetch the plan ids which qualify for the patient based on Encounter_filter pref")
 ;end select
 SET ntotalplans = size(plans->plan_id_list,5)
 SELECT
  IF (access_cnt > 0
   AND load_tapers_only_ind=1)INTO "nl:"
   pw.pathway_id, pw.person_id, pw.encntr_id
   FROM pathway pw,
    pathway_catalog pwc
   PLAN (pw
    WHERE expand(num,nstart,ntotalplans,pw.pw_group_nbr,plans->plan_id_list[num].plan_id)
     AND pw.type_mean="TAPERPLAN")
    JOIN (pwc
    WHERE pwc.pathway_catalog_id=pw.pw_cat_group_id)
   ORDER BY pw.pw_group_nbr, pw.pathway_id
  ELSEIF (access_cnt > 0
   AND load_tapers_only_ind=0)INTO "nl:"
   pw.pathway_id, pw.person_id, pw.encntr_id
   FROM pathway pw,
    pathway_catalog pwc
   PLAN (pw
    WHERE expand(num,nstart,ntotalplans,pw.pw_group_nbr,plans->plan_id_list[num].plan_id)
     AND pw.pw_status_cd != pw_dropped_cd)
    JOIN (pwc
    WHERE pwc.pathway_catalog_id=pw.pw_cat_group_id)
   ORDER BY pw.pw_group_nbr, pw.pathway_id
  ELSEIF (access_cnt <= 0
   AND load_tapers_only_ind=1)INTO "nl:"
   pw.pathway_id, pw.person_id, pw.encntr_id
   FROM pathway pw,
    pathway_catalog pwc
   PLAN (pw
    WHERE pw.person_id=person_id
     AND expand(num,nstart,ntotalplans,pw.pw_group_nbr,plans->plan_id_list[num].plan_id)
     AND pw.type_mean="TAPERPLAN")
    JOIN (pwc
    WHERE pwc.pathway_catalog_id=pw.pw_cat_group_id)
   ORDER BY pw.pw_group_nbr, pw.pathway_id
  ELSEIF (access_cnt <= 0
   AND load_tapers_only_ind=0)INTO "nl:"
   pw.pathway_id, pw.person_id, pw.encntr_id
   FROM pathway pw,
    pathway_catalog pwc
   PLAN (pw
    WHERE pw.person_id=person_id
     AND expand(num,nstart,ntotalplans,pw.pw_group_nbr,plans->plan_id_list[num].plan_id)
     AND pw.pw_status_cd != pw_dropped_cd)
    JOIN (pwc
    WHERE pwc.pathway_catalog_id=pw.pw_cat_group_id)
   ORDER BY pw.pw_group_nbr, pw.pathway_id
  ELSE
  ENDIF
  HEAD REPORT
   plancnt = 0, ballowplan = 1
  HEAD pw.pw_group_nbr
   ballowplan = 1
   IF (pw.pathway_type_cd != 0.0)
    IF (nexcludecnt > 0)
     IF (0 < locateval(num,1,nexcludecnt,pw.pathway_type_cd,request->plantypeexcludelist[num].
      pathway_type_cd))
      ballowplan = 0
     ENDIF
    ELSEIF (nincludecnt > 0)
     IF (0 >= locateval(num,1,nincludecnt,pw.pathway_type_cd,request->plantypeincludelist[num].
      pathway_type_cd))
      ballowplan = 0
     ENDIF
    ENDIF
   ENDIF
   IF (nplanidincludecnt > 0)
    IF (locateval(num,1,nplanidincludecnt,pw.pw_group_nbr,request->planidincludelist[num].plan_id)
     <= 0)
     ballowplan = 0
    ENDIF
   ENDIF
   IF (ballowplan=1)
    plancnt += 1, phasecnt = 0, nphasenewlistsize = 0
    IF (plancnt > nplannewlistsize)
     nplannewlistsize += plan_batch_size, stat = alterlist(temp->planlist,nplannewlistsize)
    ENDIF
    temp->planlist[plancnt].pw_group_nbr = pw.pw_group_nbr, temp->planlist[plancnt].pw_group_desc =
    trim(pw.pw_group_desc), temp->planlist[plancnt].cross_encntr_ind = pw.cross_encntr_ind,
    temp->planlist[plancnt].version = pw.pw_cat_version, temp->planlist[plancnt].pathway_catalog_id
     = pw.pw_cat_group_id, temp->planlist[plancnt].pathway_type_cd = pw.pathway_type_cd,
    temp->planlist[plancnt].pathway_class_cd = pw.pathway_class_cd, temp->planlist[plancnt].
    status_ind = 0, temp->planlist[plancnt].cycle_nbr = pw.cycle_nbr,
    temp->planlist[plancnt].default_view_mean = pw.default_view_mean, temp->planlist[plancnt].
    diagnosis_capture_ind = pw.diagnosis_capture_ind, temp->planlist[plancnt].version_pw_cat_id = pwc
    .version_pw_cat_id,
    temp->planlist[plancnt].cycle_label_cd = pw.cycle_label_cd, temp->planlist[plancnt].cycle_end_nbr
     = pw.cycle_end_nbr, temp->planlist[plancnt].synonym_name = trim(pw.synonym_name),
    temp->planlist[plancnt].pathway_customized_plan_id = pw.pathway_customized_plan_id, temp->
    planlist[plancnt].reference_plan_name = trim(pwc.display_description), temp->planlist[plancnt].
    facility_access_pw_cat_id = pw.pw_cat_group_id
    IF (query_cnt <= 0
     AND load_tapers_only_ind=0)
     temp->planlist[plancnt].focus_ind = 1
    ELSE
     temp->planlist[plancnt].focus_ind = 0
    ENDIF
    IF ((temp->planlist[plancnt].diagnosis_capture_ind=1))
     loadphasediagnosislinks = "Y"
    ENDIF
    temp->planlist[plancnt].restricted_actions_bitmask = pwc.restricted_actions_bitmask, temp->
    planlist[plancnt].override_mrd_on_plan_ind = validate(pwc.override_mrd_on_plan_ind,0)
   ENDIF
  HEAD pw.pathway_id
   IF (ballowplan=1)
    IF (pw.type_mean="PHASE")
     temp->planlist[plancnt].type_mean = "PATHWAY"
    ELSEIF (pw.type_mean="CAREPLAN")
     temp->planlist[plancnt].type_mean = "CAREPLAN"
    ELSEIF (pw.type_mean="TAPERPLAN")
     temp->planlist[plancnt].type_mean = "TAPERPLAN"
    ENDIF
    phasecnt += 1
    IF (phasecnt > nphasenewlistsize)
     nphasenewlistsize += phase_batch_size, stat = alterlist(temp->planlist[plancnt].phaselist,
      nphasenewlistsize)
    ENDIF
    temp->planlist[plancnt].phaselist[phasecnt].pathway_id = pw.pathway_id, temp->planlist[plancnt].
    phaselist[phasecnt].description = trim(pw.description), temp->planlist[plancnt].phaselist[
    phasecnt].pw_status_cd = pw.pw_status_cd,
    temp->planlist[plancnt].phaselist[phasecnt].encntr_id = pw.encntr_id, temp->planlist[plancnt].
    phaselist[phasecnt].type_mean = pw.type_mean, temp->planlist[plancnt].phaselist[phasecnt].
    duration_qty = pw.duration_qty,
    temp->planlist[plancnt].phaselist[phasecnt].duration_unit_cd = pw.duration_unit_cd, temp->
    planlist[plancnt].phaselist[phasecnt].started_ind = pw.started_ind, temp->planlist[plancnt].
    phaselist[phasecnt].updt_cnt = pw.updt_cnt,
    temp->planlist[plancnt].phaselist[phasecnt].start_dt_tm = pw.start_dt_tm, temp->planlist[plancnt]
    .phaselist[phasecnt].calc_end_dt_tm = pw.calc_end_dt_tm, temp->planlist[plancnt].phaselist[
    phasecnt].order_dt_tm = pw.order_dt_tm,
    temp->planlist[plancnt].phaselist[phasecnt].pathway_catalog_id = pw.pathway_catalog_id, temp->
    planlist[plancnt].phaselist[phasecnt].display_method_cd = pw.display_method_cd, temp->planlist[
    plancnt].phaselist[phasecnt].parent_phase_desc = pw.parent_phase_desc,
    temp->planlist[plancnt].phaselist[phasecnt].start_tz = pw.start_tz, temp->planlist[plancnt].
    phaselist[phasecnt].calc_end_tz = pw.calc_end_tz, temp->planlist[plancnt].phaselist[phasecnt].
    order_tz = pw.order_tz,
    temp->planlist[plancnt].phaselist[phasecnt].alerts_on_plan_ind = pw.alerts_on_plan_ind, temp->
    planlist[plancnt].phaselist[phasecnt].alerts_on_plan_upd_ind = pw.alerts_on_plan_upd_ind, temp->
    planlist[plancnt].phaselist[phasecnt].start_estimated_ind = pw.start_estimated_ind,
    temp->planlist[plancnt].phaselist[phasecnt].calc_end_estimated_ind = pw.calc_end_estimated_ind,
    temp->planlist[plancnt].phaselist[phasecnt].scheduled_facility_cd = pw
    .future_location_facility_cd, temp->planlist[plancnt].phaselist[phasecnt].
    scheduled_nursing_unit_cd = pw.future_location_nurse_unit_cd,
    temp->planlist[plancnt].phaselist[phasecnt].period_nbr = pw.period_nbr, temp->planlist[plancnt].
    phaselist[phasecnt].period_custom_label = trim(pw.period_custom_label), temp->planlist[plancnt].
    phaselist[phasecnt].review_status_flag = pw.review_status_flag,
    temp->planlist[plancnt].phaselist[phasecnt].pathway_group_id = pw.pathway_group_id, temp->
    planlist[plancnt].phaselist[phasecnt].warning_level_bit = pw.warning_level_bit, temp->planlist[
    plancnt].phaselist[phasecnt].copy_source_pathway_id = pw.copy_source_pathway_id,
    temp->planlist[plancnt].phaselist[phasecnt].review_required_sig_count = pw
    .review_required_sig_count, temp->planlist[plancnt].phaselist[phasecnt].linked_phase_ind = pw
    .linked_phase_ind
    IF (pw.ref_owner_person_id > 0)
     temp->planlist[plancnt].ref_owner_person_id = pw.ref_owner_person_id
    ENDIF
    IF (pw.pw_status_cd IN (pw_planned_cd, pw_future_cd, pw_future_review_cd, pw_initiated_review_cd)
    )
     temp->planlist[plancnt].status_ind = 1
    ELSEIF (load_tapers_only_ind=0
     AND (temp->planlist[plancnt].focus_ind=0))
     IF (locateval(nfindidx,1,query_cnt,pw.encntr_id,request->querylist[nfindidx].encntr_id) > 0)
      IF (pw.started_ind=1)
       temp->planlist[plancnt].focus_ind = 1
      ELSE
       temp->planlist[plancnt].status_ind = 1
      ENDIF
     ENDIF
    ENDIF
    IF ((temp->planlist[plancnt].cross_encntr_ind=0))
     IF (pw.started_ind=1)
      temp->planlist[plancnt].init_encntr_id = pw.encntr_id
     ENDIF
    ENDIF
   ENDIF
  FOOT  pw.pathway_id
   IF (ballowplan=1)
    IF ((temp->planlist[plancnt].type_mean=null))
     temp->planlist[plancnt].type_mean = "CAREPLAN"
    ENDIF
    IF (((facility_cd=0.0) OR ((temp->planlist[plancnt].ref_owner_person_id > 0))) )
     temp->planlist[plancnt].facility_access_ind = 1
    ELSE
     temp->planlist[plancnt].facility_access_ind = 0
    ENDIF
   ENDIF
  FOOT  pw.pw_group_nbr
   nphaselistsize = phasecnt
   IF (ballowplan=1)
    stat = alterlist(temp->planlist[plancnt].phaselist,phasecnt)
   ENDIF
  FOOT REPORT
   nplanlistsize = plancnt
   FOR (i = (nplanlistsize+ 1) TO nplannewlistsize)
     temp->planlist[i].pathway_catalog_id = temp->planlist[nplanlistsize].pathway_catalog_id, temp->
     planlist[i].version_pw_cat_id = temp->planlist[nplanlistsize].version_pw_cat_id, temp->planlist[
     i].facility_access_ind = temp->planlist[nplanlistsize].facility_access_ind
   ENDFOR
   stat = alter(temp->planlist,nplanlistsize)
  WITH nocounter, expand = 2, orahintcbo("Query to fetch the plan and phase details")
 ;end select
 CALL echo(build("'Results =",plancnt,"'"))
 IF (nplannewlistsize > 0)
  SET nbatchsize = plan_batch_size
  SET nloopcount = ceil((cnvtreal(nplannewlistsize)/ nbatchsize))
  SET nstart = 1
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(nloopcount)),
    pathway_catalog pwc
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nbatchsize))))
    JOIN (pwc
    WHERE expand(num,nstart,(nstart+ (nbatchsize - 1)),pwc.version_pw_cat_id,temp->planlist[num].
     version_pw_cat_id)
     AND pwc.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
     AND pwc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   ORDER BY pwc.version_pw_cat_id, pwc.version
   HEAD REPORT
    dummy = 0
   DETAIL
    nfoundidx = 1, nfoundidx = locateval(nfindidx,nfoundidx,nplannewlistsize,pwc.version_pw_cat_id,
     temp->planlist[nfindidx].version_pw_cat_id)
    WHILE (nfoundidx > 0)
      temp->planlist[nfoundidx].newest_version = pwc.version, temp->planlist[nfoundidx].
      newest_version_active_ind = pwc.active_ind, temp->planlist[nfoundidx].newest_version_pw_cat_id
       = pwc.pathway_catalog_id,
      temp->planlist[nfoundidx].allow_copy_forward_ind = pwc.allow_copy_forward_ind
      IF ((pwc.version >= temp->planlist[nfoundidx].version))
       temp->planlist[nfoundidx].facility_access_pw_cat_id = pwc.pathway_catalog_id
      ENDIF
      nfoundidx += 1, nfoundidx = locateval(nfindidx,nfoundidx,nplannewlistsize,pwc.version_pw_cat_id,
       temp->planlist[nfindidx].version_pw_cat_id)
    ENDWHILE
   FOOT REPORT
    dummy = 0
   WITH nocounter, expand = 2, orahintcbo(
     "Query to load latest version of the plan from pathway catalog table")
  ;end select
  IF (facility_cd > 0.0
   AND load_tapers_only_ind=0)
   SET nstart = 1
   SELECT INTO "nl:"
    pcf.display_description_key, pcf.parent_entity_name, pcf.parent_entity_id
    FROM (dummyt d1  WITH seq = value(nloopcount)),
     pw_cat_flex pcf
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nbatchsize))))
     JOIN (pcf
     WHERE pcf.parent_entity_id IN (facility_cd, 0)
      AND pcf.parent_entity_name="CODE_VALUE"
      AND expand(num,nstart,(nstart+ (nbatchsize - 1)),pcf.pathway_catalog_id,temp->planlist[num].
      facility_access_pw_cat_id))
    HEAD REPORT
     dummy = 0
    DETAIL
     nfoundidx = 1, nfoundidx = locateval(nfindidx,nfoundidx,nplannewlistsize,0,temp->planlist[
      nfindidx].facility_access_ind,
      pcf.pathway_catalog_id,temp->planlist[nfindidx].facility_access_pw_cat_id)
     WHILE (nfoundidx > 0)
       temp->planlist[nfoundidx].facility_access_ind = 1, nfoundidx += 1, nfoundidx = locateval(
        nfindidx,nfoundidx,nplannewlistsize,0,temp->planlist[nfindidx].facility_access_ind,
        pcf.pathway_catalog_id,temp->planlist[nfindidx].facility_access_pw_cat_id)
     ENDWHILE
    FOOT REPORT
     dummy = 0
    WITH nocounter, expand = 2, orahintcbo(
      "Query to load correct version of plans from activity table")
   ;end select
  ENDIF
 ENDIF
 IF (debug=1)
  CALL echorecord(temp)
 ENDIF
 SET total = 0
 SET query_phase_action->batch_size = 20
 SET query_phase_action->count = 0
 SET query_phase_action->loop_count = 0
 SET query_phase_action->size = 0
 SET query_pathway_notification->batch_size = 20
 SET query_pathway_notification->count = 0
 SET query_pathway_notification->loop_count = 0
 SET query_pathway_notification->size = 0
 SET query_pathway_catalog->batch_size = 20
 SET query_pathway_catalog->count = 0
 SET query_pathway_catalog->loop_count = 0
 SET query_pathway_catalog->size = 0
 SET query_parent_phases->batch_size = 20
 SET query_parent_phases->count = 0
 SET query_parent_phases->loop_count = 0
 SET query_parent_phases->size = 0
 FOR (i = 1 TO value(size(temp->planlist,5)))
   SET plan_pathway_catalog_idx = getpathwaycatalogquerylistindex(temp->planlist[i].
    pathway_catalog_id)
   SET phasecnt = value(size(temp->planlist[i].phaselist,5))
   IF ((((temp->planlist[i].focus_ind=1)) OR ((((temp->planlist[i].type_mean="TAPERPLAN")) OR ((temp
   ->planlist[i].pathway_type_cd=ivsequence_cd))) )) )
    SET stat = alterlist(temp2->phaselist,(total+ phasecnt))
    FOR (j = 1 TO phasecnt)
      SET total += 1
      SET phase_pathway_catalog_idx = getpathwaycatalogquerylistindex(temp->planlist[i].phaselist[j].
       pathway_catalog_id)
      SET temp2->phaselist[total].plan_pathway_catalog_idx = plan_pathway_catalog_idx
      SET temp2->phaselist[total].phase_pathway_catalog_idx = phase_pathway_catalog_idx
      SET temp2->phaselist[total].pw_group_nbr = temp->planlist[i].pw_group_nbr
      SET temp2->phaselist[total].pw_group_desc = temp->planlist[i].pw_group_desc
      SET temp2->phaselist[total].group_type_mean = temp->planlist[i].type_mean
      SET temp2->phaselist[total].cross_encntr_ind = temp->planlist[i].cross_encntr_ind
      SET temp2->phaselist[total].version = temp->planlist[i].version
      SET temp2->phaselist[total].newest_version = temp->planlist[i].newest_version
      SET temp2->phaselist[total].newest_version_active_ind = temp->planlist[i].
      newest_version_active_ind
      SET temp2->phaselist[total].newest_version_pw_cat_id = temp->planlist[i].
      newest_version_pw_cat_id
      SET temp2->phaselist[total].pathway_type_cd = temp->planlist[i].pathway_type_cd
      SET temp2->phaselist[total].pathway_class_cd = temp->planlist[i].pathway_class_cd
      SET temp2->phaselist[total].pw_cat_group_id = temp->planlist[i].pathway_catalog_id
      SET temp2->phaselist[total].cycle_nbr = temp->planlist[i].cycle_nbr
      SET temp2->phaselist[total].default_view_mean = temp->planlist[i].default_view_mean
      SET temp2->phaselist[total].diagnosis_capture_ind = temp->planlist[i].diagnosis_capture_ind
      SET temp2->phaselist[total].allow_copy_forward_ind = temp->planlist[i].allow_copy_forward_ind
      SET temp2->phaselist[total].restricted_actions_bitmask = temp->planlist[i].
      restricted_actions_bitmask
      SET temp2->phaselist[total].override_mrd_on_plan_ind = temp->planlist[i].
      override_mrd_on_plan_ind
      SET temp2->phaselist[total].pathway_id = temp->planlist[i].phaselist[j].pathway_id
      SET temp2->phaselist[total].description = temp->planlist[i].phaselist[j].description
      SET temp2->phaselist[total].pw_status_cd = temp->planlist[i].phaselist[j].pw_status_cd
      SET temp2->phaselist[total].encntr_id = temp->planlist[i].phaselist[j].encntr_id
      SET temp2->phaselist[total].type_mean = temp->planlist[i].phaselist[j].type_mean
      SET temp2->phaselist[total].duration_qty = temp->planlist[i].phaselist[j].duration_qty
      SET temp2->phaselist[total].duration_unit_cd = temp->planlist[i].phaselist[j].duration_unit_cd
      SET temp2->phaselist[total].started_ind = temp->planlist[i].phaselist[j].started_ind
      SET temp2->phaselist[total].updt_cnt = temp->planlist[i].phaselist[j].updt_cnt
      SET temp2->phaselist[total].start_dt_tm = temp->planlist[i].phaselist[j].start_dt_tm
      SET temp2->phaselist[total].calc_end_dt_tm = temp->planlist[i].phaselist[j].calc_end_dt_tm
      SET temp2->phaselist[total].order_dt_tm = temp->planlist[i].phaselist[j].order_dt_tm
      SET temp2->phaselist[total].pathway_catalog_id = temp->planlist[i].phaselist[j].
      pathway_catalog_id
      SET temp2->phaselist[total].last_updt_dt_tm = temp->planlist[i].phaselist[j].last_updt_dt_tm
      SET temp2->phaselist[total].last_updt_prsnl_id = temp->planlist[i].phaselist[j].
      last_updt_prsnl_id
      SET temp2->phaselist[total].display_method_cd = temp->planlist[i].phaselist[j].
      display_method_cd
      SET temp2->phaselist[total].parent_phase_desc = temp->planlist[i].phaselist[j].
      parent_phase_desc
      SET temp2->phaselist[total].start_tz = temp->planlist[i].phaselist[j].start_tz
      SET temp2->phaselist[total].calc_end_tz = temp->planlist[i].phaselist[j].calc_end_tz
      SET temp2->phaselist[total].order_tz = temp->planlist[i].phaselist[j].order_tz
      SET temp2->phaselist[total].last_updt_tz = temp->planlist[i].phaselist[j].last_updt_tz
      SET temp2->phaselist[total].ref_owner_person_id = temp->planlist[i].ref_owner_person_id
      SET temp2->phaselist[total].alerts_on_plan_ind = temp->planlist[i].phaselist[j].
      alerts_on_plan_ind
      SET temp2->phaselist[total].alerts_on_plan_upd_ind = temp->planlist[i].phaselist[j].
      alerts_on_plan_upd_ind
      SET temp2->phaselist[total].cycle_label_cd = temp->planlist[i].cycle_label_cd
      SET temp2->phaselist[total].start_estimated_ind = temp->planlist[i].phaselist[j].
      start_estimated_ind
      SET temp2->phaselist[total].calc_end_estimated_ind = temp->planlist[i].phaselist[j].
      calc_end_estimated_ind
      SET temp2->phaselist[total].cycle_end_nbr = temp->planlist[i].cycle_end_nbr
      SET temp2->phaselist[total].scheduled_facility_cd = temp->planlist[i].phaselist[j].
      scheduled_facility_cd
      SET temp2->phaselist[total].scheduled_nursing_unit_cd = temp->planlist[i].phaselist[j].
      scheduled_nursing_unit_cd
      SET temp2->phaselist[total].synonym_name = temp->planlist[i].synonym_name
      SET temp2->phaselist[total].period_nbr = temp->planlist[i].phaselist[j].period_nbr
      SET temp2->phaselist[total].period_custom_label = temp->planlist[i].phaselist[j].
      period_custom_label
      SET temp2->phaselist[total].review_status_flag = temp->planlist[i].phaselist[j].
      review_status_flag
      SET temp2->phaselist[total].pathway_group_id = temp->planlist[i].phaselist[j].pathway_group_id
      SET temp2->phaselist[total].processing_status_flag = n_processing_status_not_processing
      SET temp2->phaselist[total].pathway_customized_plan_id = temp->planlist[i].
      pathway_customized_plan_id
      SET temp2->phaselist[total].reference_plan_name = temp->planlist[i].reference_plan_name
      SET temp2->phaselist[total].warning_level_bit = temp->planlist[i].phaselist[j].
      warning_level_bit
      SET temp2->phaselist[total].copy_source_pathway_id = temp->planlist[i].phaselist[j].
      copy_source_pathway_id
      SET temp2->phaselist[total].review_required_sig_count = temp->planlist[i].phaselist[j].
      review_required_sig_count
      SET temp2->phaselist[total].linked_phase_ind = temp->planlist[i].phaselist[j].linked_phase_ind
      IF ((temp->planlist[i].facility_access_ind=1))
       SET temp2->phaselist[total].facility_access_ind = 1
      ENDIF
      IF ((temp2->phaselist[total].type_mean="SUBPHASE"))
       CALL additemtolist(query_act_pw_comp,total,0,temp2->phaselist[total].pathway_id)
      ENDIF
      IF ((temp2->phaselist[total].pathway_id > 0.0))
       SET query_phase_action->count += 1
       IF ((query_phase_action->size < query_phase_action->count))
        SET query_phase_action->size += query_phase_action->batch_size
        SET query_phase_action->loop_count += 1
        SET stat = alterlist(query_phase_action->phases,query_phase_action->size)
       ENDIF
       SET query_phase_action->phases[query_phase_action->count].pathway_id = temp2->phaselist[total]
       .pathway_id
       SET query_phase_action->phases[query_phase_action->count].phase_idx = total
       IF ((temp2->phaselist[total].type_mean="DOT"))
        SET query_parent_phases->count += 1
        IF ((query_parent_phases->size < query_parent_phases->count))
         SET query_parent_phases->size += query_parent_phases->batch_size
         SET query_parent_phases->loop_count += 1
         SET stat = alterlist(query_parent_phases->phases,query_parent_phases->size)
        ENDIF
        SET query_parent_phases->phases[query_parent_phases->count].pathway_id = temp2->phaselist[
        total].pathway_id
        SET query_parent_phases->phases[query_parent_phases->count].phase_idx = total
       ENDIF
       IF ((temp2->phaselist[total].review_status_flag IN (review_status_planning,
       review_status_pending, review_status_rejected)))
        SET query_pathway_notification->count += 1
        IF ((query_pathway_notification->size < query_pathway_notification->count))
         SET query_pathway_notification->size += query_pathway_notification->batch_size
         SET query_pathway_notification->loop_count += 1
         SET stat = alterlist(query_pathway_notification->phases,query_pathway_notification->size)
        ENDIF
        SET query_pathway_notification->phases[query_pathway_notification->count].pathway_id = temp2
        ->phaselist[total].pathway_id
        SET query_pathway_notification->phases[query_pathway_notification->count].phase_idx = total
       ENDIF
      ENDIF
    ENDFOR
   ELSEIF ((temp->planlist[i].status_ind=1)
    AND isplanphaseinitiateavailable(i)="Y")
    FOR (j = 1 TO phasecnt)
      SET total += 1
      SET stat = alterlist(temp2->phaselist,total)
      SET phase_pathway_catalog_idx = getpathwaycatalogquerylistindex(temp->planlist[i].phaselist[j].
       pathway_catalog_id)
      SET temp2->phaselist[total].plan_pathway_catalog_idx = plan_pathway_catalog_idx
      SET temp2->phaselist[total].phase_pathway_catalog_idx = phase_pathway_catalog_idx
      SET temp2->phaselist[total].pw_group_nbr = temp->planlist[i].pw_group_nbr
      SET temp2->phaselist[total].pw_group_desc = temp->planlist[i].pw_group_desc
      SET temp2->phaselist[total].group_type_mean = temp->planlist[i].type_mean
      SET temp2->phaselist[total].cross_encntr_ind = temp->planlist[i].cross_encntr_ind
      SET temp2->phaselist[total].version = temp->planlist[i].version
      SET temp2->phaselist[total].newest_version = temp->planlist[i].newest_version
      SET temp2->phaselist[total].newest_version_active_ind = temp->planlist[i].
      newest_version_active_ind
      SET temp2->phaselist[total].newest_version_pw_cat_id = temp->planlist[i].
      newest_version_pw_cat_id
      SET temp2->phaselist[total].pathway_type_cd = temp->planlist[i].pathway_type_cd
      SET temp2->phaselist[total].pathway_class_cd = temp->planlist[i].pathway_class_cd
      SET temp2->phaselist[total].pw_cat_group_id = temp->planlist[i].pathway_catalog_id
      SET temp2->phaselist[total].cycle_nbr = temp->planlist[i].cycle_nbr
      SET temp2->phaselist[total].default_view_mean = temp->planlist[i].default_view_mean
      SET temp2->phaselist[total].diagnosis_capture_ind = temp->planlist[i].diagnosis_capture_ind
      SET temp2->phaselist[total].allow_copy_forward_ind = temp->planlist[i].allow_copy_forward_ind
      SET temp2->phaselist[total].pathway_id = temp->planlist[i].phaselist[j].pathway_id
      SET temp2->phaselist[total].description = temp->planlist[i].phaselist[j].description
      SET temp2->phaselist[total].pw_status_cd = temp->planlist[i].phaselist[j].pw_status_cd
      SET temp2->phaselist[total].encntr_id = temp->planlist[i].phaselist[j].encntr_id
      SET temp2->phaselist[total].type_mean = temp->planlist[i].phaselist[j].type_mean
      SET temp2->phaselist[total].duration_qty = temp->planlist[i].phaselist[j].duration_qty
      SET temp2->phaselist[total].duration_unit_cd = temp->planlist[i].phaselist[j].duration_unit_cd
      SET temp2->phaselist[total].started_ind = temp->planlist[i].phaselist[j].started_ind
      SET temp2->phaselist[total].updt_cnt = temp->planlist[i].phaselist[j].updt_cnt
      SET temp2->phaselist[total].start_dt_tm = temp->planlist[i].phaselist[j].start_dt_tm
      SET temp2->phaselist[total].calc_end_dt_tm = temp->planlist[i].phaselist[j].calc_end_dt_tm
      SET temp2->phaselist[total].order_dt_tm = temp->planlist[i].phaselist[j].order_dt_tm
      SET temp2->phaselist[total].pathway_catalog_id = temp->planlist[i].phaselist[j].
      pathway_catalog_id
      SET temp2->phaselist[total].last_updt_dt_tm = temp->planlist[i].phaselist[j].last_updt_dt_tm
      SET temp2->phaselist[total].last_updt_prsnl_id = temp->planlist[i].phaselist[j].
      last_updt_prsnl_id
      SET temp2->phaselist[total].display_method_cd = temp->planlist[i].phaselist[j].
      display_method_cd
      SET temp2->phaselist[total].parent_phase_desc = temp->planlist[i].phaselist[j].
      parent_phase_desc
      SET temp2->phaselist[total].start_tz = temp->planlist[i].phaselist[j].start_tz
      SET temp2->phaselist[total].calc_end_tz = temp->planlist[i].phaselist[j].calc_end_tz
      SET temp2->phaselist[total].order_tz = temp->planlist[i].phaselist[j].order_tz
      SET temp2->phaselist[total].last_updt_tz = temp->planlist[i].phaselist[j].last_updt_tz
      SET temp2->phaselist[total].ref_owner_person_id = temp->planlist[i].ref_owner_person_id
      SET temp2->phaselist[total].alerts_on_plan_ind = temp->planlist[i].phaselist[j].
      alerts_on_plan_ind
      SET temp2->phaselist[total].alerts_on_plan_upd_ind = temp->planlist[i].phaselist[j].
      alerts_on_plan_upd_ind
      SET temp2->phaselist[total].cycle_label_cd = temp->planlist[i].cycle_label_cd
      SET temp2->phaselist[total].start_estimated_ind = temp->planlist[i].phaselist[j].
      start_estimated_ind
      SET temp2->phaselist[total].calc_end_estimated_ind = temp->planlist[i].phaselist[j].
      calc_end_estimated_ind
      SET temp2->phaselist[total].cycle_end_nbr = temp->planlist[i].cycle_end_nbr
      SET temp2->phaselist[total].scheduled_facility_cd = temp->planlist[i].phaselist[j].
      scheduled_facility_cd
      SET temp2->phaselist[total].scheduled_nursing_unit_cd = temp->planlist[i].phaselist[j].
      scheduled_nursing_unit_cd
      SET temp2->phaselist[total].synonym_name = temp->planlist[i].synonym_name
      SET temp2->phaselist[total].period_nbr = temp->planlist[i].phaselist[j].period_nbr
      SET temp2->phaselist[total].period_custom_label = temp->planlist[i].phaselist[j].
      period_custom_label
      SET temp2->phaselist[total].review_status_flag = temp->planlist[i].phaselist[j].
      review_status_flag
      SET temp2->phaselist[total].pathway_group_id = temp->planlist[i].phaselist[j].pathway_group_id
      SET temp2->phaselist[total].processing_status_flag = n_processing_status_not_processing
      SET temp2->phaselist[total].pathway_customized_plan_id = temp->planlist[i].
      pathway_customized_plan_id
      SET temp2->phaselist[total].reference_plan_name = temp->planlist[i].reference_plan_name
      SET temp2->phaselist[total].warning_level_bit = temp->planlist[i].phaselist[j].
      warning_level_bit
      SET temp2->phaselist[total].copy_source_pathway_id = temp->planlist[i].phaselist[j].
      copy_source_pathway_id
      SET temp2->phaselist[total].review_required_sig_count = temp->planlist[i].phaselist[j].
      review_required_sig_count
      SET temp2->phaselist[total].restricted_actions_bitmask = temp->planlist[i].
      restricted_actions_bitmask
      SET temp2->phaselist[total].override_mrd_on_plan_ind = temp->planlist[i].
      override_mrd_on_plan_ind
      SET temp2->phaselist[total].linked_phase_ind = temp->planlist[i].phaselist[j].linked_phase_ind
      IF ((temp->planlist[i].facility_access_ind=1))
       SET temp2->phaselist[total].facility_access_ind = 1
      ENDIF
      IF ((temp2->phaselist[total].type_mean="SUBPHASE"))
       CALL additemtolist(query_act_pw_comp,total,0,temp2->phaselist[total].pathway_id)
      ENDIF
      IF ((temp2->phaselist[total].pathway_id > 0.0))
       SET query_phase_action->count += 1
       IF ((query_phase_action->size < query_phase_action->count))
        SET query_phase_action->size += query_phase_action->batch_size
        SET query_phase_action->loop_count += 1
        SET stat = alterlist(query_phase_action->phases,query_phase_action->size)
       ENDIF
       SET query_phase_action->phases[query_phase_action->count].pathway_id = temp2->phaselist[total]
       .pathway_id
       SET query_phase_action->phases[query_phase_action->count].phase_idx = total
       IF ((temp2->phaselist[total].type_mean="DOT"))
        SET query_parent_phases->count += 1
        IF ((query_parent_phases->size < query_parent_phases->count))
         SET query_parent_phases->size += query_parent_phases->batch_size
         SET query_parent_phases->loop_count += 1
         SET stat = alterlist(query_parent_phases->phases,query_parent_phases->size)
        ENDIF
        SET query_parent_phases->phases[query_parent_phases->count].pathway_id = temp2->phaselist[
        total].pathway_id
        SET query_parent_phases->phases[query_parent_phases->count].phase_idx = total
       ENDIF
       IF ((temp2->phaselist[total].review_status_flag IN (review_status_planning,
       review_status_pending, review_status_rejected)))
        SET query_pathway_notification->count += 1
        IF ((query_pathway_notification->size < query_pathway_notification->count))
         SET query_pathway_notification->size += query_pathway_notification->batch_size
         SET query_pathway_notification->loop_count += 1
         SET stat = alterlist(query_pathway_notification->phases,query_pathway_notification->size)
        ENDIF
        SET query_pathway_notification->phases[query_pathway_notification->count].pathway_id = temp2
        ->phaselist[total].pathway_id
        SET query_pathway_notification->phases[query_pathway_notification->count].phase_idx = total
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 FOR (i = (query_parent_phases->count+ 1) TO query_parent_phases->size)
   SET query_parent_phases->phases[i].pathway_id = query_parent_phases->phases[query_parent_phases->
   count].pathway_id
 ENDFOR
 IF ((query_parent_phases->loop_count > 0))
  SET lstart = 1
  SELECT INTO "nl:"
   pw.pw_cat_group_id, pw.pathway_catalog_id, pw.pw_group_nbr,
   pw.pathway_id, pr.pathway_t_id
   FROM (dummyt d1  WITH seq = value(query_parent_phases->loop_count)),
    pathway_reltn pr,
    pathway pw
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ query_parent_phases->batch_size))))
    JOIN (pr
    WHERE expand(idx,lstart,(lstart+ (query_parent_phases->batch_size - 1)),pr.pathway_t_id,
     query_parent_phases->phases[idx].pathway_id)
     AND pr.type_mean="GROUP")
    JOIN (pw
    WHERE pw.pathway_id=pr.pathway_s_id
     AND (pw.person_id=request->person_id))
   ORDER BY pw.pw_cat_group_id, pw.pathway_catalog_id, pw.pw_group_nbr,
    pw.pathway_id, pr.pathway_t_id
   HEAD REPORT
    ltemp2index = 0, lactionindex = 0, lchildphaseindex = 0,
    ltemp2count = size(temp2->phaselist,5), ltemp2size = ltemp2count
   HEAD pw.pw_cat_group_id
    plan_pathway_catalog_idx = getpathwaycatalogquerylistindex(pw.pw_cat_group_id)
   HEAD pw.pathway_catalog_id
    phase_pathway_catalog_idx = getpathwaycatalogquerylistindex(pw.pathway_catalog_id)
   HEAD pw.pathway_id
    ltemp2index = 0, lactionindex = 0, idx = locateval(idx,1,query_parent_phases->count,pr
     .pathway_t_id,query_parent_phases->phases[idx].pathway_id)
    IF (idx > 0)
     lchildphaseindex = query_parent_phases->phases[idx].phase_idx, lactionindex = locateval(idx,1,
      query_phase_action->count,pw.pathway_id,query_phase_action->phases[idx].pathway_id)
     IF (lactionindex > 0)
      ltemp2index = query_phase_action->phases[lactionindex].phase_idx
     ENDIF
     IF (ltemp2index < 1)
      ltemp2count += 1
      IF (ltemp2count > ltemp2size)
       ltemp2size += 20, stat = alterlist(temp2->phaselist,ltemp2size)
      ENDIF
      ltemp2index = ltemp2count, temp2->phaselist[ltemp2index].plan_pathway_catalog_idx =
      plan_pathway_catalog_idx, temp2->phaselist[ltemp2index].phase_pathway_catalog_idx =
      phase_pathway_catalog_idx,
      temp2->phaselist[ltemp2index].pw_group_nbr = pw.pw_group_nbr, temp2->phaselist[ltemp2index].
      pw_group_desc = trim(pw.pw_group_desc), temp2->phaselist[ltemp2index].cross_encntr_ind = pw
      .cross_encntr_ind,
      temp2->phaselist[ltemp2index].version = temp2->phaselist[lchildphaseindex].version, temp2->
      phaselist[ltemp2index].newest_version = temp2->phaselist[lchildphaseindex].newest_version,
      temp2->phaselist[ltemp2index].newest_version_active_ind = temp2->phaselist[lchildphaseindex].
      newest_version_active_ind,
      temp2->phaselist[ltemp2index].newest_version_pw_cat_id = temp2->phaselist[lchildphaseindex].
      newest_version_pw_cat_id, temp2->phaselist[ltemp2index].pathway_type_cd = pw.pathway_type_cd,
      temp2->phaselist[ltemp2index].pathway_class_cd = pw.pathway_class_cd,
      temp2->phaselist[ltemp2index].pw_cat_group_id = pw.pw_cat_group_id, temp2->phaselist[
      ltemp2index].cycle_nbr = pw.cycle_nbr, temp2->phaselist[ltemp2index].default_view_mean = trim(
       pw.default_view_mean),
      temp2->phaselist[ltemp2index].diagnosis_capture_ind = pw.diagnosis_capture_ind, temp2->
      phaselist[ltemp2index].allow_copy_forward_ind = temp2->phaselist[lchildphaseindex].
      allow_copy_forward_ind, temp2->phaselist[ltemp2index].pathway_id = pw.pathway_id,
      temp2->phaselist[ltemp2index].description = trim(pw.description), temp2->phaselist[ltemp2index]
      .pw_status_cd = pw.pw_status_cd, temp2->phaselist[ltemp2index].encntr_id = pw.encntr_id,
      temp2->phaselist[ltemp2index].type_mean = trim(pw.type_mean), temp2->phaselist[ltemp2index].
      duration_qty = pw.duration_qty, temp2->phaselist[ltemp2index].duration_unit_cd = pw
      .duration_unit_cd,
      temp2->phaselist[ltemp2index].started_ind = pw.started_ind, temp2->phaselist[ltemp2index].
      updt_cnt = pw.updt_cnt, temp2->phaselist[ltemp2index].start_dt_tm = pw.start_dt_tm,
      temp2->phaselist[ltemp2index].calc_end_dt_tm = pw.calc_end_dt_tm, temp2->phaselist[ltemp2index]
      .order_dt_tm = pw.order_dt_tm, temp2->phaselist[ltemp2index].pathway_catalog_id = pw
      .pathway_catalog_id,
      temp2->phaselist[ltemp2index].display_method_cd = pw.display_method_cd, temp2->phaselist[
      ltemp2index].parent_phase_desc = trim(pw.parent_phase_desc), temp2->phaselist[ltemp2index].
      start_tz = pw.start_tz,
      temp2->phaselist[ltemp2index].calc_end_tz = pw.calc_end_tz, temp2->phaselist[ltemp2index].
      order_tz = pw.order_tz, temp2->phaselist[ltemp2index].ref_owner_person_id = pw
      .ref_owner_person_id,
      temp2->phaselist[ltemp2index].alerts_on_plan_ind = pw.alerts_on_plan_ind, temp2->phaselist[
      ltemp2index].alerts_on_plan_upd_ind = pw.alerts_on_plan_upd_ind, temp2->phaselist[ltemp2index].
      cycle_label_cd = pw.cycle_label_cd,
      temp2->phaselist[ltemp2index].start_estimated_ind = pw.start_estimated_ind, temp2->phaselist[
      ltemp2index].calc_end_estimated_ind = pw.calc_end_estimated_ind, temp2->phaselist[ltemp2index].
      cycle_end_nbr = pw.cycle_end_nbr,
      temp2->phaselist[ltemp2index].scheduled_facility_cd = pw.future_location_facility_cd, temp2->
      phaselist[ltemp2index].scheduled_nursing_unit_cd = pw.future_location_nurse_unit_cd, temp2->
      phaselist[ltemp2index].synonym_name = trim(pw.synonym_name),
      temp2->phaselist[ltemp2index].period_nbr = pw.period_nbr, temp2->phaselist[ltemp2index].
      period_custom_label = trim(pw.period_custom_label), temp2->phaselist[ltemp2index].
      review_status_flag = pw.review_status_flag,
      temp2->phaselist[ltemp2index].pathway_group_id = pw.pathway_group_id, temp2->phaselist[
      ltemp2index].processing_status_flag = n_processing_status_not_processing, temp2->phaselist[
      ltemp2index].pathway_customized_plan_id = pw.pathway_customized_plan_id,
      temp2->phaselist[ltemp2index].warning_level_bit = pw.warning_level_bit, temp2->phaselist[
      ltemp2index].copy_source_pathway_id = pw.copy_source_pathway_id, temp2->phaselist[ltemp2index].
      review_required_sig_count = pw.review_required_sig_count,
      temp2->phaselist[ltemp2index].linked_phase_ind = pw.linked_phase_ind, temp2->phaselist[
      ltemp2index].facility_access_ind = temp2->phaselist[lchildphaseindex].facility_access_ind,
      query_phase_action->count += 1
      IF ((query_phase_action->size < query_phase_action->count))
       query_phase_action->size += query_phase_action->batch_size, query_phase_action->loop_count +=
       1, stat = alterlist(query_phase_action->phases,query_phase_action->size)
      ENDIF
      query_phase_action->phases[query_phase_action->count].pathway_id = pw.pathway_id,
      query_phase_action->phases[query_phase_action->count].phase_idx = ltemp2index
      IF (pw.review_status_flag IN (review_status_planning, review_status_pending,
      review_status_rejected))
       query_pathway_notification->count += 1
       IF ((query_pathway_notification->size < query_pathway_notification->count))
        query_pathway_notification->size += query_pathway_notification->batch_size,
        query_pathway_notification->loop_count += 1, stat = alterlist(query_pathway_notification->
         phases,query_pathway_notification->size)
       ENDIF
       query_pathway_notification->phases[query_pathway_notification->count].pathway_id = temp2->
       phaselist[ltemp2index].pathway_id, query_pathway_notification->phases[
       query_pathway_notification->count].phase_idx = ltemp2index
      ENDIF
     ENDIF
     temp2->phaselist[ltemp2index].qualified_grouped_phase_count = 0, temp2->phaselist[ltemp2index].
     hide_grouped_phases_ind = 0
    ENDIF
   HEAD pr.pathway_t_id
    IF (ltemp2index > 0)
     temp2->phaselist[ltemp2index].qualified_grouped_phase_count += 1, idx = locateval(idx,1,
      query_parent_phases->count,pr.pathway_t_id,query_parent_phases->phases[idx].pathway_id)
     IF (idx > 0)
      lchildphaseindex = query_parent_phases->phases[idx].phase_idx
      IF (lchildphaseindex > 0)
       temp2->phaselist[lchildphaseindex].pw_group_nbr = pw.pw_group_nbr, temp2->phaselist[
       lchildphaseindex].pw_group_desc = trim(pw.pw_group_desc), temp2->phaselist[lchildphaseindex].
       cross_encntr_ind = pw.cross_encntr_ind,
       temp2->phaselist[lchildphaseindex].pathway_type_cd = pw.pathway_type_cd, temp2->phaselist[
       lchildphaseindex].pathway_class_cd = pw.pathway_class_cd, temp2->phaselist[lchildphaseindex].
       pw_cat_group_id = pw.pw_cat_group_id,
       temp2->phaselist[lchildphaseindex].cycle_nbr = pw.cycle_nbr, temp2->phaselist[lchildphaseindex
       ].default_view_mean = trim(pw.default_view_mean), temp2->phaselist[lchildphaseindex].
       diagnosis_capture_ind = pw.diagnosis_capture_ind,
       temp2->phaselist[lchildphaseindex].ref_owner_person_id = pw.ref_owner_person_id, temp2->
       phaselist[lchildphaseindex].cycle_label_cd = pw.cycle_label_cd, temp2->phaselist[
       lchildphaseindex].cycle_end_nbr = pw.cycle_end_nbr,
       temp2->phaselist[lchildphaseindex].synonym_name = trim(pw.synonym_name), temp2->phaselist[
       lchildphaseindex].group_parent_temp2_idx = ltemp2index
      ENDIF
     ENDIF
    ENDIF
   FOOT REPORT
    IF (ltemp2count > 0
     AND ltemp2count < ltemp2size)
     stat = alterlist(temp2->phaselist,ltemp2count)
    ENDIF
   WITH nocounter, expand = 2, orahintcbo("Query to fetch all the details of the phases ")
  ;end select
 ENDIF
 FOR (idx = (query_pathway_catalog->count+ 1) TO query_pathway_catalog->size)
   SET query_pathway_catalog->list[idx].pathway_catalog_id = query_pathway_catalog->list[
   query_pathway_catalog->count].pathway_catalog_id
 ENDFOR
 FOR (i = (query_phase_action->count+ 1) TO query_phase_action->size)
   SET query_phase_action->phases[i].pathway_id = query_phase_action->phases[query_phase_action->
   count].pathway_id
 ENDFOR
 FOR (i = (query_pathway_notification->count+ 1) TO query_pathway_notification->size)
   SET query_pathway_notification->phases[i].pathway_id = query_pathway_notification->phases[
   query_pathway_notification->count].pathway_id
 ENDFOR
 FREE RECORD temp
 IF (load_tapers_only_ind=0)
  IF ((query->query_list[query_act_pw_comp].value_count > 0))
   SET lstart = 1
   SET lcount = query->query_list[query_act_pw_comp].value_count
   SET lsize = query->query_list[query_act_pw_comp].value_size
   SET lloopcount = query->query_list[query_act_pw_comp].value_loops
   SET lbatchsize = batch_size_default
   FOR (idx = lcount TO lsize)
     SET query->query_list[query_act_pw_comp].value_list[idx].value = query->query_list[
     query_act_pw_comp].value_list[lcount].value
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(lloopcount)),
     act_pw_comp apc
    PLAN (d1
     WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
     JOIN (apc
     WHERE expand(idx,lstart,(lstart+ (lbatchsize - 1)),apc.parent_entity_id,query->query_list[
      query_act_pw_comp].value_list[idx].value)
      AND apc.parent_entity_name="PATHWAY")
    DETAIL
     idx = locateval(idx,1,lcount,apc.parent_entity_id,query->query_list[query_act_pw_comp].
      value_list[idx].value)
     IF (idx > 0)
      idx = query->query_list[query_act_pw_comp].value_list[idx].idx
      IF (idx > 0)
       temp2->phaselist[idx].sequence = apc.sequence, temp2->phaselist[idx].included_ind = apc
       .included_ind
      ENDIF
     ENDIF
    WITH nocounter, expand = 2, orahintcbo("Query to fetch subphase components")
   ;end select
  ENDIF
 ENDIF
 SET high = value(size(temp2->phaselist,5))
 FREE RECORD processing
 RECORD processing(
   1 phases_idx = i4
   1 phases_count = i4
   1 phases_loop_count = i4
   1 phases[*]
     2 pathway_id = f8
     2 pw_group_nbr = f8
     2 pathway_catalog_id = f8
     2 processing_update_count = i4
     2 encounter_id = f8
     2 person_id = f8
     2 processing_status_flag = i2
     2 processing_expired_date_time = dq8
 )
 SELECT INTO "nl:"
  pw.pathway_id
  FROM pw_processing_action ppa,
   pathway pw
  PLAN (ppa
   WHERE ppa.person_id=person_id)
   JOIN (pw
   WHERE (pw.pathway_id= Outerjoin(ppa.pathway_id)) )
  ORDER BY ppa.pathway_id
  HEAD REPORT
   idx = 0, nprocessingstatusflag = n_processing_status_unknown, lupdatecount = 0,
   processingcount = 0, processingindex = 0
  HEAD ppa.pathway_id
   IF (pw.pathway_id > 0.0)
    lupdatecount = pw.updt_cnt
   ELSE
    lupdatecount = - (1)
   ENDIF
   nprocessingstatusflag = getpwprocessingstatus(lupdatecount,ppa.processing_updt_cnt,cnvtdatetime(
     ppa.processing_start_dt_tm),l_stale_in_min), idx = 0
   IF (high > 0
    AND pw.pathway_id > 0.0)
    idx = locateval(idx,1,high,pw.pathway_id,temp2->phaselist[idx].pathway_id)
   ENDIF
   IF (idx > 0)
    temp2->phaselist[idx].processing_status_flag = nprocessingstatusflag
    IF (nprocessingstatusflag IN (n_processing_status_processing,
    n_processing_status_failed_in_processing))
     temp2->phaselist[idx].processing_ind = 1, temp2->phaselist[idx].processing_expired_date_time =
     cnvtlookahead(build('"',l_stale_in_min,',MIN"'),cnvtdatetime(ppa.processing_start_dt_tm))
    ENDIF
   ELSEIF (pw.pathway_id <= 0.0)
    processingindex += 1
    IF (processingcount < processingindex)
     processingcount += 20, processing->phases_loop_count += 1, stat = alterlist(processing->phases,
      processingcount)
    ENDIF
    processing->phases[processingindex].pathway_id = ppa.pathway_id, processing->phases[
    processingindex].pw_group_nbr = ppa.pw_group_nbr, processing->phases[processingindex].
    pathway_catalog_id = ppa.pathway_catalog_id,
    processing->phases[processingindex].processing_update_count = ppa.processing_updt_cnt, processing
    ->phases[processingindex].encounter_id = ppa.encntr_id, processing->phases[processingindex].
    person_id = ppa.person_id,
    processing->phases[processingindex].processing_status_flag = nprocessingstatusflag, processing->
    phases[processingindex].processing_expired_date_time = cnvtlookahead(build('"',l_stale_in_min,
      ',MIN"'),cnvtdatetime(ppa.processing_start_dt_tm))
   ENDIF
  FOOT REPORT
   IF (processingindex > 0)
    processing->phases_idx = processingindex, processing->phases_count = processingcount
    FOR (idx = (processingindex+ 1) TO processingcount)
      processing->phases[idx].pathway_id = processing->phases[processingindex].pathway_id, processing
      ->phases[idx].pw_group_nbr = processing->phases[processingindex].pw_group_nbr, processing->
      phases[idx].pathway_catalog_id = processing->phases[processingindex].pathway_catalog_id,
      processing->phases[idx].processing_update_count = processing->phases[processingindex].
      processing_update_count, processing->phases[idx].encounter_id = processing->phases[
      processingindex].encounter_id, processing->phases[idx].person_id = processing->phases[
      processingindex].person_id,
      processing->phases[idx].processing_status_flag = processing->phases[processingindex].
      processing_status_flag, processing->phases[idx].processing_expired_date_time = processing->
      phases[processingindex].processing_expired_date_time
    ENDFOR
   ENDIF
  WITH nocounter, orahintcbo("Query to check for phases in processing status")
 ;end select
 IF ((processing->phases_loop_count > 0))
  DECLARE pathwaytypecd = f8 WITH protect, noconstant(0.0)
  DECLARE processingindex = i4 WITH protect, noconstant(0)
  DECLARE processingnextindex = i4 WITH protect, noconstant(0)
  DECLARE temp2planindex = i4 WITH protect, noconstant(0)
  DECLARE temp2index = i4 WITH protect, noconstant(0)
  DECLARE temp2count = i4 WITH protect, noconstant(0)
  SET lstart = 1
  SELECT INTO "nl:"
   pwc.pathway_catalog_id
   FROM (dummyt d1  WITH seq = value(processing->phases_loop_count)),
    pathway_catalog pwc,
    pw_cat_reltn pwcr,
    pathway_catalog pwc2
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ 20))))
    JOIN (pwc
    WHERE expand(idx,lstart,(lstart+ 19),pwc.pathway_catalog_id,processing->phases[idx].
     pathway_catalog_id)
     AND pwc.type_mean IN ("CAREPLAN", "PHASE"))
    JOIN (pwcr
    WHERE (pwcr.pw_cat_t_id= Outerjoin(pwc.pathway_catalog_id))
     AND (pwcr.type_mean= Outerjoin("GROUP")) )
    JOIN (pwc2
    WHERE (pwc2.pathway_catalog_id= Outerjoin(pwcr.pw_cat_s_id)) )
   ORDER BY pwc2.pathway_catalog_id, pwc.pathway_catalog_id
   HEAD REPORT
    ballowplan = 1, processingcount = processing->phases_idx, temp2index = size(temp2->phaselist,5),
    temp2count = temp2index
   HEAD pwc2.pathway_catalog_id
    ballowplan = 1
   HEAD pwc.pathway_catalog_id
    ballowplan = 1, pathwaytypecd = 0.0, processingindex = 0,
    processingnextindex = 0, temp2planindex = 0
    IF (pwc.type_mean="CAREPLAN")
     pathwaytypecd = pwc.pathway_type_cd
    ELSEIF (pwc2.type_mean="PATHWAY")
     pathwaytypecd = pwc2.pathway_type_cd
    ENDIF
    IF (pathwaytypecd != 0.0)
     IF (nexcludecnt > 0)
      IF (0 < locateval(num,1,nexcludecnt,pathwaytypecd,request->plantypeexcludelist[num].
       pathway_type_cd))
       ballowplan = 0
      ENDIF
     ELSEIF (nincludecnt > 0)
      IF (0 >= locateval(num,1,nincludecnt,pathwaytypecd,request->plantypeincludelist[num].
       pathway_type_cd))
       ballowplan = 0
      ENDIF
     ENDIF
    ENDIF
    IF (ballowplan=1)
     processingindex = locateval(processingindex,1,processing->phases_idx,pwc.pathway_catalog_id,
      processing->phases[processingindex].pathway_catalog_id)
     WHILE (processingindex > 0)
       temp2index += 1
       IF (temp2count < temp2index)
        temp2count += 20, stat = alterlist(temp2->phaselist,temp2count)
       ENDIF
       IF (pwc2.type_mean="PATHWAY")
        temp2planindex = locateval(temp2planindex,1,high,processing->phases[processingindex].
         pw_group_nbr,temp2->phaselist[temp2planindex].pw_group_nbr)
       ENDIF
       IF (temp2planindex > 0)
        temp2->phaselist[temp2index].pw_group_nbr = temp2->phaselist[temp2planindex].pw_group_nbr,
        temp2->phaselist[temp2index].group_type_mean = temp2->phaselist[temp2planindex].
        group_type_mean, temp2->phaselist[temp2index].pw_group_desc = temp2->phaselist[temp2planindex
        ].pw_group_desc,
        temp2->phaselist[temp2index].cross_encntr_ind = temp2->phaselist[temp2planindex].
        cross_encntr_ind, temp2->phaselist[temp2index].version = temp2->phaselist[temp2planindex].
        version, temp2->phaselist[temp2index].newest_version = temp2->phaselist[temp2planindex].
        newest_version,
        temp2->phaselist[temp2index].newest_version_active_ind = temp2->phaselist[temp2planindex].
        newest_version_active_ind, temp2->phaselist[temp2index].newest_version_pw_cat_id = temp2->
        phaselist[temp2planindex].newest_version_pw_cat_id, temp2->phaselist[temp2index].
        pw_cat_group_id = temp2->phaselist[temp2planindex].pw_cat_group_id,
        temp2->phaselist[temp2index].pathway_type_cd = temp2->phaselist[temp2planindex].
        pathway_type_cd, temp2->phaselist[temp2index].pathway_class_cd = temp2->phaselist[
        temp2planindex].pathway_class_cd, temp2->phaselist[temp2index].cycle_nbr = temp2->phaselist[
        temp2planindex].cycle_nbr,
        temp2->phaselist[temp2index].default_view_mean = temp2->phaselist[temp2planindex].
        default_view_mean, temp2->phaselist[temp2index].diagnosis_capture_ind = temp2->phaselist[
        temp2planindex].diagnosis_capture_ind, temp2->phaselist[temp2index].allow_copy_forward_ind =
        temp2->phaselist[temp2planindex].allow_copy_forward_ind,
        temp2->phaselist[temp2index].ref_owner_person_id = temp2->phaselist[temp2planindex].
        ref_owner_person_id, temp2->phaselist[temp2index].cycle_label_cd = temp2->phaselist[
        temp2planindex].cycle_label_cd, temp2->phaselist[temp2index].cycle_end_nbr = temp2->
        phaselist[temp2planindex].cycle_end_nbr,
        temp2->phaselist[temp2index].synonym_name = temp2->phaselist[temp2planindex].synonym_name
       ELSE
        temp2->phaselist[temp2index].pw_group_nbr = processing->phases[processingindex].pw_group_nbr
        IF (pwc2.type_mean="PATHWAY")
         temp2->phaselist[temp2index].pw_group_desc = trim(pwc2.display_description), temp2->
         phaselist[temp2index].cross_encntr_ind = pwc2.cross_encntr_ind, temp2->phaselist[temp2index]
         .version = pwc2.version,
         temp2->phaselist[temp2index].pw_cat_group_id = pwc2.pathway_catalog_id, temp2->phaselist[
         temp2index].pathway_type_cd = pwc2.pathway_type_cd
        ELSE
         temp2->phaselist[temp2index].pw_group_desc = trim(pwc.display_description), temp2->
         phaselist[temp2index].cross_encntr_ind = pwc.cross_encntr_ind, temp2->phaselist[temp2index].
         version = pwc.version,
         temp2->phaselist[temp2index].pw_cat_group_id = pwc.pathway_catalog_id, temp2->phaselist[
         temp2index].pathway_type_cd = pwc.pathway_type_cd
        ENDIF
       ENDIF
       temp2->phaselist[temp2index].pathway_id = processing->phases[processingindex].pathway_id,
       temp2->phaselist[temp2index].encntr_id = processing->phases[processingindex].encounter_id,
       temp2->phaselist[temp2index].processing_status_flag = processing->phases[processingindex].
       processing_status_flag,
       temp2->phaselist[temp2index].processing_expired_date_time = processing->phases[processingindex
       ].processing_expired_date_time, temp2->phaselist[temp2index].description = trim(pwc
        .description), temp2->phaselist[temp2index].type_mean = trim(pwc.type_mean),
       temp2->phaselist[temp2index].processing_ind = 1, temp2->phaselist[temp2index].
       pathway_catalog_id = pwc.pathway_catalog_id, temp2->phaselist[temp2index].display_method_cd =
       pwc.display_method_cd,
       processingnextindex = locateval(processingnextindex,(processingindex+ 1),processing->
        phases_idx,pwc.pathway_catalog_id,processing->phases[processingnextindex].pathway_catalog_id),
       processingindex = processingnextindex
     ENDWHILE
    ENDIF
   FOOT  pwc.pathway_catalog_id
    dummy = 0
   FOOT  pwc2.pathway_catalog_id
    dummy = 0
   FOOT REPORT
    IF (temp2index > 0
     AND temp2index < temp2count)
     stat = alterlist(temp2->phaselist,temp2index)
    ENDIF
   WITH nocounter, expand = 2, orahintcbo(
     "Query to fetch phases from pathway_catalog table and add them to the list if they're in processing status"
     )
  ;end select
 ENDIF
 FREE RECORD processing
 IF (size(temp2->phaselist,5) <= 0)
  SET cstatus = "Z"
  GO TO exit_script
 ENDIF
 IF (value(size(temp2->phaselist,5)) > 0)
  CALL querypathwayaction(0)
  CALL querypathwaynotification(0)
  IF ((query_credential->loop_count > 0))
   CALL querycredential(0)
  ENDIF
  IF ((query_prsnl->loop_count > 0))
   CALL querypersonnel(0)
  ENDIF
  CALL querypwcompactreltn(0)
  IF (load_tapers_only_ind=0)
   SET high = value(size(temp2->phaselist,5))
   SELECT INTO "nl:"
    groupflag = evaluate(pr.type_mean,"GROUP",1,0)
    FROM pathway_reltn pr,
     pathway pw
    PLAN (pr
     WHERE expand(num,1,high,pr.pathway_s_id,temp2->phaselist[num].pathway_id)
      AND pr.active_ind=1)
     JOIN (pw
     WHERE pw.pathway_id=pr.pathway_t_id
      AND pw.pw_status_cd != pw_dropped_cd)
    ORDER BY pr.pathway_s_id, groupflag
    HEAD REPORT
     pwrcnt = 0, idx = 0, totalgroupcount = 0
    HEAD pr.pathway_s_id
     pwrcnt = 0, totalgroupcount = 0, idx = locateval(idx,1,high,pr.pathway_s_id,temp2->phaselist[idx
      ].pathway_id),
     movedind = 0
    DETAIL
     pwrcnt += 1
     IF (pwrcnt > size(temp2->phaselist[idx].phasereltnlist,5))
      stat = alterlist(temp2->phaselist[idx].phasereltnlist,(pwrcnt+ 10))
     ENDIF
     IF (pr.type_mean="GROUP"
      AND pw.person_id != person_id)
      movedind = 1
     ENDIF
     temp2->phaselist[idx].phasereltnlist[pwrcnt].pathway_s_id = pr.pathway_s_id, temp2->phaselist[
     idx].phasereltnlist[pwrcnt].pathway_t_id = pr.pathway_t_id, temp2->phaselist[idx].
     phasereltnlist[pwrcnt].type_mean = pr.type_mean,
     temp2->phaselist[idx].phasereltnlist[pwrcnt].offset_qty = pr.offset_qty, temp2->phaselist[idx].
     phasereltnlist[pwrcnt].offset_unit_cd = pr.offset_unit_cd
     IF (pr.type_mean="SUBPHASE")
      temp2->phaselist[idx].sub_phase_ind = 1, idx2 = locateval(idx2,1,high,pr.pathway_t_id,temp2->
       phaselist[idx2].pathway_id)
      IF (idx2 > 0)
       temp2->phaselist[idx].phasereltnlist[pwrcnt].sub_sequence = temp2->phaselist[idx2].sequence,
       l_action_idx_from = temp2->phaselist[idx2].last_upd_action_idx, l_action_idx_to = temp2->
       phaselist[idx].last_upd_action_idx
       IF (l_action_idx_from > 0
        AND l_action_idx_to > 0)
        IF (cnvtdatetimeutc(temp2->phaselist[idx2].actions[l_action_idx_from].action_dt_tm,3,temp2->
         phaselist[idx2].actions[l_action_idx_from].action_tz) > cnvtdatetimeutc(temp2->phaselist[idx
         ].actions[l_action_idx_to].action_dt_tm,3,temp2->phaselist[idx].actions[l_action_idx_to].
         action_tz))
         temp2->phaselist[idx].actions[l_action_idx_to].action_dt_tm = temp2->phaselist[idx2].
         actions[l_action_idx_from].action_dt_tm, temp2->phaselist[idx].actions[l_action_idx_to].
         action_type_cd = temp2->phaselist[idx2].actions[l_action_idx_from].action_type_cd, temp2->
         phaselist[idx].actions[l_action_idx_to].action_tz = temp2->phaselist[idx2].actions[
         l_action_idx_from].action_tz,
         temp2->phaselist[idx].actions[l_action_idx_to].prsnl_idx = temp2->phaselist[idx2].actions[
         l_action_idx_from].prsnl_idx, temp2->phaselist[idx].actions[l_action_idx_to].provider_id =
         temp2->phaselist[idx2].actions[l_action_idx_from].provider_id
        ENDIF
       ENDIF
      ENDIF
     ELSEIF (pr.type_mean="GROUP")
      totalgroupcount += 1
     ENDIF
    FOOT  pr.pathway_s_id
     IF (idx > 0)
      IF (pwrcnt > 0)
       stat = alterlist(temp2->phaselist[idx].phasereltnlist,pwrcnt)
      ENDIF
      IF ((totalgroupcount != temp2->phaselist[idx].qualified_grouped_phase_count))
       temp2->phaselist[idx].hide_grouped_phases_ind = 1, temp2->phaselist[idx].
       qualified_grouped_phase_count = 0
      ENDIF
      idx3 = locateval(idx3,1,size(temp2->phaselist,5),pw.pathway_group_id,temp2->phaselist[idx3].
       pathway_id)
      IF (pw.pathway_group_id > 0
       AND ((idx3 <= 0) OR (movedind > 0)) )
       idx3 = locateval(idx3,1,size(temp2->phaselist,5),pw.pathway_group_id,temp2->phaselist[idx3].
        pathway_group_id)
       IF (movedind > 0
        AND idx3 > 0)
        temp2->phaselist[idx3].pathway_missing_reason_flag = 1
       ELSEIF (idx3 > 0)
        temp2->phaselist[idx3].do_not_load_phase = 1
       ENDIF
       WHILE (idx3 > 0
        AND idx3 < size(temp2->phaselist,5))
        idx3 = locateval(idx3,(idx3+ 1),size(temp2->phaselist,5),pw.pathway_group_id,temp2->
         phaselist[idx3].pathway_group_id),
        IF (movedind > 0
         AND idx3 > 0)
         temp2->phaselist[idx3].pathway_missing_reason_flag = 1
        ELSEIF (idx3 > 0)
         temp2->phaselist[idx3].do_not_load_phase = 1
        ENDIF
       ENDWHILE
      ENDIF
     ENDIF
    FOOT REPORT
     pwrcnt = 0
    WITH nocounter, expand = 2, orahintcbo(
      "Query to fetch details for the phases thats been filtered from previous queries")
   ;end select
   IF ((query_pathway_catalog->loop_count > 0))
    SET lstart = 1
    SELECT INTO "nl:"
     per.pathway_catalog_id, per.type_mean, per.evidence_sequence
     FROM (dummyt d1  WITH seq = value(query_pathway_catalog->loop_count)),
      pw_evidence_reltn per
     PLAN (d1
      WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ query_pathway_catalog->batch_size))))
      JOIN (per
      WHERE expand(idx,lstart,(lstart+ (query_pathway_catalog->batch_size - 1)),per
       .pathway_catalog_id,query_pathway_catalog->list[idx].pathway_catalog_id))
     ORDER BY per.pathway_catalog_id, per.type_mean, per.evidence_sequence
     HEAD REPORT
      evidence_count = 0, evidence_size = 0, evidence_batch_size = 5
     HEAD per.pathway_catalog_id
      evidence_count = 0, evidence_size = 0, idx = locateval(idx,1,query_pathway_catalog->count,per
       .pathway_catalog_id,query_pathway_catalog->list[idx].pathway_catalog_id)
     DETAIL
      IF (idx > 0)
       evidence_count += 1
       IF (evidence_size < evidence_count)
        evidence_size += evidence_batch_size, stat = alterlist(query_pathway_catalog->list[idx].
         evidence_list,evidence_size)
       ENDIF
       query_pathway_catalog->list[idx].evidence_list[evidence_count].dcp_clin_cat_cd = per
       .dcp_clin_cat_cd, query_pathway_catalog->list[idx].evidence_list[evidence_count].
       dcp_clin_sub_cat_cd = per.dcp_clin_sub_cat_cd, query_pathway_catalog->list[idx].evidence_list[
       evidence_count].pathway_comp_id = per.pathway_comp_id,
       query_pathway_catalog->list[idx].evidence_list[evidence_count].evidence_type_mean = per
       .type_mean, query_pathway_catalog->list[idx].evidence_list[evidence_count].
       pw_evidence_reltn_id = per.pw_evidence_reltn_id, query_pathway_catalog->list[idx].
       evidence_list[evidence_count].evidence_locator = trim(per.evidence_locator),
       query_pathway_catalog->list[idx].evidence_list[evidence_count].pathway_catalog_id = per
       .pathway_catalog_id, query_pathway_catalog->list[idx].evidence_list[evidence_count].
       evidence_sequence = per.evidence_sequence
       IF (per.type_mean="REFTEXT")
        query_pathway_catalog->list[idx].ref_text_ind = 1
       ENDIF
      ENDIF
     FOOT  per.pathway_catalog_id
      IF (idx > 0)
       IF (evidence_count > 0
        AND evidence_count < evidence_size)
        stat = alterlist(query_pathway_catalog->list[idx].evidence_list,evidence_count)
       ENDIF
      ENDIF
     WITH nocounter, expand = 2, orahintcbo("Query to retrive plan/phase's evidence links")
    ;end select
   ENDIF
   IF ((query_pathway_catalog->loop_count > 0))
    SET lstart = 1
    SELECT INTO "nl:"
     rtr.parent_entity_name, rtr.parent_entity_id
     FROM (dummyt d1  WITH seq = value(query_pathway_catalog->loop_count)),
      ref_text_reltn rtr
     PLAN (d1
      WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ query_pathway_catalog->batch_size))))
      JOIN (rtr
      WHERE rtr.parent_entity_name="PATHWAY_CATALOG"
       AND expand(idx,lstart,(lstart+ (query_pathway_catalog->batch_size - 1)),rtr.parent_entity_id,
       query_pathway_catalog->list[idx].pathway_catalog_id)
       AND rtr.active_ind=1)
     ORDER BY rtr.parent_entity_name, rtr.parent_entity_id
     HEAD rtr.parent_entity_id
      idx = locateval(idx,1,query_pathway_catalog->count,rtr.parent_entity_id,query_pathway_catalog->
       list[idx].pathway_catalog_id)
      IF (idx > 0)
       query_pathway_catalog->list[idx].ref_text_ind = 1
      ENDIF
     WITH nocounter, expand = 2, orahintcbo("Query to retrive reference text of the plans")
    ;end select
   ENDIF
   IF ((query_pathway_catalog->loop_count > 0))
    SET lstart = 1
    SELECT INTO "nl:"
     pwc.pathway_catalog_id, pwc2.pathway_catalog_id, pwc2.description,
     pwc2.version, pwc2.reschedule_reason_accept_flag, pwc2.disable_activate_all_ind
     FROM (dummyt d1  WITH seq = value(query_pathway_catalog->loop_count)),
      pathway_catalog pwc,
      pathway_catalog pwc2
     PLAN (d1
      WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ query_pathway_catalog->batch_size))))
      JOIN (pwc
      WHERE expand(idx,lstart,(lstart+ (query_pathway_catalog->batch_size - 1)),pwc
       .pathway_catalog_id,query_pathway_catalog->list[idx].pathway_catalog_id)
       AND pwc.type_mean IN ("CAREPLAN"))
      JOIN (pwc2
      WHERE pwc2.pathway_uuid=pwc.pathway_uuid
       AND pwc2.pathway_uuid != null
       AND pwc2.pathway_uuid > " ")
     ORDER BY pwc.pathway_catalog_id, pwc2.version
     HEAD pwc.pathway_catalog_id
      idx = 0, idx = locateval(idx,1,query_pathway_catalog->count,pwc.pathway_catalog_id,
       query_pathway_catalog->list[idx].pathway_catalog_id)
     DETAIL
      IF (idx > 0)
       IF (pwc.pathway_catalog_id=pwc2.pathway_catalog_id)
        query_pathway_catalog->list[idx].future_ind = pwc2.future_ind, query_pathway_catalog->list[
        idx].route_for_review_ind = pwc2.route_for_review_ind, query_pathway_catalog->list[idx].
        reschedule_reason_accept_flag = pwc2.reschedule_reason_accept_flag,
        query_pathway_catalog->list[idx].allow_activate_all_ind = evaluate(pwc2
         .disable_activate_all_ind,1,0,0,1)
       ENDIF
       IF (pwc2.beg_effective_dt_tm < cnvtdatetime(sysdate)
        AND pwc2.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
        AND pwc2.active_ind=1)
        query_pathway_catalog->list[idx].future_ind = pwc2.future_ind, query_pathway_catalog->list[
        idx].route_for_review_ind = pwc2.route_for_review_ind, query_pathway_catalog->list[idx].
        reschedule_reason_accept_flag = pwc2.reschedule_reason_accept_flag,
        query_pathway_catalog->list[idx].allow_activate_all_ind = evaluate(pwc2
         .disable_activate_all_ind,1,0,0,1)
       ENDIF
       IF (pwc2.beg_effective_dt_tm=cnvtdatetime("31-DEC-2100")
        AND pwc2.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
        AND pwc.pathway_catalog_id=pwc2.pathway_catalog_id)
        query_pathway_catalog->list[idx].future_ind = pwc2.future_ind, query_pathway_catalog->list[
        idx].route_for_review_ind = pwc2.route_for_review_ind, query_pathway_catalog->list[idx].
        reschedule_reason_accept_flag = pwc2.reschedule_reason_accept_flag,
        query_pathway_catalog->list[idx].allow_activate_all_ind = evaluate(pwc2
         .disable_activate_all_ind,1,0,0,1)
       ENDIF
      ENDIF
     WITH nocounter, expand = 2, orahintcbo(
       "Query to fetch single plan's plan level attributes base on their versions")
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(query_pathway_catalog->loop_count)),
      pathway_catalog pwc,
      pw_cat_reltn pcr,
      pathway_catalog pwc2,
      pathway_catalog pwc3
     PLAN (d1
      WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ query_pathway_catalog->batch_size))))
      JOIN (pwc
      WHERE expand(idx,lstart,(lstart+ (query_pathway_catalog->batch_size - 1)),pwc
       .pathway_catalog_id,query_pathway_catalog->list[idx].pathway_catalog_id)
       AND pwc.type_mean IN ("PHASE"))
      JOIN (pwc2
      WHERE pwc2.pathway_uuid=pwc.pathway_uuid
       AND pwc2.pathway_uuid != null
       AND pwc2.pathway_uuid > " ")
      JOIN (pcr
      WHERE pcr.pw_cat_t_id=pwc2.pathway_catalog_id
       AND pcr.type_mean="GROUP")
      JOIN (pwc3
      WHERE pwc3.pathway_catalog_id=pcr.pw_cat_s_id)
     ORDER BY pwc.pathway_catalog_id, pwc3.version
     HEAD pwc.pathway_catalog_id
      idx = 0, idx = locateval(idx,1,query_pathway_catalog->count,pwc.pathway_catalog_id,
       query_pathway_catalog->list[idx].pathway_catalog_id)
     DETAIL
      IF (idx > 0)
       IF (pwc.pathway_catalog_id=pwc2.pathway_catalog_id)
        query_pathway_catalog->list[idx].future_ind = pwc2.future_ind, query_pathway_catalog->list[
        idx].route_for_review_ind = pwc2.route_for_review_ind, query_pathway_catalog->list[idx].
        reschedule_reason_accept_flag = pwc2.reschedule_reason_accept_flag,
        query_pathway_catalog->list[idx].allow_activate_all_ind = evaluate(pwc2
         .disable_activate_all_ind,1,0,0,1)
       ENDIF
       IF (pwc3.beg_effective_dt_tm < cnvtdatetime(sysdate)
        AND pwc3.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
        AND pwc3.active_ind=1)
        query_pathway_catalog->list[idx].future_ind = pwc2.future_ind, query_pathway_catalog->list[
        idx].route_for_review_ind = pwc2.route_for_review_ind, query_pathway_catalog->list[idx].
        reschedule_reason_accept_flag = pwc2.reschedule_reason_accept_flag,
        query_pathway_catalog->list[idx].allow_activate_all_ind = evaluate(pwc2
         .disable_activate_all_ind,1,0,0,1)
       ENDIF
       IF (pwc3.beg_effective_dt_tm=cnvtdatetime("31-DEC-2100")
        AND pwc3.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
        AND pwc.pathway_catalog_id=pwc2.pathway_catalog_id
        AND pwc2.active_ind=1)
        query_pathway_catalog->list[idx].future_ind = pwc2.future_ind, query_pathway_catalog->list[
        idx].route_for_review_ind = pwc2.route_for_review_ind, query_pathway_catalog->list[idx].
        reschedule_reason_accept_flag = pwc2.reschedule_reason_accept_flag,
        query_pathway_catalog->list[idx].allow_activate_all_ind = evaluate(pwc2
         .disable_activate_all_ind,1,0,0,1)
       ENDIF
      ENDIF
     WITH nocounter, expand = 2, orahintcbo(
       "Query to fetch multi phase plan's phase level attribute values")
    ;end select
   ENDIF
   IF (loadphasediagnosislinks="Y")
    SELECT INTO "nl:"
     FROM nomen_entity_reltn ner,
      diagnosis d,
      nomenclature n
     PLAN (ner
      WHERE ner.parent_entity_name="PATHWAY"
       AND expand(num,1,high,ner.parent_entity_id,temp2->phaselist[num].pathway_id)
       AND ner.active_ind=1)
      JOIN (d
      WHERE d.diagnosis_id=ner.child_entity_id)
      JOIN (n
      WHERE n.nomenclature_id=d.nomenclature_id)
     ORDER BY ner.parent_entity_id, ner.priority
     HEAD REPORT
      nomcnt = 0, idx = 0
     HEAD ner.parent_entity_id
      nomcnt = 0, idx = locateval(idx,1,high,ner.parent_entity_id,temp2->phaselist[idx].pathway_id)
     DETAIL
      nomcnt += 1
      IF (nomcnt > size(temp2->phaselist[idx].nomenreltnlist,5))
       stat = alterlist(temp2->phaselist[idx].nomenreltnlist,(nomcnt+ 10))
      ENDIF
      temp2->phaselist[idx].nomenreltnlist[nomcnt].nomen_entity_reltn_id = ner.nomen_entity_reltn_id,
      temp2->phaselist[idx].nomenreltnlist[nomcnt].nomenclature_id = ner.nomenclature_id, temp2->
      phaselist[idx].nomenreltnlist[nomcnt].priority = ner.priority,
      temp2->phaselist[idx].nomenreltnlist[nomcnt].diagnosis_id = d.diagnosis_id, temp2->phaselist[
      idx].nomenreltnlist[nomcnt].diag_type_cd = d.diag_type_cd, temp2->phaselist[idx].
      nomenreltnlist[nomcnt].active_ind = d.active_ind,
      temp2->phaselist[idx].nomenreltnlist[nomcnt].diagnosis_group = d.diagnosis_group, temp2->
      phaselist[idx].nomenreltnlist[nomcnt].encntr_id = d.encntr_id
      IF (d.nomenclature_id > 0.0)
       temp2->phaselist[idx].nomenreltnlist[nomcnt].display = trim(n.source_string), temp2->
       phaselist[idx].nomenreltnlist[nomcnt].concept_cki = trim(n.concept_cki), temp2->phaselist[idx]
       .nomenreltnlist[nomcnt].source_vocab_cd = n.source_vocabulary_cd
      ELSE
       temp2->phaselist[idx].nomenreltnlist[nomcnt].display = trim(d.diag_ftdesc)
      ENDIF
     FOOT  ner.parent_entity_id
      IF (nomcnt > 0)
       stat = alterlist(temp2->phaselist[idx].nomenreltnlist,nomcnt)
      ENDIF
     FOOT REPORT
      nomcnt = 0
     WITH nocounter, expand = 2, orahintcbo("Query to fetch the plan's phase/diagnosis data")
    ;end select
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   pw_group_nbr = temp2->phaselist[d1.seq].pw_group_nbr, pathway_id = temp2->phaselist[d1.seq].
   pathway_id, sequence = temp2->phaselist[d1.seq].phasereltnlist[d2.seq].sub_sequence
   FROM (dummyt d1  WITH seq = value(size(temp2->phaselist,5))),
    (dummyt d2  WITH seq = 5)
   PLAN (d1
    WHERE maxrec(d2,size(temp2->phaselist[d1.seq].phasereltnlist,5)) > 0
     AND (temp2->phaselist[d1.seq].do_not_load_phase=0))
    JOIN (d2)
   ORDER BY pw_group_nbr, pathway_id, sequence
   HEAD REPORT
    pwcnt = 0, action_count = 0, protocol_review_info_count = 0,
    b_processed_last_updated = 0, d_action_type_cd = 0.0, evidence_count = 0,
    old_evidence_count = 0, evidence_idx = 0, reply_evidence_idx = 0,
    lplancompphasereltncount = 0, lplancompphasereltnsize = 0, lphasecompphasereltncount = 0,
    lphasecompphasereltnsize = 0, ltreatmentlinkedcomponentcount = 0, ltreatmentlinkedcomponentsize
     = 0,
    pwrcnt = 0
   HEAD pw_group_nbr
    phscnt = 0, compcnt = 0, comptotal = 0,
    evidence_count = 0, old_evidence_count = 0, evidence_idx = 0,
    reply_evidence_idx = 0, lplancompphasereltncount = 0, lplancompphasereltnsize = 0,
    lphasecompphasereltncount = 0, lphasecompphasereltnsize = 0, ltreatmentlinkedcomponentcount = 0,
    ltreatmentlinkedcomponentsize = 0, pwcnt += 1
    IF (pwcnt > size(reply->pwlist,5))
     stat = alterlist(reply->pwlist,(pwcnt+ 10))
    ENDIF
    reply->pwlist[pwcnt].pw_group_nbr = temp2->phaselist[d1.seq].pw_group_nbr, reply->pwlist[pwcnt].
    type_mean = temp2->phaselist[d1.seq].group_type_mean, reply->pwlist[pwcnt].pw_group_desc = temp2
    ->phaselist[d1.seq].pw_group_desc,
    reply->pwlist[pwcnt].cross_encntr_ind = temp2->phaselist[d1.seq].cross_encntr_ind, reply->pwlist[
    pwcnt].version = temp2->phaselist[d1.seq].version, reply->pwlist[pwcnt].newest_version = temp2->
    phaselist[d1.seq].newest_version,
    reply->pwlist[pwcnt].newest_version_active_ind = temp2->phaselist[d1.seq].
    newest_version_active_ind, reply->pwlist[pwcnt].newest_version_pw_cat_id = temp2->phaselist[d1
    .seq].newest_version_pw_cat_id, reply->pwlist[pwcnt].pathway_catalog_id = temp2->phaselist[d1.seq
    ].pw_cat_group_id,
    reply->pwlist[pwcnt].pathway_type_cd = temp2->phaselist[d1.seq].pathway_type_cd, reply->pwlist[
    pwcnt].pathway_class_cd = temp2->phaselist[d1.seq].pathway_class_cd, reply->pwlist[pwcnt].
    display_method_cd = temp2->phaselist[d1.seq].display_method_cd,
    reply->pwlist[pwcnt].cycle_nbr = temp2->phaselist[d1.seq].cycle_nbr, reply->pwlist[pwcnt].
    default_view_mean = temp2->phaselist[d1.seq].default_view_mean, reply->pwlist[pwcnt].
    diagnosis_capture_ind = temp2->phaselist[d1.seq].diagnosis_capture_ind,
    reply->pwlist[pwcnt].allow_copy_forward_ind = temp2->phaselist[d1.seq].allow_copy_forward_ind,
    reply->pwlist[pwcnt].ref_owner_person_id = temp2->phaselist[d1.seq].ref_owner_person_id, reply->
    pwlist[pwcnt].cycle_label_cd = temp2->phaselist[d1.seq].cycle_label_cd,
    reply->pwlist[pwcnt].cycle_end_nbr = temp2->phaselist[d1.seq].cycle_end_nbr, reply->pwlist[pwcnt]
    .synonym_name = temp2->phaselist[d1.seq].synonym_name, reply->pwlist[pwcnt].
    pathway_customized_plan_id = temp2->phaselist[d1.seq].pathway_customized_plan_id,
    CALL marshalandvalidateplanattributesintoreply(pwcnt,d1.seq), reply->pwlist[pwcnt].
    reference_plan_name = temp2->phaselist[d1.seq].reference_plan_name, plan_pathway_catalog_idx =
    temp2->phaselist[d1.seq].plan_pathway_catalog_idx
    IF (plan_pathway_catalog_idx > 0
     AND (plan_pathway_catalog_idx <= query_pathway_catalog->count))
     reply->pwlist[pwcnt].ref_text_ind = query_pathway_catalog->list[plan_pathway_catalog_idx].
     ref_text_ind, old_evidence_count = evidence_count, evidence_count += size(query_pathway_catalog
      ->list[plan_pathway_catalog_idx].evidence_list,5),
     evidence_idx = 0, stat = alterlist(reply->pwlist[pwcnt].planevidencelist,evidence_count)
     FOR (reply_evidence_idx = (old_evidence_count+ 1) TO evidence_count)
       evidence_idx += 1, reply->pwlist[pwcnt].planevidencelist[reply_evidence_idx].dcp_clin_cat_cd
        = query_pathway_catalog->list[plan_pathway_catalog_idx].evidence_list[evidence_idx].
       dcp_clin_cat_cd, reply->pwlist[pwcnt].planevidencelist[reply_evidence_idx].dcp_clin_sub_cat_cd
        = query_pathway_catalog->list[plan_pathway_catalog_idx].evidence_list[evidence_idx].
       dcp_clin_sub_cat_cd,
       reply->pwlist[pwcnt].planevidencelist[reply_evidence_idx].pathway_comp_id =
       query_pathway_catalog->list[plan_pathway_catalog_idx].evidence_list[evidence_idx].
       pathway_comp_id, reply->pwlist[pwcnt].planevidencelist[reply_evidence_idx].evidence_type_mean
        = query_pathway_catalog->list[plan_pathway_catalog_idx].evidence_list[evidence_idx].
       evidence_type_mean, reply->pwlist[pwcnt].planevidencelist[reply_evidence_idx].
       pw_evidence_reltn_id = query_pathway_catalog->list[plan_pathway_catalog_idx].evidence_list[
       evidence_idx].pw_evidence_reltn_id,
       reply->pwlist[pwcnt].planevidencelist[reply_evidence_idx].evidence_locator =
       query_pathway_catalog->list[plan_pathway_catalog_idx].evidence_list[evidence_idx].
       evidence_locator, reply->pwlist[pwcnt].planevidencelist[reply_evidence_idx].pathway_catalog_id
        = query_pathway_catalog->list[plan_pathway_catalog_idx].evidence_list[evidence_idx].
       pathway_catalog_id, reply->pwlist[pwcnt].planevidencelist[reply_evidence_idx].
       evidence_sequence = query_pathway_catalog->list[plan_pathway_catalog_idx].evidence_list[
       evidence_idx].evidence_sequence
     ENDFOR
    ENDIF
   HEAD pathway_id
    ltreatmentlinkedcomponentcount = 0, ltreatmentlinkedcomponentsize = 0, phscnt += 1
    IF (phscnt > size(reply->pwlist[pwcnt].phaselist,5))
     stat = alterlist(reply->pwlist[pwcnt].phaselist,(phscnt+ 10))
    ENDIF
    IF (trim(temp2->phaselist[d1.seq].type_mean)="PHASE")
     reply->pwlist[pwcnt].type_mean = "PATHWAY"
    ELSEIF (trim(temp2->phaselist[d1.seq].type_mean)="CAREPLAN")
     reply->pwlist[pwcnt].type_mean = "CAREPLAN"
    ELSEIF (trim(temp2->phaselist[d1.seq].type_mean)="TAPERPLAN")
     reply->pwlist[pwcnt].type_mean = "TAPERPLAN"
    ENDIF
    reply->pwlist[pwcnt].phaselist[phscnt].pathway_id = temp2->phaselist[d1.seq].pathway_id, reply->
    pwlist[pwcnt].phaselist[phscnt].encntr_id = temp2->phaselist[d1.seq].encntr_id, reply->pwlist[
    pwcnt].phaselist[phscnt].pw_status_cd = temp2->phaselist[d1.seq].pw_status_cd,
    reply->pwlist[pwcnt].phaselist[phscnt].description = temp2->phaselist[d1.seq].description, reply
    ->pwlist[pwcnt].phaselist[phscnt].type_mean = temp2->phaselist[d1.seq].type_mean, reply->pwlist[
    pwcnt].phaselist[phscnt].duration_qty = temp2->phaselist[d1.seq].duration_qty,
    reply->pwlist[pwcnt].phaselist[phscnt].duration_unit_cd = temp2->phaselist[d1.seq].
    duration_unit_cd, reply->pwlist[pwcnt].phaselist[phscnt].started_ind = temp2->phaselist[d1.seq].
    started_ind, reply->pwlist[pwcnt].phaselist[phscnt].processing_ind = temp2->phaselist[d1.seq].
    processing_ind,
    reply->pwlist[pwcnt].phaselist[phscnt].sub_phase_ind = temp2->phaselist[d1.seq].sub_phase_ind,
    reply->pwlist[pwcnt].phaselist[phscnt].updt_cnt = temp2->phaselist[d1.seq].updt_cnt, reply->
    pwlist[pwcnt].phaselist[phscnt].start_dt_tm = temp2->phaselist[d1.seq].start_dt_tm,
    reply->pwlist[pwcnt].phaselist[phscnt].calc_end_dt_tm = temp2->phaselist[d1.seq].calc_end_dt_tm,
    reply->pwlist[pwcnt].phaselist[phscnt].order_dt_tm = temp2->phaselist[d1.seq].order_dt_tm, reply
    ->pwlist[pwcnt].phaselist[phscnt].pathway_catalog_id = temp2->phaselist[d1.seq].
    pathway_catalog_id,
    reply->pwlist[pwcnt].phaselist[phscnt].display_method_cd = temp2->phaselist[d1.seq].
    display_method_cd, reply->pwlist[pwcnt].phaselist[phscnt].parent_phase_desc = temp2->phaselist[d1
    .seq].parent_phase_desc, reply->pwlist[pwcnt].phaselist[phscnt].facility_access_ind = temp2->
    phaselist[d1.seq].facility_access_ind,
    reply->pwlist[pwcnt].phaselist[phscnt].start_tz = temp2->phaselist[d1.seq].start_tz, reply->
    pwlist[pwcnt].phaselist[phscnt].calc_end_tz = temp2->phaselist[d1.seq].calc_end_tz, reply->
    pwlist[pwcnt].phaselist[phscnt].order_tz = temp2->phaselist[d1.seq].order_tz,
    reply->pwlist[pwcnt].phaselist[phscnt].included_ind = temp2->phaselist[d1.seq].included_ind,
    reply->pwlist[pwcnt].phaselist[phscnt].alerts_on_plan_ind = temp2->phaselist[d1.seq].
    alerts_on_plan_ind, reply->pwlist[pwcnt].phaselist[phscnt].alerts_on_plan_upd_ind = temp2->
    phaselist[d1.seq].alerts_on_plan_upd_ind,
    reply->pwlist[pwcnt].phaselist[phscnt].start_estimated_ind = temp2->phaselist[d1.seq].
    start_estimated_ind, reply->pwlist[pwcnt].phaselist[phscnt].calc_end_estimated_ind = temp2->
    phaselist[d1.seq].calc_end_estimated_ind, reply->pwlist[pwcnt].phaselist[phscnt].
    scheduled_facility_cd = temp2->phaselist[d1.seq].scheduled_facility_cd,
    reply->pwlist[pwcnt].phaselist[phscnt].scheduled_nursing_unit_cd = temp2->phaselist[d1.seq].
    scheduled_nursing_unit_cd, reply->pwlist[pwcnt].phaselist[phscnt].period_nbr = temp2->phaselist[
    d1.seq].period_nbr, reply->pwlist[pwcnt].phaselist[phscnt].period_custom_label = temp2->
    phaselist[d1.seq].period_custom_label,
    reply->pwlist[pwcnt].phaselist[phscnt].review_status_flag = temp2->phaselist[d1.seq].
    review_status_flag, reply->pwlist[pwcnt].phaselist[phscnt].pathway_group_id = temp2->phaselist[d1
    .seq].pathway_group_id, reply->pwlist[pwcnt].phaselist[phscnt].processing_status_flag = temp2->
    phaselist[d1.seq].processing_status_flag,
    reply->pwlist[pwcnt].phaselist[phscnt].processing_expired_date_time = temp2->phaselist[d1.seq].
    processing_expired_date_time, reply->pwlist[pwcnt].phaselist[phscnt].pathway_missing_reason_flag
     = temp2->phaselist[d1.seq].pathway_missing_reason_flag, reply->pwlist[pwcnt].phaselist[phscnt].
    warning_level_bit = temp2->phaselist[d1.seq].warning_level_bit,
    CALL marshalandvalidatephaseattributesintoreply(pwcnt,phscnt,d1.seq), phase_pathway_catalog_idx
     = temp2->phaselist[d1.seq].phase_pathway_catalog_idx, lphasecompphasereltnsize = size(temp2->
     phaselist[d1.seq].compphasereltnlist,5)
    IF (lphasecompphasereltnsize > 0)
     FOR (lphasecompphasereltncount = 1 TO lphasecompphasereltnsize)
       IF ((temp2->phaselist[d1.seq].compphasereltnlist[lphasecompphasereltncount].type_mean="DOT"))
        ltreatmentlinkedcomponentcount += 1
        IF (ltreatmentlinkedcomponentcount > ltreatmentlinkedcomponentsize)
         ltreatmentlinkedcomponentsize += 10, stat = alterlist(reply->pwlist[pwcnt].phaselist[phscnt]
          .treatmentlinkedcomponentlist,ltreatmentlinkedcomponentsize)
        ENDIF
        reply->pwlist[pwcnt].phaselist[phscnt].treatmentlinkedcomponentlist[
        ltreatmentlinkedcomponentcount].act_pw_comp_id = temp2->phaselist[d1.seq].compphasereltnlist[
        lphasecompphasereltncount].act_pw_comp_id
       ELSE
        lplancompphasereltncount += 1
        IF (lplancompphasereltncount > lplancompphasereltnsize)
         lplancompphasereltnsize += 10, stat = alterlist(reply->pwlist[pwcnt].compphasereltnlist,
          lplancompphasereltnsize)
        ENDIF
        reply->pwlist[pwcnt].compphasereltnlist[lplancompphasereltncount].act_pw_comp_id = temp2->
        phaselist[d1.seq].compphasereltnlist[lphasecompphasereltncount].act_pw_comp_id, reply->
        pwlist[pwcnt].compphasereltnlist[lplancompphasereltncount].pathway_id = temp2->phaselist[d1
        .seq].compphasereltnlist[lphasecompphasereltncount].pathway_id, reply->pwlist[pwcnt].
        compphasereltnlist[lplancompphasereltncount].type_mean = temp2->phaselist[d1.seq].
        compphasereltnlist[lphasecompphasereltncount].type_mean
       ENDIF
     ENDFOR
    ENDIF
    IF (ltreatmentlinkedcomponentcount > 0
     AND ltreatmentlinkedcomponentcount < ltreatmentlinkedcomponentsize)
     stat = alterlist(reply->pwlist[pwcnt].phaselist[phscnt].treatmentlinkedcomponentlist,
      ltreatmentlinkedcomponentcount)
    ENDIF
    IF (phase_pathway_catalog_idx > 0
     AND (phase_pathway_catalog_idx <= query_pathway_catalog->count))
     reply->pwlist[pwcnt].phaselist[phscnt].future_ind = query_pathway_catalog->list[
     phase_pathway_catalog_idx].future_ind, reply->pwlist[pwcnt].phaselist[phscnt].
     route_for_review_ind = query_pathway_catalog->list[phase_pathway_catalog_idx].
     route_for_review_ind, reply->pwlist[pwcnt].phaselist[phscnt].reschedule_reason_accept_flag =
     query_pathway_catalog->list[phase_pathway_catalog_idx].reschedule_reason_accept_flag,
     CALL marshalandvalidatephasecatalogattributesintoreply(pwcnt,phscnt,phase_pathway_catalog_idx),
     reply->pwlist[pwcnt].phaselist[phscnt].ref_text_ind = query_pathway_catalog->list[
     phase_pathway_catalog_idx].ref_text_ind
     IF (phase_pathway_catalog_idx != plan_pathway_catalog_idx)
      old_evidence_count = evidence_count, evidence_count += size(query_pathway_catalog->list[
       phase_pathway_catalog_idx].evidence_list,5), evidence_idx = 0,
      stat = alterlist(reply->pwlist[pwcnt].planevidencelist,evidence_count)
      FOR (reply_evidence_idx = (old_evidence_count+ 1) TO evidence_count)
        evidence_idx += 1, reply->pwlist[pwcnt].planevidencelist[reply_evidence_idx].dcp_clin_cat_cd
         = query_pathway_catalog->list[phase_pathway_catalog_idx].evidence_list[evidence_idx].
        dcp_clin_cat_cd, reply->pwlist[pwcnt].planevidencelist[reply_evidence_idx].
        dcp_clin_sub_cat_cd = query_pathway_catalog->list[phase_pathway_catalog_idx].evidence_list[
        evidence_idx].dcp_clin_sub_cat_cd,
        reply->pwlist[pwcnt].planevidencelist[reply_evidence_idx].pathway_comp_id =
        query_pathway_catalog->list[phase_pathway_catalog_idx].evidence_list[evidence_idx].
        pathway_comp_id, reply->pwlist[pwcnt].planevidencelist[reply_evidence_idx].evidence_type_mean
         = query_pathway_catalog->list[phase_pathway_catalog_idx].evidence_list[evidence_idx].
        evidence_type_mean, reply->pwlist[pwcnt].planevidencelist[reply_evidence_idx].
        pw_evidence_reltn_id = query_pathway_catalog->list[phase_pathway_catalog_idx].evidence_list[
        evidence_idx].pw_evidence_reltn_id,
        reply->pwlist[pwcnt].planevidencelist[reply_evidence_idx].evidence_locator =
        query_pathway_catalog->list[phase_pathway_catalog_idx].evidence_list[evidence_idx].
        evidence_locator, reply->pwlist[pwcnt].planevidencelist[reply_evidence_idx].
        pathway_catalog_id = query_pathway_catalog->list[phase_pathway_catalog_idx].evidence_list[
        evidence_idx].pathway_catalog_id, reply->pwlist[pwcnt].planevidencelist[reply_evidence_idx].
        evidence_sequence = query_pathway_catalog->list[phase_pathway_catalog_idx].evidence_list[
        evidence_idx].evidence_sequence
      ENDFOR
     ENDIF
    ENDIF
    phsnomenreltntotal = size(temp2->phaselist[d1.seq].nomenreltnlist,5), stat = alterlist(reply->
     pwlist[pwcnt].phaselist[phscnt].nomenreltnlist,phsnomenreltntotal)
    FOR (ncnt = 1 TO phsnomenreltntotal)
      reply->pwlist[pwcnt].phaselist[phscnt].nomenreltnlist[ncnt].nomen_entity_reltn_id = temp2->
      phaselist[d1.seq].nomenreltnlist[ncnt].nomen_entity_reltn_id, reply->pwlist[pwcnt].phaselist[
      phscnt].nomenreltnlist[ncnt].nomenclature_id = temp2->phaselist[d1.seq].nomenreltnlist[ncnt].
      nomenclature_id, reply->pwlist[pwcnt].phaselist[phscnt].nomenreltnlist[ncnt].priority = temp2->
      phaselist[d1.seq].nomenreltnlist[ncnt].priority,
      reply->pwlist[pwcnt].phaselist[phscnt].nomenreltnlist[ncnt].display = temp2->phaselist[d1.seq].
      nomenreltnlist[ncnt].display, reply->pwlist[pwcnt].phaselist[phscnt].nomenreltnlist[ncnt].
      concept_cki = temp2->phaselist[d1.seq].nomenreltnlist[ncnt].concept_cki, reply->pwlist[pwcnt].
      phaselist[phscnt].nomenreltnlist[ncnt].diagnosis_id = temp2->phaselist[d1.seq].nomenreltnlist[
      ncnt].diagnosis_id,
      reply->pwlist[pwcnt].phaselist[phscnt].nomenreltnlist[ncnt].diag_type_cd = temp2->phaselist[d1
      .seq].nomenreltnlist[ncnt].diag_type_cd, reply->pwlist[pwcnt].phaselist[phscnt].nomenreltnlist[
      ncnt].active_ind = temp2->phaselist[d1.seq].nomenreltnlist[ncnt].active_ind, reply->pwlist[
      pwcnt].phaselist[phscnt].nomenreltnlist[ncnt].source_vocab_cd = temp2->phaselist[d1.seq].
      nomenreltnlist[ncnt].source_vocab_cd,
      reply->pwlist[pwcnt].phaselist[phscnt].nomenreltnlist[ncnt].diagnosis_group = temp2->phaselist[
      d1.seq].nomenreltnlist[ncnt].diagnosis_group, reply->pwlist[pwcnt].phaselist[phscnt].
      nomenreltnlist[ncnt].encntr_id = temp2->phaselist[d1.seq].nomenreltnlist[ncnt].encntr_id
    ENDFOR
    action_count = temp2->phaselist[d1.seq].actions_count, stat = alterlist(reply->pwlist[pwcnt].
     phaselist[phscnt].actions,action_count), b_processed_last_updated = 0
    FOR (ncnt = 1 TO action_count)
      prsnl_idx = temp2->phaselist[d1.seq].actions[ncnt].prsnl_idx, d_action_type_cd = temp2->
      phaselist[d1.seq].actions[ncnt].action_type_cd
      IF (d_action_type_cd != action_type_ran_alert_cd
       AND b_processed_last_updated=0)
       b_processed_last_updated = 1, reply->pwlist[pwcnt].phaselist[phscnt].last_updt_dt_tm = temp2->
       phaselist[d1.seq].actions[ncnt].action_dt_tm, reply->pwlist[pwcnt].phaselist[phscnt].
       last_updt_tz = temp2->phaselist[d1.seq].actions[ncnt].action_tz
       IF (prsnl_idx > 0)
        reply->pwlist[pwcnt].phaselist[phscnt].last_updt_prsnl_name = query_prsnl->list[prsnl_idx].
        name_full_formatted
       ENDIF
      ENDIF
      reply->pwlist[pwcnt].phaselist[phscnt].actions[ncnt].action_type_cd = temp2->phaselist[d1.seq].
      actions[ncnt].action_type_cd, reply->pwlist[pwcnt].phaselist[phscnt].actions[ncnt].action_dt_tm
       = temp2->phaselist[d1.seq].actions[ncnt].action_dt_tm, reply->pwlist[pwcnt].phaselist[phscnt].
      actions[ncnt].pw_action_seq = temp2->phaselist[d1.seq].actions[ncnt].pw_action_seq,
      reply->pwlist[pwcnt].phaselist[phscnt].actions[ncnt].pw_status_cd = temp2->phaselist[d1.seq].
      actions[ncnt].pw_status_cd, reply->pwlist[pwcnt].phaselist[phscnt].actions[ncnt].action_tz =
      temp2->phaselist[d1.seq].actions[ncnt].action_tz, reply->pwlist[pwcnt].phaselist[phscnt].
      actions[ncnt].provider_id = temp2->phaselist[d1.seq].actions[ncnt].provider_id
      IF (prsnl_idx > 0)
       reply->pwlist[pwcnt].phaselist[phscnt].actions[ncnt].action_prsnl_id = query_prsnl->list[
       prsnl_idx].prsnl_id, reply->pwlist[pwcnt].phaselist[phscnt].actions[ncnt].action_prsnl_disp =
       query_prsnl->list[prsnl_idx].name_full_formatted, reply->pwlist[pwcnt].phaselist[phscnt].
       actions[ncnt].action_prsnl_name_first = query_prsnl->list[prsnl_idx].name_first,
       reply->pwlist[pwcnt].phaselist[phscnt].actions[ncnt].action_prsnl_name_last = query_prsnl->
       list[prsnl_idx].name_last, prsnl_credential_idx = locateval(prsnl_credential_idx,1,
        query_credential->count,query_prsnl->list[prsnl_idx].prsnl_id,query_credential->personnel[
        prsnl_credential_idx].prsnl_id)
       IF (prsnl_credential_idx > 0)
        credential_idx = 0, credential_list_size = 0
        FOR (idx = 1 TO query_credential->personnel[prsnl_credential_idx].count)
          IF (cnvtdatetime(reply->pwlist[pwcnt].phaselist[phscnt].actions[ncnt].action_dt_tm)
           BETWEEN query_credential->personnel[prsnl_credential_idx].credential[idx].
          beg_effective_dt_tm AND query_credential->personnel[prsnl_credential_idx].credential[idx].
          end_effective_dt_tm)
           credential_idx += 1
           IF (credential_idx > credential_list_size)
            credential_list_size += 10, stat = alterlist(reply->pwlist[pwcnt].phaselist[phscnt].
             actions[ncnt].action_prsnl_credentials,credential_list_size)
           ENDIF
           reply->pwlist[pwcnt].phaselist[phscnt].actions[ncnt].action_prsnl_credentials[
           credential_idx].credential_cd = query_credential->personnel[prsnl_credential_idx].
           credential[idx].credential_cd
          ENDIF
        ENDFOR
        stat = alterlist(reply->pwlist[pwcnt].phaselist[phscnt].actions[ncnt].
         action_prsnl_credentials,credential_idx)
       ENDIF
      ENDIF
    ENDFOR
    protocol_review_info_count = temp2->phaselist[d1.seq].protocol_review_info_count, stat =
    alterlist(reply->pwlist[pwcnt].phaselist[phscnt].protocolreviewinfolist,
     protocol_review_info_count)
    FOR (ncnt = 1 TO protocol_review_info_count)
      reply->pwlist[pwcnt].phaselist[phscnt].protocolreviewinfolist[ncnt].to_prsnl_group_id = temp2->
      phaselist[d1.seq].protocolreviewinfolist[ncnt].to_prsnl_group_id, reply->pwlist[pwcnt].
      phaselist[phscnt].protocolreviewinfolist[ncnt].to_prsnl_group_name = trim(temp2->phaselist[d1
       .seq].protocolreviewinfolist[ncnt].to_prsnl_group_name), reply->pwlist[pwcnt].phaselist[phscnt
      ].protocolreviewinfolist[ncnt].review_dt_tm = cnvtdatetime(temp2->phaselist[d1.seq].
       protocolreviewinfolist[ncnt].review_dt_tm),
      reply->pwlist[pwcnt].phaselist[phscnt].protocolreviewinfolist[ncnt].review_tz = temp2->
      phaselist[d1.seq].protocolreviewinfolist[ncnt].review_tz, prsnl_idx = temp2->phaselist[d1.seq].
      protocolreviewinfolist[ncnt].from_prsnl_idx
      IF (prsnl_idx > 0)
       reply->pwlist[pwcnt].phaselist[phscnt].protocolreviewinfolist[ncnt].from_prsnl_id =
       query_prsnl->list[prsnl_idx].prsnl_id, reply->pwlist[pwcnt].phaselist[phscnt].
       protocolreviewinfolist[ncnt].from_prsnl_name_first = trim(query_prsnl->list[prsnl_idx].
        name_first), reply->pwlist[pwcnt].phaselist[phscnt].protocolreviewinfolist[ncnt].
       from_prsnl_name_last = trim(query_prsnl->list[prsnl_idx].name_last),
       prsnl_credential_idx = locateval(prsnl_credential_idx,1,query_credential->count,query_prsnl->
        list[prsnl_idx].prsnl_id,query_credential->personnel[prsnl_credential_idx].prsnl_id)
       IF (prsnl_credential_idx > 0)
        credential_idx = 0, credential_list_size = 0
        FOR (idx = 1 TO query_credential->personnel[prsnl_credential_idx].count)
          IF (cnvtdatetime(temp2->phaselist[d1.seq].protocolreviewinfolist[ncnt].review_dt_tm)
           BETWEEN query_credential->personnel[prsnl_credential_idx].credential[idx].
          beg_effective_dt_tm AND query_credential->personnel[prsnl_credential_idx].credential[idx].
          end_effective_dt_tm)
           credential_idx += 1
           IF (credential_idx > credential_list_size)
            credential_list_size += 10, stat = alterlist(reply->pwlist[pwcnt].phaselist[phscnt].
             protocolreviewinfolist[ncnt].from_prsnl_credentials,credential_list_size)
           ENDIF
           reply->pwlist[pwcnt].phaselist[phscnt].protocolreviewinfolist[ncnt].
           from_prsnl_credentials[credential_idx].credential_cd = query_credential->personnel[
           prsnl_credential_idx].credential[idx].credential_cd
          ENDIF
        ENDFOR
        stat = alterlist(reply->pwlist[pwcnt].phaselist[phscnt].protocolreviewinfolist[ncnt].
         from_prsnl_credentials,credential_idx)
       ENDIF
      ENDIF
      prsnl_idx = temp2->phaselist[d1.seq].protocolreviewinfolist[ncnt].to_prsnl_idx
      IF (prsnl_idx > 0)
       reply->pwlist[pwcnt].phaselist[phscnt].protocolreviewinfolist[ncnt].to_prsnl_id = query_prsnl
       ->list[prsnl_idx].prsnl_id, reply->pwlist[pwcnt].phaselist[phscnt].protocolreviewinfolist[ncnt
       ].to_prsnl_name_first = trim(query_prsnl->list[prsnl_idx].name_first), reply->pwlist[pwcnt].
       phaselist[phscnt].protocolreviewinfolist[ncnt].to_prsnl_name_last = trim(query_prsnl->list[
        prsnl_idx].name_last),
       prsnl_credential_idx = locateval(prsnl_credential_idx,1,query_credential->count,query_prsnl->
        list[prsnl_idx].prsnl_id,query_credential->personnel[prsnl_credential_idx].prsnl_id)
       IF (prsnl_credential_idx > 0)
        credential_idx = 0, credential_list_size = 0
        FOR (idx = 1 TO query_credential->personnel[prsnl_credential_idx].count)
          IF (cnvtdatetime(temp2->phaselist[d1.seq].protocolreviewinfolist[ncnt].review_dt_tm)
           BETWEEN query_credential->personnel[prsnl_credential_idx].credential[idx].
          beg_effective_dt_tm AND query_credential->personnel[prsnl_credential_idx].credential[idx].
          end_effective_dt_tm)
           credential_idx += 1
           IF (credential_idx > credential_list_size)
            credential_list_size += 10, stat = alterlist(reply->pwlist[pwcnt].phaselist[phscnt].
             protocolreviewinfolist[ncnt].to_prsnl_credentials,credential_list_size)
           ENDIF
           reply->pwlist[pwcnt].phaselist[phscnt].protocolreviewinfolist[ncnt].to_prsnl_credentials[
           credential_idx].credential_cd = query_credential->personnel[prsnl_credential_idx].
           credential[idx].credential_cd
          ENDIF
        ENDFOR
        stat = alterlist(reply->pwlist[pwcnt].phaselist[phscnt].protocolreviewinfolist[ncnt].
         to_prsnl_credentials,credential_idx)
       ENDIF
      ENDIF
    ENDFOR
    pwrcnt = 0
   DETAIL
    IF (d2.seq > 0)
     pwrcnt += 1, stat = alterlist(reply->pwlist[pwcnt].phaselist[phscnt].phasereltnlist,pwrcnt),
     reply->pwlist[pwcnt].phaselist[phscnt].phasereltnlist[pwrcnt].pathway_s_id = temp2->phaselist[d1
     .seq].phasereltnlist[d2.seq].pathway_s_id,
     reply->pwlist[pwcnt].phaselist[phscnt].phasereltnlist[pwrcnt].pathway_t_id = temp2->phaselist[d1
     .seq].phasereltnlist[d2.seq].pathway_t_id, reply->pwlist[pwcnt].phaselist[phscnt].
     phasereltnlist[pwrcnt].type_mean = temp2->phaselist[d1.seq].phasereltnlist[d2.seq].type_mean,
     reply->pwlist[pwcnt].phaselist[phscnt].phasereltnlist[pwrcnt].offset_qty = temp2->phaselist[d1
     .seq].phasereltnlist[d2.seq].offset_qty,
     reply->pwlist[pwcnt].phaselist[phscnt].phasereltnlist[pwrcnt].offset_unit_cd = temp2->phaselist[
     d1.seq].phasereltnlist[d2.seq].offset_unit_cd
     IF ((temp2->phaselist[d1.seq].phasereltnlist[d2.seq].type_mean="SUCCEED"))
      reply->pwlist[pwcnt].phaselist[phscnt].succeed_id = temp2->phaselist[d1.seq].phasereltnlist[d2
      .seq].pathway_t_id
     ENDIF
    ENDIF
   FOOT  pathway_id
    dummy = 0
   FOOT  pw_group_nbr
    IF (phscnt > 0)
     stat = alterlist(reply->pwlist[pwcnt].phaselist,phscnt)
    ENDIF
    IF (lplancompphasereltncount > 0
     AND lplancompphasereltncount < lplancompphasereltnsize)
     stat = alterlist(reply->pwlist[pwcnt].compphasereltnlist,lplancompphasereltncount)
    ENDIF
   FOOT REPORT
    IF (pwcnt > 0)
     stat = alterlist(reply->pwlist,pwcnt)
    ENDIF
   WITH nocounter, outerjoin = d1, orahintcbo(
     "Query to copy all the data from temp2 to pwlist. pwlist is the one thats displayed in 601541 reply structure"
     )
  ;end select
 ENDIF
 SUBROUTINE (isplanphaseinitiateavailable(idx=i4) =c1)
   IF ((temp->planlist[idx].cross_encntr_ind=1)
    AND (temp->planlist[idx].facility_access_ind=1))
    RETURN("Y")
   ENDIF
   IF ((temp->planlist[idx].cross_encntr_ind=0)
    AND (temp->planlist[idx].facility_access_ind=1)
    AND (temp->planlist[idx].init_encntr_id=0))
    RETURN("Y")
   ENDIF
   IF ((temp->planlist[idx].cross_encntr_ind=0)
    AND (temp->planlist[idx].facility_access_ind=1)
    AND (temp->planlist[idx].init_encntr_id=request->querylist[1].encntr_id))
    RETURN("Y")
   ENDIF
   RETURN("N")
 END ;Subroutine
 SUBROUTINE (increment(value=i4(ref)) =i4)
  SET value += 1
  RETURN(value)
 END ;Subroutine
 SUBROUTINE (additemtolist(lqueryindex=i4,lindex=i4,lsubindex=i4,dvalue=f8) =null)
   IF (dvalue > 0.0
    AND lqueryindex > 0
    AND lqueryindex <= query_index_total)
    SET lcount = query->query_list[lqueryindex].value_count
    SET lsize = query->query_list[lqueryindex].value_size
    SET lcount += 1
    IF (lcount > lsize)
     SET lsize += batch_size_default
     SET stat = alterlist(query->query_list[lqueryindex].value_list,lsize)
     SET query->query_list[lqueryindex].value_size = lsize
     SET query->query_list[lqueryindex].value_loops += 1
    ENDIF
    SET query->query_list[lqueryindex].value_count = lcount
    SET query->query_list[lqueryindex].value_list[lcount].value = dvalue
    SET query->query_list[lqueryindex].value_list[lcount].idx = lindex
    SET query->query_list[lqueryindex].value_list[lcount].sub_idx = lsubindex
    SET query->query_list[lqueryindex].value_list[lcount].exist_ind = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE (marshalandvalidatephasecatalogattributesintoreply(lreplyplanindex=i4,lreplyphaseindex=i4,
  lphasecatalogindex=i4) =null WITH protect)
   IF (validate(reply->pwlist[lreplyplanindex].phaselist[lreplyphaseindex].allow_activate_all_ind)=1)
    SET reply->pwlist[lreplyplanindex].phaselist[lreplyphaseindex].allow_activate_all_ind =
    query_pathway_catalog->list[lphasecatalogindex].allow_activate_all_ind
   ENDIF
 END ;Subroutine
 SUBROUTINE (marshalandvalidatephaseattributesintoreply(lreplyplanindex=i4,lreplyphaseindex=i4,
  ltemp2phaseindex=i4) =null WITH protect)
   IF (validate(reply->pwlist[lreplyplanindex].phaselist[lreplyphaseindex].copy_source_pathway_id)=1)
    SET reply->pwlist[lreplyplanindex].phaselist[lreplyphaseindex].copy_source_pathway_id = temp2->
    phaselist[ltemp2phaseindex].copy_source_pathway_id
   ENDIF
   IF (validate(reply->pwlist[lreplyplanindex].phaselist[lreplyphaseindex].hide_grouped_phase_ind)=1)
    SET reply->pwlist[lreplyplanindex].phaselist[lreplyphaseindex].hide_grouped_phase_ind = temp2->
    phaselist[ltemp2phaseindex].hide_grouped_phase_ind
   ENDIF
   IF (validate(reply->pwlist[lreplyplanindex].phaselist[lreplyphaseindex].review_require_sig_count)=
   1)
    SET reply->pwlist[lreplyplanindex].phaselist[lreplyphaseindex].review_require_sig_count = temp2->
    phaselist[ltemp2phaseindex].review_require_sig_count
   ENDIF
   IF (validate(reply->pwlist[lreplyplanindex].phaselist[lreplyphaseindex].linked_phase_ind)=1)
    SET reply->pwlist[lreplyplanindex].phaselist[lreplyphaseindex].linked_phase_ind = temp2->
    phaselist[ltemp2phaseindex].linked_phase_ind
   ENDIF
 END ;Subroutine
 SUBROUTINE (marshalandvalidateplanattributesintoreply(pwcnt=i4,ltemp2phaseindex=i4) =null WITH
  protect)
  IF (validate(reply->pwlist[pwcnt].restricted_actions_bitmask)=1)
   SET reply->pwlist[pwcnt].restricted_actions_bitmask = temp2->phaselist[ltemp2phaseindex].
   restricted_actions_bitmask
  ENDIF
  IF (validate(reply->pwlist[pwcnt].override_mrd_on_plan_ind)=1)
   SET reply->pwlist[pwcnt].override_mrd_on_plan_ind = temp2->phaselist[ltemp2phaseindex].
   override_mrd_on_plan_ind
  ENDIF
 END ;Subroutine
 SUBROUTINE (querypersonnel(dummy=i2) =i4)
   IF ((query_prsnl->loop_count < 1))
    RETURN(0)
   ENDIF
   SET lstart = 1
   SELECT INTO "nl:"
    p.person_id
    FROM (dummyt d1  WITH seq = value(query_prsnl->loop_count)),
     prsnl p
    PLAN (d1
     WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ query_prsnl->batch_size))))
     JOIN (p
     WHERE expand(idx,lstart,(lstart+ (query_prsnl->batch_size - 1)),p.person_id,query_prsnl->list[
      idx].prsnl_id))
    ORDER BY p.person_id
    HEAD p.person_id
     idx = locateval(idx,1,query_prsnl->count,p.person_id,query_prsnl->list[idx].prsnl_id)
     IF (idx > 0)
      query_prsnl->list[idx].name_full_formatted = trim(p.name_full_formatted), query_prsnl->list[idx
      ].name_first = trim(p.name_first), query_prsnl->list[idx].name_last = trim(p.name_last)
     ENDIF
    WITH nocounter
   ;end select
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (querycredential(dummy=i2) =i4)
   IF ((query_credential->loop_count < 1))
    RETURN(0)
   ENDIF
   SET lstart = 1
   SELECT INTO "nl:"
    c.prsnl_id, c.display_seq
    FROM (dummyt d1  WITH seq = value(query_credential->loop_count)),
     credential c
    PLAN (d1
     WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ query_credential->batch_size))))
     JOIN (c
     WHERE expand(idx,lstart,(lstart+ (query_credential->batch_size - 1)),c.prsnl_id,query_credential
      ->personnel[idx].prsnl_id)
      AND c.display_seq != 0)
    ORDER BY c.prsnl_id, c.display_seq
    HEAD c.prsnl_id
     idx = locateval(idx,1,query_credential->count,c.prsnl_id,query_credential->personnel[idx].
      prsnl_id)
    HEAD c.display_seq
     IF (idx > 0)
      query_credential->personnel[idx].count += 1
      IF ((query_credential->personnel[idx].size < query_credential->personnel[idx].count))
       query_credential->personnel[idx].size += query_credential->batch_size, stat = alterlist(
        query_credential->personnel[idx].credential,query_credential->personnel[idx].size)
      ENDIF
      query_credential->personnel[idx].credential[query_credential->personnel[idx].count].
      credential_cd = c.credential_cd, query_credential->personnel[idx].credential[query_credential->
      personnel[idx].count].beg_effective_dt_tm = cnvtdatetime(c.beg_effective_dt_tm),
      query_credential->personnel[idx].credential[query_credential->personnel[idx].count].
      end_effective_dt_tm = cnvtdatetime(c.end_effective_dt_tm)
     ENDIF
    FOOT  c.prsnl_id
     IF ((query_credential->personnel[idx].count > 0)
      AND (query_credential->personnel[idx].count < query_credential->personnel[idx].size))
      stat = alterlist(query_credential->personnel[idx].credential,query_credential->personnel[idx].
       count)
     ENDIF
    WITH nocounter
   ;end select
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (querypathwayaction(dummy=i2) =i4)
   IF ((query_phase_action->loop_count < 1))
    RETURN(0)
   ENDIF
   SET query_prsnl->batch_size = 20
   SET query_credential->batch_size = 20
   SET lstart = 1
   SELECT INTO "nl:"
    pa.pathway_id, pa.pw_action_seq
    FROM (dummyt d1  WITH seq = value(query_phase_action->loop_count)),
     pathway_action pa
    PLAN (d1
     WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ query_phase_action->batch_size))))
     JOIN (pa
     WHERE expand(idx,lstart,(lstart+ (query_phase_action->batch_size - 1)),pa.pathway_id,
      query_phase_action->phases[idx].pathway_id))
    ORDER BY pa.pathway_id, pa.pw_action_seq DESC
    HEAD REPORT
     b_processed_first_item = 0, b_found_ran_alert = 0, action_count = 0,
     action_size = 0, action_batch_size = 20, prsnl_idx = 0,
     MACRO (add_credential)
      prsnl_idx = locateval(prsnl_idx,1,query_credential->count,pa.action_prsnl_id,query_credential->
       personnel[prsnl_idx].prsnl_id)
      IF (prsnl_idx=0)
       query_credential->count += 1
       IF ((query_credential->size < query_credential->count))
        query_credential->size += query_credential->batch_size, query_credential->loop_count += 1,
        stat = alterlist(query_credential->personnel,query_credential->size)
       ENDIF
       query_credential->personnel[query_credential->count].prsnl_id = pa.action_prsnl_id, prsnl_idx
        = query_credential->count
      ENDIF
      query_credential->personnel[prsnl_idx].phase_idx = idx
     ENDMACRO
     ,
     MACRO (add_prsnl)
      prsnl_idx = locateval(prsnl_idx,1,query_prsnl->count,pa.action_prsnl_id,query_prsnl->list[
       prsnl_idx].prsnl_id)
      IF (prsnl_idx=0)
       query_prsnl->count += 1
       IF ((query_prsnl->size < query_prsnl->count))
        query_prsnl->size += query_prsnl->batch_size, query_prsnl->loop_count += 1, stat = alterlist(
         query_prsnl->list,query_prsnl->size)
       ENDIF
       query_prsnl->list[query_prsnl->count].prsnl_id = pa.action_prsnl_id, prsnl_idx = query_prsnl->
       count
      ENDIF
      temp2->phaselist[idx].actions[action_count].prsnl_idx = prsnl_idx
     ENDMACRO
     ,
     MACRO (add_action)
      action_count += 1
      IF (action_size < action_count)
       action_size += action_batch_size, stat = alterlist(temp2->phaselist[idx].actions,action_size)
      ENDIF
      temp2->phaselist[idx].actions[action_count].action_dt_tm = cnvtdatetime(pa.action_dt_tm), temp2
      ->phaselist[idx].actions[action_count].action_type_cd = pa.action_type_cd, temp2->phaselist[idx
      ].actions[action_count].action_tz = pa.action_tz,
      temp2->phaselist[idx].actions[action_count].pw_action_seq = pa.pw_action_seq, temp2->phaselist[
      idx].actions[action_count].pw_status_cd = pa.pw_status_cd, temp2->phaselist[idx].actions[
      action_count].provider_id = pa.provider_id
      IF (pa.action_prsnl_id > 0.0)
       add_prsnl
      ENDIF
     ENDMACRO
    HEAD pa.pathway_id
     b_processed_first_item = 0, b_found_ran_alert = 0, action_count = 0,
     action_size = 0, idx = locateval(idx,1,query_phase_action->count,pa.pathway_id,
      query_phase_action->phases[idx].pathway_id)
     IF (idx > 0)
      idx = query_phase_action->phases[idx].phase_idx
     ENDIF
    HEAD pa.pw_action_seq
     IF (idx > 0)
      IF (pa.action_type_cd=action_type_ran_alert_cd)
       IF (b_found_ran_alert=0)
        b_found_ran_alert = 1, add_action, add_credential,
        temp2->phaselist[idx].last_alert_action_idx = action_count
       ENDIF
      ELSEIF (pa.action_type_cd > 0.0)
       IF (b_processed_first_item=0)
        add_action, add_credential, temp2->phaselist[idx].last_upd_action_idx = action_count
       ENDIF
      ENDIF
     ENDIF
    FOOT  pa.pathway_id
     IF (action_count > 0)
      temp2->phaselist[idx].actions_count = action_count
      IF (action_count < action_size)
       stat = alterlist(temp2->phaselist[idx].actions,action_count)
      ENDIF
     ENDIF
     FOR (idx = (query_prsnl->count+ 1) TO query_prsnl->size)
       query_prsnl->list[idx].prsnl_id = query_prsnl->list[query_prsnl->count].prsnl_id
     ENDFOR
     FOR (idx = (query_credential->count+ 1) TO query_credential->size)
       query_credential->personnel[idx].prsnl_id = query_credential->personnel[query_credential->
       count].prsnl_id
     ENDFOR
    WITH nocounter, expand = 2
   ;end select
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getpathwaycatalogquerylistindex(pathway_catalog_id=f8) =i4)
   SET idx = 0
   IF (pathway_catalog_id <= 0.0)
    RETURN(idx)
   ENDIF
   IF ((query_pathway_catalog->count > 0))
    SET idx = locateval(idx,1,query_pathway_catalog->count,pathway_catalog_id,query_pathway_catalog->
     list[idx].pathway_catalog_id)
   ENDIF
   IF (idx < 1)
    SET query_pathway_catalog->count += 1
    IF ((query_pathway_catalog->count > query_pathway_catalog->size))
     SET query_pathway_catalog->loop_count += 1
     SET query_pathway_catalog->size += query_pathway_catalog->batch_size
     SET stat = alterlist(query_pathway_catalog->list,query_pathway_catalog->size)
    ENDIF
    SET query_pathway_catalog->list[query_pathway_catalog->count].pathway_catalog_id =
    pathway_catalog_id
    SET idx = query_pathway_catalog->count
   ENDIF
   RETURN(idx)
 END ;Subroutine
 SUBROUTINE (querypwcompactreltn(dummy=i2) =i4)
   IF ((query_phase_action->loop_count < 1))
    RETURN(0)
   ENDIF
   SET lstart = 1
   SELECT INTO "nl:"
    pcar.pathway_id
    FROM (dummyt d1  WITH seq = value(query_phase_action->loop_count)),
     pw_comp_act_reltn pcar
    PLAN (d1
     WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ query_phase_action->batch_size))))
     JOIN (pcar
     WHERE expand(idx,lstart,(lstart+ (query_phase_action->batch_size - 1)),pcar.pathway_id,
      query_phase_action->phases[idx].pathway_id))
    ORDER BY pcar.pathway_id
    HEAD REPORT
     lcompphasereltncount = 0, lcompphasereltnsize = 0
    HEAD pcar.pathway_id
     lcompphasereltncount = 0, lcompphasereltnsize = 0, idx = locateval(idx,1,query_phase_action->
      size,pcar.pathway_id,query_phase_action->phases[idx].pathway_id)
     IF (idx > 0)
      idx = query_phase_action->phases[idx].phase_idx
     ENDIF
    DETAIL
     IF (idx > 0)
      lcompphasereltncount += 1
      IF (lcompphasereltncount > lcompphasereltnsize)
       lcompphasereltnsize += 10, stat = alterlist(temp2->phaselist[idx].compphasereltnlist,
        lcompphasereltnsize)
      ENDIF
      temp2->phaselist[idx].compphasereltnlist[lcompphasereltncount].act_pw_comp_id = pcar
      .act_pw_comp_id, temp2->phaselist[idx].compphasereltnlist[lcompphasereltncount].pathway_id =
      pcar.pathway_id, temp2->phaselist[idx].compphasereltnlist[lcompphasereltncount].type_mean =
      trim(pcar.type_mean)
     ENDIF
    FOOT  pcar.pathway_id
     IF (lcompphasereltncount > 0
      AND lcompphasereltncount < lcompphasereltnsize)
      stat = alterlist(temp2->phaselist[idx].compphasereltnlist,lcompphasereltncount)
     ENDIF
    WITH nocounter, expand = 2
   ;end select
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (querypathwaynotification(dummy=i2) =i4)
   IF ((query_pathway_notification->loop_count < 1))
    RETURN(0)
   ENDIF
   SET query_prsnl->batch_size = 20
   SET query_credential->batch_size = 20
   SET lstart = 1
   SELECT INTO "nl:"
    pn.pathway_id, notification_created_dt_tm_utc = cnvtdatetimeutc(cnvtdatetime(pn
      .notification_created_dt_tm),3,pn.notification_created_tz)
    FROM (dummyt d1  WITH seq = value(query_pathway_notification->loop_count)),
     pathway_notification pn,
     prsnl_group pg
    PLAN (d1
     WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ query_pathway_notification->batch_size))))
     JOIN (pn
     WHERE expand(idx,lstart,(lstart+ (query_pathway_notification->batch_size - 1)),pn.pathway_id,
      query_pathway_notification->phases[idx].pathway_id))
     JOIN (pg
     WHERE pn.to_prsnl_group_id=pg.prsnl_group_id)
    ORDER BY pn.pathway_id, notification_created_dt_tm_utc DESC, pn.pw_action_seq DESC
    HEAD REPORT
     baddedprotocolreview = 0, protocol_review_count = 0, protocol_review_size = 0,
     protocol_review_batch_size = 20, to_prsnl_idx = 0, from_prsnl_idx = 0,
     MACRO (add_notification_credential)
      IF (pn.to_prsnl_id > 0)
       to_prsnl_idx = locateval(to_prsnl_idx,1,query_credential->count,pn.to_prsnl_id,
        query_credential->personnel[to_prsnl_idx].prsnl_id)
       IF (to_prsnl_idx=0)
        query_credential->count += 1
        IF ((query_credential->size < query_credential->count))
         query_credential->size += query_credential->batch_size, query_credential->loop_count += 1,
         stat = alterlist(query_credential->personnel,query_credential->size)
        ENDIF
        query_credential->personnel[query_credential->count].prsnl_id = pn.to_prsnl_id
       ENDIF
      ENDIF
      IF (pn.from_prsnl_id > 0)
       from_prsnl_idx = locateval(from_prsnl_idx,1,query_credential->count,pn.from_prsnl_id,
        query_credential->personnel[from_prsnl_idx].prsnl_id)
       IF (from_prsnl_idx=0)
        query_credential->count += 1
        IF ((query_credential->size < query_credential->count))
         query_credential->size += query_credential->batch_size, query_credential->loop_count += 1,
         stat = alterlist(query_credential->personnel,query_credential->size)
        ENDIF
        query_credential->personnel[query_credential->count].prsnl_id = pn.from_prsnl_id
       ENDIF
      ENDIF
     ENDMACRO
     ,
     MACRO (add_notification_prsnl)
      IF (pn.to_prsnl_id > 0)
       to_prsnl_idx = locateval(to_prsnl_idx,1,query_prsnl->count,pn.to_prsnl_id,query_prsnl->list[
        to_prsnl_idx].prsnl_id)
       IF (to_prsnl_idx=0)
        query_prsnl->count += 1
        IF ((query_prsnl->size < query_prsnl->count))
         query_prsnl->size += query_prsnl->batch_size, query_prsnl->loop_count += 1, stat = alterlist
         (query_prsnl->list,query_prsnl->size)
        ENDIF
        query_prsnl->list[query_prsnl->count].prsnl_id = pn.to_prsnl_id, to_prsnl_idx = query_prsnl->
        count
       ENDIF
      ENDIF
      IF (pn.from_prsnl_id > 0)
       from_prsnl_idx = locateval(from_prsnl_idx,1,query_prsnl->count,pn.from_prsnl_id,query_prsnl->
        list[from_prsnl_idx].prsnl_id)
       IF (from_prsnl_idx=0)
        query_prsnl->count += 1
        IF ((query_prsnl->size < query_prsnl->count))
         query_prsnl->size += query_prsnl->batch_size, query_prsnl->loop_count += 1, stat = alterlist
         (query_prsnl->list,query_prsnl->size)
        ENDIF
        query_prsnl->list[query_prsnl->count].prsnl_id = pn.to_prsnl_id, from_prsnl_idx = query_prsnl
        ->count
       ENDIF
      ENDIF
     ENDMACRO
     ,
     MACRO (add_protocol_review_notification)
      IF (pn.notification_type_flag=notification_type_phase_protocol_review
       AND baddedprotocolreview=0)
       IF ( NOT (pn.notification_status_flag IN (notification_status_none,
       notification_status_no_longer_needed)))
        baddedprotocolreview = 1, protocol_review_count += 1
        IF (protocol_review_size < protocol_review_count)
         protocol_review_size += protocol_review_batch_size, stat = alterlist(temp2->phaselist[idx].
          protocolreviewinfolist,protocol_review_size)
        ENDIF
        temp2->phaselist[idx].protocolreviewinfolist[protocol_review_count].to_prsnl_group_id = pn
        .to_prsnl_group_id
        IF (pn.to_prsnl_group_id > 0.0)
         temp2->phaselist[idx].protocolreviewinfolist[protocol_review_count].to_prsnl_group_name =
         trim(pg.prsnl_group_name)
        ENDIF
        IF (pn.notification_status_flag IN (notification_status_accepted,
        notification_status_rejected))
         temp2->phaselist[idx].protocolreviewinfolist[protocol_review_count].review_dt_tm =
         cnvtdatetime(pn.notification_resolved_dt_tm), temp2->phaselist[idx].protocolreviewinfolist[
         protocol_review_count].review_tz = pn.notification_resolved_tz
        ELSE
         temp2->phaselist[idx].protocolreviewinfolist[protocol_review_count].review_dt_tm =
         cnvtdatetime(pn.notification_created_dt_tm), temp2->phaselist[idx].protocolreviewinfolist[
         protocol_review_count].review_tz = pn.notification_created_tz
        ENDIF
        add_notification_prsnl
        IF (pn.to_prsnl_id > 0.0)
         temp2->phaselist[idx].protocolreviewinfolist[protocol_review_count].to_prsnl_idx =
         to_prsnl_idx
        ENDIF
        IF (pn.from_prsnl_id > 0)
         temp2->phaselist[idx].protocolreviewinfolist[protocol_review_count].from_prsnl_idx =
         from_prsnl_idx
        ENDIF
        add_notification_credential
       ENDIF
      ENDIF
     ENDMACRO
    HEAD pn.pathway_id
     baddedprotocolreview = 0, protocol_review_count = 0, protocol_review_size = 0,
     idx = locateval(idx,1,query_pathway_notification->count,pn.pathway_id,query_pathway_notification
      ->phases[idx].pathway_id)
     IF (idx > 0)
      idx = query_pathway_notification->phases[idx].phase_idx
     ENDIF
    DETAIL
     IF (idx > 0)
      add_protocol_review_notification
     ENDIF
    FOOT  pn.pathway_id
     IF (protocol_review_count > 0)
      temp2->phaselist[idx].protocol_review_info_count = protocol_review_count
      IF (protocol_review_count < protocol_review_size)
       stat = alterlist(temp2->phaselist[idx].protocolreviewinfolist,protocol_review_count)
      ENDIF
     ENDIF
    FOOT REPORT
     FOR (idx = (query_prsnl->count+ 1) TO query_prsnl->size)
       query_prsnl->list[idx].prsnl_id = query_prsnl->list[query_prsnl->count].prsnl_id
     ENDFOR
     FOR (idx = (query_credential->count+ 1) TO query_credential->size)
       query_credential->personnel[idx].prsnl_id = query_credential->personnel[query_credential->
       count].prsnl_id
     ENDFOR
    WITH nocounter, expand = 2
   ;end select
   RETURN(1)
 END ;Subroutine
#exit_script
 IF (size(reply->pwlist,5) > 0)
  SET cstatus = "S"
 ELSEIF (size(reply->pwlist,5)=0)
  SET cstatus = "Z"
 ENDIF
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt <= 50)
   SET errcnt += 1
   SET cstatus = "F"
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET reply->status_data.status = cstatus
 IF (debug=1)
  CALL echorecord(query_parent_phases)
  CALL echorecord(query_prsnl)
  CALL echorecord(query_credential)
  CALL echorecord(query_pathway_notification)
  CALL echorecord(temp2)
  CALL echorecord(reply)
 ENDIF
 FREE RECORD query
 FREE RECORD temp2
 FREE RECORD query_prsnl
 FREE RECORD query_phase_action
 FREE RECORD query_credential
 FREE RECORD query_pathway_catalog
 FREE RECORD query_parent_phases
 FREE RECORD query_pathway_notification
 FREE RECORD plans
 SET last_mod = "045"
 SET mod_date = "Nov 11, 2021"
END GO
