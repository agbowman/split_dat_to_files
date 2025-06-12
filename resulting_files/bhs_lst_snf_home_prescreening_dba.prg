CREATE PROGRAM bhs_lst_snf_home_prescreening:dba
 CALL echo("LAST MOD: 001")
 CALL echo("LAST MOD DATE: 1/15/2025 ")
 CALL echo("LAST MOD BY: Joe Fenton")
 DECLARE mf_cs71_emergency = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY")), protect
 DECLARE mf_cs71_observation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")),
 protect
 DECLARE mf_cs71_daystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY")), protect
 DECLARE mf_cs71_inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 DECLARE mf_cs62_ma = f8 WITH constant(uar_get_code_by("DESCRIPTION",62,"Massachusetts")), protect
 DECLARE mf_cs72_highriskcriteriascreen = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "HIGHRISKCRITERIASCREEN")), protect
 DECLARE mf_cs72_livingsituation = f8 WITH constant(uar_get_code_by_cki("CKI.EC!5993")), protect
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
  FROM clinical_event ce,
   clinical_event ce1,
   encounter e,
   encntr_domain ed,
   address a,
   person p
  PLAN (ed
   WHERE ed.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ed.loc_building_cd > 0
    AND ed.loc_nurse_unit_cd > 0
    AND parser(fac_where))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd IN (mf_cs71_daystay, mf_cs71_inpatient, mf_cs71_emergency,
   mf_cs71_observation)
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND e.disch_dt_tm=null)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.birth_dt_tm <= cnvtdatetime(md_age))
   JOIN (a
   WHERE a.parent_entity_id=p.person_id
    AND a.address_type_cd=value(uar_get_code_by("MEANING",212,"HOME"))
    AND a.parent_entity_name="PERSON"
    AND a.active_ind=1
    AND a.state_cd=mf_cs62_ma
    AND a.city IN ("AGAWAM", "CHICOPEE", "EAST LONGMEADOW", "FEEDING HILLS", "HOLYOKE",
   "LONGMEADOW", "SPRINGFIELD", "WEST SPRINGFIELD", "WESTFIELD", "WILBRAHAM"))
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.person_id=e.person_id
    AND ce.valid_until_dt_tm > sysdate
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
   mf_cs8_active_cd)
    AND ce.event_cd=mf_cs72_livingsituation
    AND ((cnvtupper(ce.result_val)=patstring("*ASSISTED LIVING*")) OR (((cnvtupper(ce.result_val)=
   patstring("*ENTENDED CARE FACILITY*")) OR (((cnvtupper(ce.result_val)=patstring(
    "*HOME INDEPENDENTLY*")) OR (((cnvtupper(ce.result_val)=patstring("*HOME WITH DAY CARE*")) OR (((
   cnvtupper(ce.result_val)=patstring("*HOME WITH FAMILY CARE*")) OR (((cnvtupper(ce.result_val)=
   patstring("*HOME WITH FAMILY*")) OR (((cnvtupper(ce.result_val)=patstring(
    "*HOME WITH HOME HEALTH*")) OR (((cnvtupper(ce.result_val)=patstring(
    "*HOME WITH INFUSION THERAPY*")) OR (((cnvtupper(ce.result_val)=patstring(
    "*HOME WITH RESPONSIBLE CAREGIVER*")) OR (((cnvtupper(ce.result_val)=patstring(
    "*HOME WITH TELEHEALTH*")) OR (((cnvtupper(ce.result_val)=patstring("*REHABILITATION UNIT*")) OR
   (cnvtupper(ce.result_val)=patstring("*SKILLED NURSING FACILITY*"))) )) )) )) )) )) )) )) )) )) ))
   )
   JOIN (ce1
   WHERE ce1.encntr_id=e.encntr_id
    AND ce1.person_id=p.person_id
    AND ce1.valid_until_dt_tm > sysdate
    AND ce1.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
   mf_cs8_active_cd)
    AND ce1.event_cd=mf_cs72_highriskcriteriascreen
    AND ((cnvtupper(ce1.result_val)=patstring(
    "*ANTICIPATE NEED TO TRANSFER TO SKILLED NURSING FACILITY*")) OR (cnvtupper(ce1.result_val)=
   patstring("*ANTICIPATE NEED FOR CERTIFIED HOME CARE SERVICES*"))) )
  ORDER BY ed.person_id
  HEAD REPORT
   stat = alterlist(patients->patients,10)
  HEAD ed.person_id
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
