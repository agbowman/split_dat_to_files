CREATE PROGRAM aps_add_db_dc_discrepancy:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[1]
     2 code_value = f8
 )
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET nbr_to_insert = cnvtint(size(request->qual,5))
 IF (nbr_to_insert > 1)
  SET stat = alter(temp->qual,nbr_to_insert)
 ENDIF
 FOR (x = 1 TO nbr_to_insert)
  SELECT INTO "nl:"
   seq_nbr = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    temp->qual[x].code_value = cnvtreal(seq_nbr)
   WITH format, counter
  ;end select
  IF (curqual=0)
   GO TO seq_failed
  ENDIF
 ENDFOR
 INSERT  FROM ap_dc_discrepancy_term addt,
   (dummyt d  WITH seq = value(nbr_to_insert))
  SET addt.discrepancy_term_id = temp->qual[d.seq].code_value, addt.display = request->qual[d.seq].
   display, addt.description = request->qual[d.seq].description,
   addt.discrepancy_cd = request->qual[d.seq].discrepancy_cd, addt.active_ind = request->qual[d.seq].
   active_ind, addt.updt_dt_tm = cnvtdatetime(curdate,curtime),
   addt.updt_id = reqinfo->updt_id, addt.updt_task = reqinfo->updt_task, addt.updt_applctx = reqinfo
   ->updt_applctx,
   addt.updt_cnt = 0
  PLAN (d)
   JOIN (addt)
  WITH nocounter
 ;end insert
 IF (curqual != nbr_to_insert)
  GO TO c_failed
 ENDIF
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "NEXTVAL"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "SEQ"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "REFERENCE_SEQ"
 SET failed = "T"
 GO TO exit_script
#c_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_DC_DISCREPANCY_TERM"
 SET failed = "T"
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  SET reply->status_data.status = "F"
  ROLLBACK
 ENDIF
END GO
