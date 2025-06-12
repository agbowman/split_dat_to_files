CREATE PROGRAM ccl_menu_test_123_max_pgm_name
 PROMPT
  "Printer:" = mine
 SELECT INTO  $1
  p.name_full_formatted
  FROM person p
  WITH maxrec = 1, format, separator = " "
 ;end select
END GO
