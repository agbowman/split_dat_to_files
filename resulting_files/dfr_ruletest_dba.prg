CREATE PROGRAM dfr_ruletest:dba
 SET retval = 0
 SELECT INTO value("npi7a166a")
  p.name_full_formatted
  FROM person p
  WHERE p.person_id=858241
  DETAIL
   name = trim(p.name_full_formatted), row 01, col 01,
   "Name: ", name, row 06,
   col 01, "This is a rules test", retval = 100
  WITH nocounter
 ;end select
 IF (retval=100)
  SET log_message = "Select was successful"
 ELSE
  SET log_message = "Select failed"
 ENDIF
END GO
