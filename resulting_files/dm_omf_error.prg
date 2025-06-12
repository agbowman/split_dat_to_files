CREATE PROGRAM dm_omf_error
 SET month =  $2
 SET year =  $3
 FREE SET startdatesstring
 FREE SET enddatesstring
 SET startdatesstring = concat("01-",concat(month,concat("-",concat(year," 00:00:00.00"))))
 IF (((month="jan") OR (((month="mar") OR (((month="may") OR (((month="jul") OR (((month="aug") OR (
 ((month="oct") OR (month="dec")) )) )) )) )) )) )
  SET enddatesstring = concat("31-",concat(month,concat("-",concat(year," 23:59:59.59"))))
 ELSEIF (((month="apr") OR (((month="jun") OR (((month="sep") OR (month="nov")) )) )) )
  SET enddatesstring = concat("30-",concat(month,concat("-",concat(year," 23:59:59.59"))))
 ELSEIF (month="feb")
  SET enddatesstring = concat("28-",concat(month,concat("-",concat(year," 23:59:59.59"))))
 ELSE
  CALL echo(concat(month," is an invalid month."))
  GO TO end_prg
 ENDIF
 SELECT INTO  $1
  *
  FROM ub92_mon_encounter_error mee,
   omf_error_code oec
  PLAN (oec)
   JOIN (mee
   WHERE mee.error_cd=oec.error_cd
    AND mee.reporting_period=cnvtdatetime(startdatesstring))
  WITH append
 ;end select
 SELECT INTO  $1
  *
  FROM ub92_mon_diagnosis_error mee,
   omf_error_code oec
  PLAN (oec)
   JOIN (mee
   WHERE mee.error_cd=oec.error_cd
    AND mee.reporting_period=cnvtdatetime(startdatesstring))
  WITH append
 ;end select
 SELECT INTO  $1
  *
  FROM ub92_mon_proc_phys_error mee,
   omf_error_code oec
  PLAN (oec)
   JOIN (mee
   WHERE mee.error_cd=oec.error_cd
    AND mee.reporting_period=cnvtdatetime(startdatesstring))
  WITH append
 ;end select
END GO
