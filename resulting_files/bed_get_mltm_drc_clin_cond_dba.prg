CREATE PROGRAM bed_get_mltm_drc_clin_cond:dba
 FREE SET reply
 RECORD reply(
   1 groupers[*]
     2 id = f8
     2 display = vc
     2 conditions[*]
       3 condition1_disp = vc
       3 condition2_disp = vc
       3 premises[*]
         4 drc_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_cond
 RECORD temp_cond(
   1 group[*]
     2 id = f8
     2 cond[*]
       3 cki = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET match_ind = 0
 SELECT INTO "nl:"
  FROM mltm_drc_premise mdp,
   nomenclature n,
   dcp_entity_reltn der,
   code_value cv,
   code_value cv2
  PLAN (mdp
   WHERE ((mdp.dose_range_check_id+ 0) > 0)
    AND mdp.parent_premise_id=0
    AND mdp.condition_concept_cki > " "
    AND mdp.route_id > 0
    AND  NOT ( EXISTS (
   (SELECT
    d.dose_range_check_id
    FROM drc_premise d
    WHERE d.dose_range_check_id=mdp.dose_range_check_id
     AND d.premise_type_flag=7))))
   JOIN (der
   WHERE der.entity_reltn_mean="DRC/ROUTE"
    AND der.entity1_id=mdp.route_id
    AND der.active_ind=1)
   JOIN (n
   WHERE n.concept_cki=mdp.condition_concept_cki
    AND n.primary_cterm_ind=1
    AND n.active_ind=1
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
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
  ORDER BY mdp.grouper_id, mdp.condition_concept_cki
  HEAD REPORT
   cnt = 0, list_cnt = 0, stat = alterlist(reply->groupers,100),
   match_ind = 1
  HEAD mdp.grouper_id
   sub_cnt = 0, tot_cnt = 0
   IF (match_ind=1)
    list_cnt = (list_cnt+ 1), cnt = (cnt+ 1)
    IF (list_cnt > 100)
     stat = alterlist(reply->groupers,(cnt+ 100)), list_cnt = 1
    ENDIF
   ELSE
    stat = alterlist(reply->groupers[cnt].conditions,0)
   ENDIF
   reply->groupers[cnt].id = mdp.grouper_id, reply->groupers[cnt].display = mdp.grouper_name, stat =
   alterlist(reply->groupers[cnt].conditions,10),
   match_ind = 0
  HEAD mdp.condition_concept_cki
   pcnt = 0, ptot_cnt = 0
   IF (((match_ind=1) OR (sub_cnt=0)) )
    sub_cnt = (sub_cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (tot_cnt > 10)
     stat = alterlist(reply->groupers[cnt].conditions,(sub_cnt+ 10)), tot_cnt = 1
    ENDIF
   ENDIF
   reply->groupers[cnt].conditions[sub_cnt].condition1_disp = n.source_string, stat = alterlist(reply
    ->groupers[cnt].conditions[sub_cnt].premises,10)
  DETAIL
   IF (((mdp.dose_range_type_id=5
    AND mdp.comment_txt > " ") OR (mdp.dose_range_type_id != 5
    AND cv.code_value > 0)) )
    IF (((mdp.max_dose_unit_cki > " "
     AND cv2.code_value > 0) OR (mdp.max_dose_unit_cki IN ("", " ", null))) )
     match_ind = 1, pcnt = (pcnt+ 1), ptot_cnt = (ptot_cnt+ 1)
     IF (ptot_cnt > 10)
      stat = alterlist(reply->groupers[cnt].conditions[sub_cnt].premises,(pcnt+ 10)), ptot_cnt = 1
     ENDIF
     reply->groupers[cnt].conditions[sub_cnt].premises[pcnt].drc_cki = mdp.drc_cki
    ENDIF
   ENDIF
  FOOT  mdp.condition_concept_cki
   stat = alterlist(reply->groupers[cnt].conditions[sub_cnt].premises,pcnt)
  FOOT  mdp.grouper_id
   stat = alterlist(reply->groupers[cnt].conditions,sub_cnt)
  FOOT REPORT
   IF (cnt > 0
    AND match_ind=0)
    stat = alterlist(reply->groupers,(cnt - 1))
   ELSE
    stat = alterlist(reply->groupers,cnt)
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
