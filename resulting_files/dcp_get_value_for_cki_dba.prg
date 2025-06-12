CREATE PROGRAM dcp_get_value_for_cki:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 display = c40
     2 description = c60
     2 cdf_meaning = c12
     2 cki = vc
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET rec_cnt = size(request->qual,5)
 SET count1 = 0
 SET code_value = 0.0
 SET cdf_meaning = "DELETED"
 SET code_set = 48
 EXECUTE cpm_get_cd_for_cdf
 SET deleted = code_value
 SELECT
  IF ((request->qual[1].code_set > 0))
   PLAN (d)
    JOIN (c
    WHERE (c.code_set=request->qual[d.seq].code_set)
     AND (c.cki=request->qual[d.seq].cki)
     AND c.active_type_cd != deleted
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ELSE
   PLAN (d)
    JOIN (c
    WHERE (c.cki=request->qual[d.seq].cki)
     AND c.active_type_cd != deleted
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ENDIF
  INTO "nl:"
  c.code_value
  FROM code_value c,
   (dummyt d  WITH seq = value(rec_cnt))
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].code_value = c.code_value, reply->qual[count1].display = c.display, reply->
   qual[count1].description = c.description,
   reply->qual[count1].cdf_meaning = c.cdf_meaning, reply->qual[count1].cki = c.cki, reply->qual[
   count1].updt_cnt = c.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
