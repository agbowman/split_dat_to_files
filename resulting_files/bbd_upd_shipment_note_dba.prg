CREATE PROGRAM bbd_upd_shipment_note:dba
 RECORD reply(
   1 shipment_updt_cnt = i4
   1 long_text = vc
   1 long_text_id = f8
   1 long_text_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 RECORD hold_text(
   1 text = vc
 )
 RECORD new_text(
   1 text = vc
 )
 DECLARE text_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET text_id = 0.0
 SET shipment_updt_cnt = 0
 SET dt_tm_text = concat(trim(format(curdate,"mm/dd/yyyy;;d"))," ",trim(format(curtime,"hh:mm;;m")))
 SELECT INTO "nl:"
  s.updt_cnt
  FROM bb_shipment s
  PLAN (s
   WHERE (s.shipment_id=request->shipment_id))
  HEAD REPORT
   shipment_updt_cnt = s.updt_cnt
  WITH nocounter
 ;end select
 IF ((request->new_indicator=1))
  SET hold_text->text = concat(">> ",trim(dt_tm_text),"  ",trim(request->user_name),"   ",
   trim(request->long_text))
  SELECT INTO "nl:"
   seqn = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    text_id = seqn
   WITH format, nocounter
  ;end select
  INSERT  FROM long_text l
   SET l.long_text_id = text_id, l.parent_entity_name = "BB_SHIPMENT", l.parent_entity_id = request->
    shipment_id,
    l.long_text = hold_text->text, l.updt_cnt = 0, l.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
    updt_applctx,
    l.active_ind = 1, l.active_status_cd = reqdata->active_status_cd, l.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    l.active_status_prsnl_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status = "S"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_note.prg"
   SET reply->status_data.subeventstatus[1].operationname = "Insert"
   SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error inserting a shipment note into the long_text table."
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   s.*
   FROM bb_shipment s
   WHERE (s.shipment_id=request->shipment_id)
    AND s.updt_cnt=shipment_updt_cnt
   WITH counter, forupdate(s)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_note.prg"
   SET reply->status_data.subeventstatus[1].operationname = "Update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "BB_SHIPMENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error locking the bb_shipment table."
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 2
   GO TO exit_script
  ENDIF
  UPDATE  FROM bb_shipment s
   SET s.long_text_id = text_id, s.updt_cnt = (s.updt_cnt+ 1), s.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
    updt_applctx
   WHERE (s.shipment_id=request->shipment_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_note.prg"
   SET reply->status_data.subeventstatus[1].operationname = "Update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "BB_SHIPMENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error updating a shipment note ID into the bb_shipment table."
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 3
   GO TO exit_script
  ELSE
   SET shipment_updt_cnt = (shipment_updt_cnt+ 1)
   SET reply->shipment_updt_cnt = shipment_updt_cnt
   SET reply->long_text = hold_text->text
   SET reply->long_text_id = text_id
   SET reply->long_text_updt_cnt = 0
  ENDIF
 ELSE
  SELECT INTO "nl:"
   l.*
   FROM long_text l
   WHERE (l.long_text_id=request->long_text_id)
    AND (l.updt_cnt=request->long_text_updt_cnt)
   DETAIL
    hold_text->text = l.long_text
   WITH counter, forupdate(l)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_note.prg"
   SET reply->status_data.subeventstatus[1].operationname = "Update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error locking the long_text table. "
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 4
   GO TO exit_script
  ENDIF
  IF ((request->add_indicator=1))
   SET new_text->text = concat(">> ",trim(dt_tm_text),"  ",trim(request->user_name),"   ",
    trim(request->long_text),char(13),char(10),char(13),char(10),
    trim(hold_text->text))
  ELSE
   SET new_text->text = trim(request->long_text)
  ENDIF
  UPDATE  FROM long_text lt
   SET lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id =
    reqinfo->updt_id,
    lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.long_text =
    new_text->text
   WHERE (lt.long_text_id=request->long_text_id)
    AND (lt.updt_cnt=request->long_text_updt_cnt)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_note.prg"
   SET reply->status_data.subeventstatus[1].operationname = "Update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error updating a row in the long_text table."
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 5
   GO TO exit_script
  ELSE
   SET shipment_updt_cnt = (shipment_updt_cnt+ 1)
   SET reply->shipment_updt_cnt = shipment_updt_cnt
   SET reply->long_text = new_text->text
   SET reply->long_text_id = request->long_text_id
   SET reply->long_text_updt_cnt = (request->long_text_updt_cnt+ 1)
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
