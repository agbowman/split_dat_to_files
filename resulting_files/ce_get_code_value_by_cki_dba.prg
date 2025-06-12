CREATE PROGRAM ce_get_code_value_by_cki:dba
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki=trim(request->cki)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].code_value = cv.code_value, reply->reply_list[cnt].code_set = cv.code_set,
   reply->reply_list[cnt].cdf_meaning = trim(cv.cdf_meaning),
   reply->reply_list[cnt].display = trim(cv.display), reply->reply_list[cnt].display_key = trim(cv
    .display_key), reply->reply_list[cnt].description = trim(cv.description),
   reply->reply_list[cnt].definition = trim(cv.definition), reply->reply_list[cnt].collation_seq = cv
   .collation_seq, reply->reply_list[cnt].active_type_cd = cv.active_type_cd,
   reply->reply_list[cnt].active_ind = cv.active_ind, reply->reply_list[cnt].active_dt_tm = cv
   .active_dt_tm, reply->reply_list[cnt].inactive_dt_tm = cv.inactive_dt_tm,
   reply->reply_list[cnt].updt_dt_tm = cv.updt_dt_tm, reply->reply_list[cnt].updt_id = cv.updt_id,
   reply->reply_list[cnt].updt_cnt = cv.updt_cnt,
   reply->reply_list[cnt].updt_task = cv.updt_task, reply->reply_list[cnt].updt_applctx = cv
   .updt_applctx, reply->reply_list[cnt].begin_effective_dt_tm = cv.begin_effective_dt_tm,
   reply->reply_list[cnt].end_effective_dt_tm = cv.end_effective_dt_tm, reply->reply_list[cnt].
   data_status_cd = cv.data_status_cd, reply->reply_list[cnt].data_status_dt_tm = cv
   .data_status_dt_tm,
   reply->reply_list[cnt].data_status_prsnl_id = cv.data_status_prsnl_id, reply->reply_list[cnt].
   active_status_prsnl_id = cv.active_status_prsnl_id, reply->reply_list[cnt].cki = trim(cv.cki),
   reply->reply_list[cnt].display_key_nls = trim(cv.display_key_nls)
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
