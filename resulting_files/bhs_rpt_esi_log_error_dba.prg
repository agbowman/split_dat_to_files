CREATE PROGRAM bhs_rpt_esi_log_error:dba
 DECLARE mf_cs89_labcorpamb_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",89,
   "LABCORPAMB"))
 DECLARE mf_cs89_labcorpambunmatch_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",89,
   "LABCORPAMBUNMATCH"))
 DECLARE dclcom = vc
 DECLARE dcllen = i4
 DECLARE dclstatus = i4
 DECLARE tempfile = vc
 DECLARE outfile = vc
 DECLARE outfile2 = vc
 DECLARE message_file = vc
 DECLARE ms_subject = vc WITH protect, noconstant("")
 SET tab = char(9)
 SET qt = concat(char(34))
 SET tempfile = concat("cer_print:temp_esi_log_error_report_",format(cnvtdatetime(curdate,curtime),
   "yyyy-mm-dd_HHmm;;q"),".txt")
 SET outfile = concat("cer_print:esi_log_error_report_",format(cnvtdatetime(curdate,curtime),
   "yyyy-mm-dd_HHmm;;q"),".txt")
 SET outfile2 = concat("esi_log_error_report_",format(cnvtdatetime(curdate,curtime),
   "yyyy-mm-dd_HHmm;;q"),".txt")
 SET message_file = "report_out.msg"
 DECLARE bcnt = i2
 SELECT INTO value(tempfile)
  sending_system = trim(uar_get_code_display(e.contributor_system_cd),3), req_id =
  IF (findstring("TXA|",o.msg_text,1,0) > 0) trim(piece(substring(findstring("TXA|",o.msg_text,1,0),
      500,o.msg_text),"|",16,"Unknown"),3)
  ELSE trim(piece(substring(findstring("OBR|",o.msg_text,1,0),500,o.msg_text),"|",3,"Unknown"))
  ENDIF
  , pat_name = trim(cnvtupper(e.name_full_formatted),3),
  location = trim(uar_get_code_description(enc.loc_facility_cd),3), time = format(e.create_dt_tm,
   "YYYY-MM-DD HH:MM:SS;;d"), error_text = trim(e.error_text),
  hl7_entity_code = trim(e.hl7_entity_code,3)
  FROM esi_log e,
   oen_txlog o,
   encounter enc
  WHERE e.tx_key=o.tx_key
   AND e.error_stat="ESI_STAT_FAILURE"
   AND e.contributor_system_cd IN (mf_cs89_labcorpamb_cd, mf_cs89_labcorpambunmatch_cd)
   AND e.create_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),235959)
   AND e.encntr_id=enc.encntr_id
  HEAD REPORT
   "Sending System", col 22, "Requisition ID",
   col 55, "Patient Name", col 85,
   "Time Report in ESI_LOG", col 110, "Location",
   col 155, "Error Text", col 656,
   "HL7 Entity Code", row + 2
  DETAIL
   sending_system, col 22, req_id,
   col 55, pat_name, col 85,
   time, col 110, location,
   col 155, error_text, col 656,
   hl7_entity_code, row + 1
  FOOT REPORT
   row + 0
  WITH maxcol = 1000, noheading, format = variable,
   separator = " "
 ;end select
 SET ms_subject = concat("ESI_STAT_FAILURE","-",curdomain)
 SET tempfile = replace(tempfile,":","/")
 SET tempfile = concat("$",tempfile)
 SET outfile = replace(outfile,":","/")
 SET outfile = concat("$",outfile)
 SET dclcom = concat("ls ",value(tempfile))
 SET dcllen = size(trim(dclcom))
 SET dclstatus = 0
 CALL dcl(dclcom,dcllen,dclstatus)
 CALL echo(dclcom)
 IF (curqual != 0)
  IF (dclstatus=1)
   FOR (x = 1 TO 100)
     SET dclcom = concat("sed ",qt,"s/ @/@/g",qt," ",
      value(tempfile)," > ",value(outfile))
     SET dcllen = size(trim(dclcom))
     SET dclstatus = 0
     CALL dcl(dclcom,dcllen,dclstatus)
     SET dclcom = concat("cp -I ",value(outfile)," ",value(tempfile))
     SET dcllen = size(trim(dclcom))
     SET dclstatus = 0
     CALL dcl(dclcom,dcllen,dclstatus)
   ENDFOR
  ENDIF
  SET dclcom = concat("sed ",qt,"s/@/",tab,"/g",
   qt," ",value(tempfile)," > ",value(outfile))
  SET dcllen = size(trim(dclcom))
  SET dclstatus = 0
  CALL dcl(dclcom,dcllen,dclstatus)
  SET dclcom = concat("cp ",value(outfile)," ",value(outfile2))
  SET dcllen = size(trim(dclcom))
  SET dclstatus = 0
  CALL dcl(dclcom,dcllen,dclstatus)
  SET body = "Attached is a list of reports from the previous 24 hours that have ESI_STAT_FAILURE"
  SET dclcom = concat("echo '",body,"'"," | mailx -s '",ms_subject,
   "' -a ",outfile2," ","angelce.lazovski@bhs.org, labcorpesi@baystatehealth.org")
  SET dcllen = size(trim(dclcom))
  SET dclstatus = 0
  CALL dcl(dclcom,dcllen,dclstatus)
  CALL echo(dclcom)
 ENDIF
#exit_script
END GO
