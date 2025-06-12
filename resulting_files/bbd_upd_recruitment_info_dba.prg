CREATE PROGRAM bbd_upd_recruitment_info:dba
 RECORD reply(
   1 rare[*]
     2 new_ind = i2
     2 rare_type_cd = f8
     2 rare_type_id = f8
     2 updt_cnt = i4
   1 special[*]
     2 new_ind = i2
     2 special_interest_cd = f8
     2 special_interest_id = f8
     2 updt_cnt = i4
   1 contact_method[*]
     2 new_ind = i2
     2 contact_method_cd = f8
     2 contact_method_id = f8
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE rcount = i4 WITH protect, constant(size(request->rare,5))
 DECLARE scount = i4 WITH protect, constant(size(request->special,5))
 DECLARE mcount = i4 WITH protect, constant(size(request->contact_method,5))
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE y = i4 WITH protect, noconstant(0)
 DECLARE z = i4 WITH protect, noconstant(0)
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 IF ((request->updt_ind=1))
  SELECT INTO "nl:"
   p.*
   FROM person_donor p
   WHERE (p.person_id=request->person_id)
    AND (p.updt_cnt=request->updt_cnt)
   WITH counter, forupdate(p)
  ;end select
  UPDATE  FROM person_donor p
   SET p.willingness_level_cd = request->willingness_level_cd, p.preferred_donation_location_cd =
    request->pref_don_loc_cd, p.updt_applctx = reqinfo->updt_applctx,
    p.updt_task = reqinfo->updt_task, p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->updt_id,
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE (p.person_id=request->person_id)
    AND (p.updt_cnt=request->updt_cnt)
    AND (p.lock_ind=request->lock_ind)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_DONOR"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Update error..."
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->rare,rcount)
 FOR (x = 1 TO rcount)
   IF ((request->rare[x].add_mod=0))
    SELECT INTO "nl:"
     r.rare_id
     FROM bbd_rare_types r
     WHERE (r.rare_id=request->rare[x].rare_id)
      AND (r.updt_cnt=request->rare[x].updt_cnt)
     DETAIL
      reply->rare[x].rare_type_cd = r.rare_type_cd, reply->rare[x].rare_type_id = r.rare_id
     WITH nocounter, forupdate(r)
    ;end select
    UPDATE  FROM bbd_rare_types r
     SET r.active_ind = 0, r.updt_applctx = reqinfo->updt_applctx, r.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_cnt = (r.updt_cnt+ 1)
     WHERE (r.rare_id=request->rare[x].rare_id)
      AND (r.updt_cnt=request->rare[x].updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.status = "S"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "BBD_RARE_TYPES"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Update error..."
     GO TO exit_script
    ELSE
     SET reply->rare[x].new_ind = 0
     SET reply->rare[x].updt_cnt = request->rare[x].updt_cnt
    ENDIF
   ELSEIF ((request->rare[x].add_mod=1))
    SET new_pathnet_seq = 0.0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    INSERT  FROM bbd_rare_types r
     SET r.rare_id = new_pathnet_seq, r.person_id = request->person_id, r.rare_type_cd = request->
      rare[x].rare_type_cd,
      r.active_ind = 1, r.active_status_cd = reqdata->active_status_cd, r.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      r.active_status_prsnl_id = reqinfo->updt_id, r.updt_applctx = reqinfo->updt_applctx, r
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.status = "S"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "BBD_RARE_TYPES"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Insert error..."
     GO TO exit_script
    ELSE
     SET reply->rare[x].new_ind = 1
     SET reply->rare[x].rare_type_cd = request->rare[x].rare_type_cd
     SET reply->rare[x].rare_type_id = new_pathnet_seq
     SET reply->rare[x].updt_cnt = 0
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->special,scount)
 FOR (y = 1 TO scount)
   IF ((request->special[y].add_mod=0))
    SELECT INTO "nl:"
     i.special_interest_id
     FROM bbd_special_interest i
     WHERE (i.special_interest_id=request->special[y].special_interest_id)
      AND (i.updt_cnt=request->special[y].updt_cnt)
     DETAIL
      reply->special[y].special_interest_cd = i.special_interest_cd, reply->special[y].
      special_interest_id = i.special_interest_id
     WITH nocounter, forupdate(i)
    ;end select
    UPDATE  FROM bbd_special_interest i
     SET i.active_ind = 0, i.updt_applctx = reqinfo->updt_applctx, i.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      i.updt_id = reqinfo->updt_id, i.updt_task = reqinfo->updt_task, i.updt_cnt = (i.updt_cnt+ 1)
     WHERE (i.special_interest_id=request->special[y].special_interest_id)
      AND (i.updt_cnt=request->special[y].updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.status = "S"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "BBD_SPECIAL_INTEREST"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Update error..."
     GO TO exit_script
    ELSE
     SET reply->special[y].new_ind = 0
     SET reply->special[y].updt_cnt = (request->special[y].updt_cnt+ 1)
    ENDIF
   ELSEIF ((request->special[y].add_mod=1))
    SET new_pathnet_seq = 0.0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    INSERT  FROM bbd_special_interest i
     SET i.special_interest_id = new_pathnet_seq, i.person_id = request->person_id, i
      .special_interest_cd = request->special[y].special_interest_cd,
      i.active_ind = 1, i.active_status_cd = reqdata->active_status_cd, i.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      i.active_status_prsnl_id = reqinfo->updt_id, i.updt_applctx = reqinfo->updt_applctx, i
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      i.updt_id = reqinfo->updt_id, i.updt_task = reqinfo->updt_task, i.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.status = "S"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "BBD_SPECIAL_INTEREST"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Insert error..."
     GO TO exit_script
    ELSE
     SET reply->special[y].new_ind = 1
     SET reply->special[y].special_interest_cd = request->special[y].special_interest_cd
     SET reply->special[y].special_interest_id = new_pathnet_seq
     SET reply->special[y].updt_cnt = 0
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->contact_method,mcount)
 FOR (z = 1 TO mcount)
   IF ((request->contact_method[z].add_mod=0))
    SELECT INTO "nl:"
     cm.contact_method_id
     FROM bbd_contact_method cm
     WHERE (cm.contact_method_id=request->contact_method[z].contact_method_id)
      AND (cm.updt_cnt=request->contact_method[z].updt_cnt)
     DETAIL
      reply->contact_method[z].contact_method_cd = cm.contact_method_cd, reply->contact_method[z].
      contact_method_id = cm.contact_method_id
     WITH nocounter, forupdate(cm)
    ;end select
    UPDATE  FROM bbd_contact_method cm
     SET cm.active_ind = 0, cm.updt_applctx = reqinfo->updt_applctx, cm.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      cm.updt_id = reqinfo->updt_id, cm.updt_task = reqinfo->updt_task, cm.updt_cnt = (cm.updt_cnt+ 1
      )
     WHERE (cm.contact_method_id=request->contact_method[z].contact_method_id)
      AND (cm.updt_cnt=request->contact_method[z].updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.status = "S"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "BBD_CONTACT_METHOD"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Update error..."
     GO TO exit_script
    ELSE
     SET reply->contact_method[z].new_ind = 0
     SET reply->contact_method[z].updt_cnt = (request->contact_method[z].updt_cnt+ 1)
    ENDIF
   ELSEIF ((request->contact_method[z].add_mod=1))
    SET new_pathnet_seq = 0.0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = cnvtreal(seqn)
     WITH format, nocounter
    ;end select
    INSERT  FROM bbd_contact_method cm
     SET cm.contact_method_id = new_pathnet_seq, cm.contact_method_cd = request->contact_method[z].
      contact_method_cd, cm.active_ind = 1,
      cm.person_id = request->person_id, cm.updt_applctx = reqinfo->updt_applctx, cm.updt_cnt = 0,
      cm.updt_dt_tm = cnvtdatetime(curdate,curtime3), cm.updt_id = reqinfo->updt_id, cm.updt_task =
      reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.status = "S"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "BBD_CONTACT_METHOD"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Insert error..."
     GO TO exit_script
    ELSE
     SET reply->contact_method[z].new_ind = 1
     SET reply->contact_method[z].contact_method_cd = request->contact_method[z].contact_method_cd
     SET reply->contact_method[z].contact_method_id = new_pathnet_seq
     SET reply->contact_method[z].updt_cnt = 0
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
