CREATE PROGRAM core_get_cd_value_by_set:dba
 RECORD reply(
   1 qual[*]
     2 active_dt_tm = dq8
     2 active_ind = i2
     2 active_status_prsnl_id = f8
     2 active_type_cd = f8
     2 begin_effective_dt_tm = dq8
     2 cdf_meaning = c12
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 definition = vc
     2 description = vc
     2 display = c40
     2 display_key = c40
     2 display_key_nls = vc
     2 end_effective_dt_tm = dq8
     2 inactive_dt_tm = dq8
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
 SET number_to_get = size(request->qual,5)
 SELECT INTO "nl:"
  c.display, c.definition, c.cdf_meaning,
  c.updt_cnt
  FROM code_value c,
   (dummyt d  WITH seq = value(number_to_get))
  PLAN (d)
   JOIN (c
   WHERE (((request->qual[d.seq].return_all=1)
    AND (c.code_set=request->qual[d.seq].code_set)) OR ((request->qual[d.seq].return_all=0)
    AND (c.code_set=request->qual[d.seq].code_set)
    AND c.active_ind=1
    AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))) )
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->qual,10)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].active_dt_tm = c.active_dt_tm, reply->qual[count1].active_ind = c.active_ind,
   reply->qual[count1].active_status_prsnl_id = c.active_status_prsnl_id,
   reply->qual[count1].active_type_cd = c.active_type_cd, reply->qual[count1].begin_effective_dt_tm
    = c.begin_effective_dt_tm, reply->qual[count1].cdf_meaning = c.cdf_meaning,
   reply->qual[count1].cki = c.cki, reply->qual[count1].code_set = c.code_set, reply->qual[count1].
   code_value = c.code_value,
   reply->qual[count1].collation_seq = c.collation_seq, reply->qual[count1].data_status_cd = c
   .data_status_cd, reply->qual[count1].data_status_dt_tm = c.data_status_dt_tm,
   reply->qual[count1].data_status_prsnl_id = c.data_status_prsnl_id, reply->qual[count1].definition
    = c.definition, reply->qual[count1].description = c.description,
   reply->qual[count1].display = c.display, reply->qual[count1].display_key = c.display_key, reply->
   qual[count1].display_key_nls = c.display_key_nls,
   reply->qual[count1].end_effective_dt_tm = c.end_effective_dt_tm, reply->qual[count1].
   inactive_dt_tm = c.inactive_dt_tm, reply->qual[count1].updt_cnt = c.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
