CREATE PROGRAM bbd_add_hist_donor:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD tempdonoreligdttm(
   1 eligible_dt_tm = dq8
 )
 RECORD tempeligibledttm(
   1 eligible_dt_tm = dq8
 )
 DECLARE sscript_name = c25 WITH protect, constant("BBD_ADD_HIST_DONOR")
 DECLARE leligibility_type_code_set = i4 WITH protect, constant(14237)
 DECLARE lwillingness_level_code_set = i4 WITH protect, constant(14236)
 DECLARE lcontact_method_code_set = i4 WITH protect, constant(14222)
 DECLARE llocation_code_set = i4 WITH protect, constant(220)
 DECLARE lstandard_aborh_code_set = i4 WITH protect, constant(1640)
 DECLARE labo_only_code_set = i4 WITH protect, constant(1641)
 DECLARE lrh_only_code_set = i4 WITH protect, constant(1642)
 DECLARE laborh_result_code_set = i4 WITH protect, constant(1643)
 DECLARE lspecial_testing_code_set = i4 WITH protect, constant(1612)
 DECLARE lantibody_code_set = i4 WITH protect, constant(1613)
 DECLARE lrare_type_code_set = i4 WITH protect, constant(14235)
 DECLARE lspecial_interest_code_set = i4 WITH protect, constant(14238)
 DECLARE lcomment_type_code_set = i4 WITH protect, constant(14)
 DECLARE lcontact_type_code_set = i4 WITH protect, constant(14220)
 DECLARE lcontact_outcome_code_set = i4 WITH protect, constant(14221)
 DECLARE lprocedure_code_set = i4 WITH protect, constant(14219)
 DECLARE lvenipuncture_site_code_set = i4 WITH protect, constant(1028)
 DECLARE lbag_type_code_set = i4 WITH protect, constant(1665)
 DECLARE lspecimen_unit_meas_code_set = i4 WITH protect, constant(54)
 DECLARE lreason_code_set = i4 WITH protect, constant(14223)
 DECLARE lcontact_status_code_set = i4 WITH protect, constant(14224)
 DECLARE sabo_only = c12 WITH protect, constant("ABOOnly_cd")
 DECLARE srh_only = c12 WITH protect, constant("RhOnly_cd")
 DECLARE saborh = c12 WITH protect, constant("ABORH_cd")
 DECLARE sdonor_comment_cdf_mean = c12 WITH protect, constant("DONOR")
 DECLARE sconfidential_comment_cdf_mean = c12 WITH protect, constant("DNRCONFIDNTL")
 DECLARE scounsel_comment_cdf_mean = c12 WITH protect, constant("DNRCOUNSEL")
 DECLARE sdonation_comment_cdf_mean = c12 WITH protect, constant("DNRDONATION")
 DECLARE sgood_cdf_mean = c12 WITH protect, constant("GOOD")
 DECLARE stemp_defer_cdf_mean = c12 WITH protect, constant("TEMP")
 DECLARE sperm_defer_cdf_mean = c12 WITH protect, constant("PERMNENT")
 DECLARE scontact_complete_cdf_mean = c12 WITH protect, constant("COMPLETE")
 DECLARE sdonate_cdf_mean = c12 WITH protect, constant("DONATE")
 DECLARE sconfidential_cdf_mean = c12 WITH protect, constant("CONFIDENTIAL")
 DECLARE scounsel_cdf_mean = c12 WITH protect, constant("COUNSEL")
 DECLARE ssuccess_outcome_cdf_mean = c12 WITH protect, constant("SUCCESS")
 DECLARE stemp_defer_outcome_cdf_mean = c12 WITH protect, constant("TEMPDEF")
 DECLARE sperm_defer_outcome_cdf_mean = c12 WITH protect, constant("PERMDEF")
 DECLARE nabo_discrep_type_flag = i2 WITH protect, constant(1)
 DECLARE nelig_level_discrep_type_flag = i2 WITH protect, constant(2)
 DECLARE nelig_donors_discrep_type_flag = i2 WITH protect, constant(3)
 DECLARE serrormsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE nerror_check = i2 WITH protect, noconstant(error(serrormsg,1))
 DECLARE ldonor_count = i4 WITH protect, noconstant(size(request->donors,5))
 DECLARE ldonor_index = i4 WITH protect, noconstant(0)
 DECLARE lantigen_count = i4 WITH protect, noconstant(0)
 DECLARE lantigen_index = i4 WITH protect, noconstant(0)
 DECLARE lantibody_count = i4 WITH protect, noconstant(0)
 DECLARE lantibody_index = i4 WITH protect, noconstant(0)
 DECLARE lrare_type_count = i4 WITH protect, noconstant(0)
 DECLARE lrare_type_index = i4 WITH protect, noconstant(0)
 DECLARE lspecial_interest_count = i4 WITH protect, noconstant(0)
 DECLARE lspecial_interest_index = i4 WITH protect, noconstant(0)
 DECLARE ldonor_note_count = i4 WITH protect, noconstant(0)
 DECLARE ldonor_note_index = i4 WITH protect, noconstant(0)
 DECLARE lsecured_note_count = i4 WITH protect, noconstant(0)
 DECLARE lsecured_note_index = i4 WITH protect, noconstant(0)
 DECLARE lcontact_count = i4 WITH protect, noconstant(0)
 DECLARE lcontact_index = i4 WITH protect, noconstant(0)
 DECLARE lproduct_count = i4 WITH protect, noconstant(0)
 DECLARE lproduct_index = i4 WITH protect, noconstant(0)
 DECLARE ldefer_reason_count = i4 WITH protect, noconstant(0)
 DECLARE ldefer_reason_index = i4 WITH protect, noconstant(0)
 DECLARE dabo_cd = f8 WITH protect, noconstant(0.0)
 DECLARE drh_cd = f8 WITH protect, noconstant(0.0)
 DECLARE nabo_code_set_discrep = i2 WITH protect, noconstant(0)
 DECLARE nrh_code_set_discrep = i2 WITH protect, noconstant(0)
 DECLARE nnew_person_donor_ind = i2 WITH protect, noconstant(0)
 DECLARE nexist_person_donor_ind = i2 WITH protect, noconstant(0)
 DECLARE nduplicate_person_donor_ind = i2 WITH protect, noconstant(0)
 DECLARE nfull_donation_upload = i2 WITH protect, noconstant(0)
 DECLARE dcontact_id = f8 WITH protect, noconstant(0.0)
 DECLARE deligibility_id = f8 WITH protect, noconstant(0.0)
 DECLARE ddonation_result_id = f8 WITH protect, noconstant(0.0)
 DECLARE dproduct_id = f8 WITH protect, noconstant(0.0)
 DECLARE seligibility_type_mean = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE scontact_type_mean = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE sfinal_contact_outcome_mean = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE scontact_outcome_mean = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE new_line = c2 WITH protect, noconstant(concat(char(13),char(11)))
 DECLARE nopposite_found_ind = i2 WITH protect, noconstant(0)
 DECLARE sopposite_antigen_1 = vc WITH protect, noconstant(" ")
 DECLARE sopposite_antigen_2 = vc WITH protect, noconstant(" ")
 DECLARE dlong_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE nfound_confidential_ind = i2 WITH protect, noconstant(0)
 DECLARE nfound_counsel_ind = i2 WITH protect, noconstant(0)
 DECLARE check_valid_donor_items(ldonor_index=i4(value)) = null
 DECLARE check_valid_contact_items(ldonor_index=i4(value)) = null
 DECLARE check_valid_donation_rslt_items(ldonor_index=i4(value),lcontact_index=i4(value)) = null
 DECLARE check_valid_other_contact_items(ldonor_index=i4(value),lcontact_index=i4(value)) = null
 DECLARE upload_donor_demographics(ldonor_index=i4(value)) = null
 DECLARE upload_donor_contacts(ldonor_index=i4(value)) = null
 DECLARE check_duplicate_contact(ldonor_index=i4(value),lcontact_index=i4(value)) = i2
 DECLARE check_valid_code_value(dcode_value=f8(value),lcode_set=i4(value),sobjectname=vc(value),
  sobjectvalue=vc(value)) = null
 DECLARE get_cdf_meaning_by_code(dcode_value=f8(value),lcode_set=i4(value),sobjectname=vc(value),
  sobjectvalue=vc(value)) = c12
 DECLARE get_code_by_cdf_meaning(scdf_mean=c12(value),lcode_set=i4(value),sobjectname=vc(value),
  sobjectvalue=vc(value)) = f8
 DECLARE check_valid_encntr_id(dperson_id=f8(value),dencntr_id=f8(value),sobjectstring=vc(value)) =
 null
 DECLARE check_valid_prsnl_id(dprsnl_id=f8(value),sobjectstring=vc(value)) = null
 DECLARE check_valid_donation_product(ldonor_index=i4(value),lcontact_index=i4(value)) = null
 DECLARE get_longest_eligible_dt_tm(ldonor_index=i4(value),lcontact_index=i4(value)) = null
 DECLARE add_hist_contact_method(ldonor_index=i4(value)) = null
 DECLARE add_hist_rare_types(ldonor_index=i4(value)) = null
 DECLARE add_hist_special_interest(ldonor_index=i4(value)) = null
 DECLARE add_hist_donor_note(ldonor_index=i4(value)) = null
 DECLARE add_hist_confidential_note(ldonor_index=i4(value)) = null
 DECLARE add_hist_counseling_note(ldonor_index=i4(value)) = null
 DECLARE add_hist_donor_contact(ldonor_index=i4(value),lcontact_index=i4(value)) = null
 DECLARE add_hist_donor_eligibility(ldonor_index=i4(value),lcontact_index=i4(value)) = null
 DECLARE add_hist_deferral_reason(ldonor_index=i4(value),lcontact_index=i4(value)) = null
 DECLARE add_hist_donation_result(ldonor_index=i4(value),lcontact_index=i4(value)) = null
 DECLARE add_hist_contact_note(ldonor_index=i4(value),lcontact_index=i4(value)) = null
 DECLARE add_hist_donation_product_rel(ldonor_index=i4(value),lcontact_index=i4(value)) = null
 DECLARE add_hist_other_contact(ldonor_index=i4(value),lcontact_index=i4(value)) = null
 DECLARE update_long_text(dlong_text_id=f8(value)) = null
 DECLARE add_long_text(dlong_text_id=f8(value),slong_text=vc(value),sparent_entity_name=vc(value),
  dparent_entity_id=f8(value)) = null
 DECLARE next_pathnet_seq(no_param=i2(value)) = f8
 DECLARE next_longtext_seq(no_param=i2(value)) = f8
 DECLARE errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) = null
 DECLARE lactive_aborh_cnt = i4 WITH protect, noconstant(0)
 DECLARE add_hist_donor_aborh(ldonor_index=i4(value),dabo_cd=f8(value),drh_cd=f8(value)) = null
 DECLARE load_donor_aborh(ldonor_index=i4(value)) = null
 DECLARE insert_donor_aborh(ldonor_index=i4(value),dabo_cd=f8(value),drh_cd=f8(value)) = null
 DECLARE inactive_donor_aborh(ddonor_aborh_id=f8(value)) = null
 DECLARE add_aborh_descrep(ldonor_index=i4(value)) = null
 SUBROUTINE add_hist_donor_aborh(ldonor_index,dabo_cd,drh_cd)
   DECLARE dposted_donor_abo_cd = f8 WITH protect, noconstant(0.0)
   DECLARE dposted_donor_rh_cd = f8 WITH protect, noconstant(0.0)
   FREE RECORD existdonoraborh
   RECORD existdonoraborh(
     1 donor_aborh_id = f8
     1 abo_cd = f8
     1 rh_cd = f8
     1 updt_cnt = i4
   )
   CALL load_donor_aborh(ldonor_index)
   IF (lactive_aborh_cnt=0)
    CALL insert_donor_aborh(ldonor_index,dabo_cd,drh_cd)
    IF (((nexist_person_donor_ind=1) OR (nduplicate_person_donor_ind=1)) )
     SET dposted_donor_abo_cd = dabo_cd
     SET dposted_donor_rh_cd = drh_cd
     CALL add_aborh_descrep(ldonor_index)
    ENDIF
   ELSEIF (lactive_aborh_cnt=1)
    IF ((request->donors[ldonor_index].donor_aborh.aborh_cd <= 0.0))
     SET dposted_donor_abo_cd = existdonoraborh->abo_cd
     SET dposted_donor_rh_cd = existdonoraborh->rh_cd
     CALL add_aborh_descrep(ldonor_index)
    ELSE
     IF ((((existdonoraborh->abo_cd != dabo_cd)) OR ((existdonoraborh->rh_cd != drh_cd))) )
      CALL inactive_donor_aborh(existdonoraborh->donor_aborh_id)
      SET dposted_donor_abo_cd = 0.0
      SET dposted_donor_rh_cd = 0.0
      CALL add_aborh_descrep(ldonor_index)
     ENDIF
    ENDIF
   ENDIF
   FREE RECORD existdonoraborh
 END ;Subroutine
 SUBROUTINE load_donor_aborh(ldonor_index)
   SET lactive_aborh_cnt = 0
   SELECT INTO "nl:"
    FROM donor_aborh da
    PLAN (da
     WHERE (da.person_id=request->donors[ldonor_index].person_id)
      AND da.active_ind=1)
    DETAIL
     lactive_aborh_cnt = (lactive_aborh_cnt+ 1), existdonoraborh->donor_aborh_id = da.donor_aborh_id,
     existdonoraborh->abo_cd = da.abo_cd,
     existdonoraborh->rh_cd = da.rh_cd, existdonoraborh->updt_cnt = da.updt_cnt
    WITH nocounter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (lactive_aborh_cnt > 1)
     CALL errorhandler("F","Multiple donor ABORhs exist",concat(
       "Multiple donor ABORhs found in donor_aborh table. Please resolve ","for person_id: ",request
       ->donors[ldonor_index].person_id," and for donor_xref_txt: ",request->donors[ldonor_index].
       donor_xref_txt,
       "."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","Donor ABORh select.",serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_donor_aborh(ldonor_index,dabo_cd,drh_cd)
   INSERT  FROM donor_aborh da
    SET da.donor_aborh_id = seq(pathnet_seq,nextval), da.person_id = request->donors[ldonor_index].
     person_id, da.abo_cd = dabo_cd,
     da.rh_cd = drh_cd, da.contributor_system_cd = request->contributor_system_cd, da.active_ind = 1,
     da.active_status_cd = reqdata->active_status_cd, da.active_status_dt_tm = cnvtdatetime(request->
      active_status_dt_tm), da.active_status_prsnl_id = request->active_status_prsnl_id,
     da.updt_cnt = 0, da.updt_dt_tm = cnvtdatetime(curdate,curtime3), da.updt_id = reqinfo->updt_id,
     da.updt_task = reqinfo->updt_task, da.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","DONOR_ABORH insert",concat(
       "Insert into DONOR_ABORH table failed. Please resolve ","for donor_xref_txt: ",request->
       donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","DONOR_ABORH insert",serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE inactive_donor_aborh(ddonor_aborh_id)
   SELECT INTO "nl:"
    FROM donor_aborh da
    WHERE da.donor_aborh_id=ddonor_aborh_id
    WITH nocounter, forupdate(da)
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","DONOR_ABORH select",concat(
       "Select DONOR_ABORH table for update failed. Please resolve ","for donor_xref_txt: ",request->
       donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","DONOR_ABORH select",serrormsg)
    GO TO exit_script
   ENDIF
   UPDATE  FROM donor_aborh da
    SET da.contributor_system_cd = request->contributor_system_cd, da.active_ind = 0, da
     .active_status_cd = reqdata->inactive_status_cd,
     da.active_status_dt_tm = cnvtdatetime(request->active_status_dt_tm), da.active_status_prsnl_id
      = request->active_status_prsnl_id, da.updt_cnt = (existdonoraborh->updt_cnt+ 1),
     da.updt_dt_tm = cnvtdatetime(curdate,curtime3), da.updt_id = reqinfo->updt_id, da.updt_task =
     reqinfo->updt_task,
     da.updt_applctx = reqinfo->updt_applctx
    WHERE da.donor_aborh_id=ddonor_aborh_id
    WITH nocounter
   ;end update
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","DONOR_ABORH update",concat(
       "Update into DONOR_ABORH table failed. Please resolve ","for donor_xref_txt: ",request->
       donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","DONOR_ABORH update",serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE add_aborh_descrep(ldonor_index)
   INSERT  FROM bbd_upload_review bur
    SET bur.bbd_upload_review_id = seq(pathnet_seq,nextval), bur.person_id = request->donors[
     ldonor_index].person_id, bur.upload_donor_abo_cd = dabo_cd,
     bur.upload_donor_rh_cd = drh_cd, bur.demog_donor_abo_cd = existdonoraborh->abo_cd, bur
     .demog_donor_rh_cd = existdonoraborh->rh_cd,
     bur.upload_donor_elig_type_cd = 0.0, bur.demog_donor_elig_type_cd = 0.0, bur
     .upload_contact_outcome_cd = 0.0,
     bur.upload_outcome_cd = 0.0, bur.upload_donor_defer_until_dt_tm = null, bur
     .demog_donor_defer_until_dt_tm = null,
     bur.upload_contributor_system_cd = request->contributor_system_cd, bur
     .demog_contributor_system_cd = existpersondonor->contributor_system_cd, bur
     .upload_discrep_type_flag = nabo_discrep_type_flag,
     bur.upload_dt_tm = cnvtdatetime(request->active_status_dt_tm), bur.posted_donor_abo_cd =
     dposted_donor_abo_cd, bur.posted_donor_rh_cd = dposted_donor_rh_cd,
     bur.posted_donor_elig_type_cd = 0, bur.posted_donor_defer_until_dt_tm = null, bur.updt_cnt = 0,
     bur.updt_dt_tm = cnvtdatetime(curdate,curtime3), bur.updt_id = reqinfo->updt_id, bur.updt_task
      = reqinfo->updt_task,
     bur.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","BB_UPLOAD_REVIEW insert",concat(
       "Insert into BB_UPLOAD_REVIEW table failed. Please resolve ","for donor_xref_txt: ",request->
       donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","BB_UPLOAD_REVIEW insert",serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 DECLARE add_hist_donor_antigen(ldonor_index=i4(value)) = null
 SUBROUTINE add_hist_donor_antigen(ldonor_index)
   DECLARE nantigen_exist_ind = i2 WITH protect, noconstant(0)
   SET nopposite_found_ind = 0
   SET lantigen_count = size(request->donors[ldonor_index].antigens,5)
   FOR (lantigen_index = 1 TO lantigen_count)
     SELECT INTO "nl:"
      FROM donor_antigen da,
       code_value cv,
       code_value_extension cve
      PLAN (da
       WHERE (da.person_id=request->donors[ldonor_index].person_id)
        AND da.active_ind=1)
       JOIN (cv
       WHERE cv.code_set=lspecial_testing_code_set
        AND cv.code_value=da.antigen_cd
        AND ((cv.cdf_meaning="-") OR (cv.cdf_meaning="+"))
        AND cv.active_ind=1)
       JOIN (cve
       WHERE cve.code_set=cv.code_set
        AND cve.code_value=cv.code_value
        AND cve.field_name="Opposite")
      DETAIL
       IF ((cnvtreal(cve.field_value)=request->donors[ldonor_index].antigens[lantigen_index].
       antigen_cd))
        nopposite_found_ind = 1, sopposite_antigen_1 = trim(cnvtstring(request->donors[ldonor_index].
          antigens[lantigen_index].antigen_cd)), sopposite_antigen_2 = trim(cnvtstring(cve
          .field_value))
       ENDIF
      WITH nocounter
     ;end select
     SET nerror_check = error(serrormsg,0)
     IF (nerror_check=0)
      IF (nopposite_found_ind=1)
       CALL errorhandler("F","Opposite Antigen Found",concat("Opposite Antigen Found for person_id: ",
         trim(cnvtstring(request->donors[ldonor_index].person_id))," antigen_cd: ",
         sopposite_antigen_1," with opposite field_value: ",
         sopposite_antigen_2,". Please resolve ","for donor_xref_txt: ",trim(request->donors[
          ldonor_index].donor_xref_txt),"."))
       GO TO exit_script
      ENDIF
     ELSE
      CALL errorhandler("F","Opposite Antigen select.",serrormsg)
      GO TO exit_script
     ENDIF
     SET nantigen_exist_ind = 0
     SELECT INTO "nl:"
      FROM donor_antigen da
      PLAN (da
       WHERE (da.person_id=request->donors[ldonor_index].person_id)
        AND (da.antigen_cd=request->donors[ldonor_index].antigens[lantigen_index].antigen_cd)
        AND (da.contributor_system_cd=request->contributor_system_cd)
        AND da.active_ind=1)
      DETAIL
       nantigen_exist_ind = 1
      WITH nocounter
     ;end select
     SET nerror_check = error(serrormsg,0)
     IF (nerror_check != 0)
      CALL errorhandler("F","Donor Antigen select.",serrormsg)
      GO TO exit_script
     ENDIF
     IF (nantigen_exist_ind=0)
      INSERT  FROM donor_antigen da
       SET da.donor_antigen_id = seq(pathnet_seq,nextval), da.person_id = request->donors[
        ldonor_index].person_id, da.encntr_id = request->donors[ldonor_index].antigens[lantigen_index
        ].encntr_id,
        da.antigen_cd = request->donors[ldonor_index].antigens[lantigen_index].antigen_cd, da
        .result_id = 0.0, da.bb_result_nbr = 0,
        da.donor_rh_phenotype_id = 0.0, da.contributor_system_cd = request->contributor_system_cd, da
        .active_ind = 1,
        da.active_status_cd = reqdata->active_status_cd, da.active_status_dt_tm = cnvtdatetime(
         request->active_status_dt_tm), da.active_status_prsnl_id = request->active_status_prsnl_id,
        da.updt_cnt = 0, da.updt_dt_tm = cnvtdatetime(curdate,curtime3), da.updt_id = reqinfo->
        updt_id,
        da.updt_task = reqinfo->updt_task, da.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET nerror_check = error(serrormsg,0)
      IF (nerror_check=0)
       IF (curqual=0)
        CALL errorhandler("F","DONOR_ANTIGEN insert",concat(
          "Insert into DONOR_ANTIGEN table failed. Please resolve ","for donor_xref_txt: ",request->
          donors[ldonor_index].donor_xref_txt,"."))
        GO TO exit_script
       ENDIF
      ELSE
       CALL errorhandler("F","DONOR_ANTIGEN insert",serrormsg)
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 DECLARE add_hist_donor_antibody(ldonor_index=i4(value)) = null
 SUBROUTINE add_hist_donor_antibody(ldonor_index)
   DECLARE nantibody_exist_ind = i2 WITH protect, noconstant(0)
   SET lantibody_count = size(request->donors[ldonor_index].antibodies,5)
   FOR (lantibody_index = 1 TO lantibody_count)
     SET nantibody_exist_ind = 0
     SELECT INTO "nl:"
      FROM donor_antibody da
      PLAN (da
       WHERE (da.person_id=request->donors[ldonor_index].person_id)
        AND (da.antibody_cd=request->donors[ldonor_index].antibodies[lantibody_index].antibody_cd)
        AND (da.contributor_system_cd=request->contributor_system_cd)
        AND da.active_ind=1)
      DETAIL
       nantibody_exist_ind = 1
      WITH nocounter
     ;end select
     SET nerror_check = error(serrormsg,0)
     IF (nerror_check != 0)
      CALL errorhandler("F","Donor Antibody select",serrormsg)
      GO TO exit_script
     ENDIF
     IF (nantibody_exist_ind=0)
      INSERT  FROM donor_antibody da
       SET da.donor_antibody_id = seq(pathnet_seq,nextval), da.person_id = request->donors[
        ldonor_index].person_id, da.encntr_id = request->donors[ldonor_index].antibodies[
        lantibody_index].encntr_id,
        da.antibody_cd = request->donors[ldonor_index].antibodies[lantibody_index].antibody_cd, da
        .result_id = 0.0, da.bb_result_nbr = 0,
        da.contributor_system_cd = request->contributor_system_cd, da.active_ind = 1, da
        .active_status_cd = reqdata->active_status_cd,
        da.active_status_dt_tm = cnvtdatetime(request->active_status_dt_tm), da
        .active_status_prsnl_id = request->active_status_prsnl_id, da.updt_cnt = 0,
        da.updt_dt_tm = cnvtdatetime(curdate,curtime3), da.updt_id = reqinfo->updt_id, da.updt_task
         = reqinfo->updt_task,
        da.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET nerror_check = error(serrormsg,0)
      IF (nerror_check=0)
       IF (curqual=0)
        CALL errorhandler("F","DONOR_ANTIBODY insert",concat(
          "Insert into DONOR_ANTIBODY table failed. Please resolve ","for donor_xref_txt: ",request->
          donors[ldonor_index].donor_xref_txt,"."))
        GO TO exit_script
       ENDIF
      ELSE
       CALL errorhandler("F","DONOR_ANTIBODY insert",serrormsg)
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 DECLARE add_hist_person_donor(ldonor_index=i4(value)) = null
 DECLARE validate_elig_levels_descrep(ldonor_index=i4(value)) = null
 DECLARE validate_elig_donors_descrep(ldonor_index=i4(value)) = null
 DECLARE add_elig_levels_descrep(ldonor_index=i4(value)) = null
 DECLARE add_elig_donors_descrep(ldonor_index=i4(value)) = null
 DECLARE insert_person_donor(ldonor_index=i4(value)) = null
 DECLARE update_person_donor(ldonor_index=i4(value)) = null
 SUBROUTINE add_hist_person_donor(ldonor_index)
   FREE RECORD posteddonorleveleligibility
   RECORD posteddonorleveleligibility(
     1 eligibility_type_cd = f8
     1 eligibility_type_mean = c12
     1 defer_until_dt_tm = dq8
   )
   FREE RECORD posteddonorseligibility
   RECORD posteddonorseligibility(
     1 eligibility_type_cd = f8
     1 eligibility_type_mean = c12
     1 defer_until_dt_tm = dq8
   )
   FREE RECORD existdonoreligibility
   RECORD existdonoreligibility(
     1 demog_eligibility_type_cd = f8
     1 demog_eligibility_type_mean = c12
     1 demog_defer_until_dt_tm = dq8
     1 demog_contributor_system_cd = f8
   )
   FREE RECORD tempdonoreligibledttm
   RECORD tempdonoreligibledttm(
     1 eligible_dt_tm = dq8
   )
   CALL validate_elig_levels_descrep(ldonor_index)
   SET posteddonorseligibility->eligibility_type_mean = posteddonorleveleligibility->
   eligibility_type_mean
   SET posteddonorseligibility->defer_until_dt_tm = posteddonorleveleligibility->defer_until_dt_tm
   SET posteddonorseligibility->eligibility_type_cd = get_code_by_cdf_meaning(
    posteddonorleveleligibility->eligibility_type_mean,leligibility_type_code_set,
    "ELIGIBILITY_TYPE_Mean sel","Eligibility_type_mean")
   IF (((nexist_person_donor_ind=1) OR (nduplicate_person_donor_ind=1)) )
    CALL echo("Before Validate_Elig_Donors_Descrep")
    CALL validate_elig_donors_descrep(ldonor_index)
   ENDIF
   CALL echo(build("nExist_Person_Donor_Ind: ",nexist_person_donor_ind))
   IF (nnew_person_donor_ind=1)
    CALL insert_person_donor(ldonor_index)
   ELSEIF (((nexist_person_donor_ind=1) OR (nduplicate_person_donor_ind=1)) )
    CALL update_person_donor(ldonor_index)
   ENDIF
   FREE RECORD posteddonorleveleligibility
   FREE RECORD posteddonorseligibility
   FREE RECORD existdonoreligibility
   FREE RECORD existdonoreligibility
   FREE RECORD tempdonoreligibledttm
 END ;Subroutine
 SUBROUTINE validate_elig_levels_descrep(ldonor_index)
   SET posteddonorleveleligibility->eligibility_type_mean = get_cdf_meaning_by_code(request->donors[
    ldonor_index].eligibility_type_cd,leligibility_type_code_set,"ELIGIBILITY_TYPE_CD sel",
    "Eligibility_type_cd")
   SET posteddonorleveleligibility->defer_until_dt_tm = request->donors[ldonor_index].
   defer_until_dt_tm
   SET posteddonorleveleligibility->eligibility_type_cd = request->donors[ldonor_index].
   eligibility_type_cd
   CALL echorecord(posteddonorseligibility)
   CALL echorecord(posteddonorleveleligibility)
   SET lcontact_count = size(request->donors[ldonor_index].contacts,5)
   FOR (lcontact_index = 1 TO lcontact_count)
     IF ((posteddonorleveleligibility->eligibility_type_mean=sgood_cdf_mean))
      SET sfinal_contact_outcome_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].
       contacts[lcontact_index].contact_outcome_cd,lcontact_outcome_code_set,"CONTACT_OUTCOME_CD sel",
       "Contact_outcome_cd")
      IF (sfinal_contact_outcome_mean=stemp_defer_outcome_cdf_mean)
       SET posteddonorleveleligibility->eligibility_type_mean = stemp_defer_cdf_mean
       SET scontact_type_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[
        lcontact_index].contact_type_cd,lcontact_type_code_set,"CONTACT_TYPE_CD select",
        "Contact_type_cd")
       CALL echo(build("sContactTypeMean::",scontact_type_mean))
       IF (scontact_type_mean=sdonate_cdf_mean)
        SET scontact_outcome_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[
         lcontact_index].donation_result.outcome_cd,lcontact_outcome_code_set,"OUTCOME_CD sel",
         "Donation result Outcome_cd")
       ELSE
        SET scontact_outcome_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[
         lcontact_index].other_contact.outcome_cd,lcontact_outcome_code_set,"OUTCOME_CD sel",
         "Other Contact Outcome_cd")
       ENDIF
       IF (scontact_outcome_mean=sperm_defer_outcome_cdf_mean)
        SET posteddonorleveleligibility->eligibility_type_mean = sperm_defer_cdf_mean
       ENDIF
       IF ((posteddonorleveleligibility->eligibility_type_mean=stemp_defer_cdf_mean))
        CALL echo("checking ELIG DATE TIME")
        CALL get_longest_eligible_dt_tm(ldonor_index,lcontact_index)
        SET tempdonoreligibledttm->eligible_dt_tm = tempeligibledttm->eligible_dt_tm
        IF ((posteddonorleveleligibility->defer_until_dt_tm < tempdonoreligibledttm->eligible_dt_tm))
         SET posteddonorleveleligibility->defer_until_dt_tm = tempdonoreligibledttm->eligible_dt_tm
        ENDIF
       ENDIF
       CALL add_elig_levels_descrep(ldonor_index,lcontact_index)
      ELSEIF (sfinal_contact_outcome_mean=sperm_defer_outcome_cdf_mean)
       SET posteddonorleveleligibility->eligibility_type_mean = sperm_defer_cdf_mean
       CALL add_elig_levels_descrep(ldonor_index,lcontact_index)
      ENDIF
     ELSEIF ((posteddonorleveleligibility->eligibility_type_mean=stemp_defer_cdf_mean))
      SET sfinal_contact_outcome_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].
       contacts[lcontact_index].contact_outcome_cd,lcontact_outcome_code_set,"CONTACT_OUTCOME_CD sel",
       "Contact_outcome_cd")
      IF (sfinal_contact_outcome_mean=stemp_defer_outcome_cdf_mean)
       SET scontact_type_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[
        lcontact_index].contact_type_cd,lcontact_type_code_set,"CONTACT_TYPE_CD select",
        "Contact_type_cd")
       CALL echo(build("sContactTypeMean::",scontact_type_mean))
       IF (scontact_type_mean=sdonate_cdf_mean)
        SET scontact_outcome_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[
         lcontact_index].donation_result.outcome_cd,lcontact_outcome_code_set,"OUTCOME_CD sel",
         "Donation result Outcome_cd")
       ELSE
        SET scontact_outcome_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[
         lcontact_index].other_contact.outcome_cd,lcontact_outcome_code_set,"OUTCOME_CD sel",
         "Other Contact Outcome_cd")
       ENDIF
       IF (scontact_outcome_mean=sperm_defer_outcome_cdf_mean)
        SET posteddonorleveleligibility->eligibility_type_mean = sperm_defer_cdf_mean
       ENDIF
       IF ((posteddonorleveleligibility->eligibility_type_mean=stemp_defer_cdf_mean))
        CALL get_longest_eligible_dt_tm(ldonor_index,lcontact_index)
        SET tempdonoreligibledttm->eligible_dt_tm = tempeligibledttm->eligible_dt_tm
        IF ((posteddonorleveleligibility->defer_until_dt_tm < tempdonoreligibledttm->eligible_dt_tm))
         SET posteddonorleveleligibility->defer_until_dt_tm = tempdonoreligibledttm->eligible_dt_tm
        ENDIF
       ENDIF
      ELSEIF (sfinal_contact_outcome_mean=sperm_defer_outcome_cdf_mean)
       SET posteddonorleveleligibility->eligibility_type_mean = sperm_defer_cdf_mean
       CALL add_elig_levels_descrep(ldonor_index,lcontact_index)
      ENDIF
     ELSEIF ((posteddonorleveleligibility->eligibility_type_mean=sperm_defer_cdf_mean))
      SET lcontact_index = lcontact_count
     ENDIF
   ENDFOR
   IF ((posteddonorleveleligibility->eligibility_type_mean != stemp_defer_cdf_mean))
    SET posteddonorleveleligibility->defer_until_dt_tm = null
   ENDIF
 END ;Subroutine
 SUBROUTINE validate_elig_donors_descrep(ldonor_index)
   SET existdonoreligibility->demog_eligibility_type_cd = existpersondonor->eligibility_type_cd
   SET existdonoreligibility->demog_defer_until_dt_tm = existpersondonor->defer_until_dt_tm
   SET existdonoreligibility->demog_contributor_system_cd = existpersondonor->contributor_system_cd
   CALL echorecord(existdonoreligibility)
   IF ((existdonoreligibility->demog_eligibility_type_cd=0.0))
    SET posteddonorseligibility->eligibility_type_mean = posteddonorleveleligibility->
    eligibility_type_mean
    SET posteddonorseligibility->defer_until_dt_tm = posteddonorleveleligibility->defer_until_dt_tm
    CALL add_elig_donors_descrep(ldonor_index)
   ELSE
    SET existdonoreligibility->demog_eligibility_type_mean = get_cdf_meaning_by_code(
     existdonoreligibility->demog_eligibility_type_cd,leligibility_type_code_set,
     "ELIGIBILITY_TYPE_CD sel","Eligibility_type_Cd")
    SET posteddonorseligibility->eligibility_type_mean = posteddonorleveleligibility->
    eligibility_type_mean
    SET posteddonorseligibility->defer_until_dt_tm = posteddonorleveleligibility->defer_until_dt_tm
    IF ((posteddonorseligibility->eligibility_type_mean=existdonoreligibility->
    demog_eligibility_type_mean))
     IF ((posteddonorseligibility->eligibility_type_mean=stemp_defer_cdf_mean))
      IF ((posteddonorseligibility->defer_until_dt_tm > existdonoreligibility->
      demog_defer_until_dt_tm))
       CALL add_elig_donors_descrep(ldonor_index)
      ELSEIF ((posteddonorseligibility->defer_until_dt_tm < existdonoreligibility->
      demog_defer_until_dt_tm))
       SET posteddonorseligibility->defer_until_dt_tm = existdonoreligibility->
       demog_defer_until_dt_tm
       CALL add_elig_donors_descrep(ldonor_index)
      ENDIF
     ENDIF
    ELSE
     IF ((posteddonorseligibility->eligibility_type_mean=sgood_cdf_mean))
      IF ((existdonoreligibility->demog_eligibility_type_mean=stemp_defer_cdf_mean))
       SET posteddonorseligibility->eligibility_type_mean = stemp_defer_cdf_mean
       SET posteddonorseligibility->defer_until_dt_tm = existdonoreligibility->
       demog_defer_until_dt_tm
       CALL add_elig_donors_descrep(ldonor_index)
      ELSEIF ((existdonoreligibility->demog_eligibility_type_mean=sperm_defer_cdf_mean))
       SET posteddonorseligibility->eligibility_type_mean = sperm_defer_cdf_mean
       CALL add_elig_donors_descrep(ldonor_index)
      ENDIF
     ELSEIF ((posteddonorseligibility->eligibility_type_mean=stemp_defer_cdf_mean))
      IF ((existdonoreligibility->demog_eligibility_type_mean=sgood_cdf_mean))
       CALL add_elig_donors_descrep(ldonor_index)
      ELSEIF ((existdonoreligibility->demog_eligibility_type_mean=sperm_defer_cdf_mean))
       SET posteddonorseligibility->eligibility_type_mean = sperm_defer_cdf_mean
       CALL add_elig_donors_descrep(ldonor_index)
      ENDIF
     ELSEIF ((posteddonorseligibility->eligibility_type_mean=sperm_defer_cdf_mean))
      IF ((existdonoreligibility->demog_eligibility_type_mean=sgood_cdf_mean))
       CALL add_elig_donors_descrep(ldonor_index)
      ELSEIF ((existdonoreligibility->demog_eligibility_type_mean=stemp_defer_cdf_mean))
       CALL add_elig_donors_descrep(ldonor_index)
      ENDIF
     ENDIF
    ENDIF
    IF ((posteddonorseligibility->eligibility_type_mean != stemp_defer_cdf_mean))
     SET posteddonorleveleligibility->defer_until_dt_tm = null
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_elig_levels_descrep(ldonor_index,lcontact_index)
   CALL echo("Add_Elig_Levels_Descrep")
   SET scontact_type_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[
    lcontact_index].contact_type_cd,lcontact_type_code_set,"CONTACT_TYPE_CD sel","Contact_type_cd")
   SET seligibility_type_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[
    lcontact_index].donor_eligibility.eligibility_type_cd,leligibility_type_code_set,
    "ELIGIBILITY_TYPE_CD sel","Donor contacts Eligibility_type_cd")
   SET posteddonorleveleligibility->eligibility_type_cd = get_code_by_cdf_meaning(
    posteddonorleveleligibility->eligibility_type_mean,leligibility_type_code_set,
    "ELIGIBILITY_TYPE_Mean sel","Eligibility_type_mean")
   INSERT  FROM bbd_upload_review bur
    SET bur.bbd_upload_review_id = seq(pathnet_seq,nextval), bur.person_id = request->donors[
     ldonor_index].person_id, bur.upload_donor_abo_cd = 0.0,
     bur.upload_donor_rh_cd = 0.0, bur.demog_donor_abo_cd = 0.0, bur.demog_donor_rh_cd = 0.0,
     bur.upload_donor_elig_type_cd = request->donors[ldonor_index].eligibility_type_cd, bur
     .demog_donor_elig_type_cd = 0.0, bur.upload_donor_defer_until_dt_tm = cnvtdatetime(request->
      donors[ldonor_index].defer_until_dt_tm),
     bur.demog_donor_defer_until_dt_tm = null, bur.upload_contact_outcome_cd = request->donors[
     ldonor_index].contacts[lcontact_index].contact_outcome_cd, bur.upload_outcome_cd =
     IF (scontact_type_mean=sdonate_cdf_mean) request->donors[ldonor_index].contacts[lcontact_index].
      donation_result.outcome_cd
     ELSEIF (((scontact_type_mean=sconfidential_cdf_mean) OR (scontact_type_mean=scounsel_cdf_mean))
     ) request->donors[ldonor_index].contacts[lcontact_index].other_contact.outcome_cd
     ENDIF
     ,
     bur.upload_contact_eligible_dt_tm =
     IF (((seligibility_type_mean=sgood_cdf_mean) OR (seligibility_type_mean=sperm_defer_cdf_mean)) )
       null
     ELSEIF (seligibility_type_mean=stemp_defer_cdf_mean) cnvtdatetime(tempdonoreligibledttm->
       eligible_dt_tm)
     ENDIF
     , bur.upload_contributor_system_cd = request->contributor_system_cd, bur
     .demog_contributor_system_cd = 0.0,
     bur.upload_discrep_type_flag = nelig_level_discrep_type_flag, bur.upload_dt_tm = cnvtdatetime(
      request->active_status_dt_tm), bur.posted_donor_abo_cd = 0.0,
     bur.posted_donor_rh_cd = 0.0, bur.posted_donor_elig_type_cd = posteddonorleveleligibility->
     eligibility_type_cd, bur.posted_donor_defer_until_dt_tm = cnvtdatetime(
      posteddonorleveleligibility->defer_until_dt_tm),
     bur.updt_cnt = 0, bur.updt_dt_tm = cnvtdatetime(curdate,curtime3), bur.updt_id = reqinfo->
     updt_id,
     bur.updt_task = reqinfo->updt_task, bur.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","BBD_UPLOAD_REVIEW insert",concat(
       "Insert into BBD_UPLOAD_REVIEW table failed. Please resolve ","for donor_xref_txt: ",request->
       donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","BBD_UPLOAD_REVIEW insert",serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE add_elig_donors_descrep(ldonor_index)
   CALL echo("Add_Elig_Donors_Descrep")
   CALL echo(build("PostedDonorsEligibility->eligibility_type_mean: ",posteddonorseligibility->
     eligibility_type_mean))
   SET posteddonorseligibility->eligibility_type_cd = get_code_by_cdf_meaning(posteddonorseligibility
    ->eligibility_type_mean,leligibility_type_code_set,"ELIGIBILITY_TYPE_Mean sel",
    "Eligibility_type_mean")
   SET posteddonorleveleligibility->eligibility_type_cd = get_code_by_cdf_meaning(
    posteddonorleveleligibility->eligibility_type_mean,leligibility_type_code_set,
    "ELIGIBILITY_TYPE_Mean sel","Eligibility_type_mean")
   INSERT  FROM bbd_upload_review bur
    SET bur.bbd_upload_review_id = seq(pathnet_seq,nextval), bur.person_id = request->donors[
     ldonor_index].person_id, bur.upload_donor_abo_cd = 0.0,
     bur.upload_donor_rh_cd = 0.0, bur.demog_donor_abo_cd = 0.0, bur.demog_donor_rh_cd = 0.0,
     bur.upload_donor_elig_type_cd = posteddonorleveleligibility->eligibility_type_cd, bur
     .demog_donor_elig_type_cd = existdonoreligibility->demog_eligibility_type_cd, bur
     .upload_contact_outcome_cd = 0.0,
     bur.upload_outcome_cd = 0.0, bur.upload_donor_defer_until_dt_tm = cnvtdatetime(
      posteddonorleveleligibility->defer_until_dt_tm), bur.demog_donor_defer_until_dt_tm =
     cnvtdatetime(existdonoreligibility->demog_defer_until_dt_tm),
     bur.upload_contributor_system_cd = request->contributor_system_cd, bur
     .demog_contributor_system_cd = existdonoreligibility->demog_contributor_system_cd, bur
     .upload_discrep_type_flag = nelig_donors_discrep_type_flag,
     bur.upload_dt_tm = cnvtdatetime(request->active_status_dt_tm), bur.posted_donor_abo_cd = 0.0,
     bur.posted_donor_rh_cd = 0.0,
     bur.posted_donor_elig_type_cd = posteddonorseligibility->eligibility_type_cd, bur
     .posted_donor_defer_until_dt_tm = cnvtdatetime(posteddonorseligibility->defer_until_dt_tm), bur
     .updt_cnt = 0,
     bur.updt_dt_tm = cnvtdatetime(curdate,curtime3), bur.updt_id = reqinfo->updt_id, bur.updt_task
      = reqinfo->updt_task,
     bur.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","BBD_UPLOAD_REVIEW insert",concat(
       "Insert into BBD_UPLOAD_REVIEW table failed. Please resolve ","for donor_xref_txt: ",request->
       donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","BBD_UPLOAD_REVIEW insert",serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_person_donor(ldonor_index)
   INSERT  FROM person_donor pd
    SET pd.person_id = request->donors[ldonor_index].person_id, pd.counseling_reqrd_cd = 0.0, pd
     .defer_until_dt_tm = cnvtdatetime(posteddonorseligibility->defer_until_dt_tm),
     pd.donation_level = request->donors[ldonor_index].donation_level_trans, pd.donation_level_trans
      = request->donors[ldonor_index].donation_level_trans, pd.donations_trans_tot_cnt = request->
     donors[ldonor_index].donations_trans_tot_cnt,
     pd.donor_xref_txt = request->donors[ldonor_index].donor_xref_txt, pd.eligibility_type_cd =
     posteddonorseligibility->eligibility_type_cd, pd.elig_for_reinstate_ind =
     IF (cnvtdatetime(request->donors[ldonor_index].defer_until_dt_tm) < cnvtdatetime(curdate,
      curtime3)) 1
     ELSE 0
     ENDIF
     ,
     pd.last_donation_dt_tm = cnvtdatetime(request->donors[ldonor_index].last_donation_dt_tm), pd
     .lock_ind = 0, pd.mailings_ind = request->donors[ldonor_index].mailings_ind,
     pd.preferred_donation_location_cd = request->donors[ldonor_index].prefer_don_ambulatory_cd, pd
     .rare_donor_cd = 0, pd.recruit_inv_area_cd = 0.0,
     pd.recruit_owner_area_cd = 0.0, pd.reinstated_dt_tm = null, pd.reinstated_ind = 0,
     pd.spec_dnr_interest_cd = 0.0, pd.watch_ind = 0, pd.watch_reason_cd = 0.0,
     pd.willingness_level_cd = request->donors[ldonor_index].willingness_level_cd, pd
     .contributor_system_cd = request->contributor_system_cd, pd.active_ind = 1,
     pd.active_status_cd = reqdata->active_status_cd, pd.active_status_dt_tm = cnvtdatetime(request->
      active_status_dt_tm), pd.active_status_prsnl_id = request->active_status_prsnl_id,
     pd.updt_cnt = 0, pd.updt_dt_tm = cnvtdatetime(curdate,curtime3), pd.updt_id = reqinfo->updt_id,
     pd.updt_task = reqinfo->updt_task, pd.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","PERSON_DONOR insert",concat(
       "Insert into PERSON_DONOR table failed. Please resolve ","for donor_xref_txt: ",request->
       donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","PERSON_DONOR insert",serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE update_person_donor(ldonor_index)
   SELECT INTO "nl:"
    FROM person_donor pd
    WHERE (pd.person_id=request->donors[ldonor_index].person_id)
    WITH nocounter, forupdate(pd)
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","PERSON_DONOR select",concat(
       "Select PERSON_DONOR table for update failed. Please resolve ","for donor_xref_txt: ",request
       ->donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","PERSON_DONOR select",serrormsg)
    GO TO exit_script
   ENDIF
   UPDATE  FROM person_donor pd
    SET pd.person_id = request->donors[ldonor_index].person_id, pd.counseling_reqrd_cd = 0.0, pd
     .defer_until_dt_tm = cnvtdatetime(posteddonorseligibility->defer_until_dt_tm),
     pd.donation_level = ((pd.donation_level - pd.donation_level_trans)+ request->donors[ldonor_index
     ].donation_level_trans), pd.donation_level_trans = request->donors[ldonor_index].
     donation_level_trans, pd.donations_trans_tot_cnt = request->donors[ldonor_index].
     donations_trans_tot_cnt,
     pd.donor_xref_txt = request->donors[ldonor_index].donor_xref_txt, pd.eligibility_type_cd =
     posteddonorseligibility->eligibility_type_cd, pd.elig_for_reinstate_ind =
     IF (cnvtdatetime(request->donors[ldonor_index].defer_until_dt_tm) < cnvtdatetime(curdate,
      curtime3)) 1
     ELSE 0
     ENDIF
     ,
     pd.last_donation_dt_tm = cnvtdatetime(request->donors[ldonor_index].last_donation_dt_tm), pd
     .lock_ind = 0, pd.mailings_ind = request->donors[ldonor_index].mailings_ind,
     pd.preferred_donation_location_cd = request->donors[ldonor_index].prefer_don_ambulatory_cd, pd
     .rare_donor_cd = 0, pd.recruit_inv_area_cd = 0.0,
     pd.recruit_owner_area_cd = 0.0, pd.reinstated_dt_tm = null, pd.reinstated_ind = 0,
     pd.spec_dnr_interest_cd = 0.0, pd.watch_ind = 0, pd.watch_reason_cd = 0.0,
     pd.willingness_level_cd = request->donors[ldonor_index].willingness_level_cd, pd
     .contributor_system_cd = request->contributor_system_cd, pd.active_ind = 1,
     pd.active_status_cd = reqdata->active_status_cd, pd.active_status_dt_tm = cnvtdatetime(request->
      active_status_dt_tm), pd.active_status_prsnl_id = request->active_status_prsnl_id,
     pd.updt_cnt = 0, pd.updt_dt_tm = cnvtdatetime(curdate,curtime3), pd.updt_id = reqinfo->updt_id,
     pd.updt_task = reqinfo->updt_task, pd.updt_applctx = reqinfo->updt_applctx
    WHERE (pd.person_id=request->donors[ldonor_index].person_id)
    WITH nocounter
   ;end update
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","PERSON_DONOR update",concat(
       "Update into PERSON_DONOR table failed. Please resolve ","for donor_xref_txt: ",request->
       donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","PERSON_DONOR update",serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SET modify = predeclare
 SET reply->status_data.status = "F"
 IF ((request->contributor_system_cd <= 0.0))
  CALL errorhandler("F","CONTRIBUTOR_SYSTEM_CD val",
   "Contributor system is blank.  Upload canceled. Please resolve.")
  GO TO exit_script
 ENDIF
 FOR (ldonor_index = 1 TO ldonor_count)
   FREE RECORD existpersondonor
   RECORD existpersondonor(
     1 donor_xref_txt = c40
     1 contributor_system_cd = f8
     1 eligibility_type_cd = f8
     1 defer_until_dt_tm = dq8
   )
   SET nnew_person_donor_ind = 0
   SET nexist_person_donor_ind = 0
   SET nduplicate_person_donor_ind = 0
   SET nfull_donation_upload = 0
   IF (size(trim(request->donors[ldonor_index].donor_xref_txt,3),1)=0)
    CALL errorhandler("F","DONOR_XREF_TXT validation",concat(
      "Donor cross reference is blank. Please resolve ","for donor person_id: ",cnvtstring(request->
       donors[ldonor_index].person_id),"."))
    GO TO exit_script
   ENDIF
   IF ((request->donors[ldonor_index].person_id <= 0.0))
    CALL errorhandler("F","PERSON_ID validation",concat("PERSON_ID is blank. Please resolve ",
      "for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,"."))
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM person_donor pd
    PLAN (pd
     WHERE (pd.person_id=request->donors[ldonor_index].person_id)
      AND pd.active_ind=1)
    DETAIL
     existpersondonor->donor_xref_txt = pd.donor_xref_txt, existpersondonor->contributor_system_cd =
     pd.contributor_system_cd, existpersondonor->eligibility_type_cd = pd.eligibility_type_cd,
     existpersondonor->defer_until_dt_tm = pd.defer_until_dt_tm
    WITH nocounter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     SET nnew_person_donor_ind = 1
    ELSE
     IF (size(trim(existpersondonor->donor_xref_txt,3),1)=0
      AND (existpersondonor->contributor_system_cd=0))
      SET nexist_person_donor_ind = 1
     ELSEIF ((trim(existpersondonor->donor_xref_txt,3)=request->donors[ldonor_index].donor_xref_txt)
      AND (existpersondonor->contributor_system_cd=request->contributor_system_cd))
      SET nduplicate_person_donor_ind = 1
     ELSE
      CALL errorhandler("F","DONOR_XREF_TXT select",concat(
        "Donor_xref_txt and contributor_system_cd exist but are discrepant for person_id: ",trim(
         cnvtstring(request->donors[ldonor_index].person_id)),". Please resolve",
        " for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,
        " and contributor_system_cd: ",trim(cnvtstring(request->contributor_system_cd)),"."))
      GO TO exit_script
     ENDIF
    ENDIF
    CALL check_valid_donor_items(ldonor_index)
    CALL check_valid_contact_items(ldonor_index)
    CALL upload_donor_demographics(ldonor_index)
    CALL upload_donor_contacts(ldonor_index)
   ELSE
    CALL errorhandler("F","Duplicate checking",serrormsg)
    GO TO exit_script
   ENDIF
   CALL echo("End of dnnors.donor_cross_preference duplicate check")
 ENDFOR
 SET reply->status_data.status = "S"
 GO TO exit_script
 SUBROUTINE check_valid_donor_items(ldonor_index)
   SELECT INTO "nl:"
    p.person_id
    FROM person p
    PLAN (p
     WHERE (p.person_id=request->donors[ldonor_index].person_id))
    WITH nocounter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","PERSON_ID validation",concat("Person_ID: ",trim(cnvtstring(request->
         donors[ldonor_index].person_id))," does not exist on the Person table. Please resolve ",
       "for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,
       "."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","PERSON_ID validation",serrormsg)
    GO TO exit_script
   ENDIF
   CALL echo("End of donors.person_id check")
   SET seligibility_type_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].
    eligibility_type_cd,leligibility_type_code_set,"ELIGIBILITY_TYPE_CD val","Eligibility_type_cd")
   CALL echo("End of donors.eligibility_type_cd check")
   IF (seligibility_type_mean=stemp_defer_cdf_mean)
    IF ((((request->donors[ldonor_index].defer_until_dt_tm=null)) OR ((request->donors[ldonor_index].
    defer_until_dt_tm=0))) )
     CALL errorhandler("F","DEFER_UNTIL_DT_TM val",concat(
       "Defer_until_dt_tm is blank for temp deferral. Please resolve ","for donor_xref_txt: ",request
       ->donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ENDIF
   CALL echo("End of donors.defer_until_dt_tm check")
   IF ((request->donors[ldonor_index].willingness_level_cd > 0.0))
    CALL check_valid_code_value(request->donors[ldonor_index].willingness_level_cd,
     lwillingness_level_code_set,"WILLINGNESS_LEVEL_CD val","Willingness_Level_cd: ")
   ENDIF
   CALL echo("End of donors.willingness_level_cd check")
   IF ((request->donors[ldonor_index].prefer_recruit_method_cd > 0.0))
    CALL check_valid_code_value(request->donors[ldonor_index].prefer_recruit_method_cd,
     lcontact_method_code_set,"PREFER_RECRUIT_METHOD_CD","Prefer_recruit_method_cd: ")
   ENDIF
   CALL echo("End of donors.prefer_recruit_method_cd check")
   IF ((request->donors[ldonor_index].prefer_don_ambulatory_cd > 0.0))
    CALL check_valid_code_value(request->donors[ldonor_index].prefer_don_ambulatory_cd,
     llocation_code_set,"PREFER_AMBULATORY_CD val","Prefer_don_ambulatory_cd: ")
   ENDIF
   CALL echo("End of donors.prefer_don_ambulatory_cd check")
   IF ((request->donors[ldonor_index].donor_aborh.aborh_cd > 0.0))
    CALL check_valid_code_value(request->donors[ldonor_index].donor_aborh.aborh_cd,
     laborh_result_code_set,"ABORH_CD validation","ABORH_CD: ")
    SET dabo_cd = 0.0
    SET drh_cd = 0.0
    SELECT INTO "nl:"
     FROM code_value_extension cve1,
      code_value_extension cve2
     PLAN (cve1
      WHERE (cve1.code_value=request->donors[ldonor_index].donor_aborh.aborh_cd)
       AND cve1.code_set=laborh_result_code_set
       AND cve1.field_name=saborh)
      JOIN (cve2
      WHERE cve2.code_value=cnvtreal(cve1.field_value)
       AND cve2.code_set=lstandard_aborh_code_set)
     DETAIL
      IF (cve2.field_name=sabo_only)
       dabo_cd = cnvtreal(cve2.field_value)
      ELSEIF (cve2.field_name=srh_only)
       drh_cd = cnvtreal(cve2.field_value)
      ENDIF
     WITH nocounter
    ;end select
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","ABORH_CD EXTENSION val",concat("ABORH_CD: ",trim(cnvtstring(request->
          donors[ldonor_index].donor_aborh.aborh_cd)),
        " not found on code_value_extension. Please resolve ","for donor_xref_txt: ",request->donors[
        ldonor_index].donor_xref_txt,
        "."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","ABORH_CD EXTENSION val",serrormsg)
     GO TO exit_script
    ENDIF
    SET nabo_code_set_discrep = 1
    SET nrh_code_set_discrep = 1
    SELECT INTO "nl:"
     cv.code_value, cv.code_set
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_value IN (dabo_cd, drh_cd)
       AND cv.code_set IN (labo_only_code_set, lrh_only_code_set)
       AND cv.active_ind=1)
     DETAIL
      IF (cv.code_value=dabo_cd)
       IF (cv.code_set=labo_only_code_set)
        nabo_code_set_discrep = 0
       ENDIF
      ENDIF
      IF (cv.code_value=drh_cd)
       IF (cv.code_set=lrh_only_code_set)
        nrh_code_set_discrep = 0
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","ABORH_CD validation",concat(
        "ABO_cd or rh_cd not found on code_set 1641 or 1642. Please resolve for ","donor_xref_txt: ",
        request->donors[ldonor_index].donor_xref_txt,"."))
      GO TO exit_script
     ELSEIF (nabo_code_set_discrep=1)
      CALL errorhandler("F","ABO_CD validation",concat(
        "ABO_CD not found in code_set 1641. Please resolve for ","donor_xref_txt: ",request->donors[
        ldonor_index].donor_xref_txt,"."))
      GO TO exit_script
     ELSEIF (nrh_code_set_discrep=1)
      CALL errorhandler("F","RH_CD validation",concat(
        "Rh_cd not found in code_set 1642. Please resolve for ","donor_xref_txt: ",request->donors[
        ldonor_index].donor_xref_txt,"."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","ABORH_CD validation",serrormsg)
     GO TO exit_script
    ENDIF
   ENDIF
   CALL echo("End of donors.aborh_cd check")
   SET lantigen_count = size(request->donors[ldonor_index].antigens,5)
   IF (lantigen_count > 0)
    FOR (lantigen_index = 1 TO lantigen_count)
      IF ((request->donors[ldonor_index].antigens[lantigen_index].encntr_id <= 0.0))
       CALL errorhandler("F","ENCNTR_ID validation",concat(
         "Antigen Encntr_id is blank. Please resolve ","for donor_xref_txt: ",request->donors[
         ldonor_index].donor_xref_txt,"."))
       GO TO exit_script
      ENDIF
      CALL check_valid_encntr_id(request->donors[ldonor_index].person_id,request->donors[ldonor_index
       ].antigens[lantigen_index].encntr_id,"Antigen Encntr_Id")
      CALL echo("End of donors.antigens.encntr_id check")
      CALL check_valid_code_value(request->donors[ldonor_index].antigens[lantigen_index].antigen_cd,
       lspecial_testing_code_set,"ANTIGEN_CD validation","Antigen_cd: ")
    ENDFOR
    SET nopposite_found_ind = 0
    SELECT INTO "nl:"
     FROM code_value cv,
      code_value_extension cve
     PLAN (cv
      WHERE cv.code_set=lspecial_testing_code_set
       AND expand(lidx,1,lantigen_count,cv.code_value,request->donors[ldonor_index].antigens[lidx].
       antigen_cd)
       AND ((cv.cdf_meaning="-") OR (cv.cdf_meaning="+"))
       AND cv.active_ind=1)
      JOIN (cve
      WHERE cve.code_set=cv.code_set
       AND cve.code_value=cv.code_value
       AND cve.field_name="Opposite")
     DETAIL
      FOR (lantigen_index = 1 TO lantigen_count)
        IF ((cnvtreal(cve.field_value)=request->donors[ldonor_index].antigens[lantigen_index].
        antigen_cd))
         nopposite_found_ind = 1, sopposite_antigen_1 = trim(cnvtstring(request->donors[ldonor_index]
           .antigens[lantigen_index].antigen_cd)), sopposite_antigen_2 = trim(cnvtstring(cve
           .field_value))
        ENDIF
      ENDFOR
     WITH nocounter
    ;end select
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (nopposite_found_ind=1)
      CALL errorhandler("F","Opposite Antigen Found",concat("Opposite Antigen Found for person_id: ",
        trim(cnvtstring(request->donors[ldonor_index].person_id))," antigen_cd: ",sopposite_antigen_1,
        " with opposite field_value: ",
        sopposite_antigen_2,". Please resolve ","for donor_xref_txt: ",trim(request->donors[
         ldonor_index].donor_xref_txt),"."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","Opposite Antigen select",serrormsg)
     GO TO exit_script
    ENDIF
   ENDIF
   CALL echo("End of donors.antigens.antigen_cd check")
   SET lantibody_count = size(request->donors[ldonor_index].antibodies,5)
   IF (lantibody_count > 0)
    FOR (lantibody_index = 1 TO lantibody_count)
      IF ((request->donors[ldonor_index].antibodies[lantibody_index].encntr_id <= 0.0))
       CALL errorhandler("F","ENCNTR_ID validation",concat(
         "Antibody Encntr_id is blank. Please resolve ","for donor_xref_txt: ",request->donors[
         ldonor_index].donor_xref_txt,"."))
       GO TO exit_script
      ENDIF
      CALL check_valid_encntr_id(request->donors[ldonor_index].person_id,request->donors[ldonor_index
       ].antibodies[lantibody_index].encntr_id,"Antibody Encntr_Id")
      CALL echo("End of donors.antibodies.encntr_id check")
      CALL check_valid_code_value(request->donors[ldonor_index].antibodies[lantibody_index].
       antibody_cd,lantibody_code_set,"ANTIBODY_CD validation","Antibody_cd: ")
      CALL echo("End of donors.antibodies.antibody_cd check")
    ENDFOR
   ENDIF
   SET lrare_type_count = size(request->donors[ldonor_index].rare_types,5)
   IF (lrare_type_count > 0)
    FOR (lrare_type_index = 1 TO lrare_type_count)
      CALL check_valid_code_value(request->donors[ldonor_index].rare_types[lrare_type_index].
       rare_type_cd,lrare_type_code_set,"RARE_TYPE_CD validation","Rare_type_cd: ")
    ENDFOR
    CALL echo("End of donors.rare_types.rare_type_cd check")
   ENDIF
   SET lspecial_interest_count = size(request->donors[ldonor_index].spec_interests,5)
   IF (lspecial_interest_count > 0)
    FOR (lspecial_interest_index = 1 TO lspecial_interest_count)
      CALL check_valid_code_value(request->donors[ldonor_index].spec_interests[
       lspecial_interest_index].special_interest_cd,lspecial_interest_code_set,
       "SPECIAL_INTEREST_CD val","Special_interest_cd: ")
    ENDFOR
    CALL echo("End of donors.spec_interests.special_interest_cd check")
   ENDIF
   SET ldonor_note_count = size(request->donors[ldonor_index].donor_notes,5)
   IF (ldonor_note_count > 0)
    FOR (ldonor_note_index = 1 TO ldonor_note_count)
      IF (get_cdf_meaning_by_code(request->donors[ldonor_index].donor_notes[ldonor_note_index].
       comment_type_cd,lcomment_type_code_set,"COMMENT_TYPE_CD select","Donor Note Comment_type_cd")
       != sdonor_comment_cdf_mean)
       CALL errorhandler("F","COMMENT_TYPE_CD val",concat("Donor Notes Comment_Type_CD: ",trim(
          cnvtstring(request->donors[ldonor_index].donor_notes[ldonor_note_index].comment_type_cd)),
         " does not exist in code_set 14. Please resolve ","for donor_xref_txt: ",request->donors[
         ldonor_index].donor_xref_txt,
         "."))
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
   SET lsecured_note_count = size(request->donors[ldonor_index].secured_notes,5)
   IF (lsecured_note_count > 0)
    FOR (lsecured_note_index = 1 TO lsecured_note_count)
      IF ( NOT (get_cdf_meaning_by_code(request->donors[ldonor_index].secured_notes[
       lsecured_note_index].comment_type_cd,lcomment_type_code_set,"COMMENT_TYPE_CD select",
       "Secured Note Comment_type_cd") IN (sconfidential_comment_cdf_mean, scounsel_comment_cdf_mean)
      ))
       CALL errorhandler("F","COMMENT_TYPE_CD val",concat("Secured Notes Comment_type_cd: ",trim(
          cnvtstring(request->donors[ldonor_index].secured_notes[lsecured_note_index].comment_type_cd
           ))," does not exist in code_set 14. Please resolve ","for donor_xref_txt: ",request->
         donors[ldonor_index].donor_xref_txt,
         "."))
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
   SET lsecured_note_count = size(request->donors[ldonor_index].secured_notes,5)
   IF (lsecured_note_count > 0)
    SET nfound_confidential_ind = 0
    SET nfound_counsel_ind = 0
    FOR (lsecured_note_index = 1 TO lsecured_note_count)
     SET lcontact_count = size(request->donors[ldonor_index].contacts,5)
     IF (lcontact_count > 0)
      IF (nfound_confidential_ind=0)
       IF (get_cdf_meaning_by_code(request->donors[ldonor_index].secured_notes[lsecured_note_index].
        comment_type_cd,lcomment_type_code_set,"COMMENT_TYPE_CD select",
        "Secured Note Comment_type_cd")=sconfidential_comment_cdf_mean)
        FOR (lcontact_index = 1 TO lcontact_count)
          IF (nfound_confidential_ind=0)
           IF (get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[lcontact_index].
            contact_type_cd,lcontact_type_code_set,"CONTACT_TYPE_CD select","Contact contact_type_cd"
            )=sconfidential_cdf_mean)
            SET nfound_confidential_ind = 1
           ENDIF
          ENDIF
        ENDFOR
        IF (nfound_confidential_ind=0)
         CALL errorhandler("F","COMMENT_TYPE_CD val",concat("Secured Notes comment_type_mean: ",trim(
            sconfidential_comment_cdf_mean)," is not accompanied by a contact of ",trim(
            sconfidential_cdf_mean),". Please resolve."))
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
      IF (nfound_counsel_ind=0)
       IF (get_cdf_meaning_by_code(request->donors[ldonor_index].secured_notes[lsecured_note_index].
        comment_type_cd,lcomment_type_code_set,"COMMENT_TYPE_CD select",
        "Secured Note Comment_type_cd")=scounsel_comment_cdf_mean)
        FOR (lcontact_index = 1 TO lcontact_count)
          IF (nfound_counsel_ind=0)
           IF (get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[lcontact_index].
            contact_type_cd,lcontact_type_code_set,"CONTACT_TYPE_CD select","Contact contact_type_cd"
            )=scounsel_cdf_mean)
            SET nfound_counsel_ind = 1
           ENDIF
          ENDIF
        ENDFOR
        IF (nfound_counsel_ind=0)
         CALL errorhandler("F","COMMENT_TYPE_CD val",concat("Secured Notes comment_type_mean: ",trim(
            scounsel_comment_cdf_mean)," is not accompanied by a contact_type_mean: ",trim(
            scounsel_cdf_mean),". Please resolve."))
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
     ELSE
      CALL errorhandler("F","COMMENT_TYPE_CD val",concat("Secured Notes Comment_type_cd: ",trim(
         cnvtstring(request->donors[ldonor_index].secured_notes[lsecured_note_index].comment_type_cd)
         )," exisits without any contacts. Please resolve."))
      GO TO exit_script
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE check_valid_contact_items(ldonor_index)
   SET lcontact_count = size(request->donors[ldonor_index].contacts,5)
   FOR (lcontact_index = 1 TO lcontact_count)
    IF ((request->donors[ldonor_index].contacts[lcontact_index].encntr_id <= 0.0))
     CALL errorhandler("F","ENCNTR_ID validation",concat(
       "Contacts Encntr_id is blank. Please resolve ","for donor_xref_txt: ",request->donors[
       ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
    CALL check_valid_encntr_id(request->donors[ldonor_index].person_id,request->donors[ldonor_index].
     contacts[lcontact_index].encntr_id,"Contact Encntr_Id")
   ENDFOR
   FOR (lcontact_index = 1 TO lcontact_count)
     IF ((((request->donors[ldonor_index].contacts[lcontact_index].contact_dt_tm=null)) OR ((request
     ->donors[ldonor_index].contacts[lcontact_index].contact_dt_tm=0))) )
      CALL errorhandler("F","CONTACT_DT_TM validation",concat(
        "Contact_dt_tm is blank. Please resolve ","for donor_xref_txt: ",request->donors[ldonor_index
        ].donor_xref_txt,"."))
      GO TO exit_script
     ENDIF
   ENDFOR
   FOR (lcontact_index = 1 TO lcontact_count)
     IF ((request->donors[ldonor_index].contacts[lcontact_index].init_contact_prsnl_id > 0.0))
      CALL check_valid_prsnl_id(request->donors[ldonor_index].contacts[lcontact_index].
       init_contact_prsnl_id,"Init_contact_prsnl_id")
     ENDIF
   ENDFOR
   CALL echo("End init_contact_prsnl_id check")
   FOR (lcontact_index = 1 TO lcontact_count)
     CALL check_valid_code_value(request->donors[ldonor_index].contacts[lcontact_index].
      contact_outcome_cd,lcontact_outcome_code_set,"CONTACT_OUTCOME_CD val","Contact_outcome_cd: ")
   ENDFOR
   CALL echo("after contact_outcome_cd check")
   FOR (lcontact_index = 1 TO lcontact_count)
    SET scontact_type_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[
     lcontact_index].contact_type_cd,lcontact_type_code_set,"CONTACT_TYPE_CD val","Contact_type_cd")
    IF (((scontact_type_mean=sconfidential_cdf_mean) OR (scontact_type_mean=scounsel_cdf_mean)) )
     CALL check_valid_other_contact_items(ldonor_index,lcontact_index)
    ENDIF
   ENDFOR
   CALL echo("after Check_Valid_Other_Contact_Items")
   FOR (lcontact_index = 1 TO lcontact_count)
     IF ((request->donors[ldonor_index].contacts[lcontact_index].donation_result.procedure_cd > 0.0))
      SET nfull_donation_upload = 1
      SET lcontact_index = lcontact_count
     ENDIF
   ENDFOR
   IF (nfull_donation_upload=1)
    FOR (lcontact_index = 1 TO lcontact_count)
      SET scontact_type_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[
       lcontact_index].contact_type_cd,lcontact_type_code_set,"CONTACT_TYPE_CD select",
       "Contact_type_cd")
      IF (scontact_type_mean=sdonate_cdf_mean)
       CALL check_valid_donation_rslt_items(ldonor_index,lcontact_index)
      ENDIF
      CALL echo("after Check_Valid_Donation_Rslt_Items check")
    ENDFOR
   ENDIF
   FOR (lcontact_index = 1 TO lcontact_count)
     SET seligibility_type_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[
      lcontact_index].donor_eligibility.eligibility_type_cd,leligibility_type_code_set,
      "ELIGIBILITY_TYPE_CD val","Contacts Eligibility_type_cd")
     IF (((seligibility_type_mean=stemp_defer_cdf_mean) OR (seligibility_type_mean=
     sperm_defer_cdf_mean)) )
      SET ldefer_reason_count = size(request->donors[ldonor_index].contacts[lcontact_index].
       donor_eligibility.deferral_reasons,5)
      IF (ldefer_reason_count=0)
       CALL errorhandler("F","DEFERRAL_REASONS val",concat(
         "Deferral_reasons is blank for temp or permanent deferral. Please resolve ",
         "for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,"."))
       GO TO exit_script
      ENDIF
      FOR (ldefer_reason_index = 1 TO ldefer_reason_count)
        CALL check_valid_code_value(request->donors[ldonor_index].contacts[lcontact_index].
         donor_eligibility.deferral_reasons[ldefer_reason_index].reason_cd,lreason_code_set,
         "REASON_CD validation","Deferral Reason_cd: ")
      ENDFOR
      IF (seligibility_type_mean=stemp_defer_cdf_mean)
       FOR (ldefer_reason_index = 1 TO ldefer_reason_count)
         IF ((((request->donors[ldonor_index].contacts[lcontact_index].donor_eligibility.
         deferral_reasons[ldefer_reason_index].eligible_dt_tm=null)) OR ((request->donors[
         ldonor_index].contacts[lcontact_index].donor_eligibility.deferral_reasons[
         ldefer_reason_index].eligible_dt_tm=0))) )
          CALL errorhandler("F","ELIGIBLE_DT_TM validation",concat(
            "Eligible_dt_tm is blank for temp deferral. Please resolve ","for donor_xref_txt: ",
            request->donors[ldonor_index].donor_xref_txt,"."))
          GO TO exit_script
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
     SET sfinal_contact_outcome_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].
      contacts[lcontact_index].contact_outcome_cd,lcontact_outcome_code_set,"CONTACT_OUTCOME_CD val",
      "contact_outcome_cd")
     IF (sfinal_contact_outcome_mean=ssuccess_outcome_cdf_mean)
      IF (seligibility_type_mean != sgood_cdf_mean)
       CALL errorhandler("F","ELIGIBILITY_TYPE_CD val",concat(
         "Donor eligibility type doesn't match the eligibility corresponding to final outcome. Please resolve ",
         "for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,"."))
       GO TO exit_script
      ENDIF
     ELSEIF (sfinal_contact_outcome_mean=stemp_defer_outcome_cdf_mean)
      IF (seligibility_type_mean != stemp_defer_cdf_mean)
       CALL errorhandler("F","ELIGIBILITY_TYPE_CD val",concat(
         "Donor eligibility type doesn't match the eligibility corresponding to final outcome. Please resolve ",
         "for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,"."))
       GO TO exit_script
      ENDIF
     ELSEIF (sfinal_contact_outcome_mean=sperm_defer_outcome_cdf_mean)
      IF (seligibility_type_mean != sperm_defer_cdf_mean)
       CALL errorhandler("F","ELIGIBILITY_TYPE_CD val",concat(
         "Donor eligibility type doesn't match the eligibility corresponding to final outcome. Please resolve ",
         "for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,"."))
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE check_valid_donation_rslt_items(ldonor_index,lcontact_index)
   IF ((((request->donors[ldonor_index].contacts[lcontact_index].donation_result.drawn_dt_tm=null))
    OR ((request->donors[ldonor_index].contacts[lcontact_index].donation_result.drawn_dt_tm=0))) )
    CALL errorhandler("F","DRAWN_DT_TM validation",concat("Drawn_dt_tm is blank. Please resolve ",
      "for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,"."))
    GO TO exit_script
   ENDIF
   CALL check_valid_code_value(request->donors[ldonor_index].contacts[lcontact_index].donation_result
    .procedure_cd,lprocedure_code_set,"PROCEDURE_CD validation","Procedure_cd: ")
   CALL echo("End check PROCEDURE_CD")
   IF ((request->donors[ldonor_index].contacts[lcontact_index].donation_result.phleb_prsnl_id > 0.0))
    CALL check_valid_prsnl_id(request->donors[ldonor_index].contacts[lcontact_index].donation_result.
     phleb_prsnl_id,"Phleb_prsnl_id")
   ENDIF
   CALL echo("End check PHLEB_PRSNL_ID")
   IF ((request->donors[ldonor_index].contacts[lcontact_index].donation_result.venipuncture_site_cd
    > 0.0))
    CALL check_valid_code_value(request->donors[ldonor_index].contacts[lcontact_index].
     donation_result.venipuncture_site_cd,lvenipuncture_site_code_set,"VENIPUNCTURE_SITE_CD val",
     "Venipuncture_site_cd: ")
   ENDIF
   CALL echo("End check venipuncture_site_cd")
   IF ((request->donors[ldonor_index].contacts[lcontact_index].donation_result.bag_type_cd > 0.0))
    CALL check_valid_code_value(request->donors[ldonor_index].contacts[lcontact_index].
     donation_result.bag_type_cd,lbag_type_code_set,"BAG_TYPE_CD validation","Bag_type_cd: ")
   ENDIF
   CALL echo("End check bag_type_cd")
   IF ((request->donors[ldonor_index].contacts[lcontact_index].donation_result.specimen_volume > 0))
    IF ((request->donors[ldonor_index].contacts[lcontact_index].donation_result.specimen_unit_meas_cd
     <= 0.0))
     CALL errorhandler("F","SPECIMEN_UNIT_MEAS_CD val",concat(
       "Specimen_volume is passed in, but specimen_unit_meas_cd is not passed in. Please resolve ",
       "for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((request->donors[ldonor_index].contacts[lcontact_index].donation_result.specimen_unit_meas_cd
    > 0.0))
    CALL check_valid_code_value(request->donors[ldonor_index].contacts[lcontact_index].
     donation_result.specimen_unit_meas_cd,lspecimen_unit_meas_code_set,"SPECIMEN_UNIT_MEAS_CD val",
     "Specimen_unit_meas_cd: ")
   ENDIF
   CALL echo("End check specimen_unit_meas_cd")
   CALL check_valid_code_value(request->donors[ldonor_index].contacts[lcontact_index].donation_result
    .outcome_cd,lcontact_outcome_code_set,"OUTCOME_CD validation","Donation result outcome_cd: ")
   CALL echo("End check Donation Result OUTCOME_CD validation")
   SET lproduct_count = size(request->donors[ldonor_index].contacts[lcontact_index].donation_result.
    products,5)
   FOR (lproduct_index = 1 TO lproduct_count)
     IF (size(trim(request->donors[ldonor_index].contacts[lcontact_index].donation_result.products.
       cross_reference,3),1)=0)
      CALL errorhandler("F","CROSS_REFERENCE val",concat(
        "Product Cross_reference is blank. Please resolve ","for donor_xref_txt: ",request->donors[
        ldonor_index].donor_xref_txt,"."))
      GO TO exit_script
     ENDIF
     IF (size(trim(request->donors[ldonor_index].contacts[lcontact_index].donation_result.products.
       product_nbr,3),1)=0)
      CALL errorhandler("F","PRODUCT_NBR validation",concat(
        "Product_number is blank. Please resolve ","for donor_xref_txt: ",request->donors[
        ldonor_index].donor_xref_txt,"."))
      GO TO exit_script
     ENDIF
     IF ((request->donors[ldonor_index].contacts[lcontact_index].donation_result.bag_type_cd=0.0))
      CALL errorhandler("F","BAG_TYPE_CD validation",concat("BAG_TYPE_CD is 0.0. Please resolve ",
        "for donor_xref_txt: ",trim(request->donors[ldonor_index].donor_xref_txt),"."))
      GO TO exit_script
     ENDIF
   ENDFOR
   CALL check_valid_donation_product(ldonor_index,lcontact_index)
   CALL echo("End Check_Valid_Donation_Product")
   IF ((request->donors[ldonor_index].contacts[lcontact_index].donation_result.
   donation_comment_type_cd > 0.0))
    IF (get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[lcontact_index].
     donation_result.donation_comment_type_cd,lcomment_type_code_set,"DONATION_COMMENT_TYPE_CD",
     "DONATION_COMMENT_TYPE_CD select") != sdonation_comment_cdf_mean)
     CALL errorhandler("F","DONATION_COMMENT_TYPE_CD",concat("Donation Comment_type_cd: ",trim(
        cnvtstring(request->donors[ldonor_index].contacts[lcontact_index].donation_result.
         donation_comment_type_cd))," does not exist in code_set 14. Please resolve ",
       "for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,
       "."))
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE check_valid_other_contact_items(ldonor_index,lcontact_index)
   IF ((request->donors[ldonor_index].contacts[lcontact_index].other_contact.contact_prsnl_id > 0.0))
    CALL check_valid_prsnl_id(request->donors[ldonor_index].contacts[lcontact_index].other_contact.
     contact_prsnl_id,"Other Contacat Contact_prsnl_id")
   ENDIF
   IF ((request->donors[ldonor_index].contacts[lcontact_index].other_contact.method_cd > 0.0))
    CALL check_valid_code_value(request->donors[ldonor_index].contacts[lcontact_index].other_contact.
     method_cd,lcontact_method_code_set,"METHOD_CD validation","Other contact Method_cd: ")
   ENDIF
   CALL check_valid_code_value(request->donors[ldonor_index].contacts[lcontact_index].other_contact.
    outcome_cd,lcontact_outcome_code_set,"OUTCOME_CD validation","Other contact Outcome_cd: ")
 END ;Subroutine
 SUBROUTINE upload_donor_demographics(ldonor_index)
   CALL add_hist_person_donor(ldonor_index)
   IF (((dabo_cd > 0.0) OR (drh_cd > 0.0)) )
    CALL add_hist_donor_aborh(ldonor_index,dabo_cd,drh_cd)
   ENDIF
   IF (size(request->donors[ldonor_index].antigens,5) > 0)
    CALL add_hist_donor_antigen(ldonor_index)
   ENDIF
   IF (size(request->donors[ldonor_index].antibodies,5) > 0)
    CALL add_hist_donor_antibody(ldonor_index)
   ENDIF
   IF ((request->donors[ldonor_index].prefer_recruit_method_cd > 0.0))
    CALL add_hist_contact_method(ldonor_index)
   ENDIF
   IF (size(request->donors[ldonor_index].rare_types,5) > 0)
    CALL add_hist_rare_types(ldonor_index)
   ENDIF
   IF (size(request->donors[ldonor_index].spec_interests,5) > 0)
    CALL add_hist_special_interest(ldonor_index)
   ENDIF
   IF (size(request->donors[ldonor_index].donor_notes,5) > 0)
    CALL add_hist_donor_note(ldonor_index)
   ENDIF
 END ;Subroutine
 SUBROUTINE upload_donor_contacts(ldonor_index)
   DECLARE nduplicate_contact_ind = i2 WITH protect, noconstant(0)
   SET lcontact_count = size(request->donors[ldonor_index].contacts,5)
   FOR (lcontact_index = 1 TO lcontact_count)
    SET nduplicate_contact_ind = check_duplicate_contact(ldonor_index,lcontact_index)
    IF (nduplicate_contact_ind=0)
     CALL add_hist_donor_contact(ldonor_index,lcontact_index)
     CALL echo("After Add_Hist_Donor_Contact")
     CALL add_hist_donor_eligibility(ldonor_index,lcontact_index)
     CALL echo("After Add_Hist_Donor_Eligibility")
     IF (size(request->donors[ldonor_index].contacts[lcontact_index].donor_eligibility.
      deferral_reasons,5) > 0)
      CALL add_hist_deferral_reason(ldonor_index,lcontact_index)
     ENDIF
     CALL echo("After Add_Hist_Deferral_Reason")
     SET scontact_type_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[
      lcontact_index].contact_type_cd,lcontact_type_code_set,"CONTACT_TYPE_CD select",
      "Contact_type_cd")
     IF (((scontact_type_mean=sconfidential_cdf_mean) OR (scontact_type_mean=scounsel_cdf_mean)) )
      CALL add_hist_other_contact(ldonor_index,lcontact_index)
      IF (size(request->donors[ldonor_index].secured_notes,5) > 0)
       IF (scontact_type_mean=sconfidential_cdf_mean)
        CALL add_hist_confidential_note(ldonor_index)
        CALL echo("After Add_Hist_Confidential_Note")
       ELSE
        CALL add_hist_counseling_note(ldonor_index)
        CALL echo("After Add_Hist_Counseling_Note")
       ENDIF
      ENDIF
     ENDIF
     IF (nfull_donation_upload=1)
      IF (scontact_type_mean=sdonate_cdf_mean)
       CALL add_hist_donation_result(ldonor_index,lcontact_index)
       CALL echo("After Add_Hist_Donation_Result")
       SET scontact_outcome_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[
        lcontact_index].donation_result.outcome_cd,lcontact_outcome_code_set,"OUTCOME_CD select",
        "Donation result outcome_cd")
       SET lproduct_count = size(request->donors[ldonor_index].contacts[lcontact_index].
        donation_result.products,5)
       IF (scontact_outcome_mean=ssuccess_outcome_cdf_mean
        AND lproduct_count > 0)
        CALL add_hist_donation_product_rel(ldonor_index,lcontact_index)
       ENDIF
       CALL echo("After Add_Hist_Donation_Product_Rel")
       IF (size(trim(request->donors[ldonor_index].contacts[lcontact_index].donation_result.
         donation_comment,3),1) > 0)
        CALL add_hist_contact_note(ldonor_index,lcontact_index)
       ENDIF
       CALL echo("After Add_Hist_Contact_Note")
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE check_duplicate_contact(ldonor_index,lcontact_index)
   DECLARE nduplicate_ind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM bbd_donor_contact bdc
    PLAN (bdc
     WHERE (bdc.person_id=request->donors[ldonor_index].person_id)
      AND (bdc.encntr_id=request->donors[ldonor_index].contacts[lcontact_index].encntr_id)
      AND (bdc.contact_type_cd=request->donors[ldonor_index].contacts[lcontact_index].contact_type_cd
     )
      AND bdc.contact_dt_tm=cnvtdatetime(request->donors[ldonor_index].contacts[lcontact_index].
      contact_dt_tm))
    WITH nocounter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual > 0)
     SET nduplicate_ind = 1
    ENDIF
   ELSE
    CALL errorhandler("F","Duplicate checking",serrormsg)
    GO TO exit_script
   ENDIF
   RETURN(nduplicate_ind)
 END ;Subroutine
 SUBROUTINE check_valid_code_value(dcode_value,lcode_set,sobjectname,sobjectvalue)
   SELECT INTO "nl:"
    cv.code_value, cv.code_set
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_value=dcode_value
      AND cv.code_set=lcode_set
      AND cv.active_ind=1
      AND cv.code_value > 0.0)
    WITH nocounter
   ;end select
   SET nerror_check = error(serrormsg,0)
   CALL echo(build("code_value CURQUAL: ",curqual))
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F",sobjectname,concat(sobjectvalue,": ",trim(cnvtstring(dcode_value)),
       " not found in code_set ",trim(cnvtstring(lcode_set)),
       ". ","Please resolve for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F",sobjectname,serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE get_cdf_meaning_by_code(dcode_value,lcode_set,sobjectname,sobjectvalue)
   DECLARE scdf_meaning = c12 WITH protect, noconstant(fillstring(12," "))
   SELECT INTO "nl:"
    cv.code_value, cv.code_set
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_value=dcode_value
      AND cv.code_set=lcode_set
      AND cv.active_ind=1
      AND cv.code_value > 0.0)
    DETAIL
     scdf_meaning = cv.cdf_meaning
    WITH nocounter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F",sobjectname,concat(sobjectvalue,": ",trim(cnvtstring(dcode_value)),
       " not found in code_set ",trim(cnvtstring(lcode_set)),
       ". ","Please resolve for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F",sobjectname,serrormsg)
    GO TO exit_script
   ENDIF
   RETURN(scdf_meaning)
 END ;Subroutine
 SUBROUTINE get_code_by_cdf_meaning(scdf_mean,lcode_set,sobjectname,sobjectvalue)
   DECLARE dcode_value = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    cv.code_value, cv.code_set
    FROM code_value cv
    PLAN (cv
     WHERE cv.cdf_meaning=scdf_mean
      AND cv.code_set=lcode_set
      AND cv.active_ind=1
      AND cv.code_value > 0.0)
    DETAIL
     dcode_value = cv.code_value
    WITH nocounter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F",sobjectname,concat(sobjectvalue,": ",scdf_mean," not found in code_set ",
       trim(cnvtstring(lcode_set)),
       ". ","Please resolve for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F",sobjectname,serrormsg)
    GO TO exit_script
   ENDIF
   RETURN(dcode_value)
 END ;Subroutine
 SUBROUTINE check_valid_encntr_id(dperson_id,dencntr_id,sobjectstring)
   SELECT INTO "nl:"
    e.encntr_id, e.person_id
    FROM encounter e
    PLAN (e
     WHERE e.encntr_id=dencntr_id
      AND e.person_id=dperson_id
      AND e.active_ind=1)
    WITH nocounter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","ENCNTR_ID validation",concat(sobjectstring,": ",trim(cnvtstring(
         dencntr_id))," does not exist on the Encounter table. Please resolve for ",
       "donor_xref_txt: ",
       request->donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","ENCNTR_ID validation",serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_valid_prsnl_id(dprsnl_id,sobjectstring)
   SELECT INTO "nl:"
    pr.person_id
    FROM prsnl pr
    PLAN (pr
     WHERE pr.person_id=dprsnl_id
      AND pr.person_id > 0.0
      AND pr.active_ind=1)
    WITH nocounter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","PRSNL_ID validation",concat(sobjectstring,": ",trim(cnvtstring(dprsnl_id)
        )," does not exist on the Prsnl table. Please resolve for ","donor_xref_txt: ",
       request->donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","PRSNL_ID validation",serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_valid_donation_product(ldonor_index,lcontact_index)
  SET lproduct_count = size(request->donors[ldonor_index].contacts[lcontact_index].donation_result.
   products,5)
  FOR (lproduct_index = 1 TO lproduct_count)
    SET dproduct_id = 0.0
    SELECT INTO "nl"
     FROM bbhist_product bp
     PLAN (bp
      WHERE (bp.product_nbr=request->donors[ldonor_index].contacts[lcontact_index].donation_result.
      products[lproduct_index].product_nbr)
       AND (bp.cross_reference=request->donors[ldonor_index].contacts[lcontact_index].donation_result
      .products[lproduct_index].cross_reference)
       AND bp.active_ind=1)
     DETAIL
      dproduct_id = bp.product_id
     WITH nocounter
    ;end select
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check != 0)
     CALL errorhandler("F","BBHIST_PRODUCT select",serrormsg)
     GO TO exit_script
    ENDIF
    IF (dproduct_id=0.0)
     CALL errorhandler("F","BBHIST_PRODUCT select",concat("Donation result product: ",request->
       donors[ldonor_index].contacts[lcontact_index].donation_result.products[lproduct_index].
       product_nbr," doesn't exist in BBHIST_PRODUCT table.  Please resolve"," for donor_xref_txt: ",
       request->donors[ldonor_index].donor_xref_txt,
       "."))
     GO TO exit_script
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE add_hist_contact_method(ldonor_index)
   DECLARE ncontact_method_exist_ind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM bbd_contact_method bcm
    PLAN (bcm
     WHERE (bcm.person_id=request->donors[ldonor_index].person_id)
      AND (bcm.contact_method_cd=request->donors[ldonor_index].prefer_recruit_method_cd)
      AND bcm.active_ind=1)
    DETAIL
     ncontact_method_exist_ind = 1
    WITH nocounter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check != 0)
    CALL errorhandler("F","CONTACT_METHOD_CD select",serrormsg)
    GO TO exit_script
   ENDIF
   IF (ncontact_method_exist_ind=0)
    INSERT  FROM bbd_contact_method bcm
     SET bcm.contact_method_id = seq(pathnet_seq,nextval), bcm.person_id = request->donors[
      ldonor_index].person_id, bcm.contact_method_cd = request->donors[ldonor_index].
      prefer_recruit_method_cd,
      bcm.contributor_system_cd = request->contributor_system_cd, bcm.active_ind = 1, bcm
      .active_status_cd = reqdata->active_status_cd,
      bcm.active_status_dt_tm = cnvtdatetime(request->active_status_dt_tm), bcm
      .active_status_prsnl_id = request->active_status_prsnl_id, bcm.updt_cnt = 0,
      bcm.updt_dt_tm = cnvtdatetime(curdate,curtime3), bcm.updt_id = reqinfo->updt_id, bcm.updt_task
       = reqinfo->updt_task,
      bcm.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","BBD_CONTACT_METHOD insert",concat(
        "Insert into BBD_CONTACT_METHOD table failed. Please resolve ","for donor_xref_txt: ",request
        ->donors[ldonor_index].donor_xref_txt,"."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_CONTACT_METHOD insert",serrormsg)
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_hist_rare_types(ldonor_index)
   DECLARE nrare_type_exist_ind = i2 WITH protect, noconstant(0)
   SET lrare_type_count = size(request->donors[ldonor_index].rare_types,5)
   FOR (lrare_type_index = 1 TO lrare_type_count)
     SET nrare_type_exist_ind = 0
     SELECT INTO "nl:"
      FROM bbd_rare_types brt
      PLAN (brt
       WHERE (brt.person_id=request->donors[ldonor_index].person_id)
        AND (brt.rare_type_cd=request->donors[ldonor_index].rare_types[lrare_type_index].rare_type_cd
       )
        AND brt.active_ind=1)
      DETAIL
       nrare_type_exist_ind = 1
      WITH nocounter
     ;end select
     SET nerror_check = error(serrormsg,0)
     IF (nerror_check != 0)
      CALL errorhandler("F","Rare_Type_CD select",serrormsg)
      GO TO exit_script
     ENDIF
     IF (nrare_type_exist_ind=0)
      INSERT  FROM bbd_rare_types brt
       SET brt.rare_id = seq(pathnet_seq,nextval), brt.person_id = request->donors[ldonor_index].
        person_id, brt.rare_type_cd = request->donors[ldonor_index].rare_types[lrare_type_index].
        rare_type_cd,
        brt.contributor_system_cd = request->contributor_system_cd, brt.active_ind = 1, brt
        .active_status_cd = reqdata->active_status_cd,
        brt.active_status_dt_tm = cnvtdatetime(request->active_status_dt_tm), brt
        .active_status_prsnl_id = request->active_status_prsnl_id, brt.updt_cnt = 0,
        brt.updt_dt_tm = cnvtdatetime(curdate,curtime3), brt.updt_id = reqinfo->updt_id, brt
        .updt_task = reqinfo->updt_task,
        brt.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET nerror_check = error(serrormsg,0)
      IF (nerror_check=0)
       IF (curqual=0)
        CALL errorhandler("F","BBD_RARE_TYPES insert",concat(
          "Insert into BBD_RARE_TYPES table failed. Please resolve ","for donor_xref_txt: ",request->
          donors[ldonor_index].donor_xref_txt,"."))
        GO TO exit_script
       ENDIF
      ELSE
       CALL errorhandler("F","BBD_RARE_TYPES insert",serrormsg)
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE add_hist_special_interest(ldonor_index)
   DECLARE nspec_interest_exist_ind = i2 WITH protect, noconstant(0)
   SET lspecial_interest_count = size(request->donors[ldonor_index].spec_interests,5)
   FOR (lspecial_interest_index = 1 TO lspecial_interest_count)
     SET nspec_interest_exist_ind = 0
     SELECT INTO "nl:"
      FROM bbd_special_interest bsi
      PLAN (bsi
       WHERE (bsi.person_id=request->donors[ldonor_index].person_id)
        AND (bsi.special_interest_cd=request->donors[ldonor_index].spec_interests[
       lspecial_interest_index].special_interest_cd)
        AND bsi.active_ind=1)
      DETAIL
       nspec_interest_exist_ind = 1
      WITH nocounter
     ;end select
     SET nerror_check = error(serrormsg,0)
     IF (nerror_check != 0)
      CALL errorhandler("F","BBD_SPECIAL_INTEREST sel",serrormsg)
      GO TO exit_script
     ENDIF
     IF (nspec_interest_exist_ind=0)
      INSERT  FROM bbd_special_interest bsi
       SET bsi.special_interest_id = seq(pathnet_seq,nextval), bsi.person_id = request->donors[
        ldonor_index].person_id, bsi.special_interest_cd = request->donors[ldonor_index].
        spec_interests[lspecial_interest_index].special_interest_cd,
        bsi.contributor_system_cd = request->contributor_system_cd, bsi.active_ind = 1, bsi
        .active_status_cd = reqdata->active_status_cd,
        bsi.active_status_dt_tm = cnvtdatetime(request->active_status_dt_tm), bsi
        .active_status_prsnl_id = request->active_status_prsnl_id, bsi.updt_cnt = 0,
        bsi.updt_dt_tm = cnvtdatetime(curdate,curtime3), bsi.updt_id = reqinfo->updt_id, bsi
        .updt_task = reqinfo->updt_task,
        bsi.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET nerror_check = error(serrormsg,0)
      IF (nerror_check=0)
       IF (curqual=0)
        CALL errorhandler("F","BBD_SPECIAL_INTEREST ins",concat(
          "Insert into BBD_SPECIAL_INTEREST table failed. Please resolve ","for donor_xref_txt: ",
          request->donors[ldonor_index].donor_xref_txt,"."))
        GO TO exit_script
       ENDIF
      ELSE
       CALL errorhandler("F","BBD_SPECIAL_INTEREST ins",serrormsg)
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE add_hist_donor_note(ldonor_index)
   DECLARE sdonor_note = vc WITH protect, noconstant("")
   DECLARE ddonor_note_id = f8 WITH protect, noconstant(0.0)
   DECLARE ndonor_note_exist_ind = i2 WITH protect, noconstant(0)
   SET dlong_text_id = 0.0
   SELECT INTO "nl:"
    FROM bbd_donor_note bdn,
     long_text lt
    PLAN (bdn
     WHERE (bdn.person_id=request->donors[ldonor_index].person_id)
      AND bdn.donor_note_id > 0.0
      AND bdn.active_ind=1)
     JOIN (lt
     WHERE lt.long_text_id=bdn.long_text_id
      AND lt.long_text_id > 0.0
      AND lt.active_ind=1)
    DETAIL
     ddonor_note_id = bdn.donor_note_id, sdonor_note = lt.long_text, dlong_text_id = lt.long_text_id
    WITH nocounter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     SET ndonor_note_exist_ind = 0
    ELSE
     SET ndonor_note_exist_ind = 1
    ENDIF
   ELSE
    CALL errorhandler("F","BBD_DONOR_NOTE select",serrormsg)
    GO TO exit_script
   ENDIF
   IF (ndonor_note_exist_ind=0)
    SET ldonor_note_count = size(request->donors[ldonor_index].donor_notes,5)
    FOR (ldonor_note_index = 1 TO ldonor_note_count)
      IF (ldonor_note_index=1)
       SET sdonor_note = request->donors[ldonor_index].donor_notes[ldonor_note_index].comment_text
      ELSE
       IF ((request->donors[ldonor_index].donor_notes[ldonor_note_index].comment_append_ind=0))
        SET sdonor_note = concat(request->donors[ldonor_index].donor_notes[ldonor_note_index].
         comment_text,new_line,new_line,sdonor_note)
       ELSE
        SET sdonor_note = concat(sdonor_note,new_line,new_line,request->donors[ldonor_index].
         donor_notes[ldonor_note_index].comment_text)
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    SET ldonor_note_count = size(request->donors[ldonor_index].donor_notes,5)
    FOR (ldonor_note_index = 1 TO ldonor_note_count)
      IF ((request->donors[ldonor_index].donor_notes[ldonor_note_index].comment_append_ind=0))
       SET sdonor_note = concat(request->donors[ldonor_index].donor_notes[ldonor_note_index].
        comment_text,new_line,new_line,sdonor_note)
      ELSE
       SET sdonor_note = concat(sdonor_note,new_line,new_line,request->donors[ldonor_index].
        donor_notes[ldonor_note_index].comment_text)
      ENDIF
    ENDFOR
   ENDIF
   IF (ndonor_note_exist_ind=1)
    SELECT INTO "nl:"
     FROM bbd_donor_note bdn
     WHERE bdn.donor_note_id=ddonor_note_id
     WITH nocounter, forupdate(bdn)
    ;end select
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","BBD_DONOR_NOTE select",concat(
        "Select BBD_DONOR_NOTE table for update failed. Please resolve ","for donor_xref_txt: ",
        request->donors[ldonor_index].donor_xref_txt,"."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_DONOR_NOTE select",serrormsg)
     GO TO exit_script
    ENDIF
    UPDATE  FROM bbd_donor_note bdn
     SET bdn.active_ind = 0, bdn.active_status_cd = reqdata->inactive_status_cd, bdn
      .active_status_dt_tm = cnvtdatetime(request->active_status_dt_tm),
      bdn.active_status_prsnl_id = request->active_status_prsnl_id, bdn.updt_cnt = (bdn.updt_cnt+ 1),
      bdn.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bdn.updt_id = reqinfo->updt_id, bdn.updt_task = reqinfo->updt_task, bdn.updt_applctx = reqinfo
      ->updt_applctx
     WHERE bdn.donor_note_id=ddonor_note_id
     WITH nocounter
    ;end update
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","BBD_DONOR_NOTE update",concat(
        "Update BBD_DONOR_NOTE table for update failed. Please resolve ","for donor_xref_txt: ",
        request->donors[ldonor_index].donor_xref_txt,"."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_DONOR_NOTE update",serrormsg)
     GO TO exit_script
    ENDIF
    CALL update_long_text(dlong_text_id)
   ENDIF
   SET ddonor_note_id = 0.0
   SET dlong_text_id = 0.0
   SET ddonor_note_id = next_pathnet_seq(0)
   SET dlong_text_id = next_longtext_seq(0)
   INSERT  FROM bbd_donor_note bdn
    SET bdn.donor_note_id = ddonor_note_id, bdn.person_id = request->donors[ldonor_index].person_id,
     bdn.long_text_id = dlong_text_id,
     bdn.create_dt_tm = cnvtdatetime(request->active_status_dt_tm), bdn.contributor_system_cd =
     request->contributor_system_cd, bdn.active_ind = 1,
     bdn.active_status_cd = reqdata->active_status_cd, bdn.active_status_dt_tm = cnvtdatetime(request
      ->active_status_dt_tm), bdn.active_status_prsnl_id = request->active_status_prsnl_id,
     bdn.updt_cnt = 0, bdn.updt_dt_tm = cnvtdatetime(curdate,curtime3), bdn.updt_id = reqinfo->
     updt_id,
     bdn.updt_task = reqinfo->updt_task, bdn.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","BBD_DONOR_NOTE insert",concat(
       "Insert into BBD_DONOR_NOTE table failed. Please resolve ","for donor_xref_txt: ",request->
       donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","BBD_DONOR_NOTE insert",serrormsg)
    GO TO exit_script
   ENDIF
   CALL add_long_text(dlong_text_id,sdonor_note,"BBD_DONOR_NOTE",ddonor_note_id)
 END ;Subroutine
 SUBROUTINE add_hist_donor_contact(ldonor_index,lcontact_index)
   DECLARE dcomplete_contact_status_cd = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    cv.code_value, cv.code_set
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=lcontact_status_code_set
      AND cv.cdf_meaning=scontact_complete_cdf_mean
      AND cv.active_ind=1
      AND cv.code_value > 0.0)
    DETAIL
     dcomplete_contact_status_cd = cv.code_value
    WITH nocounter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","CONTACT_STATUS_CD select",concat(
       "Complete contact status cd not found in code_set 14224. Please resolve ",
       "for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","CONTACT_STATUS_CD select",serrormsg)
    GO TO exit_script
   ENDIF
   SET dcontact_id = 0.0
   SET dcontact_id = next_pathnet_seq(0)
   INSERT  FROM bbd_donor_contact bdc
    SET bdc.contact_id = dcontact_id, bdc.person_id = request->donors[ldonor_index].person_id, bdc
     .encntr_id = request->donors[ldonor_index].contacts[lcontact_index].encntr_id,
     bdc.contact_type_cd = request->donors[ldonor_index].contacts[lcontact_index].contact_type_cd,
     bdc.init_contact_prsnl_id = request->donors[ldonor_index].contacts[lcontact_index].
     init_contact_prsnl_id, bdc.contact_outcome_cd = request->donors[ldonor_index].contacts[
     lcontact_index].contact_outcome_cd,
     bdc.contact_dt_tm = cnvtdatetime(request->donors[ldonor_index].contacts[lcontact_index].
      contact_dt_tm), bdc.needed_dt_tm = null, bdc.contact_status_cd = dcomplete_contact_status_cd,
     bdc.owner_area_cd = 0.0, bdc.inventory_area_cd = 0.0, bdc.organization_id = 0.0,
     bdc.contributor_system_cd = request->contributor_system_cd, bdc.active_ind = 1, bdc
     .active_status_cd = reqdata->active_status_cd,
     bdc.active_status_dt_tm = cnvtdatetime(request->active_status_dt_tm), bdc.active_status_prsnl_id
      = request->active_status_prsnl_id, bdc.updt_cnt = 0,
     bdc.updt_dt_tm = cnvtdatetime(curdate,curtime3), bdc.updt_id = reqinfo->updt_id, bdc.updt_task
      = reqinfo->updt_task,
     bdc.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","BBD_DONOR_CONTACT insert",concat(
       "Insert into BBD_DONOR_CONTACT table failed. Please resolve ","for donor_xref_txt: ",request->
       donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","BBD_DONOR_CONTACT insert",serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE add_hist_donor_eligibility(ldonor_index,lcontact_index)
   SET seligibility_type_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[
    lcontact_index].donor_eligibility.eligibility_type_cd,leligibility_type_code_set,
    "ELIGIBILITY_TYPE_CD sel","Donor contacts ELIGIBILITY_TYPE_CD Select")
   SET tempdonoreligdttm->eligible_dt_tm = null
   IF (seligibility_type_mean=stemp_defer_cdf_mean)
    CALL get_longest_eligible_dt_tm(ldonor_index,lcontact_index)
    SET tempdonoreligdttm->eligible_dt_tm = tempeligibledttm->eligible_dt_tm
   ENDIF
   CALL echo(build("eligible_dt_tm :",tempdonoreligdttm->eligible_dt_tm))
   CALL echo(build("sEligibility_Type_Mean :",seligibility_type_mean))
   SET deligibility_id = 0.0
   SET deligibility_id = next_pathnet_seq(0)
   CALL echo(build("dEligibility_Id :",deligibility_id))
   INSERT  FROM bbd_donor_eligibility bde
    SET bde.eligibility_id = deligibility_id, bde.person_id = request->donors[ldonor_index].person_id,
     bde.encntr_id = request->donors[ldonor_index].contacts[lcontact_index].encntr_id,
     bde.contact_id = dcontact_id, bde.eligibility_type_cd = request->donors[ldonor_index].contacts[
     lcontact_index].donor_eligibility.eligibility_type_cd, bde.eligible_dt_tm = cnvtdatetime(
      tempdonoreligdttm->eligible_dt_tm),
     bde.active_ind = 1, bde.active_status_cd = reqdata->active_status_cd, bde.active_status_dt_tm =
     cnvtdatetime(request->active_status_dt_tm),
     bde.active_status_prsnl_id = request->active_status_prsnl_id, bde.updt_cnt = 0, bde.updt_dt_tm
      = cnvtdatetime(curdate,curtime3),
     bde.updt_id = reqinfo->updt_id, bde.updt_task = reqinfo->updt_task, bde.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","BBD_DONOR_ELIGIBILITY ins",concat(
       "Insert into BBD_DONOR_ELIGIBILITY table failed. Please resolve ","for donor_xref_txt: ",
       request->donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","BBD_DONOR_ELIGIBILITY ins",serrormsg)
    GO TO exit_script
   ENDIF
   CALL echo("after bbd_donor_eligibility insert")
 END ;Subroutine
 SUBROUTINE add_hist_deferral_reason(ldonor_index,lcontact_index)
  SET ldefer_reason_count = size(request->donors[ldonor_index].contacts[lcontact_index].
   donor_eligibility.deferral_reasons,5)
  FOR (ldefer_reason_index = 1 TO ldefer_reason_count)
    INSERT  FROM bbd_deferral_reason bdr
     SET bdr.deferral_reason_id = seq(pathnet_seq,nextval), bdr.person_id = request->donors[
      ldonor_index].person_id, bdr.encntr_id = request->donors[ldonor_index].contacts[lcontact_index]
      .encntr_id,
      bdr.contact_id = dcontact_id, bdr.eligibility_id = deligibility_id, bdr.reason_cd = request->
      donors[ldonor_index].contacts[lcontact_index].donor_eligibility.deferral_reasons[
      ldefer_reason_index].reason_cd,
      bdr.eligible_dt_tm = cnvtdatetime(request->donors[ldonor_index].contacts[lcontact_index].
       donor_eligibility.deferral_reasons[ldefer_reason_index].eligible_dt_tm), bdr.occurred_dt_tm =
      null, bdr.calc_elig_dt_tm = null,
      bdr.active_ind = 1, bdr.active_status_cd = reqdata->active_status_cd, bdr.active_status_dt_tm
       = cnvtdatetime(request->active_status_dt_tm),
      bdr.active_status_prsnl_id = request->active_status_prsnl_id, bdr.updt_cnt = 0, bdr.updt_dt_tm
       = cnvtdatetime(curdate,curtime3),
      bdr.updt_id = reqinfo->updt_id, bdr.updt_task = reqinfo->updt_task, bdr.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","BBD_DEFERRAL_REASON ins",concat(
        "Insert into BBD_DEFERRAL_REASON table failed. Please resolve ","for donor_xref_txt: ",
        request->donors[ldonor_index].donor_xref_txt,"."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_DEFERRAL_REASON ins",serrormsg)
     GO TO exit_script
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE add_hist_donation_result(ldonor_index,lcontact_index)
   SET ddonation_result_id = 0.0
   SET ddonation_result_id = next_pathnet_seq(0)
   CALL echo(build("dDonation_Result_Id: ",ddonation_result_id))
   INSERT  FROM bbd_donation_results bdr
    SET bdr.donation_result_id = ddonation_result_id, bdr.person_id = request->donors[ldonor_index].
     person_id, bdr.encntr_id = request->donors[ldonor_index].contacts[lcontact_index].encntr_id,
     bdr.drawn_dt_tm = cnvtdatetime(request->donors[ldonor_index].contacts[lcontact_index].
      drawn_dt_tm), bdr.start_dt_tm = cnvtdatetime(request->donors[ldonor_index].contacts[
      lcontact_index].start_dt_tm), bdr.stop_dt_tm = cnvtdatetime(request->donors[ldonor_index].
      contacts[lcontact_index].stop_dt_tm),
     bdr.procedure_cd = request->donors[ldonor_index].contacts[lcontact_index].procedure_cd, bdr
     .venipuncture_site_cd = request->donors[ldonor_index].contacts[lcontact_index].
     venipuncture_site_cd, bdr.bag_type_cd = request->donors[ldonor_index].contacts[lcontact_index].
     bag_type_cd,
     bdr.phleb_prsnl_id = request->donors[ldonor_index].contacts[lcontact_index].phleb_prsnl_id, bdr
     .outcome_cd = request->donors[ldonor_index].contacts[lcontact_index].outcome_cd, bdr
     .specimen_volume = request->donors[ldonor_index].contacts[lcontact_index].specimen_volume,
     bdr.total_volume = request->donors[ldonor_index].contacts[lcontact_index].total_volume, bdr
     .owner_area_cd = 0.0, bdr.inv_area_cd = 0.0,
     bdr.draw_station_cd = 0.0, bdr.specimen_unit_meas_cd = request->donors[ldonor_index].contacts[
     lcontact_index].specimen_unit_meas_cd, bdr.contact_id = dcontact_id,
     bdr.active_ind = 1, bdr.active_status_cd = reqdata->active_status_cd, bdr.active_status_dt_tm =
     cnvtdatetime(request->active_status_dt_tm),
     bdr.active_status_prsnl_id = request->active_status_prsnl_id, bdr.updt_cnt = 0, bdr.updt_dt_tm
      = cnvtdatetime(curdate,curtime3),
     bdr.updt_id = reqinfo->updt_id, bdr.updt_task = reqinfo->updt_task, bdr.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","BBD_DONATION_RESULTS ins",concat(
       "Insert into BBD_DONATION_RESULTS table failed. Please resolve ","for donor_xref_txt: ",
       request->donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","BBD_DONATION_RESULTS ins",serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE add_hist_contact_note(ldonor_index,lcontact_index)
   DECLARE dcontact_note_id = f8 WITH protect, noconstant(0.0)
   SET dcontact_note_id = next_pathnet_seq(0)
   SET dlong_text_id = 0.0
   SET dlong_text_id = next_longtext_seq(0)
   INSERT  FROM bbd_contact_note bcn
    SET bcn.contact_note_id = dcontact_note_id, bcn.person_id = request->donors[ldonor_index].
     person_id, bcn.encntr_id = request->donors[ldonor_index].contacts[lcontact_index].encntr_id,
     bcn.contact_id = dcontact_id, bcn.contact_type_cd = request->donors[ldonor_index].contacts[
     lcontact_index].contact_type_cd, bcn.long_text_id = dlong_text_id,
     bcn.create_dt_tm = cnvtdatetime(request->donors[ldonor_index].contacts[lcontact_index].
      donation_result.drawn_dt_tm), bcn.active_ind = 1, bcn.active_status_cd = reqdata->
     active_status_cd,
     bcn.active_status_dt_tm = cnvtdatetime(request->active_status_dt_tm), bcn.active_status_prsnl_id
      = request->active_status_prsnl_id, bcn.updt_cnt = 0,
     bcn.updt_dt_tm = cnvtdatetime(curdate,curtime3), bcn.updt_id = reqinfo->updt_id, bcn.updt_task
      = reqinfo->updt_task,
     bcn.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","BBD_CONTACT_NOTE ins",concat(
       "Insert into BBD_CONTACT_NOTE table failed. Please resolve ","for donor_xref_txt: ",request->
       donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","BBD_CONTACT_NOTE ins",serrormsg)
    GO TO exit_script
   ENDIF
   CALL add_long_text(dlong_text_id,request->donors[ldonor_index].contacts[lcontact_index].
    donation_result.donation_comment,"BBD_CONTACT_NOTE",dcontact_note_id)
 END ;Subroutine
 SUBROUTINE add_hist_donation_product_rel(ldonor_index,lcontact_index)
   DECLARE nproduct_rel_exist_ind = i2 WITH protect, noconstant(0)
   SET lproduct_count = size(request->donors[ldonor_index].contacts[lcontact_index].donation_result.
    products,5)
   FOR (lproduct_index = 1 TO lproduct_count)
     SET dproduct_id = 0.0
     SELECT INTO "nl"
      FROM bbhist_product bp
      PLAN (bp
       WHERE (bp.product_nbr=request->donors[ldonor_index].contacts[lcontact_index].donation_result.
       products[lproduct_index].product_nbr)
        AND (bp.cross_reference=request->donors[ldonor_index].contacts[lcontact_index].
       donation_result.products[lproduct_index].cross_reference)
        AND (bp.donor_xref_txt=request->donors[ldonor_index].donor_xref_txt)
        AND bp.active_ind=1)
      DETAIL
       dproduct_id = bp.product_id
      WITH nocounter
     ;end select
     SET nerror_check = error(serrormsg,0)
     IF (nerror_check != 0)
      CALL errorhandler("F","BBHIST_PRODUCT select",serrormsg)
      GO TO exit_script
     ENDIF
     IF (dproduct_id > 0.0)
      SET nproduct_rel_exist_ind = 0
      SELECT INTO "nl:"
       FROM bbd_don_product_r bdpr
       PLAN (bdpr
        WHERE bdpr.product_id=dproduct_id
         AND bdpr.active_ind=1)
       DETAIL
        nproduct_rel_exist_ind = 1
       WITH nocounter
      ;end select
      SET nerror_check = error(serrormsg,0)
      IF (nerror_check != 0)
       CALL errorhandler("F","PRODUCT_ID select",serrormsg)
       GO TO exit_script
      ENDIF
      IF (nproduct_rel_exist_ind=1)
       CALL errorhandler("F","BBD_DON_PRODUCT_R select",concat("Donation result product: ",request->
         donors[ldonor_index].contacts[lcontact_index].donation_result.products[lproduct_index].
         product_nbr," exists in BBD_DON_PRODUCT_R table already.  Please resolve",
         " for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,
         "."))
       GO TO exit_script
      ELSE
       INSERT  FROM bbd_don_product_r bdpr
        SET bdpr.donation_product_id = seq(pathnet_seq,nextval), bdpr.person_id = request->donors[
         ldonor_index].person_id, bdpr.contact_id = dcontact_id,
         bdpr.donation_results_id = ddonation_result_id, bdpr.product_id = dproduct_id, bdpr
         .active_ind = 1,
         bdpr.active_status_cd = reqdata->active_status_cd, bdpr.active_status_dt_tm = cnvtdatetime(
          request->active_status_dt_tm), bdpr.active_status_prsnl_id = request->
         active_status_prsnl_id,
         bdpr.updt_cnt = 0, bdpr.updt_dt_tm = cnvtdatetime(curdate,curtime3), bdpr.updt_id = reqinfo
         ->updt_id,
         bdpr.updt_task = reqinfo->updt_task, bdpr.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       SET nerror_check = error(serrormsg,0)
       IF (nerror_check=0)
        IF (curqual=0)
         CALL errorhandler("F","BBD_DON_PRODUCT_R insert",concat(
           "Insert into BBD_DON_PRODUCT_R table failed. Please resolve ","for donor_xref_txt: ",
           request->donors[ldonor_index].donor_xref_txt,"."))
         GO TO exit_script
        ENDIF
       ELSE
        CALL errorhandler("F","BBD_DON_PRODUCT_R insert",serrormsg)
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE add_hist_other_contact(ldonor_index,lcontact_index)
   INSERT  FROM bbd_other_contact boc
    SET boc.other_contact_id = seq(pathnet_seq,nextval), boc.contact_id = dcontact_id, boc.person_id
      = request->donors[ldonor_index].person_id,
     boc.outcome_cd = request->donors[ldonor_index].contacts[lcontact_index].other_contact.outcome_cd,
     boc.method_cd = request->donors[ldonor_index].contacts[lcontact_index].other_contact.method_cd,
     boc.contact_prsnl_id = request->donors[ldonor_index].contacts[lcontact_index].other_contact.
     contact_prsnl_id,
     boc.follow_up_ind = 0, boc.contact_dt_tm = cnvtdatetime(request->donors[ldonor_index].contacts[
      lcontact_index].contact_dt_tm), boc.active_ind = 1,
     boc.active_status_cd = reqdata->active_status_cd, boc.active_status_dt_tm = cnvtdatetime(request
      ->active_status_dt_tm), boc.active_status_prsnl_id = request->active_status_prsnl_id,
     boc.updt_cnt = 0, boc.updt_dt_tm = cnvtdatetime(curdate,curtime3), boc.updt_id = reqinfo->
     updt_id,
     boc.updt_task = reqinfo->updt_task, boc.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","BBD_OTHER_CONTACT insert",concat(
       "Insert into BBD_OTHER_CONTACT table failed. Please resolve ","for donor_xref_txt: ",request->
       donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","BBD_OTHER_CONTACT insert",serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE add_hist_confidential_note(ldonor_index)
   DECLARE sconfidential_note = vc WITH protect, noconstant("")
   DECLARE dconfidential_id = f8 WITH protect, noconstant(0.0)
   DECLARE nconfidential_note_exist_ind = i2 WITH protect, noconstant(0)
   DECLARE nconfidential_note_count = i2 WITH protect, noconstant(0)
   SET dlong_text_id = 0.0
   SELECT INTO "nl:"
    FROM bbd_confidential_note bcn,
     long_text lt
    PLAN (bcn
     WHERE (bcn.person_id=request->donors[ldonor_index].person_id)
      AND bcn.confidential_id > 0.0
      AND bcn.active_ind=1)
     JOIN (lt
     WHERE lt.long_text_id=bcn.long_text_id
      AND lt.long_text_id > 0.0
      AND lt.active_ind=1)
    DETAIL
     dconfidential_id = bcn.confidential_id, sconfidential_note = lt.long_text, dlong_text_id = lt
     .long_text_id
    WITH nocounter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     SET nconfidential_note_exist_ind = 0
    ELSE
     SET nconfidential_note_exist_ind = 1
    ENDIF
   ELSE
    CALL errorhandler("F","BBD_CONFIDENTIAL_NOTE sel",serrormsg)
    GO TO exit_script
   ENDIF
   IF (nconfidential_note_exist_ind=0)
    SET lsecured_note_count = size(request->donors[ldonor_index].secured_notes,5)
    FOR (lsecured_note_index = 1 TO lsecured_note_count)
      IF (get_cdf_meaning_by_code(request->donors[ldonor_index].secured_notes[lsecured_note_index].
       comment_type_cd,lcomment_type_code_set,"COMMENT_TYPE_CD select","Secured Note Comment_type_cd"
       )=sconfidential_comment_cdf_mean)
       IF (nconfidential_note_count=0)
        SET sconfidential_note = request->donors[ldonor_index].secured_notes[lsecured_note_index].
        comment_text
        SET nconfidential_note_count = (nconfidential_note_count+ 1)
       ELSE
        IF ((request->donors[ldonor_index].secured_notes[lsecured_note_index].comment_append_ind=0))
         SET sconfidential_note = concat(request->donors[ldonor_index].secured_notes[
          lsecured_note_index].comment_text,new_line,new_line,sconfidential_note)
        ELSE
         SET sconfidential_note = concat(sconfidential_note,new_line,new_line,request->donors[
          ldonor_index].secured_notes[lsecured_note_index].comment_text)
        ENDIF
        SET nconfidential_note_count = (nconfidential_note_count+ 1)
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    SET lsecured_note_count = size(request->donors[ldonor_index].secured_notes,5)
    FOR (lsecured_note_index = 1 TO lsecured_note_count)
      IF (get_cdf_meaning_by_code(request->donors[ldonor_index].secured_notes[lsecured_note_index].
       comment_type_cd,lcomment_type_code_set,"COMMENT_TYPE_CD select","Secured Note Comment_type_cd"
       )=sconfidential_comment_cdf_mean)
       IF ((request->donors[ldonor_index].secured_notes[lsecured_note_index].comment_append_ind=0))
        SET sconfidential_note = concat(request->donors[ldonor_index].secured_notes[
         lsecured_note_index].comment_text,new_line,new_line,sconfidential_note)
       ELSE
        SET sconfidential_note = concat(sconfidential_note,new_line,new_line,request->donors[
         ldonor_index].secured_notes[lsecured_note_index].comment_text)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (nconfidential_note_exist_ind=1)
    SELECT INTO "nl:"
     FROM bbd_confidential_note bcn
     WHERE bcn.confidential_id=dconfidential_id
     WITH nocounter, forupdate(bcn)
    ;end select
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","BBD_CONFIDENTIAL_NOTE sel",concat(
        "Select BBD_CONFIDENTIAL_NOTE table for update failed. Please resolve ",
        "for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,"."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_CONFIDENTIAL_NOTE sel",serrormsg)
     GO TO exit_script
    ENDIF
    UPDATE  FROM bbd_confidential_note bcn
     SET bcn.active_ind = 0, bcn.active_status_cd = reqdata->inactive_status_cd, bcn
      .active_status_dt_tm = cnvtdatetime(request->active_status_dt_tm),
      bcn.active_status_prsnl_id = request->active_status_prsnl_id, bcn.updt_cnt = (bcn.updt_cnt+ 1),
      bcn.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bcn.updt_id = reqinfo->updt_id, bcn.updt_task = reqinfo->updt_task, bcn.updt_applctx = reqinfo
      ->updt_applctx
     WHERE bcn.confidential_id=dconfidential_id
     WITH nocounter
    ;end update
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","BBD_CONFIDENTIAL_NOTE upd",concat(
        "Update BBD_CONFIDENTIAL_NOTE table for update failed. Please resolve ",
        "for donor_xref_txt: ",request->donors[ldonor_index].donor_xref_txt,"."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_CONFIDENTIAL_NOTE upd",serrormsg)
     GO TO exit_script
    ENDIF
    CALL update_long_text(dlong_text_id)
   ENDIF
   SET dconfidential_id = 0.0
   SET dlong_text_id = 0.0
   SET dconfidential_id = next_pathnet_seq(0)
   SET dlong_text_id = next_longtext_seq(0)
   INSERT  FROM bbd_confidential_note bcn
    SET bcn.confidential_id = dconfidential_id, bcn.person_id = request->donors[ldonor_index].
     person_id, bcn.long_text_id = dlong_text_id,
     bcn.create_dt_tm = cnvtdatetime(request->active_status_dt_tm), bcn.contact_id = dcontact_id, bcn
     .contributor_system_cd = request->contributor_system_cd,
     bcn.active_ind = 1, bcn.active_status_cd = reqdata->active_status_cd, bcn.active_status_dt_tm =
     cnvtdatetime(request->active_status_dt_tm),
     bcn.active_status_prsnl_id = request->active_status_prsnl_id, bcn.updt_cnt = 0, bcn.updt_dt_tm
      = cnvtdatetime(curdate,curtime3),
     bcn.updt_id = reqinfo->updt_id, bcn.updt_task = reqinfo->updt_task, bcn.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","BBD_CONFIDENTIAL_NOTE ins",concat(
       "Insert into BBD_CONFIDENTIAL_NOTE table failed. Please resolve ","for donor_xref_txt: ",
       request->donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","BBD_CONFIDENTIAL_NOTE ins",serrormsg)
    GO TO exit_script
   ENDIF
   CALL add_long_text(dlong_text_id,sconfidential_note,"BBD_CONFIDENTIAL_NOTE",dconfidential_id)
 END ;Subroutine
 SUBROUTINE add_hist_counseling_note(ldonor_index)
   DECLARE scounseling_note = vc WITH protect, noconstant("")
   DECLARE dcounseling_note_id = f8 WITH protect, noconstant(0.0)
   DECLARE nexisting_counseling_note_ind = i2 WITH protect, noconstant(0)
   DECLARE ncounseling_note_count = i2 WITH protect, noconstant(0)
   SET dlong_text_id = 0.0
   SELECT INTO "nl:"
    FROM bbd_counseling_note bcn,
     long_text lt
    PLAN (bcn
     WHERE (bcn.person_id=request->donors[ldonor_index].person_id)
      AND bcn.counseling_note_id > 0.0
      AND bcn.active_ind=1)
     JOIN (lt
     WHERE lt.long_text_id=bcn.long_text_id
      AND lt.long_text_id > 0.0
      AND lt.active_ind=1)
    DETAIL
     dcounseling_note_id = bcn.counseling_note_id, scounseling_note = lt.long_text, dlong_text_id =
     lt.long_text_id
    WITH nocounter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     SET nexisting_counseling_note_ind = 0
    ELSE
     SET nexisting_counseling_note_ind = 1
    ENDIF
   ELSE
    CALL errorhandler("F","BBD_COUNSELING_NOTE sel",serrormsg)
    GO TO exit_script
   ENDIF
   IF (nexisting_counseling_note_ind=0)
    SET lsecured_note_count = size(request->donors[ldonor_index].secured_notes,5)
    FOR (lsecured_note_index = 1 TO lsecured_note_count)
      IF (get_cdf_meaning_by_code(request->donors[ldonor_index].secured_notes[lsecured_note_index].
       comment_type_cd,lcomment_type_code_set,"COMMENT_TYPE_CD select","Secured Note Comment_type_cd"
       )=scounsel_comment_cdf_mean)
       IF (ncounseling_note_count=0)
        SET scounseling_note = request->donors[ldonor_index].secured_notes[lsecured_note_index].
        comment_text
        SET ncounseling_note_count = (ncounseling_note_count+ 1)
       ELSE
        IF ((request->donors[ldonor_index].secured_notes[lsecured_note_index].comment_append_ind=0))
         SET scounseling_note = concat(request->donors[ldonor_index].secured_notes[
          lsecured_note_index].comment_text,new_line,new_line,scounseling_note)
        ELSE
         SET scounseling_note = concat(scounseling_note,new_line,new_line,request->donors[
          ldonor_index].secured_notes[lsecured_note_index].comment_text)
        ENDIF
        SET ncounseling_note_count = (ncounseling_note_count+ 1)
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    SET lsecured_note_count = size(request->donors[ldonor_index].secured_notes,5)
    FOR (lsecured_note_index = 1 TO lsecured_note_count)
      IF (get_cdf_meaning_by_code(request->donors[ldonor_index].secured_notes[lsecured_note_index].
       comment_type_cd,lcomment_type_code_set,"COMMENT_TYPE_CD select","Secured Note Comment_type_cd"
       )=scounsel_comment_cdf_mean)
       IF ((request->donors[ldonor_index].secured_notes[lsecured_note_index].comment_append_ind=0))
        SET scounseling_note = concat(request->donors[ldonor_index].secured_notes[lsecured_note_index
         ].comment_text,new_line,new_line,scounseling_note)
       ELSE
        SET scounseling_note = concat(scounseling_note,new_line,new_line,request->donors[ldonor_index
         ].secured_notes[lsecured_note_index].comment_text)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (nexisting_counseling_note_ind=1)
    SELECT INTO "nl:"
     FROM bbd_counseling_note bcn
     WHERE bcn.counseling_note_id=dcounseling_note_id
     WITH nocounter, forupdate(bcn)
    ;end select
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","BBD_COUNSELING_NOTE sel",concat(
        "Select BBD_COUNSELING_NOTE table for update failed. Please resolve ","for donor_xref_txt: ",
        request->donors[ldonor_index].donor_xref_txt,"."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_COUNSELING_NOTE sel",serrormsg)
     GO TO exit_script
    ENDIF
    UPDATE  FROM bbd_counseling_note bcn
     SET bcn.active_ind = 0, bcn.active_status_cd = reqdata->inactive_status_cd, bcn
      .active_status_dt_tm = cnvtdatetime(request->active_status_dt_tm),
      bcn.active_status_prsnl_id = request->active_status_prsnl_id, bcn.updt_cnt = (bcn.updt_cnt+ 1),
      bcn.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bcn.updt_id = reqinfo->updt_id, bcn.updt_task = reqinfo->updt_task, bcn.updt_applctx = reqinfo
      ->updt_applctx
     WHERE bcn.counseling_note_id=dcounseling_note_id
     WITH nocounter
    ;end update
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","BBD_COUNSELING_NOTE upd",concat(
        "Update BBD_COUNSELING_NOTE table for update failed. Please resolve ","for donor_xref_txt: ",
        request->donors[ldonor_index].donor_xref_txt,"."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_COUNSELING_NOTE upd",serrormsg)
     GO TO exit_script
    ENDIF
    CALL update_long_text(dlong_text_id)
   ENDIF
   SET dcounseling_note_id = 0.0
   SET dlong_text_id = 0.0
   SET dcounseling_note_id = next_pathnet_seq(0)
   SET dlong_text_id = next_longtext_seq(0)
   INSERT  FROM bbd_counseling_note bcn
    SET bcn.counseling_note_id = dcounseling_note_id, bcn.person_id = request->donors[ldonor_index].
     person_id, bcn.long_text_id = dlong_text_id,
     bcn.create_dt_tm = cnvtdatetime(request->active_status_dt_tm), bcn.contact_id = dcontact_id, bcn
     .contributor_system_cd = request->contributor_system_cd,
     bcn.active_ind = 1, bcn.active_status_cd = reqdata->active_status_cd, bcn.active_status_dt_tm =
     cnvtdatetime(request->active_status_dt_tm),
     bcn.active_status_prsnl_id = request->active_status_prsnl_id, bcn.updt_cnt = 0, bcn.updt_dt_tm
      = cnvtdatetime(curdate,curtime3),
     bcn.updt_id = reqinfo->updt_id, bcn.updt_task = reqinfo->updt_task, bcn.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","BBD_COUNSELING_NOTE ins",concat(
       "Insert into BBD_COUNSELING_NOTE table failed. Please resolve ","for donor_xref_txt: ",request
       ->donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","BBD_COUNSELING_NOTE ins",serrormsg)
    GO TO exit_script
   ENDIF
   CALL add_long_text(dlong_text_id,scounseling_note,"BBD_COUNSELING_NOTE",dcounseling_note_id)
 END ;Subroutine
 SUBROUTINE update_long_text(dlong_text_id)
   SELECT INTO "nl:"
    FROM long_text lt
    WHERE lt.long_text_id=dlong_text_id
    WITH nocounter, forupdate(lt)
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","LONG_TEXT select",concat(
       "Select LONG_TEXT table for update failed. Please resolve ","for donor_xref_txt: ",request->
       donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","LONG_TEXT select",serrormsg)
    GO TO exit_script
   ENDIF
   UPDATE  FROM long_text lt
    SET lt.active_ind = 0, lt.active_status_cd = reqdata->inactive_status_cd, lt.active_status_dt_tm
      = cnvtdatetime(request->active_status_dt_tm),
     lt.active_status_prsnl_id = request->active_status_prsnl_id, lt.updt_cnt = (lt.updt_cnt+ 1), lt
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
     updt_applctx
    WHERE lt.long_text_id=dlong_text_id
    WITH nocounter
   ;end update
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","LONG_TEXT update",concat(
       "Update LONG_TEXT table for update failed. Please resolve ","for donor_xref_txt: ",request->
       donors[ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","LONG_TEXT update",serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE add_long_text(dlong_text_id,slong_text,sparent_entity_name,dparent_entity_id)
   INSERT  FROM long_text lt
    SET lt.long_text_id = dlong_text_id, lt.active_ind = 1, lt.long_text = slong_text,
     lt.parent_entity_name = sparent_entity_name, lt.parent_entity_id = dparent_entity_id, lt
     .active_ind = 1,
     lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm = cnvtdatetime(request->
      active_status_dt_tm), lt.active_status_prsnl_id = request->active_status_prsnl_id,
     lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","LONG_TEXT insert",concat(
       "Insert into LONG_TEXT table failed. Please resolve ","for donor_xref_txt: ",request->donors[
       ldonor_index].donor_xref_txt,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","LONG_TEXT insert",serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE get_longest_eligible_dt_tm(ldonor_index,lcontact_index)
   SET tempeligibledttm->eligible_dt_tm = null
   SET seligibility_type_mean = get_cdf_meaning_by_code(request->donors[ldonor_index].contacts[
    lcontact_index].donor_eligibility.eligibility_type_cd,leligibility_type_code_set,
    "ELIGIBILITY_TYPE_CD sel","Donor contacts ELIGIBILITY_TYPE_CD select")
   IF (seligibility_type_mean=stemp_defer_cdf_mean)
    SET tempeligibledttm->eligible_dt_tm = null
    SET ldefer_reason_count = size(request->donors[ldonor_index].contacts[lcontact_index].
     donor_eligibility.deferral_reasons,5)
    FOR (ldefer_reason_index = 1 TO ldefer_reason_count)
      IF ((request->donors[ldonor_index].contacts[lcontact_index].donor_eligibility.deferral_reasons[
      ldefer_reason_index].eligible_dt_tm > tempeligibledttm->eligible_dt_tm))
       SET tempeligibledttm->eligible_dt_tm = request->donors[ldonor_index].contacts[lcontact_index].
       donor_eligibility.deferral_reasons[ldefer_reason_index].eligible_dt_tm
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE next_pathnet_seq(no_param)
   DECLARE dnew_pathnet_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    snbr = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     dnew_pathnet_id = snbr
    WITH format, counter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","Get unique pathnet seq","Unable to retrieve unique pathnet seq.")
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","Get unique pathnet seq",serrormsg)
    GO TO long_text_id
   ENDIF
   RETURN(dnew_pathnet_id)
 END ;Subroutine
 SUBROUTINE next_longtext_seq(no_param)
   DECLARE dnew_long_text_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    snbr = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     dnew_long_text_id = snbr
    WITH format, counter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","Get unique long_text_id","Unable to retrieve unique long_text_id.")
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","Get unique long_text_id",serrormsg)
    GO TO long_text_id
   ENDIF
   RETURN(dnew_long_text_id)
 END ;Subroutine
 SUBROUTINE errorhandler(operationstatus,targetobjectname,targetobjectvalue)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = sscript_name
   SET reply->status_data.subeventstatus[1].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ENDIF
 IF ((request->debug_ind=1))
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
 FREE RECORD tempeligibledttm
 FREE RECORD tempdonoreligdttm
 FREE RECORD existpersondonor
END GO
