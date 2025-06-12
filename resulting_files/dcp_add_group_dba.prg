CREATE PROGRAM dcp_add_group:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE count1 = i2 WITH noconstant(0)
 DECLARE grp_cd = f8 WITH noconstant(0.0)
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE comp_cnt = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  lg.log_grouping_cd
  FROM logical_grouping lg
  WHERE (lg.log_grouping_cd=request->log_grouping_cd)
   AND (request->log_grouping_cd > 0)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("No group existing!")
  SELECT INTO "nl:"
   j = seq(reference_seq,nextval)"######################;rp0"
   FROM dual
   DETAIL
    grp_cd = cnvtint(j)
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
  INSERT  FROM logical_grouping l
   SET l.log_grouping_cd = grp_cd, l.logical_group_desc = request->logical_group_desc, l.comp_type_cd
     = request->comp_type_cd,
    l.log_grouping_type_cd = request->log_grouping_type_cd, l.updt_applctx = reqinfo->updt_applctx, l
    .updt_id = reqinfo->updt_id,
    l.updt_cnt = 0, l.updt_task = reqinfo->updt_task, l.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("Group exists!")
  UPDATE  FROM logical_grouping lg
   SET lg.updt_id = reqinfo->updt_id, lg.updt_cnt = 0, lg.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE (lg.log_grouping_cd=request->log_grouping_cd)
   WITH nocounter
  ;end update
 ENDIF
 SET comp_cnt = cnvtint(size(request->qual,5))
 IF ((request->log_grouping_cd=0))
  CALL echo("Adding for new group...")
  INSERT  FROM log_group_entry lg,
    (dummyt d  WITH seq = value(comp_cnt))
   SET lg.log_grouping_comp_cd = cnvtint(seq(reference_seq,nextval)), lg.log_grouping_cd = grp_cd, lg
    .item_cd = request->qual[d.seq].item_cd,
    lg.event_set_name = request->qual[d.seq].event_set_name, lg.exception_entity_name = request->
    qual[d.seq].exception_entity_name, lg.exception_type_cd = request->qual[d.seq].exception_type_cd,
    lg.updt_applctx = reqinfo->updt_applctx, lg.updt_id = reqinfo->updt_id, lg.updt_cnt = 0,
    lg.updt_task = reqinfo->updt_task, lg.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d)
    JOIN (lg)
   WITH nocounter
  ;end insert
 ELSE
  CALL echo("Adding exceptions...")
  INSERT  FROM log_group_entry lg,
    (dummyt d  WITH seq = value(comp_cnt))
   SET lg.log_grouping_comp_cd = cnvtint(seq(reference_seq,nextval)), lg.log_grouping_cd = request->
    log_grouping_cd, lg.item_cd = request->qual[d.seq].item_cd,
    lg.event_set_name = request->qual[d.seq].event_set_name, lg.exception_entity_name = request->
    qual[d.seq].exception_entity_name, lg.exception_type_cd = request->qual[d.seq].exception_type_cd,
    lg.updt_applctx = reqinfo->updt_applctx, lg.updt_id = reqinfo->updt_id, lg.updt_cnt = 0,
    lg.updt_task = reqinfo->updt_task, lg.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d)
    JOIN (lg
    WHERE (lg.log_grouping_cd=request->log_grouping_cd))
  ;end insert
 ENDIF
 IF (curqual != comp_cnt)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "T"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
