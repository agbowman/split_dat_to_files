CREATE PROGRAM djh_rn_name_chgs
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
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  pr.person_id, pr.name_last, p.name_full,
  pr.username, p.updt_cnt, pr.position_cd,
  pr_position_disp = uar_get_code_display(pr.position_cd), p.active_ind, p.active_status_cd,
  p_active_status_disp = uar_get_code_display(p.active_status_cd), p.active_status_dt_tm, p
  .active_status_prsnl_id,
  p.beg_effective_dt_tm, p.data_status_cd, p_data_status_disp = uar_get_code_display(p.data_status_cd
   ),
  p.data_status_dt_tm, p.data_status_prsnl_id, p.end_effective_dt_tm,
  p.name_first, p.name_first_key, p.name_initials,
  p.name_last, p.name_last_key, p.name_middle,
  p.name_middle_key, p.name_type_cd, p_name_type_disp = uar_get_code_display(p.name_type_cd),
  p.name_type_seq, p.person_id, p.person_name_id,
  p.updt_dt_tm, p.updt_id
  FROM prsnl pr,
   person_name p
  PLAN (pr
   WHERE ((pr.position_cd=719555) OR (((pr.position_cd=1465246) OR (((pr.position_cd=36409588) OR (((
   pr.position_cd=1713124) OR (((pr.position_cd=984626) OR (((pr.position_cd=35742679) OR (((pr
   .position_cd=2063502) OR (pr.position_cd=966302)) )) )) )) )) )) )) )
   JOIN (p
   WHERE pr.person_id=p.person_id)
  ORDER BY p.updt_dt_tm DESC, pr.person_id
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36
  WITH maxrec = 100, maxcol = 300, maxrow = 500,
   dio = 08, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
