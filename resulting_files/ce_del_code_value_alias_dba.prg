CREATE PROGRAM ce_del_code_value_alias:dba
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 DELETE  FROM code_value_alias cva
  WHERE (cva.code_value=request->code_value)
  WITH counter
 ;end delete
 SET error_code = error(error_msg,0)
 SET reply->num_deleted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
