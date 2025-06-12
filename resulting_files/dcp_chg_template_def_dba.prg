CREATE PROGRAM dcp_chg_template_def:dba
 RECORD temp(
   1 qual[10]
     2 location_cd = f8
     2 prsnl_id = f8
     2 note_type_template_reltn_id = f8
     2 default_ind = f8
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE temp_cnt = i4 WITH noconstant(0)
 DECLARE pos = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE ind_cnt = i4 WITH noconstant(0)
 SET reply->status_data.status = "S"
 SET temp_cnt = cnvtint(size(request->qual,5))
 UPDATE  FROM note_type_template_reltn ntt,
   (dummyt d  WITH seq = value(temp_cnt))
  SET ntt.default_ind = request->qual[d.seq].default_ind, ntt.updt_dt_tm = cnvtdatetime(curdate,
    curtime), ntt.updt_id = reqinfo->updt_id,
   ntt.updt_task = reqinfo->updt_task, ntt.updt_applctx = reqinfo->updt_applctx, ntt.updt_cnt = (ntt
   .updt_cnt+ 1)
  PLAN (d)
   JOIN (ntt
   WHERE (request->qual[d.seq].note_type_id=ntt.note_type_id)
    AND (request->qual[d.seq].template_id=ntt.template_id)
    AND (request->qual[d.seq].location_cd=0.0)
    AND (request->qual[d.seq].prsnl_id=0.0))
  WITH nocounter
 ;end update
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp_cnt)),
   note_type_template_reltn ntt,
   prsnl_loc_template_reltn pltr
  PLAN (d)
   JOIN (ntt
   WHERE (ntt.note_type_id=request->qual[d.seq].note_type_id)
    AND (ntt.template_id=request->qual[d.seq].template_id))
   JOIN (pltr
   WHERE (((request->qual[d.seq].prsnl_id > 0)) OR ((request->qual[d.seq].location_cd > 0)))
    AND pltr.note_type_template_reltn_id=ntt.note_type_template_reltn_id
    AND (pltr.location_cd=request->qual[d.seq].location_cd)
    AND (pltr.prsnl_id=request->qual[d.seq].prsnl_id))
  DETAIL
   pos = locateval(num,1,temp_cnt,pltr.prsnl_id,request->qual[num].prsnl_id,
    pltr.location_cd,request->qual[num].location_cd,ntt.note_type_id,request->qual[num].note_type_id,
    ntt.template_id,
    request->qual[num].template_id)
   IF (pos > 0)
    ind_cnt = (ind_cnt+ 1)
    IF (mod(ind_cnt,10)=1
     AND ind_cnt > 1)
     stat = alter(temp->qual,(ind_cnt+ 9))
    ENDIF
    temp->qual[ind_cnt].note_type_template_reltn_id = ntt.note_type_template_reltn_id, temp->qual[
    ind_cnt].prsnl_id = request->qual[pos].prsnl_id, temp->qual[ind_cnt].location_cd = request->qual[
    pos].location_cd,
    temp->qual[ind_cnt].default_ind = request->qual[pos].default_ind
   ENDIF
   pos = 0
  WITH nocounter
 ;end select
 SET stat = alter(temp->qual,ind_cnt)
 CALL echorecord(temp)
 CALL echo(build(" Count : ",ind_cnt))
 IF (ind_cnt > 0)
  UPDATE  FROM prsnl_loc_template_reltn pltr,
    (dummyt d  WITH seq = value(ind_cnt))
   SET pltr.default_ind = temp->qual[d.seq].default_ind, pltr.updt_dt_tm = cnvtdatetime(curdate,
     curtime), pltr.updt_id = reqinfo->updt_id,
    pltr.updt_task = reqinfo->updt_task, pltr.updt_applctx = reqinfo->updt_applctx, pltr.updt_cnt = (
    pltr.updt_cnt+ 1)
   PLAN (d)
    JOIN (pltr
    WHERE (temp->qual[d.seq].note_type_template_reltn_id=pltr.note_type_template_reltn_id)
     AND (temp->qual[d.seq].location_cd=pltr.location_cd)
     AND (temp->qual[d.seq].prsnl_id=pltr.prsnl_id))
   WITH nocounter
  ;end update
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "NOTE_TYPE_TEMPLATE_RELTN or PRSNL_LOC_TEMPLATE_RELTN"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
