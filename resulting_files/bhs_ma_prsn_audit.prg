CREATE PROGRAM bhs_ma_prsn_audit
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
 FREE RECORD users
 RECORD users(
   1 qual[*]
     2 pid = f8
 )
 FREE RECORD audit
 RECORD audit(
   1 user[*]
     2 pid = f8
     2 status = vc
     2 username = vc
     2 position = vc
     2 created = vc
     2 lastlogin = vc
 )
 DECLARE date_qual = dq8
 SET date_qual = cnvtlookbehind("90,D",cnvtdatetime(curdate,curtime3))
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE p.username > " ")
  HEAD REPORT
   cnt = 0, stat = alterlist(audit->user,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cn,10)=1)
    stat = alterlist(audit->user,(cnt+ 10))
   ENDIF
   audit->user[cnt].created = format(p.create_dt_tm,"mm/dd/yyyy;;d"), audit->user[cnt].pid = p
   .person_id, audit->user[cnt].position = uar_get_code_display(p.position_cd)
  FOOT REPORT
   stat = alterlist(audit->user,cnt)
  WITH nocounter
 ;end select
 GO TO end_prog
 SELECT DISTINCT INTO value(output_dest)
  pr.name_last, pr.name_first, pr.username,
  position = uar_get_code_display(pr.position_cd), updt_dt_tm = format(pr.create_dt_tm,
   "mm/dd/yyyy ;;D"), last_log_in = format(oa.start_day,"mm/dd/yyyy ;;D")
  FROM prsnl pr,
   dummyt d,
   omf_app_ctx_day_st oa
  PLAN (pr
   WHERE pr.active_ind=1
    AND pr.active_status_cd=188.00
    AND pr.username > " ")
   JOIN (d)
   JOIN (oa
   WHERE oa.person_id=outerjoin(pr.person_id)
    AND oa.application_number > outerjoin(0)
    AND oa.start_day > outerjoin(pr.beg_effective_dt_tm))
  ORDER BY pr.name_last, pr.name_first, oa.start_day DESC,
   0
  HEAD REPORT
   col 1, ",", "Last Name",
   ",", "First Name", ",",
   "Login", ",", "Position",
   ",", "Last Login", ",",
   "Create Date", ",", row + 1
  HEAD pr.name_last
   position1 = trim(uar_get_code_display(pr.position_cd)), last_login = format(oa.start_day,
    "YYYY/MM/DD;;D"), output_string = build(',"',pr.name_last,'","',pr.name_first,'","',
    pr.username,'","',position1,'","',last_login,
    '","',updt_dt_tm,'",'),
   col 1, output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYYMMDD ;;D"),".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"Baystate Health CIS Acct Audit")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
