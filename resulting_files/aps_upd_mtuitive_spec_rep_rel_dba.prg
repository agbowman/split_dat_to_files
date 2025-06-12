CREATE PROGRAM aps_upd_mtuitive_spec_rep_rel:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 ckisrc = vc
     2 old_ckiidentifier = vc
     2 new_ckiidentifier = vc
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET errmsg = fillstring(132," ")
 DECLARE ep_iter = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  qual_new_ckiidentifier = substring(1,30,request->qual[d1.seq].new_ckiidentifier), qual_ckisrc =
  substring(1,30,request->qual[d1.seq].ckisrc)
  FROM (dummyt d1  WITH seq = size(request->qual,5)),
   scr_pattern s
  PLAN (d1)
   JOIN (s
   WHERE (s.cki_identifier=request->qual[d1.seq].new_ckiidentifier)
    AND (s.cki_source=request->qual[d1.seq].ckisrc))
  ORDER BY d1.seq
  HEAD REPORT
   ep_iter = 0
  HEAD d1.seq
   ep_iter += 1
   IF (mod(ep_iter,10)=1)
    stat = alterlist(temp->qual,(ep_iter+ 9))
   ENDIF
   temp->qual[ep_iter].old_ckiidentifier = request->qual[d1.seq].old_ckiidentifier, temp->qual[
   ep_iter].ckisrc = request->qual[d1.seq].ckisrc, temp->qual[ep_iter].new_ckiidentifier = request->
   qual[d1.seq].new_ckiidentifier
  FOOT REPORT
   stat = alterlist(temp->qual,ep_iter)
  WITH nocounter, separator = " ", format
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM ap_synoptic_spec_prefix_r ap,
   (dummyt d  WITH seq = size(temp->qual,5))
  PLAN (d)
   JOIN (ap
   WHERE (ap.cki_identifier=temp->qual[d.seq].old_ckiidentifier)
    AND (ap.cki_source=temp->qual[d.seq].ckisrc))
  WITH nocounter, forupdatewait(ap)
 ;end select
 IF (error(errmsg,0) != 0)
  CALL handle_errors("LOCK","F","TABLE","AP_SYNOPTIC_SPEC_PREFIX_R")
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  GO TO update_ckiid_rpt_section
 ENDIF
 UPDATE  FROM ap_synoptic_spec_prefix_r ap,
   (dummyt d  WITH seq = size(temp->qual,5))
  SET ap.cki_identifier = temp->qual[d.seq].new_ckiidentifier, ap.updt_dt_tm = cnvtdatetime(sysdate),
   ap.updt_cnt = (ap.updt_cnt+ 1),
   ap.updt_applctx = reqinfo->updt_applctx, ap.updt_task = reqinfo->updt_task, ap.updt_id = reqinfo->
   updt_id
  PLAN (d)
   JOIN (ap
   WHERE (ap.cki_identifier=temp->qual[d.seq].old_ckiidentifier)
    AND (ap.cki_source=temp->qual[d.seq].ckisrc))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) != 0)
  CALL handle_errors("UPDATE","F","TABLE","AP_SYNOPTIC_SPEC_PREFIX_R")
  GO TO exit_script
 ENDIF
#update_ckiid_rpt_section
 SELECT INTO "nl:"
  FROM ap_synoptic_rpt_section_r ap,
   (dummyt d  WITH seq = size(temp->qual,5))
  PLAN (d)
   JOIN (ap
   WHERE (ap.cki_identifier=temp->qual[d.seq].old_ckiidentifier)
    AND (ap.cki_source=temp->qual[d.seq].ckisrc))
  WITH nocounter, forupdatewait(ap)
 ;end select
 IF (error(errmsg,0) != 0)
  CALL handle_errors("LOCK","F","TABLE","AP_SYNOPTIC_RPT_SECTION_R")
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 UPDATE  FROM ap_synoptic_rpt_section_r ap,
   (dummyt d  WITH seq = size(temp->qual,5))
  SET ap.cki_identifier = temp->qual[d.seq].new_ckiidentifier, ap.updt_dt_tm = cnvtdatetime(sysdate),
   ap.updt_cnt = (ap.updt_cnt+ 1),
   ap.updt_applctx = reqinfo->updt_applctx, ap.updt_task = reqinfo->updt_task, ap.updt_id = reqinfo->
   updt_id
  PLAN (d)
   JOIN (ap
   WHERE (ap.cki_identifier=temp->qual[d.seq].old_ckiidentifier)
    AND (ap.cki_source=temp->qual[d.seq].ckisrc))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) != 0)
  CALL handle_errors("UPDATE","F","TABLE","AP_SYNOPTIC_RPT_SECTION_R")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ENDIF
 SUBROUTINE (handle_errors(op_name=c25,op_status=c1,tar_name=c25,tar_value=vc) =null)
   SET reply->status_data.subeventstatus[1].operationname = op_name
   SET reply->status_data.subeventstatus[1].operationstatus = op_status
   SET reply->status_data.subeventstatus[1].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[1].targetobjectvalue = tar_value
 END ;Subroutine
END GO
