CREATE PROGRAM cdi_chg_batch_otg_sign:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE number_to_chg = i4 WITH public, noconstant(0)
 DECLARE failed = vc WITH public, noconstant("")
 DECLARE del_count = i4 WITH public, noconstant(0)
 DECLARE upd_count = i4 WITH public, noconstant(0)
 DECLARE index_num = i4 WITH public, noconstant(0)
 DECLARE complete_cd = f8 WITH public, noconstant(0.0)
 SET number_to_chg = size(request->qual,5)
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(79,"COMPLETE",1,complete_cd)
 SELECT INTO "nl:"
  FROM cdi_batch_otg_sign cbos
  WHERE expand(index_num,1,number_to_chg,cbos.cdi_batch_otg_sign_id,request->qual[index_num].
   cdi_batch_otg_sign_id)
  ORDER BY cbos.cdi_batch_otg_sign_id
  WITH nocounter, forupdate(cbos)
 ;end select
 SET index_num = 0
 DELETE  FROM cdi_batch_otg_sign cbos
  WHERE expand(index_num,1,number_to_chg,cbos.cdi_batch_otg_sign_id,request->qual[index_num].
   cdi_batch_otg_sign_id,
   complete_cd,request->qual[index_num].status_cd)
  WITH nocounter
 ;end delete
 SET del_count = curqual
 IF (del_count < number_to_chg)
  UPDATE  FROM cdi_batch_otg_sign cbos,
    (dummyt d  WITH seq = value(number_to_chg))
   SET cbos.status_cd = request->qual[d.seq].status_cd, cbos.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), cbos.updt_id = reqinfo->updt_id,
    cbos.updt_task = reqinfo->updt_task, cbos.updt_applctx = reqinfo->updt_applctx, cbos.updt_cnt = (
    cbos.updt_cnt+ 1)
   PLAN (d
    WHERE  NOT ((request->qual[d.seq].status_cd=complete_cd)))
    JOIN (cbos
    WHERE (cbos.cdi_batch_otg_sign_id=request->qual[d.seq].cdi_batch_otg_sign_id))
   WITH nocounter
  ;end update
  SET upd_count = curqual
 ENDIF
 IF (((upd_count+ del_count) != number_to_chg))
  SET failed = "T"
  GO TO exit_script
 ENDIF
 FREE RECORD temp
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_BATCH_OTG_SIGN"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Not all rows in request got updated."
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
