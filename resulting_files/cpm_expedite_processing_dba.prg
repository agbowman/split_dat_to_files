CREATE PROGRAM cpm_expedite_processing:dba
 RECORD reply(
   1 qual[1]
     2 chart_request_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD encntr(
   1 organization_id = f8
   1 cur_loc_facility_cd = f8
   1 cur_loc_building_cd = f8
   1 cur_loc_nurse_unit_cd = f8
   1 cur_loc_room_cd = f8
   1 cur_loc_bed_cd = f8
   1 cur_loc_temp_cd = f8
   1 ord_loc_facility_cd = f8
   1 ord_loc_building_cd = f8
   1 ord_loc_nurse_unit_cd = f8
   1 ord_loc_room_cd = f8
   1 ord_loc_bed_cd = f8
   1 pat_loc_facility_cd = f8
   1 pat_loc_building_cd = f8
   1 pat_loc_nurse_unit_cd = f8
   1 pat_loc_room_cd = f8
   1 pat_loc_bed_cd = f8
 )
 RECORD tree(
   1 qual[*]
     2 code_value = f8
     2 sr_tree_lvl = i4
     2 lowest_child_cd = f8
 )
 RECORD expedite(
   1 qual[*]
     2 duplicate_ind = i2
     2 dup_format_ind = i2
     2 expedite_trigger_id = f8
     2 trigger_name = vc
     2 precedence_seq = i4
     2 expedite_params_id = f8
     2 params_name = vc
     2 coded_resp_ind = i2
     2 chart_content_flag = i2
     2 order_complete_flag = i2
     2 chart_format_id = f8
     2 scope_flag = i2
     2 output_flag = i2
     2 output_dest_cd = f8
     2 output_device_cd = f8
     2 device_name = vc
     2 output_dest_name = vc
     2 service_resource_cd = f8
     2 copy_ind = i2
     2 manual_expedite_ind = i2
     2 manual_provider_id = f8
     2 manual_prov_role_cd = f8
     2 event_ind = i2
     2 expedite_manual_id = f8
     2 rrd_deliver_dt_tm = dq8
     2 rrd_phone_suffix = c30
     2 begin_dt_tm = dq8
     2 end_dt_tm = dq8
     2 date_range_ind = i2
     2 event_id_list[*]
       3 em_event_id = f8
       3 event_id = f8
       3 result_status_cd = f8
 )
 RECORD copy(
   1 qual[*]
     2 duplicate_ind = i2
     2 dup_format_ind = i2
     2 trigger_name = vc
     2 expedite_params_id = f8
     2 params_name = vc
     2 chart_format_id = f8
     2 chart_content_flag = i2
     2 order_complete_flag = i2
     2 encntr_prsnl_r_cd = f8
     2 provider_id = f8
     2 output_dest_cd = f8
     2 output_device_cd = f8
     2 device_name = vc
     2 output_dest_name = vc
     2 order_level_ind = i2
 )
#start_init
 SET trace = errorclear
 SET trace = errorclearcom
 SET order_total = size(request->orders,5)
 SET order_provider_id = 0.0
 DECLARE admitdoc_type_cd = f8 WITH noconstant(0.0)
 DECLARE orderdoc_type_cd = f8 WITH noconstant(0.0)
 SET assay_total = 0
 SET assay_cnt = 0
 SET cur_total = 0
 SET exp_cnt = 0
 SET e_cnt = 0
 SET copy_cnt = 0
 SET copy_ind = 0
 SET cr_cnt = 0
 SET tree_cnt = 0
 SET child_cd = 0
 SET lowest_child_cd = 0
 SET sr_tree_lvl = 0
 SET sr_lvl = 0
 SET new_sr_ind = 0
 SET idx = 0
 SET idx2 = 0
 SET idx3 = 0
 SET location_cd = 0
 SET child_cd = 0
 SET meaning_cdf = fillstring(12," ")
 SET diff_loc_ind = 0
 SET cur_loc_xref_ind = 0
 SET pat_loc_xref_ind = 0
 SET ord_loc_xref_ind = 0
 SET org_xref_ind = 0
 SET sr_xref_ind = 0
 SET provider_xref_ind = 0
 SET assigned_ind = 0
 SET cur_loc_temp_xref_ind = 0
 SET new_request_ind = 0
 SET error_ind = 0
 SET acc_logged_ind = 0
 SET et_where = fillstring(1000," ")
 SET loc_output_dest_cd = 0
 SET loc_output_device_cd = 0
 SET loc_device_name = fillstring(20," ")
 SET loc_output_dest_name = fillstring(20," ")
 SET loc_temp_output_dest_cd = 0
 SET loc_temp_output_device_cd = 0
 SET loc_temp_device_name = fillstring(20," ")
 SET loc_temp_output_dest_name = fillstring(20," ")
 SET sr_output_dest_cd = 0
 SET sr_output_device_cd = 0
 SET sr_output_dest_name = fillstring(20," ")
 SET sr_output_device_name = fillstring(20," ")
 SET pat_output_dest_cd = 0
 SET pat_output_device_cd = 0
 SET pat_device_name = fillstring(20," ")
 SET pat_output_dest_name = fillstring(20," ")
 SET ord_output_dest_cd = 0
 SET ord_output_device_cd = 0
 SET ord_device_name = fillstring(20," ")
 SET ord_output_dest_name = fillstring(20," ")
 SET provider_output_dest_cd = 0
 SET provider_output_device_cd = 0
 SET provider_output_device_name = fillstring(20," ")
 SET provider_output_dest_name = fillstring(20," ")
 SET org_output_dest_cd = 0
 SET org_output_device_cd = 0
 SET org_output_dest_name = fillstring(20," ")
 SET org_output_device_name = fillstring(20," ")
 DECLARE action_type_cd = f8 WITH noconstant(0.0)
 DECLARE consult_doc_cd = f8 WITH noconstant(0.0)
 SET params_id = 0.0
 SET add_cons = 0
 SET sr_dest_found_ind = 0
 SET coded_resp_ind = 0
 SET num_coded_resp = 0
 SET max_coded_resp = 0
 SET cur_coded_resp = 0
 SET file_name = concat("cer_temp:expedites",format(curdate,"MMDD;;d"),".log")
 SET error_msg = fillstring(255," ")
 SET msg_size = 0
 SET error_check = error(error_msg,1)
 SET dup_log = fillstring(10," ")
 SET on_ind = 0
 SET log_level = 0
 SET log_nbr = 0
 SET log_buffer[500] = fillstring(100," ")
 SET discharged_status = 0
 DECLARE complete_order_ind = i2 WITH noconstant(0)
 DECLARE ast_ind = c2
 SET stat = uar_get_meaning_by_codeset(333,"CONSULTDOC",1,consult_doc_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"ORDER",1,action_type_cd)
 SET stat = uar_get_meaning_by_codeset(333,"ORDERDOC",1,orderdoc_type_cd)
 SET powerform_processing_ind = 0
 DECLARE coded_response_cd_ind = i2
#end_init
#start_check_processing
 SELECT INTO "nl:"
  e.on_ind
  FROM expedite_processing e
  HEAD REPORT
   on_ind = e.on_ind, log_level = e.log_level
  WITH nocounter
 ;end select
 IF (on_ind=0)
  GO TO expedites_off
 ENDIF
#end_check_processing
 IF (log_level >= 2)
  EXECUTE FROM start_log_accession TO end_log_accession
 ENDIF
 GO TO start_check_status
#start_log_accession
 SET acc_logged_ind = 1
 SET log_nbr = (log_nbr+ 1)
 SET log_buffer[log_nbr] = fillstring(100,"*")
 SET log_nbr = (log_nbr+ 1)
 SET log_buffer[log_nbr] = concat("Expedite Processing called by ",request->calling_program)
 SET log_nbr = (log_nbr+ 1)
 SET log_buffer[log_nbr] = format(cnvtdatetime(curdate,curtime3),"DD-MMM-YYYY HH:MM:SS;;D")
 SET log_nbr = (log_nbr+ 1)
 SET log_buffer[log_nbr] = concat("person_id: ",cnvtstring(request->person_id))
 SET log_nbr = (log_nbr+ 1)
 SET log_buffer[log_nbr] = concat("encntr_id: ",cnvtstring(request->encntr_id))
 SET log_nbr = (log_nbr+ 1)
 SET log_buffer[log_nbr] = concat("accession: ",request->accession)
#end_log_accession
#start_check_status
 IF ((request->status="F")
  AND log_level >= 1)
  SET error_ind = 1
  IF (log_level=1
   AND acc_logged_ind=0)
   EXECUTE FROM start_log_accession TO end_log_accession
  ENDIF
  SET log_nbr = (log_nbr+ 1)
  SET log_buffer[log_nbr] = "Incoming request failure - no expedite processed"
  GO TO exit_script
 ELSEIF ((request->status="F"))
  GO TO exit_script
 ENDIF
#end_check_status
#start_check_pf
 IF (order_total > 0)
  IF ((request->orders[1].reference_task_id > 0))
   SET powerform_processing_ind = 1
  ENDIF
 ENDIF
#end_check_pf
#start_find_max
 SET assay_total = 0
 FOR (idx = 1 TO order_total)
  SET cur_total = size(request->orders[idx].assays,5)
  IF (cur_total > assay_total)
   SET assay_total = cur_total
  ENDIF
 ENDFOR
 IF (log_level >= 2)
  FOR (idx = 1 TO order_total)
    IF ((request->orders[idx].order_complete_ind=0))
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat("Order not complete (order_id: ",cnvtstring(request->orders[idx
       ].order_id),")")
    ENDIF
  ENDFOR
 ENDIF
#end_find_max
#start_find_coded_response_cds
 FOR (idx = 1 TO order_total)
  SET assay_cnt = size(request->orders[idx].assays,5)
  FOR (idx2 = 1 TO assay_cnt)
   SET coded_resp_cnt = size(request->orders[idx].assays[idx2].coded_resp,5)
   FOR (idx3 = 1 TO coded_resp_cnt)
     IF ((request->orders[idx].assays[idx2].coded_resp[idx3].coded_response_cd > 0))
      SET coded_response_cd_ind = 1
      GO TO start_find_ord_loc
     ENDIF
   ENDFOR
  ENDFOR
 ENDFOR
#end_find_coded_response_cds
#start_find_ord_loc
 SELECT INTO "nl:"
  oa.order_loc_cd
  FROM order_action oa
  PLAN (oa
   WHERE (oa.order_id=request->orders[1].order_id)
    AND oa.order_locn_cd > 0.0)
  HEAD REPORT
   location_cd = oa.order_locn_cd
  WITH nocounter
 ;end select
 SET tree_cnt = 1
 SET stat = alterlist(tree->qual,tree_cnt)
 SET child_cd = location_cd
 SET tree->qual[1].code_value = child_cd
 EXECUTE exp_build_loc_tree
 FOR (x = 1 TO tree_cnt)
  SELECT INTO "nl:"
   cv.cdf_meaning
   FROM code_value cv
   WHERE cv.code_set=220
    AND (cv.code_value=tree->qual[x].code_value)
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   DETAIL
    meaning_cdf = cv.cdf_meaning
   WITH nocounter
  ;end select
  CASE (meaning_cdf)
   OF "FACILITY":
    SET encntr->ord_loc_facility_cd = tree->qual[x].code_value
   OF "BUILDING":
    SET encntr->ord_loc_building_cd = tree->qual[x].code_value
   OF "NURSEUNIT":
    SET encntr->ord_loc_nurse_unit_cd = tree->qual[x].code_value
   OF "AMBULATORY":
    SET encntr->ord_loc_nurse_unit_cd = tree->qual[x].code_value
   OF "APPTLOC":
    SET encntr->ord_loc_nurse_unit_cd = tree->qual[x].code_value
   OF "ROOM":
    SET encntr->ord_loc_room_cd = tree->qual[x].code_value
   OF "CHECKOUT":
    SET encntr->ord_loc_room_cd = tree->qual[x].code_value
   OF "WAITROOM":
    SET encntr->ord_loc_room_cd = tree->qual[x].code_value
   OF "BED":
    SET encntr->ord_loc_bed_cd = tree->qual[x].code_value
  ENDCASE
 ENDFOR
#end_find_ord_loc
#start_find_pat_loc
 SELECT INTO "nl:"
  o.orig_order_dt_tm";;q", elh.beg_effective_dt_tm";;q", elh.end_effective_dt_tm";;q"
  FROM orders o,
   encntr_loc_hist elh
  PLAN (o
   WHERE (o.order_id=request->orders[1].order_id))
   JOIN (elh
   WHERE (elh.encntr_id=request->encntr_id)
    AND elh.active_ind=1
    AND o.orig_order_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
  HEAD REPORT
   encntr->pat_loc_facility_cd = elh.loc_facility_cd, encntr->pat_loc_building_cd = elh
   .loc_building_cd, encntr->pat_loc_nurse_unit_cd = elh.loc_nurse_unit_cd,
   encntr->pat_loc_room_cd = elh.loc_room_cd, encntr->pat_loc_bed_cd = elh.loc_bed_cd
  WITH nocounter
 ;end select
#end_find_pat_loc
#start_find_cur_loc
 SELECT INTO "nl:"
  e.organization_id
  FROM encounter e
  WHERE (e.encntr_id=request->encntr_id)
  HEAD REPORT
   encntr->organization_id = e.organization_id, encntr->cur_loc_facility_cd = e.loc_facility_cd,
   encntr->cur_loc_building_cd = e.loc_building_cd,
   encntr->cur_loc_nurse_unit_cd = e.loc_nurse_unit_cd, encntr->cur_loc_room_cd = e.loc_room_cd,
   encntr->cur_loc_bed_cd = e.loc_bed_cd,
   encntr->cur_loc_temp_cd = e.loc_temp_cd
   IF (e.disch_dt_tm=null)
    discharged_status = 0
   ELSE
    discharged_status = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (log_level >= 2)
  SET log_nbr = (log_nbr+ 1)
  IF (discharged_status=0)
   SET log_buffer[log_nbr] = "Patient is non-discharged"
  ELSE
   SET log_buffer[log_nbr] = "Patient is discharged"
  ENDIF
 ENDIF
#end_find_cur_loc
#start_build_sr_tree
 SET stat = alterlist(tree->qual,0)
 SET tree_cnt = 0
 FOR (idx = 1 TO order_total)
  SET assay_cnt = size(request->orders[idx].assays,5)
  FOR (idx2 = 1 TO assay_cnt)
    SET new_sr_ind = 1
    FOR (idx3 = 1 TO tree_cnt)
      IF ((request->orders[idx].assays[idx2].service_resource_cd=tree->qual[idx3].lowest_child_cd))
       SET new_sr_ind = 0
      ENDIF
    ENDFOR
    IF (new_sr_ind=1)
     SET sr_tree_lvl = 1
     SET tree_cnt = (tree_cnt+ 1)
     SET stat = alterlist(tree->qual,tree_cnt)
     SET child_cd = request->orders[idx].assays[idx2].service_resource_cd
     SET lowest_child_cd = child_cd
     SET tree->qual[tree_cnt].code_value = child_cd
     SET tree->qual[tree_cnt].sr_tree_lvl = sr_tree_lvl
     SET tree->qual[tree_cnt].lowest_child_cd = lowest_child_cd
     EXECUTE exp_build_sr_tree
    ENDIF
  ENDFOR
 ENDFOR
#end_build_sr_tree
#start_et_where
 SET et_where = concat(" ((et.location_cd in",
  " (0, encntr->cur_loc_facility_cd, encntr->cur_loc_building_cd,",
  "  encntr->cur_loc_nurse_unit_cd, encntr->cur_loc_room_cd,","  encntr->cur_loc_bed_cd) and",
  " et.location_context_flag in (0,1,6,8,9))",
  " OR (et.location_cd in"," (0, encntr->pat_loc_facility_cd, encntr->pat_loc_building_cd,",
  "  encntr->pat_loc_nurse_unit_cd, encntr->pat_loc_room_cd, ","  encntr->pat_loc_bed_cd) and",
  " et.location_context_flag in (0,2,7,8,9))",
  " OR (et.location_cd in"," (0, encntr->ord_loc_facility_cd, encntr->ord_loc_building_cd,",
  " encntr->ord_loc_nurse_unit_cd, encntr->ord_loc_room_cd, "," encntr->ord_loc_bed_cd) and",
  " et.location_context_flag in (0,3,6,7,9)))")
 FOR (idx = 1 TO order_total)
   IF ((request->orders[idx].order_complete_ind=1))
    SET complete_order_ind = 1
    SET idx = (order_total+ 1)
   ENDIF
 ENDFOR
 IF (complete_order_ind=0)
  SET et_where = concat(trim(et_where),"and et.order_complete_flag = 0")
 ENDIF
#end_et_where
#start_find_provider
 SELECT INTO "nl:"
  oa.order_provider_id
  FROM order_action oa
  WHERE (oa.order_id=request->orders[1].order_id)
   AND oa.action_sequence=1
  HEAD REPORT
   order_provider_id = oa.order_provider_id
  WITH nocounter
 ;end select
 SET et_where = concat(trim(et_where),
  " and (et.provider_id = 0 or et.provider_id = order_provider_id)")
#end_find_provider
 CALL echorecord(request)
 CALL echorecord(encntr)
 CALL echorecord(tree)
 CALL echorecord(expedite)
#start_triggers
 SELECT INTO "nl:"
  epr.precedence_seq, ep.chart_format_id, ep.output_flag,
  ep.name, et.name_key
  FROM expedite_trigger et,
   expedite_params_r epr,
   expedite_params ep,
   (dummyt d1  WITH seq = value(order_total)),
   (dummyt d2  WITH seq = value(assay_total)),
   (dummyt d3  WITH seq = value(tree_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(request->orders[d1.seq].assays,5))
   JOIN (d3)
   JOIN (et
   WHERE ((et.organization_id=0) OR ((et.organization_id=encntr->organization_id)))
    AND parser(et_where)
    AND ((et.report_priority_cd=0) OR ((et.report_priority_cd=request->orders[d1.seq].assays[d2.seq].
   report_priority_cd)))
    AND ((et.result_range_cd=0) OR ((et.result_range_cd=request->orders[d1.seq].assays[d2.seq].
   result_range_cd)))
    AND ((et.result_status_cd=0) OR ((et.result_status_cd=request->orders[d1.seq].assays[d2.seq].
   result_status_cd)))
    AND ((et.result_cd=0) OR ((et.result_cd=request->orders[d1.seq].assays[d2.seq].result_cd)))
    AND ((et.result_nbr=0) OR ((et.result_nbr >= request->orders[d1.seq].assays[d2.seq].result_nbr)
   ))
    AND ((et.report_processing_cd=0) OR ((et.report_processing_cd=request->orders[d1.seq].assays[d2
   .seq].report_processing_cd)))
    AND ((et.report_processing_nbr=0) OR ((et.report_processing_nbr >= request->orders[d1.seq].
   assays[d2.seq].report_processing_nbr)))
    AND ((et.service_resource_cd=0) OR ((et.service_resource_cd=tree->qual[d3.seq].code_value)))
    AND ((et.catalog_type_cd=0) OR ((et.catalog_type_cd=request->orders[d1.seq].catalog_type_cd)))
    AND ((et.activity_type_cd=0) OR ((et.activity_type_cd=request->orders[d1.seq].activity_type_cd)
   ))
    AND ((et.catalog_cd=0) OR ((et.catalog_cd=request->orders[d1.seq].catalog_cd)))
    AND ((et.task_assay_cd=0) OR ((et.task_assay_cd=request->orders[d1.seq].assays[d2.seq].
   task_assay_cd)))
    AND et.active_ind=1
    AND ((et.discharged_flag=0) OR (((et.discharged_flag=1
    AND discharged_status=0) OR (et.discharged_flag=2
    AND discharged_status=1)) ))
    AND ((et.mic_ver_flag=0
    AND et.mic_cor_flag=0
    AND et.mic_com_flag=0
    AND et.mic_after_com_flag=0) OR (((et.mic_ver_flag=1
    AND (request->orders[d1.seq].assays[d2.seq].mic_ver_ind=1)) OR (((et.mic_cor_flag=1
    AND (request->orders[d1.seq].assays[d2.seq].mic_cor_ind=1)) OR (((et.mic_com_flag=1
    AND (request->orders[d1.seq].assays[d2.seq].mic_com_ind=1)) OR (et.mic_after_com_flag=1
    AND (request->orders[d1.seq].assays[d2.seq].mic_after_com_ind=1))) )) )) ))
    AND ((et.reference_task_id=0) OR ((et.reference_task_id=request->orders[d1.seq].reference_task_id
   ))) )
   JOIN (epr
   WHERE epr.expedite_trigger_id=et.expedite_trigger_id)
   JOIN (ep
   WHERE ep.expedite_params_id=epr.expedite_params_id)
  ORDER BY epr.precedence_seq DESC, et.name_key
  HEAD REPORT
   exp_cnt = 0, cur_loc_xref_ind = 0, pat_loc_xref_ind = 0,
   ord_loc_xref_ind = 0, org_xref_ind = 0, sr_xref_ind = 0,
   assigned_ind = 0, cur_loc_temp_xref_ind = 0, provider_xref_ind = 0,
   dup_ind = 0, copy_ind = 0, coded_resp_ind = 0
  HEAD et.name_key
   IF (et.coded_resp_ind=1)
    coded_resp_ind = 1
   ELSE
    exp_cnt = (exp_cnt+ 1), stat = alterlist(expedite->qual,exp_cnt), expedite->qual[exp_cnt].
    duplicate_ind = 0,
    expedite->qual[exp_cnt].dup_format_ind = 0, expedite->qual[exp_cnt].expedite_trigger_id = et
    .expedite_trigger_id, expedite->qual[exp_cnt].trigger_name = et.name,
    expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq, expedite->qual[exp_cnt].
    expedite_params_id = ep.expedite_params_id, expedite->qual[exp_cnt].params_name = ep.name,
    expedite->qual[exp_cnt].coded_resp_ind = et.coded_resp_ind, expedite->qual[exp_cnt].
    chart_content_flag = ep.chart_content_flag, expedite->qual[exp_cnt].order_complete_flag = et
    .order_complete_flag,
    expedite->qual[exp_cnt].chart_format_id = ep.chart_format_id, expedite->qual[exp_cnt].output_flag
     = ep.output_flag, expedite->qual[exp_cnt].output_dest_cd = ep.output_dest_cd,
    expedite->qual[exp_cnt].output_device_cd = ep.output_device_cd, expedite->qual[exp_cnt].
    service_resource_cd = tree->qual[d3.seq].lowest_child_cd, expedite->qual[exp_cnt].copy_ind = ep
    .copy_ind
    IF (ep.copy_ind=1)
     copy_ind = 1
    ENDIF
    CASE (ep.output_flag)
     OF 0:
      assigned_ind = 1
     OF 1:
      cur_loc_xref_ind = 1,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=ep.output_flag)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
     OF 2:
      pat_loc_xref_ind = 1,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=ep.output_flag)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
     OF 3:
      cur_loc_xref_ind = 1,pat_loc_xref_ind = 1,ord_loc_xref_ind = 1,
      exp_cnt = (exp_cnt+ 1),stat = alterlist(expedite->qual,exp_cnt),expedite->qual[exp_cnt].
      duplicate_ind = 0,
      expedite->qual[exp_cnt].dup_format_ind = 0,expedite->qual[exp_cnt].expedite_trigger_id = et
      .expedite_trigger_id,expedite->qual[exp_cnt].trigger_name = et.name,
      expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq,expedite->qual[exp_cnt].
      expedite_params_id = ep.expedite_params_id,expedite->qual[exp_cnt].params_name = ep.name,
      expedite->qual[exp_cnt].chart_content_flag = ep.chart_content_flag,expedite->qual[exp_cnt].
      order_complete_flag = et.order_complete_flag,expedite->qual[exp_cnt].chart_format_id = ep
      .chart_format_id,
      expedite->qual[exp_cnt].output_flag = 2,expedite->qual[exp_cnt].copy_ind = ep.copy_ind,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=2)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
      ,exp_cnt = (exp_cnt+ 1),stat = alterlist(expedite->qual,exp_cnt),expedite->qual[exp_cnt].
      duplicate_ind = 0,
      expedite->qual[exp_cnt].dup_format_ind = 0,expedite->qual[exp_cnt].expedite_trigger_id = et
      .expedite_trigger_id,expedite->qual[exp_cnt].trigger_name = et.name,
      expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq,expedite->qual[exp_cnt].
      expedite_params_id = ep.expedite_params_id,expedite->qual[exp_cnt].params_name = ep.name,
      expedite->qual[exp_cnt].chart_content_flag = ep.chart_content_flag,expedite->qual[exp_cnt].
      order_complete_flag = et.order_complete_flag,expedite->qual[exp_cnt].chart_format_id = ep
      .chart_format_id,
      expedite->qual[exp_cnt].output_flag = 7,expedite->qual[exp_cnt].copy_ind = ep.copy_ind,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=7)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
      ,exp_cnt = (exp_cnt+ 1),stat = alterlist(expedite->qual,exp_cnt),expedite->qual[exp_cnt].
      duplicate_ind = 0,
      expedite->qual[exp_cnt].dup_format_ind = 0,expedite->qual[exp_cnt].expedite_trigger_id = et
      .expedite_trigger_id,expedite->qual[exp_cnt].trigger_name = et.name,
      expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq,expedite->qual[exp_cnt].
      expedite_params_id = ep.expedite_params_id,expedite->qual[exp_cnt].params_name = ep.name,
      expedite->qual[exp_cnt].chart_content_flag = ep.chart_content_flag,expedite->qual[exp_cnt].
      order_complete_flag = et.order_complete_flag,expedite->qual[exp_cnt].chart_format_id = ep
      .chart_format_id,
      expedite->qual[exp_cnt].output_flag = 1,expedite->qual[exp_cnt].copy_ind = ep.copy_ind,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=1)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
     OF 4:
      sr_xref_ind = 1,expedite->qual[exp_cnt].output_dest_cd = 0,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=ep.output_flag)
         AND ep.output_flag=4
         AND (expedite->qual[idx].service_resource_cd=request->orders[d1.seq].assays[d2.seq].
        service_resource_cd)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
     OF 5:
      org_xref_ind = 1,expedite->qual[exp_cnt].output_dest_cd = 0,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=5)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
     OF 7:
      ord_loc_xref_ind = 1,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=ep.output_flag)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
     OF 8:
      cur_loc_temp_xref_ind = 1,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=ep.output_flag)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
     OF 9:
      cur_loc_temp_xref_ind = 1,cur_loc_xref_ind = 1,exp_cnt = (exp_cnt+ 1),
      stat = alterlist(expedite->qual,exp_cnt),expedite->qual[exp_cnt].duplicate_ind = 0,expedite->
      qual[exp_cnt].dup_format_ind = 0,
      expedite->qual[exp_cnt].expedite_trigger_id = et.expedite_trigger_id,expedite->qual[exp_cnt].
      trigger_name = et.name,expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq,
      expedite->qual[exp_cnt].expedite_params_id = ep.expedite_params_id,expedite->qual[exp_cnt].
      params_name = ep.name,expedite->qual[exp_cnt].chart_content_flag = ep.chart_content_flag,
      expedite->qual[exp_cnt].order_complete_flag = et.order_complete_flag,expedite->qual[exp_cnt].
      chart_format_id = ep.chart_format_id,expedite->qual[exp_cnt].output_flag = 1,
      expedite->qual[exp_cnt].copy_ind = ep.copy_ind,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=1)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
      ,exp_cnt = (exp_cnt+ 1),stat = alterlist(expedite->qual,exp_cnt),expedite->qual[exp_cnt].
      duplicate_ind = 0,
      expedite->qual[exp_cnt].dup_format_ind = 0,expedite->qual[exp_cnt].expedite_trigger_id = et
      .expedite_trigger_id,expedite->qual[exp_cnt].trigger_name = et.name,
      expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq,expedite->qual[exp_cnt].
      expedite_params_id = ep.expedite_params_id,expedite->qual[exp_cnt].params_name = ep.name,
      expedite->qual[exp_cnt].chart_content_flag = ep.chart_content_flag,expedite->qual[exp_cnt].
      order_complete_flag = et.order_complete_flag,expedite->qual[exp_cnt].chart_format_id = ep
      .chart_format_id,
      expedite->qual[exp_cnt].output_flag = 8,expedite->qual[exp_cnt].copy_ind = ep.copy_ind,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=8)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
    ENDCASE
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(expedite)
#start_coded_resp
 IF (coded_resp_ind=1)
  DECLARE join_clause = vc
  IF (coded_response_cd_ind=1)
   SET join_clause = "ecr.coded_response_cd = "
   SET join_clause = concat(join_clause,
    "request->orders[d1.seq]->assays[d2.seq]->coded_resp[d4.seq]->coded_response_cd")
  ELSE
   SET join_clause = "ecr.nomenclature_id ="
   SET join_clause = concat(join_clause,
    "request->orders[d1.seq]->assays[d2.seq]->coded_resp[d4.seq]->nomenclature_id")
  ENDIF
  SET max_coded_resp = 0
  SET cur_coded_resp = 0
  FOR (idx = 1 TO order_total)
    FOR (idx2 = 1 TO assay_total)
     SET cur_coded_resp = size(request->orders[idx].assays[idx2].coded_resp,5)
     IF (cur_coded_resp > max_coded_resp)
      SET max_coded_resp = cur_coded_resp
     ENDIF
    ENDFOR
  ENDFOR
  SELECT INTO "nl:"
   epr.precedence_seq, ep.chart_format_id, ep.output_flag,
   ep.name, et.name_key
   FROM expedite_trigger et,
    expedite_params_r epr,
    expedite_params ep,
    expedite_coded_resp ecr,
    (dummyt d1  WITH seq = value(order_total)),
    (dummyt d2  WITH seq = value(assay_total)),
    (dummyt d3  WITH seq = value(tree_cnt)),
    (dummyt d4  WITH seq = value(max_coded_resp))
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(request->orders[d1.seq].assays,5))
    JOIN (d3)
    JOIN (et
    WHERE ((et.organization_id=0) OR ((et.organization_id=encntr->organization_id)))
     AND parser(et_where)
     AND et.coded_resp_ind=1
     AND ((et.report_priority_cd=0) OR ((et.report_priority_cd=request->orders[d1.seq].assays[d2.seq]
    .report_priority_cd)))
     AND ((et.result_range_cd=0) OR ((et.result_range_cd=request->orders[d1.seq].assays[d2.seq].
    result_range_cd)))
     AND ((et.result_status_cd=0) OR ((et.result_status_cd=request->orders[d1.seq].assays[d2.seq].
    result_status_cd)))
     AND ((et.result_cd=0) OR ((et.result_cd=request->orders[d1.seq].assays[d2.seq].result_cd)))
     AND ((et.result_nbr=0) OR ((et.result_nbr >= request->orders[d1.seq].assays[d2.seq].result_nbr)
    ))
     AND ((et.report_processing_cd=0) OR ((et.report_processing_cd=request->orders[d1.seq].assays[d2
    .seq].report_processing_cd)))
     AND ((et.report_processing_nbr=0) OR ((et.report_processing_nbr >= request->orders[d1.seq].
    assays[d2.seq].report_processing_nbr)))
     AND ((et.service_resource_cd=0) OR ((et.service_resource_cd=tree->qual[d3.seq].code_value)))
     AND ((et.catalog_type_cd=0) OR ((et.catalog_type_cd=request->orders[d1.seq].catalog_type_cd)))
     AND ((et.activity_type_cd=0) OR ((et.activity_type_cd=request->orders[d1.seq].activity_type_cd)
    ))
     AND ((et.catalog_cd=0) OR ((et.catalog_cd=request->orders[d1.seq].catalog_cd)))
     AND ((et.task_assay_cd=0) OR ((et.task_assay_cd=request->orders[d1.seq].assays[d2.seq].
    task_assay_cd)))
     AND et.active_ind=1
     AND ((et.discharged_flag=0) OR (((et.discharged_flag=1
     AND discharged_status=0) OR (et.discharged_flag=2
     AND discharged_status=1)) ))
     AND ((et.mic_ver_flag=0
     AND et.mic_cor_flag=0
     AND et.mic_com_flag=0
     AND et.mic_after_com_flag=0) OR (((et.mic_ver_flag=1
     AND (request->orders[d1.seq].assays[d2.seq].mic_ver_ind=1)) OR (((et.mic_cor_flag=1
     AND (request->orders[d1.seq].assays[d2.seq].mic_cor_ind=1)) OR (((et.mic_com_flag=1
     AND (request->orders[d1.seq].assays[d2.seq].mic_com_ind=1)) OR (et.mic_after_com_flag=1
     AND (request->orders[d1.seq].assays[d2.seq].mic_after_com_ind=1))) )) )) ))
     AND ((et.reference_task_id=0) OR ((et.reference_task_id=request->orders[d1.seq].
    reference_task_id))) )
    JOIN (epr
    WHERE epr.expedite_trigger_id=et.expedite_trigger_id)
    JOIN (ep
    WHERE ep.expedite_params_id=epr.expedite_params_id)
    JOIN (d4
    WHERE d4.seq <= size(request->orders[d1.seq].assays[d2.seq].coded_resp,5))
    JOIN (ecr
    WHERE ecr.expedite_trigger_id=et.expedite_trigger_id
     AND parser(join_clause))
   ORDER BY epr.precedence_seq DESC, et.name_key
   HEAD et.name_key
    exp_cnt = (exp_cnt+ 1), stat = alterlist(expedite->qual,exp_cnt), expedite->qual[exp_cnt].
    duplicate_ind = 0,
    expedite->qual[exp_cnt].dup_format_ind = 0, expedite->qual[exp_cnt].expedite_trigger_id = et
    .expedite_trigger_id, expedite->qual[exp_cnt].trigger_name = et.name,
    expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq, expedite->qual[exp_cnt].
    expedite_params_id = ep.expedite_params_id, expedite->qual[exp_cnt].params_name = ep.name,
    expedite->qual[exp_cnt].coded_resp_ind = et.coded_resp_ind, expedite->qual[exp_cnt].
    chart_content_flag = ep.chart_content_flag, expedite->qual[exp_cnt].order_complete_flag = et
    .order_complete_flag,
    expedite->qual[exp_cnt].chart_format_id = ep.chart_format_id, expedite->qual[exp_cnt].output_flag
     = ep.output_flag, expedite->qual[exp_cnt].output_dest_cd = ep.output_dest_cd,
    expedite->qual[exp_cnt].output_device_cd = ep.output_device_cd, expedite->qual[exp_cnt].
    service_resource_cd = tree->qual[d3.seq].lowest_child_cd, expedite->qual[exp_cnt].copy_ind = ep
    .copy_ind
    IF (ep.copy_ind=1)
     copy_ind = 1
    ENDIF
    CASE (ep.output_flag)
     OF 0:
      assigned_ind = 1
     OF 1:
      cur_loc_xref_ind = 1,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=ep.output_flag)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
     OF 2:
      pat_loc_xref_ind = 1,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=ep.output_flag)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
     OF 3:
      cur_loc_xref_ind = 1,pat_loc_xref_ind = 1,ord_loc_xref_ind = 1,
      exp_cnt = (exp_cnt+ 1),stat = alterlist(expedite->qual,exp_cnt),expedite->qual[exp_cnt].
      duplicate_ind = 0,
      expedite->qual[exp_cnt].dup_format_ind = 0,expedite->qual[exp_cnt].expedite_trigger_id = et
      .expedite_trigger_id,expedite->qual[exp_cnt].trigger_name = et.name,
      expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq,expedite->qual[exp_cnt].
      expedite_params_id = ep.expedite_params_id,expedite->qual[exp_cnt].params_name = ep.name,
      expedite->qual[exp_cnt].chart_content_flag = ep.chart_content_flag,expedite->qual[exp_cnt].
      order_complete_flag = et.order_complete_flag,expedite->qual[exp_cnt].chart_format_id = ep
      .chart_format_id,
      expedite->qual[exp_cnt].output_flag = 2,expedite->qual[exp_cnt].copy_ind = ep.copy_ind,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=2)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
      ,exp_cnt = (exp_cnt+ 1),stat = alterlist(expedite->qual,exp_cnt),expedite->qual[exp_cnt].
      duplicate_ind = 0,
      expedite->qual[exp_cnt].dup_format_ind = 0,expedite->qual[exp_cnt].expedite_trigger_id = et
      .expedite_trigger_id,expedite->qual[exp_cnt].trigger_name = et.name,
      expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq,expedite->qual[exp_cnt].
      expedite_params_id = ep.expedite_params_id,expedite->qual[exp_cnt].params_name = ep.name,
      expedite->qual[exp_cnt].chart_content_flag = ep.chart_content_flag,expedite->qual[exp_cnt].
      order_complete_flag = et.order_complete_flag,expedite->qual[exp_cnt].chart_format_id = ep
      .chart_format_id,
      expedite->qual[exp_cnt].output_flag = 7,expedite->qual[exp_cnt].copy_ind = ep.copy_ind,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=7)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
      ,exp_cnt = (exp_cnt+ 1),stat = alterlist(expedite->qual,exp_cnt),expedite->qual[exp_cnt].
      duplicate_ind = 0,
      expedite->qual[exp_cnt].dup_format_ind = 0,expedite->qual[exp_cnt].expedite_trigger_id = et
      .expedite_trigger_id,expedite->qual[exp_cnt].trigger_name = et.name,
      expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq,expedite->qual[exp_cnt].
      expedite_params_id = ep.expedite_params_id,expedite->qual[exp_cnt].params_name = ep.name,
      expedite->qual[exp_cnt].chart_content_flag = ep.chart_content_flag,expedite->qual[exp_cnt].
      order_complete_flag = et.order_complete_flag,expedite->qual[exp_cnt].chart_format_id = ep
      .chart_format_id,
      expedite->qual[exp_cnt].output_flag = 1,expedite->qual[exp_cnt].copy_ind = ep.copy_ind,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=1)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
     OF 4:
      sr_xref_ind = 1,expedite->qual[exp_cnt].output_dest_cd = 0,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=ep.output_flag)
         AND ep.output_flag=4
         AND (expedite->qual[idx].service_resource_cd=request->orders[d1.seq].assays[d2.seq].
        service_resource_cd)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
     OF 5:
      org_xref_ind = 1,expedite->qual[exp_cnt].output_dest_cd = 0,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=5)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
     OF 7:
      ord_loc_xref_ind = 1,expedite->qual[exp_cnt].output_dest_cd = 0,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=ep.output_flag)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
     OF 8:
      cur_loc_temp_xref_ind = 1,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=ep.output_flag)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
     OF 9:
      cur_loc_temp_xref_ind = 1,cur_loc_xref_ind = 1,exp_cnt = (exp_cnt+ 1),
      stat = alterlist(expedite->qual,exp_cnt),expedite->qual[exp_cnt].duplicate_ind = 0,expedite->
      qual[exp_cnt].dup_format_ind = 0,
      expedite->qual[exp_cnt].expedite_trigger_id = et.expedite_trigger_id,expedite->qual[exp_cnt].
      trigger_name = et.name,expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq,
      expedite->qual[exp_cnt].expedite_params_id = ep.expedite_params_id,expedite->qual[exp_cnt].
      params_name = ep.name,expedite->qual[exp_cnt].chart_content_flag = ep.chart_content_flag,
      expedite->qual[exp_cnt].order_complete_flag = et.order_complete_flag,expedite->qual[exp_cnt].
      chart_format_id = ep.chart_format_id,expedite->qual[exp_cnt].output_flag = 1,
      expedite->qual[exp_cnt].copy_ind = ep.copy_ind,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=1)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
      ,exp_cnt = (exp_cnt+ 1),stat = alterlist(expedite->qual,exp_cnt),expedite->qual[exp_cnt].
      duplicate_ind = 0,
      expedite->qual[exp_cnt].dup_format_ind = 0,expedite->qual[exp_cnt].expedite_trigger_id = et
      .expedite_trigger_id,expedite->qual[exp_cnt].trigger_name = et.name,
      expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq,expedite->qual[exp_cnt].
      expedite_params_id = ep.expedite_params_id,expedite->qual[exp_cnt].params_name = ep.name,
      expedite->qual[exp_cnt].chart_content_flag = ep.chart_content_flag,expedite->qual[exp_cnt].
      order_complete_flag = et.order_complete_flag,expedite->qual[exp_cnt].chart_format_id = ep
      .chart_format_id,
      expedite->qual[exp_cnt].output_flag = 8,expedite->qual[exp_cnt].copy_ind = ep.copy_ind,
      FOR (idx = 1 TO (exp_cnt - 1))
        IF ((expedite->qual[idx].output_flag=8)
         AND (expedite->qual[idx].order_complete_flag=et.order_complete_flag))
         expedite->qual[idx].duplicate_ind = 1
         IF ((expedite->qual[idx].chart_format_id=ep.chart_format_id))
          expedite->qual[idx].dup_format_ind = 1
         ENDIF
        ENDIF
      ENDFOR
    ENDCASE
   WITH nocounter
  ;end select
 ENDIF
 IF (exp_cnt=0)
  IF (log_level >= 2)
   IF (log_level=2
    AND acc_logged_ind=0)
    EXECUTE FROM start_log_accession TO end_log_accession
   ENDIF
   SET log_nbr = (log_nbr+ 1)
   SET log_buffer[log_nbr] = "No expedite triggered"
  ENDIF
  IF (log_level >= 4)
   FOR (idx = 1 TO order_total)
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat("  order_id: ",cnvtstring(request->orders[idx].order_id))
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat("  order_complete_ind: ",cnvtstring(request->orders[idx].
       order_complete_ind))
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat("  catalog_type_cd: ",cnvtstring(request->orders[idx].
       catalog_type_cd))
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat("  activity_type_cd: ",cnvtstring(request->orders[idx].
       activity_type_cd))
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat("  catalog_cd: ",cnvtstring(request->orders[idx].catalog_cd))
     SET cur_total = size(request->orders[idx].assays,5)
     FOR (idx2 = 1 TO cur_total)
       SET log_nbr = (log_nbr+ 1)
       SET log_buffer[log_nbr] = concat("    task_assay_cd: ",cnvtstring(request->orders[idx].assays[
         idx2].task_assay_cd))
       SET log_nbr = (log_nbr+ 1)
       SET log_buffer[log_nbr] = concat("    report_priority_cd: ",cnvtstring(request->orders[idx].
         assays[idx2].report_priority_cd))
       SET log_nbr = (log_nbr+ 1)
       SET log_buffer[log_nbr] = concat("    result_range_cd: ",cnvtstring(request->orders[idx].
         assays[idx2].result_range_cd))
       SET log_nbr = (log_nbr+ 1)
       SET log_buffer[log_nbr] = concat("    result_status_cd: ",cnvtstring(request->orders[idx].
         assays[idx2].result_status_cd))
       SET log_nbr = (log_nbr+ 1)
       SET log_buffer[log_nbr] = concat("    result_cd: ",cnvtstring(request->orders[idx].assays[idx2
         ].result_cd))
       SET log_nbr = (log_nbr+ 1)
       SET log_buffer[log_nbr] = concat("    result_nbr: ",cnvtstring(request->orders[idx].assays[
         idx2].result_nbr))
       SET log_nbr = (log_nbr+ 1)
       SET log_buffer[log_nbr] = concat("    report_processing_cd: ",cnvtstring(request->orders[idx].
         assays[idx2].report_processing_cd))
       SET log_nbr = (log_nbr+ 1)
       SET log_buffer[log_nbr] = concat("    report_processing_nbr: ",cnvtstring(request->orders[idx]
         .assays[idx2].report_processing_nbr))
       SET log_nbr = (log_nbr+ 1)
       SET log_buffer[log_nbr] = concat("    service_resource_cd: ",cnvtstring(request->orders[idx].
         assays[idx2].service_resource_cd))
       SET num_coded_resp = size(request->orders[idx].assays[idx2].coded_resp,5)
       IF (num_coded_resp > 0)
        FOR (idx3 = 1 TO num_coded_resp)
         SET log_nbr = (log_nbr+ 1)
         SET log_buffer[log_nbr] = concat("    nomenclature_id: ",cnvtstring(request->orders[idx].
           assays[idx2].coded_resp[idx3].nomenclature_id))
        ENDFOR
       ENDIF
     ENDFOR
   ENDFOR
  ENDIF
  GO TO start_manual_expedites
 ENDIF
#end_triggers
#start_loc_xref
 IF (((cur_loc_xref_ind=1) OR (((pat_loc_xref_ind=1) OR (((ord_loc_xref_ind=1) OR (
 cur_loc_temp_xref_ind=1)) )) )) )
  SELECT INTO "nl:"
   od.output_dest_cd
   FROM device_xref x,
    output_dest od,
    device d,
    dummyt d2,
    remote_device rd,
    remote_device_type rdt
   PLAN (x
    WHERE x.parent_entity_id IN (encntr->cur_loc_facility_cd, encntr->cur_loc_building_cd, encntr->
    cur_loc_nurse_unit_cd, encntr->cur_loc_room_cd, encntr->cur_loc_bed_cd,
    encntr->cur_loc_temp_cd)
     AND x.parent_entity_name="LOCATION")
    JOIN (d
    WHERE d.device_cd=x.device_cd)
    JOIN (od
    WHERE od.device_cd=d.device_cd)
    JOIN (d2)
    JOIN (rd
    WHERE rd.device_cd=od.device_cd)
    JOIN (rdt
    WHERE rdt.remote_dev_type_id=rd.remote_dev_type_id)
   HEAD REPORT
    loc_lvl = 9
   DETAIL
    CASE (x.parent_entity_id)
     OF encntr->cur_loc_facility_cd:
      IF (5 < loc_lvl)
       loc_output_dest_cd = od.output_dest_cd, loc_output_device_cd = rdt.output_format_cd,
       loc_output_dest_name = od.name
       IF (d.name != od.name)
        loc_device_name = d.name
       ENDIF
       loc_lvl = 5
      ENDIF
     OF encntr->cur_loc_building_cd:
      IF (4 < loc_lvl)
       loc_output_dest_cd = od.output_dest_cd, loc_output_device_cd = rdt.output_format_cd,
       loc_output_dest_name = od.name
       IF (d.name != od.name)
        loc_device_name = d.name
       ENDIF
       loc_lvl = 4
      ENDIF
     OF encntr->cur_loc_nurse_unit_cd:
      IF (3 < loc_lvl)
       loc_output_dest_cd = od.output_dest_cd, loc_output_device_cd = rdt.output_format_cd,
       loc_output_dest_name = od.name
       IF (d.name != od.name)
        loc_device_name = d.name
       ENDIF
       loc_lvl = 3
      ENDIF
     OF encntr->cur_loc_room_cd:
      IF (2 < loc_lvl)
       loc_output_dest_cd = od.output_dest_cd, loc_output_device_cd = rdt.output_format_cd,
       loc_output_dest_name = od.name
       IF (d.name != od.name)
        loc_device_name = d.name
       ENDIF
       loc_lvl = 2
      ENDIF
     OF encntr->cur_loc_bed_cd:
      IF (1 < loc_lvl)
       loc_output_dest_cd = od.output_dest_cd, loc_output_device_cd = rdt.output_format_cd,
       loc_output_dest_name = od.name
       IF (d.name != od.name)
        loc_device_name = d.name
       ENDIF
       loc_lvl = 1
      ENDIF
     OF encntr->cur_loc_temp_cd:
      loc_temp_output_dest_cd = od.output_dest_cd,loc_temp_output_device_cd = rdt.output_format_cd,
      loc_temp_output_dest_name = od.name,
      IF (d.name != od.name)
       loc_temp_device_name = d.name
      ENDIF
    ENDCASE
   WITH nocounter, outerjoin = d2
  ;end select
  SELECT INTO "nl:"
   od.output_dest_cd
   FROM device_xref x,
    output_dest od,
    device d,
    dummyt d2,
    remote_device rd,
    remote_device_type rdt
   PLAN (x
    WHERE x.parent_entity_id IN (encntr->pat_loc_facility_cd, encntr->pat_loc_building_cd, encntr->
    pat_loc_nurse_unit_cd, encntr->pat_loc_room_cd, encntr->pat_loc_bed_cd)
     AND x.parent_entity_name="LOCATION")
    JOIN (d
    WHERE d.device_cd=x.device_cd)
    JOIN (od
    WHERE od.device_cd=d.device_cd)
    JOIN (d2)
    JOIN (rd
    WHERE rd.device_cd=od.device_cd)
    JOIN (rdt
    WHERE rdt.remote_dev_type_id=rd.remote_dev_type_id)
   HEAD REPORT
    pat_lvl = 9
   DETAIL
    CASE (x.parent_entity_id)
     OF encntr->pat_loc_facility_cd:
      IF (5 < pat_lvl)
       pat_output_dest_cd = od.output_dest_cd, pat_output_device_cd = rdt.output_format_cd,
       pat_output_dest_name = od.name
       IF (d.name != od.name)
        pat_device_name = d.name
       ENDIF
       pat_lvl = 5
      ENDIF
     OF encntr->pat_loc_building_cd:
      IF (4 < pat_lvl)
       pat_output_dest_cd = od.output_dest_cd, pat_output_device_cd = rdt.output_format_cd,
       pat_output_dest_name = od.name
       IF (d.name != od.name)
        pat_device_name = d.name
       ENDIF
       pat_lvl = 4
      ENDIF
     OF encntr->pat_loc_nurse_unit_cd:
      IF (3 < pat_lvl)
       pat_output_dest_cd = od.output_dest_cd, pat_output_device_cd = rdt.output_format_cd,
       pat_output_dest_name = od.name
       IF (d.name != od.name)
        pat_device_name = d.name
       ENDIF
       pat_lvl = 3
      ENDIF
     OF encntr->pat_loc_room_cd:
      IF (2 < pat_lvl)
       pat_output_dest_cd = od.output_dest_cd, pat_output_device_cd = rdt.output_format_cd,
       pat_output_dest_name = od.name
       IF (d.name != od.name)
        pat_device_name = d.name
       ENDIF
       pat_lvl = 2
      ENDIF
     OF encntr->pat_loc_bed_cd:
      IF (1 < pat_lvl)
       pat_output_dest_cd = od.output_dest_cd, pat_output_device_cd = rdt.output_format_cd,
       pat_output_dest_name = od.name
       IF (d.name != od.name)
        pat_device_name = d.name
       ENDIF
       pat_lvl = 1
      ENDIF
    ENDCASE
   WITH nocounter, outerjoin = d2
  ;end select
  SELECT INTO "nl:"
   od.output_dest_cd
   FROM device_xref x,
    output_dest od,
    device d,
    dummyt d2,
    remote_device rd,
    remote_device_type rdt
   PLAN (x
    WHERE x.parent_entity_id IN (encntr->ord_loc_facility_cd, encntr->ord_loc_building_cd, encntr->
    ord_loc_nurse_unit_cd, encntr->ord_loc_room_cd, encntr->ord_loc_bed_cd)
     AND x.parent_entity_name="LOCATION")
    JOIN (d
    WHERE d.device_cd=x.device_cd)
    JOIN (od
    WHERE od.device_cd=d.device_cd)
    JOIN (d2)
    JOIN (rd
    WHERE rd.device_cd=od.device_cd)
    JOIN (rdt
    WHERE rdt.remote_dev_type_id=rd.remote_dev_type_id)
   HEAD REPORT
    ord_lvl = 9
   DETAIL
    CASE (x.parent_entity_id)
     OF encntr->ord_loc_facility_cd:
      IF (5 < ord_lvl)
       ord_output_dest_cd = od.output_dest_cd, ord_output_device_cd = rdt.output_format_cd,
       ord_output_dest_name = od.name
       IF (d.name != od.name)
        ord_device_name = d.name
       ENDIF
       ord_lvl = 5
      ENDIF
     OF encntr->ord_loc_building_cd:
      IF (4 < ord_lvl)
       ord_output_dest_cd = od.output_dest_cd, ord_output_device_cd = rdt.output_format_cd,
       ord_output_dest_name = od.name
       IF (d.name != od.name)
        ord_device_name = d.name
       ENDIF
       ord_lvl = 4
      ENDIF
     OF encntr->ord_loc_nurse_unit_cd:
      IF (3 < ord_lvl)
       ord_output_dest_cd = od.output_dest_cd, ord_output_device_cd = rdt.output_format_cd,
       ord_output_dest_name = od.name
       IF (d.name != od.name)
        ord_device_name = d.name
       ENDIF
       ord_lvl = 3
      ENDIF
     OF encntr->ord_loc_room_cd:
      IF (2 < ord_lvl)
       ord_output_dest_cd = od.output_dest_cd, ord_output_device_cd = rdt.output_format_cd,
       ord_output_dest_name = od.name
       IF (d.name != od.name)
        ord_device_name = d.name
       ENDIF
       ord_lvl = 2
      ENDIF
     OF encntr->ord_loc_bed_cd:
      IF (1 < ord_lvl)
       ord_output_dest_cd = od.output_dest_cd, ord_output_device_cd = rdt.output_format_cd,
       ord_output_dest_name = od.name
       IF (d.name != od.name)
        ord_device_name = d.name
       ENDIF
       ord_lvl = 1
      ENDIF
    ENDCASE
   WITH nocounter, outerjoin = d2
  ;end select
  IF (log_level >= 1)
   IF (cur_loc_xref_ind=1
    AND loc_output_dest_cd=0)
    SET error_ind = 1
    IF (log_level=1
     AND acc_logged_ind=0)
     EXECUTE FROM start_log_accession TO end_log_accession
    ENDIF
    SET log_nbr = (log_nbr+ 1)
    SET log_buffer[log_nbr] = "No device found for patient's location so no expedite sent"
    SET log_nbr = (log_nbr+ 1)
    SET log_buffer[log_nbr] = concat("fac, bld, nu, room, bed: ",cnvtstring(encntr->
      cur_loc_facility_cd),cnvtstring(encntr->cur_loc_building_cd),cnvtstring(encntr->
      cur_loc_nurse_unit_cd),cnvtstring(encntr->cur_loc_room_cd),
     cnvtstring(encntr->cur_loc_bed_cd))
   ELSEIF (pat_loc_xref_ind=1
    AND pat_output_dest_cd=0)
    SET error_ind = 1
    IF (log_level=1
     AND acc_logged_ind=0)
     EXECUTE FROM start_log_accession TO end_log_accession
    ENDIF
    SET log_nbr = (log_nbr+ 1)
    SET log_buffer[log_nbr] =
    "No device found for patient's location at time of order so no expedite sent."
    SET log_nbr = (log_nbr+ 1)
    SET log_buffer[log_nbr] = concat("fac, bld, nu, room, bed: ",cnvtstring(encntr->
      pat_loc_facility_cd),cnvtstring(encntr->pat_loc_building_cd),cnvtstring(encntr->
      pat_loc_nurse_unit_cd),cnvtstring(encntr->pat_loc_room_cd),
     cnvtstring(encntr->pat_loc_bed_cd))
   ELSEIF (ord_loc_xref_ind=1
    AND ord_output_dest_cd=0)
    SET error_ind = 1
    IF (log_level=1
     AND acc_logged_ind=0)
     EXECUTE FROM start_log_accession TO end_log_accession
    ENDIF
    SET log_nbr = (log_nbr+ 1)
    SET log_buffer[log_nbr] = "No device found for order location so no expedite sent."
    SET log_nbr = (log_nbr+ 1)
    SET log_buffer[log_nbr] = concat("fac, bld, nu, room, bed: ",cnvtstring(encntr->
      ord_loc_facility_cd),cnvtstring(encntr->ord_loc_building_cd),cnvtstring(encntr->
      ord_loc_nurse_unit_cd),cnvtstring(encntr->ord_loc_room_cd),
     cnvtstring(encntr->ord_loc_bed_cd))
   ELSEIF (cur_loc_temp_xref_ind=1
    AND loc_temp_output_dest_cd=0)
    SET error_ind = 1
    IF (log_level=1
     AND acc_logged_ind=0)
     EXECUTE FROM start_log_accession TO end_log_accession
    ENDIF
    SET log_nbr = (log_nbr+ 1)
    IF ((encntr->cur_loc_temp_cd > 0))
     SET log_buffer[log_nbr] =
     "No device found for current patient temporary location so no expedite sent."
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat("patient temporary location: ",cnvtstring(encntr->
       cur_loc_temp_cd))
    ELSE
     SET log_buffer[log_nbr] = "Current patient temporary location code is Zero so no expedite sent."
    ENDIF
   ENDIF
  ENDIF
  FOR (idx = 1 TO exp_cnt)
    IF ((expedite->qual[idx].output_flag=1))
     SET expedite->qual[idx].output_dest_cd = loc_output_dest_cd
     SET expedite->qual[idx].output_device_cd = loc_output_device_cd
     IF (loc_device_name > " ")
      SET expedite->qual[idx].device_name = loc_device_name
     ENDIF
     SET expedite->qual[idx].output_dest_name = loc_output_dest_name
    ELSEIF ((expedite->qual[idx].output_flag=2))
     SET expedite->qual[idx].output_dest_cd = pat_output_dest_cd
     SET expedite->qual[idx].output_device_cd = pat_output_device_cd
     IF (pat_device_name > " ")
      SET expedite->qual[idx].device_name = pat_device_name
     ENDIF
     SET expedite->qual[idx].output_dest_name = pat_output_dest_name
    ELSEIF ((expedite->qual[idx].output_flag=7))
     SET expedite->qual[idx].output_dest_cd = ord_output_dest_cd
     SET expedite->qual[idx].output_device_cd = ord_output_device_cd
     IF (ord_device_name > " ")
      SET expedite->qual[idx].device_name = ord_device_name
     ENDIF
     SET expedite->qual[idx].output_dest_name = ord_output_dest_name
    ELSEIF ((expedite->qual[idx].output_flag=8))
     SET expedite->qual[idx].output_dest_cd = loc_temp_output_dest_cd
     SET expedite->qual[idx].output_device_cd = loc_temp_output_device_cd
     IF (loc_temp_device_name > " ")
      SET expedite->qual[idx].device_name = loc_temp_device_name
     ENDIF
     SET expedite->qual[idx].output_dest_name = loc_temp_output_dest_name
    ENDIF
  ENDFOR
 ENDIF
#end_loc_xref
#start_sr_xref
 IF (sr_xref_ind=1)
  FOR (idx = 1 TO exp_cnt)
    IF ((expedite->qual[idx].output_flag=4)
     AND (expedite->qual[idx].output_dest_cd=0))
     SET sr_output_dest_cd = 0
     SELECT INTO "nl:"
      od.output_dest_cd
      FROM (dummyt d1  WITH seq = value(tree_cnt)),
       device_xref x,
       device d,
       output_dest od,
       dummyt d2,
       remote_device rd,
       remote_device_type rdt
      PLAN (d1
       WHERE (tree->qual[d1.seq].lowest_child_cd=expedite->qual[idx].service_resource_cd))
       JOIN (x
       WHERE (x.parent_entity_id=tree->qual[d1.seq].code_value)
        AND x.parent_entity_name="SERVICE_RESOURCE")
       JOIN (d
       WHERE d.device_cd=x.device_cd)
       JOIN (od
       WHERE od.device_cd=d.device_cd)
       JOIN (d2)
       JOIN (rd
       WHERE rd.device_cd=od.device_cd)
       JOIN (rdt
       WHERE rdt.remote_dev_type_id=rd.remote_dev_type_id)
      HEAD REPORT
       sr_lvl = 9, sr_output_dest_cd = 0, sr_output_device_cd = 0,
       sr_output_dest_name = fillstring(20," "), sr_output_device_name = fillstring(20," ")
      DETAIL
       IF (5 < sr_lvl
        AND (tree->qual[d1.seq].sr_tree_lvl=5))
        sr_output_dest_cd = od.output_dest_cd, sr_output_device_cd = rdt.output_format_cd,
        sr_output_dest_name = od.name
        IF (d.name != od.name)
         sr_output_device_name = d.name
        ENDIF
        sr_lvl = 5
       ENDIF
       IF (4 < sr_lvl
        AND (tree->qual[d1.seq].sr_tree_lvl=4))
        sr_output_dest_cd = od.output_dest_cd, sr_output_device_cd = rdt.output_format_cd,
        sr_output_dest_name = od.name
        IF (d.name != od.name)
         sr_output_device_name = d.name
        ENDIF
        sr_lvl = 4
       ENDIF
       IF (3 < sr_lvl
        AND (tree->qual[d1.seq].sr_tree_lvl=3))
        sr_output_dest_cd = od.output_dest_cd, sr_output_device_cd = rdt.output_format_cd,
        sr_output_dest_name = od.name
        IF (d.name != od.name)
         sr_output_device_name = d.name
        ENDIF
        sr_lvl = 3
       ENDIF
       IF (2 < sr_lvl
        AND (tree->qual[d1.seq].sr_tree_lvl=2))
        sr_output_dest_cd = od.output_dest_cd, sr_output_device_cd = rdt.output_format_cd,
        sr_output_dest_name = od.name
        IF (d.name != od.name)
         sr_output_device_name = d.name
        ENDIF
        sr_lvl = 2
       ENDIF
       IF (1 < sr_lvl
        AND (tree->qual[d1.seq].sr_tree_lvl=1))
        sr_output_dest_cd = od.output_dest_cd, sr_output_device_cd = rdt.output_format_cd,
        sr_output_dest_name = od.name
        IF (d.name != od.name)
         sr_output_device_name = d.name
        ENDIF
        sr_lvl = 1
       ENDIF
      WITH nocounter, outerjoin = d2
     ;end select
     IF (sr_output_dest_cd > 0)
      FOR (idx2 = 1 TO exp_cnt)
        IF ((expedite->qual[idx2].output_flag=4)
         AND (expedite->qual[idx2].service_resource_cd=expedite->qual[idx].service_resource_cd))
         SET expedite->qual[idx2].output_dest_cd = sr_output_dest_cd
         SET expedite->qual[idx2].output_device_cd = sr_output_device_cd
         SET expedite->qual[idx2].output_dest_name = sr_output_dest_name
         IF (trim(cnvtupper(sr_output_dest_name)) != trim(cnvtupper(sr_output_device_name)))
          SET expedite->qual[idx2].device_name = sr_output_device_name
         ENDIF
        ENDIF
      ENDFOR
     ELSE
      IF (log_level >= 1)
       SET error_ind = 1
       IF (log_level=1
        AND acc_logged_ind=0)
        EXECUTE FROM start_log_accession TO end_log_accession
       ENDIF
       SET log_nbr = (log_nbr+ 1)
       SET log_buffer[log_nbr] = concat("No device xref found for service resource: ",cnvtstring(
         expedite->qual[idx].service_resource_cd))
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
#end_sr_xref
#start_org_xref
 IF (org_xref_ind=1)
  SELECT INTO "nl:"
   od.output_dest_cd
   FROM device_xref x,
    device d,
    output_dest od,
    dummyt d2,
    remote_device rd,
    remote_device_type rdt
   PLAN (x
    WHERE (x.parent_entity_id=encntr->organization_id)
     AND x.parent_entity_name="ORGANIZATION")
    JOIN (d
    WHERE d.device_cd=x.device_cd)
    JOIN (od
    WHERE od.device_cd=d.device_cd)
    JOIN (d2)
    JOIN (rd
    WHERE rd.device_cd=od.device_cd)
    JOIN (rdt
    WHERE rdt.remote_dev_type_id=rd.remote_dev_type_id)
   HEAD REPORT
    org_output_dest_cd = od.output_dest_cd, org_output_device_cd = rdt.output_format_cd,
    org_output_dest_name = od.name
    IF (trim(cnvtupper(od.name)) != trim(cnvtupper(d.name)))
     org_output_device_name = d.name
    ENDIF
   WITH nocounter, outerjoin = d2
  ;end select
  IF (org_output_dest_cd > 0)
   FOR (idx2 = 1 TO exp_cnt)
     IF ((expedite->qual[idx2].output_flag=5))
      SET expedite->qual[idx2].output_dest_cd = org_output_dest_cd
      SET expedite->qual[idx2].output_device_cd = org_output_device_cd
      SET expedite->qual[idx2].output_dest_name = org_output_dest_name
      IF (trim(cnvtupper(org_output_dest_name)) != trim(cnvtupper(org_output_device_name)))
       SET expedite->qual[idx2].device_name = org_output_device_name
      ENDIF
     ENDIF
   ENDFOR
  ELSE
   IF (log_level >= 1)
    SET error_ind = 1
    IF (log_level=1
     AND acc_logged_ind=0)
     EXECUTE FROM start_log_accession TO end_log_accession
    ENDIF
    SET log_nbr = (log_nbr+ 1)
    SET log_buffer[log_nbr] = concat("No device xref found for organization: ",cnvtstring(encntr->
      organization_id))
   ENDIF
  ENDIF
 ENDIF
#end_org_xref
#start_assigned
 IF (assigned_ind=1)
  SELECT INTO "nl:"
   od.output_dest_cd
   FROM (dummyt d1  WITH seq = value(exp_cnt)),
    device d,
    output_dest od
   PLAN (d1
    WHERE (expedite->qual[d1.seq].output_flag=0))
    JOIN (od
    WHERE (od.output_dest_cd=expedite->qual[d1.seq].output_dest_cd))
    JOIN (d
    WHERE d.device_cd=od.device_cd)
   DETAIL
    expedite->qual[d1.seq].output_dest_name = od.name
    IF (trim(cnvtupper(od.name)) != trim(cnvtupper(d.name)))
     expedite->qual[d1.seq].device_name = d.name
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#end_assigned
#start_dup_check
 FOR (idx = 1 TO exp_cnt)
  SET idx2 = ((exp_cnt+ 1) - idx)
  IF ((expedite->qual[idx2].duplicate_ind=0))
   FOR (idx3 = 1 TO exp_cnt)
     IF (idx3 != idx2
      AND (expedite->qual[idx3].output_dest_cd=expedite->qual[idx2].output_dest_cd)
      AND (expedite->qual[idx3].chart_format_id=expedite->qual[idx2].chart_format_id)
      AND (expedite->qual[idx3].order_complete_flag=expedite->qual[idx2].order_complete_flag))
      SET expedite->qual[idx3].duplicate_ind = 1
      SET expedite->qual[idx3].dup_format_ind = 1
     ENDIF
   ENDFOR
  ENDIF
 ENDFOR
#end_dup_check
#start_copy_to_providers
 IF (copy_ind=1)
  SELECT INTO "nl:"
   ec.expedite_params_id
   FROM (dummyt d  WITH seq = value(exp_cnt)),
    expedite_copy ec,
    encntr_prsnl_reltn epr
   PLAN (d
    WHERE (expedite->qual[d.seq].copy_ind=1))
    JOIN (ec
    WHERE (expedite->qual[d.seq].expedite_params_id=ec.expedite_params_id))
    JOIN (epr
    WHERE (request->encntr_id=epr.encntr_id)
     AND ec.encntr_prsnl_r_cd=epr.encntr_prsnl_r_cd)
   HEAD REPORT
    copy_cnt = 0
   DETAIL
    copy_cnt = (copy_cnt+ 1), stat = alterlist(copy->qual,copy_cnt), copy->qual[copy_cnt].
    duplicate_ind = 0,
    copy->qual[copy_cnt].dup_format_ind = 0, copy->qual[copy_cnt].expedite_params_id = ec
    .expedite_params_id, copy->qual[copy_cnt].trigger_name = expedite->qual[d.seq].trigger_name,
    copy->qual[copy_cnt].chart_content_flag = expedite->qual[d.seq].chart_content_flag, copy->qual[
    copy_cnt].order_complete_flag = expedite->qual[d.seq].order_complete_flag, copy->qual[copy_cnt].
    chart_format_id = expedite->qual[d.seq].chart_format_id,
    copy->qual[copy_cnt].params_name = expedite->qual[d.seq].params_name, copy->qual[copy_cnt].
    encntr_prsnl_r_cd = ec.encntr_prsnl_r_cd, copy->qual[copy_cnt].provider_id = epr.prsnl_person_id,
    copy->qual[copy_cnt].order_level_ind = 0
    FOR (idx = 1 TO (copy_cnt - 1))
     IF ((copy->qual[idx].encntr_prsnl_r_cd=ec.encntr_prsnl_r_cd)
      AND (copy->qual[idx].order_complete_flag=expedite->qual[d.seq].order_complete_flag))
      copy->qual[idx].duplicate_ind = 1
      IF ((copy->qual[idx].chart_format_id=expedite->qual[d.seq].chart_format_id))
       copy->qual[idx].dup_format_ind = 1
      ENDIF
     ENDIF
     ,
     IF ((copy->qual[idx].provider_id=epr.prsnl_person_id)
      AND (copy->qual[idx].order_complete_flag=expedite->qual[d.seq].order_complete_flag))
      copy->qual[idx].duplicate_ind = 1, copy->qual[idx].dup_format_ind = 1
     ENDIF
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
#end_copy_to_providers
#start_consulting_providers
 IF (copy_ind=1)
  SELECT INTO "nl:"
   ec.encntr_prsnl_r_cd
   FROM (dummyt d  WITH seq = value(exp_cnt)),
    expedite_copy ec
   PLAN (d
    WHERE (expedite->qual[d.seq].copy_ind=1))
    JOIN (ec
    WHERE (expedite->qual[d.seq].expedite_params_id=ec.expedite_params_id))
   DETAIL
    IF (ec.encntr_prsnl_r_cd=consult_doc_cd)
     add_cons = 1, params_id = ec.expedite_params_id
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (add_cons=1)
  SELECT INTO "nl:"
   od.order_id, od.oe_field_value
   FROM (dummyt d  WITH seq = value(exp_cnt)),
    (dummyt d1  WITH seq = value(size(request->orders,5))),
    order_detail od
   PLAN (d
    WHERE (expedite->qual[d.seq].copy_ind=1)
     AND (expedite->qual[d.seq].expedite_params_id=params_id))
    JOIN (d1
    WHERE (request->orders[d1.seq].order_id > 0.0))
    JOIN (od
    WHERE (od.order_id=request->orders[d1.seq].order_id)
     AND od.oe_field_meaning="CONSULTDOC"
     AND od.oe_field_meaning_id=2)
   ORDER BY od.order_id, od.action_sequence DESC, od.detail_sequence
   HEAD od.order_id
    row + 1, lastestseq = 1
   HEAD od.action_sequence
    do_nothing = 0
   DETAIL
    IF (lastestseq=1
     AND od.oe_field_display_value > " ")
     copy_cnt = (copy_cnt+ 1), status = alterlist(copy->qual,copy_cnt), copy->qual[copy_cnt].
     duplicate_ind = 0,
     copy->qual[copy_cnt].dup_format_ind = 0, copy->qual[copy_cnt].expedite_params_id = expedite->
     qual[d.seq].expedite_params_id, copy->qual[copy_cnt].trigger_name = expedite->qual[d.seq].
     trigger_name,
     copy->qual[copy_cnt].chart_content_flag = expedite->qual[d.seq].chart_content_flag, copy->qual[
     copy_cnt].order_complete_flag = expedite->qual[d.seq].order_complete_flag, copy->qual[copy_cnt].
     chart_format_id = expedite->qual[d.seq].chart_format_id,
     copy->qual[copy_cnt].params_name = expedite->qual[d.seq].params_name, copy->qual[copy_cnt].
     encntr_prsnl_r_cd = consult_doc_cd, copy->qual[copy_cnt].provider_id = od.oe_field_value
     FOR (idx = 1 TO (copy_cnt - 1))
       IF ((copy->qual[idx].provider_id=od.oe_field_value)
        AND (copy->qual[copy_cnt].order_complete_flag=expedite->qual[d.seq].order_complete_flag))
        copy->qual[idx].duplicate_ind = 1
        IF ((copy->qual[idx].chart_format_id=expedite->qual[d.seq].chart_format_id))
         copy->qual[idx].dup_format_ind = 1
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   FOOT  od.action_sequence
    IF (lastestseq=1)
     lastestseq = 0
    ENDIF
   FOOT  od.order_id
    do_nothing = 0
   WITH nocounter
  ;end select
 ENDIF
#end_consulting_providers
#start_order_providers
 SELECT INTO "nl:"
  ec.encntr_prsnl_r_cd
  FROM expedite_copy ec,
   (dummyt d  WITH seq = value(exp_cnt))
  PLAN (d
   WHERE (expedite->qual[d.seq].output_flag=6))
   JOIN (ec
   WHERE (ec.expedite_params_id=expedite->qual[d.seq].expedite_params_id)
    AND ec.encntr_prsnl_r_cd=orderdoc_type_cd)
  DETAIL
   copy_cnt = (copy_cnt+ 1),
   CALL echo(build("copy_cnt in if = : ",copy_cnt)), status = alterlist(copy->qual,copy_cnt),
   copy->qual[copy_cnt].duplicate_ind = 0, copy->qual[copy_cnt].dup_format_ind = 0, copy->qual[
   copy_cnt].expedite_params_id = expedite->qual[d.seq].expedite_params_id,
   copy->qual[copy_cnt].trigger_name = expedite->qual[d.seq].trigger_name, copy->qual[copy_cnt].
   chart_content_flag = expedite->qual[d.seq].chart_content_flag, copy->qual[copy_cnt].
   order_complete_flag = expedite->qual[d.seq].order_complete_flag,
   copy->qual[copy_cnt].chart_format_id = expedite->qual[d.seq].chart_format_id, copy->qual[copy_cnt]
   .params_name = expedite->qual[d.seq].params_name, copy->qual[copy_cnt].encntr_prsnl_r_cd =
   orderdoc_type_cd,
   copy->qual[copy_cnt].provider_id = order_provider_id, copy->qual[copy_cnt].order_level_ind = 1
   FOR (idx2 = 1 TO (copy_cnt - 1))
     IF ((copy->qual[copy_cnt].trigger_name=copy->qual[idx2].trigger_name)
      AND (copy->qual[copy_cnt].provider_id=copy->qual[idx2].provider_id))
      copy->qual[idx2].duplicate_ind = 1, copy->qual[idx2].dup_format_ind = 1
     ELSEIF ((copy->qual[copy_cnt].trigger_name != copy->qual[idx2].trigger_name)
      AND (copy->qual[copy_cnt].provider_id=copy->qual[idx2].provider_id)
      AND (copy->qual[copy_cnt].chart_format_id=copy->qual[idx2].chart_format_id)
      AND (copy->qual[idx2].order_level_ind=1))
      copy->qual[copy_cnt].duplicate_ind = 1, copy->qual[copy_cnt].dup_format_ind = 1
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
#end_order_providers
#start_copy_xref
 IF (copy_cnt > 0)
  SELECT INTO "nl:"
   od.output_dest_cd
   FROM (dummyt d1  WITH seq = value(copy_cnt)),
    device_xref x,
    device d,
    output_dest od,
    dummyt d2,
    remote_device rd,
    remote_device_type rdt
   PLAN (d1
    WHERE (((copy->qual[d1.seq].duplicate_ind=0)) OR ((copy->qual[d1.seq].duplicate_ind=1)
     AND (copy->qual[d1.seq].dup_format_ind=0))) )
    JOIN (x
    WHERE (x.parent_entity_id=copy->qual[d1.seq].provider_id)
     AND x.parent_entity_name="PRSNL")
    JOIN (d
    WHERE d.device_cd=x.device_cd)
    JOIN (od
    WHERE od.device_cd=d.device_cd)
    JOIN (d2)
    JOIN (rd
    WHERE rd.device_cd=od.device_cd)
    JOIN (rdt
    WHERE rdt.remote_dev_type_id=rd.remote_dev_type_id)
   DETAIL
    copy->qual[d1.seq].output_dest_cd = od.output_dest_cd, copy->qual[d1.seq].output_device_cd = rdt
    .output_format_cd, copy->qual[d1.seq].output_dest_name = od.name
    IF (d.name != od.name)
     copy->qual[d1.seq].device_name = d.name
    ENDIF
   WITH nocounter, outerjoin = d2
  ;end select
 ENDIF
#end_copy_xref
#start_manual_expedites
 SELECT INTO "nl:"
  em.person_id
  FROM expedite_manual em
  WHERE (((em.accession=request->accession)
   AND em.scope_flag=4) OR ((((em.encntr_id=request->encntr_id)
   AND em.scope_flag=2) OR ((em.person_id=request->person_id)
   AND em.scope_flag=1)) ))
  DETAIL
   exp_cnt = (exp_cnt+ 1), stat = alterlist(expedite->qual,exp_cnt), expedite->qual[exp_cnt].
   duplicate_ind = 0,
   expedite->qual[exp_cnt].dup_format_ind = 0, expedite->qual[exp_cnt].chart_content_flag = em
   .chart_content_flag, expedite->qual[exp_cnt].chart_format_id = em.chart_format_id,
   expedite->qual[exp_cnt].scope_flag = em.scope_flag, expedite->qual[exp_cnt].output_flag = 0,
   expedite->qual[exp_cnt].output_dest_cd = em.output_dest_cd,
   expedite->qual[exp_cnt].output_device_cd = em.output_device_cd, expedite->qual[exp_cnt].
   output_dest_name = em.output_dest_name, expedite->qual[exp_cnt].rrd_deliver_dt_tm = em
   .rrd_deliver_dt_tm,
   expedite->qual[exp_cnt].rrd_phone_suffix = em.rrd_phone_suffix, expedite->qual[exp_cnt].
   begin_dt_tm = em.begin_dt_tm, expedite->qual[exp_cnt].end_dt_tm = em.end_dt_tm,
   expedite->qual[exp_cnt].date_range_ind = em.date_range_ind
   IF (em.device_name != em.output_dest_name)
    expedite->qual[exp_cnt].device_name = em.device_name
   ENDIF
   expedite->qual[exp_cnt].manual_expedite_ind = 1, expedite->qual[exp_cnt].manual_provider_id = em
   .provider_id, expedite->qual[exp_cnt].manual_prov_role_cd = em.provider_role_cd,
   expedite->qual[exp_cnt].event_ind = em.event_ind, expedite->qual[exp_cnt].expedite_manual_id = em
   .expedite_manual_id
  WITH nocounter
 ;end select
 IF (exp_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  em.event_ind
  FROM (dummyt d1  WITH seq = value(exp_cnt)),
   expedite_manual_event eme
  PLAN (d1
   WHERE (expedite->qual[d1.seq].event_ind=1))
   JOIN (eme
   WHERE (eme.expedite_manual_id=expedite->qual[d1.seq].expedite_manual_id))
  HEAD d1.seq
   x = 0
  DETAIL
   x = (x+ 1)
   IF (mod(x,10)=1)
    stat = alterlist(expedite->qual[d1.seq].event_id_list,(x+ 9))
   ENDIF
   expedite->qual[d1.seq].event_id_list[x].em_event_id = eme.em_event_id, expedite->qual[d1.seq].
   event_id_list[x].event_id = eme.event_id, expedite->qual[d1.seq].event_id_list[x].result_status_cd
    = eme.result_status_cd
  FOOT  d1.seq
   stat = alterlist(expedite->qual[d1.seq].event_id_list,x)
  WITH nocounter
 ;end select
 FOR (i = 1 TO exp_cnt)
  IF ((expedite->qual[i].event_ind=1))
   SET e_cnt = size(expedite->qual[i].event_id_list,5)
   FOR (j = 1 TO e_cnt)
     DELETE  FROM expedite_manual_event eme
      WHERE (eme.em_event_id=expedite->qual[i].event_id_list[j].em_event_id)
       AND (eme.event_id=expedite->qual[i].event_id_list[j].event_id)
       AND (eme.result_status_cd=expedite->qual[i].event_id_list[j].result_status_cd)
      WITH nocounter
     ;end delete
   ENDFOR
  ENDIF
  DELETE  FROM expedite_manual em
   WHERE (em.expedite_manual_id=expedite->qual[i].expedite_manual_id)
    AND em.expedite_manual_id > 0
   WITH nocounter
  ;end delete
 ENDFOR
#end_manual_expedites
#start_log_triggers
 IF (log_level >= 3)
  SET log_nbr = (log_nbr+ 1)
  SET log_buffer[log_nbr] = "Expedite triggered by (reverse precedence order): "
  FOR (idx = 1 TO exp_cnt)
    IF ((expedite->qual[idx].order_complete_flag=1))
     SET ast_ind = " *"
    ELSE
     SET ast_ind = "  "
    ENDIF
    IF ((((expedite->qual[idx].duplicate_ind=0)) OR ((expedite->qual[idx].duplicate_ind=1)
     AND (expedite->qual[idx].dup_format_ind=0)))
     AND (expedite->qual[idx].output_dest_cd > 0))
     SET dup_log = concat(ast_ind," (send) ")
    ELSE
     SET dup_log = concat(ast_ind,fillstring(8," "))
    ENDIF
    IF ((expedite->qual[idx].output_flag=0)
     AND (expedite->qual[idx].manual_expedite_ind != 1))
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat(dup_log,expedite->qual[idx].trigger_name,
      " to assigned printer ",trim(expedite->qual[idx].output_dest_name),
      IF ((expedite->qual[idx].device_name > " ")) " ("
      ELSE " "
      ENDIF
      ,
      trim(expedite->qual[idx].device_name),
      IF ((expedite->qual[idx].device_name > " ")) ")"
      ELSE " "
      ENDIF
      ,"with format ",cnvtstring(expedite->qual[idx].chart_format_id))
    ELSEIF ((expedite->qual[idx].output_flag=1)
     AND (expedite->qual[idx].manual_expedite_ind != 1))
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat(dup_log,expedite->qual[idx].trigger_name,
      " to patient loc printer ",trim(expedite->qual[idx].output_dest_name),
      IF ((expedite->qual[idx].device_name > " ")) " ("
      ELSE " "
      ENDIF
      ,
      trim(expedite->qual[idx].device_name),
      IF ((expedite->qual[idx].device_name > " ")) " )"
      ELSE " "
      ENDIF
      ,"with format ",cnvtstring(expedite->qual[idx].chart_format_id))
    ELSEIF ((expedite->qual[idx].output_flag=2)
     AND (expedite->qual[idx].manual_expedite_ind != 1))
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat(dup_log,expedite->qual[idx].trigger_name,
      " to patient loc at time of order printer ",trim(expedite->qual[idx].output_dest_name),
      IF ((expedite->qual[idx].device_name > " ")) " ("
      ELSE " "
      ENDIF
      ,
      trim(expedite->qual[idx].device_name),
      IF ((expedite->qual[idx].device_name > " ")) " )"
      ELSE " "
      ENDIF
      ,"with format ",cnvtstring(expedite->qual[idx].chart_format_id))
    ELSEIF ((expedite->qual[idx].output_flag=4)
     AND (expedite->qual[idx].manual_expedite_ind != 1))
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat(dup_log,expedite->qual[idx].trigger_name,
      " to service resource printer ",trim(expedite->qual[idx].output_dest_name),
      IF ((expedite->qual[idx].device_name > " ")) " ("
      ELSE " "
      ENDIF
      ,
      trim(expedite->qual[idx].device_name),
      IF ((expedite->qual[idx].device_name > " ")) " )"
      ELSE " "
      ENDIF
      ,"with format ",cnvtstring(expedite->qual[idx].chart_format_id))
    ELSEIF ((expedite->qual[idx].output_flag=5)
     AND (expedite->qual[idx].manual_expedite_ind != 1))
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat(dup_log,expedite->qual[idx].trigger_name,
      " to organization printer ",trim(expedite->qual[idx].output_dest_name),
      IF ((expedite->qual[idx].device_name > " ")) " ("
      ELSE " "
      ENDIF
      ,
      trim(expedite->qual[idx].device_name),
      IF ((expedite->qual[idx].device_name > " ")) " )"
      ELSE " "
      ENDIF
      ,"with format ",cnvtstring(expedite->qual[idx].chart_format_id))
    ELSEIF ((expedite->qual[idx].output_flag=6)
     AND (expedite->qual[idx].manual_expedite_ind != 1))
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat(dup_log,expedite->qual[idx].trigger_name,
      " to selected provider printer ",trim(expedite->qual[idx].output_dest_name),
      IF ((expedite->qual[idx].device_name > " ")) " ("
      ELSE " "
      ENDIF
      ,
      trim(expedite->qual[idx].device_name),
      IF ((expedite->qual[idx].device_name > " ")) " )"
      ELSE " "
      ENDIF
      ,"with format ",cnvtstring(expedite->qual[idx].chart_format_id))
    ELSEIF ((expedite->qual[idx].output_flag=7)
     AND (expedite->qual[idx].manual_expedite_ind != 1))
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat(dup_log,expedite->qual[idx].trigger_name,
      " to order location printer ",trim(expedite->qual[idx].output_dest_name),
      IF ((expedite->qual[idx].device_name > " ")) " ("
      ELSE " "
      ENDIF
      ,
      trim(expedite->qual[idx].device_name),
      IF ((expedite->qual[idx].device_name > " ")) " )"
      ELSE " "
      ENDIF
      ,"with format ",cnvtstring(expedite->qual[idx].chart_format_id))
    ELSEIF ((expedite->qual[idx].output_flag=8)
     AND (expedite->qual[idx].manual_expedite_ind != 1))
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat(dup_log,expedite->qual[idx].trigger_name,
      " to patient temporary location printer ",trim(expedite->qual[idx].output_dest_name),
      IF ((expedite->qual[idx].device_name > " ")) " ("
      ELSE " "
      ENDIF
      ,
      trim(expedite->qual[idx].device_name),
      IF ((expedite->qual[idx].device_name > " ")) " )"
      ELSE " "
      ENDIF
      ,"with format ",cnvtstring(expedite->qual[idx].chart_format_id))
    ELSEIF ((expedite->qual[idx].manual_expedite_ind != 1))
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat(dup_log,expedite->qual[idx].trigger_name,
      " to printer ? with format ",cnvtstring(expedite->qual[idx].chart_format_id))
    ENDIF
  ENDFOR
  FOR (idx = 1 TO copy_cnt)
    IF ((((copy->qual[idx].duplicate_ind=0)) OR ((copy->qual[idx].duplicate_ind=1)
     AND (copy->qual[idx].dup_format_ind=0))) )
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = "Copy chart to:"
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat("  (send) Provider_id  ",trim(cnvtstring(copy->qual[idx].
        provider_id))," to assigned printer ",trim(copy->qual[idx].output_dest_name),
      IF ((copy->qual[idx].device_name > " ")) " ("
      ELSE " "
      ENDIF
      ,
      trim(copy->qual[idx].device_name),
      IF ((copy->qual[idx].device_name > " ")) ")"
      ELSE " "
      ENDIF
      ,"with format ",cnvtstring(copy->qual[idx].chart_format_id))
    ENDIF
  ENDFOR
  FOR (idx = 1 TO exp_cnt)
    IF ((expedite->qual[idx].manual_expedite_ind=1))
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat("Manual expedite sent to printer ",trim(expedite->qual[idx].
       output_dest_name),
      IF ((expedite->qual[idx].device_name > " ")) " ("
      ELSE " "
      ENDIF
      ,trim(expedite->qual[idx].device_name),
      IF ((expedite->qual[idx].device_name > " ")) ")"
      ELSE " "
      ENDIF
      ,
      "with format ",cnvtstring(expedite->qual[idx].chart_format_id))
    ENDIF
  ENDFOR
  IF (complete_order_ind=1)
   SET log_nbr = (log_nbr+ 1)
   SET log_buffer[log_nbr] = " * NOTE: Forced Cumulative Chart"
  ENDIF
 ENDIF
#start_chart_request
 FOR (idx2 = 1 TO exp_cnt)
   SET idx = ((exp_cnt+ 1) - idx2)
   SET log_nbr = (log_nbr+ 1)
   SET log_buffer[log_nbr] = concat("Chart_format_id: ",cnvtstring(expedite->qual[idx].
     chart_format_id))
   SET log_nbr = (log_nbr+ 1)
   SET log_buffer[log_nbr] = concat("Duplicate_ind: ",cnvtstring(expedite->qual[idx].duplicate_ind))
   SET log_nbr = (log_nbr+ 1)
   SET log_buffer[log_nbr] = concat("Dup_format_ind: ",cnvtstring(expedite->qual[idx].dup_format_ind)
    )
   SET log_nbr = (log_nbr+ 1)
   SET log_buffer[log_nbr] = concat("Output_dest_cd: ",cnvtstring(expedite->qual[idx].output_dest_cd)
    )
   SET log_nbr = (log_nbr+ 1)
   SET log_buffer[log_nbr] = concat("Order_complete_flag: ",cnvtstring(expedite->qual[idx].
     order_complete_flag))
   IF ((expedite->qual[idx].output_flag != 6))
    IF ((expedite->qual[idx].chart_format_id > 0))
     IF ((((expedite->qual[idx].duplicate_ind=0)) OR ((expedite->qual[idx].duplicate_ind=1)
      AND (expedite->qual[idx].dup_format_ind=0)))
      AND (expedite->qual[idx].output_dest_cd > 0))
      SET cr_cnt = (cr_cnt+ 1)
      IF (mod(cr_cnt,10)=1)
       SET stat = alterlist(request->qual,(cr_cnt+ 9))
      ENDIF
      IF ((expedite->qual[idx].manual_expedite_ind=1))
       SET request->qual[cr_cnt].scope_flag = expedite->qual[idx].scope_flag
      ELSEIF (powerform_processing_ind=1)
       SET request->qual[cr_cnt].scope_flag = 2
      ELSE
       SET request->qual[cr_cnt].scope_flag = 4
      ENDIF
      SET request->qual[cr_cnt].person_id = request->person_id
      SET request->qual[cr_cnt].encntr_id = request->encntr_id
      SET request->qual[cr_cnt].order_id = request->orders[1].order_id
      SET request->qual[cr_cnt].accession_nbr = request->accession
      SET request->qual[cr_cnt].chart_format_id = expedite->qual[idx].chart_format_id
      SET request->qual[cr_cnt].trigger_name = expedite->qual[idx].trigger_name
      SET request->qual[cr_cnt].date_range_ind = 1
      IF ((((expedite->qual[idx].chart_content_flag=0)) OR (complete_order_ind=1
       AND (expedite->qual[idx].order_complete_flag=1))) )
       SET request->qual[cr_cnt].begin_dt_tm = cnvtdatetime("01-JAN-1800 00:00:00.00")
      ELSE
       SET request->qual[cr_cnt].begin_dt_tm = request->event_dt_tm
      ENDIF
      SET request->qual[cr_cnt].end_dt_tm = request->event_dt_tm
      SET request->qual[cr_cnt].chart_pending_flag = 2
      SET request->qual[cr_cnt].output_dest_cd = expedite->qual[idx].output_dest_cd
      SET request->qual[cr_cnt].output_device_cd = expedite->qual[idx].output_device_cd
      SET request->qual[cr_cnt].rrd_deliver_dt_tm = cnvtdatetime(curdate,curtime3)
      SET request->qual[cr_cnt].rrd_phone_suffix = expedite->qual[idx].rrd_phone_suffix
      SET request->qual[cr_cnt].request_type = 2
      SET request->qual[cr_cnt].event_ind = expedite->qual[idx].event_ind
      IF ((expedite->qual[idx].event_ind=1))
       SET nbr_of_events = size(expedite->qual[idx].event_id_list,5)
       SET stat = alterlist(request->qual[cr_cnt].event_id_list,nbr_of_events)
       FOR (e_cnt = 1 TO nbr_of_events)
        SET request->qual[cr_cnt].event_id_list[e_cnt].event_id = expedite->qual[idx].event_id_list[
        e_cnt].event_id
        SET request->qual[cr_cnt].event_id_list[e_cnt].result_status_cd = expedite->qual[idx].
        event_id_list[e_cnt].result_status_cd
       ENDFOR
      ENDIF
     ENDIF
     IF ((expedite->qual[idx].manual_provider_id > 0))
      SET request->qual[cr_cnt].prsnl_person_id = expedite->qual[idx].manual_provider_id
      SET request->qual[cr_cnt].prsnl_person_r_cd = expedite->qual[idx].manual_prov_role_cd
      SET request->qual[cr_cnt].rrd_deliver_dt_tm = expedite->qual[idx].rrd_deliver_dt_tm
      SET request->qual[cr_cnt].rrd_phone_suffix = expedite->qual[idx].rrd_phone_suffix
      SET request->qual[cr_cnt].begin_dt_tm = expedite->qual[idx].begin_dt_tm
      SET request->qual[cr_cnt].end_dt_tm = expedite->qual[idx].end_dt_tm
      SET request->qual[cr_cnt].date_range_ind = expedite->qual[idx].date_range_ind
     ELSE
      SET stat = uar_get_meaning_by_codeset(333,"ADMITDOC",1,admitdoc_type_cd)
      SELECT INTO "nl:"
       epr.prsnl_person_id, epr.encntr_prsnl_r_cd
       FROM encntr_prsnl_reltn epr
       WHERE (request->encntr_id=epr.encntr_id)
        AND epr.encntr_prsnl_r_cd=admitdoc_type_cd
        AND epr.active_ind=1
        AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       DETAIL
        request->qual[cr_cnt].prsnl_person_id = epr.prsnl_person_id, request->qual[cr_cnt].
        prsnl_person_r_cd = epr.encntr_prsnl_r_cd
        FOR (idx = 1 TO copy_cnt)
          IF ((copy->qual[idx].provider_id=epr.prsnl_person_id))
           copy->qual[idx].duplicate_ind = 1, copy->qual[idx].dup_format_ind = 1
          ENDIF
        ENDFOR
       WITH nocounter
      ;end select
     ENDIF
    ELSE
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat("Chart format missing for parameter ",expedite->qual[idx].
      params_name," under trigger ",expedite->qual[idx].trigger_name," so no expedite sent.")
    ENDIF
   ENDIF
 ENDFOR
 FOR (idx2 = 1 TO copy_cnt)
   IF ((copy->qual[idx2].chart_format_id > 0))
    IF ((((copy->qual[idx2].duplicate_ind=0)) OR ((copy->qual[idx2].duplicate_ind=1)
     AND (copy->qual[idx2].dup_format_ind=0)))
     AND (copy->qual[idx2].output_dest_cd > 0))
     SET cr_cnt = (cr_cnt+ 1)
     IF (mod(cr_cnt,10)=1)
      SET stat = alterlist(request->qual,(cr_cnt+ 9))
     ENDIF
     IF (powerform_processing_ind=1)
      SET request->qual[cr_cnt].scope_flag = 2
     ELSE
      SET request->qual[cr_cnt].scope_flag = 4
     ENDIF
     SET request->qual[cr_cnt].person_id = request->person_id
     SET request->qual[cr_cnt].encntr_id = request->encntr_id
     SET request->qual[cr_cnt].order_id = request->orders[1].order_id
     SET request->qual[cr_cnt].accession_nbr = request->accession
     SET request->qual[cr_cnt].chart_format_id = copy->qual[idx2].chart_format_id
     SET request->qual[cr_cnt].trigger_name = copy->qual[idx2].trigger_name
     SET request->qual[cr_cnt].date_range_ind = 1
     IF ((((copy->qual[idx2].chart_content_flag=0)) OR (complete_order_ind=1
      AND (copy->qual[idx2].order_complete_flag=1))) )
      SET request->qual[cr_cnt].begin_dt_tm = cnvtdatetime("01-JAN-1800 00:00:00.00")
     ELSE
      SET request->qual[cr_cnt].begin_dt_tm = request->event_dt_tm
     ENDIF
     SET request->qual[cr_cnt].end_dt_tm = request->event_dt_tm
     SET request->qual[cr_cnt].chart_pending_flag = 2
     SET request->qual[cr_cnt].output_dest_cd = copy->qual[idx2].output_dest_cd
     SET request->qual[cr_cnt].output_device_cd = copy->qual[idx2].output_device_cd
     SET request->qual[cr_cnt].rrd_deliver_dt_tm = cnvtdatetime(curdate,curtime3)
     SET request->qual[cr_cnt].rrd_phone_suffix = expedite->qual[idx].rrd_phone_suffix
     SET request->qual[cr_cnt].request_type = 2
     SET request->qual[cr_cnt].prsnl_person_id = copy->qual[idx2].provider_id
     SET request->qual[cr_cnt].prsnl_person_r_cd = copy->qual[idx2].encntr_prsnl_r_cd
    ENDIF
   ELSE
    SET log_nbr = (log_nbr+ 1)
    SET log_buffer[log_nbr] = concat("Chart format missing for parameter ",copy->qual[idx2].
     params_name," under trigger ",copy->qual[idx2].trigger_name,
     " so no additional copy expedite sent.")
   ENDIF
 ENDFOR
 SET stat = alterlist(request->qual,cr_cnt)
 IF (cr_cnt > 0)
  EXECUTE cp_add_chart_request
  IF ((reply->status_data.status="S"))
   IF (log_level >= 2)
    SET log_nbr = (log_nbr+ 1)
    SET log_buffer[log_nbr] = concat(cnvtstring(cr_cnt,2),
     "chart request(s) added with chart_request_ids: ")
    FOR (idx = 1 TO cr_cnt)
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = concat("  ",cnvtstring(reply->qual[idx].chart_request_id))
    ENDFOR
   ENDIF
   COMMIT
  ELSE
   IF (log_level >= 1)
    SET error_ind = 1
    IF (log_level=1
     AND acc_logged_ind=0)
     EXECUTE FROM start_log_accession TO end_log_accession
    ENDIF
    SET log_nbr = (log_nbr+ 1)
    SET log_buffer[log_nbr] = "Failure adding chart_requests"
   ENDIF
   ROLLBACK
  ENDIF
 ELSE
  IF (log_level >= 1)
   SET log_nbr = (log_nbr+ 1)
   SET log_buffer[log_nbr] = "No chart_requests sent"
  ENDIF
 ENDIF
#end_chart_request
#exit_script
#start_error_check
 IF (log_level >= 1)
  SET error_check = 1
  WHILE (error_check > 0)
    SET error_check = error(error_msg,0)
    SET msg_size = size(error_msg,1)
    IF (error_check != 0)
     SET error_ind = 1
     IF (log_level=1
      AND acc_logged_ind=0)
      EXECUTE FROM start_log_accession TO end_log_accession
     ENDIF
     SET log_nbr = (log_nbr+ 1)
     SET log_buffer[log_nbr] = trim(error_msg)
     IF (msg_size BETWEEN 100 AND 200)
      SET log_nbr = (log_nbr+ 1)
      SET log_buffer[log_nbr] = substring(101,100,error_msg)
     ENDIF
     IF (msg_size > 200)
      SET log_nbr = (log_nbr+ 1)
      SET log_buffer[log_nbr] = substring(101,100,error_msg)
      SET log_nbr = (log_nbr+ 1)
      SET log_buffer[log_nbr] = substring(201,55,error_msg)
     ENDIF
    ENDIF
  ENDWHILE
 ENDIF
#end_error_check
 IF (log_level >= 1)
  SELECT INTO value(file_name)
   d.seq
   FROM dummyt d
   DETAIL
    FOR (x = 1 TO log_nbr)
      col 1, log_buffer[x], row + 1
    ENDFOR
   WITH maxcol = 150, format = variable, noformfeed,
    maxrow = 1, noheading, append
  ;end select
 ENDIF
#expedites_off
#end_of_script
END GO
