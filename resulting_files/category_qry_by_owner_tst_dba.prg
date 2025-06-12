CREATE PROGRAM category_qry_by_owner_tst:dba
 FREE SET request
 RECORD request(
   1 owner_id = f8
   1 start_create_dt_tm = dq8
   1 end_create_dt_tm = dq8
 )
 FREE SET reply
 RECORD reply(
   1 msg_category_knt = i4
   1 msg_category_list[*]
     2 msg_category_id = f8
     2 name = vc
     2 create_dt_tm = dq8
     2 msg_category_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET request->owner_id = 12312.0
 SET request->start_create_dt_tm = cnvtdatetime("01-JAN-2006 10:00:00")
 SET request->end_create_dt_tm = cnvtdatetime("01-MAR-2006 10:00:00")
 EXECUTE category_qry_by_owner
 CALL echorecord(reply)
END GO
