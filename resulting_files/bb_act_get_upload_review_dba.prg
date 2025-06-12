CREATE PROGRAM bb_act_get_upload_review:dba
 RECORD reply(
   1 uploadreviews[*]
     2 bb_upload_review_id = f8
     2 person_id = f8
     2 upload_person_aborh_id = f8
     2 upload_dt_tm = dq8
     2 demog_person_aborh_id = f8
     2 demog_aborh_dt_tm = dq8
     2 reviewed_ind = i2
     2 updt_dt_tm = dq8
     2 updt_cnt = i4
     2 updt_task = i4
     2 updt_applctx = i4
     2 updt_id = f8
     2 reviewdocs[*]
       3 bb_upload_long_text_r_id = f8
       3 long_text_id = f8
       3 long_text = vc
       3 long_text_updt_cnt = i4
       3 action_cd = f8
       3 updt_dt_tm = dq8
       3 updt_cnt = i4
       3 updt_task = i4
       3 updt_applctx = i4
       3 updt_id = f8
       3 active_ind = i2
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 active_status_cd = f8
     2 uploadpersonaborhrs[*]
       3 bb_upload_person_aborh_r_id = f8
       3 person_aborh_id = f8
       3 demog_aborh_dt_tm = dq8
       3 updt_dt_tm = dq8
       3 updt_cnt = i4
       3 updt_task = i4
       3 updt_applctx = i4
       3 updt_id = f8
   1 personaborhs[*]
     2 person_aborh_id = f8
     2 person_id = f8
     2 abo_cd = f8
     2 rh_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 contributor_system_cd = f8
     2 last_verified_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 aborhs[*]
     2 aborh_id = f8
 )
 DECLARE nburcount = i2 WITH noconstant(0)
 DECLARE nbultcount = i2 WITH noconstant(0)
 DECLARE nbupacount = i2 WITH noconstant(0)
 DECLARE npacount = i2 WITH noconstant(0)
 DECLARE nindex1 = i2 WITH noconstant(0)
 DECLARE nindex2 = i2 WITH noconstant(0)
 DECLARE naborh_cnt = i2 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE serrormsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE nerrorcheck = i2 WITH noconstant(error(serrormsg,1))
 DECLARE sscriptname = c25 WITH constant("BB_ACT_GET_UPLOAD_REVIEW")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  bur.*, bupa.*, bupa_seq = decode(bupa.seq,1,0),
  bult.*, bult_seq = decode(bult.seq,1,0), lt.long_text
  FROM bb_upload_review bur,
   (dummyt d1  WITH seq = 1),
   bb_upload_long_text_r bult,
   long_text lt,
   (dummyt d2  WITH seq = 1),
   bb_upload_person_aborh_r bupa
  PLAN (bur
   WHERE (((request->person_id > 0.0)
    AND (bur.person_id=request->person_id)) OR ((request->person_id=0.0)))
    AND (((((request->reviewed_flag=0)) OR ((request->reviewed_flag=1)))
    AND (bur.reviewed_ind=request->reviewed_flag)) OR ( NOT ((request->reviewed_flag IN (0, 1)))))
    AND (((request->begin_dt_tm=0)) OR (bur.upload_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm)
    AND cnvtdatetime(request->end_dt_tm)))
    AND bur.bb_upload_review_id > 0.0)
   JOIN (d1)
   JOIN (((bupa
   WHERE bur.bb_upload_review_id=bupa.bb_upload_review_id)
   ) ORJOIN ((d2)
   JOIN (bult
   WHERE bult.bb_upload_review_id=bur.bb_upload_review_id)
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(bult.long_text_id)
    AND lt.long_text_id > outerjoin(0.0))
   ))
  ORDER BY bur.bb_upload_review_id, bult.bb_upload_long_text_r_id, bupa.bb_upload_person_aborh_r_id
  HEAD bur.bb_upload_review_id
   nburcount = (nburcount+ 1)
   IF (mod(nburcount,10)=1)
    stat = alterlist(reply->uploadreviews,(nburcount+ 9))
   ENDIF
   nbultcount = 0, nbupacount = 0, reply->uploadreviews[nburcount].bb_upload_review_id = bur
   .bb_upload_review_id,
   reply->uploadreviews[nburcount].person_id = bur.person_id, reply->uploadreviews[nburcount].
   upload_person_aborh_id = bur.upload_person_aborh_id, reply->uploadreviews[nburcount].upload_dt_tm
    = bur.upload_dt_tm,
   reply->uploadreviews[nburcount].demog_person_aborh_id = bur.demog_person_aborh_id, reply->
   uploadreviews[nburcount].demog_aborh_dt_tm = bur.demog_aborh_dt_tm, reply->uploadreviews[nburcount
   ].reviewed_ind = bur.reviewed_ind,
   reply->uploadreviews[nburcount].updt_dt_tm = bur.updt_dt_tm, reply->uploadreviews[nburcount].
   updt_cnt = bur.updt_cnt, reply->uploadreviews[nburcount].updt_task = bur.updt_task,
   reply->uploadreviews[nburcount].updt_applctx = bur.updt_applctx, reply->uploadreviews[nburcount].
   updt_id = bur.updt_id
  HEAD bult.bb_upload_long_text_r_id
   IF (bult.bb_upload_long_text_r_id > 0.0
    AND bult_seq=1)
    nbultcount = (nbultcount+ 1)
    IF (mod(nbultcount,10)=1)
     stat = alterlist(reply->uploadreviews[nburcount].reviewdocs,(nbultcount+ 9))
    ENDIF
    reply->uploadreviews[nburcount].reviewdocs[nbultcount].bb_upload_long_text_r_id = bult
    .bb_upload_long_text_r_id, reply->uploadreviews[nburcount].reviewdocs[nbultcount].long_text_id =
    bult.long_text_id
    IF (lt.long_text_id > 0.0)
     reply->uploadreviews[nburcount].reviewdocs[nbultcount].long_text = lt.long_text, reply->
     uploadreviews[nburcount].reviewdocs[nbultcount].long_text_updt_cnt = lt.updt_cnt
    ENDIF
    reply->uploadreviews[nburcount].reviewdocs[nbultcount].action_cd = bult.action_cd, reply->
    uploadreviews[nburcount].reviewdocs[nbultcount].updt_dt_tm = bult.updt_dt_tm, reply->
    uploadreviews[nburcount].reviewdocs[nbultcount].updt_cnt = bult.updt_cnt,
    reply->uploadreviews[nburcount].reviewdocs[nbultcount].updt_task = bult.updt_task, reply->
    uploadreviews[nburcount].reviewdocs[nbultcount].updt_applctx = bult.updt_applctx, reply->
    uploadreviews[nburcount].reviewdocs[nbultcount].updt_id = bult.updt_id,
    reply->uploadreviews[nburcount].reviewdocs[nbultcount].active_ind = bult.active_ind, reply->
    uploadreviews[nburcount].reviewdocs[nbultcount].active_status_dt_tm = bult.active_status_dt_tm,
    reply->uploadreviews[nburcount].reviewdocs[nbultcount].active_status_prsnl_id = bult
    .active_status_prsnl_id,
    reply->uploadreviews[nburcount].reviewdocs[nbultcount].active_status_cd = bult.active_status_cd
   ENDIF
  HEAD bupa.bb_upload_person_aborh_r_id
   IF (bupa.bb_upload_person_aborh_r_id > 0.0
    AND bupa_seq=1)
    nbupacount = (nbupacount+ 1)
    IF (mod(nbupacount,10)=1)
     stat = alterlist(reply->uploadreviews[nburcount].uploadpersonaborhrs,(nbupacount+ 9))
    ENDIF
    reply->uploadreviews[nburcount].uploadpersonaborhrs[nbupacount].bb_upload_person_aborh_r_id =
    bupa.bb_upload_person_aborh_r_id, reply->uploadreviews[nburcount].uploadpersonaborhrs[nbupacount]
    .person_aborh_id = bupa.person_aborh_id, reply->uploadreviews[nburcount].uploadpersonaborhrs[
    nbupacount].demog_aborh_dt_tm = bupa.demog_aborh_dt_tm,
    reply->uploadreviews[nburcount].uploadpersonaborhrs[nbupacount].updt_dt_tm = bupa.updt_dt_tm,
    reply->uploadreviews[nburcount].uploadpersonaborhrs[nbupacount].updt_cnt = bupa.updt_cnt, reply->
    uploadreviews[nburcount].uploadpersonaborhrs[nbupacount].updt_task = bupa.updt_task,
    reply->uploadreviews[nburcount].uploadpersonaborhrs[nbupacount].updt_applctx = bupa.updt_applctx,
    reply->uploadreviews[nburcount].uploadpersonaborhrs[nbupacount].updt_id = bupa.updt_id
   ENDIF
  FOOT  bur.bb_upload_review_id
   stat = alterlist(reply->uploadreviews[nburcount].uploadpersonaborhrs,nbupacount), stat = alterlist
   (reply->uploadreviews[nburcount].reviewdocs,nbultcount)
  WITH nocounter, outerjoin(d1), outerjoin(d2)
 ;end select
 SET stat = alterlist(reply->uploadreviews,nburcount)
 SET nerrorcheck = error(serrormsg,0)
 IF (nerrorcheck=0)
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
 ELSE
  CALL errorhandler(sscriptname,"F","BB_UPLOAD_REVIEW select",serrormsg)
 ENDIF
 IF (size(reply->uploadreviews,5) > 0)
  FOR (nindex1 = 1 TO size(reply->uploadreviews,5))
    IF ((reply->uploadreviews[nindex1].upload_person_aborh_id > 0.0))
     CALL addpersonaborh(reply->uploadreviews[nindex1].upload_person_aborh_id)
    ENDIF
    IF ((reply->uploadreviews[nindex1].demog_person_aborh_id > 0.0))
     CALL addpersonaborh(reply->uploadreviews[nindex1].demog_person_aborh_id)
    ENDIF
    FOR (nindex2 = 1 TO size(reply->uploadreviews[nindex1].uploadpersonaborhrs,5))
      IF ((reply->uploadreviews[nindex1].uploadpersonaborhrs[nindex2].person_aborh_id > 0.0))
       CALL addpersonaborh(reply->uploadreviews[nindex1].uploadpersonaborhrs[nindex2].person_aborh_id
        )
      ENDIF
    ENDFOR
  ENDFOR
  SET stat = alterlist(temp->aborhs,naborh_cnt)
  SELECT DISTINCT INTO "nl:"
   pa.person_aborh_id
   FROM person_aborh pa,
    (dummyt d  WITH seq = value(size(temp->aborhs,5)))
   PLAN (d)
    JOIN (pa
    WHERE (pa.person_aborh_id=temp->aborhs[d.seq].aborh_id)
     AND pa.person_aborh_id > 0.0)
   ORDER BY pa.person_aborh_id
   DETAIL
    npacount = (npacount+ 1)
    IF (mod(npacount,10)=1)
     stat = alterlist(reply->personaborhs,(npacount+ 9))
    ENDIF
    reply->personaborhs[npacount].person_aborh_id = pa.person_aborh_id, reply->personaborhs[npacount]
    .person_id = pa.person_id, reply->personaborhs[npacount].abo_cd = pa.abo_cd,
    reply->personaborhs[npacount].rh_cd = pa.rh_cd, reply->personaborhs[npacount].active_ind = pa
    .active_ind, reply->personaborhs[npacount].active_status_cd = pa.active_status_cd,
    reply->personaborhs[npacount].active_status_dt_tm = pa.active_status_dt_tm, reply->personaborhs[
    npacount].active_status_prsnl_id = pa.active_status_prsnl_id, reply->personaborhs[npacount].
    begin_effective_dt_tm = pa.begin_effective_dt_tm,
    reply->personaborhs[npacount].end_effective_dt_tm = pa.end_effective_dt_tm, reply->personaborhs[
    npacount].updt_cnt = pa.updt_cnt, reply->personaborhs[npacount].updt_dt_tm = pa.updt_dt_tm,
    reply->personaborhs[npacount].updt_id = pa.updt_id, reply->personaborhs[npacount].updt_task = pa
    .updt_task, reply->personaborhs[npacount].updt_applctx = pa.updt_applctx,
    reply->personaborhs[npacount].contributor_system_cd = pa.contributor_system_cd, reply->
    personaborhs[npacount].last_verified_dt_tm = pa.last_verified_dt_tm
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->personaborhs,npacount)
  SET stat = alterlist(temp->aborhs,0)
  SET nerrorcheck = error(serrormsg,0)
  IF (nerrorcheck=0)
   IF (curqual=0)
    SET reply->status_data.status = "Z"
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ELSE
   CALL errorhandler(sscriptname,"F","PERSON_ABORH select",serrormsg)
  ENDIF
 ENDIF
 DECLARE errorhandler(operationname=c25,operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc)
  = null
 SUBROUTINE errorhandler(operationname,operationstatus,targetobjectname,targetobjectvalue)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = operationname
   SET reply->status_data.subeventstatus[1].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
 DECLARE addpersonaborh(personaborhid=f8) = null
 SUBROUTINE addpersonaborh(personaborhid)
   SET naborh_cnt = (naborh_cnt+ 1)
   IF (mod(naborh_cnt,10)=1)
    SET stat = alterlist(temp->aborhs,(naborh_cnt+ 9))
   ENDIF
   SET temp->aborhs[naborh_cnt].aborh_id = personaborhid
 END ;Subroutine
#exit_script
 IF ((request->debug_ind=1))
  CALL echorecord(request)
  CALL echorecord(reply)
  CALL echorecord(temp)
 ENDIF
END GO
