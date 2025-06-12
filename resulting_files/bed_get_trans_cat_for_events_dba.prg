CREATE PROGRAM bed_get_trans_cat_for_events:dba
 FREE SET reply
 RECORD reply(
   1 relationships[*]
     2 transfer_category_id = f8
     2 transfer_category_name = vc
     2 transfer_type_code_value = f8
     2 transfer_type_display = vc
     2 reltn_sequence = i4
     2 dcp_cf_trans_event_cd_r_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET rcnt = 0
 SELECT INTO "nl:"
  FROM dcp_cf_trans_event_cd_r d1,
   dcp_cf_trans_cat_reltn d2,
   dcp_cf_trans_cat d3,
   code_value cv
  PLAN (d1
   WHERE (d1.source_event_cd=request->source_event_code_value)
    AND (d1.target_event_cd=request->target_event_code_value)
    AND (d1.association_identifier_cd=request->assoc_ident_code_value)
    AND d1.active_ind=1)
   JOIN (d2
   WHERE d2.dcp_cf_trans_event_cd_r_id=d1.dcp_cf_trans_event_cd_r_id
    AND d2.active_ind=1)
   JOIN (d3
   WHERE d3.dcp_cf_trans_cat_id=d2.dcp_cf_trans_cat_id
    AND d3.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=d1.cf_transfer_type_cd
    AND cv.active_ind=1)
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(reply->relationships,rcnt), reply->relationships[rcnt].
   transfer_category_id = d2.dcp_cf_trans_cat_id,
   reply->relationships[rcnt].transfer_category_name = d3.cf_category_name, reply->relationships[rcnt
   ].transfer_type_code_value = d1.cf_transfer_type_cd, reply->relationships[rcnt].
   transfer_type_display = cv.display,
   reply->relationships[rcnt].reltn_sequence = d2.reltn_sequence, reply->relationships[rcnt].
   dcp_cf_trans_event_cd_r_id = d1.dcp_cf_trans_event_cd_r_id
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
