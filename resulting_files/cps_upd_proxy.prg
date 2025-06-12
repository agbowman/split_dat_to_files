CREATE PROGRAM cps_upd_proxy
 RECORD internal(
   1 num[*]
     2 proxy_type_cd = f8
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET script_version = "000 06/01/05 MH2659"
END GO
