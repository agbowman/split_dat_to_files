CREATE PROGRAM dm_ins_code_filter
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET y = 0
 SET knt = size(request->qual,5)
 CALL echo(build("knt : ",knt))
 SET errormsg = fillstring(132," ")
 SET error_check = 0
 SET reply->status_data.status = "F"
#start
 SET y = (y+ 1)
 FOR (y = y TO knt)
  SELECT INTO "nl:"
   FROM code_domain_filter cf
   WHERE cf.code_set=cnvtint(request->qual[y].code_set)
   WITH nocounter
  ;end select
  IF (curqual < 1)
   CALL echo("the code set is new... Insert to code_domain_filter table")
   SET definition = fillstring(35," ")
   SELECT INTO "nl:"
    FROM dm_code_set dc
    WHERE (dc.code_set=request->qual[y].code_set)
    DETAIL
     definition = dc.description
    WITH nocounter
   ;end select
   INSERT  FROM code_domain_filter cd
    SET cd.code_set = request->qual[y].code_set, cd.definition = definition, cd.domain_id = 0,
     cd.domain_key = "test7", cd.updt_applctx = reqinfo->updt_applctx, cd.updt_cnt = 1,
     cd.updt_dt_tm = cnvtdatetime(curdate,curtime3), cd.updt_id = reqinfo->updt_id, cd.updt_task =
     reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual < 1)
    CALL echo("Error during insert to code domain filter table")
    SET errormsg = "Error during insert to code domain filter table"
    SET error_check = (error_check+ 1)
    GO TO exit_script
   ELSE
    CALL echo("continue to insert into display table")
    FOR (z = 1 TO size(request->qual[y].code,5))
      INSERT  FROM code_domain_filter_display cd
       SET cd.code_set = request->qual[y].code_set, cd.code_value = request->qual[y].code[z].
        code_value, cd.updt_applctx = reqinfo->updt_applctx,
        cd.updt_cnt = 0, cd.updt_dt_tm = cnvtdatetime(curdate,curtime3), cd.updt_id = reqinfo->
        updt_id,
        cd.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
    ENDFOR
    IF (curqual < 1)
     CALL echo("Error during insert to code domain filter table")
     SET errormsg = "Error during insert to code domain filter table"
     SET error_check = (error_check+ 1)
     GO TO exit_script
    ENDIF
   ENDIF
  ELSE
   CALL echo("code set is already in code_domain_filter table..")
   SET z = size(request->qual[y].code,5)
   FOR (x = 1 TO z)
     CALL echo("validate if code value exist in display table")
     SELECT INTO "nl:"
      FROM code_domain_filter_display cf
      WHERE (cf.code_set=request->qual[y].code_set)
       AND (cf.code_value=request->qual[y].code[x].code_value)
      WITH nocounter
     ;end select
     IF (curqual=1)
      CALL echo("The code value is in display table... ")
      CALL echo("go check the next code set in code filter table..")
     ELSE
      CALL echo("insert into display table")
      INSERT  FROM code_domain_filter_display cd
       SET cd.code_set = request->qual[y].code_set, cd.code_value = request->qual[y].code[x].
        code_value, cd.updt_applctx = reqinfo->updt_applctx,
        cd.updt_cnt = 0, cd.updt_dt_tm = cnvtdatetime(curdate,curtime3), cd.updt_id = reqinfo->
        updt_id,
        cd.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
     ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 IF (curqual=0)
  SET errormsg = "Error during insert to code domain filter display table"
  SET error_check = (error_check+ 1)
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_check != 0)
  CALL echo(build("error found = ",errormsg))
  SET error_check = error(errormsg,0)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "T"
  ROLLBACK
 ELSEIF (error_check=0)
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
