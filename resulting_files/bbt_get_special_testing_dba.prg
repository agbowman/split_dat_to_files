CREATE PROGRAM bbt_get_special_testing:dba
 RECORD reply(
   1 list[*]
     2 special_testing_id = f8
     2 product_id = f8
     2 special_testing_cd = f8
     2 special_testing_cd_disp = vc
     2 special_testing_mean = c12
     2 confirmed_ind = i2
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 modifiable_flag = i2
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
  s.*
  FROM special_testing s,
   (dummyt d  WITH seq = 1),
   special_testing_result st
  PLAN (s
   WHERE (s.product_id=request->product_id)
    AND s.active_ind=1)
   JOIN (d
   WHERE d.seq=1)
   JOIN (st
   WHERE st.special_testing_id=s.special_testing_id
    AND s.active_ind=1)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1, stat = alterlist(reply->list,count1), reply->list[count1].special_testing_id = s
   .special_testing_id,
   reply->list[count1].product_id = s.product_id, reply->list[count1].special_testing_cd = s
   .special_testing_cd, reply->list[count1].confirmed_ind = s.confirmed_ind,
   reply->list[count1].updt_cnt = s.updt_cnt, reply->list[count1].updt_dt_tm = s.updt_dt_tm, reply->
   list[count1].updt_id = s.updt_id,
   reply->list[count1].updt_task = s.updt_task, reply->list[count1].updt_applctx = s.updt_applctx,
   reply->list[count1].active_ind = s.active_ind,
   reply->list[count1].active_status_cd = s.active_status_cd, reply->list[count1].active_status_dt_tm
    = s.active_status_dt_tm, reply->list[count1].active_status_prsnl_id = s.active_status_prsnl_id,
   reply->list[count1].modifiable_flag = s.modifiable_flag
  WITH outerjoin = d, dontexist
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
