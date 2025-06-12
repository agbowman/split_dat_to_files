CREATE PROGRAM cv_run_harvest_verification:dba
 PROMPT
  "Enter DATASET NAME ( Enter STS for STS 2.35 or STS02 for STS 2.41 data )[STS] = " = "STS",
  "Enter SEASON of the harvest for ( S for Speing, F for Fall )[F] = " = "F",
  "Enter YEAR of the harvest for ( 2002 )[CURRENT_YEAR] = " = "CURRENT_YEAR",
  "Enter PARTICIPANT NUMBER ( Assigned by STS )[*] = " = "*"
 RECORD request(
   1 dataset_id = f8
   1 part_nbr = vc
   1 loc_facility_cd = f8
   1 from_date_str = vc
   1 to_date_str = vc
   1 start_dt = dq8
   1 stop_dt = dq8
   1 date_cd = f8
   1 file_type_ind = i2
   1 status_type_ind = i2
   1 organization_id = f8
   1 ops_date = dq8
   1 batch_selection = vc
   1 output_dest = vc
   1 dataset_mode_num = i2
 )
 RECORD date_range(
   1 rec[*]
     2 from_date = dq8
     2 to_date = dq8
 )
 DECLARE call_from_user = i2
 DECLARE dataset_param = vc
 SET dataset_param = trim(cnvtupper( $1),3)
 DECLARE season = c1
 SET season = trim(cnvtupper( $2),3)
 DECLARE cur_yr_in = c12
 SET cur_yr_in = trim(cnvtupper( $3),3)
 DECLARE cur_yr = i4
 DECLARE verify_driver_failed = c1
 SET verify_driver_failed = "F"
 SELECT INTO "nl:"
  *
  FROM cv_dataset cd
  WHERE trim(cnvtupper(cd.dataset_internal_name),3)=dataset_param
  DETAIL
   request->dataset_id = cd.dataset_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Dataset name not found!")
  SET verify_driver_failed = "T"
  GO TO exit_script
 ENDIF
 IF ( NOT (season IN ("S", "F")))
  CALL echo("Season entry incorrect!")
  SET verify_driver_failed = "T"
  GO TO exit_script
 ENDIF
 IF (cur_yr_in="CURRENT_YEAR")
  SET cur_yr = 0
 ELSEIF (size(cur_yr_in,1)=4)
  SET cur_yr = cnvtint(cur_yr_in)
 ENDIF
 SET request->part_nbr = trim(cnvtupper( $4),3)
 SET request->date_cd = 0
 SET request->loc_facility_cd = 0
 SET request->file_type_ind = 1
 SET request->status_type_ind = 1
 EXECUTE cv_get_harvest_verification
#exit_script
 IF (verify_driver_failed="T")
  SET reqinfo->commit_ind = 0
  CALL echo("Type 'cv_harvest_verify_driver go' to try again")
 ELSE
  SET reqinfo->commit_ind = 1
  CALL echo("Script executed successfully!")
 ENDIF
END GO
