CREATE PROGRAM bbd_chg_conta_selected_org:dba
 RECORD reply(
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
 SET y = 0
 SET new_container_org_id = 0.0
 SET reply->status_data.status = "F"
 SET failed = "F"
 FOR (y = 1 TO request->organization_count)
   IF ((request->qual[y].add_row=1))
    DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
    SET new_pathnet_seq = 0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    SET new_container_org_id = new_pathnet_seq
    INSERT  FROM container_org_r p
     SET p.container_org_id = new_container_org_id, p.container_type_cd = request->qual[y].
      container_type_cd, p.organization_id = request->qual[y].organization_id,
      p.active_ind = 1, p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      p.active_status_prsnl_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p
      .updt_id = reqinfo->updt_id,
      p.updt_cnt = 0, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx,
      p.inventory_area_cd = request->qual[y].inventory_area_cd
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].targetobjectname = "container_org_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "organization insert"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
   ELSE
    SELECT INTO "nl:"
     p.*
     FROM container_org_r p
     WHERE (p.container_org_id=request->qual[y].container_org_id)
      AND (p.updt_cnt=request->qual[y].updt_cnt)
     WITH counter, forupdate(p)
    ;end select
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].operationname = "lock"
     SET reply->status_data.subeventstatus[1].targetobjectname = "container_org_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "organization lock"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
    UPDATE  FROM container_org_r p
     SET p.active_status_cd = reqdata->inactive_status_cd, p.active_ind = 0, p.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      p.active_status_prsnl_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p
      .updt_id = reqinfo->updt_id,
      p.updt_cnt = (request->qual[y].updt_cnt+ 1), p.updt_task = reqinfo->updt_task, p.updt_applctx
       = reqinfo->updt_applctx,
      p.inventory_area_cd = request->qual[y].inventory_area_cd
     WHERE (p.container_org_id=request->qual[y].container_org_id)
      AND (p.updt_cnt=request->qual[y].updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].targetobjectname = "container_org_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "update organization"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
