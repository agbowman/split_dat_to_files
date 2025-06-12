CREATE PROGRAM bbt_get_bbt_activity_cd:dba
 RECORD reply(
   1 bbt_trans_event_cd = f8
   1 bbt_act_type_cd = f8
   1 bbt_act_type_disp = vc
   1 bbt_act_type_mean = vc
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
 SET failed = "F"
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_set = 0
 SET bbt_trans_cd = 38883.0
 SET code_cnt = 1
 SET code_set = 73
 SET cdf_meaning = "BBT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,bbt_trans_cd)
 SELECT INTO "nl:"
  c.event_cd
  FROM code_value_event_r c
  PLAN (c
   WHERE c.parent_cd=bbt_trans_cd)
  DETAIL
   reply->bbt_trans_event_cd = c.event_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET code_set = 106
 SET cdf_meaning = "BB"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,code_value)
 SET reply->bbt_act_type_cd = code_value
END GO
