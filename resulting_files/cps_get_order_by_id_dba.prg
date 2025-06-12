CREATE PROGRAM cps_get_order_by_id:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE RECORD reply
 RECORD reply(
   1 last_updt_dt_tm = dq8
   1 qual_cnt = i4
   1 qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 catalog_type_disp = c40
     2 catalog_type_mean = c40
     2 contributor_system_cd = f8
     2 order_status_cd = f8
     2 order_status_disp = c40
     2 order_status_mean = c40
     2 order_mnemonic = vc
     2 generic_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 last_action_sequence = i4
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 activity_type_mean = c40
     2 activity_subtype_cd = f8
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 last_update_provider_id = f8
     2 provider_full_name = vc
     2 template_order_id = f8
     2 template_order_flag = i2
     2 synonym_id = f8
     2 group_order_id = f8
     2 group_order_flag = i2
     2 link_order_id = f8
     2 link_order_flag = i2
     2 suspend_ind = i2
     2 order_detail_display_line = vc
     2 oe_format_id = f8
     2 iv_ind = i2
     2 constant_ind = i2
     2 prn_ind = i2
     2 order_comment_ind = i2
     2 need_rx_verify_ind = i2
     2 need_nurse_review_ind = i2
     2 need_doctor_cosign_ind = i2
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 projected_stop_dt_tm = dq8
     2 projected_stop_tz = i4
     2 suspend_effective_dt_tm = dq8
     2 suspend_effective_tz = i4
     2 resume_ind = i2
     2 resume_effective_dt_tm = dq8
     2 resume_effective_tz = i4
     2 discontinue_ind = i2
     2 discontinue_effective_dt_tm = dq8
     2 discontinue_effective_tz = i4
     2 cs_order_id = f8
     2 cs_flag = i2
     2 last_updt_cnt = i4
     2 orig_ord_as_flag = i2
     2 dept_status_cd = f8
     2 ref_text_mask = i4
     2 cki = vc
     2 synonym_cki = vc
     2 dup_checking_ind = i2
     2 incomplete_order_ind = i2
     2 last_action_type_cd = f8
     2 last_action_type_disp = c40
     2 last_action_type_mean = c12
     2 disable_order_comment_ind = i2
     2 mnemonic_type_cd = f8
     2 need_physician_validate_ind = i2
     2 med_order_type_cd = f8
     2 additive_count_for_ivpb = i4
     2 communication_type_cd = f8
     2 dispensed_by_pharmacy_ind = i2
     2 processed_by_pharmacy_ind = i2
     2 lost_dispense_record_ind = i2
     2 requisition_format_cd = f8
     2 requisition_object_name = vc
     2 organization_id = f8
     2 simplified_display_line = vc
     2 action_dt_tm = dq8
     2 action_tz = i4
     2 compound_ind = i2
   1 retail_order_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 catalog_type_disp = c40
     2 catalog_type_mean = c40
     2 contributor_system_cd = f8
     2 order_status_cd = f8
     2 order_status_disp = c40
     2 order_status_mean = c40
     2 order_mnemonic = vc
     2 generic_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 last_action_sequence = i4
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 activity_type_mean = c40
     2 activity_subtype_cd = f8
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 last_update_provider_id = f8
     2 provider_full_name = vc
     2 template_order_id = f8
     2 template_order_flag = i2
     2 synonym_id = f8
     2 group_order_id = f8
     2 group_order_flag = i2
     2 link_order_id = f8
     2 link_order_flag = i2
     2 suspend_ind = i2
     2 order_detail_display_line = vc
     2 oe_format_id = f8
     2 iv_ind = i2
     2 constant_ind = i2
     2 prn_ind = i2
     2 order_comment_ind = i2
     2 need_rx_verify_ind = i2
     2 need_nurse_review_ind = i2
     2 need_doctor_cosign_ind = i2
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 projected_stop_dt_tm = dq8
     2 projected_stop_tz = i4
     2 suspend_effective_dt_tm = dq8
     2 suspend_effective_tz = i4
     2 resume_ind = i2
     2 resume_effective_dt_tm = dq8
     2 resume_effective_tz = i4
     2 discontinue_ind = i2
     2 discontinue_effective_dt_tm = dq8
     2 discontinue_effective_tz = i4
     2 cs_order_id = f8
     2 cs_flag = i2
     2 last_updt_cnt = i4
     2 orig_ord_as_flag = i2
     2 dept_status_cd = f8
     2 ref_text_mask = i4
     2 cki = vc
     2 synonym_cki = vc
     2 dup_checking_ind = i2
     2 incomplete_order_ind = i2
     2 last_action_type_cd = f8
     2 last_action_type_disp = c40
     2 last_action_type_mean = c12
     2 disable_order_comment_ind = i2
     2 mnemonic_type_cd = f8
     2 need_physician_validate_ind = i2
     2 med_order_type_cd = f8
     2 additive_count_for_ivpb = i4
     2 communication_type_cd = f8
     2 dispensed_by_pharmacy_ind = i2
     2 processed_by_pharmacy_ind = i2
     2 lost_dispense_record_ind = i2
     2 requisition_format_cd = f8
     2 requisition_object_name = vc
     2 organization_id = f8
     2 simplified_display_line = vc
     2 action_dt_tm = dq8
     2 action_tz = i4
     2 compound_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count1 = i4 WITH public, noconstant(0)
 DECLARE dvar = i4 WITH public, noconstant(0)
 DECLARE ivpb_cd = f8 WITH public, noconstant(0.0)
 DECLARE iv_cd = f8 WITH public, noconstant(0.0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE expand_idx = i4 WITH protect, noconstant(0)
 DECLARE locate_idx = i4 WITH protect, noconstant(0)
 DECLARE order_idx = i4 WITH protect, noconstant(0)
 DECLARE ivpb_ind = i2 WITH protect, noconstant(0)
 DECLARE additive = i2 WITH protect, constant(3)
 DECLARE compound_parent = i2 WITH protect, constant(4)
 DECLARE compound_child = i2 WITH protect, constant(5)
 FREE RECORD tdate
 RECORD tdate(
   1 hupdt_dt_tm = dq8
 )
 SET tdate->hupdt_dt_tm = cnvtdatetime("01-JAN-1800 00:00")
 SET reply->status_data.status = "F"
 SET code_set = 18309
 SET cdf_meaning = "INTERMITTENT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,ivpb_cd)
 IF (ivpb_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "IV"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,iv_cd)
 IF (iv_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  o.order_id
  FROM (dummyt d1  WITH seq = value(request->qual_knt)),
   orders o,
   person p,
   order_catalog oc,
   order_catalog_synonym ocs,
   order_action oa
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (o
   WHERE (o.order_id=request->qual[d1.seq].order_id))
   JOIN (p
   WHERE p.person_id=o.last_update_provider_id)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (ocs
   WHERE ocs.synonym_id=o.synonym_id)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=o.last_action_sequence)
  HEAD REPORT
   dvar = 0, count1 = 0, stat = alterlist(reply->qual,10)
  HEAD o.order_id
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   IF (datetimediff(o.updt_dt_tm,tdate->hupdt_dt_tm) > 0)
    tdate->hupdt_dt_tm = cnvtdatetime(o.updt_dt_tm)
   ENDIF
   CALL fill_reply(dvar)
  FOOT REPORT
   reply->last_updt_dt_tm = tdate->hupdt_dt_tm, reply->qual_cnt = count1, stat = alterlist(reply->
    qual,count1)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ORDERS"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM order_ingredient oi
  WHERE expand(expand_idx,1,value(size(reply->qual,5)),oi.order_id,reply->qual[expand_idx].order_id,
   oi.action_sequence,reply->qual[expand_idx].last_action_sequence)
  ORDER BY oi.order_id
  HEAD oi.order_id
   ivpb_ind = false, order_idx = locateval(locate_idx,1,value(size(reply->qual,5)),oi.order_id,reply
    ->qual[locate_idx].order_id,
    oi.action_sequence,reply->qual[locate_idx].last_action_sequence)
   IF (order_idx > 0)
    IF ((reply->qual[order_idx].med_order_type_cd=ivpb_cd))
     ivpb_ind = true
    ENDIF
   ENDIF
  DETAIL
   IF (order_idx > 0)
    IF (ivpb_ind=true
     AND oi.ingredient_type_flag=additive)
     reply->qual[order_idx].additive_count_for_ivpb = (reply->qual[order_idx].additive_count_for_ivpb
     + 1)
    ENDIF
    IF (((oi.ingredient_type_flag=compound_parent) OR (oi.ingredient_type_flag=compound_child)) )
     reply->qual[order_idx].compound_ind = true
    ENDIF
   ENDIF
  FOOT  oi.order_id
   IF (order_idx > 0)
    IF ((reply->qual[order_idx].additive_count_for_ivpb > 1))
     reply->qual[order_idx].iv_ind = true
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 GO TO exit_script
 SUBROUTINE fill_reply(var)
   SET reply->qual[count1].order_id = o.order_id
   SET reply->qual[count1].encntr_id = o.encntr_id
   SET reply->qual[count1].catalog_cd = o.catalog_cd
   SET reply->qual[count1].catalog_type_cd = o.catalog_type_cd
   SET reply->qual[count1].order_status_cd = o.order_status_cd
   SET reply->qual[count1].order_mnemonic = o.order_mnemonic
   SET reply->qual[count1].ordered_as_mnemonic = o.ordered_as_mnemonic
   SET reply->qual[count1].hna_order_mnemonic = o.hna_order_mnemonic
   SET reply->qual[count1].last_action_sequence = o.last_action_sequence
   SET reply->qual[count1].activity_type_cd = o.activity_type_cd
   SET reply->qual[count1].orig_order_dt_tm = cnvtdatetime(o.orig_order_dt_tm)
   SET reply->qual[count1].orig_order_tz = o.orig_order_tz
   SET reply->qual[count1].order_detail_display_line = o.clinical_display_line
   SET reply->qual[count1].simplified_display_line = o.simplified_display_line
   SET reply->qual[count1].oe_format_id = o.oe_format_id
   SET reply->qual[count1].last_update_provider_id = o.last_update_provider_id
   SET reply->qual[count1].template_order_id = o.template_order_id
   SET reply->qual[count1].template_order_flag = o.template_order_flag
   SET reply->qual[count1].synonym_id = o.synonym_id
   SET reply->qual[count1].group_order_id = o.group_order_id
   SET reply->qual[count1].group_order_flag = o.group_order_flag
   SET reply->qual[count1].contributor_system_cd = o.contributor_system_cd
   SET reply->qual[count1].link_order_flag = o.link_order_flag
   SET reply->qual[count1].link_order_id = o.link_order_id
   SET reply->qual[count1].suspend_ind = o.suspend_ind
   SET reply->qual[count1].constant_ind = o.constant_ind
   SET reply->qual[count1].prn_ind = o.prn_ind
   SET reply->qual[count1].order_comment_ind = o.order_comment_ind
   SET reply->qual[count1].need_rx_verify_ind = o.need_rx_verify_ind
   SET reply->qual[count1].need_nurse_review_ind = o.need_nurse_review_ind
   SET reply->qual[count1].need_doctor_cosign_ind = o.need_doctor_cosign_ind
   SET reply->qual[count1].current_start_dt_tm = cnvtdatetime(o.current_start_dt_tm)
   SET reply->qual[count1].current_start_tz = o.current_start_tz
   SET reply->qual[count1].projected_stop_dt_tm = cnvtdatetime(o.projected_stop_dt_tm)
   SET reply->qual[count1].projected_stop_tz = o.projected_stop_tz
   SET reply->qual[count1].suspend_effective_dt_tm = cnvtdatetime(o.suspend_effective_dt_tm)
   SET reply->qual[count1].suspend_effective_tz = o.suspend_effective_tz
   SET reply->qual[count1].resume_ind = o.resume_ind
   SET reply->qual[count1].resume_effective_dt_tm = cnvtdatetime(o.resume_effective_dt_tm)
   SET reply->qual[count1].resume_effective_tz = o.resume_effective_tz
   SET reply->qual[count1].discontinue_ind = o.discontinue_ind
   SET reply->qual[count1].discontinue_effective_dt_tm = cnvtdatetime(o.discontinue_effective_dt_tm)
   SET reply->qual[count1].discontinue_effective_tz = o.discontinue_effective_tz
   SET reply->qual[count1].cs_order_id = o.cs_order_id
   SET reply->qual[count1].cs_flag = o.cs_flag
   SET reply->qual[count1].last_updt_cnt = o.updt_cnt
   SET reply->qual[count1].orig_ord_as_flag = o.orig_ord_as_flag
   SET reply->qual[count1].provider_full_name = p.name_full_formatted
   SET reply->qual[count1].dept_status_cd = o.dept_status_cd
   SET reply->qual[count1].ref_text_mask = o.ref_text_mask
   SET reply->qual[count1].incomplete_order_ind = o.incomplete_order_ind
   SET reply->qual[count1].last_action_type_cd = oa.action_type_cd
   SET reply->qual[count1].disable_order_comment_ind = oc.disable_order_comment_ind
   SET reply->qual[count1].cki = oc.cki
   SET reply->qual[count1].dup_checking_ind = oc.dup_checking_ind
   SET reply->qual[count1].mnemonic_type_cd = ocs.mnemonic_type_cd
   SET reply->qual[count1].activity_subtype_cd = ocs.activity_subtype_cd
   SET reply->qual[count1].synonym_cki = ocs.cki
   SET reply->qual[count1].need_physician_validate_ind = o.need_physician_validate_ind
   SET reply->qual[count1].med_order_type_cd = o.med_order_type_cd
   SET reply->qual[count1].communication_type_cd = oa.communication_type_cd
   IF (o.med_order_type_cd=iv_cd)
    SET reply->qual[count1].iv_ind = true
   ENDIF
   SET reply->qual[count1].requisition_format_cd = oc.requisition_format_cd
   SET reply->qual[count1].requisition_object_name = uar_get_code_meaning(oc.requisition_format_cd)
 END ;Subroutine
#exit_script
 CALL echo("***   EXIT_SCRIPT")
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "008 01/03/08 SJ9054"
END GO
