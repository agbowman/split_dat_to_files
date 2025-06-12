CREATE PROGRAM cmn_revoke_task_driver_1:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "Pass Input File Name" = "",
  "Select Audit/Commit" = ""
  WITH outdev, directory, inputfile,
  auditcommit
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
  SET failed = exe_error
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
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 FREE RECORD file_content
 RECORD file_content(
   1 qual[*]
     2 app_group_cd = vc
     2 task_number = vc
 )
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, i = 0, count = 0,
   stat = alterlist(file_content->qual,10)
  HEAD r.line
   line1 = r.line,
   CALL echo(line1)
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (count > 1)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=0)
      stat = alterlist(file_content->qual,(row_count+ 9))
     ENDIF
     file_content->qual[row_count].app_group_cd = piece(line1,",",1,"Not Found"), file_content->qual[
     row_count].task_number = piece(line1,",",2,"Not Found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(file_content->qual,row_count)
  WITH nocounter
 ;end select
 IF (( $AUDITCOMMIT="Audit"))
  SELECT INTO  $OUTDEV
   app_group_cd = substring(1,30,file_content->qual[d1.seq].app_group_cd), task_number = substring(1,
    30,file_content->qual[d1.seq].task_number)
   FROM (dummyt d1  WITH seq = value(size(file_content->qual,5)))
   PLAN (d1)
   WITH nocounter, separator = " ", format
  ;end select
 ELSE
  EXECUTE cmn_revoke_task:dba
  SET failed_mess = true
  SET serrmsg = "Successfully Revoked"
 ENDIF
#exit_script
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
 SET last_mod = "000  31/03/2016 KH043067 and VB035883"
END GO
