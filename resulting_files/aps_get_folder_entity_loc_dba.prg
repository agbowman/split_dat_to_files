CREATE PROGRAM aps_get_folder_entity_loc:dba
 RECORD input_rec(
   1 qual[*]
     2 prev_table = vc
     2 prev_id = f8
     2 new_table = vc
     2 new_id = f8
 )
 RECORD chg_loc_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET failed = "F"
 SET qual_index = 0
 SET event_rep_cnt = cnvtint(size(event_rep->rb_list,5))
 SET event_index = 0
 SET input_rec_cnt = 0
 SET bfound = "F"
 SET bfromeventserver = " "
 IF (validate(request->qual[1].prev_table,"N")="N")
  SET bfromeventserver = "F"
  CALL echo("APS_GET_FOLDER_ENTITY_LOC::This is not from the event server.")
  SET qual_cnt = cnvtint(size(event_req->qual,5))
 ELSE
  SET bfromeventserver = "T"
  CALL echo("APS_GET_FOLDER_ENTITY_LOC::This is from the event server.")
  SET qual_cnt = cnvtint(size(request->qual,5))
 ENDIF
 CALL echo(build("APS_GET_FOLDER_ENTITY_LOC::qual_cnt is: ",qual_cnt))
 FOR (qual_index = 1 TO qual_cnt)
   SET event_index = 0
   SET bfound = "F"
   WHILE (event_index <= event_rep_cnt
    AND bfound="F")
    SET event_index = (event_index+ 1)
    IF (bfromeventserver="T")
     IF (trim(request->qual[qual_index].reference_nbr)=trim(event_rep->rb_list[event_index].
      reference_nbr))
      SET bfound = "T"
     ENDIF
    ELSE
     IF (trim(event_req->qual[qual_index].reference_nbr)=trim(event_rep->rb_list[event_index].
      reference_nbr))
      SET bfound = "T"
     ENDIF
    ENDIF
   ENDWHILE
   IF (bfound="T")
    SET input_rec_cnt = (input_rec_cnt+ 1)
    SET stat = alterlist(input_rec->qual,input_rec_cnt)
    IF (bfromeventserver="T")
     SET input_rec->qual[input_rec_cnt].prev_table = request->qual[qual_index].prev_table
     SET input_rec->qual[input_rec_cnt].prev_id = request->qual[qual_index].prev_id
    ELSE
     SET input_rec->qual[input_rec_cnt].prev_table = event_req->qual[qual_index].prev_table
     SET input_rec->qual[input_rec_cnt].prev_id = event_req->qual[qual_index].prev_id
    ENDIF
    SET input_rec->qual[input_rec_cnt].new_table = "CLINICAL_EVENT"
    SET input_rec->qual[input_rec_cnt].new_id = event_rep->rb_list[event_index].event_id
   ENDIF
 ENDFOR
 IF (input_rec_cnt > 0)
  EXECUTE aps_chg_folder_entity_loc
  IF ((chg_loc_reply->status_data.status != "S"))
   GO TO chg_loc_failed
  ENDIF
 ENDIF
 GO TO exit_script
#chg_loc_failed
 IF (bfromeventserver="T")
  SET reply->status_data.subeventstatus[1].operationname = chg_loc_reply->status_data.subeventstatus[
  1].operationname
  SET reply->status_data.subeventstatus[1].operationstatus = chg_loc_reply->status_data.
  subeventstatus[1].operationstatus
  SET reply->status_data.subeventstatus[1].targetobjectname = chg_loc_reply->status_data.
  subeventstatus[1].targetobjectname
  SET reply->status_data.subeventstatus[1].targetobjectvalue = chg_loc_reply->status_data.
  subeventstatus[1].targetobjectvalue
 ELSE
  SET get_loc_rep->status_data.subeventstatus[1].operationname = chg_loc_reply->status_data.
  subeventstatus[1].operationname
  SET get_loc_rep->status_data.subeventstatus[1].operationstatus = chg_loc_reply->status_data.
  subeventstatus[1].operationstatus
  SET get_loc_rep->status_data.subeventstatus[1].targetobjectname = chg_loc_reply->status_data.
  subeventstatus[1].targetobjectname
  SET get_loc_rep->status_data.subeventstatus[1].targetobjectvalue = chg_loc_reply->status_data.
  subeventstatus[1].targetobjectvalue
 ENDIF
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (bfromeventserver="T")
  IF (failed="F")
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "F"
  ENDIF
 ELSE
  IF (failed="F")
   SET get_loc_rep->status_data.status = "S"
  ELSE
   SET get_loc_rep->status_data.status = "F"
  ENDIF
 ENDIF
END GO
