CREATE PROGRAM bhs_eks_audit_summary
 PROMPT
  "OUTPUT TO FILE/PRINTER/MINE" = "MINE",
  "SELECT MODULE" = "",
  "START DATE /TIME" = "SYSDATE",
  "END DATE / TIME" = "SYSDATE"
  WITH outdev, prompt2, prompt3,
  prompt4
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
  run_dt_tm = em.begin_dt_tm"@SHORTDATETIME", em.module_name, conclude =
  IF (em.conclude=0) "LOGIC FALSE"
  ELSEIF (em.conclude=1) "LOGIC TRUE"
  ELSEIF (em.conclude=2) "ACTION"
  ELSE "R - LOGIC TRUE"
  ENDIF
  ,
  em.logic_return, em.action_return, em.conclude,
  log1 = substring(1,3,em.logic_return), log2 = substring(4,3,em.logic_return), log3 = substring(7,3,
   em.logic_return),
  log4 = substring(10,3,em.logic_return), log5 = substring(13,3,em.logic_return), log6 = substring(16,
   3,em.logic_return),
  log7 = substring(19,3,em.logic_return), log8 = substring(22,3,em.logic_return), log9 = substring(25,
   3,em.logic_return),
  log10 = substring(28,3,em.logic_return), log11 = substring(31,3,em.logic_return), log12 = substring
  (34,3,em.logic_return),
  patent_name = substring(1,40,trim(p.name_full_formatted,3)), acctnumber = ea.alias, em.rec_id,
  e.logging
  FROM eks_module_audit em,
   eks_module_audit_det e,
   encounter en,
   person p,
   encntr_alias ea
  PLAN (em
   WHERE em.begin_dt_tm >= cnvtdatetime( $PROMPT3)
    AND em.end_dt_tm <= cnvtdatetime( $PROMPT4)
    AND (em.module_name= $PROMPT2))
   JOIN (e
   WHERE e.module_audit_id=em.rec_id
    AND e.template_name="EKS_EXEC_CCL_L")
   JOIN (en
   WHERE en.encntr_id=e.encntr_id)
   JOIN (ea
   WHERE ea.encntr_id=en.encntr_id
    AND ea.encntr_alias_type_cd=1077)
   JOIN (p
   WHERE p.person_id=en.person_id)
  ORDER BY conclude
  WITH maxrec = 999, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
