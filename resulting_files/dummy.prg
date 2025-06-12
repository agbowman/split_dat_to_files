CREATE PROGRAM dummy
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 299
 ENDIF
 SELECT INTO  $OUTDEV
  pe.active_ind, pe.active_status_cd, pe_active_status_disp = uar_get_code_display(pe
   .active_status_cd),
  pe.active_status_dt_tm, pe.active_status_prsnl_id, pe.beg_effective_dt_tm,
  pe.create_dt_tm, pe.create_prsnl_id, pe.end_effective_dt_tm,
  pe.name_full_formatted, pe.person_id, pe.person_type_cd,
  pe_person_type_disp = uar_get_code_display(pe.person_type_cd), pe.updt_applctx, pe.updt_cnt,
  pe.updt_dt_tm, pe.updt_id, pe.updt_task
  FROM person pe
  WHERE pe.updt_id=754400
  WITH maxrec = 10, maxcol = 170, maxrow = 48,
   landscape, compress, format,
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
