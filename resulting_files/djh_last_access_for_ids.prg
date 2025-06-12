CREATE PROGRAM djh_last_access_for_ids
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
 DECLARE date_qual = dq8
 SET date_qual = cnvtlookbehind("90,D",cnvtdatetime(curdate,curtime3))
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 SELECT DISTINCT INTO value(output_dest)
  p.name_full_formatted, p.username, position = uar_get_code_display(p.position_cd),
  updt_dt_tm = format(p.updt_dt_tm,"YYYY/MM/DD ;;D")
  FROM prsnl p,
   omf_app_ctx_day_st oa
  PLAN (p
   WHERE ((p.username="xx09757") OR (((p.username="*09757*") OR (((p.username="*SN71984") OR (((p
   .username="*SN72015") OR (((p.username="*SN72123") OR (((p.username="*SN72142") OR (((p.username=
   "*SN72202") OR (((p.username="*SN72203") OR (((p.username="*SN72219") OR (((p.username="*SN72221")
    OR (((p.username="*SN72222") OR (((p.username="*SN72223") OR (((p.username="*SN72239") OR (((p
   .username="*SN72245") OR (((p.username="*SN72247") OR (((p.username="*SN72248") OR (((p.username=
   "*SN72250") OR (((p.username="*SN72252") OR (((p.username="*SN72301") OR (((p.username="*SN72320")
    OR (((p.username="*SN72332") OR (((p.username="*SN72335") OR (((p.username="*SN72373") OR (((p
   .username="*SN72395") OR (((p.username="*SN72399") OR (((p.username="*SN72406") OR (((p.username=
   "*SN72407") OR (((p.username="*SN72410") OR (((p.username="*SN72411") OR (((p.username="*SN72413")
    OR (((p.username="*SN72425") OR (((p.username="*SN72439") OR (((p.username="*SN72440") OR (((p
   .username="*SN72442") OR (((p.username="*SN72444") OR (((p.username="*SN72445") OR (((p.username=
   "*SN72447") OR (((p.username="*SN90262") OR (((p.username="*SN90263") OR (((p.username="*SN90543")
    OR (((p.username="*SN90545") OR (((p.username="*SN90549") OR (((p.username="*SN90553") OR (((p
   .username="*SN91217") OR (p.username="*SN91978"
    AND  NOT (p.person_id IN (
   (SELECT
    oai.person_id
    FROM omf_app_ctx_day_st oai
    WHERE oai.person_id=p.person_id
     AND oai.start_day > cnvtdatetime((curdate - 0),000)))))) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
   JOIN (oa
   WHERE oa.person_id=outerjoin(p.person_id))
  ORDER BY p.username, p.name_full_formatted, oa.start_day DESC,
   0
  HEAD REPORT
   col 1, ",", "User",
   ",", "Login", ",",
   "Position", ",", "Last Login",
   ",", "Update Date", ",",
   "Status", row + 1
  HEAD p.name_full_formatted
   position = trim(uar_get_code_display(p.position_cd)), last_login = format(oa.start_day,
    "YYYY/MM/DD;;D"), output_string = build(',"',p.name_full_formatted,'","',p.username,'","',
    position,'","',last_login,'","',updt_dt_tm,
    '","',uar_get_code_display(p.active_status_cd),'",'),
   col 1, output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYYMMDD ;;D"),"-ID_last_access.csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," test - Baystate Health CIS Acnts inactive 90 days")
  SET dclcom = concat('sed "s/$/`echo \\\r`/" ',filename_in)
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
