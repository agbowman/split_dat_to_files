CREATE PROGRAM bed_get_legacy:dba
 FREE SET reply
 RECORD reply(
   1 oc_ind = i2
   1 dta_ind = i2
   1 oc_dta_reltn_ind = i2
   1 dta_rrf_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET reply->oc_ind = 0
 SET reply->dta_ind = 0
 SET reply->oc_dta_reltn_ind = 0
 IF ((request->oc_ind=1))
  SELECT INTO "NL:"
   FROM br_oc_work b
   WITH nocounter, maxqual(b,1)
  ;end select
  IF (curqual > 0)
   SET reply->oc_ind = 1
  ENDIF
 ENDIF
 IF ((request->dta_ind=1))
  SELECT INTO "NL:"
   FROM br_dta_work b
   WITH nocounter, maxqual(b,1)
  ;end select
  IF (curqual > 0)
   SET reply->dta_ind = 1
  ENDIF
 ENDIF
 IF ((request->oc_dta_reltn_ind=1))
  SELECT INTO "NL:"
   FROM br_oc_work b,
    br_dta_relationship d
   PLAN (b
    WHERE b.match_orderable_cd > 0)
    JOIN (d
    WHERE d.oc_id=b.oc_id)
   WITH nocounter, maxqual(d,1)
  ;end select
  IF (curqual > 0)
   SET reply->oc_dta_reltn_ind = 1
  ENDIF
 ENDIF
 IF ((request->dta_rrf_ind=1))
  SELECT INTO "NL:"
   FROM br_dta_rrf b
   WITH nocounter, maxqual(b,1)
  ;end select
  IF (curqual > 0)
   SET reply->dta_rrf_ind = 1
  ENDIF
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
