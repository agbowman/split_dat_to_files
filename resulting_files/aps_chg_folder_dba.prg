CREATE PROGRAM aps_chg_folder:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET long_text_id = 0.0
 SET folder_updt_cnt = 0
 SET updt_cnt_err = 0
 SET comment = ""
 SET del_long_text_id = 0.0
 SELECT INTO "nl:"
  af.comment_id
  FROM ap_folder af,
   long_text lt
  PLAN (af
   WHERE (af.folder_id=request->folder_id))
   JOIN (lt
   WHERE lt.long_text_id=af.comment_id)
  DETAIL
   folder_updt_cnt = af.updt_cnt, long_text_id = af.comment_id, comment = lt.long_text
  WITH nocounter
 ;end select
 IF (curqual != 1)
  GO TO af_sel_failed
 ENDIF
 IF ((request->updt_cnt != folder_updt_cnt))
  GO TO af_cnt_failed
 ENDIF
 SELECT INTO "nl:"
  FROM ap_folder af
  PLAN (af
   WHERE (af.folder_id=request->folder_id))
  WITH nocounter, forupdate(af)
 ;end select
 IF (curqual != 1)
  GO TO af_sel_failed
 ENDIF
 IF ((request->chg_proxy_cnt > 0))
  SELECT INTO "nl:"
   afp.parent_entity_id
   FROM ap_folder_proxy afp,
    (dummyt d  WITH seq = value(request->chg_proxy_cnt))
   PLAN (d)
    JOIN (afp
    WHERE (afp.folder_id=request->folder_id)
     AND (afp.parent_entity_id=request->chg_proxy_qual[d.seq].parent_entity_id)
     AND (afp.parent_entity_name=request->chg_proxy_qual[d.seq].parent_entity_name))
   DETAIL
    IF ((request->chg_proxy_qual[d.seq].updt_cnt != afp.updt_cnt))
     updt_cnt_err = 1
    ENDIF
   WITH nocounter, forupdate(afp)
  ;end select
  IF (updt_cnt_err != 0)
   GO TO afp_cnt_failed
  ENDIF
 ENDIF
 IF ((request->comment="")
  AND long_text_id != 0.0)
  SET del_long_text_id = long_text_id
  SET long_text_id = 0.0
 ELSEIF ((request->comment != "")
  AND long_text_id=0.0)
  SELECT INTO "nl:"
   seq_nbr = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    long_text_id = seq_nbr
   WITH format, counter
  ;end select
  IF (curqual=0)
   GO TO lt_seq_failed
  ENDIF
  INSERT  FROM long_text lt
   SET lt.long_text_id = long_text_id, lt.long_text = request->comment, lt.parent_entity_name =
    "AP_FOLDER",
    lt.parent_entity_id = request->folder_id, lt.active_ind = 1, lt.active_status_cd = reqdata->
    active_status_cd,
    lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
    updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual != 1)
   GO TO lt_ins_failed
  ENDIF
 ELSEIF ((request->comment != comment)
  AND long_text_id != 0.0)
  UPDATE  FROM long_text lt
   SET lt.long_text = request->comment, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id =
    reqinfo->updt_id,
    lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = (lt
    .updt_cnt+ 1)
   WHERE lt.long_text_id=long_text_id
   WITH nocounter
  ;end update
  IF (curqual != 1)
   GO TO lt_upd_failed
  ENDIF
 ENDIF
 IF ((request->add_proxy_cnt > 0))
  INSERT  FROM ap_folder_proxy afp,
    (dummyt d  WITH seq = value(request->add_proxy_cnt))
   SET afp.folder_id = request->folder_id, afp.parent_entity_id = request->add_proxy_qual[d.seq].
    parent_entity_id, afp.parent_entity_name = request->add_proxy_qual[d.seq].parent_entity_name,
    afp.permission_bitmap = request->add_proxy_qual[d.seq].permission_bitmap, afp.contact_ind =
    request->add_proxy_qual[d.seq].folder_contact_ind, afp.updt_dt_tm = cnvtdatetime(curdate,curtime3
     ),
    afp.updt_id = reqinfo->updt_id, afp.updt_task = reqinfo->updt_task, afp.updt_applctx = reqinfo->
    updt_applctx,
    afp.updt_cnt = 0
   PLAN (d)
    JOIN (afp
    WHERE (afp.folder_id=request->folder_id)
     AND (afp.parent_entity_id=request->add_proxy_qual[d.seq].parent_entity_id)
     AND (afp.parent_entity_name=request->add_proxy_qual[d.seq].parent_entity_name))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF ((curqual != request->add_proxy_cnt))
   GO TO afp_ins_failed
  ENDIF
 ENDIF
 IF ((request->chg_proxy_cnt > 0))
  UPDATE  FROM ap_folder_proxy afp,
    (dummyt d  WITH seq = value(request->chg_proxy_cnt))
   SET afp.permission_bitmap = request->chg_proxy_qual[d.seq].permission_bitmap, afp.contact_ind =
    request->chg_proxy_qual[d.seq].folder_contact_ind, afp.updt_dt_tm = cnvtdatetime(curdate,curtime3
     ),
    afp.updt_id = reqinfo->updt_id, afp.updt_task = reqinfo->updt_task, afp.updt_applctx = reqinfo->
    updt_applctx,
    afp.updt_cnt = (afp.updt_cnt+ 1)
   PLAN (d)
    JOIN (afp
    WHERE (afp.folder_id=request->folder_id)
     AND (afp.parent_entity_id=request->chg_proxy_qual[d.seq].parent_entity_id)
     AND (afp.parent_entity_name=request->chg_proxy_qual[d.seq].parent_entity_name))
   WITH nocounter
  ;end update
  IF ((curqual != request->chg_proxy_cnt))
   GO TO afp_chg_failed
  ENDIF
 ENDIF
 IF ((request->del_proxy_cnt > 0))
  DELETE  FROM ap_folder_proxy afp,
    (dummyt d  WITH seq = value(request->del_proxy_cnt))
   SET afp.parent_entity_id = request->del_proxy_qual[d.seq].parent_entity_id
   PLAN (d)
    JOIN (afp
    WHERE (afp.folder_id=request->folder_id)
     AND (afp.parent_entity_id=request->del_proxy_qual[d.seq].parent_entity_id)
     AND (afp.parent_entity_name=request->del_proxy_qual[d.seq].parent_entity_name))
   WITH nocounter
  ;end delete
  IF ((curqual != request->del_proxy_cnt))
   GO TO afp_del_failed
  ENDIF
 ENDIF
 UPDATE  FROM ap_folder af
  SET af.folder_name = request->folder_name, af.folder_name_key = cnvtupper(request->folder_name), af
   .parent_folder_id = request->parent_folder_id,
   af.public_ind = request->public_ind, af.default_bitmap = request->default_bitmap, af
   .anonymous_bitmap = request->anonymous_bitmap,
   af.comment_id = long_text_id, af.updt_dt_tm = cnvtdatetime(curdate,curtime3), af.updt_id = reqinfo
   ->updt_id,
   af.updt_task = reqinfo->updt_task, af.updt_applctx = reqinfo->updt_applctx, af.updt_cnt = (af
   .updt_cnt+ 1)
  WHERE (af.folder_id=request->folder_id)
  WITH nocounter
 ;end update
 IF (curqual != 1)
  GO TO af_upd_failed
 ENDIF
 IF (del_long_text_id != 0.0)
  DELETE  FROM long_text lt
   WHERE lt.long_text_id=del_long_text_id
   WITH nocounter
  ;end delete
  IF (curqual != 1)
   GO TO lt_del_failed
  ENDIF
 ENDIF
 GO TO exit_script
#af_sel_failed
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER"
 SET failed = "T"
 GO TO exit_script
#af_upd_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER"
 SET failed = "T"
 GO TO exit_script
#af_cnt_failed
 SET reply->status_data.subeventstatus[1].operationname = "VERIFYCHG"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER"
 SET failed = "T"
 GO TO exit_script
#afp_cnt_failed
 SET reply->status_data.subeventstatus[1].operationname = "VERIFYCHG"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_PROXY"
 SET failed = "T"
 GO TO exit_script
#afp_ins_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_PROXY"
 SET failed = "T"
 GO TO exit_script
#afp_upd_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_PROXY"
 SET failed = "T"
 GO TO exit_script
#afp_del_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_PROXY"
 SET failed = "T"
 GO TO exit_script
#lt_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "long_data_seq"
 SET failed = "T"
 GO TO exit_script
#lt_ins_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
#lt_del_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
#lt_upd_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
