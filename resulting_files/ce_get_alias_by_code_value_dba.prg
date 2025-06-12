CREATE PROGRAM ce_get_alias_by_code_value:dba
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 SELECT INTO "nl:"
  FROM code_value_alias cva
  WHERE (cva.code_value=request->code_value)
   AND (cva.contributor_source_cd=request->contributor_source_cd)
   AND ((cva.alias_type_meaning = null) OR (cva.alias_type_meaning=" "))
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].alias = cva.alias
  WITH nocounter, maxqual(cva,1)
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
