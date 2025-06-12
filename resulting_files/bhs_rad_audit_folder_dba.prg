CREATE PROGRAM bhs_rad_audit_folder:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE order_catalog_disp = f8
 DECLARE catalog_type_cd_disp = f8
 SET catalog_type_disp = uar_get_code_by("MEANING",6000,"RADIOLOGY")
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
  e.catalog_cd, e.image_class_type_cd, e.lib_group_cd,
  catalog_type_disp
  FROM exam_folder e,
   order_catalog o
  PLAN (e)
   JOIN (o
   WHERE e.catalog_cd=o.catalog_cd
    AND o.catalog_type_cd=2517)
  ORDER BY o.catalog_cd
  WITH maxrec = 150000, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
