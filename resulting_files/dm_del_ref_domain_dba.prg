CREATE PROGRAM dm_del_ref_domain:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 DELETE  FROM dm_ref_domain_r a
  WHERE a.ref_domain_name=trim(request->ref_domain_name)
  WITH nocounter
 ;end delete
 DELETE  FROM dm_ref_domain b
  WHERE b.ref_domain_name=trim(request->ref_domain_name)
  WITH nocounter
 ;end delete
 SET reply->status_data.status = "S"
 COMMIT
END GO
