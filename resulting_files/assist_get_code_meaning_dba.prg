CREATE PROGRAM assist_get_code_meaning:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 code_set[1]
      2 code_set_num = i4
      2 qual = i4
      2 code[1]
        3 code_number = f8
        3 code_disp_key = c40
        3 code_cdf_meaning = c12
        3 description = c100
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET hassist_get_code = 0
 SET istatus = 0
 SET serrmsg = fillstring(132," ")
 SET reply->status_data.status = "F"
 SET table_name = "CODE_VALUE"
 SET tot_num = size(request->code_set,5)
 SET stat = alter(reply->code_set,tot_num)
 SET max2level = 1
 SELECT DISTINCT INTO "NL:"
  c.*
  FROM code_value c,
   (dummyt d  WITH seq = value(tot_num))
  PLAN (d)
   JOIN (c
   WHERE (c.code_set=request->code_set[d.seq].code)
    AND (c.cdf_meaning=request->code_set[d.seq].cdf_meaning))
  HEAD REPORT
   count = 0, max2level = 1
  HEAD c.code_set
   count = (count+ 1), count2 = 0
  DETAIL
   count2 = (count2+ 1)
   IF (count2 > max2level)
    max2level = count2, stat = alter(reply->code_set.code,max2level)
   ENDIF
   reply->code_set[count].code[count2].code_number = c.code_value, reply->code_set[count].code[count2
   ].code_disp_key = c.display_key, reply->code_set[count].code[count2].code_cdf_meaning = c
   .cdf_meaning,
   reply->code_set[count].code[count2].description = c.description
  FOOT  c.code_set
   reply->code_set[count].qual = count2, reply->code_set[count].code_set_num = c.code_set
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = true
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
  SET reply->status_data.subeventstatus[2].operationstatus = "S"
  CALL echo("FAILED: Table = [",0)
  CALL echo(table_name,0)
  CALL echo("]  failed to [",0)
  SET op_name = reply->status_data.subeventstatus[1].operationname
  CALL echo(op_name,0)
  CALL echo("]  ",1)
  CALL echo("        CCL error = [",0)
  CALL echo(serrmsg,0)
  CALL echo("]",1)
 ENDIF
 GO TO end_program
#end_program
END GO
