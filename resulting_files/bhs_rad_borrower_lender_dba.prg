CREATE PROGRAM bhs_rad_borrower_lender:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $1
  b.*
  FROM borrower_lender b
  WITH nocounter, separator = " ", format
 ;end select
END GO
