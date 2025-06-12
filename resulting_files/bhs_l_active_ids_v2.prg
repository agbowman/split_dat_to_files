CREATE PROGRAM bhs_l_active_ids_v2
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
 SELECT INTO  $OUTDEV
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.username, p.name_full_formatted, p.position_cd,
  p_position_disp = uar_get_code_display(p.position_cd), p.end_effective_dt_tm, p.updt_dt_tm,
  p.updt_id
  FROM prsnl p
  WHERE p.active_ind=1
  ORDER BY p.username
  HEAD PAGE
   col 1, " ln", col 7,
   "Act", col 11, "   Stat",
   col 26, " LogIn", col 116,
   "  END", col 146, "Change",
   row + 1, col 1, " nbr",
   col 7, "ID", col 12,
   "Code/Desc", col 27, "  ID",
   col 43, "User Name", col 73,
   "Position Code & Description", col 116, "Eff Date",
   col 127, "Update / Time", col 146,
   "  ID", row + 1, col 1,
   "---------+---------+---------+---------+---------+---------+---------+---------+", col + 0,
   "---------+---------+---------+---------+---------+---------+---------+---------+",
   row + 1
  DETAIL
   fupdtm = format(p.updt_dt_tm,"@SHORTDATETIME"), fenddttm = format(p.end_effective_dt_tm,"mm-dd-yy"
    ), lncnt = (lncnt+ 1)
   IF (p.physician_ind=1)
    physflg = "**"
   ELSE
    physflg = " "
   ENDIF
   col 1, lncnt"####", col + 3,
   p.active_ind"#", col + 1, p.active_status_cd"###",
   col + 1, p_active_status_disp"##########", col + 0,
   physflg"##", col + 1, p.username"###############",
   col + 0, p.name_full_formatted"##############################", col + 0,
   p.position_cd"##########", col + 1, p_position_disp"################################",
   col + 1, fenddttm, col + 1,
   fupdtm, col + 1, p.updt_id"##########",
   row + 1
   IF (row > 60)
    BREAK
   ENDIF
  FOOT PAGE
   row + 1, col 1, curprog,
   col 70, curdate, col 130,
   "Page:", curpage
  WITH maxrec = 10, maxcol = 162, maxrow = 66,
   seperator = " ", format
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYYMMDD ;;D"),".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," - Baystate Health CIS Acnts inactive 90 days")
  SET dclcom = concat('sed "s/$/`echo \\\r`/" ',filename_in)
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
