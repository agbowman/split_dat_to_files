CREATE PROGRAM aps_get_case_specimens:dba
 RECORD reply(
   1 specimen_qual[*]
     2 case_specimen_id = f8
     2 specimen_tag_group_cd = f8
     2 specimen_tag_cd = f8
     2 specimen_description = vc
     2 specimen_tag_display = c7
     2 specimen_tag_sequence = i4
     2 specimen_cd = f8
     2 specimen_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET spec_cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cs.case_specimen, at.tag_id, at.tag_sequence
  FROM case_specimen cs,
   ap_tag at
  PLAN (cs
   WHERE (cs.case_id=request->case_id))
   JOIN (at
   WHERE cs.specimen_tag_id=at.tag_id)
  ORDER BY at.tag_sequence
  HEAD REPORT
   spec_cnt = 0, stat = alterlist(reply->specimen_qual,10)
  DETAIL
   spec_cnt = (spec_cnt+ 1)
   IF (mod(spec_cnt,10)=1)
    stat = alterlist(reply->specimen_qual,(spec_cnt+ 9))
   ENDIF
   reply->specimen_qual[spec_cnt].case_specimen_id = cs.case_specimen_id, reply->specimen_qual[
   spec_cnt].specimen_tag_group_cd = at.tag_group_id, reply->specimen_qual[spec_cnt].specimen_tag_cd
    = cs.specimen_tag_id,
   reply->specimen_qual[spec_cnt].specimen_description = trim(cs.specimen_description), reply->
   specimen_qual[spec_cnt].specimen_tag_display = at.tag_disp, reply->specimen_qual[spec_cnt].
   specimen_tag_sequence = at.tag_sequence,
   reply->specimen_qual[spec_cnt].specimen_cd = cs.specimen_cd
  FOOT REPORT
   stat = alterlist(reply->specimen_qual,spec_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_SPECIMEN"
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
