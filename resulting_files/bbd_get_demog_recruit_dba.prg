CREATE PROGRAM bbd_get_demog_recruit:dba
 RECORD reply(
   1 recruit_inv_area_cd = f8
   1 recruit_inv_area_disp = vc
   1 recruit_owner_area_cd = f8
   1 recruit_owner_area_disp = vc
   1 willingness_level_cd = f8
   1 willingness_level_disp = vc
   1 mailings_ind = i2
   1 qual_rare[*]
     2 rare_type_cd = f8
     2 rare_type_disp = vc
   1 qual_special[*]
     2 special_interest_cd = f8
     2 special_interest_disp = vc
   1 recruit_contact_dt_tm = di8
   1 recruit_contact_outcome_cd = f8
   1 recruit_contact_outcome_disp = vc
   1 recruit_contacted_by = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET recruitment_type_cd = 0.0
 SET rcount = 0
 SET icount = 0
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14220,"RECRUIT",cv_cnt,recruitment_type_cd)
 IF (recruitment_type_cd=0.0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to read recruitment type code value"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.*, r.*, i.*
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
   reply->willingness_level_cd = p.willingness_level_cd, reply->recruit_owner_area_cd = p
   .recruit_owner_area_cd, reply->recruit_inv_area_cd = p.recruit_inv_area_cd,
   reply->mailings_ind = p.mailings_ind
  HEAD r.rare_id
   IF (r.rare_id > 0)
    rcount = (rcount+ 1), stat = alterlist(reply->qual_rare,rcount), reply->qual_rare[rcount].
    rare_type_cd = r.rare_type_cd
   ENDIF
  FOOT  i.special_interest_id
   IF (i.special_interest_id > 0)
    icount = (icount+ 1), stat = alterlist(reply->qual_special,icount), reply->qual_special[icount].
    special_interest_cd = i.special_interest_cd
   ENDIF
  WITH counter, outerjoin = d1, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  dc.*
  FROM bbd_donor_contact dc,
   bbd_recruitment_rslts rr,
   person p
  PLAN (dc
   WHERE (dc.person_id=request->person_id)
    AND dc.contact_type_cd=recruitment_type_cd
    AND dc.active_ind=1)
   JOIN (rr
   WHERE rr.person_id=dc.person_id
    AND rr.contact_id=dc.contact_id
    AND rr.active_ind=1)
   JOIN (p
   WHERE p.person_id=rr.recruit_prsnl_id
    AND p.active_ind=1)
  ORDER BY dc.contact_dt_tm DESC
  DETAIL
   reply->recruit_contact_dt_tm = dc.contact_dt_tm, reply->recruit_contact_outcome_cd = dc
   .contact_outcome_cd, reply->recruit_contacted_by = p.name_full_formatted
  WITH nocounter, maxqual(dc,value(1))
 ;end select
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
