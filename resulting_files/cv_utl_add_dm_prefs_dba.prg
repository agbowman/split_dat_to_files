CREATE PROGRAM cv_utl_add_dm_prefs:dba
 IF (validate(cv_action,"notdefined") != "notdefined")
  CALL echo("cv_action record is already defined!")
 ELSE
  RECORD cv_action(
    1 action_list[*]
      2 pref_name = vc
      2 pref_section = vc
      2 pref_str = vc
      2 pref_id = f8
      2 pref_ind = i2
      2 pref_nbr = i4
      2 dataset_id = f8
  )
 ENDIF
 DECLARE stat = i4 WITH protect
 SET stat = alterlist(cv_action->action_list,19)
 SET cv_action->action_list[1].pref_name = "ACC02"
 SET cv_action->action_list[1].pref_section = "CV_FLAG_CTRL_ACC_OR_STS_ETC"
 SET cv_action->action_list[1].pref_str = "CV_FLAG_IN_SCRIPT_NAME"
 SET cv_action->action_list[1].pref_nbr = 1
 SET cv_action->action_list[2].pref_name = "STS"
 SET cv_action->action_list[2].pref_section = "CV_FLAG_CTRL_ACC_OR_STS_ETC"
 SET cv_action->action_list[2].pref_str = "CV_FLAG_IN_SCRIPT_NAME"
 SET cv_action->action_list[2].pref_nbr = 2
 SET cv_action->action_list[3].pref_name = "STS02"
 SET cv_action->action_list[3].pref_section = "CV_FLAG_CTRL_ACC_OR_STS_ETC"
 SET cv_action->action_list[3].pref_str = "CV_FLAG_IN_SCRIPT_NAME"
 SET cv_action->action_list[3].pref_nbr = 2
 SET cv_action->action_list[4].pref_name = "STS"
 SET cv_action->action_list[4].pref_section = "CV_INSERT_RECORD_COMPLETE_IN_FILE"
 SET cv_action->action_list[4].pref_str = "CV_GET_HARVEST_VALIDATE_STS"
 SET cv_action->action_list[4].pref_nbr = 1
 SET cv_action->action_list[5].pref_name = "STS02"
 SET cv_action->action_list[5].pref_section = "CV_REMOVE_RECORD_COMPLETE_IN_FILE"
 SET cv_action->action_list[5].pref_str = "CV_GET_HARVEST_VALIDATE_STS"
 SET cv_action->action_list[5].pref_nbr = 1
 SET cv_action->action_list[6].pref_name = "STS"
 SET cv_action->action_list[6].pref_section = "CV_EXECUTE_STS_IN_EXPORT"
 SET cv_action->action_list[6].pref_str = "CV_GET_HARVEST_EXPORT"
 SET cv_action->action_list[6].pref_nbr = 1
 SET cv_action->action_list[7].pref_name = "ACC02"
 SET cv_action->action_list[7].pref_section = "CV_EXECUTE_ACC_IN_EXPORT"
 SET cv_action->action_list[7].pref_str = "CV_GET_HARVEST_EXPORT"
 SET cv_action->action_list[7].pref_nbr = 1
 SET cv_action->action_list[8].pref_name = "STS02"
 SET cv_action->action_list[8].pref_section = "CV_EXECUTE_STS02_IN_EXPORT"
 SET cv_action->action_list[8].pref_str = "CV_GET_HARVEST_EXPORT"
 SET cv_action->action_list[8].pref_nbr = 1
 SET cv_action->action_list[9].pref_name = "STS"
 SET cv_action->action_list[9].pref_section = "CV_EXECUTE_ALGORITHM_IN_HARVEST"
 SET cv_action->action_list[9].pref_str = "CV_GET_HARVEST"
 SET cv_action->action_list[9].pref_nbr = 1
 SET cv_action->action_list[10].pref_name = "STS02"
 SET cv_action->action_list[10].pref_section = "CV_EXECUTE_ALGORITHM_IN_HARVEST"
 SET cv_action->action_list[10].pref_str = "CV_GET_HARVEST"
 SET cv_action->action_list[10].pref_nbr = 1
 SET cv_action->action_list[11].pref_name = "STS"
 SET cv_action->action_list[11].pref_section = "CV_EXPORT_BOTH_STS_FLAG"
 SET cv_action->action_list[11].pref_str = "CV_GET_HARVEST_EXPORT"
 SET cv_action->action_list[11].pref_nbr = 0
 SET cv_action->action_list[12].pref_name = "STS02"
 SET cv_action->action_list[12].pref_section = "CV_EXPORT_BOTH_STS2_FLAG"
 SET cv_action->action_list[12].pref_str = "CV_GET_HARVEST_EXPORT"
 SET cv_action->action_list[12].pref_nbr = 0
 SET cv_action->action_list[13].pref_name = "ACC03"
 SET cv_action->action_list[13].pref_section = "CV_FLAG_CTRL_ACC_OR_STS_ETC"
 SET cv_action->action_list[13].pref_str = "CV_FLAG_IN_SCRIPT_NAME"
 SET cv_action->action_list[13].pref_nbr = 1
 SET cv_action->action_list[14].pref_name = "ACC03"
 SET cv_action->action_list[14].pref_section = "CV_EXECUTE_ACC_IN_EXPORT"
 SET cv_action->action_list[14].pref_str = "CV_GET_HARVEST_EXPORT"
 SET cv_action->action_list[14].pref_nbr = 1
 SET cv_action->action_list[15].pref_name = "ACC03"
 SET cv_action->action_list[15].pref_section = "REGISTRY_VERSION"
 SET cv_action->action_list[15].pref_str = "CV_FLAG_IN_SCRIPT_NAME"
 SET cv_action->action_list[15].pref_nbr = 3
 SET cv_action->action_list[16].pref_name = "STS03"
 SET cv_action->action_list[16].pref_section = "CV_FLAG_CTRL_ACC_OR_STS_ETC"
 SET cv_action->action_list[16].pref_str = "CV_FLAG_IN_SCRIPT_NAME"
 SET cv_action->action_list[16].pref_nbr = 2
 SET cv_action->action_list[17].pref_name = "STS03"
 SET cv_action->action_list[17].pref_section = "CV_REMOVE_RECORD_COMPLETE_IN_FILE"
 SET cv_action->action_list[17].pref_str = "CV_GET_HARVEST_VALIDATE_STS"
 SET cv_action->action_list[17].pref_nbr = 1
 SET cv_action->action_list[18].pref_name = "STS03"
 SET cv_action->action_list[18].pref_section = "CV_EXECUTE_STS03_IN_EXPORT"
 SET cv_action->action_list[18].pref_str = "CV_GET_HARVEST_EXPORT"
 SET cv_action->action_list[18].pref_nbr = 1
 SET cv_action->action_list[19].pref_name = "STS03"
 SET cv_action->action_list[19].pref_section = "CV_EXECUTE_ALGORITHM_IN_HARVEST"
 SET cv_action->action_list[19].pref_str = "CV_GET_HARVEST"
 SET cv_action->action_list[19].pref_nbr = 1
 DECLARE ctrl_cnt = i4 WITH protect, constant(size(cv_action->action_list,5))
 DECLARE ctrl_idx = i4 WITH protect, noconstant(0)
 DECLARE pref_failed = c1 WITH protect, noconstant("T")
 DECLARE idx = i4 WITH protect
 DECLARE num = i4 WITH protect
 DECLARE index = i4 WITH protect
 IF (validate(request,"notdefined") != "notdefined")
  CALL echo("Request Record is already defined!")
 ELSE
  RECORD request(
    1 application_nbr = i4
    1 parent_entity_id = f8
    1 parent_entity_name = c32
    1 person_id = f8
    1 pref_cd = f8
    1 pref_domain = vc
    1 pref_dt_tm = dq8
    1 pref_id = f8
    1 pref_name = vc
    1 pref_nbr = i4
    1 pref_section = vc
    1 pref_str = vc
    1 reference_ind = i2
  )
 ENDIF
 SELECT INTO "nl:"
  FROM dm_prefs dp
  WHERE expand(idx,1,ctrl_cnt,dp.pref_section,cv_action->action_list[idx].pref_section,
   dp.pref_name,cv_action->action_list[idx].pref_name)
   AND dp.pref_domain="CVNET"
  DETAIL
   index = locateval(num,1,ctrl_cnt,dp.pref_section,cv_action->action_list[num].pref_section,
    dp.pref_name,cv_action->action_list[num].pref_name), cv_action->action_list[index].pref_ind = 1,
   cv_action->action_list[index].pref_id = dp.pref_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo("Previous records were sent for updating!")
 ELSE
  CALL echo("New records were sent for insertion!")
 ENDIF
 SELECT INTO "nl:"
  FROM cv_dataset cd
  WHERE expand(idx,1,ctrl_cnt,cd.dataset_internal_name,cv_action->action_list[idx].pref_name)
  DETAIL
   index = locateval(num,1,ctrl_cnt,cd.dataset_internal_name,cv_action->action_list[num].pref_name)
   WHILE (index > 0)
    cv_action->action_list[index].dataset_id = cd.dataset_id,index = locateval(num,(index+ 1),
     ctrl_cnt,cd.dataset_internal_name,cv_action->action_list[num].pref_name)
   ENDWHILE
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Dataset is not in cv_dataset table!")
 ENDIF
 CALL echorecord(cv_action)
 FOR (ctrl_idx = 1 TO ctrl_cnt)
   SET request->application_nbr = 4100522
   SET request->parent_entity_id = cv_action->action_list[ctrl_idx].dataset_id
   SET request->parent_entity_name = "CV_DATASET"
   SET request->pref_domain = "CVNET"
   SET request->pref_id = cv_action->action_list[ctrl_idx].pref_id
   SET request->pref_name = cv_action->action_list[ctrl_idx].pref_name
   SET request->pref_section = cv_action->action_list[ctrl_idx].pref_section
   SET request->pref_str = cv_action->action_list[ctrl_idx].pref_str
   SET request->pref_nbr = cv_action->action_list[ctrl_idx].pref_nbr
   SET request->pref_dt_tm = cnvtdatetime(curdate,curtime3)
   SET request->reference_ind = 1
   IF ((cv_action->action_list[ctrl_idx].pref_ind=0))
    EXECUTE dm_ins_dm_prefs
   ELSE
    EXECUTE dm_upd_dm_prefs
   ENDIF
 ENDFOR
 SET pref_failed = "F"
#exit_script
 IF (pref_failed="T")
  ROLLBACK
  CALL echo("No valid dataset found, exit without updating!")
 ELSE
  COMMIT
  CALL echo("DM_pref table has been updated and action commited!")
  FREE RECORD request
 ENDIF
 DECLARE cv_utl_add_dm_prefs_vrsn = vc WITH private, constant("MOD 005 06/30/06  MH9140")
END GO
