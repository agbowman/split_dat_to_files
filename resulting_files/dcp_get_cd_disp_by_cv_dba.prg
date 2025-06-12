CREATE PROGRAM dcp_get_cd_disp_by_cv:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 code_set = i4
     2 display = c40
     2 display_key = c40
     2 description = vc
     2 definition = vc
     2 cdf_meaning = c12
     2 active_ind = i2
     2 updt_cnt = i4
     2 collation_seq = i4
     2 active_dt_tm = dq8
     2 inactive_dt_tm = dq8
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 data_status_cd = f8
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
  cv.updt_cnt
  FROM code_value cv
  WHERE (cv.code_value=request->code_value)
   AND cv.active_ind=1
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->qual,5)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,5)=1
    AND count1 != 1)
    stat = alterlist(reply->qual,(count1+ 4))
   ENDIF
   reply->qual[count1].code_value = cv.code_value, reply->qual[count1].code_set = cv.code_set, reply
   ->qual[count1].display = cv.display,
   reply->qual[count1].display_key = cv.display_key, reply->qual[count1].description = cv.description,
   reply->qual[count1].cdf_meaning = cv.cdf_meaning,
   reply->qual[count1].definition = cv.definition, reply->qual[count1].active_ind = cv.active_ind,
   reply->qual[count1].updt_cnt = cv.updt_cnt,
   reply->qual[count1].collation_seq = cv.collation_seq, reply->qual[count1].active_dt_tm = cv
   .active_dt_tm, reply->qual[count1].inactive_dt_tm = cv.inactive_dt_tm,
   reply->qual[count1].begin_effective_dt_tm = cv.begin_effective_dt_tm, reply->qual[count1].
   end_effective_dt_tm = cv.end_effective_dt_tm, reply->qual[count1].data_status_cd = cv
   .data_status_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count1)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
