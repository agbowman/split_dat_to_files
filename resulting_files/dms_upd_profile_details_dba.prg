CREATE PROGRAM dms_upd_profile_details:dba
 CALL echo("<==================== Entering DMS_UPD_PROFILE_DETAILS Script ====================>")
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
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
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 FREE SET numdetail
 DECLARE numdetail = i4 WITH noconstant(size(request->servicedetail,5))
 FREE RECORD curdetails
 RECORD curdetails(
   1 servicedetail[*]
     2 id = f8
     2 name = vc
     2 value = vc
 )
 FREE RECORD alldetails
 RECORD alldetails(
   1 qual[*]
     2 id = f8
 )
 FREE RECORD deldetails
 RECORD deldetails(
   1 qual[*]
     2 id = f8
 )
 SET stat = alterlist(curdetails->servicedetail,numdetail)
 FOR (z = 1 TO numdetail)
   SET curdetails->servicedetail[z].id = 0.0
   SET curdetails->servicedetail[z].name = request->servicedetail[z].name
   SET curdetails->servicedetail[z].value = request->servicedetail[z].value
 ENDFOR
 SELECT INTO "nl:"
  dpd.*
  FROM (dummyt d  WITH seq = value(numdetail)),
   dms_profile_detail dpd
  PLAN (d)
   JOIN (dpd
   WHERE (dpd.dms_profile_service_id=request->dms_profile_service_id)
    AND (dpd.detail_name=request->servicedetail[d.seq].name))
  DETAIL
   curdetails->servicedetail[d.seq].id = dpd.dms_profile_detail_id, curdetails->servicedetail[d.seq].
   name = request->servicedetail[d.seq].name, curdetails->servicedetail[d.seq].value = request->
   servicedetail[d.seq].value
  WITH nocounter
 ;end select
 INSERT  FROM dms_profile_detail dpd,
   (dummyt d  WITH seq = value(numdetail))
  SET dpd.dms_profile_detail_id = seq(dms_seq,nextval), dpd.dms_profile_service_id = request->
   dms_profile_service_id, dpd.detail_name = curdetails->servicedetail[d.seq].name,
   dpd.detail_value = curdetails->servicedetail[d.seq].value, dpd.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), dpd.updt_id = reqinfo->updt_id,
   dpd.updt_task = reqinfo->updt_task, dpd.updt_cnt = 0, dpd.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (curdetails->servicedetail[d.seq].id=0.0)
    AND (curdetails->servicedetail[d.seq].name > "")
    AND (curdetails->servicedetail[d.seq].value > ""))
   JOIN (dpd)
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  dpd.*
  FROM (dummyt d  WITH seq = value(numdetail)),
   dms_profile_detail dpd
  PLAN (d)
   JOIN (dpd
   WHERE (dpd.dms_profile_service_id=request->dms_profile_service_id)
    AND (dpd.detail_name=request->servicedetail[d.seq].name))
  DETAIL
   curdetails->servicedetail[d.seq].id = dpd.dms_profile_detail_id, curdetails->servicedetail[d.seq].
   name = request->servicedetail[d.seq].name, curdetails->servicedetail[d.seq].value = request->
   servicedetail[d.seq].value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dms_profile_detail dpd,
   (dummyt d  WITH seq = value(numdetail))
  PLAN (d
   WHERE (curdetails->servicedetail[d.seq].id > 0.0))
   JOIN (dpd
   WHERE (dpd.dms_profile_detail_id=curdetails->servicedetail[d.seq].id)
    AND (dpd.detail_name=curdetails->servicedetail[d.seq].name)
    AND (dpd.detail_value != curdetails->servicedetail[d.seq].value))
  WITH nocounter, forupdate(dpd)
 ;end select
 IF (0 < curqual)
  UPDATE  FROM dms_profile_detail dpd,
    (dummyt d  WITH seq = value(numdetail))
   SET dpd.detail_value = curdetails->servicedetail[d.seq].value, dpd.updt_dt_tm = cnvtdatetime(
     curdate,curtime3), dpd.updt_id = reqinfo->updt_id,
    dpd.updt_task = reqinfo->updt_task, dpd.updt_cnt = (dpd.updt_cnt+ 1), dpd.updt_applctx = reqinfo
    ->updt_applctx
   PLAN (d
    WHERE (curdetails->servicedetail[d.seq].id > 0.0))
    JOIN (dpd
    WHERE (dpd.dms_profile_detail_id=curdetails->servicedetail[d.seq].id)
     AND (dpd.detail_name=curdetails->servicedetail[d.seq].name)
     AND (dpd.detail_value != curdetails->servicedetail[d.seq].value))
   WITH nocounter
  ;end update
 ENDIF
 FREE SET totdetails
 DECLARE totdetails = i4 WITH noconstant(0)
 SET stat = alterlist(alldetails->qual,0)
 SELECT INTO "nl:"
  dpd.dms_profile_detail_id
  FROM dms_profile_detail dpd
  WHERE (dpd.dms_profile_service_id=request->dms_profile_service_id)
  DETAIL
   totdetails = (totdetails+ 1)
   IF (mod(totdetails,10)=1)
    stat = alterlist(alldetails->qual,(totdetails+ 9))
   ENDIF
   alldetails->qual[totdetails].id = dpd.dms_profile_detail_id
  WITH nocounter
 ;end select
 SET stat = alterlist(alldetails->qual,totdetails)
 FREE SET numdelete
 DECLARE numdelete = i4 WITH noconstant(0)
 FOR (j = 1 TO totdetails)
   SET bfound = 0
   SET count = 0
   WHILE (count < numdetail)
    SET count = (count+ 1)
    IF ((alldetails->qual[j].id=curdetails->servicedetail[count].id))
     SET bfound = 1
     SET count = numdetail
    ENDIF
   ENDWHILE
   IF ( NOT (bfound))
    SET numdelete = (numdelete+ 1)
    SET stat = alterlist(deldetails->qual,numdelete)
    SET deldetails->qual[numdelete].id = alldetails->qual[j].id
   ENDIF
 ENDFOR
 IF (0 < numdelete)
  DELETE  FROM dms_profile_detail dpd,
    (dummyt d  WITH seq = value(numdelete))
   SET dpd.seq = 1
   PLAN (d)
    JOIN (dpd
    WHERE (dpd.dms_profile_detail_id=deldetails->qual[d.seq].id))
   WITH nocounter
  ;end delete
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_UPD_PROFILE_DETAILS Script ====================>")
END GO
