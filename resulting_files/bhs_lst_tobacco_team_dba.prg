CREATE PROGRAM bhs_lst_tobacco_team:dba
 CALL echo("LAST MOD: 001")
 CALL echo("LAST MOD DATE: 10/25/2023")
 CALL echo("LAST MOD BY: Joe Fenton")
 DECLARE mf_cs17_admitting = f8 WITH constant(uar_get_code_by("DISPLAYKEY",17,"ADMITTING")), protect
 DECLARE mf_cs72_smokingcessation = f8 WITH constant(uar_get_code_by_cki("CKI.EC!9514")), protect
 DECLARE mf_cs14003_ecigaretteuse = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "SHXECIGARETTEUSE")), protect
 DECLARE mf_cs14003_smokelesstobaccouse = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "SHXSMOKELESSTOBACCOUSE")), protect
 DECLARE mf_cs14003_tobaccouse = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,"SHXTOBACCOUSE")
  ), protect
 DECLARE mf_cs_71_emergency = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY")), protect
 DECLARE mf_cs71_observation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")),
 protect
 DECLARE mf_cs319_mrn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE mf_cs319_fin = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_cs71_daystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY")), protect
 DECLARE mf_cs71_inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs400_icd10cm = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!4101498946")),
 protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 DECLARE ml_cnt_pat = i4 WITH noconstant(0), protect
 DECLARE md_age = dq8 WITH constant(cnvtagedatetime(18,0,0,0)), protect
 DECLARE paramcnt = i4 WITH constant(size(definition->parameters,5))
 DECLARE valuecnt = i4 WITH noconstant(0)
 DECLARE fac_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 RECORD definition(
   1 patient_list_id = f8
   1 parameters[*]
     2 parameter_name = vc
     2 parameter_seq = i4
     2 values[*]
       3 value_name = vc
       3 value_seq = i4
       3 value_string = vc
       3 value_dt = dq8
       3 value_id = f8
       3 value_entity = vc
 )
 RECORD patients(
   1 patients[*]
     2 person_id = f8
     2 encntr_id = f8
     2 priority = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD providers(
   1 providers[*]
     2 person_id = f8
 )
 RECORD date(
   1 startdate = dq8
   1 enddate = dq8
 )
 SET modify = predeclare
 SET patients->status_data.status = "F"
 SET valuecnt = size(definition->parameters[1].values,5)
 FOR (y = 1 TO paramcnt)
   IF ((definition->parameters[y].parameter_seq=1))
    SET valuecnt = size(definition->parameters[y].values,5)
    SET fac_where = " ed.loc_facility_cd in ("
    FOR (x = 1 TO valuecnt)
      IF ((definition->parameters[y].values[x].value_name="V_ENTITY_ID"))
       SET fac_where = concat(fac_where,trim(cnvtstring(definition->parameters[y].values[x].value_id)
         ),",")
      ENDIF
    ENDFOR
    IF (trim(fac_where)=" ed.loc_facility_cd in (")
     FOR (x = 1 TO valuecnt)
       IF ((definition->parameters[y].values[x].value_name="R_ENTITY_ID"))
        SET fac_where = concat(fac_where,trim(cnvtstring(definition->parameters[y].values[x].value_id
           )),",")
       ENDIF
     ENDFOR
    ENDIF
    IF (trim(fac_where) != "")
     SET fac_where = replace(fac_where,",",")",2)
    ELSE
     SET fac_where = " 1= 1"
    ENDIF
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  facility = uar_get_code_display(e.loc_facility_cd), nurse_unit = uar_get_code_display(e
   .loc_nurse_unit_cd), sort_name = build(p.name_full_formatted,p.person_id)
  FROM encntr_domain ed,
   encounter e,
   encntr_alias fin,
   encntr_alias mrn,
   clinical_event ce,
   person p
  PLAN (ed
   WHERE ed.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ed.loc_building_cd > 0
    AND ed.loc_nurse_unit_cd > 0
    AND parser(fac_where))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd IN (mf_cs71_daystay, mf_cs71_inpatient, mf_cs_71_emergency,
   mf_cs71_observation)
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND e.disch_dt_tm=null)
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.encntr_alias_type_cd=mf_cs319_fin)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.birth_dt_tm <= cnvtdatetime(md_age))
   JOIN (mrn
   WHERE mrn.encntr_id=e.encntr_id
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn)
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.person_id=e.person_id
    AND ce.event_cd=mf_cs72_smokingcessation
    AND ce.valid_until_dt_tm > sysdate
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
   mf_cs8_active_cd)
    AND trim(ce.result_val,3) IN ("Patient has smoked in the last 30 days"))
  ORDER BY facility, nurse_unit, sort_name
  HEAD REPORT
   stat = alterlist(patients->patients,10)
  HEAD sort_name
   ml_cnt_pat += 1
   IF (mod(ml_cnt_pat,10)=1
    AND ml_cnt_pat > 1)
    stat = alterlist(patients->patients,(ml_cnt_pat+ 9))
   ENDIF
   patients->patients[ml_cnt_pat].encntr_id = e.encntr_id, patients->patients[ml_cnt_pat].person_id
    = e.person_id
  FOOT REPORT
   stat = alterlist(patients->patients,ml_cnt_pat), ml_cnt_pat = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  facility = uar_get_code_display(e.loc_facility_cd), nurse_unit = uar_get_code_display(e
   .loc_nurse_unit_cd), sort_name = build(p.name_full_formatted,p.person_id)
  FROM encntr_domain ed,
   encounter e,
   encntr_alias fin,
   encntr_alias mrn,
   shx_activity sa,
   shx_response sr,
   shx_alpha_response sar,
   person p,
   nomenclature n,
   prsnl chtd
  PLAN (ed
   WHERE ed.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ed.loc_building_cd > 0
    AND ed.loc_nurse_unit_cd > 0
    AND parser(fac_where))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.disch_dt_tm=null
    AND e.encntr_type_cd IN (mf_cs71_daystay, mf_cs71_inpatient, mf_cs_71_emergency,
   mf_cs71_observation)
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND  NOT (e.person_id IN (
   (SELECT
    ce.person_id
    FROM clinical_event ce
    WHERE ce.encntr_id=e.encntr_id
     AND ce.person_id=e.person_id
     AND ce.event_cd=mf_cs72_smokingcessation
     AND ce.valid_until_dt_tm > sysdate
     AND ce.view_level=1
     AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
    mf_cs8_active_cd)))))
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.encntr_alias_type_cd=mf_cs319_fin)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.birth_dt_tm <= cnvtdatetime(md_age))
   JOIN (mrn
   WHERE mrn.encntr_id=e.encntr_id
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn)
   JOIN (sa
   WHERE sa.person_id=e.person_id
    AND sa.active_ind=1
    AND sa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (chtd
   WHERE chtd.person_id=sa.updt_id)
   JOIN (sr
   WHERE sr.shx_activity_id=sa.shx_activity_id
    AND sr.active_ind=1
    AND sr.task_assay_cd IN (mf_cs14003_tobaccouse))
   JOIN (sar
   WHERE sar.shx_response_id=sr.shx_response_id)
   JOIN (n
   WHERE n.nomenclature_id=sar.nomenclature_id
    AND n.source_string_keycap IN ("4 OR LESS CIGARETTES(LESS THAN 1/4 PACK)/DAY IN LAST 30 DAYS",
   "5-9 CIGARETTES (BETWEEN 1/4 TO 1/2 PACK)/DAY IN LAST 30 DAYS",
   "10 OR MORE CIGARETTES (1/2 PACK OR MORE)/DAY IN LAST 30 DAYS",
   "CIGARS OR PIPES DAILY WITHIN LAST 30 DAYS", "SMOKER, CURRENT STATUS UNKNOWN"))
  ORDER BY facility, nurse_unit, sort_name,
   sr.task_assay_cd, sa.perform_dt_tm DESC
  HEAD REPORT
   IF (size(patients->patients,5)=0)
    stat = alterlist(patients->patients,10), ml_cnt_pat = 0
   ELSEIF (size(patients->patients,5) > 0)
    ml_cnt_pat = size(patients->patients,5), stat = alterlist(patients->patients,(ml_cnt_pat+ 9))
   ENDIF
  HEAD sort_name
   ml_cnt_pat += 1
   IF (mod(ml_cnt_pat,10)=1
    AND ml_cnt_pat > 1)
    stat = alterlist(patients->patients,(ml_cnt_pat+ 9))
   ENDIF
   patients->patients[ml_cnt_pat].encntr_id = e.encntr_id, patients->patients[ml_cnt_pat].person_id
    = e.person_id
  FOOT REPORT
   stat = alterlist(patients->patients,ml_cnt_pat), ml_cnt_pat = 0
  WITH nocounter
 ;end select
 IF (size(patients->patients) > 0)
  SET patients->status_data.status = "S"
 ELSE
  SET patients->status_data.status = "Z"
 ENDIF
END GO
