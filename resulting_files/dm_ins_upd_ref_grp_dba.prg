CREATE PROGRAM dm_ins_upd_ref_grp:dba
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
 SELECT INTO "nl:"
  a.group_name
  FROM dm_ref_domain_group a
  WHERE (request->group_name=a.group_name)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  UPDATE  FROM dm_ref_domain_group dm
   SET dm.description = trim(request->description)
   WHERE trim(request->group_name)=dm.group_name
   WITH nocounter
  ;end update
 ELSE
  INSERT  FROM dm_ref_domain_group dm
   SET dm.group_name = trim(request->group_name), dm.description = trim(request->description)
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
