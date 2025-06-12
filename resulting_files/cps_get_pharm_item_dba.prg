CREATE PROGRAM cps_get_pharm_item:dba
 FREE SET reply
 RECORD reply(
   1 synonym_count = i4
   1 synonym[*]
     2 alt_sel_category_id = f8
     2 synonym_id = f8
     2 sequence = i4
     2 order_sentence_id = f8
     2 order_sentence_disp = vc
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 oe_format_id = f8
     2 activity_type_cd = f8
     2 activity_subtype_cd = f8
     2 mnemonic = vc
     2 generic_mnemonic = vc
     2 mnemonic_key_cap = vc
     2 ref_text_mask = i4
     2 prep_info_flag = i2
     2 orderable_type_flag = i2
     2 dup_checking_ind = i2
     2 cki = vc
     2 synonym_cki = vc
     2 orderable_type_flag = i2
     2 virtual_view = vc
     2 health_plan_view = vc
     2 comment_template_flag = i2
     2 disable_order_comment_ind = i2
     2 mnemonic_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 SET virtual_ind = 0
 IF ((request->virtual_offset > 0)
  AND (request->virtual_offset < 101))
  SET virtual_ind = 1
 ENDIF
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0
 SET primary_cd = 0.0
 SET cdf_meaning = "PRIMARY"
 SET code_set = 6011
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET primary_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to find cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT
  IF (virtual_ind=1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (al
    WHERE (al.alt_sel_category_id=request->cat_list[d.seq].alt_sel_cat_id)
     AND al.synonym_id > 0
     AND al.list_type=2)
    JOIN (os
    WHERE al.synonym_id=os.synonym_id
     AND os.active_ind=1
     AND os.mnemonic_type_cd=primary_cd
     AND substring(request->virtual_offset,1,os.virtual_view)="1")
    JOIN (oc
    WHERE os.catalog_cd=oc.catalog_cd)
  ELSE
   PLAN (d
    WHERE d.seq > 0)
    JOIN (al
    WHERE (al.alt_sel_category_id=request->cat_list[d.seq].alt_sel_cat_id)
     AND al.synonym_id > 0
     AND al.list_type=2)
    JOIN (os
    WHERE al.synonym_id=os.synonym_id
     AND os.active_ind=1
     AND os.mnemonic_type_cd=primary_cd)
    JOIN (oc
    WHERE os.catalog_cd=oc.catalog_cd)
  ENDIF
  INTO "nl:"
  FROM (dummyt d  WITH seq = value(request->cat_list_qual)),
   alt_sel_list al,
   order_catalog_synonym os,
   order_catalog oc
  ORDER BY al.alt_sel_category_id, al.sequence, os.mnemonic_key_cap
  HEAD REPORT
   knt = 0, stat = alterlist(reply->synonym,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->synonym,(knt+ 9))
   ENDIF
   reply->synonym[knt].alt_sel_category_id = al.alt_sel_category_id, reply->synonym[knt].synonym_id
    = os.synonym_id, reply->synonym[knt].sequence = al.sequence,
   reply->synonym[knt].order_sentence_id = os.order_sentence_id, reply->synonym[knt].catalog_cd = os
   .catalog_cd, reply->synonym[knt].catalog_type_cd = os.catalog_type_cd,
   reply->synonym[knt].oe_format_id = os.oe_format_id, reply->synonym[knt].activity_type_cd = os
   .activity_type_cd, reply->synonym[knt].activity_subtype_cd = os.activity_subtype_cd,
   reply->synonym[knt].mnemonic = os.mnemonic, reply->synonym[knt].generic_mnemonic = oc.description,
   reply->synonym[knt].mnemonic_key_cap = os.mnemonic_key_cap,
   reply->synonym[knt].ref_text_mask = os.ref_text_mask, reply->synonym[knt].prep_info_flag = oc
   .prep_info_flag, reply->synonym[knt].orderable_type_flag = oc.orderable_type_flag,
   reply->synonym[knt].dup_checking_ind = oc.dup_checking_ind, reply->synonym[knt].cki = oc.cki,
   reply->synonym[knt].synonym_cki = os.cki,
   reply->synonym[knt].orderable_type_flag = os.orderable_type_flag, reply->synonym[knt].virtual_view
    = os.virtual_view, reply->synonym[knt].health_plan_view = os.health_plan_view,
   reply->synonym[knt].comment_template_flag = oc.comment_template_flag, reply->synonym[knt].
   disable_order_comment_ind = oc.disable_order_comment_ind, reply->synonym[knt].mnemonic_type_cd =
   os.mnemonic_type_cd
  FOOT REPORT
   reply->synonym_count = knt, stat = alterlist(reply->synonym,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ALT_SEL_LIST"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GEN_SEQ_NBR"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
  ELSEIF (failed=lock_error)
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "007 10/04/01 SF3151"
END GO
