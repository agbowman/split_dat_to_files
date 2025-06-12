CREATE PROGRAM dcp_get_event_cd_r:dba
 RECORD reply(
   1 qual[*]
     2 event_cd = f8
     2 event_cd_disp = vc
     2 flex1_cd = f8
     2 flex2_cd = f8
     2 flex3_cd = f8
     2 flex4_cd = f8
     2 flex5_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET qual_cnt = size(request->qual,5)
 SET stat = alterlist(reply->qual,qual_cnt)
 SELECT INTO "nl:"
  cer.event_cd, v.event_cd
  FROM (dummyt d1  WITH seq = value(qual_cnt)),
   code_value_event_r cer,
   v500_event_code v
  PLAN (d1)
   JOIN (cer
   WHERE (cer.parent_cd=request->qual[d1.seq].parent_cd)
    AND (cer.flex1_cd=request->qual[d1.seq].flex1_cd)
    AND (cer.flex2_cd=request->qual[d1.seq].flex2_cd)
    AND (cer.flex3_cd=request->qual[d1.seq].flex3_cd)
    AND (cer.flex4_cd=request->qual[d1.seq].flex4_cd)
    AND (cer.flex5_cd=request->qual[d1.seq].flex5_cd))
   JOIN (v
   WHERE v.event_cd=cer.event_cd)
  DETAIL
   reply->qual[d1.seq].event_cd = cer.event_cd, reply->qual[d1.seq].event_cd_disp = v.event_cd_disp,
   reply->qual[d1.seq].flex1_cd = cer.flex1_cd,
   reply->qual[d1.seq].flex2_cd = cer.flex2_cd, reply->qual[d1.seq].flex3_cd = cer.flex3_cd, reply->
   qual[d1.seq].flex4_cd = cer.flex4_cd,
   reply->qual[d1.seq].flex5_cd = cer.flex5_cd
  WITH nocounter
 ;end select
 IF (curqual)
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ENDIF
END GO
