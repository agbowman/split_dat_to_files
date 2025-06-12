CREATE PROGRAM dm_dbimport_text_find:dba
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
 FREE RECORD dm_sql_reply
 RECORD dm_sql_reply(
   1 status = c1
   1 msg = vc
 )
 DECLARE scatstatus = vc WITH protect, noconstant(" ")
 DECLARE scatmsg = vc WITH protect, noconstant(" ")
 DECLARE squerystatus = vc WITH protect, noconstant(" ")
 DECLARE squerymsg = vc WITH protect, noconstant(" ")
 DECLARE scatrstatus = vc WITH protect, noconstant(" ")
 DECLARE scatrmsg = vc WITH protect, noconstant(" ")
 DECLARE stextstatus = vc WITH protect, noconstant(" ")
 DECLARE stextmsg = vc WITH protect, noconstant(" ")
 DECLARE sdetailstatus = vc WITH protect, noconstant(" ")
 DECLARE sdetailmsg = vc WITH protect, noconstant(" ")
 DECLARE sdtlqueryrstatus = vc WITH protect, noconstant(" ")
 DECLARE sdtlqueryrmsg = vc WITH protect, noconstant(" ")
 DECLARE sweightstatus = vc WITH protect, noconstant(" ")
 DECLARE sweightmsg = vc WITH protect, noconstant(" ")
 SET readme_data->status = "F"
 SET readme_data->message = "Initializing to Failure."
 EXECUTE dm_readme_include_sql "cer_install:dm_txtfnd_get_both.sql"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = dm_sql_reply->status
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_main
 ENDIF
 EXECUTE dm_readme_include_sql_chk "dm_txtfnd_get_both", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = dm_sql_reply->status
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_main
 ENDIF
 EXECUTE dm_readme_include_sql "cer_install:dm_txtfnd_get_org_reltns.sql"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = dm_sql_reply->status
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_main
 ENDIF
 EXECUTE dm_readme_include_sql_chk "dm_txtfnd_get_org_reltns", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = dm_sql_reply->status
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_main
 ENDIF
 EXECUTE dm_dbimport "cer_install:dm_text_find_cat.csv", "dm_load_text_find_cat", 1000
 SET squerystatus = readme_data->status
 SET squerymsg = readme_data->message
 EXECUTE dm_dbimport "cer_install:dm_text_find_query.csv", "dm_load_text_find_query", 1000
 SET scatstatus = readme_data->status
 SET scatmsg = readme_data->message
 EXECUTE dm_dbimport "cer_install:dm_text_find.csv", "dm_load_text_find", 1000
 SET stextstatus = readme_data->status
 SET stextmsg = readme_data->message
 EXECUTE dm_dbimport "cer_install:dm_text_find_cat_r.csv", "dm_load_text_find_cat_r", 1000
 SET scatrstatus = readme_data->status
 SET scatrmsg = readme_data->message
 EXECUTE dm_dbimport "cer_install:dm_text_find_detail.csv", "dm_load_text_find_detail", 1000
 SET sdetailstatus = readme_data->status
 SET sdetailmsg = readme_data->message
 EXECUTE dm_dbimport "cer_install:dm_text_find_dtl_query_r.csv", "dm_load_text_find_dtl_query_r",
 1000
 SET sdtlqueryrstatus = readme_data->status
 SET sdtlqueryrmsg = readme_data->message
 DELETE  FROM dm_text_find_query_weight d
  WHERE 1=1
  WITH nocounter
 ;end delete
 IF (error(sweightmsg,0) > 0)
  ROLLBACK
  SET sweightstatus = "F"
  SET sweightmsg = concat("Failed to delete DM_TEXT_FIND_QUERY_WEIGHT: ",sweightmsg)
 ELSE
  EXECUTE dm_dbimport "cer_install:dm_text_find_query_weight.csv", "dm_load_text_find_query_weight",
  1000
  SET sweightstatus = readme_data->status
  SET sweightmsg = readme_data->message
 ENDIF
 IF (stextstatus="S"
  AND squerystatus="S"
  AND sdetailstatus="S"
  AND scatstatus="S"
  AND scatrstatus="S"
  AND sdtlqueryrstatus="S"
  AND sweightstatus="S")
  SET readme_data->status = "S"
  SET readme_data->message = "All DM_TEXT_FIND* table data uploaded successfully"
 ELSEIF (scatstatus="F")
  SET readme_data->status = "F"
  SET readme_data->message = scatmsg
 ELSEIF (stextstatus="F")
  SET readme_data->status = "F"
  SET readme_data->message = stextmsg
 ELSEIF (scatrstatus="F")
  SET readme_data->status = "F"
  SET readme_data->message = scatrmsg
 ELSEIF (sdetailstatus="F")
  SET readme_data->status = "F"
  SET readme_data->message = sdetailmsg
 ELSEIF (squerystatus="F")
  SET readme_data->status = "F"
  SET readme_data->message = squerymsg
 ELSEIF (sdtlqueryrstatus="F")
  SET readme_data->status = "F"
  SET readme_data->status = sdtlqueryrmsg
 ELSEIF (sweightstatus="F")
  SET readme_data->status = "F"
  SET readme_data->status = sweightmsg
 ENDIF
#exit_main
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
