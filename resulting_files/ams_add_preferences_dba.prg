CREATE PROGRAM ams_add_preferences:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Audit/Commit" = "",
  "File Name:" = ""
  WITH outdev, auditcommit, filename
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
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 CALL echo("Entering ams add procedure")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 DECLARE application = vc
 DECLARE position = vc
 DECLARE level1 = vc
 DECLARE pref_name = vc
 DECLARE pref_value = vc
 FOR (i = 1 TO value(size(file_content->qual,5)))
   FREE RECORD request
   RECORD request(
     1 application_number = i4
     1 position_cd = f8
     1 prsnl_id = f8
     1 nv[*]
       2 pvc_name = c32
       2 pvc_value = vc
       2 sequence = i2
       2 merge_id = f8
       2 merge_name = vc
   )
   SET stat = alterlist(request->nv,1)
   SET application = trim(file_content->qual[i].application)
   CALL echo(build2("application is",application))
   SELECT
    a.application_number
    FROM application a
    WHERE a.object_name=application
    DETAIL
     request->application_number = a.application_number
   ;end select
   SET position = trim(file_content->qual[i].position)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=88
     AND cv.display=position
    DETAIL
     request->position_cd = cv.code_value
   ;end select
   SET request->prsnl_id = 0.0
   SET request->nv[1].pvc_name = trim(file_content->qual[i].pref_name)
   SET request->nv[1].pvc_value = trim(file_content->qual[i].pref_value)
   SET request->nv[1].merge_id = 0.0
   SET request->nv[1].sequence = 0
   SET request->nv[1].merge_name = " "
   CALL echo("after loading request_details")
   CALL echorecord(request)
   EXECUTE dcp_add_app_prefs
   CALL echo("Ending execution")
 ENDFOR
#exit_script
 SET script_ver = " 000 09/15/15 AK032157  Initial Release "
END GO
