CREATE PROGRAM bed_ens_rad_seg_orders:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET cnt = 0
 RECORD temp(
   1 qual[*]
     2 action_flag = i2
     2 catalog_cd = f8
     2 mnemonic = vc
     2 seg_ind = i2
 )
 SET cnt = size(request->orderables,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(temp->qual,cnt)
 FOR (x = 1 TO cnt)
   SET temp->qual[x].action_flag = request->orderables[x].action_flag
   SET temp->qual[x].catalog_cd = request->orderables[x].code_value
   SET temp->qual[x].seg_ind = request->orderables[x].multi_segment_ind
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   order_catalog oc
  PLAN (d)
   JOIN (oc
   WHERE (oc.catalog_cd=temp->qual[d.seq].catalog_cd))
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].mnemonic = oc.primary_mnemonic
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
  IF ((temp->qual[x].action_flag=1))
   SET ierrcode = 0
   INSERT  FROM br_exam_segment_info b
    SET b.catalog_cd = temp->qual[x].catalog_cd, b.primary_mnemonic = temp->qual[x].mnemonic, b
     .multi_segment_ind = temp->qual[x].seg_ind,
     b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
    PLAN (b)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    SET reply->error_msg = serrmsg
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((temp->qual[x].action_flag=3))
   SET ierrcode = 0
   DELETE  FROM br_exam_segment_info b
    WHERE (b.catalog_cd=temp->qual[x].catalog_cd)
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    SET reply->error_msg = serrmsg
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
