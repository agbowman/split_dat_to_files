CREATE PROGRAM ccl_menutestprompts
 PROMPT
  "Output to File/Printer/MINE " = mine
 SET maxsecs = 0
 SELECT INTO  $1
  o.order_mnemonic
  FROM orders o
  WHERE o.order_mnemonic > " "
  WITH format, maxrec = 100, maxcol = 250
 ;end select
END GO
