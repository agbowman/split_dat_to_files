CREATE PROGRAM bbd_get_recruitment_info:dba
 RECORD reply(
   1 willingness_level_cd = f8
   1 donation_level_trans = f8
   1 recruit_owner_area_cd = f8
   1 recruit_inv_area_cd = f8
   1 mailings_ind = i2
   1 updt_cnt = i4
   1 rare[*]
     2 rare_id = f8
     2 rare_type_cd = f8
     2 updt_cnt = i4
   1 special[*]
     2 special_interest_id = f8
     2 special_interest_cd = f8
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET rcount = 0
 SET icount = 0
 SELECT
  p.person_id, r.rare_id, i.special_interest_id
  FROM person_donor p,
   (dummyt d1  WITH seq = 1),
   bbd_rare_types r,
   (dummyt d2  WITH seq = 1),
   bbd_special_interest i
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1)
   JOIN (((d1
   WHERE d1.seq=1)
   JOIN (r
   WHERE r.person_id=p.person_id
    AND r.active_ind=1)
   ) ORJOIN ((d2
   WHERE d2.seq=1)
   JOIN (i
   WHERE i.person_id=p.person_id
    AND i.active_ind=1)
   ))
  ORDER BY r.rare_id
  HEAD REPORT
   reply->willingness_level_cd = p.willingness_level_cd, reply->donation_level_trans = p
   .donation_level_trans, reply->recruit_owner_area_cd = p.recruit_owner_area_cd,
   reply->recruit_inv_area_cd = p.recruit_inv_area_cd, reply->mailings_ind = p.mailings_ind, reply->
   updt_cnt = p.updt_cnt
  HEAD r.rare_id
   IF (r.rare_id > 0)
    rcount = (rcount+ 1), stat = alterlist(reply->rare,rcount), reply->rare[rcount].rare_id = r
    .rare_id,
    reply->rare[rcount].rare_type_cd = r.rare_type_cd, reply->rare[rcount].updt_cnt = r.updt_cnt
   ENDIF
  FOOT  i.special_interest_id
   IF (i.special_interest_id > 0)
    icount = (icount+ 1), stat = alterlist(reply->special,icount), reply->special[icount].
    special_interest_id = i.special_interest_id,
    reply->special[icount].special_interest_cd = i.special_interest_cd, reply->special[icount].
    updt_cnt = i.updt_cnt
   ENDIF
  WITH counter, outerjoin = d1, outerjoin = d2
 ;end select
 IF ((request->lock_ind=1))
  UPDATE  FROM person_donor p
   SET lock_ind = 1, p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task,
    p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = (p
    .updt_cnt+ 1)
   WHERE (person_id=request->person_id)
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status = "S"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_get_recruitment_info"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_DONOR"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error locking person_donor"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(current->system_dt_tm)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
