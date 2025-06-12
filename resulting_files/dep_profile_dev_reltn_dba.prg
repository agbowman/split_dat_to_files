CREATE PROGRAM dep_profile_dev_reltn:dba
 FREE RECORD profile_device_category_info
 RECORD profile_device_category_info(
   1 profile_device_reltn[*]
     2 profile_id = f8
     2 device_id = f8
     2 category_id = f8
 )
 SET readme_data->status = "F"
 SET readme_data->message = "Beginning readme to update dep_profile_dev_reltn"
 UPDATE  FROM dep_profile_dev_reltn dpdr
  SET dpdr.device_sync_status_cd = 7
  WHERE dpdr.device_sync_status_cd=0
   AND dpdr.device_status_cd=7
 ;end update
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_profile_dev_reltn UPDATE:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 UPDATE  FROM dep_profile_dev_reltn dpdr
  SET dpdr.device_sync_status_cd = 23
  WHERE dpdr.device_sync_status_cd=0
   AND dpdr.device_status_cd=23
 ;end update
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_profile_dev_reltn UPDATE:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 UPDATE  FROM dep_profile_dev_reltn dpdr
  SET dpdr.device_sync_status_cd = 5
  WHERE dpdr.device_sync_status_cd=0
   AND dpdr.device_status_cd=5
 ;end update
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_profile_dev_reltn UPDATE:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 UPDATE  FROM dep_profile_dev_reltn dpdr
  SET dpdr.device_sync_status_cd = 21
  WHERE dpdr.device_sync_status_cd=0
   AND dpdr.device_status_cd != 7
   AND dpdr.device_status_cd != 23
   AND dpdr.device_status_cd != 5
 ;end update
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_profile_dev_reltn UPDATE:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 SET stat = alterlist(profile_device_category_info->profile_device_reltn,0)
 SELECT INTO "nl:"
  dpdr.device_id, dpdr.profile_id, dp.category_id
  FROM dep_profile dp,
   dep_profile_dev_reltn dpdr
  WHERE dp.dep_env_id=dep_env_id
   AND dp.profile_id=dpdr.profile_id
   AND dpdr.category_id=0
  ORDER BY dp.description
  HEAD REPORT
   stat = alterlist(profile_device_category_info->profile_device_reltn,10), count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 > 10)
    stat = alterlist(profile_device_category_info->profile_device_reltn,(count1+ 9))
   ENDIF
   profile_device_category_info->profile_device_reltn[count1].category_id = dp.category_id,
   profile_device_category_info->profile_device_reltn[count1].device_id = dpdr.device_id,
   profile_device_category_info->profile_device_reltn[count1].profile_id = dpdr.profile_id
  FOOT REPORT
   stat = alterlist(profile_device_category_info->profile_device_reltn,count1)
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_profile_dev_reltn SELECT:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 UPDATE  FROM dep_profile_dev_reltn dpdr,
   (dummyt d1  WITH seq = value(size(profile_device_category_info->profile_device_reltn,5)))
  SET dpdr.category_id = cnvtreal(profile_device_category_info->profile_device_reltn[d1.seq].
    category_id)
  PLAN (d1)
   JOIN (dpdr
   WHERE dpdr.device_id=cnvtreal(profile_device_category_info->profile_device_reltn[d1.seq].device_id
    )
    AND dpdr.profile_id=cnvtreal(profile_device_category_info->profile_device_reltn[d1.seq].
    profile_id))
  WITH nocounter
 ;end update
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_profile_dev_reltn UPDATE:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "EUC dep_profile_dev_reltn list updated successfully"
#enditnow
 FREE RECORD profile_device_category_info
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
