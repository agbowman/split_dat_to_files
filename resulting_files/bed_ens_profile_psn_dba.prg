CREATE PROGRAM bed_ens_profile_psn:dba
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
   1 priv_loc_reltn_id = f8
 )
 DECLARE logprivilegedelete(priv_id=f8) = null
 DECLARE hasloggedviewdelete = i2
 SET hasloggedviewdelete = 0
 DECLARE hasloggedupdatedelete = i2
 SET hasloggedupdatedelete = 0
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 SET tot_count = 0
 SET count = 0
 SET tot_privcount = 0
 SET privcount = 0
 SET tot_ecount = 0
 SET ecount = 0
 SET last_priv_loc_reltn_id = 0.0
 SET position_code_value = 0.0
 DECLARE hold_priv_id = f8
 SET active_code_value = 0
 SELECT INTO "NL:"
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
 SET yes_code_value = 0.0
 SET yes_cdf = fillstring(12," ")
 SET no_code_value = 0.0
 SET no_cdf = fillstring(12," ")
 SET inc_code_value = 0.0
 SET inc_cdf = fillstring(12," ")
 SET exc_code_value = 0.0
 SET exc_cdf = fillstring(12," ")
 DECLARE priv_mean1 = vc
 DECLARE priv_mean2 = vc
 DECLARE priv_cd1 = f8
 DECLARE priv_cd2 = f8
 SET in_synch = " "
 SET ecnt = 0
 DECLARE new_updt_priv_value = vc
 DECLARE new_view_priv_value = vc
 DECLARE curr_view_priv_value = vc
 DECLARE curr_updt_priv_value = vc
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
 CALL echo(build("request->pcv = ",request->position_code_value))
 SET position_code_value = validate(request->position_code_value,0)
 CALL echo(build("pcv = ",position_code_value))
 IF ((request->priv_loc_reltn_id=0))
  IF (position_code_value=0)
   SET error_flag = "Y"
   SET error_msg = "Request invalid, priv_loc_reltn_id must be populated"
   GO TO exit_script
  ELSE
   SELECT INTO "nl:"
    y = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     request->priv_loc_reltn_id = cnvtreal(y)
    WITH format, counter
   ;end select
   INSERT  FROM priv_loc_reltn plr
    SET plr.priv_loc_reltn_id = request->priv_loc_reltn_id, plr.person_id = 0, plr.position_cd =
     position_code_value,
     plr.ppr_cd = 0, plr.location_cd = 0, plr.updt_cnt = 0,
     plr.updt_dt_tm = cnvtdatetime(curdate,curtime), plr.updt_id = reqinfo->updt_id, plr.updt_task =
     reqinfo->updt_task,
     plr.updt_applctx = reqinfo->updt_applctx, plr.active_ind = 1, plr.active_status_dt_tm =
     cnvtdatetime(curdate,curtime),
     plr.active_status_prsnl_id = reqinfo->updt_id, plr.beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime), plr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    WITH nocounter
   ;end insert
   SET view_priv_value_cd = 0
   SET updt_priv_value_cd = 0
   SELECT INTO "NL:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=6017
      AND cv.cdf_meaning IN (request->updt_priv_value_mean, request->view_priv_value_mean))
    HEAD cv.code_value
     IF ((cv.cdf_meaning=request->updt_priv_value_mean))
      updt_priv_value_cd = cv.code_value
     ENDIF
     IF ((cv.cdf_meaning=request->view_priv_value_mean))
      view_priv_value_cd = cv.code_value
     ENDIF
    WITH nocounter
   ;end select
   IF ((request->updt_priv_value_mean > "   "))
    INSERT  FROM privilege priv
     SET priv.privilege_id = seq(reference_seq,nextval), priv.priv_loc_reltn_id = request->
      priv_loc_reltn_id, priv.privilege_cd = updt_priv_cd,
      priv.priv_value_cd = updt_priv_value_cd, priv.active_ind = 1, priv.active_status_cd =
      active_code_value,
      priv.active_status_dt_tm = cnvtdatetime(curdate,curtime3), priv.active_status_prsnl_id =
      reqinfo->updt_id, priv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      priv.updt_id = reqinfo->updt_id, priv.updt_task = reqinfo->updt_task, priv.updt_cnt = 0,
      priv.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
   ENDIF
   IF ((request->view_priv_value_mean > "   "))
    INSERT  FROM privilege priv
     SET priv.privilege_id = seq(reference_seq,nextval), priv.priv_loc_reltn_id = request->
      priv_loc_reltn_id, priv.privilege_cd = view_priv_cd,
      priv.priv_value_cd = view_priv_value_cd, priv.active_ind = 1, priv.active_status_cd =
      active_code_value,
      priv.active_status_dt_tm = cnvtdatetime(curdate,curtime3), priv.active_status_prsnl_id =
      reqinfo->updt_id, priv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      priv.updt_id = reqinfo->updt_id, priv.updt_task = reqinfo->updt_task, priv.updt_cnt = 0,
      priv.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
   ENDIF
  ENDIF
 ENDIF
 SET reply->priv_loc_reltn_id = request->priv_loc_reltn_id
 SET valid_plr_id = "N"
 SELECT INTO "nl:"
  FROM priv_loc_reltn plr
  PLAN (plr
   WHERE (plr.priv_loc_reltn_id=request->priv_loc_reltn_id))
  DETAIL
   valid_plr_id = "Y"
  WITH nocounter
 ;end select
 IF (valid_plr_id="N")
  SET error_flag = "Y"
  SET error_msg = "Request invalid, priv_loc_reltn row not found."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6017
   AND cv.cdf_meaning IN ("YES", "INCLUDE", "EXCLUDE", "NO")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="YES")
    yes_code_value = cv.code_value, yes_cdf = cv.cdf_meaning
   ELSEIF (cv.cdf_meaning="INCLUDE")
    inc_code_value = cv.code_value, inc_cdf = cv.cdf_meaning
   ELSEIF (cv.cdf_meaning="EXCLUDE")
    exc_code_value = cv.code_value, exc_cdf = cv.cdf_meaning
   ELSEIF (cv.cdf_meaning="NO")
    no_code_value = cv.code_value, no_cdf = cv.cdf_meaning
   ENDIF
  WITH nocounter
 ;end select
 IF (((yes_code_value=0) OR (((no_code_value=0) OR (((inc_code_value=0) OR (exc_code_value=0)) )) ))
 )
  SET error_flag = "Y"
  SET error_msg = "Unable to find yes,include or exclude on cs 6017"
  GO TO exit_script
 ENDIF
 IF ((request->updt_priv_value_mean IN ("YES", "NO", "INCLUDE", "EXCLUDE"))
  AND (request->view_priv_value_mean IN ("YES", "NO", "INCLUDE", "EXCLUDE")))
  SET new_updt_priv_value = request->updt_priv_value_mean
  SET new_view_priv_value = request->view_priv_value_mean
 ELSE
  SET error_msg = "Priv value mean not recognized, must be YES,NO,INCLUDE or EXCLUDE."
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 IF (new_updt_priv_value != "NO"
  AND new_view_priv_value != new_updt_priv_value)
  SET error_msg = "The request priv values are not valid, they must match unless updt = NO."
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 DECLARE curr_updt_priv_id = f8
 DECLARE curr_view_priv_id = f8
 SET curr_updt_priv_id = 0.0
 SET curr_view_priv_id = 0.0
 SET curr_updt_priv_value_cd = yes_code_value
 SET curr_view_priv_value_cd = yes_code_value
 SELECT INTO "nl:"
  FROM privilege p
  PLAN (p
   WHERE (p.priv_loc_reltn_id=request->priv_loc_reltn_id)
    AND p.privilege_cd IN (view_priv_cd, updt_priv_cd))
  DETAIL
   IF (p.privilege_cd=view_priv_cd)
    curr_view_priv_id = p.privilege_id, curr_view_priv_value_cd = p.priv_value_cd
   ELSE
    curr_updt_priv_id = p.privilege_id, curr_updt_priv_value_cd = p.priv_value_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (curr_updt_priv_value_cd != curr_view_priv_value_cd)
  IF (curr_updt_priv_value_cd != no_code_value)
   SET error_flag = "Y"
   SET error_msg = "View and Update privs are out of synch, cannot process."
   GO TO exit_script
  ENDIF
 ENDIF
 IF (curr_view_priv_value_cd=yes_code_value)
  SET curr_view_priv_value = "YES"
 ELSEIF (curr_view_priv_value_cd=no_code_value)
  SET curr_view_priv_value = "NO"
 ELSEIF (curr_view_priv_value_cd=inc_code_value)
  SET curr_view_priv_value = "INCLUDE"
 ELSEIF (curr_view_priv_value_cd=exc_code_value)
  SET curr_view_priv_value = "EXCLUDE"
 ELSE
  SET error_flag = "Y"
  SET error_msg = "Current view priv value is invalid, cannot process."
  GO TO exit_script
 ENDIF
 IF (curr_updt_priv_value_cd=yes_code_value)
  SET curr_updt_priv_value = "YES"
 ELSEIF (curr_updt_priv_value_cd=no_code_value)
  SET curr_updt_priv_value = "NO"
 ELSEIF (curr_updt_priv_value_cd=inc_code_value)
  SET curr_updt_priv_value = "INCLUDE"
 ELSEIF (curr_updt_priv_value_cd=exc_code_value)
  SET curr_updt_priv_value = "EXCLUDE"
 ELSE
  SET error_flag = "Y"
  SET error_msg = "Current view priv value is invalid, cannot process."
  GO TO exit_script
 ENDIF
 IF ((curr_updt_priv_value=request->updt_priv_value_mean)
  AND (curr_view_priv_value=request->view_priv_value_mean))
  IF (curr_view_priv_value IN ("YES", "NO")
   AND curr_updt_priv_value IN ("YES", "NO"))
   GO TO exit_script
  ELSE
   GO TO exceptions
  ENDIF
 ENDIF
 IF ((request->view_priv_value_mean="YES"))
  IF (curr_view_priv_id > 0)
   CALL logprivilegedelete(curr_view_priv_id)
   DELETE  FROM privilege_exception pe
    WHERE pe.privilege_id=curr_view_priv_id
    WITH nocounter
   ;end delete
   DELETE  FROM privilege p
    WHERE p.privilege_id=curr_view_priv_id
    WITH nocounter
   ;end delete
  ENDIF
 ENDIF
 IF ((request->updt_priv_value_mean="YES"))
  IF (curr_updt_priv_id > 0)
   CALL logprivilegedelete(curr_updt_priv_id)
   DELETE  FROM privilege_exception pe
    WHERE pe.privilege_id=curr_updt_priv_id
    WITH nocounter
   ;end delete
   DELETE  FROM privilege p
    WHERE p.privilege_id=curr_updt_priv_id
    WITH nocounter
   ;end delete
  ENDIF
 ENDIF
 IF ((request->view_priv_value_mean="NO"))
  IF (curr_view_priv_id > 0)
   CALL logprivilegedelete(curr_view_priv_id)
   DELETE  FROM privilege_exception pe
    WHERE pe.privilege_id=curr_view_priv_id
    WITH nocounter
   ;end delete
   UPDATE  FROM privilege p
    SET p.priv_value_cd = no_code_value, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id =
     reqinfo->updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->
     updt_applctx
    WHERE p.privilege_id=curr_view_priv_id
    WITH nocounter
   ;end update
  ELSE
   INSERT  FROM privilege priv
    SET priv.privilege_id = seq(reference_seq,nextval), priv.priv_loc_reltn_id = request->
     priv_loc_reltn_id, priv.privilege_cd = view_priv_cd,
     priv.priv_value_cd = no_code_value, priv.active_ind = 1, priv.active_status_cd =
     active_code_value,
     priv.active_status_dt_tm = cnvtdatetime(curdate,curtime3), priv.active_status_prsnl_id = reqinfo
     ->updt_id, priv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     priv.updt_id = reqinfo->updt_id, priv.updt_task = reqinfo->updt_task, priv.updt_cnt = 0,
     priv.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 IF ((request->updt_priv_value_mean="NO"))
  IF (curr_updt_priv_id > 0)
   CALL logprivilegedelete(curr_updt_priv_id)
   DELETE  FROM privilege_exception pe
    WHERE pe.privilege_id=curr_updt_priv_id
    WITH nocounter
   ;end delete
   UPDATE  FROM privilege p
    SET p.priv_value_cd = no_code_value, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id =
     reqinfo->updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->
     updt_applctx
    WHERE p.privilege_id=curr_updt_priv_id
    WITH nocounter
   ;end update
  ELSE
   INSERT  FROM privilege priv
    SET priv.privilege_id = seq(reference_seq,nextval), priv.priv_loc_reltn_id = request->
     priv_loc_reltn_id, priv.privilege_cd = updt_priv_cd,
     priv.priv_value_cd = no_code_value, priv.active_ind = 1, priv.active_status_cd =
     active_code_value,
     priv.active_status_dt_tm = cnvtdatetime(curdate,curtime3), priv.active_status_prsnl_id = reqinfo
     ->updt_id, priv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     priv.updt_id = reqinfo->updt_id, priv.updt_task = reqinfo->updt_task, priv.updt_cnt = 0,
     priv.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 IF ((request->view_priv_value_mean="INCLUDE"))
  IF (curr_view_priv_id > 0)
   CALL logprivilegedelete(curr_view_priv_id)
   DELETE  FROM privilege_exception pe
    WHERE pe.privilege_id=curr_view_priv_id
    WITH nocounter
   ;end delete
   UPDATE  FROM privilege p
    SET p.priv_value_cd = inc_code_value, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id =
     reqinfo->updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->
     updt_applctx
    WHERE p.privilege_id=curr_view_priv_id
    WITH nocounter
   ;end update
  ELSE
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     curr_view_priv_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM privilege priv
    SET priv.privilege_id = curr_view_priv_id, priv.priv_loc_reltn_id = request->priv_loc_reltn_id,
     priv.privilege_cd = view_priv_cd,
     priv.priv_value_cd = inc_code_value, priv.active_ind = 1, priv.active_status_cd =
     active_code_value,
     priv.active_status_dt_tm = cnvtdatetime(curdate,curtime3), priv.active_status_prsnl_id = reqinfo
     ->updt_id, priv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     priv.updt_id = reqinfo->updt_id, priv.updt_task = reqinfo->updt_task, priv.updt_cnt = 0,
     priv.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 IF ((request->updt_priv_value_mean="INCLUDE"))
  IF (curr_updt_priv_id > 0)
   CALL logprivilegedelete(curr_updt_priv_id)
   DELETE  FROM privilege_exception pe
    WHERE pe.privilege_id=curr_updt_priv_id
    WITH nocounter
   ;end delete
   UPDATE  FROM privilege p
    SET p.priv_value_cd = inc_code_value, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id =
     reqinfo->updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->
     updt_applctx
    WHERE p.privilege_id=curr_updt_priv_id
    WITH nocounter
   ;end update
  ELSE
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     curr_updt_priv_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM privilege priv
    SET priv.privilege_id = curr_updt_priv_id, priv.priv_loc_reltn_id = request->priv_loc_reltn_id,
     priv.privilege_cd = updt_priv_cd,
     priv.priv_value_cd = inc_code_value, priv.active_ind = 1, priv.active_status_cd =
     active_code_value,
     priv.active_status_dt_tm = cnvtdatetime(curdate,curtime3), priv.active_status_prsnl_id = reqinfo
     ->updt_id, priv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     priv.updt_id = reqinfo->updt_id, priv.updt_task = reqinfo->updt_task, priv.updt_cnt = 0,
     priv.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 IF ((request->view_priv_value_mean="EXCLUDE"))
  IF (curr_view_priv_id > 0)
   CALL logprivilegedelete(curr_view_priv_id)
   DELETE  FROM privilege_exception pe
    WHERE pe.privilege_id=curr_view_priv_id
    WITH nocounter
   ;end delete
   UPDATE  FROM privilege p
    SET p.priv_value_cd = exc_code_value, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id =
     reqinfo->updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->
     updt_applctx
    WHERE p.privilege_id=curr_view_priv_id
    WITH nocounter
   ;end update
  ELSE
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     curr_view_priv_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM privilege priv
    SET priv.privilege_id = curr_view_priv_id, priv.priv_loc_reltn_id = request->priv_loc_reltn_id,
     priv.privilege_cd = view_priv_cd,
     priv.priv_value_cd = exc_code_value, priv.active_ind = 1, priv.active_status_cd =
     active_code_value,
     priv.active_status_dt_tm = cnvtdatetime(curdate,curtime3), priv.active_status_prsnl_id = reqinfo
     ->updt_id, priv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     priv.updt_id = reqinfo->updt_id, priv.updt_task = reqinfo->updt_task, priv.updt_cnt = 0,
     priv.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 IF ((request->updt_priv_value_mean="EXCLUDE"))
  IF (curr_updt_priv_id > 0)
   CALL logprivilegedelete(curr_updt_priv_id)
   DELETE  FROM privilege_exception pe
    WHERE pe.privilege_id=curr_updt_priv_id
    WITH nocounter
   ;end delete
   UPDATE  FROM privilege p
    SET p.priv_value_cd = exc_code_value, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id =
     reqinfo->updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->
     updt_applctx
    WHERE p.privilege_id=curr_updt_priv_id
    WITH nocounter
   ;end update
  ELSE
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     curr_updt_priv_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM privilege priv
    SET priv.privilege_id = curr_updt_priv_id, priv.priv_loc_reltn_id = request->priv_loc_reltn_id,
     priv.privilege_cd = updt_priv_cd,
     priv.priv_value_cd = exc_code_value, priv.active_ind = 1, priv.active_status_cd =
     active_code_value,
     priv.active_status_dt_tm = cnvtdatetime(curdate,curtime3), priv.active_status_prsnl_id = reqinfo
     ->updt_id, priv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     priv.updt_id = reqinfo->updt_id, priv.updt_task = reqinfo->updt_task, priv.updt_cnt = 0,
     priv.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
#exceptions
 IF (new_view_priv_value IN ("YES", "NO")
  AND new_updt_priv_value IN ("YES", "NO"))
  GO TO exit_script
 ENDIF
 SET ecnt = size(request->elist,5)
 IF (ecnt=0)
  SET error_flag = "Y"
  SET error_msg = "INCLUDE or EXCLUDE must have exceptions passed in."
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO ecnt)
   IF ((request->elist[x].action_flag=3))
    CALL logprivilegedelete(curr_view_priv_id)
    DELETE  FROM privilege_exception pe
     WHERE (pe.exception_id=request->elist[x].exception_id)
      AND (pe.exception_entity_name=request->elist[x].exception_entity_name)
      AND pe.privilege_id=curr_view_priv_id
     WITH nocounter
    ;end delete
    CALL logprivilegedelete(curr_updt_priv_id)
    DELETE  FROM privilege_exception pe
     WHERE (pe.exception_id=request->elist[x].exception_id)
      AND (pe.exception_entity_name=request->elist[x].exception_entity_name)
      AND pe.privilege_id=curr_updt_priv_id
     WITH nocounter
    ;end delete
   ELSEIF ((request->elist[x].action_flag=1))
    IF (new_view_priv_value IN ("INCLUDE", "EXCLUDE"))
     INSERT  FROM privilege_exception pe
      SET pe.privilege_exception_id = seq(reference_seq,nextval), pe.privilege_id = curr_view_priv_id,
       pe.exception_id = request->elist[x].exception_id,
       pe.exception_type_cd =
       (SELECT
        cv.code_value
        FROM code_value cv
        WHERE cv.code_set=6015
         AND cv.cdf_meaning=substring(1,12,trim(cnvtupper(request->elist[x].exception_entity_name)))
         AND cv.active_ind=1), pe.exception_entity_name = request->elist[x].exception_entity_name, pe
       .active_ind = 1,
       pe.active_status_cd = active_code_value, pe.active_status_dt_tm = cnvtdatetime(curdate,curtime
        ), pe.active_status_prsnl_id = reqinfo->updt_id,
       pe.updt_dt_tm = cnvtdatetime(curdate,curtime), pe.updt_id = reqinfo->updt_id, pe.updt_task =
       reqinfo->updt_task,
       pe.updt_cnt = 0, pe.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
    IF (new_updt_priv_value IN ("INCLUDE", "EXCLUDE"))
     INSERT  FROM privilege_exception pe
      SET pe.privilege_exception_id = seq(reference_seq,nextval), pe.privilege_id = curr_updt_priv_id,
       pe.exception_id = request->elist[x].exception_id,
       pe.exception_type_cd =
       (SELECT
        cv.code_value
        FROM code_value cv
        WHERE cv.code_set=6015
         AND cv.cdf_meaning=substring(1,12,trim(cnvtupper(request->elist[x].exception_entity_name)))
         AND cv.active_ind=1), pe.exception_entity_name = request->elist[x].exception_entity_name, pe
       .active_ind = 1,
       pe.active_status_cd = active_code_value, pe.active_status_dt_tm = cnvtdatetime(curdate,curtime
        ), pe.active_status_prsnl_id = reqinfo->updt_id,
       pe.updt_dt_tm = cnvtdatetime(curdate,curtime), pe.updt_id = reqinfo->updt_id, pe.updt_task =
       reqinfo->updt_task,
       pe.updt_cnt = 0, pe.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE logprivilegedelete(priv_id)
   IF (((priv_id=curr_view_priv_id
    AND hasloggedviewdelete=0) OR (priv_id=curr_updt_priv_id
    AND hasloggedupdatedelete=0)) )
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
    IF (priv_id=curr_view_priv_id)
     SET hasloggedviewdelete = 1
    ENDIF
    IF (priv_id=curr_updt_priv_id)
     SET hasloggedupdatedelete = 1
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
