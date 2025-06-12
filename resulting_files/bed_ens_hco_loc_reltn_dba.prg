CREATE PROGRAM bed_ens_hco_loc_reltn:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 hco_loc_relations[*]
      2 hco_id = f8
      2 location_cd = f8
      2 hco_loc_reltn_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET insertrecord
 RECORD insertrecord(
   1 items[*]
     2 hco_loc_reltn_id = f8
     2 hco_id = f8
     2 location_cd = f8
 )
 FREE SET deleterecord
 RECORD deleterecord(
   1 items[*]
     2 hco_loc_reltn_id = f8
 )
 DECLARE logerror(namemsg=vc,valuemsg=vc) = null
 DECLARE error_flag = vc
 DECLARE insertcnt = i4 WITH noconstant(0)
 DECLARE deletecnt = i4 WITH noconstant(0)
 DECLARE requestcnt = i4
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET requestcnt = size(request->hco_loc_relations,5)
 FOR (i = 1 TO requestcnt)
  IF ((request->hco_loc_relations[i].action_flag=1))
   DECLARE new_loc_reltn_id = f8
   SET new_loc_reltn_id = 0.0
   SELECT INTO "nl:"
    z = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     new_loc_reltn_id = cnvtreal(z)
    WITH nocounter
   ;end select
   SET insertcnt = (insertcnt+ 1)
   SET stat = alterlist(insertrecord->items,insertcnt)
   SET insertrecord->items[insertcnt].hco_id = request->hco_loc_relations[i].hco_id
   SET insertrecord->items[insertcnt].location_cd = request->hco_loc_relations[i].location_cd
   SET insertrecord->items[insertcnt].hco_loc_reltn_id = new_loc_reltn_id
   SET stat = alterlist(reply->hco_loc_relations,insertcnt)
   SET reply->hco_loc_relations[insertcnt].hco_id = request->hco_loc_relations[i].hco_id
   SET reply->hco_loc_relations[insertcnt].location_cd = request->hco_loc_relations[i].location_cd
   SET reply->hco_loc_relations[insertcnt].hco_loc_reltn_id = new_loc_reltn_id
  ENDIF
  IF ((request->hco_loc_relations[i].action_flag=3))
   SET deletecnt = (deletecnt+ 1)
   SET stat = alterlist(deleterecord->items,deletecnt)
   SET deleterecord->items[deletecnt].hco_loc_reltn_id = request->hco_loc_relations[i].
   hco_loc_reltn_id
  ENDIF
 ENDFOR
 IF (deletecnt > 0)
  DELETE  FROM br_hco_loc_reltn b,
    (dummyt d  WITH seq = value(deletecnt))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_hco_loc_reltn_id=deleterecord->items[d.seq].hco_loc_reltn_id))
   WITH nocounter
  ;end delete
 ENDIF
 IF (insertcnt > 0)
  INSERT  FROM br_hco_loc_reltn b,
    (dummyt d  WITH seq = value(insertcnt))
   SET b.br_hco_loc_reltn_id = insertrecord->items[d.seq].hco_loc_reltn_id, b.br_hco_id =
    insertrecord->items[d.seq].hco_id, b.location_cd = insertrecord->items[d.seq].location_cd,
    b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
    reqinfo->updt_task,
    b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
   PLAN (d)
    JOIN (b)
   WITH nocounter
  ;end insert
 ENDIF
 SUBROUTINE logerror(namemsg,valuemsg)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = namemsg
   SET reply->status_data.subeventstatus[1].targetobjectvalue = valuemsg
   GO TO exit_script
 END ;Subroutine
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
