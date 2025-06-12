CREATE PROGRAM ctx_get_querycount:dba
 SET count1 = 0
 SELECT INTO "nl:"
  a.app_ctx_id
  FROM application_context a
  WHERE a.start_dt_tm >= cnvtdatetime(request->start_dt_tm)
   AND  $1
   AND  $2
   AND  $3
   AND  $4
   AND  $5
  DETAIL
   count1 += 1
  WITH nocounter
 ;end select
 SET reply->querycount = count1
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSEIF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
