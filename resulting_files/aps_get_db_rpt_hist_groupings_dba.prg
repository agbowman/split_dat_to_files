CREATE PROGRAM aps_get_db_rpt_hist_groupings:dba
 RECORD reply(
   1 qual[5]
     2 grouping_cd = f8
     2 grouping_desc = c40
     2 updt_cnt = i4
     2 det_cnt = i4
     2 det_qual[5]
       3 task_assay_cd = f8
       3 collating_seq = i4
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET grp_cnt = 00000
 SET det_cnt = 00000
 SET max_det_cnt = 00000
 SELECT INTO "nl:"
  rhgr.task_assay_cd, rhgr.grouping_cd, c.code_value,
  c.display, c.updt_cnt
  FROM report_history_grouping_r rhgr,
   code_value c
  PLAN (c
   WHERE c.code_set=1311)
   JOIN (rhgr
   WHERE c.code_value=rhgr.grouping_cd)
  ORDER BY rhgr.grouping_cd
  HEAD rhgr.grouping_cd
   det_cnt = 0, grp_cnt = (grp_cnt+ 1)
   IF (mod(grp_cnt,5)=1
    AND grp_cnt != 1)
    stat = alter(reply->qual,(grp_cnt+ 4))
   ENDIF
   reply->qual[grp_cnt].grouping_cd = c.code_value, reply->qual[grp_cnt].grouping_desc = c.display,
   reply->qual[grp_cnt].updt_cnt = c.updt_cnt
  DETAIL
   det_cnt = (det_cnt+ 1)
   IF (det_cnt > max_det_cnt)
    max_det_cnt = det_cnt
    IF (mod(max_det_cnt,5)=1
     AND max_det_cnt != 1)
     stat = alter(reply->qual.det_qual,(max_det_cnt+ 4))
    ENDIF
   ENDIF
   reply->qual[grp_cnt].det_qual[det_cnt].task_assay_cd = rhgr.task_assay_cd, reply->qual[grp_cnt].
   det_qual[det_cnt].collating_seq = rhgr.collating_seq, reply->qual[grp_cnt].det_qual[det_cnt].
   updt_cnt = rhgr.updt_cnt,
   reply->qual[grp_cnt].det_cnt = det_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT_HISTORY_GROUPING_R"
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  IF (grp_cnt != 5)
   SET stat = alter(reply->qual,grp_cnt)
  ENDIF
  IF (max_det_cnt != 5)
   SET stat = alter(reply->qual.det_qual,max_det_cnt)
  ENDIF
 ENDIF
END GO
