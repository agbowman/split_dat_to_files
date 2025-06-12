CREATE PROGRAM cps_rpt_visit:dba
 CALL echo("***")
 CALL echo("***   Init/Declare Block")
 CALL echo("***")
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DECLARE bpersonorgsecurityon = i2 WITH public, noconstant(false)
 DECLARE dminfo_ok = i2 WITH private, noconstant(false)
 DECLARE eidx = i4 WITH public, noconstant(0)
 DECLARE fidx = i4 WITH public, noconstant(0)
 DECLARE algy_bit_pos = i2 WITH public, noconstant(0)
 DECLARE diag_bit_pos = i2 WITH public, noconstant(0)
 DECLARE prob_bit_pos = i2 WITH public, noconstant(0)
 DECLARE proc_bit_pos = i2 WITH public, noconstant(0)
 DECLARE meds_bit_pos = i2 WITH public, noconstant(0)
 DECLARE algy_access_priv = f8 WITH public, noconstant(0.0)
 DECLARE diag_access_priv = f8 WITH public, noconstant(0.0)
 DECLARE prob_access_priv = f8 WITH public, noconstant(0.0)
 DECLARE proc_access_priv = f8 WITH public, noconstant(0.0)
 DECLARE meds_access_priv = f8 WITH public, noconstant(0.0)
 DECLARE access_granted = i2 WITH public, noconstant(false)
 DECLARE dvar = i2 WITH public, noconstant(0)
 DECLARE visit_date = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE report_title = c13 WITH public, constant("Visit Summary")
 DECLARE blank = c1 WITH public, constant(" ")
 DECLARE bar_line = vc WITH public, constant(fillstring(88,"_"))
 DECLARE rfv_banner_line = vc WITH public, constant(concat("Reason For Visit:",substring(1,(88 -
    textlen("Reason For Visit:")),bar_line)))
 DECLARE rfv_banner_cont = vc WITH public, constant(concat("Reason For Visist Continued:",substring(1,
    (88 - textlen("Reason For Visist Continued:")),bar_line)))
 DECLARE doc_banner_line = vc WITH public, constant(concat("Clinicians Seen:",substring(1,(88 -
    textlen("Clinicians Seen:")),bar_line)))
 DECLARE doc_banner_cont = vc WITH public, constant(concat("Clinicians Seen Continued:",substring(1,(
    88 - textlen("Clinicians Seen Continued:")),bar_line)))
 DECLARE vital_banner_line = vc WITH public, constant(concat("Vital Signs:",substring(1,(88 - textlen
    ("Vital Signs:")),bar_line)))
 DECLARE vital_banner_cont = vc WITH public, constant(concat("Vital Signs Continued:",substring(1,(88
     - textlen("Vital Signs Continued:")),bar_line)))
 DECLARE diag_banner_line = vc WITH public, constant(concat("Visit Diagnosis:",substring(1,(88 -
    textlen("Visit Diagnosis:")),bar_line)))
 DECLARE diag_banner_cont = vc WITH public, constant(concat("Visit Diagnosis Continued:",substring(1,
    (88 - textlen("Visit Diagnosis Continued:")),bar_line)))
 DECLARE meds_banner_line = vc WITH public, constant(concat("Medications:",substring(1,(88 - textlen(
     "Medications:")),bar_line)))
 DECLARE meds_banner_cont = vc WITH public, constant(concat("Medications Continued:",substring(1,(88
     - textlen("Medications Continued:")),bar_line)))
 DECLARE srv_banner_line = vc WITH public, constant(concat("Services Rendered:",substring(1,(88 -
    textlen("Services Rendered:")),bar_line)))
 DECLARE srv_banner_cont = vc WITH public, constant(concat("Services Rendered Continued:",substring(1,
    (88 - textlen("Services Rendered Continued:")),bar_line)))
 DECLARE alg_banner_line = vc WITH public, constant(concat("Allergy Summary:",substring(1,(88 -
    textlen("Allergy Summary:")),bar_line)))
 DECLARE alg_banner_cont = vc WITH public, constant(concat("Allergy Summary Continued:",substring(1,(
    88 - textlen("Allergy Summary Continued:")),bar_line)))
 DECLARE pat_name = vc WITH public, noconstant(fillstring(100," "))
 DECLARE dob = c10 WITH public, noconstant(fillstring(10," "))
 DECLARE age = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE sex = c8 WITH public, noconstant(fillstring(8," "))
 DECLARE pat_street_addr1 = vc WITH public, noconstant(fillstring(100," "))
 DECLARE pat_street_addr2 = vc WITH public, noconstant(fillstring(100," "))
 DECLARE pat_street_addr3 = vc WITH public, noconstant(fillstring(100," "))
 DECLARE pat_street_addr4 = vc WITH public, noconstant(fillstring(100," "))
 DECLARE pat_city = vc WITH public, noconstant(fillstring(100," "))
 DECLARE pat_state = vc WITH public, noconstant(fillstring(40," "))
 DECLARE pat_zipcode = vc WITH public, noconstant(fillstring(25," "))
 DECLARE pat_work_nbr = vc WITH public, noconstant(fillstring(100," "))
 DECLARE pat_home_nbr = vc WITH public, noconstant(fillstring(100," "))
 DECLARE pins_name = vc WITH public, noconstant(fillstring(100," "))
 DECLARE pins_policy = vc WITH public, noconstant(fillstring(100," "))
 DECLARE pins_group = vc WITH public, noconstant(fillstring(100," "))
 DECLARE sins_name = vc WITH public, noconstant(fillstring(100," "))
 DECLARE sins_policy = vc WITH public, noconstant(fillstring(100," "))
 DECLARE sins_group = vc WITH public, noconstant(fillstring(100," "))
 DECLARE reason_for_visit = vc WITH public, noconstant(fillstring(255," "))
 DECLARE print_by = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE rpt_street_addr1 = vc WITH public, noconstant(fillstring(100," "))
 DECLARE rpt_street_addr2 = vc WITH public, noconstant(fillstring(100," "))
 DECLARE rpt_street_addr3 = vc WITH public, noconstant(fillstring(100," "))
 DECLARE rpt_street_addr4 = vc WITH public, noconstant(fillstring(100," "))
 DECLARE rpt_city = vc WITH public, noconstant(fillstring(100," "))
 DECLARE rpt_state = vc WITH public, noconstant(fillstring(40," "))
 DECLARE rpt_zipcode = vc WITH public, noconstant(fillstring(25," "))
 DECLARE rpt_phone_nbr = vc WITH public, noconstant(fillstring(100," "))
 DECLARE rpt_fax_nbr = vc WITH public, noconstant(fillstring(100," "))
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE code_value = f8 WITH public, noconstant(0.0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE bus_addr_cd = f8 WITH public, noconstant(0.0)
 DECLARE bus_phone_cd = f8 WITH public, noconstant(0.0)
 DECLARE bus_fax_cd = f8 WITH public, noconstant(0.0)
 DECLARE home_addr_cd = f8 WITH public, noconstant(0.0)
 DECLARE home_phone_cd = f8 WITH public, noconstant(0.0)
 DECLARE pcp_cd = f8 WITH public, noconstant(0.0)
 DECLARE ordered_cd = f8 WITH public, noconstant(0.0)
 DECLARE incomplete_cd = f8 WITH public, noconstant(0.0)
 DECLARE inprocess_cd = f8 WITH public, noconstant(0.0)
 DECLARE can_react_cd = f8 WITH public, noconstant(0.0)
 DECLARE user_first_page = i2 WITH public, noconstant(false)
 DECLARE cur_row = i2 WITH public, noconstant(1)
 DECLARE new_page = i2 WITH public, noconstant(false)
 DECLARE cur_page = i2 WITH public, noconstant(1)
 DECLARE tot_page = i2 WITH public, noconstant(1)
 DECLARE max_rows = i2 WITH public, noconstant(62)
 SET app_time = datetimezone(datetimezone(cnvtdatetime(sysdate),curtimezonesys,2),curtimezoneapp)
 SET print_dt_tm = concat(format(app_time,"mm/dd/yyyy hh:mm;;d")," ",datetimezonebyindex(
   curtimezoneapp))
 FREE SET app_time
 FREE RECORD visit_req
 RECORD visit_req(
   1 person_id = f8
   1 prsnl_id = f8
   1 encntr_id = f8
   1 report_title = vc
 )
 CALL echo("***")
 CALL echo("***   Validate Request")
 CALL echo("***")
 IF ((((request->person_cnt > 0)) OR (size(request->person,5) > 0)) )
  SET visit_req->person_id = request->person[1].person_id
 ELSEIF ((((request->visit_cnt > 0)) OR (size(request->visit,5) > 0)) )
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM encounter e
   PLAN (e
    WHERE (e.encntr_id=request->visit[1].encntr_id))
   DETAIL
    visit_req->person_id = e.person_id
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "ENCNTR"
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->text = "Invalid person list in request"
  SET failed = input_error
  SET table_name = "REQUEST"
  SET serrmsg = "Invalid person list in request"
  GO TO exit_script
 ENDIF
 IF ((request->prsnl_cnt > 0))
  SET visit_req->prsnl_id = request->prsnl[1].prsnl_id
 ELSE
  SET visit_req->prsnl_id = reqinfo->updt_id
 ENDIF
 IF ((request->visit_cnt > 0))
  SET visit_req->encntr_id = request->visit[1].encntr_id
 ELSE
  SET reply->text = "Invalid visit list in request"
  SET failed = input_error
  SET table_name = "REQUEST"
  SET serrmsg = "Invalid visit list in request"
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Code Values")
 CALL echo("***")
 SET code_set = 212
 SET code_value = 0.0
 SET cdf_meaning = "BUSINESS"
 EXECUTE cpm_get_cd_for_cdf
 SET bus_addr_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding the code_value for cdf_meaning ",trim(cdf_meaning),
   " on code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 212
 SET code_value = 0.0
 SET cdf_meaning = "HOME"
 EXECUTE cpm_get_cd_for_cdf
 SET home_addr_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding the code_value for cdf_meaning ",trim(cdf_meaning),
   " on code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 43
 SET code_value = 0.0
 SET cdf_meaning = "BUSINESS"
 EXECUTE cpm_get_cd_for_cdf
 SET bus_phone_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding the code_value for cdf_meaning ",trim(cdf_meaning),
   " on code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 43
 SET code_value = 0.0
 SET cdf_meaning = "HOME"
 EXECUTE cpm_get_cd_for_cdf
 SET home_phone_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding the code_value for cdf_meaning ",trim(cdf_meaning),
   " on code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 43
 SET code_value = 0.0
 SET cdf_meaning = "FAX BUS"
 EXECUTE cpm_get_cd_for_cdf
 SET bus_fax_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding the code_value for cdf_meaning ",trim(cdf_meaning),
   " on code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 331
 SET code_value = 0.0
 SET cdf_meaning = "PCP"
 EXECUTE cpm_get_cd_for_cdf
 SET pcp_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding the code_value for cdf_meaning ",trim(cdf_meaning),
   " on code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 6000
 SET code_value = 0.0
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET pharm_type_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET code_set = 6004
 SET code_value = 0.0
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding the code_value for cdf_meaning ",trim(cdf_meaning),
   " on code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 6004
 SET code_value = 0.0
 SET cdf_meaning = "INCOMPLETE"
 EXECUTE cpm_get_cd_for_cdf
 SET incomplete_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding the code_value for cdf_meaning ",trim(cdf_meaning),
   " on code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 6004
 SET code_value = 0.0
 SET cdf_meaning = "INPROCESS"
 EXECUTE cpm_get_cd_for_cdf
 SET inprocess_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding the code_value for cdf_meaning ",trim(cdf_meaning),
   " on code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 12025
 SET code_value = 0.0
 SET cdf_meaning = "CANCELED"
 EXECUTE cpm_get_cd_for_cdf
 SET can_react_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding the code_value for cdf_meaning ",trim(cdf_meaning),
   " on code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Determine Person Org Security Status")
 CALL echo("***")
 SET dminfo_ok = validate(ccldminfo->mode,0)
 IF (dminfo_ok=1)
  IF ((ccldminfo->sec_org_reltn=1)
   AND (ccldminfo->person_org_sec=1))
   SET bpersonorgsecurityon = true
  ENDIF
 ELSE
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="SECURITY"
     AND di.info_name IN ("SEC_ORG_RELTN", "PERSON_ORG_SEC")
     AND di.info_number=1)
   HEAD REPORT
    encntr_org_sec_on = 0, person_org_sec_on = 0
   DETAIL
    IF (di.info_name="SEC_ORG_RELTN"
     AND di.info_number=1)
     encntr_org_sec_on = 1
    ELSEIF (di.info_name="PERSON_ORG_SEC")
     person_org_sec_on = 1
    ENDIF
   FOOT REPORT
    IF (person_org_sec_on=1
     AND encntr_org_sec_on=1)
     bpersonorgsecurityon = true
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "DM_INFO"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (bpersonorgsecurityon=true)
  SELECT INTO "nl:"
   FROM person_prsnl_reltn ppr,
    code_value_extension cve
   PLAN (ppr
    WHERE (ppr.prsnl_person_id=reqinfo->updt_id)
     AND ppr.active_ind=1
     AND ((ppr.person_id+ 0)=visit_req->person_id)
     AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (cve
    WHERE cve.code_value=ppr.person_prsnl_r_cd
     AND cve.code_set=331
     AND ((cve.field_value="1") OR (cve.field_value="2"))
     AND cve.field_name="Override")
   HEAD REPORT
    bpersonorgsecurityon = false
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "PRSNL_OVERRIDE"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (bpersonorgsecurityon=true)
  SET algy_access_priv = uar_get_code_by("DISPLAYKEY",413574,"ALLERGIES")
  IF (algy_access_priv < 1)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = "Failed to find Code Value for Display Key ALLERGIES in Code Set 413574"
   GO TO exit_script
  ENDIF
  SET meds_access_priv = uar_get_code_by("DISPLAYKEY",413574,"MEDICATIONORDERS")
  IF (meds_access_priv < 1)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = "Failed to find Code Value for Display Key MEDICATIONORDERS in Code Set 413574"
   GO TO exit_script
  ENDIF
  SET diag_access_priv = uar_get_code_by("DISPLAYKEY",413574,"DIAGNOSIS")
  IF (diag_access_priv < 1)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = "Failed to find Code Value for Display Key DIAGNOSIS in Code Set 413574"
   GO TO exit_script
  ENDIF
  SET prob_access_priv = uar_get_code_by("DISPLAYKEY",413574,"PROBLEMS")
  IF (prob_access_priv < 1)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = "Failed to find Code Value for Display Key PROBLEMS in Code Set 413574"
   GO TO exit_script
  ENDIF
  SET proc_access_priv = uar_get_code_by("DISPLAYKEY",413574,"PROCEDURES")
  IF (proc_access_priv < 1)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = "Failed to find Code Value for Display Key PROCEDURES in Code Set 413574"
   GO TO exit_script
  ENDIF
  SET algy_bit_pos = uar_get_collation_seq(algy_access_priv)
  IF (algy_bit_pos < 0)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = "Failed to find Collation Sequence for ALLERGIES in Code Set 413574"
   GO TO exit_script
  ENDIF
  SET meds_bit_pos = uar_get_collation_seq(meds_access_priv)
  IF (meds_bit_pos < 0)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = "Failed to find Collation Sequence for MEDICATIONORDERS in Code Set 413574"
   GO TO exit_script
  ENDIF
  SET diag_bit_pos = uar_get_collation_seq(diag_access_priv)
  IF (diag_bit_pos < 0)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = "Failed to find Collation Sequence for DIAGNOSIS in Code Set 413574"
   GO TO exit_script
  ENDIF
  SET prob_bit_pos = uar_get_collation_seq(prob_access_priv)
  IF (prob_bit_pos < 0)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = "Failed to find Collation Sequence for PROBLEMS in Code Set 413574"
   GO TO exit_script
  ENDIF
  SET proc_bit_pos = uar_get_collation_seq(proc_access_priv)
  IF (proc_bit_pos < 0)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = "Failed to find Collation Sequence for PROCEDURES in Code Set 413574"
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo("***")
 CALL echo(build("****   bPersonOrgSecurityOn :",bpersonorgsecurityon))
 CALL echo("***")
 IF (bpersonorgsecurityon=true)
  CALL echo("***")
  CALL echo("***   Load Prsnl Orgs")
  CALL echo("***")
  DECLARE network_var = f8 WITH constant(uar_get_code_by("MEANING",28881,"NETWORK")), protect
  FREE RECORD prsnl_orgs
  RECORD prsnl_orgs(
    1 org_knt = i4
    1 org[*]
      2 organization_id = f8
    1 org_set_knt = i4
    1 org_set[*]
      2 org_set_id = f8
      2 access_privs = i4
      2 org_list_knt = i4
      2 org_list[*]
        3 organization_id = f8
  )
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  IF (validate(_sacrtl_org_inc_,99999)=99999)
   DECLARE _sacrtl_org_inc_ = i2 WITH constant(1)
   RECORD sac_org(
     1 organizations[*]
       2 organization_id = f8
       2 confid_cd = f8
       2 confid_level = i4
   )
   EXECUTE secrtl
   EXECUTE sacrtl
   DECLARE orgcnt = i4 WITH protected, noconstant(0)
   DECLARE secstat = i2
   DECLARE logontype = i4 WITH protect, noconstant(- (1))
   DECLARE dynamic_org_ind = i4 WITH protect, noconstant(- (1))
   DECLARE dcur_trustid = f8 WITH protect, noconstant(0.0)
   DECLARE dynorg_enabled = i4 WITH constant(1)
   DECLARE dynorg_disabled = i4 WITH constant(0)
   DECLARE logontype_nhs = i4 WITH constant(1)
   DECLARE logontype_legacy = i4 WITH constant(0)
   DECLARE confid_cnt = i4 WITH protected, noconstant(0)
   RECORD confid_codes(
     1 list[*]
       2 code_value = f8
       2 coll_seq = f8
   )
   CALL uar_secgetclientlogontype(logontype)
   CALL echo(build("logontype:",logontype))
   IF (logontype != logontype_nhs)
    SET dynamic_org_ind = dynorg_disabled
   ENDIF
   IF (logontype=logontype_nhs)
    SUBROUTINE (getdynamicorgpref(dtrustid=f8) =i4)
      DECLARE scur_trust = vc
      DECLARE pref_val = vc
      DECLARE is_enabled = i4 WITH constant(1)
      DECLARE is_disabled = i4 WITH constant(0)
      SET scur_trust = cnvtstring(dtrustid)
      SET scur_trust = concat(scur_trust,".00")
      IF ( NOT (validate(pref_req,0)))
       RECORD pref_req(
         1 write_ind = i2
         1 delete_ind = i2
         1 pref[*]
           2 contexts[*]
             3 context = vc
             3 context_id = vc
           2 section = vc
           2 section_id = vc
           2 subgroup = vc
           2 entries[*]
             3 entry = vc
             3 values[*]
               4 value = vc
       )
      ENDIF
      IF ( NOT (validate(pref_rep,0)))
       RECORD pref_rep(
         1 pref[*]
           2 section = vc
           2 section_id = vc
           2 subgroup = vc
           2 entries[*]
             3 pref_exists_ind = i2
             3 entry = vc
             3 values[*]
               4 value = vc
         1 status_data
           2 status = c1
           2 subeventstatus[1]
             3 operationname = c25
             3 operationstatus = c1
             3 targetobjectname = c25
             3 targetobjectvalue = vc
       )
      ENDIF
      SET stat = alterlist(pref_req->pref,1)
      SET stat = alterlist(pref_req->pref[1].contexts,2)
      SET stat = alterlist(pref_req->pref[1].entries,1)
      SET pref_req->pref[1].contexts[1].context = "organization"
      SET pref_req->pref[1].contexts[1].context_id = scur_trust
      SET pref_req->pref[1].contexts[2].context = "default"
      SET pref_req->pref[1].contexts[2].context_id = "system"
      SET pref_req->pref[1].section = "workflow"
      SET pref_req->pref[1].section_id = "UK Trust Security"
      SET pref_req->pref[1].entries[1].entry = "dynamic organizations"
      EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
      IF (cnvtupper(pref_rep->pref[1].entries[1].values[1].value)="ENABLED")
       RETURN(is_enabled)
      ELSE
       RETURN(is_disabled)
      ENDIF
    END ;Subroutine
    DECLARE hprop = i4 WITH protect, noconstant(0)
    DECLARE tmpstat = i2
    DECLARE spropname = vc
    DECLARE sroleprofile = vc
    SET hprop = uar_srvcreateproperty()
    SET tmpstat = uar_secgetclientattributesext(5,hprop)
    SET spropname = uar_srvfirstproperty(hprop)
    SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
    SELECT INTO "nl:"
     FROM prsnl_org_reltn_type prt,
      prsnl_org_reltn por
     PLAN (prt
      WHERE prt.role_profile=sroleprofile
       AND prt.active_ind=1
       AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND prt.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (por
      WHERE (por.organization_id= Outerjoin(prt.organization_id))
       AND (por.person_id= Outerjoin(prt.prsnl_id))
       AND (por.active_ind= Outerjoin(1))
       AND (por.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
       AND (por.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
     ORDER BY por.prsnl_org_reltn_id
     DETAIL
      orgcnt = 1, secstat = alterlist(sac_org->organizations,1), user_person_id = prt.prsnl_id,
      sac_org->organizations[1].organization_id = prt.organization_id, sac_org->organizations[1].
      confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
      sac_org->organizations[1].confid_level =
      IF (confid_cd > 0) confid_cd
      ELSE 0
      ENDIF
     WITH maxrec = 1
    ;end select
    SET dcur_trustid = sac_org->organizations[1].organization_id
    SET dynamic_org_ind = getdynamicorgpref(dcur_trustid)
    CALL uar_srvdestroyhandle(hprop)
   ENDIF
   IF (dynamic_org_ind=dynorg_disabled)
    SET confid_cnt = 0
    SELECT INTO "NL:"
     c.code_value, c.collation_seq
     FROM code_value c
     WHERE c.code_set=87
     DETAIL
      confid_cnt += 1
      IF (mod(confid_cnt,10)=1)
       secstat = alterlist(confid_codes->list,(confid_cnt+ 9))
      ENDIF
      confid_codes->list[confid_cnt].code_value = c.code_value, confid_codes->list[confid_cnt].
      coll_seq = c.collation_seq
     WITH nocounter
    ;end select
    SET secstat = alterlist(confid_codes->list,confid_cnt)
    SELECT DISTINCT INTO "nl:"
     FROM prsnl_org_reltn por
     WHERE (por.person_id=reqinfo->updt_id)
      AND por.active_ind=1
      AND por.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND por.end_effective_dt_tm >= cnvtdatetime(sysdate)
     HEAD REPORT
      IF (orgcnt > 0)
       secstat = alterlist(sac_org->organizations,100)
      ENDIF
     DETAIL
      orgcnt += 1
      IF (mod(orgcnt,100)=1)
       secstat = alterlist(sac_org->organizations,(orgcnt+ 99))
      ENDIF
      sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
      orgcnt].confid_cd = por.confid_level_cd
     FOOT REPORT
      secstat = alterlist(sac_org->organizations,orgcnt)
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM (dummyt d1  WITH seq = value(orgcnt)),
      (dummyt d2  WITH seq = value(confid_cnt))
     PLAN (d1)
      JOIN (d2
      WHERE (sac_org->organizations[d1.seq].confid_cd=confid_codes->list[d2.seq].code_value))
     DETAIL
      sac_org->organizations[d1.seq].confid_level = confid_codes->list[d2.seq].coll_seq
     WITH nocounter
    ;end select
   ELSEIF (dynamic_org_ind=dynorg_enabled)
    DECLARE nhstrustchild_org_org_reltn_cd = f8
    SET nhstrustchild_org_org_reltn_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
    SELECT INTO "nl:"
     FROM org_org_reltn oor
     PLAN (oor
      WHERE oor.organization_id=dcur_trustid
       AND oor.active_ind=1
       AND oor.beg_effective_dt_tm < cnvtdatetime(sysdate)
       AND oor.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND oor.org_org_reltn_cd=nhstrustchild_org_org_reltn_cd)
     HEAD REPORT
      IF (orgcnt > 0)
       secstat = alterlist(sac_org->organizations,10)
      ENDIF
     DETAIL
      IF (oor.related_org_id > 0)
       orgcnt += 1
       IF (mod(orgcnt,10)=1)
        secstat = alterlist(sac_org->organizations,(orgcnt+ 9))
       ENDIF
       sac_org->organizations[orgcnt].organization_id = oor.related_org_id
      ENDIF
     FOOT REPORT
      secstat = alterlist(sac_org->organizations,orgcnt)
     WITH nocounter
    ;end select
   ELSE
    CALL echo(build("Unexpected login type: ",dynamimc_org_ind))
   ENDIF
  ENDIF
  SET prsnl_orgs->org_knt = size(sac_org->organizations,5)
  SET stat = alterlist(prsnl_orgs->org,prsnl_orgs->org_knt)
  FOR (i = 1 TO prsnl_orgs->org_knt)
    SET prsnl_orgs->org[i].organization_id = sac_org->organizations[i].organization_id
  ENDFOR
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "PRSNL_ORG_RELTN"
   GO TO exit_script
  ENDIF
  IF (network_var < 1)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = "Failed to find Code Value for CDF_MEANING NETWORK from Code Set 28881"
   GO TO exit_script
  ENDIF
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM org_set_prsnl_r ospr,
    org_set_type_r ostr,
    org_set_org_r osor,
    org_set os
   PLAN (ospr
    WHERE (ospr.prsnl_id=visit_req->prsnl_id)
     AND ospr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ospr.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND ospr.active_ind=true)
    JOIN (ostr
    WHERE ostr.org_set_id=ospr.org_set_id
     AND ostr.org_set_type_cd=network_var
     AND ostr.active_ind=1
     AND ostr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ostr.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (os
    WHERE os.org_set_id=ospr.org_set_id)
    JOIN (osor
    WHERE osor.org_set_id=os.org_set_id
     AND osor.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND osor.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND osor.active_ind=true)
   HEAD REPORT
    knt = 0, stat = alterlist(prsnl_orgs->org_set,10)
   HEAD ospr.org_set_id
    knt += 1
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(prsnl_orgs->org_set,(knt+ 9))
    ENDIF
    prsnl_orgs->org_set[knt].org_set_id = ospr.org_set_id, prsnl_orgs->org_set[knt].access_privs = os
    .org_set_attr_bit, oknt = 0,
    stat = alterlist(prsnl_orgs->org_set[knt].org_list,10)
   DETAIL
    oknt += 1
    IF (mod(oknt,10)=1
     AND oknt != 1)
     stat = alterlist(prsnl_orgs->org_set[knt].org_list,(oknt+ 9))
    ENDIF
    prsnl_orgs->org_set[knt].org_list[oknt].organization_id = osor.organization_id
   FOOT  ospr.org_set_id
    prsnl_orgs->org_set[knt].org_list_knt = oknt, stat = alterlist(prsnl_orgs->org_set[knt].org_list,
     oknt)
   FOOT REPORT
    prsnl_orgs->org_set_knt = knt, stat = alterlist(prsnl_orgs->org_set,knt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "PRSNL_ORG_RELTN"
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Printer Info")
 CALL echo("***")
 SET ierrcode = 0
 SELECT INTO "nl:"
  p.person_id, a.address_type_seq, a.beg_effective_dt_tm
  FROM prsnl p,
   address a
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
   JOIN (a
   WHERE (a.parent_entity_id= Outerjoin(p.person_id))
    AND (a.parent_entity_name= Outerjoin("PERSON"))
    AND (a.address_type_cd= Outerjoin(bus_addr_cd))
    AND (a.active_ind= Outerjoin(1))
    AND (a.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (a.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY p.person_id, a.address_type_seq, a.beg_effective_dt_tm DESC
  HEAD p.person_id
   print_by = substring(1,12,p.username), found = false
  HEAD a.address_type_seq
   IF (a.address_id > 0.0
    AND found=false)
    rpt_street_addr1 = a.street_addr, rpt_street_addr2 = a.street_addr2, rpt_street_addr3 = a
    .street_addr3,
    rpt_street_addr4 = a.street_addr4, rpt_city = a.city, rpt_zipcode = a.zipcode
    IF (a.state_cd > 0)
     rpt_state = uar_get_code_display(a.state_cd)
    ELSE
     rpt_state = a.state
    ENDIF
    found = true
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PRSNL"
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 SELECT INTO "nl:"
  p.parent_entity_id, p.phone_type_cd, p.phone_type_seq,
  p.beg_effective_dt_tm, phone_nbr = cnvtphone(cnvtalphanum(p.phone_num),p.phone_format_cd)
  FROM phone p
  PLAN (p
   WHERE (p.parent_entity_id=reqinfo->updt_id)
    AND p.parent_entity_name="PERSON"
    AND p.phone_type_cd IN (bus_phone_cd, bus_fax_cd)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY p.parent_entity_id, p.phone_type_cd, p.phone_type_seq,
   p.beg_effective_dt_tm DESC
  HEAD p.parent_entity_id
   found_ph = false, found_fx = false
  HEAD p.phone_type_cd
   IF (found_ph=false
    AND p.phone_type_cd=bus_phone_cd)
    rpt_phone_nbr = phone_nbr, found_ph = true
   ELSEIF (found_fx=false
    AND p.phone_type_cd=bus_fax_cd)
    rpt_fax_nbr = phone_nbr, found_fx = true
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PHONE"
  GO TO exit_script
 ENDIF
 SET city_line = concat(trim(rpt_city),", ",trim(rpt_state)," ",trim(rpt_zipcode))
 SET phone_line = concat("Phone: ",trim(rpt_phone_nbr),"    Fax: ",trim(rpt_fax_nbr))
 CALL echo("***")
 CALL echo("***   Get Person Demo Info")
 CALL echo("***")
 SET ierrcode = 0
 SELECT INTO "nl:"
  p.person_id, a.address_type_seq, a.beg_effective_dt_tm
  FROM person p,
   (dummyt d  WITH seq = 1),
   address a
  PLAN (p
   WHERE (p.person_id=visit_req->person_id))
   JOIN (d)
   JOIN (a
   WHERE a.parent_entity_id=p.person_id
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=home_addr_cd
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND a.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY p.person_id, a.address_type_seq, a.beg_effective_dt_tm DESC
  HEAD p.person_id
   pat_name = p.name_full_formatted, dob = datebirthformat(p.birth_dt_tm,p.birth_tz,p.birth_prec_flag,
    "mm/dd/yyyy;;d",1), age = cnvtage(p.birth_dt_tm),
   sex = substring(1,8,uar_get_code_display(p.sex_cd)), found = false
  HEAD a.address_type_cd
   IF (found=false)
    pat_street_addr1 = a.street_addr, pat_street_addr2 = a.street_addr2, pat_street_addr3 = a
    .street_addr3,
    pat_street_addr4 = a.street_addr4, pat_city = a.city, pat_zipcode = a.zipcode
    IF (a.state_cd > 0)
     pat_state = uar_get_code_display(a.state_cd)
    ELSE
     pat_state = a.state
    ENDIF
    found = true
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PERSON"
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 SELECT INTO "nl:"
  p.parent_entity_id, p.phone_type_cd, p.phone_type_seq,
  p.beg_effective_dt_tm, phone_nbr = cnvtphone(cnvtalphanum(p.phone_num),p.phone_format_cd)
  FROM phone p
  PLAN (p
   WHERE (p.parent_entity_id=visit_req->person_id)
    AND p.parent_entity_name="PERSON"
    AND p.phone_type_cd IN (bus_phone_cd, home_phone_cd)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY p.parent_entity_id, p.phone_type_cd, p.phone_type_seq,
   p.beg_effective_dt_tm DESC
  HEAD p.parent_entity_id
   found_wk = false, found_hm = false
  HEAD p.phone_type_cd
   IF (found_wk=false
    AND p.phone_type_cd=bus_phone_cd)
    pat_work_nbr = phone_nbr, found_wk = true
   ELSEIF (found_hm=false
    AND p.phone_type_cd=home_phone_cd)
    pat_home_nbr = phone_nbr, found_hm = true
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PHONE"
  GO TO exit_script
 ENDIF
 FREE RECORD pat_info
 RECORD pat_info(
   1 qual_knt = i4
   1 qual[*]
     2 info = c88
 )
 SET pat_info->qual_knt = 1
 SET stat = alterlist(pat_info->qual,pat_info->qual_knt)
 IF (pat_street_addr1 > " ")
  SET csz_stamp = false
  SET pat_info->qual[1].info = concat("Patient Address:     ",substring(1,24,trim(pat_street_addr1)),
   "    Home Phone:    ",substring(1,25,trim(pat_home_nbr)))
  SET pat_info->qual_knt = 2
  SET stat = alterlist(pat_info->qual,pat_info->qual_knt)
  IF (pat_street_addr2 > " ")
   SET pat_info->qual[2].info = concat(substring(1,21," "),substring(1,24,trim(pat_street_addr2)),
    "    Work Phone:    ",substring(1,25,trim(pat_work_nbr)))
  ELSEIF (((pat_city > " ") OR (((pat_state > " ") OR (pat_zipcode > " ")) )) )
   SET csz_stamp = true
   SET pat_info->qual[2].info = concat(substring(1,21," "),substring(1,24,concat(trim(substring(1,14,
        pat_city)),", ",trim(substring(1,2,pat_state))," ",trim(substring(1,5,pat_zipcode)))),
    "    Work Phone:    ",substring(1,25,trim(pat_work_nbr)))
  ELSE
   SET pat_info->qual[2].info = concat(substring(1,41," "),"    Work Phone:    ")
  ENDIF
  IF (pat_street_addr3 > " ")
   SET pat_info->qual_knt = 3
   SET stat = alterlist(pat_info->qual,pat_info->qual_knt)
   SET pat_info->qual[3].info = concat(substring(1,21," "),substring(1,24,trim(pat_street_addr3)))
  ELSEIF (((pat_city > " ") OR (((pat_state > " ") OR (pat_zipcode > " ")) ))
   AND csz_stamp=false)
   SET csz_stamp = true
   SET pat_info->qual_knt = 3
   SET stat = alterlist(pat_info->qual,pat_info->qual_knt)
   SET pat_info->qual[3].info = concat(substring(1,21," "),trim(substring(1,14,pat_city)),", ",trim(
     substring(1,2,pat_state))," ",
    trim(substring(1,5,pat_zipcode)))
  ENDIF
  IF (pat_street_addr4 > " ")
   SET pat_info->qual_knt = 4
   SET stat = alterlist(pat_info->qual,pat_info->qual_knt)
   SET pat_info->qual[4].info = concat(substring(1,21," "),substring(1,24,trim(pat_street_addr3)))
  ELSEIF (((pat_city > " ") OR (((pat_state > " ") OR (pat_zipcode > " ")) ))
   AND csz_stamp=false)
   SET csz_stamp = true
   SET pat_info->qual_knt = 4
   SET stat = alterlist(pat_info->qual,pat_info->qual_knt)
   SET pat_info->qual[4].info = concat(substring(1,21," "),trim(substring(1,14,pat_city)),", ",trim(
     substring(1,2,pat_state))," ",
    trim(substring(1,5,pat_zipcode)))
  ENDIF
  IF (((pat_city > " ") OR (((pat_state > " ") OR (pat_zipcode > " ")) ))
   AND csz_stamp=false)
   SET csz_stamp = true
   SET pat_info->qual_knt = 5
   SET stat = alterlist(pat_info->qual,pat_info->qual_knt)
   SET pat_info->qual[5].info = concat(substring(1,21," "),trim(substring(1,14,pat_city)),", ",trim(
     substring(1,2,pat_state))," ",
    trim(substring(1,5,pat_zipcode)))
  ENDIF
 ELSE
  SET pat_info->qual[1].info = concat("Patient Address:     ",substring(1,20,"Unknown"),
   "    Home Phone:    ",substring(1,25,trim(pat_home_nbr)))
  SET pat_info->qual_knt = 2
  SET stat = alterlist(pat_info->qual,pat_info->qual_knt)
  SET pat_info->qual[2].info = concat(substring(1,41," "),"    Work Phone:    ",substring(1,25,trim(
     pat_work_nbr)))
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Insurance Info")
 CALL echo("***")
 SET encntr_plan_found = false
 SET ierrcode = 0
 SELECT INTO "nl:"
  epr.priority_seq
  FROM encounter e,
   (dummyt d  WITH seq = 1),
   encntr_plan_reltn epr,
   health_plan hp
  PLAN (e
   WHERE (e.encntr_id=visit_req->encntr_id)
    AND e.encntr_id > 0)
   JOIN (d)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id)
  ORDER BY epr.priority_seq
  HEAD REPORT
   ins_cnt = 0
  DETAIL
   reason_for_visit = e.reason_for_visit
   IF (e.reg_dt_tm != null)
    visit_date = format(cnvtdatetime(e.reg_dt_tm),"dd-mmm-yyyy;;d")
   ELSEIF (e.pre_reg_dt_tm != null)
    visit_date = format(cnvtdatetime(e.pre_reg_dt_tm),"dd-mmm-yyyy;;d")
   ELSE
    visit_date = format(cnvtdatetime(sysdate),"dd-mmm-yyyy;;d")
   ENDIF
   IF (epr.encntr_id > 0)
    encntr_plan_found = true
   ENDIF
   ins_cnt += 1
   IF (ins_cnt=1)
    pins_name = hp.plan_name, pins_group = hp.group_nbr, pins_policy = hp.policy_nbr
   ELSEIF (ins_cnt=2)
    sins_name = hp.plan_name, sins_group = hp.group_nbr, sins_policy = hp.policy_nbr
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ENCOUNTER"
  GO TO exit_script
 ENDIF
 IF (encntr_plan_found=false)
  SET ierrcode = 0
  SELECT INTO "nl:"
   epr.priority_seq
   FROM person_plan_reltn epr,
    health_plan hp
   PLAN (epr
    WHERE (epr.person_id=visit_req->person_id)
     AND epr.active_ind=1
     AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (hp
    WHERE hp.health_plan_id=epr.health_plan_id)
   ORDER BY epr.priority_seq
   HEAD REPORT
    ins_cnt = 0
   DETAIL
    ins_cnt += 1
    IF (ins_cnt=1)
     pins_name = hp.plan_name, pins_group = hp.group_nbr, pins_policy = hp.policy_nbr
    ELSEIF (ins_cnt=2)
     sins_name = hp.plan_name, sins_group = hp.group_nbr, sins_policy = hp.policy_nbr
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "HEALTH_PLAN"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (((pins_name > " ") OR (((pins_policy > " ") OR (pins_group > " ")) )) )
  SET pat_info->qual_knt += 1
  SET stat = alterlist(pat_info->qual,pat_info->qual_knt)
  SET pat_info->qual[pat_info->qual_knt].info = concat("Primary Insurance:   ",substring(1,24,trim(
     pins_name)),"   Policy/Group #: ",substring(1,10,trim(pins_policy)),"/",
   substring(1,10,trim(pins_group)))
  IF (((sins_name > " ") OR (((sins_policy > " ") OR (sins_group > " ")) )) )
   SET pat_info->qual_knt += 1
   SET stat = alterlist(pat_info->qual,pat_info->qual_knt)
   SET pat_info->qual[pat_info->qual_knt].info = concat("Secondary Insurance: ",substring(1,24,trim(
      sins_name)),"   Policy/Group #: ",substring(1,10,trim(sins_policy)),"/",
    substring(1,10,trim(sins_group)))
  ENDIF
 ENDIF
 CALL echo("***")
 CALL echo("***    Handle Reason For Visit")
 CALL echo("***")
 FREE RECORD rfv
 RECORD rfv(
   1 qual_knt = i4
   1 qual[*]
     2 info = c80
 )
 IF (reason_for_visit > " ")
  IF (textlen(trim(reason_for_visit)) <= 80)
   SET rfv->qual_knt = 1
   SET stat = alterlist(rfv->qual,rfv->qual_knt)
   SET rfv->qual[1].info = trim(reason_for_visit)
  ELSE
   SET continue = true
   SET cur_start = 1
   SET cur_pos = 81
   SET line_length = textlen(trim(reason_for_visit))
   SET loop_knt = 10
   WHILE (continue=true)
     SET loop_knt -= 1
     IF (substring(cur_start,cur_pos,reason_for_visit)=blank)
      SET rfv->qual_knt += 1
      SET stat = alterlist(rfv->qual,rfv->qual_knt)
      SET rfv->qual[rfv->qual_knt].info = substring(cur_start,(cur_pos - 1),reason_for_visit)
      SET reason_for_visit = substring((cur_pos+ 1),(line_length - cur_pos),reason_for_visit)
      SET line_length = textlen(trim(reason_for_visit))
      IF (line_length <= 80)
       SET continue = false
       SET rfv->qual_knt += 1
       SET stat = alterlist(rfv->qual,rfv->qual_knt)
       SET rfv->qual[rfv->qual_knt].info = substring(cur_start,line_length,reason_for_visit)
       SET loop_knt = 10
      ELSE
       SET cur_pos = 82
       SET loop_knt = 10
      ENDIF
     ENDIF
     IF (loop_knt=0)
      SET rfv->qual_knt += 1
      SET stat = alterlist(rfv->qual,rfv->qual_knt)
      SET rfv->qual[rfv->qual_knt].info = concat(substring(cur_start,(cur_pos+ 5),reason_for_visit),
       "...")
      SET reason_for_visit = substring((cur_pos+ 6),((line_length - cur_pos)+ 5),reason_for_visit)
      SET line_length = textlen(trim(reason_for_visit))
      IF (line_length <= 80)
       SET continue = false
       SET rfv->qual_knt += 1
       SET stat = alterlist(rfv->qual,rfv->qual_knt)
       SET rfv->qual[rfv->qual_knt].info = substring(cur_start,line_length,reason_for_visit)
      ELSE
       SET cur_pos = 82
       SET loop_knt = 10
      ENDIF
     ENDIF
     SET cur_pos -= 1
   ENDWHILE
  ENDIF
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Docs")
 CALL echo("***")
 FREE RECORD doc
 RECORD doc(
   1 qual_knt = i4
   1 qual[*]
     2 info = c80
 )
 SET ierrcode = 0
 SELECT INTO "nl:"
  ppr.beg_effective_dt_tm
  FROM person_prsnl_reltn ppr,
   prsnl p
  PLAN (ppr
   WHERE (ppr.person_id=visit_req->person_id)
    AND ppr.person_prsnl_r_cd=pcp_cd
    AND ppr.active_ind=1
    AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id)
  ORDER BY ppr.beg_effective_dt_tm DESC
  HEAD REPORT
   IF (p.person_id > 0)
    knt = 1, doc->qual_knt = knt, stat = alterlist(doc->qual,knt),
    doc->qual[knt].info = concat(substring(1,35,p.name_full_formatted),"     ",substring(1,35,
      uar_get_code_display(pcp_cd)))
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PERSON_PRSNL_RELTN"
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 SELECT INTO "nl:"
  ppr.encntr_prsnl_r_cd, ppr.beg_effective_dt_tm
  FROM encntr_prsnl_reltn ppr,
   prsnl p
  PLAN (ppr
   WHERE (ppr.encntr_id=visit_req->encntr_id)
    AND ppr.prsnl_person_id > 0
    AND ppr.encntr_prsnl_r_cd > 0
    AND ppr.active_ind=1
    AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id)
  ORDER BY ppr.encntr_prsnl_r_cd, ppr.beg_effective_dt_tm DESC
  HEAD REPORT
   knt = doc->qual_knt, cur_reltn_cd = 0.0
  HEAD ppr.encntr_prsnl_r_cd
   IF (cur_reltn_cd != ppr.encntr_prsnl_r_cd)
    cur_reltn_cd = ppr.encntr_prsnl_r_cd, knt += 1, stat = alterlist(doc->qual,knt),
    doc->qual[knt].info = concat(substring(1,35,p.name_full_formatted),"     ",substring(1,35,
      uar_get_code_display(ppr.encntr_prsnl_r_cd)))
   ENDIF
  FOOT REPORT
   doc->qual_knt = knt
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ENCNTR_PRSNL_RELTN"
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Vital Signs")
 CALL echo("***")
 FREE RECORD vital
 RECORD vital(
   1 qual_knt = i4
   1 qual[*]
     2 info = c80
 )
 FREE RECORD event
 RECORD event(
   1 qual_knt = i4
   1 qual[*]
     2 event_cd = f8
     2 event_name = vc
     2 event_disp = c40
     2 result_val = vc
     2 result_unit_disp = c40
 )
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM v500_event_set_code ec,
   v500_event_set_explode ex
  PLAN (ec
   WHERE ec.event_set_name_key IN ("BP", "HEIGHT", "PERIPHERALPULSES", "RESPIRATORYRATE",
   "TEMPERATURE",
   "WEIGHT", "DIASTOLICBLOODPRESSURE", "SYSTOLICBLOODPRESSURE"))
   JOIN (ex
   WHERE ex.event_set_cd=ec.event_set_cd)
  HEAD REPORT
   knt = 0, stat = alterlist(event->qual,10)
  DETAIL
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(event->qual,(knt+ 9))
   ENDIF
   event->qual[knt].event_cd = ex.event_cd, event->qual[knt].event_name = ec.event_set_name_key,
   event->qual[knt].event_disp = uar_get_code_display(ex.event_cd)
  FOOT REPORT
   event->qual_knt = knt, stat = alterlist(event->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "EVENT_CODES"
  GO TO exit_script
 ENDIF
 SET pat_temp = fillstring(50," ")
 SET pat_bp = fillstring(50," ")
 SET pat_sbp = fillstring(50," ")
 SET pat_dbp = fillstring(50," ")
 SET pat_ht = fillstring(50," ")
 SET pat_wt = fillstring(50," ")
 SET pat_pulse = fillstring(50," ")
 SET pat_resp = fillstring(50," ")
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq, event_cd = event->qual[d.seq].event_cd, ce.updt_dt_tm
  FROM (dummyt d  WITH seq = value(event->qual_knt)),
   clinical_event ce
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ce
   WHERE (ce.person_id=visit_req->person_id)
    AND (ce.encntr_id=visit_req->encntr_id)
    AND (ce.event_cd=event->qual[d.seq].event_cd))
  ORDER BY d.seq, event_cd, ce.updt_dt_tm DESC
  HEAD REPORT
   cur_event_cd = 0, found_it = false
  HEAD d.seq
   IF (cur_event_cd != ce.event_cd)
    cur_event_cd = ce.event_cd, event->qual[d.seq].result_val = ce.result_val, event->qual[d.seq].
    result_unit_disp = uar_get_code_display(ce.result_units_cd)
    IF ((event->qual[d.seq].event_name="BP"))
     found_it = true, pat_bp = concat(trim(substring(1,10,ce.result_val)))
    ELSEIF ((event->qual[d.seq].event_name="DIASTOLICBLOODPRESSURE"))
     found_it = true, pat_dbp = concat(trim(substring(1,10,ce.result_val)))
    ELSEIF ((event->qual[d.seq].event_name="SYSTOLICBLOODPRESSURE"))
     found_it = true, pat_sbp = concat(trim(substring(1,10,ce.result_val)))
    ELSEIF ((event->qual[d.seq].event_name="PERIPHERALPULSES"))
     found_it = true, pat_pulse = concat(trim(substring(1,10,ce.result_val))," ",trim(
       uar_get_code_display(ce.result_units_cd)))
    ELSEIF ((event->qual[d.seq].event_name="RESPIRATORYRATE"))
     found_it = true, pat_resp = concat(trim(substring(1,10,ce.result_val))," ",trim(
       uar_get_code_display(ce.result_units_cd)))
    ELSEIF ((event->qual[d.seq].event_name="TEMPERATURE"))
     found_it = true, pat_temp = concat(trim(substring(1,10,ce.result_val))," ",trim(
       uar_get_code_display(ce.result_units_cd)))
    ELSEIF ((event->qual[d.seq].event_name="HEIGHT"))
     found_it = true, pat_ht = concat(trim(substring(1,10,ce.result_val))," ",trim(
       uar_get_code_display(ce.result_units_cd)))
    ELSEIF ((event->qual[d.seq].event_name="WEIGHT"))
     found_it = true, pat_wt = concat(trim(substring(1,10,ce.result_val))," ",trim(
       uar_get_code_display(ce.result_units_cd)))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "CLINICAL_EVENT"
  GO TO exit_script
 ENDIF
 IF (((pat_bp > " ") OR (((pat_sbp > " ") OR (pat_dbp > " ")) )) )
  IF (((pat_sbp > " ") OR (pat_dbp > " ")) )
   IF ( NOT (pat_sbp > " "))
    SET pat_sbp = "-"
   ENDIF
   IF ( NOT (pat_dbp > " "))
    SET pat_dbp = "-"
   ENDIF
   SET pat_bp = concat(trim(pat_sbp),"/",trim(pat_dbp))
  ELSE
   SET pat_bp = trim(pat_bp)
  ENDIF
 ENDIF
 IF (pat_bp > " ")
  SET vital->qual_knt += 1
  SET stat = alterlist(vital->qual,vital->qual_knt)
  SET vital->qual[vital->qual_knt].info = concat(substring(1,22,"Blood Pressure: "),trim(pat_bp))
 ENDIF
 IF (pat_pulse > " ")
  SET vital->qual_knt += 1
  SET stat = alterlist(vital->qual,vital->qual_knt)
  SET vital->qual[vital->qual_knt].info = concat(substring(1,22,"Pulse Rate: "),trim(pat_pulse))
 ENDIF
 IF (pat_resp > " ")
  SET vital->qual_knt += 1
  SET stat = alterlist(vital->qual,vital->qual_knt)
  SET vital->qual[vital->qual_knt].info = concat(substring(1,22,"Respiratory Rate: "),trim(pat_resp))
 ENDIF
 IF (pat_temp > " ")
  SET vital->qual[vital->qual_knt].info = concat(substring(1,22,"Temperature: "),trim(pat_temp))
 ENDIF
 IF (pat_ht > " ")
  SET vital->qual_knt += 1
  SET stat = alterlist(vital->qual,vital->qual_knt)
  SET vital->qual[vital->qual_knt].info = concat(substring(1,22,"Height: "),trim(pat_ht))
 ENDIF
 IF (pat_wt > " ")
  SET vital->qual_knt += 1
  SET stat = alterlist(vital->qual,vital->qual_knt)
  SET vital->qual[vital->qual_knt].info = concat(substring(1,22,"Weight: "),trim(pat_wt))
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Diagonses")
 CALL echo("***")
 FREE RECORD diag
 RECORD diag(
   1 qual_knt = i4
   1 qual[*]
     2 info = c80
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.diag_priority
  FROM diagnosis d,
   nomenclature n
  PLAN (d
   WHERE (d.person_id=visit_req->person_id)
    AND (d.encntr_id=visit_req->encntr_id)
    AND d.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id)
  ORDER BY d.diag_priority
  HEAD REPORT
   knt = 0, stat = alterlist(diag->qual,10)
  DETAIL
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(diag->qual,(knt+ 9))
   ENDIF
   IF (n.nomenclature_id > 0)
    diag->qual[knt].info = concat(substring(1,60,n.source_string),"   ",substring(1,15,
      uar_get_code_display(d.diag_type_cd)))
   ELSE
    diag->qual[knt].info = concat(substring(1,60,d.diag_ftdesc),"   ",substring(1,15,
      uar_get_code_display(d.diag_type_cd)))
   ENDIF
  FOOT REPORT
   diag->qual_knt = knt, stat = alterlist(diag->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "DIAGNOSIS"
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Valid Encounters")
 CALL echo("***")
 FREE RECORD valid_req
 RECORD valid_req(
   1 prsnl_id = f8
   1 person_id = f8
 )
 SET valid_req->prsnl_id = visit_req->prsnl_id
 SET valid_req->person_id = visit_req->person_id
 FREE RECORD valid_encntr
 RECORD valid_encntr(
   1 restrict_ind = i2
   1 encntrs
     2 data_cnt = i2
     2 data[1]
       3 encntr_id = f8
   1 lookup_status = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 EXECUTE pts_get_valid_encntrs  WITH replace(request,valid_req), replace(reply,valid_encntr)
 CALL echo("***")
 CALL echo(build("***    STATUS :",valid_encntr->status_data.status))
 CALL echo("***")
 IF ((valid_encntr->status_data.status="F"))
  SET failed = select_error
  SET table_name = "SECURITY"
  SET serrmsg = trim(substring(1,132,valid_encntr->status_data.subeventstatus[1].targetobjectvalue))
  GO TO exit_script
 ENDIF
 SET valid_encntr->encntrs.data_cnt = size(valid_encntr->encntrs.data,5)
 CALL echo("***")
 CALL echo("***   Get Meds")
 CALL echo("***")
 FREE RECORD treply
 RECORD treply(
   1 ord_qual_knt = i4
   1 ord_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 organization_id = f8
     2 viewable_ind = i2
     2 synonym_mnemonic = vc
     2 order_status_cd = f8
     2 det_qual_knt = i4
     2 det_qual[*]
       3 oe_field_value_display = vc
       3 oe_field_dt_tm_value = dq8
       3 oe_field_tz = i4
       3 oe_field_meaning_id = f8
       3 oe_field_meaning = c25
       3 oe_field_id = f8
     2 adr_knt = i4
     2 adr[*]
       3 reltn_entity_name = vc
       3 reltn_entity_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  o.order_id
  FROM orders o,
   encounter e,
   order_detail od
  PLAN (o
   WHERE (o.person_id=visit_req->person_id)
    AND o.catalog_type_cd=pharm_type_cd
    AND o.ordered_as_mnemonic > " "
    AND ((o.template_order_flag+ 0) IN (0, 1, 5))
    AND o.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (od
   WHERE od.order_id=o.order_id)
  ORDER BY o.order_id, od.oe_field_id, od.action_sequence DESC
  HEAD REPORT
   knt = 0, stat = alterlist(treply->ord_qual,10)
  HEAD o.order_id
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(treply->ord_qual,(knt+ 9))
   ENDIF
   treply->ord_qual[knt].order_id = o.order_id, treply->ord_qual[knt].encntr_id = o.encntr_id, treply
   ->ord_qual[knt].organization_id = e.organization_id
   IF (e.organization_id=0.0)
    treply->ord_qual[knt].viewable_ind = 1
   ENDIF
   treply->ord_qual[knt].synonym_mnemonic = o.ordered_as_mnemonic, treply->ord_qual[knt].
   order_status_cd = o.order_status_cd, dknt = 0,
   stat = alterlist(treply->ord_qual[knt].det_qual,10), cur_field_id = 0.0, cur_action_seq = 0
  DETAIL
   IF (cur_field_id != od.oe_field_id)
    cur_field_id = od.oe_field_id, cur_action_seq = od.action_sequence, dknt += 1
    IF (mod(dknt,10)=1
     AND dknt != 1)
     stat = alterlist(treply->ord_qual[knt].det_qual,(dknt+ 9))
    ENDIF
    treply->ord_qual[knt].det_qual[dknt].oe_field_value_display = od.oe_field_display_value, treply->
    ord_qual[knt].det_qual[dknt].oe_field_dt_tm_value = od.oe_field_dt_tm_value, treply->ord_qual[knt
    ].det_qual[dknt].oe_field_id = od.oe_field_id,
    treply->ord_qual[knt].det_qual[dknt].oe_field_meaning = od.oe_field_meaning, treply->ord_qual[knt
    ].det_qual[dknt].oe_field_meaning_id = od.oe_field_meaning_id, treply->ord_qual[knt].det_qual[
    dknt].oe_field_tz = validate(od.oe_field_tz,0)
   ENDIF
  FOOT  o.order_id
   treply->ord_qual[knt].det_qual_knt = dknt, stat = alterlist(treply->ord_qual[knt].det_qual,dknt)
  FOOT REPORT
   treply->ord_qual_knt = knt, stat = alterlist(treply->ord_qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ORDERS"
  GO TO exit_script
 ENDIF
 IF ((treply->ord_qual_knt > 0))
  IF (bpersonorgsecurityon=true)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM activity_data_reltn adr
    PLAN (adr
     WHERE expand(eidx,1,treply->ord_qual_knt,adr.activity_entity_id,treply->ord_qual[eidx].order_id)
      AND adr.activity_entity_name="ORDERS")
    HEAD adr.activity_entity_id
     fidx = 0, fidx = locateval(fidx,1,treply->ord_qual_knt,adr.activity_entity_id,treply->ord_qual[
      fidx].order_id)
     IF (fidx > 0)
      stat = alterlist(treply->ord_qual[fidx].adr,10)
     ENDIF
     knt = 0
    DETAIL
     IF (fidx > 0)
      knt += 1
      IF (mod(knt,10)=1
       AND knt != 1)
       stat = alterlist(treply->ord_qual[fidx].adr,(knt+ 9))
      ENDIF
      treply->ord_qual[fidx].adr[knt].reltn_entity_name = adr.reltn_entity_name, treply->ord_qual[
      fidx].adr[knt].reltn_entity_id = adr.reltn_entity_id
     ENDIF
    FOOT  adr.activity_entity_id
     treply->ord_qual[fidx].adr_knt = knt, stat = alterlist(treply->ord_qual[fidx].adr,knt)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "ADR-MED-ORDERS"
    GO TO exit_script
   ENDIF
   FOR (vidx = 1 TO treply->ord_qual_knt)
     SET continue = true
     SET oknt = 1
     WHILE (continue=true
      AND (oknt <= prsnl_orgs->org_knt)
      AND (treply->ord_qual[vidx].viewable_ind < 1))
      IF ((treply->ord_qual[vidx].organization_id=prsnl_orgs->org[oknt].organization_id))
       SET treply->ord_qual[vidx].viewable_ind = 1
       SET continue = false
      ENDIF
      SET oknt += 1
     ENDWHILE
     IF ((treply->ord_qual[vidx].viewable_ind < 1))
      SET osknt = 1
      SET continue = true
      WHILE (continue=true
       AND (osknt <= prsnl_orgs->org_set_knt))
        SET oknt = 1
        SET access_granted = false
        SET access_granted = btest(prsnl_orgs->org_set[osknt].access_privs,meds_bit_pos)
        WHILE (continue=true
         AND (oknt <= prsnl_orgs->org_set[osknt].org_list_knt)
         AND access_granted=true)
         IF ((treply->ord_qual[vidx].organization_id=prsnl_orgs->org_set[osknt].org_list[oknt].
         organization_id))
          SET treply->ord_qual[vidx].viewable_ind = 1
          SET continue = false
         ENDIF
         SET oknt += 1
        ENDWHILE
        SET osknt += 1
      ENDWHILE
     ENDIF
     IF ((treply->ord_qual[vidx].adr_knt > 0)
      AND (treply->ord_qual[vidx].viewable_ind < 1))
      FOR (ridx = 1 TO reply->ord_qual[vidx].adr_knt)
        SET continue = true
        SET oknt = 1
        WHILE (continue=true
         AND (oknt <= prsnl_orgs->org_knt)
         AND (treply->ord_qual[vidx].viewable_ind < 1))
         IF ((treply->ord_qual[vidx].adr[ridx].reltn_entity_name="ORGANIZATION")
          AND (treply->ord_qual[vidx].adr[ridx].reltn_entity_id=prsnl_orgs->org[oknt].organization_id
         ))
          SET treply->ord_qual[vidx].viewable_ind = 2
          SET continue = false
         ENDIF
         SET oknt += 1
        ENDWHILE
        IF ((treply->ord_qual[vidx].viewable_ind < 1))
         SET osknt = 1
         SET continue = true
         WHILE (continue=true
          AND (osknt <= prsnl_orgs->org_set_knt))
           SET oknt = 1
           SET access_granted = false
           SET access_granted = btest(prsnl_orgs->org_set[osknt].access_privs,meds_bit_pos)
           WHILE (continue=true
            AND (oknt <= prsnl_orgs->org_set[osknt].org_list_knt)
            AND access_granted=true)
            IF ((treply->ord_qual[vidx].adr[ridx].reltn_entity_name="ORGANIZATION")
             AND (treply->ord_qual[vidx].adr[ridx].reltn_entity_id=prsnl_orgs->org_set[osknt].
            org_list[oknt].organization_id))
             SET treply->ord_qual[vidx].viewable_ind = 2
             SET continue = false
            ENDIF
            SET oknt += 1
           ENDWHILE
           SET osknt += 1
         ENDWHILE
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  ELSE
   FOR (vidx = 1 TO treply->ord_qual_knt)
     SET treply->ord_qual[vidx].viewable_ind = 1
   ENDFOR
  ENDIF
 ENDIF
 FREE RECORD meds
 RECORD meds(
   1 qual_knt = i4
   1 qual[*]
     2 info = c88
     2 ind = c6
 )
 IF ((treply->ord_qual_knt > 0))
  FOR (i = 1 TO treply->ord_qual_knt)
    FREE RECORD tmed
    RECORD tmed(
      1 name = vc
      1 ind_med = vc
      1 sig_line = vc
      1 prn_inst = vc
      1 spec_inst = vc
      1 rxroute = vc
      1 freq = vc
      1 str_dose = vc
      1 str_unit = vc
      1 vol_dose = vc
      1 vol_unit = vc
      1 freetxt_dose = vc
      1 duration = vc
      1 dur_unit = vc
      1 disp_unit = vc
    )
    SET ierrcode = 0
    SELECT
     IF ((valid_encntr->restrict_ind < 1))
      FROM (dummyt d  WITH seq = value(treply->ord_qual[i].det_qual_knt)),
       (dummyt d2  WITH seq = 1),
       order_entry_fields oef,
       code_value cv
      PLAN (d
       WHERE d.seq > 0
        AND (treply->ord_qual[i].viewable_ind > 0)
        AND (treply->ord_qual[i].det_qual[d.seq].oe_field_meaning IN ("STRENGTHDOSE",
       "STRENGTHDOSEUNIT", "VOLUMNEDOSE", "VOLUMNEDOSEUNIT", "FREETXTDOSE",
       "RXROUTE", "FREQ", "DURATION", "DURATIONUNIT", "DISPENSEQTYUNIT",
       "SPECINX", "PRNINSTRUCTIONS")))
       JOIN (oef
       WHERE (oef.oe_field_id=treply->ord_qual[i].det_qual[d.seq].oe_field_id))
       JOIN (d2)
       JOIN (cv
       WHERE cv.code_set=oef.codeset
        AND (cv.display=treply->ord_qual[i].det_qual[d.seq].oe_field_value_display))
     ELSE
      FROM (dummyt d  WITH seq = value(treply->ord_qual[i].det_qual_knt)),
       (dummyt d2  WITH seq = 1),
       order_entry_fields oef,
       code_value cv,
       (dummyt d3  WITH seq = value(size(valid_encntr->encntrs.data,5)))
      PLAN (d3
       WHERE d3.seq > 0)
       JOIN (d
       WHERE (treply->ord_qual[i].encntr_id=valid_encntr->encntrs.data[d3.seq].encntr_id)
        AND (treply->ord_qual[i].viewable_ind > 0)
        AND (treply->ord_qual[i].det_qual[d.seq].oe_field_meaning IN ("STRENGTHDOSE",
       "STRENGTHDOSEUNIT", "VOLUMNEDOSE", "VOLUMNEDOSEUNIT", "FREETXTDOSE",
       "RXROUTE", "FREQ", "DURATION", "DURATIONUNIT", "DISPENSEQTYUNIT",
       "SPECINX", "PRNINSTRUCTIONS")))
       JOIN (oef
       WHERE (oef.oe_field_id=treply->ord_qual[i].det_qual[d.seq].oe_field_id))
       JOIN (d2)
       JOIN (cv
       WHERE cv.code_set=oef.codeset
        AND (cv.display=treply->ord_qual[i].det_qual[d.seq].oe_field_value_display))
     ENDIF
     INTO "nl:"
     d.seq, order_id = treply->ord_qual[i].order_id, encntr_id = treply->ord_qual[i].encntr_id,
     order_status = substring(1,15,uar_get_code_display(treply->ord_qual[i].order_status_cd)),
     synonym_mnemonic = substring(1,20,treply->ord_qual[i].synonym_mnemonic), oe_field_value_display
      = substring(1,20,treply->ord_qual[i].det_qual[d.seq].oe_field_value_display),
     display = substring(1,20,cv.description), oe_field_dt_tm_value = format(cnvtdatetime(treply->
       ord_qual[i].det_qual[d.seq].oe_field_dt_tm_value),"dd-mmm-yyyy hh:mm:ss;;d"), oe_field_tz =
     treply->ord_qual[i].det_qual[d.seq].oe_field_tz,
     oe_field_meaning_id = treply->ord_qual[i].det_qual[d.seq].oe_field_meaning_id, oe_field_meaning
      = substring(1,25,treply->ord_qual[i].det_qual[d.seq].oe_field_meaning), oe_field_id = treply->
     ord_qual[i].det_qual[d.seq].oe_field_id
     ORDER BY order_id, oe_field_id
     HEAD REPORT
      printable = false
     HEAD order_id
      IF ((((treply->ord_qual[i].order_status_cd=ordered_cd)) OR ((treply->ord_qual[i].encntr_id=
      visit_req->encntr_id))) )
       printable = true
      ELSE
       printable = false
      ENDIF
      IF (printable=true)
       IF ((treply->ord_qual[i].order_status_cd=ordered_cd)
        AND (treply->ord_qual[i].encntr_id=visit_req->encntr_id))
        tmed->ind_med = "NEW"
       ELSEIF ((treply->ord_qual[i].order_status_cd != ordered_cd)
        AND (treply->ord_qual[i].encntr_id=visit_req->encntr_id))
        tmed->ind_med = "STOP"
       ENDIF
      ENDIF
     DETAIL
      IF (printable=true)
       IF ((treply->ord_qual[i].det_qual[d.seq].oe_field_meaning="STRENGTHDOSE"))
        tmed->str_dose = trim(treply->ord_qual[i].det_qual[d.seq].oe_field_value_display)
       ELSEIF ((treply->ord_qual[i].det_qual[d.seq].oe_field_meaning="STRENGTHDOSEUNIT"))
        IF (cv.code_value > 0)
         tmed->str_unit = trim(cv.description)
        ELSE
         tmed->str_unit = trim(treply->ord_qual[i].det_qual[d.seq].oe_field_value_display)
        ENDIF
       ELSEIF ((treply->ord_qual[i].det_qual[d.seq].oe_field_meaning="VOLUMNEDOSE"))
        tmed->vol_dose = trim(treply->ord_qual[i].det_qual[d.seq].oe_field_value_display)
       ELSEIF ((treply->ord_qual[i].det_qual[d.seq].oe_field_meaning="VOLUMNEDOSEUNIT"))
        IF (cv.code_value > 0)
         tmed->vol_unit = trim(cv.description)
        ELSE
         tmed->vol_unit = trim(treply->ord_qual[i].det_qual[d.seq].oe_field_value_display)
        ENDIF
       ELSEIF ((treply->ord_qual[i].det_qual[d.seq].oe_field_meaning="FREETXTDOSE"))
        tmed->freetxt_dose = trim(treply->ord_qual[i].det_qual[d.seq].oe_field_value_display)
       ELSEIF ((treply->ord_qual[i].det_qual[d.seq].oe_field_meaning="RXROUTE"))
        IF (cv.code_value > 0)
         tmed->rxroute = trim(cv.description)
        ELSE
         tmed->rxroute = trim(treply->ord_qual[i].det_qual[d.seq].oe_field_value_display)
        ENDIF
       ELSEIF ((treply->ord_qual[i].det_qual[d.seq].oe_field_meaning="FREQ"))
        IF (cv.code_value > 0)
         tmed->freq = trim(cv.description)
        ELSE
         tmed->freq = trim(treply->ord_qual[i].det_qual[d.seq].oe_field_value_display)
        ENDIF
       ELSEIF ((treply->ord_qual[i].det_qual[d.seq].oe_field_meaning="DURATION"))
        tmed->duration = trim(treply->ord_qual[i].det_qual[d.seq].oe_field_value_display)
       ELSEIF ((treply->ord_qual[i].det_qual[d.seq].oe_field_meaning="DURATIONUNIT"))
        IF (cv.code_value > 0)
         tmed->dur_unit = trim(cv.description)
        ELSE
         tmed->dur_unit = trim(treply->ord_qual[i].det_qual[d.seq].oe_field_value_display)
        ENDIF
       ELSEIF ((treply->ord_qual[i].det_qual[d.seq].oe_field_meaning="DISPENSEQTYUNIT"))
        IF (cv.code_value > 0)
         tmed->disp_unit = trim(cv.description)
        ELSE
         tmed->disp_unit = trim(treply->ord_qual[i].det_qual[d.seq].oe_field_value_display)
        ENDIF
       ELSEIF ((treply->ord_qual[i].det_qual[d.seq].oe_field_meaning="SPECINX"))
        tmed->spec_inst = trim(treply->ord_qual[i].det_qual[d.seq].oe_field_value_display)
       ELSEIF ((treply->ord_qual[i].det_qual[d.seq].oe_field_meaning="PRNINSTRUCTIONS"))
        tmed->prn_inst = trim(treply->ord_qual[i].det_qual[d.seq].oe_field_value_display)
       ENDIF
      ENDIF
     FOOT  order_id
      IF (printable=true)
       tmed->name = concat(substring(1,7,tmed->ind_med),trim(treply->ord_qual[i].synonym_mnemonic))
       IF ((((tmed->str_dose > " ")) OR ((((tmed->str_unit > " ")) OR ((((tmed->vol_dose > " ")) OR (
       (tmed->vol_unit > " "))) )) )) )
        tmed->sig_line = trim(concat(trim(tmed->str_dose)," ",trim(tmed->str_unit)," ",trim(tmed->
           vol_dose),
          " ",trim(tmed->vol_unit)," ",trim(tmed->rxroute)," ",
          trim(tmed->freq)))
        IF ((tmed->duration > " ")
         AND (tmed->duration != "0"))
         tmed->sig_line = trim(concat(tmed->sig_line," for ",trim(tmed->duration)," ",trim(tmed->
            dur_unit)),3)
        ENDIF
       ELSE
        tmed->sig_line = trim(concat(trim(tmed->freetxt_dose)," ",trim(tmed->str_unit)," ",trim(tmed
           ->vol_dose),
          " ",trim(tmed->vol_unit)," ",trim(tmed->rxroute)," ",
          trim(tmed->freq)))
        IF ((tmed->duration > " ")
         AND (tmed->duration != "0"))
         tmed->sig_line = trim(concat(tmed->sig_line," for ",trim(tmed->duration)," ",trim(tmed->
            dur_unit)),3)
        ENDIF
       ENDIF
       meds->qual_knt += 1, stat = alterlist(meds->qual,meds->qual_knt)
       IF (textlen(concat(trim(tmed->name),substring(1,4,blank),trim(tmed->sig_line,3))) > 86)
        meds->qual[meds->qual_knt].info = substring(1,87,trim(tmed->name))
        IF ((tmed->sig_line > " "))
         meds->qual_knt += 1, stat = alterlist(meds->qual,meds->qual_knt), meds->qual[meds->qual_knt]
         .info = substring(1,88,concat(substring(1,9,blank),trim(tmed->sig_line,3)))
        ENDIF
        IF ((tmed->prn_inst > " "))
         meds->qual_knt += 1, stat = alterlist(meds->qual,meds->qual_knt), meds->qual[meds->qual_knt]
         .info = substring(1,88,concat(substring(1,9,blank),trim(tmed->prn_inst,3)))
        ENDIF
        IF ((tmed->spec_inst > " "))
         meds->qual_knt += 1, stat = alterlist(meds->qual,meds->qual_knt), meds->qual[meds->qual_knt]
         .info = substring(1,88,concat(substring(1,9,blank),trim(tmed->spec_inst,3)))
        ENDIF
       ELSE
        meds->qual[meds->qual_knt].info = concat(trim(tmed->name),substring(1,4,blank),trim(tmed->
          sig_line,3))
        IF ((tmed->prn_inst > " "))
         meds->qual_knt += 1, stat = alterlist(meds->qual,meds->qual_knt), meds->qual[meds->qual_knt]
         .info = substring(1,88,concat(substring(1,9,blank),trim(tmed->prn_inst,3)))
        ENDIF
        IF ((tmed->spec_inst > " "))
         meds->qual_knt += 1, stat = alterlist(meds->qual,meds->qual_knt), meds->qual[meds->qual_knt]
         .info = substring(1,88,concat(substring(1,9,blank),trim(tmed->spec_inst,3)))
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter, outerjoin = d, outerjoin = d2
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "MEDICATIONS"
     GO TO exit_script
    ENDIF
  ENDFOR
  FREE RECORD tmed
 ENDIF
 FREE RECORD treply
 CALL echo("***")
 CALL echo("***   Get Services ")
 CALL echo("***")
 FREE RECORD treply
 RECORD treply(
   1 qual_cnt = i4
   1 qual[*]
     2 encntr_id = f8
     2 order_status_cd = f8
     2 order_mnemonic = vc
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.person_id=visit_req->person_id)
    AND (o.encntr_id=visit_req->encntr_id)
    AND ((o.catalog_type_cd+ 0) != pharm_type_cd)
    AND ((o.template_order_flag+ 0) IN (0, 1, 5))
    AND ((o.active_ind+ 0)=1))
  HEAD REPORT
   knt = 0, stat = alterlist(treply->qual,10)
  DETAIL
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(treply->qual,(knt+ 9))
   ENDIF
   treply->qual[knt].encntr_id = o.encntr_id, treply->qual[knt].order_mnemonic = o
   .ordered_as_mnemonic, treply->qual[knt].order_status_cd = o.order_status_cd
  FOOT REPORT
   treply->qual_cnt = knt, stat = alterlist(treply->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ORDERS"
  GO TO exit_script
 ENDIF
 FREE RECORD srv
 RECORD srv(
   1 qual_knt = i4
   1 qual[*]
     2 info = c80
 )
 IF ((treply->qual_cnt > 0))
  SET ierrcode = 0
  SELECT
   IF ((valid_encntr->restrict_ind < 1))
    FROM (dummyt d  WITH seq = value(treply->qual_cnt))
    PLAN (d
     WHERE d.seq > 0
      AND (treply->qual[d.seq].order_status_cd IN (ordered_cd, incomplete_cd, inprocess_cd)))
   ELSE
    FROM (dummyt d  WITH seq = value(treply->qual_cnt)),
     (dummyt d3  WITH seq = value(size(valid_encntr->encntrs.data,5)))
    PLAN (d3
     WHERE d3.seq > 0)
     JOIN (d
     WHERE (treply->qual[d.seq].encntr_id=valid_encntr->encntrs.data[d3.seq].encntr_id)
      AND (treply->qual[d.seq].order_status_cd IN (ordered_cd, incomplete_cd, inprocess_cd)))
   ENDIF
   INTO "nl:"
   HEAD REPORT
    knt = 0, stat = alterlist(srv->qual,10)
   DETAIL
    knt += 1
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(srv->qual,(knt+ 9))
    ENDIF
    srv->qual[knt].info = substring(1,80,treply->qual[d.seq].order_mnemonic)
   FOOT REPORT
    srv->qual_knt = knt, stat = alterlist(srv->qual,knt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "SERVICES"
   GO TO exit_script
  ENDIF
 ENDIF
 FREE RECORD treply
 CALL echo("***")
 CALL echo("***   Get Allergies")
 CALL echo("***")
 FREE RECORD treply
 RECORD treply(
   1 allergy_qual = i4
   1 allergy[*]
     2 encntr_id = f8
     2 organization_id = f8
     2 viewable_ind = i2
     2 source_string = vc
     2 substance_nom_id = f8
     2 substance_ftdesc = vc
     2 allergy_id = f8
     2 reaction_status_cd = f8
     2 reaction_qual = i4
     2 reaction[*]
       3 reaction_nom_id = f8
       3 source_string = vc
       3 reaction_ftdesc = vc
       3 active_ind = i2
     2 adr_knt = i4
     2 adr[*]
       3 reltn_entity_name = vc
       3 reltn_entity_id = f8
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM allergy a,
   nomenclature n1,
   reaction r,
   nomenclature n2
  PLAN (a
   WHERE (a.person_id=visit_req->person_id)
    AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND a.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (n1
   WHERE n1.nomenclature_id=a.substance_nom_id)
   JOIN (r
   WHERE (r.allergy_id= Outerjoin(a.allergy_id))
    AND (r.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (r.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (n2
   WHERE (n2.nomenclature_id= Outerjoin(r.reaction_nom_id)) )
  HEAD REPORT
   knt = 0, stat = alterlist(treply->allergy,10)
  HEAD a.allergy_id
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(treply->allergy,(knt+ 9))
   ENDIF
   treply->allergy[knt].allergy_id = a.allergy_id, treply->allergy[knt].encntr_id = a.encntr_id,
   treply->allergy[knt].organization_id = a.organization_id
   IF (a.organization_id=0.0)
    treply->allergy[knt].viewable_ind = 1
   ENDIF
   treply->allergy[knt].reaction_status_cd = a.reaction_status_cd, treply->allergy[knt].source_string
    = n1.source_string, treply->allergy[knt].substance_ftdesc = a.substance_ftdesc,
   treply->allergy[knt].substance_nom_id = a.substance_nom_id, rknt = 0, stat = alterlist(treply->
    allergy[knt].reaction,10)
  DETAIL
   IF (r.reaction_id > 0)
    rknt += 1
    IF (mod(rknt,10)=1
     AND rknt != 1)
     stat = alterlist(treply->allergy[knt].reaction,(rknt+ 9))
    ENDIF
    treply->allergy[knt].reaction[rknt].active_ind = r.active_ind, treply->allergy[knt].reaction[rknt
    ].reaction_ftdesc = r.reaction_ftdesc, treply->allergy[knt].reaction[rknt].reaction_nom_id = r
    .reaction_nom_id,
    treply->allergy[knt].reaction[rknt].source_string = n2.source_string
   ENDIF
  FOOT  a.allergy_id
   treply->allergy[knt].reaction_qual = rknt, stat = alterlist(treply->allergy[knt].reaction,rknt)
  FOOT REPORT
   treply->allergy_qual = knt, stat = alterlist(treply->allergy,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "SERVICES"
  GO TO exit_script
 ENDIF
 CALL echorecord(treply)
 IF ((treply->allergy_qual > 0))
  IF (bpersonorgsecurityon=true)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM activity_data_reltn adr
    PLAN (adr
     WHERE expand(eidx,1,treply->allergy_qual,adr.activity_entity_id,treply->allergy[eidx].allergy_id
      )
      AND adr.activity_entity_name="ALLERGY")
    HEAD adr.activity_entity_id
     fidx = 0, fidx = locateval(fidx,1,treply->allergy_qual,adr.activity_entity_id,treply->allergy[
      fidx].allergy_id)
     IF (fidx > 0)
      stat = alterlist(treply->allergy[fidx].adr,10)
     ENDIF
     knt = 0
    DETAIL
     IF (fidx > 0)
      knt += 1
      IF (mod(knt,10)=1
       AND knt != 1)
       stat = alterlist(treply->allergy[fidx].adr,(knt+ 9))
      ENDIF
      treply->allergy[fidx].adr[knt].reltn_entity_name = adr.reltn_entity_name, treply->allergy[fidx]
      .adr[knt].reltn_entity_id = adr.reltn_entity_id
     ENDIF
    FOOT  adr.activity_entity_id
     treply->allergy[fidx].adr_knt = knt, stat = alterlist(treply->allergy[fidx].adr,knt)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "ADR-ALLERGY"
    GO TO exit_script
   ENDIF
   CALL echorecord(treply)
   FOR (vidx = 1 TO treply->allergy_qual)
     SET continue = true
     SET oknt = 1
     WHILE (continue=true
      AND (oknt <= prsnl_orgs->org_knt)
      AND (treply->allergy[vidx].viewable_ind < 1))
      IF ((treply->allergy[vidx].organization_id=prsnl_orgs->org[oknt].organization_id))
       SET treply->allergy[vidx].viewable_ind = 1
       SET continue = false
      ENDIF
      SET oknt += 1
     ENDWHILE
     IF ((treply->allergy[vidx].viewable_ind < 1))
      SET osknt = 1
      SET continue = true
      WHILE (continue=true
       AND (osknt <= prsnl_orgs->org_set_knt))
        SET oknt = 1
        SET access_granted = false
        SET access_granted = btest(prsnl_orgs->org_set[osknt].access_privs,algy_bit_pos)
        WHILE (continue=true
         AND (oknt <= prsnl_orgs->org_set[osknt].org_list_knt)
         AND access_granted=true)
         IF ((treply->allergy[vidx].organization_id=prsnl_orgs->org_set[osknt].org_list[oknt].
         organization_id))
          SET treply->allergy[vidx].viewable_ind = 1
          SET continue = false
         ENDIF
         SET oknt += 1
        ENDWHILE
        SET osknt += 1
      ENDWHILE
     ENDIF
     IF ((treply->allergy[vidx].adr_knt > 0)
      AND (treply->allergy[vidx].viewable_ind < 1))
      FOR (ridx = 1 TO treply->allergy[vidx].adr_knt)
        SET oknt = 1
        SET continue = true
        WHILE (continue=true
         AND (oknt <= prsnl_orgs->org_knt)
         AND (treply->allergy[vidx].viewable_ind < 1))
         IF ((treply->allergy[vidx].adr[ridx].reltn_entity_name="ORGANIZATION")
          AND (treply->allergy[vidx].adr[ridx].reltn_entity_id=prsnl_orgs->org[oknt].organization_id)
         )
          SET treply->allergy[vidx].viewable_ind = 1
          SET continue = false
         ENDIF
         SET oknt += 1
        ENDWHILE
        IF ((treply->allergy[vidx].viewable_ind < 1))
         SET osknt = 1
         SET continue = true
         WHILE (continue=true
          AND (osknt <= prsnl_orgs->org_set_knt))
           SET oknt = 1
           SET access_granted = false
           SET access_granted = btest(prsnl_orgs->org_set[osknt].access_privs,algy_bit_pos)
           WHILE (continue=true
            AND (oknt <= prsnl_orgs->org_set[osknt].org_list_knt)
            AND access_granted=true)
            IF ((treply->allergy[vidx].adr[ridx].reltn_entity_name="ORGANIZATION")
             AND (treply->allergy[vidx].adr[ridx].reltn_entity_id=prsnl_orgs->org_set[osknt].
            org_list[oknt].organization_id))
             SET treply->allergy[vidx].viewable_ind = 2
             SET continue = false
            ENDIF
            SET oknt += 1
           ENDWHILE
           SET osknt += 1
         ENDWHILE
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  ELSE
   FOR (vidx = 1 TO treply->allergy_qual)
     SET treply->allergy[vidx].viewable_ind = 1
   ENDFOR
  ENDIF
 ENDIF
 FREE RECORD alg
 RECORD alg(
   1 qual_knt = i4
   1 qual[*]
     2 info = c88
 )
 SET new_alg = fillstring(7," ")
 SET alg_name = fillstring(25," ")
 IF ((treply->allergy_qual > 0))
  FOR (i = 1 TO treply->allergy_qual)
   SET viewable = true
   IF ((treply->allergy[i].viewable_ind > 0))
    SET ierrcode = 0
    IF ((treply->allergy[i].reaction_status_cd != can_react_cd))
     IF ((treply->allergy[i].encntr_id=visit_req->encntr_id))
      SET new_alg = substring(1,7,"NEW")
     ELSE
      SET new_alg = substring(1,7,blank)
     ENDIF
     IF ((treply->allergy[i].substance_nom_id > 0))
      SET alg_name = substring(1,25,treply->allergy[i].source_string)
     ELSE
      SET alg_name = substring(1,25,treply->allergy[i].substance_ftdesc)
     ENDIF
     IF ((treply->allergy[i].reaction_qual > 0))
      SET ierrcode = 0
      SET ierrcode = error(serrmsg,0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(treply->allergy[i].reaction_qual))
       PLAN (d
        WHERE d.seq > 0)
       HEAD REPORT
        alg->qual_knt += 1, stat = alterlist(alg->qual,alg->qual_knt), alg->qual[alg->qual_knt].info
         = concat(new_alg,alg_name),
        hit_nbr = 0, react_name = fillstring(20," ")
       DETAIL
        react_name = substring(1,20,blank)
        IF ((treply->allergy[i].reaction[d.seq].reaction_nom_id > 0))
         react_name = substring(1,20,treply->allergy[i].reaction[d.seq].source_string)
        ELSE
         react_name = substring(1,20,treply->allergy[i].reaction[d.seq].reaction_ftdesc)
        ENDIF
        IF ((treply->allergy[i].reaction[d.seq].active_ind=1))
         hit_nbr += 1
         IF (hit_nbr=1)
          alg->qual[alg->qual_knt].info = concat(substring(1,32,alg->qual[alg->qual_knt].info),
           " Reaction(s): ",trim(react_name))
         ELSE
          alg->qual[alg->qual_knt].info = concat(trim(alg->qual[alg->qual_knt].info),", ",trim(
            react_name))
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = select_error
       SET table_name = "ALLERGIES"
       GO TO exit_script
      ENDIF
     ELSE
      SET alg->qual_knt += 1
      SET stat = alterlist(alg->qual,alg->qual_knt)
      SET alg->qual[alg->qual_knt].info = concat(new_alg,alg_name)
     ENDIF
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
 FREE RECORD treply
 CALL echo("***")
 CALL echo("***   Produce Report")
 CALL echo("***")
 SET ierrcode = 0
 SELECT INTO request->output_device
  dvar
  HEAD REPORT
   cur_page = 1, tot_page = 1,
   MACRO (print_page_template1)
    "{f/5/1}{cpi/6^}{lpi/6}{pos/021/25}", row + 1, col 4,
    rpt_street_addr1, col + 1, "{f/5/1}{cpi/10^}{lpi/8}",
    row + 1, col 7, rpt_street_addr2,
    col + 1, "{f/4/1}{cpi/10^}{lpi/8}", row + 1,
    col 7, rpt_street_addr3, row + 1,
    col 7, rpt_street_addr4, row + 1,
    col 7, city_line, row + 1,
    col 7, phone_line, row + 1,
    "{f/5/1}{cpi/6^}{lpi/6}", row + 1, col 4,
    report_title, col + 1, col 72,
    visit_date, col + 1, "{f/5/1}{cpi/10^}{lpi/8}",
    row + 1, "{color/30/1}{pos/031/115}{box/73/1}", row + 1,
    "{color/31/1}{pos/031/115}{box/73/1}", row + 1, "{pos/031/133}{box/73/1}",
    row + 1, "{pos/031/133}{box/73/64}", row + 1,
    "{pos/031/117}{f/5/0}", row + 1, col 08,
    "Patient Name:", col + 1, pat_name,
    row + 1, "{pos/031/136}{f/4/0}", row + 1,
    col 08, "DOB:", col + 1,
    dob, col 69, "Age:",
    col + 1, age, col 125,
    "Sex:", col + 1, sex,
    row + 1, "{f/0/1}{cpi/12^}{lpi/8}{pos/002/720}", row + 1,
    col 04, "Printed By:", col + 1,
    print_by, col + 2, "At:",
    col + 1, print_dt_tm
    IF (cur_page < tot_page)
     col 55, "<< Report Continued >>"
    ELSE
     col 55, "<< End of Report >>"
    ENDIF
    cp = format(cur_page,"###;P0"), tp = format(tot_page,"###;P0"), col 77,
    "Page", col + 1, cp,
    col + 1, "of", col + 1,
    tp, col + 1, "{pos/031/147}",
    row + 1
   ENDMACRO
   ,
   MACRO (print_page_template2)
    "{f/5/1}{cpi/8^}{lpi/6}{pos/021/15}", row + 1, "{f/5/1}{cpi/6^}{lpi/6}",
    row + 1, col 4, report_title,
    col + 1, col 72, visit_date,
    col + 1, "{f/5/1}{cpi/10^}{lpi/8}", row + 1,
    "{color/30/1}{pos/031/50}{box/73/1}", row + 1, "{color/31/1}{pos/031/50}{box/73/1}",
    row + 1, "{pos/031/68}{box/73/1}", row + 1,
    "{pos/031/68}{box/73/72}", row + 1, "{pos/031/52}{f/5/0}",
    row + 1, col 08, "Patient Name:",
    col + 1, pat_name, row + 1,
    "{pos/031/72}{f/4/0}", row + 1, col 08,
    "DOB:", col + 1, dob,
    col 69, "Age:", col + 1,
    age, col 125, "Sex:",
    col + 1, sex, row + 1,
    "{f/0/1}{cpi/12^}{lpi/8}{pos/002/720}", row + 1, col 04,
    "Printed By:", col + 1, print_by,
    col + 2, "At:", col + 1,
    print_dt_tm
    IF (cur_page < tot_page)
     col 55, "<< Report Continued >>"
    ELSE
     col 55, "<< End of Report >>"
    ENDIF
    cp = format(cur_page,"###;P0"), tp = format(tot_page,"###;P0"), col 77,
    "Page", col + 1, cp,
    col + 1, "of", col + 1,
    tp, col + 1, "{f/0/1}{cpi/12^}{lpi/8}{pos/031/072}",
    row + 1
   ENDMACRO
   ,
   MACRO (check_space)
    IF (((rows_2_print+ cur_row) > max_rows))
     new_page = true, BREAK, cur_page += 1,
     print_page_template2, cur_row = 1, max_rows = 70
    ELSE
     new_page = false
    ENDIF
   ENDMACRO
   ,
   MACRO (check_space_dummy)
    IF (((rows_2_print+ cur_row) > max_rows))
     new_page = true, cur_page += 1, cur_row = 1,
     max_rows = 70
    ELSE
     new_page = false
    ENDIF
   ENDMACRO
   ,
   MACRO (find_total_pages)
    tot_page = 1
    IF ((pat_info->qual_knt > 0))
     rows_2_print = 2, check_space_dummy, cur_row += 1
     FOR (ipat = 1 TO pat_info->qual_knt)
       rows_2_print = 1, check_space_dummy
       IF (new_page=true)
        cur_row += 1, new_page = false
       ENDIF
       cur_row += 1
     ENDFOR
    ENDIF
    IF ((rfv->qual_knt > 0))
     rows_2_print = 3, check_space_dummy, cur_row += 3
     FOR (ipat = 1 TO rfv->qual_knt)
       rows_2_print = 1, check_space_dummy
       IF (new_page=true)
        cur_row += 1, new_page = false
       ENDIF
       cur_row += 1
     ENDFOR
    ENDIF
    IF ((doc->qual_knt > 0))
     rows_2_print = 3, check_space_dummy, cur_row += 3
     FOR (ipat = 1 TO doc->qual_knt)
       rows_2_print = 1, check_space_dummy
       IF (new_page=true)
        cur_row += 1, new_page = false
       ENDIF
       cur_row += 1
     ENDFOR
    ENDIF
    IF ((vital->qual_knt > 0))
     rows_2_print = 3, check_space_dummy, cur_row += 3
     FOR (ipat = 1 TO vital->qual_knt)
       rows_2_print = 1, check_space_dummy
       IF (new_page=true)
        cur_row += 1, new_page = false
       ENDIF
       cur_row += 1
     ENDFOR
    ENDIF
    IF ((diag->qual_knt > 0))
     rows_2_print = 3, check_space_dummy, cur_row += 3
     FOR (ipat = 1 TO diag->qual_knt)
       rows_2_print = 1, check_space_dummy
       IF (new_page=true)
        cur_row += 1, new_page = false
       ENDIF
       cur_row += 1
     ENDFOR
    ENDIF
    IF ((meds->qual_knt > 0))
     rows_2_print = 3, check_space_dummy, cur_row += 3
     FOR (ipat = 1 TO meds->qual_knt)
       rows_2_print = 1, check_space_dummy
       IF (new_page=true)
        cur_row += 1, new_page = false
       ENDIF
       cur_row += 1
     ENDFOR
    ENDIF
    IF ((srv->qual_knt > 0))
     rows_2_print = 3, check_space_dummy, cur_row += 3
     FOR (ipat = 1 TO srv->qual_knt)
       rows_2_print = 1, check_space_dummy
       IF (new_page=true)
        cur_row += 1, new_page = false
       ENDIF
       cur_row += 1
     ENDFOR
    ENDIF
    IF ((alg->qual_knt > 0))
     rows_2_print = 3, check_space_dummy, cur_row += 3
     FOR (ipat = 1 TO alg->qual_knt)
       rows_2_print = 1, check_space_dummy
       IF (new_page=true)
        cur_row += 1, new_page = false
       ENDIF
       cur_row += 1
     ENDFOR
    ENDIF
    tot_page = cur_page, cur_row = 1, max_rows = 62,
    cur_page = 1, new_page = false
   ENDMACRO
   ,
   MACRO (print_pat_info)
    rows_2_print = 2, check_space, cur_row += 1,
    "{pos/031/147}", row + 2
    FOR (ipat = 1 TO pat_info->qual_knt)
      col 04, pat_info->qual[ipat].info, row + 1,
      rows_2_print = 1, check_space
      IF (new_page=true)
       row + 2, cur_row += 1, col 04,
       "Patient Information continued ...", row + 1, new_page = false
      ENDIF
      cur_row += 1
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_rfv)
    rows_2_print = 3, check_space, col + 1,
    row + 1, "{f/1/1}", row + 1,
    col 004, rfv_banner_line, col + 1,
    "{f/0/1}", row + 1, cur_row += 3
    FOR (ipat = 1 TO rfv->qual_knt)
      col 011, rfv->qual[ipat].info, row + 1,
      rows_2_print = 1, check_space
      IF (new_page=true)
       "{f/1/1}", row + 2, cur_row += 1,
       col 04, rfv_banner_cont, col + 1,
       "{f/0/1}", row + 1, new_page = false
      ENDIF
      cur_row += 1
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_doc)
    rows_2_print = 3, check_space, col + 1,
    row + 1, "{f/1/1}", row + 1,
    col 004, doc_banner_line, col + 1,
    "{f/0/1}", row + 1, cur_row += 3
    FOR (ipat = 1 TO doc->qual_knt)
      col 011, doc->qual[ipat].info, row + 1,
      rows_2_print = 1, check_space
      IF (new_page=true)
       "{f/1/1}", row + 2, cur_row += 1,
       col 04, doc_banner_cont, col + 1,
       "{f/0/1}", row + 1, new_page = false
      ENDIF
      cur_row += 1
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_vital)
    rows_2_print = 3, check_space, col + 1,
    row + 1, "{f/1/1}", row + 1,
    col 004, vital_banner_line, col + 1,
    "{f/0/1}", row + 1, cur_row += 3
    FOR (ipat = 1 TO vital->qual_knt)
      col 011, vital->qual[ipat].info, row + 1,
      rows_2_print = 1, check_space
      IF (new_page=true)
       "{f/1/1}", row + 2, cur_row += 1,
       col 04, vital_banner_cont, col + 1,
       "{f/0/1}", row + 1, new_page = false
      ENDIF
      cur_row += 1
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_diag)
    rows_2_print = 3, check_space, col + 1,
    row + 1, "{f/1/1}", row + 1,
    col 004, diag_banner_line, col + 1,
    "{f/0/1}", row + 1, cur_row += 3
    FOR (ipat = 1 TO diag->qual_knt)
      col 011, diag->qual[ipat].info, row + 1,
      rows_2_print = 1, check_space
      IF (new_page=true)
       "{f/1/1}", row + 2, cur_row += 1,
       col 04, diag_banner_cont, col + 1,
       "{f/0/1}", row + 1, new_page = false
      ENDIF
      cur_row += 1
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_meds)
    rows_2_print = 3, check_space, col + 1,
    row + 1, "{f/1/1}", row + 1,
    col 004, meds_banner_line, col + 1,
    "{f/0/1}", row + 1, cur_row += 3
    FOR (ipat = 1 TO meds->qual_knt)
      col 04, meds->qual[ipat].info, row + 1,
      rows_2_print = 1, check_space
      IF (new_page=true)
       "{f/1/1}", row + 2, cur_row += 1,
       col 04, meds_banner_cont, col + 1,
       "{f/0/1}", row + 1, new_page = false
      ENDIF
      cur_row += 1
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_srv)
    rows_2_print = 3, check_space, col + 1,
    row + 1, "{f/1/1}", row + 1,
    col 004, srv_banner_line, col + 1,
    "{f/0/1}", row + 1, cur_row += 3
    FOR (ipat = 1 TO srv->qual_knt)
      col 011, srv->qual[ipat].info, row + 1,
      rows_2_print = 1, check_space
      IF (new_page=true)
       "{f/1/1}", row + 2, cur_row += 1,
       col 04, srv_banner_cont, col + 1,
       "{f/0/1}", row + 1, new_page = false
      ENDIF
      cur_row += 1
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_alg)
    rows_2_print = 3, check_space, col + 1,
    row + 1, "{f/1/1}", row + 1,
    col 004, alg_banner_line, col + 1,
    "{f/0/1}", row + 1, cur_row += 3
    FOR (ipat = 1 TO alg->qual_knt)
      col 004, alg->qual[ipat].info, row + 1,
      rows_2_print = 1, check_space
      IF (new_page=true)
       "{f/1/1}", row + 2, cur_row += 1,
       col 04, alg_banner_cont, col + 1,
       "{f/0/1}", row + 1, new_page = false
      ENDIF
      cur_row += 1
    ENDFOR
   ENDMACRO
   ,
   find_total_pages, print_page_template1
   IF ((pat_info->qual_knt > 0))
    print_pat_info
   ENDIF
   IF ((rfv->qual_knt > 0))
    print_rfv
   ENDIF
   IF ((doc->qual_knt > 0))
    print_doc
   ENDIF
   IF ((vital->qual_knt > 0))
    print_vital
   ENDIF
   IF ((diag->qual_knt > 0))
    print_diag
   ENDIF
   IF ((meds->qual_knt > 0))
    print_meds
   ENDIF
   IF ((srv->qual_knt > 0))
    print_srv
   ENDIF
   IF ((alg->qual_knt > 0))
    print_alg
   ENDIF
  WITH check, nocounter, nullreport,
   maxrow = 100, maxcol = 300, dio = postscript
 ;end select
 IF (ierrcode > 0)
  SET failed = insert_error
  SET table_name = "REPORT"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_verson = "021 10/17/07 JS011018"
END GO
