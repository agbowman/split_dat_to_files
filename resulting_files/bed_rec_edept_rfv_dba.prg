CREATE PROGRAM bed_rec_edept_rfv:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->run_status_flag = 1
 SET rfvdx = uar_get_code_by("MEANING",17,"RFV")
 SELECT INTO "nl:"
  FROM name_value_prefs np,
   detail_prefs dp,
   view_prefs vp,
   name_value_prefs vc,
   code_value cv
  PLAN (np
   WHERE np.pvc_name="DX_DEFAULT_TYPE"
    AND np.parent_entity_name="DETAIL_PREFS"
    AND ((cnvtreal(trim(np.pvc_value)) != rfvdx) OR (np.pvc_value IN ("", " ", null))) )
   JOIN (dp
   WHERE dp.detail_prefs_id=np.parent_entity_id
    AND dp.application_number=4250111
    AND dp.active_ind=1)
   JOIN (vp
   WHERE vp.prsnl_id=dp.prsnl_id
    AND vp.position_cd=dp.position_cd
    AND vp.application_number=dp.application_number
    AND vp.view_name=dp.view_name
    AND vp.view_seq=dp.view_seq
    AND vp.active_ind=1)
   JOIN (vc
   WHERE vc.parent_entity_id=vp.view_prefs_id
    AND vc.parent_entity_name="VIEW_PREFS"
    AND trim(vc.pvc_name)="VIEW_CAPTION")
   JOIN (cv
   WHERE cv.code_value=outerjoin(dp.position_cd)
    AND cv.active_ind=outerjoin(1))
  DETAIL
   IF (((cv.code_value > 0
    AND dp.position_cd > 0) OR (dp.position_cd=0)) )
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
