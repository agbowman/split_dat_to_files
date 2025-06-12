CREATE PROGRAM bed_ens_vvl_reset_vv:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL echo(" This script has been deprecated as a resolution as part of CAPA 501 ")
 SET reply->error_msg = "This script has been deprecated as a resolution as part of CAPA 501"
 SET reply->status_data.status = "F"
END GO
