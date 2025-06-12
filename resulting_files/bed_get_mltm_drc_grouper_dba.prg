CREATE PROGRAM bed_get_mltm_drc_grouper:dba
 FREE SET reply
 RECORD reply(
   1 groupers[*]
     2 id = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET match_ind = 0
 SELECT INTO "nl:"
  FROM mltm_drc_premise mdp,
   dcp_entity_reltn der,
   code_value cv,
   code_value cv2,
   dose_range_check drc
  PLAN (mdp
   WHERE mdp.dose_range_check_id=0
    AND mdp.route_id > 0)
   JOIN (der
   WHERE der.entity_reltn_mean="DRC/ROUTE"
    AND der.entity1_id=mdp.route_id
    AND der.active_ind=1)
   JOIN (drc
   WHERE drc.dose_range_check_name=mdp.grouper_name)
   JOIN (cv
   WHERE cv.cki=outerjoin(mdp.dose_unit_cki)
    AND cv.code_set=outerjoin(54)
    AND cv.active_ind=outerjoin(1)
    AND cv.cki > outerjoin(" "))
   JOIN (cv2
   WHERE cv2.cki=outerjoin(mdp.max_dose_unit_cki)
    AND cv2.code_set=outerjoin(54)
    AND cv2.active_ind=outerjoin(1)
    AND cv2.cki > outerjoin(" "))
  ORDER BY mdp.grouper_id
  HEAD REPORT
   cnt = 0, list_cnt = 0, stat = alterlist(reply->groupers,100),
   match_ind = 1
  HEAD mdp.grouper_id
   IF (match_ind=1)
    list_cnt = (list_cnt+ 1), cnt = (cnt+ 1)
    IF (list_cnt > 100)
     stat = alterlist(reply->groupers,(cnt+ 100)), list_cnt = 1
    ENDIF
   ENDIF
   reply->groupers[cnt].id = mdp.grouper_id, reply->groupers[cnt].display = mdp.grouper_name,
   match_ind = 0
  DETAIL
   IF (((mdp.dose_range_type_id=5
    AND mdp.comment_txt > " ") OR (mdp.dose_range_type_id != 5
    AND cv.code_value > 0)) )
    IF (((mdp.max_dose_unit_cki > " "
     AND cv2.code_value > 0) OR (mdp.max_dose_unit_cki IN ("", " ", null))) )
     match_ind = 1
    ENDIF
   ENDIF
  FOOT REPORT
   IF (cnt > 0
    AND match_ind=0)
    stat = alterlist(reply->groupers,(cnt - 1))
   ELSE
    stat = alterlist(reply->groupers,cnt)
   ENDIF
  WITH nocounter
 ;end select
 EXECUTE mltm_upd_mltm_drc_premise  WITH replace("REPLY",reply_mltm)
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
