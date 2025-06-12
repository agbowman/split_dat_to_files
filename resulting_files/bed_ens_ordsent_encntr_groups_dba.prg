CREATE PROGRAM bed_ens_ordsent_encntr_groups:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET gcnt = 0
 SET tcnt = 0
 SET gcnt = size(request->encntr_groups,5)
 FOR (x = 1 TO gcnt)
  SET tcnt = size(request->encntr_groups[x].encntr_types,5)
  FOR (y = 1 TO tcnt)
    IF ((request->encntr_groups[x].encntr_types[y].action_flag=1))
     SET ierrcode = 0
     INSERT  FROM code_value_group c
      SET c.parent_code_value = request->encntr_groups[x].code_value, c.child_code_value = request->
       encntr_groups[x].encntr_types[y].code_value, c.collation_seq = null,
       c.code_set = 29100, c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(curdate,curtime),
       c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
      PLAN (c)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = "Y"
      SET reply->error_msg = serrmsg
      GO TO exit_script
     ENDIF
    ELSEIF ((request->encntr_groups[x].encntr_types[y].action_flag=3))
     SET ierrcode = 0
     DELETE  FROM code_value_group c
      WHERE (c.parent_code_value=request->encntr_groups[x].code_value)
       AND (c.child_code_value=request->encntr_groups[x].encntr_types[y].code_value)
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = "Y"
      SET reply->error_msg = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
 ENDFOR
#exit_script
 IF (failed="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
