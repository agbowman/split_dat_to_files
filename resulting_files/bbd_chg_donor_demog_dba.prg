CREATE PROGRAM bbd_chg_donor_demog:dba
 RECORD reply(
   1 qual[*]
     2 person_alias_id = f8
     2 person_id = f8
     2 new_person_name_id = f8
     2 person_name_id = f8
     2 pa_updt_cnt = i4
     2 alias_type = vc
     2 maiden_name_id = f8
     2 pn_updt_cnt = i4
     2 home_phone_id = f8
     2 new_home_phone_id = f8
     2 business_phone_id = f8
     2 new_business_phone_id = f8
     2 person_org_reltn_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SET modify = predeclare
 DECLARE new_person = f8 WITH protect, noconstant(0.0)
 DECLARE new_name = f8 WITH protect, noconstant(0.0)
 DECLARE new_alias = f8 WITH protect, noconstant(0.0)
 DECLARE new_nbr = f8 WITH protect, noconstant(0.0)
 DECLARE new_org = f8 WITH protect, noconstant(0.0)
 DECLARE cdf_meaning = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE donor_code = f8 WITH protect, noconstant(0.0)
 DECLARE ssn_code = f8 WITH protect, noconstant(0.0)
 DECLARE drlic_code = f8 WITH protect, noconstant(0.0)
 DECLARE data_status_code = f8 WITH protect, noconstant(0.0)
 DECLARE alias_pool_code = f8 WITH protect, noconstant(0.0)
 DECLARE current_code = f8 WITH protect, noconstant(0.0)
 DECLARE maiden_code = f8 WITH protect, noconstant(0.0)
 DECLARE previous_code = f8 WITH protect, noconstant(0.0)
 DECLARE person_type_code = f8 WITH protect, noconstant(0.0)
 DECLARE person_org_reltn_code = f8 WITH protect, noconstant(0.0)
 DECLARE home_phone_code = f8 WITH protect, noconstant(0.0)
 DECLARE business_phone_code = f8 WITH protect, noconstant(0.0)
 DECLARE y = i4 WITH protect, noconstant(0)
 DECLARE dnr_alias_id = f8 WITH protect, noconstant(0.0)
 DECLARE dnr_name_id = f8 WITH protect, noconstant(0.0)
 DECLARE dnr_id = f8 WITH protect, noconstant(0.0)
 DECLARE dnr_id_hold = f8 WITH protect, noconstant(0.0)
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE code_set = i4 WITH protect, noconstant(4)
 SET cdf_meaning = "DONORID"
 DECLARE code_cnt = i4 WITH protect, noconstant(1)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donor_code)
 SET cdf_meaning = "SSN"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,ssn_code)
 SET cdf_meaning = "DRLIC"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,drlic_code)
 SET code_set = 8
 SET cdf_meaning = "UNAUTH"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,data_status_code)
 SET alias_pool_code = 0.0
 SELECT INTO "nl:"
  p.alias_pool_cd
  FROM org_alias_pool_reltn p
  PLAN (p
   WHERE p.alias_entity_name="PERSON_ALIAS"
    AND p.alias_entity_alias_type_cd=donor_code
    AND p.active_ind=1)
  DETAIL
   alias_pool_code = p.alias_pool_cd
  WITH counter
 ;end select
 SET code_set = 213
 SET cdf_meaning = "CURRENT"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,current_code)
 SET cdf_meaning = "MAIDEN"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,maiden_code)
 SET cdf_meaning = "PREVIOUS"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,previous_code)
 SET code_set = 302
 SET cdf_meaning = "PERSON"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,person_type_code)
 SET code_set = 338
 SET cdf_meaning = "EMPLOYER"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,person_org_reltn_code)
 SET code_set = 43
 SET cdf_meaning = "HOME"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,home_phone_code)
 SET cdf_meaning = "BUSINESS"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,business_phone_code)
 IF (((donor_code=0.0) OR (((ssn_code=0.0) OR (((drlic_code=0.0) OR (((data_status_code=0.0) OR (((
 current_code=0.0) OR (((maiden_code=0.0) OR (((previous_code=0.0) OR (((person_type_code=0.0) OR (((
 person_org_reltn_code=0.0) OR (((home_phone_code=0.0) OR (business_phone_code=0.0)) )) )) )) )) ))
 )) )) )) )) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  IF (donor_code=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to read donor id code value."
  ELSEIF (ssn_code=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to read ssn code value."
  ELSEIF (drlic_code=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read drivers license code value."
  ELSEIF (data_status_code=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read data status code value."
  ELSEIF (current_code=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to read current code value."
  ELSEIF (maiden_code=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read maiden name code value."
  ELSEIF (previous_code=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to read previous code value."
  ELSEIF (person_type_code=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read person type code value."
  ELSEIF (person_org_reltn_code=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read person/orginization relationship code value."
  ELSEIF (home_phone_code=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read home phone code value."
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read business phone code value"
  ENDIF
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SET y = 0
 SET dnr_alias_id = 0.0
 SET dnr_name_id = 0.0
 SET dnr_id = 0.0
 SET dnr_id_hold = 0.0
 SET reply->status_data.status = "F"
 SET failed = "F"
 FOR (y = 1 TO request->dnr_cnt)
   IF ((request->qual[y].table_ind="PN"))
    IF ((request->qual[y].add_mod_ind="ADD"))
     SET new_person = 0.0
     SELECT INTO "nl:"
      seqn = seq(person_only_seq,nextval)
      FROM dual
      DETAIL
       new_person = seqn
      WITH format, counter
     ;end select
     IF (curqual=0)
      RETURN
     ELSE
      SET dnr_id = new_person
     ENDIF
     IF (dnr_id > 0)
      SET dnr_id_hold = dnr_id
     ELSE
      SET dnr_id_hold = request->person_id
     ENDIF
     INSERT  FROM person p
      SET p.person_id = dnr_id_hold, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
       updt_applctx,
       p.active_ind = 1, p.active_status_cd = reqdata->active_status_cd, p.active_status_prsnl_id =
       reqinfo->updt_id,
       p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.create_dt_tm = cnvtdatetime(curdate,
        curtime3), p.create_prsnl_id = 1,
       p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
        "01-dec-2100"), p.person_type_cd = person_type_code,
       p.name_last_key = cnvtalphanum(cnvtupper(request->qual[y].name_last)), p.name_first_key =
       cnvtalphanum(cnvtupper(request->qual[y].name_first)), p.name_middle_key = cnvtalphanum(
        cnvtupper(request->qual[y].name_middle)),
       p.name_full_formatted = concat(trim(request->qual[y].name_last),", ",trim(request->qual[y].
         name_first)," ",trim(request->qual[y].name_middle)), p.autopsy_cd = 0, p.birth_dt_cd = 0,
       p.birth_dt_tm = cnvtdatetime(request->qual[y].birth_dt_tm), p.conception_dt_tm = null, p
       .cause_of_death = null,
       p.deceased_cd = 0, p.deceased_dt_tm = null, p.ethnic_grp_cd = 0,
       p.language_cd = 0, p.marital_type_cd = request->qual[y].marital_type_cd, p.purge_option_cd = 0,
       p.race_cd = request->qual[y].race_cd, p.religion_cd = 0, p.sex_cd = request->qual[y].sex_cd,
       p.sex_age_change_ind = 0, p.data_status_cd = reqdata->data_status_cd, p.data_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       p.data_status_prsnl_id = reqinfo->updt_id, p.contributor_system_cd = 0, p.language_dialect_cd
        = 0,
       p.name_last = request->qual[y].name_last, p.name_first = request->qual[y].name_first, p
       .name_phonetic = soundex(cnvtupper(cnvtalphanum(concat(request->qual[y].name_last,request->
           qual[y].name_first)))),
       p.last_encntr_dt_tm = null, p.species_cd = request->qual[y].species_cd, p.confid_level_cd = 0,
       p.vip_cd = 0, p.name_first_synonym_id = 0, p.citizenship_cd = 0,
       p.vet_military_status_cd = 0, p.mother_maiden_name = null, p.nationality_cd = request->qual[y]
       .nationality_cd,
       p.ft_entity_name = null, p.ft_entity_id = 0, p.name_middle = request->qual[y].name_middle
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Insert"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to insert into the person table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 2
      GO TO exit_script
     ELSE
      SET stat = alterlist(reply->qual,y)
      SET reply->qual[y].person_id = dnr_id_hold
     ENDIF
     SET new_name = 0.0
     SELECT INTO "nl:"
      seqn = seq(person_seq,nextval)
      FROM dual
      DETAIL
       new_name = seqn
      WITH format, counter
     ;end select
     IF (curqual=0)
      RETURN
     ELSE
      SET dnr_name_id = new_name
     ENDIF
     IF (dnr_id > 0)
      SET dnr_id_hold = dnr_id
     ELSE
      SET dnr_id_hold = request->person_id
     ENDIF
     INSERT  FROM person_name pn
      SET pn.person_name_id = dnr_name_id, pn.person_id = dnr_id_hold, pn.name_type_cd = current_code,
       pn.updt_cnt = 0, pn.updt_dt_tm = cnvtdatetime(curdate,curtime3), pn.updt_id = reqinfo->updt_id,
       pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->updt_applctx, pn.active_ind = 1,
       pn.active_status_cd = reqdata->inactive_status_cd, pn.active_status_dt_tm = cnvtdatetime(
        curdate,curtime3), pn.active_status_prsnl_id = reqinfo->updt_id,
       pn.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pn.end_effective_dt_tm = cnvtdatetime
       ("31-DEC-2100 00:00:00.00"), pn.name_original = "",
       pn.name_format_cd = 0, pn.name_full = concat(trim(request->qual[y].name_last),", ",trim(
         request->qual[y].name_first)," ",trim(request->qual[y].name_middle)), pn.name_first =
       request->qual[y].name_first,
       pn.name_middle = request->qual[y].name_middle, pn.name_last = request->qual[y].name_last, pn
       .name_degree = "",
       pn.name_title = "", pn.name_prefix = "", pn.name_suffix = "",
       pn.name_initials = "", pn.data_status_cd = reqdata->data_status_cd, pn.data_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       pn.data_status_prsnl_id = reqinfo->updt_id, pn.contributor_system_cd = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Insert"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_NAME"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to insert into the person_name table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 5
      GO TO exit_script
     ELSE
      SET stat = alterlist(reply->qual,y)
      SET reply->qual[y].person_id = dnr_id_hold
      SET reply->qual[y].new_person_name_id = dnr_name_id
      SET reply->qual[y].pn_updt_cnt = 0
     ENDIF
    ELSE
     SELECT INTO "nl:"
      p.*
      FROM person p
      WHERE (p.person_id=request->person_id)
       AND (p.updt_cnt=request->qual[y].p_updt_cnt)
      WITH counter, forupdate(p)
     ;end select
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Lock"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to lock the person table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 6
      GO TO exit_script
     ENDIF
     IF (dnr_id > 0)
      SET dnr_id_hold = dnr_id
     ELSE
      SET dnr_id_hold = request->person_id
     ENDIF
     UPDATE  FROM person p
      SET p.updt_cnt = (request->qual[y].p_updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3
        ), p.updt_id = reqinfo->updt_id,
       p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.name_last_key =
       cnvtalphanum(cnvtupper(request->qual[y].name_last)),
       p.name_first_key = cnvtalphanum(cnvtupper(request->qual[y].name_first)), p.name_middle_key =
       cnvtalphanum(cnvtupper(request->qual[y].name_middle)), p.name_full_formatted = concat(trim(
         request->qual[y].name_last),", ",trim(request->qual[y].name_first)," ",trim(request->qual[y]
         .name_middle)),
       p.birth_dt_tm = cnvtdatetime(request->qual[y].birth_dt_tm), p.marital_type_cd = request->qual[
       y].marital_type_cd, p.race_cd = request->qual[y].race_cd,
       p.sex_cd = request->qual[y].sex_cd, p.species_cd = request->qual[y].species_cd, p
       .nationality_cd = request->qual[y].nationality_cd,
       p.name_last = request->qual[y].name_last, p.name_first = request->qual[y].name_first, p
       .name_middle = request->qual[y].name_middle
      WHERE (p.person_id=request->person_id)
       AND (p.updt_cnt=request->qual[y].p_updt_cnt)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Update"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to update the person table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 7
      GO TO exit_script
     ELSE
      SET stat = alterlist(reply->qual,y)
      SET reply->qual[y].person_id = request->person_id
     ENDIF
     IF ((request->qual[y].dnr_name_chg="Y"))
      SELECT INTO "nl:"
       pn.*
       FROM person_name pn
       WHERE (pn.person_name_id=request->qual[y].person_name_id)
        AND (pn.updt_cnt=request->qual[y].pn_updt_cnt)
       WITH counter, forupdate(pn)
      ;end select
      IF (curqual=0)
       SET failed = "T"
       SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
       SET reply->status_data.subeventstatus[1].operationname = "Lock"
       SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_NAME"
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Unable to lock the person_name table."
       SET reply->status_data.subeventstatus[1].sourceobjectqual = 8
       GO TO exit_script
      ENDIF
      IF (dnr_id > 0)
       SET dnr_id_hold = dnr_id
      ELSE
       SET dnr_id_hold = request->person_id
      ENDIF
      UPDATE  FROM person_name pn
       SET pn.updt_cnt = (request->qual[y].pn_updt_cnt+ 1), pn.updt_dt_tm = cnvtdatetime(curdate,
         curtime3), pn.updt_id = reqinfo->updt_id,
        pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->updt_applctx, pn.name_type_cd
         = previous_code
       WHERE (pn.person_name_id=request->qual[y].person_name_id)
        AND (pn.updt_cnt=request->qual[y].pn_updt_cnt)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET failed = "T"
       SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
       SET reply->status_data.subeventstatus[1].operationname = "Update"
       SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_NAME"
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Unable to update the person_name table."
       SET reply->status_data.subeventstatus[1].sourceobjectqual = 9
       GO TO exit_script
      ELSE
       SET stat = alterlist(reply->qual,y)
       SET reply->qual[y].person_name_id = request->qual[y].person_name_id
       SET reply->qual[y].person_id = request->person_id
      ENDIF
      SET new_name = 0.0
      SELECT INTO "nl:"
       seqn = seq(person_seq,nextval)
       FROM dual
       DETAIL
        new_name = seqn
       WITH format, counter
      ;end select
      IF (curqual=0)
       RETURN
      ELSE
       SET dnr_name_id = new_name
      ENDIF
      IF (dnr_id > 0)
       SET dnr_id_hold = dnr_id
      ELSE
       SET dnr_id_hold = request->person_id
      ENDIF
      INSERT  FROM person_name pn
       SET pn.person_name_id = dnr_name_id, pn.person_id = request->person_id, pn.name_type_cd =
        current_code,
        pn.updt_cnt = 0, pn.updt_dt_tm = cnvtdatetime(curdate,curtime3), pn.updt_id = reqinfo->
        updt_id,
        pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->updt_applctx, pn.active_ind = 1,
        pn.active_status_cd = reqdata->inactive_status_cd, pn.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3), pn.active_status_prsnl_id = reqinfo->updt_id,
        pn.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pn.end_effective_dt_tm =
        cnvtdatetime("31-DEC-2100 00:00:00.00"), pn.name_original = "",
        pn.name_format_cd = 0, pn.name_full = concat(trim(request->qual[y].name_last),", ",trim(
          request->qual[y].name_first)," ",trim(request->qual[y].name_middle)), pn.name_first =
        request->qual[y].name_first,
        pn.name_middle = request->qual[y].name_middle, pn.name_last = request->qual[y].name_last, pn
        .name_degree = "",
        pn.name_title = "", pn.name_prefix = "", pn.name_suffix = "",
        pn.name_initials = "", pn.data_status_cd = reqdata->data_status_cd, pn.data_status_dt_tm =
        cnvtdatetime(curdate,curtime3),
        pn.data_status_prsnl_id = reqinfo->updt_id, pn.contributor_system_cd = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failed = "T"
       SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
       SET reply->status_data.subeventstatus[1].operationname = "Insert"
       SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_NAME"
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Unable to insert into the person_name table."
       SET reply->status_data.subeventstatus[1].sourceobjectqual = 10
       GO TO exit_script
      ELSE
       SET stat = alterlist(reply->qual,y)
       SET reply->qual[y].new_person_name_id = dnr_name_id
       SET reply->qual[y].person_id = request->person_id
       SET reply->qual[y].pn_updt_cnt = 0
      ENDIF
     ENDIF
    ENDIF
   ELSEIF ((request->qual[y].table_ind="PNM"))
    IF ((request->qual[y].add_mod_ind="ADD"))
     SET new_name = 0.0
     SELECT INTO "nl:"
      seqn = seq(person_seq,nextval)
      FROM dual
      DETAIL
       new_name = seqn
      WITH format, counter
     ;end select
     IF (curqual=0)
      RETURN
     ELSE
      SET dnr_name_id = new_name
     ENDIF
     IF (dnr_id > 0)
      SET dnr_id_hold = dnr_id
     ELSE
      SET dnr_id_hold = request->person_id
     ENDIF
     INSERT  FROM person_name pn
      SET pn.person_name_id = dnr_name_id, pn.person_id = dnr_id_hold, pn.name_type_cd = maiden_code,
       pn.updt_cnt = 0, pn.updt_dt_tm = cnvtdatetime(curdate,curtime3), pn.updt_id = reqinfo->updt_id,
       pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->updt_applctx, pn.active_ind = 1,
       pn.active_status_cd = reqdata->inactive_status_cd, pn.active_status_dt_tm = cnvtdatetime(
        curdate,curtime3), pn.active_status_prsnl_id = reqinfo->updt_id,
       pn.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pn.end_effective_dt_tm = cnvtdatetime
       ("31-DEC-2100 00:00:00.00"), pn.name_original = "",
       pn.name_format_cd = 0, pn.name_full = request->qual[y].name_maiden, pn.name_first = "",
       pn.name_middle = "", pn.name_last = "", pn.name_degree = "",
       pn.name_title = "", pn.name_prefix = "", pn.name_suffix = "",
       pn.name_initials = "", pn.data_status_cd = reqdata->data_status_cd, pn.data_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       pn.data_status_prsnl_id = reqinfo->updt_id, pn.contributor_system_cd = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Insert"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_NAME"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to insert into the person_name table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 11
      GO TO exit_script
     ELSE
      SET stat = alterlist(reply->qual,y)
      SET reply->qual[y].maiden_name_id = dnr_name_id
      SET reply->qual[y].person_id = dnr_id_hold
      SET reply->qual[y].pn_updt_cnt = 0
     ENDIF
    ELSE
     SELECT INTO "nl:"
      pn.*
      FROM person_name pn
      WHERE (pn.person_name_id=request->qual[y].person_name_id)
       AND (pn.updt_cnt=request->qual[y].pn_updt_cnt)
      WITH counter, forupdate(pn)
     ;end select
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Lock"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_NAME"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to lock the person_name table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 12
      GO TO exit_script
     ENDIF
     IF (dnr_id > 0)
      SET dnr_id_hold = dnr_id
     ELSE
      SET dnr_id_hold = request->person_id
     ENDIF
     UPDATE  FROM person_name pn
      SET pn.updt_cnt = (request->qual[y].pn_updt_cnt+ 1), pn.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), pn.updt_id = reqinfo->updt_id,
       pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->updt_applctx, pn.active_ind = 0
      WHERE (pn.person_name_id=request->qual[y].person_name_id)
       AND (pn.updt_cnt=request->qual[y].pn_updt_cnt)
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Update"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_NAME"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to update the person_name table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 13
      GO TO exit_script
     ELSE
      SET stat = alterlist(reply->qual,y)
      SET reply->qual[y].person_name_id = request->person_name_id
      SET reply->qual[y].person_id = request->person_id
     ENDIF
     SET new_name = 0.0
     SELECT INTO "nl:"
      seqn = seq(person_seq,nextval)
      FROM dual
      DETAIL
       new_name = seqn
      WITH format, counter
     ;end select
     IF (curqual=0)
      RETURN
     ELSE
      SET dnr_name_id = new_name
     ENDIF
     IF (dnr_id > 0)
      SET dnr_id_hold = dnr_id
     ELSE
      SET dnr_id_hold = request->person_id
     ENDIF
     INSERT  FROM person_name pn
      SET pn.person_name_id = dnr_name_id, pn.person_id = request->person_id, pn.name_type_cd =
       maiden_code,
       pn.updt_cnt = 0, pn.updt_dt_tm = cnvtdatetime(curdate,curtime3), pn.updt_id = reqinfo->updt_id,
       pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->updt_applctx, pn.active_ind = 1,
       pn.active_status_cd = reqdata->inactive_status_cd, pn.active_status_dt_tm = cnvtdatetime(
        curdate,curtime3), pn.active_status_prsnl_id = reqinfo->updt_id,
       pn.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pn.end_effective_dt_tm = cnvtdatetime
       ("31-DEC-2100 00:00:00.00"), pn.name_original = "",
       pn.name_format_cd = 0, pn.name_full = request->qual[y].name_maiden, pn.name_first = "",
       pn.name_middle = "", pn.name_last = "", pn.name_degree = "",
       pn.name_title = "", pn.name_prefix = "", pn.name_suffix = "",
       pn.name_initials = "", pn.data_status_cd = reqdata->data_status_cd, pn.data_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       pn.data_status_prsnl_id = reqinfo->updt_id, pn.contributor_system_cd = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Insert"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_NAME"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to insert into the person_name table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 14
      GO TO exit_script
     ELSE
      SET stat = alterlist(reply->qual,y)
      SET reply->qual[y].maiden_name_id = dnr_name_id
      SET reply->qual[y].person_id = request->person_id
      SET reply->qual[y].pn_updt_cnt = 0
     ENDIF
    ENDIF
   ELSEIF ((request->qual[y].table_ind="PA"))
    IF ((request->qual[y].add_mod_ind="ADD"))
     SET new_alias = 0.0
     SELECT INTO "nl:"
      seqn = seq(person_seq,nextval)
      FROM dual
      DETAIL
       new_alias = seqn
      WITH format, counter
     ;end select
     IF (curqual=0)
      RETURN
     ELSE
      SET dnr_alias_id = new_alias
     ENDIF
     IF (dnr_id > 0)
      SET dnr_id_hold = dnr_id
     ELSE
      SET dnr_id_hold = request->person_id
     ENDIF
     INSERT  FROM person_alias pa
      SET pa.person_alias_id = dnr_alias_id, pa.person_id = dnr_id_hold, pa.updt_cnt = 0,
       pa.updt_dt_tm = cnvtdatetime(curdate,curtime3), pa.updt_id = reqinfo->updt_id, pa.updt_task =
       reqinfo->updt_task,
       pa.updt_applctx = reqinfo->updt_applctx, pa.active_ind = 1, pa.active_status_cd = reqdata->
       active_status_cd,
       pa.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pa.active_status_prsnl_id = reqinfo->
       updt_id, pa.alias_pool_cd = alias_pool_code,
       pa.person_alias_type_cd =
       IF ((request->qual[y].alias_type="DONORID")) donor_code
       ELSEIF ((request->qual[y].alias_type="SSN")) ssn_code
       ELSEIF ((request->qual[y].alias_type="DRLIC")) drlic_code
       ENDIF
       , pa.alias = cnvtupper(request->qual[y].alias), pa.person_alias_sub_type_cd = 0,
       pa.check_digit = 0, pa.check_digit_method_cd = 0, pa.beg_effective_dt_tm = cnvtdatetime(
        curdate,curtime3),
       pa.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), pa.data_status_cd = reqdata
       ->data_status_cd, pa.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
       pa.data_status_prsnl_id = reqinfo->updt_id, pa.contributor_system_cd = 0, pa.visit_seq_nbr = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Insert"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_ALIAS"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to insert into the person_alias table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 15
      GO TO exit_script
     ELSE
      SET stat = alterlist(reply->qual,y)
      SET reply->qual[y].person_alias_id = dnr_alias_id
      SET reply->qual[y].person_id = dnr_id_hold
      SET reply->qual[y].alias_type = request->qual[y].alias_type
      SET reply->qual[y].pa_updt_cnt = 0
     ENDIF
    ELSE
     SELECT INTO "nl:"
      pa.*
      FROM person_alias pa
      WHERE (pa.person_alias_id=request->qual[y].person_alias_id)
       AND (pa.updt_cnt=request->qual[y].pa_updt_cnt)
      WITH counter, forupdate(pa)
     ;end select
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Lock"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_ALIAS"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to lock the person_alias table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 16
      GO TO exit_script
     ENDIF
     IF (dnr_id > 0)
      SET dnr_id_hold = dnr_id
     ELSE
      SET dnr_id_hold = request->person_id
     ENDIF
     UPDATE  FROM person_alias pa
      SET pa.updt_cnt = (request->qual[y].pa_updt_cnt+ 1), pa.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), pa.updt_id = reqinfo->updt_id,
       pa.updt_task = reqinfo->updt_task, pa.updt_applctx = reqinfo->updt_applctx, pa.alias =
       cnvtupper(request->qual[y].alias)
      WHERE (pa.person_alias_id=request->qual[y].person_alias_id)
       AND (pa.updt_cnt=request->qual[y].pa_updt_cnt)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Update"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_ALIAS"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to update the person_alias table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 17
      GO TO exit_script
     ELSE
      SET stat = alterlist(reply->qual,y)
      SET reply->qual[y].person_alias_id = request->qual[y].person_alias_id
      SET reply->qual[y].person_id = request->person_id
      SET reply->qual[y].alias_type = cnvtupper(request->qual[y].alias_type)
      SET reply->qual[y].pa_updt_cnt = (request->qual[y].pa_updt_cnt+ 1)
     ENDIF
    ENDIF
   ELSEIF ((((request->qual[y].table_ind="HP")) OR ((request->qual[y].table_ind="BP"))) )
    IF ((request->qual[y].add_mod_ind="ADD"))
     SET new_nbr = 0.0
     SELECT INTO "nl:"
      seqn = seq(phone_seq,nextval)
      FROM dual
      DETAIL
       new_nbr = seqn
      WITH format, counter
     ;end select
     IF (dnr_id > 0)
      SET dnr_id_hold = dnr_id
     ELSE
      SET dnr_id_hold = request->person_id
     ENDIF
     INSERT  FROM phone p
      SET p.phone_id = new_nbr, p.parent_entity_name = "PERSON", p.parent_entity_id = dnr_id_hold,
       p.phone_type_cd =
       IF ((request->qual[y].table_ind="HP")) home_phone_code
       ELSE business_phone_code
       ENDIF
       , p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
       updt_applctx,
       p.active_ind = 1, p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       p.active_status_prsnl_id = reqinfo->updt_id, p.phone_format_cd = 0, p.phone_num =
       IF ((request->qual[y].table_ind="HP")) request->qual[y].home_phone
       ELSE request->qual[y].business_phone
       ENDIF
       ,
       p.phone_type_seq = 1, p.description = "", p.contact = "",
       p.call_instruction = "", p.modem_capability_cd = 0, p.extension = "",
       p.paging_code = "", p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p
       .end_effective_dt_tm = cnvtdatetime("01-dec-2100"),
       p.data_status_cd = reqdata->data_status_cd, p.data_status_dt_tm = cnvtdatetime(curdate,
        curtime3), p.data_status_prsnl_id = reqinfo->updt_id,
       p.beg_effective_mm_dd = null, p.end_effective_mm_dd = null, p.contributor_system_cd = 0,
       p.operation_hours = ""
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Insert"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PHONE"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to insert into the phone table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 18
      GO TO exit_script
     ELSE
      SET stat = alterlist(reply->qual,y)
      SET reply->qual[y].person_id = dnr_id_hold
      IF ((request->qual[y].table_ind="HP"))
       SET reply->qual[y].new_home_phone_id = new_nbr
      ELSE
       SET reply->qual[y].new_business_phone_id = new_nbr
      ENDIF
     ENDIF
    ELSE
     SET phone_id_hold = 0.0
     SET phone_updt_cnt_hold = 0.0
     IF ((request->qual[y].table_ind="HP"))
      SET phone_id_hold = request->qual[y].home_phone_id
      SET phone_updt_cnt_hold = request->qual[y].ph_home_updt_cnt
     ELSE
      SET phone_id_hold = request->qual[y].business_phone_id
      SET phone_updt_cnt_hold = request->qual[y].ph_business_updt_cnt
     ENDIF
     SELECT INTO "nl:"
      ph.*
      FROM phone ph
      WHERE ph.phone_id=phone_id_hold
       AND ph.updt_cnt=phone_updt_cnt_hold
      WITH counter, forupdate(ph)
     ;end select
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Lock"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PHONE"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to lock the phone table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 19
      GO TO exit_script
     ENDIF
     UPDATE  FROM phone ph
      SET ph.updt_cnt = (phone_updt_cnt_hold+ 1), ph.updt_dt_tm = cnvtdatetime(curdate,curtime3), ph
       .updt_id = reqinfo->updt_id,
       ph.updt_task = reqinfo->updt_task, ph.updt_applctx = reqinfo->updt_task, ph.active_ind = 0
      WHERE ph.phone_id=phone_id_hold
       AND ph.updt_cnt=phone_updt_cnt_hold
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Update"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PHONE"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to update the phone table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 20
      GO TO exit_script
     ELSE
      SET stat = alterlist(reply->qual,y)
      SET reply->qual[y].person_id = request->person_id
      IF ((request->qual[y].table_ind="HP"))
       SET reply->qual[y].home_phone_id = request->qual[y].home_phone_id
      ELSE
       SET reply->qual[y].business_phone_id = request->qual[y].business_phone_id
      ENDIF
     ENDIF
     SET new_nbr = 0.0
     SELECT INTO "nl:"
      seqn = seq(phone_seq,nextval)
      FROM dual
      DETAIL
       new_nbr = seqn
      WITH format, counter
     ;end select
     IF (dnr_id > 0)
      SET dnr_id_hold = dnr_id
     ELSE
      SET dnr_id_hold = request->person_id
     ENDIF
     INSERT  FROM phone p
      SET p.phone_id = new_nbr, p.parent_entity_name = "PERSON", p.parent_entity_id = dnr_id_hold,
       p.phone_type_cd =
       IF ((request->qual[y].table_ind="HP")) home_phone_code
       ELSE business_phone_code
       ENDIF
       , p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
       updt_applctx,
       p.active_ind = 1, p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       p.active_status_prsnl_id = reqinfo->updt_id, p.phone_format_cd = 0, p.phone_num =
       IF ((request->qual[y].table_ind="HP")) request->qual[y].home_phone
       ELSE request->qual[y].business_phone
       ENDIF
       ,
       p.phone_type_seq = 1, p.description = "", p.contact = "",
       p.call_instruction = "", p.modem_capability_cd = 0, p.extension = "",
       p.paging_code = "", p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p
       .end_effective_dt_tm = cnvtdatetime("01-dec-2100"),
       p.data_status_cd = reqdata->data_status_cd, p.data_status_dt_tm = cnvtdatetime(curdate,
        curtime3), p.data_status_prsnl_id = reqinfo->updt_id,
       p.beg_effective_mm_dd = null, p.end_effective_mm_dd = null, p.contributor_system_cd = 0,
       p.operation_hours = ""
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Insert"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PHONE"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to update the phone table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 21
      GO TO exit_script
     ELSE
      SET stat = alterlist(reply->qual,y)
      SET reply->qual[y].person_id = request->person_id
      IF ((request->qual[y].table_ind="HP"))
       SET reply->qual[y].new_home_phone_id = new_nbr
      ELSE
       SET reply->qual[y].new_business_phone_id = new_nbr
      ENDIF
     ENDIF
    ENDIF
   ELSEIF ((request->qual[y].table_ind="EMP"))
    IF ((request->qual[y].add_mod_ind="ADD"))
     SET new_org = 0.0
     SELECT INTO "nl:"
      seqn = seq(person_seq,nextval)
      FROM dual
      DETAIL
       new_org = seqn
      WITH format, counter
     ;end select
     IF (curqual=0)
      RETURN
     ELSE
      SET org_id = new_org
     ENDIF
     IF (dnr_id > 0)
      SET dnr_id_hold = dnr_id
     ELSE
      SET dnr_id_hold = request->person_id
     ENDIF
     INSERT  FROM person_org_reltn por
      SET por.person_org_reltn_id = org_id, por.person_id = dnr_id_hold, por.person_org_reltn_cd =
       person_org_reltn_code,
       por.organization_id = request->qual[y].organization_id, por.updt_cnt = 0, por.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       por.updt_id = reqinfo->updt_id, por.updt_task = reqinfo->updt_task, por.updt_applctx = reqinfo
       ->updt_applctx,
       por.active_ind = 1, por.active_status_cd = reqdata->active_status_cd, por.active_status_dt_tm
        = cnvtdatetime(curdate,curtime3),
       por.active_status_prsnl_id = reqinfo->updt_id, por.beg_effective_dt_tm = cnvtdatetime(curdate,
        curtime3), por.end_effective_dt_tm = cnvtdatetime("01-dec-2100"),
       por.data_status_cd = reqdata->data_status_cd, por.data_status_dt_tm = cnvtdatetime(curdate,
        curtime3), por.data_status_prsnl_id = reqinfo->updt_id,
       por.contributor_system_cd = 0, por.person_org_nbr = null, por.person_org_alias = null,
       por.empl_type_cd = 0, por.empl_status_cd = 0, por.empl_occupation_text = null,
       por.empl_occupation_cd = 0, por.empl_title = null, por.empl_position = null,
       por.empl_contact = null, por.empl_contact_title = null, por.free_text_ind = 0,
       por.ft_org_name = null, por.priority_seq = 0, por.internal_seq = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Insert"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_ORG_RELTN"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to insert into the person_org_reltn table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 22
      GO TO exit_script
     ELSE
      SET stat = alterlist(reply->qual,y)
      SET reply->qual[y].person_id = dnr_id_hold
      SET reply->qual[y].person_org_reltn_id = org_id
     ENDIF
    ELSE
     SELECT INTO "nl:"
      por.*
      FROM person_org_reltn por
      WHERE (por.person_org_reltn_id=request->qual[y].person_org_reltn_id)
       AND (por.updt_cnt=request->qual[y].por_updt_cnt)
      WITH counter, forupdate(por)
     ;end select
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Lock"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_ORG_RELTN"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to lock the person_org_reltn table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 23
      GO TO exit_script
     ENDIF
     UPDATE  FROM person_org_reltn por
      SET por.organization_id = request->qual[y].organization_id, por.updt_cnt = (request->qual[y].
       por_updt_cnt+ 1), por.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       por.updt_id = reqinfo->updt_id, por.updt_task = reqinfo->updt_task, por.updt_applctx = reqinfo
       ->updt_applctx,
       por.active_ind =
       IF ((request->qual[y].organization_id=0)) 0
       ELSE 1
       ENDIF
      WHERE (por.person_org_reltn_id=request->qual[y].person_org_reltn_id)
       AND (por.updt_cnt=request->qual[y].por_updt_cnt)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Update"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_ORG_RELTN"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to update the person_org_reltn table."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 24
      GO TO exit_script
     ELSE
      SET stat = alterlist(reply->qual,y)
      SET reply->qual[y].person_org_reltn_id = request->qual[y].person_org_reltn_id
     ENDIF
    ENDIF
   ENDIF
   IF ((reply->qual[y].person_id=0))
    SET stat = alterlist(reply->qual,y)
    SET reply->qual[y].person_id = request->person_id
   ENDIF
   SELECT INTO "nl:"
    pd.person_id
    FROM person_donor pd
    PLAN (pd
     WHERE (pd.person_id=reply->qual[y].person_id))
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM person_donor pd
     SET pd.person_id = reply->qual[y].person_id, pd.lock_ind = 0, pd.active_ind = 1,
      pd.active_status_cd = reqdata->active_status_cd, pd.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), pd.active_status_prsnl_id = reqinfo->updt_id,
      pd.updt_applctx = reqinfo->updt_applctx, pd.updt_dt_tm = cnvtdatetime(curdate,curtime3), pd
      .updt_id = reqinfo->updt_id,
      pd.updt_task = reqinfo->updt_task, pd.updt_cnt = 0, pd.rare_donor_cd = 0,
      pd.willingness_level_cd = 0, pd.eligibility_type_cd = 0, pd.defer_until_dt_tm = null,
      pd.spec_dnr_interest_cd = 0, pd.elig_for_reinstate_ind = 0, pd.counseling_reqrd_cd = 0,
      pd.reinstated_ind = 0, pd.reinstated_dt_tm = null, pd.watch_ind = 0,
      pd.watch_reason_cd = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_donor_demog.prg"
     SET reply->status_data.subeventstatus[1].operationname = "Insert"
     SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_DONOR"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Unable to insert into the person_donor table."
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 3
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "Failure"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "Success"
 ENDIF
END GO
