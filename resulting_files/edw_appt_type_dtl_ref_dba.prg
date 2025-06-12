CREATE PROGRAM edw_appt_type_dtl_ref:dba
 DECLARE appt_type_cnt = i4 WITH noconstant(0)
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 RECORD appt_type_keys(
   1 qual[*]
     2 appt_type_cd = f8
 )
 SELECT INTO "nl:"
  FROM sch_appt_type sat
  WHERE sat.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
  DETAIL
   appt_type_cnt = (appt_type_cnt+ 1)
   IF (mod(appt_type_cnt,10)=1)
    stat = alterlist(appt_type_keys->qual,(appt_type_cnt+ 9))
   ENDIF
   appt_type_keys->qual[appt_type_cnt].appt_type_cd = sat.appt_type_cd
  WITH nocounter
 ;end select
 IF (atdr_code_value="Y")
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
     AND cv.code_set=14230)
   DETAIL
    appt_type_cnt = (appt_type_cnt+ 1)
    IF (mod(appt_type_cnt,10)=1)
     stat = alterlist(appt_type_keys->qual,(appt_type_cnt+ 9))
    ENDIF
    appt_type_keys->qual[appt_type_cnt].appt_type_cd = cv.code_value
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   appt_type_cd = appt_type_keys->qual[d.seq].appt_type_cd
   FROM (dummyt d  WITH seq = value(appt_type_cnt))
   PLAN (d
    WHERE appt_type_cnt > 0)
   ORDER BY appt_type_cd
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), appt_type_keys->qual[cnt].appt_type_cd = appt_type_cd
   FOOT REPORT
    appt_type_cnt = cnt
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO value(apt_tp_r_extractfile)
  n_active_ind = nullind(sat.active_ind)
  FROM (dummyt d  WITH seq = value(appt_type_cnt)),
   sch_appt_type sat,
   code_value cv
  PLAN (d
   WHERE appt_type_cnt > 0)
   JOIN (sat
   WHERE (sat.appt_type_cd=appt_type_keys->qual[d.seq].appt_type_cd))
   JOIN (cv
   WHERE cv.code_value=sat.appt_type_cd)
  DETAIL
   col 0,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(sat.appt_type_cd,16))), v_bar,
   CALL print(trim(replace(cv.concept_cki,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(cv.cdf_meaning,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cv.display,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cv.description,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(cv.definition,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(sat.appt_type_flag))), v_bar,
   CALL print(trim(cnvtstring(sat.grp_prompt_cd,16))),
   v_bar,
   CALL print(trim(cnvtstring(sat.grp_resource_cd,16))), v_bar,
   CALL print(trim(cnvtstring(sat.person_accept_cd,16))), v_bar,
   CALL print(trim(cnvtstring(sat.recur_cd,16))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar,
   CALL print(trim(evaluate(n_active_ind,0,build(sat.active_ind)," "))),
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 FREE RECORD appt_type_keys
 CALL echo(build("APT_TP_R Count = ",curqual))
 CALL edwupdatescriptstatus("APT_TP_R",curqual,"4","4")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "004 08/27/07 YC3429"
END GO
