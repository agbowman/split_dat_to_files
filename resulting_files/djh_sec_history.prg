CREATE PROGRAM djh_sec_history
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE bhs_check_domain:dba
 DECLARE ms_domain = vc WITH protect, noconstant("")
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  username, passwd_cnt, qual
  FROM sec_history p
  ORDER BY username
  HEAD PAGE
   col 1, "         1         2         3         4", row + 1,
   col 1, "1234567890123456789012345678901234567890", row + 1,
   col 1, "---------+---------+---------+---------+", row + 1
  DETAIL
   lncnt = (lncnt+ 1), col 1, lncnt"####",
   col + 3, p.username"###############", col + 1,
   p.passwd_cnt, col + 1, p.qual,
   row + 1
   IF (row > 60)
    BREAK
   ENDIF
  FOOT PAGE
   row + 1, col 1, curprog,
   col 70, curdate, col 90,
   curnode
   IF (gl_bhs_prod_flag=1)
    ms_domain = "PROD"
   ELSEIF (curnode="casdtest")
    ms_domain = "BUILD"
   ELSEIF (curnode="casbtest")
    ms_domain = "CERT"
   ELSE
    ms_domain = "domain?"
   ENDIF
   col 100, ms_domain, col 130,
   "Page:", curpage
  WITH maxcol = 162, maxrow = 66, seperator = " ",
   format, maxrec = 20
 ;end select
END GO
