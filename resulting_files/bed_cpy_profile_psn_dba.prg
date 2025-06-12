CREATE PROGRAM bed_cpy_profile_psn:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD tempcfv(
   1 privilege_id = f8
   1 privilege_cd = f8
   1 priv_value_cd = f8
   1 active_status_cd = f8
   1 restr_method_cd = f8
   1 log_grouping_cd = f8
   1 elist[*]
     2 exception_type_cd = f8
     2 exception_id = f8
     2 active_status_cd = f8
     2 exception_entity_name = vc
     2 event_set_name = vc
 )
 RECORD tempcfu(
   1 privilege_id = f8
   1 privilege_cd = f8
   1 priv_value_cd = f8
   1 active_status_cd = f8
   1 restr_method_cd = f8
   1 log_grouping_cd = f8
   1 elist[*]
     2 exception_type_cd = f8
     2 exception_id = f8
     2 active_status_cd = f8
     2 exception_entity_name = vc
     2 event_set_name = vc
 )
 DECLARE logprivilegedelete(priv_id=f8) = null
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 DECLARE priv_mean1 = vc
 DECLARE priv_mean2 = vc
 DECLARE priv_cd1 = f8
 DECLARE priv_cd2 = f8
 DECLARE ctvp_id = f8
 DECLARE ctup_id = f8
 SET ctcnt = 0
 IF ((request->copy_from_psn_cd=0))
  SET error_flag = "Y"
  SET error_msg = "Request invalid, copy from psn must be populated"
  GO TO exit_script
 ENDIF
 SET ctcnt = size(request->ctlist,5)
 IF (ctcnt=0)
  SET error_flag = "Y"
  SET error_msg = "Request invalid, copy to list is empty."
  GO TO exit_script
 ENDIF
 IF ((request->profile_mean="ALLERGY"))
  SET priv_mean1 = "VIEWALLERGY"
  SET priv_mean2 = "UPDTALLERGY"
 ELSEIF ((request->profile_mean="PROCEDURE"))
  SET priv_mean1 = "VIEWPROCHIS"
  SET priv_mean2 = "UPDTPROCHIS"
 ELSEIF ((request->profile_mean="PROBLEM"))
  SET priv_mean1 = "VIEWPROBNOM"
  SET priv_mean2 = "UPDTPROBNOM"
 ELSEIF ((request->profile_mean="PROBLEMCLASS"))
  SET priv_mean1 = "VIEWPROB"
  SET priv_mean2 = "UPDATEPROB"
 ELSEIF ((request->profile_mean="CLINDIAG"))
  SET priv_mean1 = "VIEWDIAGSEL"
  SET priv_mean2 = "UPDTDIAGSEL"
 ELSEIF ((request->profile_mean="ORDER"))
  SET priv_mean1 = "VIEWORDER"
  SET priv_mean2 = "ORDER"
 ELSE
  SET error_msg = "Profile mode not recognized, must be ALLERGY,PROBLEM,CLINDIAG,ORDER or PROCEDURE."
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 SET view_priv_cd = 0
 SET updt_priv_cd = 0
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
 SET tempcfv->privilege_id = 0.0
 SET tempcfu->privilege_id = 0.0
 SET copy_from_priv_id = 0.0
 SET cfvcnt = 0
 SET cfucnt = 0
 SELECT INTO "nl:"
  FROM priv_loc_reltn plr,
   privilege p,
   privilege_exception pe
  PLAN (plr
   WHERE (plr.position_cd=request->copy_from_psn_cd)
    AND plr.active_ind=1)
   JOIN (p
   WHERE p.priv_loc_reltn_id=plr.priv_loc_reltn_id
    AND p.privilege_cd IN (updt_priv_cd, view_priv_cd)
    AND p.active_ind=1)
   JOIN (pe
   WHERE pe.privilege_id=outerjoin(p.privilege_id)
    AND pe.active_ind=outerjoin(1))
  ORDER BY p.privilege_cd
  HEAD REPORT
   cfvcnt = 0, cfucnt = 0
  HEAD p.privilege_cd
   IF (p.privilege_cd=view_priv_cd)
    tempcfv->privilege_id = p.privilege_id, tempcfv->privilege_cd = p.privilege_cd, tempcfv->
    priv_value_cd = p.priv_value_cd,
    tempcfv->active_status_cd = p.active_status_cd, tempcfv->restr_method_cd = p.restr_method_cd,
    tempcfv->log_grouping_cd = p.log_grouping_cd
   ELSEIF (p.privilege_cd=updt_priv_cd)
    tempcfu->privilege_id = p.privilege_id, tempcfu->privilege_cd = p.privilege_cd, tempcfu->
    priv_value_cd = p.priv_value_cd,
    tempcfu->active_status_cd = p.active_status_cd, tempcfu->restr_method_cd = p.restr_method_cd,
    tempcfu->log_grouping_cd = p.log_grouping_cd
   ENDIF
  DETAIL
   IF (pe.privilege_exception_id > 0)
    IF (p.privilege_cd=view_priv_cd)
     cfvcnt = (cfvcnt+ 1), stat = alterlist(tempcfv->elist,cfvcnt), tempcfv->elist[cfvcnt].
     exception_type_cd = pe.exception_type_cd,
     tempcfv->elist[cfvcnt].exception_id = pe.exception_id, tempcfv->elist[cfvcnt].active_status_cd
      = pe.active_status_cd, tempcfv->elist[cfvcnt].exception_entity_name = pe.exception_entity_name,
     tempcfv->elist[cfvcnt].event_set_name = pe.event_set_name
    ELSEIF (p.privilege_cd=updt_priv_cd)
     cfucnt = (cfucnt+ 1), stat = alterlist(tempcfu->elist,cfucnt), tempcfu->elist[cfucnt].
     exception_type_cd = pe.exception_type_cd,
     tempcfu->elist[cfucnt].exception_id = pe.exception_id, tempcfu->elist[cfucnt].active_status_cd
      = pe.active_status_cd, tempcfu->elist[cfucnt].exception_entity_name = pe.exception_entity_name,
     tempcfu->elist[cfucnt].event_set_name = pe.event_set_name
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO ctcnt)
   SET plr_id = 0.0
   SELECT INTO "nl:"
    FROM priv_loc_reltn plr
    WHERE (plr.position_cd=request->ctlist[x].copy_to_psn_cd)
    DETAIL
     plr_id = plr.priv_loc_reltn_id
    WITH nocounter
   ;end select
   SET ctvp_id = 0
   SET ctup_id = 0
   IF (plr_id=0)
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      plr_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM priv_loc_reltn plr
     SET plr.priv_loc_reltn_id = plr_id, plr.person_id = 0, plr.position_cd = request->ctlist[x].
      copy_to_psn_cd,
      plr.ppr_cd = 0, plr.location_cd = 0, plr.active_ind = 1,
      plr.active_status_cd = active_code_value, plr.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), plr.active_status_prsnl_id = reqinfo->updt_id,
      plr.updt_dt_tm = cnvtdatetime(curdate,curtime3), plr.updt_id = reqinfo->updt_id, plr.updt_task
       = reqinfo->updt_task,
      plr.updt_cnt = 0, plr.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
   ELSE
    SELECT INTO "nl:"
     FROM privilege p
     PLAN (p
      WHERE p.priv_loc_reltn_id=plr_id
       AND p.privilege_cd IN (view_priv_cd, updt_priv_cd))
     DETAIL
      IF (p.privilege_cd=view_priv_cd)
       ctvp_id = p.privilege_id
      ELSE
       ctup_id = p.privilege_id
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((tempcfv->privilege_id=0))
    IF (ctvp_id > 0)
     CALL logprivilegedelete(ctvp_id)
     DELETE  FROM privilege_exception pe
      WHERE pe.privilege_id=ctvp_id
      WITH nocounter
     ;end delete
     DELETE  FROM privilege p
      WHERE p.privilege_id=ctvp_id
      WITH nocounter
     ;end delete
    ENDIF
    IF (ctup_id > 0)
     CALL logprivilegedelete(ctup_id)
     DELETE  FROM privilege_exception pe
      WHERE pe.privilege_id=ctup_id
      WITH nocounter
     ;end delete
     DELETE  FROM privilege p
      WHERE p.privilege_id=ctup_id
      WITH nocounter
     ;end delete
    ENDIF
   ELSE
    IF (ctvp_id=0)
     SELECT INTO "NL:"
      j = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       ctvp_id = cnvtreal(j)
      WITH format, counter
     ;end select
     INSERT  FROM privilege priv
      SET priv.privilege_id = ctvp_id, priv.priv_loc_reltn_id = plr_id, priv.privilege_cd =
       view_priv_cd,
       priv.priv_value_cd = tempcfv->priv_value_cd, priv.restr_method_cd = tempcfv->restr_method_cd,
       priv.log_grouping_cd = tempcfv->log_grouping_cd,
       priv.active_ind = 1, priv.active_status_cd = tempcfv->active_status_cd, priv
       .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       priv.active_status_prsnl_id = reqinfo->updt_id, priv.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), priv.updt_id = reqinfo->updt_id,
       priv.updt_task = reqinfo->updt_task, priv.updt_cnt = 0, priv.updt_applctx = reqinfo->
       updt_applctx
      WITH nocounter
     ;end insert
    ELSE
     UPDATE  FROM privilege priv
      SET priv.priv_value_cd = tempcfv->priv_value_cd, priv.active_status_cd = tempcfv->
       active_status_cd, priv.restr_method_cd = tempcfv->restr_method_cd,
       priv.log_grouping_cd = tempcfv->log_grouping_cd, priv.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), priv.updt_id = reqinfo->updt_id,
       priv.updt_task = reqinfo->updt_task, priv.updt_cnt = (priv.updt_cnt+ 1), priv.updt_applctx =
       reqinfo->updt_applctx
      WHERE priv.privilege_id=ctvp_id
      WITH nocounter
     ;end update
    ENDIF
    IF (ctup_id=0)
     SELECT INTO "NL:"
      j = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       ctup_id = cnvtreal(j)
      WITH format, counter
     ;end select
     INSERT  FROM privilege priv
      SET priv.privilege_id = ctup_id, priv.priv_loc_reltn_id = plr_id, priv.privilege_cd =
       updt_priv_cd,
       priv.priv_value_cd = tempcfu->priv_value_cd, priv.restr_method_cd = tempcfu->restr_method_cd,
       priv.log_grouping_cd = tempcfu->log_grouping_cd,
       priv.active_ind = 1, priv.active_status_cd = tempcfu->active_status_cd, priv
       .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       priv.active_status_prsnl_id = reqinfo->updt_id, priv.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), priv.updt_id = reqinfo->updt_id,
       priv.updt_task = reqinfo->updt_task, priv.updt_cnt = 0, priv.updt_applctx = reqinfo->
       updt_applctx
      WITH nocounter
     ;end insert
    ELSE
     UPDATE  FROM privilege priv
      SET priv.priv_value_cd = tempcfu->priv_value_cd, priv.active_status_cd = tempcfu->
       active_status_cd, priv.restr_method_cd = tempcfu->restr_method_cd,
       priv.log_grouping_cd = tempcfu->log_grouping_cd, priv.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), priv.updt_id = reqinfo->updt_id,
       priv.updt_task = reqinfo->updt_task, priv.updt_cnt = (priv.updt_cnt+ 1), priv.updt_applctx =
       reqinfo->updt_applctx
      WHERE priv.privilege_id=ctup_id
      WITH nocounter
     ;end update
    ENDIF
    IF (cfvcnt > 0)
     CALL logprivilegedelete(ctvp_id)
     DELETE  FROM privilege_exception pe
      WHERE pe.privilege_id=ctvp_id
      WITH nocounter
     ;end delete
     FOR (y = 1 TO cfvcnt)
       INSERT  FROM privilege_exception pe
        SET pe.privilege_exception_id = seq(reference_seq,nextval), pe.privilege_id = ctvp_id, pe
         .exception_id = tempcfv->elist[y].exception_id,
         pe.exception_type_cd = tempcfv->elist[y].exception_type_cd, pe.exception_entity_name =
         tempcfv->elist[y].exception_entity_name, pe.active_ind = 1,
         pe.active_status_cd = tempcfv->elist[y].active_status_cd, pe.active_status_dt_tm =
         cnvtdatetime(curdate,curtime), pe.active_status_prsnl_id = reqinfo->updt_id,
         pe.updt_dt_tm = cnvtdatetime(curdate,curtime), pe.updt_id = reqinfo->updt_id, pe.updt_task
          = reqinfo->updt_task,
         pe.updt_cnt = 0, pe.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
     ENDFOR
    ENDIF
    IF (cfucnt > 0)
     CALL logprivilegedelete(ctup_id)
     DELETE  FROM privilege_exception pe
      WHERE pe.privilege_id=ctup_id
      WITH nocounter
     ;end delete
     FOR (y = 1 TO cfucnt)
       INSERT  FROM privilege_exception pe
        SET pe.privilege_exception_id = seq(reference_seq,nextval), pe.privilege_id = ctup_id, pe
         .exception_id = tempcfu->elist[y].exception_id,
         pe.exception_type_cd = tempcfu->elist[y].exception_type_cd, pe.exception_entity_name =
         tempcfu->elist[y].exception_entity_name, pe.active_ind = 1,
         pe.active_status_cd = tempcfu->elist[y].active_status_cd, pe.active_status_dt_tm =
         cnvtdatetime(curdate,curtime), pe.active_status_prsnl_id = reqinfo->updt_id,
         pe.updt_dt_tm = cnvtdatetime(curdate,curtime), pe.updt_id = reqinfo->updt_id, pe.updt_task
          = reqinfo->updt_task,
         pe.updt_cnt = 0, pe.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE logprivilegedelete(priv_id)
   CALL echo(build("deleting priv id ",priv_id))
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
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
