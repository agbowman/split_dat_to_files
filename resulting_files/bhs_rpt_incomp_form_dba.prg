CREATE PROGRAM bhs_rpt_incomp_form:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date:" = "CURDATE",
  "End date:" = "CURDATE",
  "Forms:" = 0,
  "Facility:" = 0,
  "Nursing unit(s):" = 0
  WITH outdev, ms_start_dt, ms_end_dt,
  ml_form_cd, mf_facilities_cd, mf_units_cd
 RECORD m_rec(
   1 m_fac[*]
     2 ms_fac_name = vc
     2 mf_fac_cd = f8
     2 m_unit[*]
       3 ms_unit_name = vc
       3 mf_unit_cd = f8
       3 m_form[*]
         4 ms_pat_name = vc
         4 ms_fin = vc
         4 ms_admit_dt = vc
         4 ms_physicion = vc
         4 ms_form_name = vc
         4 ms_create_dt = vc
         4 ms_form_status = vc
   1 m_type[*]
     2 ms_form_name = vc
     2 mf_form_cd = f8
   1 m_grp_fac[*]
     2 ms_fac_name = vc
 ) WITH protect
 DECLARE mf_start_dt = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_START_DT,"DD-MMM-YYYY"),
   000000))
 DECLARE mf_end_dt = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_END_DT,"DD-MMM-YYYY"),
   235959))
 DECLARE mn_fac_param = i2 WITH protect, constant(5)
 DECLARE mn_nur_param = i2 WITH protect, constant(6)
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_pcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE mf_build_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",222,"BUILDINGS"))
 DECLARE mf_facil_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",222,"FACILITYS"))
 DECLARE mf_lunit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",222,"NURSEUNITS"))
 DECLARE ml_fac_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_unit_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_form_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_typf_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_log = vc WITH protect, noconstant("SUCCESS")
 DECLARE ms_data_type = vc WITH protect, noconstant(" ")
 DECLARE ms_fac = vc WITH protect, noconstant(" ")
 DECLARE ms_unit = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 IF (mf_start_dt >= mf_end_dt)
  SET ms_log = "Start date must be less than End date. Exit."
  GO TO exit_script
 ENDIF
 CALL alterlist(m_rec->m_grp_fac,1)
 IF (( $ML_FORM_CD=1))
  CALL alterlist(m_rec->m_grp_fac,2)
  SET m_rec->m_grp_fac[1].ms_fac_name = "Admission*"
  SET m_rec->m_grp_fac[2].ms_fac_name = "Daystay Assessment"
 ELSEIF (( $ML_FORM_CD=2))
  SET m_rec->m_grp_fac[1].ms_fac_name = "Biophysical*"
 ELSEIF (( $ML_FORM_CD=3))
  SET m_rec->m_grp_fac[1].ms_fac_name = "Braden*"
 ELSEIF (( $ML_FORM_CD=4))
  SET m_rec->m_grp_fac[1].ms_fac_name = "CARE Unit Charge Guide"
 ELSEIF (( $ML_FORM_CD=5))
  SET m_rec->m_grp_fac[1].ms_fac_name = "Fall*"
 ELSEIF (( $ML_FORM_CD=6))
  SET m_rec->m_grp_fac[1].ms_fac_name = "Patient/Family Education*"
 ELSEIF (( $ML_FORM_CD=7))
  SET m_rec->m_grp_fac[1].ms_fac_name = "Safety Data*"
 ELSEIF (( $ML_FORM_CD=8))
  SET m_rec->m_grp_fac[1].ms_fac_name = "Valuables and Belongings*"
 ELSEIF (( $ML_FORM_CD=9))
  CALL alterlist(m_rec->m_grp_fac,2)
  SET m_rec->m_grp_fac[1].ms_fac_name = "Vaccine Influenza*"
  SET m_rec->m_grp_fac[2].ms_fac_name = "Vaccine Pneumococcal*"
 ELSEIF (( $ML_FORM_CD=10))
  SET m_rec->m_grp_fac[1].ms_fac_name = "Smoking History and Management*"
 ENDIF
 SELECT DISTINCT INTO "nl:"
  FROM dcp_forms_ref dfr,
   (dummyt d  WITH seq = size(m_rec->m_grp_fac,5))
  PLAN (d)
   JOIN (dfr
   WHERE dfr.active_ind=1
    AND operator(dfr.description,"LIKE",notrim(patstring(m_rec->m_grp_fac[d.seq].ms_fac_name,1))))
  ORDER BY dfr.description
  DETAIL
   ml_typf_cnt = (ml_typf_cnt+ 1)
   IF (mod(ml_typf_cnt,100)=1)
    CALL alterlist(m_rec->m_type,(ml_typf_cnt+ 99))
   ENDIF
   m_rec->m_type[ml_typf_cnt].mf_form_cd = dfr.dcp_forms_ref_id, m_rec->m_type[ml_typf_cnt].
   ms_form_name = trim(dfr.description)
  FOOT REPORT
   CALL alterlist(m_rec->m_type,ml_typf_cnt)
  WITH nocounter
 ;end select
 SET ms_data_type = reflect(parameter(mn_fac_param,0))
 IF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = cnvtstring(parameter(mn_fac_param,ml_cnt),20)
   IF (ml_cnt=1)
    SET ms_fac = concat(" e.loc_facility_cd in (",trim(ms_tmp_str))
   ELSE
    SET ms_fac = concat(ms_fac,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_fac = concat(ms_fac,")")
 ELSEIF (substring(1,2,ms_data_type)="C1")
  SET ms_fac = parameter(mn_fac_param,1)
  IF (trim(ms_fac)=char(42))
   SET ms_fac = " 1=1"
  ENDIF
 ELSE
  SET ms_fac = cnvtstring(parameter(mn_fac_param,1),20)
  SET ms_fac = concat(" e.loc_facility_cd = ",trim(ms_fac))
 ENDIF
 SET ms_data_type = reflect(parameter(mn_nur_param,0))
 IF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = cnvtstring(parameter(mn_nur_param,ml_cnt),20)
   IF (ml_cnt=1)
    SET ms_unit = concat(" e.loc_nurse_unit_cd in (",trim(ms_tmp_str))
   ELSE
    SET ms_unit = concat(ms_unit,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_unit = concat(ms_unit,")")
 ELSEIF (substring(1,2,ms_data_type)="C1")
  SET ms_unit = parameter(mn_nur_param,1)
  IF (trim(ms_unit)=char(42))
   SET ms_unit = " 1=1"
  ENDIF
 ELSE
  SET ms_unit = cnvtstring(parameter(mn_nur_param,1),20)
  SET ms_unit = concat(" e.loc_nurse_unit_cd = ",trim(ms_unit))
 ENDIF
 SET ml_fac_cnt = 0
 SET ml_unit_cnt = 0
 SELECT INTO "nl:"
  FROM dcp_forms_activity dfa,
   encounter e,
   encntr_alias ea,
   person p,
   person p2,
   person_prsnl_reltn ppr
  PLAN (dfa
   WHERE dfa.flags=1
    AND dfa.form_dt_tm >= cnvtdatetime(mf_start_dt)
    AND dfa.form_dt_tm <= cnvtdatetime(mf_end_dt)
    AND expand(ml_cnt,1,size(m_rec->m_type,5),dfa.dcp_forms_ref_id,m_rec->m_type[ml_cnt].mf_form_cd))
   JOIN (e
   WHERE e.encntr_id=dfa.encntr_id
    AND e.end_effective_dt_tm > sysdate
    AND e.beg_effective_dt_tm < sysdate
    AND e.active_ind=1
    AND parser(ms_unit)
    AND parser(ms_fac))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate
    AND p.active_ind=1)
   JOIN (ppr
   WHERE ppr.person_id=p.person_id
    AND ppr.person_prsnl_r_cd=mf_pcp_cd
    AND ppr.beg_effective_dt_tm < sysdate
    AND ppr.end_effective_dt_tm > sysdate
    AND ppr.active_ind=1)
   JOIN (p2
   WHERE p2.person_id=ppr.prsnl_person_id
    AND p2.beg_effective_dt_tm < sysdate
    AND p2.end_effective_dt_tm > sysdate
    AND p2.active_ind=1)
  ORDER BY uar_get_code_display(e.loc_facility_cd), uar_get_code_display(e.loc_nurse_unit_cd), dfa
   .beg_activity_dt_tm
  HEAD e.loc_facility_cd
   ml_fac_cnt = (ml_fac_cnt+ 1)
   IF (mod(ml_fac_cnt,100)=1)
    CALL alterlist(m_rec->m_fac,(ml_fac_cnt+ 99))
   ENDIF
   m_rec->m_fac[ml_fac_cnt].ms_fac_name = uar_get_code_display(e.loc_facility_cd), m_rec->m_fac[
   ml_fac_cnt].mf_fac_cd = e.loc_facility_cd, ml_unit_cnt = 0
  HEAD e.loc_nurse_unit_cd
   ml_unit_cnt = (ml_unit_cnt+ 1)
   IF (mod(ml_unit_cnt,100)=1)
    CALL alterlist(m_rec->m_fac[ml_fac_cnt].m_unit,(ml_unit_cnt+ 99))
   ENDIF
   m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].ms_unit_name = uar_get_code_display(e
    .loc_nurse_unit_cd), m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].mf_unit_cd = e
   .loc_nurse_unit_cd, ml_form_cnt = 0
  DETAIL
   ml_form_cnt = (ml_form_cnt+ 1)
   IF (mod(ml_form_cnt,100)=1)
    CALL alterlist(m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form,(ml_form_cnt+ 99))
   ENDIF
   m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[ml_form_cnt].ms_pat_name = trim(p
    .name_full_formatted), m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[ml_form_cnt].ms_fin =
   trim(ea.alias), m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[ml_form_cnt].ms_admit_dt =
   format(e.arrive_dt_tm,"mm/dd/yy hh:mm;;d"),
   m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[ml_form_cnt].ms_physicion = trim(p2
    .name_full_formatted), m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[ml_form_cnt].
   ms_form_name = trim(dfa.description), m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[
   ml_form_cnt].ms_create_dt = format(dfa.beg_activity_dt_tm,"mm/dd/yy hh:mm;;d"),
   m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[ml_form_cnt].ms_form_status = trim(
    uar_get_code_display(dfa.form_status_cd))
  FOOT  e.loc_nurse_unit_cd
   CALL alterlist(m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form,ml_form_cnt)
  FOOT  e.loc_facility_cd
   CALL alterlist(m_rec->m_fac[ml_fac_cnt].m_unit,ml_unit_cnt)
  FOOT REPORT
   CALL alterlist(m_rec->m_fac,ml_fac_cnt)
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  FROM (dummyt d1  WITH seq = value(size(m_rec->m_fac,5))),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->m_fac[d1.seq].m_unit,5)))
   JOIN (d2
   WHERE maxrec(d3,size(m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form,5)))
   JOIN (d3)
  ORDER BY m_rec->m_fac[d1.seq].ms_fac_name, m_rec->m_fac[d1.seq].m_unit[d2.seq].ms_unit_name, m_rec
   ->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].ms_pat_name,
   m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].ms_create_dt
  HEAD d1.seq
   col 0, "Facility: ", m_rec->m_fac[d1.seq].ms_fac_name,
   row + 1
  HEAD d2.seq
   col 5, "Nursing Unit: ", m_rec->m_fac[d1.seq].m_unit[d2.seq].ms_unit_name,
   row + 1, col 10, "Patient Full Name",
   col 40, "Account #", col 60,
   "Admit Date", col 77, "Primary Physicion",
   col 118, "Form", col 158,
   "Form Date", col 175, "Form Status",
   row + 1
  DETAIL
   col 10, m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].ms_pat_name, col 40,
   m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].ms_fin, col 60, m_rec->m_fac[d1.seq].m_unit[d2
   .seq].m_form[d3.seq].ms_admit_dt,
   col 77, m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].ms_physicion, col 118,
   m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].ms_form_name, col 158, m_rec->m_fac[d1.seq].
   m_unit[d2.seq].m_form[d3.seq].ms_create_dt,
   col 175, m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].ms_form_status, row + 1
  WITH nocounter, maxcol = 200
 ;end select
#exit_script
 IF (ms_log != "SUCCESS")
  SELECT INTO  $OUTDEV
   HEAD REPORT
    col 0, ms_log
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD m_rec
END GO
