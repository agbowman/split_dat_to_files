CREATE PROGRAM djh_l_prsnl_org_reltn_type
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
  po.active_ind, po.active_status_cd, po_active_status_disp = uar_get_code_display(po
   .active_status_cd),
  po.active_status_dt_tm, po.beg_effective_dt_tm, po.end_effective_dt_tm,
  po.organization_id, po.prsnl_id, po.prsnl_org_reltn_type_cd,
  po_prsnl_org_reltn_type_disp = uar_get_code_display(po.prsnl_org_reltn_type_cd), po
  .prsnl_org_reltn_type_id, po.updt_applctx,
  po.updt_cnt, po.updt_dt_tm, po.updt_id,
  po.updt_task
  FROM prsnl_org_reltn_type po
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
