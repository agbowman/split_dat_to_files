CREATE PROGRAM bed_ens_organization_group:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 repqual[*]
      2 org_set_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET orgs
 RECORD orgs(
   1 orglist[*]
     2 org_id = f8
 )
 FREE SET prs
 RECORD prs(
   1 plist[*]
     2 prsnl_id = f8
 )
 FREE SET prs2
 RECORD prs2(
   1 plist[*]
     2 prsnl_id = f8
     2 del_ind = i2
 )
 DECLARE ocnt = i4
 DECLARE pcnt = i4
 DECLARE routclin_cd = f8
 DECLARE new_nbr = f8
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET orgcnt = 0
 SET active_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning="ACTIVE")
  DETAIL
   active_cd = c.code_value
  WITH nocounter
 ;end select
 SET deleted_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning="DELETED")
  DETAIL
   deleted_cd = c.code_value
  WITH nocounter
 ;end select
 SET security_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=28881
    AND c.cdf_meaning="SECURITY")
  DETAIL
   security_cd = c.code_value
  WITH nocounter
 ;end select
 SET routclin_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=87
    AND c.cdf_meaning="ROUTCLINICAL"
    AND c.active_ind=1)
  DETAIL
   routclin_cd = c.code_value
  WITH nocounter
 ;end select
 SET orgcnt = size(request->reqqual,5)
 SET stat = alterlist(reply->repqual,orgcnt)
 FOR (j = 1 TO orgcnt)
  IF ((request->reqqual[j].action_flag=1))
   SET new_org_set_id = 0.0
   SELECT INTO "nl:"
    y = seq(organization_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_org_set_id = cnvtreal(y)
    WITH format, counter
   ;end select
   SET request->reqqual[j].org_set_id = new_org_set_id
   INSERT  FROM org_set os
    SET os.org_set_id = new_org_set_id, os.name = request->reqqual[j].name, os.description = request
     ->reqqual[j].desc,
     os.active_ind = 1, os.active_status_cd = active_cd, os.active_status_dt_tm = cnvtdatetime(
      curdate,curtime),
     os.active_status_prsnl_id = reqinfo->updt_id, os.beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime), os.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
     os.updt_dt_tm = cnvtdatetime(curdate,curtime), os.updt_applctx = reqinfo->updt_applctx, os
     .updt_id = reqinfo->updt_id,
     os.updt_cnt = 0, os.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   SET reply->repqual[j].org_set_id = new_org_set_id
   SET new_org_set_r_id = 0.0
   SELECT INTO "nl:"
    y = seq(organization_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_org_set_r_id = cnvtreal(y)
    WITH format, counter
   ;end select
   INSERT  FROM org_set_type_r ostr
    SET ostr.org_set_type_r_id = new_org_set_r_id, ostr.org_set_id = new_org_set_id, ostr
     .org_set_type_cd = security_cd,
     ostr.active_ind = 1, ostr.active_status_cd = active_cd, ostr.active_status_dt_tm = cnvtdatetime(
      curdate,curtime),
     ostr.active_status_prsnl_id = reqinfo->updt_id, ostr.beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime), ostr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
     ostr.updt_dt_tm = cnvtdatetime(curdate,curtime), ostr.updt_applctx = reqinfo->updt_applctx, ostr
     .updt_id = reqinfo->updt_id,
     ostr.updt_cnt = 0, ostr.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
  ELSEIF ((request->reqqual[j].action_flag=2))
   UPDATE  FROM org_set os
    SET os.name = request->reqqual[j].name, os.description = request->reqqual[j].desc, os.updt_dt_tm
      = cnvtdatetime(curdate,curtime),
     os.updt_applctx = reqinfo->updt_applctx, os.updt_id = reqinfo->updt_id, os.updt_cnt = (os
     .updt_cnt+ 1),
     os.updt_task = reqinfo->updt_task
    WHERE (os.org_set_id=request->reqqual[j].org_set_id)
    WITH nocounter
   ;end update
   SET reply->repqual[j].org_set_id = request->reqqual[j].org_set_id
  ELSEIF ((request->reqqual[j].action_flag=3))
   UPDATE  FROM org_set os
    SET os.active_ind = 0, os.end_effective_dt_tm = cnvtdatetime(curdate,curtime), os.updt_dt_tm =
     cnvtdatetime(curdate,curtime),
     os.updt_applctx = reqinfo->updt_applctx, os.updt_id = reqinfo->updt_id, os.updt_cnt = (os
     .updt_cnt+ 1),
     os.updt_task = reqinfo->updt_task
    WHERE (os.org_set_id=request->reqqual[j].org_set_id)
    WITH nocounter
   ;end update
   UPDATE  FROM org_set_type_r ostr
    SET ostr.active_ind = 0, ostr.end_effective_dt_tm = cnvtdatetime(curdate,curtime), ostr
     .updt_dt_tm = cnvtdatetime(curdate,curtime),
     ostr.updt_applctx = reqinfo->updt_applctx, ostr.updt_id = reqinfo->updt_id, ostr.updt_cnt = (
     ostr.updt_cnt+ 1),
     ostr.updt_task = reqinfo->updt_task
    WHERE (ostr.org_set_id=request->reqqual[j].org_set_id)
    WITH nocounter
   ;end update
   SET ocnt = 0
   SELECT INTO "nl:"
    FROM org_set_org_r osor
    PLAN (osor
     WHERE (osor.org_set_id=request->reqqual[j].org_set_id))
    DETAIL
     ocnt = (ocnt+ 1), stat = alterlist(orgs->orglist,ocnt), orgs->orglist[ocnt].org_id = osor
     .organization_id
    WITH nocounter
   ;end select
   UPDATE  FROM org_set_org_r osor
    SET osor.active_ind = 0, osor.end_effective_dt_tm = cnvtdatetime(curdate,curtime), osor
     .updt_dt_tm = cnvtdatetime(curdate,curtime),
     osor.updt_applctx = reqinfo->updt_applctx, osor.updt_id = reqinfo->updt_id, osor.updt_cnt = (
     osor.updt_cnt+ 1),
     osor.updt_task = reqinfo->updt_task
    WHERE (osor.org_set_id=request->reqqual[j].org_set_id)
    WITH nocounter
   ;end update
   UPDATE  FROM org_set_prsnl_r ospr
    SET ospr.active_ind = 0, ospr.end_effective_dt_tm = cnvtdatetime(curdate,curtime), ospr
     .updt_dt_tm = cnvtdatetime(curdate,curtime),
     ospr.updt_applctx = reqinfo->updt_applctx, ospr.updt_id = reqinfo->updt_id, ospr.updt_cnt = (
     ospr.updt_cnt+ 1),
     ospr.updt_task = reqinfo->updt_task
    WHERE (ospr.org_set_id=request->reqqual[j].org_set_id)
    WITH nocounter
   ;end update
   FOR (ii = 1 TO ocnt)
     SET stat = initrec(prs2)
     SET ptcnt = 0
     SELECT INTO "nl:"
      FROM org_set_prsnl_r ospr
      PLAN (ospr
       WHERE (ospr.org_set_id=request->reqqual[j].org_set_id))
      DETAIL
       ptcnt = (ptcnt+ 1), stat = alterlist(prs2->plist,ptcnt), prs2->plist[ptcnt].prsnl_id = ospr
       .prsnl_id,
       prs2->plist[ptcnt].del_ind = 1
      WITH nocounter
     ;end select
     IF (ptcnt > 0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(ptcnt)),
        org_set_prsnl_r ospr,
        org_set_org_r osor
       PLAN (d)
        JOIN (ospr
        WHERE (ospr.prsnl_id=prs2->plist[d.seq].prsnl_id)
         AND (ospr.org_set_id != request->reqqual[j].org_set_id)
         AND ospr.active_ind=1
         AND ospr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
         AND ospr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
        JOIN (osor
        WHERE osor.org_set_id=ospr.org_set_id
         AND (osor.organization_id=orgs->orglist[ii].org_id)
         AND osor.active_ind=1
         AND osor.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
         AND osor.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       ORDER BY d.seq
       DETAIL
        prs2->plist[d.seq].del_ind = 0
       WITH nocounter
      ;end select
      UPDATE  FROM prsnl_org_reltn por,
        (dummyt d  WITH seq = value(ptcnt))
       SET por.active_ind = 0, por.end_effective_dt_tm = cnvtdatetime(curdate,curtime), por
        .updt_dt_tm = cnvtdatetime(curdate,curtime),
        por.updt_applctx = reqinfo->updt_applctx, por.updt_id = reqinfo->updt_id, por.updt_cnt = (por
        .updt_cnt+ 1),
        por.updt_task = reqinfo->updt_task
       PLAN (d
        WHERE (prs2->plist[d.seq].del_ind=1))
        JOIN (por
        WHERE (por.organization_id=orgs->orglist[ii].org_id)
         AND (por.person_id=prs2->plist[d.seq].prsnl_id)
         AND por.active_ind=1
         AND por.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
         AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       WITH nocounter
      ;end update
     ENDIF
   ENDFOR
   SET reply->repqual[j].org_set_id = request->reqqual[j].org_set_id
  ENDIF
  IF ((request->reqqual[j].action_flag != 3))
   SET ocnt = 0
   SET ocnt = size(request->reqqual[j].org,5)
   FOR (x = 1 TO ocnt)
     IF ((request->reqqual[j].org[x].action_flag=1))
      SET stat = add_reltn(j,x)
     ELSEIF ((request->reqqual[j].org[x].action_flag=3))
      SET stat = del_reltn(j,x)
     ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 SUBROUTINE add_reltn(j,x)
   SET new_org_set_org_r_id = 0.0
   SELECT INTO "nl:"
    y = seq(organization_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_org_set_org_r_id = cnvtreal(y)
    WITH format, counter
   ;end select
   INSERT  FROM org_set_org_r osor
    SET osor.org_set_org_r_id = new_org_set_org_r_id, osor.org_set_id = request->reqqual[j].
     org_set_id, osor.organization_id = request->reqqual[j].org[x].organization_id,
     osor.active_ind = 1, osor.active_status_cd = active_cd, osor.active_status_dt_tm = cnvtdatetime(
      curdate,curtime),
     osor.active_status_prsnl_id = reqinfo->updt_id, osor.beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime), osor.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
     osor.updt_dt_tm = cnvtdatetime(curdate,curtime), osor.updt_applctx = reqinfo->updt_applctx, osor
     .updt_id = reqinfo->updt_id,
     osor.updt_cnt = 0, osor.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   SET pcnt = 0
   SELECT INTO "nl:"
    FROM org_set_prsnl_r ospr
    PLAN (ospr
     WHERE (ospr.org_set_id=request->reqqual[j].org_set_id)
      AND ospr.active_ind=1
      AND ospr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ospr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     pcnt = (pcnt+ 1), stat = alterlist(prs->plist,pcnt), prs->plist[pcnt].prsnl_id = ospr.prsnl_id
    WITH nocounter
   ;end select
   IF (pcnt > 0)
    FOR (kk = 1 TO pcnt)
      SET pfound = 0
      SELECT INTO "nl:"
       FROM prsnl_org_reltn por
       PLAN (por
        WHERE (por.person_id=prs->plist[kk].prsnl_id)
         AND (por.organization_id=request->reqqual[j].org[x].organization_id)
         AND por.active_ind=1
         AND por.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
         AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       DETAIL
        pfound = 1
       WITH nocounter
      ;end select
      IF (pfound=0)
       SET ld_match = 0
       SELECT INTO "nl:"
        FROM prsnl p,
         organization o
        PLAN (p
         WHERE (p.person_id=prs->plist[kk].prsnl_id))
         JOIN (o
         WHERE (o.organization_id=request->reqqual[j].org[x].organization_id)
          AND p.logical_domain_id=o.logical_domain_id)
        DETAIL
         ld_match = 1
        WITH nocounter
       ;end select
       IF (ld_match=1)
        SET new_nbr = 0.0
        SELECT INTO "nl:"
         y = seq(prsnl_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          new_nbr = cnvtreal(y)
         WITH format, counter
        ;end select
        INSERT  FROM prsnl_org_reltn por
         SET por.prsnl_org_reltn_id = new_nbr, por.person_id = prs->plist[kk].prsnl_id, por
          .organization_id = request->reqqual[j].org[x].organization_id,
          por.updt_cnt = 0, por.updt_dt_tm = cnvtdatetime(curdate,curtime), por.updt_id = reqinfo->
          updt_id,
          por.updt_task = reqinfo->updt_task, por.updt_applctx = reqinfo->updt_applctx, por
          .active_ind = 1,
          por.active_status_cd = active_cd, por.active_status_dt_tm = cnvtdatetime(curdate,curtime),
          por.active_status_prsnl_id = reqinfo->updt_id,
          por.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), por.end_effective_dt_tm =
          cnvtdatetime("31-DEC-2100 00:00:00.00"), por.confid_level_cd = routclin_cd
         WITH nocounter
        ;end insert
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_reltn(j,x)
   UPDATE  FROM org_set_org_r osor
    SET osor.active_ind = 0, osor.end_effective_dt_tm = cnvtdatetime(curdate,curtime), osor
     .updt_dt_tm = cnvtdatetime(curdate,curtime),
     osor.updt_applctx = reqinfo->updt_applctx, osor.updt_id = reqinfo->updt_id, osor.updt_cnt = (
     osor.updt_cnt+ 1),
     osor.updt_task = reqinfo->updt_task
    WHERE (osor.org_set_id=request->reqqual[j].org_set_id)
     AND (osor.organization_id=request->reqqual[j].org[x].organization_id)
    WITH nocounter
   ;end update
   SET stat = initrec(prs2)
   SET ptcnt = 0
   SELECT INTO "nl:"
    FROM org_set_prsnl_r ospr
    PLAN (ospr
     WHERE (ospr.org_set_id=request->reqqual[j].org_set_id)
      AND ospr.active_ind=1
      AND ospr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND ospr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     ptcnt = (ptcnt+ 1), stat = alterlist(prs2->plist,ptcnt), prs2->plist[ptcnt].prsnl_id = ospr
     .prsnl_id,
     prs2->plist[ptcnt].del_ind = 1
    WITH nocounter
   ;end select
   IF (ptcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(ptcnt)),
      org_set_prsnl_r ospr,
      org_set_org_r osor
     PLAN (d)
      JOIN (ospr
      WHERE (ospr.prsnl_id=prs2->plist[d.seq].prsnl_id)
       AND (ospr.org_set_id != request->reqqual[j].org_set_id)
       AND ospr.active_ind=1
       AND ospr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND ospr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (osor
      WHERE osor.org_set_id=ospr.org_set_id
       AND (osor.organization_id=request->reqqual[j].org[x].organization_id)
       AND osor.active_ind=1
       AND osor.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND osor.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     ORDER BY d.seq
     DETAIL
      prs2->plist[d.seq].del_ind = 0
     WITH nocounter
    ;end select
    UPDATE  FROM prsnl_org_reltn por,
      (dummyt d  WITH seq = value(ptcnt))
     SET por.active_ind = 0, por.end_effective_dt_tm = cnvtdatetime(curdate,curtime), por.updt_dt_tm
       = cnvtdatetime(curdate,curtime),
      por.updt_applctx = reqinfo->updt_applctx, por.updt_id = reqinfo->updt_id, por.updt_cnt = (por
      .updt_cnt+ 1),
      por.updt_task = reqinfo->updt_task
     PLAN (d
      WHERE (prs2->plist[d.seq].del_ind=1))
      JOIN (por
      WHERE (por.organization_id=request->reqqual[j].org[x].organization_id)
       AND (por.person_id=prs2->plist[d.seq].prsnl_id)
       AND por.active_ind=1
       AND por.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     WITH nocounter
    ;end update
   ENDIF
   RETURN(1.0)
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
