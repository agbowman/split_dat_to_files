CREATE PROGRAM cv_chk_sts_xref_field:dba
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
 DECLARE second_readme_type = vc WITH private, constant("CV_CHK_STS_XREF_FIELD_UPDATE")
 DECLARE type_b_ds_id = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  cd.dataset_id
  FROM cv_dataset cd
  WHERE cd.dataset_internal_name="STS"
  DETAIL
   type_b_ds_id = cd.dataset_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->message = concat(second_readme_type," Readme Successful. ",
   " No need updating cv_xref_field.")
  SET readme_data->status = "S"
  EXECUTE dm_readme_status
 ELSE
  EXECUTE cv_chk_xref_field
 ENDIF
 COMMIT
END GO
