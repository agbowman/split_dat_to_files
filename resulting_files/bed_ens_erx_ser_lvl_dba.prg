CREATE PROGRAM bed_ens_erx_ser_lvl:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc WITH protect, noconstant("N")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 IF ( NOT (validate(request->ss_version_nbr)))
  DECLARE ss_version_nbr = vc WITH protect, noconstant("44")
 ELSE
  DECLARE ss_version_nbr = vc WITH protect, noconstant(request->ss_version_nbr)
 ENDIF
 DECLARE req_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET req_cnt = size(request->service_levels,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 DECLARE cs320spi = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"SPI"))
 DECLARE cs48active = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 SET ierrcode = 0
 DELETE  FROM eprescribe_detail e,
   (dummyt d  WITH seq = value(req_cnt))
  SET e.seq = 1
  PLAN (d
   WHERE (request->service_levels[d.seq].action_flag=3))
   JOIN (e
   WHERE (e.prsnl_reltn_id=request->service_levels[d.seq].prsnl_reltn_id))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Delete eprescribe_detail rows."
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 IF (ss_version_nbr="60")
  UPDATE  FROM eprescribe_detail e,
    (dummyt d  WITH seq = value(req_cnt))
   SET e.prop_service_level_nbr = request->service_levels[d.seq].service_level_mask, e
    .beg_effective_dt_tm = cnvtdatetime(request->service_levels[d.seq].beg_effective_dt_tm), e
    .end_effective_dt_tm = cnvtdatetime(request->service_levels[d.seq].end_effective_dt_tm),
    e.message_ident = request->service_levels[d.seq].message_id, e.status_cd = 0.0, e.error_cd = 0.0,
    e.error_desc = " ", e.submit_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = reqinfo->updt_id,
    e.updt_cnt = (e.updt_cnt+ 1), e.updt_applctx = reqinfo->updt_applctx, e.updt_task = reqinfo->
    updt_task,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (request->service_levels[d.seq].action_flag=2))
    JOIN (e
    WHERE (e.prsnl_reltn_id=request->service_levels[d.seq].prsnl_reltn_id))
   WITH nocounter
  ;end update
 ELSE
  UPDATE  FROM eprescribe_detail e,
    (dummyt d  WITH seq = value(req_cnt))
   SET e.service_level_nbr = request->service_levels[d.seq].service_level_mask, e.beg_effective_dt_tm
     = cnvtdatetime(request->service_levels[d.seq].beg_effective_dt_tm), e.end_effective_dt_tm =
    cnvtdatetime(request->service_levels[d.seq].end_effective_dt_tm),
    e.message_ident = request->service_levels[d.seq].message_id, e.status_cd = 0.0, e.error_cd = 0.0,
    e.error_desc = " ", e.submit_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = reqinfo->updt_id,
    e.updt_cnt = (e.updt_cnt+ 1), e.updt_applctx = reqinfo->updt_applctx, e.updt_task = reqinfo->
    updt_task,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (request->service_levels[d.seq].action_flag=2))
    JOIN (e
    WHERE (e.prsnl_reltn_id=request->service_levels[d.seq].prsnl_reltn_id))
   WITH nocounter
  ;end update
 ENDIF
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Update eprescribe_detail rows."
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 IF (ss_version_nbr="60")
  INSERT  FROM eprescribe_detail e,
    (dummyt d  WITH seq = value(req_cnt))
   SET e.eprescribe_detail_id = seq(prsnl_seq,nextval), e.prsnl_reltn_id = request->service_levels[d
    .seq].prsnl_reltn_id, e.prop_service_level_nbr = request->service_levels[d.seq].
    service_level_mask,
    e.service_level_nbr = 0, e.beg_effective_dt_tm = cnvtdatetime(request->service_levels[d.seq].
     beg_effective_dt_tm), e.end_effective_dt_tm = cnvtdatetime(request->service_levels[d.seq].
     end_effective_dt_tm),
    e.message_ident = request->service_levels[d.seq].message_id, e.submit_dt_tm = cnvtdatetime(
     curdate,curtime3), e.status_cd = 0.0,
    e.error_cd = 0.0, e.error_desc = " ", e.updt_id = reqinfo->updt_id,
    e.updt_cnt = 0, e.updt_applctx = reqinfo->updt_applctx, e.updt_task = reqinfo->updt_task,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (request->service_levels[d.seq].action_flag=1))
    JOIN (e)
   WITH nocounter
  ;end insert
 ELSE
  INSERT  FROM eprescribe_detail e,
    (dummyt d  WITH seq = value(req_cnt))
   SET e.eprescribe_detail_id = seq(prsnl_seq,nextval), e.prsnl_reltn_id = request->service_levels[d
    .seq].prsnl_reltn_id, e.service_level_nbr = request->service_levels[d.seq].service_level_mask,
    e.beg_effective_dt_tm = cnvtdatetime(request->service_levels[d.seq].beg_effective_dt_tm), e
    .end_effective_dt_tm = cnvtdatetime(request->service_levels[d.seq].end_effective_dt_tm), e
    .message_ident = request->service_levels[d.seq].message_id,
    e.submit_dt_tm = cnvtdatetime(curdate,curtime3), e.status_cd = 0.0, e.error_cd = 0.0,
    e.error_desc = " ", e.updt_id = reqinfo->updt_id, e.updt_cnt = 0,
    e.updt_applctx = reqinfo->updt_applctx, e.updt_task = reqinfo->updt_task, e.updt_dt_tm =
    cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (request->service_levels[d.seq].action_flag=1))
    JOIN (e)
   WITH nocounter
  ;end insert
 ENDIF
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Insert eprescribe_detail rows."
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM (dummyt d  WITH seq = value(req_cnt)),
   prsnl_reltn pr
  SET pr.end_effective_dt_tm = cnvtdatetime(request->service_levels[d.seq].end_effective_dt_tm), pr
   .updt_id = reqinfo->updt_id, pr.updt_cnt = (pr.updt_cnt+ 1),
   pr.updt_applctx = reqinfo->updt_applctx, pr.updt_task = reqinfo->updt_task, pr.updt_dt_tm =
   cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE (request->service_levels[d.seq].action_flag IN (1, 2)))
   JOIN (pr
   WHERE (pr.prsnl_reltn_id=request->service_levels[d.seq].prsnl_reltn_id)
    AND pr.display_seq != 0
    AND pr.active_ind=1)
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Update prsnl_reltn End Date."
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 FREE RECORD tempaliasupdt
 RECORD tempaliasupdt(
   1 aliases[*]
     2 prsnl_alias_id = f8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
 )
 DECLARE alias_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   prsnl_reltn_child pr,
   prsnl_alias pa
  PLAN (d
   WHERE (request->service_levels[d.seq].action_flag IN (1, 2)))
   JOIN (pr
   WHERE (pr.prsnl_reltn_id=request->service_levels[d.seq].prsnl_reltn_id)
    AND pr.parent_entity_name="PRSNL_ALIAS")
   JOIN (pa
   WHERE pa.prsnl_alias_id=pr.parent_entity_id
    AND pa.prsnl_alias_type_cd=cs320spi
    AND pa.active_ind=1
    AND pa.active_status_cd=cs48active)
  ORDER BY pa.prsnl_alias_id
  HEAD pa.prsnl_alias_id
   alias_cnt = (alias_cnt+ 1), stat = alterlist(tempaliasupdt->aliases,alias_cnt), tempaliasupdt->
   aliases[alias_cnt].prsnl_alias_id = pa.prsnl_alias_id,
   tempaliasupdt->aliases[alias_cnt].end_effective_dt_tm = request->service_levels[d.seq].
   end_effective_dt_tm
  WITH nocounter
 ;end select
 FOR (i = 1 TO alias_cnt)
   IF (cnvtdatetime(tempaliasupdt->aliases[i].end_effective_dt_tm) > cnvtdatetime(curdate,curtime3))
    SET tempaliasupdt->aliases[i].active_ind = 1
   ELSE
    SET tempaliasupdt->aliases[i].active_ind = 0
   ENDIF
 ENDFOR
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get Alias to update SPI error."
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 IF (alias_cnt > 0)
  UPDATE  FROM (dummyt d  WITH seq = value(alias_cnt)),
    prsnl_alias pa
   SET pa.end_effective_dt_tm = cnvtdatetime(tempaliasupdt->aliases[d.seq].end_effective_dt_tm), pa
    .updt_id = reqinfo->updt_id, pa.updt_cnt = (pa.updt_cnt+ 1),
    pa.updt_applctx = reqinfo->updt_applctx, pa.updt_task = reqinfo->updt_task, pa.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    pa.active_ind = tempaliasupdt->aliases[d.seq].active_ind, pa.active_status_cd =
    IF ((tempaliasupdt->aliases[d.seq].active_ind=1)) reqdata->active_status_cd
    ELSE reqdata->inactive_status_cd
    ENDIF
   PLAN (d
    WHERE (request->service_levels[d.seq].action_flag IN (1, 2)))
    JOIN (pa
    WHERE (pa.prsnl_alias_id=tempaliasupdt->aliases[d.seq].prsnl_alias_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Update SPI Alias End Date."
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (i = 1 TO req_cnt)
   IF (cnvtdatetime(request->service_levels[i].end_effective_dt_tm) > cnvtdatetime(curdate,curtime3))
    UPDATE  FROM prsnl_reltn_child prc
     SET prc.end_effective_dt_tm = cnvtdatetime(request->service_levels[i].end_effective_dt_tm), prc
      .updt_id = reqinfo->updt_id, prc.updt_cnt = (prc.updt_cnt+ 1),
      prc.updt_applctx = reqinfo->updt_applctx, prc.updt_task = reqinfo->updt_task, prc.updt_dt_tm =
      cnvtdatetime(curdate,curtime3)
     PLAN (prc
      WHERE (request->service_levels[i].action_flag IN (1, 2))
       AND (prc.prsnl_reltn_id=request->service_levels[i].prsnl_reltn_id)
       AND prc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname =
     "Update prsnl_reltn_child  End Date."
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ELSE
    UPDATE  FROM prsnl_reltn_child prc
     SET prc.end_effective_dt_tm = cnvtdatetime(request->service_levels[i].end_effective_dt_tm), prc
      .display_seq = 0, prc.updt_id = reqinfo->updt_id,
      prc.updt_cnt = (prc.updt_cnt+ 1), prc.updt_applctx = reqinfo->updt_applctx, prc.updt_task =
      reqinfo->updt_task,
      prc.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (prc
      WHERE (request->service_levels[i].action_flag IN (1, 2))
       AND (prc.prsnl_reltn_id=request->service_levels[i].prsnl_reltn_id)
       AND prc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname =
     "Update prsnl_reltn_child  End Date."
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
