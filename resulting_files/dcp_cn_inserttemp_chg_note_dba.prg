CREATE PROGRAM dcp_cn_inserttemp_chg_note:dba
 FREE RECORD request
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "FAILED: starting dcp_cn_inserttemp_chg_note"
 RECORD request(
   1 message_key = vc
   1 category = vc
   1 subject = vc
   1 message = vc
   1 active_ind = i2
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 applications[*]
     2 app_number = i4
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET request->message_key = "PDD_INSERT_TEMP"
 SET request->subject = "Clinical Notes and Message Center: Inserting Templates"
 DECLARE smessage = vc
 SET smessage = "Selecting the Insert button in the Template Selection window"
 SET smessage = concat(smessage," in Clinical Notes and Message Center will no longer insert")
 SET smessage = concat(smessage," the text at the end of the note. It will instead insert the")
 SET smessage = concat(smessage," template at the location of the cursor. A new button")
 SET smessage = concat(smessage," labeled Append has been added that will insert the template")
 SET smessage = concat(smessage," at the end of the note.")
 SET request->message = trim(smessage)
 SET request->active_ind = 1
 SET stat = alterlist(request->applications,3)
 SET request->applications[1].app_number = 600005
 SET request->applications[2].app_number = 961000
 SET request->applications[3].app_number = 4250111
 SELECT INTO "nl:"
  s.message_key
  FROM sys_chg_message s
  WHERE s.message_key=cnvtupper(request->message_key)
  WITH nocounter
 ;end select
 IF (curqual=0)
  EXECUTE sys_add_user_notification
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = build("Message [",request->message_key,
   "] is already present. No new notification is necessary.")
  SET reply->status_data.status = "S"
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
