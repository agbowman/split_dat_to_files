CREATE PROGRAM cv_utl_upd_dm_prefs_ssn:dba
 PROMPT
  "Enter Dataset Name:(e.g. ACC02, STS, STS02)[ACC02] = " = "ACC02",
  "Enter Action Name:(e.g. SSN)[SSN-REPLACE] = " = "SSN-REPLACE",
  "Enter Action Indicator (e.g. PERSON_ID On=1, Off=0 [1] = " = "1"
 DECLARE ctrl_idx = i4 WITH private, noconstant(0)
 DECLARE pref_failed = c1 WITH private, noconstant("T")
 DECLARE stat = i4 WITH protect
 IF (((trim(cnvtupper( $1))=" ") OR (((trim(cnvtupper( $2))=" ") OR (trim(cnvtupper( $2))=" ")) )) )
  CALL echo("******************************************")
  CALL echo("Blank is invalid entry, run program again!")
  CALL echo("******************************************")
  GO TO exit_script
 ENDIF
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
      2 pref_nbr = i2
      2 dataset_id = f8
  )
 ENDIF
 SET stat = alterlist(cv_action->action_list,1)
 SET cv_action->action_list[1].pref_name = trim(cnvtupper( $1))
 SET cv_action->action_list[1].pref_section = trim(cnvtupper( $2))
 SET cv_action->action_list[1].pref_str = "CV_HARVEST_CONTROLLER"
 SET cv_action->action_list[1].pref_nbr = cnvtint(trim(cnvtupper( $3)))
 DECLARE ctrl_cnt = i4 WITH private, constant(size(cv_action->action_list,5))
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
 DECLARE cvnet_cnst = c25 WITH protect, constant("CVNET")
 SELECT INTO "nl:"
  FROM dm_prefs dp,
   (dummyt d  WITH seq = value(ctrl_cnt))
  PLAN (d)
   JOIN (dp
   WHERE dp.pref_domain=cvnet_cnst
    AND dp.pref_section=trim(cnvtupper(cv_action->action_list[d.seq].pref_section),3)
    AND dp.pref_name=trim(cnvtupper(cv_action->action_list[d.seq].pref_name),3))
  DETAIL
   cv_action->action_list[d.seq].pref_ind = 1, cv_action->action_list[d.seq].pref_id = dp.pref_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo("Previous records were sent for updating!")
 ELSE
  CALL echo("New records were sent for insertion!")
 ENDIF
 SELECT INTO "nl:"
  FROM cv_dataset cd,
   (dummyt d  WITH seq = value(size(cv_action->action_list,5)))
  PLAN (d)
   JOIN (cd
   WHERE cd.dataset_internal_name=trim(cnvtupper(cv_action->action_list[d.seq].pref_name)))
  DETAIL
   cv_action->action_list[d.seq].dataset_id = cd.dataset_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Dataset is not in cv_dataset table!")
  GO TO exit_script
 ENDIF
 CALL echorecord(cv_action)
 FOR (ctrl_idx = 1 TO ctrl_cnt)
   SET request->application_nbr = cv_action->action_list[ctrl_idx].dataset_id
   SET request->parent_entity_id = cv_action->action_list[ctrl_idx].dataset_id
   SET request->parent_entity_name = "CV_DATASET"
   SET request->pref_domain = "CVNET"
   SET request->pref_id = cv_action->action_list[ctrl_idx].pref_id
   SET request->pref_name = trim(cnvtupper(cv_action->action_list[ctrl_idx].pref_name),3)
   SET request->pref_section = trim(cnvtupper(cv_action->action_list[ctrl_idx].pref_section),3)
   SET request->pref_str = trim(cnvtupper(cv_action->action_list[ctrl_idx].pref_str),3)
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
 DECLARE cv_ut_upd_dm_prefs_ssn_vrsn = vc WITH private, constant("MOD 00? 05/31/06 BM9013")
END GO
