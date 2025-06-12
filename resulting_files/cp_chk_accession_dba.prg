CREATE PROGRAM cp_chk_accession:dba
 RECORD reply(
   1 person_id = f8
   1 encntr_id = f8
   1 order_id = f8
   1 accession_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET accession_match = "F"
 SELECT INTO "nl:"
  a.accession_id
  FROM accession a,
   accession_order_r aor,
   orders o
  PLAN (a
   WHERE (a.accession=request->accession_nbr))
   JOIN (aor
   WHERE aor.accession_id=a.accession_id)
   JOIN (o
   WHERE aor.order_id=o.order_id
    AND o.active_ind=1)
  HEAD REPORT
   reply->person_id = o.person_id, reply->encntr_id = o.encntr_id, reply->order_id = o.order_id,
   reply->accession_id = a.accession_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ELSE
  SET accession_match = "T"
 ENDIF
#exit_script
 IF (accession_match="F")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(reply->status_data.status)
END GO
