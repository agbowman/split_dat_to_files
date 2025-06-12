CREATE PROGRAM djh_l_residents:dba
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
 DECLARE restnd = f8
 DECLARE radres = f8
 SET restnd = uar_get_code_by("display",88,"BHS Resident")
 SET radres = uar_get_code_by("display",88,"BHS Rad Resident")
 SET bhres = uar_get_code_by("display",88,"BHS BH Resident")
 RECORD res_rec(
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
     2 phys_flg = f8
 )
 SELECT INTO "nl:"
  FROM prsnl pr
  PLAN (pr
   WHERE pr.active_ind=1
    AND pr.active_status_cd=188
    AND pr.updt_dt_tm >= cnvtdatetime((curdate - 1),0)
    AND cnvtupper(pr.name_full_formatted) != "*BYPASS*"
    AND ((pr.position_cd=restnd) OR (((pr.position_cd=radres) OR (pr.position_cd=bhres)) )) )
  ORDER BY pr.name_full_formatted
  HEAD REPORT
   cnt1 = 0
  HEAD pr.person_id
   cnt1 = (cnt1+ 1), stat = alterlist(res_rec->qual,cnt1), res_rec->qual[cnt1].name = pr
   .name_full_formatted,
   res_rec->qual[cnt1].stat_cd = pr.active_status_cd, res_rec->qual[cnt1].stat_descr =
   uar_get_code_display(pr.active_status_cd), res_rec->qual[cnt1].username = pr.username,
   res_rec->qual[cnt1].last_name = pr.name_last, res_rec->qual[cnt1].first_name = pr.name_first,
   res_rec->qual[cnt1].position = uar_get_code_display(pr.position_cd),
   res_rec->qual[cnt1].personid = pr.person_id, res_rec->qual[cnt1].demog_updt = pr.updt_dt_tm,
   res_rec->qual[cnt1].phys_flg = pr.physician_ind
  WITH nocounter, time = 90
 ;end select
 SELECT INTO value(output_dest)
  res_rec->qual[d.seq].personid
  FROM (dummyt d  WITH seq = size(res_rec->qual,5))
  WHERE d.seq > 0
  HEAD REPORT
   col 1, ",", "Log-in ID",
   ",", "Name", ",",
   "PHYS-flg", ",", "Position",
   ",", "Status", ",",
   "Person ID", ",", "UPDT",
   ",", row + 1, display_line = build(res_rec->qual[d.seq].name)
   FOR (y = 1 TO size(res_rec->qual[d.seq],5))
     xperson_id = format(res_rec->qual[y].personid,"#########"), xphysflg =
     IF ((res_rec->qual[y].phys_flg=0)) ""
     ELSE "*"
     ENDIF
     , output_string = build(y,',"',res_rec->qual[y].username,'","',res_rec->qual[y].name,
      '","',xphysflg,'","',res_rec->qual[y].position,'","',
      res_rec->qual[y].stat_descr,'","',xperson_id,'","',format(res_rec->qual[y].demog_updt,
       "yyyy-mm-dd;;d"),
      '",'),
     col 1, output_string
     IF ( NOT (curendreport))
      row + 1
     ENDIF
   ENDFOR
   col 1, ",", "Node:",
   ",", curnode, ",",
   curprog, ",", ",",
   "Run Date: ", curdate, row + 1
  WITH format = variable, formfeed = none, maxcol = 550
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD;;D"),"_Residents.csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"-V1.x - Residents ",curnode)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
END GO
