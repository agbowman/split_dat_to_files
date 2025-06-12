CREATE PROGRAM config_asnmnt_qry_tst:dba
 FREE SET request
 RECORD request(
   1 msg_config_asnmnt_knt = i4
   1 msg_config_asnmnt_list[*]
     2 msg_config_pub_asnmnt_id = f8
   1 prsnl_id = f8
   1 position_cd = f8
   1 application_number = i4
   1 pool_id = f8
 )
 FREE SET reply
 RECORD reply(
   1 msg_config_asnmnt_knt = i4
   1 msg_config_asnmnt_list[*]
     2 msg_config_pub_asnmnt_id = f8
     2 prsnl_id = f8
     2 position_cd = f8
     2 application_number = i4
     2 pool_id = f8
     2 msg_config_id = f8
     2 msg_config_public_ind = i2
     2 msg_config_name = vc
     2 msg_config_desc = vc
     2 search_rng_value = f8
     2 search_rng_units = i4
     2 user_modify_ind = i2
     2 msg_category_knt = i4
     2 msg_category_list[*]
       3 msg_category_id = f8
       3 msg_category_type_cd = f8
       3 msg_category_public_ind = i2
       3 msg_category_name = vc
       3 msg_category_desc = vc
       3 msg_notify_category_cd = f8
       3 msg_notify_item_cd = f8
       3 prsnl_id = f8
       3 position_cd = f8
       3 application_number = i4
       3 pool_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET request->application_number = 961000
 SET request->prsnl_id = 18663784
 EXECUTE config_asnmnt_qry
 CALL echorecord(reply)
END GO
