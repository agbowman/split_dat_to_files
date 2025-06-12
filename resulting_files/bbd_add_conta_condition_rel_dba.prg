CREATE PROGRAM bbd_add_conta_condition_rel:dba
 RECORD reply(
   1 container_condition_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET reply->container_condition_id = 0.0
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 SET new_contact_id = new_pathnet_seq
 SET reply->container_condition_id = new_contact_id
 INSERT  FROM container_condition_r c
  SET c.container_condition_id = new_pathnet_seq, c.container_type_cd = request->container_cd, c
   .condition_cd = request->condition_cd,
   c.active_ind = 1, c.active_status_cd = reqdata->active_status_cd, c.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   c.active_status_prsnl_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_dt_tm
    = cnvtdatetime(curdate,curtime3),
   c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = 0,
   c.cntnr_temperature_value = request->container_temperature, c.cntnr_temperature_degree_cd =
   request->container_temperature_degree_cd
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_conta_condition_rel"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd container condition r table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
