CREATE PROGRAM dcp_get_valid_encntrs:dba
 RECORD reply(
   1 restrict_ind = i2
   1 persons[*]
     2 person_id = f8
     2 encntrs[*]
       3 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 org_list[*]
     2 organization_id = f8
     2 confid_level = i4
   1 encntr_list[*]
     2 person_id = f8
     2 encntr_id = f8
     2 organization_id = f8
     2 confid_level = i4
     2 auth_ind = i2
 )
 SET reply->status_data.status = "F"
 DECLARE person_cnt = i4 WITH noconstant(0)
 DECLARE encntr_cnt = i4 WITH noconstant(0)
 DECLARE org_cnt = i4 WITH noconstant(0)
 DECLARE encntr_org_sec_ind = i2 WITH noconstant(0)
 DECLARE confid_ind = i2 WITH noconstant(0)
 SET reply->restrict_ind = 0
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="SECURITY"
    AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID"))
  DETAIL
   IF (di.info_name="SEC_ORG_RELTN"
    AND di.info_number=1)
    encntr_org_sec_ind = 1
   ELSEIF (di.info_name="SEC_CONFID"
    AND di.info_number=1)
    confid_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET sz = size(request->persons,5)
 IF (((encntr_org_sec_ind=1) OR (confid_ind=1)) )
  SET reply->restrict_ind = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(sz)),
    encounter e
   PLAN (d)
    JOIN (e
    WHERE (e.person_id=request->persons[d.seq].person_id)
     AND e.active_ind=1)
   ORDER BY e.person_id
   HEAD REPORT
    encntr_cnt = 0
   DETAIL
    encntr_cnt = (encntr_cnt+ 1)
    IF (mod(encntr_cnt,10)=1)
     stat = alterlist(temp->encntr_list,(encntr_cnt+ 9))
    ENDIF
    temp->encntr_list[encntr_cnt].person_id = e.person_id, temp->encntr_list[encntr_cnt].encntr_id =
    e.encntr_id, temp->encntr_list[encntr_cnt].organization_id = e.organization_id,
    temp->encntr_list[encntr_cnt].confid_level = uar_get_collation_seq(e.confid_level_cd)
    IF ((temp->encntr_list[encntr_cnt].confid_level < 0))
     temp->encntr_list[encntr_cnt].confid_level = 0
    ENDIF
    temp->encntr_list[encntr_cnt].auth_ind = 0
   FOOT REPORT
    stat = alterlist(temp->encntr_list,encntr_cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM prsnl_org_reltn por
   PLAN (por
    WHERE (por.person_id=request->prsnl_id)
     AND por.active_ind=1
     AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   HEAD REPORT
    org_cnt = 0
   DETAIL
    org_cnt = (org_cnt+ 1)
    IF (mod(org_cnt,5)=1)
     stat = alterlist(temp->org_list,(org_cnt+ 4))
    ENDIF
    temp->org_list[org_cnt].organization_id = por.organization_id, temp->org_list[org_cnt].
    confid_level = uar_get_collation_seq(por.confid_level_cd)
    IF ((temp->org_list[org_cnt].confid_level < 0))
     temp->org_list[org_cnt].confid_level = 0
    ENDIF
   FOOT REPORT
    stat = alterlist(temp->org_list,org_cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(encntr_cnt)),
    (dummyt d2  WITH seq = value(org_cnt))
   PLAN (d
    WHERE (temp->encntr_list[d.seq].auth_ind=0))
    JOIN (d2
    WHERE (temp->encntr_list[d.seq].organization_id=temp->org_list[d2.seq].organization_id))
   ORDER BY d.seq
   DETAIL
    IF (confid_ind=1)
     IF ((temp->encntr_list[d.seq].confid_level <= temp->org_list[d2.seq].confid_level))
      temp->encntr_list[d.seq].auth_ind = 1
     ENDIF
    ELSE
     temp->encntr_list[d.seq].auth_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(encntr_cnt))
   PLAN (d
    WHERE (temp->encntr_list[d.seq].auth_ind=1))
   ORDER BY d.seq
   HEAD REPORT
    person_cnt = 0, person_id = 0.0
   DETAIL
    IF ((person_id != temp->encntr_list[d.seq].person_id))
     person_cnt = (person_cnt+ 1)
     IF (mod(person_cnt,10)=1)
      stat = alterlist(reply->persons,(person_cnt+ 9))
     ENDIF
     person_id = temp->encntr_list[d.seq].person_id, reply->persons[person_cnt].person_id = temp->
     encntr_list[d.seq].person_id, encntr_cnt = 0
    ENDIF
    encntr_cnt = (encntr_cnt+ 1), stat = alterlist(reply->persons[person_cnt].encntrs,encntr_cnt),
    reply->persons[person_cnt].encntrs[encntr_cnt].encntr_id = temp->encntr_list[d.seq].encntr_id
   FOOT REPORT
    stat = alterlist(reply->persons,person_cnt)
   WITH nocounter
  ;end select
  FREE RECORD temp
 ELSE
  SET reply->restrict_ind = 0
 ENDIF
 SET reply->status_data.status = "S"
END GO
