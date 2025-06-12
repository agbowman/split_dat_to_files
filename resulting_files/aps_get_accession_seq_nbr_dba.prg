CREATE PROGRAM aps_get_accession_seq_nbr:dba
 RECORD reply(
   1 accession_ind = i2
   1 accession_seq_nbr = i4
   1 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET _acc_assign_date = cnvtdatetimeutc(cnvtdatetime(cnvtdate2(concat("0101",cnvtstring(year(curdate),
      4,0,r)),"mmddyyyy"),0),2)
 SELECT INTO "nl:"
  aap.initial_value, aa_exists = decode(aa.seq,1,0)
  FROM accession_assign_pool aap,
   (dummyt d  WITH seq = 1),
   accession_assignment aa
  PLAN (aap
   WHERE (request->group_cd=aap.accession_assignment_pool_id))
   JOIN (d
   WHERE d.seq=1)
   JOIN (aa
   WHERE aap.accession_assignment_pool_id=aa.acc_assign_pool_id
    AND cnvtdatetimeutc(_acc_assign_date,0)=aa.acc_assign_date)
  DETAIL
   IF (aa_exists=1)
    reply->accession_ind = 1, reply->accession_seq_nbr = aa.accession_seq_nbr, reply->updt_cnt = aa
    .updt_cnt
   ELSE
    reply->accession_ind = 0, reply->accession_seq_nbr = aap.initial_value, reply->updt_cnt = aap
    .updt_cnt
   ENDIF
  WITH outerjoin = d, nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ACCESSION_ASSIGN_POOL"
  SET failed = "T"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
