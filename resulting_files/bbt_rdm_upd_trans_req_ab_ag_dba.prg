CREATE PROGRAM bbt_rdm_upd_trans_req_ab_ag:dba
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
 DECLARE serrormsg = c132 WITH public, noconstant(fillstring(132," "))
 DECLARE lerrorcode = i4 WITH public, noconstant(0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script bbt_rdm_upd_trans_req_ab_ag..."
 DECLARE codevalue_active = f8 WITH noconstant(0), protect
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning="ACTIVE"
   AND c.code_set=48
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   codevalue_active = c.code_value
  WITH nocounter
 ;end select
 SET lerrorcode = error(serrormsg,0)
 IF (lerrorcode != 0)
  SET readme_data->message = concat("Error selecting from the code_value table: ",serrormsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM person_trans_req ptr
  SET ptr.removed_prsnl_id = ptr.updt_id, ptr.removed_dt_tm = ptr.updt_dt_tm
  WHERE ptr.active_ind=0
   AND ptr.person_trans_req_id > 0
   AND ptr.removed_prsnl_id=0.0
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM person_combine_det pcd
   WHERE pcd.entity_id=ptr.person_trans_req_id)))
   AND  EXISTS (
  (SELECT
   "x"
   FROM encounter e
   WHERE e.active_ind > 0
    AND e.person_id=ptr.person_id
    AND e.encntr_id=ptr.encntr_id))
 ;end update
 SET lerrorcode = error(serrormsg,0)
 IF (lerrorcode != 0)
  SET readme_data->message = concat("Failed to update person_trans_req table: ",serrormsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM person_antigen pag
  SET pag.removed_prsnl_id = pag.updt_id, pag.removed_dt_tm = pag.updt_dt_tm
  WHERE pag.active_ind=0
   AND pag.person_antigen_id > 0
   AND pag.active_status_cd=codevalue_active
   AND pag.removed_prsnl_id=0.0
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM person_combine_det pcd
   WHERE pcd.entity_id=pag.person_antigen_id)))
   AND  EXISTS (
  (SELECT
   "x"
   FROM encounter e
   WHERE e.active_ind > 0
    AND e.person_id=pag.person_id
    AND e.encntr_id=pag.encntr_id))
 ;end update
 SET lerrorcode = error(serrormsg,0)
 IF (lerrorcode != 0)
  SET readme_data->message = concat("Failed to update person_antigen table: ",serrormsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM person_antibody pab
  SET pab.removed_prsnl_id = pab.updt_id, pab.removed_dt_tm = pab.updt_dt_tm
  WHERE pab.active_ind=0
   AND pab.person_antibody_id > 0
   AND pab.active_status_cd=codevalue_active
   AND pab.removed_prsnl_id=0.0
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM person_combine_det pcd
   WHERE pcd.entity_id=pab.person_antibody_id)))
   AND  EXISTS (
  (SELECT
   "x"
   FROM encounter e
   WHERE e.active_ind > 0
    AND e.person_id=pab.person_id
    AND e.encntr_id=pab.encntr_id))
 ;end update
 SET lerrorcode = error(serrormsg,0)
 IF (lerrorcode != 0)
  SET readme_data->message = concat("Failed to update person_antibody table: ",serrormsg)
  GO TO exit_script
 ENDIF
 SET readme_data->message = "Readme successful: Tables updated successfully"
 SET readme_data->status = "S"
 COMMIT
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
