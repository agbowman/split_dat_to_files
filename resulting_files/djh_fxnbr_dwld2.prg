CREATE PROGRAM djh_fxnbr_dwld2
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
 DECLARE output_string = vc
 SELECT DISTINCT INTO value(output_dest)
  d.description, rd.area_code, rd.exchange,
  rd.phone_suffix, dxr.parent_entity_name
  FROM remote_device rd,
   device d,
   device_xref dxr
  PLAN (d
   WHERE cnvtupper(d.name)="A*")
   JOIN (rd
   WHERE d.device_cd=rd.device_cd)
   JOIN (dxr
   WHERE d.device_cd=dxr.device_cd
    AND dxr.parent_entity_name="PRSNL")
  ORDER BY d.description
  HEAD REPORT
   col 1, ",", "Physician Name",
   ",", "Area CD", ",",
   "Exchange", ",", "Phone Suffix",
   ",", "Local flag", ",",
   row + 1
  HEAD d.description
   output_string = build(',"',d.description,'","',rd.area_code,'","',
    rd.exchange,'","',rd.phone_suffix,'","',rd.local_flag,
    '",'), col 1, output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none, maxrec = 50
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD ;;D"),"-FxNbrs.csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," - PHYS Fax Numbers")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
