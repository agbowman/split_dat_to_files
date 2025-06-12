CREATE PROGRAM dcp_rdm_drop_excluded_subphase:dba
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
 SET readme_data->message = "Readme Failed: script dcp_rdm_drop_excluded_subphase"
 DECLARE err_code = i4 WITH protect, noconstant(0)
 DECLARE err_msg = vc WITH protect, noconstant("")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE pw_status_planned_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pw_status_dropped_cd = f8 WITH protect, noconstant(0.0)
 DECLARE comp_type_subphase_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pathway_status_code_set = i4 WITH protect, constant(16769)
 DECLARE pathway_comp_type_set = i4 WITH protect, constant(16750)
 DECLARE pathway_comp_type_meaning_subphase = vc WITH protect, constant("SUBPHASE")
 DECLARE pathway_status_meaning_planned = vc WITH protect, constant("PLANNED")
 DECLARE pathway_status_meaning_dropped = vc WITH protect, constant("DROPPED")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=pathway_status_code_set
   AND cv.cdf_meaning IN (pathway_status_meaning_planned, pathway_status_meaning_dropped)
  DETAIL
   IF (cv.cdf_meaning=pathway_status_meaning_planned)
    pw_status_planned_cd = cv.code_value
   ELSE
    pw_status_dropped_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (error(err_msg,0) != 0)
  SET readme_data->message = concat(
   "Failed to retrieve Code value of PLANNED/DROPPED from CodeSet 16769: ",err_msg)
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=pathway_comp_type_set
   AND cv.cdf_meaning=pathway_comp_type_meaning_subphase
  DETAIL
   comp_type_subphase_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(err_msg,0) != 0)
  SET readme_data->message = concat("Failed to retrieve Code value of SUBPHASE from CodeSet 16750: ",
   err_msg)
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 UPDATE  FROM pathway p
  SET p.pw_status_cd = pw_status_dropped_cd, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p
   .updt_cnt = (p.updt_cnt+ 1),
   p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
   updt_applctx
  WHERE p.pathway_id IN (
  (SELECT
   pa.pathway_id
   FROM act_pw_comp apc,
    pathway pa
   WHERE pa.type_mean="SUBPHASE"
    AND pa.pw_status_cd=pw_status_planned_cd
    AND apc.parent_entity_id=pa.pathway_id
    AND apc.parent_entity_name="PATHWAY"
    AND apc.included_ind=0
    AND apc.comp_type_cd=comp_type_subphase_cd))
  WITH nocounter
 ;end update
 IF (error(err_msg,0) != 0)
  SET readme_data->message = concat(
   "Failed to update the excluded subphases that are in PLANNED status: ",err_msg)
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 UPDATE  FROM pathway p
  SET p.pw_status_cd = pw_status_dropped_cd, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p
   .updt_cnt = (p.updt_cnt+ 1),
   p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
   updt_applctx
  WHERE p.pathway_id IN (
  (SELECT
   pa.pathway_id
   FROM pathway pa
   WHERE pa.type_mean="SUBPHASE"
    AND pa.pw_status_cd=pw_status_planned_cd
    AND  NOT ( EXISTS (
   (SELECT
    apc.parent_entity_id
    FROM act_pw_comp apc
    WHERE apc.parent_entity_id=pa.pathway_id
     AND apc.parent_entity_name="PATHWAY"
     AND apc.comp_type_cd=comp_type_subphase_cd)))))
  WITH nocounter
 ;end update
 IF (error(err_msg,0) != 0)
  SET readme_data->message = concat(
   "Failed to update the excluded subphases from newly placed plans : ",err_msg)
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 UPDATE  FROM pathway p
  SET p.pw_status_cd = pw_status_planned_cd, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p
   .updt_cnt = (p.updt_cnt+ 1),
   p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
   updt_applctx
  WHERE p.pathway_id IN (
  (SELECT
   p2.pathway_id
   FROM act_pw_comp apc,
    pathway p2
   WHERE apc.parent_entity_name="PATHWAY"
    AND apc.parent_entity_id=p2.pathway_id
    AND apc.included_ind=1
    AND p2.pw_status_cd=pw_status_dropped_cd
    AND p2.type_mean="SUBPHASE"
    AND apc.comp_type_cd=comp_type_subphase_cd))
  WITH nocounter
 ;end update
 IF (error(err_msg,0) != 0)
  SET readme_data->message = concat(
   "Failed to update the DROPPED subphases that are linked to included sub phase component : ",
   err_msg)
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 COMMIT
 SET readme_data->message = "Success: Updated the subphases as DROPPED/PLANNED in PATHWAY table."
 SET readme_data->status = "S"
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 SET last_mod = "001"
END GO
