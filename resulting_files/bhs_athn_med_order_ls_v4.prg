CREATE PROGRAM bhs_athn_med_order_ls_v4
 DECLARE moutputdevice = vc WITH noconstant( $1)
 DECLARE order_status_list = vc WITH constant( $5)
 DECLARE active_ord_status = vc WITH noconstant("1")
 FREE RECORD act_order_status_ls
 RECORD act_order_status_ls(
   1 qual[6]
     2 order_status_cd = vc
 )
 SET act_order_status_ls->qual[0].order_status_cd = "1"
 SET act_order_status_ls->qual[1].order_status_cd = "2546"
 SET act_order_status_ls->qual[2].order_status_cd = "2547"
 SET act_order_status_ls->qual[3].order_status_cd = "2548"
 SET act_order_status_ls->qual[4].order_status_cd = "2549"
 SET act_order_status_ls->qual[5].order_status_cd = "2550"
 SET act_order_status_ls->qual[6].order_status_cd = "2552"
 FOR (i = 0 TO 6)
  SET act_ord_status = act_order_status_ls->qual[i].order_status_cd
  IF (findstring(act_ord_status,order_status_list) > 0)
   SET active_ord_status = build(active_ord_status,",",act_ord_status)
  ENDIF
 ENDFOR
 SET where_act_ord_params = build(" O.order_status_cd IN (",trim(active_ord_status),") ")
 DECLARE other_ord_status = vc WITH noconstant("1")
 FREE RECORD oth_order_status_ls1
 RECORD oth_order_status_ls1(
   1 qual[6]
     2 order_status_cd = vc
 )
 FREE RECORD oth_order_status_ls2
 RECORD oth_order_status_ls2(
   1 qual[3]
     2 order_status_cd = vc
 )
 SET oth_order_status_ls1->qual[0].order_status_cd = "1"
 SET oth_order_status_ls1->qual[1].order_status_cd = "2542"
 SET oth_order_status_ls1->qual[2].order_status_cd = "2543"
 SET oth_order_status_ls1->qual[3].order_status_cd = "2544"
 SET oth_order_status_ls1->qual[4].order_status_cd = "2545"
 SET oth_order_status_ls1->qual[5].order_status_cd = "2551"
 SET oth_order_status_ls1->qual[6].order_status_cd = "2553"
 SET oth_order_status_ls2->qual[0].order_status_cd = "1"
 SET oth_order_status_ls2->qual[1].order_status_cd = "614538"
 SET oth_order_status_ls2->qual[2].order_status_cd = "643466"
 SET oth_order_status_ls2->qual[3].order_status_cd = "643467"
 FOR (i = 0 TO 6)
  SET oth_ord_status1 = oth_order_status_ls1->qual[i].order_status_cd
  IF (findstring(oth_ord_status1,order_status_list) > 0)
   SET other_ord_status = build(other_ord_status,",",oth_ord_status1)
  ENDIF
 ENDFOR
 FOR (i = 0 TO 3)
  SET oth_ord_status2 = oth_order_status_ls2->qual[i].order_status_cd
  IF (findstring(oth_ord_status2,order_status_list) > 0)
   SET other_ord_status = build(other_ord_status,",",oth_ord_status2)
  ENDIF
 ENDFOR
 SET where_oth_ord_params = build(" O.order_status_cd IN (",trim(other_ord_status),") ")
 SET where_params = build(" O.CATALOG_TYPE_CD IN ", $4)
 IF (( $3 != 0))
  SET where_params1 = build("(O.ENCNTR_ID =", $3," OR O.ENCNTR_ID=0) AND O.PERSON_ID=", $2)
 ELSE
  SET where_params1 = build("O.PERSON_ID =", $2)
 ENDIF
 DECLARE ncollect_ind = i4
 DECLARE request_st_ind = i4
 DECLARE vcnt = i4
 FREE RECORD order_list
 RECORD order_list(
   1 qual[*]
     2 order_id = f8
     2 person_id = vc
     2 encounter_id = f8
     2 catalog_cd = vc
     2 catalog_disp = vc
     2 catalog_mean = vc
     2 order_catalog_synonym_id = vc
     2 format_id = vc
     2 hnaorder_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 mnemonic = vc
     2 ordered_datetime = vc
     2 ordered_timezone = vc
     2 start_datetime = vc
     2 startdate_timezone = vc
     2 original_ordering_provider_id = vc
     2 original_ordering_providername = vc
     2 order_status_cd = vc
     2 order_status_mean = vc
     2 order_status_disp = vc
     2 nurse_review_indicator = vc
     2 provider_cosign_flag = vc
     2 pharmacist_review_flag = vc
     2 clinical_displayline = vc
     2 catalog_type_cd = vc
     2 catalog_type_mean = vc
     2 catalog_type_disp = vc
     2 activity_type_cd = vc
     2 activity_type_mean = vc
     2 activity_type_disp = vc
     2 clinical_category_cd = vc
     2 clinical_category_mean = vc
     2 clinical_category_disp = vc
     2 order_catalog_cki = vc
     2 orderable_type_flag = vc
     2 action_sequence = i4
     2 prn_indicator = i2
     2 medication_ordertype_mean = vc
     2 medication_ordertype_cd = vc
     2 medication_ordered_as_flag = vc
     2 frequency_type_flag = vc
     2 department_status_cd = f8
     2 department_status_mean = vc
     2 department_status_disp = vc
     2 departmental_displayline = vc
     2 template_order_flag = vc
     2 template_order_id = f8
     2 billonly_indicator = i2
     2 witness_flag = i2
     2 pathway_plan = vc
     2 proposal_status = vc
     2 dcdisplay_days = vc
     2 default_stop_duration = f8
     2 stop_duration_unit_cd = f8
     2 stop_duration_unit = vc
     2 disable_order_comment_flag = i2
     2 protocol_order_id = vc
     2 reftext_mask = vc
     2 frequency = vc
     2 stop_datetime = vc
     2 stopdate_timezone = vc
 )
 SELECT INTO "nl:"
  o.order_id
  FROM orders o
  PLAN (o
   WHERE parser(where_params)
    AND parser(where_params1)
    AND parser(where_oth_ord_params)
    AND o.updt_dt_tm BETWEEN cnvtdatetime( $6) AND cnvtdatetime( $7)
    AND o.template_order_flag IN (0, 1, 6, 7))
  DETAIL
   vcnt += 1, stat = alterlist(order_list->qual,vcnt), order_list->qual[vcnt].order_id = o.order_id
  WITH nocounter, separator = " ", format,
   time = 60
 ;end select
 SELECT INTO "nl:"
  o.order_id
  FROM orders o
  PLAN (o
   WHERE parser(where_params)
    AND parser(where_params1)
    AND parser(where_act_ord_params)
    AND o.template_order_flag IN (0, 1, 6, 7))
  DETAIL
   vcnt += 1, stat = alterlist(order_list->qual,vcnt), order_list->qual[vcnt].order_id = o.order_id
  WITH nocounter, separator = " ", format,
   time = 60
 ;end select
 SELECT DISTINCT INTO "NL:"
  o.order_id
  FROM (dummyt d1  WITH seq = size(order_list->qual,5)),
   orders o,
   order_action oa,
   prsnl prl,
   order_catalog oc,
   order_catalog_synonym os,
   pathway_catalog p,
   order_proposal op,
   frequency_schedule fs,
   order_detail od1
  PLAN (d1)
   JOIN (o
   WHERE (o.order_id=order_list->qual[d1.seq].order_id))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=2534.00)
   JOIN (prl
   WHERE (prl.person_id= Outerjoin(oa.order_provider_id)) )
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (os
   WHERE (os.synonym_id= Outerjoin(o.synonym_id))
    AND (os.catalog_cd= Outerjoin(o.catalog_cd)) )
   JOIN (p
   WHERE (p.pathway_catalog_id= Outerjoin(o.pathway_catalog_id)) )
   JOIN (op
   WHERE (op.order_id= Outerjoin(o.order_id))
    AND (op.encntr_id= Outerjoin(o.encntr_id)) )
   JOIN (fs
   WHERE (fs.frequency_id= Outerjoin(o.frequency_id))
    AND (fs.active_ind= Outerjoin(1)) )
   JOIN (od1
   WHERE (od1.order_id= Outerjoin(o.order_id))
    AND (od1.oe_field_meaning= Outerjoin("STOPDTTM")) )
  ORDER BY o.catalog_type_cd, o.encntr_id, o.order_id,
   od1.action_sequence DESC
  HEAD o.order_id
   order_list->qual[d1.seq].encounter_id = o.encntr_id, order_list->qual[d1.seq].
   order_catalog_synonym_id = cnvtstring(o.synonym_id), order_list->qual[d1.seq].person_id =
   cnvtstring(o.person_id),
   order_list->qual[d1.seq].catalog_cd = cnvtstring(o.catalog_cd), order_list->qual[d1.seq].
   catalog_disp = uar_get_code_display(o.catalog_cd), order_list->qual[d1.seq].format_id = cnvtstring
   (o.oe_format_id),
   order_list->qual[d1.seq].hnaorder_mnemonic = trim(o.hna_order_mnemonic,3), order_list->qual[d1.seq
   ].ordered_as_mnemonic = trim(o.ordered_as_mnemonic,3), order_list->qual[d1.seq].mnemonic = trim(os
    .mnemonic,3),
   order_list->qual[d1.seq].ordered_datetime = format(o.orig_order_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
   order_list->qual[d1.seq].ordered_timezone = substring(21,3,datetimezoneformat(o.orig_order_dt_tm,o
     .orig_order_tz,"MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)), order_list->qual[d1.seq].
   start_datetime = format(o.current_start_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
   order_list->qual[d1.seq].startdate_timezone = substring(21,3,datetimezoneformat(o
     .current_start_dt_tm,o.current_start_tz,"MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)), order_list->
   qual[d1.seq].original_ordering_provider_id = cnvtstring(oa.order_provider_id), order_list->qual[d1
   .seq].original_ordering_providername = trim(prl.name_full_formatted,3),
   order_list->qual[d1.seq].order_status_cd = cnvtstring(o.order_status_cd), order_list->qual[d1.seq]
   .order_status_disp = uar_get_code_display(o.order_status_cd), order_list->qual[d1.seq].
   order_status_mean = uar_get_code_meaning(o.order_status_cd),
   order_list->qual[d1.seq].nurse_review_indicator = trim(substring(0,25,
     IF (o.need_nurse_review_ind=1) "NurseReviewRequired"
     ELSE "NurseReviewNotRequired"
     ENDIF
     ),3), order_list->qual[d1.seq].provider_cosign_flag = trim(substring(0,30,
     IF (o.need_doctor_cosign_ind=0) "DoesNotNeedDoctorCosign"
     ELSEIF (o.need_doctor_cosign_ind=1) "NeedsDoctorCosign"
     ELSEIF (o.need_doctor_cosign_ind=2) "CosignRefusedByDoctor"
     ENDIF
     ),3), order_list->qual[d1.seq].pharmacist_review_flag = trim(substring(0,30,
     IF (o.need_rx_verify_ind=0) "PharmacistReviewNotRequired"
     ELSEIF (o.need_rx_verify_ind=1) "NeedsPharmacistReview"
     ELSEIF (o.need_rx_verify_ind=2) "RejectedByPharmacist"
     ENDIF
     ),3),
   order_list->qual[d1.seq].clinical_displayline = trim(o.clinical_display_line,3), order_list->qual[
   d1.seq].catalog_type_cd = cnvtstring(o.catalog_type_cd), order_list->qual[d1.seq].
   catalog_type_disp = uar_get_code_display(o.catalog_type_cd),
   order_list->qual[d1.seq].catalog_type_mean = uar_get_code_meaning(o.catalog_type_cd), order_list->
   qual[d1.seq].activity_type_cd = cnvtstring(o.activity_type_cd), order_list->qual[d1.seq].
   activity_type_disp = uar_get_code_display(o.activity_type_cd),
   order_list->qual[d1.seq].activity_type_mean = uar_get_code_meaning(o.activity_type_cd), order_list
   ->qual[d1.seq].clinical_category_cd = cnvtstring(o.dcp_clin_cat_cd), order_list->qual[d1.seq].
   clinical_category_disp = uar_get_code_display(o.dcp_clin_cat_cd),
   order_list->qual[d1.seq].clinical_category_mean = uar_get_code_meaning(o.dcp_clin_cat_cd),
   order_list->qual[d1.seq].order_catalog_cki = trim(o.cki,3), order_list->qual[d1.seq].
   orderable_type_flag = trim(substring(0,8,
     IF (o.orderable_type_flag=0) "NORMAL"
     ENDIF
     ),3),
   order_list->qual[d1.seq].action_sequence = oa.action_sequence, order_list->qual[d1.seq].
   prn_indicator = cnvtbool(o.prn_ind), order_list->qual[d1.seq].medication_ordertype_cd = cnvtstring
   (o.med_order_type_cd),
   order_list->qual[d1.seq].medication_ordertype_mean = uar_get_code_meaning(o.med_order_type_cd),
   order_list->qual[d1.seq].medication_ordered_as_flag = substring(0,30,
    IF (o.orig_ord_as_flag=0) "NormalOrder"
    ELSEIF (o.orig_ord_as_flag=1) "PrescriptionDischarge"
    ELSEIF (o.orig_ord_as_flag=2) "RecordedOrHomeMeds"
    ELSEIF (o.orig_ord_as_flag=3) "PatientOwnsMeds"
    ELSEIF (o.orig_ord_as_flag=4) "PharmacyChargeOnly"
    ELSEIF (o.orig_ord_as_flag=5) "SatelliteSuperBillsMeds"
    ENDIF
    ), order_list->qual[d1.seq].frequency_type_flag = cnvtstring(o.freq_type_flag),
   order_list->qual[d1.seq].department_status_cd = o.dept_status_cd, order_list->qual[d1.seq].
   department_status_disp = uar_get_code_display(o.dept_status_cd), order_list->qual[d1.seq].
   department_status_mean = uar_get_code_meaning(o.dept_status_cd),
   order_list->qual[d1.seq].departmental_displayline = trim(o.order_detail_display_line,3),
   order_list->qual[d1.seq].template_order_flag = trim(substring(0,25,
     IF (o.template_order_flag=0) "None"
     ELSEIF (o.template_order_flag=1) "Template"
     ELSEIF (o.template_order_flag=2) "Order Based Instance"
     ELSEIF (o.template_order_flag=3) "Task Based Instance"
     ELSEIF (o.template_order_flag=4) "Rx Based Instance"
     ELSEIF (o.template_order_flag=5) "Future Recurring Template"
     ELSEIF (o.template_order_flag=6) "Future Recurring Instance"
     ELSEIF (o.template_order_flag=7) "Protocol"
     ENDIF
     ),3), order_list->qual[d1.seq].template_order_id = o.template_order_id,
   order_list->qual[d1.seq].billonly_indicator = oc.bill_only_ind, order_list->qual[d1.seq].
   witness_flag = os.witness_flag, order_list->qual[d1.seq].pathway_plan = p.display_description,
   order_list->qual[d1.seq].proposal_status = uar_get_code_display(op.proposal_status_cd), order_list
   ->qual[d1.seq].dcdisplay_days = cnvtstring(oc.dc_display_days), order_list->qual[d1.seq].
   default_stop_duration = oc.stop_duration,
   order_list->qual[d1.seq].stop_duration_unit_cd = oc.stop_duration_unit_cd, order_list->qual[d1.seq
   ].stop_duration_unit = uar_get_code_display(oc.stop_duration_unit_cd), order_list->qual[d1.seq].
   disable_order_comment_flag = oc.disable_order_comment_ind,
   order_list->qual[d1.seq].protocol_order_id = cnvtstring(o.protocol_order_id), order_list->qual[d1
   .seq].reftext_mask =
   IF (oc.ref_text_mask > 0
    AND oc.ref_text_mask != 16
    AND oc.ref_text_mask != 18
    AND oc.ref_text_mask != 64) "RefTextAvailable"
   ELSE "RefTextNotAvailable"
   ENDIF
   , order_list->qual[d1.seq].frequency = cnvtstring(fs.frequency_cd),
   order_list->qual[d1.seq].stop_datetime = format(od1.oe_field_dt_tm_value,"MM/DD/YYYY HH:MM;;D"),
   order_list->qual[d1.seq].stopdate_timezone = substring(21,3,datetimezoneformat(od1
     .oe_field_dt_tm_value,od1.oe_field_tz,"MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef))
  WITH time = 90
 ;end select
 EXECUTE bhs_athn_write_json_output  WITH replace("OUT_REC","ORDER_LIST"), replace("OUT_REC",
  "ORDER_LIST")
 FREE RECORD act_order_status_ls
 FREE RECORD oth_order_status_ls1
 FREE RECORD oth_order_status_ls2
 FREE RECORD order_list
END GO
