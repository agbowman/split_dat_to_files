CREATE PROGRAM cs_srv_get_interface:dba
 CALL echo(concat("CS_SRV_GET_INTERFACE - ",format(curdate,"MMM DD, YYYY;;D"),format(curtime3,
    " - HH:MM:SS;;S")))
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(request)
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE interface_cnt = i2 WITH protect, noconstant(0)
 SELECT
  IF ((request->load_all=1))
   WHERE it.active_ind=1
  ELSE
   WHERE (it.interface_file_id=request->interface_file_id)
    AND it.active_ind=1
  ENDIF
  INTO "nl"
  it.interface_file_id, it.order_phys_copy_ind
  FROM interface_file it
  DETAIL
   interface_cnt += 1, stat = alterlist(reply->interfacelist,interface_cnt), reply->interfacelist[
   interface_cnt].interface_file_id = it.interface_file_id,
   reply->interfacelist[interface_cnt].order_phys_copy_ind = it.order_phys_copy_ind
  WITH nocounter
 ;end select
 IF (interface_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
END GO
