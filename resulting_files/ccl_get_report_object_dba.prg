CREATE PROGRAM ccl_get_report_object:dba
 RECORD reply(
   1 report_name = c100
   1 object_name = c30
   1 object_type = c10
   1 object_description = vc
   1 object_id = f8
   1 file_name = c100
   1 ccl_group = i2
   1 active_ind = i2
   1 active_status_cd = f8
   1 active_status_dt_tm = dq8
   1 active_status_prsnl_id = f8
   1 driver_object_id = f8
   1 product_cd = f8
   1 section_list[*]
     2 section_id = f8
     2 section_name = c30
     2 section_description = vc
     2 section_height = f8
     2 section_type_ind = i2
     2 section_blob_id = f8
     2 section_blob = gvc
   1 height = f8
   1 width = f8
   1 orientation = i4
   1 top_margin = f8
   1 bottom_margin = f8
   1 left_margin = f8
   1 right_margin = f8
   1 sub_left_margin = f8
   1 sub_top_margin = f8
   1 row_size = i4
   1 column_size = i4
   1 row_gutter = f8
   1 column_gutter = f8
   1 username = vc
   1 modified = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE _status = c WITH noconstant("S"), protect
 DECLARE _rpt_obj_id = f8 WITH noconstant(0.0), protect
 DECLARE _rpt_obj_type = vc WITH noconstant(""), protect
 DECLARE cnt = i2 WITH noconstant(0), protect
 DECLARE errmsg = vc WITH noconstant(fillstring(255," ")), protect
 SELECT INTO "nl:"
  ro.report_name, ro.object_id, ro.object_name,
  ro.object_type, ro.object_description, ro.file_name,
  ro.ccl_group, ro.active_ind, ro.active_status_cd,
  ro.active_status_dt_tm, ro.active_status_prsnl_id, ro.driver_object_id,
  ro.product_cd, p.username, ro.updt_dt_tm
  FROM ccl_report_object ro,
   prsnl p
  PLAN (ro
   WHERE ro.object_name=cnvtupper(request->object_name)
    AND (ro.ccl_group=request->ccl_group))
   JOIN (p
   WHERE p.person_id=ro.updt_id)
  DETAIL
   _rpt_obj_id = ro.object_id, reply->object_id = ro.object_id, reply->report_name = ro.report_name,
   reply->object_name = ro.object_name, _rpt_obj_type = ro.object_type, reply->object_type = ro
   .object_type,
   reply->object_description = ro.object_description, reply->file_name = ro.file_name, reply->
   ccl_group = ro.ccl_group,
   reply->active_ind = ro.active_ind, reply->active_status_cd = ro.active_status_cd, reply->
   active_status_dt_tm = ro.active_status_dt_tm,
   reply->active_status_prsnl_id = ro.active_status_prsnl_id, reply->driver_object_id = ro
   .driver_object_id, reply->product_cd = ro.product_cd,
   reply->username = p.username, reply->modified = format(ro.updt_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")
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
 SELECT INTO "nl:"
  ls.section_id, ror.rep_obj_reltn_id
  FROM ccl_report_object_r ror,
   ccl_layout_section ls
  PLAN (ror
   WHERE ror.object_id=_rpt_obj_id)
   JOIN (ls
   WHERE ls.section_id=ror.section_id)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   ls.section_id, ls.section_name, ls.section_type_ind,
   ls.section_description, ls.section_height, lb.long_blob_id,
   lb.long_blob, moreblob = textlen(lb.long_blob)
   FROM ccl_report_object_r ror,
    ccl_layout_section ls,
    long_blob lb
   PLAN (ror
    WHERE ror.object_id=_rpt_obj_id)
    JOIN (ls
    WHERE ls.section_id=ror.section_id)
    JOIN (lb
    WHERE lb.long_blob_id=ls.section_blob_id)
   HEAD REPORT
    outbuf = fillstring(32767," ")
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->section_list,(cnt+ 9))
    ENDIF
    reply->section_list[cnt].section_id = ls.section_id, reply->section_list[cnt].section_name = ls
    .section_name, reply->section_list[cnt].section_type_ind = ls.section_type_ind,
    reply->section_list[cnt].section_description = ls.section_description, reply->section_list[cnt].
    section_height = ls.section_height, reply->section_list[cnt].section_blob_id = lb.long_blob_id,
    offset = 0, retlen = 1
    WHILE (retlen > 0)
      retlen = blobget(outbuf,offset,lb.long_blob), offset = (offset+ retlen), reply->section_list[
      cnt].section_blob = notrim(concat(notrim(reply->section_list[cnt].section_blob),notrim(
         substring(1,retlen,outbuf))))
    ENDWHILE
   WITH nocounter, rdbarrayfetch = 1
  ;end select
  SET stat = alterlist(reply->section_list,cnt)
  IF (curqual=0)
   SET errcode = error(errmsg,1)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CCL_LAYOUT_SECTION"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
   SET _status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (_status="F")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
