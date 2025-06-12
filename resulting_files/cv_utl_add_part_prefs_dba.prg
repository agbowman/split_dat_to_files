CREATE PROGRAM cv_utl_add_part_prefs:dba
 PROMPT
  "Dataset[ACC03] =" = "ACC03",
  "Participant Number =" = "",
  "Participant Name =" = ""
  WITH dataset_name, part_number, participant
 DECLARE part_str = vc WITH protect, constant(trim( $PART_NUMBER))
 DECLARE part_nbr = i4 WITH protect, constant(cnvtint(part_str))
 DECLARE part_name = vc WITH protect, constant(trim( $PARTICIPANT))
 DECLARE ds_id = f8 WITH noconstant(0.0), protect
 DECLARE pref_failed = c1 WITH private, noconstant("T")
 DECLARE idx = i4 WITH protect
 DECLARE num = i4 WITH protect
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
 IF (part_nbr=0)
  CALL echo("Participant number must be non-zero")
  GO TO exit_script
 ENDIF
 IF (part_name="")
  CALL echo("Participant name must be filled out")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM cv_dataset cd
  WHERE cd.dataset_internal_name=trim( $DATASET_NAME,3)
  DETAIL
   ds_id = cd.dataset_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Dataset is not in cv_dataset table!")
  GO TO exit_script
 ENDIF
 SET stat = alterlist(cv_action->action_list,3)
 SET cv_action->action_list[1].pref_section = "MINIMUM_DATA_SET"
 SET cv_action->action_list[1].pref_str = "N"
 SET cv_action->action_list[2].pref_section = "ADMIN_FILE_ROW"
 SET cv_action->action_list[2].pref_str = build("|",trim(part_name),
  "|<TIMEFRAM>|CERNCORP|8.1|3.04|<MDS>")
 SET cv_action->action_list[3].pref_section = "EXPORT_PASSWORD"
 SET cv_action->action_list[3].pref_str = "Missing"
 DECLARE ctrl_cnt = i4 WITH private, noconstant(size(cv_action->action_list,5))
 DECLARE ctrl_idx = i4 WITH private, noconstant(0)
 FOR (ctrl_idx = 1 TO ctrl_cnt)
   SET cv_action->action_list[ctrl_idx].dataset_id = ds_id
   SET cv_action->action_list[ctrl_idx].pref_name = part_str
   SET cv_action->action_list[ctrl_idx].pref_nbr = part_nbr
 ENDFOR
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
  WHERE dp.pref_domain="CVNET"
   AND expand(idx,1,ctrl_cnt,dp.pref_section,cv_action->action_list[idx].pref_section,
   dp.pref_name,cv_action->action_list[idx].pref_name)
  DETAIL
   num = locateval(idx,1,ctrl_cnt,dp.pref_section,cv_action->action_list[idx].pref_section,
    dp.pref_name,cv_action->action_list[idx].pref_name), cv_action->action_list[num].pref_ind = 1,
   cv_action->action_list[num].pref_id = dp.pref_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo("Previous records were sent for updating!")
 ELSE
  CALL echo("New records were sent for insertion!")
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
 DECLARE cv_utl_add_part_prefs_vrsn = vc WITH private, constant("MOD 001 BM9013 02/24/06")
END GO
