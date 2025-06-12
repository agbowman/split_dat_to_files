CREATE PROGRAM cps_get_orders:dba
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
     2 last_action_sequence = i4
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 activity_type_mean = c40
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 last_update_provider_id = f8
     2 provider_full_name = vc
     2 template_order_id = f8
     2 template_order_flag = i2
     2 synonym_id = f8
     2 generic_mnemonic = vc
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
     2 dup_checking_ind = i2
     2 incomplete_order_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET resume_list
 RECORD resume_list(
   1 qual[1]
     2 order_id = f8
 )
 FREE SET disc_list
 RECORD disc_list(
   1 qual[1]
     2 order_id = f8
 )
 SET count1 = 0
 SET count2 = 0
 SET count3 = 0
 SET disc_count = 0
 SET failed = false
 SET reply->status_data.status = "F"
 SET susp_cd = 0.0
 SET disc_cd = 0.0
 SET status_cd = 0.0
 SET incomplete_cd = 0.0
 SET inprocess_cd = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 6004
 SET code_value = 0.0
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET status_cd = code_value
 IF (code_value < 1)
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
 SET code_value = 0.0
 SET cdf_meaning = "DISCONTINUED"
 EXECUTE cpm_get_cd_for_cdf
 SET disc_cd = code_value
 IF (code_value < 1)
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
 SET code_value = 0.0
 SET cdf_meaning = "SUSPENDED"
 EXECUTE cpm_get_cd_for_cdf
 SET susp_cd = code_value
 IF (code_value < 1)
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
 SET code_value = 0.0
 SET cdf_meaning = "INCOMPLETE"
 EXECUTE cpm_get_cd_for_cdf
 SET incomplete_cd = code_value
 IF (code_value < 1)
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
 SET code_value = 0.0
 SET cdf_meaning = "INPROCESS"
 EXECUTE cpm_get_cd_for_cdf
 SET inprocess_cd = code_value
 IF (code_value < 1)
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
 SET code_value = 0.0
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET catalog_type_cd = code_value
 IF (code_value < 1)
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
 IF ((request->updt_dt_tm=null))
  SET request->updt_dt_tm = cnvtdatetime("01-jan-1800 00:00:01")
  SET tupdt_dt_tm = cnvtdatetime(request->updt_dt_tm)
 ELSEIF ((request->updt_dt_tm > 0))
  SET tupdt_dt_tm = cnvtdatetime(request->updt_dt_tm)
 ELSE
  SET tupdt_dt_tm = cnvtdatetime("01-jan-1800 00:00:01")
 ENDIF
 SET ierrcode = 0
 SELECT
  IF ((request->all_cat_ind=5))
   PLAN (o
    WHERE (o.person_id=request->person_id)
     AND (o.encntr_id=request->encntr_id)
     AND ((o.catalog_type_cd+ 0) != catalog_type_cd)
     AND ((o.active_ind+ 0)=1))
    JOIN (p
    WHERE p.person_id=o.last_update_provider_id)
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
    JOIN (ocs
    WHERE ocs.synonym_id=o.synonym_id)
   WITH nocounter
  ELSEIF ((request->all_cat_ind=2)
   AND (request->encntr_id > 0))
   PLAN (o
    WHERE (o.person_id=request->person_id)
     AND o.encntr_id IN (request->encntr_id, 0, null)
     AND o.active_ind=1
     AND o.updt_dt_tm >= cnvtdatetime(request->updt_dt_tm))
    JOIN (p
    WHERE p.person_id=o.last_update_provider_id)
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
    JOIN (ocs
    WHERE ocs.synonym_id=o.synonym_id)
   WITH nocounter, orahint("index(o XIE3ORDERS)")
  ELSEIF ((request->all_cat_ind=1)
   AND (request->encntr_id > 0))
   PLAN (o
    WHERE (o.person_id=request->person_id)
     AND o.encntr_id IN (request->encntr_id, 0, null)
     AND o.catalog_type_cd != catalog_type_cd
     AND o.active_ind=1
     AND o.updt_dt_tm >= cnvtdatetime(request->updt_dt_tm))
    JOIN (p
    WHERE p.person_id=o.last_update_provider_id)
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
    JOIN (ocs
    WHERE ocs.synonym_id=o.synonym_id)
   WITH nocounter
  ELSEIF ((request->encntr_id > 0))
   PLAN (o
    WHERE (o.person_id=request->person_id)
     AND o.catalog_type_cd=catalog_type_cd
     AND o.encntr_id IN (request->encntr_id, 0, null)
     AND o.active_ind=1
     AND o.updt_dt_tm >= cnvtdatetime(request->updt_dt_tm))
    JOIN (p
    WHERE p.person_id=o.last_update_provider_id)
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
    JOIN (ocs
    WHERE ocs.synonym_id=o.synonym_id)
   ORDER BY cnvtdatetime(o.orig_order_dt_tm) DESC
   WITH nocounter
  ELSEIF ((request->all_cat_ind=2))
   PLAN (o
    WHERE (request->person_id=o.person_id)
     AND o.active_ind=1
     AND o.updt_dt_tm >= cnvtdatetime(request->updt_dt_tm))
    JOIN (p
    WHERE p.person_id=o.last_update_provider_id)
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
    JOIN (ocs
    WHERE ocs.synonym_id=o.synonym_id)
   WITH nocounter
  ELSEIF ((request->all_cat_ind=1))
   PLAN (o
    WHERE (request->person_id=o.person_id)
     AND o.catalog_type_cd != catalog_type_cd
     AND o.active_ind=1
     AND o.updt_dt_tm >= cnvtdatetime(request->updt_dt_tm))
    JOIN (p
    WHERE p.person_id=o.last_update_provider_id)
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
    JOIN (ocs
    WHERE ocs.synonym_id=o.synonym_id)
   WITH nocounter
  ELSE
   PLAN (o
    WHERE (request->person_id=o.person_id)
     AND o.catalog_type_cd=catalog_type_cd
     AND o.active_ind=1
     AND o.updt_dt_tm >= cnvtdatetime(request->updt_dt_tm))
    JOIN (p
    WHERE p.person_id=o.last_update_provider_id)
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
    JOIN (ocs
    WHERE ocs.synonym_id=o.synonym_id)
   ORDER BY cnvtdatetime(o.orig_order_dt_tm) DESC
   WITH nocounter
  ENDIF
  INTO "nl:"
  o.order_id, o.order_status_cd, o.orig_order_dt_tm
  FROM orders o,
   person p,
   order_catalog oc,
   order_catalog_synonym ocs
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   IF (datetimediff(o.updt_dt_tm,tupdt_dt_tm) > 0)
    tupdt_dt_tm = cnvtdatetime(o.updt_dt_tm)
   ENDIF
   reply->qual[count1].order_id = o.order_id, reply->qual[count1].encntr_id = o.encntr_id, reply->
   qual[count1].catalog_cd = o.catalog_cd,
   reply->qual[count1].catalog_type_cd = o.catalog_type_cd, reply->qual[count1].order_status_cd = o
   .order_status_cd
   IF (o.synonym_id > 0)
    reply->qual[count1].order_mnemonic = ocs.mnemonic
   ELSE
    reply->qual[count1].order_mnemonic = o.hna_order_mnemonic
   ENDIF
   reply->qual[count1].last_action_sequence = o.last_action_sequence, reply->qual[count1].
   activity_type_cd = o.activity_type_cd, reply->qual[count1].orig_order_dt_tm = cnvtdatetime(o
    .orig_order_dt_tm),
   reply->qual[count1].orig_order_tz = o.orig_order_tz, reply->qual[count1].order_detail_display_line
    = o.clinical_display_line, reply->qual[count1].oe_format_id = o.oe_format_id,
   reply->qual[count1].last_update_provider_id = o.last_update_provider_id, reply->qual[count1].
   template_order_id = o.template_order_id, reply->qual[count1].template_order_flag = o
   .template_order_flag,
   reply->qual[count1].synonym_id = o.synonym_id, reply->qual[count1].group_order_id = o
   .group_order_id, reply->qual[count1].group_order_flag = o.group_order_flag,
   reply->qual[count1].contributor_system_cd = o.contributor_system_cd, reply->qual[count1].
   link_order_flag = o.link_order_flag, reply->qual[count1].link_order_id = o.link_order_id,
   reply->qual[count1].suspend_ind = o.suspend_ind, reply->qual[count1].iv_ind = o.iv_ind, reply->
   qual[count1].constant_ind = o.constant_ind,
   reply->qual[count1].prn_ind = o.prn_ind, reply->qual[count1].order_comment_ind = o
   .order_comment_ind, reply->qual[count1].need_rx_verify_ind = o.need_rx_verify_ind,
   reply->qual[count1].need_nurse_review_ind = o.need_nurse_review_ind, reply->qual[count1].
   need_doctor_cosign_ind = o.need_doctor_cosign_ind, reply->qual[count1].current_start_dt_tm =
   cnvtdatetime(o.current_start_dt_tm),
   reply->qual[count1].current_start_tz = o.current_start_tz, reply->qual[count1].
   projected_stop_dt_tm = cnvtdatetime(o.projected_stop_dt_tm), reply->qual[count1].projected_stop_tz
    = o.projected_stop_tz,
   reply->qual[count1].suspend_effective_dt_tm = cnvtdatetime(o.suspend_effective_dt_tm), reply->
   qual[count1].suspend_effective_tz = o.suspend_effective_tz, reply->qual[count1].resume_ind = o
   .resume_ind,
   reply->qual[count1].resume_effective_dt_tm = cnvtdatetime(o.resume_effective_dt_tm), reply->qual[
   count1].resume_effective_tz = o.resume_effective_tz, reply->qual[count1].discontinue_ind = o
   .discontinue_ind,
   reply->qual[count1].discontinue_effective_dt_tm = cnvtdatetime(o.discontinue_effective_dt_tm),
   reply->qual[count1].discontinue_effective_tz = o.discontinue_effective_tz, reply->qual[count1].
   cs_order_id = o.cs_order_id,
   reply->qual[count1].cs_flag = o.cs_flag, reply->qual[count1].last_updt_cnt = o.updt_cnt, reply->
   qual[count1].orig_ord_as_flag = o.orig_ord_as_flag,
   reply->qual[count1].generic_mnemonic = oc.description, reply->qual[count1].provider_full_name = p
   .name_full_formatted, reply->qual[count1].dept_status_cd = o.dept_status_cd,
   reply->qual[count1].ref_text_mask = o.ref_text_mask, reply->qual[count1].cki = oc.cki, reply->
   qual[count1].dup_checking_ind = oc.dup_checking_ind,
   reply->qual[count1].incomplete_order_ind = o.incomplete_order_ind
   IF ((((status_cd=reply->qual[count1].order_status_cd)) OR ((inprocess_cd=reply->qual[count1].
   order_status_cd))) )
    IF ((reply->qual[count1].discontinue_ind <= 0))
     count1 = (count1+ 0)
    ELSEIF ((cnvtdatetime(curdate,curtime3) >= reply->qual[count1].discontinue_effective_dt_tm))
     count3 = (count3+ 1), reply->qual[count1].order_status_cd = disc_cd, disc_count = 1
    ENDIF
    IF (disc_count=0)
     IF ((reply->qual[count1].suspend_ind=1))
      IF ((cnvtdatetime(curdate,curtime3) >= reply->qual[count1].suspend_effective_dt_tm))
       IF ((reply->qual[count1].resume_ind=1))
        IF ((cnvtdatetime(curdate,curtime3) >= reply->qual[count1].resume_effective_dt_tm))
         reply->qual[count1].suspend_ind = 0, reply->qual[count1].suspend_effective_dt_tm = null,
         reply->qual[count1].resume_ind = 0,
         reply->qual[count1].resume_effective_dt_tm = null, count2 = (count2+ 1)
        ELSE
         reply->qual[count1].order_status_cd = susp_cd
        ENDIF
       ELSE
        reply->qual[count1].order_status_cd = susp_cd
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   reply->last_updt_dt_tm = cnvtdatetime(tupdt_dt_tm), reply->qual_cnt = count1, stat = alterlist(
    reply->qual,count1),
   disc_cnt = 0
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ORDERS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ELSE
  IF (curqual < 1)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#exit_script
 SET script_version = "023 04/29/03 SF3151"
END GO
