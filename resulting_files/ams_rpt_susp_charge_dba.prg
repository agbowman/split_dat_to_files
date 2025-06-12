CREATE PROGRAM ams_rpt_susp_charge:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Client Mnemonic" = "",
  "Enter Email Address" = ""
  WITH outdev, p_client, p_email
 DECLARE zipfile_full = vc WITH protect, constant("")
 DECLARE removing_file = i2 WITH protect, constant(0)
 DECLARE email_file(mail_addr=vc,from_addr=vc,mail_sub=vc,attach_file_full=vc,attach_zipfile_full=vc(
   value,zipfile_full),
  remove_files=i2(value,removing_file)) = i2
 DECLARE linuxversion(null) = i4
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
   DECLARE linver = i4 WITH private, noconstant(0.0)
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
    SET dclcom = concat("zip -j ",attach_zipfile," ",attach_file)
    CALL dcl(dclcom,size(trim(dclcom)),dclstatus)
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
    SET linver = linuxversion(null)
    IF (((dclstatus=1) OR (zipping_file=0)) )
     IF (linver >= 6.0)
      SET dclcom1 = concat("echo | mailx -r '",from_addr,"' -s '",mail_sub,"' -a '",
       email_file,"' ",mail_addr)
      SET returnval = dcl(dclcom1,size(trim(dclcom1)),dclstatus1)
     ELSE
      SET dclcom1 = concat("uuencode"," ",email_full," ",email_file,
       " ",'|mailx -s "',mail_sub,'" ',mail_to)
      SET returnval = dcl(dclcom1,size(trim(dclcom1)),dclstatus1)
     ENDIF
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
   SET last_mod = "12/28/2015 RJ4716"
 END ;Subroutine
 SUBROUTINE linuxversion(null)
   DECLARE filelinuxversiontemp = vc WITH constant(build2("ccps_rpt_os_ver.dat")), protect
   DECLARE strversion = vc WITH noconstant(""), protect
   DECLARE linversion = i4 WITH noconstant(0.0), protect
   DECLARE status = i4 WITH noconstant(0), protect
   DECLARE dcloutput = vc WITH noconstant(""), protect
   SET dclrem = build2("rm ",trim(filelinuxversiontemp,3))
   SET len = size(trim(dclrem))
   CALL dcl(dclrem,len,status)
   SET dclcom = build2("cat /etc/redhat-release >> ",trim(filelinuxversiontemp,3))
   SET len = size(trim(dclcom))
   SET status = - (1)
   CALL dcl(dclcom,len,status)
   FREE DEFINE rtl
   DEFINE rtl filelinuxversiontemp
   SELECT INTO "nl:"
    FROM rtlt r
    HEAD REPORT
     dcloutput = cnvtupper(trim(r.line,3))
    WITH nocounter
   ;end select
   SET strversion = substring((findstring("RELEASE",dcloutput)+ 8),3,dcloutput)
   IF (isnumeric(strversion) > 0)
    SET linversion = cnvtint(strversion)
   ENDIF
   RETURN(linversion)
 END ;Subroutine
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 EXECUTE ams_define_toolkit_common
 DECLARE smessage = vc WITH protect, noconstant("")
 IF (validate(reply->status_data,"F")="F")
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE dcvchargemodtypesuspense = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!3520"))
 DECLARE semailaddress = vc WITH protect, constant(trim( $P_EMAIL,3))
 DECLARE sclient = vc WITH protect, constant(cnvtupper( $P_CLIENT))
 FREE RECORD rdata
 RECORD rdata(
   1 col_knt = i4
   1 col[*]
     2 name = vc
   1 row_knt = i4
   1 row[*]
     2 col_1_value = vc
     2 col_2_value = vc
 )
 DECLARE semailsubject = vc WITH protect, noconstant(concat(sclient,
   " - Suspense Count (Total Count: "))
 DECLARE semailmessage = vc WITH protect, noconstant("")
 DECLARE itotalknt = i4 WITH protect, noconstant(0)
 SET rdata->col_knt = 2
 SET stat = alterlist(rdata->col,rdata->col_knt)
 SET rdata->col[1].name = "Suspense Reason"
 SET rdata->col[2].name = "Count"
 IF (validate(request->batch_selection,"F")="F")
  SET bisanopsjob = false
  SET bamsassociate = isamsuser(reqinfo->updt_id)
  IF ( NOT (bamsassociate))
   SET failed = exe_error
   SET serrmsg = "User must be a Cerner AMS associated to run this program from Explorer Menu"
   SET semailsubject = concat(semailsubject,"ERROR")
   SET semailmessage = "User must be a Cerner AMS associated to run this program from Explorer Menu"
   GO TO send_email
  ENDIF
 ELSE
  SET bisanopsjob = true
 ENDIF
 SELECT INTO "nl:"
  cm.field1_id, suspense_reason_disp = uar_get_code_display(cm.field1_id), suspense_reason_cd = cm
  .field1_id
  FROM charge c,
   charge_mod cm
  PLAN (c
   WHERE c.process_flg=1
    AND c.active_ind=1)
   JOIN (cm
   WHERE cm.charge_item_id=c.charge_item_id
    AND cm.charge_mod_type_cd=dcvchargemodtypesuspense
    AND cm.active_ind=1)
  ORDER BY cm.field1_id
  HEAD REPORT
   qknt = 0, stat = alterlist(rdata->row,100)
  HEAD cm.field1_id
   qknt = (qknt+ 1)
   IF (mod(qknt,100)=1
    AND qknt != 1)
    stat = alterlist(rdata->row,(qknt+ 99))
   ENDIF
   rdata->row[qknt].col_1_value = uar_get_code_display(cm.field1_id), sknt = 0
  DETAIL
   sknt = (sknt+ 1)
  FOOT  cm.field1_id
   rdata->row[qknt].col_2_value = trim(cnvtstring(sknt),3), itotalknt = (itotalknt+ sknt)
  FOOT REPORT
   rdata->row_knt = qknt, stat = alterlist(rdata->row,qknt)
  WITH nocounter
 ;end select
 SET semailsubject = concat(semailsubject,trim(cnvtstring(itotalknt),3),")")
 DECLARE scrlf = c2 WITH protect, constant(concat(char(13),char(10)))
 DECLARE squote = c1 WITH protect, constant('"')
 DECLARE scomma = c1 WITH protect, constant(",")
 FOR (ifdx = 1 TO rdata->col_knt)
   IF (ifdx=1)
    SET semailmessage = concat(squote,rdata->col[ifdx].name,squote)
   ELSE
    SET semailmessage = concat(semailmessage,scomma,squote,rdata->col[ifdx].name,squote)
   ENDIF
 ENDFOR
 SET semailmessage = concat(semailmessage,scrlf)
 IF ((rdata->row_knt > 0))
  FOR (ifdx = 1 TO rdata->row_knt)
   SET semailmessage = concat(semailmessage,squote,rdata->row[ifdx].col_1_value,squote,scomma,
    squote,rdata->row[ifdx].col_2_value,squote)
   SET semailmessage = concat(semailmessage,scrlf)
  ENDFOR
 ELSE
  SET semailmessage = concat(semailmessage,scrlf,"No Items Found")
 ENDIF
 SET semailmessage = concat(semailmessage,scrlf,scrlf,
  "Please do not reply to this email.  The from email address is not monitored")
#send_email
 CALL uar_send_mail(nullterm(semailaddress),nullterm(semailsubject),nullterm(semailmessage),concat(
   cnvtlower(sclient),"@",cnvtlower(sclient),".com"),5,
  "IPM.NOTE")
#exit_script
 IF (bisanopsjob=false)
  IF ((rdata->row_knt < 1))
   IF (failed != false)
    SET smessage = concat("ERROR: ",trim(serrmsg,3))
   ELSE
    SET smessage = concat("No Items Found >>  email sent to ",semailaddress)
   ENDIF
  ELSE
   SET smessage = concat(trim(cnvtstring(itotalknt),3)," Items Found >> email sent to ",trim(
     semailaddress,3))
  ENDIF
  IF (failed != exe_error)
   CALL updtdminfo("AMS_RPT_SUSP_CHARGE")
  ENDIF
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,smessage),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(serrmsg,3)
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=exe_error)
   SET reply->status_data.subeventstatus[1].operationname = "EXE_ERROR"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = 1)
  WITH nocounter, format, separator = " "
 ;end select
 SET script_ver = "000 08/29/12 Initial Release"
END GO
