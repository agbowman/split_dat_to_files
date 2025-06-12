CREATE PROGRAM djh_l_prov_grps_v2:dba
 PROMPT
  "Output to File/Printer/MINE" = "CISRequests@bhs.org"
  WITH outdev
 EXECUTE bhs_check_domain:dba
 DECLARE ms_domain = vc WITH protect, noconstant("")
 IF (findstring("@", $1) > 0)
  SET output_dest = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"))
  SET email_ind = 1
 ELSE
  SET output_dest =  $1
  SET email_ind = 0
 ENDIF
 CALL echo(output_dest)
 SET lncnt = 0
 SELECT INTO value(output_dest)
  pg.prsnl_group_name
  FROM prsnl_group pg
  WHERE pg.prsnl_group_class_cd=11156
  ORDER BY pg.prsnl_group_name
  HEAD REPORT
   col 1, "Ln#,", "Act-IND,",
   "PRSNL Group Name,", "PRSNL Group Desc,", "PRSNL GRP ID,",
   "Act STAT DT,", "Act STAT prsnl id,", "Beg Date/TM,",
   "End Date/TM,", "Grp Typ CD,", "Grp Class CD,",
   row + 1
  HEAD pg.prsnl_group_desc
   lncnt = (lncnt+ 1), output_string = build(lncnt,',"',pg.active_ind,'"',',"',
    pg.prsnl_group_name,'"',',"',pg.prsnl_group_desc,'"',
    ',"',pg.prsnl_group_id,'"',',"',format(pg.active_status_dt_tm,"yyyy-mm-dd hh:mm:ss"),
    '"',',"',pg.active_status_prsnl_id,'"',',"',
    format(pg.beg_effective_dt_tm,"yyyy-mm-dd hh:mm:ss"),'"',',"',format(pg.end_effective_dt_tm,
     "yyyy-mm-dd hh:mm:ss"),'"',
    ',"',pg.prsnl_group_type_cd,'"',',"',pg.prsnl_group_class_cd,
    '"',","), col 1,
   output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
   IF (gl_bhs_prod_flag=1)
    ms_domain = "PROD"
   ELSEIF (curnode="casdtest")
    ms_domain = "BUILD"
   ELSEIF (curnode="casetest")
    ms_domain = "TEST"
   ELSE
    ms_domain = "??"
   ENDIF
  FOOT REPORT
   row + 1, col 1, ",",
   ",", "Prog: ", curprog,
   ",", "Run Date: ", curdate,
   row + 1, col 1, ",",
   ",", "Node: ", curnode,
   "- ", ms_domain
  WITH format = variable, formfeed = none, maxcol = 2000
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD ;;D"),"_PRVD_GRP",".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"-V1.x - Provider Groups ",curnode)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
