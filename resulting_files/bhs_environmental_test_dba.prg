CREATE PROGRAM bhs_environmental_test:dba
 EXECUTE bhs_sys_stand_subroutine:dba
 SET ms_email_body = concat("The situational awareness mpage driver just ran for location code TEST",
  " which is a location that is not configured on the dm_info table")
 SET ms_email_list = "Vitaliy.Kiriukhin@bhs.org,Vitaliy.Kiriukhin@baystatehealth.org"
 SET subject = concat("Test name")
 SET ms_tmp_str = concat("Files Emailed ",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))
 SET ms_filename = "test_dcl_file.dat"
 SET logical test_dcl_file "bhscust:test_dcl_file.dat"
 SELECT INTO test_dcl_file
  p.name_full_formatted
  FROM person p
  WITH maxrec = 5, nocounter
 ;end select
 CALL echo("emailing file")
 CALL emailfile(concat("$bhscust/",ms_filename),concat("$bhscust/",ms_filename),ms_email_list,
  ms_tmp_str,1)
END GO
