CREATE PROGRAM ce_get_cva_by_code_value:dba
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 SELECT INTO "nl:"
  FROM code_value_alias c
  WHERE c.alias=trim(request->alias)
   AND (c.code_set=request->code_set)
   AND (c.contributor_source_cd=request->contributor_source_cd)
   AND (c.code_value=request->code_value)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].code_set = c.code_set, reply->reply_list[cnt].contributor_source_cd = c
   .contributor_source_cd, reply->reply_list[cnt].alias = trim(c.alias),
   reply->reply_list[cnt].code_value = c.code_value, reply->reply_list[cnt].primary_ind = c
   .primary_ind, reply->reply_list[cnt].updt_dt_tm = c.updt_dt_tm,
   reply->reply_list[cnt].updt_id = c.updt_id, reply->reply_list[cnt].updt_task = c.updt_task, reply
   ->reply_list[cnt].updt_cnt = c.updt_cnt,
   reply->reply_list[cnt].updt_applctx = c.updt_applctx, reply->reply_list[cnt].alias_type_meaning =
   trim(c.alias_type_meaning)
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
