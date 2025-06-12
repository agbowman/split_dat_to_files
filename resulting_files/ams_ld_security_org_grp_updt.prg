CREATE PROGRAM ams_ld_security_org_grp_updt
 PROMPT
  "Maximum updates (0=no max):" = 0,
  "Repair associations without confid (0=no/1=yes):" = 1,
  "Group name:" = "Group Name",
  "Title of users" = "Title",
  "LD Key" = "LogicalD"
  WITH maxupdt, fixgrpconfid, groupname,
  title, logicald
 DECLARE time1 = dq8 WITH public, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE time2 = dq8 WITH public, noconstant
 DECLARE external_type_cd = f8 WITH protect
 DECLARE inactive_cd = f8 WITH protect
 SET current_cd = uar_get_code_by("MEANING",213,"CURRENT")
 SET prsnl_name_cd = uar_get_code_by("MEANING",213,"PRSNL")
 IF ( NOT (( $GROUPNAME > " ")))
  GO TO exit_script
 ENDIF
 IF (validate(temp,0))
  CALL echo("using existing record structure for user list and group name")
 ELSE
  FREE RECORD temp
  RECORD temp(
    1 group_name = vc
    1 person_upd_cnt = i4
    1 person_cnt = i4
    1 person[*]
      2 person_id = f8
      2 username = vc
      2 conf_level_cd = f8
      2 org_group_prior = i1
      2 org_group_added = i1
      2 fix_missing_org_conf_ind = i1
  )
  SET temp->group_name =  $GROUPNAME
  SELECT DISTINCT INTO "nl:"
   FROM prsnl p,
    person_name pn
   PLAN (p
    WHERE p.active_ind=1
     AND p.username="*#*"
     AND (p.logical_domain_id=
    (SELECT
     logical_domain_id
     FROM logical_domain
     WHERE (mnemonic_key= $LOGICALD))))
    JOIN (pn
    WHERE p.person_id=pn.person_id
     AND (pn.name_title= $TITLE)
     AND pn.active_ind=1
     AND pn.name_type_cd IN (prsnl_name_cd)
     AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY p.username
   DETAIL
    temp->person_cnt = (temp->person_cnt+ 1)
    IF (mod(temp->person_cnt,20)=1)
     stat = alterlist(temp->person,(temp->person_cnt+ 19))
    ENDIF
    temp->person[temp->person_cnt].person_id = p.person_id, temp->person[temp->person_cnt].username
     = p.username
   WITH nocounter
  ;end select
 ENDIF
 DECLARE idx = i4
 DECLARE idxb = i4
 DECLARE person_idx = i4
 DECLARE routine_confid_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",87,"ROUTCLINICAL"))
 IF (( $FIXGRPCONFID > 0))
  CALL echo("Find users who are already in the group without a confidentiality")
  CALL echo(format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d"))
  SELECT INTO "nl:"
   FROM org_set os,
    org_set_prsnl_r ospr,
    org_set_org_r osor,
    prsnl_org_reltn por,
    prsnl p
   PLAN (os
    WHERE os.name=value(temp->group_name)
     AND os.active_ind=1
     AND os.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
     AND os.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    JOIN (ospr
    WHERE ospr.org_set_id=os.org_set_id
     AND ospr.active_ind=1
     AND ospr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
     AND ospr.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    JOIN (osor
    WHERE osor.org_set_id=os.org_set_id
     AND osor.active_ind=1
     AND osor.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
     AND osor.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    JOIN (por
    WHERE por.person_id=ospr.prsnl_id
     AND por.organization_id=osor.organization_id
     AND por.active_ind=1
     AND por.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
     AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
     AND por.confid_level_cd=0.0)
    JOIN (p
    WHERE p.person_id=por.person_id
     AND p.active_ind=1)
   ORDER BY p.person_id
   HEAD p.person_id
    person_idx = locateval(idx,1,temp->person_cnt,p.person_id,temp->person[idx].person_id)
    IF (person_idx > 0)
     temp->person[person_idx].fix_missing_org_conf_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#already
 CALL echo(";002 Begin - Find users already associated to the org group")
 CALL echo(format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d"))
 SELECT INTO "nl:"
  FROM prsnl p,
   org_set os,
   org_set_prsnl_r ospr
  PLAN (p
   WHERE p.username > " "
    AND p.active_ind=1)
   JOIN (ospr
   WHERE ospr.prsnl_id=p.person_id
    AND ospr.org_set_type_cd=value(uar_get_code_by("MEANING",28881,"SECURITY"))
    AND ospr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ospr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ospr.active_ind=1)
   JOIN (os
   WHERE os.org_set_id=ospr.org_set_id
    AND os.active_ind=1
    AND os.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND os.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND (os.name=temp->group_name))
  ORDER BY p.person_id
  HEAD p.person_id
   person_idx = locateval(idx,1,temp->person_cnt,p.person_id,temp->person[idx].person_id)
   IF (person_idx > 0)
    CALL echo("    temp->person[person_idx]->org_group_prior = 1"),
    CALL echo(build("person_idx=",person_idx)), temp->person[person_idx].org_group_prior = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("for (person_idx = 1 to temp->person_cnt)")
 CALL echo(format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d"))
 FOR (person_idx = 1 TO temp->person_cnt)
  IF ((temp->person[person_idx].org_group_prior=0)
   AND ((( $MAXUPDT=0)) OR ((temp->person_upd_cnt <  $MAXUPDT))) )
   CALL echo(build("person_idx=",person_idx,"/",temp->person_cnt))
   CALL echo(build("temp->person_upd_cnt=",temp->person_upd_cnt,"(max ", $MAXUPDT,")"))
   CALL echo("Get current org relationships - save the confidentiality level for the org")
   CALL echo(format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d"))
   SET temp->person[person_idx].org_group_added = 1
   SET temp->person_upd_cnt = (temp->person_upd_cnt+ 1)
   CALL echo("Add user to the org group")
   CALL echo(format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d"))
   CALL echorecord(temp)
   FREE RECORD temp_request
   RECORD temp_request(
     1 action_flag = i2
     1 mode = i2
     1 options = vc
     1 prsnl_id = f8
     1 org_set_type_cd = f8
     1 org_set[*]
       2 subaction_flag = i2
       2 org_set_id = f8
       2 org_set_type_cd = f8
       2 orgs[*]
         3 subaction_flag = i2
         3 org_id = f8
   )
   FREE RECORD temp_reply
   RECORD temp_reply(
     1 org_set_prsnl_r[*]
       2 org_set_prsnl_id = f8
       2 org_set_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET temp_request->action_flag = 7
   SET temp_request->mode = 1
   SET temp_request->prsnl_id = temp->person[person_idx].person_id
   SET temp_request->org_set_type_cd = uar_get_code_by("MEANING",28881,"SECURITY")
   SET stat = alterlist(temp_request->org_set,1)
   SET temp_request->org_set[1].subaction_flag = 1
   SELECT INTO "nl:"
    FROM org_set os
    PLAN (os
     WHERE os.name=value(temp->group_name)
      AND os.active_ind=1)
    HEAD REPORT
     temp_request->org_set[1].org_set_id = os.org_set_id
    WITH nocounter
   ;end select
   SET temp_request->org_set[1].org_set_type_cd = uar_get_code_by("MEANING",28881,"SECURITY")
   CALL echorecord(temp_request)
   EXECUTE pm_prsnl_org_set  WITH replace("REQUEST","TEMP_REQUEST"), replace("REPLY","TEMP_REPLY")
   CALL echo("Associate user to orgs in the group")
   CALL echo(format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d"))
   FREE RECORD temp_request
   RECORD temp_request(
     1 person_id = f8
     1 qual[*]
       2 organization_id = f8
       2 active_ind = i2
       2 confid_level_cd = f8
   )
   FREE RECORD temp_reply
   RECORD temp_reply(
     1 qual[*]
       2 organization_id = f8
       2 confid_level_cd = f8
       2 prsnl_org_reltn_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET temp_request->person_id = temp->person[person_idx].person_id
   SELECT INTO "nl:"
    FROM org_set os,
     org_set_org_r osor,
     organization o
    PLAN (os
     WHERE os.name=value(temp->group_name)
      AND os.active_ind=1
      AND os.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
      AND os.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
     JOIN (osor
     WHERE osor.org_set_id=os.org_set_id
      AND osor.active_ind=1
      AND osor.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
      AND osor.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
     JOIN (o
     WHERE o.organization_id=osor.organization_id
      AND o.active_ind=1
      AND o.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
      AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    HEAD REPORT
     idx = 0
    DETAIL
     idx = (idx+ 1), stat = alterlist(temp_request->qual,idx), temp_request->qual[idx].
     organization_id = osor.organization_id,
     temp_request->qual[idx].active_ind = 1, temp_request->qual[idx].confid_level_cd =
     routine_confid_cd
    WITH nocounter
   ;end select
   EXECUTE uzr_add_org_to_prsnl  WITH replace("REQUEST","TEMP_REQUEST"), replace("REPLY","TEMP_REPLY"
    )
   CALL echo("commit")
   CALL echo(format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d"))
   COMMIT
  ENDIF
  IF ((temp->person[person_idx].fix_missing_org_conf_ind=1))
   IF ((temp->person[person_idx].conf_level_cd=0.0))
    SET temp->person[person_idx].conf_level_cd = routine_confid_cd
   ENDIF
   FREE RECORD temp_request
   RECORD temp_request(
     1 qual[*]
       2 confid_level_cd = f8
       2 effective_ind = i2
       2 prsnl_org_reltn_id = f8
   )
   CALL echo("Fix user's org associations missing confid")
   CALL echo(format(cnvtdatetime(curdate,curtime3),"hh:mm:ss;;d"))
   SELECT INTO "nl:"
    FROM prsnl p,
     org_set_prsnl_r ospr,
     org_set_org_r osor,
     prsnl_org_reltn por,
     organization o
    PLAN (p
     WHERE (p.person_id=temp->person[person_idx].person_id)
      AND p.active_ind=1)
     JOIN (ospr
     WHERE ospr.prsnl_id=p.person_id
      AND (ospr.org_set_id=
     (SELECT
      org_set_id
      FROM org_set
      WHERE name=value(temp->group_name)
       AND active_ind=1
       AND beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
       AND end_effective_dt_tm > cnvtdatetime(curdate,curtime)))
      AND ospr.active_ind=1
      AND ospr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
      AND ospr.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
     JOIN (osor
     WHERE osor.org_set_id=ospr.org_set_id
      AND osor.active_ind=1
      AND osor.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
      AND osor.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
     JOIN (por
     WHERE por.person_id=p.person_id
      AND por.organization_id=osor.organization_id
      AND por.active_ind=1
      AND por.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
      AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
      AND por.confid_level_cd=0.0)
     JOIN (o
     WHERE o.organization_id=por.organization_id
      AND o.active_ind=1)
    ORDER BY por.prsnl_org_reltn_id
    HEAD REPORT
     idx = 0
    HEAD por.prsnl_org_reltn_id
     idx = (idx+ 1), stat = alterlist(temp_request->qual,idx), temp_request->qual[idx].effective_ind
      = 1,
     temp_request->qual[idx].prsnl_org_reltn_id = por.prsnl_org_reltn_id, temp_request->qual[idx].
     confid_level_cd = temp->person[person_idx].conf_level_cd
    WITH nocounter
   ;end select
   FREE RECORD temp_reply
   RECORD temp_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   EXECUTE uzr_chg_prsnl_org_reltn  WITH replace("REQUEST","TEMP_REQUEST"), replace("REPLY",
    "TEMP_REPLY")
   COMMIT
  ENDIF
 ENDFOR
 SET time2 = cnvtdatetime(curdate,curtime3)
 CALL echo(build("time1 to time2 (sec)=",datetimediff(time2,time1,5)))
#exit_script
END GO
