CREATE PROGRAM bbt_get_valid_app_states:dba
 RECORD reply(
   1 qual[2]
     2 state_cd = f8
     2 state_disp = c40
     2 state_desc = vc
     2 state_mean = c12
     2 active_ind = i2
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
  v.state_cd
  FROM valid_state v
  WHERE (v.process_cd=request->process_cd)
   AND (v.category_cd=request->category_cd)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,2)=1
    AND count1 != 1)
    stat = alter(reply->qual,(count1+ 1))
   ENDIF
   reply->qual[count1].state_cd = v.state_cd, reply->qual[count1].updt_cnt = v.updt_cnt, reply->qual[
   count1].active_ind = v.active_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET stat = alter(reply->qual,0)
 ELSE
  SET stat = alter(reply->qual,count1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
