CREATE PROGRAM ct_get_prot_amd_statuses:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 prot_master_id = f8
    1 prot_status_cd = f8
    1 prot_status_disp = vc
    1 prot_status_desc = vc
    1 prot_status_mean = c12
    1 qual[*]
      2 prot_amendment_id = f8
      2 amd_status_cd = f8
      2 amd_status_disp = vc
      2 amd_status_desc = vc
      2 amd_status_mean = c12
      2 amd_nbr = i4
      2 amd_dt_tm = dq8
      2 rev_qual[*]
        3 prot_amendment_id = f8
        3 revision_nbr = c30
        3 revision_seq = i4
        3 revision_status_cd = f8
        3 revision_status_disp = vc
        3 revision_status_desc = vc
        3 revision_status_mean = c12
        3 revision_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET last_mod = "002"
 SET mod_date = "August 22, 2006"
 SELECT INTO "nl:"
  FROM prot_master pm,
   prot_amendment pa
  PLAN (pm
   WHERE (pm.prot_master_id=request->prot_master_id))
   JOIN (pa
   WHERE pa.prot_master_id=pm.prot_master_id)
  ORDER BY pa.parent_amendment_id, pa.revision_seq
  HEAD REPORT
   reply->prot_master_id = request->prot_master_id, reply->prot_status_cd = pm.prot_status_cd,
   amd_cnt = 0
  HEAD pa.parent_amendment_id
   rev_cnt = 0
   IF (pa.revision_ind=0)
    amd_cnt = (amd_cnt+ 1)
    IF (amd_cnt > size(reply->qual,5))
     bstat = alterlist(reply->qual,(amd_cnt+ 5))
    ENDIF
    reply->qual[amd_cnt].prot_amendment_id = pa.prot_amendment_id, reply->qual[amd_cnt].amd_status_cd
     = pa.amendment_status_cd, reply->qual[amd_cnt].amd_nbr = pa.amendment_nbr,
    reply->qual[amd_cnt].amd_dt_tm = pa.amendment_dt_tm
   ENDIF
  DETAIL
   IF (pa.revision_ind=1)
    rev_cnt = (rev_cnt+ 1)
    IF (rev_cnt > size(reply->qual[amd_cnt].rev_qual,5))
     bstat = alterlist(reply->qual[amd_cnt].rev_qual,(rev_cnt+ 5))
    ENDIF
    reply->qual[amd_cnt].rev_qual[rev_cnt].prot_amendment_id = pa.prot_amendment_id, reply->qual[
    amd_cnt].rev_qual[rev_cnt].revision_nbr = pa.revision_nbr_txt, reply->qual[amd_cnt].rev_qual[
    rev_cnt].revision_seq = pa.revision_seq,
    reply->qual[amd_cnt].rev_qual[rev_cnt].revision_status_cd = pa.amendment_status_cd, reply->qual[
    amd_cnt].rev_qual[rev_cnt].revision_dt_tm = pa.amendment_dt_tm
   ENDIF
  FOOT  pa.parent_amendment_id
   bstat = alterlist(reply->qual[amd_cnt].rev_qual,rev_cnt)
  FOOT REPORT
   bstat = alterlist(reply->qual,amd_cnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
#exit_script
END GO
