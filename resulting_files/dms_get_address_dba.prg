CREATE PROGRAM dms_get_address:dba
 CALL echo("<==================== Entering DMS_GET_ADDRESS Script ====================>")
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 address[*]
      2 address_id = f8
      2 parent_entity_name = vc
      2 parent_entity_id = f8
      2 street_addr = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 DECLARE numaddress = i4 WITH constant(size(request->address,5))
 SET stat = alterlist(reply->address,numaddress)
 SELECT INTO "nl:"
  a.*
  FROM (dummyt d  WITH seq = value(numaddress)),
   address a
  PLAN (d)
   JOIN (a
   WHERE (a.address_id=request->address[d.seq].address_id)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq
  DETAIL
   reply->address[d.seq].address_id = a.address_id, reply->address[d.seq].parent_entity_name = a
   .parent_entity_name, reply->address[d.seq].parent_entity_id = a.parent_entity_id,
   reply->address[d.seq].street_addr = a.street_addr
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_GET_ADDRESS Script ====================>")
END GO
