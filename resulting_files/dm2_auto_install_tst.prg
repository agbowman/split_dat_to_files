CREATE PROGRAM dm2_auto_install_tst
 FREE RECORD request
 RECORD request(
   1 plan_id = f8
   1 install_mode = vc
 )
 RECORD reply(
   1 execution_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET request->plan_id =  $1
 SET request->install_mode =  $2
 EXECUTE dm2_auto_install  WITH replace("REPLY","REPLY")
 CALL echorecord(reply)
END GO
