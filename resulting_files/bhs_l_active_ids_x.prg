CREATE PROGRAM bhs_l_active_ids_x
 PROMPT
  "Output to File/Printer/MINE" = "David.Hounshell@bhs.org"
  WITH outdev
 EXECUTE bhs_sys_stand_subroutine
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
  p.active_ind, p.active_status_cd"###", p_active_status_disp = uar_get_code_display(p
   .active_status_cd),
  p.username, p.name_full_formatted, p.position_cd"##########",
  p_position_disp = uar_get_code_display(p.position_cd), p.beg_effective_dt_tm, p.end_effective_dt_tm,
  p.updt_dt_tm, p.updt_id
  FROM prsnl p,
   prsnl p1
  WHERE p.active_ind=1
   AND p.username="EN*"
  ORDER BY p.username
  HEAD REPORT
   col 1, "LnNbr,", "ActInd,",
   "StatCD,", "Stat Desc,", "Login,",
   "User Name,", "Position Code,", "Position Description,",
   "Begine Date-Time,", "End Date-Time,", "UpDate Date-Time,",
   "Up Date ID,", row + 1
  HEAD p.name_full_formatted
   lncnt = (lncnt+ 1), xp_active_status_disp = uar_get_code_display(p.active_status_cd),
   xp_position_disp = uar_get_code_display(p.position_cd),
   xenddttm = format(p.beg_effective_dt_tm,"yyyy-mm-dd hh:mm:ss"), xbegdttm = format(p
    .end_effective_dt_tm,"yyyy-mm-dd hh:mm:ss"), xupdtdttm = format(p.updt_dt_tm,
    "yyyy-mm-dd hh:mm:ss"),
   output_string = build(lncnt,",",p.active_ind,",",p.active_status_cd,
    ',"',xp_active_status_disp,'"',',"',p.username,
    '"',',"',p.name_full_formatted,'"',",",
    p.position_cd,',"',xp_position_disp,'"',",",
    xbegdttm,",",xenddttm,",",xupdtdttm,
    ",",p.updt_id), col 1, output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH maxrec = 20, format = variable, formfeed = none,
   maxcol = 500
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYYMMDD ;;D"),"x.csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," - Active IDs")
  SET dclcom = concat('sed "s/$/`echo \\\r`/" ',filename_in)
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
