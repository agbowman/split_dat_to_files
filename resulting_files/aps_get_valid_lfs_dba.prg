CREATE PROGRAM aps_get_valid_lfs:dba
 RECORD reply(
   1 lfs_qual[*]
     2 ucmr_layout_field_id = f8
     2 format_id = f8
     2 status_flag = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET active_status_code = uar_get_code_by("MEANING",48,"ACTIVE")
 SET inactive_status_code = uar_get_code_by("MEANING",48,"INACTIVE")
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM sign_line_layout_field_r slfr,
   ucmr_layout_field ulf,
   sign_line_format slf
  PLAN (slfr
   WHERE slfr.active_ind=1)
   JOIN (ulf
   WHERE ulf.ucmr_layout_field_id=slfr.ucmr_layout_field_id
    AND ulf.active_ind=1
    AND ((ulf.active_status_cd=active_status_code) OR (ulf.active_status_cd=inactive_status_code)) )
   JOIN (slf
   WHERE slf.format_id=slfr.format_id
    AND slf.active_ind=1)
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->lfs_qual,5)
  DETAIL
   cnt += 1
   IF (mod(cnt,5)=1
    AND cnt != 1)
    stat = alterlist(reply->lfs_qual,(cnt+ 4))
   ENDIF
   reply->lfs_qual[cnt].ucmr_layout_field_id = slfr.ucmr_layout_field_id, reply->lfs_qual[cnt].
   format_id = slfr.format_id, reply->lfs_qual[cnt].status_flag = slfr.status_flag
  FOOT REPORT
   stat = alterlist(reply->lfs_qual,cnt)
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->lfs_qual,0)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
