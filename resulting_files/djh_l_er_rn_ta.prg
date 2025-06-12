CREATE PROGRAM djh_l_er_rn_ta
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
  pn.active_ind, pn.active_status_cd, pn_active_status_disp = uar_get_code_display(pn
   .active_status_cd),
  pn.active_status_dt_tm, pn.active_status_prsnl_id, pn.change_bit,
  pn.name_degree, pn.name_first, pn.name_first_key,
  pn.name_first_key_nls, pn.name_full, pn.name_initials,
  pn.name_last, pn.name_last_key, pn.name_last_key_nls,
  pn.name_middle, pn.name_middle_key, pn.name_middle_key_nls,
  pn.name_prefix, pn.name_suffix, pn.name_title,
  pn.name_type_cd, pn_name_type_disp = uar_get_code_display(pn.name_type_cd), pn.person_id,
  pn.person_name_hist_id, pn.person_name_id, pn.pm_hist_tracking_id,
  pn.rowid, pn.tracking_bit, pn.transaction_dt_tm,
  pn.updt_applctx, pn.updt_cnt, pn.updt_dt_tm,
  pn.updt_id, pn.updt_task
  FROM person_name_hist pn
  ORDER BY pr.position_cd, pr.name_full_formatted, p.person_id
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36
  HEAD p.person_id
   y_pos = (y_pos+ 24)
  FOOT  p.person_id
   y_pos = (y_pos+ 0)
  WITH maxrec = 5, maxcol = 300, maxrow = 500,
   dio = 08, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
