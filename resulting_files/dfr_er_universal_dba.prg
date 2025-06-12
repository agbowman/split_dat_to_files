CREATE PROGRAM dfr_er_universal:dba
 SET call_echo = 1
 SET retval = - (1)
 SET log_message = " dfr_er_universal failed during execution "
 DECLARE iso_mnem = vc
 DECLARE mrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE fin_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 SELECT
  p1.name_full_formatted, p1.sex_cd, sex = uar_get_code_display(p1.sex_cd),
  p1.birth_dt_tm, dob = format(p1.birth_dt_tm,"mm/dd/yyyy;;q"), e1.encntr_id,
  e1.reg_dt_tm, adm = format(e1.reg_dt_tm,"mm/dd/yyyy hh:mm;;q"), pa.alias,
  ea.alias, n1.mnemonic, a.*
  FROM person p1,
   encounter e1,
   person_alias pa,
   encntr_alias ea,
   problem pr,
   nomenclature n1,
   allergy a,
   dummyt d1,
   dummyt d2
  PLAN (p1
   WHERE p1.person_id=850770
    AND p1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (e1
   WHERE e1.person_id=p1.person_id
    AND e1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pa
   WHERE pa.person_id=p1.person_id
    AND pa.person_alias_type_cd=mrn_cd
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (ea
   WHERE ea.encntr_id=e1.encntr_id
    AND ea.encntr_alias_type_cd=fin_cd
    AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d1)
   JOIN (pr
   WHERE pr.person_id=p1.person_id
    AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (n1
   WHERE n1.nomenclature_id=pr.nomenclature_id)
   JOIN (d2)
   JOIN (a
   WHERE a.person_id=p1.person_id
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   iso_mnem = trim(n.mnemonic)
  WITH check, nocounter, outerjoin = d1,
   outerjoin = d2, skipreport = 1
 ;end select
END GO
