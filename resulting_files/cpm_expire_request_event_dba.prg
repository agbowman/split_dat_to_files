CREATE PROGRAM cpm_expire_request_event:dba
 RECORD reply(
   1 status_data
     2 status = c1
 )
 EXECUTE cpm_add_request_event  WITH replace("REQUEST_EVENT_R","REQUEST")
END GO
