CREATE PROGRAM djh_ma_prsnl_chk_by_name
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
 DECLARE date_qual = dq8
 SET date_qual = cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3))
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 SELECT DISTINCT INTO value(output_dest)
  pr.name_last, pr.name_first, pr.username,
  position = uar_get_code_display(pr.position_cd), updt_dt_tm = format(pr.updt_dt_tm,"YYYY/MM/DD ;;D"
   )
  FROM prsnl pr,
   omf_app_ctx_day_st oa
  PLAN (pr
   WHERE pr.active_ind >= 0
    AND ((pr.name_last_key="ASHKAR*"
    AND pr.name_first_key="RAMI*") OR (((pr.name_last_key="BALLAN*"
    AND pr.name_first_key="DAVID*") OR (((pr.name_last_key="BANDA*"
    AND pr.name_first_key="MARY*") OR (((pr.name_last_key="BELCASTRO*"
    AND pr.name_first_key="WILLIAM*") OR (((pr.name_last_key="BOMBARDIER*"
    AND pr.name_first_key="GLEN*") OR (((pr.name_last_key="BUKALO*"
    AND pr.name_first_key="NERMINA*") OR (((pr.name_last_key="CALVANESE*"
    AND pr.name_first_key="ALPHONSE*") OR (((pr.name_last_key="CARRINGTON*"
    AND pr.name_first_key="FRANKLYN*") OR (((pr.name_last_key="CHAREST*"
    AND pr.name_first_key="SHAWN*") OR (((pr.name_last_key="CHAUHAN*"
    AND pr.name_first_key="KIRAN*") OR (((pr.name_last_key="CLINTON*"
    AND pr.name_first_key="DAVID*") OR (((pr.name_last_key="COGHLAN*"
    AND pr.name_first_key="*PATRICK*") OR (((pr.name_last_key="COOK*"
    AND pr.name_first_key="VICTORIA*") OR (((pr.name_last_key="DIEBOLD*"
    AND pr.name_first_key="KURT*") OR (((pr.name_last_key="DRESS*"
    AND pr.name_first_key="DANIEL*") OR (((pr.name_last_key="FANTI*"
    AND pr.name_first_key="DAVID*") OR (((pr.name_last_key="FARUK*"
    AND pr.name_first_key="OMAR*") OR (((pr.name_last_key="GAZIANO*"
    AND pr.name_first_key="PHILIP*") OR (((pr.name_last_key="GERSTEIN*"
    AND pr.name_first_key="ALAN*") OR (((pr.name_last_key="GURJAR*MD*"
    AND pr.name_first_key="MILIND*") OR (((pr.name_last_key="HAINES*"
    AND pr.name_first_key="JAMES*") OR (((pr.name_last_key="HESSION*"
    AND pr.name_first_key="JAMES*") OR (((pr.name_last_key="HOWARD*"
    AND pr.name_first_key="LISA*") OR (((pr.name_last_key="ISHAK*"
    AND pr.name_first_key="REDA*") OR (((pr.name_last_key="IZENSTEIN*"
    AND pr.name_first_key="BARRY*") OR (((pr.name_last_key="JACOBSON*"
    AND pr.name_first_key="GARY*") OR (((pr.name_last_key="KANAGAKI*"
    AND pr.name_first_key="RONALD*") OR (((pr.name_last_key="KOREY*"
    AND pr.name_first_key="CATHIE*") OR (((pr.name_last_key="LAKRITZ*"
    AND pr.name_first_key="NEAL*") OR (((pr.name_last_key="LAREAU*"
    AND pr.name_first_key="ALAN*") OR (((pr.name_last_key="LARSEN*"
    AND pr.name_first_key="RODNEY*") OR (((pr.name_last_key="LEONE*"
    AND pr.name_first_key="JAMES*") OR (((pr.name_last_key="MERCADANTE*"
    AND pr.name_first_key="GINO*") OR (((pr.name_last_key="MULLAN*"
    AND pr.name_first_key="MARK*") OR (((pr.name_last_key="MURRAY*"
    AND pr.name_first_key="FRANCIS*") OR (((pr.name_last_key="OPPENHEIMER*"
    AND pr.name_first_key="PAUL*") OR (((pr.name_last_key="PRESTIA*"
    AND pr.name_first_key="CLIFFORD*") OR (((pr.name_last_key="RAINA*"
    AND pr.name_first_key="ABISHAKE*") OR (((pr.name_last_key="RAO*"
    AND pr.name_first_key="MOHAN*") OR (((pr.name_last_key="RYTER*"
    AND pr.name_first_key="EDWARD*") OR (((pr.name_last_key="SCHMIDT*"
    AND pr.name_first_key="KEVIN*") OR (((pr.name_last_key="SEILER*"
    AND pr.name_first_key="*RICHARD*") OR (((pr.name_last_key="SOBEY*"
    AND pr.name_first_key="ANTHONY*") OR (pr.name_last_key="THOMAS*"
    AND pr.name_first_key="ADEL*KE*")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
    AND  NOT (pr.person_id IN (
   (SELECT
    oai.person_id
    FROM omf_app_ctx_day_st oai
    WHERE oai.person_id=pr.person_id
     AND oai.start_day > cnvtdatetime((curdate - 0),000)))))
   JOIN (oa
   WHERE oa.person_id=outerjoin(pr.person_id))
  ORDER BY pr.name_last, pr.name_first, oa.start_day DESC,
   0
  HEAD REPORT
   col 1, ",", "Last Name",
   ",", "First Name", ",",
   "Login", ",", "Position",
   ",", "Last Login", ",",
   "Update Date", ",", row + 1
  HEAD pr.name_last
   position = trim(uar_get_code_display(pr.position_cd)), last_login = format(oa.start_day,
    "YYYY/MM/DD;;D"), output_string = build(',"',pr.name_last,'","',pr.name_first,'","',
    pr.username,'","',position,'","',last_login,
    '","',updt_dt_tm,'",'),
   col 1, output_string
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
