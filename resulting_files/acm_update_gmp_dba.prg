CREATE PROGRAM acm_update_gmp:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 gmp_prsnl_id = f8
    1 gp_practice_org_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE (loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("INFO-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
        '"',",",option_flag,") not found, CURPROG [",curprog,
        "]"))
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 FREE SET data
 RECORD data(
   1 person_org_reltn_qual_cnt = i4
   1 person_org_reltn_qual[*]
     2 person_org_reltn_id = f8
     2 organization_id = f8
     2 updt_cnt = i4
     2 beg_effective_dt_tm = dq8
   1 person_org_reltn_beg_date = dq8
   1 primary_care_gp
     2 person_id = f8
     2 prsnl_reltn_id = f8
     2 person_prsnl_reltn_id = f8
   1 gmp_prsnl
     2 person_id = f8
     2 prsnl_reltn_id = f8
     2 person_prsnl_reltn_id = f8
   1 person_prsnl_reltn_qual_cnt = i4
   1 person_prsnl_reltn_qual[*]
     2 person_prsnl_reltn_id = f8
     2 prsnl_person_id = f8
     2 updt_cnt = i4
     2 prsnl_org_reltn_org_id = f8
     2 prsnl_reltn_id = f8
 )
 DECLARE nhs_gmp_alias_pool_cd = f8 WITH protect, noconstant(0.0)
 DECLARE nhs_contrib_system_cd = f8 WITH protect, noconstant(loadcodevalue(89,"NHS",0))
 DECLARE ext_alias_cd = f8 WITH protect, noconstant(loadcodevalue(320,"EXTERNALID",0))
 DECLARE pcp_cd = f8 WITH protect, constant(loadcodevalue(331,"PCP",0))
 DECLARE reg_practice_cd = f8 WITH protect, constant(loadcodevalue(338,"REGPRACTICE",0))
 DECLARE demog_reltn_cd = f8 WITH protect, noconstant(loadcodevalue(30300,"DEMOGRELTN",0))
 DECLARE nhs_gmp_oid = vc WITH public, constant("1.2.826.0.1285.0.2.1.168")
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE count2 = i4 WITH protect, noconstant(0)
 DECLARE org_id_found = i4 WITH protect, noconstant(0)
 DECLARE org_id_index = i4 WITH protect, noconstant(0)
 DECLARE person_org_reltn_id_found = i4 WITH protect, noconstant(0)
 DECLARE person_org_reltn_id_index = i4 WITH protect, noconstant(0)
 DECLARE person_id_found = i4 WITH protect, noconstant(0)
 DECLARE person_id_index = i4 WITH protect, noconstant(0)
 DECLARE val_gp_prsnl_reltn_id = f8 WITH protect, noconstant(0)
 DECLARE val_add_person_prsnl_reltn_id = f8 WITH protect, noconstant(0)
 DECLARE val_pra_prsnl_reltn_activity_id = f8 WITH protect, noconstant(0)
 DECLARE val_pra_prsnl_reltn_id = f8 WITH protect, noconstant(0)
 DECLARE val_pra_updt_cnt = i4 WITH protect, noconstant(0)
 DECLARE val_pra_status = i4 WITH protect, noconstant(0)
 DECLARE add_action = i2 WITH protect, constant(1)
 DECLARE chg_action = i2 WITH protect, constant(2)
 DECLARE del_action = i2 WITH protect, constant(3)
 DECLARE act_action = i2 WITH protect, constant(4)
 DECLARE ina_action = i2 WITH protect, constant(5)
 SELECT INTO "nl:"
  FROM esi_alias_trans eat
  WHERE eat.contributor_system_cd=nhs_contrib_system_cd
   AND eat.alias_entity_alias_type_cd=ext_alias_cd
   AND eat.esi_assign_auth=nhs_gmp_oid
   AND eat.active_ind=1
  DETAIL
   nhs_gmp_alias_pool_cd = eat.alias_pool_cd
  WITH nocounter
 ;end select
 IF (nhs_gmp_alias_pool_cd=0.0)
  SET failed = select_error
  SET table_name = build(nhs_gmp_oid,
   ": does not exist under esi_alias_trans for alias type of EXTERNALID. Script failed.")
  GO TO exit_script
 ENDIF
 IF ((request->person_id > 0))
  IF ((request->gp_practice_org_id > 0))
   CALL sub_get_person_org_reltns("")
   IF ((data->person_org_reltn_qual_cnt=0))
    CALL sub_add_person_org_reltn("")
    SET reply->gp_practice_org_id = request->gp_practice_org_id
   ELSE
    SET org_id_found = locateval(org_id_index,1,data->person_org_reltn_qual_cnt,request->
     gp_practice_org_id,data->person_org_reltn_qual[org_id_index].organization_id)
    IF (org_id_found=0)
     CALL sub_end_person_org_reltns(0)
     CALL sub_add_person_org_reltn("")
     SET reply->gp_practice_org_id = request->gp_practice_org_id
    ELSE
     IF ((data->person_org_reltn_qual_cnt > 1))
      CALL sub_end_person_org_reltns(org_id_index)
     ENDIF
     SET data->person_org_reltn_beg_date = data->person_org_reltn_qual[org_id_index].
     beg_effective_dt_tm
     SET reply->gp_practice_org_id = data->person_org_reltn_qual[org_id_index].organization_id
    ENDIF
   ENDIF
   CALL sub_get_person_prsnl_reltns("")
   IF ((data->person_prsnl_reltn_qual_cnt=0))
    CALL sub_get_pcp_by_org("")
    IF ((data->primary_care_gp.person_id > 0))
     SET data->primary_care_gp.person_prsnl_reltn_id = sub_add_person_prsnl_reltn(data->
      primary_care_gp.person_id)
     CALL sub_maintain_prsnl_reltn_activity(data->primary_care_gp.person_prsnl_reltn_id,data->
      primary_care_gp.prsnl_reltn_id)
     SET reply->gmp_prsnl_id = data->primary_care_gp.person_id
    ENDIF
   ELSE
    SET person_org_reltn_id_found = locateval(person_org_reltn_id_index,1,data->
     person_prsnl_reltn_qual_cnt,request->gp_practice_org_id,data->person_prsnl_reltn_qual[
     person_org_reltn_id_index].prsnl_org_reltn_org_id)
    IF (person_org_reltn_id_found=0)
     CALL sub_end_person_prsnl_reltns(0)
     CALL sub_get_pcp_by_org("")
     IF ((data->primary_care_gp.person_id > 0))
      SET data->primary_care_gp.person_prsnl_reltn_id = sub_add_person_prsnl_reltn(data->
       primary_care_gp.person_id)
      CALL sub_maintain_prsnl_reltn_activity(data->primary_care_gp.person_prsnl_reltn_id,data->
       primary_care_gp.prsnl_reltn_id)
      SET reply->gmp_prsnl_id = data->primary_care_gp.person_id
     ENDIF
    ELSE
     IF ((data->person_prsnl_reltn_qual_cnt > 1))
      CALL sub_end_person_prsnl_reltns(person_org_reltn_id_index)
     ENDIF
     CALL sub_maintain_prsnl_reltn_activity(data->person_prsnl_reltn_qual[person_org_reltn_id_index].
      person_prsnl_reltn_id,data->person_prsnl_reltn_qual[person_org_reltn_id_index].prsnl_reltn_id)
     SET reply->gmp_prsnl_id = data->person_prsnl_reltn_qual[person_org_reltn_id_index].
     prsnl_person_id
    ENDIF
   ENDIF
  ELSEIF ((request->gmp_prsnl_id > 0))
   CALL sub_get_person_prsnl_reltns("")
   IF ((data->person_prsnl_reltn_qual_cnt=0))
    SET data->gmp_prsnl.person_prsnl_reltn_id = sub_add_person_prsnl_reltn(request->gmp_prsnl_id)
    SET data->gmp_prsnl.prsnl_reltn_id = sub_get_gp_prsnl_reltn_id(request->gmp_prsnl_id)
    CALL sub_maintain_prsnl_reltn_activity(data->gmp_prsnl.person_prsnl_reltn_id,data->gmp_prsnl.
     prsnl_reltn_id)
    SET reply->gmp_prsnl_id = request->gmp_prsnl_id
   ELSEIF ((data->person_prsnl_reltn_qual_cnt > 1))
    CALL sub_end_person_prsnl_reltns(1)
    CALL sub_maintain_prsnl_reltn_activity(data->person_prsnl_reltn_qual[1].person_prsnl_reltn_id,
     data->person_prsnl_reltn_qual[1].prsnl_reltn_id)
    SET reply->gmp_prsnl_id = data->person_prsnl_reltn_qual[1].prsnl_person_id
   ELSE
    CALL sub_maintain_prsnl_reltn_activity(data->person_prsnl_reltn_qual[1].person_prsnl_reltn_id,
     data->person_prsnl_reltn_qual[1].prsnl_reltn_id)
    SET reply->gmp_prsnl_id = data->person_prsnl_reltn_qual[1].prsnl_person_id
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE (sub_get_person_org_reltns(val_dummy=vc) =null WITH protect)
  SET count2 = 0
  SELECT INTO "nl:"
   por.person_org_reltn_id, por.organization_id
   FROM person_org_reltn por
   PLAN (por
    WHERE (por.person_id=request->person_id)
     AND por.person_org_reltn_cd=reg_practice_cd
     AND por.active_ind=1
     AND (por.active_status_cd=reqdata->active_status_cd)
     AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
   ORDER BY por.person_org_reltn_id DESC
   DETAIL
    data->person_org_reltn_qual_cnt += 1, stat = alterlist(data->person_org_reltn_qual,data->
     person_org_reltn_qual_cnt), data->person_org_reltn_qual[data->person_org_reltn_qual_cnt].
    person_org_reltn_id = por.person_org_reltn_id,
    data->person_org_reltn_qual[data->person_org_reltn_qual_cnt].organization_id = por
    .organization_id, data->person_org_reltn_qual[data->person_org_reltn_qual_cnt].updt_cnt = por
    .updt_cnt, data->person_org_reltn_qual[data->person_org_reltn_qual_cnt].beg_effective_dt_tm = por
    .beg_effective_dt_tm
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE (sub_get_person_prsnl_reltns(val_dummy=vc) =null WITH protect)
   SELECT INTO "nl:"
    ppr.person_prsnl_reltn_id, ppr.prsnl_person_id
    FROM person_prsnl_reltn ppr
    PLAN (ppr
     WHERE (ppr.person_id=request->person_id)
      AND ((ppr.person_prsnl_r_cd+ 0)=pcp_cd)
      AND ppr.active_ind=1
      AND (ppr.active_status_cd=reqdata->active_status_cd)
      AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
    ORDER BY ppr.person_prsnl_reltn_id DESC
    DETAIL
     data->person_prsnl_reltn_qual_cnt += 1, stat = alterlist(data->person_prsnl_reltn_qual,data->
      person_prsnl_reltn_qual_cnt), data->person_prsnl_reltn_qual[data->person_prsnl_reltn_qual_cnt].
     person_prsnl_reltn_id = ppr.person_prsnl_reltn_id,
     data->person_prsnl_reltn_qual[data->person_prsnl_reltn_qual_cnt].prsnl_person_id = ppr
     .prsnl_person_id, data->person_prsnl_reltn_qual[data->person_prsnl_reltn_qual_cnt].updt_cnt =
     ppr.updt_cnt
    WITH nocounter
   ;end select
   IF ((request->gp_practice_org_id > 0)
    AND (data->person_prsnl_reltn_qual_cnt > 0))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(data->person_prsnl_reltn_qual_cnt)),
      prsnl_org_reltn por
     PLAN (d
      WHERE (data->person_prsnl_reltn_qual[d.seq].prsnl_person_id > 0))
      JOIN (por
      WHERE (por.person_id=data->person_prsnl_reltn_qual[d.seq].prsnl_person_id)
       AND (por.organization_id=request->gp_practice_org_id)
       AND por.active_ind=1
       AND (por.active_status_cd=reqdata->active_status_cd)
       AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm > cnvtdatetime(curdate,0))
     DETAIL
      data->person_prsnl_reltn_qual[d.seq].prsnl_org_reltn_org_id = por.organization_id
     WITH nocounter
    ;end select
   ENDIF
   FOR (count = 1 TO data->person_prsnl_reltn_qual_cnt)
     SET data->person_prsnl_reltn_qual[count].prsnl_reltn_id = sub_get_gp_prsnl_reltn_id(data->
      person_prsnl_reltn_qual[count].prsnl_person_id)
   ENDFOR
 END ;Subroutine
 SUBROUTINE (sub_get_pcp_by_org(val_dummy=vc) =null WITH protect)
  SELECT INTO "nl:"
   por_person_id_min = min(por.person_id)
   FROM prsnl_org_reltn por,
    prsnl_alias pa
   PLAN (por
    WHERE (por.organization_id=request->gp_practice_org_id)
     AND por.active_ind=1
     AND (por.active_status_cd=reqdata->active_status_cd)
     AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND por.end_effective_dt_tm > cnvtdatetime(curdate,0))
    JOIN (pa
    WHERE pa.person_id=por.person_id
     AND ((pa.prsnl_alias_type_cd+ 0)=ext_alias_cd)
     AND ((pa.alias_pool_cd+ 0)=nhs_gmp_alias_pool_cd)
     AND pa.active_ind=1
     AND (pa.active_status_cd=reqdata->active_status_cd))
   FOOT REPORT
    data->primary_care_gp.person_id = por_person_id_min
   WITH nocounter
  ;end select
  SET data->primary_care_gp.prsnl_reltn_id = sub_get_gp_prsnl_reltn_id(data->primary_care_gp.
   person_id)
 END ;Subroutine
 SUBROUTINE (sub_get_gp_prsnl_reltn_id(val_gp_prsnl_id=f8) =f8 WITH protect)
   SET val_gp_prsnl_reltn_id = 0
   IF (val_gp_prsnl_id > 0)
    IF ((request->gp_practice_org_id > 0))
     SELECT INTO "nl:"
      prc_prsnl_reltn_id_max = max(prc.prsnl_reltn_id)
      FROM prsnl_reltn pr,
       prsnl_reltn_child prc
      PLAN (pr
       WHERE pr.person_id=val_gp_prsnl_id
        AND ((pr.parent_entity_id+ 0)=request->gp_practice_org_id)
        AND pr.parent_entity_name="ORGANIZATION"
        AND pr.reltn_type_cd=demog_reltn_cd
        AND pr.active_ind=1
        AND (pr.active_status_cd=reqdata->active_status_cd)
        AND pr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND pr.end_effective_dt_tm > cnvtdatetime(curdate,0))
       JOIN (prc
       WHERE prc.prsnl_reltn_id=pr.prsnl_reltn_id
        AND prc.parent_entity_name="ADDRESS")
      FOOT REPORT
       val_gp_prsnl_reltn_id = prc_prsnl_reltn_id_max
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      prc_prsnl_reltn_id_max = max(prc.prsnl_reltn_id)
      FROM prsnl_reltn pr,
       prsnl_reltn_child prc
      PLAN (pr
       WHERE pr.person_id=val_gp_prsnl_id
        AND pr.parent_entity_name="ORGANIZATION"
        AND pr.reltn_type_cd=demog_reltn_cd
        AND pr.active_ind=1
        AND (pr.active_status_cd=reqdata->active_status_cd)
        AND pr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND pr.end_effective_dt_tm > cnvtdatetime(curdate,0))
       JOIN (prc
       WHERE prc.prsnl_reltn_id=pr.prsnl_reltn_id
        AND prc.parent_entity_name="ADDRESS")
      FOOT REPORT
       val_gp_prsnl_reltn_id = prc_prsnl_reltn_id_max
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(val_gp_prsnl_reltn_id)
 END ;Subroutine
 SUBROUTINE (sub_maintain_prsnl_reltn_activity(val_person_prsnl_reltn_id=f8,val_prsnl_reltn_id=f8) =
  null WITH protect)
   SET val_pra_prsnl_reltn_activity_id = 0
   SET val_pra_prsnl_reltn_id = 0
   SET val_pra_updt_cnt = 0
   SET val_pra_status = 0
   IF (val_person_prsnl_reltn_id > 0
    AND val_prsnl_reltn_id > 0)
    SELECT INTO "nl:"
     FROM prsnl_reltn_activity pra
     PLAN (pra
      WHERE (pra.person_id=request->person_id)
       AND pra.parent_entity_name="PERSON_PRSNL_RELTN"
       AND pra.parent_entity_id=val_person_prsnl_reltn_id)
     ORDER BY pra.prsnl_reltn_activity_id DESC
     DETAIL
      val_pra_prsnl_reltn_activity_id = pra.prsnl_reltn_activity_id, val_pra_prsnl_reltn_id = pra
      .prsnl_reltn_id
     WITH nocounter
    ;end select
    IF (val_pra_prsnl_reltn_activity_id=0)
     SELECT INTO "nl:"
      nextseqnum = seq(person_seq,nextval)
      FROM dual
      DETAIL
       val_pra_prsnl_reltn_activity_id = cnvtreal(nextseqnum)
      WITH nocounter, format
     ;end select
     IF (curqual=0)
      SET failed = gen_nbr_error
      GO TO exit_script
     ENDIF
     INSERT  FROM prsnl_reltn_activity pra
      SET pra.prsnl_reltn_activity_id = val_pra_prsnl_reltn_activity_id, pra.person_id = request->
       person_id, pra.parent_entity_id = val_person_prsnl_reltn_id,
       pra.parent_entity_name = "PERSON_PRSNL_RELTN", pra.prsnl_reltn_id = val_prsnl_reltn_id, pra
       .updt_cnt = 0,
       pra.updt_dt_tm = cnvtdatetime(sysdate), pra.updt_id = reqinfo->updt_id, pra.updt_applctx =
       reqinfo->updt_applctx,
       pra.updt_task = reqinfo->updt_task
      PLAN (pra)
      WITH nocounter, status(val_pra_status)
     ;end insert
     IF (val_pra_status=0)
      SET failed = insert_error
      SET table_name = "PRSNL_RELTN_ACTIVITY"
      GO TO exit_script
     ENDIF
    ELSEIF (val_pra_prsnl_reltn_id != val_prsnl_reltn_id)
     UPDATE  FROM prsnl_reltn_activity pra
      SET pra.prsnl_reltn_id = val_prsnl_reltn_id, pra.updt_cnt = (val_pra_updt_cnt+ 1), pra
       .updt_dt_tm = cnvtdatetime(sysdate),
       pra.updt_id = reqinfo->updt_id, pra.updt_applctx = reqinfo->updt_applctx, pra.updt_task =
       reqinfo->updt_task
      PLAN (pra
       WHERE pra.prsnl_reltn_activity_id=val_pra_prsnl_reltn_activity_id)
      WITH nocounter, status(val_pra_status)
     ;end update
     IF (val_pra_status=0)
      SET failed = update_error
      SET table_name = "PRSNL_RELTN_ACTIVITY"
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (sub_end_person_org_reltns(val_exclude_index=i4) =null WITH protect)
   FREE RECORD acm_request
   RECORD acm_request(
     1 force_updt_ind = i2
     1 use_req_updt_ind = i2
     1 person_org_reltn_qual[*]
       2 beg_effective_dt_tm = dq8
       2 contributor_system_cd = f8
       2 empl_contact = vc
       2 empl_contact_title = vc
       2 empl_hire_dt_tm = dq8
       2 empl_occupation_cd = f8
       2 empl_occupation_text = vc
       2 empl_position = vc
       2 empl_retire_dt_tm = dq8
       2 empl_status_cd = f8
       2 empl_term_dt_tm = dq8
       2 empl_title = vc
       2 empl_type_cd = f8
       2 end_effective_dt_tm = dq8
       2 free_text_ind = i2
       2 ft_org_name = vc
       2 internal_seq = i4
       2 organization_id = f8
       2 organization_idx = i4
       2 person_id = f8
       2 person_idx = i4
       2 person_org_alias = vc
       2 person_org_nbr = vc
       2 person_org_reltn_cd = f8
       2 person_org_reltn_id = f8
       2 priority_seq = i4
       2 action_flag = i2
       2 active_ind = i2
       2 active_status_cd = f8
       2 chg_str = vc
       2 data_status_cd = f8
       2 updt_cnt = i4
       2 source_identifier = vc
   )
   FREE RECORD acm_reply
   RECORD acm_reply(
     1 transaction_info_qual_cnt = i4
     1 transaction_info_qual[*]
       2 transaction_id = f8
       2 pm_hist_tracking_id = f8
       2 person_id = f8
       2 person_idx = i4
       2 encntr_id = f8
       2 encntr_idx = i4
       2 status = i2
     1 address_qual_cnt = i4
     1 address_qual[*]
       2 address_id = f8
       2 status = i2
     1 encntr_alias_qual_cnt = i4
     1 encntr_alias_qual[*]
       2 encntr_alias_id = f8
       2 status = i2
     1 encntr_code_value_r_qual_cnt = i4
     1 encntr_code_value_r_qual[*]
       2 encntr_code_value_r_id = f8
       2 status = i2
     1 encntr_domain_qual_cnt = i4
     1 encntr_domain_qual[*]
       2 encntr_domain_id = f8
       2 status = i2
     1 encntr_financial_qual_cnt = i4
     1 encntr_financial_qual[*]
       2 encntr_financial_id = f8
       2 status = i2
     1 encntr_info_qual_cnt = i4
     1 encntr_info_qual[*]
       2 encntr_info_id = f8
       2 status = i2
     1 encntr_loc_hist_qual_cnt = i4
     1 encntr_loc_hist_qual[*]
       2 encntr_loc_hist_id = f8
       2 status = i2
     1 encntr_org_reltn_qual_cnt = i4
     1 encntr_org_reltn_qual[*]
       2 encntr_org_reltn_id = f8
       2 status = i2
     1 encntr_person_reltn_qual_cnt = i4
     1 encntr_person_reltn_qual[*]
       2 encntr_person_reltn_id = f8
       2 status = i2
     1 encntr_plan_reltn_qual_cnt = i4
     1 encntr_plan_reltn_qual[*]
       2 encntr_plan_reltn_id = f8
       2 status = i2
     1 encntr_prsnl_reltn_qual_cnt = i4
     1 encntr_prsnl_reltn_qual[*]
       2 encntr_prsnl_reltn_id = f8
       2 status = i2
     1 encounter_qual_cnt = i4
     1 encounter_qual[*]
       2 encntr_id = f8
       2 status = i2
     1 health_plan_qual_cnt = i4
     1 health_plan_qual[*]
       2 health_plan_id = f8
       2 status = i2
     1 person_qual_cnt = i4
     1 person_qual[*]
       2 person_id = f8
       2 status = i2
     1 person_alias_qual_cnt = i4
     1 person_alias_qual[*]
       2 person_alias_id = f8
       2 status = i2
     1 person_code_value_r_qual_cnt = i4
     1 person_code_value_r_qual[*]
       2 person_code_value_r_id = f8
       2 status = i2
     1 person_name_qual_cnt = i4
     1 person_name_qual[*]
       2 person_name_id = f8
       2 status = i2
     1 person_org_reltn_qual_cnt = i4
     1 person_org_reltn_qual[*]
       2 person_org_reltn_id = f8
       2 status = i2
     1 person_patient_qual_cnt = i4
     1 person_patient_qual[*]
       2 person_id = f8
       2 status = i2
     1 person_person_reltn_qual_cnt = i4
     1 person_person_reltn_qual[*]
       2 person_person_reltn_id = f8
       2 status = i2
     1 person_plan_reltn_qual_cnt = i4
     1 person_plan_reltn_qual[*]
       2 person_plan_reltn_id = f8
       2 status = i2
     1 person_prsnl_reltn_qual_cnt = i4
     1 person_prsnl_reltn_qual[*]
       2 person_prsnl_reltn_id = f8
       2 status = i2
     1 phone_qual_cnt = i4
     1 phone_qual[*]
       2 phone_id = f8
       2 status = i2
     1 service_category_hist_qual_cnt = i4
     1 service_category_hist_qual[*]
       2 svc_cat_hist_id = f8
       2 status = i2
     1 preprocess_qual_cnt = i4
     1 preprocess_qual[*]
       2 status = i2
     1 postprocess_qual_cnt = i4
     1 postprocess_qual[*]
       2 status = i2
     1 p_rx_plan_coverage_qual_cnt = i4
     1 person_rx_plan_coverage_qual[*]
       2 person_rx_plan_coverage_id = f8
       2 status = i2
     1 p_rx_plan_reltn_qual_cnt = i4
     1 person_rx_plan_reltn_qual[*]
       2 person_rx_plan_reltn_id = f8
       2 status = i2
     1 debug_cnt = i4
     1 debug[*]
       2 line = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
     1 error_info[1]
       2 line1 = vc
       2 line2 = vc
       2 line3 = vc
   )
   FREE RECORD xref
   RECORD xref(
     1 chg_cnt = i4
     1 chg[*]
       2 idx = i4
   )
   SET count2 = 0
   FOR (count = 1 TO data->person_org_reltn_qual_cnt)
    SET acm_request->force_updt_ind = 1
    IF (count != val_exclude_index)
     SET count2 += 1
     SET stat = alterlist(acm_request->person_org_reltn_qual,count2)
     SET stat = alterlist(acm_reply->person_qual,count2)
     SET stat = alterlist(acm_reply->person_qual,count2)
     SET stat = alterlist(xref->chg,count2)
     SET xref->chg_cnt = count2
     SET xref->chg[count2].idx = count2
     SET acm_request->person_org_reltn_qual[count2].action_flag = chg_action
     SET acm_request->person_org_reltn_qual[count2].chg_str = "END_EFFECTIVE_DT_TM,"
     SET acm_request->person_org_reltn_qual[count2].person_org_reltn_id = data->
     person_org_reltn_qual[count].person_org_reltn_id
     SET acm_request->person_org_reltn_qual[count2].end_effective_dt_tm = cnvtdatetime(sysdate)
     SET acm_request->person_org_reltn_qual[count2].updt_cnt = data->person_org_reltn_qual[count2].
     updt_cnt
    ENDIF
   ENDFOR
   SET acm_reply->person_org_reltn_qual_cnt = count2
   SET stat = alterlist(acm_reply->person_org_reltn_qual,count2)
   IF (count2 > 0)
    EXECUTE acm_chg_person_org_reltn  WITH replace("ACM_REQUEST","ACM_REQUEST"), replace("REPLY",
     "ACM_REPLY")
    IF ((acm_reply->status_data.status="F"))
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (sub_end_person_prsnl_reltns(val_exclude_index=i4) =null WITH protect)
   FREE RECORD acm_request
   RECORD acm_request(
     1 force_updt_ind = i2
     1 use_req_updt_ind = i2
     1 person_prsnl_reltn_qual[*]
       2 beg_effective_dt_tm = dq8
       2 contributor_system_cd = f8
       2 end_effective_dt_tm = dq8
       2 free_text_cd = f8
       2 ft_prsnl_name = vc
       2 internal_seq = i4
       2 manual_create_by_id = f8
       2 manual_create_by_idx = i4
       2 manual_create_dt_tm = dq8
       2 manual_create_ind = i2
       2 manual_inact_by_id = f8
       2 manual_inact_by_idx = i4
       2 manual_inact_dt_tm = dq8
       2 manual_inact_ind = i2
       2 notification_cd = f8
       2 person_id = f8
       2 person_idx = i4
       2 person_prsnl_reltn_id = f8
       2 person_prsnl_r_cd = f8
       2 priority_seq = i4
       2 prsnl_person_id = f8
       2 prsnl_person_idx = i4
       2 action_flag = i2
       2 active_ind = i2
       2 active_status_cd = f8
       2 chg_str = vc
       2 data_status_cd = f8
       2 updt_cnt = i4
       2 pm_hist_tracking_id = f8
       2 transaction_dt_tm = dq8
       2 source_identifier = vc
   )
   FREE RECORD acm_reply
   RECORD acm_reply(
     1 transaction_info_qual_cnt = i4
     1 transaction_info_qual[*]
       2 transaction_id = f8
       2 pm_hist_tracking_id = f8
       2 person_id = f8
       2 person_idx = i4
       2 encntr_id = f8
       2 encntr_idx = i4
       2 status = i2
     1 address_qual_cnt = i4
     1 address_qual[*]
       2 address_id = f8
       2 status = i2
     1 encntr_alias_qual_cnt = i4
     1 encntr_alias_qual[*]
       2 encntr_alias_id = f8
       2 status = i2
     1 encntr_code_value_r_qual_cnt = i4
     1 encntr_code_value_r_qual[*]
       2 encntr_code_value_r_id = f8
       2 status = i2
     1 encntr_domain_qual_cnt = i4
     1 encntr_domain_qual[*]
       2 encntr_domain_id = f8
       2 status = i2
     1 encntr_financial_qual_cnt = i4
     1 encntr_financial_qual[*]
       2 encntr_financial_id = f8
       2 status = i2
     1 encntr_info_qual_cnt = i4
     1 encntr_info_qual[*]
       2 encntr_info_id = f8
       2 status = i2
     1 encntr_loc_hist_qual_cnt = i4
     1 encntr_loc_hist_qual[*]
       2 encntr_loc_hist_id = f8
       2 status = i2
     1 encntr_org_reltn_qual_cnt = i4
     1 encntr_org_reltn_qual[*]
       2 encntr_org_reltn_id = f8
       2 status = i2
     1 encntr_person_reltn_qual_cnt = i4
     1 encntr_person_reltn_qual[*]
       2 encntr_person_reltn_id = f8
       2 status = i2
     1 encntr_plan_reltn_qual_cnt = i4
     1 encntr_plan_reltn_qual[*]
       2 encntr_plan_reltn_id = f8
       2 status = i2
     1 encntr_prsnl_reltn_qual_cnt = i4
     1 encntr_prsnl_reltn_qual[*]
       2 encntr_prsnl_reltn_id = f8
       2 status = i2
     1 encounter_qual_cnt = i4
     1 encounter_qual[*]
       2 encntr_id = f8
       2 status = i2
     1 health_plan_qual_cnt = i4
     1 health_plan_qual[*]
       2 health_plan_id = f8
       2 status = i2
     1 person_qual_cnt = i4
     1 person_qual[*]
       2 person_id = f8
       2 status = i2
     1 person_alias_qual_cnt = i4
     1 person_alias_qual[*]
       2 person_alias_id = f8
       2 status = i2
     1 person_code_value_r_qual_cnt = i4
     1 person_code_value_r_qual[*]
       2 person_code_value_r_id = f8
       2 status = i2
     1 person_name_qual_cnt = i4
     1 person_name_qual[*]
       2 person_name_id = f8
       2 status = i2
     1 person_org_reltn_qual_cnt = i4
     1 person_org_reltn_qual[*]
       2 person_org_reltn_id = f8
       2 status = i2
     1 person_patient_qual_cnt = i4
     1 person_patient_qual[*]
       2 person_id = f8
       2 status = i2
     1 person_person_reltn_qual_cnt = i4
     1 person_person_reltn_qual[*]
       2 person_person_reltn_id = f8
       2 status = i2
     1 person_plan_reltn_qual_cnt = i4
     1 person_plan_reltn_qual[*]
       2 person_plan_reltn_id = f8
       2 status = i2
     1 person_prsnl_reltn_qual_cnt = i4
     1 person_prsnl_reltn_qual[*]
       2 person_prsnl_reltn_id = f8
       2 status = i2
     1 phone_qual_cnt = i4
     1 phone_qual[*]
       2 phone_id = f8
       2 status = i2
     1 service_category_hist_qual_cnt = i4
     1 service_category_hist_qual[*]
       2 svc_cat_hist_id = f8
       2 status = i2
     1 preprocess_qual_cnt = i4
     1 preprocess_qual[*]
       2 status = i2
     1 postprocess_qual_cnt = i4
     1 postprocess_qual[*]
       2 status = i2
     1 p_rx_plan_coverage_qual_cnt = i4
     1 person_rx_plan_coverage_qual[*]
       2 person_rx_plan_coverage_id = f8
       2 status = i2
     1 p_rx_plan_reltn_qual_cnt = i4
     1 person_rx_plan_reltn_qual[*]
       2 person_rx_plan_reltn_id = f8
       2 status = i2
     1 debug_cnt = i4
     1 debug[*]
       2 line = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
     1 error_info[1]
       2 line1 = vc
       2 line2 = vc
       2 line3 = vc
   )
   FREE RECORD xref
   RECORD xref(
     1 chg_cnt = i4
     1 chg[*]
       2 idx = i4
   )
   SET count2 = 0
   FOR (count = 1 TO data->person_prsnl_reltn_qual_cnt)
    SET acm_request->force_updt_ind = 1
    IF (count != val_exclude_index)
     SET count2 += 1
     SET stat = alterlist(acm_request->person_prsnl_reltn_qual,count2)
     SET stat = alterlist(acm_reply->person_qual,count2)
     SET stat = alterlist(xref->chg,count2)
     SET xref->chg_cnt = count2
     SET xref->chg[count2].idx = count2
     SET acm_request->person_prsnl_reltn_qual[count2].action_flag = chg_action
     SET acm_request->person_prsnl_reltn_qual[count2].chg_str = "END_EFFECTIVE_DT_TM,"
     SET acm_request->person_prsnl_reltn_qual[count2].person_prsnl_reltn_id = data->
     person_prsnl_reltn_qual[count].person_prsnl_reltn_id
     IF ((data->person_org_reltn_beg_date <= 0))
      SET acm_request->person_prsnl_reltn_qual[count2].end_effective_dt_tm = cnvtdatetime(sysdate)
     ELSE
      SET acm_request->person_prsnl_reltn_qual[count2].end_effective_dt_tm = data->
      person_org_reltn_beg_date
     ENDIF
     SET acm_request->person_prsnl_reltn_qual[count2].updt_cnt = data->person_prsnl_reltn_qual[count2
     ].updt_cnt
    ENDIF
   ENDFOR
   SET acm_reply->person_prsnl_reltn_qual_cnt = count2
   SET stat = alterlist(acm_reply->person_prsnl_reltn_qual,count2)
   IF (count2 > 0)
    EXECUTE acm_chg_person_prsnl_reltn  WITH replace("ACM_REQUEST","ACM_REQUEST"), replace("REPLY",
     "ACM_REPLY")
    IF ((acm_reply->status_data.status="F"))
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (sub_add_person_org_reltn(val_dummy=vc) =null WITH protect)
   FREE RECORD acm_request
   RECORD acm_request(
     1 use_req_updt_ind = i2
     1 person_org_reltn_qual[*]
       2 beg_effective_dt_tm = dq8
       2 contributor_system_cd = f8
       2 empl_contact = vc
       2 empl_contact_title = vc
       2 empl_hire_dt_tm = dq8
       2 empl_occupation_cd = f8
       2 empl_occupation_text = vc
       2 empl_position = vc
       2 empl_retire_dt_tm = dq8
       2 empl_status_cd = f8
       2 empl_term_dt_tm = dq8
       2 empl_title = vc
       2 empl_type_cd = f8
       2 end_effective_dt_tm = dq8
       2 free_text_ind = i2
       2 ft_org_name = vc
       2 internal_seq = i4
       2 organization_id = f8
       2 organization_idx = i4
       2 person_id = f8
       2 person_idx = i4
       2 person_org_alias = vc
       2 person_org_nbr = vc
       2 person_org_reltn_cd = f8
       2 person_org_reltn_id = f8
       2 priority_seq = i4
       2 action_flag = i2
       2 active_ind = i2
       2 active_status_cd = f8
       2 chg_str = vc
       2 data_status_cd = f8
       2 updt_cnt = i4
       2 source_identifier = vc
   )
   FREE RECORD acm_reply
   RECORD acm_reply(
     1 transaction_info_qual_cnt = i4
     1 transaction_info_qual[*]
       2 transaction_id = f8
       2 pm_hist_tracking_id = f8
       2 person_id = f8
       2 person_idx = i4
       2 encntr_id = f8
       2 encntr_idx = i4
       2 status = i2
     1 address_qual_cnt = i4
     1 address_qual[*]
       2 address_id = f8
       2 status = i2
     1 encntr_alias_qual_cnt = i4
     1 encntr_alias_qual[*]
       2 encntr_alias_id = f8
       2 status = i2
     1 encntr_code_value_r_qual_cnt = i4
     1 encntr_code_value_r_qual[*]
       2 encntr_code_value_r_id = f8
       2 status = i2
     1 encntr_domain_qual_cnt = i4
     1 encntr_domain_qual[*]
       2 encntr_domain_id = f8
       2 status = i2
     1 encntr_financial_qual_cnt = i4
     1 encntr_financial_qual[*]
       2 encntr_financial_id = f8
       2 status = i2
     1 encntr_info_qual_cnt = i4
     1 encntr_info_qual[*]
       2 encntr_info_id = f8
       2 status = i2
     1 encntr_loc_hist_qual_cnt = i4
     1 encntr_loc_hist_qual[*]
       2 encntr_loc_hist_id = f8
       2 status = i2
     1 encntr_org_reltn_qual_cnt = i4
     1 encntr_org_reltn_qual[*]
       2 encntr_org_reltn_id = f8
       2 status = i2
     1 encntr_person_reltn_qual_cnt = i4
     1 encntr_person_reltn_qual[*]
       2 encntr_person_reltn_id = f8
       2 status = i2
     1 encntr_plan_reltn_qual_cnt = i4
     1 encntr_plan_reltn_qual[*]
       2 encntr_plan_reltn_id = f8
       2 status = i2
     1 encntr_prsnl_reltn_qual_cnt = i4
     1 encntr_prsnl_reltn_qual[*]
       2 encntr_prsnl_reltn_id = f8
       2 status = i2
     1 encounter_qual_cnt = i4
     1 encounter_qual[*]
       2 encntr_id = f8
       2 status = i2
     1 health_plan_qual_cnt = i4
     1 health_plan_qual[*]
       2 health_plan_id = f8
       2 status = i2
     1 person_qual_cnt = i4
     1 person_qual[*]
       2 person_id = f8
       2 status = i2
     1 person_alias_qual_cnt = i4
     1 person_alias_qual[*]
       2 person_alias_id = f8
       2 status = i2
     1 person_code_value_r_qual_cnt = i4
     1 person_code_value_r_qual[*]
       2 person_code_value_r_id = f8
       2 status = i2
     1 person_name_qual_cnt = i4
     1 person_name_qual[*]
       2 person_name_id = f8
       2 status = i2
     1 person_org_reltn_qual_cnt = i4
     1 person_org_reltn_qual[*]
       2 person_org_reltn_id = f8
       2 status = i2
     1 person_patient_qual_cnt = i4
     1 person_patient_qual[*]
       2 person_id = f8
       2 status = i2
     1 person_person_reltn_qual_cnt = i4
     1 person_person_reltn_qual[*]
       2 person_person_reltn_id = f8
       2 status = i2
     1 person_plan_reltn_qual_cnt = i4
     1 person_plan_reltn_qual[*]
       2 person_plan_reltn_id = f8
       2 status = i2
     1 person_prsnl_reltn_qual_cnt = i4
     1 person_prsnl_reltn_qual[*]
       2 person_prsnl_reltn_id = f8
       2 status = i2
     1 phone_qual_cnt = i4
     1 phone_qual[*]
       2 phone_id = f8
       2 status = i2
     1 service_category_hist_qual_cnt = i4
     1 service_category_hist_qual[*]
       2 svc_cat_hist_id = f8
       2 status = i2
     1 preprocess_qual_cnt = i4
     1 preprocess_qual[*]
       2 status = i2
     1 postprocess_qual_cnt = i4
     1 postprocess_qual[*]
       2 status = i2
     1 p_rx_plan_coverage_qual_cnt = i4
     1 person_rx_plan_coverage_qual[*]
       2 person_rx_plan_coverage_id = f8
       2 status = i2
     1 p_rx_plan_reltn_qual_cnt = i4
     1 person_rx_plan_reltn_qual[*]
       2 person_rx_plan_reltn_id = f8
       2 status = i2
     1 debug_cnt = i4
     1 debug[*]
       2 line = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
     1 error_info[1]
       2 line1 = vc
       2 line2 = vc
       2 line3 = vc
   )
   FREE RECORD xref
   RECORD xref(
     1 add_cnt = i4
     1 add[*]
       2 idx = i4
   )
   SET count2 = 0
   IF ((request->person_id > 0)
    AND (request->gp_practice_org_id > 0))
    SET count2 += 1
    SET stat = alterlist(acm_request->person_org_reltn_qual,count2)
    SET stat = alterlist(acm_reply->person_qual,count2)
    SET stat = alterlist(xref->add,count2)
    SET xref->add_cnt = count2
    SET xref->add[count2].idx = count2
    SET acm_request->person_org_reltn_qual[count2].action_flag = add_action
    SET acm_request->person_org_reltn_qual[count2].person_id = request->person_id
    SET acm_request->person_org_reltn_qual[count2].organization_id = request->gp_practice_org_id
    SET acm_request->person_org_reltn_qual[count2].person_org_reltn_cd = reg_practice_cd
    SET acm_request->person_org_reltn_qual[count2].active_ind = 1
    SET acm_reply->person_org_reltn_qual_cnt = count2
    SET stat = alterlist(acm_reply->person_org_reltn_qual,count2)
    EXECUTE acm_add_person_org_reltn  WITH replace("ACM_REQUEST","ACM_REQUEST"), replace("REPLY",
     "ACM_REPLY")
    IF ((acm_reply->status_data.status="F"))
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (sub_add_person_prsnl_reltn(val_gp_prsnl_id=f8) =f8 WITH protect)
   SET val_add_person_prsnl_reltn_id = 0
   FREE RECORD acm_request
   RECORD acm_request(
     1 use_req_updt_ind = i2
     1 person_prsnl_reltn_qual[*]
       2 beg_effective_dt_tm = dq8
       2 contributor_system_cd = f8
       2 end_effective_dt_tm = dq8
       2 free_text_cd = f8
       2 ft_prsnl_name = vc
       2 internal_seq = i4
       2 manual_create_by_id = f8
       2 manual_create_by_idx = i4
       2 manual_create_dt_tm = dq8
       2 manual_create_ind = i2
       2 manual_inact_by_id = f8
       2 manual_inact_by_idx = i4
       2 manual_inact_dt_tm = dq8
       2 manual_inact_ind = i2
       2 notification_cd = f8
       2 person_id = f8
       2 person_idx = i4
       2 person_prsnl_reltn_id = f8
       2 person_prsnl_r_cd = f8
       2 priority_seq = i4
       2 prsnl_person_id = f8
       2 prsnl_person_idx = i4
       2 action_flag = i2
       2 active_ind = i2
       2 active_status_cd = f8
       2 chg_str = vc
       2 data_status_cd = f8
       2 updt_cnt = i4
       2 pm_hist_tracking_id = f8
       2 transaction_dt_tm = dq8
       2 source_identifier = vc
   )
   FREE RECORD acm_reply
   RECORD acm_reply(
     1 transaction_info_qual_cnt = i4
     1 transaction_info_qual[*]
       2 transaction_id = f8
       2 pm_hist_tracking_id = f8
       2 person_id = f8
       2 person_idx = i4
       2 encntr_id = f8
       2 encntr_idx = i4
       2 status = i2
     1 address_qual_cnt = i4
     1 address_qual[*]
       2 address_id = f8
       2 status = i2
     1 encntr_alias_qual_cnt = i4
     1 encntr_alias_qual[*]
       2 encntr_alias_id = f8
       2 status = i2
     1 encntr_code_value_r_qual_cnt = i4
     1 encntr_code_value_r_qual[*]
       2 encntr_code_value_r_id = f8
       2 status = i2
     1 encntr_domain_qual_cnt = i4
     1 encntr_domain_qual[*]
       2 encntr_domain_id = f8
       2 status = i2
     1 encntr_financial_qual_cnt = i4
     1 encntr_financial_qual[*]
       2 encntr_financial_id = f8
       2 status = i2
     1 encntr_info_qual_cnt = i4
     1 encntr_info_qual[*]
       2 encntr_info_id = f8
       2 status = i2
     1 encntr_loc_hist_qual_cnt = i4
     1 encntr_loc_hist_qual[*]
       2 encntr_loc_hist_id = f8
       2 status = i2
     1 encntr_org_reltn_qual_cnt = i4
     1 encntr_org_reltn_qual[*]
       2 encntr_org_reltn_id = f8
       2 status = i2
     1 encntr_person_reltn_qual_cnt = i4
     1 encntr_person_reltn_qual[*]
       2 encntr_person_reltn_id = f8
       2 status = i2
     1 encntr_plan_reltn_qual_cnt = i4
     1 encntr_plan_reltn_qual[*]
       2 encntr_plan_reltn_id = f8
       2 status = i2
     1 encntr_prsnl_reltn_qual_cnt = i4
     1 encntr_prsnl_reltn_qual[*]
       2 encntr_prsnl_reltn_id = f8
       2 status = i2
     1 encounter_qual_cnt = i4
     1 encounter_qual[*]
       2 encntr_id = f8
       2 status = i2
     1 health_plan_qual_cnt = i4
     1 health_plan_qual[*]
       2 health_plan_id = f8
       2 status = i2
     1 person_qual_cnt = i4
     1 person_qual[*]
       2 person_id = f8
       2 status = i2
     1 person_alias_qual_cnt = i4
     1 person_alias_qual[*]
       2 person_alias_id = f8
       2 status = i2
     1 person_code_value_r_qual_cnt = i4
     1 person_code_value_r_qual[*]
       2 person_code_value_r_id = f8
       2 status = i2
     1 person_name_qual_cnt = i4
     1 person_name_qual[*]
       2 person_name_id = f8
       2 status = i2
     1 person_org_reltn_qual_cnt = i4
     1 person_org_reltn_qual[*]
       2 person_org_reltn_id = f8
       2 status = i2
     1 person_patient_qual_cnt = i4
     1 person_patient_qual[*]
       2 person_id = f8
       2 status = i2
     1 person_person_reltn_qual_cnt = i4
     1 person_person_reltn_qual[*]
       2 person_person_reltn_id = f8
       2 status = i2
     1 person_plan_reltn_qual_cnt = i4
     1 person_plan_reltn_qual[*]
       2 person_plan_reltn_id = f8
       2 status = i2
     1 person_prsnl_reltn_qual_cnt = i4
     1 person_prsnl_reltn_qual[*]
       2 person_prsnl_reltn_id = f8
       2 status = i2
     1 phone_qual_cnt = i4
     1 phone_qual[*]
       2 phone_id = f8
       2 status = i2
     1 service_category_hist_qual_cnt = i4
     1 service_category_hist_qual[*]
       2 svc_cat_hist_id = f8
       2 status = i2
     1 preprocess_qual_cnt = i4
     1 preprocess_qual[*]
       2 status = i2
     1 postprocess_qual_cnt = i4
     1 postprocess_qual[*]
       2 status = i2
     1 p_rx_plan_coverage_qual_cnt = i4
     1 person_rx_plan_coverage_qual[*]
       2 person_rx_plan_coverage_id = f8
       2 status = i2
     1 p_rx_plan_reltn_qual_cnt = i4
     1 person_rx_plan_reltn_qual[*]
       2 person_rx_plan_reltn_id = f8
       2 status = i2
     1 debug_cnt = i4
     1 debug[*]
       2 line = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
     1 error_info[1]
       2 line1 = vc
       2 line2 = vc
       2 line3 = vc
   )
   FREE RECORD xref
   RECORD xref(
     1 add_cnt = i4
     1 add[*]
       2 idx = i4
   )
   SET count2 = 0
   IF ((request->person_id > 0)
    AND val_gp_prsnl_id > 0)
    SET count2 += 1
    SET stat = alterlist(acm_request->person_prsnl_reltn_qual,count2)
    SET stat = alterlist(acm_reply->person_qual,count2)
    SET stat = alterlist(xref->add,count2)
    SET xref->add_cnt = count2
    SET xref->add[count2].idx = count2
    SET acm_request->person_prsnl_reltn_qual[count2].action_flag = add_action
    SET acm_request->person_prsnl_reltn_qual[count2].person_id = request->person_id
    SET acm_request->person_prsnl_reltn_qual[count2].prsnl_person_id = val_gp_prsnl_id
    SET acm_request->person_prsnl_reltn_qual[count2].person_prsnl_r_cd = pcp_cd
    SET acm_request->person_prsnl_reltn_qual[count2].active_ind = 1
    SET acm_request->person_prsnl_reltn_qual[count2].beg_effective_dt_tm = data->
    person_org_reltn_beg_date
    SET acm_reply->person_prsnl_reltn_qual_cnt = count2
    SET stat = alterlist(acm_reply->person_prsnl_reltn_qual,count2)
    EXECUTE acm_add_person_prsnl_reltn  WITH replace("ACM_REQUEST","ACM_REQUEST"), replace("REPLY",
     "ACM_REPLY")
    IF ((acm_reply->status_data.status="F"))
     GO TO exit_script
    ELSE
     SET val_add_person_prsnl_reltn_id = acm_reply->person_prsnl_reltn_qual[count2].
     person_prsnl_reltn_id
    ENDIF
    RETURN(val_add_person_prsnl_reltn_id)
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  SET reply->status_data.status = "F"
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    SUBROUTINE (s_next_subeventstatus(s_null=i4) =i4)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 += 1
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) =i4)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus_cclerr(s_null=i4) =i4)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (s_log_subeventstatus(s_null=i4) =i4)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE (s_clear_subeventstatus(s_null=i4) =i4)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    SUBROUTINE (s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) =i2)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   SET reqinfo->commit_ind = false
   CALL s_add_subeventstatus_cclerr(1)
   CALL s_log_subeventstatus(1)
  ENDIF
 ENDIF
END GO
