CREATE PROGRAM bhs_ccps_cs_bill_item_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Email To" = "",
  "Audit Type" = "",
  "Organization Name" = 0,
  "Activity Type" = 0,
  "Effective Date" = curdate
  WITH outdev, email_to, audit_type,
  org_name, activity_type, eff_date
 DECLARE parsedateprompt(date_str=vc,default_date=vc,time=i4) = dq8
 DECLARE _evaluatedatestr(date_str=vc) = i4
 DECLARE _parsedate(date_str=vc) = i4
 SUBROUTINE parsedateprompt(date_str,default_date,time)
   DECLARE _return_val = dq8 WITH noconstant, private
   DECLARE _time = i4 WITH constant(cnvtint(time)), private
   DECLARE _date = i4 WITH constant(_parsedate(date_str)), private
   IF (_date=0.0)
    CASE (substring(1,1,reflect(default_date)))
     OF "F":
      SET _return_val = cnvtdatetime(cnvtdate(default_date),_time)
     OF "C":
      SET _return_val = cnvtdatetime(_evaluatedatestr(default_date),_time)
     OF "I":
      SET _return_val = cnvtdatetime(default_date,_time)
     ELSE
      SET _return_val = 0
    ENDCASE
   ELSE
    SET _return_val = cnvtdatetime(_date,_time)
   ENDIF
   RETURN(_return_val)
 END ;Subroutine
 SUBROUTINE _parsedate(date_str)
   DECLARE _return_val = dq8 WITH noconstant, private
   DECLARE _time = i4 WITH constant(0), private
   IF (isnumeric(date_str))
    DECLARE _date = vc WITH constant(trim(cnvtstring(date_str))), private
    SET _return_val = cnvtdatetime(cnvtdate(_date),_time)
    IF (_return_val=0.0)
     SET _return_val = cnvtdatetime(cnvtint(_date),_time)
    ENDIF
   ELSE
    DECLARE _date = vc WITH constant(trim(date_str)), private
    IF (textlen(trim(_date))=0)
     SET _return_val = 0
    ELSE
     IF (_date IN ("*CURDATE*"))
      SET _return_val = cnvtdatetime(_evaluatedatestr(_date),_time)
     ELSE
      SET _return_val = cnvtdatetime(cnvtdate2(_date,"DD-MMM-YYYY"),_time)
     ENDIF
    ENDIF
   ENDIF
   RETURN(cnvtdate(_return_val))
 END ;Subroutine
 SUBROUTINE _evaluatedatestr(date_str)
   DECLARE _dq8 = dq8 WITH noconstant, private
   DECLARE _parse = vc WITH constant(concat("set _dq8 = cnvtdatetime(",date_str,", 0) go")), private
   CALL parser(_parse)
   RETURN(cnvtdate(_dq8))
 END ;Subroutine
 DECLARE zipfile_full = vc WITH protect, constant("")
 DECLARE removing_file = i2 WITH protect, constant(0)
 DECLARE email_file(mail_addr=vc,from_addr=vc,mail_sub=vc,attach_file_full=vc,attach_zipfile_full=vc(
   value,zipfile_full),
  remove_files=i2(value,removing_file)) = i2
 SUBROUTINE email_file(mail_addr,from_addr,mail_sub,attach_file_full,attach_zipfile_full,remove_files
  )
   DECLARE ccl_ver = i4 WITH private, noconstant(cnvtint(build(currev,currevminor,currevminor2)))
   DECLARE start_pos = i4 WITH private, noconstant(0)
   DECLARE cur_pos = i4 WITH private, noconstant(0)
   DECLARE end_flag = i2 WITH private, noconstant(0)
   DECLARE stemp = vc WITH private, noconstant("")
   DECLARE mail_to = vc WITH private, noconstant("")
   DECLARE attach_file = vc WITH private, noconstant("")
   DECLARE attach_zipfile = vc WITH private, noconstant("")
   DECLARE email_full = vc WITH private, noconstant("")
   DECLARE email_file = vc WITH private, noconstant("")
   DECLARE dclcom = vc WITH private, noconstant("")
   DECLARE dclcom1 = vc WITH private, noconstant("")
   DECLARE dclstatus = i2 WITH private, noconstant(9)
   DECLARE dclstatus1 = i2 WITH private, noconstant(9)
   DECLARE returnval = i2 WITH private, noconstant(9)
   DECLARE removeval = i2 WITH private, noconstant(0)
   DECLARE zipping_file = i2 WITH private, noconstant(0)
   IF ( NOT (cursys2 IN ("AIX", "HPX", "LNX"))
    AND ccl_ver < 844)
    RETURN(0)
   ENDIF
   SET start_pos = 1
   SET cur_pos = 1
   SET end_flag = 0
   WHILE (end_flag=0
    AND cur_pos < 500)
     SET stemp = piece(mail_addr,";",cur_pos,"Not Found")
     IF (stemp != "Not Found")
      IF (size(trim(mail_to))=0)
       SET mail_to = stemp
      ELSE
       SET mail_to = concat(mail_to," ",stemp)
      ENDIF
     ELSE
      SET end_flag = 1
     ENDIF
     SET cur_pos = (cur_pos+ 1)
   ENDWHILE
   SET cur_pos = findstring("/",attach_file_full,start_pos,1)
   IF (cur_pos < 1)
    SET attach_file = trim(attach_file_full,3)
   ELSE
    SET attach_file = trim(substring((cur_pos+ 1),((size(attach_file_full) - cur_pos)+ 1),
      attach_file_full),3)
   ENDIF
   SET email_file = attach_file
   SET email_full = attach_file_full
   IF (textlen(trim(attach_zipfile_full,3)) > 0)
    SET zipping_file = 1
    SET start_pos = 1
    SET cur_pos = 1
    SET cur_pos = findstring("/",attach_zipfile_full,start_pos,1)
    IF (cur_pos < 1)
     SET attach_zipfile = trim(attach_zipfile_full,3)
    ELSE
     SET attach_zipfile = trim(substring((cur_pos+ 1),((size(attach_zipfile_full) - cur_pos)+ 1),
       attach_zipfile_full),3)
    ENDIF
    SET email_file = attach_zipfile
    SET email_full = attach_zipfile_full
   ENDIF
   IF (cursys2="AIX")
    IF (((dclstatus=0) OR (zipping_file=0)) )
     SET dclcom1 = concat("uuencode"," ",email_full," ",email_file,
      " ",'|mailx -s "',mail_sub,'" ',"-r ",
      from_addr," ",mail_to)
     SET returnval = dcl(dclcom1,size(trim(dclcom1)),dclstatus1)
    ENDIF
   ELSEIF (cursys2="HPX")
    IF (((dclstatus=0) OR (zipping_file=0)) )
     SET dclcom1 = concat("uuencode"," ",email_full," ",email_file,
      " ",'|mailx -m -s "',mail_sub,'" ',"-r ",
      from_addr," ",mail_to)
     SET returnval = dcl(dclcom1,size(trim(dclcom1)),dclstatus1)
    ENDIF
   ELSEIF (cursys2="LNX")
    IF (((dclstatus=1) OR (zipping_file=0)) )
     SET dclcom1 = concat("uuencode"," ",email_full," ",email_file,
      " ",'|mailx -s "',mail_sub,'" ',mail_to)
     SET returnval = dcl(dclcom1,size(trim(dclcom1)),dclstatus1)
    ENDIF
   ENDIF
   IF (returnval != 9
    AND remove_files != 0)
    IF (textlen(trim(attach_zipfile_full,3))=0)
     SET removeval = remove(attach_file_full)
    ELSEIF (textlen(trim(attach_zipfile_full,3)) > 0)
     SET removeval = remove(attach_file_full)
     SET removeval = remove(attach_zipfile_full)
    ENDIF
   ENDIF
   IF (returnval != 9
    AND removeval IN (0, 1))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
   SET last_mod = "02/02/2012 MP9098"
 END ;Subroutine
 DECLARE eff_dt_tm = dq8 WITH constant(parsedateprompt( $EFF_DATE,curdate,235959)), protect
 DECLARE rad_activity_type_cd = f8 WITH constant(uar_get_code_by("MEANING",106,"RADIOLOGY")), protect
 DECLARE pharm_activity_type_cd = f8 WITH constant(uar_get_code_by("MEANING",106,"PHARMACY")),
 protect
 DECLARE cdm_med_id_type_cd = f8 WITH constant(uar_get_code_by("MEANING",11000,"CDM")), protect
 DECLARE ndc_med_id_type_cd = f8 WITH constant(uar_get_code_by("MEANING",11000,"NDC")), protect
 DECLARE alpha_response_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"ALPHA RESP")), protect
 DECLARE chrg_point_sch_cd = f8 WITH constant(uar_get_code_by("MEANING",13019,"CHARGE POINT")),
 protect
 DECLARE bill_code_sch_cd = f8 WITH constant(uar_get_code_by("MEANING",13019,"BILL CODE")), protect
 DECLARE add_on_assigned_cd = f8 WITH constant(uar_get_code_by("MEANING",13019,"ADD ON")), protect
 DECLARE workload_sch_cd = f8 WITH constant(uar_get_code_by("MEANING",13019,"WORKLOAD")), protect
 DECLARE client_org_type_cd = f8 WITH constant(uar_get_code_by("MEANING",278,"CLIENT")), protect
 DECLARE charge_point_cd = f8 WITH constant(uar_get_code_by("MEANING",13036,"CHARGE POINT")), protect
 DECLARE cdm_sched_cd = f8 WITH constant(uar_get_code_by("MEANING",13036,"CDM_SCHED")), protect
 DECLARE cpt4_cd = f8 WITH constant(uar_get_code_by("MEANING",13036,"CPT4")), protect
 DECLARE hcpcs_cd = f8 WITH constant(uar_get_code_by("MEANING",13036,"HCPCS")), protect
 DECLARE modifier_cd = f8 WITH constant(uar_get_code_by("MEANING",13036,"MODIFIER")), protect
 DECLARE price_sched_cd = f8 WITH constant(uar_get_code_by("MEANING",13036,"PRICESCHED")), protect
 DECLARE revenue_cd = f8 WITH constant(uar_get_code_by("MEANING",13036,"REVENUE")), protect
 DECLARE pharm_cdm_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14002,"CDMSCHEDPHARM")),
 protect
 DECLARE 106_add_on_activity_type_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2828")),
 protect
 DECLARE 106_supplies_activity_type_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!12576")),
 protect
 DECLARE 222_facility_location_type_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2844")),
 protect
 DECLARE 4500_inpt_pharmacy_type_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!101131")),
 protect
 DECLARE display_message = vc WITH noconstant(" "), public
 DECLARE activity_type_anyall = vc WITH noconstant("No"), public
 DECLARE activity_type_is_rad = vc WITH noconstant("No"), public
 DECLARE activity_type_is_pharm = vc WITH noconstant("No"), public
 DECLARE index = i4 WITH noconstant(0), public
 DECLARE enum = i4 WITH noconstant(0), public
 DECLARE num = i4 WITH noconstant(0), public
 DECLARE num2 = i4 WITH noconstant(0), public
 DECLARE pos = i4 WITH noconstant(0), public
 DECLARE pos2 = i4 WITH noconstant(0), public
 DECLARE temp_description = vc WITH noconstant(" "), public
 DECLARE pharm_cnvtstring_temp = vc WITH constant(trim(cnvtstring(pharm_activity_type_cd,15,6))),
 public
 DECLARE rad_cnvtstring_temp = vc WITH constant(trim(cnvtstring(rad_activity_type_cd,15,6))), public
 DECLARE pharm_findstring = i2 WITH noconstant(0), public
 DECLARE rad_findstring = i2 WITH noconstant(0), public
 DECLARE pharm_cdm_cnvtstring_temp = vc WITH constant(trim(cnvtstring(pharm_cdm_cd))), public
 DECLARE pharm_cdm_findstring = i2 WITH noconstant(0), public
 DECLARE pharm_cdm_exists = vc WITH noconstant("No"), public
 DECLARE chrg_process_cd_parser = vc WITH noconstant(" "), public
 DECLARE price_id_parser = vc WITH noconstant(" "), public
 DECLARE bill_code_cd_parser = vc WITH noconstant(" "), public
 DECLARE temp_facility_parser = vc WITH noconstant(" "), public
 DECLARE activity_type_parser = vc WITH noconstant(" "), public
 DECLARE facility_parser = vc WITH noconstant(" "), public
 DECLARE logmsg(mymsg=vc,msglvl=i2(value,2)) = null
 DECLARE logrecord(myrecstruct=vc(ref)) = null
 DECLARE finalizemsgs(outdest=vc(value,""),recsizezflag=i4(value,1)) = null
 DECLARE catcherrors(mymsg=vc) = i2
 DECLARE getreply(null) = vc
 DECLARE geterrorcount(null) = i4
 DECLARE getcodewithcheck(type=vc,code_set=i4(value,0),expression=vc(value,""),msglvl=i2(value,2)) =
 f8
 DECLARE setreply(mystat=vc) = null
 DECLARE populatesubeventstatus(errorcnt=i4(value),operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) = i2
 DECLARE writemlgmsg(msg=vc,lvl=i2) = null
 DECLARE ccps_json = i2 WITH protect, constant(0)
 DECLARE ccps_xml = i2 WITH protect, constant(1)
 DECLARE ccps_rec_listing = i2 WITH protect, constant(2)
 DECLARE ccps_info_domain = vc WITH protect, constant("CCPS_SCRIPT_LOGGING")
 DECLARE ccps_none_ind = i2 WITH protect, constant(0)
 DECLARE ccps_file_ind = i2 WITH protect, constant(1)
 DECLARE ccps_msgview_ind = i2 WITH protect, constant(2)
 DECLARE ccps_listing_ind = i2 WITH protect, constant(3)
 DECLARE ccps_log_error = i2 WITH protect, constant(0)
 DECLARE ccps_log_audit = i2 WITH protect, constant(2)
 DECLARE ccps_error_disp = vc WITH protect, noconstant("ERROR")
 DECLARE ccps_audit_disp = vc WITH protect, noconstant("AUDIT")
 DECLARE ccps_serrmsg = vc WITH protect, noconstant(fillstring(132," "))
 DECLARE ccps_ierrcode = i4 WITH protect, noconstant(error(ccps_serrmsg,1))
 EXECUTE msgrtl
 IF ( NOT (validate(debug_values)))
  RECORD debug_values(
    1 log_program_name = vc
    1 log_file_dest = vc
    1 inactive_dt_tm = vc
    1 log_level = i2
    1 log_level_override = i2
    1 logging_on = i2
    1 rec_format = i2
    1 suppress_rec = i2
    1 suppress_msg = i2
    1 debug_method = i4
  ) WITH protect
  SET debug_values->logging_on = false
  SET debug_values->log_program_name = curprog
 ENDIF
 IF ( NOT (validate(ccps_log)))
  RECORD ccps_log(
    1 ecnt = i4
    1 cnt = i4
    1 qual[*]
      2 msg = vc
      2 msg_type_id = i4
      2 msg_type_display = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(frec)))
  RECORD frec(
    1 file_desc = i4
    1 file_offset = i4
    1 file_dir = i4
    1 file_name = vc
    1 file_buf = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 CALL setreply("F")
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=ccps_info_domain
    AND (dm.info_name=debug_values->log_program_name)
    AND dm.info_date >= cnvtdatetime(curdate,curtime3))
  ORDER BY dm.info_name
  HEAD dm.info_name
   entity_cnt = 0, component_cnt = 0, entity = trim(piece(dm.info_char,",",(entity_cnt+ 1),
     "Not Found"),3),
   component = fillstring(4000," ")
   WHILE (component != "Not Found")
     component_cnt = (component_cnt+ 1), component = trim(piece(entity,";",component_cnt,"Not Found"),
      3), component_head = trim(piece(cnvtlower(component),":",1,"Not Found"),3),
     component_value = trim(piece(component,":",2,"Not Found"),3)
     CASE (component_head)
      OF "program":
       debug_values->log_program_name = component_value
      OF "debug_method":
       IF (component_value="None")
        debug_values->debug_method = ccps_none_ind
       ELSEIF (component_value="File")
        debug_values->debug_method = ccps_file_ind
       ELSEIF (component_value="Message View")
        debug_values->debug_method = ccps_msgview_ind
       ELSEIF (component_value="Listing")
        debug_values->debug_method = ccps_listing_ind
       ENDIF
      OF "file_name":
       debug_values->log_file_dest = component_value
      OF "inactive_dt_tm":
       debug_values->inactive_dt_tm = component_value
      OF "rec_type":
       debug_values->rec_format = cnvtint(component_value)
      OF "suppress_rec":
       debug_values->suppress_rec = cnvtint(component_value)
      OF "suppress_msg":
       debug_values->suppress_msg = cnvtint(component_value)
     ENDCASE
   ENDWHILE
   IF ((debug_values->debug_method != ccps_none_ind))
    debug_values->logging_on = true
   ELSE
    debug_values->logging_on = false
   ENDIF
  FOOT  dm.info_name
   null
  WITH nocounter
 ;end select
 IF (validate(ccps_debug))
  IF ( NOT (validate(ccps_file)))
   SET debug_values->log_file_dest = build(debug_values->log_program_name,"_DBG.dat")
  ENDIF
  IF ( NOT (validate(ccps_rec_format)))
   IF (ccps_debug != ccps_listing_ind)
    SET debug_values->rec_format = ccps_json
   ELSE
    SET debug_values->rec_format = ccps_rec_listing
   ENDIF
  ELSE
   IF (ccps_rec_format=ccps_xml)
    SET debug_values->rec_format = ccps_xml
   ELSEIF (ccps_rec_format=ccps_json)
    SET debug_values->rec_format = ccps_json
   ELSE
    SET debug_values->rec_format = ccps_rec_listing
   ENDIF
  ENDIF
  IF ( NOT (validate(ccps_suppress_rec)))
   SET debug_values->suppress_rec = false
  ELSE
   IF (ccps_suppress_rec=true)
    SET debug_values->suppress_rec = true
   ELSE
    SET debug_values->suppress_rec = false
   ENDIF
  ENDIF
  IF ( NOT (validate(ccps_suppress_msg)))
   SET debug_values->suppress_msg = false
  ELSE
   IF (ccps_suppress_msg=true)
    SET debug_values->suppress_msg = true
   ELSE
    SET debug_values->suppress_msg = false
   ENDIF
  ENDIF
  CASE (ccps_debug)
   OF ccps_none_ind:
    SET debug_values->debug_method = ccps_none_ind
    SET debug_values->logging_on = false
   OF ccps_file_ind:
    SET debug_values->debug_method = ccps_file_ind
    SET debug_values->logging_on = true
   OF ccps_msgview_ind:
    SET debug_values->debug_method = ccps_msgview_ind
    SET debug_values->logging_on = true
   OF ccps_listing_ind:
    SET debug_values->debug_method = ccps_listing_ind
    SET debug_values->logging_on = true
  ENDCASE
 ENDIF
 IF (debug_values->logging_on)
  CALL echo("****************************")
  CALL echo("*** Logging is turned ON ***")
  CALL echo("****************************")
  CASE (debug_values->debug_method)
   OF ccps_file_ind:
    CALL echo(build("*** Will write to file: ",debug_values->log_file_dest,"***"))
   OF ccps_msgview_ind:
    CALL echo("*****************************")
    CALL echo("*** Will write to MsgView ***")
    CALL echo("*****************************")
   OF ccps_listing_ind:
    CALL echo("*********************************")
    CALL echo("*** Will write to the listing ***")
    CALL echo("*********************************")
  ENDCASE
  IF ((debug_values->suppress_rec=true))
   CALL echo("****************************")
   CALL echo("***  Suppress Rec is ON  ***")
   CALL echo("****************************")
  ENDIF
  IF ((debug_values->suppress_msg=true))
   CALL echo("****************************")
   CALL echo("***  Suppress Msg is ON  ***")
   CALL echo("****************************")
  ENDIF
 ELSE
  CALL echo("*****************************")
  CALL echo("*** Logging is turned OFF ***")
  CALL echo("*****************************")
 ENDIF
 SUBROUTINE logmsg(mymsg,msglvl)
   DECLARE seek_retval = i4 WITH private, noconstant
   DECLARE filelen = i4 WITH private, noconstant
   DECLARE write_stat = i2 WITH private, noconstant
   DECLARE imsglvl = i2 WITH private, noconstant
   DECLARE smsglvl = vc WITH private, noconstant
   DECLARE slogtext = vc WITH private, noconstant("")
   DECLARE start_char = i4 WITH private, noconstant
   SET imsglvl = msglvl
   SET slogtext = mymsg
   IF ((((debug_values->suppress_msg=false)) OR ((debug_values->suppress_msg=true)
    AND msglvl=ccps_log_error)) )
    IF (((imsglvl=ccps_log_error) OR ((debug_values->logging_on=true))) )
     SET ccps_log->cnt = (ccps_log->cnt+ 1)
     IF (msglvl=ccps_log_error)
      SET ccps_log->ecnt = (ccps_log->ecnt+ 1)
     ENDIF
     SET stat = alterlist(ccps_log->qual,ccps_log->cnt)
     SET ccps_log->qual[ccps_log->cnt].msg = trim(mymsg,3)
     SET ccps_log->qual[ccps_log->cnt].msg_type_id = msglvl
     IF (msglvl=ccps_log_error)
      SET ccps_log->qual[ccps_log->cnt].msg_type_display = ccps_error_disp
     ELSE
      SET ccps_log->qual[ccps_log->cnt].msg_type_display = ccps_audit_disp
     ENDIF
    ENDIF
    CASE (imsglvl)
     OF ccps_log_error:
      SET smsglvl = "Error"
     OF ccps_log_audit:
      SET smsglvl = "Audit"
    ENDCASE
    IF (imsglvl=ccps_log_error)
     CALL writemlgmsg(slogtext,imsglvl)
     CALL populatesubeventstatus(ccps_log->ecnt,ccps_error_disp,"F",build(curprog),trim(mymsg,3))
    ENDIF
    IF ((debug_values->logging_on=true))
     IF ((debug_values->debug_method=ccps_msgview_ind)
      AND msglvl != ccps_log_error)
      CALL writemlgmsg(slogtext,imsglvl)
     ELSEIF ((debug_values->debug_method=ccps_file_ind))
      SET frec->file_name = debug_values->log_file_dest
      SET frec->file_buf = "ab"
      SET stat = cclio("OPEN",frec)
      SET frec->file_dir = 2
      SET seek_retval = cclio("SEEK",frec)
      SET filelen = cclio("TELL",frec)
      SET frec->file_offset = filelen
      SET frec->file_buf = build2(format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;d"),
       fillstring(5," "),"{",smsglvl,"}",
       fillstring(5," "),mymsg,char(13),char(10))
      SET write_stat = cclio("WRITE",frec)
      SET stat = cclio("CLOSE",frec)
     ELSEIF ((debug_values->debug_method=ccps_listing_ind))
      CALL echo(build2("*** ",format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;d"),
        fillstring(5," "),"{",smsglvl,
        "}",fillstring(5," "),mymsg))
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE logrecord(myrecstruct)
   IF ((debug_values->suppress_rec=false))
    DECLARE smsgtype = vc WITH private, noconstant
    DECLARE write_stat = i4 WITH private, noconstant
    SET smsgtype = "Audit"
    IF ((debug_values->logging_on=true))
     IF ((debug_values->debug_method=ccps_file_ind))
      SET frec->file_name = debug_values->log_file_dest
      SET frec->file_buf = "ab"
      SET stat = cclio("OPEN",frec)
      SET frec->file_dir = 2
      SET seek_retval = cclio("SEEK",frec)
      SET filelen = cclio("TELL",frec)
      SET frec->file_offset = filelen
      SET frec->file_buf = build2(format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;d"),
       fillstring(5," "),"{",smsgtype,"}",
       fillstring(5," "))
      IF ((debug_values->rec_format=ccps_xml))
       CALL echoxml(myrecstruct,debug_values->log_file_dest,1)
      ELSEIF ((debug_values->rec_format=ccps_json))
       CALL echojson(myrecstruct,debug_values->log_file_dest,1)
      ELSE
       CALL echorecord(myrecstruct,debug_values->log_file_dest,1)
      ENDIF
      SET frec->file_buf = build(frec->file_buf,char(13),char(10))
      SET write_stat = cclio("WRITE",frec)
      SET stat = cclio("CLOSE",frec)
     ELSEIF ((debug_values->debug_method=ccps_listing_ind))
      CALL echo(build2("*** ",format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;d"),
        fillstring(5," "),"{",smsgtype,
        "}",fillstring(5," ")))
      IF ((debug_values->rec_format=ccps_xml))
       CALL echoxml(myrecstruct)
      ELSEIF ((debug_values->rec_format=ccps_json))
       CALL echojson(myrecstruct)
      ELSE
       CALL echorecord(myrecstruct)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE catcherrors(mymsg)
   DECLARE ccps_ierroroccurred = i2 WITH private, noconstant(0)
   SET ccps_ierrcode = error(ccps_serrmsg,0)
   WHILE (ccps_ierrcode > 0
    AND (ccps_log->ecnt < 50))
     SET ccps_ierroroccurred = 1
     CALL logmsg(trim(build2(mymsg," -- ",trim(ccps_serrmsg,3)),3),ccps_log_error)
     SET ccps_ierrcode = error(ccps_serrmsg,1)
   ENDWHILE
   RETURN(ccps_ierroroccurred)
 END ;Subroutine
 SUBROUTINE geterrorcount(null)
   RETURN(ccps_log->ecnt)
 END ;Subroutine
 SUBROUTINE finalizemsgs(outdest,recsizezflag)
   DECLARE errcnt = i4 WITH noconstant, private
   SET stat = catcherrors("Performing final check for errors...")
   SET errcnt = geterrorcount(null)
   IF (errcnt > 0)
    CALL setreply("F")
   ELSEIF (recsizezflag=0)
    CALL setreply("Z")
   ELSE
    CALL setreply("S")
   ENDIF
   IF ((ccps_log->ecnt > 0)
    AND cnvtstring(outdest) != "")
    SELECT INTO value(outdest)
     FROM (dummyt d  WITH seq = ccps_log->cnt)
     PLAN (d
      WHERE (ccps_log->qual[d.seq].msg_type_id=ccps_log_error))
     HEAD REPORT
      CALL print(build2(
       "*** Errors have occurred in the CCL Script.  Please contact your System Administrator ",
       "and/or Cerner for assistance with resolving the issue. ***",char(13),char(10),char(13),
       char(10)))
     DETAIL
      CALL print(ccps_log->qual[d.seq].msg), row + 1
     FOOT REPORT
      null
     WITH nocounter, maxcol = 500
    ;end select
   ENDIF
   IF ((debug_values->debug_method=ccps_listing_ind))
    CALL echo("********************************")
    CALL echo("*** Printing Logging Summary ***")
    CALL echo("********************************")
    CALL logrecord(ccps_log)
    CALL logrecord(reply)
   ENDIF
 END ;Subroutine
 SUBROUTINE setreply(mystat)
   IF (validate(reply->status_data.status)=1)
    SET reply->status_data.status = mystat
   ENDIF
 END ;Subroutine
 SUBROUTINE getreply(null)
   IF (validate(reply->status_data.status)=1)
    RETURN(reply->status_data.status)
   ELSE
    RETURN("Z")
   ENDIF
 END ;Subroutine
 SUBROUTINE getcodewithcheck(type,code_set,expression,msglvl)
   DECLARE cki_flag = i2 WITH private, noconstant(0)
   IF (code_set=0)
    DECLARE tmp_code_value = f8 WITH private, noconstant(uar_get_code_by_cki(type))
    SET cki_flag = 1
   ELSE
    DECLARE tmp_code_value = f8 WITH private, noconstant(uar_get_code_by(type,code_set,expression))
   ENDIF
   IF (tmp_code_value <= 0)
    IF (cki_flag=0)
     CALL logmsg(build2("*** ! Code value from code set ",trim(cnvtstring(code_set),3)," with ",type,
       " of ",
       expression," was not found !"),msglvl)
    ELSE
     CALL logmsg(build2("*** ! Code value with CKI of ",type," was not found !"),msglvl)
    ENDIF
   ENDIF
   RETURN(tmp_code_value)
 END ;Subroutine
 SUBROUTINE populatesubeventstatus(errorcnt,operationname,operationstatus,targetobjectname,
  targetobjectvalue)
   DECLARE ccps_isubeventcnt = i4 WITH protect, noconstant(0)
   DECLARE ccps_isubeventsize = i4 WITH protect, noconstant(0)
   IF (validate(reply->ops_event)=1
    AND errorcnt=1)
    SET reply->ops_event = targetobjectvalue
   ENDIF
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET ccps_isubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (ccps_isubeventcnt > 0)
     SET ccps_isubeventsize = size(trim(reply->status_data.subeventstatus[ccps_isubeventcnt].
       operationname))
     SET ccps_isubeventsize = (ccps_isubeventsize+ size(trim(reply->status_data.subeventstatus[
       ccps_isubeventcnt].operationstatus)))
     SET ccps_isubeventsize = (ccps_isubeventsize+ size(trim(reply->status_data.subeventstatus[
       ccps_isubeventcnt].targetobjectname)))
     SET ccps_isubeventsize = (ccps_isubeventsize+ size(trim(reply->status_data.subeventstatus[
       ccps_isubeventcnt].targetobjectvalue)))
    ENDIF
    IF (ccps_isubeventsize > 0)
     SET ccps_isubeventcnt = (ccps_isubeventcnt+ 1)
     SET iloggingstat = alter(reply->status_data.subeventstatus,ccps_isubeventcnt)
    ENDIF
    IF (ccps_isubeventcnt > 0)
     SET reply->status_data.subeventstatus[ccps_isubeventcnt].operationname = substring(1,25,
      operationname)
     SET reply->status_data.subeventstatus[ccps_isubeventcnt].operationstatus = substring(1,1,
      operationstatus)
     SET reply->status_data.subeventstatus[ccps_isubeventcnt].targetobjectname = substring(1,25,
      targetobjectname)
     SET reply->status_data.subeventstatus[ccps_isubeventcnt].targetobjectvalue = targetobjectvalue
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE writemlgmsg(msg,lvl)
   DECLARE sys_handle = i4 WITH noconstant(0), private
   DECLARE sys_status = i4 WITH noconstant(0), private
   CALL uar_syscreatehandle(sys_handle,sys_status)
   IF (sys_handle > 0)
    CALL uar_msgsetlevel(sys_handle,lvl)
    CALL uar_sysevent(sys_handle,lvl,nullterm(debug_values->log_program_name),nullterm(msg))
    CALL uar_sysdestroyhandle(sys_handle)
   ENDIF
 END ;Subroutine
 SET lastmod = "001  9/11/12   ML011047"
 IF ( NOT (validate(list_in)))
  DECLARE list_in = i2 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(list_not_in)))
  DECLARE list_not_in = i2 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(ccps_records)))
  RECORD ccps_records(
    1 cnt = i4
    1 list[*]
      2 name = vc
    1 num = i4
  ) WITH persistscript
 ENDIF
 DECLARE ispromptany(which_prompt=i2) = i2
 SUBROUTINE ispromptany(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (prompt_reflect="C1")
    IF (ichar(value(parameter(which_prompt,1)))=42)
     SET return_val = 1
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE ispromptlist(which_prompt=i2) = i2
 SUBROUTINE ispromptlist(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (substring(1,1,prompt_reflect)="L")
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE ispromptsingle(which_prompt=i2) = i2
 SUBROUTINE ispromptsingle(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (textlen(trim(prompt_reflect,3)) > 0
    AND  NOT (ispromptany(which_prompt))
    AND  NOT (ispromptlist(which_prompt)))
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE ispromptempty(which_prompt=i2) = i2
 SUBROUTINE ispromptempty(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (textlen(trim(prompt_reflect,3))=0)
    SET return_val = 1
   ELSEIF (ispromptsingle(which_prompt))
    IF (substring(1,1,prompt_reflect)="C")
     IF (textlen(trim(value(parameter(which_prompt,0)),3))=0)
      SET return_val = 1
     ENDIF
    ELSE
     IF (cnvtreal(value(parameter(which_prompt,1)))=0)
      SET return_val = 1
     ENDIF
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE getpromptlist(which_prompt=i2,which_column=vc,which_option=i2(value,list_in)) = vc
 SUBROUTINE getpromptlist(which_prompt,which_column,which_option)
   DECLARE prompt_reflect = vc WITH noconstant(reflect(parameter(which_prompt,0))), private
   DECLARE count = i4 WITH noconstant(0), private
   DECLARE item_num = i4 WITH noconstant(0), private
   DECLARE option_str = vc WITH noconstant(""), private
   DECLARE return_val = vc WITH noconstant("0=1"), private
   IF (which_option=list_not_in)
    SET option_str = " NOT IN ("
   ELSE
    SET option_str = " IN ("
   ENDIF
   IF (ispromptany(which_prompt))
    SET return_val = "1=1"
   ELSEIF (ispromptlist(which_prompt))
    SET count = cnvtint(substring(2,(textlen(prompt_reflect) - 1),prompt_reflect))
   ELSEIF (ispromptsingle(which_prompt))
    SET count = 1
   ENDIF
   IF (count > 0)
    SET return_val = concat("(",which_column,option_str)
    FOR (item_num = 1 TO count)
     IF (mod(item_num,1000)=1
      AND item_num > 1)
      SET return_val = replace(return_val,",",")",2)
      SET return_val = concat(return_val," or ",which_column,option_str)
     ENDIF
     IF (substring(1,1,reflect(parameter(which_prompt,item_num)))="C")
      SET return_val = concat(return_val,"'",value(parameter(which_prompt,item_num)),"'",",")
     ELSE
      SET return_val = build(return_val,value(parameter(which_prompt,item_num)),",")
     ENDIF
    ENDFOR
    SET return_val = replace(return_val,",",")",2)
    SET return_val = concat(return_val,")")
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE getpromptexpand(which_prompt=i2,which_column=vc,which_option=i2(value,list_in)) = vc
 SUBROUTINE getpromptexpand(which_prompt,which_column,which_option)
   DECLARE record_name = vc WITH private, noconstant(" ")
   DECLARE return_val = vc WITH private, noconstant("0=1")
   IF (ispromptany(which_prompt))
    SET return_val = "1=1"
   ELSEIF (((ispromptlist(which_prompt)) OR (ispromptsingle(which_prompt))) )
    SET record_name = getpromptrecord(which_prompt,which_column)
    IF (textlen(trim(record_name,3)) > 0)
     SET return_val = createexpandparser(which_column,record_name,which_option)
    ENDIF
   ENDIF
   CALL logmsg(concat("GetPromptExpand: return value = ",return_val))
   RETURN(return_val)
 END ;Subroutine
 DECLARE getpromptrecord(which_prompt=i2,which_rec=vc) = vc
 SUBROUTINE getpromptrecord(which_prompt,which_rec)
   DECLARE record_name = vc WITH private, noconstant(" ")
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0))), private
   DECLARE count = i4 WITH private, noconstant(0)
   DECLARE item_num = i4 WITH private, noconstant(0)
   DECLARE idx = i4 WITH private, noconstant(0)
   DECLARE data_type = vc WITH private, noconstant(" ")
   DECLARE alias_parser = vc WITH private, noconstant(" ")
   DECLARE cnt_parser = vc WITH private, noconstant(" ")
   DECLARE alterlist_parser = vc WITH private, noconstant(" ")
   DECLARE data_type_parser = vc WITH private, noconstant(" ")
   DECLARE return_val = vc WITH private, noconstant(" ")
   IF ((( NOT (ispromptany(which_prompt))) OR ( NOT (ispromptempty(which_prompt)))) )
    SET record_name = createrecord(which_rec)
    IF (textlen(trim(record_name,3)) > 0)
     IF (ispromptlist(which_prompt))
      SET count = cnvtint(substring(2,(textlen(prompt_reflect) - 1),prompt_reflect))
     ELSEIF (ispromptsingle(which_prompt))
      SET count = 1
     ENDIF
     IF (count > 0)
      SET alias_parser = concat("set curalias = which_rec_alias ",record_name,"->list[idx] go")
      SET cnt_parser = build2("set ",record_name,"->cnt = ",count," go")
      SET alterlist_parser = build2("set stat = alterlist(",record_name,"->list,",record_name,
       "->cnt) go")
      SET data_type = cnvtupper(substring(1,1,reflect(parameter(which_prompt,1))))
      SET data_type_parser = concat("set ",record_name,"->data_type = '",data_type,"' go")
      CALL parser(alias_parser)
      CALL parser(cnt_parser)
      CALL parser(alterlist_parser)
      CALL parser(data_type_parser)
      CALL logmsg(concat("GetPromptRecord: alias_parser = ",alias_parser))
      CALL logmsg(concat("GetPromptRecord: cnt_parser = ",cnt_parser))
      CALL logmsg(concat("GetPromptRecord: alterlist_parser = ",alterlist_parser))
      CALL logmsg(concat("GetPromptRecord: data_type_parser = ",data_type_parser))
      FOR (item_num = 1 TO count)
       SET idx = (idx+ 1)
       CASE (data_type)
        OF "I":
         SET which_rec_alias->number = cnvtreal(value(parameter(which_prompt,item_num)))
        OF "F":
         SET which_rec_alias->number = cnvtreal(value(parameter(which_prompt,item_num)))
        OF "C":
         SET which_rec_alias->string = value(parameter(which_prompt,item_num))
       ENDCASE
      ENDFOR
      SET cnt_parser = concat(record_name,"->cnt")
      IF (validate(parser(cnt_parser),0) > 0)
       SET return_val = record_name
      ELSE
       CALL cclexception(999,"E","GetPromptRecord: failed to add the prompt values to the new record"
        )
      ENDIF
      SET alias_parser = concat("set curalias which_rec_alias off go")
      CALL parser(alias_parser)
      CALL logmsg(concat("GetPromptRecord: cnt_parser = ",cnt_parser))
      CALL logmsg(concat("GetPromptRecord: alias_parser = ",alias_parser))
     ELSE
      CALL logmsg("GetPromptRecord: zero records found")
     ENDIF
    ENDIF
   ELSE
    CALL logmsg("GetPromptRecord: prompt value is any(*) or empty")
   ENDIF
   IF (textlen(trim(record_name,3)) > 0)
    CALL parser(concat("call logRecord(",record_name,") go"))
   ENDIF
   CALL logmsg(concat("GetPromptRecord: return value = ",return_val))
   CALL catcherrors("An error occurred in GetPromptRecord()")
   RETURN(return_val)
 END ;Subroutine
 DECLARE createrecord(which_rec=vc(value,"")) = vc
 SUBROUTINE createrecord(which_rec)
   DECLARE record_name = vc WITH private, noconstant(" ")
   DECLARE record_parser = vc WITH private, noconstant(" ")
   DECLARE new_record_ind = i2 WITH private, noconstant(0)
   DECLARE return_val = vc WITH private, noconstant(" ")
   IF (textlen(trim(which_rec,3)) > 0)
    IF (findstring(".",which_rec,1,0) > 0)
     SET record_name = concat("ccps_",trim(which_rec,3),"_rec")
    ELSE
     SET record_name = trim(which_rec,3)
    ENDIF
   ELSE
    SET record_name = build("ccps_temp_",(ccps_records->cnt+ 1),"_rec")
   ENDIF
   SET record_name = concat(trim(replace(record_name,concat(
       'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 !"#$%&',
       "'()*+,-./:;<=>?@[\]^_`{|}~"),concat(
       "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_______",
       "__________________________"),3),3))
   CALL logmsg(concat("CreateRecord: record_name = ",record_name))
   IF ( NOT (validate(parser(record_name))))
    SET record_parser = concat("record ",record_name," (1 cnt = i4",
     " 1 list[*] 2 string = vc 2 number = f8"," 1 data_type = c1 1 num = i4)",
     " with persistscript go")
    CALL logmsg(concat("CreateRecord: record parser = ",record_parser))
    CALL parser(record_parser)
    IF (validate(parser(record_name)))
     SET return_val = record_name
     SET ccps_records->cnt = (ccps_records->cnt+ 1)
     SET stat = alterlist(ccps_records->list,ccps_records->cnt)
     SET ccps_records->list[ccps_records->cnt].name = record_name
    ELSE
     CALL cclexception(999,"E","CreateRecord: failed to create record")
    ENDIF
   ELSE
    CALL cclexception(999,"E","CreateRecord: record already exists")
    CALL parser(concat("call logRecord(",record_name,") go"))
   ENDIF
   CALL logrecord(ccps_records)
   CALL logmsg(concat("CreateRecord: return value = ",return_val))
   CALL catcherrors("An error occurred in CreateRecord()")
   RETURN(return_val)
 END ;Subroutine
 DECLARE createexpandparser(which_column=vc,which_rec=vc,which_option=i2(value,list_in)) = vc
 SUBROUTINE createexpandparser(which_column,which_rec,which_option)
   DECLARE return_val = vc WITH private, noconstant("0=1")
   DECLARE option_str = vc WITH private, noconstant(" ")
   DECLARE record_member = vc WITH private, noconstant(" ")
   DECLARE data_type = vc WITH private, noconstant(" ")
   DECLARE data_type_parser = vc WITH private, noconstant(" ")
   IF (validate(parser(which_rec)))
    IF (which_option=list_not_in)
     SET option_str = " NOT"
    ENDIF
    SET data_type_parser = concat("set data_type = ",which_rec,"->data_type go")
    CALL parser(data_type_parser)
    CASE (data_type)
     OF "I":
      SET record_member = "number"
     OF "F":
      SET record_member = "number"
     OF "C":
      SET record_member = "string"
    ENDCASE
    SET return_val = build(option_str," expand(",which_rec,"->num",",",
     "1,",which_rec,"->cnt,",which_column,",",
     which_rec,"->list[",which_rec,"->num].",record_member,
     ")")
   ELSE
    CALL logmsg(concat("CreateExpandParser: ",which_rec," does not exist"))
   ENDIF
   CALL logmsg(concat("CreateExpandParser: return value = ",return_val))
   CALL catcherrors("An error occurred in CreateExpandParser()")
   RETURN(return_val)
 END ;Subroutine
 CALL logmsg("sc_cps_get_prompt_list 007 11/02/2012 ML011047")
 IF ( NOT (validate(reply->status_data)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE ld_concept_person = i2 WITH public, constant(1)
 DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
 DECLARE ld_concept_organization = i2 WITH public, constant(3)
 DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
 DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
 DECLARE ld_concept_encounter = i2 WITH public, constant(6)
 DECLARE ld_concept_location = i2 WITH public, constant(7)
 DECLARE ld_concept_pft_encntr = i2 WITH public, constant(8)
 DECLARE ld_concept_billing = i2 WITH public, constant(9)
 DECLARE invalid_printer = i2 WITH public, constant(1)
 DECLARE invalid_user = i2 WITH public, constant(2)
 DECLARE invalid_ld = i2 WITH public, constant(3)
 DECLARE ops_scheduler = i4 WITH public, constant(4600)
 DECLARE ops_monitor = i4 WITH public, constant(4700)
 DECLARE ops_server = i4 WITH public, constant(4800)
 DECLARE isopsjob = i2 WITH public, constant(isopsexecution(null))
 DECLARE ismine = i2 WITH public, constant(ismine(null))
 DECLARE logical_domain_error = i4 WITH public, noconstant(0)
 DECLARE cur_logical_domain = f8 WITH public, constant(getcurrentlogicaldomain(reqinfo->updt_id))
 IF (cur_logical_domain < 0)
  SET logical_domain_error = cnvtint(abs(cur_logical_domain))
 ENDIF
 IF (textlen(trim(reflect(parameter(1,0)),3)) > 0)
  IF (ispromptsingle(1)
   AND substring(1,1,reflect(parameter(1,1)))="C")
   IF ( NOT (isprinterindomain(value(parameter(1,0)),cur_logical_domain)))
    SET logical_domain_error = invalid_printer
   ENDIF
  ENDIF
 ENDIF
 DECLARE isuserindomain(user_id=f8,log_domain_id=f8) = i2
 SUBROUTINE isuserindomain(user_id,log_domain_id)
   DECLARE return_val = i2 WITH noconstant(- (1)), protect
   DECLARE b_logicaldomain = i4 WITH constant(column_exists("PRSNL","LOGICAL_DOMAIN_ID")), protect
   DECLARE user_domain_grp_id = f8 WITH noconstant(0.0), protect
   IF (b_logicaldomain)
    SELECT INTO "nl:"
     FROM prsnl p
     PLAN (p
      WHERE p.person_id=user_id)
     HEAD p.person_id
      user_domain_grp_id = p.logical_domain_grp_id
      IF (user_domain_grp_id=0.0)
       IF (p.logical_domain_id=log_domain_id)
        return_val = 1
       ELSE
        return_val = 0
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (user_domain_grp_id > 0.0)
     SELECT INTO "nl:"
      FROM logical_domain_grp_reltn ld
      PLAN (ld
       WHERE ld.logical_domain_grp_id=user_domain_grp_id
        AND ld.active_ind=1
        AND ld.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND ld.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      HEAD ld.logical_domain_grp_id
       return_val = 0
      HEAD ld.logical_domain_id
       IF (ld.logical_domain_id=log_domain_id)
        return_val = 1
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE isorgindomain(org_id=f8,log_domain_id=f8) = i2
 SUBROUTINE isorgindomain(org_id,log_domain_id)
   DECLARE return_val = i2 WITH noconstant(- (1)), protect
   DECLARE b_logicaldomain = i4 WITH constant(column_exists("ORGANIZATION","LOGICAL_DOMAIN_ID")),
   protect
   IF (b_logicaldomain)
    SELECT INTO "nl:"
     FROM organization o
     PLAN (o
      WHERE o.organization_id=org_id)
     HEAD o.organization_id
      IF (o.logical_domain_id=log_domain_id)
       return_val = 1
      ELSE
       return_val = 0
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE isorginuserdomain(org_id=f8,user_id=f8) = i2
 SUBROUTINE isorginuserdomain(org_id,user_id)
   DECLARE return_val = i2 WITH noconstant(- (1)), protect
   DECLARE org_domain_id = f8 WITH noconstant(0.0), protect
   DECLARE b_logicaldomain = i4 WITH noconstant(column_exists("ORGANIZATION","LOGICAL_DOMAIN_ID")),
   protect
   IF (b_logicaldomain)
    SELECT INTO "nl:"
     FROM organization o
     PLAN (o
      WHERE o.organization_id=org_id)
     HEAD o.organization_id
      org_domain_id = o.logical_domain_id
     WITH nocounter
    ;end select
    SET return_val = isuserindomain(user_id,org_domain_id)
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE islogicaldomainsactive(null) = i2
 SUBROUTINE islogicaldomainsactive(null)
   DECLARE return_val = i4 WITH noconstant(0), protect
   DECLARE b_logicaldomain = i4 WITH noconstant(column_exists("LOGICAL_DOMAIN","LOGICAL_DOMAIN_ID")),
   protect
   DECLARE ld_id = f8 WITH noconstant(0.0), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   IF (b_logicaldomain)
    SELECT INTO "nl:"
     FROM logical_domain ld
     PLAN (ld
      WHERE ld.logical_domain_id > 0.0
       AND ld.active_ind=1)
     ORDER BY ld.logical_domain_id
     HEAD ld.logical_domain_id
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE column_exists(stable=vc,scolumn=vc) = i4
 SUBROUTINE column_exists(stable,scolumn)
   DECLARE return_val = i4 WITH noconstant(0), protect
   DECLARE ce_temp = vc WITH noconstant(""), protect
   SET stable = cnvtupper(stable)
   SET scolumn = cnvtupper(scolumn)
   IF (((currev=8
    AND currevminor=2
    AND currevminor2 >= 4) OR (((currev=8
    AND currevminor > 2) OR (currev > 8)) )) )
    SET ce_temp = build('"',stable,".",scolumn,'"')
    SET stat = checkdic(parser(ce_temp),"A",0)
    IF (stat > 0)
     SET return_val = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr a,
      dtableattrl l
     WHERE a.table_name=stable
      AND l.attr_name=scolumn
      AND l.structtype="F"
      AND btest(l.stat,11)=0
     DETAIL
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE getcurrentlogicaldomain(user_id=f8(value,0.0)) = f8
 SUBROUTINE getcurrentlogicaldomain(user_id)
   DECLARE return_val = f8 WITH noconstant(0.0), protect
   IF (isopsjob)
    SET return_val = getopslogicaldomain(null)
   ELSE
    IF (islogicaldomainsactive(null))
     SELECT INTO "nl:"
      FROM prsnl p
      PLAN (p
       WHERE p.person_id=user_id)
      HEAD p.person_id
       return_val = p.logical_domain_id
      WITH nocounter
     ;end select
     IF (curqual <= 0)
      SET return_val = - (2.0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = curprog
      SET reply->status_data.subeventstatus[1].targetobjectname = "getCurrentLogicalDomain"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("User ",trim(cnvtstring(
         user_id),3)," is not related to a Logical Domain.")
     ENDIF
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE getopslogicaldomain(null) = f8
 SUBROUTINE getopslogicaldomain(null)
   DECLARE return_val = f8 WITH noconstant(0.0), protect
   DECLARE last_prompt = i4 WITH noconstant(0), protect
   DECLARE ld_prompt_val = vc WITH noconstant(""), protect
   DECLARE ld_prompt_prefix = vc WITH noconstant(""), protect
   DECLARE ld_prompt_id = vc WITH noconstant(""), protect
   IF (isopsjob)
    IF (islogicaldomainsactive(null))
     WHILE (textlen(trim(reflect(parameter((last_prompt+ 1),0)),3)) > 0)
       SET last_prompt = (last_prompt+ 1)
     ENDWHILE
     IF (last_prompt > 0
      AND ispromptsingle(last_prompt)
      AND substring(1,1,reflect(parameter(last_prompt,1)))="C")
      SET ld_prompt_val = trim(check(cnvtupper(value(parameter(last_prompt,1))),char(40)),3)
      SET ld_prompt_prefix = substring(1,3,ld_prompt_val)
      IF (ld_prompt_prefix="LD:")
       SET return_val = - (3.0)
       SET ld_prompt_id = substring(4,(textlen(ld_prompt_val) - 3),ld_prompt_val)
       IF (isnumeric(ld_prompt_id))
        SELECT INTO "nl:"
         FROM logical_domain ld
         PLAN (ld
          WHERE ld.logical_domain_id=cnvtreal(ld_prompt_id)
           AND ld.active_ind=1)
         ORDER BY ld.logical_domain_id
         HEAD ld.logical_domain_id
          return_val = ld.logical_domain_id
         WITH nocounter
        ;end select
       ENDIF
       IF ((return_val=- (3.0)))
        SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Logical Domain ID ",
         ld_prompt_id," is not valid.")
       ENDIF
      ELSE
       SET return_val = - (3.0)
       SET reply->status_data.subeventstatus[1].targetobjectvalue = build2(
        "Batch Selection is Missing the ","Logical Domain Prefix, e.g., 'LD:'.")
      ENDIF
     ELSE
      SET return_val = - (3.0)
      SET reply->status_data.subeventstatus[1].targetobjectvalue = build2(
       "Batch Selection is Missing the ","Logical Domain Prefix and ID, e.g., ","'LD:1234.00'.")
     ENDIF
     IF (return_val < 0.0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = curprog
      SET reply->status_data.subeventstatus[1].targetobjectname = "getOpsLogicalDomain"
     ENDIF
    ENDIF
   ELSE
    SET return_val = - (2.0)
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE ismine(null) = i2
 SUBROUTINE ismine(null)
   DECLARE return_val = i2 WITH noconstant(0), private
   IF (textlen(trim(reflect(parameter(1,0)),3)) > 0)
    IF (ispromptsingle(1)
     AND substring(1,1,reflect(parameter(1,1)))="C")
     IF (((cnvtupper(validate(request->qual[1].parameter,"NOT MINE"))="MINE") OR (cnvtupper(trim(
       check(value(parameter(1,1)),char(40)),3))="MINE")) )
      SET return_val = 1
     ENDIF
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE isprinterindomain(output_dest=vc,log_domain_id=f8) = i2
 SUBROUTINE isprinterindomain(output_dest,log_domain_id)
   DECLARE cur_printer = vc WITH constant(trim(check(output_dest,char(40)),3)), protect
   DECLARE isvalid = i2 WITH noconstant(0), protect
   IF (islogicaldomainsactive(null))
    IF (checkqueue(cur_printer))
     SELECT INTO "nl:"
      FROM output_dest od,
       device d,
       location l,
       organization o
      PLAN (od
       WHERE od.name=cur_printer)
       JOIN (d
       WHERE d.device_cd=od.device_cd)
       JOIN (l
       WHERE l.location_cd=d.location_cd
        AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND l.active_ind=1)
       JOIN (o
       WHERE o.organization_id=l.organization_id
        AND o.logical_domain_id=log_domain_id
        AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND o.active_ind=1)
      ORDER BY o.logical_domain_id
      HEAD REPORT
       isvalid = 1
      WITH nocounter
     ;end select
     IF ( NOT (isvalid)
      AND  NOT (logical_domain_error))
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = curprog
      SET reply->status_data.subeventstatus[1].targetobjectname = "IsPrinterInDomain"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Printer ",cur_printer,
       " is not valid ","for Logical Domain ID ",trim(cnvtstring(log_domain_id),3),
       ".")
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE getldconceptparser(pconcept=i2,pfield=vc,plogicaldomainid=f8,pprompt=i2(value,0),poption=i2(
   value,list_in)) = vc
 SUBROUTINE getldconceptparser(pconcept,pfield,plogicaldomainid,pprompt,poption)
   DECLARE return_val = vc WITH private, noconstant("1=1")
   IF (pprompt > 0)
    IF ( NOT (ispromptempty(pprompt))
     AND  NOT (ispromptany(pprompt)))
     SET return_val = getpromptlist(pprompt,pfield,poption)
    ENDIF
   ENDIF
   CASE (pconcept)
    OF ld_concept_person:
     IF (column_exists("PERSON","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1"," from person p_ld",
       " where p_ld.person_id = ",
       pfield," and p_ld.logical_domain_id = ",plogicaldomainid,")")
     ENDIF
    OF ld_concept_prsnl:
     IF (column_exists("PRSNL","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1"," from prsnl p_ld",
       " where p_ld.person_id = ",
       pfield," and p_ld.logical_domain_id = ",plogicaldomainid,")")
     ENDIF
    OF ld_concept_organization:
     IF (column_exists("ORGANIZATION","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1"," from organization o_ld",
       " where o_ld.organization_id = ",
       pfield," and o_ld.logical_domain_id = ",plogicaldomainid,")")
     ENDIF
    OF ld_concept_healthplan:
     IF (column_exists("HEALTH_PLAN","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1"," from health_plan hp_ld",
       " where hp_ld.health_plan_id = ",
       pfield," and hp_ld.logical_domain_id = ",plogicaldomainid,")")
     ENDIF
    OF ld_concept_alias_pool:
     IF (column_exists("ALIAS_POOL","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1"," from alias_pool ap_ld",
       " where ap_ld.alias_pool_cd = ",
       pfield," and ap_ld.logical_domain_id = ",plogicaldomainid,")")
     ENDIF
    OF ld_concept_encounter:
     IF (column_exists("PERSON","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1",
       " from encounter e_ld, person p_ld"," where e_ld.encntr_id = ",
       pfield," and p_ld.person_id = e_ld.person_id"," and p_ld.logical_domain_id = ",
       plogicaldomainid,")")
     ENDIF
    OF ld_concept_location:
     IF (column_exists("ORGANIZATION","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1",
       " from location l_ld, organization o_ld"," where l_ld.location_cd = ",
       pfield," and o_ld.organization_id = l_ld.organization_id"," and o_ld.logical_domain_id = ",
       plogicaldomainid,")")
     ENDIF
    OF ld_concept_pft_encntr:
     IF (column_exists("PERSON","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1",
       " from pft_encntr pe_ld, encounter e_ld, person p_ld"," where pe_ld.pft_encntr_id = ",
       pfield," and e_ld.encntr_id = pe_ld.encntr_id"," and p_ld.person_id = e_ld.person_id",
       " and p_ld.logical_domain_id = ",plogicaldomainid,
       ")")
     ENDIF
    OF ld_concept_billing:
     IF (column_exists("ORGANIZATION","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1",
       " from billing_entity be_ld, organization o_ld"," where be_ld.billing_entity_id = ",
       pfield," and o_ld.organization_id = be_ld.organization_id"," and o_ld.logical_domain_id = ",
       plogicaldomainid,")")
     ENDIF
    ELSE
     SET return_val = "0=1"
   ENDCASE
   RETURN(return_val)
 END ;Subroutine
 DECLARE isopsexecution(null) = i2
 SUBROUTINE isopsexecution(null)
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (validate(reqinfo->updt_app,- (1)) IN (ops_scheduler, ops_monitor, ops_server))
    SET return_val = true
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 IF ( NOT (validate(list_in)))
  DECLARE list_in = i2 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(list_not_in)))
  DECLARE list_not_in = i2 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(cs278_facility)))
  DECLARE cs278_facility = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4977"))
 ENDIF
 IF ( NOT (validate(cs278_client)))
  DECLARE cs278_client = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4974"))
 ENDIF
 IF ( NOT (validate(ccps_org_sec_rec)))
  RECORD ccps_org_sec_rec(
    1 cnt = i4
    1 list[*]
      2 organization_id = f8
      2 logical_domain_id = f8
      2 name = vc
    1 prsnl_id = f8
    1 org_type_cd = f8
    1 num = i4
  )
 ENDIF
 DECLARE isencntrorgsecurityon(null) = i2
 SUBROUTINE isencntrorgsecurityon(null)
   DECLARE return_val = i2 WITH protect, noconstant(0)
   IF (validate(ccldminfo->mode,0))
    IF ((ccldminfo->sec_org_reltn > 0))
     SET return_val = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="SEC_ORG_RELTN"
      AND di.info_domain="SECURITY"
      AND di.info_number > 0.0
     DETAIL
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE isconfidentialitysecurityon(null) = i2
 SUBROUTINE isconfidentialitysecurityon(null)
   DECLARE return_val = i2 WITH protect, noconstant(0)
   IF (validate(ccldminfo->mode,0))
    IF ((ccldminfo->sec_confid > 0))
     SET return_val = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="SEC_CONFID"
      AND di.info_domain="SECURITY"
      AND di.info_number > 0.0
     DETAIL
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE ispersonorgsecurityon(null) = i2
 SUBROUTINE ispersonorgsecurityon(null)
   DECLARE return_val = i2 WITH protect, noconstant(0)
   IF (validate(ccldminfo->mode,0))
    IF ((ccldminfo->person_org_sec > 0))
     SET return_val = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="PERSON_ORG_SEC"
      AND di.info_domain="SECURITY"
      AND di.info_number > 0.0
     DETAIL
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE getprsnlorglist(prsnl_id=f8,which_column=vc,which_option=i2(value,list_in),org_type_cd=f8(
   value,cs278_facility)) = vc
 SUBROUTINE getprsnlorglist(prsnl_id,which_column,which_option,org_type_cd)
   DECLARE option_str = vc WITH private, noconstant(" ")
   DECLARE idx = i4 WITH private, noconstant(0)
   DECLARE return_val = vc WITH private, noconstant("0=1")
   IF (getprsnlorgrecord(prsnl_id,org_type_cd))
    IF (which_option=list_not_in)
     SET option_str = " not in ("
    ELSE
     SET option_str = " in ("
    ENDIF
    SET return_val = concat("(",which_column,option_str)
    FOR (idx = 1 TO ccps_org_sec_rec->cnt)
     IF (mod(idx,1000)=1
      AND idx > 1)
      SET return_val = replace(return_val,",",")",2)
      SET return_val = concat(return_val," or ",which_column,option_str)
     ENDIF
     SET return_val = build(return_val,ccps_org_sec_rec->list[idx].organization_id,",")
    ENDFOR
    SET return_val = replace(return_val,",",")",2)
    SET return_val = concat(return_val,")")
   ENDIF
   CALL logmsg(concat("GetPrsnlOrgList: return value = ",return_val))
   RETURN(return_val)
 END ;Subroutine
 DECLARE getprsnlorgexpand(prsnl_id=f8,which_column=vc,which_option=i2(value,list_in),org_type_cd=f8(
   value,cs278_facility)) = vc
 SUBROUTINE getprsnlorgexpand(prsnl_id,which_column,which_option,org_type_cd)
   DECLARE return_val = vc WITH private, noconstant("0=1")
   DECLARE option_str = vc WITH private, noconstant(" ")
   IF (getprsnlorgrecord(prsnl_id,org_type_cd))
    IF (which_option=list_not_in)
     SET option_str = " NOT"
    ENDIF
    SET return_val = build(option_str," expand(ccps_org_sec_rec->num,","1,","ccps_org_sec_rec->cnt,",
     which_column,
     ",","ccps_org_sec_rec->list[ccps_org_sec_rec->num].organization_id)")
   ENDIF
   CALL logmsg(concat("GetPrsnlOrgExpand: return value = ",return_val))
   RETURN(return_val)
 END ;Subroutine
 DECLARE getprsnlorgrecord(prsnl_id=f8,org_type_cd=f8(value,cs278_facility)) = i2
 SUBROUTINE getprsnlorgrecord(prsnl_id,org_type_cd)
   DECLARE return_val = i2 WITH private, noconstant(0)
   SET ccps_org_sec_rec->prsnl_id = prsnl_id
   SET ccps_org_sec_rec->org_type_cd = org_type_cd
   SELECT INTO "nl:"
    FROM prsnl_org_reltn por,
     organization o,
     org_type_reltn otr
    PLAN (por
     WHERE por.person_id=prsnl_id
      AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND por.active_ind=1)
     JOIN (o
     WHERE o.organization_id=por.organization_id
      AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND o.active_ind=1)
     JOIN (otr
     WHERE otr.organization_id=o.organization_id
      AND ((otr.org_type_cd+ 0)=org_type_cd)
      AND otr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND otr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND otr.active_ind=1)
    ORDER BY por.organization_id
    HEAD REPORT
     cnt = 0
    HEAD por.organization_id
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(ccps_org_sec_rec->list,(cnt+ 9))
     ENDIF
     ccps_org_sec_rec->list[cnt].organization_id = o.organization_id, ccps_org_sec_rec->list[cnt].
     logical_domain_id = o.logical_domain_id, ccps_org_sec_rec->list[cnt].name = trim(o.org_name,3)
    FOOT REPORT
     ccps_org_sec_rec->cnt = cnt, stat = alterlist(ccps_org_sec_rec->list,cnt)
    WITH nocounter
   ;end select
   IF ((ccps_org_sec_rec->cnt > 0))
    SET return_val = 1
   ELSE
    CALL logmsg("GetPrsnlOrgRecord: zero records qualified")
   ENDIF
   CALL logrecord(ccps_org_sec_rec)
   CALL logmsg(build("GetPrsnlOrgRecord: return value = ",return_val))
   RETURN(return_val)
 END ;Subroutine
 CALL logmsg("ccps_org_security 001 10/26/2012 ML011047")
 DECLARE isldactive = i2 WITH constant(islogicaldomainsactive(null)), protect
 DECLARE ld_parser = vc WITH noconstant("0=1"), protect
 DECLARE organization_parser = vc WITH noconstant("0=1"), protect
 DECLARE ld_failure_flag = i4 WITH noconstant(0), protect
 DECLARE display_message = vc WITH noconstant(" "), protect
 IF (logical_domain_error)
  SET display_message = reply->status_data.subeventstatus[1].targetobjectvalue
  SET ld_failure_flag = 1
  GO TO exit_prg
 ENDIF
 DECLARE createldorgparsers(prsnl_id=f8,ld_column=vc,org_prompt=i2,org_column=vc,which_option=i2(
   value,list_in)) = null
 SUBROUTINE createldorgparsers(prsnl_id,ld_column,org_prompt,org_column,which_option)
   DECLARE ld_mismatch = i2 WITH protect, noconstant(0)
   DECLARE org_cnt = i4 WITH protect, noconstant(0)
   DECLARE option_str = vc WITH private, noconstant(" ")
   IF (isldactive)
    IF (((ispromptany(org_prompt)) OR (ispromptempty(org_prompt))) )
     SET organization_parser = getprsnlorgexpand(prsnl_id,org_column,which_option,cs278_client)
    ELSEIF (((ispromptlist(org_prompt)) OR (ispromptsingle(org_prompt))) )
     CALL getpromptrecord(org_prompt,"org_prompt_rec")
     IF (validate(org_prompt_rec->cnt))
      SELECT INTO "nl:"
       FROM organization o,
        logical_domain ld
       PLAN (o
        WHERE expand(org_prompt_rec->num,1,org_prompt_rec->cnt,o.organization_id,org_prompt_rec->
         list[org_prompt_rec->num].number))
        JOIN (ld
        WHERE ld.logical_domain_id=o.logical_domain_id
         AND ld.active_ind=1)
       ORDER BY o.organization_id
       HEAD REPORT
        pos = 0, cs_logical_domain_id = 0.0
       DETAIL
        IF (cs_logical_domain_id=0.0)
         cs_logical_domain_id = o.logical_domain_id
        ELSE
         IF (cs_logical_domain_id != o.logical_domain_id)
          ld_mismatch = 1
         ENDIF
        ENDIF
        pos = locateval(org_prompt_rec->num,1,org_prompt_rec->cnt,o.organization_id,org_prompt_rec->
         list[org_prompt_rec->num].number)
        IF (pos > 0)
         org_prompt_rec->list[pos].string = trim(o.org_name,3)
        ENDIF
        org_cnt = (org_cnt+ 1)
       WITH nocounter, expand = 1
      ;end select
      IF (ld_mismatch=1)
       SET display_message = build2(
        "Logical domains are in use. Please verify each organization ID shares ",
        "the same logical_domain_id when running from operations.")
      ELSEIF ((org_cnt != org_prompt_rec->cnt))
       SET display_message = "Please verify each organization ID is valid."
      ELSE
       SET organization_parser = createexpandparser(org_column,"org_prompt_rec",which_option)
      ENDIF
     ENDIF
    ENDIF
    IF (which_option=list_not_in)
     SET option_str = " not in ("
    ELSE
     SET option_str = " in ("
    ENDIF
    SET ld_parser = build(ld_column,option_str,cur_logical_domain,")")
   ELSE
    IF (((ispromptany(org_prompt)) OR (ispromptempty(org_prompt))) )
     SET organization_parser = getprsnlorgexpand(prsnl_id,org_column,which_option,cs278_client)
    ELSEIF (((ispromptlist(org_prompt)) OR (ispromptsingle(org_prompt))) )
     CALL getpromptrecord(org_prompt,"org_prompt_rec")
     IF (validate(org_prompt_rec->cnt))
      SELECT INTO "nl:"
       FROM organization o
       PLAN (o
        WHERE expand(org_prompt_rec->num,1,org_prompt_rec->cnt,o.organization_id,org_prompt_rec->
         list[org_prompt_rec->num].number))
       ORDER BY o.organization_id
       HEAD REPORT
        pos = 0
       DETAIL
        pos = locateval(org_prompt_rec->num,1,org_prompt_rec->cnt,o.organization_id,org_prompt_rec->
         list[org_prompt_rec->num].number)
        IF (pos > 0)
         org_prompt_rec->list[pos].string = trim(o.org_name,3)
        ENDIF
        org_cnt = (org_cnt+ 1)
       WITH nocounter, expand = 1
      ;end select
      IF ((org_cnt=org_prompt_rec->cnt))
       SET organization_parser = createexpandparser(org_column,"org_prompt_rec",which_option)
      ELSE
       SET display_message = "Please verify each organization ID is valid."
      ENDIF
     ENDIF
    ENDIF
    SET ld_parser = "1=1"
   ENDIF
   IF (validate(org_prompt_rec))
    CALL logrecord(org_prompt_rec)
   ENDIF
   CALL logmsg(build2("* * * ld_parser is:     ",ld_parser))
   CALL logmsg(build2("* * * ORGANIZATION_PARSER is:     ",organization_parser))
   CALL logmsg(build2("* * * display_message is:     ",display_message))
   CALL logmsg(build2("* * * is opsjob:     ",isopsjob))
 END ;Subroutine
 CALL logmsg("ccps_cs_security 000 10/26/2012 ML011047")
 CALL createldorgparsers(reqinfo->updt_id,"o.logical_domain_id",4,"otr.organization_id")
 IF (((ld_parser="0=1") OR (organization_parser="0=1")) )
  SET ld_failure_flag = 1
  SET display_message = "The logical domain and/or organization security validation failed."
  GO TO exit_prg
 ENDIF
 CALL echo(build2("* * * ld_parser is ",ld_parser))
 CALL echo(build2("* * * ORGANIZATION_PARSER is ",organization_parser))
 CALL echo(build2("* * * CUR_LOGICAL_DOMAIN is ",cur_logical_domain))
 IF (cur_logical_domain > 0.00)
  SELECT INTO "nl:"
   FROM organization o,
    billing_entity be,
    location l
   PLAN (o
    WHERE o.logical_domain_id=cur_logical_domain
     AND o.active_ind=1)
    JOIN (be
    WHERE be.organization_id=o.organization_id)
    JOIN (l
    WHERE l.organization_id=be.organization_id
     AND l.location_type_cd=222_facility_location_type_cd)
   ORDER BY l.location_cd
   HEAD l.location_cd
    IF (textlen(temp_facility_parser)=0)
     temp_facility_parser = concat(cnvtstring(l.location_cd,0))
    ELSE
     temp_facility_parser = concat(temp_facility_parser,", ",cnvtstring(l.location_cd,0))
    ENDIF
   FOOT  l.location_cd
    facility_parser = concat(" mfoi.parent_entity_id in (",temp_facility_parser,")")
   WITH nocounter
  ;end select
  CALL echo(build2("* * * FACILITY_PARSER is ",facility_parser))
 ENDIF
 IF (ispromptempty(5))
  SET activity_type_parser = "1=1"
 ELSE
  SET activity_type_parser = getpromptlist(5,"bi.ext_owner_cd")
 ENDIF
 IF (((ispromptempty(5)) OR (ispromptany(5))) )
  SET activity_type_is_rad = "Yes"
  SET activity_type_is_pharm = "Yes"
  SET activity_type_anyall = "Yes"
 ELSE
  SET pharm_findstring = findstring(pharm_cnvtstring_temp,activity_type_parser,1,0)
  SET rad_findstring = findstring(rad_cnvtstring_temp,activity_type_parser,1,0)
  IF (rad_findstring > 0)
   SET activity_type_is_rad = "Yes"
  ELSEIF (pharm_findstring > 0)
   SET activity_type_is_pharm = "Yes"
  ENDIF
 ENDIF
 DECLARE num_wl_for_header = i2 WITH noconstant(0)
 DECLARE comma_char = vc WITH constant(char(44))
 DECLARE quote_char = vc WITH constant(char(34))
 DECLARE row_detail = vc WITH noconstant(" ")
 DECLARE bc_header = vc WITH noconstant(" ")
 DECLARE price_header = vc WITH noconstant(" ")
 DECLARE cp_header = vc WITH noconstant(" ")
 DECLARE wl_header = vc WITH noconstant(" ")
 DECLARE total_header = vc WITH noconstant(" ")
 DECLARE bi_header = vc WITH constant(concat("BILL_ITEM_ID",comma_char,"PARENT_REFERENCE_ID",
   comma_char,"CHILD_REFERENCE_ID",
   comma_char,"LONG_DESCRIPTION",comma_char,"SHORT_DESCRIPTION",comma_char,
   "ACTIVITY_TYPE",comma_char))
 DECLARE ao_header = vc WITH constant(concat("GENERIC ADD-ONS",comma_char))
 DECLARE file_name = vc WITH noconstant(concat("bill_item_audit_",format(cnvtdatetime(curdate,
     curtime3),"mmddyyyy_hhmm;;q"),".csv"))
 DECLARE zip_file_name = vc WITH constant("bill_item_audit.dat")
 DECLARE full_file_path = vc WITH noconstant(" ")
 DECLARE zip_full_file_path = vc WITH noconstant(" ")
 DECLARE email_address = vc WITH noconstant(" ")
 DECLARE file_directory = c10 WITH constant("ccluserdir")
 DECLARE file_removal = i2 WITH constant(1)
 SET full_file_path = build(logical(file_directory),"/",file_name)
 SET zip_full_file_path = build(logical(file_directory),"/",zip_file_name)
 SET email_address = trim( $EMAIL_TO)
 DECLARE email_subject = vc WITH protect, constant("Charge Services Bill Item Audit")
 DECLARE email_from = vc WITH protect, constant("Cerner")
 DECLARE email_stat = i2 WITH protect, noconstant(0)
 DECLARE dclcom9 = vc WITH private, noconstant("")
 DECLARE dclstatus9 = i2 WITH private, noconstant(9)
 DECLARE other_zip_filename = vc WITH noconstant(" ")
 FREE RECORD bill_item_audit
 RECORD bill_item_audit(
   1 bia_cnt = i4
   1 bia_detail[*]
     2 bill_item_id = f8
     2 parent_reference_id = f8
     2 child_reference_id = f8
     2 child_contributor_cd = f8
     2 long_description = vc
     2 short_description = vc
     2 activity_type_cd = f8
     2 activity_type = vc
     2 cp_cnt = i4
     2 cp_detail[*]
       3 cp_bi_mod_id = f8
       3 chrg_point_sched_cd = f8
       3 chrg_point_sched = vc
       3 chrg_point = vc
       3 chrg_level = vc
       3 chrg_attributes = vc
     2 bc_cnt = i4
     2 bc_detail[*]
       3 bc_bi_mod_id = f8
       3 bill_code_sched_cd = f8
       3 bill_code = vc
       3 bill_code_qcf = f8
     2 p_cnt = i4
     2 p_detail[*]
       3 price_sched_items_id = f8
       3 price_sched_id = f8
       3 price = vc
     2 ao_cnt = i4
     2 ao_detail[*]
       3 ao_bi_mod_id = f8
       3 ao_description = vc
       3 ao_qty = f8
     2 wl_cnt = i4
     2 wl_detail[*]
       3 wl_bi_mod_id = f8
       3 wl_sched = f8
       3 wl_code = vc
       3 wl_code_desc = vc
       3 wl_stage = vc
       3 wl_item_for_count = vc
       3 wl_raw_count = f8
       3 wl_multiplier = f8
       3 wl_units = f8
       3 wl_riq = i2
       3 wlc_code_id = f8
       3 wlc_code = vc
       3 wlc_code_desc = vc
       3 wlc_stage = vc
       3 wlc_item_for_count = vc
       3 wlc_multiplier = i4
       3 wlc_units = f8
       3 book = vc
       3 chapter = vc
       3 section = vc
 )
 FREE SET schedules
 RECORD schedules(
   1 price_cnt = i4
   1 price_detail[*]
     2 price_sched_id = f8
     2 price_sched_desc = vc
   1 bill_code_cnt = i4
   1 bill_code_detail[*]
     2 bill_code_cd = f8
     2 bill_code_desc = vc
     2 bill_code_sched_type = f8
   1 chrg_process_cnt = i4
   1 chrg_process_detail[*]
     2 chrg_process_cd = f8
     2 chrg_process_desc = vc
 )
 SELECT DISTINCT
  tier_cell_display =
  IF (tm.tier_cell_entity_name="CODE_VALUE") trim(uar_get_code_display(tm.tier_cell_value_id))
  ELSEIF (tm.tier_cell_entity_name="PRICE_SCHED") trim(ps.price_sched_desc)
  ENDIF
  , tm.tier_cell_type_cd
  FROM org_type_reltn otr,
   organization o,
   bill_org_payor bop,
   tier_matrix tm,
   price_sched ps
  PLAN (otr
   WHERE otr.org_type_cd=client_org_type_cd
    AND parser(organization_parser))
   JOIN (o
   WHERE o.organization_id=otr.organization_id
    AND parser(ld_parser))
   JOIN (bop
   WHERE bop.organization_id=o.organization_id
    AND bop.bill_org_type_cd IN (
   (SELECT
    cv3.code_value
    FROM code_value cv3
    WHERE ((cv3.code_set+ 0)=13031)
     AND trim(cv3.cdf_meaning) IN ("CLTTIERGROUP", "TIERGROUP")
     AND cv3.active_ind=1))
    AND bop.active_ind=1
    AND bop.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND bop.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (tm
   WHERE tm.tier_group_cd=bop.bill_org_type_id
    AND tm.tier_cell_type_cd IN (charge_point_cd, cdm_sched_cd, cpt4_cd, hcpcs_cd, modifier_cd,
   price_sched_cd, revenue_cd)
    AND tm.active_ind=1
    AND tm.beg_effective_dt_tm <= cnvtdatetime(eff_dt_tm)
    AND tm.end_effective_dt_tm > cnvtdatetime(eff_dt_tm))
   JOIN (ps
   WHERE ps.price_sched_id=outerjoin(tm.tier_cell_value_id)
    AND ps.active_ind=outerjoin(1)
    AND ps.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ps.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY tm.tier_cell_type_cd, tier_cell_display
  HEAD REPORT
   price_cnt = 0, bill_code_cnt = 0, chrg_process_cnt = 0
  DETAIL
   IF (tm.tier_cell_type_cd=charge_point_cd)
    chrg_process_cnt = (chrg_process_cnt+ 1), stat = alterlist(schedules->chrg_process_detail,
     chrg_process_cnt), schedules->chrg_process_detail[chrg_process_cnt].chrg_process_cd = tm
    .tier_cell_value_id,
    schedules->chrg_process_detail[chrg_process_cnt].chrg_process_desc = trim(uar_get_code_display(tm
      .tier_cell_value_id))
    IF (textlen(chrg_process_cd_parser)=0)
     chrg_process_cd_parser = cnvtstring(tm.tier_cell_value_id,0)
    ELSE
     chrg_process_cd_parser = concat(chrg_process_cd_parser,", ",cnvtstring(tm.tier_cell_value_id,0))
    ENDIF
    cp_header = concat(cp_header,quote_char,trim(schedules->chrg_process_detail[chrg_process_cnt].
      chrg_process_desc),quote_char,comma_char)
   ELSEIF (tm.tier_cell_type_cd=price_sched_cd)
    price_cnt = (price_cnt+ 1)
    IF (mod(price_cnt,5)=1)
     stat = alterlist(schedules->price_detail,(price_cnt+ 4))
    ENDIF
    schedules->price_detail[price_cnt].price_sched_id = tm.tier_cell_value_id, schedules->
    price_detail[price_cnt].price_sched_desc = trim(ps.price_sched_desc)
    IF (textlen(price_id_parser)=0)
     price_id_parser = cnvtstring(tm.tier_cell_value_id,0)
    ELSE
     price_id_parser = concat(price_id_parser,", ",cnvtstring(tm.tier_cell_value_id,0))
    ENDIF
    price_header = concat(price_header,quote_char,trim(schedules->price_detail[price_cnt].
      price_sched_desc),quote_char,comma_char)
   ELSE
    bill_code_cnt = (bill_code_cnt+ 1)
    IF (mod(bill_code_cnt,5)=1)
     stat = alterlist(schedules->bill_code_detail,(bill_code_cnt+ 4))
    ENDIF
    schedules->bill_code_detail[bill_code_cnt].bill_code_cd = tm.tier_cell_value_id, schedules->
    bill_code_detail[bill_code_cnt].bill_code_desc = trim(uar_get_code_display(tm.tier_cell_value_id)
     ), schedules->bill_code_detail[bill_code_cnt].bill_code_sched_type = tm.tier_cell_type_cd
    IF (textlen(bill_code_cd_parser)=0)
     bill_code_cd_parser = cnvtstring(tm.tier_cell_value_id,0)
    ELSE
     bill_code_cd_parser = concat(bill_code_cd_parser,", ",cnvtstring(tm.tier_cell_value_id,0))
    ENDIF
    IF (tm.tier_cell_type_cd=hcpcs_cd)
     combine_desc_qcf = concat(trim(substring(1,100,schedules->bill_code_detail[bill_code_cnt].
        bill_code_desc))," - QCF"), bc_header = concat(bc_header,quote_char,schedules->
      bill_code_detail[bill_code_cnt].bill_code_desc,quote_char,comma_char,
      quote_char,trim(combine_desc_qcf),quote_char,comma_char)
    ELSE
     bc_header = concat(bc_header,quote_char,schedules->bill_code_detail[bill_code_cnt].
      bill_code_desc,quote_char,comma_char)
    ENDIF
   ENDIF
  FOOT REPORT
   chrg_process_cd_parser = concat(" bim.key1_id in (",chrg_process_cd_parser,")"), price_id_parser
    = concat(" psi.price_sched_id in (",price_id_parser,")"), bill_code_cd_parser = concat(
    " bim.key1_id in (",bill_code_cd_parser,")"),
   stat = alterlist(schedules->price_detail,price_cnt), schedules->price_cnt = price_cnt, stat =
   alterlist(schedules->bill_code_detail,bill_code_cnt),
   schedules->bill_code_cnt = bill_code_cnt, stat = alterlist(schedules->chrg_process_detail,
    chrg_process_cnt), schedules->chrg_process_cnt = chrg_process_cnt
  WITH nocounter
 ;end select
 SET pharm_cdm_findstring = findstring(pharm_cdm_cnvtstring_temp,bill_code_cd_parser,1,0)
 IF (pharm_cdm_findstring > 0)
  SET pharm_cdm_exists = "Yes"
 ENDIF
 SELECT
  IF (( $AUDIT_TYPE="ALL"))
   FROM bill_item bi,
    (left JOIN bill_item_modifier bim ON bim.bill_item_id=bi.bill_item_id
     AND ((bim.bill_item_type_cd+ 0) IN (chrg_point_sch_cd, bill_code_sch_cd, add_on_assigned_cd,
    workload_sch_cd))
     AND bim.active_ind=1
     AND ((bim.beg_effective_dt_tm+ 0) <= cnvtdatetime(eff_dt_tm))
     AND ((bim.end_effective_dt_tm+ 0) > cnvtdatetime(eff_dt_tm))),
    (left JOIN workload_code wc ON wc.workload_code_id=bim.key3_id
     AND wc.active_ind=1),
    (left JOIN workload_group wg ON wg.workload_code_id=wc.workload_code_id
     AND wg.active_ind=1)
   PLAN (bi
    WHERE ((parser(activity_type_parser)) OR (bi.ext_owner_cd=0.00
     AND bi.ext_child_contributor_cd=alpha_response_cd))
     AND ((bi.logical_domain_id=0.00
     AND  NOT (bi.ext_owner_cd IN (106_add_on_activity_type_cd, 106_supplies_activity_type_cd))) OR (
    bi.logical_domain_id=cur_logical_domain
     AND bi.ext_owner_cd IN (106_add_on_activity_type_cd, 106_supplies_activity_type_cd)))
     AND ((bi.active_ind+ 0)=1)
     AND bi.beg_effective_dt_tm <= cnvtdatetime(eff_dt_tm)
     AND bi.end_effective_dt_tm > cnvtdatetime(eff_dt_tm))
    JOIN (bim)
    JOIN (wc)
    JOIN (wg)
  ELSE
   FROM bill_item bi,
    bill_item_modifier bim,
    workload_code wc,
    workload_group wg
   PLAN (bi
    WHERE ((parser(activity_type_parser)) OR (bi.ext_owner_cd=0.00
     AND bi.ext_child_contributor_cd=alpha_response_cd))
     AND ((bi.logical_domain_id=0.00
     AND  NOT (bi.ext_owner_cd IN (106_add_on_activity_type_cd, 106_supplies_activity_type_cd))) OR (
    bi.logical_domain_id=cur_logical_domain
     AND bi.ext_owner_cd IN (106_add_on_activity_type_cd, 106_supplies_activity_type_cd)))
     AND ((bi.active_ind+ 0)=1)
     AND bi.beg_effective_dt_tm <= cnvtdatetime(eff_dt_tm)
     AND bi.end_effective_dt_tm > cnvtdatetime(eff_dt_tm))
    JOIN (bim
    WHERE bim.bill_item_id=bi.bill_item_id
     AND ((((bim.bill_item_type_cd+ 0)=chrg_point_sch_cd)
     AND parser(chrg_process_cd_parser)) OR (((((bim.bill_item_type_cd+ 0)=bill_code_sch_cd)
     AND parser(bill_code_cd_parser)) OR (((bim.bill_item_type_cd+ 0) IN (add_on_assigned_cd,
    workload_sch_cd)))) ))
     AND bim.active_ind=1
     AND ((bim.beg_effective_dt_tm+ 0) <= cnvtdatetime(eff_dt_tm))
     AND ((bim.end_effective_dt_tm+ 0) > cnvtdatetime(eff_dt_tm)))
    JOIN (wc
    WHERE wc.workload_code_id=outerjoin(bim.key3_id)
     AND wc.active_ind=outerjoin(1))
    JOIN (wg
    WHERE wg.workload_code_id=outerjoin(wc.workload_code_id)
     AND wg.active_ind=outerjoin(1))
  ENDIF
  INTO "nl:"
  bill_code_sched_meaning = uar_get_code_meaning(bim.key1_id), bill_code_sched_display =
  uar_get_code_display(bim.key1_id)
  ORDER BY bi.bill_item_id, bill_code_sched_meaning, bill_code_sched_display
  HEAD REPORT
   bia_cnt = 0, num_wl_for_header = 0
  HEAD bi.bill_item_id
   bia_cnt = (bia_cnt+ 1)
   IF (mod(bia_cnt,1000)=1)
    stat = alterlist(bill_item_audit->bia_detail,(bia_cnt+ 999))
   ENDIF
   bill_item_audit->bia_detail[bia_cnt].bill_item_id = bi.bill_item_id, bill_item_audit->bia_detail[
   bia_cnt].parent_reference_id = bi.ext_parent_reference_id, bill_item_audit->bia_detail[bia_cnt].
   child_reference_id = bi.ext_child_reference_id,
   bill_item_audit->bia_detail[bia_cnt].child_contributor_cd = bi.ext_child_contributor_cd,
   bill_item_audit->bia_detail[bia_cnt].long_description = trim(bi.ext_description), bill_item_audit
   ->bia_detail[bia_cnt].short_description = trim(bi.ext_short_desc),
   bill_item_audit->bia_detail[bia_cnt].activity_type_cd = bi.ext_owner_cd, bill_item_audit->
   bia_detail[bia_cnt].activity_type = trim(uar_get_code_display(bi.ext_owner_cd)), cp_cnt = 0,
   bc_cnt = 0, ao_cnt = 0, wl_cnt = 0
  DETAIL
   IF (bim.bill_item_type_cd=chrg_point_sch_cd
    AND parser(chrg_process_cd_parser))
    cp_cnt = (cp_cnt+ 1)
    IF (mod(cp_cnt,5)=1)
     stat = alterlist(bill_item_audit->bia_detail[bia_cnt].cp_detail,(cp_cnt+ 4))
    ENDIF
    bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].cp_bi_mod_id = bim.bill_item_mod_id,
    bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_point_sched_cd = bim.key1_id,
    bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_point_sched = trim(
     uar_get_code_display(bim.key1_id)),
    bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_point = trim(uar_get_code_display(bim
      .key2_id)), bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_level = trim(
     uar_get_code_display(bim.key4_id))
    CASE (bim.bim1_int)
     OF 1:
      bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "M"
     OF 2:
      bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "D"
     OF 3:
      bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "MD"
     OF 4:
      bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "P"
     OF 5:
      bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "MP"
     OF 6:
      bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "DP"
     OF 7:
      bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "MDP"
     OF 8:
      bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "Q"
     OF 9:
      bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "MQ"
     OF 10:
      bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "DQ"
     OF 11:
      bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "MDQ"
     OF 12:
      bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "PQ"
     OF 13:
      bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "MPQ"
     OF 14:
      bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "DPQ"
     OF 15:
      bill_item_audit->bia_detail[bia_cnt].cp_detail[cp_cnt].chrg_attributes = "MDPQ"
    ENDCASE
   ELSEIF (bim.bill_item_type_cd=bill_code_sch_cd
    AND parser(bill_code_cd_parser))
    bc_cnt = (bc_cnt+ 1)
    IF (mod(bc_cnt,5)=1)
     stat = alterlist(bill_item_audit->bia_detail[bia_cnt].bc_detail,(bc_cnt+ 4))
    ENDIF
    bill_item_audit->bia_detail[bia_cnt].bc_detail[bc_cnt].bc_bi_mod_id = bim.bill_item_mod_id,
    bill_item_audit->bia_detail[bia_cnt].bc_detail[bc_cnt].bill_code_sched_cd = bim.key1_id,
    bill_item_audit->bia_detail[bia_cnt].bc_detail[bc_cnt].bill_code = trim(bim.key6),
    bill_item_audit->bia_detail[bia_cnt].bc_detail[bc_cnt].bill_code_qcf = bim.bim1_nbr
   ELSEIF (bim.bill_item_type_cd=add_on_assigned_cd
    AND bi.logical_domain_id=cur_logical_domain)
    ao_cnt = (ao_cnt+ 1)
    IF (mod(ao_cnt,5)=1)
     stat = alterlist(bill_item_audit->bia_detail[bia_cnt].ao_detail,(ao_cnt+ 4))
    ENDIF
    bill_item_audit->bia_detail[bia_cnt].ao_detail[ao_cnt].ao_bi_mod_id = bim.bill_item_mod_id,
    bill_item_audit->bia_detail[bia_cnt].ao_detail[ao_cnt].ao_description = trim(bim.key6),
    bill_item_audit->bia_detail[bia_cnt].ao_detail[ao_cnt].ao_qty = bim.bim1_int
   ELSEIF (bim.bill_item_type_cd=workload_sch_cd)
    wl_cnt = (wl_cnt+ 1)
    IF (mod(wl_cnt,5)=1)
     stat = alterlist(bill_item_audit->bia_detail[bia_cnt].wl_detail,(wl_cnt+ 4))
    ENDIF
    bill_item_audit->bia_detail[bia_cnt].wl_detail[wl_cnt].wl_bi_mod_id = bim.bill_item_mod_id,
    bill_item_audit->bia_detail[bia_cnt].wl_detail[wl_cnt].wl_sched = bim.key1_id, bill_item_audit->
    bia_detail[bia_cnt].wl_detail[wl_cnt].wl_code = trim(bim.key6),
    bill_item_audit->bia_detail[bia_cnt].wl_detail[wl_cnt].wl_code_desc = nullterm(replace(bim.key7,
      '"',"",0)), bill_item_audit->bia_detail[bia_cnt].wl_detail[wl_cnt].wl_stage = trim(
     uar_get_code_display(bim.key2_id)), bill_item_audit->bia_detail[bia_cnt].wl_detail[wl_cnt].
    wl_item_for_count = trim(uar_get_code_display(bim.key15_id)),
    bill_item_audit->bia_detail[bia_cnt].wl_detail[wl_cnt].wl_raw_count = bim.bim1_int,
    bill_item_audit->bia_detail[bia_cnt].wl_detail[wl_cnt].wl_multiplier = bim.bim2_int,
    bill_item_audit->bia_detail[bia_cnt].wl_detail[wl_cnt].wl_units = bim.bim1_nbr,
    bill_item_audit->bia_detail[bia_cnt].wl_detail[wl_cnt].wl_riq = bim.bim1_ind, bill_item_audit->
    bia_detail[bia_cnt].wl_detail[wl_cnt].wlc_code_id = bim.key3_id, bill_item_audit->bia_detail[
    bia_cnt].wl_detail[wl_cnt].wlc_code = trim(wc.code),
    bill_item_audit->bia_detail[bia_cnt].wl_detail[wl_cnt].wlc_code_desc = trim(wc.description),
    bill_item_audit->bia_detail[bia_cnt].wl_detail[wl_cnt].wlc_stage = trim(uar_get_code_display(wc
      .event_cd)), bill_item_audit->bia_detail[bia_cnt].wl_detail[wl_cnt].wlc_item_for_count = trim(
     uar_get_code_display(wc.item_for_count_cd)),
    bill_item_audit->bia_detail[bia_cnt].wl_detail[wl_cnt].wlc_multiplier = wc.multiplier,
    bill_item_audit->bia_detail[bia_cnt].wl_detail[wl_cnt].wlc_units = wc.units, bill_item_audit->
    bia_detail[bia_cnt].wl_detail[wl_cnt].book = trim(uar_get_code_display(wg.book_cd)),
    bill_item_audit->bia_detail[bia_cnt].wl_detail[wl_cnt].chapter = trim(uar_get_code_display(wg
      .chapter_cd)), bill_item_audit->bia_detail[bia_cnt].wl_detail[wl_cnt].section = trim(
     uar_get_code_display(wg.section_cd))
   ENDIF
  FOOT  bi.bill_item_id
   stat = alterlist(bill_item_audit->bia_detail[bia_cnt].cp_detail,cp_cnt), bill_item_audit->
   bia_detail[bia_cnt].cp_cnt = cp_cnt, stat = alterlist(bill_item_audit->bia_detail[bia_cnt].
    bc_detail,bc_cnt),
   bill_item_audit->bia_detail[bia_cnt].bc_cnt = bc_cnt, stat = alterlist(bill_item_audit->
    bia_detail[bia_cnt].ao_detail,ao_cnt), bill_item_audit->bia_detail[bia_cnt].ao_cnt = ao_cnt,
   stat = alterlist(bill_item_audit->bia_detail[bia_cnt].wl_detail,wl_cnt), bill_item_audit->
   bia_detail[bia_cnt].wl_cnt = wl_cnt
   IF (wl_cnt > num_wl_for_header)
    num_wl_for_header = wl_cnt
   ENDIF
  FOOT REPORT
   stat = alterlist(bill_item_audit->bia_detail,bia_cnt), bill_item_audit->bia_cnt = bia_cnt
  WITH nocounter
 ;end select
 IF (pharm_cdm_exists="Yes"
  AND activity_type_is_pharm="Yes"
  AND cur_logical_domain=0.00)
  SELECT INTO "nl:"
   FROM bill_item bi,
    med_product mp,
    med_identifier mi1,
    med_identifier mi3
   PLAN (bi
    WHERE bi.ext_owner_cd=pharm_activity_type_cd
     AND ((bi.active_ind+ 0)=1))
    JOIN (mp
    WHERE mp.manf_item_id=bi.ext_parent_reference_id
     AND mp.active_ind=1)
    JOIN (mi1
    WHERE mi1.med_product_id=mp.med_product_id
     AND mi1.active_ind=1
     AND mi1.primary_ind=1
     AND mi1.med_identifier_type_cd=ndc_med_id_type_cd)
    JOIN (mi3
    WHERE mi3.item_id=mi1.item_id
     AND mi3.active_ind=1
     AND mi3.med_identifier_type_cd=cdm_med_id_type_cd)
   ORDER BY bi.bill_item_id
   HEAD bi.bill_item_id
    pos = locateval(num,1,bill_item_audit->bia_cnt,bi.bill_item_id,bill_item_audit->bia_detail[num].
     bill_item_id)
    IF (pos=0)
     bia_cnt = (bill_item_audit->bia_cnt+ 1), stat = alterlist(bill_item_audit->bia_detail,bia_cnt),
     bill_item_audit->bia_detail[bia_cnt].bill_item_id = bi.bill_item_id,
     bill_item_audit->bia_detail[bia_cnt].parent_reference_id = bi.ext_parent_reference_id,
     bill_item_audit->bia_detail[bia_cnt].child_reference_id = bi.ext_child_reference_id,
     bill_item_audit->bia_detail[bia_cnt].child_contributor_cd = bi.ext_child_contributor_cd,
     bill_item_audit->bia_detail[bia_cnt].long_description = trim(bi.ext_description),
     bill_item_audit->bia_detail[bia_cnt].short_description = trim(bi.ext_short_desc),
     bill_item_audit->bia_detail[bia_cnt].activity_type_cd = bi.ext_owner_cd,
     bill_item_audit->bia_detail[bia_cnt].activity_type = trim(uar_get_code_display(bi.ext_owner_cd)),
     bill_item_audit->bia_cnt = bia_cnt, bc_cnt = (bill_item_audit->bia_detail[bia_cnt].bc_cnt+ 1),
     stat = alterlist(bill_item_audit->bia_detail[bia_cnt].bc_detail,bc_cnt), bill_item_audit->
     bia_detail[bia_cnt].bc_detail[bc_cnt].bill_code_sched_cd = pharm_cdm_cd, bill_item_audit->
     bia_detail[bia_cnt].bc_detail[bc_cnt].bill_code = trim(mi3.value),
     bill_item_audit->bia_detail[bia_cnt].bc_cnt = bc_cnt
    ELSE
     pos2 = locateval(num2,1,bill_item_audit->bia_detail[pos].bc_cnt,pharm_cdm_cd,bill_item_audit->
      bia_detail[pos].bc_detail[num2].bill_code_sched_cd)
     IF (pos2=0)
      bc_cnt = (bill_item_audit->bia_detail[pos].bc_cnt+ 1), stat = alterlist(bill_item_audit->
       bia_detail[pos].bc_detail,bc_cnt), bill_item_audit->bia_detail[pos].bc_detail[bc_cnt].
      bill_code_sched_cd = pharm_cdm_cd,
      bill_item_audit->bia_detail[pos].bc_detail[bc_cnt].bill_code = trim(mi3.value), bill_item_audit
      ->bia_detail[pos].bc_cnt = bc_cnt
     ELSEIF (pos2 > 0
      AND textlen(trim(bill_item_audit->bia_detail[pos].bc_detail[num2].bill_code))=0)
      bill_item_audit->bia_detail[pos].bc_detail[pos2].bill_code_sched_cd = pharm_cdm_cd,
      bill_item_audit->bia_detail[pos].bc_detail[pos2].bill_code = trim(mi3.value)
     ENDIF
    ENDIF
   FOOT  bi.bill_item_id
    null
   WITH nocounter
  ;end select
 ELSEIF (pharm_cdm_exists="Yes"
  AND activity_type_is_pharm="Yes"
  AND cur_logical_domain > 0.00)
  SELECT INTO "nl:"
   FROM bill_item bi,
    med_product mp,
    med_identifier mi1,
    med_identifier mi3,
    med_def_flex mdf,
    med_flex_object_idx mfoi
   PLAN (bi
    WHERE bi.ext_owner_cd=pharm_activity_type_cd
     AND ((bi.active_ind+ 0)=1))
    JOIN (mp
    WHERE mp.manf_item_id=bi.ext_parent_reference_id
     AND mp.active_ind=1)
    JOIN (mi1
    WHERE mi1.med_product_id=mp.med_product_id
     AND mi1.active_ind=1
     AND mi1.primary_ind=1
     AND mi1.med_identifier_type_cd=ndc_med_id_type_cd)
    JOIN (mi3
    WHERE mi3.item_id=mi1.item_id
     AND mi3.active_ind=1
     AND mi3.med_identifier_type_cd=cdm_med_id_type_cd)
    JOIN (mdf
    WHERE mdf.item_id=mi3.item_id
     AND mdf.pharmacy_type_cd=4500_inpt_pharmacy_type_cd
     AND mdf.active_ind=1)
    JOIN (mfoi
    WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
     AND parser(facility_parser)
     AND mfoi.active_ind=1)
   ORDER BY bi.bill_item_id
   HEAD bi.bill_item_id
    pos = locateval(num,1,bill_item_audit->bia_cnt,bi.bill_item_id,bill_item_audit->bia_detail[num].
     bill_item_id)
    IF (pos=0)
     bia_cnt = (bill_item_audit->bia_cnt+ 1), stat = alterlist(bill_item_audit->bia_detail,bia_cnt),
     bill_item_audit->bia_detail[bia_cnt].bill_item_id = bi.bill_item_id,
     bill_item_audit->bia_detail[bia_cnt].parent_reference_id = bi.ext_parent_reference_id,
     bill_item_audit->bia_detail[bia_cnt].child_reference_id = bi.ext_child_reference_id,
     bill_item_audit->bia_detail[bia_cnt].child_contributor_cd = bi.ext_child_contributor_cd,
     bill_item_audit->bia_detail[bia_cnt].long_description = trim(bi.ext_description),
     bill_item_audit->bia_detail[bia_cnt].short_description = trim(bi.ext_short_desc),
     bill_item_audit->bia_detail[bia_cnt].activity_type_cd = bi.ext_owner_cd,
     bill_item_audit->bia_detail[bia_cnt].activity_type = trim(uar_get_code_display(bi.ext_owner_cd)),
     bill_item_audit->bia_cnt = bia_cnt, bc_cnt = (bill_item_audit->bia_detail[bia_cnt].bc_cnt+ 1),
     stat = alterlist(bill_item_audit->bia_detail[bia_cnt].bc_detail,bc_cnt), bill_item_audit->
     bia_detail[bia_cnt].bc_detail[bc_cnt].bill_code_sched_cd = pharm_cdm_cd, bill_item_audit->
     bia_detail[bia_cnt].bc_detail[bc_cnt].bill_code = trim(mi3.value),
     bill_item_audit->bia_detail[bia_cnt].bc_cnt = bc_cnt
    ELSE
     pos2 = locateval(num2,1,bill_item_audit->bia_detail[pos].bc_cnt,pharm_cdm_cd,bill_item_audit->
      bia_detail[pos].bc_detail[num2].bill_code_sched_cd)
     IF (pos2=0)
      bc_cnt = (bill_item_audit->bia_detail[pos].bc_cnt+ 1), stat = alterlist(bill_item_audit->
       bia_detail[pos].bc_detail,bc_cnt), bill_item_audit->bia_detail[pos].bc_detail[bc_cnt].
      bill_code_sched_cd = pharm_cdm_cd,
      bill_item_audit->bia_detail[pos].bc_detail[bc_cnt].bill_code = trim(mi3.value), bill_item_audit
      ->bia_detail[pos].bc_cnt = bc_cnt
     ELSEIF (pos2 > 0
      AND textlen(trim(bill_item_audit->bia_detail[pos].bc_detail[num2].bill_code))=0)
      bill_item_audit->bia_detail[pos].bc_detail[pos2].bill_code_sched_cd = pharm_cdm_cd,
      bill_item_audit->bia_detail[pos].bc_detail[pos2].bill_code = trim(mi3.value)
     ENDIF
    ENDIF
   FOOT  bi.bill_item_id
    null
   WITH nocounter
  ;end select
 ENDIF
 IF (( $AUDIT_TYPE="ALL"))
  SELECT INTO "nl:"
   FROM price_sched_items psi,
    price_sched ps
   PLAN (psi
    WHERE expand(index,1,bill_item_audit->bia_cnt,psi.bill_item_id,bill_item_audit->bia_detail[index]
     .bill_item_id)
     AND parser(price_id_parser)
     AND psi.active_ind=1
     AND psi.beg_effective_dt_tm <= cnvtdatetime(eff_dt_tm)
     AND psi.end_effective_dt_tm > cnvtdatetime(eff_dt_tm))
    JOIN (ps
    WHERE ps.price_sched_id=psi.price_sched_id
     AND ps.active_ind=1
     AND ps.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ps.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY psi.bill_item_id, ps.price_sched_desc
   HEAD psi.bill_item_id
    p_cnt = 0, pos = locateval(num,1,bill_item_audit->bia_cnt,psi.bill_item_id,bill_item_audit->
     bia_detail[num].bill_item_id)
   DETAIL
    IF (pos > 0)
     p_cnt = (p_cnt+ 1)
     IF (mod(p_cnt,5)=1)
      stat = alterlist(bill_item_audit->bia_detail[pos].p_detail,(p_cnt+ 4))
     ENDIF
     bill_item_audit->bia_detail[pos].p_detail[p_cnt].price_sched_items_id = psi.price_sched_items_id,
     bill_item_audit->bia_detail[pos].p_detail[p_cnt].price_sched_id = psi.price_sched_id,
     bill_item_audit->bia_detail[pos].p_detail[p_cnt].price = trim(format(psi.price,
       "###########.##;R"),3)
     IF (psi.interval_template_cd > 0.00)
      bill_item_audit->bia_detail[pos].p_detail[p_cnt].price = "interval"
     ENDIF
     IF (psi.stats_only_ind=1)
      bill_item_audit->bia_detail[pos].p_detail[p_cnt].price = "STAT"
     ENDIF
    ENDIF
   FOOT  psi.bill_item_id
    stat = alterlist(bill_item_audit->bia_detail[pos].p_detail,p_cnt), bill_item_audit->bia_detail[
    pos].p_cnt = p_cnt
   WITH nocounter, expand = 1
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM price_sched_items psi,
    bill_item bi,
    price_sched ps
   PLAN (psi
    WHERE parser(price_id_parser)
     AND psi.active_ind=1
     AND psi.beg_effective_dt_tm <= cnvtdatetime(eff_dt_tm)
     AND psi.end_effective_dt_tm > cnvtdatetime(eff_dt_tm))
    JOIN (bi
    WHERE bi.bill_item_id=psi.bill_item_id
     AND ((parser(activity_type_parser)) OR (bi.ext_owner_cd=0.00
     AND bi.ext_child_contributor_cd=alpha_response_cd))
     AND ((bi.logical_domain_id=0.00
     AND  NOT (bi.ext_owner_cd IN (106_add_on_activity_type_cd, 106_supplies_activity_type_cd))) OR (
    bi.logical_domain_id=cur_logical_domain
     AND bi.ext_owner_cd IN (106_add_on_activity_type_cd, 106_supplies_activity_type_cd)))
     AND ((bi.active_ind+ 0)=1)
     AND bi.beg_effective_dt_tm <= cnvtdatetime(eff_dt_tm)
     AND bi.end_effective_dt_tm > cnvtdatetime(eff_dt_tm))
    JOIN (ps
    WHERE ps.price_sched_id=psi.price_sched_id
     AND ps.active_ind=1
     AND ps.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ps.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY psi.bill_item_id, ps.price_sched_desc
   HEAD REPORT
    bia_cnt = bill_item_audit->bia_cnt, num = 0
   HEAD psi.bill_item_id
    pos = locateval(num,1,size(bill_item_audit->bia_detail,5),psi.bill_item_id,bill_item_audit->
     bia_detail[num].bill_item_id)
    IF (pos=0)
     bia_cnt = (bia_cnt+ 1), stat = alterlist(bill_item_audit->bia_detail,bia_cnt), bill_item_audit->
     bia_detail[bia_cnt].bill_item_id = bi.bill_item_id,
     bill_item_audit->bia_detail[bia_cnt].parent_reference_id = bi.ext_parent_reference_id,
     bill_item_audit->bia_detail[bia_cnt].child_reference_id = bi.ext_child_reference_id,
     bill_item_audit->bia_detail[bia_cnt].child_contributor_cd = bi.ext_child_contributor_cd,
     bill_item_audit->bia_detail[bia_cnt].long_description = trim(bi.ext_description),
     bill_item_audit->bia_detail[bia_cnt].short_description = trim(bi.ext_short_desc),
     bill_item_audit->bia_detail[bia_cnt].activity_type_cd = bi.ext_owner_cd,
     bill_item_audit->bia_detail[bia_cnt].activity_type = trim(uar_get_code_display(bi.ext_owner_cd)),
     bill_item_audit->bia_cnt = bia_cnt
    ENDIF
    p_cnt = 0
   DETAIL
    IF (pos > 0)
     p_cnt = (p_cnt+ 1)
     IF (mod(p_cnt,5)=1)
      stat = alterlist(bill_item_audit->bia_detail[pos].p_detail,(p_cnt+ 4))
     ENDIF
     bill_item_audit->bia_detail[pos].p_detail[p_cnt].price_sched_items_id = psi.price_sched_items_id,
     bill_item_audit->bia_detail[pos].p_detail[p_cnt].price_sched_id = psi.price_sched_id,
     bill_item_audit->bia_detail[pos].p_detail[p_cnt].price = trim(format(psi.price,
       "###########.##;R"),3)
     IF (psi.interval_template_cd > 0.00)
      bill_item_audit->bia_detail[pos].p_detail[p_cnt].price = "interval"
     ENDIF
     IF (psi.stats_only_ind=1)
      bill_item_audit->bia_detail[pos].p_detail[p_cnt].price = "STAT"
     ENDIF
    ELSE
     p_cnt = (p_cnt+ 1)
     IF (mod(p_cnt,5)=1)
      stat = alterlist(bill_item_audit->bia_detail[bia_cnt].p_detail,(p_cnt+ 4))
     ENDIF
     bill_item_audit->bia_detail[bia_cnt].p_detail[p_cnt].price_sched_items_id = psi
     .price_sched_items_id, bill_item_audit->bia_detail[bia_cnt].p_detail[p_cnt].price_sched_id = psi
     .price_sched_id, bill_item_audit->bia_detail[bia_cnt].p_detail[p_cnt].price = trim(format(psi
       .price,"###########.##;R"),3)
     IF (psi.interval_template_cd > 0.00)
      bill_item_audit->bia_detail[bia_cnt].p_detail[p_cnt].price = "interval"
     ENDIF
     IF (psi.stats_only_ind=1)
      bill_item_audit->bia_detail[bia_cnt].p_detail[p_cnt].price = "STAT"
     ENDIF
    ENDIF
   FOOT  psi.bill_item_id
    IF (pos > 0)
     stat = alterlist(bill_item_audit->bia_detail[pos].p_detail,p_cnt), bill_item_audit->bia_detail[
     pos].p_cnt = p_cnt
    ELSE
     stat = alterlist(bill_item_audit->bia_detail[bia_cnt].p_detail,p_cnt), bill_item_audit->
     bia_detail[bia_cnt].p_cnt = p_cnt
    ENDIF
   FOOT REPORT
    stat = alterlist(bill_item_audit->bia_detail,bia_cnt), bill_item_audit->bia_cnt = bia_cnt
   WITH nocounter
  ;end select
 ENDIF
 IF (activity_type_is_rad="Yes")
  SELECT INTO "nl:"
   primary_sort = bill_item_audit->bia_detail[d.seq].parent_reference_id, secondary_sort =
   bill_item_audit->bia_detail[d.seq].child_reference_id
   FROM (dummyt d  WITH seq = value(bill_item_audit->bia_cnt))
   PLAN (d
    WHERE (bill_item_audit->bia_detail[d.seq].activity_type_cd=rad_activity_type_cd))
   ORDER BY primary_sort, secondary_sort
   HEAD primary_sort
    IF ((bill_item_audit->bia_detail[d.seq].child_reference_id=0.00))
     temp_description = bill_item_audit->bia_detail[d.seq].long_description
    ENDIF
   DETAIL
    IF (cnvtupper(trim(bill_item_audit->bia_detail[d.seq].long_description))="REPORT")
     bill_item_audit->bia_detail[d.seq].long_description = concat(trim(temp_description)," - Report")
    ENDIF
   FOOT  primary_sort
    null
   WITH nocounter
  ;end select
 ENDIF
 SET num = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(bill_item_audit->bia_cnt))
  PLAN (d
   WHERE (bill_item_audit->bia_detail[d.seq].child_reference_id > 0.00)
    AND (bill_item_audit->bia_detail[d.seq].activity_type_cd=0.00)
    AND (bill_item_audit->bia_detail[d.seq].parent_reference_id > 0.00))
  DETAIL
   IF ((bill_item_audit->bia_detail[d.seq].child_contributor_cd=alpha_response_cd))
    pos = locateval(num,1,size(bill_item_audit->bia_detail,5),bill_item_audit->bia_detail[d.seq].
     parent_reference_id,bill_item_audit->bia_detail[num].child_reference_id)
    IF (pos > 0)
     bill_item_audit->bia_detail[d.seq].activity_type_cd = bill_item_audit->bia_detail[pos].
     activity_type_cd, bill_item_audit->bia_detail[d.seq].activity_type = bill_item_audit->
     bia_detail[pos].activity_type, bill_item_audit->bia_detail[d.seq].long_description = concat(trim
      (bill_item_audit->bia_detail[d.seq].long_description)," - ",trim(bill_item_audit->bia_detail[
       pos].long_description))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (num_wl_for_header > 0)
  FOR (i = 1 TO num_wl_for_header)
   SET code_num = trim(cnvtstring(i))
   SET wl_header = build2(wl_header,"WL",code_num," Code",comma_char,
    "WL",code_num," Code Description",comma_char,"WL",
    code_num," Units",comma_char,"WL",code_num,
    " Stage",comma_char,"WL",code_num," Item For Count",
    comma_char,"WL",code_num," Raw Count",comma_char,
    "WL",code_num," Multiplier",comma_char,"WL",
    code_num," Result Is Quantity",comma_char,"WL",code_num,
    " Book",comma_char,"WL",code_num," Chapter",
    comma_char,"WL",code_num," Section",comma_char)
  ENDFOR
 ENDIF
 SET total_header = build2(bi_header,cp_header,bc_header,price_header,ao_header,
  wl_header)
 IF ((bill_item_audit->bia_cnt=0))
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    "{CPI/9}{FONT/4}", display_message = build2(
     "There is no data to output.  Consider changing the prompt selections."), row 0,
    col 0, display_message
   WITH nocounter, nullreport, maxcol = 300,
    dio = postscript
  ;end select
 ELSE
  SELECT
   IF (activity_type_anyall="Yes")
    FROM (dummyt d  WITH seq = value(bill_item_audit->bia_cnt))
    PLAN (d)
   ELSE
    FROM (dummyt d  WITH seq = value(bill_item_audit->bia_cnt))
    PLAN (d
     WHERE (bill_item_audit->bia_detail[d.seq].activity_type_cd > 0.00))
   ENDIF
   INTO  $OUTDEV
   primary_sort = bill_item_audit->bia_detail[d.seq].activity_type, secondary_sort = bill_item_audit
   ->bia_detail[d.seq].long_description
   ORDER BY primary_sort, secondary_sort
   HEAD REPORT
    col 0, total_header, row + 1
   DETAIL
    row_detail = "", row_detail = build2(bill_item_audit->bia_detail[d.seq].bill_item_id,comma_char,
     bill_item_audit->bia_detail[d.seq].parent_reference_id,comma_char,bill_item_audit->bia_detail[d
     .seq].child_reference_id,
     comma_char,quote_char,bill_item_audit->bia_detail[d.seq].long_description,quote_char,comma_char,
     quote_char,bill_item_audit->bia_detail[d.seq].short_description,quote_char,comma_char,quote_char,
     bill_item_audit->bia_detail[d.seq].activity_type,quote_char,comma_char)
    FOR (i = 1 TO size(schedules->chrg_process_detail,5))
      found = 0
      FOR (bi = 1 TO size(bill_item_audit->bia_detail[d.seq].cp_detail,5))
        IF ((schedules->chrg_process_detail[i].chrg_process_cd=bill_item_audit->bia_detail[d.seq].
        cp_detail[bi].chrg_point_sched_cd))
         IF (found > 0)
          row_detail = build2(row_detail,"<and>")
         ENDIF
         IF (textlen(trim(bill_item_audit->bia_detail[d.seq].cp_detail[bi].chrg_attributes))=0)
          row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].cp_detail[bi].chrg_level,
           "/",bill_item_audit->bia_detail[d.seq].cp_detail[bi].chrg_point)
         ELSE
          row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].cp_detail[bi].chrg_level,
           "/",bill_item_audit->bia_detail[d.seq].cp_detail[bi].chrg_point,"/",
           bill_item_audit->bia_detail[d.seq].cp_detail[bi].chrg_attributes)
         ENDIF
         found = (found+ 1)
        ENDIF
      ENDFOR
      row_detail = build2(row_detail,comma_char)
    ENDFOR
    FOR (i = 1 TO size(schedules->bill_code_detail,5))
      found = 0, hcpcs_output = 0
      FOR (bi = 1 TO size(bill_item_audit->bia_detail[d.seq].bc_detail,5))
        IF ((schedules->bill_code_detail[i].bill_code_cd=bill_item_audit->bia_detail[d.seq].
        bc_detail[bi].bill_code_sched_cd))
         IF (found > 0)
          row_detail = build2(row_detail,"<and>")
         ENDIF
         IF ((schedules->bill_code_detail[i].bill_code_sched_type=hcpcs_cd))
          row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].bc_detail[bi].bill_code,
           comma_char,bill_item_audit->bia_detail[d.seq].bc_detail[bi].bill_code_qcf), hcpcs_output
           = 1
         ELSE
          row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].bc_detail[bi].bill_code)
         ENDIF
         found = (found+ 1)
        ENDIF
      ENDFOR
      IF ((schedules->bill_code_detail[i].bill_code_sched_type=hcpcs_cd)
       AND hcpcs_output=0)
       row_detail = build2(row_detail,comma_char,comma_char)
      ELSE
       row_detail = build2(row_detail,comma_char)
      ENDIF
    ENDFOR
    FOR (i = 1 TO size(schedules->price_detail,5))
      found = 0
      FOR (bi = 1 TO size(bill_item_audit->bia_detail[d.seq].p_detail,5))
        IF ((schedules->price_detail[i].price_sched_id=bill_item_audit->bia_detail[d.seq].p_detail[bi
        ].price_sched_id))
         IF (found > 0)
          row_detail = build2(row_detail,"<and>")
         ENDIF
         row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].p_detail[bi].price), found
          = (found+ 1)
        ENDIF
      ENDFOR
      row_detail = build2(row_detail,comma_char)
    ENDFOR
    ao_total = size(bill_item_audit->bia_detail[d.seq].ao_detail,5), row_detail = build2(row_detail,
     quote_char)
    FOR (i = 1 TO size(bill_item_audit->bia_detail[d.seq].ao_detail,5))
      ao_total = (ao_total - 1), ao_quantity = build(cnvtint(bill_item_audit->bia_detail[d.seq].
        ao_detail[i].ao_qty)), row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].
       ao_detail[i].ao_description,"^",ao_quantity)
      IF (ao_total != 0)
       row_detail = build2(row_detail,";")
      ENDIF
    ENDFOR
    row_detail = build2(row_detail,quote_char,comma_char)
    FOR (i = 1 TO size(bill_item_audit->bia_detail[d.seq].wl_detail,5))
      row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].wl_detail[i].wl_code,
       comma_char), row_detail = build2(row_detail,quote_char,bill_item_audit->bia_detail[d.seq].
       wl_detail[i].wl_code_desc,quote_char,comma_char)
      IF ((bill_item_audit->bia_detail[d.seq].wl_detail[i].wl_units > - (1)))
       row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].wl_detail[i].wl_units,
        comma_char)
      ELSE
       row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].wl_detail[i].wlc_units,
        comma_char)
      ENDIF
      row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].wl_detail[i].wl_stage,
       comma_char), row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].wl_detail[i].
       wl_item_for_count,comma_char), row_detail = build2(row_detail,bill_item_audit->bia_detail[d
       .seq].wl_detail[i].wl_raw_count,comma_char)
      IF ((bill_item_audit->bia_detail[d.seq].wl_detail[i].wl_multiplier > - (1)))
       row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].wl_detail[i].wl_multiplier,
        comma_char)
      ELSE
       row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].wl_detail[i].wlc_multiplier,
        comma_char)
      ENDIF
      row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].wl_detail[i].wl_riq,
       comma_char), row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].wl_detail[i].
       book,comma_char), row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].wl_detail[
       i].chapter,comma_char),
      row_detail = build2(row_detail,bill_item_audit->bia_detail[d.seq].wl_detail[i].section,
       comma_char)
    ENDFOR
    col 0, row_detail, row + 1
   FOOT REPORT
    null
   WITH nocounter, nullreport, noformfeed,
    format = variable, noheading, maxcol = 32000
  ;end select
 ENDIF
#exit_prg
 SET last_mod = "04/10/13 MP9098"
END GO
