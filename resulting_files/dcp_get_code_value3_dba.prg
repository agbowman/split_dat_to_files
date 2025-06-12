CREATE PROGRAM dcp_get_code_value3:dba
 RECORD reply(
   1 qual[5]
     2 code_set = i4
     2 code_value = f8
     2 display = c40
     2 display_key = c40
     2 description = vc
     2 definition = vc
     2 cdf_meaning = c12
     2 active_ind = i2
     2 updt_cnt = i4
     2 collation_seq = i4
   1 qual_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET nbr_req = cnvtint(size(request->code_value,5))
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  cer.updt_cnt
  FROM (dummyt d1  WITH seq = value(nbr_req)),
   code_value cer
  PLAN (d1)
   JOIN (cer
   WHERE (cer.code_set=request->code_value[d1.seq].code_set)
    AND cer.active_ind=1)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alter(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].code_set = cer.code_set, reply->qual[count1].code_value = cer.code_value,
   reply->qual[count1].display = cer.display,
   reply->qual[count1].display_key = cer.display_key, reply->qual[count1].description = cer
   .description, reply->qual[count1].cdf_meaning = cer.cdf_meaning,
   reply->qual[count1].definition = cer.definition, reply->qual[count1].active_ind = cer.active_ind,
   reply->qual[count1].updt_cnt = cer.updt_cnt,
   reply->qual[count1].collation_seq = cer.collation_seq
  WITH nocounter
 ;end select
 SET stat = alter(reply->qual,count1)
 SET reply->qual_cnt = count1
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
