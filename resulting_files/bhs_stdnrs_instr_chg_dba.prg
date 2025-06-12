CREATE PROGRAM bhs_stdnrs_instr_chg:dba
 PROMPT
  "Output to File/Printer/MINE" = "David.Hounshell@baystatehealth.org"
  WITH outdev
 IF (findstring("@", $1) > 0)
  SET output_dest = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"))
  SET email_ind = 1
 ELSE
  SET output_dest =  $1
  SET email_ind = 0
 ENDIF
 CALL echo(output_dest)
 DECLARE date_qual = dq8
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 DECLARE nrsstd = f8
 DECLARE rninstr = f8
 DECLARE rn2instr = f8
 SET nrsstd = uar_get_code_by("display",88,"BHS Nursing Student")
 SET rninstr = uar_get_code_by("display",88,"BHS RN")
 SET rn2instr = uar_get_code_by("display",88,"BHS RN Supv")
 RECORD nrs_std(
   1 qual[*]
     2 name = vc
     2 stat_cd = f8
     2 stat_descr = vc
     2 last_name = vc
     2 first_name = vc
     2 username = vc
     2 position = vc
     2 personid = f8
     2 demog_updt = dq8
     2 is_flg = c1
 )
 SELECT INTO "nl:"
  FROM prsnl pr
  PLAN (pr
   WHERE pr.active_ind=1
    AND pr.updt_dt_tm >= cnvtdatetime((curdate - 7),0)
    AND cnvtupper(pr.name_full_formatted) != "*BYPASS*"
    AND ((pr.position_cd=nrsstd) OR (cnvtupper(pr.name_full_formatted)="*INSTR*"
    AND ((pr.position_cd=rninstr) OR (pr.position_cd=rn2instr)) )) )
  ORDER BY pr.position_cd DESC, pr.name_full_formatted
  HEAD REPORT
   cnt1 = 0
  HEAD pr.person_id
   cnt1 = (cnt1+ 1), stat = alterlist(nrs_std->qual,cnt1), nrs_std->qual[cnt1].name = pr
   .name_full_formatted,
   nrs_std->qual[cnt1].stat_cd = pr.active_status_cd, nrs_std->qual[cnt1].stat_descr =
   uar_get_code_display(pr.active_status_cd), nrs_std->qual[cnt1].username = pr.username,
   nrs_std->qual[cnt1].last_name = pr.name_last, nrs_std->qual[cnt1].first_name = pr.name_first,
   nrs_std->qual[cnt1].position = uar_get_code_display(pr.position_cd),
   nrs_std->qual[cnt1].personid = pr.person_id, nrs_std->qual[cnt1].demog_updt = pr.updt_dt_tm
   IF (pr.position_cd=nrsstd)
    nrs_std->qual[cnt1].is_flg = "S"
   ELSE
    nrs_std->qual[cnt1].is_flg = "I"
   ENDIF
  WITH nocounter, time = 90
 ;end select
 SELECT INTO value(output_dest)
  nrs_std->qual[d.seq].personid
  FROM (dummyt d  WITH seq = size(nrs_std->qual,5))
  WHERE d.seq > 0
  HEAD REPORT
   col 1, ",", "Node:",
   ",", curnode, ",",
   curprog, ",", ",",
   "Run Date: ", curdate, row + 1,
   col 1, ",", "Log-in ID",
   ",", "Name", ",",
   "Position", ",", "Status",
   ",", "Date Changed", ",",
   "Person ID", ",", "I/S",
   ",", row + 1, display_line = build(nrs_std->qual[d.seq].name)
   FOR (y = 1 TO size(nrs_std->qual[d.seq],5))
     IF ((nrs_std->qual[y].is_flg="I"))
      xperson_id = format(nrs_std->qual[y].personid,"#########"), output_string = build(y,',"',
       nrs_std->qual[y].username,'","',nrs_std->qual[y].name,
       '","',nrs_std->qual[y].position,'","',nrs_std->qual[y].stat_descr,'","',
       format(nrs_std->qual[y].demog_updt,"yyyy-mm-dd;;d"),'","',xperson_id,'","',nrs_std->qual[y].
       is_flg,
       '",'), col 1,
      output_string
      IF ( NOT (curendreport))
       row + 1
      ENDIF
     ENDIF
   ENDFOR
   FOR (y = 1 TO size(nrs_std->qual[d.seq],5))
     IF ((nrs_std->qual[y].is_flg="S"))
      xperson_id = format(nrs_std->qual[y].personid,"#########"), output_string = build(y,',"',
       nrs_std->qual[y].username,'","',nrs_std->qual[y].name,
       '","',nrs_std->qual[y].position,'","',nrs_std->qual[y].stat_descr,'","',
       format(nrs_std->qual[y].demog_updt,"yyyy-mm-dd;;d"),'","',xperson_id,'","',nrs_std->qual[y].
       is_flg,
       '",'), col 1,
      output_string
      IF ( NOT (curendreport))
       row + 1
      ENDIF
     ENDIF
   ENDFOR
  WITH format = variable, formfeed = none, maxcol = 550
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD;;D"),"_NRS_INSTR_STD_chg.csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"-V1.x - Nurse/INSTR chg ",curnode)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
END GO
