CREATE PROGRAM acc_check_accession:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 accession_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE accession_id = f8 WITH protected, noconstant(0.0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  aor.accession
  FROM accession_order_r aor
  WHERE (aor.accession=request->accession_nbr)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   aor.accession_id
   FROM accession_order_r aor,
    orders o
   PLAN (aor
    WHERE (aor.accession=request->accession_nbr))
    JOIN (o
    WHERE o.order_id=aor.order_id
     AND ((o.person_id+ 0)=request->person_id)
     AND ((o.encntr_id+ 0)=request->encounter_id))
   DETAIL
    accession_id = aor.accession_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Accession_nbr received belongs to a different person and/or encounter than recieved."
  ELSE
   SET reply->status_data.status = "S"
   SET reply->accession_id = accession_id
  ENDIF
 ELSE
  SELECT INTO "nl:"
   acc.accession_id
   FROM accession acc
   WHERE (acc.accession=request->accession_nbr)
   DETAIL
    accession_id = acc.accession_id
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET reply->status_data.status = "S"
   SET reply->accession_id = accession_id
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
END GO
