CREATE PROGRAM cpmdecoder_get_cs_val:dba
 RECORD reply(
   1 cd_val_cnt = i4
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
  cnt = count(code_value)
  FROM code_value
  DETAIL
   reply->cd_val_cnt = cnt
  WITH nocounter
 ;end select
END GO
