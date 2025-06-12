CREATE PROGRAM bed_ens_rel_prsnl_org:dba
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
   1 person_list[*]
     2 person_id = f8
     2 person_name = vc
     2 action_flag = i2
     2 org_id = f8
     2 org_name = vc
     2 confid_level_code_value = f8
     2 confid_level_display = vc
     2 org_set_id = f8
     2 org_set_name = vc
 )
 FREE SET orgs
 RECORD orgs(
   1 orglist[*]
     2 org_id = f8
     2 org_name = vc
     2 confid_level_code_value = f8
     2 confid_level_display = vc
 )
 FREE SET orgsets
 RECORD orgsets(
   1 orgsetlist[*]
     2 org_set_id = f8
     2 org_set_name = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 DECLARE orgcnt = i4
 DECLARE orgsetcnt = i4
 DECLARE personcnt = i4
 DECLARE def_confid_cd = f8
 DECLARE add_flag = i4
 DECLARE inactive_cd = f8
 DECLARE osprid = f8
 DECLARE error_flag = vc
 DECLARE new_nbr = i4
 DECLARE active_cd = f8
 DECLARE rcnt = i4
 DECLARE type_code_value = f8
 DECLARE org_group_reltn_id = f8
 DECLARE confid_change = f8
 SET error_flag = "N"
 SET new_nbr = 0
 SET orgcnt = 0
 SET orgsetcnt = 0
 SET personcnt = 0
 SET add_flag = 0
 SET rcnt = 0
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
 SET inactive_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="INACTIVE"
   AND cv.active_ind=1
  DETAIL
   inactive_cd = cv.code_value
  WITH nocounter
 ;end select
 SET def_confid_cd = 0.0
 DECLARE def_confid_display = vc
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.cdf_meaning="ROUTCLINICAL"
    AND c.code_set=87
    AND c.active_ind=1)
  DETAIL
   def_confid_cd = c.code_value, def_confid_display = c.display
  WITH nocounter
 ;end select
 SET type_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=28881
   AND cv.active_ind=1
   AND cv.cdf_meaning="SECURITY"
  DETAIL
   type_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET org_group_reltn_id = 0
 SET personcnt = size(request->person_list,5)
 SET orgcnt = size(request->org_list,5)
 SET orgsetcnt = size(request->org_group_list,5)
 IF ((((request->person_list[1].person_id=0)) OR (personcnt=0)) )
  SET error_flag = "T"
  SET error_msg = "No personnel in request structure."
  GO TO exit_script
 ENDIF
 FREE SET temp1
 RECORD temp1(
   1 person_list[*]
     2 name = vc
 )
 FREE SET temp2
 RECORD temp2(
   1 org_list[*]
     2 name = vc
     2 confid_level_display = vc
 )
 FREE SET temp3
 RECORD temp3(
   1 org_group_list[*]
     2 name = vc
 )
 IF (personcnt > 0)
  SET stat = alterlist(temp1->person_list,personcnt)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(personcnt)),
    person p
   PLAN (d)
    JOIN (p
    WHERE (p.person_id=request->person_list[d.seq].person_id))
   DETAIL
    temp1->person_list[d.seq].name = p.name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
 IF (orgcnt > 0)
  SET stat = alterlist(temp2->org_list,orgcnt)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(orgcnt)),
    organization o,
    code_value cv
   PLAN (d)
    JOIN (o
    WHERE (o.organization_id=request->org_list[d.seq].org_id))
    JOIN (cv
    WHERE (cv.code_value=request->org_list[d.seq].confid_level_code_value))
   DETAIL
    temp2->org_list[d.seq].name = o.org_name, temp2->org_list[d.seq].confid_level_display = cv
    .display
   WITH nocounter
  ;end select
 ENDIF
 IF (orgsetcnt > 0)
  SET stat = alterlist(temp3->org_group_list,orgsetcnt)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(orgsetcnt)),
    org_set os
   PLAN (d)
    JOIN (os
    WHERE (os.org_set_id=request->org_group_list[d.seq].org_set_id))
   DETAIL
    temp3->org_group_list[d.seq].name = os.description
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->action_flag=1))
  SELECT INTO "nl:"
   FROM prsnl_org_reltn por,
    organization o,
    code_value cv
   PLAN (por
    WHERE (por.person_id=request->source_person_id)
     AND por.active_ind=1
     AND por.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=null
    )) )
    JOIN (o
    WHERE o.organization_id=por.organization_id)
    JOIN (cv
    WHERE cv.code_value=outerjoin(por.confid_level_cd)
     AND cv.active_ind=outerjoin(1))
   DETAIL
    orgcnt = (orgcnt+ 1), stat = alterlist(orgs->orglist,orgcnt), orgs->orglist[orgcnt].org_id = por
    .organization_id,
    orgs->orglist[orgcnt].confid_level_code_value = por.confid_level_cd, orgs->orglist[orgcnt].
    org_name = o.org_name, orgs->orglist[orgcnt].confid_level_display = cv.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM org_set_prsnl_r ospr,
    org_set os
   PLAN (ospr
    WHERE (ospr.prsnl_id=request->source_person_id)
     AND ospr.active_ind=1
     AND ospr.org_set_type_cd=type_code_value)
    JOIN (os
    WHERE os.org_set_id=ospr.org_set_id)
   DETAIL
    orgsetcnt = (orgsetcnt+ 1), stat = alterlist(orgsets->orgsetlist,orgsetcnt), orgsets->orgsetlist[
    orgsetcnt].org_set_id = ospr.org_set_id,
    orgsets->orgsetlist[orgsetcnt].org_set_name = os.description
   WITH nocounter
  ;end select
  IF (orgcnt > 0)
   FOR (x = 1 TO personcnt)
     FOR (y = 1 TO orgcnt)
      SELECT INTO "NL:"
       FROM prsnl_org_reltn por
       WHERE (por.person_id=request->person_list[x].person_id)
        AND (por.organization_id=orgs->orglist[y].org_id)
       WITH nocounter
      ;end select
      IF (curqual=0)
       INSERT  FROM prsnl_org_reltn por
        SET por.prsnl_org_reltn_id = seq(prsnl_seq,nextval), por.person_id = request->person_list[x].
         person_id, por.organization_id = orgs->orglist[y].org_id,
         por.confid_level_cd =
         IF ((orgs->orglist[y].confid_level_code_value > 0)) orgs->orglist[y].confid_level_code_value
         ELSE def_confid_cd
         ENDIF
         , por.updt_id = reqinfo->updt_id, por.updt_cnt = 0,
         por.updt_applctx = reqinfo->updt_applctx, por.updt_task = reqinfo->updt_task, por.updt_dt_tm
          = cnvtdatetime(curdate,curtime3),
         por.active_ind = 1, por.active_status_cd = active_cd, por.active_status_dt_tm = cnvtdatetime
         (curdate,curtime3),
         por.active_status_prsnl_id = 0, por.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
         por.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "T"
        SET error_msg = concat(error_msg,">>","Error inserting prsnl-org relationship for prsnl: ",
         cnvtstring(request->person_list[x].person_id),"  Org: ",
         cnvtstring(orgs->orglist[y].org_id),".")
        GO TO exit_script
       ENDIF
       SET rcnt = (rcnt+ 1)
       SET stat = alterlist(reply->person_list,rcnt)
       SET reply->person_list[rcnt].person_id = request->person_list[x].person_id
       SET reply->person_list[rcnt].person_name = temp1->person_list[x].name
       SET reply->person_list[rcnt].action_flag = 1
       SET reply->person_list[rcnt].org_id = orgs->orglist[y].org_id
       SET reply->person_list[rcnt].org_name = orgs->orglist[y].org_name
       IF ((orgs->orglist[y].confid_level_code_value > 0))
        SET reply->person_list[rcnt].confid_level_code_value = orgs->orglist[y].
        confid_level_code_value
        SET reply->person_list[rcnt].confid_level_display = orgs->orglist[y].confid_level_display
       ELSE
        SET reply->person_list[rcnt].confid_level_code_value = def_confid_cd
        SET reply->person_list[rcnt].confid_level_display = def_confid_display
       ENDIF
       SET reply->person_list[rcnt].org_set_id = 0
      ENDIF
     ENDFOR
   ENDFOR
  ENDIF
  IF (orgsetcnt > 0)
   FOR (x = 1 TO personcnt)
     FOR (z = 1 TO orgsetcnt)
      SELECT INTO "NL:"
       FROM org_set_prsnl_r ospr
       WHERE (ospr.prsnl_id=request->person_list[x].person_id)
        AND (ospr.org_set_id=orgsets->orgsetlist[z].org_set_id)
        AND ospr.org_set_type_cd=type_code_value
        AND ospr.active_ind=1
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET iacnt = 0
       SELECT INTO "NL:"
        FROM org_set_prsnl_r ospr
        PLAN (ospr
         WHERE (ospr.prsnl_id=request->person_list[x].person_id)
          AND (ospr.org_set_id=orgsets->orgsetlist[z].org_set_id)
          AND ospr.org_set_type_cd=type_code_value
          AND ospr.active_ind=0)
        DETAIL
         osprid = ospr.org_set_prsnl_r_id
        WITH nocounter
       ;end select
       IF (curqual=0)
        INSERT  FROM org_set_prsnl_r ospr
         SET ospr.org_set_prsnl_r_id = seq(organization_seq,nextval), ospr.org_set_id = orgsets->
          orgsetlist[z].org_set_id, ospr.prsnl_id = request->person_list[x].person_id,
          ospr.org_set_type_cd = type_code_value, ospr.updt_id = reqinfo->updt_id, ospr.updt_cnt = 0,
          ospr.updt_applctx = reqinfo->updt_applctx, ospr.updt_task = reqinfo->updt_task, ospr
          .updt_dt_tm = cnvtdatetime(curdate,curtime3),
          ospr.active_ind = 1, ospr.active_status_cd = active_cd, ospr.active_status_dt_tm =
          cnvtdatetime(curdate,curtime3),
          ospr.active_status_prsnl_id = 0, ospr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
          ospr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "T"
         SET error_msg = concat(error_msg,">>","Error adding org group for prsnl: ",cnvtstring(
           request->person_list[x].person_id)," Org Group: ",
          cnvtstring(orgsets->orgsetlist[z].org_set_id),".")
         GO TO exit_script
        ENDIF
        SET rcnt = (rcnt+ 1)
        SET stat = alterlist(reply->person_list,rcnt)
        SET reply->person_list[rcnt].person_id = request->person_list[x].person_id
        SET reply->person_list[rcnt].person_name = temp1->person_list[x].name
        SET reply->person_list[rcnt].action_flag = 1
        SET reply->person_list[rcnt].org_id = 0
        SET reply->person_list[rcnt].confid_level_code_value = 0
        SET reply->person_list[rcnt].org_set_id = orgsets->orgsetlist[z].org_set_id
        SET reply->person_list[rcnt].org_set_name = orgsets->orgsetlist[z].org_set_name
       ELSE
        UPDATE  FROM org_set_prsnl_r ospr
         SET ospr.updt_id = reqinfo->updt_id, ospr.updt_cnt = (ospr.updt_cnt+ 1), ospr.updt_applctx
           = reqinfo->updt_applctx,
          ospr.updt_task = reqinfo->updt_task, ospr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ospr
          .active_ind = 1,
          ospr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ospr.end_effective_dt_tm =
          cnvtdatetime("31-DEC-2100")
         WHERE ospr.org_set_prsnl_r_id=osprid
         WITH nocounter
        ;end update
        SET rcnt = (rcnt+ 1)
        SET stat = alterlist(reply->person_list,rcnt)
        SET reply->person_list[rcnt].person_id = request->person_list[x].person_id
        SET reply->person_list[rcnt].person_name = temp1->person_list[x].name
        SET reply->person_list[rcnt].action_flag = 1
        SET reply->person_list[rcnt].org_id = 0
        SET reply->person_list[rcnt].confid_level_code_value = 0
        SET reply->person_list[rcnt].org_set_id = orgsets->orgsetlist[z].org_set_id
        SET reply->person_list[rcnt].org_set_name = orgsets->orgsetlist[z].org_set_name
       ENDIF
      ENDIF
     ENDFOR
   ENDFOR
  ENDIF
 ENDIF
 IF ((request->action_flag=2))
  UPDATE  FROM (dummyt d  WITH seq = value(personcnt)),
    prsnl_org_reltn por
   SET por.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), por.updt_id = reqinfo->updt_id, por
    .updt_cnt = (por.updt_cnt+ 1),
    por.updt_applctx = reqinfo->updt_applctx, por.updt_task = reqinfo->updt_task, por.updt_dt_tm =
    cnvtdatetime(curdate,curtime3)
   PLAN (d)
    JOIN (por
    WHERE (por.person_id=request->person_list[d.seq].person_id))
   WITH nocounter
  ;end update
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(personcnt)),
    prsnl_org_reltn por,
    organization o
   PLAN (d)
    JOIN (por
    WHERE (por.person_id=request->person_list[d.seq].person_id))
    JOIN (o
    WHERE o.organization_id=por.organization_id)
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->person_list,rcnt), reply->person_list[rcnt].person_id
     = request->person_list[d.seq].person_id,
    reply->person_list[rcnt].person_name = temp1->person_list[d.seq].name, reply->person_list[rcnt].
    action_flag = 3, reply->person_list[rcnt].org_id = por.organization_id,
    reply->person_list[rcnt].org_name = o.org_name, reply->person_list[rcnt].confid_level_code_value
     = 0, reply->person_list[rcnt].org_set_id = 0
   WITH nocounter
  ;end select
  UPDATE  FROM (dummyt d  WITH seq = value(personcnt)),
    org_set_prsnl_r ospr
   SET ospr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), ospr.active_ind = 0, ospr.updt_id
     = reqinfo->updt_id,
    ospr.updt_cnt = (ospr.updt_cnt+ 1), ospr.updt_applctx = reqinfo->updt_applctx, ospr.updt_task =
    reqinfo->updt_task,
    ospr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d)
    JOIN (ospr
    WHERE (ospr.prsnl_id=request->person_list[d.seq].person_id))
   WITH nocounter
  ;end update
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(personcnt)),
    org_set_prsnl_r ospr,
    org_set os
   PLAN (d)
    JOIN (ospr
    WHERE (ospr.prsnl_id=request->person_list[d.seq].person_id))
    JOIN (os
    WHERE os.org_set_id=ospr.org_set_id)
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->person_list,rcnt), reply->person_list[rcnt].person_id
     = request->person_list[d.seq].person_id,
    reply->person_list[rcnt].person_name = temp1->person_list[d.seq].name, reply->person_list[rcnt].
    action_flag = 3, reply->person_list[rcnt].org_id = 0,
    reply->person_list[rcnt].confid_level_code_value = 0, reply->person_list[rcnt].org_set_id = ospr
    .org_set_id, reply->person_list[rcnt].org_set_name = os.description
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM prsnl_org_reltn por,
    organization o,
    code_value cv
   PLAN (por
    WHERE (por.person_id=request->source_person_id)
     AND por.active_ind=1
     AND por.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=null
    )) )
    JOIN (o
    WHERE o.organization_id=por.organization_id)
    JOIN (cv
    WHERE cv.code_value=outerjoin(por.confid_level_cd)
     AND cv.active_ind=outerjoin(1))
   DETAIL
    orgcnt = (orgcnt+ 1), stat = alterlist(orgs->orglist,orgcnt), orgs->orglist[orgcnt].org_id = por
    .organization_id,
    orgs->orglist[orgcnt].confid_level_code_value = por.confid_level_cd, orgs->orglist[orgcnt].
    org_name = o.org_name, orgs->orglist[orgcnt].confid_level_display = cv.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM org_set_prsnl_r ospr,
    org_set os
   PLAN (ospr
    WHERE (ospr.prsnl_id=request->source_person_id)
     AND ospr.active_ind=1
     AND ospr.org_set_type_cd=type_code_value)
    JOIN (os
    WHERE os.org_set_id=ospr.org_set_id)
   DETAIL
    orgsetcnt = (orgsetcnt+ 1), stat = alterlist(orgsets->orgsetlist,orgsetcnt), orgsets->orgsetlist[
    orgsetcnt].org_set_id = ospr.org_set_id,
    orgsets->orgsetlist[orgsetcnt].org_set_name = os.description
   WITH nocounter
  ;end select
  IF (orgcnt > 0)
   INSERT  FROM prsnl_org_reltn por,
     (dummyt d1  WITH seq = value(personcnt)),
     (dummyt d2  WITH seq = value(orgcnt))
    SET por.seq = 1, por.prsnl_org_reltn_id = seq(prsnl_seq,nextval), por.person_id = request->
     person_list[d1.seq].person_id,
     por.organization_id = orgs->orglist[d2.seq].org_id, por.confid_level_cd =
     IF ((orgs->orglist[d2.seq].confid_level_code_value > 0)) orgs->orglist[d2.seq].
      confid_level_code_value
     ELSE def_confid_cd
     ENDIF
     , por.updt_id = reqinfo->updt_id,
     por.updt_cnt = 0, por.updt_applctx = reqinfo->updt_applctx, por.updt_task = reqinfo->updt_task,
     por.updt_dt_tm = cnvtdatetime(curdate,curtime3), por.active_ind = 1, por.active_status_cd =
     active_cd,
     por.active_status_dt_tm = cnvtdatetime(curdate,curtime3), por.active_status_prsnl_id = 0, por
     .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     por.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    PLAN (d1)
     JOIN (d2)
     JOIN (por)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "T"
    SET error_mst = "Error inserting prsnl_org_reltn rows."
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(personcnt)),
     (dummyt d2  WITH seq = value(orgcnt))
    PLAN (d1)
     JOIN (d2)
    DETAIL
     rcnt = (rcnt+ 1), stat = alterlist(reply->person_list,rcnt), reply->person_list[rcnt].person_id
      = request->person_list[d1.seq].person_id,
     reply->person_list[rcnt].person_name = temp1->person_list[d1.seq].name, reply->person_list[rcnt]
     .action_flag = 1, reply->person_list[rcnt].org_id = orgs->orglist[d2.seq].org_id,
     reply->person_list[rcnt].org_name = orgs->orglist[d2.seq].org_name
     IF ((orgs->orglist[d2.seq].confid_level_code_value > 0))
      reply->person_list[rcnt].confid_level_code_value = orgs->orglist[d2.seq].
      confid_level_code_value, reply->person_list[rcnt].confid_level_display = orgs->orglist[d2.seq].
      confid_level_display
     ELSE
      reply->person_list[rcnt].confid_level_code_value = def_confid_cd, reply->person_list[rcnt].
      confid_level_display = def_confid_display
     ENDIF
     reply->person_list[rcnt].org_set_id = 0
    WITH nocounter
   ;end select
  ENDIF
  IF (orgsetcnt > 0)
   INSERT  FROM org_set_prsnl_r ospr,
     (dummyt d1  WITH seq = value(personcnt)),
     (dummyt d2  WITH seq = value(orgsetcnt))
    SET ospr.seq = 1, ospr.org_set_prsnl_r_id = seq(organization_seq,nextval), ospr.prsnl_id =
     request->person_list[d1.seq].person_id,
     ospr.org_set_id = orgsets->orgsetlist[d2.seq].org_set_id, ospr.org_set_type_cd = type_code_value,
     ospr.updt_id = reqinfo->updt_id,
     ospr.updt_cnt = 0, ospr.updt_applctx = reqinfo->updt_applctx, ospr.updt_task = reqinfo->
     updt_task,
     ospr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ospr.active_ind = 1, ospr.active_status_cd =
     active_cd,
     ospr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ospr.active_status_prsnl_id = 0, ospr
     .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     ospr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    PLAN (d1)
     JOIN (d2)
     JOIN (ospr)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = "Error inserting org_set_prsnl_r rows."
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(personcnt)),
     (dummyt d2  WITH seq = value(orgsetcnt))
    PLAN (d1)
     JOIN (d2)
    DETAIL
     rcnt = (rcnt+ 1), stat = alterlist(reply->person_list,rcnt), reply->person_list[rcnt].person_id
      = request->person_list[d1.seq].person_id,
     reply->person_list[rcnt].person_name = temp1->person_list[d1.seq].name, reply->person_list[rcnt]
     .action_flag = 1, reply->person_list[rcnt].org_id = 0,
     reply->person_list[rcnt].confid_level_code_value = 0, reply->person_list[rcnt].org_set_id =
     orgsets->orgsetlist[d2.seq].org_set_id, reply->person_list[rcnt].org_set_name = orgsets->
     orgsetlist[d2.seq].org_set_name
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((request->action_flag=3))
  SET personcnt = size(request->person_list,5)
  SET orgcnt = size(request->org_list,5)
  SET orgsetcnt = size(request->org_group_list,5)
  IF (personcnt > 0)
   FOR (ii = 1 TO personcnt)
    IF (orgcnt > 0)
     FOR (jj = 1 TO orgcnt)
       IF ((request->org_list[jj].org_action_flag IN (0, 1, 2)))
        SET confid_change = 0.0
        SELECT INTO "nl:"
         FROM prsnl_org_reltn por
         PLAN (por
          WHERE (por.person_id=request->person_list[ii].person_id)
           AND (por.organization_id=request->org_list[jj].org_id)
           AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
         DETAIL
          confid_change = por.confid_level_cd
         WITH nocounter
        ;end select
        IF (curqual=0)
         INSERT  FROM prsnl_org_reltn por
          SET por.prsnl_org_reltn_id = seq(prsnl_seq,nextval), por.person_id = request->person_list[
           ii].person_id, por.organization_id = request->org_list[jj].org_id,
           por.confid_level_cd = request->org_list[jj].confid_level_code_value, por.updt_id = reqinfo
           ->updt_id, por.updt_cnt = 0,
           por.updt_applctx = reqinfo->updt_applctx, por.updt_task = reqinfo->updt_task, por
           .updt_dt_tm = cnvtdatetime(curdate,curtime3),
           por.active_ind = 1, por.active_status_cd = active_cd, por.active_status_dt_tm =
           cnvtdatetime(curdate,curtime3),
           por.active_status_prsnl_id = reqinfo->updt_id, por.beg_effective_dt_tm = cnvtdatetime(
            curdate,curtime3), por.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
          WITH nocounter
         ;end insert
         SET rcnt = (rcnt+ 1)
         SET stat = alterlist(reply->person_list,rcnt)
         SET reply->person_list[rcnt].person_id = request->person_list[ii].person_id
         SET reply->person_list[rcnt].person_name = temp1->person_list[ii].name
         SET reply->person_list[rcnt].action_flag = 1
         SET reply->person_list[rcnt].org_id = request->org_list[jj].org_id
         SET reply->person_list[rcnt].org_name = temp2->org_list[jj].name
         SET reply->person_list[rcnt].confid_level_code_value = request->org_list[jj].
         confid_level_code_value
         SET reply->person_list[rcnt].confid_level_display = temp2->org_list[jj].confid_level_display
         SET reply->person_list[rcnt].org_set_id = 0
        ELSE
         IF ((confid_change != request->org_list[jj].confid_level_code_value))
          UPDATE  FROM prsnl_org_reltn por
           SET por.active_ind = 1, por.active_status_cd = active_cd, por.active_status_dt_tm =
            cnvtdatetime(curdate,curtime3),
            por.active_status_prsnl_id = reqinfo->updt_id, por.confid_level_cd = request->org_list[jj
            ].confid_level_code_value, por.updt_id = reqinfo->updt_id,
            por.updt_cnt = (por.updt_cnt+ 1), por.updt_applctx = reqinfo->updt_applctx, por.updt_task
             = reqinfo->updt_task,
            por.updt_dt_tm = cnvtdatetime(curdate,curtime3)
           WHERE (por.person_id=request->person_list[ii].person_id)
            AND (por.organization_id=request->org_list[jj].org_id)
           WITH nocounter
          ;end update
          SET rcnt = (rcnt+ 1)
          SET stat = alterlist(reply->person_list,rcnt)
          SET reply->person_list[rcnt].person_id = request->person_list[ii].person_id
          SET reply->person_list[rcnt].person_name = temp1->person_list[ii].name
          SET reply->person_list[rcnt].action_flag = 1
          SET reply->person_list[rcnt].org_id = request->org_list[jj].org_id
          SET reply->person_list[rcnt].org_name = temp2->org_list[jj].name
          SET reply->person_list[rcnt].confid_level_code_value = request->org_list[jj].
          confid_level_code_value
          SET reply->person_list[rcnt].confid_level_display = temp2->org_list[jj].
          confid_level_display
          SET reply->person_list[rcnt].org_set_id = 0
         ENDIF
        ENDIF
       ELSEIF ((request->org_list[jj].org_action_flag=3))
        SELECT INTO "nl:"
         FROM prsnl_org_reltn por
         PLAN (por
          WHERE (por.person_id=request->person_list[ii].person_id)
           AND (por.organization_id=request->org_list[jj].org_id))
         DETAIL
          add_flag = por.active_ind
         WITH nocounter
        ;end select
        IF (curqual > 0
         AND add_flag=1)
         UPDATE  FROM prsnl_org_reltn por
          SET por.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), por.updt_id = reqinfo->
           updt_id, por.updt_cnt = (por.updt_cnt+ 1),
           por.updt_applctx = reqinfo->updt_applctx, por.updt_task = reqinfo->updt_task, por
           .updt_dt_tm = cnvtdatetime(curdate,curtime3)
          WHERE (por.person_id=request->person_list[ii].person_id)
           AND (por.organization_id=request->org_list[jj].org_id)
          WITH nocounter
         ;end update
         SET rcnt = (rcnt+ 1)
         SET stat = alterlist(reply->person_list,rcnt)
         SET reply->person_list[rcnt].person_id = request->person_list[ii].person_id
         SET reply->person_list[rcnt].person_name = temp1->person_list[ii].name
         SET reply->person_list[rcnt].action_flag = 3
         SET reply->person_list[rcnt].org_id = request->org_list[jj].org_id
         SET reply->person_list[rcnt].org_name = temp2->org_list[jj].name
         SET reply->person_list[rcnt].confid_level_code_value = 0
         SET reply->person_list[rcnt].org_set_id = 0
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    IF (orgsetcnt > 0)
     FOR (kk = 1 TO orgsetcnt)
       IF ((request->org_group_list[kk].org_group_action_flag=1))
        INSERT  FROM org_set_prsnl_r ospr
         SET ospr.org_set_prsnl_r_id = seq(organization_seq,nextval), ospr.org_set_id = request->
          org_group_list[kk].org_set_id, ospr.prsnl_id = request->person_list[ii].person_id,
          ospr.org_set_type_cd = type_code_value, ospr.updt_id = reqinfo->updt_id, ospr.updt_cnt = 0,
          ospr.updt_applctx = reqinfo->updt_applctx, ospr.updt_task = reqinfo->updt_task, ospr
          .updt_dt_tm = cnvtdatetime(curdate,curtime3),
          ospr.active_ind = 1, ospr.active_status_cd = active_cd, ospr.active_status_dt_tm =
          cnvtdatetime(curdate,curtime3),
          ospr.active_status_prsnl_id = reqinfo->updt_id, ospr.beg_effective_dt_tm = cnvtdatetime(
           curdate,curtime3), ospr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "T"
         SET error_msg = concat(error_msg,">>","Error adding org group for prsnl: ",cnvtstring(
           request->person_list[ii].person_id)," Org Group: ",
          cnvtstring(request->org_group_list[kk].org_set_id),".")
         GO TO exit_script
        ENDIF
        SET rcnt = (rcnt+ 1)
        SET stat = alterlist(reply->person_list,rcnt)
        SET reply->person_list[rcnt].person_id = request->person_list[ii].person_id
        SET reply->person_list[rcnt].person_name = temp1->person_list[ii].name
        SET reply->person_list[rcnt].action_flag = 1
        SET reply->person_list[rcnt].org_id = 0
        SET reply->person_list[rcnt].confid_level_code_value = 0
        SET reply->person_list[rcnt].org_set_id = request->org_group_list[kk].org_set_id
        SET reply->person_list[rcnt].org_set_name = temp3->org_group_list[kk].name
       ELSEIF ((request->org_group_list[kk].org_group_action_flag=2))
        SELECT INTO "nl:"
         FROM org_set_prsnl_r ospr
         PLAN (ospr
          WHERE (ospr.org_set_id=request->org_group_list[kk].org_set_id)
           AND (ospr.prsnl_id=request->person_list[ii].person_id)
           AND ospr.org_set_type_cd=type_code_value
           AND ospr.active_ind=1
           AND ospr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
         WITH nocounter
        ;end select
        IF (curqual=0)
         INSERT  FROM org_set_prsnl_r ospr
          SET ospr.org_set_prsnl_r_id = seq(organization_seq,nextval), ospr.org_set_id = request->
           org_group_list[kk].org_set_id, ospr.prsnl_id = request->person_list[ii].person_id,
           ospr.org_set_type_cd = type_code_value, ospr.updt_id = reqinfo->updt_id, ospr.updt_cnt = 0,
           ospr.updt_applctx = reqinfo->updt_applctx, ospr.updt_task = reqinfo->updt_task, ospr
           .updt_dt_tm = cnvtdatetime(curdate,curtime3),
           ospr.active_ind = 1, ospr.active_status_cd = active_cd, ospr.active_status_dt_tm =
           cnvtdatetime(curdate,curtime3),
           ospr.active_status_prsnl_id = reqinfo->updt_id, ospr.beg_effective_dt_tm = cnvtdatetime(
            curdate,curtime3), ospr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "T"
          SET error_msg = concat(error_msg,">>","Error adding org group for prsnl: ",cnvtstring(
            request->person_list[ii].person_id)," Org Group: ",
           cnvtstring(request->org_group_list[kk].org_set_id),".")
          GO TO exit_script
         ENDIF
         SET rcnt = (rcnt+ 1)
         SET stat = alterlist(reply->person_list,rcnt)
         SET reply->person_list[rcnt].person_id = request->person_list[ii].person_id
         SET reply->person_list[rcnt].person_name = temp1->person_list[ii].name
         SET reply->person_list[rcnt].action_flag = 1
         SET reply->person_list[rcnt].org_id = 0
         SET reply->person_list[rcnt].confid_level_code_value = 0
         SET reply->person_list[rcnt].org_set_id = request->org_group_list[kk].org_set_id
         SET reply->person_list[rcnt].org_set_name = temp3->org_group_list[kk].name
        ELSE
         UPDATE  FROM org_set_prsnl_r ospr
          SET ospr.active_ind = 1, ospr.active_status_cd = active_cd, ospr.active_status_dt_tm =
           cnvtdatetime(curdate,curtime3),
           ospr.active_status_prsnl_id = reqinfo->updt_id, ospr.updt_id = reqinfo->updt_id, ospr
           .updt_cnt = (ospr.updt_cnt+ 1),
           ospr.updt_applctx = reqinfo->updt_applctx, ospr.updt_task = reqinfo->updt_task, ospr
           .updt_dt_tm = cnvtdatetime(curdate,curtime3)
          WHERE (ospr.org_set_id=request->org_group_list[kk].org_set_id)
           AND (ospr.prsnl_id=request->person_list[ii].person_id)
           AND ospr.org_set_type_cd=type_code_value
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "T"
          SET error_msg = concat(error_msg,">>","Error updating org group for prsnl: ",cnvtstring(
            request->person_list[ii].person_id)," Org Group: ",
           cnvtstring(request->org_group_list[kk].org_set_id),".")
          GO TO exit_script
         ENDIF
         SET rcnt = (rcnt+ 1)
         SET stat = alterlist(reply->person_list,rcnt)
         SET reply->person_list[rcnt].person_id = request->person_list[ii].person_id
         SET reply->person_list[rcnt].person_name = temp1->person_list[ii].name
         SET reply->person_list[rcnt].action_flag = 1
         SET reply->person_list[rcnt].org_id = 0
         SET reply->person_list[rcnt].confid_level_code_value = 0
         SET reply->person_list[rcnt].org_set_id = request->org_group_list[kk].org_set_id
         SET reply->person_list[rcnt].org_set_name = temp3->org_group_list[kk].name
        ENDIF
       ELSEIF ((request->org_group_list[kk].org_group_action_flag=3))
        SELECT INTO "nl:"
         FROM org_set_prsnl_r ospr
         PLAN (ospr
          WHERE (ospr.org_set_id=request->org_group_list[kk].org_set_id)
           AND (ospr.prsnl_id=request->person_list[ii].person_id)
           AND ospr.org_set_type_cd=type_code_value
           AND ospr.active_ind=1)
         WITH nocounter
        ;end select
        IF (curqual > 0)
         UPDATE  FROM org_set_prsnl_r ospr
          SET ospr.active_ind = 0, ospr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ospr
           .active_status_prsnl_id = reqinfo->updt_id,
           ospr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), ospr.updt_id = reqinfo->updt_id,
           ospr.updt_cnt = (ospr.updt_cnt+ 1),
           ospr.updt_applctx = reqinfo->updt_applctx, ospr.updt_task = reqinfo->updt_task, ospr
           .updt_dt_tm = cnvtdatetime(curdate,curtime3)
          WHERE (ospr.org_set_id=request->org_group_list[kk].org_set_id)
           AND (ospr.prsnl_id=request->person_list[ii].person_id)
           AND ospr.org_set_type_cd=type_code_value
           AND ospr.active_ind=1
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "T"
          SET error_msg = concat(error_msg,">>","Error rmoving org group for prsnl: ",cnvtstring(
            request->person_list[ii].person_id)," Org Group: ",
           cnvtstring(request->org_group_list[kk].org_set_id),".")
          GO TO exit_script
         ENDIF
         SET rcnt = (rcnt+ 1)
         SET stat = alterlist(reply->person_list,rcnt)
         SET reply->person_list[rcnt].person_id = request->person_list[ii].person_id
         SET reply->person_list[rcnt].person_name = temp1->person_list[ii].name
         SET reply->person_list[rcnt].action_flag = 3
         SET reply->person_list[rcnt].org_id = 0
         SET reply->person_list[rcnt].confid_level_code_value = 0
         SET reply->person_list[rcnt].org_set_id = request->org_group_list[kk].org_set_id
         SET reply->person_list[rcnt].org_set_name = temp3->org_group_list[kk].name
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_REL_PRSNL_ORG","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
