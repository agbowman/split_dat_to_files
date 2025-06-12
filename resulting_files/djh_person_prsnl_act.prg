CREATE PROGRAM djh_person_prsnl_act
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 300
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  pe.name_full_formatted, pr.name_full_formatted, pr_position_disp = uar_get_code_display(pr
   .position_cd),
  p_ppa_type_disp = uar_get_code_display(p.ppa_type_cd), xactdt = format(p.active_status_dt_tm,
   "@SHORTDATE"), p.active_status_prsnl_id,
  p.active_ind, p.person_id, pr.person_id,
  p.ppa_first_dt_tm, p.ppa_type_cd, p.ppr_cd,
  p_ppr_disp = uar_get_code_display(p.ppr_cd), p.prsnl_id, p.updt_dt_tm
  FROM person_prsnl_activity p,
   person pe,
   prsnl pr
  PLAN (p
   WHERE p.person_id=1228508)
   JOIN (pe
   WHERE p.person_id=pe.person_id)
   JOIN (pr
   WHERE p.active_status_prsnl_id=pr.person_id)
  ORDER BY pe.name_full_formatted, pr.name_full_formatted, xactdt,
   pr_position_disp, p_ppa_type_disp, 0
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
