CREATE PROGRAM bhs_access_by_location
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "start date" = curdate,
  "end date" = curdate
  WITH prompt1, prompt2, prompt3
 SET name = substring(1,10,curprog)
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 15
 ENDIF
 SELECT DISTINCT INTO  $1
  patient = p.name_full_formatted, mrn = trim(ea.alias), provider = pr.name_full_formatted,
  username = pr.username, access_date = pp.ppa_first_dt_tm"mm/dd/yyyy hh:mm:SS ;;q"
  FROM person p,
   prsnl pr,
   person_prsnl_activity pp,
   encounter e,
   encntr_alias ea
  PLAN (pp
   WHERE pp.ppa_first_dt_tm BETWEEN cnvtdatetime(cnvtdate( $2),000000) AND cnvtdatetime(cnvtdate( $3),
    235959))
   JOIN (p
   WHERE p.person_id=pp.person_id)
   JOIN (pr
   WHERE pr.person_id=pp.prsnl_id)
   JOIN (e
   WHERE e.person_id=p.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=1079
    AND ea.end_effective_dt_tm > sysdate
    AND ea.active_ind=1)
  ORDER BY pr.name_full_formatted, p.name_full_formatted, access_date
  WITH nocounter, separator = " ", format
 ;end select
END GO
