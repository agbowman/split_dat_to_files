CREATE PROGRAM aps_chk_dup_result_name:dba
 RECORD reply(
   1 duplicate_ind = i2
   1 query_prsnl_username = c50
   1 query_status = i2
   1 case_query_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->duplicate_ind = 0
 DECLARE ap_activity_type_cd = f8 WITH public, noconstant(0.0)
 SET ap_activity_type_cd = uar_get_code_by("MEANING",106,"AP")
 IF (ap_activity_type_cd <= 0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  acq.case_query_id, acq.started_prsnl_id
  FROM ap_case_query acq,
   prsnl p
  PLAN (acq
   WHERE acq.result_name_key=cnvtupper(request->result_name)
    AND ((acq.activity_type_cd=ap_activity_type_cd) OR (acq.activity_type_cd=0)) )
   JOIN (p
   WHERE acq.started_prsnl_id=p.person_id)
  DETAIL
   reply->query_prsnl_username = p.username, reply->duplicate_ind = 1, reply->query_status = acq
   .status_flag,
   reply->case_query_id = acq.case_query_id
 ;end select
 SET reply->status_data.status = "S"
#exit_script
END GO
