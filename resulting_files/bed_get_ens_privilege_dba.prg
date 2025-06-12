CREATE PROGRAM bed_get_ens_privilege:dba
 FREE SET reply
 RECORD reply(
   1 pvlist[*]
     2 privilege_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET yes_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6017
   AND cv.cdf_meaning="YES"
   AND cv.active_ind=1
  DETAIL
   yes_cd = cv.code_value
  WITH nocounter
 ;end select
 SET no_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6017
   AND cv.cdf_meaning="NO"
   AND cv.active_ind=1
  DETAIL
   no_cd = cv.code_value
  WITH nocounter
 ;end select
 SET include_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6017
   AND cv.cdf_meaning="INCLUDE"
   AND cv.active_ind=1
  DETAIL
   include_cd = cv.code_value
  WITH nocounter
 ;end select
 SET exclude_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6017
   AND cv.cdf_meaning="EXCLUDE"
   AND cv.active_ind=1
  DETAIL
   exclude_cd = cv.code_value
  WITH nocounter
 ;end select
 SET active_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SET listcount = 0
 SET listcount = size(request->pvlist,5)
 SET stat = alterlist(reply->pvlist,listcount)
 FOR (lvar = 1 TO listcount)
   SET reply->pvlist[lvar].privilege_id = 0.0
   SET priv_cd = 0.0
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.code_set=6016
     AND (cv.cdf_meaning=request->pvlist[lvar].priv_cdf_meaning)
     AND cv.active_ind=1
    DETAIL
     priv_cd = cv.code_value
    WITH nocounter
   ;end select
   SET priv_loc_reltn_id = 0.0
   SELECT INTO "NL:"
    FROM priv_loc_reltn plr
    WHERE (plr.person_id=request->pvlist[lvar].person_id)
     AND (plr.position_cd=request->pvlist[lvar].position_cd)
     AND (plr.ppr_cd=request->pvlist[lvar].ppr_cd)
     AND (plr.location_cd=request->pvlist[lvar].location_cd)
     AND plr.active_ind=1
    DETAIL
     priv_loc_reltn_id = plr.priv_loc_reltn_id
    WITH nocounter
   ;end select
   IF ((request->pvlist[lvar].action_flag="0"))
    IF (priv_loc_reltn_id > 0)
     SELECT INTO "NL:"
      FROM privilege p
      WHERE p.priv_loc_reltn_id=priv_loc_reltn_id
       AND p.privilege_cd=priv_cd
       AND p.active_ind=1
       AND p.priv_value_cd=no_cd
      DETAIL
       reply->pvlist[lvar].privilege_id = p.privilege_id
      WITH nocounter
     ;end select
    ENDIF
   ELSEIF ((request->pvlist[lvar].action_flag="1"))
    IF (priv_loc_reltn_id=0.0)
     SELECT INTO "nl:"
      z = seq(reference_seq,nextval)
      FROM dual
      DETAIL
       priv_loc_reltn_id = cnvtreal(z)
      WITH format, nocounter
     ;end select
     INSERT  FROM priv_loc_reltn plr
      SET plr.priv_loc_reltn_id = priv_loc_reltn_id, plr.person_id = request->pvlist[lvar].person_id,
       plr.position_cd = request->pvlist[lvar].position_cd,
       plr.ppr_cd = request->pvlist[lvar].ppr_cd, plr.location_cd = request->pvlist[lvar].location_cd,
       plr.updt_cnt = 0,
       plr.updt_dt_tm = cnvtdatetime(curdate,curtime), plr.updt_id = reqinfo->updt_id, plr.updt_task
        = reqinfo->updt_task,
       plr.updt_applctx = reqinfo->updt_applctx, plr.active_ind = 1, plr.active_status_cd = active_cd,
       plr.active_status_dt_tm = cnvtdatetime(curdate,curtime), plr.active_status_prsnl_id = reqinfo
       ->updt_id, plr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
       plr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
      WITH nocounter
     ;end insert
    ENDIF
    SET next_privilege_id = 0.0
    IF ((request->pvlist[lvar].priv_value="YES"))
     SET priv_value_cd = yes_cd
    ELSEIF ((request->pvlist[lvar].priv_value="NO"))
     SET priv_value_cd = no_cd
    ELSEIF ((request->pvlist[lvar].priv_value="INCLUDE"))
     SET priv_value_cd = include_cd
    ELSEIF ((request->pvlist[lvar].priv_value="EXCLUDE"))
     SET priv_value_cd = exclude_cd
    ENDIF
    SELECT INTO "nl:"
     z = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      next_privilege_id = cnvtreal(z)
     WITH format, nocounter
    ;end select
    INSERT  FROM privilege p
     SET p.privilege_id = next_privilege_id, p.priv_loc_reltn_id = priv_loc_reltn_id, p.privilege_cd
       = priv_cd,
      p.priv_value_cd = priv_value_cd, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime),
      p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
      updt_applctx,
      p.active_ind = 1, p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,
       curtime),
      p.active_status_prsnl_id = reqinfo->updt_id, p.restr_method_cd = 0.0
     WITH nocounter
    ;end insert
    SET reply->pvlist[lvar].privilege_id = next_privilege_id
   ELSEIF ((request->pvlist[lvar].action_flag="3"))
    DELETE  FROM privilege p
     WHERE p.priv_loc_reltn_id=priv_loc_reltn_id
      AND p.privilege_cd=priv_cd
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
END GO
