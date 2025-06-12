CREATE PROGRAM cps_get_inc_orders:dba
 RECORD reply(
   1 qual_knt = i4
   1 qual[*]
     2 name_full_formatted = vc
     2 order_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 order_status_cd = f8
     2 order_status_disp = c40
     2 order_status_mean = c12
     2 order_mnemonic = vc
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 activity_type_desc = c60
     2 activity_type_mean = c12
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 last_update_provider_id = f8
     2 provider_full_name = vc
     2 order_detail_display_line = vc
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 catalog_type_disp = c40
     2 catalog_type_desc = c60
     2 catalog_type_mean = c12
     2 synonym_id = f8
     2 oe_format_id = f8
     2 ref_text_mask = i4
     2 last_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET knt = 0
 SET incomplete_cd = 0.0
 SET pharmacy_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0.0
 SET code_value = 0.0
 SET order_stat_cd_set = 6004
 SET catalog_type_cd_set = 6000
 SET false = 0
 SET true = 1
 SET get_error = 3
 SET ierrcode = 0
 SET serrmsg = fillstring(132," ")
 SET failed = false
 SET table_name = fillstring(50," ")
 SET reply->status_data.status = "F"
 SET cdf_meaning = "INCOMPLETE"
 SET code_set = order_stat_cd_set
 EXECUTE cpm_get_cd_for_cdf
 SET incomplete_cd = code_value
 IF (code_value < 1)
  SET failed = get_error
  SET table_name = "code_value"
  SET ierrcode = error(serrmsg,0)
  GO TO exit_script
 ENDIF
 SET code_value = 0.0
 SET cdf_meaning = "PHARMACY"
 SET code_set = catalog_type_cd_set
 EXECUTE cpm_get_cd_for_cdf
 SET pharmacy_cd = code_value
 IF (code_value < 1)
  SET failed = get_error
  SET table_name = "code_value"
  SET ierrcode = error(serrmsg,0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  o.order_id
  FROM orders o,
   person p
  PLAN (o
   WHERE (o.last_update_provider_id=request->phys_id)
    AND o.order_status_cd=incomplete_cd
    AND o.order_mnemonic != " "
    AND ((o.catalog_type_cd=pharmacy_cd
    AND o.template_order_flag IN (0, 1, 5)) OR (o.catalog_type_cd != pharmacy_cd))
    AND o.active_ind=1)
   JOIN (p
   WHERE o.person_id=p.person_id)
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->qual,(knt+ 9))
   ENDIF
   reply->qual[knt].name_full_formatted = p.name_full_formatted, reply->qual[knt].order_id = o
   .order_id, reply->qual[knt].person_id = o.person_id,
   reply->qual[knt].encntr_id = o.encntr_id, reply->qual[knt].order_status_cd = o.order_status_cd,
   reply->qual[knt].order_mnemonic = o.order_mnemonic,
   reply->qual[knt].activity_type_cd = o.activity_type_cd, reply->qual[knt].orig_order_dt_tm =
   cnvtdatetime(o.orig_order_dt_tm), reply->qual[knt].orig_order_tz = o.orig_order_tz,
   reply->qual[knt].last_update_provider_id = o.last_update_provider_id, reply->qual[knt].
   order_detail_display_line = o.order_detail_display_line, reply->qual[knt].catalog_cd = o
   .catalog_cd,
   reply->qual[knt].catalog_type_cd = o.catalog_type_cd, reply->qual[knt].synonym_id = o.synonym_id,
   reply->qual[knt].oe_format_id = o.oe_format_id,
   reply->qual[knt].ref_text_mask = o.ref_text_mask, reply->qual[knt].last_updt_cnt = o.updt_cnt
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET reply->status_data.status = "Z"
  SET ierrcode = error(serrmsg,0)
  IF (ierrcode > 0)
   SET failed = get_error
   SET table_name = "orders"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
 ELSE
  CASE (failed)
   OF get_error:
    SET reply->status_data.subeventstatus[1].operationname = "GET"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "table"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  IF (ierrcode > 0)
   SET stat = alterlist(reply->status_data.subeventstatus,2)
   SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
 ENDIF
#end_program
 SET script_version = "003 10/24/01 RN4254"
END GO
