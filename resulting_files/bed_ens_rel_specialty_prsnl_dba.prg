CREATE PROGRAM bed_ens_rel_specialty_prsnl:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET spec_cnt = 0
 SET spec_cnt = size(request->spec_list,5)
 SET person_cnt = 0
 SET person_cnt = size(request->person_list,5)
 CALL echo(build("person list :",person_cnt))
 CALL echo(build("person list :",person_cnt))
 IF ((((request->spec_list[1].specialty_id=0)) OR (spec_cnt=0)) )
  SET error_flag = "T"
  SET error_msg = "No specialties in the request structure."
  GO TO exit_script
 ENDIF
 IF ((request->action_flag=1))
  FOR (x = 1 TO spec_cnt)
    FOR (y = 1 TO person_cnt)
     SELECT INTO "NL:"
      FROM br_prsnl_specialty b
      WHERE (b.specialty_id=request->spec_list[x].specialty_id)
       AND (b.prsnl_id=request->person_list[y].person_id)
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM br_prsnl_specialty b
       SET b.prsnl_id = request->person_list[y].person_id, b.specialty_id = request->spec_list[x].
        specialty_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = 0,
        b.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "T"
       SET error_msg = concat("Unable to insert personnel ",cnvtstring(request->person_list[y].
         person_id)," specialty ",cnvtstring(request->spec_list[x].specialty_id),
        " on the br_prsnl_specialty table.")
       GO TO exit_script
      ENDIF
     ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 IF ((request->action_flag=3))
  FOR (x = 1 TO spec_cnt)
    FOR (y = 1 TO person_cnt)
      IF ((request->person_list[y].action_flag=3))
       DELETE  FROM br_prsnl_specialty b
        WHERE (b.prsnl_id=request->person_list[y].person_id)
         AND (b.specialty_id=request->spec_list[x].specialty_id)
        WITH nocounter
       ;end delete
      ELSEIF ((request->person_list[y].action_flag=1))
       SELECT INTO "nl:"
        FROM br_prsnl_specialty b
        PLAN (b
         WHERE (b.prsnl_id=request->person_list[y].person_id)
          AND (b.specialty_id=request->spec_list[x].specialty_id))
        WITH nocounter
       ;end select
       IF (curqual=0)
        INSERT  FROM br_prsnl_specialty b
         SET b.prsnl_id = request->person_list[y].person_id, b.specialty_id = request->spec_list[x].
          specialty_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = 0,
          b.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "T"
         SET error_msg = concat("Unable to insert personnel ",cnvtstring(request->person_list[y].
           person_id)," specialty ",cnvtstring(request->spec_list[x].specialty_id),
          " on the br_prsnl_specialty table.")
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_REL_SPECIALTY_PRSNL","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
