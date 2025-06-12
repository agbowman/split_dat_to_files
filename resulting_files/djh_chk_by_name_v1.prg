CREATE PROGRAM djh_chk_by_name_v1
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
   WHERE p.active_ind > 0)
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND ((p.name_last_key="xHOUNSHELL*"
    AND p.name_first_key="DAVID*") OR (((p.name_last_key="KUPRAS*"
    AND p.name_first_key="APRIL*") OR (((p.name_last_key="COOPER*"
    AND p.name_first_key="BARBARA*") OR (((p.name_last_key="LONG*"
    AND p.name_first_key="BARBARA*") OR (((p.name_last_key="KOCINSKI*"
    AND p.name_first_key="BETTY*") OR (((p.name_last_key="PERO*"
    AND p.name_first_key="CATHERINA*") OR (((p.name_last_key="LATOUR*"
    AND p.name_first_key="DANIELLE*") OR (((p.name_last_key="CHERESKI*"
    AND p.name_first_key="DEBORAH*") OR (((p.name_last_key="KANE*"
    AND p.name_first_key="ERIN*") OR (((p.name_last_key="RISSER*"
    AND p.name_first_key="JANINE*") OR (((p.name_last_key="PALMER*"
    AND p.name_first_key="JEFFREY*") OR (((p.name_last_key="BIGGIE*"
    AND p.name_first_key="JESSICA*") OR (((p.name_last_key="PAJEK*"
    AND p.name_first_key="JOAN*") OR (((p.name_last_key="BRUNETTE*"
    AND p.name_first_key="JOJEAN*") OR (((p.name_last_key="GRENIER*"
    AND p.name_first_key="KAREN*") OR (((p.name_last_key="MEAGHER*"
    AND p.name_first_key="KATE*") OR (((p.name_last_key="SMITH*"
    AND p.name_first_key="KATHLEEN*") OR (((p.name_last_key="WALLACE*"
    AND p.name_first_key="KATHLEEN*") OR (((p.name_last_key="MOorE*"
    AND p.name_first_key="KATRINA*") OR (((p.name_last_key="BROWN*"
    AND p.name_first_key="KIM*") OR (((p.name_last_key="BARTAK*"
    AND p.name_first_key="LAURA*") OR (((p.name_last_key="PELIS*"
    AND p.name_first_key="LAUREL*") OR (((p.name_last_key="NAUGHTON*"
    AND p.name_first_key="LAURIE*") OR (((p.name_last_key="DUMAS*"
    AND p.name_first_key="LISA*") OR (((p.name_last_key="LETOURNEAU*"
    AND p.name_first_key="LISA*") OR (((p.name_last_key="DUNCAN*"
    AND p.name_first_key="MARCHA*") OR (((p.name_last_key="GUMP*"
    AND p.name_first_key="MARUERITE*") OR (((p.name_last_key="ELLEN*"
    AND p.name_first_key="MARY*") OR (((p.name_last_key="GALENSKI*"
    AND p.name_first_key="MEGHAN*") OR (((p.name_last_key="BENNETT*"
    AND p.name_first_key="MELISSA*") OR (((p.name_last_key="AYER*"
    AND p.name_first_key="MISTY*") OR (((p.name_last_key="MALLETT*"
    AND p.name_first_key="NICOLE*") OR (((p.name_last_key="IVERSON*"
    AND p.name_first_key="PATRICIA*") OR (((p.name_last_key="CARLAN*"
    AND p.name_first_key="PAUL*") OR (((p.name_last_key="MONTPLAISIR*"
    AND p.name_first_key="PAUL*") OR (((p.name_last_key="BUCHANAN*"
    AND p.name_first_key="PETER*") OR (((p.name_last_key="MINER*"
    AND p.name_first_key="PHILIP*") OR (((p.name_last_key="BROWN*"
    AND p.name_first_key="RICHARD*") OR (((p.name_last_key="RALICKI*"
    AND p.name_first_key="ROBIN*") OR (((p.name_last_key="MOFFATT*"
    AND p.name_first_key="SHARLEEN*") OR (((p.name_last_key="CONNELLEY*"
    AND p.name_first_key="STEPHANIE*") OR (((p.name_last_key="HARVEY*"
    AND p.name_first_key="SUSAN*") OR (((p.name_last_key="GIBSON*"
    AND p.name_first_key="TAMMY*") OR (((p.name_last_key="SWAN-COUSINEAU*"
    AND p.name_first_key="TAMMY*") OR (((p.name_last_key="FUTRELL*"
    AND p.name_first_key="TARA*") OR (((p.name_last_key="KOSTECKI*"
    AND p.name_first_key="TORI*") OR (p.name_last_key="SIMPTER*"
    AND p.name_first_key="VICKI*")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
  ORDER BY p.name_last, p.name_first
  HEAD REPORT
   col 1, ",", "Last Name",
   ",", "First Name", ",",
   "Login", ",", "Person ID",
   ",", "Act Stat", ",",
   "Position", ",", row + 1
  HEAD p.name_last
   position = trim(uar_get_code_display(p.position_cd)), output_string = build(',"',p.name_last,'","',
    p.name_first,'","',
    p.username,'","',format(p.person_id,"############"),'","',p.active_status_cd,
    '","',position,'",'), col 1,
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
  SET subject_line = concat(curprog,"Vx.0 - VMG Name List")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
