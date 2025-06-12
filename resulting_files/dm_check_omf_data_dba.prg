CREATE PROGRAM dm_check_omf_data:dba
 SET month =  $1
 SET year =  $2
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
 SET startdate = cnvtdatetime(startdatesstring)
 SET enddate = cnvtdatetime(enddatesstring)
 DELETE  FROM ub92_mon_proc_phys mpp
  WHERE mpp.principal_procedure_code_fl80=null
   AND mpp.other_procedure_code_1_fl81=null
   AND mpp.other_procedure_code_2_fl81=null
   AND mpp.other_procedure_code_3_fl81=null
   AND mpp.other_procedure_code_4_fl81=null
   AND mpp.other_procedure_code_5_fl81=null
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM ub92_mon_proc_phys_error mppe
  WHERE mppe.reporting_period=cnvtdatetime(startdatesstring)
  WITH nocounter
 ;end delete
 DELETE  FROM ub92_mon_diagnosis_error mppe
  WHERE mppe.reporting_period=cnvtdatetime(startdatesstring)
  WITH nocounter
 ;end delete
 DELETE  FROM ub92_mon_encounter_error mppe
  WHERE mppe.reporting_period=cnvtdatetime(startdatesstring)
  WITH nocounter
 ;end delete
 COMMIT
 EXECUTE dm_check_omf_1
 COMMIT
 EXECUTE dm_check_omf_2
 COMMIT
 EXECUTE dm_check_omf_3
 COMMIT
 EXECUTE dm_check_omf_4
 COMMIT
 EXECUTE dm_check_omf_5
 COMMIT
 EXECUTE dm_check_omf_6
 COMMIT
 EXECUTE dm_check_omf_7
 COMMIT
 EXECUTE dm_check_omf_9
 COMMIT
 EXECUTE dm_check_omf_11
 COMMIT
 EXECUTE dm_check_omf_13
 COMMIT
 EXECUTE dm_check_omf_14
 COMMIT
 EXECUTE dm_check_omf_17
 COMMIT
 EXECUTE dm_check_omf_18
 COMMIT
#end_prg
END GO
