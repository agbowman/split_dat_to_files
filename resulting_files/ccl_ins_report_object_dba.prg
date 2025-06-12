CREATE PROGRAM ccl_ins_report_object:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE _active_var = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE _object_name = vc WITH noconstant(cnvtupper(request->object_name)), protect
 DECLARE _object_id = f8 WITH noconstant(0.0), protect
 DECLARE _object_seq = f8 WITH noconstant(0.0), protect
 DECLARE _section_id = f8 WITH noconstant(0.0), protect
 DECLARE _section_seq = f8 WITH noconstant(0.0), protect
 DECLARE _blob_id = f8 WITH noconstant(0.0), protect
 DECLARE _blob_seq = f8 WITH noconstant(0.0), protect
 DECLARE _ror_id = f8 WITH noconstant(0.0), protect
 DECLARE _update_cnt = i4 WITH noconstant(0), protect
 DECLARE _status = c WITH noconstant("S"), protect
 DECLARE errmsg = vc WITH noconstant(fillstring(255," ")), protect
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  ro.object_id
  FROM ccl_report_object ro
  WHERE ro.object_name=_object_name
   AND (ro.ccl_group=request->ccl_group)
  DETAIL
   _object_id = ro.object_id
  WITH nocounter
 ;end select
 IF (_object_id=0)
  SELECT INTO "nl:"
   _reportobjseq = seq(ccl_seq,nextval)
   FROM dual
   DETAIL
    _object_seq = _reportobjseq
   WITH nocounter
  ;end select
  INSERT  FROM ccl_report_object ro
   SET ro.report_name = _object_name, ro.object_name = _object_name, ro.object_type = cnvtupper(
     request->object_type),
    ro.object_description = request->object_description, ro.object_id = _object_seq, ro.file_name =
    request->file_name,
    ro.ccl_group = request->ccl_group, ro.active_ind = 1, ro.active_status_cd = _active_var,
    ro.active_status_dt_tm = cnvtdatetime(sysdate), ro.active_status_prsnl_id = reqinfo->updt_id, ro
    .driver_object_id = request->driver_object_id,
    ro.product_cd = request->product_cd, ro.updt_dt_tm = cnvtdatetime(sysdate), ro.updt_task =
    reqinfo->updt_task,
    ro.updt_id = reqinfo->updt_id, ro.updt_cnt = 1, ro.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET errcode = error(errmsg,1)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CCL_REPORT_OBJECT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
   SET _status = "F"
   GO TO exit_script
  ENDIF
 ELSE
  SET _object_seq = _object_id
  IF ((request->section_only=0))
   SELECT INTO "nl:"
    ro.*
    FROM ccl_report_object ro
    WHERE ro.object_id=_object_seq
    WITH nocounter, forupdate(ro)
   ;end select
   SELECT INTO "nl:"
    ro.updt_cnt
    FROM ccl_report_object ro
    WHERE ro.object_id=_object_seq
    DETAIL
     _update_cnt = (ro.updt_cnt+ 1)
    WITH nocounter
   ;end select
   UPDATE  FROM ccl_report_object ro
    SET ro.report_name = _object_name, ro.object_name = _object_name, ro.object_type = cnvtupper(
      request->object_type),
     ro.object_description = request->object_description, ro.file_name = request->file_name, ro
     .ccl_group = request->ccl_group,
     ro.active_ind = 1, ro.active_status_cd = _active_var, ro.active_status_dt_tm = cnvtdatetime(
      sysdate),
     ro.active_status_prsnl_id = reqinfo->updt_id, ro.driver_object_id = request->driver_object_id,
     ro.product_cd = request->product_cd,
     ro.updt_dt_tm = cnvtdatetime(sysdate), ro.updt_task = reqinfo->updt_task, ro.updt_id = reqinfo->
     updt_id,
     ro.updt_cnt = _update_cnt, ro.updt_applctx = reqinfo->updt_applctx
    WHERE ro.object_id=_object_seq
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET errcode = error(errmsg,1)
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CCL_REPORT_OBJECT"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
    SET _status = "F"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 FOR (x = 1 TO size(request->section_list,5))
   SET _section_id = 0.0
   SET _blob_id = 0.0
   SET _ror_id = 0.0
   IF (_object_id > 0)
    SELECT INTO "nl:"
     ls.section_id, ls.section_blob_id, ror.rep_obj_reltn_id,
     ls.section_name, ls.section_type_ind
     FROM ccl_report_object_r ror,
      ccl_layout_section ls
     PLAN (ror
      WHERE ror.object_id=_object_seq)
      JOIN (ls
      WHERE ls.section_id=ror.section_id
       AND ls.section_name=cnvtupper(request->section_list[x].section_name)
       AND (ls.section_type_ind=request->section_list[x].section_type_ind))
     DETAIL
      _section_id = ls.section_id, _blob_id = ls.section_blob_id, _ror_id = ror.rep_obj_reltn_id
     WITH nocounter, separator = " ", format
    ;end select
   ENDIF
   IF (_section_id > 0)
    SELECT INTO "nl:"
     lb.*
     FROM long_blob lb
     WHERE lb.long_blob_id=_blob_id
     WITH nocounter, forupdate(lb)
    ;end select
    SELECT INTO "nl:"
     lb.updt_cnt
     FROM long_blob lb
     WHERE lb.long_blob_id=_blob_id
     DETAIL
      _update_cnt = (lb.updt_cnt+ 1)
     WITH nocounter
    ;end select
    UPDATE  FROM long_blob lb
     SET lb.active_ind = 1, lb.active_status_cd = _active_var, lb.active_status_dt_tm = cnvtdatetime(
       sysdate),
      lb.active_status_prsnl_id = reqinfo->updt_id, lb.long_blob = request->section_list[x].
      section_blob, lb.parent_entity_id = _section_id,
      lb.parent_entity_name = "CCL_LAYOUT_SECTION", lb.updt_dt_tm = cnvtdatetime(sysdate), lb
      .updt_task = reqinfo->updt_task,
      lb.updt_id = reqinfo->updt_id, lb.updt_cnt = _update_cnt, lb.updt_applctx = reqinfo->
      updt_applctx
     WHERE lb.long_blob_id=_blob_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET errcode = error(errmsg,1)
     SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_BLOB"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
     SET _status = "F"
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     ls.*
     FROM ccl_layout_section ls
     WHERE ls.section_id=_section_id
     WITH nocounter, forupdate(ls)
    ;end select
    SELECT INTO "nl:"
     ls.updt_cnt
     FROM ccl_layout_section ls
     WHERE ls.section_id=_section_id
     DETAIL
      _update_cnt = (ls.updt_cnt+ 1)
     WITH nocounter
    ;end select
    UPDATE  FROM ccl_layout_section ls
     SET ls.section_name = cnvtupper(request->section_list[x].section_name), ls.section_blob_id =
      _blob_id, ls.section_description = request->section_list[x].section_description,
      ls.section_height = request->section_list[x].section_height, ls.section_version = request->
      section_list[x].section_version, ls.section_type_ind = request->section_list[x].
      section_type_ind,
      ls.driver_object_id = 0, ls.updt_dt_tm = cnvtdatetime(sysdate), ls.updt_task = reqinfo->
      updt_task,
      ls.updt_id = reqinfo->updt_id, ls.updt_cnt = _update_cnt, ls.updt_applctx = reqinfo->
      updt_applctx
     WHERE ls.section_id=_section_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET errcode = error(errmsg,1)
     SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CCL_LAYOUT_SECTION"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
     SET _status = "F"
     GO TO exit_script
    ENDIF
   ELSE
    SELECT INTO "nl:"
     _reportseq = seq(ccl_seq,nextval), _blobseq = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      _section_seq = _reportseq, _blob_seq = _blobseq
     WITH nocounter
    ;end select
    INSERT  FROM long_blob lb
     SET lb.active_ind = 1, lb.active_status_cd = _active_var, lb.active_status_dt_tm = cnvtdatetime(
       sysdate),
      lb.active_status_prsnl_id = reqinfo->updt_id, lb.long_blob = request->section_list[x].
      section_blob, lb.long_blob_id = _blob_seq,
      lb.parent_entity_id = _section_seq, lb.parent_entity_name = "CCL_LAYOUT_SECTION", lb.updt_dt_tm
       = cnvtdatetime(sysdate),
      lb.updt_task = reqinfo->updt_task, lb.updt_id = reqinfo->updt_id, lb.updt_cnt = 1,
      lb.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET errcode = error(errmsg,1)
     SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_BLOB"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
     SET _status = "F"
     GO TO exit_script
    ENDIF
    INSERT  FROM ccl_layout_section ls
     SET ls.section_id = _section_seq, ls.section_name = cnvtupper(request->section_list[x].
       section_name), ls.section_blob_id = _blob_seq,
      ls.section_description = request->section_list[x].section_description, ls.section_height =
      request->section_list[x].section_height, ls.section_version = request->section_list[x].
      section_version,
      ls.section_type_ind = request->section_list[x].section_type_ind, ls.driver_object_id = 0, ls
      .updt_dt_tm = cnvtdatetime(sysdate),
      ls.updt_task = reqinfo->updt_task, ls.updt_id = reqinfo->updt_id, ls.updt_cnt = 1,
      ls.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET errcode = error(errmsg,1)
     SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CCL_LAYOUT_SECTION"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
     SET _status = "F"
     GO TO exit_script
    ENDIF
    INSERT  FROM ccl_report_object_r ror
     SET ror.rep_obj_reltn_id = seq(ccl_seq,nextval), ror.object_id = _object_seq, ror.section_id =
      _section_seq,
      ror.section_sequence = 0, ror.updt_dt_tm = cnvtdatetime(sysdate), ror.updt_task = reqinfo->
      updt_task,
      ror.updt_id = reqinfo->updt_id, ror.updt_cnt = 1, ror.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET errcode = error(errmsg,1)
     SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CCL_REPORT_OBJECT_R"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
     SET _status = "F"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (_status="F")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
