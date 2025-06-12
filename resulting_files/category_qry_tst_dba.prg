CREATE PROGRAM category_qry_tst:dba
 FREE SET request
 RECORD request(
   1 msg_category_knt = i4
   1 msg_category_list[*]
     2 msg_category_id = f8
   1 query_all_public_ind = i2
   1 msg_category_type_cd = f8
   1 load_column_dtl = i2
   1 load_event_set_dtl = i2
   1 load_encntr_dtl = i2
   1 load_item_grp_dtl = i2
   1 load_item_type_dtl = i2
 )
 FREE SET reply
 RECORD reply(
   1 msg_category_knt = i4
   1 msg_category_list[*]
     2 msg_category_id = f8
     2 msg_category_public_ind = i2
     2 msg_category_name = vc
     2 msg_category_desc = vc
     2 msg_category_prsnl_id = f8
     2 msg_category_position_cd = f8
     2 msg_category_prsnl_group_id = f8
     2 msg_category_app_num = i4
     2 msg_notify_category_cd = f8
     2 msg_notify_item_cd = f8
     2 msg_category_type_cd = f8
     2 msg_column_grp_id = f8
     2 msg_column_grp_public_ind = i2
     2 msg_column_grp_name = vc
     2 msg_column_grp_desc = vc
     2 msg_column_grp_prsnl_id = f8
     2 msg_column_grp_position_cd = f8
     2 msg_column_grp_prsnl_group_id = f8
     2 msg_column_grp_app_num = i4
     2 msg_column_grp_dtl_knt = i4
     2 msg_column_grp_dtl_list[*]
       3 msg_column_type_cd = f8
     2 msg_item_grp_knt = i4
     2 msg_item_grp_list[*]
       3 msg_item_grp_id = f8
       3 msg_item_grp_public_ind = i2
       3 msg_item_grp_name = vc
       3 msg_item_grp_desc = vc
       3 msg_item_grp_prsnl_id = f8
       3 msg_item_grp_position_cd = f8
       3 msg_item_grp_prsnl_group_id = f8
       3 msg_item_grp_app_num = i4
       3 msg_notify_category_cd = f8
       3 msg_notify_item_cd = f8
       3 msg_item_grp_type_cd = f8
       3 msg_item_grp_dtl_knt = i4
       3 msg_item_grp_dtl_list[*]
         4 msg_item_type_cd = f8
     2 msg_event_set_grp_id = f8
     2 msg_event_filter_inc_ind = i2
     2 msg_event_set_grp_public_ind = i2
     2 msg_event_set_grp_name = vc
     2 msg_event_set_grp_desc = vc
     2 msg_event_set_grp_prsnl_id = f8
     2 msg_event_set_grp_position_cd = f8
     2 msg_event_set_grp_prsnl_group_id = f8
     2 msg_event_set_grp_app_num = i4
     2 msg_event_set_grp_dtl_knt = i4
     2 msg_event_set_grp_dtl_list[*]
       3 event_set_name = vc
     2 msg_encntr_grp_id = f8
     2 msg_encntr_grp_public_ind = i2
     2 msg_encntr_grp_name = vc
     2 msg_encntr_grp_desc = vc
     2 msg_encntr_grp_prsnl_id = f8
     2 msg_encntr_grp_position_cd = f8
     2 msg_encntr_grp_prsnl_group_id = f8
     2 msg_encntr_grp_app_num = i4
     2 msg_encntr_grp_dtl_knt = i4
     2 msg_encntr_grp_dtl_list[*]
       3 encntr_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET request->msg_category_type_cd = 13265418.00
 SET request->query_all_public_ind = 1
 SET request->load_event_set_dtl = 1
 SET request->load_encntr_dtl = 1
 SET request->load_item_grp_dtl = 1
 SET request->load_item_type_dtl = 1
 EXECUTE category_qry
 CALL echorecord(reply)
END GO
