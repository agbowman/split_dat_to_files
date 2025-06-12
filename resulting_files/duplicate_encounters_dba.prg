CREATE PROGRAM duplicate_encounters:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  ea.encntr_id, ea.alias, ea2.encntr_id
  FROM encntr_alias ea,
   encntr_alias ea2
  PLAN (ea
   WHERE ea.encntr_alias_type_cd=1077.00
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.beg_effective_dt_tm > cnvtdatetime((curdate - 20),0))
   JOIN (ea2
   WHERE ea2.alias=ea.alias
    AND ea2.active_ind=1
    AND ea2.encntr_alias_type_cd=ea.encntr_alias_type_cd
    AND ea2.encntr_alias_id != ea.encntr_alias_id)
  WITH nocounter, separator = " ", format
 ;end select
END GO
