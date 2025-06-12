CREATE PROGRAM br_ens_wizard_security:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 SET br_client_id = 0
 SELECT INTO "nl:"
  FROM br_client bc
  DETAIL
   br_client_id = bc.br_client_id
  WITH nocounter
 ;end select
 SET append_mode_ind = 0
 IF (validate(request->append_mode_ind))
  IF ((request->append_mode_ind=1))
   SET append_mode_ind = 1
  ENDIF
 ENDIF
 IF (validate(request->millennium_tools_ind))
  IF ((request->millennium_tools_ind=1))
   SET hold_ind_str = " "
   SET sec_row_exists = "N"
   SELECT INTO "nl:"
    FROM br_name_value bnv
    PLAN (bnv
     WHERE bnv.br_nv_key1="MTOOLSSECURITY"
      AND bnv.br_name="USERLEVELSECIND")
    DETAIL
     hold_ind_str = trim(bnv.br_value), sec_row_exists = "Y"
    WITH nocounter
   ;end select
   IF (sec_row_exists="Y")
    IF ((request->user_level_security_ind=0)
     AND hold_ind_str != "0")
     UPDATE  FROM br_name_value bnv
      SET bnv.br_value = "0", bnv.updt_dt_tm = cnvtdatetime(curdate,curtime), bnv.updt_cnt = (bnv
       .updt_cnt+ 1),
       bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo
       ->updt_applctx
      WHERE bnv.br_nv_key1="MTOOLSSECURITY"
       AND bnv.br_name="USERLEVELSECIND"
      WITH nocounter
     ;end update
    ELSEIF ((request->user_level_security_ind=1)
     AND hold_ind_str != "1")
     UPDATE  FROM br_name_value bnv
      SET bnv.br_value = "1", bnv.updt_dt_tm = cnvtdatetime(curdate,curtime), bnv.updt_cnt = (bnv
       .updt_cnt+ 1),
       bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo
       ->updt_applctx
      WHERE bnv.br_nv_key1="MTOOLSSECURITY"
       AND bnv.br_name="USERLEVELSECIND"
      WITH nocounter
     ;end update
    ENDIF
   ELSE
    INSERT  FROM br_name_value bnv
     SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_client_id = 1, bnv.br_nv_key1 =
      "MTOOLSSECURITY",
      bnv.br_name = "USERLEVELSECIND", bnv.br_value =
      IF ((request->user_level_security_ind=1)) "1"
      ELSE "0"
      ENDIF
      , bnv.updt_dt_tm = cnvtdatetime(curdate,curtime),
      bnv.updt_cnt = 0, bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task,
      bnv.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
   ENDIF
  ELSE
   SET hold_ind_str = " "
   SET sec_row_exists = "N"
   SELECT INTO "nl:"
    FROM br_name_value bnv
    PLAN (bnv
     WHERE bnv.br_nv_key1="SYSTEMPARAM"
      AND bnv.br_name="USERLEVELSECIND")
    DETAIL
     hold_ind_str = trim(bnv.br_value), sec_row_exists = "Y"
    WITH nocounter
   ;end select
   IF (sec_row_exists="Y")
    IF ((request->user_level_security_ind=0)
     AND hold_ind_str != "0")
     UPDATE  FROM br_name_value bnv
      SET bnv.br_value = "0", bnv.updt_dt_tm = cnvtdatetime(curdate,curtime), bnv.updt_cnt = (bnv
       .updt_cnt+ 1),
       bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo
       ->updt_applctx
      WHERE bnv.br_nv_key1="SYSTEMPARAM"
       AND bnv.br_name="USERLEVELSECIND"
      WITH nocounter
     ;end update
    ELSEIF ((request->user_level_security_ind=1)
     AND hold_ind_str != "1")
     UPDATE  FROM br_name_value bnv
      SET bnv.br_value = "1", bnv.updt_dt_tm = cnvtdatetime(curdate,curtime), bnv.updt_cnt = (bnv
       .updt_cnt+ 1),
       bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo
       ->updt_applctx
      WHERE bnv.br_nv_key1="SYSTEMPARAM"
       AND bnv.br_name="USERLEVELSECIND"
      WITH nocounter
     ;end update
    ENDIF
   ELSE
    INSERT  FROM br_name_value bnv
     SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_client_id = 1, bnv.br_nv_key1 =
      "SYSTEMPARAM",
      bnv.br_name = "USERLEVELSECIND", bnv.br_value =
      IF ((request->user_level_security_ind=1)) "1"
      ELSE "0"
      ENDIF
      , bnv.updt_dt_tm = cnvtdatetime(curdate,curtime),
      bnv.updt_cnt = 0, bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task,
      bnv.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
   ENDIF
  ENDIF
 ENDIF
 SET usercnt = size(request->userlist,5)
 FOR (u = 1 TO usercnt)
   IF ((request->userlist[u].person_id > 0))
    SET solcnt = size(request->userlist[u].sollist,5)
    IF (append_mode_ind=0)
     FOR (x = 1 TO solcnt)
       DELETE  FROM br_name_value bnv
        WHERE bnv.br_nv_key1="WIZARDSECURITY"
         AND bnv.br_name=cnvtstring(request->userlist[u].person_id)
         AND (bnv.br_value=request->userlist[u].sollist[x].solution_mean)
        WITH nocounter
       ;end delete
       DELETE  FROM br_name_value bnv
        WHERE bnv.br_nv_key1="WIZARDSECURITY"
         AND bnv.br_name=cnvtstring(request->userlist[u].person_id)
         AND bnv.br_value IN (
        (SELECT
         bcss.step_mean
         FROM br_client_sol_step bcss,
          br_client_item_reltn bcir,
          br_step bs
         WHERE bcss.br_client_id=br_client_id
          AND (bcss.solution_mean=request->userlist[u].sollist[x].solution_mean)
          AND bcir.br_client_id=bcss.br_client_id
          AND bcir.item_type="STEP"
          AND bcir.item_mean=bcss.step_mean
          AND bs.step_mean=bcir.item_mean))
        WITH nocounter
       ;end delete
       IF ((request->userlist[u].sollist[x].all_wizard_ind=1))
        INSERT  FROM br_name_value bnv
         SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "WIZARDSECURITY", bnv
          .br_name = cnvtstring(request->userlist[u].person_id),
          bnv.br_value = request->userlist[u].sollist[x].solution_mean, bnv.updt_cnt = 0, bnv
          .updt_dt_tm = cnvtdatetime(curdate,curtime3),
          bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task =
          reqinfo->updt_task
         WITH nocounter
        ;end insert
       ELSE
        SET scscnt = size(request->userlist[u].sollist[x].scslist,5)
        FOR (y = 1 TO scscnt)
          IF ((request->userlist[u].sollist[x].scslist[y].step_mean_ind=1))
           INSERT  FROM br_name_value bnv
            SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "WIZARDSECURITY",
             bnv.br_name = cnvtstring(request->userlist[u].person_id),
             bnv.br_value = request->userlist[u].sollist[x].scslist[y].step_mean, bnv.updt_cnt = 0,
             bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
             bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task
              = reqinfo->updt_task
            WITH nocounter
           ;end insert
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
    ELSEIF (append_mode_ind=1)
     FOR (x = 1 TO solcnt)
       SET current_all_wizard_ind = 0
       SELECT INTO "nl:"
        FROM br_name_value bnv
        WHERE bnv.br_nv_key1="WIZARDSECURITY"
         AND bnv.br_name=cnvtstring(request->userlist[u].person_id)
         AND (bnv.br_value=request->userlist[u].sollist[x].solution_mean)
        DETAIL
         current_all_wizard_ind = 1
        WITH nocounter
       ;end select
       IF ((request->userlist[u].sollist[x].all_wizard_ind=1))
        IF (current_all_wizard_ind=0)
         DELETE  FROM br_name_value bnv
          WHERE bnv.br_nv_key1="WIZARDSECURITY"
           AND bnv.br_name=cnvtstring(request->userlist[u].person_id)
           AND bnv.br_value IN (
          (SELECT
           bcss.step_mean
           FROM br_client_sol_step bcss,
            br_client_item_reltn bcir,
            br_step bs
           WHERE bcss.br_client_id=br_client_id
            AND (bcss.solution_mean=request->userlist[u].sollist[x].solution_mean)
            AND bcir.br_client_id=bcss.br_client_id
            AND bcir.item_type="STEP"
            AND bcir.item_mean=bcss.step_mean
            AND bs.step_mean=bcir.item_mean))
          WITH nocounter
         ;end delete
         INSERT  FROM br_name_value bnv
          SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "WIZARDSECURITY", bnv
           .br_name = cnvtstring(request->userlist[u].person_id),
           bnv.br_value = request->userlist[u].sollist[x].solution_mean, bnv.updt_cnt = 0, bnv
           .updt_dt_tm = cnvtdatetime(curdate,curtime3),
           bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task =
           reqinfo->updt_task
          WITH nocounter
         ;end insert
        ENDIF
       ELSE
        IF (current_all_wizard_ind=0)
         SET scscnt = size(request->userlist[u].sollist[x].scslist,5)
         FOR (y = 1 TO scscnt)
           IF ((request->userlist[u].sollist[x].scslist[y].step_mean_ind=1))
            SET already_exists_ind = 0
            SELECT INTO "nl:"
             FROM br_name_value bnv
             WHERE bnv.br_nv_key1="WIZARDSECURITY"
              AND bnv.br_name=cnvtstring(request->userlist[u].person_id)
              AND (bnv.br_value=request->userlist[u].sollist[x].scslist[y].step_mean)
             DETAIL
              already_exists_ind = 1
             WITH nocounter
            ;end select
            IF (already_exists_ind=0)
             INSERT  FROM br_name_value bnv
              SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "WIZARDSECURITY",
               bnv.br_name = cnvtstring(request->userlist[u].person_id),
               bnv.br_value = request->userlist[u].sollist[x].scslist[y].step_mean, bnv.updt_cnt = 0,
               bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
               bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv
               .updt_task = reqinfo->updt_task
              WITH nocounter
             ;end insert
            ENDIF
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
