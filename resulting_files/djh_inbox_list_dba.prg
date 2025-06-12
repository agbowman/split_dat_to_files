CREATE PROGRAM djh_inbox_list:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE bhs_check_domain:dba
 DECLARE ms_domain = vc WITH protect, noconstant("")
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  position = substring(1,50,uar_get_code_display(dp.position_cd)), dp.application_number
  FROM name_value_prefs nvp,
   detail_prefs dp
  PLAN (nvp
   WHERE nvp.pvc_name="INBOX_SRITEM*"
    AND nvp.pvc_value="12")
   JOIN (dp
   WHERE nvp.parent_entity_id=dp.detail_prefs_id
    AND dp.position_cd > 0.00)
  ORDER BY position, dp.application_number
  HEAD PAGE
   col 1, "         1         2         3         4         5         6         7", row + 1,
   col 1, "1234567890123456789012345678901234567890123456789012345678901234567890", row + 1,
   col 1, "---------+---------+---------+---------+---------+---------+---------+---------+", row + 1
  DETAIL
   lncnt = (lncnt+ 1)
   IF (dp.application_number=600005)
    pchart = "P-Chart"
   ELSE
    pchart = " "
   ENDIF
   IF (dp.application_number=961000)
    pcoff = "PC-Off"
   ELSE
    pcoff = " "
   ENDIF
   col 1, lncnt"###", col + 1,
   dp.position_cd"############", col + 1, position,
   col + 1, dp.application_number, col + 1,
   pchart, col + 1, pcoff,
   row + 1
   IF (row > 60)
    BREAK
   ENDIF
  FOOT PAGE
   row + 1, col 1, curprog,
   col 30, curdate, col 50,
   curnode
   IF (gl_bhs_prod_flag=1)
    ms_domain = "PROD"
   ELSEIF (curnode="casdtest")
    ms_domain = "BUILD"
   ELSEIF (curnode="casbtest")
    ms_domain = "CERT"
   ELSEIF (curnode="casetest")
    ms_domain = "TEST"
   ELSE
    ms_domain = "domain?"
   ENDIF
   col 60, ms_domain, col 70,
   "Page:", curpage
  WITH maxcol = 100, maxrow = 66, seperator = " ",
   format
 ;end select
END GO
