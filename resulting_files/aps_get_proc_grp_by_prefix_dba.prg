CREATE PROGRAM aps_get_proc_grp_by_prefix:dba
 RECORD reply(
   1 prefix_association_list[*]
     2 ap_prefix_proc_grp_r_id = f8
     2 processing_grp_cd = f8
     2 processing_grp_disp = c40
     2 processing_grp_desc = c60
     2 prefix_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ncount = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  apg.*, cv.code_value
  FROM ap_prefix_proc_grp_r apg,
   code_value cv
  PLAN (apg
   WHERE (apg.prefix_id=request->prefix_id))
   JOIN (cv
   WHERE cv.code_value=apg.processing_grp_cd
    AND cv.active_ind=1)
  DETAIL
   ncount += 1
   IF (ncount > size(reply->prefix_association_list,5))
    stat = alterlist(reply->prefix_association_list,(ncount+ 9))
   ENDIF
   reply->prefix_association_list[ncount].ap_prefix_proc_grp_r_id = apg.ap_prefix_proc_grp_r_id,
   reply->prefix_association_list[ncount].processing_grp_cd = apg.processing_grp_cd, reply->
   prefix_association_list[ncount].prefix_id = apg.prefix_id
  FOOT REPORT
   stat = alterlist(reply->prefix_association_list,ncount)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PREFIX_PROC_GRP_R"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
