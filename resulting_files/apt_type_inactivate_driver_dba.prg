CREATE PROGRAM apt_type_inactivate_driver:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "audit/commit" = "",
  "Enter the directory" = "",
  "Enter the file name" = ""
  WITH outdev, auditcommit, path,
  file
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed_mess = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed_mess = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 DECLARE parse_req_list(row_count=i2,req_list_content=vc,file_content=vc(ref)) = null
 DECLARE parse_appts(row_count=i2,inst_prep_list_content=vc,file_content=vc(ref)) = null
 DECLARE line1 = c1000
 DECLARE line2 = c1000
 DECLARE j = i4
 DECLARE locateroles = c500
 DECLARE sub_content = vc
 SET path = value(logical(trim( $PATH)))
 SET file =  $FILE
 SET file_name = build(path,"/",file)
 CALL echo(file_name)
 DEFINE rtl2 value(file_name)
 FREE RECORD file_content
 RECORD file_content(
   1 qual[*]
     2 appointment_type_name = vc
 )
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, i = 0, count = 0,
   stat = alterlist(file_content->qual,10)
  HEAD r.line
   line1 = r.line
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (count > 1)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=0)
      stat = alterlist(file_content->qual,(row_count+ 9))
     ENDIF
     file_content->qual[row_count].appointment_type_name = line1
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(file_content->qual,row_count)
  WITH nocounter
 ;end select
 CALL echorecord(file_content)
 IF (cnvtupper( $AUDITCOMMIT)="AUDIT")
  SELECT INTO  $OUTDEV
   appointment_type_name = substring(1,30,file_content->qual[d1.seq].appointment_type_name)
   FROM (dummyt d1  WITH seq = value(size(file_content->qual,5)))
   PLAN (d1)
   WITH nocounter, separator = " ", format
  ;end select
 ELSEIF (cnvtupper( $AUDITCOMMIT)="COMMIT")
  EXECUTE apt_type_inactivation:dba
  SET failed_mess = true
  SET serrmsg = "Successfully Inactivated"
 ELSE
  SET failed_mess = true
  SET serrmsg = "Invalid"
 ENDIF
 IF (failed_mess != false)
  SELECT INTO  $OUTDEV
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed_mess != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
 SET script_ver = " 000 26/06/15 MS035369         Initial Release "
END GO
