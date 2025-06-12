CREATE PROGRAM add_pool_org_rules_test:dba
 FREE SET request
 RECORD request(
   1 prsnl_group_id = f8
   1 outside_add_ind = i2
   1 outside_forward_ind = i2
 )
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET request->prsnl_group_id = 2664164
 SET request->outside_add_ind = 0
 SET request->outside_forward_ind = 1
 EXECUTE add_pool_org_rules
 CALL echorecord(reply)
END GO
