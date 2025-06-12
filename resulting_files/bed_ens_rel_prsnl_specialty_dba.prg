CREATE PROGRAM bed_ens_rel_prsnl_specialty:dba
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
 RECORD temp(
   1 slist[*]
     2 specialty_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET spec_cnt = 0
 SET spec_cnt = size(request->spec_list,5)
 SET person_cnt = 0
 SET person_cnt = size(request->person_list,5)
 CALL echo(build("person list :",person_cnt))
 CALL echo(build("spec list :",spec_cnt))
 IF ((((request->person_list[1].person_id=0)) OR (person_cnt=0)) )
  SET error_flag = "T"
  SET error_msg = "No personnel in the request structure."
  GO TO exit_script
 ENDIF
 IF ((request->action_flag=1))
  IF ((request->source_person_id=0))
   SET error_flag = "T"
   SET error_msg = "Source person ID not filled out."
   GO TO exit_script
  ENDIF
  SET scnt = 0
  SELECT INTO "nl:"
   FROM br_prsnl_specialty bps
   PLAN (bps
    WHERE (bps.prsnl_id=request->source_person_id))
   DETAIL
    scnt = (scnt+ 1), stat = alterlist(temp->slist,scnt), temp->slist[scnt].specialty_id = bps
    .specialty_id
   WITH nocounter
  ;end select
  CALL echorecord(temp)
  IF (scnt > 0)
   FOR (x = 1 TO person_cnt)
     FOR (y = 1 TO scnt)
      SELECT INTO "NL:"
       FROM br_prsnl_specialty b
       PLAN (b
        WHERE (b.prsnl_id=request->person_list[x].person_id)
         AND (b.specialty_id=temp->slist[y].specialty_id))
       WITH nocounter
      ;end select
      IF (curqual=0)
       INSERT  FROM br_prsnl_specialty b
        SET b.prsnl_id = request->person_list[x].person_id, b.specialty_id = temp->slist[y].
         specialty_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = 1,
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
 ENDIF
 IF ((request->action_flag=3))
  IF (spec_cnt=0)
   SET error_flag = "T"
   SET error_msg = "No specialties in the request structure."
   GO TO exit_script
  ENDIF
  FOR (x = 1 TO person_cnt)
    FOR (y = 1 TO spec_cnt)
      IF ((request->spec_list[y].action_flag=1))
       SELECT INTO "nl:"
        FROM br_prsnl_specialty b
        PLAN (b
         WHERE (b.prsnl_id=request->person_list[x].person_id)
          AND (b.specialty_id=request->spec_list[y].specialty_id))
        WITH nocounter
       ;end select
       IF (curqual=0)
        INSERT  FROM br_prsnl_specialty b
         SET b.prsnl_id = request->person_list[x].person_id, b.specialty_id = request->spec_list[y].
          specialty_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = 1,
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
      ELSEIF ((request->spec_list[y].action_flag=3))
       DELETE  FROM br_prsnl_specialty b
        PLAN (b
         WHERE (b.prsnl_id=request->person_list[x].person_id)
          AND (b.specialty_id=request->spec_list[y].specialty_id))
        WITH nocounter
       ;end delete
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
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_REL_PRSNL_SPECIALTY","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
