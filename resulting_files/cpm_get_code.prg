CREATE PROGRAM cpm_get_code
 RECORD reply(
   1 cdf_meaning = c12
   1 display = c40
   1 display_key = c40
   1 description = c60
   1 definition = c100
   1 collation_seq = i4
   1 status_cd = f8
   1 active_ind = i2
   1 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  c.*
  FROM code_value c
  WHERE (c.code_set=request->code_set)
   AND (c.code_value=request->code_value)
  DETAIL
   reply->display = c.display, reply->display_key = c.display_key, reply->description = c.description,
   reply->definition = c.definition, reply->cdf_meaning = c.cdf_meaning, reply->collation_seq = c
   .collation_seq,
   reply->status_cd = c.status_cd, reply->active_ind = c.active_ind, reply->updt_cnt = c.updt_cnt
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
