CREATE PROGRAM cva_get_dup_outbound:dba
 RECORD reply(
   1 qual[1]
     2 alias_cd = f8
     2 alias_disp = c40
     2 alias_desc = c60
     2 alias_mean = c12
     2 alias = vc
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
 SET count1 = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value_outbound c
  WHERE (c.contributor_source_cd=request->contributor_source_cd)
   AND (c.code_value=request->code_value)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1
   IF (mod(count1,10)=2)
    stat = alter(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].alias_cd = c.code_value, reply->qual[count1].alias = c.alias, reply->qual[
   count1].updt_cnt = c.updt_cnt
  WITH nocounter
 ;end select
 IF (count1 != 0)
  SET stat = alter(reply->qual,count1)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
