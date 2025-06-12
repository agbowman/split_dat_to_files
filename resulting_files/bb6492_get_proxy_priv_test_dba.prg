CREATE PROGRAM bb6492_get_proxy_priv_test:dba
 FREE SET request
 FREE SET reply
 SET trace = recpersist
 RECORD request(
   1 proxy_type_flag = i2
 )
 SET reqinfo->updt_id =  $1
 SET request->proxy_type_flag =  $2
 EXECUTE aps_get_proxy_privilege
 CALL echorecord(request)
 CALL echorecord(reply)
END GO
