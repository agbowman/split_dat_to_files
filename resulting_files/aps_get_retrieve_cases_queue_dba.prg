CREATE PROGRAM aps_get_retrieve_cases_queue:dba
 RECORD reply(
   1 qual[*]
     2 case_query_id = f8
     2 output_dest_id = f8
     2 nbr_copies = i2
     2 report_type_flag = i2
     2 search_type_flag = i2
     2 query_start_dt_tm = dq8
     2 started_prsnl_id = f8
     2 started_prsnl_disp = vc
     2 started_prsnl_username = vc
     2 status_flag = i2
     2 result_name = vc
     2 number_results = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_disp = vc
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET result_cnt = 0
 DECLARE ap_activity_type_cd = f8 WITH public, noconstant(0.0)
 SET ap_activity_type_cd = uar_get_code_by("MEANING",106,"AP")
 IF (ap_activity_type_cd <= 0)
  SET reply->status_data.subeventstatus[1].operationname = "uar_get_code_by"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "activity_type_cd"
  GO TO exitscript
 ENDIF
 SELECT INTO "nl:"
  acq.case_query_id, p.person_id, p1.person_id,
  aqr.query_result_id, result = decode(aqr.seq,1,0)
  FROM ap_case_query acq,
   prsnl p,
   prsnl p1,
   ap_query_result aqr,
   dummyt d
  PLAN (acq
   WHERE acq.case_query_id > 0
    AND ((acq.activity_type_cd=ap_activity_type_cd) OR (acq.activity_type_cd=0)) )
   JOIN (p
   WHERE acq.started_prsnl_id=p.person_id)
   JOIN (p1
   WHERE acq.updt_id=p1.person_id)
   JOIN (d)
   JOIN (aqr
   WHERE acq.case_query_id=aqr.case_query_id)
  ORDER BY acq.case_query_id
  HEAD REPORT
   cnt = 0
  HEAD acq.case_query_id
   result_cnt = 0, cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].case_query_id = acq.case_query_id, reply->qual[cnt].output_dest_id = acq
   .output_dest_id, reply->qual[cnt].nbr_copies = acq.nbr_copies,
   reply->qual[cnt].report_type_flag = acq.report_type_flag, reply->qual[cnt].search_type_flag = acq
   .search_type_flag, reply->qual[cnt].query_start_dt_tm = acq.query_start_dt_tm,
   reply->qual[cnt].started_prsnl_id = acq.started_prsnl_id, reply->qual[cnt].started_prsnl_disp = p
   .name_full_formatted, reply->qual[cnt].started_prsnl_username = p.username,
   reply->qual[cnt].status_flag = acq.status_flag, reply->qual[cnt].result_name = acq.result_name,
   reply->qual[cnt].updt_dt_tm = acq.updt_dt_tm,
   reply->qual[cnt].updt_id = acq.updt_id, reply->qual[cnt].updt_disp = p1.name_full_formatted, reply
   ->qual[cnt].updt_cnt = acq.updt_cnt
  DETAIL
   IF (result=1)
    result_cnt = (result_cnt+ 1)
   ENDIF
  FOOT  acq.case_query_id
   reply->qual[cnt].number_results = result_cnt,
   CALL echo(reply->qual[cnt].case_query_id),
   CALL echo(reply->qual[cnt].number_results)
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nocounter, outerjoin = d
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_CASE_QUERY"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exitscript
END GO
