CREATE PROGRAM dcp_upd_device_at_location:dba
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE devicecnt = i2 WITH noconstant(0)
 DECLARE dcp_device_location_id = f8
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE debug = i1 WITH noconstant(false)
 DECLARE newseq = f8 WITH noconstant(0.0)
 DECLARE ipaddresssize = i4 WITH noconstant(0)
 DECLARE dnsnamesize = i4 WITH noconstant(0)
 IF ((reqinfo->updt_applctx=0))
  SET debug = true
 ENDIF
 SET ipaddresssize = size(trim(request->ip_address,3),1)
 SET dnsnamesize = size(trim(request->dns_name,3),1)
 IF (ipaddresssize=0
  AND dnsnamesize=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_device_location"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "Validate"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "IpAddress or DnsName must be populated"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (debug)
  CALL echo("Return relationships")
 ENDIF
 SELECT INTO "nl:"
  d.dcp_device_location_id
  FROM dcp_device_location d
  WHERE (d.location_cd=request->location_cd)
   AND d.active_ind != 0
  ORDER BY d.dcp_device_location_id
  DETAIL
   devicecnt = (devicecnt+ 1), dcp_device_location_id = d.dcp_device_location_id
  WITH nocounter
 ;end select
 IF (devicecnt > 1)
  SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_device_location"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "Validate"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Multiple Devices are related to this location"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (devicecnt > 0)
  IF (debug)
   CALL echo("Inactivate Relationship")
  ENDIF
  UPDATE  FROM dcp_device_location d
   SET d.active_ind = 0, d.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_cnt = (d.updt_cnt+ 1),
    d.updt_applctx = reqinfo->updt_applctx
   WHERE d.dcp_device_location_id=dcp_device_location_id
   WITH counter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_device_location"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to update into table"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (debug)
  CALL echo("Insert new relationship")
 ENDIF
 INSERT  FROM dcp_device_location d
  SET d.dcp_device_location_id = seq(carenet_seq,nextval), d.location_cd = request->location_cd, d
   .ip_address = request->ip_address,
   d.port_number = request->port_number, d.dns_name = request->dns_name, d.username_txt = request->
   username_txt,
   d.password_txt = request->password_txt, d.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), d
   .active_ind = 1,
   d.updt_id = reqinfo->updt_id, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_task = reqinfo
   ->updt_task,
   d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_device_location"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SUBROUTINE nextid(seqname)
   SET newseq = 0
   SELECT INTO "nl:"
    num = seq(parser(seqname),nextval)"##################;rp0"
    FROM dual
    DETAIL
     newseq = cnvtreal(num)
    WITH format, counter
   ;end select
   IF (debug)
    CALL echo(build("---Func NextId : SeqName = ",seqname," : NewSeq = ",newseq))
   ENDIF
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "Sequence"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "insert"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed generating new seq number"
    SET failed = "T"
    RETURN
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
 IF (debug)
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
END GO
