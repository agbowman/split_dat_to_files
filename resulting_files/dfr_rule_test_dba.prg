CREATE PROGRAM dfr_rule_test:dba
 SELECT INTO value("npi7a166a")
  p.name_full_formatted
  FROM person p
  WHERE p.person_id=858241
  DETAIL
   name = trim(p.name_full_formatted), row 01, col 01,
   "Name: ", name, row 06,
   col 01, "This is a rules test"
 ;end select
END GO
