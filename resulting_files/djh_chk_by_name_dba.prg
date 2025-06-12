CREATE PROGRAM djh_chk_by_name:dba
 PROMPT
  "Output to File/Printer/MINE" = "David.Hounshell@bhs.org"
  WITH outdev
 IF (findstring("@", $1) > 0)
  SET output_dest = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"))
  SET email_ind = 1
 ELSE
  SET output_dest =  $1
  SET email_ind = 0
 ENDIF
 CALL echo(output_dest)
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 SELECT DISTINCT INTO value(output_dest)
  p.name_full_formatted, p.physician_ind, p.username,
  pa.alias, p.active_ind, p.person_id,
  pa.person_id, pa_alias_pool_disp = uar_get_code_display(pa.alias_pool_cd), pa.alias_pool_cd
  FROM prsnl p,
   prsnl_alias pa
  PLAN (p
   WHERE p.active_ind=1)
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND ((p.name_last_key="HOUNSHELL*"
    AND p.name_first_key="DAVID*") OR (((p.name_last_key="ACHEAMPONG*"
    AND p.name_first_key="JANICE") OR (((p.name_last_key="ANCHOR*SAMUELS*"
    AND p.name_first_key="JESSICA") OR (((p.name_last_key="ARMSTRONG*"
    AND p.name_first_key="ELIZABETH") OR (((p.name_last_key="AZIMOV*"
    AND p.name_first_key="PAUL") OR (((p.name_last_key="BANKER*"
    AND p.name_first_key="BRIAN") OR (((p.name_last_key="BISHOP*"
    AND p.name_first_key="DAVID") OR (((p.name_last_key="BURSTEIN*"
    AND p.name_first_key="ALAN") OR (((p.name_last_key="CODY*"
    AND p.name_first_key="IRENE") OR (((p.name_last_key="CONWAY*"
    AND p.name_first_key="KAREN") OR (((p.name_last_key="CRUZ III*"
    AND p.name_first_key="ANTONE") OR (((p.name_last_key="DESANTIS*"
    AND p.name_first_key="FRANCO") OR (((p.name_last_key="FRANCZYK*"
    AND p.name_first_key="CHESTER") OR (((p.name_last_key="GARTMAN*"
    AND p.name_first_key="THOMAS") OR (((p.name_last_key="GONZALEZ HERRAN*"
    AND p.name_first_key="JUAN") OR (((p.name_last_key="GUPTA*"
    AND p.name_first_key="BHUSHAN") OR (((p.name_last_key="HALLER*"
    AND p.name_first_key="SPENCER") OR (((p.name_last_key="HAYFRON*BENJAMIN*"
    AND p.name_first_key="CHRISTINA") OR (((p.name_last_key="HIRSCHKORN*"
    AND p.name_first_key="MARK") OR (((p.name_last_key="IBRAHIMI*"
    AND p.name_first_key="FARHAN") OR (((p.name_last_key="KANE*"
    AND p.name_first_key="MATTHEW") OR (((p.name_last_key="KASSIS*"
    AND p.name_first_key="MARK") OR (((p.name_last_key="KELLY*"
    AND p.name_first_key="JOSEPH") OR (((p.name_last_key="LEOPOLD*"
    AND p.name_first_key="TALYA") OR (((p.name_last_key="LOUNSBURY*"
    AND p.name_first_key="ROBERT") OR (((p.name_last_key="MACMILLAN*"
    AND p.name_first_key="SHARON") OR (((p.name_last_key="MCKAY*"
    AND p.name_first_key="DAVID") OR (((p.name_last_key="MILLER*"
    AND p.name_first_key="CHARLOTTE") OR (((p.name_last_key="MUJALLI*"
    AND p.name_first_key="SAMIR") OR (((p.name_last_key="MULLAN*"
    AND p.name_first_key="SARA") OR (((p.name_last_key="NAME*"
    AND p.name_first_key="ELIAS") OR (((p.name_last_key="PARK*"
    AND p.name_first_key="HYUN-YOUNG") OR (((p.name_last_key="PIEL*"
    AND p.name_first_key="ALFRED") OR (((p.name_last_key="RANKIN*"
    AND p.name_first_key="JOHN") OR (((p.name_last_key="RENCUS*"
    AND p.name_first_key="ODED") OR (((p.name_last_key="REUBEN*"
    AND p.name_first_key="SUSAN") OR (((p.name_last_key="SAMUELS*"
    AND p.name_first_key="STEVEN") OR (((p.name_last_key="SARRO*"
    AND p.name_first_key="LYDIA") OR (((p.name_last_key="SCHUMACHER*"
    AND p.name_first_key="JAMES") OR (((p.name_last_key="SHAIN*"
    AND p.name_first_key="ANNE") OR (((p.name_last_key="SHUMAN*"
    AND p.name_first_key="RICHARD") OR (((p.name_last_key="SOTELO*"
    AND p.name_first_key="JORGE") OR (((p.name_last_key="STARER*"
    AND p.name_first_key="MARC") OR (((p.name_last_key="SZUMOWSKI*"
    AND p.name_first_key="ANDREW") OR (((p.name_last_key="THAU*"
    AND p.name_first_key="WARREN") OR (((p.name_last_key="TOOLE*"
    AND p.name_first_key="BRIAN") OR (((p.name_last_key="VIAMARI*"
    AND p.name_first_key="KATHLEEN") OR (((p.name_last_key="VOMERO*"
    AND p.name_first_key="JOHN") OR (((p.name_last_key="VORA*"
    AND p.name_first_key="CHAULA") OR (((p.name_last_key="WEISWASSER*"
    AND p.name_first_key="DANIEL") OR (((p.name_last_key="WESTON*"
    AND p.name_first_key="CHARLES") OR (p.name_last_key="YU*"
    AND p.name_first_key="ZHONGMO")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
  ORDER BY p.name_last, p.name_first
  HEAD REPORT
   col 1, ",", "Last Name",
   ",", "First Name", ",",
   "Login", ",", "SMS ORG ID",
   ",", "Position", ",",
   row + 1
  HEAD p.name_last
   position = trim(uar_get_code_display(p.position_cd)), output_string = build(',"',p.name_last,'","',
    p.name_first,'","',
    p.username,'","',pa.alias,'","',position,
    '",'), col 1,
   output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD ;;D"),"x",".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"V5.1 - Baystate Health CIS Acnts inactive 1 days")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
