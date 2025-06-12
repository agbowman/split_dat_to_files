CREATE PROGRAM bhs_combine_audit_person
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "UserName" = "*",
  "Please enter start date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "email or report" = "Report_view"
  WITH outdev, username, start_dt_tm,
  end_dt_tm, email
 DECLARE var_output = vc
 DECLARE email_ind = i4
 SET email_ind = 4
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  SET var_output = "combinetesting1"
  SET filedelimiter1 = '"'
  SET filedelimiter2 = ","
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
  SET filedelimiter1 = ""
  SET filedelimiter2 = ""
 ENDIF
 DECLARE from_mrn = vc
 DECLARE to_mrn = vc
 DECLARE from_fin = vc
 DECLARE to_fin = vc
 SELECT INTO value(var_output)
  user = pr.username, user_name = pr.name_full_formatted, from_person = pc.from_person_id,
  tomrn = pa.alias, person = pc.to_person_id, date = format(pc.updt_dt_tm,"MM/DD/YY;;D")
  FROM person_combine pc,
   person_alias pa,
   prsnl pr
  PLAN (pc
   WHERE pc.updt_dt_tm BETWEEN cnvtdatetime( $START_DT_TM) AND cnvtdatetime( $END_DT_TM)
    AND pc.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=pc.updt_id
    AND pr.username=patstring( $2))
   JOIN (pa
   WHERE pa.person_id=pc.to_person_id
    AND pa.updt_task=70000)
  WITH time = 100, format, separator = " "
 ;end select
END GO
