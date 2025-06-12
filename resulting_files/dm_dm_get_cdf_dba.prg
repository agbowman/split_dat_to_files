CREATE PROGRAM dm_dm_get_cdf:dba
 RECORD reply(
   1 qual[1]
     2 cdf_meaning = c12
     2 display = c40
     2 definition = vc
     2 updt_cnt = i4
     2 delete_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET failed = "F"
 FREE SET r1
 RECORD r1(
   1 rdate = dq8
 )
 SET r1->rdate = 0
 SELECT INTO "NL:"
  dac.schema_date
  FROM dm_adm_common_data_foundation dac
  WHERE (dac.code_set=request->code_set)
  DETAIL
   IF ((dac.schema_date > r1->rdate))
    r1->rdate = cnvtdatetime(dac.schema_date)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.display, c.definition, c.cdf_meaning,
  c.updt_cnt, c.delete_ind
  FROM dm_adm_common_data_foundation c
  WHERE (c.code_set=request->code_set)
   AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate))=0
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=2)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].display = c.display, reply->qual[count1].definition = c.definition, reply->
   qual[count1].cdf_meaning = c.cdf_meaning,
   reply->qual[count1].updt_cnt = c.updt_cnt, reply->qual[count1].delete_ind = c.delete_ind
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alter(reply->qual,count1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
