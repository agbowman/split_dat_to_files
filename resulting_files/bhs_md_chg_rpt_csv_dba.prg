CREATE PROGRAM bhs_md_chg_rpt_csv:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
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
 DECLARE res_phys = f8
 SET res_phys = uar_get_code_by("display",88,"BHS Resident")
 DECLARE rres_phys = f8
 SET rres_phys = uar_get_code_by("display",88,"BHS Rad Resident")
 DECLARE ref_phys = f8
 SET ref_phys = uar_get_code_by("display",88,"Reference Physician")
 RECORD md_alias(
   1 qual[*]
     2 name = vc
     2 last_name = vc
     2 first_name = vc
     2 username = vc
     2 phys_flg = i2
     2 position = vc
     2 personid = f8
     2 create_date = dq8
     2 beg_eff_date = dq8
     2 dmgr_chg_date = dq8
     2 end_eff_date = dq8
     2 dea_nbr = vc
     2 npi_nbr = vc
     2 org_id = vc
     2 doc_upin = vc
     2 license_nbr = vc
     2 ext_id = vc
     2 spi_nbr = vc
 )
 SELECT INTO "nl:"
  FROM prsnl pr
  PLAN (pr
   WHERE pr.physician_ind=1
    AND pr.active_ind=1
    AND pr.position_cd > 0
    AND pr.position_cd != 441
    AND pr.position_cd != 228839068
    AND pr.position_cd != 227469966
    AND pr.username > " "
    AND pr.position_cd != ref_phys
    AND pr.username != "NA-*"
    AND pr.username != "SI*"
    AND pr.name_last_key != "INBOX"
    AND pr.name_first_key != "INBOX"
    AND pr.updt_dt_tm >= cnvtdatetime((curdate - 7),0))
  ORDER BY pr.person_id
  HEAD REPORT
   cnt1 = 0
  HEAD pr.person_id
   cnt1 = (cnt1+ 1), stat = alterlist(md_alias->qual,cnt1), md_alias->qual[cnt1].name = pr
   .name_full_formatted,
   md_alias->qual[cnt1].username = pr.username, md_alias->qual[cnt1].last_name = pr.name_last,
   md_alias->qual[cnt1].first_name = pr.name_first,
   md_alias->qual[cnt1].phys_flg = pr.physician_ind, md_alias->qual[cnt1].position =
   uar_get_code_display(pr.position_cd), md_alias->qual[cnt1].personid = pr.person_id,
   md_alias->qual[cnt1].dmgr_chg_date = pr.updt_dt_tm, md_alias->qual[cnt1].create_date = pr
   .create_dt_tm, md_alias->qual[cnt1].beg_eff_date = pr.beg_effective_dt_tm,
   md_alias->qual[cnt1].end_eff_date = pr.end_effective_dt_tm
  WITH nocounter, time = 90
 ;end select
 SELECT INTO value(output_dest)
  md_alias->qual[d.seq].personid
  FROM (dummyt d  WITH seq = size(md_alias->qual,5))
  WHERE d.seq > 0
  HEAD REPORT
   col 1, ",", "Name",
   ",", "Log-in ID", ",",
   "Position", ",", "Create date",
   ",", "Chg date", ",",
   row + 1, display_line = build(md_alias->qual[d.seq].name)
   FOR (y = 1 TO size(md_alias->qual[d.seq],5))
     xperson_id = format(md_alias->qual[y].personid,"#########"), output_string = build(y,',"',
      md_alias->qual[y].name,'","',md_alias->qual[y].username,
      '","',md_alias->qual[y].position,'","',format(md_alias->qual[y].create_date,"yyyy-mm-dd;;d"),
      '","',
      format(md_alias->qual[y].dmgr_chg_date,"yyyy-mm-dd;;d"),'",'), col 1,
     output_string
     IF ( NOT (curendreport))
      row + 1
     ENDIF
   ENDFOR
   row + 1, output_string = build(',"',"End of Report",'",'), col 1,
   output_string, row + 2, output_string = build(',"',"Node: ",curnode,'","',"Run Date: ",
    format(curdate,"mm-dd-yyyy;;d"),'","',"prog: ",curprog,'",'),
   col 1, output_string
  WITH format = variable, formfeed = none, maxcol = 500
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD;;D"),"_MD_CHG_rpt.csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"-V1.0 - MD Chg rpt ",curnode)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
END GO
