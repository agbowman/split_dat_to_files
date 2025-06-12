CREATE PROGRAM dm_rdm_upd_ivset_parent:dba
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
 SET readme_data->message = "Readme failed: starting script dm_rdm_upd_ivset_parent"
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE syspkgtyp = f8 WITH protect, noconstant(0)
 DECLARE dispense = f8 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 RECORD ivsets(
   1 setlist[*]
     2 itemid = f8
     2 med_dispense_id = f8
 )
 SELECT INTO "n1:"
  FROM code_value cv
  WHERE cv.code_set=4062
   AND cv.cdf_meaning="SYSPKGTYP"
  DETAIL
   syspkgtyp = cv.code_value
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("No code value found for system package type ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "n1:"
  FROM code_value cv
  WHERE cv.code_set=4063
   AND cv.cdf_meaning="DISPENSE"
  DETAIL
   dispense = cv.code_value
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("No code value found for dispense ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM medication_definition md,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_dispense mdisp
  PLAN (md
   WHERE md.med_type_flag=3)
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.sequence=0
    AND mdf.flex_type_cd=syspkgtyp)
   JOIN (mfoi
   WHERE mdf.med_def_flex_id=mfoi.med_def_flex_id
    AND mfoi.flex_object_type_cd=dispense)
   JOIN (mdisp
   WHERE mdisp.med_dispense_id=mfoi.parent_entity_id
    AND ((mdisp.strength > 0) OR (((mdisp.strength_unit_cd > 0) OR (((mdisp.volume > 0) OR (mdisp
   .volume_unit_cd > 0)) )) )) )
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1, stat = alterlist(ivsets->setlist,cnt), ivsets->setlist[cnt].itemid = md.item_id,
   ivsets->setlist[cnt].med_dispense_id = mdisp.med_dispense_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("No records found to update IV set parent items ",errmsg)
  GO TO exit_script
 ENDIF
 CALL echorecord(ivsets)
 IF (value(size(ivsets->setlist,5)) > 0)
  UPDATE  FROM med_dispense md,
    (dummyt d  WITH seq = value(size(ivsets->setlist,5)))
   SET md.volume = 0, md.volume_unit_cd = 0, md.strength = 0,
    md.strength_unit_cd = 0, md.med_filter_ind = 0
   PLAN (d)
    JOIN (md
    WHERE (md.med_dispense_id=ivsets->setlist[d.seq].med_dispense_id))
   WITH nocounter
  ;end update
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to update the IV set parent items ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
   SET readme_data->status = "S"
   SET readme_data->message = "Success: Readme performed all required IV set parent items"
  ENDIF
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "No IV set parent items found to update"
  GO TO exit_script
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
