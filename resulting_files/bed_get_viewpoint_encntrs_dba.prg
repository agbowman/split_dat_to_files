CREATE PROGRAM bed_get_viewpoint_encntrs:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 viewpoints[*]
      2 viewpoint_id = f8
      2 viewpoint_name = vc
      2 active_ind = i2
      2 mpages[*]
        3 datamart_cat_id = f8
        3 category_name = vc
        3 encntr_types[*]
          4 encntr_type_cd = f8
          4 encntr_display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE default_list_size = i4 WITH constant(10), protect
 DECLARE vp_count = i4 WITH noconstant(0), protect
 DECLARE mpage_count = i4 WITH noconstant(0), protect
 DECLARE enc_type = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SELECT INTO "nl:"
  FROM mp_viewpoint_encntr vp_enc,
   code_value cv,
   mp_viewpoint_reltn vp_rel,
   mp_viewpoint vp,
   br_datamart_category dm_cat
  PLAN (vp_enc)
   JOIN (cv
   WHERE cv.code_value=vp_enc.encntr_type_cd)
   JOIN (vp_rel
   WHERE vp_rel.mp_viewpoint_reltn_id=vp_enc.mp_viewpoint_reltn_id)
   JOIN (vp
   WHERE vp.mp_viewpoint_id=vp_rel.mp_viewpoint_id
    AND vp.active_ind=1)
   JOIN (dm_cat
   WHERE dm_cat.br_datamart_category_id=vp_rel.br_datamart_category_id)
  ORDER BY vp.mp_viewpoint_id, vp_rel.view_seq
  HEAD vp.mp_viewpoint_id
   IF (mod(vp_count,default_list_size)=0)
    stat = alterlist(reply->viewpoints,(vp_count+ default_list_size))
   ENDIF
   vp_count = (vp_count+ 1), mpage_count = 0, reply->viewpoints[vp_count].active_ind = vp.active_ind,
   reply->viewpoints[vp_count].viewpoint_id = vp.mp_viewpoint_id, reply->viewpoints[vp_count].
   viewpoint_name = vp.viewpoint_name
  HEAD vp_rel.view_seq
   IF (mod(mpage_count,default_list_size)=0)
    stat = alterlist(reply->viewpoints[vp_count].mpages,(mpage_count+ default_list_size))
   ENDIF
   mpage_count = (mpage_count+ 1), enc_count = 0, reply->viewpoints[vp_count].mpages[mpage_count].
   category_name = dm_cat.category_name,
   reply->viewpoints[vp_count].mpages[mpage_count].datamart_cat_id = dm_cat.br_datamart_category_id
  DETAIL
   IF (mod(enc_count,default_list_size)=0)
    stat = alterlist(reply->viewpoints[vp_count].mpages[mpage_count].encntr_types,(enc_count+
     default_list_size))
   ENDIF
   enc_count = (enc_count+ 1), reply->viewpoints[vp_count].mpages[mpage_count].encntr_types[enc_count
   ].encntr_type_cd = vp_enc.encntr_type_cd, reply->viewpoints[vp_count].mpages[mpage_count].
   encntr_types[enc_count].encntr_display = cv.display
  FOOT  vp_rel.view_seq
   stat = alterlist(reply->viewpoints[vp_count].mpages[mpage_count].encntr_types,enc_count)
  FOOT  vp.mp_viewpoint_id
   stat = alterlist(reply->viewpoints[vp_count].mpages,mpage_count)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Error reading mp_viewpoint table"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 IF (vp_count > 0)
  SET stat = alterlist(reply->viewpoints,vp_count)
 ENDIF
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
