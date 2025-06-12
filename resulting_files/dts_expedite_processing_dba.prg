CREATE PROGRAM dts_expedite_processing:dba
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 qual[*]
      2 chart_request_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 FREE RECORD expedite
 RECORD expedite(
   1 qual[*]
     2 duplicate_ind = i2
     2 dup_template_ind = i2
     2 expedite_trigger_id = f8
     2 trigger_name = vc
     2 precedence_seq = i4
     2 expedite_params_id = f8
     2 params_name = vc
     2 coded_resp_ind = i2
     2 chart_content_flag = i2
     2 template_id = f8
     2 scope_flag = i2
     2 output_flag = i2
     2 output_dest_cd = f8
     2 output_device_cd = f8
     2 device_name = vc
     2 output_dest_name = vc
     2 service_resource_cd = f8
     2 copy_ind = i2
     2 manual_expedite_ind = i2
     2 manual_requestor_id = f8
     2 manual_provider_id = f8
     2 manual_prov_role_cd = f8
     2 event_ind = i2
     2 expedite_manual_id = f8
     2 rrd_deliver_dt_tm = dq8
     2 rrd_phone_suffix = c30
     2 event_id_list[*]
       3 em_event_id = f8
       3 event_id = f8
       3 result_status_cd = f8
     2 exp_exclude_ind = i2
     2 expired_do_not_print = i2
     2 prsnl_person_id = f8
     2 prsnl_person_r_cd = f8
     2 user_role_profile = vc
     2 sending_org_id = f8
     2 sender_email = vc
     2 dms_service_ident = vc
 )
 FREE RECORD copy
 RECORD copy(
   1 qual[*]
     2 duplicate_ind = i2
     2 dup_template_ind = i2
     2 trigger_name = vc
     2 expedite_params_id = f8
     2 params_name = vc
     2 template_id = f8
     2 chart_content_flag = i2
     2 encntr_prsnl_r_cd = f8
     2 provider_id = f8
     2 output_dest_cd = f8
     2 output_device_cd = f8
     2 device_name = vc
     2 output_dest_name = vc
     2 sending_org_id = f8
     2 sender_email = vc
     2 dms_service_ident = vc
 )
 FREE RECORD log_rec
 RECORD log_rec(
   1 qual[*]
     2 message = vc
   1 message_counter = i4
 )
 FREE RECORD log_debug_rec
 RECORD log_debug_rec(
   1 qual[*]
     2 message = vc
   1 message_counter = i4
 )
 DECLARE getpatientlocationattimeoforder(null) = null
 DECLARE getprocessmanualexpedites(null) = i2
 DECLARE getadmittingprovider(null) = null
 DECLARE locationdestinations(null) = null
 DECLARE serviceresourcedestinations(null) = null
 DECLARE organizationdestinations(null) = null
 DECLARE providerdestinations(null) = null
 DECLARE copytodestinations(null) = null
#start_init
 DECLARE log_buffer_growth = i4 WITH constant(50)
 DECLARE log_debug_buffer_growth = i4 WITH constant(50)
 SET log_rec->message_counter = 0
 SET log_debug_rec->message_counter = 0
 SET trace = errorclear
 SET trace = errorclearcom
 SET order_total = size(request->orders,5)
 SET order_provider_id = 0.0
 SET assay_total = 0
 SET assay_cnt = 0
 SET cur_total = 0
 SET exp_cnt = 0
 SET e_cnt = 0
 SET copy_cnt = 0
 SET copy_ind = 0
 SET cr_cnt = 0
 DECLARE rr_cnt = i4 WITH noconstant(0)
 SET tree_cnt = 0
 DECLARE child_cd = f8 WITH noconstant(0.0)
 DECLARE lowest_child_cd = f8 WITH noconstant(0.0)
 SET sr_tree_lvl = 0
 SET sr_lvl = 0
 SET new_sr_ind = 0
 SET idx = 0
 SET idx2 = 0
 SET idx3 = 0
 DECLARE location_cd = f8 WITH noconstant(0.0)
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
 DECLARE et_where = vc WITH noconstant(" ")
 DECLARE et_location_parser = vc WITH noconstant(" ")
 DECLARE et_ordercomplete_parser = vc WITH noconstant(" ")
 DECLARE et_provider_parser = vc WITH noconstant(" ")
 DECLARE loc_output_dest_cd = f8 WITH noconstant(0.0)
 SET loc_device_name = fillstring(20," ")
 SET loc_output_dest_name = fillstring(20," ")
 DECLARE loc_dms_service_ident = vc WITH noconstant("")
 DECLARE loc_temp_output_dest_cd = f8 WITH noconstant(0.0)
 SET loc_temp_device_name = fillstring(20," ")
 SET loc_temp_output_dest_name = fillstring(20," ")
 DECLARE loc_temp_dms_service_ident = vc WITH noconstant("")
 DECLARE sr_output_dest_cd = f8 WITH noconstant(0.0)
 SET sr_output_dest_name = fillstring(20," ")
 SET sr_output_device_name = fillstring(20," ")
 DECLARE sr_dms_service_ident = vc WITH noconstant("")
 DECLARE pat_output_dest_cd = f8 WITH noconstant(0.0)
 SET pat_device_name = fillstring(20," ")
 SET pat_output_dest_name = fillstring(20," ")
 DECLARE pat_dms_service_ident = vc WITH noconstant("")
 DECLARE ord_output_dest_cd = f8 WITH noconstant(0.0)
 SET ord_device_name = fillstring(20," ")
 SET ord_output_dest_name = fillstring(20," ")
 DECLARE ord_dms_service_ident = vc WITH noconstant("")
 DECLARE provider_output_dest_cd = f8 WITH noconstant(0.0)
 SET provider_output_device_name = fillstring(20," ")
 SET provider_output_dest_name = fillstring(20," ")
 DECLARE provider_dms_service_ident = vc WITH noconstant("")
 DECLARE org_output_dest_cd = f8 WITH noconstant(0.0)
 SET org_output_dest_name = fillstring(20," ")
 SET org_output_device_name = fillstring(20," ")
 DECLARE org_dms_service_ident = vc WITH noconstant("")
 DECLARE consult_doc_cd = f8 WITH noconstant(0.0)
 DECLARE order_doc_cd = f8 WITH noconstant(0.0)
 DECLARE admitdoc_type_cd = f8 WITH noconstant(0.0)
 DECLARE params_id = f8 WITH noconstant(0.0)
 SET add_cons = 0
 SET sr_dest_found_ind = 0
 SET coded_resp_ind = 0
 SET num_coded_resp = 0
 SET max_coded_resp = 0
 SET cur_coded_resp = 0
 DECLARE expedite_log = vc WITH protect, constant(concat("cer_temp:expedites",format(curdate,
    "MMDD;;d"),".log"))
 SET error_msg = fillstring(255," ")
 SET msg_size = 0
 SET error_check = error(error_msg,1)
 SET send_log = fillstring(10," ")
 SET on_ind = 0
 SET log_level = 0
 SET no_chart_log_nbr = 1
 SET no_chart_log_buffer[500] = fillstring(100," ")
 SET discharged_status = 0
 SET icnt = 0
 SET icnt2 = 0
 SET author_list = fillstring(50," ")
 SET author_cnt = 0
 SET consult_doc_ind = 0
 SET order_doc_ind = 0
 DECLARE consult_encntr_cd = f8 WITH constant(uar_get_code_by("MEANING",22333,"CONSENCNTR")), protect
 DECLARE consult_order_cd = f8 WITH constant(uar_get_code_by("MEANING",22333,"CONSORDER")), protect
 DECLARE intsecemail_cd = f8 WITH constant(uar_get_code_by("MEANING",43,"INTSECEMAIL")), protect
 DECLARE organization_entity = vc WITH protect, constant("ORGANIZATION")
 DECLARE cr_destination_xref_check = i2 WITH noconstant(checkdic("CR_DESTINATION_XREF","T",0))
 SET stat = uar_get_meaning_by_codeset(333,"CONSULTDOC",1,consult_doc_cd)
 SET stat = uar_get_meaning_by_codeset(333,"ORDERDOC",1,order_doc_cd)
 SET stat = uar_get_meaning_by_codeset(333,"ADMITDOC",1,admitdoc_type_cd)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE iprocessexpedites = i2 WITH constant(getprocessmanualexpedites(null)), protect
 DECLARE size_action_prsnl_qual = i4
 DECLARE p = i4
 DECLARE addexpreportrequest(null) = null
 DECLARE addcopyreportrequest(null) = null
 DECLARE logrequest(null) = null
 SET powerform_processing_ind = 0
 DECLARE admitdoc_id = f8 WITH noconstant(0.0)
 DECLARE admitdoc_exp_ind = i2 WITH noconstant(0)
 SET reply->status_data.status = "F"
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
 GO TO check_logical_domain
#start_log_accession
 SET acc_logged_ind = 1
 CALL writelogmessage(fillstring(100,"*"))
 CALL writelogmessage(concat("Expedite Processing called by ",request->calling_program))
 CALL writelogmessage(format(cnvtdatetime(sysdate),"DD-MMM-YYYY HH:MM:SS;;D"))
 CALL writelogmessage(concat("person_id: ",cnvtstring(request->person_id)))
 CALL writelogmessage(concat("encntr_id: ",cnvtstring(request->encntr_id)))
 CALL writelogmessage(concat("accession: ",request->accession))
#end_log_accession
#check_logical_domain
 DECLARE logical_domain_enabled_ind = i4 WITH noconstant(0)
 DECLARE logical_domain_id = f8 WITH noconstant(0.0)
 DECLARE logical_domain_name = vc WITH noconstant(" ")
 DECLARE logical_domain_trigger = vc WITH noconstant("1=1")
 DECLARE logical_domain_params = vc WITH noconstant("1=1")
 SELECT INTO "nl:"
  d.info_number
  FROM dm_info d
  WHERE d.info_domain="CLINICAL REPORTING XR"
   AND d.info_name="Enable Logical Domain XR PFMT"
  DETAIL
   logical_domain_enabled_ind = d.info_number
  WITH nocounter
 ;end select
 IF (logical_domain_enabled_ind=1)
  CALL writedebuglogmessage("Logical Domain XR PFMT is enabled.")
  SELECT INTO "nl:"
   ld.logical_domain_id, ld.mnemonic
   FROM person p,
    logical_domain ld
   PLAN (p
    WHERE (p.person_id=request->person_id))
    JOIN (ld
    WHERE ld.logical_domain_id=p.logical_domain_id)
   HEAD REPORT
    do_nothing = 0
   DETAIL
    logical_domain_id = ld.logical_domain_id, logical_domain_name = ld.mnemonic
   WITH nocounter
  ;end select
  SET logical_domain_trigger = concat("et.logical_domain_id = ",cnvtstring(logical_domain_id))
  SET logical_domain_params = concat("ep.logical_domain_id = ",cnvtstring(logical_domain_id))
  CALL writedebuglogmessage(concat("Patient logical domain: ",logical_domain_name," [",trim(
     cnvtstring(logical_domain_id)),"]"))
  SELECT DISTINCT INTO "nl:"
   et.name
   FROM expedite_trigger et
   PLAN (et
    WHERE et.active_ind=1
     AND et.logical_domain_id != logical_domain_id)
   ORDER BY et.name
   HEAD REPORT
    CALL writedebuglogmessage("  Triggers in different logical domain are not processed: ")
   HEAD et.name
    CALL writedebuglogmessage(concat("  - ",trim(et.name)))
   DETAIL
    do_nothing = 0
   WITH nocounter
  ;end select
 ENDIF
 SELECT DISTINCT INTO "nl:"
  ep.template_id, ep.name, et.name
  FROM expedite_trigger et,
   expedite_params_r epr,
   expedite_params ep
  PLAN (ep
   WHERE ep.template_id=0
    AND ep.expedite_params_id > 0
    AND parser(logical_domain_params))
   JOIN (epr
   WHERE epr.expedite_params_id=ep.expedite_params_id)
   JOIN (et
   WHERE et.expedite_trigger_id=epr.expedite_trigger_id
    AND et.active_ind=1
    AND parser(logical_domain_trigger))
  ORDER BY et.name
  HEAD REPORT
   CALL writedebuglogmessage("  Triggers without template are not processed: ")
  HEAD et.name
   CALL writedebuglogmessage(build2("  - ",trim(et.name)," [",trim(ep.name),"]"))
  DETAIL
   do_nothing = 0
  WITH nocounter
 ;end select
#start_check_pf
 IF (order_total > 0)
  IF ((request->orders[1].reference_task_id > 0))
   SET powerform_processing_ind = 1
  ENDIF
  IF ((request->orders[1].event_id > 0))
   SET powerform_processing_ind = 1
  ENDIF
 ENDIF
#end_check_pf
 DECLARE dest_routing_enabled_ind = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  d.info_number
  FROM dm_info d
  WHERE d.info_domain="CLINICAL REPORTING XR"
   AND d.info_name="DESTINATION_ROUTING"
  DETAIL
   dest_routing_enabled_ind = d.info_number
  WITH nocounter
 ;end select
 IF (dest_routing_enabled_ind=1)
  CALL writedebuglogmessage("Destination Routing is enbled, going to look at CR_DESTINATION_XREF.")
 ELSE
  CALL writedebuglogmessage("Destination Routing is not enbled, going to fall back to DEVICE_XREF.")
 ENDIF
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
    IF ((request->orders[idx].order_id > 0)
     AND (request->orders[idx].order_complete_ind=0))
     CALL writelogmessage(concat("Order not complete (order_id: ",cnvtstring(request->orders[idx].
        order_id),")"))
    ENDIF
  ENDFOR
 ENDIF
#end_find_max
#start_find_ord_loc
 SELECT INTO "nl:"
  oa.order_locn_cd
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
    AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
    AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
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
 CALL getpatientlocationattimeoforder(null)
#start_find_cur_loc
 SELECT INTO "nl:"
  e.organization_id
  FROM encounter e
  WHERE (e.encntr_id=request->encntr_id)
   AND e.encntr_id > 0
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
  IF (discharged_status=0)
   CALL writelogmessage("Patient is non-discharged")
  ELSE
   CALL writelogmessage("Patient is discharged")
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
     SET tree_cnt += 1
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
 SET et_location_parser = concat(" ((et.location_cd in",
  " (0, encntr->cur_loc_facility_cd, encntr->cur_loc_building_cd,",
  "  encntr->cur_loc_nurse_unit_cd, encntr->cur_loc_room_cd,","  encntr->cur_loc_bed_cd) and",
  " et.location_context_flag in (0,1,6,8,9))",
  " or (et.location_cd in"," (0, encntr->pat_loc_facility_cd, encntr->pat_loc_building_cd,",
  "  encntr->pat_loc_nurse_unit_cd, encntr->pat_loc_room_cd, ","  encntr->pat_loc_bed_cd) and",
  " et.location_context_flag in (0,2,7,8,9))",
  " or (et.location_cd in"," (0, encntr->ord_loc_facility_cd, encntr->ord_loc_building_cd,",
  " encntr->ord_loc_nurse_unit_cd, encntr->ord_loc_room_cd, "," encntr->ord_loc_bed_cd) and",
  " et.location_context_flag in (0,3,6,7,9)))")
 FOR (idx = 1 TO order_total)
   IF ((request->orders[idx].order_complete_ind=0))
    SET et_ordercomplete_parser = " and et.order_complete_flag = 0"
    GO TO start_find_provider
   ENDIF
 ENDFOR
#end_et_where
#start_find_provider
 IF ((request->orders[1].order_id > 0))
  SELECT INTO "nl:"
   oa.order_provider_id
   FROM order_action oa
   WHERE (oa.order_id=request->orders[1].order_id)
    AND oa.action_sequence=1
   HEAD REPORT
    order_provider_id = oa.order_provider_id
   WITH nocounter
  ;end select
  SET et_provider_parser = " and (et.provider_id = 0 or et.provider_id = order_provider_id)"
 ELSEIF ((request->orders[1].event_id > 0))
  SET size_action_prsnl_qual = size(request->orders[1].action_prsnl_qual,5)
  CALL writelogmessage(build("finding action_prsnl_qual and its size = ",size_action_prsnl_qual))
  FOR (p = 1 TO size_action_prsnl_qual)
    CALL writelogmessage("--------------")
    CALL writelogmessage(build("action_type_mean = ",request->orders[1].action_prsnl_qual[p].
      action_type_mean))
    CALL writelogmessage(build("action_dt_tm = ",format(request->orders[1].action_prsnl_qual[p].
       action_dt_tm,"mm/dd/yyyy hh:mm:ss;;d")))
    CALL writelogmessage(build("action_prsnl_id = ",request->orders[1].action_prsnl_qual[p].
      action_prsnl_id))
    CALL writelogmessage(build("action_status_mean = ",request->orders[1].action_prsnl_qual[p].
      action_status_mean))
    CALL writelogmessage(build("proxy_prsnl_id = ",request->orders[1].action_prsnl_qual[p].
      proxy_prsnl_id))
    IF ((request->orders[1].action_prsnl_qual[p].action_type_mean="SIGN"))
     SET author_cnt += 1
     IF (author_cnt=1)
      SET order_provider_id = request->orders[1].action_prsnl_qual[p].action_prsnl_id
      SET author_list = build("(",cnvtstring(order_provider_id))
     ELSE
      SET author_list = build(author_list,",",cnvtstring(request->orders[1].action_prsnl_qual[p].
        action_prsnl_id))
     ENDIF
    ENDIF
  ENDFOR
  IF (author_cnt >= 1)
   SET author_list = build(author_list,")")
   SET et_provider_parser = build(" and (et.provider_id = 0 or et.provider_id in ",trim(author_list),
    ")")
  ENDIF
 ENDIF
#end_find_provider
#start_find_dta
 IF ((request->orders[1].event_id > 0))
  SELECT INTO "nl:"
   dta.event_cd, dta.task_assay_cd
   FROM discrete_task_assay dta
   WHERE (dta.event_cd=request->orders[1].event_cd)
   DETAIL
    request->orders[1].assays[1].task_assay_cd = dta.task_assay_cd
   WITH nocounter
  ;end select
 ENDIF
#end_find_dta
 CALL echorecord(request)
 CALL echorecord(encntr)
 CALL echorecord(tree)
 CALL echorecord(expedite)
#start_triggers
 SET et_where = concat(trim(et_location_parser),trim(et_ordercomplete_parser),trim(et_provider_parser
   ))
 CALL echo(build("et_where = ",et_where))
 SELECT INTO "nl:"
  epr.precedence_seq, ep.template_id, ep.output_flag,
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
    AND parser(logical_domain_trigger)
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
   WHERE ep.expedite_params_id=epr.expedite_params_id
    AND ep.template_id > 0
    AND parser(logical_domain_params))
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
    exp_cnt += 1, stat = alterlist(expedite->qual,exp_cnt), expedite->qual[exp_cnt].duplicate_ind = 0,
    expedite->qual[exp_cnt].dup_template_ind = 0, expedite->qual[exp_cnt].expedite_trigger_id = et
    .expedite_trigger_id, expedite->qual[exp_cnt].trigger_name = et.name,
    expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq, expedite->qual[exp_cnt].
    expedite_params_id = ep.expedite_params_id, expedite->qual[exp_cnt].params_name = ep.name,
    expedite->qual[exp_cnt].coded_resp_ind = et.coded_resp_ind, expedite->qual[exp_cnt].
    chart_content_flag = ep.chart_content_flag, expedite->qual[exp_cnt].template_id = ep.template_id,
    expedite->qual[exp_cnt].output_flag = ep.output_flag, expedite->qual[exp_cnt].output_dest_cd = ep
    .output_dest_cd, expedite->qual[exp_cnt].output_device_cd = ep.output_device_cd,
    expedite->qual[exp_cnt].service_resource_cd = tree->qual[d3.seq].lowest_child_cd, expedite->qual[
    exp_cnt].copy_ind = ep.copy_ind, expedite->qual[exp_cnt].exp_exclude_ind = ep.exp_prov_ind,
    expedite->qual[exp_cnt].sending_org_id = validate(ep.sending_org_id,0.0)
    IF (ep.copy_ind=1)
     copy_ind = 1
    ENDIF
    CASE (ep.output_flag)
     OF 0:
      assigned_ind = 1
     OF 1:
      cur_loc_xref_ind = 1
     OF 2:
      pat_loc_xref_ind = 1
     OF 3:
      cur_loc_xref_ind = 1,pat_loc_xref_ind = 1,ord_loc_xref_ind = 1,
      exp_cnt += 1,stat = alterlist(expedite->qual,exp_cnt),expedite->qual[exp_cnt].duplicate_ind = 0,
      expedite->qual[exp_cnt].dup_template_ind = 0,expedite->qual[exp_cnt].expedite_trigger_id = et
      .expedite_trigger_id,expedite->qual[exp_cnt].trigger_name = et.name,
      expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq,expedite->qual[exp_cnt].
      expedite_params_id = ep.expedite_params_id,expedite->qual[exp_cnt].params_name = ep.name,
      expedite->qual[exp_cnt].chart_content_flag = ep.chart_content_flag,expedite->qual[exp_cnt].
      template_id = ep.template_id,expedite->qual[exp_cnt].output_flag = 2,
      expedite->qual[exp_cnt].copy_ind = ep.copy_ind,expedite->qual[exp_cnt].exp_exclude_ind = ep
      .exp_prov_ind,expedite->qual[exp_cnt].sending_org_id = validate(ep.sending_org_id,0.0),
      exp_cnt += 1,stat = alterlist(expedite->qual,exp_cnt),expedite->qual[exp_cnt].duplicate_ind = 0,
      expedite->qual[exp_cnt].dup_template_ind = 0,expedite->qual[exp_cnt].expedite_trigger_id = et
      .expedite_trigger_id,expedite->qual[exp_cnt].trigger_name = et.name,
      expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq,expedite->qual[exp_cnt].
      expedite_params_id = ep.expedite_params_id,expedite->qual[exp_cnt].params_name = ep.name,
      expedite->qual[exp_cnt].chart_content_flag = ep.chart_content_flag,expedite->qual[exp_cnt].
      template_id = ep.template_id,expedite->qual[exp_cnt].output_flag = 7,
      expedite->qual[exp_cnt].copy_ind = ep.copy_ind,expedite->qual[exp_cnt].exp_exclude_ind = ep
      .exp_prov_ind,expedite->qual[exp_cnt].sending_org_id = validate(ep.sending_org_id,0.0),
      exp_cnt += 1,stat = alterlist(expedite->qual,exp_cnt),expedite->qual[exp_cnt].duplicate_ind = 0,
      expedite->qual[exp_cnt].dup_template_ind = 0,expedite->qual[exp_cnt].expedite_trigger_id = et
      .expedite_trigger_id,expedite->qual[exp_cnt].trigger_name = et.name,
      expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq,expedite->qual[exp_cnt].
      expedite_params_id = ep.expedite_params_id,expedite->qual[exp_cnt].params_name = ep.name,
      expedite->qual[exp_cnt].chart_content_flag = ep.chart_content_flag,expedite->qual[exp_cnt].
      template_id = ep.template_id,expedite->qual[exp_cnt].output_flag = 1,
      expedite->qual[exp_cnt].copy_ind = ep.copy_ind,expedite->qual[exp_cnt].exp_exclude_ind = ep
      .exp_prov_ind,expedite->qual[exp_cnt].sending_org_id = validate(ep.sending_org_id,0.0)
     OF 4:
      sr_xref_ind = 1,expedite->qual[exp_cnt].output_dest_cd = 0
     OF 5:
      org_xref_ind = 1,expedite->qual[exp_cnt].output_dest_cd = 0
     OF 6:
      provider_xref_ind = 1,expedite->qual[exp_cnt].output_dest_cd = 0
     OF 7:
      ord_loc_xref_ind = 1
     OF 8:
      cur_loc_temp_xref_ind = 1
     OF 9:
      cur_loc_temp_xref_ind = 1,cur_loc_xref_ind = 1,exp_cnt += 1,
      stat = alterlist(expedite->qual,exp_cnt),expedite->qual[exp_cnt].duplicate_ind = 0,expedite->
      qual[exp_cnt].dup_template_ind = 0,
      expedite->qual[exp_cnt].expedite_trigger_id = et.expedite_trigger_id,expedite->qual[exp_cnt].
      trigger_name = et.name,expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq,
      expedite->qual[exp_cnt].expedite_params_id = ep.expedite_params_id,expedite->qual[exp_cnt].
      params_name = ep.name,expedite->qual[exp_cnt].chart_content_flag = ep.chart_content_flag,
      expedite->qual[exp_cnt].template_id = ep.template_id,expedite->qual[exp_cnt].output_flag = 1,
      expedite->qual[exp_cnt].copy_ind = ep.copy_ind,
      expedite->qual[exp_cnt].exp_exclude_ind = ep.exp_prov_ind,expedite->qual[exp_cnt].
      sending_org_id = validate(ep.sending_org_id,0.0),exp_cnt += 1,
      stat = alterlist(expedite->qual,exp_cnt),expedite->qual[exp_cnt].duplicate_ind = 0,expedite->
      qual[exp_cnt].dup_template_ind = 0,
      expedite->qual[exp_cnt].expedite_trigger_id = et.expedite_trigger_id,expedite->qual[exp_cnt].
      trigger_name = et.name,expedite->qual[exp_cnt].precedence_seq = epr.precedence_seq,
      expedite->qual[exp_cnt].expedite_params_id = ep.expedite_params_id,expedite->qual[exp_cnt].
      params_name = ep.name,expedite->qual[exp_cnt].chart_content_flag = ep.chart_content_flag,
      expedite->qual[exp_cnt].template_id = ep.template_id,expedite->qual[exp_cnt].output_flag = 8,
      expedite->qual[exp_cnt].copy_ind = ep.copy_ind,
      expedite->qual[exp_cnt].exp_exclude_ind = ep.exp_prov_ind,expedite->qual[exp_cnt].
      sending_org_id = validate(ep.sending_org_id,0.0)
    ENDCASE
   ENDIF
  WITH nocounter
 ;end select
 IF (exp_cnt=0)
  IF (log_level >= 2)
   IF (log_level=2
    AND acc_logged_ind=0)
    EXECUTE FROM start_log_accession TO end_log_accession
   ENDIF
   CALL writelogmessage("No expedite triggered")
  ENDIF
  CALL logrequest(null)
  SET reply->status_data.status = "Z"
  GO TO start_manual_expedites
 ENDIF
#end_triggers
#start_loc_xref
 IF (((cur_loc_xref_ind=1) OR (((pat_loc_xref_ind=1) OR (((ord_loc_xref_ind=1) OR (
 cur_loc_temp_xref_ind=1)) )) )) )
  IF (dest_routing_enabled_ind=1
   AND cr_destination_xref_check=2)
   CALL locationdestinations(null)
  ELSE
   SELECT INTO "nl:"
    od.output_dest_cd
    FROM device_xref x,
     output_dest od,
     device d
    PLAN (x
     WHERE x.parent_entity_id IN (encntr->cur_loc_facility_cd, encntr->cur_loc_building_cd, encntr->
     cur_loc_nurse_unit_cd, encntr->cur_loc_room_cd, encntr->cur_loc_bed_cd,
     encntr->cur_loc_temp_cd)
      AND x.parent_entity_name="LOCATION")
     JOIN (d
     WHERE d.device_cd=x.device_cd)
     JOIN (od
     WHERE od.device_cd=d.device_cd)
    HEAD REPORT
     loc_lvl = 9
    DETAIL
     CASE (x.parent_entity_id)
      OF encntr->cur_loc_facility_cd:
       IF (5 < loc_lvl)
        loc_output_dest_cd = od.output_dest_cd, loc_output_dest_name = od.name
        IF (d.name != od.name)
         loc_device_name = d.name
        ENDIF
        loc_lvl = 5
       ENDIF
      OF encntr->cur_loc_building_cd:
       IF (4 < loc_lvl)
        loc_output_dest_cd = od.output_dest_cd, loc_output_dest_name = od.name
        IF (d.name != od.name)
         loc_device_name = d.name
        ENDIF
        loc_lvl = 4
       ENDIF
      OF encntr->cur_loc_nurse_unit_cd:
       IF (3 < loc_lvl)
        loc_output_dest_cd = od.output_dest_cd, loc_output_dest_name = od.name
        IF (d.name != od.name)
         loc_device_name = d.name
        ENDIF
        loc_lvl = 3
       ENDIF
      OF encntr->cur_loc_room_cd:
       IF (2 < loc_lvl)
        loc_output_dest_cd = od.output_dest_cd, loc_output_dest_name = od.name
        IF (d.name != od.name)
         loc_device_name = d.name
        ENDIF
        loc_lvl = 2
       ENDIF
      OF encntr->cur_loc_bed_cd:
       IF (1 < loc_lvl)
        loc_output_dest_cd = od.output_dest_cd, loc_output_dest_name = od.name
        IF (d.name != od.name)
         loc_device_name = d.name
        ENDIF
        loc_lvl = 1
       ENDIF
      OF encntr->cur_loc_temp_cd:
       loc_temp_output_dest_cd = od.output_dest_cd,loc_temp_output_dest_name = od.name,
       IF (d.name != od.name)
        loc_temp_device_name = d.name
       ENDIF
     ENDCASE
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    od.output_dest_cd
    FROM device_xref x,
     output_dest od,
     device d
    PLAN (x
     WHERE x.parent_entity_id IN (encntr->pat_loc_facility_cd, encntr->pat_loc_building_cd, encntr->
     pat_loc_nurse_unit_cd, encntr->pat_loc_room_cd, encntr->pat_loc_bed_cd)
      AND x.parent_entity_name="LOCATION"
      AND x.parent_entity_id > 0)
     JOIN (d
     WHERE d.device_cd=x.device_cd)
     JOIN (od
     WHERE od.device_cd=d.device_cd)
    HEAD REPORT
     pat_lvl = 9
    DETAIL
     CASE (x.parent_entity_id)
      OF encntr->pat_loc_facility_cd:
       IF (5 < pat_lvl)
        pat_output_dest_cd = od.output_dest_cd, pat_output_dest_name = od.name
        IF (d.name != od.name)
         pat_device_name = d.name
        ENDIF
        pat_lvl = 5
       ENDIF
      OF encntr->pat_loc_building_cd:
       IF (4 < pat_lvl)
        pat_output_dest_cd = od.output_dest_cd, pat_output_dest_name = od.name
        IF (d.name != od.name)
         pat_device_name = d.name
        ENDIF
        pat_lvl = 4
       ENDIF
      OF encntr->pat_loc_nurse_unit_cd:
       IF (3 < pat_lvl)
        pat_output_dest_cd = od.output_dest_cd, pat_output_dest_name = od.name
        IF (d.name != od.name)
         pat_device_name = d.name
        ENDIF
        pat_lvl = 3
       ENDIF
      OF encntr->pat_loc_room_cd:
       IF (2 < pat_lvl)
        pat_output_dest_cd = od.output_dest_cd, pat_output_dest_name = od.name
        IF (d.name != od.name)
         pat_device_name = d.name
        ENDIF
        pat_lvl = 2
       ENDIF
      OF encntr->pat_loc_bed_cd:
       IF (1 < pat_lvl)
        pat_output_dest_cd = od.output_dest_cd, pat_output_dest_name = od.name
        IF (d.name != od.name)
         pat_device_name = d.name
        ENDIF
        pat_lvl = 1
       ENDIF
     ENDCASE
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    od.output_dest_cd
    FROM device_xref x,
     output_dest od,
     device d
    PLAN (x
     WHERE x.parent_entity_id IN (encntr->ord_loc_facility_cd, encntr->ord_loc_building_cd, encntr->
     ord_loc_nurse_unit_cd, encntr->ord_loc_room_cd, encntr->ord_loc_bed_cd)
      AND x.parent_entity_name="LOCATION")
     JOIN (d
     WHERE d.device_cd=x.device_cd)
     JOIN (od
     WHERE od.device_cd=d.device_cd)
    HEAD REPORT
     ord_lvl = 9
    DETAIL
     CASE (x.parent_entity_id)
      OF encntr->ord_loc_facility_cd:
       IF (5 < ord_lvl)
        ord_output_dest_cd = od.output_dest_cd, ord_output_dest_name = od.name
        IF (d.name != od.name)
         ord_device_name = d.name
        ENDIF
        ord_lvl = 5
       ENDIF
      OF encntr->ord_loc_building_cd:
       IF (4 < ord_lvl)
        ord_output_dest_cd = od.output_dest_cd, ord_output_dest_name = od.name
        IF (d.name != od.name)
         ord_device_name = d.name
        ENDIF
        ord_lvl = 4
       ENDIF
      OF encntr->ord_loc_nurse_unit_cd:
       IF (3 < ord_lvl)
        ord_output_dest_cd = od.output_dest_cd, ord_output_dest_name = od.name
        IF (d.name != od.name)
         ord_device_name = d.name
        ENDIF
        ord_lvl = 3
       ENDIF
      OF encntr->ord_loc_room_cd:
       IF (2 < ord_lvl)
        ord_output_dest_cd = od.output_dest_cd, ord_output_dest_name = od.name
        IF (d.name != od.name)
         ord_device_name = d.name
        ENDIF
        ord_lvl = 2
       ENDIF
      OF encntr->ord_loc_bed_cd:
       IF (1 < ord_lvl)
        ord_output_dest_cd = od.output_dest_cd, ord_output_dest_name = od.name
        IF (d.name != od.name)
         ord_device_name = d.name
        ENDIF
        ord_lvl = 1
       ENDIF
     ENDCASE
    WITH nocounter
   ;end select
  ENDIF
  IF (log_level >= 1)
   IF (cur_loc_xref_ind=1
    AND loc_output_dest_cd=0
    AND size(trim(loc_dms_service_ident))=0)
    SET error_ind = 1
    IF (log_level=1
     AND acc_logged_ind=0)
     EXECUTE FROM start_log_accession TO end_log_accession
    ENDIF
    CALL writelogmessage("No device/destination found for patient's location so no expedite sent")
    CALL writelogmessage(concat("fac, bld, nu, room, bed: ",cnvtstring(encntr->cur_loc_facility_cd),
      cnvtstring(encntr->cur_loc_building_cd),cnvtstring(encntr->cur_loc_nurse_unit_cd),cnvtstring(
       encntr->cur_loc_room_cd),
      cnvtstring(encntr->cur_loc_bed_cd)))
   ELSEIF (pat_loc_xref_ind=1
    AND pat_output_dest_cd=0
    AND size(trim(pat_dms_service_ident))=0)
    SET error_ind = 1
    IF (log_level=1
     AND acc_logged_ind=0)
     EXECUTE FROM start_log_accession TO end_log_accession
    ENDIF
    CALL writelogmessage(
     "No device/destination found for patient's location at time of order so no expedite sent.")
    CALL writelogmessage(concat("fac, bld, nu, room, bed: ",cnvtstring(encntr->pat_loc_facility_cd),
      cnvtstring(encntr->pat_loc_building_cd),cnvtstring(encntr->pat_loc_nurse_unit_cd),cnvtstring(
       encntr->pat_loc_room_cd),
      cnvtstring(encntr->pat_loc_bed_cd)))
   ELSEIF (ord_loc_xref_ind=1
    AND ord_output_dest_cd=0
    AND size(trim(ord_dms_service_ident))=0)
    SET error_ind = 1
    IF (log_level=1
     AND acc_logged_ind=0)
     EXECUTE FROM start_log_accession TO end_log_accession
    ENDIF
    CALL writelogmessage("No device/destination found for order location so no expedite sent.")
    CALL writelogmessage(concat("fac, bld, nu, room, bed: ",cnvtstring(encntr->ord_loc_facility_cd),
      cnvtstring(encntr->ord_loc_building_cd),cnvtstring(encntr->ord_loc_nurse_unit_cd),cnvtstring(
       encntr->ord_loc_room_cd),
      cnvtstring(encntr->ord_loc_bed_cd)))
   ELSEIF (cur_loc_temp_xref_ind=1
    AND loc_temp_output_dest_cd=0
    AND size(trim(loc_temp_dms_service_ident))=0)
    SET error_ind = 1
    IF (log_level=1
     AND acc_logged_ind=0)
     EXECUTE FROM start_log_accession TO end_log_accession
    ENDIF
    IF ((encntr->cur_loc_temp_cd > 0))
     CALL writelogmessage(
      "No device/destination found for current patient temporary location so no expedite sent.")
     CALL writelogmessage(concat("patient temporary location: ",cnvtstring(encntr->cur_loc_temp_cd)))
    ELSE
     CALL writelogmessage("Current patient temporary location code is Zero so no expedite sent.")
    ENDIF
   ENDIF
  ENDIF
  FOR (idx = 1 TO exp_cnt)
    IF ((expedite->qual[idx].output_flag=1))
     SET expedite->qual[idx].output_dest_cd = loc_output_dest_cd
     IF (loc_device_name > " ")
      SET expedite->qual[idx].device_name = loc_device_name
     ENDIF
     SET expedite->qual[idx].output_dest_name = loc_output_dest_name
     SET expedite->qual[idx].dms_service_ident = loc_dms_service_ident
    ELSEIF ((expedite->qual[idx].output_flag=2))
     SET expedite->qual[idx].output_dest_cd = pat_output_dest_cd
     IF (pat_device_name > " ")
      SET expedite->qual[idx].device_name = pat_device_name
     ENDIF
     SET expedite->qual[idx].output_dest_name = pat_output_dest_name
     SET expedite->qual[idx].dms_service_ident = pat_dms_service_ident
    ELSEIF ((expedite->qual[idx].output_flag=7))
     SET expedite->qual[idx].output_dest_cd = ord_output_dest_cd
     IF (ord_device_name > " ")
      SET expedite->qual[idx].device_name = ord_device_name
     ENDIF
     SET expedite->qual[idx].output_dest_name = ord_output_dest_name
     SET expedite->qual[idx].dms_service_ident = ord_dms_service_ident
    ELSEIF ((expedite->qual[idx].output_flag=8))
     SET expedite->qual[idx].output_dest_cd = loc_temp_output_dest_cd
     IF (loc_temp_device_name > " ")
      SET expedite->qual[idx].device_name = loc_temp_device_name
     ENDIF
     SET expedite->qual[idx].output_dest_name = loc_temp_output_dest_name
     SET expedite->qual[idx].dms_service_ident = loc_temp_dms_service_ident
    ENDIF
  ENDFOR
 ENDIF
#end_loc_xref
#start_sr_xref
 IF (sr_xref_ind=1)
  IF (dest_routing_enabled_ind=1
   AND cr_destination_xref_check=2)
   CALL serviceresourcedestinations(null)
  ELSE
   FOR (idx = 1 TO exp_cnt)
     IF ((expedite->qual[idx].output_flag=4)
      AND (expedite->qual[idx].output_dest_cd=0))
      SET sr_output_dest_cd = 0
      SELECT INTO "nl:"
       od.output_dest_cd
       FROM (dummyt d1  WITH seq = value(tree_cnt)),
        device_xref x,
        device d,
        output_dest od
       PLAN (d1
        WHERE (tree->qual[d1.seq].lowest_child_cd=expedite->qual[idx].service_resource_cd))
        JOIN (x
        WHERE (x.parent_entity_id=tree->qual[d1.seq].code_value)
         AND x.parent_entity_name="SERVICE_RESOURCE")
        JOIN (d
        WHERE d.device_cd=x.device_cd)
        JOIN (od
        WHERE od.device_cd=d.device_cd)
       HEAD REPORT
        sr_lvl = 9, sr_output_dest_cd = 0, sr_output_dest_name = fillstring(20," "),
        sr_output_device_name = fillstring(20," ")
       DETAIL
        IF (5 < sr_lvl
         AND (tree->qual[d1.seq].sr_tree_lvl=5))
         sr_output_dest_cd = od.output_dest_cd, sr_output_dest_name = od.name
         IF (d.name != od.name)
          sr_output_device_name = d.name
         ENDIF
         sr_lvl = 5
        ENDIF
        IF (4 < sr_lvl
         AND (tree->qual[d1.seq].sr_tree_lvl=4))
         sr_output_dest_cd = od.output_dest_cd, sr_output_dest_name = od.name
         IF (d.name != od.name)
          sr_output_device_name = d.name
         ENDIF
         sr_lvl = 4
        ENDIF
        IF (3 < sr_lvl
         AND (tree->qual[d1.seq].sr_tree_lvl=3))
         sr_output_dest_cd = od.output_dest_cd, sr_output_dest_name = od.name
         IF (d.name != od.name)
          sr_output_device_name = d.name
         ENDIF
         sr_lvl = 3
        ENDIF
        IF (2 < sr_lvl
         AND (tree->qual[d1.seq].sr_tree_lvl=2))
         sr_output_dest_cd = od.output_dest_cd, sr_output_dest_name = od.name
         IF (d.name != od.name)
          sr_output_device_name = d.name
         ENDIF
         sr_lvl = 2
        ENDIF
        IF (1 < sr_lvl
         AND (tree->qual[d1.seq].sr_tree_lvl=1))
         sr_output_dest_cd = od.output_dest_cd, sr_output_dest_name = od.name
         IF (d.name != od.name)
          sr_output_device_name = d.name
         ENDIF
         sr_lvl = 1
        ENDIF
       WITH nocounter
      ;end select
      IF (sr_output_dest_cd > 0)
       FOR (idx2 = 1 TO exp_cnt)
         IF ((expedite->qual[idx2].output_flag=4)
          AND (expedite->qual[idx2].service_resource_cd=expedite->qual[idx].service_resource_cd))
          SET expedite->qual[idx2].output_dest_cd = sr_output_dest_cd
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
        CALL writelogmessage(concat("No device xref found for service resource: ",cnvtstring(expedite
           ->qual[idx].service_resource_cd)))
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
#end_sr_xref
#start_org_xref
 IF (org_xref_ind=1)
  IF (dest_routing_enabled_ind=1
   AND cr_destination_xref_check=2)
   CALL organizationdestinations(null)
  ELSE
   SELECT INTO "nl:"
    od.output_dest_cd
    FROM device_xref x,
     device d,
     output_dest od
    PLAN (x
     WHERE (x.parent_entity_id=encntr->organization_id)
      AND x.parent_entity_name="ORGANIZATION")
     JOIN (d
     WHERE d.device_cd=x.device_cd)
     JOIN (od
     WHERE od.device_cd=d.device_cd)
    HEAD REPORT
     org_output_dest_cd = od.output_dest_cd, org_output_dest_name = od.name
     IF (trim(cnvtupper(od.name)) != trim(cnvtupper(d.name)))
      org_output_device_name = d.name
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF (((org_output_dest_cd > 0) OR (size(trim(org_dms_service_ident)) > 0)) )
   FOR (idx2 = 1 TO exp_cnt)
     IF ((expedite->qual[idx2].output_flag=5))
      SET expedite->qual[idx2].output_dest_cd = org_output_dest_cd
      SET expedite->qual[idx2].output_dest_name = org_output_dest_name
      IF (trim(cnvtupper(org_output_dest_name)) != trim(cnvtupper(org_output_device_name)))
       SET expedite->qual[idx2].device_name = org_output_device_name
      ENDIF
      SET expedite->qual[idx2].dms_service_ident = org_dms_service_ident
     ENDIF
   ENDFOR
  ELSE
   IF (log_level >= 1)
    SET error_ind = 1
    IF (log_level=1
     AND acc_logged_ind=0)
     EXECUTE FROM start_log_accession TO end_log_accession
    ENDIF
    CALL writelogmessage(concat("No device/destination xref found for organization: ",cnvtstring(
       encntr->organization_id)))
   ENDIF
  ENDIF
 ENDIF
#end_org_xref
#start_provider_xref
 IF (provider_xref_ind=1)
  IF (dest_routing_enabled_ind=1
   AND cr_destination_xref_check=2)
   CALL providerdestinations(null)
  ELSE
   SELECT INTO "nl:"
    od.output_dest_cd
    FROM device_xref x,
     device d,
     output_dest od
    PLAN (x
     WHERE x.parent_entity_id=order_provider_id
      AND x.parent_entity_name="PRSNL")
     JOIN (d
     WHERE d.device_cd=x.device_cd)
     JOIN (od
     WHERE od.device_cd=d.device_cd)
    HEAD REPORT
     provider_output_dest_cd = od.output_dest_cd, provider_output_dest_name = od.name
     IF (trim(cnvtupper(od.name)) != trim(cnvtupper(d.name)))
      provider_device_name = d.name
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF (((provider_output_dest_cd > 0) OR (size(trim(provider_dms_service_ident)) > 0)) )
   FOR (idx2 = 1 TO exp_cnt)
     IF ((expedite->qual[idx2].output_flag=6))
      SET expedite->qual[idx2].output_dest_cd = provider_output_dest_cd
      SET expedite->qual[idx2].output_dest_name = provider_output_dest_name
      IF (trim(cnvtupper(provider_output_dest_name)) != trim(cnvtupper(provider_output_device_name)))
       SET expedite->qual[idx2].device_name = provider_output_device_name
      ENDIF
      SET expedite->qual[idx2].dms_service_ident = provider_dms_service_ident
     ENDIF
   ENDFOR
  ELSE
   IF (log_level >= 1)
    SET error_ind = 1
    IF (log_level=1
     AND acc_logged_ind=0)
     EXECUTE FROM start_log_accession TO end_log_accession
    ENDIF
    CALL writelogmessage(concat("No device/destination xref found for ordering provider: ",cnvtstring
      (order_provider_id)))
   ENDIF
  ENDIF
  CALL echo(build("**** ordering provider device = ",provider_output_dest_cd))
  CALL echo(build("**** ordering provider destination = ",provider_dms_service_ident))
 ENDIF
#end_provider_xref
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
 CALL getadmittingprovider(null)
#start_copy_to_providers
 IF (copy_ind=1)
  SELECT INTO "nl:"
   ec.expedite_params_id
   FROM (dummyt d  WITH seq = value(exp_cnt)),
    expedite_copy ec,
    encntr_prsnl_reltn epr,
    prsnl p
   PLAN (d
    WHERE (expedite->qual[d.seq].copy_ind=1))
    JOIN (ec
    WHERE (expedite->qual[d.seq].expedite_params_id=ec.expedite_params_id))
    JOIN (epr
    WHERE (request->encntr_id=epr.encntr_id)
     AND epr.encntr_id > 0
     AND epr.encntr_prsnl_r_cd=ec.encntr_prsnl_r_cd
     AND  NOT (epr.encntr_prsnl_r_cd IN (consult_order_cd, consult_encntr_cd, consult_doc_cd))
     AND ((epr.prsnl_person_id+ 0) > 0)
     AND epr.active_ind=1
     AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (p
    WHERE p.active_ind=1
     AND p.person_id=epr.prsnl_person_id)
   HEAD REPORT
    copy_cnt = 0
   HEAD epr.prsnl_person_id
    do_nothing = 0
   HEAD epr.encntr_prsnl_r_cd
    IF ((expedite->qual[d.seq].exp_exclude_ind=1)
     AND epr.expiration_ind=1)
     no_chart_log_nbr += 1, no_chart_log_buffer[no_chart_log_nbr] = concat(trim(expedite->qual[d.seq]
       .trigger_name)," (copy to) for physician ",trim(cnvtstring(epr.prsnl_person_id))),
     no_chart_log_nbr += 1,
     no_chart_log_buffer[no_chart_log_nbr] = concat("    Reason - physician ",trim(cnvtstring(epr
        .prsnl_person_id))," has an EXPIRED relationship ",trim(cnvtstring(epr.encntr_prsnl_r_cd)),
      " to the patient.")
    ENDIF
   DETAIL
    IF ((expedite->qual[d.seq].exp_exclude_ind=1)
     AND epr.expiration_ind=1)
     do_nothing = 0
    ELSE
     copy_cnt += 1, stat = alterlist(copy->qual,copy_cnt), copy->qual[copy_cnt].duplicate_ind = 0,
     copy->qual[copy_cnt].dup_template_ind = 0, copy->qual[copy_cnt].expedite_params_id = ec
     .expedite_params_id, copy->qual[copy_cnt].trigger_name = expedite->qual[d.seq].trigger_name,
     copy->qual[copy_cnt].chart_content_flag = expedite->qual[d.seq].chart_content_flag, copy->qual[
     copy_cnt].template_id = expedite->qual[d.seq].template_id, copy->qual[copy_cnt].params_name =
     expedite->qual[d.seq].params_name,
     copy->qual[copy_cnt].encntr_prsnl_r_cd = ec.encntr_prsnl_r_cd, copy->qual[copy_cnt].provider_id
      = epr.prsnl_person_id, copy->qual[copy_cnt].sending_org_id = expedite->qual[d.seq].
     sending_org_id
     FOR (idx = 1 TO (copy_cnt - 1))
       IF ((copy->qual[idx].provider_id=epr.prsnl_person_id))
        copy->qual[idx].duplicate_ind = 1
        IF ((copy->qual[idx].template_id=expedite->qual[d.seq].template_id))
         copy->qual[idx].dup_template_ind = 1
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->orders[1].event_id > 0)
  AND copy_ind=1)
  CALL echorecord(copy)
  CALL echo("Getting Author to copy...")
  SELECT INTO "nl:"
   ec.encntr_prsnl_r_cd
   FROM (dummyt d  WITH seq = value(exp_cnt)),
    expedite_copy ec
   PLAN (d
    WHERE (expedite->qual[d.seq].copy_ind=1))
    JOIN (ec
    WHERE (ec.expedite_params_id=expedite->qual[d.seq].expedite_params_id)
     AND ec.encntr_prsnl_r_cd IN (consult_doc_cd, consult_encntr_cd, consult_order_cd, order_doc_cd))
   ORDER BY d.seq, ec.encntr_prsnl_r_cd
   HEAD REPORT
    pnbr = size(request->orders[1].action_prsnl_qual,5)
   DETAIL
    FOR (pidx = 1 TO pnbr)
      IF (((ec.encntr_prsnl_r_cd IN (consult_doc_cd, consult_encntr_cd, consult_order_cd)
       AND (request->orders[1].action_prsnl_qual[pidx].action_type_mean="REVIEW")) OR (ec
      .encntr_prsnl_r_cd=order_doc_cd
       AND (request->orders[1].action_prsnl_qual[pidx].action_type_mean IN ("SIGN", "COSIGN")))) )
       copy_cnt += 1, stat = alterlist(copy->qual,copy_cnt), copy->qual[copy_cnt].duplicate_ind = 0,
       copy->qual[copy_cnt].dup_template_ind = 0, copy->qual[copy_cnt].expedite_params_id = expedite
       ->qual[d.seq].expedite_params_id, copy->qual[copy_cnt].trigger_name = expedite->qual[d.seq].
       trigger_name,
       copy->qual[copy_cnt].chart_content_flag = expedite->qual[d.seq].chart_content_flag, copy->
       qual[copy_cnt].template_id = expedite->qual[d.seq].template_id, copy->qual[copy_cnt].
       params_name = expedite->qual[d.seq].params_name,
       copy->qual[copy_cnt].encntr_prsnl_r_cd =
       IF (ec.encntr_prsnl_r_cd=order_doc_cd) order_doc_cd
       ELSE consult_doc_cd
       ENDIF
       , copy->qual[copy_cnt].provider_id = request->orders[1].action_prsnl_qual[pidx].
       action_prsnl_id, copy->qual[copy_cnt].sending_org_id = expedite->qual[d.seq].sending_org_id
       FOR (icnt = 1 TO (copy_cnt - 1))
         IF ((copy->qual[icnt].provider_id=request->orders[1].action_prsnl_qual[pidx].action_prsnl_id
         ))
          copy->qual[icnt].duplicate_ind = 1
          IF ((copy->qual[icnt].template_id=expedite->qual[d.seq].template_id))
           copy->qual[icnt].dup_template_ind = 1
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
  CALL echo("After adding author....")
  CALL echorecord(copy)
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
    IF (ec.encntr_prsnl_r_cd IN (consult_doc_cd, consult_order_cd))
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
    order_detail od,
    prsnl p
   PLAN (d
    WHERE (expedite->qual[d.seq].copy_ind=1)
     AND (expedite->qual[d.seq].expedite_params_id=params_id))
    JOIN (d1
    WHERE (request->orders[d1.seq].order_id > 0.0))
    JOIN (od
    WHERE (od.order_id=request->orders[d1.seq].order_id)
     AND od.oe_field_meaning="CONSULTDOC"
     AND od.oe_field_meaning_id=2)
    JOIN (p
    WHERE p.active_ind=1
     AND p.person_id=od.oe_field_value)
   ORDER BY od.order_id, od.action_sequence DESC, od.detail_sequence
   HEAD od.order_id
    row + 1, lastestseq = 1
   HEAD od.action_sequence
    do_nothing = 0
   DETAIL
    IF (lastestseq=1
     AND od.oe_field_display_value > " ")
     copy_cnt += 1, status = alterlist(copy->qual,copy_cnt), copy->qual[copy_cnt].duplicate_ind = 0,
     copy->qual[copy_cnt].dup_template_ind = 0, copy->qual[copy_cnt].expedite_params_id = expedite->
     qual[d.seq].expedite_params_id, copy->qual[copy_cnt].trigger_name = expedite->qual[d.seq].
     trigger_name,
     copy->qual[copy_cnt].chart_content_flag = expedite->qual[d.seq].chart_content_flag, copy->qual[
     copy_cnt].template_id = expedite->qual[d.seq].template_id, copy->qual[copy_cnt].params_name =
     expedite->qual[d.seq].params_name,
     copy->qual[copy_cnt].encntr_prsnl_r_cd = consult_doc_cd, copy->qual[copy_cnt].provider_id = od
     .oe_field_value, copy->qual[copy_cnt].sending_org_id = expedite->qual[d.seq].sending_org_id
     FOR (idx = 1 TO (copy_cnt - 1))
       IF ((copy->qual[idx].provider_id=od.oe_field_value))
        copy->qual[idx].duplicate_ind = 1
        IF ((copy->qual[idx].template_id=expedite->qual[d.seq].template_id))
         copy->qual[idx].dup_template_ind = 1
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
 CALL echo(build("**** additional consulting providers "))
#end_consulting_providers
#start_copy_xref
 IF (copy_cnt > 0)
  IF (dest_routing_enabled_ind=1
   AND cr_destination_xref_check=2)
   CALL copytodestinations(null)
  ELSE
   SELECT INTO "nl:"
    od.output_dest_cd
    FROM (dummyt d1  WITH seq = value(copy_cnt)),
     device_xref x,
     device d,
     output_dest od
    PLAN (d1
     WHERE (((copy->qual[d1.seq].duplicate_ind=0)) OR ((copy->qual[d1.seq].duplicate_ind=1)
      AND (copy->qual[d1.seq].dup_template_ind=0))) )
     JOIN (x
     WHERE (x.parent_entity_id=copy->qual[d1.seq].provider_id)
      AND x.parent_entity_name="PRSNL")
     JOIN (d
     WHERE d.device_cd=x.device_cd)
     JOIN (od
     WHERE od.device_cd=d.device_cd)
    DETAIL
     copy->qual[d1.seq].output_dest_cd = od.output_dest_cd, copy->qual[d1.seq].output_dest_name = od
     .name
     IF (d.name != od.name)
      copy->qual[d1.seq].device_name = d.name
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  CALL echorecord(expedite)
  CALL echorecord(copy)
 ENDIF
#end_copy_xref
 FOR (i = 1 TO exp_cnt)
  SET expedite->qual[i].expired_do_not_print = 0
  IF ((expedite->qual[i].output_flag != 6)
   AND (expedite->qual[i].prsnl_person_id=0))
   IF ((request->orders[1].event_id > 0))
    SET expedite->qual[i].prsnl_person_id = order_provider_id
    SET expedite->qual[i].prsnl_person_r_cd = order_doc_cd
   ELSE
    SET expedite->qual[i].prsnl_person_id = admitdoc_id
    SET expedite->qual[i].prsnl_person_r_cd = admitdoc_type_cd
    IF ((expedite->qual[i].exp_exclude_ind=1)
     AND admitdoc_exp_ind=1)
     SET expedite->qual[i].expired_do_not_print = 1
     SET no_chart_log_nbr += 1
     SET no_chart_log_buffer[no_chart_log_nbr] = concat(trim(expedite->qual[i].trigger_name),
      " for admitting physician ",trim(cnvtstring(admitdoc_id)))
     SET no_chart_log_nbr += 1
     SET no_chart_log_buffer[no_chart_log_nbr] = concat("    Reason - physician ",trim(cnvtstring(
        admitdoc_id))," has an EXPIRED admitting physician relationship to the patient.")
     SET no_chart_log_nbr += 1
     SET no_chart_log_buffer[no_chart_log_nbr] = concat("       Provider-",trim(cnvtstring(expedite->
        qual[i].prsnl_person_id))," Reltn-",trim(cnvtstring(expedite->qual[i].prsnl_person_r_cd)),
      " ReportTemplate-",
      trim(cnvtstring(expedite->qual[i].template_id))," OutputDest-",trim(cnvtstring(expedite->qual[i
        ].output_dest_cd))," DMS Service Identifier-",trim(expedite->qual[i].dms_service_ident),
      " CompleteFlag-",trim(cnvtstring(expedite->qual[i].order_complete_flag)))
    ELSE
     SET expedite->qual[i].expired_do_not_print = 0
    ENDIF
   ENDIF
   FOR (j = 1 TO copy_cnt)
     IF ((copy->qual[j].provider_id=expedite->qual[i].prsnl_person_id)
      AND (copy->qual[j].template_id=expedite->qual[i].template_id)
      AND (((copy->qual[j].output_dest_cd=expedite->qual[i].output_dest_cd)) OR (trim(copy->qual[j].
      dms_service_ident)=trim(expedite->qual[i].dms_service_ident))) )
      SET copy->qual[j].duplicate_ind = 1
      SET copy->qual[j].dup_template_ind = 1
     ENDIF
   ENDFOR
  ENDIF
 ENDFOR
#start_dup_check
 FOR (idx = 1 TO exp_cnt)
  SET idx2 = ((exp_cnt+ 1) - idx)
  IF ((expedite->qual[idx2].duplicate_ind=0))
   FOR (idx3 = 1 TO (idx2 - 1))
     IF ((expedite->qual[idx3].prsnl_person_id=expedite->qual[idx2].prsnl_person_id)
      AND (((expedite->qual[idx3].output_dest_cd=expedite->qual[idx2].output_dest_cd)) OR (trim(
      expedite->qual[idx3].dms_service_ident)=trim(expedite->qual[idx2].dms_service_ident)))
      AND (expedite->qual[idx3].template_id=expedite->qual[idx2].template_id))
      SET expedite->qual[idx3].duplicate_ind = 1
      SET expedite->qual[idx3].dup_template_ind = 1
     ENDIF
   ENDFOR
  ENDIF
 ENDFOR
#end_dup_check
#start_manual_expedites
 IF (iprocessexpedites)
  CALL writelogmessage("Manual Expedite processing enabled")
  SET eventnbr = size(request->orders[1].event_id_list,5)
  IF (eventnbr > 0)
   SELECT INTO "nl:"
    em.person_id
    FROM (dummyt d  WITH seq = value(eventnbr)),
     expedite_manual em,
     expedite_manual_event eme
    PLAN (d)
     JOIN (eme
     WHERE (eme.event_id=request->orders[1].event_id_list[d.seq].event_id))
     JOIN (em
     WHERE (em.encntr_id=request->encntr_id)
      AND em.encntr_id > 0
      AND (em.person_id=request->person_id)
      AND em.event_ind=1
      AND em.scope_flag=6
      AND em.template_id > 0
      AND em.expedite_manual_id=eme.expedite_manual_id)
    ORDER BY em.expedite_manual_id
    HEAD em.expedite_manual_id
     exp_cnt += 1, stat = alterlist(expedite->qual,exp_cnt), expedite->qual[exp_cnt].duplicate_ind =
     0,
     expedite->qual[exp_cnt].dup_template_ind = 0, expedite->qual[exp_cnt].chart_content_flag = em
     .chart_content_flag, expedite->qual[exp_cnt].template_id = em.template_id,
     expedite->qual[exp_cnt].scope_flag = em.scope_flag, expedite->qual[exp_cnt].output_flag = 0,
     expedite->qual[exp_cnt].output_dest_cd = em.output_dest_cd,
     expedite->qual[exp_cnt].output_device_cd = em.output_device_cd, expedite->qual[exp_cnt].
     output_dest_name = em.output_dest_name, expedite->qual[exp_cnt].rrd_deliver_dt_tm = em
     .rrd_deliver_dt_tm,
     expedite->qual[exp_cnt].rrd_phone_suffix = em.rrd_phone_suffix
     IF (em.device_name != em.output_dest_name)
      expedite->qual[exp_cnt].device_name = em.device_name
     ENDIF
     expedite->qual[exp_cnt].manual_expedite_ind = 1, expedite->qual[exp_cnt].manual_requestor_id =
     em.updt_id
     IF (em.provider_id > 0)
      expedite->qual[exp_cnt].manual_provider_id = em.provider_id, expedite->qual[exp_cnt].
      manual_prov_role_cd = em.provider_role_cd
     ELSE
      expedite->qual[exp_cnt].manual_provider_id = em.updt_id
     ENDIF
     expedite->qual[exp_cnt].event_ind = em.event_ind, expedite->qual[exp_cnt].expedite_manual_id =
     em.expedite_manual_id, expedite->qual[exp_cnt].user_role_profile = trim(validate(em
       .user_role_profile,"")),
     expedite->qual[exp_cnt].sending_org_id = validate(em.sending_org_id,0.0), expedite->qual[exp_cnt
     ].dms_service_ident = trim(validate(em.dms_service_identifier,"")), event_cnt = 0
    DETAIL
     event_cnt += 1, stat = alterlist(expedite->qual[exp_cnt].event_id_list,event_cnt), expedite->
     qual[exp_cnt].event_id_list[event_cnt].em_event_id = eme.em_event_id,
     expedite->qual[exp_cnt].event_id_list[event_cnt].event_id = eme.event_id, expedite->qual[exp_cnt
     ].event_id_list[event_cnt].result_status_cd = request->orders[1].event_id_list[d.seq].
     result_status_cd
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    em.person_id
    FROM expedite_manual em
    WHERE (((em.accession=request->accession)
     AND em.scope_flag=4) OR ((((em.encntr_id=request->encntr_id)
     AND em.scope_flag=2) OR ((em.person_id=request->person_id)
     AND em.scope_flag=1)) ))
    DETAIL
     exp_cnt += 1, stat = alterlist(expedite->qual,exp_cnt), expedite->qual[exp_cnt].duplicate_ind =
     0,
     expedite->qual[exp_cnt].dup_template_ind = 0, expedite->qual[exp_cnt].chart_content_flag = em
     .chart_content_flag, expedite->qual[exp_cnt].template_id = em.template_id,
     expedite->qual[exp_cnt].scope_flag = em.scope_flag, expedite->qual[exp_cnt].output_flag = 0,
     expedite->qual[exp_cnt].output_dest_cd = em.output_dest_cd,
     expedite->qual[exp_cnt].output_device_cd = em.output_device_cd, expedite->qual[exp_cnt].
     output_dest_name = em.output_dest_name
     IF (em.device_name != em.output_dest_name)
      expedite->qual[exp_cnt].device_name = em.device_name
     ENDIF
     expedite->qual[exp_cnt].rrd_deliver_dt_tm = em.rrd_deliver_dt_tm, expedite->qual[exp_cnt].
     rrd_phone_suffix = em.rrd_phone_suffix, expedite->qual[exp_cnt].manual_expedite_ind = 1,
     expedite->qual[exp_cnt].manual_requestor_id = em.updt_id
     IF (em.provider_id > 0)
      expedite->qual[exp_cnt].manual_provider_id = em.provider_id, expedite->qual[exp_cnt].
      manual_prov_role_cd = em.provider_role_cd
     ELSEIF (em.template_id > 0)
      expedite->qual[exp_cnt].manual_provider_id = em.updt_id
     ENDIF
     expedite->qual[exp_cnt].expedite_manual_id = em.expedite_manual_id, expedite->qual[exp_cnt].
     user_role_profile = trim(validate(em.user_role_profile,"")), expedite->qual[exp_cnt].
     sending_org_id = validate(em.sending_org_id,0.0),
     expedite->qual[exp_cnt].dms_service_ident = trim(validate(em.dms_service_identifier,""))
    WITH nocounter
   ;end select
  ENDIF
  IF (curqual > 0)
   CALL writelogmessage("Manual Expedite loaded for evaluation")
  ENDIF
 ELSE
  CALL writelogmessage("Manual Expedite processing disabled")
 ENDIF
 IF (iprocessexpedites)
  FOR (i = 1 TO exp_cnt)
    IF ((expedite->qual[i].duplicate_ind=1)
     AND (expedite->qual[i].dup_template_ind=1))
     SET no_chart_log_nbr += 1
     SET no_chart_log_buffer[no_chart_log_nbr] = concat(trim(expedite->qual[i].trigger_name),
      " for physician ",trim(cnvtstring(expedite->qual[i].prsnl_person_id)))
     SET no_chart_log_nbr += 1
     SET no_chart_log_buffer[no_chart_log_nbr] = concat("    Reason - DUPLICATE, Provider-",trim(
       cnvtstring(expedite->qual[i].prsnl_person_id))," Reltn-",trim(cnvtstring(expedite->qual[i].
        prsnl_person_r_cd))," ReportTemplate-",
      trim(cnvtstring(expedite->qual[i].template_id))," OutputDest-",trim(cnvtstring(expedite->qual[i
        ].output_dest_cd))," DMS Service Identifier-",trim(expedite->qual[i].dms_service_ident))
    ELSEIF ((expedite->qual[i].output_dest_cd=0)
     AND size(trim(expedite->qual[i].dms_service_ident))=0)
     SET no_chart_log_nbr += 1
     SET no_chart_log_buffer[no_chart_log_nbr] = concat(trim(expedite->qual[i].trigger_name),
      " for physician ",trim(cnvtstring(expedite->qual[i].prsnl_person_id)))
     SET no_chart_log_nbr += 1
     SET no_chart_log_buffer[no_chart_log_nbr] = "    Reason - Invalid output destination "
    ENDIF
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
 ENDIF
#end_manual_expedites
#start_log_triggers
 IF (log_level >= 3)
  CALL writelogmessage("Report requests produced by expedite(s) triggered: ")
  FOR (idx = 1 TO exp_cnt)
   SET send_log = "  (send) "
   IF ((((expedite->qual[idx].duplicate_ind=0)) OR ((expedite->qual[idx].duplicate_ind=1)
    AND (expedite->qual[idx].dup_template_ind=0)))
    AND (((expedite->qual[idx].output_dest_cd > 0)) OR (size(trim(expedite->qual[idx].
     dms_service_ident)) > 0))
    AND (expedite->qual[idx].expired_do_not_print=0))
    IF ((expedite->qual[idx].output_flag=0)
     AND (expedite->qual[idx].manual_expedite_ind != 1))
     CALL writelogmessage(concat(send_log,expedite->qual[idx].trigger_name,
       " to assigned destination ",trim(expedite->qual[idx].output_dest_name),
       IF ((expedite->qual[idx].device_name > " ")) " ("
       ELSE " "
       ENDIF
       ,
       trim(expedite->qual[idx].device_name),
       IF ((expedite->qual[idx].device_name > " ")) ")"
       ELSE " "
       ENDIF
       ," with DMS Service Indentifier ",expedite->qual[idx].dms_service_ident," with template ",
       cnvtstring(expedite->qual[idx].template_id)))
    ELSEIF ((expedite->qual[idx].output_flag=1)
     AND (expedite->qual[idx].manual_expedite_ind != 1))
     CALL writelogmessage(concat(send_log,expedite->qual[idx].trigger_name,
       " to patient loc destination ",trim(expedite->qual[idx].output_dest_name),
       IF ((expedite->qual[idx].device_name > " ")) " ("
       ELSE " "
       ENDIF
       ,
       trim(expedite->qual[idx].device_name),
       IF ((expedite->qual[idx].device_name > " ")) " )"
       ELSE " "
       ENDIF
       ," with DMS Service Indentifier ",expedite->qual[idx].dms_service_ident," with template ",
       cnvtstring(expedite->qual[idx].template_id)))
    ELSEIF ((expedite->qual[idx].output_flag=2)
     AND (expedite->qual[idx].manual_expedite_ind != 1))
     CALL writelogmessage(concat(send_log,expedite->qual[idx].trigger_name,
       " to patient loc at time of order destination ",trim(expedite->qual[idx].output_dest_name),
       IF ((expedite->qual[idx].device_name > " ")) " ("
       ELSE " "
       ENDIF
       ,
       trim(expedite->qual[idx].device_name),
       IF ((expedite->qual[idx].device_name > " ")) " )"
       ELSE " "
       ENDIF
       ," with DMS Service Indentifier ",expedite->qual[idx].dms_service_ident," with template ",
       cnvtstring(expedite->qual[idx].template_id)))
    ELSEIF ((expedite->qual[idx].output_flag=4)
     AND (expedite->qual[idx].manual_expedite_ind != 1))
     CALL writelogmessage(concat(send_log,expedite->qual[idx].trigger_name,
       " to service resource destination ",trim(expedite->qual[idx].output_dest_name),
       IF ((expedite->qual[idx].device_name > " ")) " ("
       ELSE " "
       ENDIF
       ,
       trim(expedite->qual[idx].device_name),
       IF ((expedite->qual[idx].device_name > " ")) " )"
       ELSE " "
       ENDIF
       ," with DMS Service Indentifier ",expedite->qual[idx].dms_service_ident," with template ",
       cnvtstring(expedite->qual[idx].template_id)))
    ELSEIF ((expedite->qual[idx].output_flag=5)
     AND (expedite->qual[idx].manual_expedite_ind != 1))
     CALL writelogmessage(concat(send_log,expedite->qual[idx].trigger_name,
       " to organization destination ",trim(expedite->qual[idx].output_dest_name),
       IF ((expedite->qual[idx].device_name > " ")) " ("
       ELSE " "
       ENDIF
       ,
       trim(expedite->qual[idx].device_name),
       IF ((expedite->qual[idx].device_name > " ")) " )"
       ELSE " "
       ENDIF
       ," with DMS Service Indentifier ",expedite->qual[idx].dms_service_ident," with template ",
       cnvtstring(expedite->qual[idx].template_id)))
    ELSEIF ((expedite->qual[idx].output_flag=7)
     AND (expedite->qual[idx].manual_expedite_ind != 1))
     CALL writelogmessage(concat(send_log,expedite->qual[idx].trigger_name,
       " to order location destination ",trim(expedite->qual[idx].output_dest_name),
       IF ((expedite->qual[idx].device_name > " ")) " ("
       ELSE " "
       ENDIF
       ,
       trim(expedite->qual[idx].device_name),
       IF ((expedite->qual[idx].device_name > " ")) " )"
       ELSE " "
       ENDIF
       ," with DMS Service Indentifier ",expedite->qual[idx].dms_service_ident," with template ",
       cnvtstring(expedite->qual[idx].template_id)))
    ELSEIF ((expedite->qual[idx].output_flag=8)
     AND (expedite->qual[idx].manual_expedite_ind != 1))
     CALL writelogmessage(concat(send_log,expedite->qual[idx].trigger_name,
       " to patient temporary location destination ",trim(expedite->qual[idx].output_dest_name),
       IF ((expedite->qual[idx].device_name > " ")) " ("
       ELSE " "
       ENDIF
       ,
       trim(expedite->qual[idx].device_name),
       IF ((expedite->qual[idx].device_name > " ")) " )"
       ELSE " "
       ENDIF
       ," with DMS Service Indentifier ",expedite->qual[idx].dms_service_ident," with template ",
       cnvtstring(expedite->qual[idx].template_id)))
    ELSEIF ((expedite->qual[idx].manual_expedite_ind != 1))
     CALL writelogmessage(concat(send_log,expedite->qual[idx].trigger_name," to destination ?",
       " with template ",cnvtstring(expedite->qual[idx].template_id)))
    ENDIF
    IF ((expedite->qual[idx].output_flag != 6)
     AND (expedite->qual[idx].manual_expedite_ind != 1))
     CALL writelogmessage(concat(" Provider-",trim(cnvtstring(expedite->qual[idx].prsnl_person_id)),
       " Reltn-",trim(cnvtstring(expedite->qual[idx].prsnl_person_r_cd))," ReportTemplate-",
       trim(cnvtstring(expedite->qual[idx].template_id))," OutputDest-",trim(cnvtstring(expedite->
         qual[idx].output_dest_cd))," DMS Service Identifier-",expedite->qual[idx].dms_service_ident)
      )
    ENDIF
   ENDIF
  ENDFOR
  FOR (idx = 1 TO copy_cnt)
    IF ((copy->qual[idx].duplicate_ind=1)
     AND (copy->qual[idx].dup_template_ind=1))
     SET do_nothing = 0
    ELSEIF ((((copy->qual[idx].output_dest_cd > 0)) OR (size(trim(copy->qual[idx].dms_service_ident))
     > 0)) )
     CALL writelogmessage(concat(send_log,copy->qual[idx].trigger_name,
       " (copy to) cross referenced destination "," with output destination name ",trim(copy->qual[
        idx].output_dest_name),
       " with DMS service identifier ",copy->qual[idx].dms_service_ident," with template ",cnvtstring
       (copy->qual[idx].template_id)))
     CALL writelogmessage(concat("       Provider-",trim(cnvtstring(copy->qual[idx].provider_id)),
       " Reltn-",trim(cnvtstring(copy->qual[idx].encntr_prsnl_r_cd))," ReportTemplate-",
       trim(cnvtstring(copy->qual[idx].template_id))," OutputDest-",trim(cnvtstring(copy->qual[idx].
         output_dest_cd))," DMS Service Identifier-",copy->qual[idx].dms_service_ident))
    ENDIF
  ENDFOR
  FOR (idx = 1 TO exp_cnt)
    IF ((expedite->qual[idx].manual_expedite_ind=1))
     CALL writelogmessage(concat("Manual expedite sent to device/destination ",trim(expedite->qual[
        idx].output_dest_name),
       IF ((expedite->qual[idx].device_name > " ")) " ("
       ELSE " "
       ENDIF
       ,trim(expedite->qual[idx].device_name),
       IF ((expedite->qual[idx].device_name > " ")) ")"
       ELSE " "
       ENDIF
       ,
       " with DMS service identifier ",expedite->qual[idx].dms_service_ident," with template ",
       cnvtstring(expedite->qual[idx].template_id),
       IF ((expedite->qual[idx].user_role_profile > " ")) " for URP: "
       ENDIF
       ,
       trim(expedite->qual[idx].user_role_profile)))
    ENDIF
  ENDFOR
 ENDIF
#start_get_sender_email
 IF (exp_cnt > 0
  AND dest_routing_enabled_ind=1)
  SELECT INTO "nl:"
   p.phone_num
   FROM (dummyt d  WITH seq = value(exp_cnt)),
    phone p
   PLAN (d
    WHERE (expedite->qual[d.seq].sending_org_id > 0))
    JOIN (p
    WHERE (expedite->qual[d.seq].sending_org_id=p.parent_entity_id)
     AND p.parent_entity_name=organization_entity
     AND p.phone_type_cd=intsecemail_cd
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    expedite->qual[d.seq].sender_email = p.phone_num
   WITH nocounter
  ;end select
 ENDIF
 IF (copy_cnt > 0
  AND dest_routing_enabled_ind=1)
  SELECT INTO "nl:"
   p.phone_num
   FROM (dummyt d  WITH seq = value(copy_cnt)),
    phone p
   PLAN (d
    WHERE (copy->qual[d.seq].sending_org_id > 0))
    JOIN (p
    WHERE (copy->qual[d.seq].sending_org_id=p.parent_entity_id)
     AND p.parent_entity_name=organization_entity
     AND p.phone_type_cd=intsecemail_cd
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    copy->qual[d.seq].sender_email = p.phone_num
   WITH nocounter
  ;end select
 ENDIF
#end_get_sender_email
#start_chart_request
 FREE RECORD report_request
 RECORD report_request(
   1 requests[*]
     2 request_type_flag = i2
     2 scope_flag = i2
     2 begin_dt_tm = dq8
     2 end_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 xencntr_ids[*]
       3 encntr_id = f8
     2 event_ids[*]
       3 event_id = f8
     2 accession_nbr = c20
     2 order_id = f8
     2 request_prsnl_id = f8
     2 provider_prsnl_id = f8
     2 provider_reltn_cd = f8
     2 template_id = f8
     2 distribution_id = f8
     2 dist_run_type_cd = f8
     2 dist_run_dt_tm = dq8
     2 dist_seq = i4
     2 reader_group = c15
     2 route_id = f8
     2 route_stop_id = f8
     2 output_dest_cd = f8
     2 trigger_name = c100
     2 eso_trigger_id = f8
     2 eso_trigger_type = c15
     2 result_status_flag = i2
     2 use_posting_date_flag = i2
     2 user_role_profile = vc
     2 section_ids[*]
       3 section_id = f8
     2 sequence_nbr = i4
     2 dms_service_ident = vc
     2 copies_nbr = i4
     2 fax_distribute_dt_tm = dq8
     2 adhoc_fax_number = vc
     2 output_content_type = vc
     2 template_version_mode_flag = i2
     2 template_version_dt_tm = dq8
     2 prsnl_reltn_id = f8
     2 output_content_type_cd = f8
     2 file_mask = vc
     2 file_name = vc
     2 output_destinations[*]
       3 output_dest_cd = f8
       3 dms_service_ident = vc
       3 dms_fax_distribute_dt_tm = dq8
       3 dms_adhoc_fax_number = vc
       3 copies_nbr = i4
     2 non_ce_begin_dt_tm = dq8
     2 non_ce_end_dt_tm = dq8
     2 contact_info = vc
     2 custodial_org_id = f8
     2 sender_email = vc
     2 external_content_ident = vc
     2 external_content_name = vc
     2 prsnl_role_profile_uid = vc
   1 test_ind = i2
   1 requesting_locale = c5
   1 print_ind = i2
 )
 FREE RECORD report_reply
 RECORD report_reply(
   1 requests[*]
     2 report_request_id = f8
     2 request_xml = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FOR (idx2 = 1 TO exp_cnt)
  SET idx = ((exp_cnt+ 1) - idx2)
  CALL addexpreportrequest(null)
 ENDFOR
 FOR (idx2 = 1 TO copy_cnt)
   CALL addcopyreportrequest(null)
 ENDFOR
 IF (rr_cnt > 0)
  SET stat = alterlist(report_request->requests,rr_cnt)
  SET report_request->print_ind = 1
  EXECUTE cr_srv_upd_report_requests  WITH replace("REQUEST",report_request), replace("REPLY",
   report_reply)
  SET reply->status_data.status = report_reply->status_data.status
  IF ((report_reply->status_data.status="W"))
   CALL writelogmessage(
    "XR Report Service is not properly configured. Please contact your administrator.")
   IF (log_level >= 2)
    CALL writelogmessage(concat(cnvtstring(rr_cnt,2),
      "report request(s) added with report_request_ids: "))
    FOR (idx = 1 TO size(report_reply->requests,5))
      CALL writelogmessage(concat("  ",cnvtstring(report_reply->requests[idx].report_request_id)))
    ENDFOR
   ENDIF
   COMMIT
  ELSEIF ((report_reply->status_data.status="S"))
   IF (log_level >= 2)
    CALL writelogmessage(concat(cnvtstring(rr_cnt,2),
      "report request(s) added with report_request_ids: "))
    FOR (idx = 1 TO size(report_reply->requests,5))
      CALL writelogmessage(concat("  ",cnvtstring(report_reply->requests[idx].report_request_id)))
    ENDFOR
   ENDIF
   COMMIT
  ELSEIF ((report_reply->status_data.status != "S")
   AND log_level >= 1)
   SET error_ind = 1
   IF (log_level=1
    AND acc_logged_ind=0)
    EXECUTE FROM start_log_accession TO end_log_accession
   ENDIF
   CALL writelogmessage("Failure adding report_requests")
  ENDIF
 ELSEIF (log_level >= 2)
  CALL writelogmessage("No report_requests qualified")
 ENDIF
 SUBROUTINE addexpreportrequest(null)
   IF ((expedite->qual[idx].output_flag != 6))
    IF ((expedite->qual[idx].template_id > 0))
     IF ((((expedite->qual[idx].duplicate_ind=0)) OR ((expedite->qual[idx].duplicate_ind=1)
      AND (expedite->qual[idx].dup_template_ind=0)))
      AND (((expedite->qual[idx].output_dest_cd > 0)) OR (size(trim(expedite->qual[idx].
       dms_service_ident)) > 0))
      AND (expedite->qual[idx].expired_do_not_print=0))
      SET rr_cnt += 1
      IF (mod(rr_cnt,10)=1)
       SET stat = alterlist(report_request->requests,(rr_cnt+ 9))
      ENDIF
      IF ((expedite->qual[idx].manual_expedite_ind=1))
       SET report_request->requests[rr_cnt].scope_flag = expedite->qual[idx].scope_flag
      ELSEIF (powerform_processing_ind=1)
       SET report_request->requests[rr_cnt].scope_flag = 2
      ELSE
       SET report_request->requests[rr_cnt].scope_flag = 4
      ENDIF
      SET report_request->requests[rr_cnt].person_id = request->person_id
      SET report_request->requests[rr_cnt].encntr_id = request->encntr_id
      SET report_request->requests[rr_cnt].order_id = request->orders[1].order_id
      SET report_request->requests[rr_cnt].accession_nbr = request->accession
      SET report_request->requests[rr_cnt].template_id = expedite->qual[idx].template_id
      SET report_request->requests[rr_cnt].trigger_name = expedite->qual[idx].trigger_name
      SET report_request->requests[rr_cnt].request_prsnl_id = 0
      SET report_request->requests[rr_cnt].provider_prsnl_id = expedite->qual[idx].prsnl_person_id
      SET report_request->requests[rr_cnt].provider_reltn_cd = expedite->qual[idx].prsnl_person_r_cd
      IF ((expedite->qual[idx].chart_content_flag=1))
       SET report_request->requests[rr_cnt].begin_dt_tm = request->event_dt_tm
      ENDIF
      SET report_request->requests[rr_cnt].end_dt_tm = request->event_dt_tm
      SET report_request->requests[rr_cnt].output_dest_cd = expedite->qual[idx].output_dest_cd
      SET report_request->requests[rr_cnt].dms_service_ident = trim(expedite->qual[idx].
       dms_service_ident)
      IF (validate(report_request->requests[rr_cnt].custodial_org_id)=1
       AND validate(report_request->requests[rr_cnt].sender_email)=1
       AND size(trim(expedite->qual[idx].dms_service_ident)) > 0
       AND findstring("@OUTPUT_DEST@SECURE_EMAIL",trim(expedite->qual[idx].dms_service_ident)) > 0)
       SET report_request->requests[rr_cnt].custodial_org_id = expedite->qual[idx].sending_org_id
       SET report_request->requests[rr_cnt].sender_email = trim(expedite->qual[idx].sender_email)
      ENDIF
      SET report_request->requests[rr_cnt].adhoc_fax_number = trim(expedite->qual[idx].
       rrd_phone_suffix)
      IF ((expedite->qual[idx].manual_expedite_ind=0))
       SET report_request->requests[rr_cnt].request_type_flag = 2
      ELSE
       SET report_request->requests[rr_cnt].request_type_flag = 3
      ENDIF
      SET report_request->requests[rr_cnt].result_status_flag = 2
      IF ((expedite->qual[idx].event_ind=1))
       SET report_request->requests[rr_cnt].scope_flag = 6
       SET nbr_of_events = size(expedite->qual[idx].event_id_list,5)
       SET stat = alterlist(report_request->requests[rr_cnt].event_ids,nbr_of_events)
       FOR (e_cnt = 1 TO nbr_of_events)
         SET report_request->requests[rr_cnt].event_ids[e_cnt].event_id = expedite->qual[idx].
         event_id_list[e_cnt].event_id
       ENDFOR
      ENDIF
      SET report_request->requests[rr_cnt].user_role_profile = expedite->qual[idx].user_role_profile
      IF ((expedite->qual[idx].manual_provider_id > 0))
       SET report_request->requests[rr_cnt].request_prsnl_id = expedite->qual[idx].
       manual_requestor_id
       SET report_request->requests[rr_cnt].provider_prsnl_id = expedite->qual[idx].
       manual_provider_id
       SET report_request->requests[rr_cnt].provider_reltn_cd = expedite->qual[idx].
       manual_prov_role_cd
       SET report_request->requests[rr_cnt].user_role_profile = expedite->qual[idx].user_role_profile
       CALL writelogmessage(build("Manual expdite sent to provider: ",expedite->qual[idx].
         manual_provider_id))
      ENDIF
      IF ((request->orders[1].event_id > 0))
       SET report_request->requests[rr_cnt].begin_dt_tm = cnvtdatetime("01-JAN-1800 00:00:00.00")
       SET report_request->requests[rr_cnt].scope_flag = 6
       SET nbr_of_events = size(request->orders[1].event_id_list,5)
       SET stat = alterlist(report_request->requests[rr_cnt].event_ids,nbr_of_events)
       FOR (e_cnt = 1 TO nbr_of_events)
         SET report_request->requests[rr_cnt].event_ids[e_cnt].event_id = request->orders[1].
         event_id_list[e_cnt].event_id
       ENDFOR
      ENDIF
     ENDIF
    ELSE
     CALL writelogmessage(concat("Template missing for parameter ",expedite->qual[idx].params_name,
       " under trigger ",expedite->qual[idx].trigger_name," so no expedite sent."))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addcopyreportrequest(null)
   IF ((copy->qual[idx2].template_id > 0))
    IF ((((copy->qual[idx2].duplicate_ind=0)) OR ((copy->qual[idx2].duplicate_ind=1)
     AND (copy->qual[idx2].dup_template_ind=0)))
     AND (((copy->qual[idx2].output_dest_cd > 0)) OR (size(trim(copy->qual[idx2].dms_service_ident))
     > 0)) )
     SET rr_cnt += 1
     IF (mod(rr_cnt,10)=1)
      SET stat = alterlist(report_request->requests,(rr_cnt+ 9))
     ENDIF
     IF (powerform_processing_ind=1)
      SET report_request->requests[rr_cnt].scope_flag = 2
     ELSE
      SET report_request->requests[rr_cnt].scope_flag = 4
     ENDIF
     SET report_request->requests[rr_cnt].person_id = request->person_id
     SET report_request->requests[rr_cnt].encntr_id = request->encntr_id
     SET report_request->requests[rr_cnt].order_id = request->orders[1].order_id
     SET report_request->requests[rr_cnt].accession_nbr = request->accession
     SET report_request->requests[rr_cnt].template_id = copy->qual[idx2].template_id
     SET report_request->requests[rr_cnt].trigger_name = copy->qual[idx2].trigger_name
     IF ((copy->qual[idx2].chart_content_flag=1))
      SET report_request->requests[rr_cnt].begin_dt_tm = request->event_dt_tm
     ENDIF
     SET report_request->requests[rr_cnt].end_dt_tm = request->event_dt_tm
     SET report_request->requests[rr_cnt].result_status_flag = 2
     SET report_request->requests[rr_cnt].output_dest_cd = copy->qual[idx2].output_dest_cd
     IF (validate(report_request->requests[rr_cnt].custodial_org_id)=1
      AND validate(report_request->requests[rr_cnt].sender_email)=1)
      SET report_request->requests[rr_cnt].custodial_org_id = copy->qual[idx2].sending_org_id
      SET report_request->requests[rr_cnt].sender_email = copy->qual[idx2].sender_email
     ENDIF
     SET report_request->requests[rr_cnt].dms_service_ident = trim(copy->qual[idx2].dms_service_ident
      )
     SET report_request->requests[rr_cnt].request_type_flag = 2
     SET report_request->requests[rr_cnt].provider_prsnl_id = copy->qual[idx2].provider_id
     SET report_request->requests[rr_cnt].provider_reltn_cd = copy->qual[idx2].encntr_prsnl_r_cd
     IF ((request->orders[1].event_id > 0))
      SET report_request->requests[rr_cnt].begin_dt_tm = cnvtdatetime("01-JAN-1800 00:00:00.00")
      SET report_request->requests[rr_cnt].scope_flag = 6
      SET nbr_of_events = size(request->orders[1].event_id_list,5)
      SET stat = alterlist(report_request->requests[rr_cnt].event_ids,nbr_of_events)
      FOR (e_cnt = 1 TO nbr_of_events)
        SET report_request->requests[rr_cnt].event_ids[e_cnt].event_id = request->orders[1].
        event_id_list[e_cnt].event_id
      ENDFOR
     ENDIF
    ENDIF
   ELSE
    CALL writelogmessage(concat("Template missing for parameter ",copy->qual[idx2].params_name,
      " under trigger ",copy->qual[idx2].trigger_name," so no additional copy expedite sent."))
   ENDIF
 END ;Subroutine
#end_chart_request
#exit_script
#start_error_check
 CALL echo(build("Status = ",reply->status_data.status))
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
     CALL writelogmessage(trim(error_msg))
     IF (msg_size BETWEEN 100 AND 200)
      CALL writelogmessage(substring(101,100,error_msg))
     ENDIF
     IF (msg_size > 200)
      CALL writelogmessage(substring(101,100,error_msg))
      CALL writelogmessage(substring(201,55,error_msg))
     ENDIF
    ENDIF
  ENDWHILE
 ENDIF
#end_error_check
 IF (log_level >= 4
  AND exp_cnt > 0)
  CALL logrequest(null)
 ENDIF
 IF (log_level >= 1)
  SELECT INTO value(expedite_log)
   d.seq
   FROM dummyt d
   DETAIL
    FOR (x = 1 TO log_rec->message_counter)
      col 1, log_rec->qual[x].message, row + 1
    ENDFOR
   WITH maxcol = 150, format = variable, noformfeed,
    maxrow = 1, noheading, append
  ;end select
 ENDIF
 IF (log_level >= 3)
  SELECT INTO value(expedite_log)
   d.seq
   FROM dummyt d
   DETAIL
    FOR (x = 1 TO log_debug_rec->message_counter)
      col 1, log_debug_rec->qual[x].message, row + 1
    ENDFOR
   WITH maxcol = 150, format = variable, noformfeed,
    maxrow = 1, noheading, append
  ;end select
 ENDIF
 IF (log_level >= 3
  AND no_chart_log_nbr > 1)
  SET no_chart_log_buffer[1] = "*** Report request not produced for the reasons below ***"
  SET no_chart_log_nbr += 1
  SET no_chart_log_buffer[no_chart_log_nbr] =
  "*** Report request not produced for the reasons above ***"
  SELECT INTO value(expedite_log)
   d.seq
   FROM dummyt d
   DETAIL
    FOR (x = 1 TO no_chart_log_nbr)
      col 1, no_chart_log_buffer[x], row + 1
    ENDFOR
   WITH maxcol = 150, format = variable, noformfeed,
    maxrow = 1, noheading, append
  ;end select
 ENDIF
#expedites_off
 SUBROUTINE getprocessmanualexpedites(null)
   DECLARE returnval = i2 WITH noconstant(1), protect
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="ClinicalReporting"
     AND d.info_name="EnableARQManualExpedite"
    DETAIL
     IF (d.info_number != 0)
      returnval = 0
     ENDIF
    WITH nocounter
   ;end select
   RETURN(returnval)
 END ;Subroutine
 SUBROUTINE getpatientlocationattimeoforder(null)
  IF ((request->orders[1].order_id > 0))
   SELECT INTO "nl:"
    FROM orders o,
     encntr_loc_hist elh
    PLAN (o
     WHERE (o.order_id=request->orders[1].order_id))
     JOIN (elh
     WHERE (elh.encntr_id=request->encntr_id)
      AND elh.encntr_id > 0
      AND elh.active_ind=1
      AND o.orig_order_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
    HEAD REPORT
     encntr->pat_loc_facility_cd = elh.loc_facility_cd, encntr->pat_loc_building_cd = elh
     .loc_building_cd, encntr->pat_loc_nurse_unit_cd = elh.loc_nurse_unit_cd,
     encntr->pat_loc_room_cd = elh.loc_room_cd, encntr->pat_loc_bed_cd = elh.loc_bed_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM order_action oa,
      encntr_loc_hist elh
     PLAN (oa
      WHERE (oa.order_id=request->orders[1].order_id)
       AND oa.action_sequence=1)
      JOIN (elh
      WHERE (elh.encntr_id=request->encntr_id)
       AND elh.encntr_id > 0
       AND elh.active_ind=1
       AND oa.action_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
     HEAD REPORT
      encntr->pat_loc_facility_cd = elh.loc_facility_cd, encntr->pat_loc_building_cd = elh
      .loc_building_cd, encntr->pat_loc_nurse_unit_cd = elh.loc_nurse_unit_cd,
      encntr->pat_loc_room_cd = elh.loc_room_cd, encntr->pat_loc_bed_cd = elh.loc_bed_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL writelogmessage("Patient location at time of order not determined")
    ENDIF
   ENDIF
  ELSEIF ((request->orders[1].event_id > 0))
   SELECT INTO "nl:"
    ce.event_end_dt_tm";;q", elh.beg_effective_dt_tm";;q", elh.end_effective_dt_tm";;q"
    FROM clinical_event ce,
     encntr_loc_hist elh
    PLAN (ce
     WHERE (ce.event_id=request->orders[1].event_id)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
     JOIN (elh
     WHERE (elh.encntr_id=request->encntr_id)
      AND elh.active_ind=1
      AND ce.event_end_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
    HEAD REPORT
     encntr->pat_loc_facility_cd = elh.loc_facility_cd, encntr->pat_loc_building_cd = elh
     .loc_building_cd, encntr->pat_loc_nurse_unit_cd = elh.loc_nurse_unit_cd,
     encntr->pat_loc_room_cd = elh.loc_room_cd, encntr->pat_loc_bed_cd = elh.loc_bed_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL writelogmessage("Patient location at time of event not determined")
   ENDIF
  ENDIF
  IF (curqual > 0)
   CALL writelogmessage("Patient location at time of event retrieved: ")
   CALL writelogmessage(concat(build(" Facility: ",encntr->pat_loc_facility_cd),build(" Building: ",
      encntr->pat_loc_building_cd),build(" Nurse unit: ",encntr->pat_loc_nurse_unit_cd),build(
      " Room: ",encntr->pat_loc_room_cd),build(" Bed: ",encntr->pat_loc_bed_cd)))
  ENDIF
 END ;Subroutine
 SUBROUTINE getadmittingprovider(null)
  SELECT INTO "nl:"
   epr.prsnl_person_id, epr.encntr_prsnl_r_cd
   FROM encntr_prsnl_reltn epr,
    prsnl p
   PLAN (epr
    WHERE (request->encntr_id=epr.encntr_id)
     AND epr.encntr_id > 0
     AND epr.encntr_prsnl_r_cd=admitdoc_type_cd
     AND epr.active_ind=1
     AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (p
    WHERE p.active_ind=1
     AND p.person_id=epr.prsnl_person_id)
   DETAIL
    admitdoc_id = epr.prsnl_person_id, admitdoc_exp_ind = epr.expiration_ind
   WITH nocounter
  ;end select
  IF (admitdoc_id=0)
   CALL writelogmessage(build("No admitting physician for encounter: ",request->encntr_id))
  ELSE
   CALL writelogmessage(build("Admitting physician is: ",admitdoc_id))
  ENDIF
 END ;Subroutine
 SUBROUTINE logrequest(null)
   IF (log_level >= 4)
    CALL writelogmessage("Request: ")
    FOR (idx = 1 TO order_total)
      CALL writelogmessage(concat("  order_id: ",cnvtstring(request->orders[idx].order_id)))
      CALL writelogmessage(concat("  event_id: ",cnvtstring(request->orders[idx].event_id)))
      CALL writelogmessage(concat("  order_complete_ind: ",cnvtstring(request->orders[idx].
         order_complete_ind)))
      CALL writelogmessage(concat("  catalog_type_cd: ",cnvtstring(request->orders[idx].
         catalog_type_cd)))
      CALL writelogmessage(concat("  activity_type_cd: ",cnvtstring(request->orders[idx].
         activity_type_cd)))
      CALL writelogmessage(concat("  event_cd: ",cnvtstring(request->orders[idx].event_cd)))
      CALL writelogmessage(concat("  catalog_cd: ",cnvtstring(request->orders[idx].catalog_cd)))
      CALL writelogmessage(concat("  reference_task_id: ",cnvtstring(request->orders[idx].
         reference_task_id)))
      SET cur_total = size(request->orders[idx].assays,5)
      FOR (idx2 = 1 TO cur_total)
        CALL writelogmessage(concat("    task_assay_cd: ",cnvtstring(request->orders[idx].assays[idx2
           ].task_assay_cd)))
        CALL writelogmessage(concat("    event_cd: ",cnvtstring(request->orders[idx].assays[idx2].
           event_cd)))
        CALL writelogmessage(concat("    report_priority_cd: ",cnvtstring(request->orders[idx].
           assays[idx2].report_priority_cd)))
        CALL writelogmessage(concat("    result_range_cd: ",cnvtstring(request->orders[idx].assays[
           idx2].result_range_cd)))
        CALL writelogmessage(concat("    result_status_cd: ",cnvtstring(request->orders[idx].assays[
           idx2].result_status_cd)))
        CALL writelogmessage(concat("    result_cd: ",cnvtstring(request->orders[idx].assays[idx2].
           result_cd)))
        CALL writelogmessage(concat("    result_nbr: ",cnvtstring(request->orders[idx].assays[idx2].
           result_nbr)))
        CALL writelogmessage(concat("    report_processing_cd: ",cnvtstring(request->orders[idx].
           assays[idx2].report_processing_cd)))
        CALL writelogmessage(concat("    report_processing_nbr: ",cnvtstring(request->orders[idx].
           assays[idx2].report_processing_nbr)))
        CALL writelogmessage(concat("    service_resource_cd: ",cnvtstring(request->orders[idx].
           assays[idx2].service_resource_cd)))
      ENDFOR
      SET num_events = size(request->orders[idx].event_id_list,5)
      IF (num_events > 0)
       FOR (idx3 = 1 TO num_events)
        CALL writelogmessage(concat("    event_id: ",cnvtstring(request->orders[idx].event_id_list[
           idx3].event_id)))
        CALL writelogmessage(concat("    result_status_cd: ",cnvtstring(request->orders[idx].
           event_id_list[idx3].result_status_cd)))
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (writelogmessage(str=vc) =null)
   SET log_rec->message_counter += 1
   IF (mod(log_rec->message_counter,log_buffer_growth)=1)
    SET stat = alterlist(log_rec->qual,((log_rec->message_counter+ log_buffer_growth) - 1))
   ENDIF
   SET log_rec->qual[log_rec->message_counter].message = str
 END ;Subroutine
 SUBROUTINE (writedebuglogmessage(str=vc) =null)
   SET log_debug_rec->message_counter += 1
   IF (mod(log_debug_rec->message_counter,log_debug_buffer_growth)=1)
    SET stat = alterlist(log_debug_rec->qual,((log_debug_rec->message_counter+
     log_debug_buffer_growth) - 1))
   ENDIF
   SET log_debug_rec->qual[log_debug_rec->message_counter].message = str
 END ;Subroutine
 SUBROUTINE locationdestinations(null)
   CALL writelogmessage(
    "Looking for LOCATION destination cross references in CR_DESTINATION_XREF table")
   SELECT INTO "nl:"
    od.output_dest_cd
    FROM cr_destination_xref x,
     output_dest od,
     device d
    PLAN (x
     WHERE x.parent_entity_id IN (encntr->cur_loc_facility_cd, encntr->cur_loc_building_cd, encntr->
     cur_loc_nurse_unit_cd, encntr->cur_loc_room_cd, encntr->cur_loc_bed_cd,
     encntr->cur_loc_temp_cd)
      AND x.parent_entity_name="LOCATION")
     JOIN (d
     WHERE d.device_cd=x.device_cd)
     JOIN (od
     WHERE od.device_cd=d.device_cd)
    HEAD REPORT
     loc_lvl = 9
    DETAIL
     CASE (x.parent_entity_id)
      OF encntr->cur_loc_facility_cd:
       IF (5 < loc_lvl)
        loc_output_dest_cd = od.output_dest_cd, loc_output_dest_name = od.name
        IF (d.name != od.name)
         loc_device_name = d.name
        ENDIF
        loc_dms_service_ident = trim(x.dms_service_identifier), loc_lvl = 5
       ENDIF
      OF encntr->cur_loc_building_cd:
       IF (4 < loc_lvl)
        loc_output_dest_cd = od.output_dest_cd, loc_output_dest_name = od.name
        IF (d.name != od.name)
         loc_device_name = d.name
        ENDIF
        loc_dms_service_ident = trim(x.dms_service_identifier), loc_lvl = 4
       ENDIF
      OF encntr->cur_loc_nurse_unit_cd:
       IF (3 < loc_lvl)
        loc_output_dest_cd = od.output_dest_cd, loc_output_dest_name = od.name
        IF (d.name != od.name)
         loc_device_name = d.name
        ENDIF
        loc_dms_service_ident = trim(x.dms_service_identifier), loc_lvl = 3
       ENDIF
      OF encntr->cur_loc_room_cd:
       IF (2 < loc_lvl)
        loc_output_dest_cd = od.output_dest_cd, loc_output_dest_name = od.name
        IF (d.name != od.name)
         loc_device_name = d.name
        ENDIF
        loc_dms_service_ident = trim(x.dms_service_identifier), loc_lvl = 2
       ENDIF
      OF encntr->cur_loc_bed_cd:
       IF (1 < loc_lvl)
        loc_output_dest_cd = od.output_dest_cd, loc_output_dest_name = od.name
        IF (d.name != od.name)
         loc_device_name = d.name
        ENDIF
        loc_dms_service_ident = trim(x.dms_service_identifier), loc_lvl = 1
       ENDIF
      OF encntr->cur_loc_temp_cd:
       loc_temp_output_dest_cd = od.output_dest_cd,loc_temp_output_dest_name = od.name,
       IF (d.name != od.name)
        loc_temp_device_name = d.name
       ENDIF
       ,loc_temp_dms_service_ident = trim(x.dms_service_identifier)
     ENDCASE
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    od.output_dest_cd
    FROM cr_destination_xref x,
     output_dest od,
     device d
    PLAN (x
     WHERE x.parent_entity_id IN (encntr->pat_loc_facility_cd, encntr->pat_loc_building_cd, encntr->
     pat_loc_nurse_unit_cd, encntr->pat_loc_room_cd, encntr->pat_loc_bed_cd)
      AND x.parent_entity_name="LOCATION"
      AND x.parent_entity_id > 0)
     JOIN (d
     WHERE d.device_cd=x.device_cd)
     JOIN (od
     WHERE od.device_cd=d.device_cd)
    HEAD REPORT
     pat_lvl = 9
    DETAIL
     CASE (x.parent_entity_id)
      OF encntr->pat_loc_facility_cd:
       IF (5 < pat_lvl)
        pat_output_dest_cd = od.output_dest_cd, pat_output_dest_name = od.name
        IF (d.name != od.name)
         pat_device_name = d.name
        ENDIF
        pat_dms_service_ident = trim(x.dms_service_identifier), pat_lvl = 5
       ENDIF
      OF encntr->pat_loc_building_cd:
       IF (4 < pat_lvl)
        pat_output_dest_cd = od.output_dest_cd, pat_output_dest_name = od.name
        IF (d.name != od.name)
         pat_device_name = d.name
        ENDIF
        pat_dms_service_ident = trim(x.dms_service_identifier), pat_lvl = 4
       ENDIF
      OF encntr->pat_loc_nurse_unit_cd:
       IF (3 < pat_lvl)
        pat_output_dest_cd = od.output_dest_cd, pat_output_dest_name = od.name
        IF (d.name != od.name)
         pat_device_name = d.name
        ENDIF
        pat_dms_service_ident = trim(x.dms_service_identifier), pat_lvl = 3
       ENDIF
      OF encntr->pat_loc_room_cd:
       IF (2 < pat_lvl)
        pat_output_dest_cd = od.output_dest_cd, pat_output_dest_name = od.name
        IF (d.name != od.name)
         pat_device_name = d.name
        ENDIF
        pat_dms_service_ident = trim(x.dms_service_identifier), pat_lvl = 2
       ENDIF
      OF encntr->pat_loc_bed_cd:
       IF (1 < pat_lvl)
        pat_output_dest_cd = od.output_dest_cd, pat_output_dest_name = od.name
        IF (d.name != od.name)
         pat_device_name = d.name
        ENDIF
        pat_dms_service_ident = trim(x.dms_service_identifier), pat_lvl = 1
       ENDIF
     ENDCASE
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    od.output_dest_cd
    FROM cr_destination_xref x,
     output_dest od,
     device d
    PLAN (x
     WHERE x.parent_entity_id IN (encntr->ord_loc_facility_cd, encntr->ord_loc_building_cd, encntr->
     ord_loc_nurse_unit_cd, encntr->ord_loc_room_cd, encntr->ord_loc_bed_cd)
      AND x.parent_entity_name="LOCATION")
     JOIN (d
     WHERE d.device_cd=x.device_cd)
     JOIN (od
     WHERE od.device_cd=d.device_cd)
    HEAD REPORT
     ord_lvl = 9
    DETAIL
     CASE (x.parent_entity_id)
      OF encntr->ord_loc_facility_cd:
       IF (5 < ord_lvl)
        ord_output_dest_cd = od.output_dest_cd, ord_output_dest_name = od.name
        IF (d.name != od.name)
         ord_device_name = d.name
        ENDIF
        ord_dms_service_ident = trim(x.dms_service_identifier), ord_lvl = 5
       ENDIF
      OF encntr->ord_loc_building_cd:
       IF (4 < ord_lvl)
        ord_output_dest_cd = od.output_dest_cd, ord_output_dest_name = od.name
        IF (d.name != od.name)
         ord_device_name = d.name
        ENDIF
        ord_dms_service_ident = trim(x.dms_service_identifier), ord_lvl = 4
       ENDIF
      OF encntr->ord_loc_nurse_unit_cd:
       IF (3 < ord_lvl)
        ord_output_dest_cd = od.output_dest_cd, ord_output_dest_name = od.name
        IF (d.name != od.name)
         ord_device_name = d.name
        ENDIF
        ord_dms_service_ident = trim(x.dms_service_identifier), ord_lvl = 3
       ENDIF
      OF encntr->ord_loc_room_cd:
       IF (2 < ord_lvl)
        ord_output_dest_cd = od.output_dest_cd, ord_output_dest_name = od.name
        IF (d.name != od.name)
         ord_device_name = d.name
        ENDIF
        ord_dms_service_ident = trim(x.dms_service_identifier), ord_lvl = 2
       ENDIF
      OF encntr->ord_loc_bed_cd:
       IF (1 < ord_lvl)
        ord_output_dest_cd = od.output_dest_cd, ord_output_dest_name = od.name
        IF (d.name != od.name)
         ord_device_name = d.name
        ENDIF
        ord_dms_service_ident = trim(x.dms_service_identifier), ord_lvl = 1
       ENDIF
     ENDCASE
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE serviceresourcedestinations(null)
  CALL writelogmessage(
   "Looking for SERVICE_RESOURCE destination cross references in CR_DESTINATION_XREF table")
  FOR (idx = 1 TO exp_cnt)
    IF ((expedite->qual[idx].output_flag=4)
     AND (expedite->qual[idx].output_dest_cd=0)
     AND size(trim(expedite->qual[idx].dms_service_ident))=0)
     SET sr_output_dest_cd = 0
     SELECT INTO "nl:"
      od.output_dest_cd
      FROM (dummyt d1  WITH seq = value(tree_cnt)),
       cr_destination_xref x,
       device d,
       output_dest od
      PLAN (d1
       WHERE (tree->qual[d1.seq].lowest_child_cd=expedite->qual[idx].service_resource_cd))
       JOIN (x
       WHERE (x.parent_entity_id=tree->qual[d1.seq].code_value)
        AND x.parent_entity_name="SERVICE_RESOURCE")
       JOIN (d
       WHERE d.device_cd=x.device_cd)
       JOIN (od
       WHERE od.device_cd=d.device_cd)
      HEAD REPORT
       sr_lvl = 9, sr_output_dest_cd = 0, sr_output_dest_name = fillstring(20," "),
       sr_output_device_name = fillstring(20," ")
      DETAIL
       IF (5 < sr_lvl
        AND (tree->qual[d1.seq].sr_tree_lvl=5))
        sr_output_dest_cd = od.output_dest_cd, sr_output_dest_name = od.name
        IF (d.name != od.name)
         sr_output_device_name = d.name
        ENDIF
        sr_dms_service_ident = trim(x.dms_service_identifier), sr_lvl = 5
       ENDIF
       IF (4 < sr_lvl
        AND (tree->qual[d1.seq].sr_tree_lvl=4))
        sr_output_dest_cd = od.output_dest_cd, sr_output_dest_name = od.name
        IF (d.name != od.name)
         sr_output_device_name = d.name
        ENDIF
        sr_dms_service_ident = trim(x.dms_service_identifier), sr_lvl = 4
       ENDIF
       IF (3 < sr_lvl
        AND (tree->qual[d1.seq].sr_tree_lvl=3))
        sr_output_dest_cd = od.output_dest_cd, sr_output_dest_name = od.name
        IF (d.name != od.name)
         sr_output_device_name = d.name
        ENDIF
        sr_dms_service_ident = trim(x.dms_service_identifier), sr_lvl = 3
       ENDIF
       IF (2 < sr_lvl
        AND (tree->qual[d1.seq].sr_tree_lvl=2))
        sr_output_dest_cd = od.output_dest_cd, sr_output_dest_name = od.name
        IF (d.name != od.name)
         sr_output_device_name = d.name
        ENDIF
        sr_dms_service_ident = trim(x.dms_service_identifier), sr_lvl = 2
       ENDIF
       IF (1 < sr_lvl
        AND (tree->qual[d1.seq].sr_tree_lvl=1))
        sr_output_dest_cd = od.output_dest_cd, sr_output_dest_name = od.name
        IF (d.name != od.name)
         sr_output_device_name = d.name
        ENDIF
        sr_dms_service_ident = trim(x.dms_service_identifier), sr_lvl = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (((sr_output_dest_cd > 0) OR (size(trim(sr_dms_service_ident)) > 0)) )
      FOR (idx2 = 1 TO exp_cnt)
        IF ((expedite->qual[idx2].output_flag=4)
         AND (expedite->qual[idx2].service_resource_cd=expedite->qual[idx].service_resource_cd))
         SET expedite->qual[idx2].output_dest_cd = sr_output_dest_cd
         SET expedite->qual[idx2].output_dest_name = sr_output_dest_name
         IF (trim(cnvtupper(sr_output_dest_name)) != trim(cnvtupper(sr_output_device_name)))
          SET expedite->qual[idx2].device_name = sr_output_device_name
         ENDIF
         SET expedite->qual[idx2].dms_service_ident = sr_dms_service_ident
        ENDIF
      ENDFOR
     ELSE
      IF (log_level >= 1)
       SET error_ind = 1
       IF (log_level=1
        AND acc_logged_ind=0)
        EXECUTE FROM start_log_accession TO end_log_accession
       ENDIF
       CALL writelogmessage(concat("No Destination xref found for service resource: ",cnvtstring(
          expedite->qual[idx].service_resource_cd)))
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE organizationdestinations(null)
  CALL writelogmessage(
   "Looking for ORGANIZATION destination cross references in CR_DESTINATION_XREF table")
  SELECT INTO "nl:"
   od.output_dest_cd
   FROM cr_destination_xref x,
    device d,
    output_dest od
   PLAN (x
    WHERE (x.parent_entity_id=encntr->organization_id)
     AND x.parent_entity_name="ORGANIZATION")
    JOIN (d
    WHERE d.device_cd=x.device_cd)
    JOIN (od
    WHERE od.device_cd=d.device_cd)
   HEAD REPORT
    org_output_dest_cd = od.output_dest_cd, org_output_dest_name = od.name
    IF (trim(cnvtupper(od.name)) != trim(cnvtupper(d.name)))
     org_output_device_name = d.name
    ENDIF
    org_dms_service_ident = trim(x.dms_service_identifier)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE providerdestinations(null)
  CALL writelogmessage("Looking for PRSNL destination cross references in CR_DESTINATION_XREF table")
  SELECT INTO "nl:"
   od.output_dest_cd
   FROM cr_destination_xref x,
    device d,
    output_dest od
   PLAN (x
    WHERE x.parent_entity_id=order_provider_id
     AND x.parent_entity_name="PRSNL")
    JOIN (d
    WHERE d.device_cd=x.device_cd)
    JOIN (od
    WHERE od.device_cd=d.device_cd)
   HEAD REPORT
    provider_output_dest_cd = od.output_dest_cd, provider_output_dest_name = od.name
    IF (trim(cnvtupper(od.name)) != trim(cnvtupper(d.name)))
     provider_device_name = d.name
    ENDIF
    provider_dms_service_ident = trim(x.dms_service_identifier)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE copytodestinations(null)
  CALL writelogmessage(
   "Looking for COPY TO PRSNL destination cross references in CR_DESTINATION_XREF table")
  SELECT INTO "nl:"
   od.output_dest_cd
   FROM (dummyt d1  WITH seq = value(copy_cnt)),
    cr_destination_xref x,
    device d,
    output_dest od
   PLAN (d1
    WHERE (((copy->qual[d1.seq].duplicate_ind=0)) OR ((copy->qual[d1.seq].duplicate_ind=1)
     AND (copy->qual[d1.seq].dup_template_ind=0))) )
    JOIN (x
    WHERE (x.parent_entity_id=copy->qual[d1.seq].provider_id)
     AND x.parent_entity_name="PRSNL")
    JOIN (d
    WHERE d.device_cd=x.device_cd)
    JOIN (od
    WHERE od.device_cd=d.device_cd)
   DETAIL
    copy->qual[d1.seq].output_dest_cd = od.output_dest_cd, copy->qual[d1.seq].output_dest_name = od
    .name
    IF (d.name != od.name)
     copy->qual[d1.seq].device_name = d.name
    ENDIF
    copy->qual[d1.seq].dms_service_ident = trim(x.dms_service_identifier)
   WITH nocounter
  ;end select
 END ;Subroutine
#end_of_script
 FREE RECORD log_rec
 FREE RECORD log_debug_rec
END GO
