CREATE PROGRAM dcp_rdm_add_overdue_lookbk_msg:dba
 IF ( NOT (validate(request,0)))
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
 ENDIF
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
 SET readme_data->message = "Readme failure. dcp_rdm_add_overdue_lookbk_msg.prg script"
 SET request->message_key = "OVERDUE_LOOKBACK_DAYS"
 SET request->category = "Order Management -- Bedside Care"
 SET request->subject = "eMAR"
 SET request->message = concat(
  "A new overdue icon button appears if you have any overdue medication tasks, ",
  "within the Overdue_Task_Look_Back time range regardless of the ",
  "current time range.  If the icon button does not appear, there are ",
  "no overdue tasks for that patient within the Overdue_Task_Look_Back ",
  "time range. If the user clicks on the icon, the system makes the ",
  "'From' time in the view equal to the oldest overdue task.  The user can then ",
  "chart any tasks in the view.  When the user clicks on the overdue icon button again, ",
  "it will take him / her back to the timeframe prior to choosing the button.")
 SET request->active_ind = 1
 SET stat = alterlist(request->applications,2)
 SET request->applications[1].app_number = 600005
 SET request->applications[2].app_number = 961000
 EXECUTE sys_add_user_notification
 CALL echorecord(readme_data)
END GO
