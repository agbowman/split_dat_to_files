CREATE PROGRAM dm_code_set_extension:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET upd_cnt_error = 0
 SET init_updt_cnt = 0
 IF ((dmrequest->field_type=1))
  SET init_field_value = "0"
  SET upd_cnt_error = 0
 ELSEIF ((dmrequest->field_type=2))
  SET init_field_value = " "
  SET upd_cnt_error = 0
 ELSE
  SET init_field_value = " "
  SET upd_cnt_error = 1
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "f"
 SELECT INTO "nl:"
  FROM code_set_extension cse
  WHERE (cse.field_name=dmrequest->field_name)
   AND (cse.code_set=dmrequest->code_set)
  WITH nocounter
 ;end select
 IF (curqual=0)
  INSERT  FROM code_set_extension cse
   SET cse.field_seq = dmrequest->field_seq, cse.field_type = dmrequest->field_type, cse.field_len =
    dmrequest->field_len,
    cse.field_prompt = dmrequest->field_prompt, cse.field_default = dmrequest->field_default, cse
    .field_help = dmrequest->field_help,
    cse.field_name = dmrequest->field_name, cse.code_set = dmrequest->code_set, cse.updt_id = reqinfo
    ->updt_id,
    cse.updt_cnt = 0, cse.updt_task = reqinfo->updt_task, cse.updt_applctx = reqinfo->updt_applctx,
    cse.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
  COMMIT
  IF (curqual=0)
   SET upd_cnt_error = 1
   GO TO exit_script
  ENDIF
  UPDATE  FROM code_value_set cvs
   SET cvs.extension_ind = 1, cvs.updt_id = reqinfo->updt_id, cvs.updt_cnt = (cvs.updt_cnt+ 1),
    cvs.updt_task = reqinfo->updt_task, cvs.updt_applctx = reqinfo->updt_applctx, cvs.updt_dt_tm =
    cnvtdatetime(curdate,curtime3)
   WHERE (cvs.code_set=dmrequest->code_set)
   WITH nocounter
  ;end update
 ENDIF
 IF (curqual=0)
  SET upd_cnt_error = 1
  GO TO exit_script
 ENDIF
 SET tempstr[14] = fillstring(130," ")
 SET tempstr[1] = "rdb insert into code_value_extension"
 SET tempstr[2] = "(code_set, code_value, field_name, field_type, field_value,"
 SET tempstr[3] = " updt_id, updt_task, updt_applctx, updt_cnt)"
 SET tempstr[4] = "(select cv1.code_set , cv1.code_value, cvs.field_name,"
 SET tempstr[5] = ' cvs.field_type, " ", 111, -1, -2, 0'
 SET tempstr[6] = " from code_value cv1,"
 SET tempstr[7] = "     code_set_extension cvs"
 SET tempstr[8] = build(" where cv1.code_set =",dmrequest->code_set)
 SET tempstr[9] = "   and cvs.code_set = cv1.code_set"
 SET tempstr[10] = ' and not exists (select "X" from code_value_extension cve'
 SET tempstr[11] = "                where cv1.code_value = cve.code_value "
 SET tempstr[12] = "                  and cve.field_name = cvs.field_name"
 SET tempstr[13] = build(" and cve.code_set =",dmrequest->code_set," ))")
 SET tempstr[14] = "go"
 SET xcnt = 0
 FOR (xcnt = 1 TO 14)
   CALL parser(tempstr[xcnt])
 ENDFOR
 COMMIT
#exit_script
 IF (upd_cnt_error=0)
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
