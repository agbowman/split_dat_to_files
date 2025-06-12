CREATE PROGRAM aps_get_signline_lfs
 SET modify = predeclare
 SET active_status_code = uar_get_code_by("MEANING",48,"ACTIVE")
 SET inactive_status_code = uar_get_code_by("MEANING",48,"INACTIVE")
 DECLARE ncount = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 RECORD reply(
   1 layout_fields[*]
     2 ucmr_layout_field_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF ((request->status_flag < 0))
  SELECT INTO "nl:"
   FROM sign_line_layout_field_r slfr,
    ucmr_layout_field ulf,
    sign_line_format slf
   PLAN (slfr
    WHERE (slfr.format_id=request->format_id)
     AND slfr.active_ind=1)
    JOIN (ulf
    WHERE ulf.ucmr_layout_field_id=slfr.ucmr_layout_field_id
     AND ulf.active_ind=1
     AND ((ulf.active_status_cd=active_status_code) OR (ulf.active_status_cd=inactive_status_code)) )
    JOIN (slf
    WHERE slf.format_id=slfr.format_id
     AND slf.active_ind=1)
   HEAD REPORT
    stat = alterlist(reply->layout_fields,10)
   DETAIL
    ncount += 1
    IF (mod(ncount,10)=1
     AND ncount != 1)
     stat = alterlist(reply->layout_fields,(ncount+ 9))
    ENDIF
    reply->layout_fields[ncount].ucmr_layout_field_id = slfr.ucmr_layout_field_id
   FOOT REPORT
    stat = alterlist(reply->layout_fields,ncount)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   SET stat = alterlist(reply->layout_fields,0)
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM sign_line_layout_field_r slfr,
    ucmr_layout_field ulf,
    sign_line_format slf
   PLAN (slfr
    WHERE (slfr.status_flag=request->status_flag)
     AND (slfr.format_id=request->format_id)
     AND slfr.active_ind=1)
    JOIN (ulf
    WHERE ulf.ucmr_layout_field_id=slfr.ucmr_layout_field_id
     AND ulf.active_ind=1
     AND ((ulf.active_status_cd=active_status_code) OR (ulf.active_status_cd=inactive_status_code)) )
    JOIN (slf
    WHERE slf.format_id=slfr.format_id
     AND slf.active_ind=1)
   HEAD REPORT
    stat = alterlist(reply->layout_fields,10)
   DETAIL
    ncount += 1
    IF (mod(ncount,10)=1
     AND ncount != 1)
     stat = alterlist(reply->layout_fields,(ncount+ 9))
    ENDIF
    reply->layout_fields[ncount].ucmr_layout_field_id = slfr.ucmr_layout_field_id
   FOOT REPORT
    stat = alterlist(reply->layout_fields,ncount)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   SET stat = alterlist(reply->layout_fields,0)
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
