CREATE PROGRAM aps_add_folder:dba
 RECORD reply(
   1 folder_id = f8
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
 SET nbr_of_proxies = cnvtint(value(size(request->proxy_qual,5)))
 DECLARE folder_id = f8 WITH protect, noconstant(0.0)
 SET parent_folder_id = request->parent_folder_id
 DECLARE long_text_id = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  seq_nbr = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   folder_id = seq_nbr, reply->folder_id = folder_id
   IF ((request->parent_folder_id=0.0))
    parent_folder_id = folder_id
   ENDIF
  WITH format, counter
 ;end select
 IF (curqual=0)
  GO TO seq_failed
 ENDIF
 IF ((request->comment != ""))
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
    lt.parent_entity_id = folder_id, lt.active_ind = 1, lt.active_status_cd = reqdata->
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
 ENDIF
 INSERT  FROM ap_folder af
  SET af.folder_id = folder_id, af.folder_name = request->folder_name, af.folder_name_key = cnvtupper
   (request->folder_name),
   af.parent_folder_id = parent_folder_id, af.create_prsnl_id = request->create_prsnl_id, af
   .public_ind = request->public_ind,
   af.default_bitmap = request->default_bitmap, af.anonymous_bitmap = request->anonymous_bitmap, af
   .comment_id = long_text_id,
   af.updt_dt_tm = cnvtdatetime(curdate,curtime3), af.updt_id = reqinfo->updt_id, af.updt_task =
   reqinfo->updt_task,
   af.updt_applctx = reqinfo->updt_applctx, af.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual != 1)
  GO TO af_ins_failed
 ENDIF
 IF (nbr_of_proxies > 0)
  INSERT  FROM ap_folder_proxy afp,
    (dummyt d  WITH seq = value(nbr_of_proxies))
   SET afp.folder_id = folder_id, afp.parent_entity_id = request->proxy_qual[d.seq].parent_entity_id,
    afp.parent_entity_name = request->proxy_qual[d.seq].parent_entity_name,
    afp.permission_bitmap = request->proxy_qual[d.seq].permission_bitmap, afp.contact_ind = request->
    proxy_qual[d.seq].folder_contact_ind, afp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    afp.updt_id = reqinfo->updt_id, afp.updt_task = reqinfo->updt_task, afp.updt_applctx = reqinfo->
    updt_applctx,
    afp.updt_cnt = 0
   PLAN (d)
    JOIN (afp
    WHERE afp.folder_id=folder_id
     AND (afp.parent_entity_id=request->proxy_qual[d.seq].parent_entity_id)
     AND (afp.parent_entity_name=request->proxy_qual[d.seq].parent_entity_name))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual != nbr_of_proxies)
   GO TO afp_ins_failed
  ENDIF
 ENDIF
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "reference_seq"
 SET failed = "T"
 GO TO exit_script
#lt_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "long_data_seq"
 SET failed = "T"
 GO TO exit_script
#af_ins_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER"
 SET failed = "T"
 GO TO exit_script
#afp_ins_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_PROXY"
 SET failed = "T"
 GO TO exit_script
#lt_ins_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
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
