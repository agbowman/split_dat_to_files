CREATE PROGRAM cp_chg_time_format:dba
 SET failed = "F"
 SET pre_count = 0
 SET post_count = 0
 SELECT INTO "nl:"
  time_format_flag
  FROM chart_horz_format
  WHERE time_format_flag >= 0
   AND chart_group_id > 0.0
   AND time_mask IN (" ", null)
  WITH nocounter
 ;end select
 SET pre_count = curqual
 IF (pre_count > 0)
  UPDATE  FROM chart_horz_format
   SET time_mask = "HH:mm"
   WHERE time_format_flag=0
    AND chart_group_id > 0.0
    AND time_mask IN (" ", null)
  ;end update
  SET post_count = curqual
  UPDATE  FROM chart_horz_format
   SET time_mask = "hh:mmtt"
   WHERE time_format_flag=1
    AND chart_group_id > 0.0
    AND time_mask IN (" ", null)
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_horz_format
   SET time_mask = "HHmm"
   WHERE time_format_flag=2
    AND chart_group_id > 0.0
    AND time_mask IN (" ", null)
  ;end update
  SET post_count += curqual
  IF (post_count < pre_count)
   CALL echo("Failed in update chart_horz_format!")
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  time_format_flag
  FROM chart_vert_format
  WHERE time_format_flag >= 0
   AND chart_group_id > 0.0
   AND time_mask IN (" ", null)
  WITH nocounter
 ;end select
 SET pre_count = curqual
 IF (pre_count > 0)
  UPDATE  FROM chart_vert_format
   SET time_mask = "HH:mm"
   WHERE time_format_flag=0
    AND chart_group_id > 0.0
    AND time_mask IN (" ", null)
  ;end update
  SET post_count = curqual
  UPDATE  FROM chart_vert_format
   SET time_mask = "hh:mmtt"
   WHERE time_format_flag=1
    AND chart_group_id > 0.0
    AND time_mask IN (" ", null)
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_vert_format
   SET time_mask = "HHmm"
   WHERE time_format_flag=2
    AND chart_group_id > 0.0
    AND time_mask IN (" ", null)
  ;end update
  SET post_count += curqual
  IF (post_count < pre_count)
   CALL echo("Failed in update chart_vert_format!")
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  time_format_flag
  FROM chart_zonal_format
  WHERE time_format_flag >= 0
   AND chart_group_id > 0.0
   AND time_mask IN (" ", null)
  WITH nocounter
 ;end select
 SET pre_count = curqual
 IF (pre_count > 0)
  UPDATE  FROM chart_zonal_format
   SET time_mask = "HH:mm"
   WHERE time_format_flag=0
    AND chart_group_id > 0.0
    AND time_mask IN (" ", null)
  ;end update
  SET post_count = curqual
  UPDATE  FROM chart_zonal_format
   SET time_mask = "hh:mmtt"
   WHERE time_format_flag=1
    AND chart_group_id > 0.0
    AND time_mask IN (" ", null)
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_zonal_format
   SET time_mask = "HHmm"
   WHERE time_format_flag=2
    AND chart_group_id > 0.0
    AND time_mask IN (" ", null)
  ;end update
  SET post_count += curqual
  IF (post_count < pre_count)
   CALL echo("Filed in update chart_zonal_format!")
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT DISTINCT INTO "nl:"
  chart_format_id
  FROM chart_format
  WHERE chart_format_id > 0.0
   AND time_mask IN (" ", null)
  WITH nocounter
 ;end select
 SET pre_count = curqual
 IF (pre_count > 0)
  UPDATE  FROM chart_format
   SET time_mask = "HH:mm:ss"
   WHERE chart_format_id > 0.0
    AND time_mask IN (" ", null)
  ;end update
  SET post_count = curqual
  IF (post_count < pre_count)
   CALL echo("Failed in update chart_format!")
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="F")
  CALL echo("Successful!")
  COMMIT
 ELSE
  CALL echo("Failed!")
  ROLLBACK
 ENDIF
END GO
