CREATE PROGRAM care_set
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 45
 ENDIF
 SELECT INTO  $OUTDEV
  o.active_ind, o_catalog_type_disp = uar_get_code_display(o.catalog_type_cd), o_cs_index_disp =
  uar_get_code_display(o.cs_index_cd),
  o_catalog_disp = uar_get_code_display(o.catalog_cd), c_catalog_disp = uar_get_code_display(c
   .catalog_cd), c.updt_dt_tm
  FROM order_catalog o,
   cs_component c
  PLAN (o
   WHERE o.catalog_type_cd > 0
    AND o.active_ind=1)
   JOIN (c
   WHERE o.catalog_cd=c.catalog_cd
    AND c.updt_dt_tm < cnvtdatetime("15-AUG-2004 23:59:59.00"))
  ORDER BY o_catalog_type_disp, c.updt_dt_tm
  WITH time = value(maxsecs), format, skipreport = 1
 ;end select
END GO
