CREATE PROGRAM cp_rdm_updt_node_behaviors:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting script cp_rdm_updt_node_behaviors"
 DECLARE err_code = i4 WITH protect, noconstant(0)
 DECLARE err_msg = vc WITH protect, noconstant("")
 DECLARE activepwstatuscd = f8 WITH noconstant(0), protect
 DECLARE guidedtreatmentcd = f8 WITH noconstant(0), protect
 DECLARE doccontenttypecd = f8 WITH noconstant(0), protect
 DECLARE bhvr_cnt = i4 WITH noconstant(0), protect
 DECLARE x = i4 WITH noconstant(0), protect
 FREE RECORD node_bhvrs_to_update
 RECORD node_bhvrs_to_update(
   1 qual[*]
     2 cp_node_behavior_id = f8
     2 cp_node_id = f8
     2 reaction_entity_id = f8
 )
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4003198
   AND cv.cdf_meaning="ACTIVE"
  HEAD REPORT
   activepwstatuscd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4003130
   AND cv.cdf_meaning="GUIDEDTRMNT"
  HEAD REPORT
   guidedtreatmentcd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4003134
   AND cv.cdf_meaning="DOCCONTENT"
  HEAD REPORT
   doccontenttypecd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM cp_pathway cp,
   cp_node cn,
   cp_component cc,
   cp_component_detail ccd,
   cp_node_behavior cnb
  PLAN (cp
   WHERE cp.pathway_status_cd=activepwstatuscd)
   JOIN (cn
   WHERE cn.cp_pathway_id=cp.cp_pathway_id
    AND cn.active_ind=1)
   JOIN (cc
   WHERE cc.cp_node_id=cn.cp_node_id
    AND cc.comp_type_cd=guidedtreatmentcd)
   JOIN (ccd
   WHERE ccd.cp_component_id=cc.cp_component_id
    AND ccd.component_detail_reltn_cd=doccontenttypecd
    AND ccd.default_ind=1)
   JOIN (cnb
   WHERE cnb.cp_node_id=cn.cp_node_id
    AND cnb.instance_ident IN (ccd.component_ident, concat("InitialRecommendations_",cnvtstring(cn
     .cp_node_id)))
    AND cnb.response_ident="ONLOAD_RECOMMENDATION")
  ORDER BY cnb.cp_node_id, cnb.reaction_entity_id
  DETAIL
   IF ((cnb.reaction_entity_id=node_bhvrs_to_update->qual[bhvr_cnt].reaction_entity_id))
    bhvr_cnt -= 1, stat = alterlist(node_bhvrs_to_update->qual,bhvr_cnt)
   ELSE
    bhvr_cnt += 1, stat = alterlist(node_bhvrs_to_update->qual,bhvr_cnt), node_bhvrs_to_update->qual[
    bhvr_cnt].cp_node_behavior_id = cnb.cp_node_behavior_id,
    node_bhvrs_to_update->qual[bhvr_cnt].cp_node_id = cnb.cp_node_id, node_bhvrs_to_update->qual[
    bhvr_cnt].reaction_entity_id = cnb.reaction_entity_id
   ENDIF
  WITH nocounter
 ;end select
 IF (err_code > 0)
  CALL echo("Readme Failed: Failed to find existing Initial Recommendations.")
  SET readme_data->message = concat("Failed to find Initial Recommendation: ",err_msg)
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 UPDATE  FROM (dummyt d1  WITH seq = bhvr_cnt),
   cp_node_behavior cnb
  SET cnb.instance_ident = concat("InitialRecommendations_",cnvtstring(node_bhvrs_to_update->qual[d1
     .seq].cp_node_id))
  PLAN (d1)
   JOIN (cnb
   WHERE (cnb.cp_node_behavior_id=node_bhvrs_to_update->qual[d1.seq].cp_node_behavior_id))
  WITH nocounter
 ;end update
 SET err_code = error(err_msg,0)
 IF (err_code > 0)
  ROLLBACK
  CALL echo("Readme Failed: Failed to perform Initial Recommendation updates.")
  SET readme_data->message = concat("Failed to perform Initial Recommendation updates: ",err_msg)
  SET readme_data->status = "F"
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->message = "Successfully updated Initial Recommendations."
 SET readme_data->status = "S"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
