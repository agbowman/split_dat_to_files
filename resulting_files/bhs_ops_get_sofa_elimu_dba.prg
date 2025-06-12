CREATE PROGRAM bhs_ops_get_sofa_elimu:dba
 EXECUTE bhs_check_domain:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 unit[*]
     2 f_unit_cd = f8
     2 s_unit_disp = vc
   1 cat[*]
     2 f_cd = f8
     2 s_disp = vc
   1 pat[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
 ) WITH protect
 FREE RECORD m_request
 RECORD m_request(
   1 f_person_id = f8
   1 f_encntr_id = f8
   1 s_json = vc
 ) WITH protect
 FREE RECORD m_reply
 RECORD m_reply(
   1 f_person_id = f8
   1 f_encntr_id = f8
   1 s_sofa = vc
   1 s_comment = vc
 )
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_cs71_ed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_cs71_inpat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_cs6000_lab_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3081"))
 DECLARE mf_cs6000_resp_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!1302732"))
 DECLARE ms_acct_id = vc WITH protect, noconstant("9aab0e36-f282-472e-85a2-0f7aeded518d")
 DECLARE ms_acct_secret = vc WITH protect, noconstant("6lIJTMhILT9pgKpvaioOjlq6uo7uKFSt")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp1 = i4 WITH protect, noconstant(0)
 DECLARE ml_exp2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 IF (gl_bhs_prod_flag=0)
  SET ms_acct_id = "9aab0e36-f282-472e-85a2-0f7aeded518d"
  SET ms_acct_secret = "6lIJTMhILT9pgKpvaioOjlq6uo7uKFSt"
 ELSE
  SET ms_acct_id = "1c9444ea-1824-4e3d-bd27-4da73c9c8a18"
  SET ms_acct_secret = "TIRIzEC9u7C1ST2OeS-L59uZRwMaOsCA"
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.cdf_meaning="NURSEUNIT"
   AND cv.display_key IN ("MICU", "SICU", "NCCU", "NIU", "HVCC",
  "CARE", "D5A", "D6B", "SW5", "ICCU",
  "ICU", "ICUN", "ESHLD")
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1,
   CALL alterlist(m_rec->unit,pl_cnt), m_rec->unit[pl_cnt].f_unit_cd = cv.code_value,
   m_rec->unit[pl_cnt].s_unit_disp = trim(cv.display,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=200
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.display IN ("ABG (Lab) POC Cartridge", "Critical Care ABG wLactate POC Cartridge",
  "Critical Care ABG POC Cartridge", "ABG w/Lactate (Lab) POC Cartridge",
  "ABG w/Lactate POC Cartridge",
  "ABG POC Cartridge", "Ventilator (Pressure Control)", "Ventilator (Assist Control)",
  "Ventilator Adult Oscillator", "Ventilator (APRV)",
  "Ventilator APRV", "Ventilator (PRVC)", "Ventilatory Targets - ECMO patient", "Ventilator",
  "Ventilator (Pressure Control with PSV)",
  "Ventilator (SIMV)", "Ventilator (Pressure Support)", "Ventilator (CPAP)",
  "Ventilator (Adult Oscillator)")
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1,
   CALL alterlist(m_rec->cat,pl_cnt), m_rec->cat[pl_cnt].f_cd = cv.code_value,
   m_rec->cat[pl_cnt].s_disp = trim(cv.display,3)
  WITH nocounter
 ;end select
 CALL echo("main select")
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e,
   orders o,
   person p
  PLAN (ed
   WHERE ed.beg_effective_dt_tm > cnvtdatetime("01-oct-2019")
    AND ed.active_ind=1
    AND expand(ml_exp1,1,size(m_rec->unit,5),ed.loc_nurse_unit_cd,m_rec->unit[ml_exp1].f_unit_cd)
    AND ed.end_effective_dt_tm > sysdate)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd IN (mf_cs71_ed_cd, mf_cs71_inpat_cd)
    AND e.active_ind=1)
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.person_id=e.person_id
    AND o.catalog_type_cd IN (mf_cs6000_lab_cd, mf_cs6000_resp_cd)
    AND expand(ml_exp2,1,size(m_rec->cat,5),o.catalog_cd,m_rec->cat[ml_exp2].f_cd))
   JOIN (p
   WHERE p.person_id=e.person_id)
  HEAD REPORT
   pl_cnt = 0
  HEAD e.encntr_id
   IF (((trim(uar_get_displaykey(e.loc_nurse_unit_cd),3) != "ESHLD") OR (trim(uar_get_displaykey(e
     .loc_nurse_unit_cd),3)="ESHLD"
    AND datetimediff(sysdate,p.birth_dt_tm) >= 7665
    AND trim(cnvtupper(uar_get_displaykey(o.catalog_cd)),3)="ABG*")) )
    CALL echo(build2("unit: ",uar_get_code_display(e.loc_nurse_unit_cd))), pl_cnt += 1
    IF (pl_cnt > size(m_rec->pat,5))
     CALL alterlist(m_rec->pat,(pl_cnt+ 30))
    ENDIF
    m_rec->pat[pl_cnt].f_encntr_id = e.encntr_id, m_rec->pat[pl_cnt].f_person_id = e.person_id
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->pat,pl_cnt)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->pat,5))),
   encntr_alias ea
  PLAN (d)
   JOIN (ea
   WHERE (ea.encntr_id=m_rec->pat[d.seq].f_encntr_id)
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=1077)
  ORDER BY d.seq
  HEAD REPORT
   CALL echo("encntr        fin")
  HEAD d.seq
   CALL echo(build2(trim(cnvtstring(ea.encntr_id),3),"    ",trim(ea.alias,3)))
  WITH nocounter
 ;end select
 CALL echo("start loop - build json")
 FOR (ml_loop = 1 TO size(m_rec->pat,5))
  IF (ml_loop=1)
   SET ms_tmp = concat('{"DATA":[')
  ELSE
   SET ms_tmp = concat(ms_tmp,",")
  ENDIF
  SET ms_tmp = concat(ms_tmp,'{"PERSON_ID":"',trim(cnvtstring(m_rec->pat[ml_loop].f_person_id),3),
   '","ENCNTR_ID":"',trim(cnvtstring(m_rec->pat[ml_loop].f_encntr_id),3),
   '"}')
 ENDFOR
 SET ms_tmp = concat(ms_tmp,"]}")
 SET m_request->s_json = ms_tmp
 EXECUTE bhs_svc_get_sofa_elimu2
 SET reply->status_data[1].status = "S"
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
