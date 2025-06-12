CREATE PROGRAM column_grp_qry_tst:dba
 FREE SET request
 RECORD request(
   1 msg_column_grp_knt = i4
   1 msg_column_grp_list[*]
     2 msg_column_grp_id = f8
   1 query_all_public_ind = i2
   1 msg_category_type_cd = f8
 )
 FREE SET reply
 RECORD reply(
   1 msg_column_grp_knt = i4
   1 msg_column_grp_list[*]
     2 msg_column_grp_id = f8
     2 name = vc
     2 desc = vc
     2 public_ind = i2
     2 owner_id = f8
     2 create_dt_tm = dq8
     2 msg_category_type_cd = f8
     2 column_cd_knt = i4
     2 column_cd_list[*]
       3 column_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET request->msg_column_grp_knt = 1
 SET stat = alterlist(request->msg_column_grp_list,1)
 SET request->msg_column_grp_list[1].msg_column_grp_id = 12312
 SET request->msg_category_type_cd = 23423.0
 EXECUTE column_grp_qry
 CALL echorecord(reply)
END GO
