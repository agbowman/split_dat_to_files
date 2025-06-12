CREATE PROGRAM djh_rpt_phys_addr_2
 PROMPT
  "Enter Last Name" = "*",
  "Output to File/Printer/MINE" = "David.Hounshell@bhs.org"
  WITH prompt2, outdev
 IF (findstring("@", $2) > 0)
  SET output_dest = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"))
  SET email_ind = 1
 ELSE
  SET output_dest =  $2
  SET email_ind = 0
 ENDIF
 CALL echo(output_dest)
 SET lncnt = 0
 SELECT INTO value(output_dest)
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.username, p.name_full_formatted, p.position_cd,
  p_position_disp =
  IF (p.position_cd > 0) uar_get_code_display(p.position_cd)
  ELSE "No CIS Position Assigned"
  ENDIF
  , p.end_effective_dt_tm, p.updt_dt_tm,
  p.updt_id, a_address_type_disp = uar_get_code_display(a.address_type_cd), a.street_addr,
  a.city, loginid =
  IF (p.username > " ") p.username
  ELSE "No LogIn ID"
  ENDIF
  FROM prsnl p,
   address a
  PLAN (p
   WHERE p.physician_ind=1
    AND p.active_ind=1
    AND p.active_status_cd=188
    AND (cnvtupper(p.name_last)= $PROMPT2)
    AND p.username != "RF*")
   JOIN (a
   WHERE p.person_id=a.parent_entity_id
    AND a.active_ind=1
    AND a.address_type_cd=754)
  ORDER BY p.name_full_formatted, p.username
  HEAD REPORT
   col 1, "Ln#,", "Log-in ID,",
   "Full Name,", "CIS Position,", "Address-1,",
   "Address-2,", "City,", "State,",
   "Zip-Code,", row + 1
  HEAD p.name_full_formatted
   lncnt = (lncnt+ 1), output_string = build(lncnt,',"',p.username,'"',',"',
    p.name_full_formatted,'"',',"',p_position_disp,'"',
    ',"',a.street_addr,'"',',"',a.street_addr2,
    '"',',"',a.city,'"',',"',
    a.state,'"',',"',a.zipcode,'"'), col 1,
   output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none, maxcol = 2000
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD ;;D"),"_PHYS_Addr_2",".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"-V1.0 - Phys Addrs 2 ",curnode)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $2,subject_line,1)
 ENDIF
END GO
