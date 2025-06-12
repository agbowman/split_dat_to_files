CREATE PROGRAM dcp_get_device_at_location:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 dcp_device_location_id = f8
     2 location_cd = f8
     2 port_number = f8
     2 ip_address = vc
     2 dns_name = vc
     2 username_txt = vc
     2 password_txt = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE devicecnt = i2 WITH noconstant(0)
 DECLARE err_status = i4 WITH private, noconstant(0)
 DECLARE err_msg = vc WITH private, noconstant(fillstring(132,""))
 SELECT INTO "nl:"
  FROM dcp_device_location d
  WHERE (d.location_cd=request->location_cd)
   AND d.active_ind=1
  DETAIL
   devicecnt = (devicecnt+ 1), stat = alterlist(reply->qual,(devicecnt+ 1)), reply->qual[devicecnt].
   dcp_device_location_id = d.dcp_device_location_id,
   reply->qual[devicecnt].location_cd = d.location_cd, reply->qual[devicecnt].port_number = d
   .port_number, reply->qual[devicecnt].ip_address = d.ip_address,
   reply->qual[devicecnt].dns_name = d.dns_name, reply->qual[devicecnt].username_txt = d.username_txt,
   reply->qual[devicecnt].password_txt = d.password_txt,
   reply->qual[devicecnt].beg_effective_dt_tm = d.beg_effective_dt_tm, reply->qual[devicecnt].
   end_effective_dt_tm = d.end_effective_dt_tm, reply->qual[devicecnt].active_ind = d.active_ind
  FOOT REPORT
   IF (devicecnt > 0)
    stat = alterlist(reply->qual[devicecnt],devicecnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (devicecnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
