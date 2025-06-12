CREATE PROGRAM djh_l_login_id_status_csv:dba
 PROMPT
  "Output to File/Printer/MINE" = "David.Hounshell@bhs.org"
  WITH outdev
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
  FROM prsnl p
  ORDER BY p.username
  HEAD REPORT
   col 1, "Ln#,", "Stat Desc,",
   "Login,", "Phys,", "Full Name,",
   "Person_ID,", "Position Description,", "Begin DateTm,",
   "End DateTm,", "UpDate DateTm,", "UpDate ID,",
   "ActInd,", "Position CD,", "StatCD,",
   row + 1
  HEAD p.name_full_formatted
   lncnt = (lncnt+ 1), xp_active_status_disp = uar_get_code_display(p.active_status_cd), xstat_desp
    =
   IF (p.active_status_cd=194) "SPNDED"
   ELSEIF (p.active_status_cd=192) "InAct"
   ELSEIF (p.active_status_cd=189) "COMB"
   ELSE uar_get_code_display(p.active_status_cd)
   ENDIF
   ,
   xp_position_disp = uar_get_code_display(p.position_cd), xbegdttm = format(p.beg_effective_dt_tm,
    "yyyy-mm-dd hh:mm:ss"), xenddttm = format(p.end_effective_dt_tm,"yyyy-mm-dd hh:mm:ss"),
   xupdtdttm = format(p.updt_dt_tm,"yyyy-mm-dd hh:mm:ss"), xphysflag =
   IF (p.physician_ind=1) "*"
   ELSE " "
   ENDIF
   , output_string = build(lncnt,',"',xstat_desp,'"',',"',
    p.username,'"',',"',xphysflag,'"',
    ',"',p.name_full_formatted,'"',",",p.person_id,
    ',"',xp_position_disp,'"',",",xbegdttm,
    ",",xenddttm,",",xupdtdttm,",",
    p.updt_id,",",p.active_ind,",",p.position_cd,
    ",",p.active_status_cd),
   col 1, output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none, maxcol = 2000
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD ;;D"),"_daily_statusT",".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"-V5.2 - Daily ID Status ",curnode)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
