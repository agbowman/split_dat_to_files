CREATE PROGRAM cp_chg_date_format:dba
 SET failed = "F"
 SET pre_count = 0
 SET post_count = 0
 SELECT INTO "nl:"
  date_format_cd
  FROM chart_horz_format
  WHERE date_format_cd >= 0
   AND chart_group_id > 0
   AND date_mask IN (" ", null)
  WITH nocounter
 ;end select
 SET pre_count = curqual
 IF (pre_count > 0)
  UPDATE  FROM chart_horz_format
   SET date_mask = "yyMMdd"
   WHERE date_format_cd=0
    AND chart_group_id > 0
    AND date_mask IN (" ", null)
  ;end update
  SET post_count = curqual
  UPDATE  FROM chart_horz_format
   SET date_mask = "ddMMyy"
   WHERE date_format_cd=1
    AND chart_group_id > 0
    AND date_mask IN (" ", null)
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_horz_format
   SET date_mask = "MM/dd/yy"
   WHERE date_format_cd=2
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_horz_format
   SET date_mask = "ddMMyyyy"
   WHERE date_format_cd=3
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_horz_format
   SET date_mask = "MM/dd/yyyy"
   WHERE date_format_cd=4
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_horz_format
   SET date_mask = "ddMMMyy"
   WHERE date_format_cd=5
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_horz_format
   SET date_mask = "ddMMMyyyy"
   WHERE date_format_cd=6
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_horz_format
   SET date_mask = "yyyy/MM/dd"
   WHERE date_format_cd=7
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  IF (post_count < pre_count)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  date_format_cd
  FROM chart_vert_format
  WHERE date_format_cd >= 0
   AND date_mask IN (" ", null)
   AND chart_group_id > 0
  WITH nocounter
 ;end select
 SET pre_count = curqual
 IF (pre_count > 0)
  UPDATE  FROM chart_vert_format
   SET date_mask = "yyMMdd"
   WHERE date_format_cd=0
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count = curqual
  UPDATE  FROM chart_vert_format
   SET date_mask = "ddMMyy"
   WHERE date_format_cd=1
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_vert_format
   SET date_mask = "MM/dd/yy"
   WHERE date_format_cd=2
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_vert_format
   SET date_mask = "ddMMyyyy"
   WHERE date_format_cd=3
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_vert_format
   SET date_mask = "MM/dd/yyyy"
   WHERE date_format_cd=4
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_vert_format
   SET date_mask = "ddMMMyy"
   WHERE date_format_cd=5
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_vert_format
   SET date_mask = "ddMMMyyyy"
   WHERE date_format_cd=6
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_vert_format
   SET date_mask = "yyyy/MM/dd"
   WHERE date_format_cd=7
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  IF (post_count < pre_count)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  date_format_cd
  FROM chart_zonal_format
  WHERE date_format_cd >= 0
   AND date_mask IN (" ", null)
   AND chart_group_id > 0
  WITH nocounter
 ;end select
 SET pre_count = curqual
 IF (pre_count > 0)
  UPDATE  FROM chart_zonal_format
   SET date_mask = "yyMMdd"
   WHERE date_format_cd=0
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count = curqual
  UPDATE  FROM chart_zonal_format
   SET date_mask = "ddMMyy"
   WHERE date_format_cd=1
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_zonal_format
   SET date_mask = "MM/dd/yy"
   WHERE date_format_cd=2
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_zonal_format
   SET date_mask = "ddMMyyyy"
   WHERE date_format_cd=3
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_zonal_format
   SET date_mask = "MM/dd/yyyy"
   WHERE date_format_cd=4
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_zonal_format
   SET date_mask = "ddMMMyy"
   WHERE date_format_cd=5
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_zonal_format
   SET date_mask = "ddMMMyyyy"
   WHERE date_format_cd=6
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  UPDATE  FROM chart_zonal_format
   SET date_mask = "yyyy/MM/dd"
   WHERE date_format_cd=7
    AND date_mask IN (" ", null)
    AND chart_group_id > 0
  ;end update
  SET post_count += curqual
  IF (post_count < pre_count)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT DISTINCT INTO "nl:"
  chart_format_id
  FROM chart_format
  WHERE date_mask IN (" ", null)
   AND chart_format_id > 0
  WITH nocounter
 ;end select
 SET pre_count = curqual
 IF (pre_count > 0)
  UPDATE  FROM chart_format
   SET date_mask = "MM/dd/yy"
   WHERE date_mask IN (" ", null)
    AND chart_format_id > 0
  ;end update
  SET post_count = curqual
  IF (post_count < pre_count)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="F")
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
