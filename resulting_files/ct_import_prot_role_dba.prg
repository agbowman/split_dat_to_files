CREATE PROGRAM ct_import_prot_role:dba
 RECORD reply(
   1 qual[*]
     2 prot_role_id = f8
     2 person_full_name = vc
     2 organization_id = f8
     2 org_name = vc
     2 person_id = f8
     2 prot_role_cd = f8
     2 prot_role_disp = c50
     2 prot_role_desc = c50
     2 prot_role_mean = c12
     2 prot_role_type_cd = f8
     2 prot_role_type_disp = c50
     2 prot_role_type_desc = c50
     2 prot_role_type_mean = c12
     2 position_cd = f8
     2 position_disp = c50
     2 position_desc = c50
     2 position_mean = c12
     2 primary_ind = i2
     2 primary_contact_rank_nbr = i4
     2 updt_cnt = i4
   1 access_list[*]
     2 person_id = f8
     2 functionality_cd = f8
     2 access_mask = c5
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH protect, noconstant("S")
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE access_cnt = i2 WITH protect, noconstant(0)
 DECLARE num_to_add = i2 WITH protect, noconstant(0)
 DECLARE primary_id = f8 WITH protect, noconstant(0.0)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE creator_cd = f8 WITH protect, noconstant(0.0)
 DECLARE parent_amd_id = f8 WITH protect, noconstant(0.0)
 DECLARE diff = f8 WITH noconstant(0.0)
 DECLARE creatorranknumber = i4 WITH noconstant(0)
 DECLARE creatorprimaryind = i2 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(17441,"CREATOR",1,creator_cd)
 IF ((request->prev_collab_amd_id > 0))
  SET parent_amd_id = request->prev_collab_amd_id
 ELSE
  SET parent_amd_id = request->prev_amendment_id
 ENDIF
 SELECT
  pr.primary_contact_rank_nbr, pr.primary_contact_ind
  FROM prot_role pr
  WHERE pr.prot_amendment_id=parent_amd_id
   AND pr.prot_role_cd=creator_cd
   AND pr.end_effective_dt_tm > cnvtdatetime(sysdate)
  DETAIL
   creatorranknumber = pr.primary_contact_rank_nbr, creatorprimaryind = pr.primary_contact_ind
 ;end select
 SELECT INTO "nl:"
  p.prot_role_id, p.organization_id, p.person_id,
  p.prot_role_cd, p.prot_role_type_cd, p.updt_cnt,
  pr.name_full_formatted
  FROM prot_role p,
   organization o,
   prsnl pr,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
  PLAN (p
   WHERE ((p.prot_amendment_id=parent_amd_id
    AND p.prot_role_cd != creator_cd) OR ((p.prot_amendment_id=request->prot_amendment_id)
    AND p.prot_role_cd=creator_cd))
    AND p.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00"))
   JOIN (d1)
   JOIN (o
   WHERE p.organization_id=o.organization_id)
   JOIN (d2)
   JOIN (pr
   WHERE p.person_id=pr.person_id
    AND pr.active_ind=1)
  HEAD REPORT
   num_to_add = 0
  DETAIL
   num_to_add += 1
   IF (num_to_add > size(reply->qual,5))
    stat = alterlist(reply->qual,(num_to_add+ 5))
   ENDIF
   reply->qual[num_to_add].organization_id = p.organization_id, reply->qual[num_to_add].org_name = o
   .org_name, reply->qual[num_to_add].person_id = p.person_id,
   reply->qual[num_to_add].person_full_name = pr.name_full_formatted, reply->qual[num_to_add].
   prot_role_cd = p.prot_role_cd, reply->qual[num_to_add].prot_role_type_cd = p.prot_role_type_cd,
   reply->qual[num_to_add].updt_cnt = p.updt_cnt, reply->qual[num_to_add].primary_ind = p
   .primary_contact_ind, reply->qual[num_to_add].primary_contact_rank_nbr = p
   .primary_contact_rank_nbr
   IF (p.prot_role_cd=creator_cd)
    reply->qual[num_to_add].prot_role_id = p.prot_role_id, reply->qual[num_to_add].
    primary_contact_rank_nbr = creatorranknumber, reply->qual[num_to_add].primary_ind =
    creatorprimaryind
   ENDIF
   reply->qual[num_to_add].position_cd = p.position_cd
  FOOT REPORT
   stat = alterlist(reply->qual,num_to_add)
  WITH dontcare = o, outerjoin = d2, nocounter
 ;end select
 IF (curqual=0)
  CALL report_failure("SELECT","Z","CT_IMPORT_PROT_ROLE","No roles found to import.")
  GO TO exit_script
 ELSE
  SELECT INTO "nl:"
   FROM entity_access ea
   PLAN (ea
    WHERE (ea.prot_amendment_id=request->prev_amendment_id)
     AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
   HEAD REPORT
    access_cnt = 0
   DETAIL
    access_cnt += 1
    IF (access_cnt > size(reply->access_list,5))
     stat = alterlist(reply->access_list,(access_cnt+ 5))
    ENDIF
    reply->access_list[access_cnt].functionality_cd = ea.functionality_cd, reply->access_list[
    access_cnt].access_mask = ea.access_mask, reply->access_list[access_cnt].person_id = ea.person_id
   FOOT REPORT
    stat = alterlist(reply->access_list,access_cnt)
   WITH nocounter
  ;end select
 ENDIF
 UPDATE  FROM prot_role pr
  SET pr.end_effective_dt_tm = cnvtdatetime(sysdate)
  WHERE (pr.prot_amendment_id=request->prot_amendment_id)
   AND pr.prot_role_cd != creator_cd
  WITH nocounter
 ;end update
 COMMIT
 SET datetimebuffer = cnvtdatetime(sysdate)
 WHILE (diff < 0.25)
  SET curdatetime = cnvtdatetime(sysdate)
  SET diff = datetimediff(curdatetime,datetimebuffer,5)
 ENDWHILE
 FOR (i = 1 TO num_to_add)
   IF ((reply->qual[i].prot_role_cd != creator_cd))
    SELECT INTO "nl:"
     num = seq(protocol_def_seq,nextval)
     FROM dual
     DETAIL
      primary_id = num
     WITH format, counter
    ;end select
    INSERT  FROM prot_role ro
     SET ro.prot_role_id = primary_id, ro.prot_amendment_id = request->prot_amendment_id, ro
      .prot_role_type_cd = reply->qual[i].prot_role_type_cd,
      ro.person_id = reply->qual[i].person_id, ro.organization_id = reply->qual[i].organization_id,
      ro.prot_role_cd = reply->qual[i].prot_role_cd,
      ro.beg_effective_dt_tm = cnvtdatetime(sysdate), ro.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"), ro.updt_dt_tm = cnvtdatetime(sysdate),
      ro.updt_id = reqinfo->updt_id, ro.updt_applctx = reqinfo->updt_applctx, ro.updt_task = reqinfo
      ->updt_task,
      ro.updt_cnt = 0, ro.primary_contact_ind = reply->qual[i].primary_ind, ro
      .primary_contact_rank_nbr = reply->qual[i].primary_contact_rank_nbr,
      ro.position_cd = reply->qual[i].position_cd
     WITH nocounter
    ;end insert
    SET reply->qual[i].prot_role_id = primary_id
    IF (curqual=0)
     CALL report_failure("INSERT","F","CT_IMPORT_PROT_ROLE",
      "Failure inserting roles from previous amendment.")
     GO TO exit_script
    ENDIF
   ELSEIF ((reply->qual[i].prot_role_cd=creator_cd))
    UPDATE  FROM prot_role ro
     SET ro.prot_role_id = reply->qual[i].prot_role_id, ro.prot_amendment_id = request->
      prot_amendment_id, ro.prot_role_type_cd = reply->qual[i].prot_role_type_cd,
      ro.person_id = reply->qual[i].person_id, ro.organization_id = reply->qual[i].organization_id,
      ro.prot_role_cd = reply->qual[i].prot_role_cd,
      ro.beg_effective_dt_tm = cnvtdatetime(sysdate), ro.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"), ro.updt_dt_tm = cnvtdatetime(sysdate),
      ro.updt_id = reqinfo->updt_id, ro.updt_applctx = reqinfo->updt_applctx, ro.updt_task = reqinfo
      ->updt_task,
      ro.updt_cnt = 0, ro.primary_contact_ind = creatorprimaryind, ro.primary_contact_rank_nbr =
      creatorranknumber,
      ro.position_cd = reply->qual[i].position_cd
     WHERE (ro.prot_amendment_id=request->prot_amendment_id)
      AND ro.prot_role_cd=creator_cd
    ;end update
    COMMIT
   ENDIF
 ENDFOR
 IF (access_cnt > 0)
  INSERT  FROM entity_access ea,
    (dummyt d  WITH seq = value(access_cnt))
   SET ea.entity_access_id = seq(protocol_def_seq,nextval), ea.prot_amendment_id = request->
    prot_amendment_id, ea.person_id = reply->access_list[d.seq].person_id,
    ea.functionality_cd = reply->access_list[d.seq].functionality_cd, ea.access_mask = reply->
    access_list[d.seq].access_mask, ea.beg_effective_dt_tm = cnvtdatetime(sysdate),
    ea.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), ea.updt_dt_tm = cnvtdatetime(
     sysdate), ea.updt_id = reqinfo->updt_id,
    ea.updt_applctx = reqinfo->updt_applctx, ea.updt_task = reqinfo->updt_task, ea.updt_cnt = 0
   PLAN (d)
    JOIN (ea)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL report_failure("INSERT","F","CT_IMPORT_PROT_ROLE",
    "Failure inserting entity_access from previous amendment.")
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE (report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) =null)
   IF (opstatus="F")
    SET failed = "T"
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET last_mod = "008"
 SET mod_date = "Feb 20, 2018"
END GO
