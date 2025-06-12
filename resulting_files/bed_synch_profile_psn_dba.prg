CREATE PROGRAM bed_synch_profile_psn:dba
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
 RECORD temp(
   1 priv_loc_reltn_id = f8
   1 privilege_id = f8
   1 priv_value_cd = f8
   1 restr_method_cd = f8
   1 log_grouping_cd = f8
   1 elist[*]
     2 exception_type_cd = f8
     2 exception_id = f8
     2 exception_entity_name = vc
     2 event_set_name = vc
 )
 DECLARE logprivilegedelete(priv_id=f8) = null
 DECLARE hasloggeddelete = i2
 SET hasloggeddelete = 0
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET pcnt = size(request->plist,5)
 IF (pcnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF ((request->profile_mean="ALLERGY"))
  SET priv_mean1 = "VIEWALLERGY"
  SET priv_mean2 = "UPDTALLERGY"
 ELSEIF ((request->profile_mean="PROCEDURE"))
  SET priv_mean1 = "VIEWPROCHIS"
  SET priv_mean2 = "UPDTPROCHIS"
 ELSEIF ((request->profile_mean="PROBLEMCLASS"))
  SET priv_mean1 = "VIEWPROB"
  SET priv_mean2 = "UPDATEPROB"
 ELSEIF ((request->profile_mean="PROBLEM"))
  SET priv_mean1 = "VIEWPROBNOM"
  SET priv_mean2 = "UPDTPROBNOM"
 ELSEIF ((request->profile_mean="CLINDIAG"))
  SET priv_mean1 = "VIEWDIAGSEL"
  SET priv_mean2 = "UPDTDIAGSEL"
 ELSEIF ((request->profile_mean="ORDER"))
  SET priv_mean1 = "VIEWORDER"
  SET priv_mean2 = "ORDER"
 ELSE
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
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
 IF (active_code_value=0)
  SET error_flag = "Y"
  SET error_msg = "Unable to find ACTIVE code on code set 48."
  GO TO exit_script
 ENDIF
 SET view_priv_cd = 0.0
 SET updt_priv_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6016
    AND cv.cdf_meaning IN (priv_mean1, priv_mean2))
  HEAD cv.code_value
   IF (cv.cdf_meaning="VIEW*")
    view_priv_cd = cv.code_value
   ELSE
    updt_priv_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (((updt_priv_cd=0) OR (view_priv_cd=0)) )
  SET error_flag = "Y"
  SET error_msg = concat("Unable to find cs 6016 entry for ",priv_mean1," or ",priv_mean2)
  GO TO exit_script
 ENDIF
 SET bad_priv_cd = 0.0
 SET good_priv_cd = 0.0
 FOR (x = 1 TO pcnt)
   SET hasloggeddelete = 0
   SET bad_priv_cd = 0.0
   SET good_priv_cd = 0.0
   IF ((request->plist[x].synch_flag=1))
    SET bad_priv_cd = updt_priv_cd
    SET good_priv_cd = view_priv_cd
   ELSE
    SET bad_priv_cd = view_priv_cd
    SET good_priv_cd = updt_priv_cd
   ENDIF
   SET temp->privilege_id = 0.0
   SET temp->priv_loc_reltn_id = 0.0
   SET ecnt = 0
   SELECT INTO "nl:"
    FROM priv_loc_reltn plr,
     privilege p,
     privilege_exception pe
    PLAN (plr
     WHERE (plr.position_cd=request->plist[x].position_code_value))
     JOIN (p
     WHERE p.priv_loc_reltn_id=outerjoin(plr.priv_loc_reltn_id)
      AND p.privilege_cd=outerjoin(good_priv_cd))
     JOIN (pe
     WHERE pe.privilege_id=outerjoin(p.privilege_id))
    HEAD REPORT
     temp->priv_loc_reltn_id = plr.priv_loc_reltn_id
     IF (p.privilege_id > 0)
      temp->privilege_id = p.privilege_id, temp->priv_value_cd = p.priv_value_cd, temp->
      restr_method_cd = p.restr_method_cd,
      temp->log_grouping_cd = p.log_grouping_cd
     ENDIF
     ecnt = 0
    DETAIL
     IF (pe.privilege_exception_id > 0)
      ecnt = (ecnt+ 1), stat = alterlist(temp->elist,ecnt), temp->elist[ecnt].exception_type_cd = pe
      .exception_type_cd,
      temp->elist[ecnt].exception_id = pe.exception_id, temp->elist[ecnt].exception_entity_name = pe
      .exception_entity_name, temp->elist[ecnt].event_set_name = pe.event_set_name
     ENDIF
    WITH nocounter
   ;end select
   IF ((temp->priv_loc_reltn_id=0))
    SET error_flag = "Y"
    GO TO exit_script
   ENDIF
   SET hold_priv_id = 0.0
   SELECT INTO "nl:"
    FROM privilege p
    PLAN (p
     WHERE (p.priv_loc_reltn_id=temp->priv_loc_reltn_id)
      AND p.privilege_cd=bad_priv_cd)
    DETAIL
     hold_priv_id = p.privilege_id
    WITH nocounter
   ;end select
   IF (hold_priv_id > 0)
    CALL logprivilegedelete(hold_priv_id)
    DELETE  FROM privilege_exception pe
     PLAN (pe
      WHERE pe.privilege_id=hold_priv_id)
     WITH nocounter
    ;end delete
   ENDIF
   IF ((temp->privilege_id > 0))
    IF (hold_priv_id > 0)
     UPDATE  FROM privilege p
      SET p.priv_value_cd = temp->priv_value_cd, p.restr_method_cd = temp->restr_method_cd, p
       .log_grouping_cd = temp->log_grouping_cd,
       p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
       reqinfo->updt_task,
       p.updt_cnt = 0, p.updt_applctx = reqinfo->updt_applctx
      WHERE p.privilege_id=hold_priv_id
      WITH nocounter
     ;end update
    ELSE
     SELECT INTO "NL:"
      j = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       hold_priv_id = cnvtreal(j)
      WITH format, counter
     ;end select
     INSERT  FROM privilege priv
      SET priv.privilege_id = hold_priv_id, priv.priv_loc_reltn_id = temp->priv_loc_reltn_id, priv
       .privilege_cd = bad_priv_cd,
       priv.priv_value_cd = temp->priv_value_cd, priv.active_ind = 1, priv.active_status_cd =
       active_code_value,
       priv.active_status_dt_tm = cnvtdatetime(curdate,curtime3), priv.active_status_prsnl_id =
       reqinfo->updt_id, priv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       priv.updt_id = reqinfo->updt_id, priv.updt_task = reqinfo->updt_task, priv.updt_cnt = 0,
       priv.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
    SET ecnt = size(temp->elist,5)
    IF (ecnt > 0)
     FOR (y = 1 TO ecnt)
       INSERT  FROM privilege_exception pe
        SET pe.privilege_exception_id = seq(reference_seq,nextval), pe.privilege_id = hold_priv_id,
         pe.exception_id = temp->elist[y].exception_id,
         pe.exception_type_cd = temp->elist[y].exception_type_cd, pe.exception_entity_name = temp->
         elist[y].exception_entity_name, pe.active_ind = 1,
         pe.active_status_cd = active_code_value, pe.active_status_dt_tm = cnvtdatetime(curdate,
          curtime), pe.active_status_prsnl_id = reqinfo->updt_id,
         pe.updt_dt_tm = cnvtdatetime(curdate,curtime), pe.updt_id = reqinfo->updt_id, pe.updt_task
          = reqinfo->updt_task,
         pe.updt_cnt = 0, pe.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
     ENDFOR
    ENDIF
   ELSE
    IF (hold_priv_id > 0)
     CALL logprivilegedelete(hold_priv_id)
     DELETE  FROM privilege p
      PLAN (p
       WHERE p.privilege_id=hold_priv_id)
      WITH nocounter
     ;end delete
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE logprivilegedelete(priv_id)
   IF (hasloggeddelete=0)
    SET plr_privilege_cd = 0
    SET plr_location_cd = 0
    SET plr_person_id = 0
    SET plr_position_cd = 0
    SET plr_ppr_cd = 0
    SELECT INTO "nl:"
     FROM privilege p,
      priv_loc_reltn plr
     PLAN (p
      WHERE p.privilege_id=priv_id
       AND p.priv_loc_reltn_id > 0)
      JOIN (plr
      WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id)
     DETAIL
      plr_privilege_cd = p.privilege_cd, plr_location_cd = plr.location_cd, plr_person_id = plr
      .person_id,
      plr_position_cd = plr.position_cd, plr_ppr_cd = plr.ppr_cd
     WITH nocounter
    ;end select
    IF (plr_privilege_cd > 0)
     INSERT  FROM privilege_deletion p
      SET p.privilege_deletion_id = cnvtreal(seq(reference_seq,nextval)), p.privilege_id = priv_id, p
       .privilege_cd = plr_privilege_cd,
       p.location_cd = plr_location_cd, p.person_id = plr_person_id, p.position_cd = plr_position_cd,
       p.ppr_cd = plr_ppr_cd, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->
       updt_id,
       p.updt_task = reqinfo->updt_task, p.updt_cnt = 0, p.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
    SET hasloggeddelete = 1
   ENDIF
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
