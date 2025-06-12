CREATE PROGRAM bhs_rad_audit_replace_grouping:dba
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
  r_catalog_disp = uar_get_code_display(r.catalog_cd), r_replace_catalog_disp = uar_get_code_display(
   r.replace_catalog_cd), r.rowid,
  r.updt_applctx, r.updt_cnt, r.updt_dt_tm,
  r.updt_id, r.updt_task
  FROM replace_grouping r
  ORDER BY r_catalog_disp
  WITH maxrec = 150000, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
