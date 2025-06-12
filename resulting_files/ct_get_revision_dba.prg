CREATE PROGRAM ct_get_revision:dba
 RECORD reply(
   1 amendment_nbr = i4
   1 amendment_rev_ind = i2
   1 hybrid_revision = i2
   1 revisions[*]
     2 revision_nbr = i4
     2 revision_description = vc
     2 revision_dt_tm = dq8
     2 revision_updt_cnt = i4
     2 revision_nbr_txt = c30
     2 revision_id = f8
     2 revision_reasons[*]
       3 reason_type_cd = f8
       3 reason_type_disp = c40
       3 reason_type_desc = c60
       3 reason_type_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE reason_cnt = i2 WITH protect, noconstant(0)
 SET last_mod = "002"
 SET mod_date = "Apr 5, 2006"
 SELECT INTO "NL:"
  pa.*
  FROM prot_amendment pa
  WHERE (pa.parent_amendment_id=request->prot_amendment_id)
   AND (pa.prot_amendment_id != request->prot_amendment_id)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->hybrid_revision = 0
 ELSE
  SET reply->hybrid_revision = 1
 ENDIF
 IF ((reply->hybrid_revision=1))
  SELECT INTO "NL:"
   pa.revision_seq, pa.revision_nbr_txt, r.*
   FROM prot_amendment pa,
    revision r,
    amendment_reason ar
   PLAN (pa
    WHERE (((pa.parent_amendment_id=request->prot_amendment_id)
     AND pa.revision_seq != 0) OR ((pa.prot_amendment_id=request->prot_amendment_id))) )
    JOIN (r
    WHERE r.prot_amendment_id=pa.prot_amendment_id)
    JOIN (ar
    WHERE ar.prot_amendment_id=r.prot_amendment_id)
   ORDER BY pa.revision_seq
   HEAD REPORT
    reply->amendment_nbr = pa.amendment_nbr, reply->amendment_rev_ind = pa.revision_ind
   HEAD r.revision_id
    reason_cnt = 0, cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->revisions,(cnt+ 9))
    ENDIF
    reply->revisions[cnt].revision_nbr = r.revision_nbr, reply->revisions[cnt].revision_description
     = r.revision_description, reply->revisions[cnt].revision_dt_tm = r.revision_dt_tm,
    reply->revisions[cnt].revision_updt_cnt = r.updt_cnt, reply->revisions[cnt].revision_id = r
    .revision_id, reply->revisions[cnt].revision_nbr_txt = pa.revision_nbr_txt
   DETAIL
    IF (pa.revision_seq > 0)
     reason_cnt = (reason_cnt+ 1)
     IF (mod(reason_cnt,10)=1)
      stat = alterlist(reply->revisions[cnt].revision_reasons,(reason_cnt+ 9))
     ENDIF
     reply->revisions[cnt].revision_reasons[reason_cnt].reason_type_cd = ar.amendment_reason_cd
    ENDIF
   FOOT  r.revision_id
    stat = alterlist(reply->revisions[cnt].revision_reasons,reason_cnt)
   FOOT REPORT
    stat = alterlist(reply->revisions,cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   SET reqinfo->commit_ind = 1
   GO TO endgo
  ENDIF
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SELECT INTO "NL:"
   pr.*, ar.amendment_reason_cd
   FROM revision pr,
    prot_amendment pa,
    amendment_reason ar
   PLAN (pa
    WHERE (pa.prot_amendment_id=request->prot_amendment_id))
    JOIN (pr
    WHERE pr.prot_amendment_id=pa.prot_amendment_id)
    JOIN (ar
    WHERE ar.prot_amendment_id=pa.prot_amendment_id)
   ORDER BY pr.revision_nbr
   HEAD REPORT
    reply->amendment_rev_ind = pa.revision_ind, reply->amendment_nbr = pa.amendment_nbr
   HEAD pr.revision_id
    reason_cnt = 0, cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->revisions,(cnt+ 9))
    ENDIF
    reply->revisions[cnt].revision_nbr = pr.revision_nbr, reply->revisions[cnt].revision_description
     = pr.revision_description, reply->revisions[cnt].revision_dt_tm = pr.revision_dt_tm,
    reply->revisions[cnt].revision_updt_cnt = pr.updt_cnt, reply->revisions[cnt].revision_id = pr
    .revision_id, reply->revisions[cnt].revision_nbr_txt = pa.revision_nbr_txt
   DETAIL
    reason_cnt = (reason_cnt+ 1)
    IF (mod(reason_cnt,10)=1)
     stat = alterlist(reply->revisions[cnt].revision_reasons,(reason_cnt+ 9))
    ENDIF
    reply->revisions[cnt].revision_reasons[reason_cnt].reason_type_cd = ar.amendment_reason_cd
   FOOT  pr.revision_id
    stat = alterlist(reply->revisions[cnt].revision_reasons,reason_cnt)
   FOOT REPORT
    stat = alterlist(reply->revisions,cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   SET reqinfo->commit_ind = 1
   GO TO endgo
  ENDIF
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
#endgo
END GO
