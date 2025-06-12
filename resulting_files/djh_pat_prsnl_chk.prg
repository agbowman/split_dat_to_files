CREATE PROGRAM djh_pat_prsnl_chk
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(_separator)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 30
 ENDIF
 SELECT INTO  $OUTDEV
  p.name_full_formatted, p.person_id, pp.person_id,
  pp.person_prsnl_reltn_id, pp.prsnl_person_id, pp_person_prsnl_r_disp = uar_get_code_display(pp
   .person_prsnl_r_cd),
  pp.person_prsnl_r_cd, pr.person_id, pr.name_full_formatted
  FROM person p,
   person_prsnl_reltn pp,
   prsnl pr
  PLAN (p
   WHERE p.name_last_key="MENDEZ*"
    AND p.name_first_key="MAG*")
   JOIN (pp
   WHERE p.person_id=pp.person_id)
   JOIN (pr
   WHERE pp.prsnl_person_id=pr.person_id)
  WITH maxrec = 20, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
