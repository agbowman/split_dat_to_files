CREATE PROGRAM bbt_get_catalog_procs:dba
 RECORD reply(
   1 qual[*]
     2 catalog_cd = f8
     2 catalog_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET hold_id = 0.0
 SET primary_cd = 0.0
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(6011,"PRIMARY",cv_cnt,primary_cd)
 SELECT INTO "nl:"
  p.task_assay_cd
  FROM profile_task_r p,
   order_catalog_synonym o
  PLAN (p
   WHERE (p.task_assay_cd=request->task_assay_cd))
   JOIN (o
   WHERE o.catalog_cd=p.catalog_cd
    AND o.mnemonic_type_cd=primary_cd)
  HEAD REPORT
   count1 = 0
  DETAIL
   IF (hold_id != o.catalog_cd)
    hold_id = o.catalog_cd, count1 = (count1+ 1), stat = alterlist(reply->qual,count1),
    reply->qual[count1].catalog_cd = o.catalog_cd, reply->qual[count1].catalog_disp = o.mnemonic
   ENDIF
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#stop
END GO
