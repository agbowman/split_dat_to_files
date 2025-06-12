CREATE PROGRAM cs_get_code_value_alias:dba
 RECORD reply(
   1 qual[1]
     2 contributor_source_cd = f8
     2 contributor_disp = c40
     2 alias_type_meaning = c12
     2 alias = vc
     2 code_value_cd = f8
     2 code_value_disp = c40
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  c.code_set
  FROM code_value_alias c
  WHERE (c.code_set=request->code_set)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=2)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].contributor_source_cd = c.contributor_source_cd, reply->qual[count1].
   alias_type_meaning = c.alias_type_meaning, reply->qual[count1].alias = c.alias,
   reply->qual[count1].code_value_cd = c.code_value, reply->qual[count1].updt_cnt = c.updt_cnt
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alter(reply->qual,count1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
