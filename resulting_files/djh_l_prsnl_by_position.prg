CREATE PROGRAM djh_l_prsnl_by_position
 PROMPT
  "Act/InAct" = 1,
  "Output to File/Printer/MINE" = "MINE"
  WITH actflg, outdev
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
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.name_full_formatted, p.person_id, p_position_disp = uar_get_code_display(p.position_cd),
  p.position_cd, p.username, begdtdttm = format(p.beg_effective_dt_tm,"@SHORTDATETIME"),
  enddttm = format(p.end_effective_dt_tm,"@SHORTDATETIME"), updttm = format(p.updt_dt_tm,
   "@SHORTDATETIME"), p.updt_id,
  p1.name_full_formatted
  FROM prsnl p,
   prsnl p1
  PLAN (p
   WHERE (p.active_ind= $ACTFLG)
    AND p.active_status_cd != 194
    AND ((p.position_cd=1465246) OR (((p.position_cd=36409588) OR (((p.position_cd=36572393) OR (p
   .position_cd=1465245)) )) )) )
   JOIN (p1
   WHERE p.updt_id=p1.person_id)
  ORDER BY p_position_disp, p.name_full_formatted
  WITH maxcol = 170, maxrow = 48, landscape,
   compress, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
