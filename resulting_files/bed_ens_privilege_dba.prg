CREATE PROGRAM bed_ens_privilege:dba
 FREE SET reply
 RECORD reply(
   1 plist[*]
     2 priv_loc_reltn_id = f8
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
 SET pcnt = size(request->plist,5)
 SET stat = alterlist(reply->plist,pcnt)
 SET privilege_id = 0.0
 SET privilege_exception_id = 0.0
 SET priv_loc_reltn_id = 0.0
 SET active_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET only_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6017
   AND cv.cdf_meaning="INCLUDE"
   AND cv.active_ind=1
  DETAIL
   only_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET exclude_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6017
   AND cv.cdf_meaning="EXCLUDE"
   AND cv.active_ind=1
  DETAIL
   exclude_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET yes_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6017
   AND cv.cdf_meaning="YES"
   AND cv.active_ind=1
  DETAIL
   yes_code_value = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO pcnt)
   IF ((request->plist[x].priv_loc_reltn_id > 0))
    SET priv_loc_reltn_id = request->plist[x].priv_loc_reltn_id
    SET reply->plist[x].priv_loc_reltn_id = priv_loc_reltn_id
   ENDIF
   IF ((request->plist[x].action_flag=1))
    SET priv_loc_reltn_id = 0.0
    SELECT INTO "nl:"
     FROM priv_loc_reltn plr
     WHERE plr.active_ind=1
      AND (plr.person_id=request->plist[x].person_id)
      AND (plr.position_cd=request->plist[x].position_code_value)
      AND (plr.ppr_cd=request->plist[x].ppr_code_value)
      AND (plr.location_cd=request->plist[x].location_code_value)
     DETAIL
      priv_loc_reltn_id = plr.priv_loc_reltn_id
     WITH nocounter
    ;end select
    IF (priv_loc_reltn_id=0)
     SELECT INTO "NL:"
      j = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       priv_loc_reltn_id = cnvtreal(j)
      WITH format, counter
     ;end select
     INSERT  FROM priv_loc_reltn plr
      SET plr.priv_loc_reltn_id = priv_loc_reltn_id, plr.person_id = request->plist[x].person_id, plr
       .position_cd = request->plist[x].position_code_value,
       plr.ppr_cd = request->plist[x].ppr_code_value, plr.location_cd = request->plist[x].
       location_code_value, plr.active_ind = 1,
       plr.active_status_cd = active_code_value, plr.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), plr.active_status_prsnl_id = reqinfo->updt_id,
       plr.updt_dt_tm = cnvtdatetime(curdate,curtime3), plr.updt_id = reqinfo->updt_id, plr.updt_task
        = reqinfo->updt_task,
       plr.updt_cnt = 0, plr.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert person_id = ",cnvtstring(request->plist[x].person_id),
       " and position_code_value = ",cnvtstring(request->plist[x].position_code_value),
       " into table priv_loc_reltn.")
      GO TO exit_script
     ENDIF
    ENDIF
    SET reply->plist[x].priv_loc_reltn_id = priv_loc_reltn_id
   ELSEIF ((request->plist[x].action_flag=2))
    UPDATE  FROM priv_loc_reltn plr
     SET plr.person_id = request->plist[x].person_id, plr.position_cd = request->plist[x].
      position_code_value, plr.ppr_cd = request->plist[x].ppr_code_value,
      plr.location_cd = request->plist[x].location_code_value, plr.active_ind = 1, plr
      .active_status_cd = active_code_value,
      plr.updt_dt_tm = cnvtdatetime(curdate,curtime3), plr.updt_id = reqinfo->updt_id, plr.updt_task
       = reqinfo->updt_task,
      plr.updt_cnt = (plr.updt_cnt+ 1), plr.updt_applctx = reqinfo->updt_applctx
     WHERE plr.priv_loc_reltn_id=priv_loc_reltn_id
      AND plr.active_ind=1
     WITH nocounter
    ;end update
   ELSEIF ((request->plist[x].action_flag=3))
    SET privilege_id = 100.0
    WHILE (privilege_id > 0)
      SET privilege_id = 0.0
      SELECT INTO "nl:"
       FROM privilege priv
       WHERE priv.active_ind=1
        AND priv.priv_loc_reltn_id=priv_loc_reltn_id
       DETAIL
        privilege_id = priv.privilege_id
       WITH nocounter
      ;end select
      IF (privilege_id > 0)
       DELETE  FROM privilege priv
        WHERE priv.privilege_id=privilege_id
        WITH nocounter
       ;end delete
       DELETE  FROM privilege_exception pe
        WHERE pe.privilege_id=privilege_id
        WITH nocounter
       ;end delete
      ENDIF
    ENDWHILE
    DELETE  FROM priv_loc_reltn plr
     WHERE plr.priv_loc_reltn_id=priv_loc_reltn_id
      AND plr.active_ind=1
     WITH nocounter
    ;end delete
   ENDIF
   SET priv_cnt = size(request->plist[x].priv_list,5)
   FOR (y = 1 TO priv_cnt)
     IF ((request->plist[x].priv_list[y].privilege_id > 0))
      SET privilege_id = request->plist[x].priv_list[y].privilege_id
     ENDIF
     IF ((request->plist[x].priv_list[y].action_flag=1))
      SET privilege_id = 0.0
      SELECT INTO "nl:"
       FROM privilege priv
       WHERE priv.active_ind=1
        AND priv.priv_loc_reltn_id=priv_loc_reltn_id
        AND (priv.privilege_cd=request->plist[x].priv_list[y].privilege_code_value)
        AND (priv.priv_value_cd=request->plist[x].priv_list[y].priv_value_code_value)
        AND priv.priv_loc_reltn_id=priv_loc_reltn_id
       DETAIL
        privilege_id = priv.privilege_id
       WITH nocounter
      ;end select
      IF (privilege_id=0)
       SELECT INTO "NL:"
        j = seq(reference_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         privilege_id = cnvtreal(j)
        WITH format, counter
       ;end select
       INSERT  FROM privilege priv
        SET priv.privilege_id = privilege_id, priv.priv_loc_reltn_id = priv_loc_reltn_id, priv
         .privilege_cd = request->plist[x].priv_list[y].privilege_code_value,
         priv.priv_value_cd = request->plist[x].priv_list[y].priv_value_code_value, priv.active_ind
          = 1, priv.active_status_cd = active_code_value,
         priv.active_status_dt_tm = cnvtdatetime(curdate,curtime3), priv.active_status_prsnl_id =
         reqinfo->updt_id, priv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         priv.updt_id = reqinfo->updt_id, priv.updt_task = reqinfo->updt_task, priv.updt_cnt = 0,
         priv.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Unable to insert privilege_code_value = ",cnvtstring(request->plist[x
          ].priv_list[y].privilege_code_value)," and priv_value_code_value = ",cnvtstring(request->
          plist[x].priv_value_code_value)," into table privilege.")
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF ((request->plist[x].priv_list[y].action_flag=2))
      SET priv_mean = fillstring(12," ")
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE cv.active_ind=1
        AND cv.code_set=6016
        AND (cv.code_value=request->plist[x].priv_list[y].privilege_code_value)
       DETAIL
        priv_mean = cv.cdf_meaning
       WITH nocounter
      ;end select
      SET view_code_value = 0.0
      CASE (priv_mean)
       OF "UPDTPROB":
        SELECT INTO "NL:"
         FROM code_value cv
         WHERE cv.active_ind=1
          AND cv.code_set=6016
          AND cv.cdf_meaning="VIEWPROB"
         DETAIL
          view_code_value = cv.code_value
         WITH counter
        ;end select
       OF "UPDTPROBNOM":
        SELECT INTO "NL:"
         FROM code_value cv
         WHERE cv.active_ind=1
          AND cv.code_set=6016
          AND cv.cdf_meaning="VIEWPROBNOM"
         DETAIL
          view_code_value = cv.code_value
         WITH counter
        ;end select
       OF "UPDTALLERGY":
        SELECT INTO "NL:"
         FROM code_value cv
         WHERE cv.active_ind=1
          AND cv.code_set=6016
          AND cv.cdf_meaning="VIEWALLERGY"
         DETAIL
          view_code_value = cv.code_value
         WITH counter
        ;end select
       OF "UPDTPROCHIS":
        SELECT INTO "NL:"
         FROM code_value cv
         WHERE cv.active_ind=1
          AND cv.code_set=6016
          AND cv.cdf_meaning="VIEWPROCHIS"
         DETAIL
          view_code_value = cv.code_value
         WITH counter
        ;end select
      ENDCASE
      SET only_ind = 0
      SET exclude_ind = 0
      SET view_privilege_id = 0.0
      SET view_priv_code_value = 0.0
      SET upd_priv_code_value = 0.0
      SELECT INTO "NL:"
       FROM privilege priv
       PLAN (priv
        WHERE ((priv.privilege_cd=view_code_value) OR ((priv.privilege_cd=request->plist[x].
        priv_list[y].privilege_code_value)))
         AND priv.active_ind=1
         AND priv.priv_loc_reltn_id=priv_loc_reltn_id)
       DETAIL
        IF (priv.privilege_cd=view_code_value)
         view_privilege_id = priv.privilege_id, view_priv_code_value = priv.priv_value_cd
         CASE (priv.priv_value_cd)
          OF only_code_value:
           only_ind = 1
          OF exclude_code_value:
           exclude_ind = 1
         ENDCASE
        ELSE
         upd_priv_code_value = priv.priv_value_cd
        ENDIF
       WITH nocounter
      ;end select
      IF (((only_ind=1) OR (exclude_ind=1))
       AND (request->plist[x].priv_list[y].priv_value_code_value != upd_priv_code_value))
       DELETE  FROM privilege_exception pe
        WHERE pe.privilege_id=view_privilege_id
        WITH nocounter
       ;end delete
       UPDATE  FROM privilege priv
        SET priv.priv_value_cd = yes_code_value, priv.active_ind = 1, priv.active_status_cd =
         active_code_value,
         priv.updt_dt_tm = cnvtdatetime(curdate,curtime3), priv.updt_id = reqinfo->updt_id, priv
         .updt_task = reqinfo->updt_task,
         priv.updt_cnt = (priv.updt_cnt+ 1), priv.updt_applctx = reqinfo->updt_applctx
        WHERE priv.privilege_id=view_privilege_id
        WITH nocounter
       ;end update
      ENDIF
      UPDATE  FROM privilege priv
       SET priv.privilege_cd = request->plist[x].priv_list[y].privilege_code_value, priv
        .priv_value_cd = request->plist[x].priv_list[y].priv_value_code_value, priv.active_ind = 1,
        priv.active_status_cd = active_code_value, priv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        priv.updt_id = reqinfo->updt_id,
        priv.updt_task = reqinfo->updt_task, priv.updt_cnt = (priv.updt_cnt+ 1), priv.updt_applctx =
        reqinfo->updt_applctx
       WHERE (priv.privilege_id=request->plist[x].priv_list[y].privilege_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to update privilege_id = ",cnvtstring(request->plist[x].
         privilege_id)," on table privilege.")
       GO TO exit_script
      ENDIF
      IF ((yes_code_value=request->plist[x].priv_list[y].priv_value_code_value))
       DELETE  FROM privilege_exception pe
        WHERE (pe.privilege_id=request->plist[x].priv_list[y].privilege_id)
        WITH nocounter
       ;end delete
      ENDIF
     ELSEIF ((request->plist[x].priv_list[y].action_flag=3))
      DELETE  FROM privilege_exception pe
       WHERE (pe.privilege_id=request->plist[x].priv_list[y].privilege_id)
       WITH nocounter
      ;end delete
      DELETE  FROM privilege priv
       WHERE (priv.privilege_id=request->plist[x].priv_list[y].privilege_id)
       WITH nocounter
      ;end delete
     ENDIF
     SET except_cnt = size(request->plist[x].priv_list[y].elist,5)
     FOR (z = 1 TO except_cnt)
      SET privilege_exception_id = 0.0
      IF ((request->plist[x].priv_list[y].elist[z].action_flag=1))
       SELECT INTO "nl:"
        FROM privilege_exception pe
        WHERE pe.active_ind=1
         AND (pe.exception_entity_name=request->plist[x].priv_list[y].elist[z].exception_entity_name)
         AND (pe.exception_type_cd=request->plist[x].priv_list[y].elist[z].exception_type_code_value)
         AND (pe.exception_id=request->plist[x].priv_list[y].elist[z].exception_id)
         AND pe.privilege_id=privilege_id
        DETAIL
         privilege_exception_id = pe.privilege_exception_id
        WITH nocounter
       ;end select
       IF (privilege_exception_id=0.0)
        SELECT INTO "NL:"
         j = seq(reference_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          privilege_exception_id = cnvtreal(j)
         WITH format, counter
        ;end select
        INSERT  FROM privilege_exception pe
         SET pe.privilege_id = privilege_id, pe.privilege_exception_id = privilege_exception_id, pe
          .exception_id = request->plist[x].priv_list[y].elist[z].exception_id,
          pe.exception_entity_name = request->plist[x].priv_list[y].elist[z].exception_entity_name,
          pe.exception_type_cd = request->plist[x].priv_list[y].elist[z].exception_type_code_value,
          pe.active_ind = 1,
          pe.active_status_cd = active_code_value, pe.active_status_dt_tm = cnvtdatetime(curdate,
           curtime3), pe.active_status_prsnl_id = reqinfo->updt_id,
          pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe.updt_task
           = reqinfo->updt_task,
          pe.updt_cnt = 0, pe.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET error_msg = concat("Unable to insert exception_id = ",cnvtstring(request->plist[x].
           priv_list[y].elist[z].exception_id)," into table privilege_exception.")
         GO TO exit_script
        ELSE
         IF ((request->plist[x].priv_list[y].action_flag=0)
          AND (request->plist[x].priv_list[y].elist[z].action_flag=1)
          AND (request->plist[x].priv_list[y].priv_value_code_value=only_code_value)
          AND only_code_value > 0.0)
          SET priv_mean = fillstring(12," ")
          SELECT INTO "NL:"
           FROM code_value cv
           WHERE cv.active_ind=1
            AND cv.code_set=6016
            AND (cv.code_value=request->plist[x].priv_list[y].privilege_code_value)
           DETAIL
            priv_mean = cv.cdf_meaning
           WITH nocounter
          ;end select
          SET view_code_value = 0.0
          CASE (priv_mean)
           OF "UPDTPROB":
            SELECT INTO "NL:"
             FROM code_value cv
             WHERE cv.active_ind=1
              AND cv.code_set=6016
              AND cv.cdf_meaning="VIEWPROB"
             DETAIL
              view_code_value = cv.code_value
             WITH counter
            ;end select
           OF "UPDTPROBNOM":
            SELECT INTO "NL:"
             FROM code_value cv
             WHERE cv.active_ind=1
              AND cv.code_set=6016
              AND cv.cdf_meaning="VIEWPROBNOM"
             DETAIL
              view_code_value = cv.code_value
             WITH counter
            ;end select
           OF "UPDTALLERGY":
            SELECT INTO "NL:"
             FROM code_value cv
             WHERE cv.active_ind=1
              AND cv.code_set=6016
              AND cv.cdf_meaning="VIEWALLERGY"
             DETAIL
              view_code_value = cv.code_value
             WITH counter
            ;end select
           OF "UPDTPROCHIS":
            SELECT INTO "NL:"
             FROM code_value cv
             WHERE cv.active_ind=1
              AND cv.code_set=6016
              AND cv.cdf_meaning="VIEWPROCHIS"
             DETAIL
              view_code_value = cv.code_value
             WITH counter
            ;end select
          ENDCASE
          SET only_ind = 0
          SET exclude_ind = 0
          SET view_privilege_id = 0.0
          SELECT INTO "NL:"
           FROM privilege priv
           PLAN (priv
            WHERE priv.privilege_cd=view_code_value
             AND priv.active_ind=1
             AND priv.priv_loc_reltn_id=priv_loc_reltn_id)
           DETAIL
            view_privilege_id = priv.privilege_id
            CASE (priv.priv_value_cd)
             OF only_code_value:
              only_ind = 1
             OF exclude_code_value:
              exclude_ind = 1
            ENDCASE
           WITH nocounter
          ;end select
          IF (((only_ind=1) OR (exclude_ind=1)) )
           SET privilege_exception_id = 0.0
           SELECT INTO "NL:"
            FROM privilege_exception pe
            WHERE pe.active_ind=1
             AND pe.privilege_id=view_privilege_id
             AND (pe.exception_id=request->plist[x].priv_list[y].elist[z].exception_id)
            DETAIL
             privilege_exception_id = pe.privilege_exception_id
            WITH nocounter
           ;end select
           IF (privilege_exception_id=0.0
            AND only_ind=1)
            SET privilege_exception_id = 0.0
            SELECT INTO "NL:"
             j = seq(reference_seq,nextval)"##################;rp0"
             FROM dual
             DETAIL
              privilege_exception_id = cnvtreal(j)
             WITH format, counter
            ;end select
            INSERT  FROM privilege_exception pe
             SET pe.privilege_id = view_privilege_id, pe.privilege_exception_id =
              privilege_exception_id, pe.exception_id = request->plist[x].priv_list[y].elist[z].
              exception_id,
              pe.exception_entity_name = request->plist[x].priv_list[y].elist[z].
              exception_entity_name, pe.exception_type_cd = request->plist[x].priv_list[y].elist[z].
              exception_type_code_value, pe.active_ind = 1,
              pe.active_status_cd = active_code_value, pe.active_status_dt_tm = cnvtdatetime(curdate,
               curtime3), pe.active_status_prsnl_id = reqinfo->updt_id,
              pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe
              .updt_task = reqinfo->updt_task,
              pe.updt_cnt = 0, pe.updt_applctx = reqinfo->updt_applctx
             WITH nocounter
            ;end insert
            IF (curqual=0)
             SET error_flag = "Y"
             SET error_msg = concat("Unable to insert exception_id = ",cnvtstring(request->plist[x].
               priv_list[y].elist[z].exception_id),
              " into table privilege_exception for the privilege_id = ",cnvtstring(view_privilege_id),
              ".")
             GO TO exit_script
            ENDIF
           ELSEIF (privilege_exception_id > 0.0
            AND exclude_ind=1)
            DELETE  FROM privilege_exception pe
             WHERE pe.privilege_exception_id=privilege_exception_id
             WITH nocounter
            ;end delete
            SELECT INTO "NL:"
             FROM privilege_exception pe
             WHERE pe.privilege_id=view_privilege_id
             WITH nocounter
            ;end select
            IF (curqual=0)
             UPDATE  FROM privilege priv
              SET priv.priv_value_cd = yes_code_value, priv.active_ind = 1, priv.active_status_cd =
               active_code_value,
               priv.updt_dt_tm = cnvtdatetime(curdate,curtime3), priv.updt_id = reqinfo->updt_id,
               priv.updt_task = reqinfo->updt_task,
               priv.updt_cnt = (priv.updt_cnt+ 1), priv.updt_applctx = reqinfo->updt_applctx
              WHERE priv.privilege_id=view_privilege_id
              WITH nocounter
             ;end update
            ENDIF
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ELSEIF ((request->plist[x].priv_list[y].elist[z].action_flag=2))
       UPDATE  FROM privilege_exception pe
        SET pe.exception_id = request->plist[x].priv_list[y].elist[z].exception_id, pe
         .exception_entity_name = request->plist[x].priv_list[y].elist[z].exception_entity_name, pe
         .exception_type_cd = request->plist[x].priv_list[y].elist[z].exception_type_code_value,
         pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.active_ind = 1, pe.active_status_cd =
         active_code_value,
         pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_cnt = (pe.updt_cnt
         + 1),
         pe.updt_applctx = reqinfo->updt_applctx
        WHERE (pe.privilege_exception_id=request->plist[x].priv_list[y].elist[z].
        privilege_exception_id)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Unable to update privilege_exception_id = ",cnvtstring(request->
          plist[x].priv_list[y].elist[z].privilege_exception_id)," on table privilege_exception.")
        GO TO exit_script
       ENDIF
      ELSEIF ((request->plist[x].priv_list[y].elist[z].action_flag=3))
       DELETE  FROM privilege_exception pe
        WHERE (pe.privilege_exception_id=request->plist[x].priv_list[y].elist[z].
        privilege_exception_id)
        WITH nocounter
       ;end delete
       SELECT INTO "NL:"
        FROM privilege_exception pe
        WHERE (pe.privilege_id=request->plist[x].priv_list[y].privilege_id)
        WITH nocounter
       ;end select
       IF (curqual=0)
        UPDATE  FROM privilege priv
         SET priv.priv_value_cd = yes_code_value, priv.active_ind = 1, priv.active_status_cd =
          active_code_value,
          priv.updt_dt_tm = cnvtdatetime(curdate,curtime3), priv.updt_id = reqinfo->updt_id, priv
          .updt_task = reqinfo->updt_task,
          priv.updt_cnt = (priv.updt_cnt+ 1), priv.updt_applctx = reqinfo->updt_applctx
         WHERE (priv.privilege_id=request->plist[x].priv_list[y].privilege_id)
         WITH nocounter
        ;end update
       ENDIF
      ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_PRIVILEGE","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
