CREATE PROGRAM dcp_get_act_phase_components:dba
 SET modify = predeclare
 RECORD patients(
   1 patients_size = i4
   1 patients[*]
     2 patient_id = f8
     2 patient_criteria
       3 birth_dt_tm = dq8
       3 birth_tz = i4
       3 postmenstrual_age_in_days = i4
       3 weight = f8
       3 weight_unit_cd = f8
 )
 RECORD component(
   1 list[*]
     2 act_pw_comp_id = f8
     2 activated_dt_tm = dq8
     2 activated_ind = i2
     2 active_ind = i2
     2 activity_type_cd = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 chemo_ind = i2
     2 chemo_related_ind = i2
     2 cki = vc
     2 comp_label = vc
     2 comp_status_cd = f8
     2 comp_text = vc
     2 comp_text_id = f8
     2 comp_type_cd = f8
     2 cross_phase_group_ind = i2
     2 cross_phase_group_nbr = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_sub_cat_cd = f8
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 exist_ind = i2
     2 expand_qty = i4
     2 expand_unit_cd = f8
     2 facility_access_ind = i2
     2 hide_expectation_ind = i2
     2 high_alert_ind = i2
     2 high_alert_long_text_id = f8
     2 high_alert_required_ntfy_ind = i2
     2 high_alert_text = vc
     2 hna_order_mnemonic = vc
     2 included_ind = i2
     2 linked_to_tf_ind = i2
     2 load_lite_ref_ind = i2
     2 long_blob_id = f8
     2 mnemonic = vc
     2 ocs_clin_cat_cd = f8
     2 oe_format_id = f8
     2 offset_quantity = f8
     2 offset_unit_cd = f8
     2 order_sentence_id = f8
     2 orderable_type_flag = i2
     2 outcome_catalog_id = f8
     2 outcome_description = vc
     2 outcome_end_dt_tm = dq8
     2 outcome_end_tz = i4
     2 outcome_event_cd = f8
     2 outcome_expectation = vc
     2 outcome_start_dt_tm = dq8
     2 outcome_start_tz = i4
     2 outcome_status_cd = f8
     2 outcome_type_cd = f8
     2 outcome_updt_cnt = i4
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 pathway_comp_id = f8
     2 pathway_id = f8
     2 persistent_ind = i2
     2 person_id = f8
     2 ref_active_ind = i2
     2 ref_prnt_ent_id = f8
     2 ref_prnt_ent_name = vc
     2 ref_text_ind = i2
     2 ref_text_mask = i4
     2 ref_text_reltn_id = f8
     2 reference_task_id = f8
     2 required_ind = i2
     2 result_type_cd = f8
     2 rx_mask = i4
     2 sequence = i4
     2 single_select_ind = i2
     2 sort_cd = f8
     2 subphase_display = vc
     2 synonym_id = f8
     2 target_type_cd = f8
     2 task_assay_cd = f8
     2 time_zero_active_ind = i2
     2 time_zero_mean = vc
     2 time_zero_offset_qty = f8
     2 time_zero_offset_unit_cd = f8
     2 updt_cnt = i4
     2 xml_order_detail = vc
     2 dose_info_hist_blob_id = f8
     2 dose_info_hist_blob = vc
     2 xml_order_detail_blob = gvc
     2 dose_info_hist_blob_text = gvc
     2 missing_required_ind = i2
     2 default_os_ind = i2
     2 updt_dt_tm = dq8
     2 intermittent_ind = i2
     2 start_estimated_ind = i2
     2 end_estimated_ind = i2
     2 reject_protocol_review_ind = i2
     2 min_tolerance_interval = i4
     2 min_tolerance_interval_unit_cd = f8
     2 act_pw_comp_group_nbr = f8
     2 display_format_xml = vc
     2 unlink_start_dt_tm_ind = i2
     2 lock_target_dose_flag = i2
     2 pathway_uuid = vc
     2 originating_encntr_id = f8
     2 discontinue_type_flag = i2
     2 ordsentlist[*]
       3 iv_comp_syn_id = f8
       3 normalized_dose_unit_ind = i2
       3 ord_comment_long_text = vc
       3 ord_comment_long_text_id = f8
       3 order_sentence_display_line = vc
       3 order_sentence_id = f8
       3 order_sentence_seq = i4
       3 rx_type_mean = c12
       3 missing_required_ind = i2
       3 applicable_to_patient_ind = i2
       3 order_sentence_filter_display = vc
 )
 RECORD query_long_blob(
   1 list[*]
     2 long_blob_id = f8
     2 idx = i4
     2 idx_type = vc
 )
 RECORD query_long_text(
   1 list[*]
     2 long_text_id = f8
     2 index_list[*]
       3 idx_type = vc
       3 idx = i4
       3 sub_idx_type = vc
       3 sub_idx = i4
 )
 RECORD query_order_component(
   1 list[*]
     2 act_pw_comp_id = f8
     2 idx = i4
 )
 RECORD query_order_activity(
   1 list[*]
     2 parent_entity_id = f8
     2 exist_ind = i2
     2 idx = i4
 )
 RECORD query_order_reference(
   1 list[*]
     2 ref_prnt_ent_id = f8
     2 index_list[*]
       3 idx = i4
 )
 RECORD query_all_order_reference(
   1 list[*]
     2 ref_prnt_ent_id = f8
     2 index_list[*]
       3 idx = i4
 )
 RECORD query_order_sentence(
   1 list[*]
     2 pathway_comp_id = f8
     2 index_list[*]
       3 idx = i4
 )
 RECORD query_outcome_activity(
   1 list[*]
     2 parent_entity_id = f8
     2 exist_ind = i2
     2 idx = i4
 )
 RECORD query_outcome_reference(
   1 list[*]
     2 act_pw_comp_id = f8
     2 idx = i4
 )
 RECORD query_sub_phase_activity(
   1 list[*]
     2 parent_entity_id = f8
     2 exist_ind = i2
     2 idx = i4
 )
 RECORD query_sub_phase_reference(
   1 list[*]
     2 ref_prnt_ent_id = f8
     2 index_list[*]
       3 idx = i4
 )
 RECORD query_component_group(
   1 list[*]
     2 ref_prnt_ent_id = f8
     2 index_list[*]
       3 idx = i4
 )
 RECORD query_component_reference(
   1 list[*]
     2 pathway_comp_id = f8
     2 index_list[*]
       3 idx = i4
 )
 RECORD filter_order_sentences(
   1 patient_criteria
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 postmenstrual_age_in_days = i4
     2 weight = f8
     2 weight_unit_cd = f8
   1 orders[*]
     2 unique_identifier = f8
     2 component_index_list[*]
       3 component_index = i4
     2 order_sentences[*]
       3 order_sentence_id = f8
       3 applicable_to_patient_ind = i2
       3 order_sentence_filters[*]
         4 order_sentence_filter_display = vc
         4 order_sentence_filter_type
           5 age_filter_ind = i2
           5 pma_filter_ind = i2
           5 weight_filter_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE debug = i2 WITH protect, constant(validate(request->debug,0))
 DECLARE copy_forward_ind = i2 WITH protect, constant(validate(request->copy_forward_ind,0))
 DECLARE batch_size_default = i4 WITH protect, constant(20)
 DECLARE batch_size_component = i4 WITH protect, constant(50)
 DECLARE batch_size_phase_list = i4 WITH protect, constant(batch_size_default)
 DECLARE batch_size_long_blob = i4 WITH protect, constant(batch_size_default)
 DECLARE batch_size_long_text = i4 WITH protect, constant(batch_size_default)
 DECLARE batch_size_order_component = i4 WITH protect, constant(batch_size_default)
 DECLARE batch_size_order_activity = i4 WITH protect, constant(batch_size_default)
 DECLARE batch_size_order_reference = i4 WITH protect, constant(batch_size_default)
 DECLARE batch_size_all_order_reference = i4 WITH protect, constant(batch_size_default)
 DECLARE batch_size_order_sentence = i4 WITH protect, constant(batch_size_default)
 DECLARE batch_size_outcome_activity = i4 WITH protect, constant(batch_size_default)
 DECLARE batch_size_outcome_reference = i4 WITH protect, constant(batch_size_default)
 DECLARE batch_size_sub_phase_activity = i4 WITH protect, constant(batch_size_default)
 DECLARE batch_size_sub_phase_reference = i4 WITH protect, constant(batch_size_default)
 DECLARE batch_size_component_group_reference = i4 WITH protect, constant(batch_size_default)
 DECLARE batch_size_component_reference = i4 WITH protext, constant(batch_size_default)
 DECLARE clin_cat_display_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30720,
   "CLINCAT"))
 DECLARE order_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16750,"ORDER CREATE"))
 DECLARE outcome_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16750,"RESULT OUTCO"))
 DECLARE prescription_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16750,
   "PRESCRIPTION"))
 DECLARE note_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16750,"NOTE"))
 DECLARE subphase_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16750,"SUBPHASE"))
 DECLARE compgroup_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16750,"COMPGROUP"))
 DECLARE activated = f8 WITH protect, constant(uar_get_code_by("MEANING",16789,"ACTIVATED"))
 DECLARE planned = f8 WITH protect, constant(uar_get_code_by("MEANING",16789,"PLANNED"))
 DECLARE failed_create = f8 WITH protect, constant(uar_get_code_by("MEANING",16789,"FAILEDCREATE"))
 DECLARE outcome_activated_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30182,"ACTIVATED"
   ))
 DECLARE outcome_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30182,"COMPLETED"
   ))
 DECLARE intervention_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30320,"INTERVENTION"))
 DECLARE moved = f8 WITH protect, constant(uar_get_code_by("MEANING",16789,"MOVED"))
 DECLARE cur_dt_tm = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE cur_date_in_min = i4 WITH protect, constant(cnvtmin2(cnvtdate(cur_dt_tm),cnvttime(cur_dt_tm)
   ))
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE rpidx = i4 WITH protect, noconstant(0)
 DECLARE rcidx = i4 WITH protect, noconstant(0)
 DECLARE rosidx = i4 WITH protect, noconstant(0)
 DECLARE cidx = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE lfindindex = i4 WITH protect, noconstant(0)
 DECLARE lfoundindex = i4 WITH protect, noconstant(0)
 DECLARE lfindindex2 = i4 WITH protect, noconstant(0)
 DECLARE lfoundindex2 = i4 WITH protect, noconstant(0)
 DECLARE dvalue = f8 WITH protect, noconstant(0.0)
 DECLARE lcount = i4 WITH protect, noconstant(0)
 DECLARE lsize = i4 WITH protect, noconstant(0)
 DECLARE lcount2 = i4 WITH protect, noconstant(0)
 DECLARE lsize2 = i4 WITH protect, noconstant(0)
 DECLARE lcomponentcount = i4 WITH protect, noconstant(0)
 DECLARE lcomponentsize = i4 WITH protect, noconstant(0)
 DECLARE llongblobcount = i4 WITH protect, noconstant(0)
 DECLARE llongblobsize = i4 WITH protect, noconstant(0)
 DECLARE llongtextcount = i4 WITH protect, noconstant(0)
 DECLARE llongtextsize = i4 WITH protect, noconstant(0)
 DECLARE lordercomponentcount = i4 WITH protect, noconstant(0)
 DECLARE lordercomponentsize = i4 WITH protect, noconstant(0)
 DECLARE lorderactivitycount = i4 WITH protect, noconstant(0)
 DECLARE lorderactivitysize = i4 WITH protect, noconstant(0)
 DECLARE lorderreferencecount = i4 WITH protect, noconstant(0)
 DECLARE lorderreferencesize = i4 WITH protect, noconstant(0)
 DECLARE lallorderreferencecount = i4 WITH protect, noconstant(0)
 DECLARE lallorderreferencesize = i4 WITH protect, noconstant(0)
 DECLARE lordersentencecount = i4 WITH protect, noconstant(0)
 DECLARE lordersentencesize = i4 WITH protect, noconstant(0)
 DECLARE loutcomeactivitycount = i4 WITH protect, noconstant(0)
 DECLARE loutcomeactivitysize = i4 WITH protect, noconstant(0)
 DECLARE loutcomereferencecount = i4 WITH protect, noconstant(0)
 DECLARE loutcomereferencesize = i4 WITH protect, noconstant(0)
 DECLARE lsubphaseactivitycount = i4 WITH protect, noconstant(0)
 DECLARE lsubphaseactivitysize = i4 WITH protect, noconstant(0)
 DECLARE lsubphasereferencecount = i4 WITH protect, noconstant(0)
 DECLARE lsubphasereferencesize = i4 WITH protect, noconstant(0)
 DECLARE lcomponentgroupreferencecount = i4 WITH protect, noconstant(0)
 DECLARE lcomponentgroupreferencesize = i4 WITH protect, noconstant(0)
 DECLARE lreplyphasesize = i4 WITH protect, noconstant(0)
 DECLARE lreplycomponentsize = i4 WITH protect, noconstant(0)
 DECLARE lreplyorderssentencesize = i4 WITH protect, noconstant(0)
 DECLARE lcomponentreferencecount = i4 WITH protect, noconstant(0)
 DECLARE lcomponentreferencesize = i4 WITH protect, noconstant(0)
 DECLARE ltotalnumberofcomponents = i4 WITH protect, noconstant(0)
 DECLARE lhighestcomponentsequence = i4 WITH protect, noconstant(0)
 DECLARE lbatchsize = i4 WITH protect, noconstant(0)
 DECLARE llistsize = i4 WITH protect, noconstant(0)
 DECLARE lnewlistsize = i4 WITH protect, noconstant(0)
 DECLARE lloopcount = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, noconstant(1)
 DECLARE lstop = i4 WITH protect, noconstant(0)
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE bpadlistind = i2 WITH protect, noconstant(0)
 DECLARE bfacilityvalid = i2 WITH protect, noconstant(0)
 DECLARE offset = i4 WITH protect, noconstant(0)
 DECLARE retlen = i4 WITH protect, noconstant(0)
 DECLARE lorderssize = i4 WITH protect, noconstant(0)
 DECLARE lfoundorderindex = i4 WITH protect, noconstant(0)
 DECLARE luniqueidentifier = f8 WITH protect, noconstant(0.0)
 DECLARE idefaultfacilityaccessind = i2 WITH protect, noconstant(0)
 DECLARE facility_cd = f8 WITH protect, constant(validate(request->facility_cd,0.0))
 IF (facility_cd <= 0.0)
  SET idefaultfacilityaccessind = 1
 ENDIF
 DECLARE facility_access_ind = i2 WITH protect, constant(idefaultfacilityaccessind)
 DECLARE stale_in_min = i4 WITH protect, noconstant(validate(request->staleinmin,10))
 IF (((stale_in_min=0) OR (stale_in_min=null)) )
  SET stale_in_min = 10
 ENDIF
 DECLARE dtimeinseconds = f8 WITH noconstant(0.0)
 DECLARE dtotaltimeinseconds = f8 WITH noconstant(0.0)
 DECLARE starttime = dq8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE stoptime = dq8
 DECLARE ndummy = i2 WITH noconstant(0)
 SET lstart = 1
 SET lbatchsize = batch_size_phase_list
 SET llistsize = size(request->phaselist,5)
 SET lloopcount = ceil((cnvtreal(llistsize)/ lbatchsize))
 SET lnewlistsize = (lloopcount * lbatchsize)
 SET stat = alterlist(request->phaselist,lnewlistsize)
 IF (lnewlistsize <= 0)
  GO TO exit_script
 ENDIF
 FOR (idx = llistsize TO lnewlistsize)
   SET request->phaselist[idx].pathwayid = request->phaselist[llistsize].pathwayid
   SET request->phaselist[idx].displaymethodcd = request->phaselist[llistsize].displaymethodcd
   SET request->phaselist[idx].personid = request->phaselist[llistsize].personid
 ENDFOR
 IF (debug=1)
  CALL echorecord(request)
 ENDIF
 SELECT INTO "nl:"
  patient_id = request->phaselist[d.seq].personid
  FROM (dummyt d  WITH seq = value(size(request->phaselist,5)))
  PLAN (d)
  ORDER BY patient_id
  HEAD REPORT
   dummy = 0
  HEAD patient_id
   patients->patients_size += 1, stat = alterlist(patients->patients,patients->patients_size),
   patients->patients[patients->patients_size].patient_id = request->phaselist[d.seq].personid,
   patients->patients[patients->patients_size].patient_criteria.birth_dt_tm = request->phaselist[d
   .seq].patient_criteria.birth_dt_tm, patients->patients[patients->patients_size].patient_criteria.
   birth_tz = request->phaselist[d.seq].patient_criteria.birth_tz, patients->patients[patients->
   patients_size].patient_criteria.postmenstrual_age_in_days = request->phaselist[d.seq].
   patient_criteria.postmenstrual_age_in_days,
   patients->patients[patients->patients_size].patient_criteria.weight = request->phaselist[d.seq].
   patient_criteria.weight, patients->patients[patients->patients_size].patient_criteria.
   weight_unit_cd = request->phaselist[d.seq].patient_criteria.weight_unit_cd
  DETAIL
   dummy = 0
  FOOT  patient_id
   dummy = 0
  FOOT REPORT
   dummy = 0
  WITH nocounter
 ;end select
 IF (debug=1)
  CALL starttimer(ndummy)
 ENDIF
 SELECT
  IF ((request->querymode="FULLALL"))
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
    JOIN (apc
    WHERE expand(num,lstart,(lstart+ (lbatchsize - 1)),apc.pathway_id,request->phaselist[num].
     pathwayid))
  ELSEIF ((request->querymode="INITOUT"))
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
    JOIN (apc
    WHERE expand(num,lstart,(lstart+ (lbatchsize - 1)),apc.pathway_id,request->phaselist[num].
     pathwayid)
     AND apc.comp_type_cd=outcome_comp_cd
     AND apc.activated_ind=1)
  ELSE
  ENDIF
  INTO "nl:"
  FROM (dummyt d1  WITH seq = value(lloopcount)),
   act_pw_comp apc
  ORDER BY apc.pathway_id, apc.act_pw_comp_id
  HEAD REPORT
   idx = 0
  HEAD apc.pathway_id
   idx = locateval(idx,1,lnewlistsize,apc.pathway_id,request->phaselist[idx].pathwayid)
  HEAD apc.act_pw_comp_id
   lcount = lcomponentcount, lsize = lcomponentsize, lcount += 1
   IF (lcount > lsize)
    lsize += batch_size_component, stat = alterlist(component->list,lsize), lcomponentsize = lsize
   ENDIF
   component->list[lcount].act_pw_comp_id = apc.act_pw_comp_id, component->list[lcount].
   activated_dt_tm = cnvtdatetime(apc.activated_dt_tm), component->list[lcount].activated_ind = apc
   .activated_ind,
   component->list[lcount].active_ind = apc.active_ind, component->list[lcount].chemo_ind = apc
   .chemo_ind, component->list[lcount].chemo_related_ind = apc.chemo_related_ind,
   component->list[lcount].comp_label = apc.comp_label, component->list[lcount].comp_status_cd = apc
   .comp_status_cd, component->list[lcount].comp_type_cd = apc.comp_type_cd,
   component->list[lcount].cross_phase_group_ind = apc.cross_phase_group_ind, component->list[lcount]
   .cross_phase_group_nbr = apc.cross_phase_group_nbr, component->list[lcount].dcp_clin_cat_cd = apc
   .dcp_clin_cat_cd,
   component->list[lcount].dcp_clin_sub_cat_cd = apc.dcp_clin_sub_cat_cd, component->list[lcount].
   duration_qty = apc.duration_qty, component->list[lcount].duration_unit_cd = apc.duration_unit_cd,
   component->list[lcount].exist_ind = 1, component->list[lcount].facility_access_ind = 1, component
   ->list[lcount].included_ind = apc.included_ind,
   component->list[lcount].linked_to_tf_ind = apc.linked_to_tf_ind, component->list[lcount].
   long_blob_id = apc.long_blob_id, component->list[lcount].offset_quantity = apc.offset_quantity,
   component->list[lcount].offset_unit_cd = apc.offset_unit_cd, component->list[lcount].
   order_sentence_id = apc.order_sentence_id, component->list[lcount].parent_entity_id = apc
   .parent_entity_id,
   component->list[lcount].parent_entity_name = apc.parent_entity_name, component->list[lcount].
   pathway_comp_id = apc.pathway_comp_id, component->list[lcount].pathway_id = apc.pathway_id,
   component->list[lcount].persistent_ind = apc.persistent_ind, component->list[lcount].person_id =
   request->phaselist[idx].personid, component->list[lcount].ref_prnt_ent_id = apc.ref_prnt_ent_id,
   component->list[lcount].ref_prnt_ent_name = apc.ref_prnt_ent_name, component->list[lcount].
   required_ind = apc.required_ind, component->list[lcount].sequence = apc.sequence,
   component->list[lcount].time_zero_active_ind = 0, component->list[lcount].time_zero_mean = "NONE",
   component->list[lcount].updt_cnt = apc.updt_cnt,
   component->list[lcount].dose_info_hist_blob_id = apc.dose_info_hist_blob_id, component->list[
   lcount].missing_required_ind = apc.missing_required_ind, component->list[lcount].default_os_ind =
   apc.default_os_ind,
   component->list[lcount].updt_dt_tm = cnvtdatetime(apc.updt_dt_tm), component->list[lcount].
   reject_protocol_review_ind = apc.reject_protocol_review_ind, component->list[lcount].
   min_tolerance_interval = apc.min_tolerance_interval,
   component->list[lcount].min_tolerance_interval_unit_cd = apc.min_tolerance_interval_unit_cd,
   component->list[lcount].act_pw_comp_group_nbr = apc.act_pw_comp_group_nbr, component->list[lcount]
   .display_format_xml =
   IF (trim(apc.display_format_xml) != null) trim(apc.display_format_xml)
   ELSE "<xml />"
   ENDIF
   ,
   component->list[lcount].unlink_start_dt_tm_ind = apc.unlink_start_dt_tm_ind, component->list[
   lcount].lock_target_dose_flag = apc.lock_target_dose_flag, component->list[lcount].pathway_uuid =
   trim(apc.pathway_uuid),
   component->list[lcount].originating_encntr_id = apc.originating_encntr_id, component->list[lcount]
   .discontinue_type_flag = nullval(validate(apc.discontinue_type_flag,1),1)
   IF ((request->phaselist[idx].displaymethodcd IN (clin_cat_display_method_cd, 0)))
    component->list[lcount].sort_cd = apc.dcp_clin_cat_cd
   ENDIF
   lcomponentcount = lcount
   IF ((component->list[lcomponentcount].comp_type_cd IN (order_comp_cd, prescription_comp_cd))
    AND (component->list[lcomponentcount].active_ind=1))
    IF (copy_forward_ind=1)
     dvalue = component->list[lcomponentcount].ref_prnt_ent_id
     IF (dvalue > 0.0)
      lcount = lallorderreferencecount, lsize = lallorderreferencesize, lfoundindex = 0
      IF (lcount > 0)
       lfoundindex = locateval(lfindindex,1,lcount,dvalue,query_all_order_reference->list[lfindindex]
        .ref_prnt_ent_id)
      ENDIF
      IF (lfoundindex=0)
       lcount += 1, lallorderreferencecount = lcount
       IF (lcount > lsize)
        lsize += batch_size_all_order_reference, stat = alterlist(query_all_order_reference->list,
         lsize), lallorderreferencesize = lsize
       ENDIF
       query_all_order_reference->list[lcount].ref_prnt_ent_id = dvalue, lfoundindex = lcount
      ENDIF
      IF (lfoundindex > 0)
       lcount = (size(query_all_order_reference->list[lfoundindex].index_list,5)+ 1), stat =
       alterlist(query_all_order_reference->list[lfoundindex].index_list,lcount),
       query_all_order_reference->list[lfoundindex].index_list[lcount].idx = lcomponentcount
      ENDIF
     ENDIF
     dvalue = component->list[lcomponentcount].dose_info_hist_blob_id
     IF (dvalue > 0.0)
      lcount = llongblobcount, lsize = llongblobsize, lcount += 1,
      llongblobcount = lcount
      IF (lcount > lsize)
       lsize += batch_size_long_blob, stat = alterlist(query_long_blob->list,lsize), llongblobsize =
       lsize
      ENDIF
      query_long_blob->list[lcount].long_blob_id = dvalue, query_long_blob->list[lcount].idx =
      lcomponentcount, query_long_blob->list[lcount].idx_type = "DOSE"
     ENDIF
     dvalue = component->list[lcomponentcount].pathway_comp_id
     IF (dvalue > 0.0)
      lcount = lcomponentreferencecount, lsize = lcomponentreferencesize, lfoundindex = 0
      IF (lcount > 0)
       lfoundindex = locateval(lfindindex,1,lcount,dvalue,query_component_reference->list[lfindindex]
        .pathway_comp_id)
      ENDIF
      IF (lfoundindex=0)
       lcount += 1, lcomponentreferencecount = lcount
       IF (lcount > lsize)
        lsize += batch_size_component_reference, stat = alterlist(query_component_reference->list,
         lsize), lcomponentreferencesize = lsize
       ENDIF
       query_component_reference->list[lcount].pathway_comp_id = dvalue, lfoundindex = lcount
      ENDIF
      IF (lfoundindex > 0)
       lcount = (size(query_component_reference->list[lfoundindex].index_list,5)+ 1), stat =
       alterlist(query_component_reference->list[lfoundindex].index_list,lcount),
       query_component_reference->list[lfoundindex].index_list[lcount].idx = lcomponentcount
      ENDIF
     ENDIF
    ENDIF
    IF ((((component->list[lcomponentcount].comp_status_cd != activated)) OR (copy_forward_ind=1)) )
     dvalue = component->list[lcomponentcount].pathway_comp_id
     IF (dvalue > 0.0)
      lcount = lordersentencecount, lsize = lordersentencesize, lfoundindex = 0
      IF (lcount > 0)
       lfoundindex = locateval(lfindindex,1,lcount,dvalue,query_order_sentence->list[lfindindex].
        pathway_comp_id)
      ENDIF
      IF (lfoundindex=0)
       lcount += 1, lordersentencecount = lcount
       IF (lcount > lsize)
        lsize += batch_size_order_sentence, stat = alterlist(query_order_sentence->list,lsize),
        lordersentencesize = lsize
       ENDIF
       query_order_sentence->list[lcount].pathway_comp_id = dvalue, lfoundindex = lcount
      ENDIF
      IF (lfoundindex > 0)
       lcount = (size(query_order_sentence->list[lfoundindex].index_list,5)+ 1), stat = alterlist(
        query_order_sentence->list[lfoundindex].index_list,lcount), query_order_sentence->list[
       lfoundindex].index_list[lcount].idx = lcomponentcount
      ENDIF
     ENDIF
    ENDIF
    dvalue = component->list[lcomponentcount].act_pw_comp_id
    IF (dvalue > 0.0)
     lcount = lordercomponentcount, lsize = lordercomponentsize, lcount += 1,
     lordercomponentcount = lcount
     IF (lcount > lsize)
      lsize += batch_size_order_component, stat = alterlist(query_order_component->list,lsize),
      lordercomponentsize = lsize
     ENDIF
     query_order_component->list[lcount].act_pw_comp_id = dvalue, query_order_component->list[lcount]
     .idx = lcomponentcount
    ENDIF
    IF ((component->list[lcomponentcount].comp_status_cd=activated))
     dvalue = component->list[lcomponentcount].parent_entity_id
     IF (dvalue > 0.0)
      lcount = lorderactivitycount, lsize = lorderactivitysize, lcount += 1,
      lorderactivitycount = lcount
      IF (lcount > lsize)
       lsize += batch_size_order_activity, stat = alterlist(query_order_activity->list,lsize),
       lorderactivitysize = lsize
      ENDIF
      query_order_activity->list[lcount].parent_entity_id = dvalue, query_order_activity->list[lcount
      ].idx = lcomponentcount, query_order_activity->list[lcount].exist_ind = 0
     ENDIF
    ELSE
     IF (copy_forward_ind=0)
      dvalue = component->list[lcomponentcount].ref_prnt_ent_id
      IF (dvalue > 0.0)
       lcount = lorderreferencecount, lsize = lorderreferencesize, lfoundindex = 0
       IF (lcount > 0)
        lfoundindex = locateval(lfindindex,1,lcount,dvalue,query_order_reference->list[lfindindex].
         ref_prnt_ent_id)
       ENDIF
       IF (lfoundindex=0)
        lcount += 1, lorderreferencecount = lcount
        IF (lcount > lsize)
         lsize += batch_size_order_reference, stat = alterlist(query_order_reference->list,lsize),
         lorderreferencesize = lsize
        ENDIF
        query_order_reference->list[lcount].ref_prnt_ent_id = dvalue, lfoundindex = lcount
       ENDIF
       IF (lfoundindex > 0)
        lcount = (size(query_order_reference->list[lfoundindex].index_list,5)+ 1), stat = alterlist(
         query_order_reference->list[lfoundindex].index_list,lcount), query_order_reference->list[
        lfoundindex].index_list[lcount].idx = lcomponentcount
       ENDIF
      ENDIF
     ENDIF
     dvalue = component->list[lcomponentcount].long_blob_id
     IF (dvalue > 0.0)
      lcount = llongblobcount, lsize = llongblobsize, lcount += 1,
      llongblobcount = lcount
      IF (lcount > lsize)
       lsize += batch_size_long_blob, stat = alterlist(query_long_blob->list,lsize), llongblobsize =
       lsize
      ENDIF
      query_long_blob->list[lcount].long_blob_id = dvalue, query_long_blob->list[lcount].idx =
      lcomponentcount, query_long_blob->list[lcount].idx_type = "DETAIL"
     ENDIF
    ENDIF
   ELSEIF ((component->list[lcomponentcount].comp_type_cd=note_comp_cd)
    AND (component->list[lcomponentcount].active_ind=1))
    dvalue = component->list[lcomponentcount].parent_entity_id
    IF (dvalue > 0.0)
     lcount = llongtextcount, lsize = llongtextsize, lfoundindex = 0
     IF (lcount > 0)
      lfoundindex = locateval(lfindindex,1,lcount,dvalue,query_long_text->list[lfindindex].
       long_text_id)
     ENDIF
     IF (lfoundindex=0)
      lcount += 1, llongtextcount = lcount
      IF (lcount > lsize)
       lsize += batch_size_long_text, stat = alterlist(query_long_text->list,lsize), llongtextsize =
       lsize
      ENDIF
      query_long_text->list[lcount].long_text_id = dvalue, lfoundindex = lcount
     ENDIF
     IF (lfoundindex > 0)
      lcount = (size(query_long_text->list[lfoundindex].index_list,5)+ 1), stat = alterlist(
       query_long_text->list[lfoundindex].index_list,lcount), query_long_text->list[lfoundindex].
      index_list[lcount].idx_type = "NOTE",
      query_long_text->list[lfoundindex].index_list[lcount].idx = lcomponentcount, query_long_text->
      list[lfoundindex].index_list[lcount].sub_idx = 0
     ENDIF
    ENDIF
   ELSEIF ((component->list[lcomponentcount].comp_type_cd=outcome_comp_cd)
    AND (component->list[lcomponentcount].active_ind=1))
    component->list[lcount].outcome_catalog_id = component->list[lcount].ref_prnt_ent_id
    IF ((component->list[lcomponentcount].parent_entity_id != 0))
     dvalue = component->list[lcomponentcount].parent_entity_id, component->list[lcomponentcount].
     exist_ind = 0
     IF (dvalue > 0.0)
      lcount = loutcomeactivitycount, lsize = loutcomeactivitysize, lcount += 1,
      loutcomeactivitycount = lcount
      IF (lcount > lsize)
       lsize += batch_size_outcome_activity, stat = alterlist(query_outcome_activity->list,lsize),
       loutcomeactivitysize = lsize
      ENDIF
      query_outcome_activity->list[lcount].parent_entity_id = dvalue, query_outcome_activity->list[
      lcount].idx = lcomponentcount, query_outcome_activity->list[lcount].exist_ind = 0
     ENDIF
    ELSE
     dvalue = component->list[lcomponentcount].act_pw_comp_id
     IF (dvalue > 0.0)
      lcount = loutcomereferencecount, lsize = loutcomereferencesize, lcount += 1,
      loutcomereferencecount = lcount
      IF (lcount > lsize)
       lsize += batch_size_outcome_reference, stat = alterlist(query_outcome_reference->list,lsize),
       loutcomereferencesize = lsize
      ENDIF
      query_outcome_reference->list[lcount].act_pw_comp_id = dvalue, query_outcome_reference->list[
      lcount].idx = lcomponentcount
     ENDIF
    ENDIF
   ELSEIF ((component->list[lcomponentcount].comp_type_cd=subphase_comp_cd)
    AND (component->list[lcomponentcount].active_ind=1))
    IF ((component->list[lcomponentcount].included_ind=1))
     dvalue = component->list[lcomponentcount].parent_entity_id, component->list[lcomponentcount].
     exist_ind = 0
     IF (dvalue > 0.0)
      lcount = lsubphaseactivitycount, lsize = lsubphaseactivitysize, lcount += 1,
      lsubphaseactivitycount = lcount
      IF (lcount > lsize)
       lsize += batch_size_sub_phase_activity, stat = alterlist(query_sub_phase_activity->list,lsize),
       lsubphaseactivitysize = lsize
      ENDIF
      query_sub_phase_activity->list[lcount].parent_entity_id = dvalue, query_sub_phase_activity->
      list[lcount].idx = lcomponentcount, query_sub_phase_activity->list[lcount].exist_ind = 0
     ENDIF
    ELSE
     dvalue = component->list[lcomponentcount].ref_prnt_ent_id
     IF (dvalue > 0.0)
      lcount = lsubphasereferencecount, lsize = lsubphasereferencesize, lfoundindex = 0
      IF (lcount > 0)
       lfoundindex = locateval(lfindindex,1,lcount,dvalue,query_sub_phase_reference->list[lfindindex]
        .ref_prnt_ent_id)
      ENDIF
      IF (lfoundindex=0)
       lcount += 1, lsubphasereferencecount = lcount
       IF (lcount > lsize)
        lsize += batch_size_sub_phase_reference, stat = alterlist(query_sub_phase_reference->list,
         lsize), lsubphasereferencesize = lsize
       ENDIF
       query_sub_phase_reference->list[lcount].ref_prnt_ent_id = dvalue, lfoundindex = lcount
      ENDIF
      IF (lfoundindex > 0)
       lcount = (size(query_sub_phase_reference->list[lfoundindex].index_list,5)+ 1), stat =
       alterlist(query_sub_phase_reference->list[lfoundindex].index_list,lcount),
       query_sub_phase_reference->list[lfoundindex].index_list[lcount].idx = lcomponentcount
      ENDIF
     ENDIF
    ENDIF
   ELSEIF ((component->list[lcomponentcount].comp_type_cd=compgroup_comp_cd)
    AND (component->list[lcomponentcount].active_ind=1))
    dvalue = component->list[lcomponentcount].ref_prnt_ent_id
    IF (dvalue > 0.0)
     lcount = lcomponentgroupreferencecount, lsize = lcomponentgroupreferencesize, lfoundindex = 0
     IF (lcount > 0)
      lfoundindex = locateval(lfindindex,1,lcount,dvalue,query_component_group->list[lfindindex].
       ref_prnt_ent_id)
     ENDIF
     IF (lfoundindex=0)
      lcount += 1, lcomponentgroupreferencecount = lcount
      IF (lcount > lsize)
       lsize += batch_size_component_group_reference, stat = alterlist(query_component_group->list,
        lsize), lcomponentgroupreferencesize = lsize
      ENDIF
      query_component_group->list[lcount].ref_prnt_ent_id = dvalue, lfoundindex = lcount
     ENDIF
     IF (lfoundindex > 0)
      lcount = (size(query_component_group->list[lfoundindex].index_list,5)+ 1), stat = alterlist(
       query_component_group->list[lfoundindex].index_list,lcount), query_component_group->list[
      lfoundindex].index_list[lcount].idx = lcomponentcount
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   ndummy = 0
  FOOT  apc.act_pw_comp_id
   ndummy = 0
  FOOT  apc.pathway_id
   idx = 0
  FOOT REPORT
   IF (lcomponentcount > 0)
    cstatus = "S"
   ENDIF
   IF (lcomponentcount > 0
    AND lcomponentcount < lcomponentsize)
    lcomponentsize = lcomponentcount, stat = alterlist(component->list,lcomponentsize)
   ENDIF
   FOR (lcount = (llongblobcount+ 1) TO llongblobsize)
     query_long_blob->list[lcount].long_blob_id = query_long_blob->list[llongblobcount].long_blob_id
   ENDFOR
   FOR (lcount = (llongtextcount+ 1) TO llongtextsize)
     query_long_text->list[lcount].long_text_id = query_long_text->list[llongtextcount].long_text_id
   ENDFOR
   FOR (lcount = (lordercomponentcount+ 1) TO lordercomponentsize)
     query_order_component->list[lcount].act_pw_comp_id = query_order_component->list[
     lordercomponentcount].act_pw_comp_id
   ENDFOR
   FOR (lcount = (lorderactivitycount+ 1) TO lorderactivitysize)
     query_order_activity->list[lcount].parent_entity_id = query_order_activity->list[
     lorderactivitycount].parent_entity_id
   ENDFOR
   FOR (lcount = (lorderreferencecount+ 1) TO lorderreferencesize)
     query_order_reference->list[lcount].ref_prnt_ent_id = query_order_reference->list[
     lorderreferencecount].ref_prnt_ent_id
   ENDFOR
   FOR (lcount = (lallorderreferencecount+ 1) TO lallorderreferencesize)
     query_all_order_reference->list[lcount].ref_prnt_ent_id = query_all_order_reference->list[
     lallorderreferencecount].ref_prnt_ent_id
   ENDFOR
   FOR (lcount = (lordersentencecount+ 1) TO lordersentencesize)
     query_order_sentence->list[lcount].pathway_comp_id = query_order_sentence->list[
     lordersentencecount].pathway_comp_id
   ENDFOR
   FOR (lcount = (loutcomeactivitycount+ 1) TO loutcomeactivitysize)
     query_outcome_activity->list[lcount].parent_entity_id = query_outcome_activity->list[
     loutcomeactivitycount].parent_entity_id
   ENDFOR
   FOR (lcount = (loutcomereferencecount+ 1) TO loutcomereferencesize)
     query_outcome_reference->list[lcount].act_pw_comp_id = query_outcome_reference->list[
     loutcomereferencecount].act_pw_comp_id
   ENDFOR
   FOR (lcount = (lsubphaseactivitycount+ 1) TO lsubphaseactivitysize)
     query_sub_phase_activity->list[lcount].parent_entity_id = query_sub_phase_activity->list[
     lsubphaseactivitycount].parent_entity_id
   ENDFOR
   FOR (lcount = (lsubphasereferencecount+ 1) TO lsubphasereferencesize)
     query_sub_phase_reference->list[lcount].ref_prnt_ent_id = query_sub_phase_reference->list[
     lsubphasereferencecount].ref_prnt_ent_id
   ENDFOR
   FOR (lcount = (lcomponentgroupreferencecount+ 1) TO lcomponentgroupreferencesize)
     query_component_group->list[lcount].ref_prnt_ent_id = query_component_group->list[
     lcomponentgroupreferencecount].ref_prnt_ent_id
   ENDFOR
   FOR (lcount = (lcomponentreferencecount+ 1) TO lcomponentreferencesize)
     query_component_reference->list[lcount].pathway_comp_id = query_component_reference->list[
     lcomponentreferencecount].pathway_comp_id
   ENDFOR
  WITH nocounter
 ;end select
 IF (debug=1)
  CALL stoptimer("01 - Initial select")
 ENDIF
 IF (lcomponentgroupreferencecount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lstart = 1
  SET lbatchsize = batch_size_component_group_reference
  SET llistsize = lcomponentgroupreferencesize
  SET lloopcount = ceil((cnvtreal(llistsize)/ lbatchsize))
  SELECT INTO "nl:"
   rtr.parent_entity_name, rtr.parent_entity_id
   FROM (dummyt d1  WITH seq = value(lloopcount)),
    ref_text_reltn rtr
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
    JOIN (rtr
    WHERE rtr.parent_entity_name="PATHWAY_CATALOG"
     AND expand(num,lstart,(lstart+ (lbatchsize - 1)),rtr.parent_entity_id,query_component_group->
     list[num].ref_prnt_ent_id)
     AND rtr.active_ind=1)
   ORDER BY rtr.parent_entity_name, rtr.parent_entity_id
   HEAD rtr.parent_entity_id
    IF (rtr.parent_entity_id > 0)
     lfoundindex = locateval(lfindindex,1,lcomponentgroupreferencecount,rtr.parent_entity_id,
      query_component_group->list[lfindindex].ref_prnt_ent_id)
     IF (lfoundindex > 0)
      lsize = size(query_component_group->list[lfoundindex].index_list,5)
      FOR (lcount = 1 TO lsize)
       idx = query_component_group->list[lfoundindex].index_list[lcount].idx,
       IF (idx > 0)
        component->list[idx].ref_text_ind = 1
       ENDIF
      ENDFOR
     ENDIF
    ENDIF
   DETAIL
    ndummy = 0
   FOOT  rtr.parent_entity_id
    ndummy = 0
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL stoptimer("01 - Get component group reference text")
  ENDIF
 ENDIF
 IF (lordercomponentcount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lstart = 1
  SET lbatchsize = batch_size_order_component
  SET llistsize = lordercomponentsize
  SET lloopcount = ceil((cnvtreal(llistsize)/ lbatchsize))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(lloopcount)),
    act_pw_comp_r apcr
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
    JOIN (apcr
    WHERE expand(num,lstart,(lstart+ (lbatchsize - 1)),apcr.act_pw_comp_s_id,query_order_component->
     list[num].act_pw_comp_id)
     AND trim(apcr.type_mean)="TIMEZERO")
   ORDER BY apcr.act_pw_comp_s_id, apcr.act_pw_comp_t_id
   HEAD REPORT
    ndummy = 0
   HEAD apcr.act_pw_comp_s_id
    lfoundindex = locateval(lfindindex,1,lordercomponentcount,apcr.act_pw_comp_s_id,
     query_order_component->list[lfindindex].act_pw_comp_id), idx = query_order_component->list[
    lfoundindex].idx, component->list[idx].time_zero_active_ind = 1,
    component->list[idx].time_zero_mean = "TIMEZERO"
   DETAIL
    idx = locateval(lfindindex,1,lcomponentcount,apcr.act_pw_comp_t_id,component->list[lfindindex].
     act_pw_comp_id)
    IF (idx > 0)
     component->list[idx].time_zero_active_ind = apcr.active_ind, component->list[idx].time_zero_mean
      = "TIMEZEROLINK", component->list[idx].time_zero_offset_qty = apcr.offset_quantity,
     component->list[idx].time_zero_offset_unit_cd = apcr.offset_unit_cd
    ENDIF
   FOOT  apcr.act_pw_comp_s_id
    ndummy = 0
   FOOT REPORT
    ndummy = 0
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL stoptimer("02 - Get component relationships")
  ENDIF
 ENDIF
 IF (llongblobcount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lstart = 1
  SET lbatchsize = batch_size_long_blob
  SET llistsize = llongblobsize
  SET lloopcount = ceil((cnvtreal(llistsize)/ lbatchsize))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(lloopcount)),
    long_blob lb
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
    JOIN (lb
    WHERE expand(num,lstart,(lstart+ (lbatchsize - 1)),lb.long_blob_id,query_long_blob->list[num].
     long_blob_id))
   DETAIL
    IF (lb.long_blob_id > 0)
     idx = 0, msg_buf = fillstring(32000," "), lfoundindex = locateval(lfindindex,1,llongblobcount,lb
      .long_blob_id,query_long_blob->list[lfindindex].long_blob_id)
     IF (lfoundindex > 0)
      idx = query_long_blob->list[lfoundindex].idx
     ENDIF
     IF (idx > 0)
      IF ((query_long_blob->list[lfoundindex].idx_type="DETAIL"))
       offset = 0, retlen = 1
       WHILE (retlen > 0)
         retlen = blobget(msg_buf,offset,lb.long_blob)
         IF (retlen > 0)
          IF (retlen=size(msg_buf))
           component->list[idx].xml_order_detail_blob = concat(component->list[idx].
            xml_order_detail_blob,msg_buf)
          ELSE
           component->list[idx].xml_order_detail_blob = concat(component->list[idx].
            xml_order_detail_blob,substring(1,retlen,msg_buf))
          ENDIF
         ENDIF
         offset += retlen
       ENDWHILE
       component->list[idx].xml_order_detail = lb.long_blob
      ELSEIF ((query_long_blob->list[lfoundindex].idx_type="DOSE"))
       offset = 0, retlen = 1
       WHILE (retlen > 0)
         retlen = blobget(msg_buf,offset,lb.long_blob)
         IF (retlen > 0)
          IF (retlen=size(msg_buf))
           component->list[idx].dose_info_hist_blob_text = concat(component->list[idx].
            dose_info_hist_blob_text,msg_buf)
          ELSE
           component->list[idx].dose_info_hist_blob_text = concat(component->list[idx].
            dose_info_hist_blob_text,substring(1,retlen,msg_buf))
          ENDIF
         ENDIF
         offset += retlen
       ENDWHILE
       component->list[idx].dose_info_hist_blob = lb.long_blob
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL stoptimer("03 - Get order details from long blob")
  ENDIF
 ENDIF
 IF (lorderactivitycount > 0)
  CALL starttimer(ndummy)
  SET lstart = 1
  SET lbatchsize = batch_size_order_activity
  SET llistsize = lorderactivitysize
  SET lloopcount = ceil((cnvtreal(llistsize)/ lbatchsize))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(lloopcount)),
    orders o
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
    JOIN (o
    WHERE expand(num,lstart,(lstart+ (lbatchsize - 1)),o.order_id,query_order_activity->list[num].
     parent_entity_id))
   DETAIL
    idx = 0
    IF (o.order_id > 0)
     lfoundindex = locateval(lfindindex,1,lorderactivitycount,o.order_id,query_order_activity->list[
      lfindindex].parent_entity_id)
     IF (lfoundindex > 0)
      query_order_activity->list[lfoundindex].exist_ind = 1, idx = query_order_activity->list[
      lfoundindex].idx
     ENDIF
     IF (idx > 0
      AND copy_forward_ind=0)
      IF ((component->list[idx].person_id > 0)
       AND (o.person_id != component->list[idx].person_id))
       component->list[idx].comp_status_cd = moved
      ENDIF
      component->list[idx].activity_type_cd = o.activity_type_cd, component->list[idx].catalog_cd = o
      .catalog_cd, component->list[idx].catalog_type_cd = o.catalog_type_cd,
      component->list[idx].ocs_clin_cat_cd = o.dcp_clin_cat_cd, component->list[idx].
      orderable_type_flag = o.orderable_type_flag, component->list[idx].synonym_id = o.synonym_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL stoptimer("04 - Get orders")
  ENDIF
 ENDIF
 IF (lorderactivitycount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lfoundindex = 0
  SET lfoundindex = locateval(lfindindex,(lfoundindex+ 1),lorderactivitycount,0,query_order_activity
   ->list[lfindindex].exist_ind)
  WHILE (lfoundindex > 0)
    SET idx = query_order_activity->list[lfoundindex].idx
    SET component->list[idx].exist_ind = 0
    IF (copy_forward_ind=0)
     SET dvalue = component->list[idx].ref_prnt_ent_id
     IF (dvalue > 0.0)
      SET lcount = lorderreferencecount
      SET lsize = lorderreferencesize
      SET lfoundindex2 = 0
      IF (lcount > 0)
       SET lfoundindex2 = locateval(lfindindex2,1,lcount,dvalue,query_order_reference->list[
        lfindindex2].ref_prnt_ent_id)
      ENDIF
      IF (lfoundindex2=0)
       SET lcount += 1
       SET lorderreferencecount = lcount
       IF (lcount > lsize)
        SET bpadlistind = 1
        SET lsize += batch_size_order_reference
        SET stat = alterlist(query_order_reference->list,lsize)
        SET lorderreferencesize = lsize
       ENDIF
       SET query_order_reference->list[lcount].ref_prnt_ent_id = dvalue
       SET lfoundindex2 = lcount
      ENDIF
      IF (lfoundindex2 > 0)
       SET lcount = (size(query_order_reference->list[lfoundindex2].index_list,5)+ 1)
       SET stat = alterlist(query_order_reference->list[lfoundindex2].index_list,lcount)
       SET query_order_reference->list[lfoundindex2].index_list[lcount].idx = idx
      ENDIF
     ENDIF
    ENDIF
    SET lfoundindex = locateval(lfindindex,(lfoundindex+ 1),lorderactivitycount,0,
     query_order_activity->list[lfindindex].exist_ind)
  ENDWHILE
  IF (bpadlistind=1)
   SET bpadlistind = 0
   FOR (lcount = (lorderreferencecount+ 1) TO lorderreferencesize)
     SET query_order_reference->list[lcount].ref_prnt_ent_id = query_order_reference->list[
     lorderreferencecount].ref_prnt_ent_id
   ENDFOR
  ENDIF
  IF (debug=1)
   CALL stoptimer("05 - Add orders that did not load to reference list")
  ENDIF
 ENDIF
 IF (copy_forward_ind=0
  AND lorderreferencecount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lstart = 1
  SET lbatchsize = batch_size_order_reference
  SET llistsize = lorderreferencesize
  SET lloopcount = ceil((cnvtreal(llistsize)/ lbatchsize))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(lloopcount)),
    order_catalog_synonym ocs,
    order_catalog oc
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
    JOIN (ocs
    WHERE expand(num,lstart,(lstart+ (lbatchsize - 1)),ocs.synonym_id,query_order_reference->list[num
     ].ref_prnt_ent_id))
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd)
   ORDER BY ocs.synonym_id
   HEAD REPORT
    ndummy = 0
   DETAIL
    IF (ocs.synonym_id > 0)
     lfoundindex = locateval(lfindindex,1,lorderreferencecount,ocs.synonym_id,query_order_reference->
      list[lfindindex].ref_prnt_ent_id)
     IF (lfoundindex > 0)
      lsize = size(query_order_reference->list[lfoundindex].index_list,5)
      FOR (lcount = 1 TO lsize)
        idx = query_order_reference->list[lfoundindex].index_list[lcount].idx, component->list[idx].
        ref_active_ind = ocs.active_ind, component->list[idx].synonym_id = ocs.synonym_id,
        component->list[idx].catalog_cd = ocs.catalog_cd, component->list[idx].catalog_type_cd = ocs
        .catalog_type_cd, component->list[idx].activity_type_cd = ocs.activity_type_cd,
        component->list[idx].mnemonic = trim(ocs.mnemonic), component->list[idx].oe_format_id = ocs
        .oe_format_id, component->list[idx].rx_mask = ocs.rx_mask,
        component->list[idx].orderable_type_flag = ocs.orderable_type_flag, component->list[idx].
        ocs_clin_cat_cd = ocs.dcp_clin_cat_cd, component->list[idx].hna_order_mnemonic = oc
        .primary_mnemonic,
        component->list[idx].cki = oc.cki, component->list[idx].ref_text_mask = ocs.ref_text_mask,
        component->list[idx].high_alert_ind = ocs.high_alert_ind,
        component->list[idx].high_alert_long_text_id = ocs.high_alert_long_text_id, component->list[
        idx].high_alert_required_ntfy_ind = ocs.high_alert_required_ntfy_ind, component->list[idx].
        intermittent_ind = ocs.intermittent_ind
        IF (ocs.high_alert_ind=1)
         dvalue = component->list[idx].high_alert_long_text_id
         IF (dvalue > 0.0)
          lcount2 = llongtextcount, lsize2 = llongtextsize, lfoundindex2 = 0
          IF (lcount2 > 0)
           lfoundindex2 = locateval(lfindindex2,1,lcount2,dvalue,query_long_text->list[lfindindex2].
            long_text_id)
          ENDIF
          IF (lfoundindex2=0)
           lcount2 += 1, llongtextcount = lcount2
           IF (lcount2 > lsize2)
            bpadlistind = 1, lsize2 += batch_size_long_text, stat = alterlist(query_long_text->list,
             lsize2),
            llongtextsize = lsize2
           ENDIF
           query_long_text->list[lcount2].long_text_id = dvalue, lfoundindex2 = lcount2
          ENDIF
          IF (lfoundindex2 > 0)
           lcount2 = (size(query_long_text->list[lfoundindex2].index_list,5)+ 1), stat = alterlist(
            query_long_text->list[lfoundindex2].index_list,lcount2), query_long_text->list[
           lfoundindex2].index_list[lcount2].idx_type = "HIGH_ALERT",
           query_long_text->list[lfoundindex2].index_list[lcount2].idx = idx, query_long_text->list[
           lfoundindex2].index_list[lcount2].sub_idx = 0
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   FOOT REPORT
    IF (bpadlistind=1)
     bpadlistind = 0
     FOR (lcount = (llongtextcount+ 1) TO llongtextsize)
       query_long_text->list[lcount].long_text_id = query_long_text->list[llongtextcount].
       long_text_id
     ENDFOR
    ENDIF
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL stoptimer("06 - Get planned orders")
  ENDIF
 ELSEIF (copy_forward_ind=1
  AND lallorderreferencecount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lstart = 1
  SET lbatchsize = batch_size_all_order_reference
  SET llistsize = lallorderreferencesize
  SET lloopcount = ceil((cnvtreal(llistsize)/ lbatchsize))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(lloopcount)),
    order_catalog_synonym ocs,
    order_catalog oc
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
    JOIN (ocs
    WHERE expand(num,lstart,(lstart+ (lbatchsize - 1)),ocs.synonym_id,query_all_order_reference->
     list[num].ref_prnt_ent_id))
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd)
   ORDER BY ocs.synonym_id
   HEAD REPORT
    ndummy = 0
   DETAIL
    IF (ocs.synonym_id > 0)
     lfoundindex = locateval(lfindindex,1,lallorderreferencecount,ocs.synonym_id,
      query_all_order_reference->list[lfindindex].ref_prnt_ent_id)
     IF (lfoundindex > 0)
      lsize = size(query_all_order_reference->list[lfoundindex].index_list,5)
      FOR (lcount = 1 TO lsize)
        idx = query_all_order_reference->list[lfoundindex].index_list[lcount].idx
        IF ((component->list[idx].activity_type_cd <= 0.0))
         component->list[idx].activity_type_cd = ocs.activity_type_cd
        ENDIF
        component->list[idx].ocs_clin_cat_cd = ocs.dcp_clin_cat_cd, component->list[idx].catalog_cd
         = ocs.catalog_cd, component->list[idx].catalog_type_cd = ocs.catalog_type_cd,
        component->list[idx].synonym_id = ocs.synonym_id, component->list[idx].ref_active_ind = ocs
        .active_ind, component->list[idx].mnemonic = trim(ocs.mnemonic),
        component->list[idx].oe_format_id = ocs.oe_format_id, component->list[idx].rx_mask = ocs
        .rx_mask, component->list[idx].orderable_type_flag = ocs.orderable_type_flag,
        component->list[idx].hna_order_mnemonic = oc.primary_mnemonic, component->list[idx].cki = oc
        .cki, component->list[idx].ref_text_mask = ocs.ref_text_mask,
        component->list[idx].high_alert_ind = ocs.high_alert_ind, component->list[idx].
        high_alert_long_text_id = ocs.high_alert_long_text_id, component->list[idx].
        high_alert_required_ntfy_ind = ocs.high_alert_required_ntfy_ind,
        component->list[idx].intermittent_ind = ocs.intermittent_ind
        IF (ocs.high_alert_ind=1)
         dvalue = component->list[idx].high_alert_long_text_id
         IF (dvalue > 0.0)
          lcount2 = llongtextcount, lsize2 = llongtextsize, lfoundindex2 = 0
          IF (lcount2 > 0)
           lfoundindex2 = locateval(lfindindex2,1,lcount2,dvalue,query_long_text->list[lfindindex2].
            long_text_id)
          ENDIF
          IF (lfoundindex2=0)
           lcount2 += 1, llongtextcount = lcount2
           IF (lcount2 > lsize2)
            bpadlistind = 1, lsize2 += batch_size_long_text, stat = alterlist(query_long_text->list,
             lsize2),
            llongtextsize = lsize2
           ENDIF
           query_long_text->list[lcount2].long_text_id = dvalue, lfoundindex2 = lcount2
          ENDIF
          IF (lfoundindex2 > 0)
           lcount2 = (size(query_long_text->list[lfoundindex2].index_list,5)+ 1), stat = alterlist(
            query_long_text->list[lfoundindex2].index_list,lcount2), query_long_text->list[
           lfoundindex2].index_list[lcount2].idx_type = "HIGH_ALERT",
           query_long_text->list[lfoundindex2].index_list[lcount2].idx = idx, query_long_text->list[
           lfoundindex2].index_list[lcount2].sub_idx = 0
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   FOOT REPORT
    IF (bpadlistind=1)
     bpadlistind = 0
     FOR (lcount = (llongtextcount+ 1) TO llongtextsize)
       query_long_text->list[lcount].long_text_id = query_long_text->list[llongtextcount].
       long_text_id
     ENDFOR
    ENDIF
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL stoptimer("07 - Get reference data for all orders")
  ENDIF
 ENDIF
 IF (lordersentencecount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lstart = 1
  SET lbatchsize = batch_size_order_sentence
  SET llistsize = lordersentencesize
  SET lloopcount = ceil((cnvtreal(llistsize)/ lbatchsize))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(lloopcount)),
    pw_comp_os_reltn pcor,
    order_sentence os
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
    JOIN (pcor
    WHERE expand(num,lstart,(lstart+ (lbatchsize - 1)),pcor.pathway_comp_id,query_order_sentence->
     list[num].pathway_comp_id))
    JOIN (os
    WHERE os.order_sentence_id=pcor.order_sentence_id)
   ORDER BY pcor.pathway_comp_id, pcor.order_sentence_seq
   HEAD REPORT
    ndummy = 0
   HEAD pcor.pathway_comp_id
    lfoundindex = locateval(lfindindex,1,lordersentencecount,pcor.pathway_comp_id,
     query_order_sentence->list[lfindindex].pathway_comp_id), lsize = 0
    IF (lfoundindex > 0)
     lsize = size(query_order_sentence->list[lfoundindex].index_list,5), lfoundorderindex = locateval
     (lfindindex,1,lorderssize,pcor.pathway_comp_id,filter_order_sentences->orders[lfindindex].
      unique_identifier)
     IF (lfoundorderindex=0)
      lorderssize += 1, stat = alterlist(filter_order_sentences->orders,lorderssize),
      filter_order_sentences->orders[lorderssize].unique_identifier = pcor.pathway_comp_id,
      lfoundorderindex = lorderssize
     ENDIF
    ENDIF
   DETAIL
    lordersentencesize = (size(filter_order_sentences->orders[lfoundorderindex].order_sentences,5)+ 1
    ), stat = alterlist(filter_order_sentences->orders[lfoundorderindex].order_sentences,
     lordersentencesize), filter_order_sentences->orders[lfoundorderindex].order_sentences[
    lordersentencesize].order_sentence_id = pcor.order_sentence_id,
    filter_order_sentences->orders[lfoundorderindex].order_sentences[lordersentencesize].
    applicable_to_patient_ind = 1
    FOR (lcount = 1 TO lsize)
      idx = query_order_sentence->list[lfoundindex].index_list[lcount].idx, idx2 = (size(component->
       list[idx].ordsentlist,5)+ 1), stat = alterlist(component->list[idx].ordsentlist,idx2),
      component->list[idx].ordsentlist[idx2].iv_comp_syn_id = pcor.iv_comp_syn_id, component->list[
      idx].ordsentlist[idx2].normalized_dose_unit_ind = pcor.normalized_dose_unit_ind, component->
      list[idx].ordsentlist[idx2].ord_comment_long_text_id = os.ord_comment_long_text_id,
      component->list[idx].ordsentlist[idx2].order_sentence_display_line = trim(os
       .order_sentence_display_line), component->list[idx].ordsentlist[idx2].order_sentence_id = pcor
      .order_sentence_id, component->list[idx].ordsentlist[idx2].order_sentence_seq = pcor
      .order_sentence_seq,
      component->list[idx].ordsentlist[idx2].rx_type_mean = os.rx_type_mean, component->list[idx].
      ordsentlist[idx2].missing_required_ind = pcor.missing_required_ind, component->list[idx].
      ordsentlist[idx2].applicable_to_patient_ind = 1
      IF (os.ord_comment_long_text_id > 0.0)
       dvalue = component->list[idx].ordsentlist[idx2].ord_comment_long_text_id
       IF (dvalue > 0.0)
        lcount2 = llongtextcount, lsize2 = llongtextsize, lfoundindex2 = 0
        IF (lcount2 > 0)
         lfoundindex2 = locateval(lfindindex2,1,lcount2,dvalue,query_long_text->list[lfindindex2].
          long_text_id)
        ENDIF
        IF (lfoundindex2=0)
         lcount2 += 1, llongtextcount = lcount2
         IF (lcount2 > lsize2)
          bpadlistind = 1, lsize2 += batch_size_long_text, stat = alterlist(query_long_text->list,
           lsize2),
          llongtextsize = lsize2
         ENDIF
         query_long_text->list[lcount2].long_text_id = dvalue, lfoundindex2 = lcount2
        ENDIF
        IF (lfoundindex2 > 0)
         lcount2 = (size(query_long_text->list[lfoundindex2].index_list,5)+ 1), stat = alterlist(
          query_long_text->list[lfoundindex2].index_list,lcount2), query_long_text->list[lfoundindex2
         ].index_list[lcount2].idx_type = "ORDER_SENTENCE_COMMENT",
         query_long_text->list[lfoundindex2].index_list[lcount2].idx = idx, query_long_text->list[
         lfoundindex2].index_list[lcount2].sub_idx = idx2
        ENDIF
       ENDIF
      ENDIF
      stat = alterlist(filter_order_sentences->orders[lfoundorderindex].component_index_list,lcount),
      filter_order_sentences->orders[lfoundorderindex].component_index_list[lcount].component_index
       = query_order_sentence->list[lfoundindex].index_list[lcount].idx
    ENDFOR
   FOOT  pcor.pathway_comp_id
    ndummy = 0
   FOOT REPORT
    IF (bpadlistind=1)
     bpadlistind = 0
     FOR (lcount = (llongtextcount+ 1) TO llongtextsize)
       query_long_text->list[lcount].long_text_id = query_long_text->list[llongtextcount].
       long_text_id
     ENDFOR
    ENDIF
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL stoptimer("08 - Get order sentences")
   CALL starttimer(ndummy)
  ENDIF
  IF ((patients->patients_size > 0))
   SET filter_order_sentences->patient_criteria.birth_dt_tm = patients->patients[patients->
   patients_size].patient_criteria.birth_dt_tm
   SET filter_order_sentences->patient_criteria.birth_tz = patients->patients[patients->patients_size
   ].patient_criteria.birth_tz
   SET filter_order_sentences->patient_criteria.postmenstrual_age_in_days = patients->patients[
   patients->patients_size].patient_criteria.postmenstrual_age_in_days
   SET filter_order_sentences->patient_criteria.weight = patients->patients[patients->patients_size].
   patient_criteria.weight
   SET filter_order_sentences->patient_criteria.weight_unit_cd = patients->patients[patients->
   patients_size].patient_criteria.weight_unit_cd
   EXECUTE crmrtl
   EXECUTE srvrtl
   DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
   DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
   SUBROUTINE (filterordersentences(orm_filter_order_sentences_record=vc(ref)) =null)
    IF (size(orm_filter_order_sentences_record->orders,5) > 0)
     SET orm_filter_order_sentences_record->status_data.subeventstatus[1].operationname =
     "FilterOrderSentences"
     DECLARE hmessage = i4 WITH private, constant(uar_srvselect("FilterOrderSentences"))
     IF (hmessage=0)
      SET orm_filter_order_sentences_record->status_data.status = "F"
      SET orm_filter_order_sentences_record->status_data.subeventstatus[1].targetobjectvalue =
      "Error creating Transaction Message"
     ELSE
      DECLARE hrequest = i4 WITH private, constant(uar_srvcreaterequest(hmessage))
      IF (hrequest=0)
       SET orm_filter_order_sentences_record->status_data.status = "F"
       SET orm_filter_order_sentences_record->status_data.subeventstatus[1].targetobjectvalue =
       "Error creating the Request for the transaction"
      ELSE
       DECLARE hreply = i4 WITH private, constant(uar_srvcreatereply(hmessage))
       IF (hreply=0)
        SET orm_filter_order_sentences_record->status_data.status = "F"
        SET orm_filter_order_sentences_record->status_data.subeventstatus[1].targetobjectvalue =
        "Error creating the Reply for the transaction"
       ELSE
        CALL populatepatientcriteria(orm_filter_order_sentences_record,hrequest)
        CALL populaterequest(orm_filter_order_sentences_record,hrequest)
        CALL executefilterordersentences(orm_filter_order_sentences_record,hmessage,hrequest,hreply)
        IF ((orm_filter_order_sentences_record->status_data.status="S"))
         CALL unpackreply(orm_filter_order_sentences_record,hreply)
        ELSE
         SET orm_filter_order_sentences_record->status_data.subeventstatus[1].operationstatus = "F"
         SET orm_filter_order_sentences_record->status_data.subeventstatus[1].targetobjectvalue =
         uar_srvgetstringptr(uar_srvgetstruct(hreply,"transaction_status"),"debug_error_message")
        ENDIF
        CALL uar_srvdestroyinstance(hreply)
       ENDIF
       CALL uar_srvdestroyinstance(hrequest)
      ENDIF
      CALL uar_srvdestroyinstance(hmessage)
     ENDIF
    ELSE
     SET orm_filter_order_sentences_record->status_data.status = "S"
    ENDIF
    RETURN
   END ;Subroutine
   SUBROUTINE (populatepatientcriteria(orm_filter_order_sentences_record=vc(ref),hrequest=i4) =null)
     DECLARE hpatientcriteria = i4 WITH private, constant(uar_srvgetstruct(hrequest,
       "patient_criteria"))
     IF (hpatientcriteria != 0)
      CALL uar_srvsetdate(hpatientcriteria,"birth_dt_tm",cnvtdatetime(
        orm_filter_order_sentences_record->patient_criteria.birth_dt_tm))
      CALL uar_srvsetlong(hpatientcriteria,"birth_tz",orm_filter_order_sentences_record->
       patient_criteria.birth_tz)
      CALL uar_srvsetlong(hpatientcriteria,"postmenstrual_age_in_days",
       orm_filter_order_sentences_record->patient_criteria.postmenstrual_age_in_days)
      CALL uar_srvsetdouble(hpatientcriteria,"weight",orm_filter_order_sentences_record->
       patient_criteria.weight)
      CALL uar_srvsetdouble(hpatientcriteria,"weight_unit_cd",orm_filter_order_sentences_record->
       patient_criteria.weight_unit_cd)
     ENDIF
     RETURN
   END ;Subroutine
   SUBROUTINE (populaterequest(orm_filter_order_sentences_record=vc(ref),hrequest=i4) =null)
     DECLARE iordersindex = i4 WITH private, noconstant(0)
     DECLARE irequestorderssize = i4 WITH private, constant(size(orm_filter_order_sentences_record->
       orders,5))
     DECLARE horders = i4 WITH private, noconstant(0)
     DECLARE iordersentenceindex = i4 WITH private, noconstant(0)
     DECLARE iordersentencessize = i4 WITH private, noconstant(0)
     DECLARE hordersentences = i4 WITH private, noconstant(0)
     FOR (iordersindex = 1 TO irequestorderssize)
      SET horders = uar_srvadditem(hrequest,"orders")
      IF (horders != 0)
       CALL uar_srvsetdouble(horders,"unique_identifier",orm_filter_order_sentences_record->orders[
        iordersindex].unique_identifier)
       SET iordersentencessize = size(orm_filter_order_sentences_record->orders[iordersindex].
        order_sentences,5)
       IF (iordersentencessize > 0)
        FOR (iordersentenceindex = 1 TO iordersentencessize)
         SET hordersentences = uar_srvadditem(horders,"order_sentences")
         IF (hordersentences != 0)
          CALL uar_srvsetdouble(hordersentences,"order_sentence_id",orm_filter_order_sentences_record
           ->orders[iordersindex].order_sentences[iordersentenceindex].order_sentence_id)
         ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ENDFOR
     RETURN
   END ;Subroutine
   SUBROUTINE (executefilterordersentences(orm_filter_order_sentences_record=vc(ref),hmessage=i4,
    hrequest=i4,hreply=i4) =null)
     IF (uar_srvexecute(hmessage,hrequest,hreply)=0)
      DECLARE htransactionstatus = i4 WITH private, constant(uar_srvgetstruct(hreply,
        "transaction_status"))
      IF (htransactionstatus != 0)
       IF (uar_srvgetshort(htransactionstatus,"success_ind")=1)
        SET orm_filter_order_sentences_record->status_data.status = "S"
        SET orm_filter_order_sentences_record->status_data.subeventstatus[1].operationstatus = "S"
       ELSE
        SET orm_filter_order_sentences_record->status_data.status = "F"
        SET orm_filter_order_sentences_record->status_data.subeventstatus[1].operationstatus = "S"
       ENDIF
      ENDIF
     ENDIF
   END ;Subroutine
   SUBROUTINE (unpackreply(orm_filter_order_sentences_record=vc(ref),hreply=i4) =null)
     DECLARE lfindindex = i4 WITH private, noconstant(0)
     DECLARE iordersindex = i4 WITH private, noconstant(0)
     DECLARE iorderssize = i4 WITH private, constant(size(orm_filter_order_sentences_record->orders,5
       ))
     DECLARE horders = i4 WITH private, noconstant(0)
     DECLARE iordersentenceindex = i4 WITH private, noconstant(0)
     DECLARE hordersentences = i4 WITH private, noconstant(0)
     DECLARE ireplyordersindex = i4 WITH private, noconstant(0)
     DECLARE ireplyordersentencesize = i4 WITH private, noconstant(0)
     DECLARE ireplyordersentenceindex = i4 WITH private, noconstant(0)
     DECLARE iordersentfilterindex = i4 WITH private, noconstant(0)
     DECLARE iordersentfiltersize = i4 WITH private, noconstant(0)
     DECLARE hordersentencefilters = i4 WITH private, noconstant(0)
     DECLARE hordersentencefiltertype = i4 WITH private, noconstant(0)
     FOR (ireplyordersindex = 1 TO iorderssize)
      SET horders = uar_srvgetitem(hreply,"orders",(ireplyordersindex - 1))
      IF (horders != 0)
       SET iordersindex = locateval(lfindindex,1,iorderssize,uar_srvgetdouble(horders,
         "unique_identifier"),orm_filter_order_sentences_record->orders[lfindindex].unique_identifier
        )
       WHILE (iordersindex > 0)
         SET ireplyordersentencesize = uar_srvgetitemcount(horders,"order_sentences")
         FOR (ireplyordersentenceindex = 1 TO ireplyordersentencesize)
          SET hordersentences = uar_srvgetitem(horders,"order_sentences",(ireplyordersentenceindex -
           1))
          IF (hordersentences != 0)
           SET iordersentenceindex = locateval(lfindindex,1,size(orm_filter_order_sentences_record->
             orders[iordersindex].order_sentences,5),uar_srvgetdouble(hordersentences,
             "order_sentence_id"),orm_filter_order_sentences_record->orders[iordersindex].
            order_sentences[lfindindex].order_sentence_id)
           IF (iordersentenceindex > 0)
            SET orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
            iordersentenceindex].applicable_to_patient_ind = uar_srvgetshort(hordersentences,
             "applicable_to_patient_ind")
            SET iordersentfiltersize = uar_srvgetitemcount(hordersentences,"order_sentence_filters")
            IF (iordersentfiltersize > 0)
             SET stat = alterlist(orm_filter_order_sentences_record->orders[iordersindex].
              order_sentences[iordersentenceindex].order_sentence_filters,iordersentfiltersize)
             FOR (iordersentfilterindex = 1 TO iordersentfiltersize)
              SET hordersentencefilters = uar_srvgetitem(hordersentences,"order_sentence_filters",0)
              IF (hordersentencefilters != 0)
               SET orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
               iordersentenceindex].order_sentence_filters[iordersentfilterindex].
               order_sentence_filter_display = uar_srvgetstringptr(hordersentencefilters,
                "order_sentence_filter_display")
               SET hordersentencefiltertype = uar_srvgetstruct(hordersentencefilters,
                "order_sentence_filter_type")
               IF (hordersentencefiltertype != 0)
                IF (validate(orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
                 iordersentenceindex].order_sentence_filters[iordersentfilterindex].
                 order_sentence_filter_type) > 0)
                 SET orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
                 iordersentenceindex].order_sentence_filters[iordersentfilterindex].
                 order_sentence_filter_type.age_filter_ind = uar_srvgetshort(hordersentencefiltertype,
                  "age_filter_ind")
                 SET orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
                 iordersentenceindex].order_sentence_filters[iordersentfilterindex].
                 order_sentence_filter_type.pma_filter_ind = uar_srvgetshort(hordersentencefiltertype,
                  "pma_filter_ind")
                 SET orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
                 iordersentenceindex].order_sentence_filters[iordersentfilterindex].
                 order_sentence_filter_type.weight_filter_ind = uar_srvgetshort(
                  hordersentencefiltertype,"weight_filter_ind")
                ENDIF
               ENDIF
              ENDIF
             ENDFOR
            ENDIF
           ENDIF
          ENDIF
         ENDFOR
         SET iordersindex = locateval(lfindindex,(iordersindex+ 1),iorderssize,uar_srvgetdouble(
           horders,"unique_identifier"),orm_filter_order_sentences_record->orders[lfindindex].
          unique_identifier)
       ENDWHILE
      ENDIF
     ENDFOR
     SET last_mod = "003"
     SET mod_date = "May 05, 2022"
   END ;Subroutine
   CALL filterordersentences(filter_order_sentences)
   IF ((filter_order_sentences->status_data.status="S"))
    DECLARE lordersentencefiltercomponentindex = i4 WITH protect, noconstant(0)
    DECLARE lordersentenceapplicabletopatientindex = i4 WITH noconstant(1), protect
    DECLARE lordersentenceapplicabletopatientindicator = i4 WITH constant(1), protect
    DECLARE lordersentencecounter = i4 WITH noconstant(0), protect
    DECLARE lordersentenceapplicabletopatientstartindex = i4 WITH noconstant(1), protect
    DECLARE lorderindex = i4 WITH protect, noconstant(0)
    DECLARE lordersentenceindex = i4 WITH protect, noconstant(0)
    DECLARE lcomponentindexlistsize = i4 WITH protect, noconstant(0)
    DECLARE lcomponentindex_index = i4 WITH protect, noconstant(0)
    DECLARE default_os_is_reset = i1 WITH noconstant(0), protect
    DECLARE replyapplicabletopatient = i2 WITH noconstant(0), protect
    SET lorderssize = size(filter_order_sentences->orders,5)
    FOR (lorderindex = 1 TO lorderssize)
     SET lcomponentindexlistsize = size(filter_order_sentences->orders[lorderindex].
      component_index_list,5)
     FOR (lcomponentindex_index = 1 TO lcomponentindexlistsize)
      SET lordersentencefiltercomponentindex = filter_order_sentences->orders[lorderindex].
      component_index_list[lcomponentindex_index].component_index
      IF (lordersentencefiltercomponentindex > 0)
       SET default_os_is_reset = 0
       SET lordersentencesize = size(filter_order_sentences->orders[lorderindex].order_sentences,5)
       FOR (lordersentenceindex = 1 TO lordersentencesize)
         SET replyapplicabletopatient = filter_order_sentences->orders[lorderindex].order_sentences[
         lordersentenceindex].applicable_to_patient_ind
         SET component->list[lordersentencefiltercomponentindex].ordsentlist[lordersentenceindex].
         applicable_to_patient_ind = replyapplicabletopatient
         IF (replyapplicabletopatient=1
          AND default_os_is_reset=0
          AND (component->list[lordersentencefiltercomponentindex].default_os_ind=1))
          IF (size(filter_order_sentences->orders[lorderindex].order_sentences[lordersentenceindex].
           order_sentence_filters,5) >= 1)
           IF (resetdefaultosindicator(filter_order_sentences->orders[lorderindex].order_sentences[
            lordersentenceindex].order_sentence_filters[1].order_sentence_filter_type.age_filter_ind,
            filter_order_sentences->orders[lorderindex].order_sentences[lordersentenceindex].
            order_sentence_filters[1].order_sentence_filter_type.weight_filter_ind)=1)
            SET component->list[lordersentencefiltercomponentindex].default_os_ind = 0
           ENDIF
          ENDIF
          SET default_os_is_reset = 1
         ENDIF
         IF (size(filter_order_sentences->orders[lorderindex].order_sentences[lordersentenceindex].
          order_sentence_filters,5) >= 1)
          SET component->list[lordersentencefiltercomponentindex].ordsentlist[lordersentenceindex].
          order_sentence_filter_display = trim(filter_order_sentences->orders[lorderindex].
           order_sentences[lordersentenceindex].order_sentence_filters[1].
           order_sentence_filter_display)
          SET lordersentencecounter += 1
          IF (lordersentencecounter=lordersentencesize)
           SET lordersentenceapplicabletopatientindex = locateval(
            lordersentenceapplicabletopatientstartindex,1,lordersentencesize,
            lordersentenceapplicabletopatientindicator,component->list[
            lordersentencefiltercomponentindex].ordsentlist[
            lordersentenceapplicabletopatientstartindex].applicable_to_patient_ind)
           SET lordersentencecounter = 0
          ENDIF
         ENDIF
         IF (lordersentenceapplicabletopatientindex=0)
          SET component->list[lordersentencefiltercomponentindex].default_os_ind = 0
          SET lordersentenceapplicabletopatientindex = 1
         ENDIF
       ENDFOR
      ENDIF
     ENDFOR
    ENDFOR
   ELSE
    DECLARE lorderssize = i4 WITH noconstant(0), protect
    DECLARE lcomponentindexlistsize = i4 WITH protect, noconstant(0)
    DECLARE lordersentencefiltercomponentindex = i4 WITH protect, noconstant(0)
    SET lorderssize = size(filter_order_sentences->orders,5)
    FOR (lorderindex = 1 TO lorderssize)
     SET lcomponentindexlistsize = size(filter_order_sentences->orders[lorderindex].
      component_index_list,5)
     FOR (lcomponentindex_index = 1 TO lcomponentindexlistsize)
      SET lordersentencefiltercomponentindex = filter_order_sentences->orders[lorderindex].
      component_index_list[lcomponentindex_index].component_index
      IF (lordersentencefiltercomponentindex > 0)
       SET component->list[lordersentencefiltercomponentindex].default_os_ind = 0
      ENDIF
     ENDFOR
    ENDFOR
   ENDIF
  ENDIF
  IF (debug=1)
   CALL stoptimer("08a - Get order sentence filters")
   CALL echorecord(filter_order_sentences)
  ENDIF
 ENDIF
 IF (llongtextcount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lstart = 1
  SET lbatchsize = batch_size_long_text
  SET llistsize = llongtextsize
  SET lloopcount = ceil((cnvtreal(llistsize)/ lbatchsize))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(lloopcount)),
    long_text lt
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
    JOIN (lt
    WHERE expand(num,lstart,(lstart+ (lbatchsize - 1)),lt.long_text_id,query_long_text->list[num].
     long_text_id))
   ORDER BY lt.long_text_id
   HEAD REPORT
    ndummy = 0
   HEAD lt.long_text_id
    lfoundindex = locateval(lfindindex,1,llongtextcount,lt.long_text_id,query_long_text->list[
     lfindindex].long_text_id), lsize = 0
    IF (lfoundindex > 0)
     lsize = size(query_long_text->list[lfoundindex].index_list,5)
    ENDIF
    FOR (lcount = 1 TO lsize)
      idx = query_long_text->list[lfoundindex].index_list[lcount].idx, idx2 = query_long_text->list[
      lfoundindex].index_list[lcount].sub_idx
      IF ((query_long_text->list[lfoundindex].index_list[lcount].idx_type="ORDER_SENTENCE_COMMENT")
       AND idx2 > 0
       AND lt.active_ind=1)
       component->list[idx].ordsentlist[idx2].ord_comment_long_text = trim(lt.long_text)
      ELSEIF ((query_long_text->list[lfoundindex].index_list[lcount].idx_type="HIGH_ALERT")
       AND lt.active_ind=1)
       component->list[idx].high_alert_text = trim(lt.long_text)
      ELSEIF ((query_long_text->list[lfoundindex].index_list[lcount].idx_type="NOTE"))
       component->list[idx].comp_text = trim(lt.long_text), component->list[idx].comp_text_id = lt
       .long_text_id
      ENDIF
    ENDFOR
   DETAIL
    ndummy = 0
   FOOT  lt.long_text_id
    ndummy = 0
   FOOT REPORT
    ndummy = 0
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL stoptimer("09 - Get long text")
  ENDIF
 ENDIF
 IF (loutcomeactivitycount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lstart = 1
  SET lbatchsize = batch_size_outcome_activity
  SET llistsize = loutcomeactivitysize
  SET lloopcount = ceil((cnvtreal(llistsize)/ lbatchsize))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(lloopcount)),
    outcome_activity oa
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
    JOIN (oa
    WHERE expand(num,lstart,(lstart+ (lbatchsize - 1)),oa.outcome_activity_id,query_outcome_activity
     ->list[num].parent_entity_id))
   DETAIL
    idx = 0
    IF (oa.outcome_activity_id > 0)
     lfoundindex = locateval(lfindindex,1,loutcomeactivitycount,oa.outcome_activity_id,
      query_outcome_activity->list[lfindindex].parent_entity_id)
     IF (lfoundindex > 0)
      IF (copy_forward_ind=0)
       query_outcome_activity->list[lfoundindex].exist_ind = 1
      ENDIF
      idx = query_outcome_activity->list[lfoundindex].idx
     ENDIF
     IF (idx > 0)
      IF (copy_forward_ind=0)
       component->list[idx].exist_ind = 1
      ENDIF
      component->list[idx].load_lite_ref_ind = 1, component->list[idx].outcome_description = oa
      .description, component->list[idx].outcome_expectation = oa.expectation,
      component->list[idx].outcome_type_cd = oa.outcome_type_cd, component->list[idx].target_type_cd
       = oa.target_type_cd, component->list[idx].expand_qty = oa.expand_qty,
      component->list[idx].expand_unit_cd = oa.expand_unit_cd, component->list[idx].
      outcome_start_dt_tm = cnvtdatetime(oa.start_dt_tm), component->list[idx].outcome_end_dt_tm =
      cnvtdatetime(oa.end_dt_tm),
      component->list[idx].outcome_updt_cnt = oa.updt_cnt, component->list[idx].outcome_event_cd = oa
      .event_cd, component->list[idx].task_assay_cd = oa.task_assay_cd,
      component->list[idx].reference_task_id = oa.reference_task_id, component->list[idx].
      result_type_cd = oa.result_type_cd, component->list[idx].single_select_ind = oa
      .single_select_ind,
      component->list[idx].hide_expectation_ind = oa.hide_expectation_ind, component->list[idx].
      ref_text_reltn_id = oa.ref_text_reltn_id, component->list[idx].outcome_start_tz = oa.start_tz,
      component->list[idx].outcome_end_tz = oa.end_tz, component->list[idx].start_estimated_ind = oa
      .start_estimated_ind, component->list[idx].end_estimated_ind = oa.end_estimated_ind
      IF (oa.outcome_status_cd=outcome_activated_cd
       AND oa.end_dt_tm != null
       AND cnvtdatetime(oa.end_dt_tm) < cnvtdatetime(cur_dt_tm))
       component->list[idx].outcome_status_cd = outcome_completed_cd
      ELSE
       component->list[idx].outcome_status_cd = oa.outcome_status_cd
      ENDIF
      IF ((component->list[idx].person_id > 0.0)
       AND (oa.person_id != component->list[idx].person_id))
       component->list[idx].comp_status_cd = moved
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL stoptimer("10 - Get outcomes")
  ENDIF
 ENDIF
 IF (loutcomeactivitycount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lfoundindex = 0
  SET lfoundindex = locateval(lfindindex,(lfoundindex+ 1),loutcomeactivitycount,0,
   query_outcome_activity->list[lfindindex].exist_ind)
  WHILE (lfoundindex > 0)
    SET idx = query_outcome_activity->list[lfoundindex].idx
    SET component->list[idx].exist_ind = 0
    SET dvalue = component->list[idx].act_pw_comp_id
    IF (dvalue > 0.0)
     SET lcount = loutcomereferencecount
     SET lsize = loutcomereferencesize
     SET lcount += 1
     SET loutcomereferencecount = lcount
     IF (lcount > lsize)
      SET lsize += batch_size_outcome_reference
      SET stat = alterlist(query_outcome_reference->list,lsize)
      SET loutcomereferencesize = lsize
     ENDIF
     SET query_outcome_reference->list[lcount].act_pw_comp_id = dvalue
     SET query_outcome_reference->list[lcount].idx = idx
    ENDIF
    SET lfoundindex = locateval(lfindindex,(lfoundindex+ 1),loutcomeactivitycount,0,
     query_outcome_activity->list[lfindindex].exist_ind)
  ENDWHILE
  IF (bpadlistind=1)
   SET bpadlistind = 0
   FOR (lcount = (loutcomereferencecount+ 1) TO loutcomereferencesize)
     SET query_outcome_reference->list[lcount].act_pw_comp_id = query_outcome_reference->list[
     loutcomereferencecount].act_pw_comp_id
   ENDFOR
  ENDIF
  IF (debug=1)
   CALL stoptimer("11 - Add outcomes that did not load to reference list")
  ENDIF
 ENDIF
 IF (loutcomereferencecount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lstart = 1
  SET lbatchsize = batch_size_outcome_reference
  SET llistsize = loutcomereferencesize
  SET lloopcount = ceil((cnvtreal(llistsize)/ lbatchsize))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(lloopcount)),
    act_pw_comp apc,
    outcome_catalog oc,
    pathway_comp pc
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
    JOIN (apc
    WHERE expand(num,lstart,(lstart+ (lbatchsize - 1)),apc.act_pw_comp_id,query_outcome_reference->
     list[num].act_pw_comp_id))
    JOIN (oc
    WHERE oc.outcome_catalog_id=apc.ref_prnt_ent_id)
    JOIN (pc
    WHERE pc.pathway_comp_id=apc.pathway_comp_id)
   DETAIL
    idx = 0
    IF (apc.act_pw_comp_id > 0)
     lfoundindex = locateval(lfindindex,1,loutcomereferencecount,apc.act_pw_comp_id,
      query_outcome_reference->list[lfindindex].act_pw_comp_id)
     IF (lfoundindex > 0)
      idx = query_outcome_reference->list[lfoundindex].idx
     ENDIF
     IF (idx > 0)
      component->list[idx].ref_active_ind = oc.active_ind
      IF ((component->list[idx].load_lite_ref_ind=1))
       component->list[idx].exist_ind = 1
      ELSE
       component->list[idx].outcome_description = oc.description, component->list[idx].
       outcome_expectation = oc.expectation, component->list[idx].outcome_type_cd = oc
       .outcome_type_cd,
       component->list[idx].outcome_event_cd = oc.event_cd, component->list[idx].task_assay_cd = oc
       .task_assay_cd, component->list[idx].reference_task_id = oc.reference_task_id,
       component->list[idx].result_type_cd = oc.result_type_cd, component->list[idx].
       single_select_ind = oc.single_select_ind, component->list[idx].hide_expectation_ind = oc
       .hide_expectation_ind,
       component->list[idx].ref_text_reltn_id = oc.ref_text_reltn_id
       IF (pc.pathway_comp_id > 0.0)
        component->list[idx].target_type_cd = pc.target_type_cd, component->list[idx].expand_qty = pc
        .expand_qty, component->list[idx].expand_unit_cd = pc.expand_unit_cd
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL stoptimer("12 - Get planned outcomes")
  ENDIF
 ENDIF
 IF (lsubphaseactivitycount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lstart = 1
  SET lbatchsize = batch_size_sub_phase_activity
  SET llistsize = lsubphaseactivitysize
  SET lloopcount = ceil((cnvtreal(llistsize)/ lbatchsize))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(lloopcount)),
    pathway p,
    pathway_catalog pwc
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
    JOIN (p
    WHERE expand(num,lstart,(lstart+ (lbatchsize - 1)),p.pathway_id,query_sub_phase_activity->list[
     num].parent_entity_id))
    JOIN (pwc
    WHERE pwc.pathway_catalog_id=p.pathway_catalog_id)
   DETAIL
    idx = 0
    IF (p.pathway_id > 0)
     lfoundindex = locateval(lfindindex,1,lsubphaseactivitycount,p.pathway_id,
      query_sub_phase_activity->list[lfindindex].parent_entity_id)
     IF (lfoundindex > 0)
      query_sub_phase_activity->list[lfoundindex].exist_ind = 1, idx = query_sub_phase_activity->
      list[lfoundindex].idx
     ENDIF
     IF (idx > 0)
      component->list[idx].exist_ind = 1, component->list[idx].subphase_display = trim(p.description),
      component->list[idx].ref_active_ind = pwc.active_ind,
      component->list[idx].start_estimated_ind = p.start_estimated_ind, component->list[idx].
      end_estimated_ind = p.calc_end_estimated_ind
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL stoptimer("13 - Get sub phases")
  ENDIF
 ENDIF
 IF (lsubphaseactivitycount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lfoundindex = 0
  SET lfoundindex = locateval(lfindindex,(lfoundindex+ 1),lsubphaseactivitycount,0,
   query_sub_phase_activity->list[lfindindex].exist_ind)
  WHILE (lfoundindex > 0)
    SET idx = query_sub_phase_activity->list[lfoundindex].idx
    SET component->list[idx].exist_ind = 0
    SET dvalue = component->list[idx].ref_prnt_ent_id
    IF (dvalue > 0.0)
     SET lcount = lsubphasereferencecount
     SET lsize = lsubphasereferencesize
     SET lfoundindex2 = 0
     IF (lcount > 0)
      SET lfoundindex2 = locateval(lfindindex2,1,lcount,dvalue,query_sub_phase_reference->list[
       lfindindex2].ref_prnt_ent_id)
     ENDIF
     IF (lfoundindex2=0)
      SET lcount += 1
      SET lsubphasereferencecount = lcount
      IF (lcount > lsize)
       SET bpadlistind = 1
       SET lsize += batch_size_sub_phase_reference
       SET stat = alterlist(query_sub_phase_reference->list,lsize)
       SET lsubphasereferencesize = lsize
      ENDIF
      SET query_sub_phase_reference->list[lcount].ref_prnt_ent_id = dvalue
      SET lfoundindex2 = lcount
     ENDIF
     IF (lfoundindex2 > 0)
      SET lcount = (size(query_sub_phase_reference->list[lfoundindex2].index_list,5)+ 1)
      SET stat = alterlist(query_sub_phase_reference->list[lfoundindex2].index_list,lcount)
      SET query_sub_phase_reference->list[lfoundindex2].index_list[lcount].idx = idx
     ENDIF
    ENDIF
    SET lfoundindex = locateval(lfindindex,(lfoundindex+ 1),lsubphaseactivitycount,0,
     query_sub_phase_activity->list[lfindindex].exist_ind)
  ENDWHILE
  IF (bpadlistind=1)
   SET bpadlistind = 0
   FOR (lcount = (lsubphasereferencecount+ 1) TO lsubphasereferencesize)
     SET query_sub_phase_reference->list[lcount].ref_prnt_ent_id = query_sub_phase_reference->list[
     lsubphasereferencecount].ref_prnt_ent_id
   ENDFOR
  ENDIF
  IF (debug=1)
   CALL stoptimer("14 - Add sub phases that did not load to reference list")
  ENDIF
 ENDIF
 IF (lsubphasereferencecount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lstart = 1
  SET lbatchsize = batch_size_sub_phase_reference
  SET llistsize = lsubphasereferencesize
  SET lloopcount = ceil((cnvtreal(llistsize)/ lbatchsize))
  SELECT INTO "nl:"
   pwc.pathway_catalog_id
   FROM (dummyt d1  WITH seq = value(lloopcount)),
    pathway_catalog pwc
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
    JOIN (pwc
    WHERE expand(num,lstart,(lstart+ (lbatchsize - 1)),pwc.pathway_catalog_id,
     query_sub_phase_reference->list[num].ref_prnt_ent_id))
   ORDER BY pwc.pathway_catalog_id
   HEAD pwc.pathway_catalog_id
    IF (pwc.pathway_catalog_id > 0)
     lfoundindex = locateval(lfindindex,1,lsubphasereferencecount,pwc.pathway_catalog_id,
      query_sub_phase_reference->list[lfindindex].ref_prnt_ent_id)
     IF (lfoundindex > 0)
      lsize = size(query_sub_phase_reference->list[lfoundindex].index_list,5)
      FOR (lcount = 1 TO lsize)
        idx = query_sub_phase_reference->list[lfoundindex].index_list[lcount].idx, component->list[
        idx].subphase_display = trim(pwc.display_description), component->list[idx].ref_active_ind =
        pwc.active_ind
      ENDFOR
     ENDIF
    ENDIF
   DETAIL
    ndummy = 0
   FOOT  pwc.pathway_catalog_id
    ndummy = 0
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL stoptimer("15 - Get planned sub phases")
  ENDIF
 ENDIF
 IF (facility_cd > 0.0
  AND lallorderreferencecount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lstart = 1
  SET lbatchsize = batch_size_all_order_reference
  SET llistsize = lallorderreferencesize
  SET lloopcount = ceil((cnvtreal(llistsize)/ lbatchsize))
  SELECT INTO "nl:"
   ocsfr.synonym_id
   FROM (dummyt d1  WITH seq = value(lloopcount)),
    ocs_facility_r ocsfr
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
    JOIN (ocsfr
    WHERE expand(num,lstart,(lstart+ (lbatchsize - 1)),ocsfr.synonym_id,query_all_order_reference->
     list[num].ref_prnt_ent_id))
   ORDER BY ocsfr.synonym_id
   HEAD ocsfr.synonym_id
    bfacilityvalid = 0
   DETAIL
    IF (ocsfr.facility_cd IN (facility_cd, 0.0))
     bfacilityvalid = 1
    ENDIF
   FOOT  ocsfr.synonym_id
    IF (ocsfr.synonym_id > 0
     AND bfacilityvalid=0)
     lfoundindex = locateval(lfindindex,1,lallorderreferencecount,ocsfr.synonym_id,
      query_all_order_reference->list[lfindindex].ref_prnt_ent_id)
     IF (lfoundindex > 0)
      lsize = size(query_all_order_reference->list[lfoundindex].index_list,5)
      FOR (lcount = 1 TO lsize)
       idx = query_all_order_reference->list[lfoundindex].index_list[lcount].idx,component->list[idx]
       .facility_access_ind = 0
      ENDFOR
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL stoptimer("16 - Get facility access for all orders")
  ENDIF
 ENDIF
 DECLARE bavailableatgivenfacility = i2 WITH noconstant(0), protect
 DECLARE icompstart = i2 WITH noconstant(1), protect
 IF (facility_cd > 0.0
  AND lcomponentcount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lstart = 1
  SELECT INTO "nl:"
   oclr.outcome_catalog_id
   FROM outcome_cat_loc_reltn oclr
   WHERE expand(num,lstart,lcomponentsize,oclr.outcome_catalog_id,component->list[num].
    outcome_catalog_id)
   ORDER BY oclr.outcome_catalog_id
   HEAD oclr.outcome_catalog_id
    bavailableatgivenfacility = 0
   DETAIL
    IF (oclr.location_cd=facility_cd)
     bavailableatgivenfacility = 1
    ENDIF
   FOOT  oclr.outcome_catalog_id
    IF (oclr.outcome_catalog_id > 0
     AND bavailableatgivenfacility=0)
     lfoundindex = locateval(lfindindex,icompstart,lcomponentcount,oclr.outcome_catalog_id,component
      ->list[lfindindex].outcome_catalog_id)
     IF (lfoundindex > 0)
      component->list[lfoundindex].facility_access_ind = 0, icompstart = (lfoundindex+ 1)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL stoptimer("16 - Get facility access for all outcomes")
  ENDIF
 ENDIF
 IF (lcomponentreferencecount > 0)
  IF (debug=1)
   CALL starttimer(ndummy)
  ENDIF
  SET lstart = 1
  SET lbatchsize = batch_size_component_reference
  SET llistsize = lcomponentreferencesize
  SET lloopcount = ceil((cnvtreal(llistsize)/ lbatchsize))
  SELECT INTO "nl:"
   pc.pathway_comp_id
   FROM (dummyt d1  WITH seq = value(lloopcount)),
    pathway_comp pc
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
    JOIN (pc
    WHERE expand(num,lstart,(lstart+ (lbatchsize - 1)),pc.pathway_comp_id,query_component_reference->
     list[num].pathway_comp_id))
   ORDER BY pc.pathway_comp_id
   HEAD pc.pathway_comp_id
    IF (pc.pathway_comp_id > 0)
     lfoundindex = locateval(lfindindex,1,lcomponentreferencecount,pc.pathway_comp_id,
      query_component_reference->list[lfindindex].pathway_comp_id)
     IF (lfoundindex > 0)
      lsize = size(query_component_reference->list[lfoundindex].index_list,5)
      FOR (lcount = 1 TO lsize)
       idx = query_component_reference->list[lfoundindex].index_list[lcount].idx,
       IF (idx > 0)
        component->list[idx].lock_target_dose_flag = pc.lock_target_dose_flag
       ENDIF
      ENDFOR
     ENDIF
    ENDIF
   DETAIL
    ndummy = 0
   FOOT  pc.pathway_comp_id
    ndummy = 0
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL stoptimer("17 - Get component reference attributes")
  ENDIF
 ENDIF
 IF (debug=1)
  CALL starttimer(ndummy)
 ENDIF
 SELECT INTO "nl:"
  pathway_id = decode(d2.seq,component->list[d2.seq].pathway_id,0.0), sort_cd = decode(d2.seq,
   component->list[d2.seq].sort_cd,0.0), comp_seq = decode(d2.seq,component->list[d2.seq].sequence,0)
  FROM (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = value(size(component->list,5)))
  PLAN (d1)
   JOIN (d2
   WHERE (component->list[d2.seq].pathway_id > 0))
  ORDER BY pathway_id, sort_cd, comp_seq
  HEAD REPORT
   lreplyphasesize = 0, rpidx = 0, cidx = 0
  HEAD pathway_id
   lreplycomponentsize = 0, rcidx = 0, ltotalnumberofcomponents = 0,
   rpidx += 1
   IF (rpidx > lreplyphasesize)
    lreplyphasesize += batch_size_phase_list, stat = alterlist(reply->phaselist,lreplyphasesize)
   ENDIF
   reply->phaselist[rpidx].pathway_id = pathway_id
  HEAD sort_cd
   rcidx = rcidx, lhighestcomponentsequence = 0
  HEAD comp_seq
   lreplyorderssentencesize = 0, cidx = d2.seq
   IF ((component->list[cidx].sequence > lhighestcomponentsequence))
    lhighestcomponentsequence = component->list[cidx].sequence
   ENDIF
   IF ((component->list[cidx].active_ind=1))
    rcidx += 1
    IF (rcidx > lreplycomponentsize)
     lreplycomponentsize += 50, stat = alterlist(reply->phaselist[rpidx].complist,lreplycomponentsize
      )
    ENDIF
    dvalue = component->list[cidx].dcp_clin_sub_cat_cd
    IF (dvalue > 0.0)
     reply->phaselist[rpidx].complist[rcidx].dcp_clin_sub_cat_cd = dvalue, reply->phaselist[rpidx].
     complist[rcidx].dcp_clin_sub_cat_disp = trim(uar_get_code_display(dvalue)), reply->phaselist[
     rpidx].complist[rcidx].dcp_clin_sub_cat_mean = trim(uar_get_code_meaning(dvalue))
    ENDIF
    dvalue = component->list[cidx].catalog_cd
    IF (dvalue > 0.0)
     reply->phaselist[rpidx].complist[rcidx].catalog_cd = dvalue, reply->phaselist[rpidx].complist[
     rcidx].catalog_disp = trim(uar_get_code_display(dvalue)), reply->phaselist[rpidx].complist[rcidx
     ].catalog_mean = trim(uar_get_code_meaning(dvalue))
    ENDIF
    dvalue = component->list[cidx].catalog_type_cd
    IF (dvalue > 0.0)
     reply->phaselist[rpidx].complist[rcidx].catalog_type_cd = dvalue, reply->phaselist[rpidx].
     complist[rcidx].catalog_type_disp = trim(uar_get_code_display(dvalue)), reply->phaselist[rpidx].
     complist[rcidx].catalog_type_mean = trim(uar_get_code_meaning(dvalue))
    ENDIF
    dvalue = component->list[cidx].activity_type_cd
    IF (dvalue > 0.0)
     reply->phaselist[rpidx].complist[rcidx].activity_type_cd = dvalue, reply->phaselist[rpidx].
     complist[rcidx].activity_type_disp = trim(uar_get_code_display(dvalue)), reply->phaselist[rpidx]
     .complist[rcidx].activity_type_mean = trim(uar_get_code_meaning(dvalue))
    ENDIF
    reply->phaselist[rpidx].complist[rcidx].act_pw_comp_id = component->list[cidx].act_pw_comp_id,
    reply->phaselist[rpidx].complist[rcidx].dcp_clin_cat_cd = component->list[cidx].dcp_clin_cat_cd,
    reply->phaselist[rpidx].complist[rcidx].comp_status_cd = component->list[cidx].comp_status_cd,
    reply->phaselist[rpidx].complist[rcidx].comp_type_cd = component->list[cidx].comp_type_cd, reply
    ->phaselist[rpidx].complist[rcidx].sequence = component->list[cidx].sequence, reply->phaselist[
    rpidx].complist[rcidx].parent_entity_name = component->list[cidx].parent_entity_name,
    reply->phaselist[rpidx].complist[rcidx].parent_entity_id = component->list[cidx].parent_entity_id,
    reply->phaselist[rpidx].complist[rcidx].synonym_id = component->list[cidx].synonym_id, reply->
    phaselist[rpidx].complist[rcidx].mnemonic = component->list[cidx].mnemonic,
    reply->phaselist[rpidx].complist[rcidx].oe_format_id = component->list[cidx].oe_format_id, reply
    ->phaselist[rpidx].complist[rcidx].rx_mask = component->list[cidx].rx_mask, reply->phaselist[
    rpidx].complist[rcidx].linked_to_tf_ind = component->list[cidx].linked_to_tf_ind,
    reply->phaselist[rpidx].complist[rcidx].required_ind = component->list[cidx].required_ind, reply
    ->phaselist[rpidx].complist[rcidx].included_ind = component->list[cidx].included_ind, reply->
    phaselist[rpidx].complist[rcidx].activated_ind = component->list[cidx].activated_ind,
    reply->phaselist[rpidx].complist[rcidx].persistent_ind = component->list[cidx].persistent_ind,
    reply->phaselist[rpidx].complist[rcidx].comp_text_id = component->list[cidx].comp_text_id, reply
    ->phaselist[rpidx].complist[rcidx].comp_text = component->list[cidx].comp_text,
    reply->phaselist[rpidx].complist[rcidx].order_sentence_id = component->list[cidx].
    order_sentence_id, reply->phaselist[rpidx].complist[rcidx].updt_cnt = component->list[cidx].
    updt_cnt, reply->phaselist[rpidx].complist[rcidx].pathway_comp_id = component->list[cidx].
    pathway_comp_id,
    reply->phaselist[rpidx].complist[rcidx].offset_quantity = component->list[cidx].offset_quantity,
    reply->phaselist[rpidx].complist[rcidx].offset_unit_cd = component->list[cidx].offset_unit_cd,
    reply->phaselist[rpidx].complist[rcidx].duration_qty = component->list[cidx].duration_qty,
    reply->phaselist[rpidx].complist[rcidx].duration_unit_cd = component->list[cidx].duration_unit_cd,
    reply->phaselist[rpidx].complist[rcidx].outcome_catalog_id = component->list[cidx].
    outcome_catalog_id, reply->phaselist[rpidx].complist[rcidx].outcome_description = component->
    list[cidx].outcome_description,
    reply->phaselist[rpidx].complist[rcidx].outcome_expectation = component->list[cidx].
    outcome_expectation, reply->phaselist[rpidx].complist[rcidx].outcome_type_cd = component->list[
    cidx].outcome_type_cd, reply->phaselist[rpidx].complist[rcidx].outcome_status_cd = component->
    list[cidx].outcome_status_cd,
    reply->phaselist[rpidx].complist[rcidx].target_type_cd = component->list[cidx].target_type_cd,
    reply->phaselist[rpidx].complist[rcidx].expand_qty = component->list[cidx].expand_qty, reply->
    phaselist[rpidx].complist[rcidx].expand_unit_cd = component->list[cidx].expand_unit_cd,
    reply->phaselist[rpidx].complist[rcidx].outcome_start_dt_tm = component->list[cidx].
    outcome_start_dt_tm, reply->phaselist[rpidx].complist[rcidx].outcome_end_dt_tm = component->list[
    cidx].outcome_end_dt_tm, reply->phaselist[rpidx].complist[rcidx].outcome_updt_cnt = component->
    list[cidx].outcome_updt_cnt,
    reply->phaselist[rpidx].complist[rcidx].outcome_event_cd = component->list[cidx].outcome_event_cd,
    reply->phaselist[rpidx].complist[rcidx].time_zero_offset_qty = component->list[cidx].
    time_zero_offset_qty, reply->phaselist[rpidx].complist[rcidx].time_zero_mean = component->list[
    cidx].time_zero_mean,
    reply->phaselist[rpidx].complist[rcidx].time_zero_offset_unit_cd = component->list[cidx].
    time_zero_offset_unit_cd, reply->phaselist[rpidx].complist[rcidx].time_zero_active_ind =
    component->list[cidx].time_zero_active_ind, reply->phaselist[rpidx].complist[rcidx].task_assay_cd
     = component->list[cidx].task_assay_cd,
    reply->phaselist[rpidx].complist[rcidx].reference_task_id = component->list[cidx].
    reference_task_id, reply->phaselist[rpidx].complist[rcidx].orderable_type_flag = component->list[
    cidx].orderable_type_flag, reply->phaselist[rpidx].complist[rcidx].comp_label = component->list[
    cidx].comp_label,
    reply->phaselist[rpidx].complist[rcidx].result_type_cd = component->list[cidx].result_type_cd,
    reply->phaselist[rpidx].complist[rcidx].xml_order_detail = component->list[cidx].xml_order_detail,
    reply->phaselist[rpidx].complist[rcidx].long_blob_id = component->list[cidx].long_blob_id,
    reply->phaselist[rpidx].complist[rcidx].ref_prnt_ent_name = component->list[cidx].
    ref_prnt_ent_name, reply->phaselist[rpidx].complist[rcidx].ref_prnt_ent_id = component->list[cidx
    ].ref_prnt_ent_id, reply->phaselist[rpidx].complist[rcidx].subphase_display = component->list[
    cidx].subphase_display,
    reply->phaselist[rpidx].complist[rcidx].cross_phase_group_nbr = component->list[cidx].
    cross_phase_group_nbr, reply->phaselist[rpidx].complist[rcidx].cross_phase_group_ind = component
    ->list[cidx].cross_phase_group_ind, reply->phaselist[rpidx].complist[rcidx].chemo_ind = component
    ->list[cidx].chemo_ind,
    reply->phaselist[rpidx].complist[rcidx].chemo_related_ind = component->list[cidx].
    chemo_related_ind, reply->phaselist[rpidx].complist[rcidx].ocs_clin_cat_cd = component->list[cidx
    ].ocs_clin_cat_cd, reply->phaselist[rpidx].complist[rcidx].single_select_ind = component->list[
    cidx].single_select_ind,
    reply->phaselist[rpidx].complist[rcidx].hide_expectation_ind = component->list[cidx].
    hide_expectation_ind, reply->phaselist[rpidx].complist[rcidx].ref_text_reltn_id = component->
    list[cidx].ref_text_reltn_id, reply->phaselist[rpidx].complist[rcidx].hna_order_mnemonic =
    component->list[cidx].hna_order_mnemonic,
    reply->phaselist[rpidx].complist[rcidx].cki = component->list[cidx].cki, reply->phaselist[rpidx].
    complist[rcidx].ref_text_ind = component->list[cidx].ref_text_ind, reply->phaselist[rpidx].
    complist[rcidx].ref_text_mask = component->list[cidx].ref_text_mask,
    reply->phaselist[rpidx].complist[rcidx].outcome_start_tz = component->list[cidx].outcome_start_tz,
    reply->phaselist[rpidx].complist[rcidx].outcome_end_tz = component->list[cidx].outcome_end_tz,
    reply->phaselist[rpidx].complist[rcidx].high_alert_ind = component->list[cidx].high_alert_ind,
    reply->phaselist[rpidx].complist[rcidx].high_alert_required_ntfy_ind = component->list[cidx].
    high_alert_required_ntfy_ind, reply->phaselist[rpidx].complist[rcidx].high_alert_text = component
    ->list[cidx].high_alert_text, reply->phaselist[rpidx].complist[rcidx].facility_access_ind =
    component->list[cidx].facility_access_ind,
    reply->phaselist[rpidx].complist[rcidx].ref_active_ind = component->list[cidx].ref_active_ind,
    reply->phaselist[rpidx].complist[rcidx].dose_info_hist_blob_id = component->list[cidx].
    dose_info_hist_blob_id, reply->phaselist[rpidx].complist[rcidx].dose_info_hist_blob = component->
    list[cidx].dose_info_hist_blob,
    reply->phaselist[rpidx].complist[rcidx].xml_order_detail_blob = component->list[cidx].
    xml_order_detail_blob, reply->phaselist[rpidx].complist[rcidx].dose_info_hist_blob_text =
    component->list[cidx].dose_info_hist_blob_text, reply->phaselist[rpidx].complist[rcidx].
    missing_required_ind = component->list[cidx].missing_required_ind,
    reply->phaselist[rpidx].complist[rcidx].default_os_ind = component->list[cidx].default_os_ind,
    reply->phaselist[rpidx].complist[rcidx].updt_dt_tm = component->list[cidx].updt_dt_tm, reply->
    phaselist[rpidx].complist[rcidx].intermittent_ind = component->list[cidx].intermittent_ind,
    reply->phaselist[rpidx].complist[rcidx].start_estimated_ind = component->list[cidx].
    start_estimated_ind, reply->phaselist[rpidx].complist[rcidx].end_estimated_ind = component->list[
    cidx].end_estimated_ind, reply->phaselist[rpidx].complist[rcidx].reject_protocol_review_ind =
    component->list[cidx].reject_protocol_review_ind,
    reply->phaselist[rpidx].complist[rcidx].min_tolerance_interval = component->list[cidx].
    min_tolerance_interval, reply->phaselist[rpidx].complist[rcidx].min_tolerance_interval_unit_cd =
    component->list[cidx].min_tolerance_interval_unit_cd, reply->phaselist[rpidx].complist[rcidx].
    act_pw_comp_group_nbr = component->list[cidx].act_pw_comp_group_nbr,
    reply->phaselist[rpidx].complist[rcidx].display_format_xml =
    IF (trim(component->list[cidx].display_format_xml) != null) trim(component->list[cidx].
      display_format_xml)
    ELSE "<xml />"
    ENDIF
    , reply->phaselist[rpidx].complist[rcidx].unlink_start_dt_tm_ind = component->list[cidx].
    unlink_start_dt_tm_ind, reply->phaselist[rpidx].complist[rcidx].lock_target_dose_flag = component
    ->list[cidx].lock_target_dose_flag,
    CALL marshalandvalidatecomponentattributesintoreply(rpidx,rcidx,cidx), lreplyorderssentencesize
     = size(component->list[cidx].ordsentlist,5)
    IF (lreplyorderssentencesize > 0)
     stat = alterlist(reply->phaselist[rpidx].complist[rcidx].ordsentlist,lreplyorderssentencesize)
    ENDIF
    FOR (rosidx = 1 TO lreplyorderssentencesize)
      reply->phaselist[rpidx].complist[rcidx].ordsentlist[rosidx].order_sentence_seq = component->
      list[cidx].ordsentlist[rosidx].order_sentence_seq, reply->phaselist[rpidx].complist[rcidx].
      ordsentlist[rosidx].order_sentence_id = component->list[cidx].ordsentlist[rosidx].
      order_sentence_id, reply->phaselist[rpidx].complist[rcidx].ordsentlist[rosidx].
      order_sentence_display_line = trim(component->list[cidx].ordsentlist[rosidx].
       order_sentence_display_line),
      reply->phaselist[rpidx].complist[rcidx].ordsentlist[rosidx].iv_comp_syn_id = component->list[
      cidx].ordsentlist[rosidx].iv_comp_syn_id, reply->phaselist[rpidx].complist[rcidx].ordsentlist[
      rosidx].ord_comment_long_text_id = component->list[cidx].ordsentlist[rosidx].
      ord_comment_long_text_id, reply->phaselist[rpidx].complist[rcidx].ordsentlist[rosidx].
      ord_comment_long_text = component->list[cidx].ordsentlist[rosidx].ord_comment_long_text,
      reply->phaselist[rpidx].complist[rcidx].ordsentlist[rosidx].rx_type_mean = component->list[cidx
      ].ordsentlist[rosidx].rx_type_mean, reply->phaselist[rpidx].complist[rcidx].ordsentlist[rosidx]
      .normalized_dose_unit_ind = component->list[cidx].ordsentlist[rosidx].normalized_dose_unit_ind,
      reply->phaselist[rpidx].complist[rcidx].ordsentlist[rosidx].missing_required_ind = component->
      list[cidx].ordsentlist[rosidx].missing_required_ind,
      reply->phaselist[rpidx].complist[rcidx].ordsentlist[rosidx].applicable_to_patient_ind =
      component->list[cidx].ordsentlist[rosidx].applicable_to_patient_ind, reply->phaselist[rpidx].
      complist[rcidx].ordsentlist[rosidx].order_sentence_filter_display = trim(component->list[cidx].
       ordsentlist[rosidx].order_sentence_filter_display)
    ENDFOR
    IF ((component->list[cidx].exist_ind=0))
     IF (((cnvtmin2(cnvtdate(component->list[cidx].activated_dt_tm),cnvttime(component->list[cidx].
       activated_dt_tm))+ stale_in_min) > cur_date_in_min))
      reply->phaselist[rpidx].complist[rcidx].processing_ind = 1
     ELSE
      reply->phaselist[rpidx].complist[rcidx].comp_status_cd = failed_create
     ENDIF
    ENDIF
    dvalue = reply->phaselist[rpidx].complist[rcidx].comp_status_cd
    IF ((reply->phaselist[rpidx].start_offset_ind=0)
     AND (reply->phaselist[rpidx].complist[rcidx].offset_quantity > 0))
     reply->phaselist[rpidx].start_offset_ind = 1
    ENDIF
    IF ((reply->phaselist[rpidx].chemo_ind=0)
     AND (reply->phaselist[rpidx].complist[rcidx].chemo_ind=1))
     reply->phaselist[rpidx].chemo_ind = 1
    ENDIF
    IF ((reply->phaselist[rpidx].chemo_related_ind=0)
     AND (reply->phaselist[rpidx].complist[rcidx].chemo_related_ind=1))
     reply->phaselist[rpidx].chemo_related_ind = 1
    ENDIF
    IF ((reply->phaselist[rpidx].high_alert_ind=0)
     AND (reply->phaselist[rpidx].complist[rcidx].high_alert_ind=1))
     reply->phaselist[rpidx].high_alert_ind = 1
    ENDIF
    IF ((reply->phaselist[rpidx].high_alert_required_ntfy_ind=0)
     AND (reply->phaselist[rpidx].complist[rcidx].high_alert_required_ntfy_ind=1))
     reply->phaselist[rpidx].high_alert_required_ntfy_ind = 1
    ENDIF
    IF ((reply->phaselist[rpidx].time_zero_ind=0)
     AND (reply->phaselist[rpidx].complist[rcidx].time_zero_active_ind=1))
     reply->phaselist[rpidx].time_zero_ind = 1
    ENDIF
   ENDIF
  DETAIL
   ndummy = 0
  FOOT  comp_seq
   ndummy = 0
  FOOT  sort_cd
   dummy = 0, ltotalnumberofcomponents += lhighestcomponentsequence
  FOOT  pathway_id
   IF (rcidx != lreplycomponentsize)
    stat = alterlist(reply->phaselist[rpidx].complist,rcidx)
   ENDIF
   CALL settotalnumberofcomponentsinreply(rpidx,ltotalnumberofcomponents)
  FOOT REPORT
   ndummy = 0
  WITH nocounter, outerjoin = d1
 ;end select
 IF (debug=1)
  CALL stoptimer("17 - Fill reply")
 ENDIF
 IF (debug=1)
  CALL starttimer(ndummy)
 ENDIF
 SET lstart = 1
 SET lbatchsize = batch_size_phase_list
 SET lsize = lreplyphasesize
 SET lloopcount = ceil((cnvtreal(lsize)/ lbatchsize))
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(lloopcount)),
   act_pw_comp_g apcg
  PLAN (d1
   WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ lbatchsize))))
   JOIN (apcg
   WHERE expand(num,lstart,(lstart+ (lbatchsize - 1)),apcg.pathway_id,request->phaselist[num].
    pathwayid))
  ORDER BY apcg.pathway_id, apcg.act_pw_comp_g_id, apcg.pw_comp_seq
  HEAD REPORT
   idx = 0
  HEAD apcg.pathway_id
   gcnt = 0, idx = locateval(idx,1,lsize,apcg.pathway_id,reply->phaselist[idx].pathway_id)
  HEAD apcg.act_pw_comp_g_id
   ccnt = 0, gcnt += 1
   IF (gcnt > size(reply->phaselist[idx].compgrouplist,5))
    stat = alterlist(reply->phaselist[idx].compgrouplist,(gcnt+ 10))
   ENDIF
   reply->phaselist[idx].compgrouplist[gcnt].act_pw_comp_g_id = apcg.act_pw_comp_g_id, reply->
   phaselist[idx].compgrouplist[gcnt].type_mean = apcg.type_mean, reply->phaselist[idx].
   compgrouplist[gcnt].description = trim(apcg.description),
   reply->phaselist[idx].compgrouplist[gcnt].linking_rule_flag = apcg.linking_rule_flag, reply->
   phaselist[idx].compgrouplist[gcnt].linking_rule_quantity = apcg.linking_rule_quantity, reply->
   phaselist[idx].compgrouplist[gcnt].override_reason_flag = apcg.override_reason_flag
  DETAIL
   ccnt += 1
   IF (ccnt > size(reply->phaselist[idx].compgrouplist[gcnt].memberlist,5))
    stat = alterlist(reply->phaselist[idx].compgrouplist[gcnt].memberlist,(ccnt+ 10))
   ENDIF
   reply->phaselist[idx].compgrouplist[gcnt].memberlist[ccnt].act_pw_comp_id = apcg.act_pw_comp_id,
   reply->phaselist[idx].compgrouplist[gcnt].memberlist[ccnt].pw_comp_seq = apcg.pw_comp_seq, reply->
   phaselist[idx].compgrouplist[gcnt].memberlist[ccnt].included_ind = apcg.included_ind,
   reply->phaselist[idx].compgrouplist[gcnt].memberlist[ccnt].updt_cnt = apcg.updt_cnt, reply->
   phaselist[idx].compgrouplist[gcnt].memberlist[ccnt].anchor_component_ind = apcg
   .anchor_component_ind
  FOOT  apcg.act_pw_comp_g_id
   IF (ccnt > 0)
    stat = alterlist(reply->phaselist[idx].compgrouplist[gcnt].memberlist,ccnt)
   ENDIF
  FOOT  apcg.pathway_id
   IF (gcnt > 0)
    stat = alterlist(reply->phaselist[idx].compgrouplist,gcnt)
   ENDIF
  FOOT REPORT
   cnt = 0
  WITH nocounter
 ;end select
 IF (debug=1)
  CALL stoptimer("18 - Load component groups")
 ENDIF
 SET stat = alterlist(reply->phaselist,rpidx)
 IF (size(reply->phaselist,5) < 1)
  SET cstatus = "Z"
 ENDIF
 SUBROUTINE (starttimer(dummy=i2) =null)
   IF (debug=1)
    SET starttime = cnvtdatetime(sysdate)
   ENDIF
 END ;Subroutine
 SUBROUTINE (stoptimer(sdisplay=vc) =null)
   IF (debug=1)
    SET stoptime = cnvtdatetime(sysdate)
    SET dtimeinseconds = datetimediff(cnvtdatetime(sysdate),starttime,5)
    SET dtotaltimeinseconds += dtimeinseconds
    IF (sdisplay > " ")
     CALL echo("'*****************************************************************'")
     CALL echo(build("'",sdisplay," = ",dtimeinseconds,"'"))
     CALL echo("'-----------------------------------------------------------------'")
     CALL echo(build("'","Total time = ",dtotaltimeinseconds,"'"))
     CALL echo("'*****************************************************************'")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (marshalandvalidatecomponentattributesintoreply(lreplyphaseindex=i4,lreplycomponentindex=
  i4,lcomponentindex=i4) =null WITH protect)
   IF (validate(reply->phaselist[lreplyphaseindex].complist[lreplycomponentindex].pathway_uuid)=1)
    SET reply->phaselist[lreplyphaseindex].complist[lreplycomponentindex].pathway_uuid = trim(
     component->list[lcomponentindex].pathway_uuid)
   ENDIF
   IF (validate(reply->phaselist[lreplyphaseindex].complist[lreplycomponentindex].
    originating_encntr_id)=1)
    SET reply->phaselist[lreplyphaseindex].complist[lreplycomponentindex].originating_encntr_id =
    component->list[lcomponentindex].originating_encntr_id
   ENDIF
   IF (validate(reply->phaselist[lreplyphaseindex].complist[lreplycomponentindex].
    discontinue_type_flag)=1)
    SET reply->phaselist[lreplyphaseindex].complist[lreplycomponentindex].discontinue_type_flag =
    component->list[lcomponentindex].discontinue_type_flag
   ENDIF
 END ;Subroutine
 SUBROUTINE (settotalnumberofcomponentsinreply(lreplyphaseindex=i4,ltotalnumberofcomponents=i4) =null
   WITH protect)
   IF (validate(reply->phaselist[lreplyphaseindex].total_number_of_components)=1)
    SET reply->phaselist[lreplyphaseindex].total_number_of_components = ltotalnumberofcomponents
   ENDIF
 END ;Subroutine
 SUBROUTINE resetdefaultosindicator(iagefilterind,iweightfilterind)
   IF (iagefilterind > 0)
    IF ((patients->patients_size > 0)
     AND (patients->patients[patients->patients_size].patient_criteria.birth_dt_tm=null))
     RETURN(1)
    ENDIF
   ENDIF
   IF (iweightfilterind > 0)
    IF ((patients->patients_size > 0)
     AND (((patients->patients[patients->patients_size].patient_criteria.weight=0.0)) OR ((patients->
    patients[patients->patients_size].patient_criteria.weight_unit_cd=0.0))) )
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
#exit_script
 FREE RECORD patients
 FREE RECORD component
 FREE RECORD query_long_blob
 FREE RECORD query_long_text
 FREE RECORD query_order_component
 FREE RECORD query_order_activity
 FREE RECORD query_order_reference
 FREE RECORD query_all_order_reference
 FREE RECORD query_outcome_activity
 FREE RECORD query_outcome_reference
 FREE RECORD query_sub_phase_activity
 FREE RECORD query_sub_phase_reference
 FREE RECORD query_component_reference
 FREE RECORD filter_order_sentences
 SET reply->status_data.status = cstatus
 IF (debug=1)
  CALL echorecord(reply)
 ENDIF
 FREE RECORD script_test
 DECLARE last_mod = c3 WITH public, constant("039")
END GO
