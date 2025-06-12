CREATE PROGRAM aps_get_query_result_names:dba
 RECORD reply(
   1 qual[*]
     2 result_name = vc
     2 case_query_id = f8
     2 started_prsnl_id = f8
     2 image_query_ind = i2
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
  acq.case_query_id, image_query_ind = evaluate(nullind(acqd.case_query_id),1,0,1)
  FROM ap_case_query acq,
   (dummyt d  WITH seq = 1),
   ap_case_query_details acqd
  PLAN (acq
   WHERE acq.activity_type_cd IN (0, ap_activity_type_cd)
    AND acq.result_name_key > " "
    AND  EXISTS (
   (SELECT
    aqr.case_query_id
    FROM ap_query_result aqr
    WHERE aqr.case_query_id=acq.case_query_id)))
   JOIN (d)
   JOIN (acqd
   WHERE acq.case_query_id=acqd.case_query_id
    AND acqd.param_name IN ("CASE_IMAGEANYLEVEL", "CASE_IMAGECASELEVEL", "CASE_IMAGEUSEDEFAULT",
   "CASE_IMAGETASKASSAY"))
  ORDER BY acq.case_query_id
  HEAD REPORT
   cnt = 0
  HEAD acq.case_query_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].case_query_id = acq.case_query_id, reply->qual[cnt].result_name = acq.result_name,
   reply->qual[cnt].started_prsnl_id = acq.started_prsnl_id,
   reply->qual[cnt].image_query_ind = image_query_ind
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
