CREATE PROGRAM dta_ec_query
 PROMPT
  "Output to File/Printer/MINE " = mine
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 60
 ENDIF
 SELECT INTO  $1
  d.task_assay_cd, d_task_assay_disp = uar_get_code_display(d.task_assay_cd), d.event_cd,
  v.event_cd, v_event_disp = uar_get_code_display(v.event_cd), v.event_cd_disp
  FROM discrete_task_assay d,
   v500_event_code v
  PLAN (d
   WHERE d.task_assay_cd >= 60000)
   JOIN (v
   WHERE d.event_cd=v.event_cd)
  ORDER BY d.task_assay_cd, d_task_assay_disp, v.event_cd,
   v.event_cd_disp
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
