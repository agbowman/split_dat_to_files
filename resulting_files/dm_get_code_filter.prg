CREATE PROGRAM dm_get_code_filter
 RECORD reply(
   1 qual_cnt = i2
   1 qual[*]
     2 code_set = i4
     2 code_cnt = i2
     2 code[*]
       3 code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cnt = 0
 SET d_cnt = 0
 SELECT INTO "nl:"
  FROM code_domain_filter_display cd,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  PLAN (d)
   JOIN (cd
   WHERE (cd.code_set=request->qual[d.seq].code_set))
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->qual,10)
  HEAD cd.code_set
   d_cnt = 0, cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 10))
   ENDIF
   reply->qual[cnt].code_set = cd.code_set
  DETAIL
   d_cnt = (d_cnt+ 1)
   IF (mod(d_cnt,10)=1)
    stat = alterlist(reply->qual[cnt].code,(d_cnt+ 10))
   ENDIF
   reply->qual[cnt].code[d_cnt].code_value = cd.code_value,
   CALL echo(build("cv  : ",reply->qual[cnt].code[d_cnt].code_value))
  FOOT  cd.code_set
   reply->qual[cnt].code_cnt = d_cnt, stat = alterlist(reply->qual[cnt].code,d_cnt)
  FOOT REPORT
   reply->qual_cnt = cnt, stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->qual_cnt = 0
  SET reply->status_data.status = "Z"
 ELSEIF (curqual < 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "code_domain_filter_display"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
