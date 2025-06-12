CREATE PROGRAM bhs_lst_norepi_levophed_team:dba
 CALL echo("LAST MOD: 001")
 CALL echo("LAST MOD DATE: 07/05/2024")
 CALL echo("LAST MOD BY: Joe Fenton")
 DECLARE mf_cs6004_completed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED")),
 protect
 DECLARE mf_cs6004_ordered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE mf_cs6000_pharmacy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY")),
 protect
 DECLARE mf_cs339_census = f8 WITH constant(uar_get_code_by("DISPLAYKEY",339,"CENSUS")), protect
 DECLARE mf_cs71_inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT")), protect
 DECLARE mf_cs_71_emergency = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY")), protect
 DECLARE mf_cs71_observation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")),
 protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE ml_cnt_pat = i4 WITH noconstant(0), protect
 DECLARE md_age = dq8 WITH constant(cnvtagedatetime(18,0,0,0)), protect
 DECLARE ml_num = i4 WITH noconstant(0), protect
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
 FREE RECORD catcodes
 RECORD catcodes(
   1 cntcats = i4
   1 codes[*]
     2 cat_cd = f8
 )
 SET modify = predeclare
 SET patients->status_data.status = "F"
 SET valuecnt = size(definition->parameters[1].values,5)
 SELECT INTO "nl:"
  FROM order_catalog oc
  PLAN (oc
   WHERE cnvtupper(oc.description) IN ("*NOREPINEPHRINE*", "*LEVOPHED*", "*MIDODRINE*")
    AND oc.active_ind=1
    AND oc.catalog_type_cd=mf_cs6000_pharmacy)
  ORDER BY oc.catalog_cd
  HEAD REPORT
   stat = alterlist(catcodes->codes,10)
  HEAD oc.catalog_cd
   catcodes->cntcats += 1
   IF (mod(catcodes->cntcats,10)=1
    AND (catcodes->cntcats > 1))
    stat = alterlist(catcodes->codes,(catcodes->cntcats+ 9))
   ENDIF
   catcodes->codes[catcodes->cntcats].cat_cd = oc.catalog_cd
  FOOT REPORT
   stat = alterlist(catcodes->codes,catcodes->cntcats)
  WITH nocounter
 ;end select
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
  FROM orders o,
   encntr_domain ed,
   encounter e,
   person p
  PLAN (o
   WHERE o.active_ind=1
    AND o.active_status_cd=mf_cs48_active
    AND o.template_order_flag IN (1, 0)
    AND o.catalog_type_cd=mf_cs6000_pharmacy
    AND o.order_status_cd IN (mf_cs6004_ordered, mf_cs6004_completed)
    AND expand(ml_num,1,size(catcodes->codes,5),o.catalog_cd,catcodes->codes[ml_num].cat_cd))
   JOIN (ed
   WHERE ed.encntr_id=o.encntr_id
    AND ed.person_id=o.person_id
    AND ed.encntr_domain_type_cd=mf_cs339_census
    AND ed.active_ind=1
    AND parser(fac_where)
    AND ed.loc_nurse_unit_cd IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=220
     AND cv.display_key IN ("ESA", "ESB", "ESC", "ESD", "ESE",
    "ESHLD")
     AND cv.cdf_meaning IN ("AMBULATORY", "NURSEUNIT")
     AND cv.active_ind=1
    WITH ncounter, time = 60)))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.active_status_cd=mf_cs48_active
    AND e.encntr_type_cd IN (mf_cs71_inpatient, mf_cs71_observation, mf_cs_71_emergency)
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND e.disch_dt_tm=null
    AND e.loc_nurse_unit_cd IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=220
     AND cv.display_key IN ("ESA", "ESB", "ESC", "ESD", "ESE",
    "ESHLD")
     AND cv.cdf_meaning IN ("AMBULATORY", "NURSEUNIT")
     AND cv.active_ind=1
    WITH ncounter, time = 60)))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.birth_dt_tm <= cnvtdatetime(md_age))
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
  WITH nocounter, expand = 1
 ;end select
 IF (size(patients->patients) > 0)
  SET patients->status_data.status = "S"
 ELSE
  SET patients->status_data.status = "Z"
 ENDIF
END GO
