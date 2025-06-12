CREATE PROGRAM bhs_l_active_ids_csv
 PROMPT
  "Output to File/Printer/MINE" = "naser.sanjar2@bhs.org"
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
  WHERE p.active_ind >= 0
   AND p.username > " "
   AND p.end_effective_dt_tm > sysdate
  ORDER BY p.username
  HEAD REPORT
   col 1, "LnNbr,", "ActInd,",
   "StatCD,", "Stat Desc,", "Login,",
   "Full Name,", "Person_ID,", "Position Code,",
   "Position Description,", "Begin Date-Time,", "End Date-Time,",
   "UpDate Date-Time,", "Up Date ID,", row + 1
  HEAD p.name_full_formatted
   lncnt = (lncnt+ 1), xp_active_status_disp = uar_get_code_display(p.active_status_cd),
   xp_position_disp = uar_get_code_display(p.position_cd),
   xbegdttm = format(p.beg_effective_dt_tm,"yyyy-mm-dd hh:mm:ss"), xenddttm = format(p
    .end_effective_dt_tm,"yyyy-mm-dd hh:mm:ss"), xupdtdttm = format(p.updt_dt_tm,
    "yyyy-mm-dd hh:mm:ss"),
   output_string = build(lncnt,",",p.active_ind,",",p.active_status_cd,
    ',"',xp_active_status_disp,'"',',"',p.username,
    '"',',"',p.name_full_formatted,'"',",",
    p.person_id,",",p.position_cd,',"',xp_position_disp,
    '"',",",xbegdttm,",",xenddttm,
    ",",xupdtdttm,",",p.updt_id), col 1, output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none, maxcol = 2000
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYYMMDD ;;D"),".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"-V5 BUILD - All IDs")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
