CREATE PROGRAM cps_rpt_summ:dba
 FREE RECORD reply
 RECORD reply(
   1 output_file = vc
   1 format_type = vc
   1 node = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET operationname = fillstring(25," ")
 SET operationstatus = "F"
 SET targetobjectname = fillstring(25," ")
 SET targetobjectvalue = fillstring(132," ")
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET the_status = "F"
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0
 SET pat_hist_name = fillstring(25," ")
 SET print_line_len = 115
 SET dvar = 0
 SET person_id_num = request->person_id
 SET prsnl_id = reqinfo->updt_id
 SET nbr_sections = request->nbr_sections
 SET allergy_num = request->allergy
 SET problem_num = request->problem
 SET orders_num = request->orders
 SET med_profile_num = request->med_profile
 SET encounter_num = request->encounter
 SET proc_hist_num = request->proc_hist
 SET plan_num = request->plan_sec
 SET immune_num = request->immune_sec
 SET immune_sched_num = request->immune_sched_sec
 SET immune_nonsched_num = request->immune_nonsched_sec
 SET pat_hist_num = request->pat_hist_sec
 SET allergy_cnt = 0
 SET problem_cnt = 0
 SET orders_cnt = 0
 SET meds_cnt = 0
 SET encounter_cnt = 0
 SET proc_cnt = 0
 SET plan_cnt = 0
 SET immune_cnt = 0
 SET pat_hist_cnt = 0
 SET immune_sched_cnt = 0
 SET immune_nonsched_cnt = 0
 SET max_row = 48
 SET allergy_heading = fillstring(50," ")
 SET allergy_heading_cont = fillstring(75," ")
 SET problem_heading = fillstring(50," ")
 SET problem_heading_cont = fillstring(75," ")
 SET orders_heading = fillstring(50," ")
 SET orders_heading_cont = fillstring(75," ")
 SET medprofile_heading = fillstring(50," ")
 SET medprofile_heading_cont = fillstring(75," ")
 SET encounter_heading = fillstring(50," ")
 SET encounter_heading_cont = fillstring(75," ")
 SET proc_hist_heading = fillstring(50," ")
 SET proc_hist_heading_cont = fillstring(75," ")
 SET plan_heading = fillstring(50," ")
 SET plan_heading_cont = fillstring(75," ")
 SET pat_hist_heading = fillstring(50," ")
 SET pat_hist_heading_cont = fillstring(75," ")
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
 DECLARE algy_priv = i2 WITH public, noconstant(false)
 DECLARE diag_priv = i2 WITH public, noconstant(false)
 DECLARE prob_priv = i2 WITH public, noconstant(false)
 DECLARE proc_priv = i2 WITH public, noconstant(false)
 DECLARE ordr_priv = i2 WITH public, noconstant(false)
 DECLARE rslt_priv = i2 WITH public, noconstant(false)
 DECLARE tcodeval = f8 WITH public, noconstant(0.0)
 DECLARE bpersonorgsecurityon = i2 WITH public, noconstant(false)
 DECLARE bencntrorgsecurityon = i2 WITH public, noconstant(false)
 DECLARE dminfo_ok = i2 WITH private, noconstant(false)
 DECLARE eidx = i4 WITH public, noconstant(0)
 DECLARE fidx = i4 WITH public, noconstant(0)
 DECLARE algy_bit_pos = i2 WITH public, noconstant(0)
 DECLARE diag_bit_pos = i2 WITH public, noconstant(0)
 DECLARE prob_bit_pos = i2 WITH public, noconstant(0)
 DECLARE proc_bit_pos = i2 WITH public, noconstant(0)
 DECLARE algy_access_priv = f8 WITH public, noconstant(0.0)
 DECLARE diag_access_priv = f8 WITH public, noconstant(0.0)
 DECLARE prob_access_priv = f8 WITH public, noconstant(0.0)
 DECLARE proc_access_priv = f8 WITH public, noconstant(0.0)
 DECLARE access_granted = i2 WITH public, noconstant(false)
 DECLARE vertical_rule = vc WITH protect, constant(fillstring(1,"|"))
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE i18n_report_title = vc WITH protect, noconstant(fillstring(150," "))
 DECLARE i18n_immunization = vc WITH protect, noconstant(fillstring(150," "))
 DECLARE i18n_immunization_cont = vc WITH protect, noconstant(fillstring(150," "))
 DECLARE i18n_immunization_sched = vc WITH protect, noconstant(fillstring(150," "))
 DECLARE i18n_immunization_sched_cont = vc WITH protect, noconstant(fillstring(150," "))
 DECLARE i18n_immunization_nonsched = vc WITH protect, noconstant(fillstring(150," "))
 DECLARE i18n_immunization_nonsched_cont = vc WITH protect, noconstant(fillstring(150," "))
 DECLARE i18n_patient = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PATIENT","Patient"))
 DECLARE i18n_med_rec = vc WITH constant(uar_i18ngetmessage(i18nhandle,"MED_REC","Med Rec"))
 DECLARE i18n_address = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ADDRESS","Address"))
 DECLARE i18n_dob = vc WITH constant(uar_i18ngetmessage(i18nhandle,"DOB","DOB"))
 DECLARE i18n_sex = vc WITH constant(uar_i18ngetmessage(i18nhandle,"SEX","Sex"))
 DECLARE i18n_phone = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PHONE","Phone"))
 DECLARE i18n_physician = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PHYSICIAN","Physician"))
 DECLARE i18n_print_by = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PRINT_BY","Print by"))
 DECLARE i18n_printed = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PRINTED","Printed"))
 DECLARE i18n_end_of_report = vc WITH constant(uar_i18ngetmessage(i18nhandle,"END_OF_REPORT",
   "end of report"))
 DECLARE i18n_continued = vc WITH constant(uar_i18ngetmessage(i18nhandle,"CONTINUED","continued..."))
 DECLARE i18n_page = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PAGE","Page"))
 DECLARE i18n_of = vc WITH constant(uar_i18ngetmessage(i18nhandle,"OF","of"))
 DECLARE i18n_vaccine = vc WITH constant(uar_i18ngetmessage(i18nhandle,"VACCINE","Vaccine"))
 DECLARE i18n_status = vc WITH constant(uar_i18ngetmessage(i18nhandle,"STATUS","Status"))
 DECLARE i18n_patient_age = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PATIENT_AGE",
   "Patient Age"))
 DECLARE i18n_admin_person = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ADMIN_PERSON",
   "Admin Person"))
 DECLARE i18n_ordered_by = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ORDERED_BY","Ordered By"))
 DECLARE i18n_admin_note = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ADMIN_NOTE","Admin Note"))
 DECLARE i18n_vaccine_product = vc WITH constant(uar_i18ngetmessage(i18nhandle,"VACCINE_PRODUCT",
   "Vaccine (Product)"))
 DECLARE i18n_location = vc WITH constant(uar_i18ngetmessage(i18nhandle,"LOCATION","Location"))
 DECLARE i18n_lot_number = vc WITH constant(uar_i18ngetmessage(i18nhandle,"LOT_NUMBER","Lot Number"))
 DECLARE i18n_date_given = vc WITH constant(uar_i18ngetmessage(i18nhandle,"DATE_GIVEN","Date Given"))
 DECLARE i18n_refusal_reason = vc WITH constant(uar_i18ngetmessage(i18nhandle,"REFUSAL_REASON",
   "Refusal Reason"))
 DECLARE i18n_dose = vc WITH constant(uar_i18ngetmessage(i18nhandle,"DOSE","Dose"))
 DECLARE i18n_type_of_vaccine = vc WITH constant(uar_i18ngetmessage(i18nhandle,"TYPE_OF_VACCINE",
   "Type of Vaccine"))
 DECLARE i18n_product_given = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PRODUCT_GIVEN",
   "Product Given"))
 DECLARE i18n_no_immunizations = vc WITH constant(uar_i18ngetmessage(i18nhandle,"NO_IMMUNIZATIONS",
   "No Immunizations Found For Patient"))
 DECLARE i18n_no_medications = vc WITH constant(uar_i18ngetmessage(i18nhandle,"NO_MEDICATIONS",
   "No Medications Ordered For Patient"))
 DECLARE i18n_no_orders = vc WITH constant(uar_i18ngetmessage(i18nhandle,"NO_ORDERS",
   "No Orders Found For Patient"))
 DECLARE i18n_cos_rev = vc WITH constant(uar_i18ngetmessage(i18nhandle,"COS_REV","Cos/Rev"))
 DECLARE i18n_catalog_type = vc WITH constant(uar_i18ngetmessage(i18nhandle,"CATALOG_TYPE",
   "Catalog Type"))
 DECLARE i18n_start_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,"START_DATE","Start Date"))
 DECLARE i18n_orderable = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ORDERABLE","Orderable"))
 DECLARE i18n_order_detail = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ORDER_DETAIL",
   "Order Detail"))
 DECLARE i18n_provider = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PROVIDER","Provider"))
 DECLARE i18n_character_c = vc WITH constant(uar_i18ngetmessage(i18nhandle,"CHARACTER_C","C"))
 DECLARE i18n_character_r = vc WITH constant(uar_i18ngetmessage(i18nhandle,"CHARACTER_R","R"))
 DECLARE i18n_no_oth_immunizations = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "NO_OTH_IMMUNIZATIONS","No Other Immunizations Found For Patient"))
 IF (textlen(trim(i18n_product_given))=21)
  SET type_of_vaccine_hdr = fillstring(39," ")
  SET product_given_hdr = fillstring(21," ")
  SET type_of_vaccine_hdr = substring(1,39,i18n_type_of_vaccine)
  SET product_given_hdr = substring(1,21,i18n_product_given)
 ELSE
  SET type_of_vaccine_hdr = fillstring(40," ")
  SET product_given_hdr = fillstring(20," ")
  SET type_of_vaccine_hdr = substring(1,40,i18n_type_of_vaccine)
  SET product_given_hdr = substring(1,20,i18n_product_given)
 ENDIF
 IF (textlen(trim(i18n_date_given))=10)
  SET date_given1_hdr = fillstring(12," ")
  SET location1_hdr = fillstring(28," ")
  SET product_given1_hdr = fillstring(30," ")
  SET date_given2_hdr = fillstring(13," ")
  SET date_given1_hdr = substring(1,12,i18n_date_given)
  SET location1_hdr = substring(1,28,i18n_location)
  SET product_given1_hdr = substring(1,30,i18n_product_given)
  SET date_given2_hdr = substring(1,13,i18n_date_given)
 ELSE
  SET date_given1_hdr = fillstring(14," ")
  SET location1_hdr = fillstring(27," ")
  SET product_given1_hdr = fillstring(29," ")
  SET date_given2_hdr = fillstring(14," ")
  SET date_given1_hdr = substring(1,14,i18n_date_given)
  SET location1_hdr = substring(1,27,i18n_location)
  SET product_given1_hdr = substring(1,29,i18n_product_given)
  SET date_given2_hdr = substring(1,14,i18n_date_given)
 ENDIF
 SET dminfo_ok = validate(ccldminfo->mode,0)
 IF (dminfo_ok=1)
  IF ((ccldminfo->sec_org_reltn=1)
   AND (ccldminfo->person_org_sec=1))
   SET bpersonorgsecurityon = true
  ENDIF
  IF ((ccldminfo->sec_org_reltn=1))
   SET bencntrorgsecurityon = true
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
    IF (encntr_org_sec_on=1)
     bencntrorgsecurityon = true
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
     AND ((ppr.person_id+ 0)=request->person_id)
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
  IF (validate(sac_org)=0)
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
    org_set os,
    org_set_org_r osor
   PLAN (ospr
    WHERE (ospr.prsnl_id=reqinfo->updt_id)
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
 DECLARE plp_prsnl_id = f8 WITH public, noconstant(0.0)
 DECLARE plp_person_id = f8 WITH public, noconstant(0.0)
 SET plp_prsnl_id = reqinfo->updt_id
 SET plp_person_id = request->person_id
 RECORD algy_exp(
   1 priv_value_cd = f8
   1 exception_knt = i4
   1 exception[*]
     2 exp_id = f8
 )
 RECORD diag_exp(
   1 priv_value_cd = f8
   1 exception_knt = i4
   1 exception[*]
     2 exp_id = f8
 )
 RECORD prob_exp(
   1 priv_value_cd = f8
   1 exception_knt = i4
   1 exception[*]
     2 exp_id = f8
 )
 RECORD proc_exp(
   1 priv_value_cd = f8
   1 exception_knt = i4
   1 exception[*]
     2 exp_id = f8
 )
 RECORD ordr_exp(
   1 priv_value_cd = f8
   1 exception_knt = i4
   1 exception_type_flag = i2
   1 exception[*]
     2 exp_id = f8
 )
 RECORD rslt_exp(
   1 priv_value_cd = f8
   1 exception_knt = i4
   1 exception_type_flag = i2
   1 exception[*]
     2 exp_id = f8
 )
 EXECUTE pco_load_privs
 IF (failed != false)
  SET operationname = "EXECUTE"
  SET operationstatus = "F"
  SET targetobjectname = "PCO_LOAD_PRIVS"
  SET targetobjectvalue = errmsg
  SET the_status = "F"
  GO TO exit_script
 ENDIF
 CALL echo("***")
 IF ((algy_exp->priv_value_cd > 0)
  AND uar_get_code_meaning(algy_exp->priv_value_cd) != "YES")
  CALL echo("***   algy_priv = TRUE")
  SET algy_priv = true
 ENDIF
 IF ((diag_exp->priv_value_cd > 0)
  AND uar_get_code_meaning(diag_exp->priv_value_cd) != "YES")
  CALL echo("***   diag_priv = TRUE")
  SET diag_priv = true
 ENDIF
 IF ((prob_exp->priv_value_cd > 0)
  AND uar_get_code_meaning(prob_exp->priv_value_cd) != "YES")
  CALL echo("***   prob_priv = TRUE")
  SET prob_priv = true
 ENDIF
 IF ((proc_exp->priv_value_cd > 0)
  AND uar_get_code_meaning(proc_exp->priv_value_cd) != "YES")
  CALL echo("***   proc_priv = TRUE")
  SET proc_priv = true
 ENDIF
 IF ((ordr_exp->priv_value_cd > 0)
  AND uar_get_code_meaning(ordr_exp->priv_value_cd) != "YES")
  CALL echo("***   ordr_priv = TRUE")
  SET ordr_priv = true
 ENDIF
 IF ((rslt_exp->priv_value_cd > 0)
  AND uar_get_code_meaning(rslt_exp->priv_value_cd) != "YES")
  CALL echo("***   rslt_priv = TRUE")
  SET rslt_priv = true
 ENDIF
 CALL echo("***")
 FREE RECORD drec
 RECORD drec(
   1 app_dt_tm = dq8
   1 sys_dt_tm = dq8
 )
 DECLARE print_time = vc WITH public, noconstant(" ")
 DECLARE print_time_ampm = vc WITH public, noconstant(" ")
 DECLARE the_time = vc WITH public, noconstant(" ")
 DECLARE pm_check = vc WITH public, noconstant(" ")
 DECLARE utc_is_on = i2 WITH public, noconstant(0)
 SET utc_is_on = curutc
 IF (utc_is_on > 0)
  SET drec->sys_dt_tm = datetimezone(cnvtdatetime(sysdate),curtimezonesys,2)
  SET drec->app_dt_tm = datetimezone(drec->sys_dt_tm,curtimezoneapp)
 ELSE
  SET drec->app_dt_tm = cnvtdatetime(sysdate)
 ENDIF
 SET print_time = format(drec->app_dt_tm,"@SHORTDATE;;d")
 SET the_time = format(drec->app_dt_tm,"@TIMENOSECONDS;;s")
 SET print_time = concat(print_time," ",substring(1,5,the_time))
 SET pm_check = format(drec->app_dt_tm,"@TIMENOSECONDS;;m")
 IF (cnvtint(substring(1,2,pm_check)) >= 12)
  SET print_time_ampm = cnvtupper(concat(print_time," PM"))
 ELSE
  SET print_time_ampm = cnvtupper(concat(print_time," AM"))
 ENDIF
 CALL echo("***")
 CALL echo(build("***   print_time_ampm :",print_time_ampm))
 CALL echo("***")
 IF (curutc > 0)
  SET offset = 0
  SET daylight = 0
  SET utclabel = datetimezonebyindex(curtimezoneapp,offset,daylight,7,drec->app_dt_tm)
  SET print_time = concat(print_time," ",utclabel)
  SET print_time_ampm = concat(print_time_ampm," ",utclabel)
 ENDIF
 CALL echo("***")
 CALL echo(build("***   print_time      :",print_time))
 CALL echo(build("***   print_time_ampm :",print_time_ampm))
 CALL echo("***")
 FREE SET offset
 FREE SET daylight
 FREE SET utclabel
 SET report_title = fillstring(55," ")
 IF ((request->report_name > " "))
  SET report_title = format(trim(substring(1,55,request->report_name)),
   "#######################################################;C;C")
 ELSE
  SET i18n_report_title = uar_i18ngetmessage(i18nhandle,"REPORT_TITLE","Unknown Report")
  SET report_title = format(trim(substring(1,55,i18n_report_title)),
   "#######################################################;C;C")
 ENDIF
 FREE RECORD plan_prt
 RECORD plan_prt(
   1 plan_qual = i4
   1 hplan[*]
     2 plan_name = vc
     2 plan_type = vc
     2 plan_id = vc
     2 org_name = vc
     2 group = vc
     2 policy = vc
     2 copay = vc
     2 beg_eff_dt = vc
     2 end_eff_dt = vc
     2 person_plan_r = vc
     2 priority_seq = vc
 )
 IF (plan_num > 0)
  EXECUTE cclaudit 0, "Output Report", "Summary Sheet",
  "SYSTEM OBJECT", "REPORT", "Report",
  "REPORT", 0, "Health Plan"
 ENDIF
 SET plan_prt->plan_qual = 0
 SET stat = alterlist(plan_prt->hplan,request->plan_qual)
 SET plan_prt->plan_qual = request->plan_qual
 FOR (i = 1 TO plan_prt->plan_qual)
   SET plan_prt->hplan[i].plan_name = request->hplan[i].plan_name
   SET plan_prt->hplan[i].plan_type = request->hplan[i].plan_type
   SET plan_prt->hplan[i].plan_id = request->hplan[i].plan_id
   SET plan_prt->hplan[i].org_name = request->hplan[i].org_name
   SET plan_prt->hplan[i].group = request->hplan[i].group
   SET plan_prt->hplan[i].policy = request->hplan[i].policy
   SET plan_prt->hplan[i].copay = request->hplan[i].copay
   SET plan_prt->hplan[i].beg_eff_dt = format(cnvtdatetime(request->hplan[i].beg_eff_dt),
    "@SHORTDATE;;d")
   SET plan_prt->hplan[i].end_eff_dt = format(cnvtdatetime(request->hplan[i].end_eff_dt),
    "@SHORTDATE;;d")
   SET plan_prt->hplan[i].person_plan_r = request->hplan[i].person_plan_r
   SET plan_prt->hplan[i].priority_seq = request->hplan[i].priority_seq
 ENDFOR
 SET tcodeval = uar_get_code_by("MEANING",12004,"HEALTH PLAN")
 IF (tcodeval <= 0)
  SET operationname = "GETCODE"
  SET operationstatus = "F"
  SET targetobjectname = "UAR"
  SET targetobjectvalue = "Unable to obtain code value for meaning HEALTH PLAN"
  SET the_status = "F"
  GO TO exit_script
 ENDIF
 SET plan_heading = trim(uar_get_code_display(tcodeval))
 SET plan_heading_cont = concat(trim(plan_heading)," ",i18n_continued)
 FREE RECORD immune_prt
 RECORD immune_prt(
   1 immune_col_ct = i4
   1 immune_cols[*]
     2 col_disp = vc
     2 col_offset = i4
   1 immune_qual = i4
   1 immune[*]
     2 vaccine = vc
     2 status = vc
     2 admin_dt = vc
     2 pat_age = vc
     2 admin_person = vc
     2 ordered_by = vc
     2 admin_note = vc
 )
 IF (immune_num > 0
  AND (request->immune_col_ct=0))
  EXECUTE cclaudit 0, "Output Report", "Summary Sheet",
  "SYSTEM OBJECT", "REPORT", "Report",
  "REPORT", 0, "Immunization"
 ELSEIF (immune_num > 0
  AND (request->immune_col_ct > 0))
  EXECUTE cclaudit 0, "Output Report", "Summary Sheet",
  "SYSTEM OBJECT", "REPORT", "Report",
  "REPORT", 0, "Immunization Schedule"
 ENDIF
 SET immune_prt->immune_col_ct = 0
 SET immune_prt->immune_qual = 0
 SET stat = alterlist(immune_prt->immune,request->immune_qual)
 SET stat = alterlist(immune_prt->immune_cols,request->immune_col_ct)
 SET immune_prt->immune_col_ct = request->immune_col_ct
 SET immune_prt->immune_qual = request->immune_qual
 FOR (i = 1 TO request->immune_col_ct)
   SET immune_prt->immune_cols[i].col_disp = request->immune_cols[i].col_disp
 ENDFOR
 FOR (i = 1 TO request->immune_qual)
   SET immune_prt->immune[i].vaccine = request->immune[i].vaccine
   SET immune_prt->immune[i].status = request->immune[i].status
   SET immune_prt->immune[i].admin_dt = format(cnvtdatetime(request->immune[i].admin_dt),
    "@SHORTDATE;;d")
   SET immune_prt->immune[i].pat_age = request->immune[i].pat_age
   SET immune_prt->immune[i].admin_person = request->immune[i].admin_person
   SET immune_prt->immune[i].ordered_by = request->immune[i].ordered_by
   SET immune_prt->immune[i].admin_note = request->immune[i].admin_note
 ENDFOR
 SET tcodeval = uar_get_code_by("MEANING",12004,"IMMUNIZATION")
 IF (tcodeval <= 0)
  SET operationname = "GETCODE"
  SET operationstatus = "F"
  SET targetobjectname = "UAR"
  SET targetobjectvalue = "Unable to obtain code value for meaning IMMUNIZATION"
  SET the_status = "F"
  GO TO exit_script
 ENDIF
 SET i18n_immunization = trim(uar_get_code_display(tcodeval))
 SET i18n_immunization_cont = concat(trim(i18n_immunization)," ",i18n_continued)
 FREE RECORD immune_sched_prt
 RECORD immune_sched_prt(
   1 immune_sched_col_ct = i4
   1 immune_sched_cols[*]
     2 col_disp = vc
     2 col_offset = i4
   1 immune_sched_qual = i4
   1 immune_sched[*]
     2 vaccine_name = vc
     2 dose_nbr = vc
     2 vaccine_type = vc
     2 product = vc
     2 admin_dt = vc
     2 location = vc
     2 fuzzy_dt_ind = i2
     2 new_immune_ind = i2
 )
 IF (immune_sched_num > 0)
  EXECUTE cclaudit 0, "Output Report", "Summary Sheet",
  "SYSTEM OBJECT", "REPORT", "Report",
  "REPORT", 0, "Immunization Schedule"
 ENDIF
 SET immune_sched_prt->immune_sched_col_ct = 0
 SET stat = alterlist(immune_sched_prt->immune_sched_cols,request->immune_sched_col_ct)
 SET immune_sched_prt->immune_sched_col_ct = request->immune_sched_col_ct
 FOR (i = 1 TO request->immune_sched_col_ct)
   SET immune_sched_prt->immune_sched_cols[i].col_disp = request->immune_sched_cols[i].col_disp
 ENDFOR
 FREE RECORD immune_nonsched_prt
 RECORD immune_nonsched_prt(
   1 immune_nonsched_col_ct = i4
   1 immune_nonsched_cols[*]
     2 col_disp = vc
     2 col_offset = i4
   1 immune_nonsched_qual = i4
   1 immune_nonsched[*]
     2 dose_nbr = vc
     2 vaccine_type = vc
     2 product = vc
     2 admin_dt = vc
     2 location = vc
     2 fuzzy_dt_ind = i2
     2 new_immune_ind = i2
 )
 IF (immune_nonsched_num > 0)
  EXECUTE cclaudit 0, "Output Report", "Summary Sheet",
  "SYSTEM OBJECT", "REPORT", "Report",
  "REPORT", 0, "Immunization Schedule"
 ENDIF
 SET immune_nonsched_prt->immune_nonsched_col_ct = 0
 SET immune_nonsched_prt->immune_nonsched_qual = 0
 SET immune_nonsched_prt->immune_nonsched_col_ct = request->immune_nonsched_col_ct
 SET stat = alterlist(immune_nonsched_prt->immune_nonsched_cols,request->immune_nonsched_col_ct)
 FOR (i = 1 TO request->immune_nonsched_col_ct)
   SET immune_nonsched_prt->immune_nonsched_cols[i].col_disp = request->immune_nonsched_cols[i].
   col_disp
 ENDFOR
 SET immune_nonsched_prt->immune_nonsched_qual = request->immune_nonsched_qual
 SET stat = alterlist(immune_nonsched_prt->immune_nonsched,request->immune_nonsched_qual)
 FOR (i = 1 TO request->immune_nonsched_qual)
   CALL echo("nonsched")
   SET immune_nonsched_prt->immune_nonsched[i].dose_nbr = request->immune_nonsched[i].dose_nbr
   SET immune_nonsched_prt->immune_nonsched[i].vaccine_type = request->immune_nonsched[i].
   vaccine_type
   SET immune_nonsched_prt->immune_nonsched[i].product = request->immune_nonsched[i].product
   SET immune_nonsched_prt->immune_nonsched[i].admin_dt = request->immune_nonsched[i].admin_dt
   SET immune_nonsched_prt->immune_nonsched[i].location = request->immune_nonsched[i].location
   SET immune_nonsched_prt->immune_nonsched[i].fuzzy_dt_ind = request->immune_nonsched[i].
   fuzzy_dt_ind
   SET immune_nonsched_prt->immune_nonsched[i].new_immune_ind = request->immune_nonsched[i].
   new_immune_ind
 ENDFOR
 SET i18n_immunization_nonsched = request->immune_nonsched_title
 SET i18n_immunization_nonsched_cont = concat(trim(i18n_immunization_nonsched)," ",i18n_continued)
 FREE RECORD pat_hist_prt
 RECORD pat_hist_prt(
   1 cat_qual = i4
   1 cat[*]
     2 name = vc
     2 line_qual = i4
     2 line[*]
       3 name = vc
       3 descript = vc
       3 units = vc
       3 date = vc
       3 comment_ind = i2
 )
 IF (pat_hist_num > 0)
  EXECUTE cclaudit 0, "Output Report", "Summary Sheet",
  "SYSTEM OBJECT", "REPORT", "Report",
  "REPORT", 0, "Patient History"
 ENDIF
 SET pat_hist_prt->cat_qual = 0
 SET stat = alterlist(pat_hist_prt->cat,request->cat_qual)
 SET pat_hist_prt->cat_qual = request->cat_qual
 FOR (i = 1 TO request->cat_qual)
   SET pat_hist_prt->cat[i].name = request->cat[i].name
   SET pat_hist_prt->cat[i].line_qual = 0
   SET stat = alterlist(pat_hist_prt->cat[i].line,request->cat[i].line_qual)
   SET pat_hist_prt->cat[i].line_qual = request->cat[i].line_qual
   FOR (j = 1 TO request->cat[i].line_qual)
     SET pat_hist_prt->cat[i].line[j].name = request->cat[i].line[j].name
     SET pat_hist_prt->cat[i].line[j].descript = request->cat[i].line[j].descript
     SET pat_hist_prt->cat[i].line[j].units = request->cat[i].line[j].units
     SET pat_hist_prt->cat[i].line[j].date = format(cnvtdatetime(request->cat[i].line[j].the_date),
      "@SHORTDATE;;d")
     SET pat_hist_prt->cat[i].line[j].comment_ind = request->cat[i].line[j].comment_ind
   ENDFOR
 ENDFOR
 SET tcodeval = uar_get_code_by("MEANING",12004,"PATHIST")
 IF (tcodeval <= 0)
  SET operationname = "GETCODE"
  SET operationstatus = "F"
  SET targetobjectname = "UAR"
  SET targetobjectvalue = "Unable to obtain code value for meaning PATHIST"
  SET the_status = "F"
  GO TO exit_script
 ENDIF
 SET pat_hist_heading = trim(uar_get_code_display(tcodeval))
 SET pat_hist_heading_cont = concat(trim(pat_hist_heading)," ",i18n_continued)
 FREE RECORD med_rec
 RECORD med_rec(
   1 sec_knt = i4
   1 sec[*]
     2 name = vc
     2 item_knt = i4
     2 item[*]
       3 order_id = f8
       3 drug_name = vc
       3 item_line_knt = i4
       3 item_line[*]
         4 item_str = vc
       3 com_line_knt = i4
       3 com_line[*]
         4 com_str = vc
 )
 IF (med_profile_num > 0)
  EXECUTE cclaudit 0, "Output Report", "Summary Sheet",
  "SYSTEM OBJECT", "REPORT", "Report",
  "REPORT", 0, "Medication Profile"
 ENDIF
 SET sknt = 0
 FOR (i = 1 TO request->med_heading_knt)
   SET sknt += 1
   SET stat = alterlist(med_rec->sec,sknt)
   SET med_rec->sec[sknt].name = request->med_heading[i].heading_name
   SET iknt = 0
   FOR (j = 1 TO request->med_heading[i].med_line_knt)
     SET iknt += 1
     SET stat = alterlist(med_rec->sec[sknt].item,iknt)
     SET med_rec->sec[sknt].item[iknt].order_id = request->med_heading[i].med_line[j].order_id
     SET med_rec->sec[sknt].item[iknt].drug_name = request->med_heading[i].med_line[j].drug_name
     SET max_len = textlen(trim(request->med_heading[i].med_line[j].data))
     IF (max_len < print_line_len)
      SET lknt = 1
      SET stat = alterlist(med_rec->sec[sknt].item[iknt].item_line,lknt)
      SET med_rec->sec[sknt].item[iknt].item_line_knt = lknt
      SET med_rec->sec[sknt].item[iknt].item_line[lknt].item_str = trim(request->med_heading[i].
       med_line[j].data)
     ELSE
      SET lknt = 0
      SET continue = true
      SET cur_pos = 1
      SET cur_line_len = 0
      SET blank = " "
      WHILE (continue=true)
        SET max_line_len = print_line_len
        IF (cur_line_len < 1)
         SET cur_line_len = max_line_len
        ENDIF
        IF (substring(cur_line_len,1,trim(substring(cur_pos,max_len,trim(request->med_heading[i].
            med_line[j].data))))=blank)
         SET lknt += 1
         SET stat = alterlist(med_rec->sec[sknt].item[iknt].item_line,lknt)
         SET med_rec->sec[sknt].item[iknt].item_line[lknt].item_str = substring(cur_pos,(cur_line_len
           - 1),trim(request->med_heading[i].med_line[j].data))
         SET cur_pos += cur_line_len
         SET cur_line_len = 0
        ELSEIF (substring((cur_line_len+ 1),1,trim(substring(cur_pos,max_len,trim(request->
            med_heading[i].med_line[j].data))))=blank)
         SET lknt += 1
         SET stat = alterlist(med_rec->sec[sknt].item[iknt].item_line,lknt)
         SET med_rec->sec[sknt].item[iknt].item_line[lknt].item_str = substring(cur_pos,cur_line_len,
          trim(request->med_heading[i].med_line[j].data))
         SET cur_pos = ((cur_pos+ cur_line_len)+ 1)
         SET cur_line_len = 0
        ELSE
         SET cur_line_len -= 2
         IF ((cur_line_len < (max_line_len - 10)))
          SET lknt += 1
          SET stat = alterlist(med_rec->sec[sknt].item[iknt].item_line,lknt)
          SET med_rec->sec[sknt].item[iknt].item_line[lknt].item_str = concat(trim(substring(cur_pos,
             cur_line_len,trim(request->med_heading[i].med_line[j].data)))," ... ")
          SET cur_pos += cur_line_len
          SET cur_line_len = 0
         ENDIF
        ENDIF
        IF (cur_pos > max_len)
         SET continue = false
        ENDIF
      ENDWHILE
      SET med_rec->sec[sknt].item[iknt].item_line_knt = lknt
     ENDIF
     FOR (z = 1 TO request->med_heading[i].med_line[j].refill_knt)
       SET lknt += 1
       SET stat = alterlist(med_rec->sec[sknt].item[iknt].item_line,lknt)
       SET med_rec->sec[sknt].item[iknt].item_line_knt = lknt
       SET med_rec->sec[sknt].item[iknt].item_line[lknt].item_str = trim(concat("   ",substring(1,(
          print_line_len - 4),request->med_heading[i].med_line[j].refill[z].data)))
     ENDFOR
   ENDFOR
   SET med_rec->sec[sknt].item_knt = iknt
 ENDFOR
 SET med_rec->sec_knt = sknt
 IF ((request->med_profile_name > " "))
  SET medprofile_heading = request->med_profile_name
 ELSE
  SET tcodeval = uar_get_code_by("MEANING",12004,"MEDPROFILE")
  IF (tcodeval <= 0)
   SET operationname = "GETCODE"
   SET operationstatus = "F"
   SET targetobjectname = "UAR"
   SET targetobjectvalue = "Unable to obtain code value for meaning MEDPROFILE"
   SET the_status = "F"
   GO TO exit_script
  ENDIF
  SET medprofile_heading = trim(uar_get_code_display(tcodeval))
 ENDIF
 SET medprofile_heading_cont = concat(trim(medprofile_heading)," ",i18n_continued)
 FREE RECORD valid_req
 RECORD valid_req(
   1 force_org_security_ind = i2
   1 prsnl_id = f8
   1 persons[*]
     2 person_id = f8
   1 force_encntrs_ind = i2
   1 provider_ind = i2
   1 exclude_life_reltns[*]
     2 person_prsnl_reltn_id = f8
   1 exclude_visit_reltns[*]
     2 encntr_prsnl_reltn_id = f8
   1 include_reltn_type_cd = f8
   1 retrieve_aliases_ind = i4
 )
 SET valid_req->prsnl_id = prsnl_id
 SET stat = alterlist(valid_req->persons,1)
 SET valid_req->persons[1].person_id = person_id_num
 SET valid_req->force_encntrs_ind = 1
 FREE RECORD valid_encntr
 RECORD valid_encntr(
   1 restrict_ind = i2
   1 persons[*]
     2 person_id = f8
     2 restrict_ind = i2
     2 encntrs[*]
       3 encntr_id = f8
       3 encntr_type_cd = f8
       3 encntr_type_disp = vc
       3 encntr_type_class_cd = f8
       3 encntr_type_class_disp = vc
       3 encntr_status_cd = f8
       3 encntr_status_disp = vc
       3 reg_dt_tm = dq8
       3 pre_reg_dt_tm = dq8
       3 location_cd = f8
       3 loc_facility_cd = f8
       3 loc_facility_disp = vc
       3 loc_building_cd = f8
       3 loc_building_disp = vc
       3 loc_nurse_unit_cd = f8
       3 loc_nurse_unit_disp = vc
       3 loc_room_cd = f8
       3 loc_room_disp = vc
       3 loc_bed_cd = f8
       3 loc_bed_disp = vc
       3 reason_for_visit = vc
       3 financial_class_cd = f8
       3 financial_class_disp = vc
       3 beg_effective_dt_tm = dq8
       3 disch_dt_tm = dq8
       3 med_service_cd = f8
       3 diet_type_cd = f8
       3 isolation_cd = f8
       3 encntr_financial_id = f8
       3 arrive_dt_tm = dq8
       3 provider_list[*]
         4 provider_id = f8
         4 provider_name = vc
         4 relationship_cd = f8
         4 relationship_disp = vc
         4 relationship_mean = c12
       3 organization_id = f8
       3 time_zone_indx = i4
       3 est_arrive_dt_tm = dq8
       3 est_disch_dt_tm = dq8
       3 contributor_system_cd = f8
       3 contributor_system_disp = vc
       3 contributor_system_mean = vc
       3 loc_temp_cd = f8
       3 loc_temp_disp = vc
       3 alias_list[*]
         4 alias = vc
         4 alias_type_cd = f8
         4 alias_type_disp = vc
         4 alias_type_mean = vc
         4 alias_status_cd = f8
         4 alias_status_disp = vc
         4 alias_status_mean = vc
         4 contributor_system_cd = f8
         4 contributor_system_disp = vc
         4 contributor_system_mean = vc
       3 encntr_type_class_mean = c12
       3 encntr_status_mean = c12
       3 med_service_disp = vc
       3 isolation_disp = vc
       3 location_disp = vc
       3 diet_type_disp = vc
       3 diet_type_mean = vc
       3 inpatient_admit_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE dcp_get_valid_encounters  WITH replace(request,valid_req), replace(reply,valid_encntr)
 CALL echo("***")
 CALL echo(build("***    STATUS       :",valid_encntr->status_data.status))
 CALL echo(build("***    restrict_ind :",valid_encntr->restrict_ind))
 CALL echo(build("***    data_cnt     :",size(valid_encntr->persons[1].encntrs,5)))
 CALL echo("***")
 IF ((valid_encntr->status_data.status="F"))
  SET operationname = "SELECT"
  SET operationstatus = "F"
  SET targetobjectname = "SECURITY"
  SET targetobjectvalue = valid_encntr->status_data.subeventstatus[1].targetobjectvalue
  SET the_status = "F"
  GO TO exit_script
 ENDIF
 FREE RECORD person_data
 RECORD person_data(
   1 name = vc
   1 birth_dt_tm = dq8
   1 birth_tz = i4
   1 sex = vc
   1 street_addr = vc
   1 street_addr2 = vc
   1 street_addr3 = vc
   1 street_addr4 = vc
   1 city = vc
   1 state = vc
   1 zipcode = vc
   1 phone = vc
   1 mrn = vc
   1 pcp = vc
   1 printed_name = vc
 )
 FREE RECORD allergy_prt
 RECORD allergy_prt(
   1 allergy_qual = i4
   1 allergy[*]
     2 allergy_id = f8
     2 source_string = vc
     2 substance_ftdesc = vc
     2 severity_disp = c20
     2 onset_dt_tm = dq8
     2 onset_date = c25
     2 onset_tz = i4
     2 reaction_status_disp = c20
     2 created_prsnl_name = vc
     2 comment_ind = i2
 )
 SET allergy_prt->allergy_qual = 0
 SET stat = alterlist(allergy_prt->allergy,10)
 FREE RECORD problem_prt
 RECORD problem_prt(
   1 problem_cnt = i4
   1 problem[*]
     2 problem_id = f8
     2 source_string = vc
     2 problem_ftdesc = vc
     2 onset_dt_tm = dq8
     2 onset_date = c25
     2 onset_tz = i4
     2 recorder_name = vc
     2 responsible_name = vc
     2 life_cycle_status_disp = c20
     2 course_disp = c20
     2 comment_ind = i2
 )
 SET problem_prt->problem_cnt = 0
 SET stat = alterlist(problem_prt->problem,10)
 FREE RECORD orders_prt
 RECORD orders_prt(
   1 orders_cnt = i4
   1 orders[*]
     2 order_id = f8
     2 catalog_type_disp = c40
     2 order_status_disp = c40
     2 order_mnemonic = vc
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 provider_full_name = vc
     2 order_detail_disp = vc
     2 need_nurse_review_ind = i2
     2 need_doctor_cosign_ind = i2
     2 comment_ind = i2
     2 start_dt_tm = dq8
     2 start_tz = i4
 )
 SET orders_prt->orders_cnt = 0
 SET stat = alterlist(orders_prt->orders,10)
 FREE RECORD meds_prt
 RECORD meds_prt(
   1 meds_cnt = i4
   1 active_cnt = i4
   1 active[*]
     2 order_id = f8
     2 catalog_type_disp = c40
     2 order_status_disp = c40
     2 order_mnemonic = vc
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 provider_full_name = vc
     2 order_detail_disp = c150
     2 need_nurse_review_ind = i2
     2 need_doctor_cosign_ind = i2
   1 prn_cnt = i4
   1 prn[*]
     2 order_id = f8
     2 catalog_type_disp = c40
     2 order_status_disp = c40
     2 order_mnemonic = vc
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 provider_full_name = vc
     2 order_detail_disp = vc
     2 need_nurse_review_ind = i2
     2 need_doctor_cosign_ind = i2
   1 suspended_cnt = i4
   1 suspended[*]
     2 order_id = f8
     2 catalog_type_disp = c40
     2 order_status_disp = c40
     2 order_mnemonic = vc
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 provider_full_name = vc
     2 order_detail_disp = vc
     2 need_nurse_review_ind = i2
     2 need_doctor_cosign_ind = i2
   1 past_cnt = i4
   1 past[*]
     2 order_id = f8
     2 catalog_type_disp = c40
     2 order_status_disp = c40
     2 order_mnemonic = vc
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 provider_full_name = vc
     2 order_detail_disp = vc
     2 need_nurse_review_ind = i2
     2 need_doctor_cosign_ind = i2
 )
 SET meds_prt->meds_cnt = 0
 SET meds_prt->active_cnt = 0
 SET meds_prt->prn_cnt = 0
 SET meds_prt->suspended_cnt = 0
 SET meds_prt->past_cnt = 0
 SET stat = alterlist(meds_prt->active,10)
 SET stat = alterlist(meds_prt->prn,10)
 SET stat = alterlist(meds_prt->suspended,10)
 SET stat = alterlist(meds_prt->past,10)
 FREE RECORD encounter_prt
 RECORD encounter_prt(
   1 encounter_qual = i4
   1 encounter[*]
     2 encntr_id = f8
     2 encntr_type_disp = vc
     2 beg_effective_dt_tm = dq8
     2 beg_effective_tz = i4
     2 provider = vc
     2 reason_for_visit = vc
     2 loc_facility_disp = vc
     2 disch_dt_tm = dq8
     2 disch_tz = i4
 )
 SET encounter_prt->encounter_qual = 0
 SET stat = alterlist(encounter_prt->encounter,10)
 FREE RECORD proc_hist_prt
 RECORD proc_hist_prt(
   1 proc_qual = i4
   1 proc[*]
     2 procedure_id = f8
     2 procedure = vc
     2 active_ind = i2
     2 date = vc
     2 provider = vc
     2 location = vc
     2 comment_ind = i2
 )
 SET proc_hist_prt->proc_qual = 0
 SET stat = alterlist(proc_hist_prt->proc,10)
 CALL echo("***")
 CALL echo("***   LOAD DEMOGRAPHICS")
 CALL echo("***")
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET home_add_cd = 0.0
 SET code_set = 212
 SET cdf_meaning = "HOME"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,home_add_cd)
 IF (home_add_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.person_id, a.beg_effective_dt_tm
  FROM person p,
   address a
  PLAN (p
   WHERE p.person_id=person_id_num)
   JOIN (a
   WHERE (a.parent_entity_id= Outerjoin(p.person_id))
    AND (a.parent_entity_name= Outerjoin("PERSON"))
    AND (a.address_type_cd= Outerjoin(home_add_cd))
    AND (a.active_ind= Outerjoin(1))
    AND (a.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (a.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY a.beg_effective_dt_tm DESC
  HEAD p.person_id
   person_data->name = p.name_full_formatted, person_data->birth_dt_tm = p.birth_dt_tm, person_data->
   birth_tz = p.birth_tz,
   person_data->sex = uar_get_code_display(p.sex_cd), person_data->street_addr = a.street_addr,
   person_data->street_addr2 = a.street_addr2,
   person_data->street_addr3 = a.street_addr3, person_data->street_addr4 = a.street_addr4,
   person_data->city = a.city
   IF (a.state_cd > 0)
    person_data->state = uar_get_code_display(a.state_cd)
   ELSE
    person_data->state = a.state
   ENDIF
   person_data->zipcode = a.zipcode
  WITH nocounter
 ;end select
 SET home_phone_cd = 0.0
 SET code_set = 43
 SET cdf_meaning = "HOME"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,home_phone_cd)
 IF (home_phone_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.beg_effective_dt_tm
  FROM phone p
  PLAN (p
   WHERE p.parent_entity_id=person_id_num
    AND p.parent_entity_name="PERSON"
    AND p.phone_type_cd=home_phone_cd
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY p.beg_effective_dt_tm DESC
  HEAD REPORT
   person_data->phone = trim(cnvtphone(cnvtalphanum(p.phone_num),p.phone_format_cd))
  WITH nocounter
 ;end select
 SET pmrn_cd = 0.0
 SET code_set = 4
 SET cdf_meaning = "MRN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,pmrn_cd)
 IF (pmrn_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET emrn_cd = 0.0
 SET code_set = 319
 SET cdf_meaning = "MRN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,emrn_cd)
 IF (pmrn_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 IF ((((request->organization_id > 0.0)) OR ((request->encntr_id > 0.0))) )
  IF ((request->organization_id=0.0)
   AND (request->encntr_id > 0.0))
   SELECT INTO "nl:"
    e.organization_id
    FROM encounter e
    WHERE (e.encntr_id=request->encntr_id)
    HEAD REPORT
     request->organization_id = e.organization_id
    WITH nocounter
   ;end select
  ENDIF
  FREE RECORD temprec
  RECORD temprec(
    1 list[*]
      2 alias_pool_cd = f8
  )
  SET lcnt = 0
  SET ltotal = 0
  SELECT INTO "nl:"
   o.organization_id
   FROM org_alias_pool_reltn o
   WHERE (o.organization_id=request->organization_id)
    AND o.alias_entity_alias_type_cd=pmrn_cd
    AND o.alias_entity_name="PERSON_ALIAS"
    AND o.active_ind=1
    AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND o.end_effective_dt_tm > cnvtdatetime(sysdate)
   HEAD REPORT
    stat = alterlist(temprec->list,10)
   DETAIL
    lcnt += 1
    IF (lcnt > 10
     AND mod(lcnt,10)=1)
     stat = alterlist(temprec->list,(lcnt+ 9))
    ENDIF
    temprec->list[lcnt].alias_pool_cd = o.alias_pool_cd
   FOOT REPORT
    stat = alterlist(temprec->list,lcnt)
   WITH nocounter
  ;end select
  IF (lcnt > 0)
   SET idx = 0
   SELECT INTO "nl:"
    pa.alias, pa.alias_pool_cd, pa.beg_effective_dt_tm
    FROM person_alias pa,
     alias_pool ap
    PLAN (pa
     WHERE (pa.person_id=request->person_id)
      AND pa.person_alias_type_cd=pmrn_cd
      AND expand(idx,1,lcnt,pa.alias_pool_cd,temprec->list[idx].alias_pool_cd)
      AND pa.active_ind=1
      AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (ap
     WHERE ap.alias_pool_cd=pa.alias_pool_cd
      AND ap.active_ind=1
      AND ap.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ap.end_effective_dt_tm > cnvtdatetime(sysdate))
    ORDER BY pa.beg_effective_dt_tm DESC
    HEAD REPORT
     IF (pa.alias_pool_cd > 0)
      person_data->mrn = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
     ELSE
      person_data->mrn = trim(pa.alias)
     ENDIF
    WITH nocounter
   ;end select
  ELSEIF ((request->encntr_id > 0.0))
   SELECT INTO "nl:"
    ea.alias, ea.alias_pool_cd, ea.beg_effective_dt_tm
    FROM encntr_alias ea
    WHERE (ea.encntr_id=request->encntr_id)
     AND ea.encntr_alias_type_cd=emrn_cd
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    ORDER BY ea.beg_effective_dt_tm DESC
    HEAD REPORT
     IF (ea.alias_pool_cd > 0)
      person_data->mrn = trim(cnvtalias(ea.alias,ea.alias_pool_cd))
     ELSE
      person_data->mrn = trim(ea.alias)
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    pa.alias, pa.alias_pool_cd, pa.beg_effective_dt_tm
    FROM person_alias pa
    WHERE (pa.person_id=request->person_id)
     AND pa.person_alias_type_cd=pmrn_cd
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
    ORDER BY pa.beg_effective_dt_tm DESC
    HEAD REPORT
     IF (pa.alias_pool_cd > 0)
      person_data->mrn = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
     ELSE
      person_data->mrn = trim(pa.alias)
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (trim(person_data->mrn)="")
  SELECT INTO "nl:"
   pa.alias, pa.alias_pool_cd, pa.beg_effective_dt_tm
   FROM person_alias pa
   WHERE (pa.person_id=request->person_id)
    AND pa.person_alias_type_cd=pmrn_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
   ORDER BY pa.beg_effective_dt_tm DESC
   HEAD REPORT
    IF (pa.alias_pool_cd > 0)
     person_data->mrn = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
    ELSE
     person_data->mrn = trim(pa.alias)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 DECLARE pcp_var = f8 WITH public, noconstant(0.0)
 SET pcp_var = uar_get_code_by("MEANING",331,"PCP")
 IF (pcp_var <= 0.0)
  SET operationname = "GETCODE"
  SET operationstatus = "F"
  SET targetobjectname = "UAR"
  SET targetobjectvalue = "Unable to obtain code value for meaning PCP from Code Set 331"
  SET the_status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  pcp = p.name_full_formatted
  FROM person_prsnl_reltn ppr,
   prsnl p
  PLAN (ppr
   WHERE ppr.person_id=person_id_num
    AND ppr.person_prsnl_r_cd=pcp_var
    AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ppr.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND ((ppr.active_ind+ 0)=1))
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
  ORDER BY ppr.updt_dt_tm DESC
  HEAD REPORT
   person_data->pcp = pcp
  DETAIL
   x = 1
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  p.name_full_formatted
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
  DETAIL
   person_data->printed_name = substring(1,50,p.name_full_formatted)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode > 0
  AND substring(1,10,errmsg) != "%CCL-W-261")
  SET operationname = "GENERATE"
  SET operationstatus = "F"
  SET targetobjectname = "PERSON_INFO"
  SET targetobjectvalue = errmsg
  SET the_status = "F"
  GO TO exit_script
 ENDIF
 IF (allergy_num > 0)
  CALL echo("***")
  CALL echo("***   LOAD ALLERGIES")
  CALL echo("***")
  EXECUTE cclaudit 0, "Output Report", "Summary Sheet",
  "SYSTEM OBJECT", "REPORT", "Report",
  "REPORT", 0, "Allergy Profile"
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  FREE RECORD treply
  RECORD treply(
    1 allergy_qual = i4
    1 allergy[*]
      2 allergy_id = f8
      2 encntr_id = f8
      2 organization_id = f8
      2 viewable_ind = i2
      2 nomenclature_id = f8
      2 source_string = vc
      2 substance_ftdesc = vc
      2 severity_cd = f8
      2 severity_disp = c40
      2 onset_precision_flag = i2
      2 onset_dt_tm = dq8
      2 onset_tz = i4
      2 reaction_status_cd = f8
      2 reaction_status_disp = c40
      2 created_prsnl_id = f8
      2 created_prsnl_name = vc
      2 comment_qual = i4
      2 adr_knt = i4
      2 adr[*]
        3 reltn_entity_name = vc
        3 reltn_entity_id = f8
  )
  SELECT INTO "nl:"
   a.allergy_id
   FROM allergy a,
    nomenclature n,
    allergy_comment ac,
    prsnl p
   PLAN (a
    WHERE a.person_id=person_id_num
     AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND a.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (n
    WHERE n.nomenclature_id=a.substance_nom_id)
    JOIN (p
    WHERE p.person_id=a.created_prsnl_id)
    JOIN (ac
    WHERE (ac.allergy_id= Outerjoin(a.allergy_id))
     AND (ac.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
     AND (ac.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
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
    treply->allergy[knt].nomenclature_id = n.nomenclature_id, treply->allergy[knt].source_string = n
    .source_string, treply->allergy[knt].substance_ftdesc = a.substance_ftdesc,
    treply->allergy[knt].severity_cd = a.severity_cd, treply->allergy[knt].onset_dt_tm = a
    .onset_dt_tm, treply->allergy[knt].onset_tz = a.onset_tz,
    treply->allergy[knt].onset_precision_flag = a.onset_precision_flag, treply->allergy[knt].
    reaction_status_cd = a.reaction_status_cd, treply->allergy[knt].created_prsnl_id = a
    .created_prsnl_id,
    treply->allergy[knt].created_prsnl_name = p.name_full_formatted, cknt = 0
   DETAIL
    IF (ac.allergy_comment_id > 0)
     cknt += 1
    ENDIF
   FOOT  a.allergy_id
    treply->allergy[knt].comment_qual = cknt
   FOOT REPORT
    treply->allergy_qual = knt, stat = alterlist(treply->allergy,knt)
   WITH nocounter
  ;end select
  IF ((treply->allergy_qual > 0))
   IF (bpersonorgsecurityon=true)
    SELECT INTO "nl:"
     FROM activity_data_reltn adr
     PLAN (adr
      WHERE expand(eidx,1,treply->allergy_qual,adr.activity_entity_id,treply->allergy[eidx].
       allergy_id)
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
       treply->allergy[fidx].adr[knt].reltn_entity_name = adr.reltn_entity_name, treply->allergy[fidx
       ].adr[knt].reltn_entity_id = adr.reltn_entity_id
      ENDIF
     FOOT  adr.activity_entity_id
      treply->allergy[fidx].adr_knt = knt, stat = alterlist(treply->allergy[fidx].adr,knt)
     WITH nocounter
    ;end select
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
         SET access_granted = btest(prsnl_orgs->org_set[osknt].access_priv,algy_bit_pos)
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
         SET continue = true
         SET oknt = 1
         WHILE (continue=true
          AND (oknt <= prsnl_orgs->org_knt)
          AND (treply->allergy[vidx].viewable_ind < 1))
          IF ((treply->allergy[vidx].adr[ridx].reltn_entity_name="ORGANIZATION")
           AND (treply->allergy[vidx].adr[ridx].reltn_entity_id=prsnl_orgs->org[oknt].organization_id
          ))
           SET treply->allergy[vidx].viewable_ind = 2
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
            SET access_granted = btest(prsnl_orgs->org_set[osknt].access_priv,algy_bit_pos)
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
   SET act_react_cd = 0.0
   SET act_stat_cd = 0.0
   SET code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET code_set = 12025
   SET cdf_meaning = "CANCELED"
   EXECUTE cpm_get_cd_for_cdf
   SET canceled_react_cd = code_value
   SET code_set = 48
   SET cdf_meaning = "ACTIVE"
   SET code_value = 0.0
   EXECUTE cpm_get_cd_for_cdf
   SET act_stat_cd = code_value
   CALL echo("***")
   CALL echo(build("***   algy_exp->priv_value_cd :",algy_exp->priv_value_cd))
   CALL echo(build("***   algy_exp->priv_value_cd :",uar_get_code_meaning(algy_exp->priv_value_cd)))
   CALL echo(build("***   algy_exp->exception_knt :",algy_exp->exception_knt))
   CALL echo("***")
   IF (uar_get_code_meaning(algy_exp->priv_value_cd)="NO")
    GO TO exit_allergy_section
   ENDIF
   IF ((((((algy_exp->priv_value_cd < 1)) OR (uar_get_code_meaning(algy_exp->priv_value_cd)="YES")) )
    OR (uar_get_code_meaning(algy_exp->priv_value_cd)="EXCLUDE"
    AND (algy_exp->exception_knt < 1))) )
    SELECT INTO "nl:"
     allergy_id = treply->allergy[d.seq].allergy_id, onset_dt_tm = treply->allergy[d.seq].onset_dt_tm
     FROM (dummyt d  WITH seq = value(size(treply->allergy,5)))
     PLAN (d
      WHERE d.seq > 0
       AND (treply->allergy[d.seq].reaction_status_cd != canceled_react_cd)
       AND (treply->allergy[d.seq].viewable_ind > 0))
     ORDER BY onset_dt_tm DESC
     HEAD REPORT
      count1 = 0
     DETAIL
      count1 += 1
      IF (size(allergy_prt->allergy,5) <= count1)
       stat = alterlist(allergy_prt->allergy,(count1+ 10))
      ENDIF
      allergy_prt->allergy[count1].allergy_id = allergy_id
      IF (textlen(treply->allergy[d.seq].source_string) > 38)
       allergy_prt->allergy[count1].source_string = concat(substring(1,35,treply->allergy[d.seq].
         source_string),"...")
      ELSE
       allergy_prt->allergy[count1].source_string = treply->allergy[d.seq].source_string
      ENDIF
      IF (textlen(treply->allergy[d.seq].substance_ftdesc) > 38)
       allergy_prt->allergy[count1].substance_ftdesc = concat(substring(1,35,treply->allergy[d.seq].
         substance_ftdesc),"...")
      ELSE
       allergy_prt->allergy[count1].substance_ftdesc = treply->allergy[d.seq].substance_ftdesc
      ENDIF
      allergy_prt->allergy[count1].severity_disp = uar_get_code_display(treply->allergy[d.seq].
       severity_cd), allergy_prt->allergy[count1].onset_dt_tm = onset_dt_tm, onset_tz = treply->
      allergy[d.seq].onset_tz
      IF (onset_tz < 1)
       onset_tz = curtimezoneapp
      ENDIF
      CASE (treply->allergy[d.seq].onset_precision_flag)
       OF 40:
        allergy_prt->allergy[count1].onset_date = datetimezoneformat(onset_dt_tm,onset_tz,"MM/yyyy")
       OF 50:
        allergy_prt->allergy[count1].onset_date = datetimezoneformat(onset_dt_tm,onset_tz,"yyyy")
       OF 60:
        IF ((treply->allergy[d.seq].onset_tz < 1))
         allergy_prt->allergy[count1].onset_date = datetimezoneformat(onset_dt_tm,onset_tz,
          "@SHORTDATETIMENOSEC")
        ELSE
         allergy_prt->allergy[count1].onset_date = trim(concat(trim(datetimezoneformat(onset_dt_tm,
             onset_tz,"@SHORTDATETIMENOSEC"))," ",trim(datetimezoneformat(onset_dt_tm,onset_tz,"ZZZ")
            )))
        ENDIF
       ELSE
        allergy_prt->allergy[count1].onset_date = datetimezoneformat(onset_dt_tm,onset_tz,
         "@SHORTDATE")
      ENDCASE
      IF (textlen(trim(allergy_prt->allergy[count1].onset_date)) > 19)
       allergy_prt->allergy[count1].onset_date = concat(substring(1,16,allergy_prt->allergy[count1].
         onset_date),"...")
      ENDIF
      allergy_prt->allergy[count1].reaction_status_disp = uar_get_code_display(treply->allergy[d.seq]
       .reaction_status_cd)
      IF ((treply->allergy[d.seq].viewable_ind=1))
       IF (textlen(treply->allergy[d.seq].created_prsnl_name) > 23)
        allergy_prt->allergy[count1].created_prsnl_name = concat(substring(1,20,treply->allergy[d.seq
          ].created_prsnl_name),"...")
       ELSE
        allergy_prt->allergy[count1].created_prsnl_name = treply->allergy[d.seq].created_prsnl_name
       ENDIF
      ELSE
       allergy_prt->allergy[count1].created_prsnl_name = " "
      ENDIF
      allergy_prt->allergy[count1].comment_ind = treply->allergy[d.seq].comment_qual
     FOOT REPORT
      allergy_prt->allergy_qual = count1, stat = alterlist(allergy_prt->allergy,count1)
     WITH nocounter
    ;end select
   ELSE
    IF (uar_get_code_meaning(algy_exp->priv_value_cd)="INCLUDE")
     IF ((algy_exp->exception_knt > 0))
      SELECT INTO "nl:"
       allergy_id = treply->allergy[d.seq].allergy_id, onset_dt_tm = treply->allergy[d.seq].
       onset_dt_tm
       FROM (dummyt d  WITH seq = value(size(treply->allergy,5))),
        (dummyt d2  WITH seq = value(algy_exp->exception_knt))
       PLAN (d2
        WHERE d2.seq > 0)
        JOIN (d
        WHERE (treply->allergy[d.seq].nomenclature_id=algy_exp->exception[d2.seq].exp_id)
         AND (treply->allergy[d.seq].reaction_status_cd != canceled_react_cd)
         AND (treply->allergy[d.seq].viewable_ind > 0))
       ORDER BY onset_dt_tm DESC
       HEAD REPORT
        count1 = 0
       DETAIL
        count1 += 1
        IF (size(allergy_prt->allergy,5) <= count1)
         stat = alterlist(allergy_prt->allergy,(count1+ 10))
        ENDIF
        allergy_prt->allergy[count1].allergy_id = allergy_id
        IF (textlen(treply->allergy[d.seq].source_string) > 38)
         allergy_prt->allergy[count1].source_string = concat(substring(1,35,treply->allergy[d.seq].
           source_string),"...")
        ELSE
         allergy_prt->allergy[count1].source_string = treply->allergy[d.seq].source_string
        ENDIF
        IF (textlen(treply->allergy[d.seq].substance_ftdesc) > 38)
         allergy_prt->allergy[count1].substance_ftdesc = concat(substring(1,35,treply->allergy[d.seq]
           .substance_ftdesc),"...")
        ELSE
         allergy_prt->allergy[count1].substance_ftdesc = treply->allergy[d.seq].substance_ftdesc
        ENDIF
        allergy_prt->allergy[count1].severity_disp = uar_get_code_display(treply->allergy[d.seq].
         severity_cd), allergy_prt->allergy[count1].onset_dt_tm = onset_dt_tm, onset_tz = treply->
        allergy[d.seq].onset_tz
        IF (onset_tz < 1)
         onset_tz = curtimezoneapp
        ENDIF
        CASE (treply->allergy[d.seq].onset_precision_flag)
         OF 40:
          allergy_prt->allergy[count1].onset_date = datetimezoneformat(onset_dt_tm,onset_tz,"MM/yyyy"
           )
         OF 50:
          allergy_prt->allergy[count1].onset_date = datetimezoneformat(onset_dt_tm,onset_tz,"yyyy")
         OF 60:
          IF ((treply->allergy[d.seq].onset_tz < 1))
           allergy_prt->allergy[count1].onset_date = datetimezoneformat(onset_dt_tm,onset_tz,
            "@SHORTDATETIMENOSEC")
          ELSE
           allergy_prt->allergy[count1].onset_date = trim(concat(trim(datetimezoneformat(onset_dt_tm,
               onset_tz,"@SHORTDATETIMENOSEC"))," ",trim(datetimezoneformat(onset_dt_tm,onset_tz,
               "ZZZ"))))
          ENDIF
         ELSE
          allergy_prt->allergy[count1].onset_date = datetimezoneformat(onset_dt_tm,onset_tz,
           "@SHORTDATE")
        ENDCASE
        IF (textlen(trim(allergy_prt->allergy[count1].onset_date)) > 19)
         allergy_prt->allergy[count1].onset_date = concat(substring(1,16,allergy_prt->allergy[count1]
           .onset_date),"...")
        ENDIF
        allergy_prt->allergy[count1].reaction_status_disp = uar_get_code_display(treply->allergy[d
         .seq].reaction_status_cd)
        IF ((treply->allergy[d.seq].viewable_ind=1))
         IF (textlen(treply->allergy[d.seq].created_prsnl_name) > 23)
          allergy_prt->allergy[count1].created_prsnl_name = concat(substring(1,20,treply->allergy[d
            .seq].created_prsnl_name),"...")
         ELSE
          allergy_prt->allergy[count1].created_prsnl_name = treply->allergy[d.seq].created_prsnl_name
         ENDIF
        ELSE
         allergy_prt->allergy[count1].created_prsnl_name = " "
        ENDIF
        allergy_prt->allergy[count1].comment_ind = treply->allergy[d.seq].comment_qual
       FOOT REPORT
        allergy_prt->allergy_qual = count1, stat = alterlist(allergy_prt->allergy,count1)
       WITH nocounter
      ;end select
     ELSE
      GO TO exit_allergy_section
     ENDIF
    ELSEIF (uar_get_code_meaning(algy_exp->priv_value_cd)="EXCLUDE")
     SELECT INTO "nl:"
      allergy_id = treply->allergy[d.seq].allergy_id, onset_dt_tm = treply->allergy[d.seq].
      onset_dt_tm
      FROM (dummyt d  WITH seq = value(size(treply->allergy,5))),
       (dummyt d2  WITH seq = value(algy_exp->exception_knt))
      PLAN (d
       WHERE d.seq > 0
        AND (treply->allergy[d.seq].reaction_status_cd != canceled_react_cd)
        AND (treply->allergy[d.seq].viewable_ind > 0))
       JOIN (d2
       WHERE (algy_exp->exception[d2.seq].exp_id=treply->allergy[d.seq].nomenclature_id))
      ORDER BY onset_dt_tm DESC
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 += 1
       IF (size(allergy_prt->allergy,5) <= count1)
        stat = alterlist(allergy_prt->allergy,(count1+ 10))
       ENDIF
       allergy_prt->allergy[count1].allergy_id = allergy_id
       IF (textlen(treply->allergy[d.seq].source_string) > 38)
        allergy_prt->allergy[count1].source_string = concat(substring(1,35,treply->allergy[d.seq].
          source_string),"...")
       ELSE
        allergy_prt->allergy[count1].source_string = treply->allergy[d.seq].source_string
       ENDIF
       IF (textlen(treply->allergy[d.seq].substance_ftdesc) > 38)
        allergy_prt->allergy[count1].substance_ftdesc = concat(substring(1,35,treply->allergy[d.seq].
          substance_ftdesc),"...")
       ELSE
        allergy_prt->allergy[count1].substance_ftdesc = treply->allergy[d.seq].substance_ftdesc
       ENDIF
       allergy_prt->allergy[count1].severity_disp = uar_get_code_display(treply->allergy[d.seq].
        severity_cd), allergy_prt->allergy[count1].onset_dt_tm = onset_dt_tm, onset_tz = treply->
       allergy[d.seq].onset_tz
       IF (onset_tz < 1)
        onset_tz = curtimezoneapp
       ENDIF
       CASE (treply->allergy[d.seq].onset_precision_flag)
        OF 40:
         allergy_prt->allergy[count1].onset_date = datetimezoneformat(onset_dt_tm,onset_tz,"MM/yyyy")
        OF 50:
         allergy_prt->allergy[count1].onset_date = datetimezoneformat(onset_dt_tm,onset_tz,"yyyy")
        OF 60:
         IF ((treply->allergy[d.seq].onset_tz < 1))
          allergy_prt->allergy[count1].onset_date = datetimezoneformat(onset_dt_tm,onset_tz,
           "@SHORTDATETIMENOSEC")
         ELSE
          allergy_prt->allergy[count1].onset_date = trim(concat(trim(datetimezoneformat(onset_dt_tm,
              onset_tz,"@SHORTDATETIMENOSEC"))," ",trim(datetimezoneformat(onset_dt_tm,onset_tz,"ZZZ"
              ))))
         ENDIF
        ELSE
         allergy_prt->allergy[count1].onset_date = datetimezoneformat(onset_dt_tm,onset_tz,
          "@SHORTDATE")
       ENDCASE
       IF (textlen(trim(allergy_prt->allergy[count1].onset_date)) > 19)
        allergy_prt->allergy[count1].onset_date = concat(substring(1,16,allergy_prt->allergy[count1].
          onset_date),"...")
       ENDIF
       allergy_prt->allergy[count1].reaction_status_disp = uar_get_code_display(treply->allergy[d.seq
        ].reaction_status_cd)
       IF ((treply->allergy[d.seq].viewable_ind=1))
        IF (textlen(treply->allergy[d.seq].created_prsnl_name) > 23)
         allergy_prt->allergy[count1].created_prsnl_name = concat(substring(1,20,treply->allergy[d
           .seq].created_prsnl_name),"...")
        ELSE
         allergy_prt->allergy[count1].created_prsnl_name = treply->allergy[d.seq].created_prsnl_name
        ENDIF
       ELSE
        allergy_prt->allergy[count1].created_prsnl_name = " "
       ENDIF
       allergy_prt->allergy[count1].comment_ind = treply->allergy[d.seq].comment_qual
      FOOT REPORT
       allergy_prt->allergy_qual = count1, stat = alterlist(allergy_prt->allergy,count1)
      WITH nocounter, outerjoin = d, dontexist
     ;end select
    ENDIF
   ENDIF
  ENDIF
  FREE SET treply
  SET errcode = error(errmsg,1)
  IF (errcode > 0
   AND substring(1,10,errmsg) != "%CCL-W-261")
   SET operationname = "GENERATE"
   SET operationstatus = "F"
   SET targetobjectname = "ALLERGY_INFO"
   SET targetobjectvalue = errmsg
   SET the_status = "F"
   GO TO exit_script
  ENDIF
  SET allergy_cnt = allergy_prt->allergy_qual
 ENDIF
 SET tcodeval = uar_get_code_by("MEANING",12004,"ALLERGY")
 IF (tcodeval <= 0)
  SET operationname = "GETCODE"
  SET operationstatus = "F"
  SET targetobjectname = "UAR"
  SET targetobjectvalue = "Unable to obtain code value for meaning ALLERGY"
  SET the_status = "F"
  GO TO exit_script
 ENDIF
 SET allergy_heading = trim(uar_get_code_display(tcodeval))
 SET allergy_heading_cont = concat(trim(allergy_heading)," ",i18n_continued)
 IF (problem_num > 0)
  CALL echo("***")
  CALL echo("***   LOAD PROBLEMS")
  CALL echo("***")
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE cclaudit 0, "Output Report", "Summary Sheet",
  "SYSTEM OBJECT", "REPORT", "Report",
  "REPORT", 0, "Problem List"
  FREE SET treply
  RECORD treply(
    1 problem[*]
      2 problem_id = f8
      2 nomenclature_id = f8
      2 organization_id = f8
      2 viewable_ind = i2
      2 source_string = vc
      2 problem_ftdesc = vc
      2 life_cycle_status_cd = f8
      2 onset_dt_tm = dq8
      2 onset_tz = i4
      2 course_cd = f8
      2 comment_ind = i2
      2 problem_reltn_prsnl_id = f8
      2 problem_prsnl_full_name = vc
      2 respon_prsnl_id = f8
      2 respon_prsnl_name = vc
  )
  DECLARE prob_record_cd = f8 WITH constant(uar_get_code_by("MEANING",12038,"RECORDER")), protect
  DECLARE prob_repons_cd = f8 WITH constant(uar_get_code_by("MEANING",12038,"RESPONSIBLE")), protect
  SELECT INTO "nl:"
   p.problem_id
   FROM problem p,
    nomenclature n
   PLAN (p
    WHERE p.person_id=person_id_num
     AND p.problem_id > 0
     AND ((p.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
     AND ((p.end_effective_dt_tm+ 0) > cnvtdatetime(sysdate)))
    JOIN (n
    WHERE n.nomenclature_id=p.nomenclature_id)
   HEAD REPORT
    knt = 0, stat = alterlist(treply->problem,10)
   DETAIL
    IF (knt > 0
     AND (p.problem_id=treply->problem[knt].problem_id))
     knt = knt
    ELSE
     knt += 1
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(treply->problem,(knt+ 9))
     ENDIF
     treply->problem[knt].problem_id = p.problem_id, treply->problem[knt].organization_id = p
     .organization_id
     IF (p.organization_id=0.0)
      treply->problem[knt].viewable_ind = 1
     ENDIF
     treply->problem[knt].nomenclature_id = p.nomenclature_id, treply->problem[knt].source_string = n
     .source_string, treply->problem[knt].problem_ftdesc = p.problem_ftdesc,
     treply->problem[knt].life_cycle_status_cd = p.life_cycle_status_cd, treply->problem[knt].
     onset_dt_tm = p.onset_dt_tm, treply->problem[knt].onset_tz = p.onset_tz,
     treply->problem[knt].course_cd = p.course_cd
    ENDIF
   FOOT REPORT
    stat = alterlist(treply->problem,knt)
   WITH nocounter
  ;end select
  IF (size(treply->problem,5) > 0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(treply->problem,5))),
     problem_comment pc
    PLAN (d1
     WHERE d1.seq > 0)
     JOIN (pc
     WHERE (pc.problem_id=treply->problem[d1.seq].problem_id)
      AND pc.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND pc.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND pc.active_ind=1)
    HEAD d1.seq
     treply->problem[d1.seq].comment_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(treply->problem,5))),
     problem_prsnl_r ppr,
     prsnl pr
    PLAN (d
     WHERE d.seq > 0)
     JOIN (ppr
     WHERE (ppr.problem_id=treply->problem[d.seq].problem_id)
      AND ppr.problem_reltn_cd IN (prob_record_cd, prob_repons_cd)
      AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
      AND ppr.active_ind=1)
     JOIN (pr
     WHERE pr.person_id=ppr.problem_reltn_prsnl_id)
    HEAD REPORT
     found_recorder = false, found_respon = false
    HEAD d.seq
     found_recorder = false, found_respon = false
    DETAIL
     IF (ppr.problem_reltn_cd=prob_record_cd
      AND found_recorder=false)
      found_recorder = true, treply->problem[d.seq].problem_reltn_prsnl_id = ppr
      .problem_reltn_prsnl_id, treply->problem[d.seq].problem_prsnl_full_name = pr
      .name_full_formatted
     ENDIF
     IF (ppr.problem_reltn_cd=prob_repons_cd
      AND found_respon=false)
      found_respon = true, treply->problem[d.seq].respon_prsnl_id = ppr.problem_reltn_prsnl_id,
      treply->problem[d.seq].respon_prsnl_name = pr.name_full_formatted
     ENDIF
    WITH nocounter
   ;end select
   SET cancelled_cd = 0.0
   SET code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET code_set = 12030
   SET cdf_meaning = "CANCELED"
   EXECUTE cpm_get_cd_for_cdf
   SET cancelled_cd = code_value
   IF (bpersonorgsecurityon=true)
    FOR (vidx = 1 TO size(treply->problem,5))
      SET continue = true
      SET oknt = 1
      WHILE (continue=true
       AND (oknt <= prsnl_orgs->org_knt)
       AND (treply->problem[vidx].viewable_ind < 1))
       IF ((treply->problem[vidx].organization_id=prsnl_orgs->org[oknt].organization_id))
        SET treply->problem[vidx].viewable_ind = 1
        SET continue = false
       ENDIF
       SET oknt += 1
      ENDWHILE
      IF ((treply->problem[vidx].viewable_ind < 1))
       SET osknt = 1
       SET continue = true
       WHILE (continue=true
        AND (osknt <= prsnl_orgs->org_set_knt))
         SET oknt = 1
         SET access_granted = false
         SET access_granted = btest(prsnl_orgs->org_set[osknt].access_priv,prob_bit_pos)
         WHILE (continue=true
          AND (oknt <= prsnl_orgs->org_set[osknt].org_list_knt)
          AND access_granted=true)
          IF ((treply->problem[vidx].organization_id=prsnl_orgs->org_set[osknt].org_list[oknt].
          organization_id))
           SET treply->problem[vidx].viewable_ind = 1
           SET continue = false
          ENDIF
          SET oknt += 1
         ENDWHILE
         SET osknt = (oknt+ 1)
       ENDWHILE
      ENDIF
    ENDFOR
   ELSE
    FOR (vidx = 1 TO size(treply->problem,5))
      SET treply->problem[vidx].viewable_ind = 1
    ENDFOR
   ENDIF
   CALL echo("***")
   CALL echo(build("***   prob_exp->priv_value_cd :",prob_exp->priv_value_cd))
   CALL echo(build("***   prob_exp->priv_value_cd :",uar_get_code_meaning(prob_exp->priv_value_cd)))
   CALL echo(build("***   prob_exp->exception_knt :",prob_exp->exception_knt))
   CALL echo("***")
   IF ((((((prob_exp->priv_value_cd < 1)) OR (uar_get_code_meaning(prob_exp->priv_value_cd)="YES")) )
    OR (uar_get_code_meaning(prob_exp->priv_value_cd)="EXCLUDE"
    AND (prob_exp->exception_knt < 1))) )
    SELECT INTO "NL:"
     problem_id = treply->problem[d.seq].problem_id, source_string = substring(1,60,treply->problem[d
      .seq].source_string), problem_ftdesc = substring(1,60,treply->problem[d.seq].problem_ftdesc),
     onset_dt_tm = treply->problem[d.seq].onset_dt_tm, onset_tz = treply->problem[d.seq].onset_tz,
     recorder_name = substring(1,25,treply->problem[d.seq].problem_prsnl_full_name),
     responsible_name = substring(1,25,treply->problem[d.seq].respon_prsnl_name),
     life_cycle_status_disp = uar_get_code_display(treply->problem[d.seq].life_cycle_status_cd),
     course_disp = uar_get_code_display(treply->problem[d.seq].course_cd),
     comment_ind = treply->problem[d.seq].comment_ind
     FROM (dummyt d  WITH seq = value(size(treply->problem,5)))
     PLAN (d
      WHERE d.seq > 0
       AND (((treply->problem[d.seq].source_string > " ")) OR ((treply->problem[d.seq].problem_ftdesc
       > " ")))
       AND (treply->problem[d.seq].life_cycle_status_cd != cancelled_cd)
       AND (treply->problem[d.seq].viewable_ind > 0))
     ORDER BY life_cycle_status_disp, onset_dt_tm DESC
     HEAD REPORT
      count1 = 0
     DETAIL
      count1 += 1
      IF (size(problem_prt->problem,5) <= count1)
       stat = alterlist(problem_prt->problem,(count1+ 10))
      ENDIF
      problem_prt->problem[count1].problem_id = problem_id, problem_prt->problem[count1].
      source_string = source_string, problem_prt->problem[count1].problem_ftdesc = problem_ftdesc,
      problem_prt->problem[count1].onset_dt_tm = onset_dt_tm
      IF ((treply->problem[d.seq].onset_tz < 1))
       problem_prt->problem[count1].onset_date = datetimezoneformat(onset_dt_tm,curtimezoneapp,
        "MM/dd/yy")
      ELSE
       problem_prt->problem[count1].onset_date = datetimezoneformat(onset_dt_tm,onset_tz,"MM/dd/yy")
      ENDIF
      problem_prt->problem[count1].recorder_name = recorder_name, problem_prt->problem[count1].
      responsible_name = responsible_name, problem_prt->problem[count1].life_cycle_status_disp =
      life_cycle_status_disp,
      problem_prt->problem[count1].course_disp = course_disp, problem_prt->problem[count1].
      comment_ind = comment_ind
     FOOT REPORT
      problem_prt->problem_cnt = count1, stat = alterlist(problem_prt->problem,count1)
     WITH nocounter
    ;end select
   ELSE
    IF (uar_get_code_meaning(prob_exp->priv_value_cd)="NO")
     GO TO exit_problem_section
    ENDIF
    IF (uar_get_code_meaning(prob_exp->priv_value_cd)="INCLUDE")
     IF ((prob_exp->exception_knt > 0))
      SELECT INTO "NL:"
       problem_id = treply->problem[d.seq].problem_id, source_string = substring(1,60,treply->
        problem[d.seq].source_string), problem_ftdesc = substring(1,60,treply->problem[d.seq].
        problem_ftdesc),
       onset_dt_tm = treply->problem[d.seq].onset_dt_tm, onset_tz = treply->problem[d.seq].onset_tz,
       recorder_name = substring(1,25,treply->problem[d.seq].problem_prsnl_full_name),
       responsible_name = substring(1,25,treply->problem[d.seq].respon_prsnl_name),
       life_cycle_status_disp = uar_get_code_display(treply->problem[d.seq].life_cycle_status_cd),
       course_disp = uar_get_code_display(treply->problem[d.seq].course_cd),
       comment_ind = treply->problem[d.seq].comment_ind
       FROM (dummyt d  WITH seq = value(size(treply->problem,5))),
        (dummyt d2  WITH seq = value(prob_exp->exception_knt))
       PLAN (d2
        WHERE d2.seq > 0
         AND (prob_exp->exception[d2.seq].exp_id > 0))
        JOIN (d
        WHERE (treply->problem[d.seq].nomenclature_id=prob_exp->exception[d2.seq].exp_id)
         AND (((treply->problem[d.seq].source_string > " ")) OR ((treply->problem[d.seq].
        problem_ftdesc > " ")))
         AND (treply->problem[d.seq].life_cycle_status_cd != cancelled_cd)
         AND (treply->problem[d.seq].viewable_ind > 0))
       ORDER BY life_cycle_status_disp, onset_dt_tm DESC
       HEAD REPORT
        count1 = 0
       DETAIL
        count1 += 1
        IF (size(problem_prt->problem,5) <= count1)
         stat = alterlist(problem_prt->problem,(count1+ 10))
        ENDIF
        problem_prt->problem[count1].problem_id = problem_id, problem_prt->problem[count1].
        source_string = source_string, problem_prt->problem[count1].problem_ftdesc = problem_ftdesc,
        problem_prt->problem[count1].onset_dt_tm = onset_dt_tm
        IF ((treply->problem[d.seq].onset_tz < 1))
         problem_prt->problem[count1].onset_date = datetimezoneformat(onset_dt_tm,curtimezoneapp,
          "MM/dd/yy")
        ELSE
         problem_prt->problem[count1].onset_date = datetimezoneformat(onset_dt_tm,onset_tz,"MM/dd/yy"
          )
        ENDIF
        problem_prt->problem[count1].recorder_name = recorder_name, problem_prt->problem[count1].
        responsible_name = responsible_name, problem_prt->problem[count1].life_cycle_status_disp =
        life_cycle_status_disp,
        problem_prt->problem[count1].course_disp = course_disp, problem_prt->problem[count1].
        comment_ind = comment_ind
       FOOT REPORT
        problem_prt->problem_cnt = count1, stat = alterlist(problem_prt->problem,count1)
       WITH nocounter
      ;end select
     ELSE
      GO TO exit_problem_section
     ENDIF
    ELSEIF (uar_get_code_meaning(prob_exp->priv_value_cd)="EXCLUDE")
     SELECT INTO "NL:"
      problem_id = treply->problem[d.seq].problem_id, source_string = substring(1,60,treply->problem[
       d.seq].source_string), problem_ftdesc = substring(1,60,treply->problem[d.seq].problem_ftdesc),
      onset_dt_tm = treply->problem[d.seq].onset_dt_tm, onset_tz = treply->problem[d.seq].onset_tz,
      recorder_name = substring(1,25,treply->problem[d.seq].problem_prsnl_full_name),
      responsible_name = substring(1,25,treply->problem[d.seq].respon_prsnl_name),
      life_cycle_status_disp = uar_get_code_display(treply->problem[d.seq].life_cycle_status_cd),
      course_disp = uar_get_code_display(treply->problem[d.seq].course_cd),
      comment_ind = treply->problem[d.seq].comment_ind
      FROM (dummyt d  WITH seq = value(size(treply->problem,5))),
       (dummyt d2  WITH seq = value(prob_exp->exception_knt))
      PLAN (d
       WHERE (((treply->problem[d.seq].source_string > " ")) OR ((treply->problem[d.seq].
       problem_ftdesc > " ")))
        AND (treply->problem[d.seq].life_cycle_status_cd != cancelled_cd)
        AND (treply->problem[d.seq].viewable_ind > 0))
       JOIN (d2
       WHERE (prob_exp->exception[d2.seq].exp_id=treply->problem[d.seq].nomenclature_id))
      ORDER BY life_cycle_status_disp, onset_dt_tm DESC
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 += 1
       IF (size(problem_prt->problem,5) <= count1)
        stat = alterlist(problem_prt->problem,(count1+ 10))
       ENDIF
       problem_prt->problem[count1].problem_id = problem_id, problem_prt->problem[count1].
       source_string = source_string, problem_prt->problem[count1].problem_ftdesc = problem_ftdesc,
       problem_prt->problem[count1].onset_dt_tm = onset_dt_tm
       IF ((treply->problem[d.seq].onset_tz < 1))
        problem_prt->problem[count1].onset_date = datetimezoneformat(onset_dt_tm,curtimezoneapp,
         "MM/dd/yy")
       ELSE
        problem_prt->problem[count1].onset_date = datetimezoneformat(onset_dt_tm,onset_tz,"MM/dd/yy")
       ENDIF
       problem_prt->problem[count1].recorder_name = recorder_name, problem_prt->problem[count1].
       responsible_name = responsible_name, problem_prt->problem[count1].life_cycle_status_disp =
       life_cycle_status_disp,
       problem_prt->problem[count1].course_disp = course_disp, problem_prt->problem[count1].
       comment_ind = comment_ind
      FOOT REPORT
       problem_prt->problem_cnt = count1, stat = alterlist(problem_prt->problem,count1)
      WITH nocounter, outerjoin = d, dontexist
     ;end select
    ENDIF
   ENDIF
  ENDIF
  FREE SET treply
  SET errcode = error(errmsg,1)
  IF (errcode > 0
   AND substring(1,10,errmsg) != "%CCL-W-261")
   SET operationname = "GENERATE"
   SET operationstatus = "F"
   SET targetobjectname = "PROBLEM_INFO"
   SET targetobjectvalue = errmsg
   SET the_status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_problem_section
 SET problem_cnt = problem_prt->problem_cnt
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET tcodeval = uar_get_code_by("MEANING",12004,"PROBLEM")
 IF (tcodeval <= 0)
  SET operationname = "GETCODE"
  SET operationstatus = "F"
  SET targetobjectname = "UAR"
  SET targetobjectvalue = "Unable to obtain code value for meaning PROBLEM"
  SET the_status = "F"
  GO TO exit_script
 ENDIF
 SET problem_heading = trim(uar_get_code_display(tcodeval))
 SET problem_heading_cont = concat(trim(problem_heading)," ",i18n_continued)
 IF (orders_num > 0)
  CALL echo("***")
  CALL echo("***   LOAD ORDERS")
  CALL echo("***")
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE cclaudit 0, "Output Report", "Summary Sheet",
  "SYSTEM OBJECT", "REPORT", "Report",
  "REPORT", 0, "Order Profile"
  FREE SET treply
  RECORD treply(
    1 qual_cnt = i4
    1 qual[*]
      2 order_id = f8
      2 encntr_id = f8
      2 organization_id = f8
      2 viewable_ind = i2
      2 catalog_type_cd = f8
      2 order_status_cd = f8
      2 order_mnemonic = vc
      2 orig_order_dt_tm = dq8
      2 provider_full_name = vc
      2 order_detail_display_line = vc
      2 order_comment_ind = i2
      2 need_nurse_review_ind = i2
      2 need_doctor_cosign_ind = i2
      2 current_start_dt_tm = dq8
  )
  DECLARE pharm_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY")), protect
  SELECT INTO "nl:"
   o.order_id, o.order_status_cd, o.orig_order_dt_tm,
   e.organization_id
   FROM orders o,
    prsnl p,
    encounter e
   PLAN (o
    WHERE o.person_id=person_id_num
     AND o.catalog_type_cd != pharm_type_cd
     AND o.active_ind=1)
    JOIN (p
    WHERE p.person_id=o.last_update_provider_id)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
   ORDER BY cnvtdatetime(o.orig_order_dt_tm) DESC
   HEAD REPORT
    knt = 0, stat = alterlist(treply->qual,10)
   DETAIL
    knt += 1
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(treply->qual,(knt+ 9))
    ENDIF
    treply->qual[knt].order_id = o.order_id, treply->qual[knt].encntr_id = o.encntr_id, treply->qual[
    knt].organization_id = e.organization_id,
    treply->qual[knt].catalog_type_cd = o.catalog_type_cd, treply->qual[knt].order_status_cd = o
    .order_status_cd, treply->qual[knt].order_mnemonic = o.ordered_as_mnemonic,
    treply->qual[knt].orig_order_dt_tm = o.orig_order_dt_tm, treply->qual[knt].provider_full_name = p
    .name_full_formatted, treply->qual[knt].order_detail_display_line = o.clinical_display_line,
    treply->qual[knt].order_comment_ind = o.order_comment_ind, treply->qual[knt].
    need_nurse_review_ind = o.need_nurse_review_ind, treply->qual[knt].need_doctor_cosign_ind = o
    .need_doctor_cosign_ind,
    treply->qual[knt].current_start_dt_tm = o.current_start_dt_tm
   FOOT REPORT
    treply->qual_cnt = knt, stat = alterlist(treply->qual,knt)
   WITH nocounter
  ;end select
  SET code_value = 0.0
  SET code_set = 6004
  SET cdf_meaning = "CANCELED"
  EXECUTE cpm_get_cd_for_cdf
  SET canceled_cd = code_value
  IF ((treply->qual_cnt > 0))
   SELECT DISTINCT INTO "NL:"
    order_id = treply->qual[d.seq].order_id, catalog_type_disp = substring(1,12,uar_get_code_display(
      treply->qual[d.seq].catalog_type_cd)), order_status_disp = substring(1,5,uar_get_code_display(
      treply->qual[d.seq].order_status_cd)),
    order_mnemonic = substring(1,15,treply->qual[d.seq].order_mnemonic), orig_order_dt_tm = treply->
    qual[d.seq].orig_order_dt_tm, provider_full_name = substring(1,17,treply->qual[d.seq].
     provider_full_name),
    order_detail_display_line = substring(1,40,treply->qual[d.seq].order_detail_display_line),
    need_nurse_review_ind = treply->qual[d.seq].need_nurse_review_ind, need_doctor_cosign_ind =
    treply->qual[d.seq].need_doctor_cosign_ind,
    comment_ind = treply->qual[d.seq].order_comment_ind, start_dt_tm = treply->qual[d.seq].
    current_start_dt_tm
    FROM (dummyt d  WITH seq = value(treply->qual_cnt))
    PLAN (d
     WHERE d.seq > 0
      AND (treply->qual[d.seq].order_status_cd != canceled_cd))
    ORDER BY catalog_type_disp, order_status_disp, orig_order_dt_tm DESC,
     order_id
    HEAD REPORT
     knt = 0, stat = alterlist(orders_prt->orders,1)
    DETAIL
     IF (order_id > 0)
      knt += 1
      IF (mod(knt,10)=1)
       stat = alterlist(orders_prt->orders,(knt+ 9))
      ENDIF
      orders_prt->orders[knt].order_id = order_id, orders_prt->orders[knt].catalog_type_disp =
      catalog_type_disp, orders_prt->orders[knt].order_status_disp = order_status_disp,
      orders_prt->orders[knt].order_mnemonic = order_mnemonic, orders_prt->orders[knt].
      orig_order_dt_tm = orig_order_dt_tm, orders_prt->orders[knt].provider_full_name =
      provider_full_name,
      orders_prt->orders[knt].order_detail_disp = order_detail_display_line, orders_prt->orders[knt].
      need_nurse_review_ind = need_nurse_review_ind, orders_prt->orders[knt].need_doctor_cosign_ind
       = need_doctor_cosign_ind,
      orders_prt->orders[knt].comment_ind = comment_ind, orders_prt->orders[knt].start_dt_tm =
      start_dt_tm
     ENDIF
    FOOT REPORT
     orders_prt->orders_cnt = knt, stat = alterlist(orders_prt->orders,knt)
    WITH nocounter
   ;end select
  ENDIF
  FREE SET treply
  SET errcode = error(errmsg,1)
  IF (errcode > 0
   AND substring(1,10,errmsg) != "%CCL-W-261")
   SET operationname = "GENERATE"
   SET operationstatus = "F"
   SET targetobjectname = "ORDERS_INFO"
   SET targetobjectvalue = errmsg
   SET the_status = "F"
   GO TO exit_script
  ENDIF
  SET orders_cnt = orders_prt->orders_cnt
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  SET tcodeval = uar_get_code_by("MEANING",12004,"ORDERS")
  IF (tcodeval <= 0)
   SET operationname = "GETCODE"
   SET operationstatus = "F"
   SET targetobjectname = "UAR"
   SET targetobjectvalue = "Unable to obtain code value for meaning ORDERS"
   SET the_status = "F"
   GO TO exit_script
  ENDIF
  SET orders_heading = trim(uar_get_code_display(tcodeval))
  SET orders_heading_cont = concat(trim(orders_heading)," ",i18n_continued)
 ENDIF
 IF (encounter_num > 0)
  CALL echo("***")
  CALL echo("***   LOAD ENCOUNTERS")
  CALL echo("***")
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE cclaudit 0, "Output Report", "Summary Sheet",
  "SYSTEM OBJECT", "REPORT", "Report",
  "REPORT", 0, "Encounter"
  FREE SET treply
  RECORD treply(
    1 encounter_qual = i4
    1 encounter[*]
      2 encntr_id = f8
      2 encntr_type_cd = f8
      2 reg_dt_tm = dq8
      2 loc_facility_cd = f8
      2 reason_for_visit = vc
      2 disch_dt_tm = dq8
      2 provider_name = vc
  )
  DECLARE encntr_canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",261,"CANCELLED")), protect
  DECLARE attenddoc_cd = f8 WITH constant(uar_get_code_by("MEANING",333,"ATTENDDOC")), protect
  DECLARE admitdoc_cd = f8 WITH constant(uar_get_code_by("MEANING",333,"ADMITDOC")), protect
  DECLARE orderdoc_cd = f8 WITH constant(uar_get_code_by("MEANING",333,"ORDERDOC")), protect
  DECLARE referdoc_cd = f8 WITH constant(uar_get_code_by("MEANING",333,"REFERDOC")), protect
  DECLARE user_tz = i4 WITH noconstant(0), protect
  IF (curutc > 0)
   SET user_tz = curtimezoneapp
  ELSE
   SET user_tz = 0
  ENDIF
  SELECT INTO "nl:"
   e.encntr_id, e.reg_dt_tm
   FROM encounter e
   PLAN (e
    WHERE e.person_id=person_id_num
     AND e.encntr_status_cd != encntr_canceled_cd
     AND e.active_ind=1)
   ORDER BY cnvtdatetime(e.reg_dt_tm) DESC, e.encntr_id
   HEAD REPORT
    knt = 0, stat = alterlist(treply->encounter,10)
   DETAIL
    knt += 1
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(treply->encounter,(knt+ 9))
    ENDIF
    treply->encounter[knt].encntr_id = e.encntr_id, treply->encounter[knt].encntr_type_cd = e
    .encntr_type_cd, treply->encounter[knt].reg_dt_tm = e.reg_dt_tm,
    treply->encounter[knt].loc_facility_cd = e.loc_facility_cd, treply->encounter[knt].
    reason_for_visit = e.reason_for_visit, treply->encounter[knt].disch_dt_tm = e.disch_dt_tm
   FOOT REPORT
    treply->encounter_qual = knt, stat = alterlist(treply->encounter,knt)
   WITH nocounter
  ;end select
  IF ((treply->encounter_qual > 0))
   SELECT INTO "nl:"
    d.seq, epr.beg_effective_dt_tm
    FROM (dummyt d  WITH seq = value(treply->encounter_qual)),
     encntr_prsnl_reltn epr,
     prsnl p
    PLAN (d
     WHERE d.seq > 0)
     JOIN (epr
     WHERE (epr.encntr_id=treply->encounter[d.seq].encntr_id)
      AND epr.encntr_prsnl_r_cd IN (attenddoc_cd, admitdoc_cd, orderdoc_cd, referdoc_cd)
      AND epr.active_ind=1
      AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (p
     WHERE p.person_id=epr.prsnl_person_id
      AND ((p.physician_ind+ 0)=1))
    ORDER BY d.seq, epr.beg_effective_dt_tm DESC
    HEAD d.seq
     rank_found = 5
    DETAIL
     IF (rank_found > 1)
      IF (epr.encntr_prsnl_r_cd=attenddoc_cd)
       treply->encounter[d.seq].provider_name = p.name_full_formatted, rank_found = 1
      ENDIF
      IF (rank_found > 2)
       IF (epr.encntr_prsnl_r_cd=admitdoc_cd)
        treply->encounter[d.seq].provider_name = p.name_full_formatted, rank_found = 2
       ENDIF
       IF (rank_found > 3)
        IF (epr.encntr_prsnl_r_cd=orderdoc_cd)
         treply->encounter[d.seq].provider_name = p.name_full_formatted, rank_found = 3
        ENDIF
        IF (rank_found > 4)
         IF (epr.encntr_prsnl_r_cd=referdoc_cd)
          treply->encounter[d.seq].provider_name = p.name_full_formatted, rank_found = 3
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET dvar = 0
   IF ((((valid_encntr->restrict_ind > 0)
    AND size(valid_encntr->persons[1].encntrs,5) > 0) OR ((valid_encntr->restrict_ind < 1))) )
    SELECT
     IF ((valid_encntr->restrict_ind < 1))
      FROM (dummyt d  WITH seq = value(size(treply->encounter,5)))
      PLAN (d
       WHERE d.seq > 0)
     ELSE
      FROM (dummyt d  WITH seq = value(size(treply->encounter,5))),
       (dummyt d2  WITH seq = value(size(valid_encntr->persons[1].encntrs,5)))
      PLAN (d2
       WHERE d2.seq > 0)
       JOIN (d
       WHERE (treply->encounter[d.seq].encntr_id=valid_encntr->persons[1].encntrs[d2.seq].encntr_id))
     ENDIF
     DISTINCT INTO "NL:"
     encntr_id = treply->encounter[d.seq].encntr_id, encntr_type_disp = substring(1,12,
      uar_get_code_display(treply->encounter[d.seq].encntr_type_cd)), beg_effective_dt_tm = treply->
     encounter[d.seq].reg_dt_tm,
     provider = substring(1,30,treply->encounter[d.seq].provider_name), reason_for_visit = substring(
      1,30,treply->encounter[d.seq].reason_for_visit), loc_facility_disp = substring(1,30,
      uar_get_code_display(treply->encounter[d.seq].loc_facility_cd)),
     disch_dt_tm = treply->encounter[d.seq].disch_dt_tm
     ORDER BY beg_effective_dt_tm DESC, encntr_id
     HEAD REPORT
      knt = 0, stat = alterlist(encounter_prt->encounter,10)
     HEAD encntr_id
      knt += 1
      IF (mod(knt,10)=1
       AND knt != 1)
       stat = alterlist(encounter_prt->encounter,(knt+ 9))
      ENDIF
      encounter_prt->encounter[knt].encntr_id = encntr_id, encounter_prt->encounter[knt].
      encntr_type_disp = encntr_type_disp, encounter_prt->encounter[knt].beg_effective_dt_tm =
      beg_effective_dt_tm,
      encounter_prt->encounter[knt].beg_effective_tz = user_tz, encounter_prt->encounter[knt].
      provider = provider, encounter_prt->encounter[knt].reason_for_visit = reason_for_visit,
      encounter_prt->encounter[knt].loc_facility_disp = loc_facility_disp, encounter_prt->encounter[
      knt].disch_dt_tm = disch_dt_tm, encounter_prt->encounter[knt].disch_tz = user_tz
     DETAIL
      dvar = 0
     FOOT REPORT
      encounter_prt->encounter_qual = knt, stat = alterlist(encounter_prt->encounter,knt)
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  FREE SET treply
  SET errcode = error(errmsg,1)
  IF (errcode > 0
   AND substring(1,10,errmsg) != "%CCL-W-261")
   SET operationname = "GENERATE"
   SET operationstatus = "F"
   SET targetobjectname = "ENCOUNTER_INFO"
   SET targetobjectvalue = errmsg
   SET the_status = "F"
   GO TO exit_script
  ENDIF
  SET encounter_cnt = encounter_prt->encounter_qual
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  SET tcodeval = uar_get_code_by("MEANING",12004,"ENCOUNTER")
  IF (tcodeval <= 0)
   SET operationname = "GETCODE"
   SET operationstatus = "F"
   SET targetobjectname = "UAR"
   SET targetobjectvalue = "Unable to obtain code value for meaning ENCOUNTER"
   SET the_status = "F"
   GO TO exit_script
  ENDIF
  SET encounter_heading = trim(uar_get_code_display(tcodeval))
  SET encounter_heading_cont = concat(trim(encounter_heading)," ",i18n_continued)
 ENDIF
 IF (proc_hist_num > 0)
  CALL echo("***")
  CALL echo("***   LOAD PROCEDURE HISTORY")
  CALL echo("***")
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE cclaudit 0, "Output Report", "Summary Sheet",
  "SYSTEM OBJECT", "REPORT", "Report",
  "REPORT", 0, "Procedure History"
  FREE RECORD treply
  RECORD treply(
    1 proc_cnt = i2
    1 proc_list[*]
      2 procedure_id = f8
      2 organization_id = f8
      2 viewable_ind = i2
      2 nomenclature_id = f8
      2 active_ind = i2
      2 encntr_id = f8
      2 source_string = vc
      2 proc_dt_tm = dq8
      2 proc_ft_time_frame = vc
      2 proc_prsnl_id = f8
      2 proc_prsnl_name = vc
      2 proc_ft_prsnl = vc
      2 proc_loc_cd = f8
      2 proc_ft_loc = vc
      2 comment_ind = i2
  )
  SELECT
   IF (bencntrorgsecurityon=true)
    PLAN (e
     WHERE expand(eidx,1,size(valid_encntr->persons[1].encntrs,5),e.encntr_id,valid_encntr->persons[1
      ].encntrs[eidx].encntr_id)
      AND e.active_ind=1)
     JOIN (p
     WHERE p.encntr_id=e.encntr_id)
     JOIN (n
     WHERE n.nomenclature_id=p.nomenclature_id)
     JOIN (ppr
     WHERE ((ppr.procedure_id=p.procedure_id) OR (ppr.proc_prsnl_reltn_id=0)) )
     JOIN (pr
     WHERE ((pr.person_id=ppr.prsnl_person_id) OR (pr.person_id=0)) )
   ELSE
    PLAN (e
     WHERE e.person_id=person_id_num
      AND e.active_ind=1)
     JOIN (p
     WHERE p.encntr_id=e.encntr_id)
     JOIN (n
     WHERE n.nomenclature_id=p.nomenclature_id)
     JOIN (ppr
     WHERE (ppr.procedure_id= Outerjoin(p.procedure_id)) )
     JOIN (pr
     WHERE (pr.person_id= Outerjoin(ppr.prsnl_person_id)) )
   ENDIF
   INTO "nl:"
   p.procedure_id, ppr.beg_effective_dt_tm
   FROM encounter e,
    procedure p,
    nomenclature n,
    proc_prsnl_reltn ppr,
    prsnl pr
   ORDER BY p.procedure_id, ppr.beg_effective_dt_tm DESC
   HEAD REPORT
    knt = 0, stat = alterlist(treply->proc_list,10)
   HEAD p.procedure_id
    knt += 1
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(treply->proc_list,(knt+ 9))
    ENDIF
    treply->proc_list[knt].procedure_id = p.procedure_id, treply->proc_list[knt].nomenclature_id = p
    .nomenclature_id, treply->proc_list[knt].organization_id = e.organization_id
    IF (e.organization_id=0.0)
     treply->proc_list[knt].viewable_ind = 1
    ENDIF
    treply->proc_list[knt].active_ind = p.active_ind, treply->proc_list[knt].encntr_id = p.encntr_id
    IF (n.nomenclature_id > 0)
     treply->proc_list[knt].source_string = n.source_string
    ELSE
     treply->proc_list[knt].source_string = p.proc_ftdesc
    ENDIF
    treply->proc_list[knt].proc_dt_tm = p.proc_dt_tm, treply->proc_list[knt].proc_ft_time_frame = p
    .proc_ft_time_frame, treply->proc_list[knt].proc_prsnl_id = ppr.prsnl_person_id
    IF (ppr.prsnl_person_id > 0)
     treply->proc_list[knt].proc_prsnl_name = pr.name_full_formatted
    ELSE
     treply->proc_list[knt].proc_prsnl_name = ppr.proc_ft_prsnl, treply->proc_list[knt].proc_ft_prsnl
      = ppr.proc_ft_prsnl
    ENDIF
    treply->proc_list[knt].proc_loc_cd = p.proc_loc_cd, treply->proc_list[knt].proc_ft_loc = p
    .proc_ft_loc, treply->proc_list[knt].comment_ind = p.comment_ind
   FOOT REPORT
    treply->proc_cnt = knt, stat = alterlist(treply->proc_list,knt)
   WITH nocounter
  ;end select
  CALL echo(" ")
  CALL echo(build("treply->proc_cnt :",treply->proc_cnt))
  CALL echo(" ")
  IF ((treply->proc_cnt < 1))
   SET proc_hist_prt->proc_qual = 0
   SET stat = alterlist(proc_hist_prt->proc,proc_hist_prt->proc_qual)
   GO TO exit_proc_section
  ENDIF
  CALL echo("***")
  CALL echo(build("***   proc_exp->priv_value_cd :",proc_exp->priv_value_cd))
  CALL echo(build("***   proc_exp->priv_value_cd :",uar_get_code_meaning(proc_exp->priv_value_cd)))
  CALL echo(build("***   proc_exp->exception_knt :",proc_exp->exception_knt))
  CALL echo("***")
  IF (uar_get_code_meaning(proc_exp->priv_value_cd)="NO")
   GO TO exit_proc_section
  ENDIF
  IF ((((((proc_exp->priv_value_cd < 1)) OR (uar_get_code_meaning(proc_exp->priv_value_cd)="YES")) )
   OR (uar_get_code_meaning(proc_exp->priv_value_cd)="EXCLUDE"
   AND (proc_exp->exception_knt < 1))) )
   SELECT INTO "nl:"
    procedure_id = treply->proc_list[d.seq].procedure_id, comment_ind = treply->proc_list[d.seq].
    comment_ind, proc_loc_disp = uar_get_code_display(treply->proc_list[d.seq].proc_loc_cd)
    FROM (dummyt d  WITH seq = value(treply->proc_cnt))
    PLAN (d
     WHERE d.seq > 0)
    ORDER BY procedure_id DESC
    HEAD REPORT
     knt = 0, stat = alterlist(proc_hist_prt->proc,10)
    DETAIL
     knt += 1
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(proc_hist_prt->proc,(knt+ 9))
     ENDIF
     proc_hist_prt->proc[knt].procedure_id = procedure_id, proc_hist_prt->proc[knt].procedure =
     treply->proc_list[d.seq].source_string, proc_hist_prt->proc[knt].active_ind = treply->proc_list[
     d.seq].active_ind,
     proc_hist_prt->proc[knt].comment_ind = treply->proc_list[d.seq].comment_ind
     IF ((treply->proc_list[d.seq].proc_ft_time_frame > " "))
      proc_hist_prt->proc[knt].date = treply->proc_list[d.seq].proc_ft_time_frame
     ELSEIF ((treply->proc_list[d.seq].proc_dt_tm > 0))
      proc_hist_prt->proc[knt].date = format(cnvtdatetime(treply->proc_list[d.seq].proc_dt_tm),
       "mm/dd/yy;;d")
     ELSE
      proc_hist_prt->proc[knt].date = " "
     ENDIF
     IF ((treply->proc_list[d.seq].proc_ft_prsnl > " "))
      proc_hist_prt->proc[knt].provider = treply->proc_list[d.seq].proc_ft_prsnl
     ELSE
      proc_hist_prt->proc[knt].provider = treply->proc_list[d.seq].proc_prsnl_name
     ENDIF
     IF ((treply->proc_list[d.seq].proc_loc_cd > 0))
      proc_hist_prt->proc[knt].location = proc_loc_disp
     ELSE
      proc_hist_prt->proc[knt].location = treply->proc_list[d.seq].proc_ft_loc
     ENDIF
    FOOT REPORT
     proc_hist_prt->proc_qual = knt, stat = alterlist(proc_hist_prt->proc,knt)
    WITH nocounter
   ;end select
  ELSEIF (uar_get_code_meaning(proc_exp->priv_value_cd)="INCLUDE")
   IF ((proc_exp->exception_knt > 0))
    SELECT INTO "nl:"
     procedure_id = treply->proc_list[d.seq].procedure_id, comment_ind = treply->proc_list[d.seq].
     comment_ind, proc_loc_disp = uar_get_code_display(treply->proc_list[d.seq].proc_loc_cd)
     FROM (dummyt d  WITH seq = value(treply->proc_cnt)),
      (dummyt d2  WITH seq = value(proc_exp->exception_knt))
     PLAN (d2
      WHERE d2.seq > 0
       AND (proc_exp->exception[d2.seq].exp_id > 0))
      JOIN (d
      WHERE (treply->proc_list[d.seq].nomenclature_id=proc_exp->exception[d2.seq].exp_id))
     ORDER BY procedure_id DESC
     HEAD REPORT
      knt = 0, stat = alterlist(proc_hist_prt->proc,10)
     DETAIL
      knt += 1
      IF (mod(knt,10)=1
       AND knt != 1)
       stat = alterlist(proc_hist_prt->proc,(knt+ 9))
      ENDIF
      proc_hist_prt->proc[knt].procedure_id = procedure_id, proc_hist_prt->proc[knt].procedure =
      treply->proc_list[d.seq].source_string, proc_hist_prt->proc[knt].active_ind = treply->
      proc_list[d.seq].active_ind,
      proc_hist_prt->proc[knt].comment_ind = treply->proc_list[d.seq].comment_ind
      IF ((treply->proc_list[d.seq].proc_ft_time_frame > " "))
       proc_hist_prt->proc[knt].date = treply->proc_list[d.seq].proc_ft_time_frame
      ELSEIF ((treply->proc_list[d.seq].proc_dt_tm > 0))
       proc_hist_prt->proc[knt].date = format(cnvtdatetime(treply->proc_list[d.seq].proc_dt_tm),
        "mm/dd/yy;;d")
      ELSE
       proc_hist_prt->proc[knt].date = " "
      ENDIF
      IF ((treply->proc_list[d.seq].proc_ft_prsnl > " "))
       proc_hist_prt->proc[knt].provider = treply->proc_list[d.seq].proc_ft_prsnl
      ELSE
       proc_hist_prt->proc[knt].provider = treply->proc_list[d.seq].proc_prsnl_name
      ENDIF
      IF ((treply->proc_list[d.seq].proc_loc_cd > 0))
       proc_hist_prt->proc[knt].location = proc_loc_disp
      ELSE
       proc_hist_prt->proc[knt].location = treply->proc_list[d.seq].proc_ft_loc
      ENDIF
     FOOT REPORT
      proc_hist_prt->proc_qual = knt, stat = alterlist(proc_hist_prt->proc,knt)
     WITH nocounter
    ;end select
   ELSE
    GO TO exit_proc_section
   ENDIF
  ELSEIF (uar_get_code_meaning(proc_exp->priv_value_cd)="EXCLUDE")
   SELECT INTO "nl:"
    procedure_id = treply->proc_list[d.seq].procedure_id, comment_ind = treply->proc_list[d.seq].
    comment_ind, proc_loc_disp = uar_get_code_display(treply->proc_list[d.seq].proc_loc_cd)
    FROM (dummyt d  WITH seq = value(treply->proc_cnt)),
     (dummyt d2  WITH seq = value(proc_exp->exception_knt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (d2
     WHERE (proc_exp->exception[d2.seq].exp_id=treply->proc_list[d.seq].nomenclature_id))
    ORDER BY procedure_id DESC
    HEAD REPORT
     knt = 0, stat = alterlist(proc_hist_prt->proc,10)
    DETAIL
     knt += 1
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(proc_hist_prt->proc,(knt+ 9))
     ENDIF
     proc_hist_prt->proc[knt].procedure_id = procedure_id, proc_hist_prt->proc[knt].procedure =
     treply->proc_list[d.seq].source_string, proc_hist_prt->proc[knt].active_ind = treply->proc_list[
     d.seq].active_ind,
     proc_hist_prt->proc[knt].comment_ind = treply->proc_list[d.seq].comment_ind
     IF ((treply->proc_list[d.seq].proc_ft_time_frame > " "))
      proc_hist_prt->proc[knt].date = treply->proc_list[d.seq].proc_ft_time_frame
     ELSEIF ((treply->proc_list[d.seq].proc_dt_tm > 0))
      proc_hist_prt->proc[knt].date = format(cnvtdatetime(treply->proc_list[d.seq].proc_dt_tm),
       "mm/dd/yy;;d")
     ELSE
      proc_hist_prt->proc[knt].date = " "
     ENDIF
     IF ((treply->proc_list[d.seq].proc_ft_prsnl > " "))
      proc_hist_prt->proc[knt].provider = treply->proc_list[d.seq].proc_ft_prsnl
     ELSE
      proc_hist_prt->proc[knt].provider = treply->proc_list[d.seq].proc_prsnl_name
     ENDIF
     IF ((treply->proc_list[d.seq].proc_loc_cd > 0))
      proc_hist_prt->proc[knt].location = proc_loc_disp
     ELSE
      proc_hist_prt->proc[knt].location = treply->proc_list[d.seq].proc_ft_loc
     ENDIF
    FOOT REPORT
     proc_hist_prt->proc_qual = knt, stat = alterlist(proc_hist_prt->proc,knt)
    WITH nocounter, outerjoin = d, dontexist
   ;end select
  ENDIF
  FREE SET treply
  SET errcode = error(errmsg,1)
  IF (errcode > 0
   AND substring(1,10,errmsg) != "%CCL-W-261")
   SET operationname = "GENERATE"
   SET operationstatus = "F"
   SET targetobjectname = "PROCEDURE_INFO"
   SET targetobjectvalue = errmsg
   SET the_status = "F"
   GO TO exit_script
  ENDIF
  SET proc_cnt = proc_hist_prt->proc_qual
 ENDIF
#exit_proc_section
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET tcodeval = uar_get_code_by("MEANING",12004,"PROCHIST")
 IF (tcodeval <= 0)
  SET operationname = "GETCODE"
  SET operationstatus = "F"
  SET targetobjectname = "UAR"
  SET targetobjectvalue = "Unable to obtain code value for meaning PROCHIST"
  SET the_status = "F"
  GO TO exit_script
 ENDIF
 SET proc_hist_heading = trim(uar_get_code_display(tcodeval))
 SET proc_hist_heading_cont = concat(trim(proc_hist_heading)," ",i18n_continued)
 EXECUTE cpm_create_file_name "ss", "ps"
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET person_index = 1
 CALL echo("***")
 CALL echo("***   Produce Report")
 CALL echo(build("***   allergy_num     :",allergy_num))
 CALL echo(build("***   problem_num     :",problem_num))
 CALL echo(build("***   med_profile_num :",med_profile_num))
 CALL echo(build("***   encounter_num   :",encounter_num))
 CALL echo(build("***   proc_hist_num   :",proc_hist_num))
 CALL echo(build("***   plan_num        :",plan_num))
 CALL echo(build("***   immune_num      :",immune_num))
 CALL echo(build("***   pat_hist_num    :",pat_hist_num))
 CALL echo(build("***   immune_sched_num:",immune_sched_num))
 CALL echo(build("***   immune_nonsched_num:",immune_nonsched_num))
 CALL echo("***")
 SELECT INTO trim(cpm_cfn_info->file_name_path)
  FROM (dummyt d  WITH seq = 1)
  PLAN (d
   WHERE d.seq=1)
  HEAD REPORT
   row_count = 0, new_row = 0, page_cnt = 1,
   page_break = fillstring(01,"N"), last_page = fillstring(01,"Y"),
   MACRO (print_page_format)
    "{f/0/1}{cpi/14^}{lpi/8}", row + 1, "{color/31/1}",
    "{pos/065/20}{box/093/2/1}", row + 1, "{color/30/1}",
    "{pos/095/47}{box/080/5/1}", row + 1, "{color/31/1}",
    "{pos/095/47}{box/080/5/1}", row + 1
    IF (last_page="Y")
     "{color/31/1}", "{pos/034/110}{box/103/65/1}", row + 1,
     "{color/31/1}", "{pos/065/720}{box/93/2/1}", row + 1
    ELSE
     "{color/31/1}", "{pos/034/110}{box/103/72/1}", row + 1
    ENDIF
    "{f/5/1}{cpi/5^}{lpi/3}", "{pos/000/10}", row + 1,
    col 06, report_title, row + 1,
    "{f/0/1}{cpi/16^}{lpi/6}", row + 1, "{pos/000/043}",
    row + 1, col 20, i18n_patient,
    " : ", person_data->name, col 70,
    i18n_med_rec, " # : ", person_data->mrn,
    row + 1, col 20, i18n_address,
    " : ", person_data->street_addr
    IF ((person_data->street_addr2 > " "))
     ", ", person_data->street_addr2
    ENDIF
    birth_dt_tm = trim(datetimezoneformat(person_data->birth_dt_tm,person_data->birth_tz,"@SHORTDATE"
      )), col 70, i18n_dob,
    " : ", birth_dt_tm, row + 1,
    col 20, "          ", col 30
    IF ((person_data->street_addr3 > " "))
     person_data->street_addr3, ", "
    ENDIF
    IF ((person_data->city > " "))
     person_data->city, ", "
    ENDIF
    IF ((person_data->state > " "))
     person_data->state, "  "
    ENDIF
    person_data->zipcode, col 70, i18n_sex,
    " : ", person_data->sex, row + 1,
    col 20, i18n_phone, " : ",
    person_data->phone, col 70, i18n_physician,
    " : ", person_data->pcp, row + 1,
    curdate_disp = format(cnvtdatetime(sysdate),"@SHORTDATETIMENOSEC"), "{pos/000/715}", row + 1,
    col 015, i18n_print_by, " :  ",
    person_data->printed_name, row + 1, col 015,
    i18n_printed, " :  ", curdate_disp,
    col 058
    IF (page_cnt=total_pages)
     "(", i18n_end_of_report, ")"
    ELSE
     "(", i18n_continued, ")"
    ENDIF
    page_cnt_line = concat(i18n_page," ",format(trim(cnvtstring(page_cnt)),"###;C")," ",i18n_of,
     " ",format(trim(cnvtstring(total_pages)),"###;C")), col 100, page_cnt_line,
    row + 1, "{pos/000/105}", row + 1
   ENDMACRO
   ,
   MACRO (row_counter)
    row_count += 1
    IF (row_count > max_row)
     CALL echo(" "),
     CALL echo("row_counter BREAKING PAGE"),
     CALL echo(" "),
     BREAK, page_cnt += 1, print_page_format,
     row_count = 0, page_break = "Y"
    ELSE
     page_break = "N"
    ENDIF
   ENDMACRO
   ,
   MACRO (row_check)
    IF (((row_count+ new_row) > max_row))
     BREAK,
     CALL echo(" "),
     CALL echo("row_check BREAKING PAGE"),
     CALL echo(" "), page_cnt += 1, print_page_format,
     row_count = 0, page_break = "Y"
    ELSE
     page_break = "N"
    ENDIF
   ENDMACRO
   ,
   MACRO (dummy_row_counter)
    row_count += 1
    IF (row_count > max_row)
     page_cnt += 1, row_count = 0, page_break = "Y"
    ELSE
     page_break = "N"
    ENDIF
   ENDMACRO
   ,
   MACRO (dummy_row_check)
    IF (((row_count+ new_row) > max_row))
     page_cnt += 1, row_count = 0, page_break = "Y"
    ELSE
     page_break = "N"
    ENDIF
   ENDMACRO
   ,
   MACRO (find_page_cnt2)
    avail_rows = max_row, total_pages = 1
    IF (nbr_sections > 0)
     FOR (section = 1 TO nbr_sections)
       IF (allergy_num=section)
        IF (algy_priv=true)
         new_row = 4
        ELSE
         new_row = 3
        ENDIF
        dummy_row_check, dummy_row_counter, dummy_row_counter
        IF ((allergy_prt->allergy_qual=0))
         dummy_row_counter
        ENDIF
        FOR (index = 1 TO value(allergy_prt->allergy_qual))
          new_row = 1, dummy_row_check
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter
          ENDIF
          dummy_row_counter
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter
          ENDIF
        ENDFOR
       ELSEIF (problem_num=section)
        IF (prob_priv=true)
         new_row = 4
        ELSE
         new_row = 3
        ENDIF
        dummy_row_check, dummy_row_counter, dummy_row_counter
        IF ((problem_prt->problem_cnt=0))
         dummy_row_counter
        ENDIF
        FOR (index = 1 TO value(problem_prt->problem_cnt))
          new_row = 1, dummy_row_check
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter
          ENDIF
          dummy_row_counter
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter
          ENDIF
        ENDFOR
       ELSEIF (med_profile_num=section)
        IF ((med_rec->sec_knt < 1))
         new_row = 2, dummy_row_check, dummy_row_counter
        ELSEIF ((med_rec->sec[1].item_knt < 1))
         new_row = 3, dummy_row_check, dummy_row_counter
        ELSEIF (((med_rec->sec[1].item[1].item_line_knt+ med_rec->sec[1].item[1].com_line_knt) < 3))
         IF ((med_rec->sec[1].item[1].order_id > 0))
          new_row = 4
         ELSE
          new_row = 5
         ENDIF
         dummy_row_check, dummy_row_counter
        ELSE
         new_row = 5, dummy_row_check, dummy_row_counter
        ENDIF
        IF ((med_rec->sec_knt < 1))
         dummy_row_counter
        ELSE
         FOR (i = 1 TO med_rec->sec_knt)
           IF ((med_rec->sec[i].item_knt > 0)
            AND ((med_rec->sec[i].item[1].item_line_knt+ med_rec->sec[i].item[1].com_line_knt) < 2)
            AND (((max_row - row_count)+ 1) < 4))
            IF ((med_rec->sec[i].item[1].order_id > 0))
             new_row = 3
            ELSE
             new_row = 4
            ENDIF
            dummy_row_check
           ELSE
            IF ((med_rec->sec[i].item[1].order_id > 0))
             new_row = 2
            ELSE
             new_row = 3
            ENDIF
            dummy_row_check
           ENDIF
           IF (page_break="Y")
            dummy_row_counter, dummy_row_counter
           ELSE
            dummy_row_counter
           ENDIF
           IF ((med_rec->sec[i].item_knt < 1))
            dummy_row_counter
           ELSE
            FOR (j = 1 TO med_rec->sec[i].item_knt)
              IF (((med_rec->sec[i].item[j].item_line_knt+ med_rec->sec[i].item[j].com_line_knt) > 2)
              )
               IF ((med_rec->sec[i].item[j].order_id > 0))
                new_row = 3
               ELSE
                new_row = 4
               ENDIF
               dummy_row_check
              ELSE
               IF ((med_rec->sec[i].item[j].order_id > 0))
                new_row = 2
               ELSE
                new_row = 3
               ENDIF
               dummy_row_check
              ENDIF
              IF (page_break="Y")
               dummy_row_counter, dummy_row_counter
               IF ((med_rec->sec[i].item[j].order_id < 1))
                dummy_row_counter
               ELSE
                dummy_row_counter
               ENDIF
              ELSE
               IF ((med_rec->sec[i].item[j].order_id < 1))
                dummy_row_counter
               ELSE
                dummy_row_counter
               ENDIF
              ENDIF
              FOR (x = 1 TO med_rec->sec[i].item[j].item_line_knt)
                new_row = 1, dummy_row_check
                IF (page_break="Y")
                 dummy_row_counter, dummy_row_counter
                 IF (x > 1)
                  IF ((med_rec->sec[i].item[j].order_id < 1))
                   dummy_row_counter
                  ELSE
                   dummy_row_counter
                  ENDIF
                 ELSE
                  IF ((med_rec->sec[i].item[j].order_id < 1))
                   dummy_row_counter
                  ELSE
                   dummy_row_counter
                  ENDIF
                 ENDIF
                ENDIF
                IF ((med_rec->sec[i].item[j].order_id > 0))
                 dummy_row_counter
                ENDIF
              ENDFOR
              FOR (y = 1 TO med_rec->sec[i].item[j].com_line_knt)
                new_row = 1, dummy_row_check
                IF (page_break="Y")
                 dummy_row_counter, dummy_row_counter
                 IF ((med_rec->sec[i].item[j].order_id < 1))
                  dummy_row_counter
                 ELSE
                  dummy_row_counter
                 ENDIF
                ENDIF
                dummy_row_counter
              ENDFOR
            ENDFOR
           ENDIF
         ENDFOR
        ENDIF
       ELSEIF (orders_num=section)
        new_row = 3, dummy_row_check, dummy_row_counter,
        dummy_row_counter
        IF ((orders_prt->orders_cnt=0))
         dummy_row_counter
        ENDIF
        FOR (index = 1 TO value(orders_prt->orders_cnt))
          new_row = 1, dummy_row_check
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter
          ENDIF
          dummy_row_counter
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter
          ENDIF
        ENDFOR
       ELSEIF (encounter_num=section)
        IF ((valid_encntr->restrict_ind > 0))
         new_row = 4
        ELSE
         new_row = 3
        ENDIF
        dummy_row_check, dummy_row_counter, dummy_row_counter
        IF ((encounter_prt->encounter_qual=0))
         dummy_row_counter
        ENDIF
        FOR (index = 1 TO value(encounter_prt->encounter_qual))
          new_row = 1, dummy_row_check
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter
          ENDIF
          dummy_row_counter
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter
          ENDIF
        ENDFOR
       ELSEIF (proc_hist_num=section)
        IF (proc_priv=true)
         new_row = 4
        ELSE
         new_row = 3
        ENDIF
        dummy_row_check, dummy_row_counter, dummy_row_counter
        IF ((proc_hist_prt->proc_qual=0))
         new_row = 1, dummy_row_check
         IF (page_break="Y")
          dummy_row_counter, dummy_row_counter
         ENDIF
         dummy_row_counter
        ENDIF
        FOR (index = 1 TO value(proc_hist_prt->proc_qual))
          new_row = 1, dummy_row_check
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter
          ENDIF
          dummy_row_counter
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter
          ENDIF
        ENDFOR
       ELSEIF (plan_num=section)
        new_row = 3, dummy_row_check, dummy_row_counter,
        dummy_row_counter
        IF ((plan_prt->plan_qual=0))
         dummy_row_counter
        ENDIF
        FOR (index = 1 TO value(plan_prt->plan_qual))
          new_row = 1, dummy_row_check
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter
          ENDIF
          dummy_row_counter
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter
          ENDIF
        ENDFOR
       ELSEIF (immune_num=section)
        new_row = 4, dummy_row_check, dummy_row_counter,
        dummy_row_counter, dummy_row_counter
        IF ((immune_prt->immune_qual=0))
         dummy_row_counter
        ENDIF
        FOR (index = 1 TO value(immune_prt->immune_qual))
          new_row = 2, dummy_row_check
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter, dummy_row_counter
          ENDIF
          dummy_row_counter, text_length = textlen(immune_prt->immune[index].admin_note)
          IF (text_length=0)
           dummy_row_counter
          ENDIF
          WHILE (text_length > 0)
            new_row = 1, dummy_row_check
            IF (page_break="Y")
             dummy_row_counter, dummy_row_counter, dummy_row_counter
            ENDIF
            dummy_row_counter, text_length -= 30
          ENDWHILE
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter, dummy_row_counter
          ENDIF
        ENDFOR
       ELSEIF (pat_hist_num=section)
        new_row = 3, dummy_row_check, dummy_row_counter
        IF ((pat_hist_prt->cat_qual < 1))
         dummy_row_counter, dummy_row_counter
        ELSE
         FOR (i = 1 TO value(pat_hist_prt->cat_qual))
           new_row = 1, dummy_row_check
           IF (page_break="Y")
            dummy_row_counter
           ENDIF
           dummy_row_counter
           IF ((pat_hist_prt->cat[i].line_qual < 1))
            dummy_row_counter
           ELSE
            FOR (index = 1 TO pat_hist_prt->cat[i].line_qual)
              new_row = 1, dummy_row_check
              IF (page_break="Y")
               dummy_row_counter, dummy_row_counter
              ENDIF
              dummy_row_counter
              IF (page_break="Y")
               dummy_row_counter, dummy_row_counter
              ENDIF
            ENDFOR
           ENDIF
         ENDFOR
        ENDIF
       ELSEIF (immune_sched_num=section)
        FOR (sched_cnt = 1 TO value(request->immune_sched_qual))
          new_row = 4, dummy_row_check, dummy_row_counter,
          dummy_row_counter
          IF ((request->immune_sched[sched_cnt].expectation_qual=0))
           dummy_row_counter
          ENDIF
          FOR (immun_cnt = 1 TO request->immune_sched[sched_cnt].expectation_qual)
            new_row = 1, dummy_row_check
            IF (page_break="Y")
             dummy_row_counter, dummy_row_counter
            ENDIF
            new_immune = request->immune_sched[sched_cnt].expectation[immun_cnt].new_immune_ind,
            vacc_sz = size(request->immune_sched[sched_cnt].expectation[immun_cnt].vaccine_name,1)
            IF (new_immune=1
             AND immun_cnt > 1
             AND vacc_sz > 0)
             dummy_row_counter
            ELSEIF (new_immune=1
             AND vacc_sz=0)
             dummy_row_counter
            ENDIF
            dummy_row_counter
            IF (page_break="Y")
             dummy_row_counter, dummy_row_counter
            ENDIF
          ENDFOR
          dummy_row_counter
        ENDFOR
       ELSEIF (immune_nonsched_num=section)
        new_row = 4, dummy_row_check, dummy_row_counter,
        dummy_row_counter
        IF ((immune_nonsched_prt->immune_nonsched_qual=0))
         dummy_row_counter
        ENDIF
        FOR (index = 1 TO value(immune_nonsched_prt->immune_nonsched_qual))
          new_row = 1, dummy_row_check
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter
          ENDIF
          IF ((immune_nonsched_prt->immune_nonsched[index].new_immune_ind=1)
           AND index > 1)
           dummy_row_counter
          ENDIF
          dummy_row_counter
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter
          ENDIF
        ENDFOR
        dummy_row_counter
       ENDIF
     ENDFOR
    ENDIF
    total_pages = page_cnt, page_cnt = 1
   ENDMACRO
   ,
   MACRO (print_allergy)
    IF (algy_priv=true)
     new_row = 4
    ELSE
     new_row = 3
    ENDIF
    row_check, col 006, "{f/5/1}{cpi/8}{lpi/6}",
    allergy_heading, row + 1, row_counter,
    "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/119/06}{b}", "      ",
    "Substance                                 ", "Reaction Status  ", "Severity      ",
    "Onset Date          ", "Created By", "{endb}",
    row + 1, row_counter
    IF (algy_priv=true)
     col 12, "{B}**** NOTE!{ENDB} Some allergies may {B}NOT{ENDB}",
     " have been printed due to Privilege restrictions of the printer ****",
     row + 1, row_counter
    ENDIF
    IF ((allergy_prt->allergy_qual=0))
     col 10, "No Allergies Found For Patient", row + 1,
     row_counter
    ENDIF
    FOR (index = 1 TO value(allergy_prt->allergy_qual))
      new_row = 1, row_check
      IF (page_break="Y")
       col 006, "{f/5/1}{cpi/8}{lpi/6}", allergy_heading_cont,
       row + 1, row_counter, "{f/0/1}{cpi/16^}{lpi/6}",
       "{color/19/119/06}{b}", "      ", "Substance                                 ",
       "Reaction Status  ", "Severity      ", "Onset Date          ",
       "Created By", "{endb}", row + 1,
       row_counter
      ENDIF
      col 006
      IF ((allergy_prt->allergy[index].comment_ind > 0))
       "*"
      ENDIF
      col 008
      IF ((allergy_prt->allergy[index].source_string > " "))
       allergy_prt->allergy[index].source_string
      ELSE
       allergy_prt->allergy[index].substance_ftdesc
      ENDIF
      col 048, allergy_prt->allergy[index].reaction_status_disp, col 065,
      allergy_prt->allergy[index].severity_disp, col 079, allergy_prt->allergy[index].onset_date,
      col 099, allergy_prt->allergy[index].created_prsnl_name, row + 1,
      row_counter
      IF (page_break="Y")
       col 006, "{f/5/1}{cpi/8}{lpi/6}", allergy_heading_cont,
       row + 1, row_counter, "{f/0/1}{cpi/16^}{lpi/6}",
       "{color/19/119/06}{b}", "      ", "Substance                                 ",
       "Reaction Status  ", "Severity      ", "Onset Date          ",
       "Created By", "{endb}", row + 1,
       row_counter
      ENDIF
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_problem)
    IF (prob_priv=true)
     new_row = 4
    ELSE
     new_row = 3
    ENDIF
    row_check, col 006, "{f/5/1}{cpi/8}{lpi/6}",
    problem_heading, row + 1, row_counter,
    "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/119/06}{b}", "      ",
    "Name of Problem                               ", "Life Cycle  ", "Course   ",
    "Onset Date  ", "Responsible Provider    ", "Recorded By",
    "{endb}", row + 1, row_counter
    IF (prob_priv=true)
     col 12, "{B}**** NOTE!{ENDB} Some problems may {B}NOT{ENDB}",
     " have been printed due to Privilege restrictions of the printer ****",
     row + 1, row_counter
    ENDIF
    IF ((problem_prt->problem_cnt=0))
     col 10, "No Problems Found For Patient", row + 1,
     row_counter
    ENDIF
    problem = fillstring(43," "), life_cycle = fillstring(8," "), course = fillstring(9," "),
    onset_dt = fillstring(8," "), responsible = fillstring(19," "), recorder = fillstring(18," ")
    FOR (index = 1 TO value(problem_prt->problem_cnt))
      new_row = 1, row_check
      IF (page_break="Y")
       col 006, "{f/5/1}{cpi/8}{lpi/6}", problem_heading_cont,
       row + 1, row_counter, "{f/0/1}{cpi/16^}{lpi/6}",
       "{color/19/119/06}{b}", "      ", "Name of Problem                               ",
       "Life Cycle  ", "Course   ", "Onset Date  ",
       "Responsible Provider    ", "Recorded By", "{endb}",
       row + 1, row_counter
      ENDIF
      IF ((problem_prt->problem[index].source_string > " "))
       problem = substring(1,43,problem_prt->problem[index].source_string)
      ELSE
       problem = substring(1,43,problem_prt->problem[index].problem_ftdesc)
      ENDIF
      life_cycle = substring(1,8,problem_prt->problem[index].life_cycle_status_disp), course =
      substring(1,9,problem_prt->problem[index].course_disp), onset_dt = format(cnvtdatetime(
        problem_prt->problem[index].onset_dt_tm),"@SHORTDATE;;d"),
      responsible = substring(1,19,problem_prt->problem[index].responsible_name), recorder =
      substring(1,18,problem_prt->problem[index].recorder_name)
      IF ((problem_prt->problem[index].comment_ind > 0))
       col 006, "*"
      ENDIF
      col 008, problem, col 053,
      life_cycle, col 063, course,
      col 074, onset_dt, col 084,
      responsible, col 105, recorder,
      row + 1, row_counter
      IF (page_break="Y")
       col 006, "{f/5/1}{cpi/8}{lpi/6}", problem_heading_cont,
       row + 1, row_counter, "{f/0/1}{cpi/16^}{lpi/6}",
       "{color/19/119/06}{b}", "      ", "Name of Problem                               ",
       "Life Cycle  ", "Course   ", "Onset Date  ",
       "Responsible Provider    ", "Recorded By", "{endb}",
       row + 1, row_counter
      ENDIF
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_orders)
    new_row = 3, row_check, col 006,
    "{f/5/1}{cpi/8}{lpi/6}", orders_heading, row + 1,
    row_counter, "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/119/06}{b}",
    col 007, i18n_status, col 015,
    i18n_cos_rev, col 022, i18n_catalog_type,
    col 034, i18n_start_date, col 046,
    i18n_orderable, col 063, i18n_order_detail,
    col 105, i18n_provider"{endb}", row + 1,
    row_counter
    IF ((orders_prt->orders_cnt=0))
     col 10, i18n_no_orders, row + 1,
     row_counter
    ENDIF
    FOR (index = 1 TO value(orders_prt->orders_cnt))
      new_row = 1, row_check
      IF (page_break="Y")
       col 006, "{f/5/1}{cpi/8}{lpi/6}", orders_heading_cont,
       row + 1, row_counter, "{f/0/1}{cpi/16^}{lpi/6}",
       "{color/19/119/06}{b}", col 007, i18n_status,
       col 015, i18n_cos_rev, col 022,
       i18n_catalog_type, col 034, i18n_start_date,
       col 046, i18n_orderable, col 063,
       i18n_order_detail, col 105, i18n_provider"{endb}",
       row + 1, row_counter
      ENDIF
      col 006
      IF ((orders_prt->orders[index].comment_ind > 0))
       "*"
      ENDIF
      col 008, orders_prt->orders[index].order_status_disp, col 015
      IF ((orders_prt->orders[index].need_doctor_cosign_ind=1))
       " ", i18n_character_c, " "
      ELSE
       "   "
      ENDIF
      IF ((orders_prt->orders[index].need_nurse_review_ind=1))
       i18n_character_r
      ENDIF
      col 022, orders_prt->orders[index].catalog_type_disp, col 036,
      orders_prt->orders[index].start_dt_tm"@SHORTDATE;;d", col 047, orders_prt->orders[index].
      order_mnemonic,
      col 064, orders_prt->orders[index].order_detail_disp, col 106,
      orders_prt->orders[index].provider_full_name, row + 1, row_counter
      IF (page_break="Y")
       col 006, "{f/5/1}{cpi/8}{lpi/6}", orders_heading_cont,
       row + 1, row_counter, "{f/0/1}{cpi/16^}{lpi/6}",
       "{color/19/119/06}{b}", col 007, i18n_status,
       col 015, i18n_cos_rev, col 022,
       i18n_catalog_type, col 034, i18n_start_date,
       col 046, i18n_orderable, col 063,
       i18n_order_detail, col 105, i18n_provider"{endb}",
       row + 1, row_counter
      ENDIF
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_encounter)
    IF ((valid_encntr->restrict_ind > 0))
     new_row = 4
    ELSE
     new_row = 3
    ENDIF
    row_check, col 006, "{f/5/1}{cpi/8}{lpi/6}",
    encounter_heading, row + 1, row_counter,
    "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/119/06}{b}", "      ",
    "Type        ", "Date / Time     ", "Provider             ",
    "Reason For Visit        ", "Facility              ", "Discharge Date / Time",
    "{endb}", row + 1, row_counter
    IF ((valid_encntr->restrict_ind > 0))
     col 12, "{B}**** NOTE!{ENDB} Some encounters may {B}NOT{ENDB}",
     " have been printed due to Security restrictions of the printer ****",
     row + 1, row_counter
    ENDIF
    IF ((encounter_prt->encounter_qual=0))
     col 10, "No Encounters Found For Patient", row + 1,
     row_counter
    ENDIF
    type = fillstring(11," "), provider = fillstring(25," "), rea_for_visit = fillstring(25," "),
    location = fillstring(25," ")
    FOR (index = 1 TO value(encounter_prt->encounter_qual))
      new_row = 1, row_check
      IF (page_break="Y")
       col 006, "{f/5/1}{cpi/8}{lpi/6}", encounter_heading_cont,
       row + 1, row_counter, "{f/0/1}{cpi/16^}{lpi/6}",
       "{color/19/119/06}{b}", "      ", "Type        ",
       "Date / Time     ", "Provider             ", "Reason For Visit        ",
       "Facility              ", "Discharge Date / Time", "{endb}",
       row + 1, row_counter
      ENDIF
      type = substring(1,11,encounter_prt->encounter[index].encntr_type_disp), provider = substring(1,
       20,encounter_prt->encounter[index].provider), rea_for_visit = substring(1,20,encounter_prt->
       encounter[index].reason_for_visit),
      location = substring(1,20,encounter_prt->encounter[index].loc_facility_disp), col 006, type,
      offset = 0, daylight = 0, time = datetimezone(encounter_prt->encounter[index].
       beg_effective_dt_tm,encounter_prt->encounter[index].beg_effective_tz),
      timezone = datetimezonebyindex(encounter_prt->encounter[index].beg_effective_tz,offset,daylight,
       7,time), timestr = format(time,"@SHORTDATETIMENOSEC"), timestrlen = size(trim(timestr,3),2)
      IF (timestrlen > 0)
       col 018, time"@SHORTDATETIMENOSEC", " ",
       timezone
      ENDIF
      col 034, provider, col 055,
      rea_for_visit, col 079, location,
      time = datetimezone(encounter_prt->encounter[index].disch_dt_tm,encounter_prt->encounter[index]
       .beg_effective_tz), timezone = datetimezonebyindex(encounter_prt->encounter[index].disch_tz,
       offset,daylight,7,time), timestr = format(time,"@SHORTDATETIMENOSEC"),
      timestrlen = size(trim(timestr,3),2)
      IF (timestrlen > 0)
       col 101, timestr, " ",
       timezone
      ENDIF
      row + 1, row_counter
      IF (page_break="Y")
       col 006, "{f/5/1}{cpi/8}{lpi/6}", encounter_heading_cont,
       row + 1, row_counter, "{f/0/1}{cpi/16^}{lpi/6}",
       "{color/19/119/06}{b}", "      ", "Type        ",
       "Date / Time     ", "Provider             ", "Reason For Visit        ",
       "Facility              ", "Discharge Date / Time", "{endb}",
       row + 1, row_counter
      ENDIF
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_proc_hist)
    IF (proc_priv=true)
     new_row = 4
    ELSE
     new_row = 3
    ENDIF
    row_check, col 006, "{f/5/1}{cpi/8}{lpi/6}",
    proc_hist_heading, row + 1, row_counter,
    "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/119/06}{b}", "       ",
    "Procedure                                               ", "Status     ", "Date      ",
    "Provider               ", "Location", "{endb}",
    row + 1, row_counter
    IF (proc_priv=true)
     col 12, "{B}**** NOTE!{ENDB} Some procedures may {B}NOT{ENDB}",
     " have been printed due to Privilege restrictions of the printer ****",
     row + 1, row_counter
    ENDIF
    IF ((proc_hist_prt->proc_qual=0))
     new_row = 1, row_check
     IF (page_break="Y")
      col 006, "{f/5/1}{cpi/8}{lpi/6}", proc_hist_heading_cont,
      row + 1, row_counter, "{f/0/1}{cpi/16^}{lpi/6}",
      "{color/19/119/06}{b}", "       ", "Procedure                                               ",
      "Status     ", "Date      ", "Provider               ",
      "Location", "{endb}", row + 1,
      row_counter
     ENDIF
     col 10, "No Procedures Found For Patient", row + 1,
     row_counter
    ENDIF
    procedure = fillstring(53," "), date = fillstring(8," "), provider = fillstring(20," "),
    location = fillstring(19," ")
    FOR (index = 1 TO value(proc_hist_prt->proc_qual))
      new_row = 1, row_check
      IF (page_break="Y")
       col 006, "{f/5/1}{cpi/8}{lpi/6}", proc_hist_heading_cont,
       row + 1, row_counter, "{f/0/1}{cpi/16^}{lpi/6}",
       "{color/19/119/06}{b}", "       ", "Procedure                                               ",
       "Status     ", "Date      ", "Provider               ",
       "Location", "{endb}", row + 1,
       row_counter
      ENDIF
      procedure = substring(1,53,proc_hist_prt->proc[index].procedure), date = substring(1,8,
       proc_hist_prt->proc[index].date), provider = substring(1,20,proc_hist_prt->proc[index].
       provider),
      location = substring(1,19,proc_hist_prt->proc[index].location)
      IF ((proc_hist_prt->proc[index].comment_ind > 0))
       col 006, "*"
      ENDIF
      col 007, procedure
      IF ((proc_hist_prt->proc[index].active_ind > 0))
       col 062, " Active "
      ELSE
       col 062, "Inactive"
      ENDIF
      col 072, date, col 082,
      provider, col 104, location,
      row + 1, row_counter
      IF (page_break="Y")
       col 006, "{f/5/1}{cpi/8}{lpi/6}", proc_hist_heading_cont,
       row + 1, row_counter, "{f/0/1}{cpi/16^}{lpi/6}",
       "{color/19/119/06}{b}", "       ", "Procedure                                               ",
       "Status     ", "Date      ", "Provider               ",
       "Location", "{endb}", row + 1,
       row_counter
      ENDIF
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_plan)
    new_row = 3, row_check, col 006,
    "{f/5/1}{cpi/8}{lpi/6}", plan_heading, row + 1,
    row_counter, "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/119/06}{b}",
    "      ", "Plan Name        ", "Plan Type     ",
    "Plan Id      ", "Org... Name       ", "Group           ",
    "Policy       ", "Co-Pay ", "Begin Date ",
    "End Date", "{endb}", row + 1,
    row_counter
    IF ((plan_prt->plan_qual=0))
     col 10, "No Health Plans Found For Patient", row + 1,
     row_counter
    ENDIF
    plan_name = fillstring(15," "), plan_type = fillstring(8," "), plan_id = fillstring(15," "),
    org_name = fillstring(13," "), group = fillstring(13," "), policy = fillstring(15," "),
    copay = fillstring(6," "), beg_eff_dt = fillstring(8," "), end_eff_dt = fillstring(8," ")
    FOR (index = 1 TO value(plan_prt->plan_qual))
      new_row = 1, row_check
      IF (page_break="Y")
       col 006, "{f/5/1}{cpi/8}{lpi/6}", plan_heading_cont,
       row + 1, row_counter, "{f/0/1}{cpi/16^}{lpi/6}",
       "{color/19/119/06}{b}", "      ", "Plan Name        ",
       "Plan Type     ", "Plan Id      ", "Org... Name       ",
       "Group           ", "Policy       ", "Co-Pay ",
       "Begin Date ", "End Date", "{endb}",
       row + 1, row_counter
      ENDIF
      plan_name = substring(1,15,plan_prt->hplan[index].plan_name), plan_type = substring(1,8,
       plan_prt->hplan[index].plan_type), plan_id = substring(1,15,plan_prt->hplan[index].plan_id),
      org_name = substring(1,13,plan_prt->hplan[index].org_name), group = substring(1,13,plan_prt->
       hplan[index].group), policy = substring(1,15,plan_prt->hplan[index].policy),
      copay = substring(1,6,plan_prt->hplan[index].copay), beg_eff_dt = substring(1,8,plan_prt->
       hplan[index].beg_eff_dt), end_eff_dt = substring(1,8,plan_prt->hplan[index].end_eff_dt),
      col 006, plan_name, col 023,
      plan_type, col 033, plan_id,
      col 050, org_name, col 065,
      group, col 080, policy,
      col 097, copay, col 105,
      beg_eff_dt, col 115, end_eff_dt,
      row + 1, row_counter
      IF (page_break="Y")
       col 006, "{f/5/1}{cpi/8}{lpi/6}", plan_heading_cont,
       row + 1, row_counter, "{f/0/1}{cpi/16^}{lpi/6}",
       "{color/19/119/06}{b}", "      ", "Plan Name        ",
       "Plan Type     ", "Plan Id      ", "Org... Name       ",
       "Group           ", "Policy       ", "Co-Pay ",
       "Begin Date ", "End Date", "{endb}",
       row + 1, row_counter
      ENDIF
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_imm_sched)
    new_row = 4, row_check, "{color/30/1}",
    "{pos/036/124}{box/117/1/1}", row + 1, "{color/31/1}",
    "{pos/036/124}{box/117/1/1}", row + 1, "{pos/000/105}",
    row + 1, col 006, "{f/5/1}{cpi/8}{lpi/6}",
    i18n_immunization, row + 1, row_counter,
    vaccine_product_hdr = fillstring(100," "), date_given_hdr = fillstring(18," "), patient_age1_hdr
     = fillstring(20," "),
    lot_number_hdr = fillstring(20," "), location_hdr = fillstring(30," "), refusal_reason_hdr =
    fillstring(32," "),
    vaccine_product_hdr = concat(trim(substring(1,99,i18n_vaccine_product))," ",i18n_dose),
    date_given_hdr = substring(1,19,i18n_date_given), patient_age1_hdr = substring(1,19,
     i18n_patient_age),
    lot_number_hdr = substring(1,19,i18n_lot_number), location_hdr = substring(1,29,i18n_location),
    refusal_reason_hdr = substring(1,32,i18n_refusal_reason),
    col 007, "{f/0/1}{cpi/16^}{lpi/6}", "{b}",
    vaccine_product_hdr, "{endb}", row + 1,
    row_counter, col 006, "{f/0/1}{cpi/16^}{lpi/6}",
    "{b}", date_given_hdr, patient_age1_hdr,
    lot_number_hdr, location_hdr, refusal_reason_hdr,
    "{endb}", row + 1, row_counter
    IF ((immune_prt->immune_qual=0))
     col 10, i18n_no_immunizations, row + 1,
     row_counter
    ENDIF
    vfirst = " ", vaccine = fillstring(110," "), admin_dt = fillstring(20," "),
    pat_age = fillstring(20," "), lot_number = fillstring(20," "), location_imm = fillstring(30," "),
    refusal_rsn = fillstring(30," ")
    FOR (index = 1 TO value(immune_prt->immune_qual))
      new_row = 2, row_check
      IF (page_break="Y")
       "{color/30/1}", "{pos/036/124}{box/117/1/1}", row + 1,
       "{color/31/1}", "{pos/036/124}{box/117/1/1}", row + 1,
       "{pos/000/105}", row + 1, col 005,
       "{f/5/1}{cpi/8}{lpi/6}", i18n_immunization_cont, row + 1,
       row_counter, col 007, "{f/0/1}{cpi/16^}{lpi/6}",
       "{b}", vaccine_product_hdr, "{endb}",
       row + 1, row_counter, col 006,
       "{f/0/1}{cpi/16^}{lpi/6}", "{b}", date_given_hdr,
       patient_age1_hdr, lot_number_hdr, location_hdr,
       refusal_reason_hdr, "{endb}", row + 1,
       row_counter
      ENDIF
      vfirst = substring(1,1,immune_prt->immune[index].vaccine), vaccine = substring(1,110,immune_prt
       ->immune[index].vaccine), admin_dt = substring(1,17,immune_prt->immune[index].admin_dt),
      pat_age = substring(1,17,immune_prt->immune[index].pat_age), refusal_rsn = substring(1,29,
       immune_prt->immune[index].admin_person), lot_number = substring(1,19,immune_prt->immune[index]
       .ordered_by),
      location_imm = substring(1,29,immune_prt->immune[index].admin_note)
      IF (vfirst != " ")
       col 006, "{b}", vaccine,
       "{endb}", row + 1
      ENDIF
      row_counter, col 006, admin_dt,
      col 025, pat_age, col 045,
      lot_number, col 064, location_imm,
      col 094, refusal_rsn, row + 1,
      row_counter
      IF (page_break="Y")
       "{color/30/1}", "{pos/036/124}{box/117/1/1}", row + 1,
       "{color/31/1}", "{pos/036/124}{box/117/1/1}", row + 1,
       "{pos/000/105}", row + 1, col 005,
       "{f/5/1}{cpi/8}{lpi/6}", i18n_immunization_cont, row + 1,
       row_counter, col 007, "{f/0/1}{cpi/16^}{lpi/6}",
       "{b}", vaccine_product_hdr, "{endb}",
       row + 1, row_counter, col 006,
       "{f/0/1}{cpi/16^}{lpi/6}", "{b}", date_given_hdr,
       patient_age1_hdr, lot_number_hdr, location_hdr,
       refusal_reason_hdr, "{endb}", row + 1,
       row_counter
      ENDIF
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_imm_sched_new)
    new_row = 4, row_check, col 005,
    "{f/5/1}{cpi/8}{lpi/6}", i18n_immunization_sched, row + 1,
    row_counter, vaccine1_hdr = fillstring(16," "), vaccine1_hdr = substring(1,20,i18n_vaccine),
    dose_hdr = concat("|",trim(substring(1,8,i18n_dose),7),"|"), dose1_hdr = format(dose_hdr,
     "##########;R"), col 006,
    "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/119/07}{b}", vaccine1_hdr,
    dose1_hdr, type_of_vaccine_hdr, "|",
    product_given_hdr, "|", date_given1_hdr,
    "|", location1_hdr, "{endb}",
    row + 1, row_counter
    IF ((immune_sched_prt->immune_sched_qual=0))
     col 10, i18n_no_immunizations, row + 1,
     row_counter
    ENDIF
    vaccine = fillstring(20," "), dose_nbr = fillstring(4," "), vaccine_type = fillstring(40," "),
    product = fillstring(20," "), given_dt = fillstring(12," "), location_imm1 = fillstring(17," "),
    new_exp_line = concat(fillstring(20,"_"),"|",fillstring(4,"_"),"|",fillstring(40,"_"),
     "|",fillstring(20,"_"),"|",fillstring(12,"_"),"|",
     fillstring(17,"_")), new_imm_line = concat("|",fillstring(4,"_"),"|",fillstring(40,"_"),"|",
     fillstring(20,"_"),"|",fillstring(12,"_"),"|",fillstring(17,"_"))
    FOR (index = 1 TO value(immune_sched_prt->immune_sched_qual))
      new_row = 1, row_check
      IF (page_break="Y")
       col 005, "{f/5/1}{cpi/8}{lpi/6}", i18n_immunization_sched_cont,
       row + 1, row_counter, col 006,
       "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/119/07}{b}", vaccine1_hdr,
       dose1_hdr, type_of_vaccine_hdr, "|",
       product_given_hdr, "|", date_given1_hdr,
       "|", location1_hdr, "{endb}",
       row + 1, row_counter
      ENDIF
      vaccine = substring(1,20,immune_sched_prt->immune_sched[index].vaccine_name), dose_nbr =
      substring(1,4,immune_sched_prt->immune_sched[index].dose_nbr), vaccine_type = substring(1,40,
       immune_sched_prt->immune_sched[index].vaccine_type),
      product = substring(1,20,immune_sched_prt->immune_sched[index].product), given_dt = substring(1,
       12,immune_sched_prt->immune_sched[index].admin_dt), location_imm1 = substring(1,17,
       immune_sched_prt->immune_sched[index].location),
      new_immune = immune_sched_prt->immune_sched[index].new_immune_ind, fuzzy_dt_ind =
      immune_sched_prt->immune_sched[index].fuzzy_dt_ind, vacc_sz = size(immune_sched_prt->
       immune_sched[index].vaccine_name,1)
      IF (new_immune=1
       AND index > 1
       AND vacc_sz > 0)
       col 005, new_exp_line, row + 1,
       row_counter
      ELSEIF (new_immune=1
       AND vacc_sz=0)
       col 025, new_imm_line, row + 1,
       row_counter
      ENDIF
      col 005, vaccine, col 025,
      vertical_rule, col 026, dose_nbr,
      col 030, vertical_rule, col 031,
      vaccine_type, col 071, vertical_rule,
      col 072, product, col 092,
      vertical_rule, col 093, given_dt,
      col 105, vertical_rule, col 106,
      location_imm1, row + 1, row_counter
      IF (page_break="Y")
       col 005, "{f/5/1}{cpi/8}{lpi/6}", i18n_immunization_sched_cont,
       row + 1, row_counter, col 006,
       "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/119/07}{b}", vaccine1_hdr,
       dose1_hdr, type_of_vaccine_hdr, "|",
       product_given_hdr, "|", date_given1_hdr,
       "|", location1_hdr, "{endb}",
       row + 1, row_counter
      ENDIF
    ENDFOR
    col 005, new_exp_line, row + 1,
    row_counter
   ENDMACRO
   ,
   MACRO (print_imm_nonsched)
    new_row = 4, row_check, col 005,
    "{f/5/1}{cpi/8}{lpi/6}", i18n_immunization_nonsched, row + 1,
    row_counter, type_of_vaccine1_hdr = fillstring(50," "), location2_hdr = fillstring(25," "),
    dose2_hdr = concat(trim(i18n_dose,7),"|"), type_of_vaccine1_hdr = substring(1,50,
     i18n_type_of_vaccine), location2_hdr = substring(1,25,i18n_location),
    col 006, "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/119/07}{b}",
    dose2_hdr, type_of_vaccine1_hdr, "{endb}",
    col 104, "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/119/07}{b}",
    "|", product_given1_hdr, "|",
    date_given2_hdr, "|", location2_hdr,
    "{endb}", row + 1, row_counter
    IF ((immune_nonsched_prt->immune_nonsched_qual=0))
     col 10, i18n_no_oth_immunizations, row + 1,
     row_counter
    ENDIF
    ns_dose_nbr = fillstring(4," "), ns_vaccine_type = fillstring(50," "), ns_product = fillstring(30,
     " "),
    ns_given_dt = fillstring(13," "), ns_location = fillstring(17," "), new_ns_imm_line = concat(
     fillstring(4,"_"),"|",fillstring(50,"_"),"|",fillstring(30,"_"),
     "|",fillstring(13,"_"),"|",fillstring(17,"_"))
    FOR (index = 1 TO value(immune_nonsched_prt->immune_nonsched_qual))
      new_row = 1, row_check
      IF (page_break="Y")
       col 005, "{f/5/1}{cpi/8}{lpi/6}", i18n_immunization_nonsched_cont,
       row + 1, row_counter, col 006,
       "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/119/07}{b}", dose2_hdr,
       type_of_vaccine1_hdr, "{endb}", col 104,
       "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/119/07}{b}", "|",
       product_given1_hdr, "|", date_given2_hdr,
       "|", location2_hdr, "{endb}",
       row + 1, row_counter
      ENDIF
      ns_dose_nbr = substring(1,4,immune_nonsched_prt->immune_nonsched[index].dose_nbr),
      ns_vaccine_type = substring(1,50,immune_nonsched_prt->immune_nonsched[index].vaccine_type),
      ns_product = substring(1,30,immune_nonsched_prt->immune_nonsched[index].product),
      ns_given_dt = substring(1,13,immune_nonsched_prt->immune_nonsched[index].admin_dt), ns_location
       = substring(1,20,immune_nonsched_prt->immune_nonsched[index].location), ns_fuzzy_dt_ind =
      immune_nonsched_prt->immune_nonsched[index].fuzzy_dt_ind,
      new_immune = immune_nonsched_prt->immune_nonsched[index].new_immune_ind
      IF (new_immune=1
       AND index > 1)
       col 5, new_ns_imm_line, row + 1,
       row_counter
      ENDIF
      col 005, ns_dose_nbr, col 009,
      vertical_rule, col 010, ns_vaccine_type,
      col 060, vertical_rule, col 061,
      ns_product, col 091, vertical_rule,
      col 092, ns_given_dt, col 105,
      vertical_rule, col 106, ns_location,
      row + 1, row_counter
      IF (page_break="Y")
       col 005, "{f/5/1}{cpi/8}{lpi/6}", i18n_immunization_nonsched_cont,
       row + 1, row_counter, col 006,
       "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/119/07}{b}", dose2_hdr,
       type_of_vaccine1_hdr, "{endb}", col 104,
       "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/119/07}{b}", "|",
       product_given1_hdr, "|", date_given2_hdr,
       "|", location2_hdr, "{endb}",
       row + 1, row_counter
      ENDIF
    ENDFOR
    col 005, new_ns_imm_line, row + 1,
    row_counter
   ENDMACRO
   ,
   MACRO (print_immune)
    new_row = 4, row_check, "{color/30/1}",
    "{pos/036/124}{box/117/1/1}", row + 1, "{color/31/1}",
    "{pos/036/124}{box/117/1/1}", row + 1, "{pos/000/105}",
    row + 1, col 006, "{f/5/1}{cpi/8}{lpi/6}",
    i18n_immunization, row + 1, row_counter,
    vaccine_hdr = fillstring(100," "), status_hdr = fillstring(13," "), admin_dt_hdr = fillstring(18,
     " "),
    patient_age_hdr = fillstring(18," "), admin_person_hdr = fillstring(20," "), ordered_by_hdr =
    fillstring(20," "),
    admin_note_hdr = fillstring(30," "), vaccine_hdr = substring(1,100,i18n_vaccine), status_hdr =
    substring(1,12,i18n_status),
    admin_dt_hdr = substring(1,17,i18n_date_given), patient_age_hdr = substring(1,17,i18n_patient_age
     ), admin_person_hdr = substring(1,19,i18n_admin_person),
    ordered_by_hdr = substring(1,19,i18n_ordered_by), admin_note_hdr = substring(1,30,i18n_admin_note
     ), col 007,
    "{f/0/1}{cpi/16^}{lpi/6}", "{b}", vaccine_hdr,
    "{endb}", row + 1, row_counter,
    col 006, "{f/0/1}{cpi/16^}{lpi/6}", "{b}",
    status_hdr, admin_dt_hdr, patient_age_hdr,
    admin_person_hdr, ordered_by_hdr, admin_note_hdr,
    "{endb}", row + 1, row_counter
    IF ((immune_prt->immune_qual=0))
     col 10, i18n_no_immunizations, row + 1,
     row_counter
    ENDIF
    vaccine = fillstring(100," "), status = fillstring(13," "), admin_dt = fillstring(18," "),
    pat_age = fillstring(18," "), admin_person = fillstring(21," "), order_by = fillstring(20," "),
    admin_note = fillstring(30," ")
    FOR (index = 1 TO value(immune_prt->immune_qual))
      new_row = 2, row_check
      IF (page_break="Y")
       "{color/30/1}", "{pos/036/124}{box/117/1/1}", row + 1,
       "{color/31/1}", "{pos/036/124}{box/117/1/1}", row + 1,
       "{pos/000/105}", row + 1, col 006,
       "{f/5/1}{cpi/8}{lpi/6}", i18n_immunization_cont, row + 1,
       row_counter, col 007, "{f/0/1}{cpi/16^}{lpi/6}",
       "{b}", vaccine_hdr, "{endb}",
       row + 1, row_counter, col 006,
       "{f/0/1}{cpi/16^}{lpi/6}", "{b}", status_hdr,
       admin_dt_hdr, patient_age_hdr, admin_person_hdr,
       ordered_by_hdr, admin_note_hdr, "{endb}",
       row + 1, row_counter
      ENDIF
      vaccine = substring(1,99,immune_prt->immune[index].vaccine), status = substring(1,12,immune_prt
       ->immune[index].status), admin_dt = substring(1,17,immune_prt->immune[index].admin_dt),
      pat_age = substring(1,17,immune_prt->immune[index].pat_age), admin_person = substring(1,20,
       immune_prt->immune[index].admin_person), order_by = substring(1,19,immune_prt->immune[index].
       ordered_by),
      col 006, "{b}", vaccine,
      "{endb}", row + 1, row_counter,
      col 006, status, col 019,
      admin_dt, col 037, pat_age,
      col 052, admin_person, col 073,
      order_by, entire_text = immune_prt->immune[index].admin_note, text_length = textlen(entire_text
       )
      IF (text_length=0)
       row + 1, row_counter
      ENDIF
      idx = 1
      WHILE (text_length > 0)
        new_row = 1, row_check
        IF (page_break="Y")
         "{color/30/1}", "{pos/036/124}{box/117/1/1}", row + 1,
         "{color/31/1}", "{pos/036/124}{box/117/1/1}", row + 1,
         "{pos/000/105}", row + 1, col 006,
         "{f/5/1}{cpi/8}{lpi/6}", i18n_immunization_cont, row + 1,
         row_counter, col 007, "{f/0/1}{cpi/16^}{lpi/6}",
         "{b}", vaccine_hdr, "{endb}",
         row + 1, row_counter, col 006,
         "{f/0/1}{cpi/16^}{lpi/6}", "{b}", status_hdr,
         admin_dt_hdr, patient_age_hdr, admin_person_hdr,
         ordered_by_hdr, admin_note_hdr, "{endb}",
         row + 1, row_counter
        ENDIF
        find_pos = findstring(" ",substring(idx,30,entire_text),1,1)
        IF (find_pos > 25
         AND  NOT (substring((idx+ 30),1,entire_text) IN (" ", ",", ".", "-")))
         admin_note = trim(substring(idx,find_pos,entire_text),7), idx += find_pos, text_length -=
         find_pos
        ELSEIF (substring((idx+ 30),1,entire_text) IN (" ", ",", ".", "-"))
         admin_note = trim(substring(idx,30,entire_text),7), idx += 30, text_length -= 30
        ELSE
         admin_note = trim(concat(substring(idx,29,entire_text),"-"),7), idx += 29, text_length -= 29
        ENDIF
        col 093, admin_note, row + 1,
        row_counter
      ENDWHILE
      IF (page_break="Y")
       "{color/30/1}", "{pos/036/124}{box/117/1/1}", row + 1,
       "{color/31/1}", "{pos/036/124}{box/117/1/1}", row + 1,
       "{pos/000/105}", row + 1, col 006,
       "{f/5/1}{cpi/8}{lpi/6}", i18n_immunization_cont, row + 1,
       row_counter, col 007, "{f/0/1}{cpi/16^}{lpi/6}",
       "{b}", vaccine_hdr, "{endb}",
       row + 1, row_counter, col 006,
       "{f/0/1}{cpi/16^}{lpi/6}", "{b}", status_hdr,
       admin_dt_hdr, patient_age_hdr, admin_person_hdr,
       ordered_by_hdr, admin_note_hdr, "{endb}",
       row + 1, row_counter
      ENDIF
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_pat_hist)
    new_row = 3, row_check, col 006,
    "{f/5/1}{cpi/8}{lpi/6}", pat_hist_heading"{f/0/1}{cpi/16^}{lpi/6}", row + 1,
    row_counter
    IF ((pat_hist_prt->cat_qual < 1))
     col 008, "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/120/07}{b}",
     "Name", col 094, "Description",
     col 140, "Units", col 158,
     "Date", "{endb}", row + 1,
     row_counter, col 010, "No Histories Found For Patient",
     row + 1, row_counter
    ELSE
     FOR (i = 1 TO value(pat_hist_prt->cat_qual))
       pat_hist_name = concat(trim(substring(1,20,pat_hist_prt->cat[i].name))," Name"), new_row = 1,
       row_check
       IF (page_break="Y")
        col 006, "{f/5/1}{cpi/8}{lpi/6}", pat_hist_heading_cont"{f/0/1}{cpi/16^}{lpi/6}",
        row + 1, row_counter, col 008,
        "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/120/07}{b}", pat_hist_name,
        col 094, "Description", col 140,
        "Units", col 158, "Date",
        "{endb}"
       ELSE
        IF (i < 2)
         col 008, "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/120/07}{b}",
         pat_hist_name, col 094, "Description",
         col 140, "Units", col 158,
         "Date", "{endb}"
        ELSE
         col 007, "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/120/06}{b}",
         pat_hist_name, col 093, "Description",
         col 139, "Units", col 157,
         "Date", "{endb}"
        ENDIF
       ENDIF
       row + 1, row_counter
       IF ((pat_hist_prt->cat[i].line_qual < 1))
        col 010, "No History Found For Patient", row + 1,
        row_counter
       ELSE
        name = fillstring(44," "), descript = fillstring(44," "), units = fillstring(14," "),
        date = fillstring(8," ")
        FOR (index = 1 TO pat_hist_prt->cat[i].line_qual)
          new_row = 1, row_check
          IF (page_break="Y")
           col 006, "{f/5/1}{cpi/8}{lpi/6}", pat_hist_heading_cont"{f/0/1}{cpi/16^}{lpi/6}",
           row + 1, row_counter, col 008,
           "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/120/07}{b}", pat_hist_name,
           col 094, "Description", col 140,
           "Units", col 158, "Date",
           "{endb}", row + 1, row_counter
          ENDIF
          name = substring(1,44,pat_hist_prt->cat[i].line[index].name), descript = substring(1,44,
           pat_hist_prt->cat[i].line[index].descript), units = substring(1,14,pat_hist_prt->cat[i].
           line[index].units),
          date = substring(1,8,pat_hist_prt->cat[i].line[index].date)
          IF ((pat_hist_prt->cat[i].line[index].comment_ind > 0))
           col 006, "*"
          ENDIF
          col 007, name, col 053,
          descript, col 099, units,
          col 115, date, row + 1,
          row_counter
          IF (page_break="Y")
           col 006, "{f/5/1}{cpi/8}{lpi/6}", pat_hist_heading_cont"{f/0/1}{cpi/16^}{lpi/6}",
           row + 1, row_counter, col 008,
           "{f/0/1}{cpi/16^}{lpi/6}", "{color/19/120/07}{b}", pat_hist_name,
           col 094, "Description", col 140,
           "Units", col 158, "Date",
           "{endb}", row + 1, row_counter
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
    ENDIF
   ENDMACRO
   ,
   MACRO (print_meds)
    CALL echo(" "),
    CALL echo("Entering Med Profile section"), generic_line = fillstring(155," "),
    section_heading_cont = fillstring(155," ")
    IF ((med_rec->sec_knt < 1))
     new_row = 2, row_check, col 006,
     "{f/5/1}{cpi/8}{lpi/6}", medprofile_heading, "{f/0/1}{cpi/16^}{lpi/6}",
     row + 1, row_counter
    ELSEIF ((med_rec->sec[1].item_knt < 1))
     new_row = 3, row_check, col 006,
     "{f/5/1}{cpi/8}{lpi/6}", medprofile_heading, "{f/0/1}{cpi/16^}{lpi/6}",
     row + 1, row_counter
    ELSEIF (((med_rec->sec[1].item[1].item_line_knt+ med_rec->sec[1].item[1].com_line_knt) < 3))
     IF ((med_rec->sec[1].item[1].order_id > 0))
      new_row = 4
     ELSE
      new_row = 5
     ENDIF
     row_check, col 006, "{f/5/1}{cpi/8}{lpi/6}",
     medprofile_heading, "{f/0/1}{cpi/16^}{lpi/6}", row + 1,
     row_counter
    ELSE
     new_row = 5, row_check, col 006,
     "{f/5/1}{cpi/8}{lpi/6}", medprofile_heading, "{f/0/1}{cpi/16^}{lpi/6}",
     row + 1, row_counter
    ENDIF
    IF ((med_rec->sec_knt < 1))
     col 07, i18n_no_medications, row + 1,
     row_counter
    ELSE
     FOR (i = 1 TO med_rec->sec_knt)
       IF ((med_rec->sec[i].item_knt > 0)
        AND ((med_rec->sec[i].item[1].item_line_knt+ med_rec->sec[i].item[1].com_line_knt) < 2)
        AND (((max_row - row_count)+ 1) < 4))
        IF ((med_rec->sec[i].item[1].order_id > 0))
         new_row = 3
        ELSE
         new_row = 4
        ENDIF
        row_check
       ELSE
        IF ((med_rec->sec[i].item[1].order_id > 0))
         new_row = 2
        ELSE
         new_row = 3
        ENDIF
        row_check
       ENDIF
       IF (page_break="Y")
        col 006, "{f/5/1}{cpi/8}{lpi/6}", medprofile_heading_cont,
        row + 1, row_counter, "{f/0/1}{cpi/16^}{lpi/6}{b}",
        "{color/19/119/06}", "      ", med_rec->sec[i].name,
        "{endb}", row + 1, row_counter
       ELSE
        "{f/0/1}{cpi/16^}{lpi/6}{b}", "{color/19/119/06}", "      ",
        med_rec->sec[i].name, "{endb}", row + 1,
        row_counter
       ENDIF
       IF ((med_rec->sec[i].item_knt < 1))
        col 07, i18n_no_medications, row + 1,
        row_counter
       ELSE
        FOR (j = 1 TO med_rec->sec[i].item_knt)
          IF (((med_rec->sec[i].item[j].item_line_knt+ med_rec->sec[i].item[j].com_line_knt) > 2))
           IF ((med_rec->sec[i].item[j].order_id > 0))
            new_row = 3
           ELSE
            new_row = 4
           ENDIF
           row_check
          ELSE
           IF ((med_rec->sec[i].item[j].order_id > 0))
            new_row = 2
           ELSE
            new_row = 3
           ENDIF
           row_check
          ENDIF
          IF (page_break="Y")
           section_heading_cont = concat(trim(med_rec->sec[i].name),"  ",i18n_continued), col 006,
           "{f/5/1}{cpi/8}{lpi/6}",
           medprofile_heading_cont, row + 1, row_counter,
           "{f/0/1}{cpi/16^}{lpi/6}{b}", "{color/19/119/06}", "      ",
           section_heading_cont, "{endb}", row + 1,
           row_counter
           IF ((med_rec->sec[i].item[j].order_id < 1))
            generic_line = trim(med_rec->sec[i].item[j].drug_name), col 007, "{BOLD/155/7}",
            generic_line, row + 1, row_counter
           ELSE
            generic_line = trim(med_rec->sec[i].item[j].drug_name), col 008, "{BOLD/155/7}",
            generic_line, row + 1, row_counter
           ENDIF
          ELSE
           IF ((med_rec->sec[i].item[j].order_id < 1))
            generic_line = trim(med_rec->sec[i].item[j].drug_name), col 007, "{BOLD/155/7}",
            generic_line, row + 1, row_counter
           ELSE
            generic_line = trim(med_rec->sec[i].item[j].drug_name), col 008, "{BOLD/155/7}",
            generic_line, row + 1, row_counter
           ENDIF
          ENDIF
          FOR (x = 1 TO med_rec->sec[i].item[j].item_line_knt)
            new_row = 1, row_check
            IF (page_break="Y")
             section_heading_cont = concat(trim(med_rec->sec[i].name),"  ",i18n_continued), col 006,
             "{f/5/1}{cpi/8}{lpi/6}",
             medprofile_heading_cont, row + 1, row_counter,
             "{f/0/1}{cpi/16^}{lpi/6}{b}", "{color/19/119/06}", "      ",
             section_heading_cont, "{endb}", row + 1,
             row_counter
             IF (x > 1)
              IF ((med_rec->sec[i].item[j].order_id < 1))
               generic_line = concat(trim(med_rec->sec[i].item[j].drug_name)," ",i18n_continued), col
                007, "{BOLD/155/7}",
               generic_line, row + 1, row_counter
              ELSE
               generic_line = concat(trim(med_rec->sec[i].item[j].drug_name)," ",i18n_continued), col
                008, "{BOLD/155/7}",
               generic_line, row + 1, row_counter
              ENDIF
             ELSE
              IF ((med_rec->sec[i].item[j].order_id < 1))
               generic_line = trim(med_rec->sec[i].item[j].drug_name), col 007, "{BOLD/155/7}",
               generic_line, row + 1, row_counter
              ELSE
               generic_line = trim(med_rec->sec[i].item[j].drug_name), col 008, "{BOLD/155/7}",
               generic_line, row + 1, row_counter
              ENDIF
             ENDIF
            ENDIF
            col 012, med_rec->sec[i].item[j].item_line[x].item_str
            IF ((med_rec->sec[i].item[j].order_id > 0))
             row + 1, row_counter
            ENDIF
          ENDFOR
          FOR (y = 1 TO med_rec->sec[i].item[j].com_line_knt)
            new_row = 1, row_check
            IF (page_break="Y")
             section_heading_cont = concat(trim(med_rec->sec[i].name),"  ",i18n_continued), col 006,
             "{f/5/1}{cpi/8}{lpi/6}",
             medprofile_heading_cont, row + 1, row_counter,
             "{f/0/1}{cpi/16^}{lpi/6}{b}", "{color/19/119/06}", "      ",
             section_heading_cont, "{endb}", row + 1,
             row_counter
             IF ((med_rec->sec[i].item[j].order_id < 1))
              generic_line = concat(trim(med_rec->sec[i].item[j].drug_name)," ",i18n_continued), col
              007, "{BOLD/155/7}",
              generic_line, row + 1, row_counter
             ELSE
              generic_line = concat(trim(med_rec->sec[i].item[j].drug_name)," ",i18n_continued), col
              008, "{BOLD/155/7}",
              generic_line, row + 1, row_counter
             ENDIF
            ENDIF
            col 012
            IF ((med_rec->sec[i].item[j].com_line_knt < 2))
             "{BOLD/8/12}", med_rec->sec[i].item[j].com_line[y].com_str
            ELSE
             med_rec->sec[i].item[j].com_line[y].com_str
            ENDIF
            row + 1, row_counter
          ENDFOR
        ENDFOR
       ENDIF
     ENDFOR
    ENDIF
   ENDMACRO
   , find_page_cnt2,
   row_count = 0, new_row = 0, page_cnt = 1,
   print_page_format, sched_cnt = 1
   FOR (section = 1 TO value(nbr_sections))
     IF (allergy_num=section)
      print_allergy
     ELSEIF (problem_num=section)
      print_problem
     ELSEIF (med_profile_num=section)
      print_meds
     ELSEIF (orders_num=section)
      print_orders
     ELSEIF (encounter_num=section)
      print_encounter
     ELSEIF (proc_hist_num=section)
      print_proc_hist
     ELSEIF (plan_num=section)
      print_plan
     ELSEIF (immune_num=section
      AND (immune_prt->immune_col_ct=0))
      print_immune
     ELSEIF (immune_num=section
      AND (immune_prt->immune_col_ct > 0))
      print_imm_sched
     ELSEIF (pat_hist_num=section)
      print_pat_hist
     ELSEIF (immune_sched_num=section)
      FOR (sched_cnt = 1 TO value(request->immune_sched_qual))
        i18n_immunization_sched = request->immune_sched[sched_cnt].schedule_name,
        i18n_immunization_sched_cont = concat(trim(i18n_immunization_sched)," ",i18n_continued),
        total_immun_cnt = request->immune_sched[sched_cnt].expectation_qual,
        stat = alterlist(immune_sched_prt->immune_sched,total_immun_cnt), immune_sched_prt->
        immune_sched_qual = total_immun_cnt
        FOR (immun_cnt = 1 TO total_immun_cnt)
          immune_sched_prt->immune_sched[immun_cnt].vaccine_name = request->immune_sched[sched_cnt].
          expectation[immun_cnt].vaccine_name, immune_sched_prt->immune_sched[immun_cnt].dose_nbr =
          request->immune_sched[sched_cnt].expectation[immun_cnt].dose_nbr, immune_sched_prt->
          immune_sched[immun_cnt].vaccine_type = request->immune_sched[sched_cnt].expectation[
          immun_cnt].vaccine_type,
          immune_sched_prt->immune_sched[immun_cnt].product = request->immune_sched[sched_cnt].
          expectation[immun_cnt].product, immune_sched_prt->immune_sched[immun_cnt].admin_dt =
          request->immune_sched[sched_cnt].expectation[immun_cnt].admin_dt, immune_sched_prt->
          immune_sched[immun_cnt].location = request->immune_sched[sched_cnt].expectation[immun_cnt].
          location,
          immune_sched_prt->immune_sched[immun_cnt].fuzzy_dt_ind = request->immune_sched[sched_cnt].
          expectation[immun_cnt].fuzzy_dt_ind, immune_sched_prt->immune_sched[immun_cnt].
          new_immune_ind = request->immune_sched[sched_cnt].expectation[immun_cnt].new_immune_ind,
          immune_sched_cnt += 1
        ENDFOR
        print_imm_sched_new
      ENDFOR
     ELSEIF (immune_nonsched_num=section)
      print_imm_nonsched
     ENDIF
   ENDFOR
  FOOT REPORT
   dvar = 0
  WITH nocounter, nullreport, maxrow = 150,
   maxcol = 255, dio = postscript
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET operationname = "GENERATE"
  SET operationstatus = "F"
  SET targetobjectname = "REPORT"
  SET targetobjectvalue = errmsg
  SET the_status = "F"
  GO TO exit_script
 ELSE
  SET the_status = "S"
 ENDIF
#exit_script
 SET reply->output_file = trim(cpm_cfn_info->file_name_full_path)
 SET reply->format_type = "application/postscript"
 SET reply->node = curnode
 IF (the_status="F")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = operationname
  SET reply->status_data.subeventstatus[1].operationstatus = operationstatus
  SET reply->status_data.subeventstatus[1].targetobjectname = targetobjectname
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "042 04/11/13 AB017375"
END GO
