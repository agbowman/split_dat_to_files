CREATE PROGRAM dcp_upd_admit_mins_crit_rdm:dba
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
 SET readme_data->message = "Readme Failed: Starting script dcp_upd_admit_mins_crit_rdm.prg..."
 DECLARE error_msg = vc WITH protect, noconstant
 DECLARE custom_var = f8 WITH constant, protect
 DECLARE lifetimerelationship_var = f8 WITH constant, protect
 DECLARE location_var = f8 WITH constant, protect
 DECLARE locationgroup_var = f8 WITH constant, protect
 DECLARE medicalservice_var = f8 WITH constant, protect
 DECLARE providergroup_var = f8 WITH constant, protect
 DECLARE visitrelationship_var = f8 WITH constant, protect
 DECLARE careteam_var = f8 WITH constant, protect
 DECLARE relationship_var = f8 WITH constant, protect
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=27360
  DETAIL
   CASE (cv.cdf_meaning)
    OF "CUSTOM":
     custom_var = cv.code_value
    OF "LRELTN":
     lifetimerelationship_var = cv.code_value
    OF "LOCATION":
     location_var = cv.code_value
    OF "LOCATIONGRP":
     locationgroup_var = cv.code_value
    OF "SERVICE":
     medicalservice_var = cv.code_value
    OF "PROVIDERGRP":
     providergroup_var = cv.code_value
    OF "VRELTN":
     visitrelationship_var = cv.code_value
    OF "CARETEAM":
     careteam_var = cv.code_value
    OF "RELTN":
     relationship_var = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 INSERT  FROM dcp_pl_argument dpa
  (dpa.argument_id, dpa.argument_name, dpa.argument_value,
  dpa.parent_entity_id, dpa.patient_list_id, dpa.updt_cnt,
  dpa.updt_dt_tm, dpa.updt_id, dpa.updt_task,
  dpa.updt_applctx)(SELECT
   argument_id = seq(dcp_patient_list_seq,nextval), argument_name = "lookforward_admit_mins",
   argument_value = "0",
   parent_entity_id = 0, patient_list_id = dpl1.patient_list_id, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = reqinfo->updt_id, updt_task = 5263,
   updt_applctx = reqinfo->updt_applctx
   FROM dcp_patient_list dpl1
   WHERE dpl1.patient_list_id IN (
   (SELECT
    dpl2.patient_list_id
    FROM dcp_patient_list dpl2,
     dcp_pl_argument dpa
    WHERE dpl2.patient_list_type_cd IN (custom_var, lifetimerelationship_var, location_var,
    locationgroup_var, medicalservice_var,
    providergroup_var, visitrelationship_var, careteam_var, relationship_var)
     AND dpl2.patient_list_id=dpa.patient_list_id
     AND dpa.argument_name="admit_mins"))
    AND  NOT (dpl1.patient_list_id IN (
   (SELECT
    dpa.patient_list_id
    FROM dcp_pl_argument dpa
    WHERE dpa.argument_name="lookforward_admit_mins")))
   ORDER BY dpl1.patient_list_id)
 ;end insert
 IF (error(error_msg,1) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: insert data due to error: ",error_msg)
  GO TO exit_script
 ELSE
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = "Success: dcp_upd_admit_mins_crit_rdm performed all required tasks"
  GO TO exit_script
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
