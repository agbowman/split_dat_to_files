CREATE PROGRAM bhs_rpt_prsn_audit
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
     2 phyind = c3
 )
 DECLARE date_qual = dq8
 DECLARE idx = i4
 SET date_qual = cnvtlookbehind("90,D",cnvtdatetime(curdate,curtime3))
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 CALL echo("select 1")
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE p.username > " ")
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
   trim(p.username), audit->user[cnt].phyind = evaluate(p.physician_ind,1,"YES",0,"NO")
  FOOT REPORT
   stat = alterlist(audit->user,cnt)
  WITH nocounter, maxrec = 100
 ;end select
 SET usercount = size(audit->user,5)
 CALL echo("select 2")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(usercount)),
   omf_app_ctx_day_st omf
  PLAN (d
   WHERE d.seq > 0)
   JOIN (omf
   WHERE (omf.person_id=audit->user[d.seq].pid))
  ORDER BY omf.person_id, omf.start_day DESC
  HEAD omf.person_id
   stat = locateval(idx,1,usercount,omf.person_id,audit->user[idx].pid), audit->user[idx].lastlogin
    = format(omf.start_day,"mm/dd/yy;;d")
  WITH nocounter
 ;end select
 CALL echo("output")
 SELECT INTO value(output_dest)
  FROM (dummyt d  WITH seq = value(usercount))
  PLAN (d
   WHERE d.seq > 0)
  HEAD REPORT
   output_string = build(",","User Name",",","Acc Status",",",
    "Position",",","Physician Indicator",",","Create Date",
    ",","Last Login",","), col 0, output_string,
   row + 1
  HEAD PAGE
   FOR (x = 1 TO usercount)
     output_string = " ", output_string = build(',"',audit->user[x].username,'","',audit->user[x].
      status,'","',
      audit->user[x].position,'","',audit->user[x].phyind,'","',audit->user[x].created,
      '","',audit->user[x].lastlogin,'",'), col 0,
     output_string, row + 1
   ENDFOR
  WITH nocunter, format = variable, formfeed = none
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
