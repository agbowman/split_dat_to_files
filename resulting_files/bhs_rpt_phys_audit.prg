CREATE PROGRAM bhs_rpt_phys_audit
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
     2 createdate = dq8
     2 endeffected = vc
     2 phyind = c3
     2 fullname = vc
     2 ligins[*]
       3 logincount = i4
       3 loginmonth = vc
 )
 DECLARE date_qual = dq8
 DECLARE idx = i4
 SET date_qual = cnvtlookbehind("90,D",cnvtdatetime(curdate,curtime3))
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 DECLARE output_string2 = vc
 CALL echo("select 1")
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE p.username > " "
    AND p.physician_ind=1)
  HEAD REPORT
   cnt = 0, stat = alterlist(audit->user,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(audit->user,(cnt+ 10))
   ENDIF
   audit->user[cnt].created = format(p.create_dt_tm,"mm/dd/yyyy;;d"), audit->user[cnt].pid = p
   .person_id, audit->user[cnt].position = uar_get_code_display(p.position_cd),
   audit->user[cnt].status = uar_get_code_display(p.active_status_cd), audit->user[cnt].username =
   trim(p.username), audit->user[cnt].phyind = evaluate(p.physician_ind,1,"YES",0,"NO"),
   audit->user[cnt].createdate = cnvtdatetime(p.create_dt_tm), audit->user[cnt].endeffected = format(
    p.end_effective_dt_tm,"mm/dd/yyyy;;d"), audit->user[cnt].fullname = trim(p.name_full_formatted)
  FOOT REPORT
   stat = alterlist(audit->user,cnt)
  WITH nocounter
 ;end select
 SET usercount = size(audit->user,5)
 CALL echo(build("usercount:",usercount))
 FOR (count = 1 TO usercount)
  CALL echo(build("user:",audit->user[count].pid))
  SELECT INTO "nl:"
   FROM omf_app_ctx_month_st omf
   PLAN (omf
    WHERE (omf.person_id=audit->user[count].pid)
     AND omf.application_number > 0
     AND omf.start_day > cnvtdatetime(audit->user[count].createdate))
   ORDER BY omf.start_month
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(audit->user[count].ligins,cnt), audit->user[count].ligins[cnt].
    logincount = log_ins,
    audit->user[count].ligins[cnt].loginmonth = format(omf.start_month,"mm/dd/yyyy;;d")
   WITH nocounter
  ;end select
 ENDFOR
 CALL echo("output")
 SELECT INTO value(output_dest)
  FROM (dummyt d  WITH seq = value(usercount))
  PLAN (d
   WHERE d.seq <= usercount)
  HEAD REPORT
   output_string = build(",","Name",",","User Name",",",
    "Acc Status",",","Position",",","Physician Indicator",
    ",","Create Date",",","Month",",",
    "LogIn Count",","), col 0, output_string,
   row + 1
  DETAIL
   output_string = " ", output_string = build(',"',audit->user[d.seq].fullname,'","',audit->user[d
    .seq].username,'","',
    audit->user[d.seq].status,'","',audit->user[d.seq].position,'","',audit->user[d.seq].phyind,
    '","',audit->user[d.seq].created,'",'), col 0,
   output_string
   FOR (login = 1 TO size(audit->user[d.seq].ligins,5))
     output_string2 = " ", output_string2 = build(',"',audit->user[d.seq].ligins[login].loginmonth,
      '","',audit->user[d.seq].ligins.logincount), output_string2,
     row + 1
   ENDFOR
  WITH maxcol = 10000, formfeed = none, format = variable
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
