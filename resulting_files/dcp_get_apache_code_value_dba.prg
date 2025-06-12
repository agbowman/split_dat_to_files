CREATE PROGRAM dcp_get_apache_code_value:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 display = c40
     2 description = c60
     2 definition = vc
     2 cdf_meaning = c12
     2 collation_seq = i4
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
 SET count1 = 0
 SET code_value = 0.0
 SET cdf_meaning = "DELETED"
 SET code_set = 48
 EXECUTE cpm_get_cd_for_cdf
 SET deleted = code_value
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE (c.code_set=request->code_set)
   AND c.active_type_cd != deleted
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ORDER BY c.collation_seq
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].code_value = c.code_value, reply->qual[count1].display = c.display, reply->
   qual[count1].description = c.description,
   reply->qual[count1].definition = c.definition, reply->qual[count1].cdf_meaning = c.cdf_meaning,
   reply->qual[count1].collation_seq = c.collation_seq,
   reply->qual[count1].updt_cnt = c.updt_cnt
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
