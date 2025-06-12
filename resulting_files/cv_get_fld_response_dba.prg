CREATE PROGRAM cv_get_fld_response:dba
 CALL echo("CV_GET_FLD_RESPONSE")
 FREE SET reply
 RECORD reply(
   1 response_rec[*]
     2 response_id = f8
     2 field_type = c1
     2 a1 = vc
     2 a2 = vc
     2 a3 = vc
     2 a4 = vc
     2 a5 = vc
     2 xref_id = f8
     2 response_internal_name = vc
     2 updt_cnt = i4
     2 nomenclature_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET updt_cnt = 0
 SET active_cd = 0
 SET xref_id = 0
 SET count = 0
 SET resp_rec_cnt = 0
 SET response_id = 0
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET arr_size = 0
 SET count_ind = 0
 SET success_ind = 0
 CALL echo(build("Today's error log date is",format(curdate,"dd-mm-yyyy hh:mm:ss.cc;;d")))
 SELECT INTO "NL:"
  FROM cv_response rep,
   (dummyt t  WITH seq = value(size(request->get_rec,5)))
  PLAN (t)
   JOIN (rep
   WHERE (rep.xref_id=request->get_rec[t.seq].xref_id))
  HEAD REPORT
   recordcount = 0, stat = 0
  DETAIL
   recordcount = (recordcount+ 1), stat = alterlist(reply->response_rec,recordcount), success_ind = 1,
   reply->response_rec[recordcount].response_id = rep.response_id, reply->response_rec[recordcount].
   field_type = rep.field_type, reply->response_rec[recordcount].a1 = rep.a1,
   reply->response_rec[recordcount].a2 = rep.a2, reply->response_rec[recordcount].a3 = rep.a3, reply
   ->response_rec[recordcount].a4 = rep.a4,
   reply->response_rec[recordcount].a5 = rep.a5, reply->response_rec[recordcount].xref_id = rep
   .xref_id, reply->response_rec[recordcount].response_internal_name = rep.response_internal_name,
   reply->response_rec[recordcount].updt_cnt = rep.updt_cnt, reply->response_rec[recordcount].
   nomenclature_id = rep.nomenclature_id
  WITH nocounter
 ;end select
 IF (success_ind=0)
  SET reply->status_data.subeventstatus[1].operationname = "GET_response_FIELD"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_get_response"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CV_GET_response"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
