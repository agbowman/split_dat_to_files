CREATE PROGRAM ccl_del_report_object
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD old_sections
 RECORD old_sections(
   1 section[*]
     2 id = f8
     2 blob = f8
     2 ror = f8
 )
 DECLARE _rpt_obj_group = i2 WITH noconstant(request->ccl_group), protect
 DECLARE _rpt_obj_name = vc WITH noconstant(cnvtupper(request->object_name)), protect
 DECLARE _rpt_obj_id = f8 WITH noconstant(0.0), protect
 DECLARE _old_cnt = i4 WITH noconstant(0), protect
 DECLARE _status = c WITH noconstant("S"), protect
 DECLARE errmsg = vc WITH noconstant(fillstring(255," ")), protect
 DECLARE _bdeleteobject = i1 WITH noconstant(1), protect
 DECLARE _nsections = i4 WITH noconstant(0), protect
 DECLARE _update_cnt = i4 WITH noconstant(0), protect
 SET _rpt_obj_name = trim(replace(_rpt_obj_name,"*","",0),3)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  _rptobjid = ro.object_id
  FROM ccl_report_object ro
  WHERE ro.object_name=_rpt_obj_name
   AND ro.ccl_group=_rpt_obj_group
  DETAIL
   _rpt_obj_id = _rptobjid
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET errcode = error(errmsg,1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CCL_REPORT_OBJECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  SET _status = "F"
  GO TO exit_script
 ENDIF
 IF (_rpt_obj_id > 0
  AND curqual=1)
  IF ((request->section_only=1))
   SELECT INTO "nl:"
    ls.section_id, ls.section_blob_id, ror.rep_obj_reltn_id
    FROM ccl_report_object_r ror,
     ccl_layout_section ls
    PLAN (ror
     WHERE ror.object_id=_rpt_obj_id)
     JOIN (ls
     WHERE ls.section_id=ror.section_id)
    DETAIL
     IF (ls.section_name=cnvtupper(request->section_name)
      AND (ls.section_type_ind=request->section_type_ind))
      _old_cnt = (_old_cnt+ 1), stat = alterlist(old_sections->section,_old_cnt), old_sections->
      section[_old_cnt].id = ls.section_id,
      old_sections->section[_old_cnt].blob = ls.section_blob_id, old_sections->section[_old_cnt].ror
       = ror.rep_obj_reltn_id
     ENDIF
     _nsections = (_nsections+ 1)
    WITH nocounter
   ;end select
   IF (_old_cnt=0)
    SET errcode = error(errmsg,1)
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CCL_LAYOUT_SECTION"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
    SET _status = "F"
    GO TO exit_script
   ENDIF
   IF (_old_cnt != _nsections)
    SET _bdeleteobject = 0
    IF (trim(request->new_object_type,3) != "")
     SELECT INTO "nl:"
      ro.*
      FROM ccl_report_object ro
      WHERE ro.object_id=_rpt_obj_id
      WITH nocounter, forupdate(ro)
     ;end select
     SELECT INTO "nl:"
      ro.updt_cnt
      FROM ccl_report_object ro
      WHERE ro.object_id=_rpt_obj_id
      DETAIL
       _update_cnt = (ro.updt_cnt+ 1)
      WITH nocounter
     ;end select
     UPDATE  FROM ccl_report_object ro
      SET ro.object_type = cnvtupper(request->new_object_type), ro.updt_dt_tm = cnvtdatetime(sysdate),
       ro.updt_task = reqinfo->updt_task,
       ro.updt_id = reqinfo->updt_id, ro.updt_cnt = _update_cnt, ro.updt_applctx = reqinfo->
       updt_applctx
      WHERE ro.object_id=_rpt_obj_id
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
  ELSE
   SELECT INTO "nl:"
    _section_id = ls.section_id, _blob_id = ls.section_blob_id, _ror_id = ror.rep_obj_reltn_id
    FROM ccl_report_object_r ror,
     ccl_layout_section ls
    PLAN (ror
     WHERE ror.object_id=_rpt_obj_id)
     JOIN (ls
     WHERE ls.section_id=ror.section_id)
    DETAIL
     _old_cnt = (_old_cnt+ 1), stat = alterlist(old_sections->section,_old_cnt), old_sections->
     section[_old_cnt].id = _section_id,
     old_sections->section[_old_cnt].blob = _blob_id, old_sections->section[_old_cnt].ror = _ror_id
    WITH nocounter
   ;end select
  ENDIF
  IF (_old_cnt > 0)
   FOR (x = 1 TO _old_cnt)
    DELETE  FROM ccl_report_object_r ror
     WHERE (ror.rep_obj_reltn_id=old_sections->section[x].ror)
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET errcode = error(errmsg,1)
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CCL_REPORT_OBJECT_R"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
     SET _status = "F"
     GO TO exit_script
    ENDIF
   ENDFOR
   FOR (x = 1 TO _old_cnt)
    DELETE  FROM ccl_layout_section ls
     WHERE (ls.section_id=old_sections->section[x].id)
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET errcode = error(errmsg,1)
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CCL_LAYOUT_SECTION"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
     SET _status = "F"
     GO TO exit_script
    ENDIF
   ENDFOR
   FOR (x = 1 TO _old_cnt)
    DELETE  FROM long_blob lb
     WHERE (lb.long_blob_id=old_sections->section[x].blob)
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET errcode = error(errmsg,1)
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_BLOB"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
     SET _status = "F"
     GO TO exit_script
    ENDIF
   ENDFOR
  ENDIF
  IF (_bdeleteobject=1)
   DELETE  FROM ccl_format_detail fd
    WHERE fd.object_id=_rpt_obj_id
    WITH nocounter
   ;end delete
   DELETE  FROM ccl_report_object ro
    WHERE ro.object_id=_rpt_obj_id
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET errcode = error(errmsg,1)
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CCL_REPORT_OBJECT"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
    SET _status = "F"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
#exit_script
 IF (_status="F")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
