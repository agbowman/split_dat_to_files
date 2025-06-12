CREATE PROGRAM djh_phys_alias_chk
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE bhs_check_domain:dba
 DECLARE ms_domain = vc WITH protect, noconstant("")
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  p.active_ind, p_active_status_disp = uar_get_code_display(p.active_status_cd), p.active_status_cd,
  p_alias_pool_disp = uar_get_code_display(p.alias_pool_cd), p.alias, nbrchk = isnumeric(p.alias),
  p.active_status_dt_tm, p.active_status_prsnl_id, p.alias_pool_cd,
  p.beg_effective_dt_tm, p.data_status_prsnl_id, p.end_effective_dt_tm,
  p.person_id, p.prsnl_alias_id, p_prsnl_alias_type_disp = uar_get_code_display(p.prsnl_alias_type_cd
   ),
  p.prsnl_alias_type_cd, p.updt_applctx, p.updt_cnt,
  p.updt_dt_tm, p.updt_id
  FROM prsnl_alias p
  WHERE p.active_ind=1
   AND p.alias_pool_cd=674619.00
   AND ((p.alias="1*") OR (((p.alias="2*") OR (((p.alias="3*") OR (((p.alias="4*") OR (((p.alias="5*"
  ) OR (((p.alias="6*") OR (((p.alias="7*") OR (((p.alias="8*") OR (((p.alias="9*") OR (p.alias="0*"
  )) )) )) )) )) )) )) )) ))
  HEAD PAGE
   col 71, "                             1         1         1         1         1", col 141,
   "         1         1", row + 1, col 1,
   "         1         2         3         4         5         6         7", col 71,
   "         8         9         0         1         2         3         4",
   col 141, "         5         6", row + 1,
   col 1, "1234567890123456789012345678901234567890123456789012345678901234567890", col 71,
   "1234567890123456789012345678901234567890123456789012345678901234567890", col 141,
   "12345678901234567890",
   row + 1, col 1, "---------+---------+---------+---------+---------+---------+---------+---------+",
   col + 0, "---------+---------+---------+---------+---------+---------+---------+---------+", row
    + 1
  DETAIL
   lncnt = (lncnt+ 1), col 1, lncnt"####",
   col + 2, p.alias"###################", col + 1,
   p.alias_pool_cd, row + 1
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
  WITH maxrec = 10, maxcol = 162, maxrow = 66,
   seperator = " ", format
 ;end select
END GO
