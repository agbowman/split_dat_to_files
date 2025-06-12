CREATE PROGRAM cps_get_med_profile:dba
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
   1 ord_qual_knt = i4
   1 ord_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 catalog_cd = f8
     2 synonym_id = f8
     2 oe_format_id = f8
     2 cs_order_id = f8
     2 order_comment_ind = i2
     2 cs_flag = i2
     2 template_order_flag = i2
     2 template_order_id = f8
     2 ref_text_mask = i4
     2 incomplete_order_ind = i2
     2 prn_ind = i2
     2 last_upd_provider_id = f8
     2 provider_full_name = vc
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 orig_ord_as_flag = i2
     2 generic_mnemonic = vc
     2 synonym_mnemonic = vc
     2 cki = vc
     2 dup_checking_ind = i2
     2 catalog_type_cd = f8
     2 dept_status_cd = f8
     2 last_action_type_cd = f8
     2 last_action_type_disp = c40
     2 last_action_type_mean = c12
     2 order_status_cd = f8
     2 order_status_disp = c40
     2 order_status_mean = c12
     2 order_comment = vc
     2 det_qual_knt = i4
     2 det_qual[*]
       3 oe_field_value_display = vc
       3 oe_field_dt_tm_value = dq8
       3 oe_field_tz = i4
       3 oe_field_meaning_id = f8
       3 oe_field_meaning = c25
       3 oe_field_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET pharm_type_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_set = 0
 SET cur_field_id = 0.0
 SET cur_action_seq = 0
 SET temp_comment = fillstring(255," ")
 SET ord_comment_cd = 0.0
 SET ierrcode = 0
 SET cdf_meaning = "PHARMACY"
 SET code_set = 6000
 EXECUTE cpm_get_cd_for_cdf
 SET pharm_type_cd = code_value
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
 IF ((request->select_ind=1))
  SET code_set = 6004
  SET code_value = 0.0
  SET cdf_meaning = "ORDERED"
  SET ierrcode = 0
  EXECUTE cpm_get_cd_for_cdf
  SET ordered_cd = code_value
  IF (code_value < 1)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set)
     ))
   GO TO exit_script
  ENDIF
  SET code_set = 6004
  SET code_value = 0.0
  SET cdf_meaning = "INCOMPLETE"
  SET ierrcode = 0
  EXECUTE cpm_get_cd_for_cdf
  SET incomplete_cd = code_value
  IF (code_value < 1)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set)
     ))
   GO TO exit_script
  ENDIF
  SET code_set = 6004
  SET code_value = 0.0
  SET cdf_meaning = "SUSPENDED"
  SET ierrcode = 0
  EXECUTE cpm_get_cd_for_cdf
  SET suspended_cd = code_value
  IF (code_value < 1)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set)
     ))
   GO TO exit_script
  ENDIF
  SET code_set = 6004
  SET code_value = 0.0
  SET cdf_meaning = "FUTURE"
  SET ierrcode = 0
  EXECUTE cpm_get_cd_for_cdf
  SET future_cd = code_value
  IF (code_value < 1)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set)
     ))
   GO TO exit_script
  ENDIF
 ELSEIF ((request->select_ind=2))
  SET code_set = 6004
  SET code_value = 0.0
  SET cdf_meaning = "CANCELED"
  SET ierrcode = 0
  EXECUTE cpm_get_cd_for_cdf
  SET canceled_cd = code_value
  IF (code_value < 1)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set)
     ))
   GO TO exit_script
  ENDIF
  SET code_set = 6004
  SET code_value = 0.0
  SET cdf_meaning = "DISCONTINUED"
  SET ierrcode = 0
  EXECUTE cpm_get_cd_for_cdf
  SET discontinued_cd = code_value
  IF (code_value < 1)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set)
     ))
   GO TO exit_script
  ENDIF
 ENDIF
 SET ierrcode = 0
 SELECT INTO "nl:"
  o.order_id, oa.action_sequence, od.oe_field_id,
  od.action_sequence
  FROM orders o,
   person p,
   order_catalog oc,
   order_catalog_synonym ocs,
   order_action oa,
   order_detail od,
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1)
  PLAN (o
   WHERE (o.person_id=request->person_id)
    AND o.catalog_type_cd=pharm_type_cd
    AND o.order_mnemonic > " "
    AND o.active_ind > 0)
   JOIN (p
   WHERE p.person_id=o.last_update_provider_id)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (ocs
   WHERE ocs.synonym_id=o.synonym_id)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (oa
   WHERE oa.order_id=o.order_id)
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (od
   WHERE od.order_id=oa.order_id
    AND od.action_sequence=oa.action_sequence)
  ORDER BY o.order_id, od.oe_field_id, od.action_sequence DESC
  HEAD REPORT
   ord_knt = 0, stat = alterlist(reply->ord_qual,10)
  HEAD o.order_id
   ord_knt = (ord_knt+ 1)
   IF (mod(ord_knt,10)=1
    AND ord_knt != 1)
    stat = alterlist(reply->ord_qual,(ord_knt+ 9))
   ENDIF
   reply->ord_qual[ord_knt].order_id = o.order_id, reply->ord_qual[ord_knt].encntr_id = o.encntr_id,
   reply->ord_qual[ord_knt].catalog_cd = o.catalog_cd,
   reply->ord_qual[ord_knt].synonym_id = o.synonym_id, reply->ord_qual[ord_knt].oe_format_id = o
   .oe_format_id, reply->ord_qual[ord_knt].cs_order_id = o.cs_order_id,
   reply->ord_qual[ord_knt].cs_flag = o.cs_flag, reply->ord_qual[ord_knt].order_comment_ind = o
   .order_comment_ind, reply->ord_qual[ord_knt].template_order_flag = o.template_order_flag,
   reply->ord_qual[ord_knt].template_order_id = o.template_order_id, reply->ord_qual[ord_knt].
   ref_text_mask = o.ref_text_mask, reply->ord_qual[ord_knt].incomplete_order_ind = o
   .incomplete_order_ind,
   reply->ord_qual[ord_knt].prn_ind = o.prn_ind, reply->ord_qual[ord_knt].orig_ord_as_flag = o
   .orig_ord_as_flag, reply->ord_qual[ord_knt].last_upd_provider_id = o.last_update_provider_id,
   reply->ord_qual[ord_knt].provider_full_name = p.name_full_formatted, reply->ord_qual[ord_knt].
   orig_order_dt_tm = o.orig_order_dt_tm, reply->ord_qual[ord_knt].orig_order_tz = o.orig_order_tz
   IF ((reply->ord_qual[ord_knt].synonym_id > 0))
    reply->ord_qual[ord_knt].synonym_mnemonic = ocs.mnemonic
   ELSE
    reply->ord_qual[ord_knt].synonym_mnemonic = o.hna_order_mnemonic
   ENDIF
   reply->ord_qual[ord_knt].generic_mnemonic = oc.description, reply->ord_qual[ord_knt].
   dup_checking_ind = oc.dup_checking_ind, reply->ord_qual[ord_knt].cki = oc.cki,
   reply->ord_qual[ord_knt].catalog_type_cd = o.catalog_type_cd, reply->ord_qual[ord_knt].
   dept_status_cd = o.dept_status_cd, reply->ord_qual[ord_knt].order_status_cd = o.order_status_cd,
   last_action_sequence = o.last_action_sequence, det_knt = 0, stat = alterlist(reply->ord_qual[
    ord_knt].det_qual,10),
   cur_field_id = 0, cur_action_seq = 0, cmt_knt = 0
  HEAD oa.action_sequence
   IF (oa.action_sequence=last_action_sequence)
    reply->ord_qual[ord_knt].last_action_type_cd = oa.action_type_cd
   ENDIF
  DETAIL
   IF (((cur_field_id != od.oe_field_id) OR (cur_action_seq=od.action_sequence)) )
    cur_field_id = od.oe_field_id, cur_action_seq = od.action_sequence, det_knt = (det_knt+ 1)
    IF (mod(det_knt,10)=1
     AND det_knt != 1)
     stat = alterlist(reply->ord_qual[ord_knt].det_qual,(det_knt+ 9))
    ENDIF
    reply->ord_qual[ord_knt].det_qual[det_knt].oe_field_value_display = od.oe_field_display_value,
    reply->ord_qual[ord_knt].det_qual[det_knt].oe_field_dt_tm_value = od.oe_field_dt_tm_value, reply
    ->ord_qual[ord_knt].det_qual[det_knt].oe_field_tz = od.oe_field_tz,
    reply->ord_qual[ord_knt].det_qual[det_knt].oe_field_meaning_id = od.oe_field_meaning_id, reply->
    ord_qual[ord_knt].det_qual[det_knt].oe_field_meaning = od.oe_field_meaning, reply->ord_qual[
    ord_knt].det_qual[det_knt].oe_field_id = od.oe_field_id
   ENDIF
  FOOT  o.order_id
   reply->ord_qual[ord_knt].det_qual_knt = det_knt, stat = alterlist(reply->ord_qual[ord_knt].
    det_qual,det_knt)
  FOOT REPORT
   reply->ord_qual_knt = ord_knt, stat = alterlist(reply->ord_qual,ord_knt)
  WITH nocounter, outerjoin = d2, outerjoin = d3,
   memsort
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
END GO
