CREATE PROGRAM bed_get_cki_unmatched_items:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 data_item_id = vc
     2 data_item_disp = vc
     2 data_item_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 FREE SET temp
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 data_item_id = vc
     2 data_item_disp = vc
     2 data_item_desc = vc
     2 use_ind = i2
 )
 SET reply->too_many_results_ind = 0
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 IF ((request->max_reply > 0))
  SET max_reply = request->max_reply
 ELSE
  SET max_reply = 1000
 ENDIF
 DECLARE catalog_type = vc
 DECLARE activity_type = vc
 SET fcnt = size(request->flist,5)
 IF (fcnt > 0)
  FOR (x = 1 TO fcnt)
    IF ((request->flist[x].filter_type="CATALOG_TYPE"))
     SET catalog_type = trim(request->flist[x].filter_value)
    ELSEIF ((request->flist[x].filter_type="ACTIVITY_TYPE"))
     SET activity_type = trim(request->flist[x].filter_value)
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM br_cki_client_data b,
   br_cki_client_data_field f
  PLAN (b
   WHERE (b.client_id=request->client_id)
    AND (b.data_type_id=request->data_type_id))
   JOIN (f
   WHERE f.br_cki_client_data_id=b.br_cki_client_data_id)
  ORDER BY f.br_cki_client_data_id
  HEAD REPORT
   cnt = 0
  HEAD f.br_cki_client_data_id
   cnt = (cnt+ 1), temp->cnt = cnt, stat = alterlist(temp->qual,cnt),
   temp->qual[cnt].use_ind = 1
  DETAIL
   IF (catalog_type > " ")
    IF (f.field_nbr=4)
     IF (f.field_content != catalog_type)
      temp->qual[cnt].use_ind = 0
     ENDIF
    ENDIF
   ENDIF
   IF (activity_type > " ")
    IF (f.field_nbr=5)
     IF (f.field_content != activity_type)
      temp->qual[cnt].use_ind = 0
     ENDIF
    ENDIF
   ENDIF
   IF (f.field_nbr=10)
    temp->qual[cnt].data_item_id = f.field_content
   ENDIF
   IF (f.field_nbr=2)
    temp->qual[cnt].data_item_disp = f.field_content
   ENDIF
   IF (f.field_nbr=3)
    temp->qual[cnt].data_item_desc = f.field_content
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   br_cki_match m
  PLAN (d)
   JOIN (m
   WHERE (m.client_id=request->client_id)
    AND (m.data_type_id=request->data_type_id)
    AND (m.data_item=temp->qual[d.seq].data_item_id)
    AND (temp->qual[d.seq].use_ind=1))
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].use_ind = 0
  WITH nocounter
 ;end select
 SET rcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5)))
  PLAN (d
   WHERE (temp->qual[d.seq].data_item_id > " ")
    AND (temp->qual[d.seq].use_ind=1))
  ORDER BY temp->qual[d.seq].data_item_disp
  DETAIL
   rcnt = (rcnt+ 1)
   IF (rcnt <= max_reply)
    stat = alterlist(reply->qual,rcnt), reply->qual[rcnt].data_item_id = temp->qual[d.seq].
    data_item_id, reply->qual[rcnt].data_item_disp = temp->qual[d.seq].data_item_disp,
    reply->qual[rcnt].data_item_desc = temp->qual[d.seq].data_item_desc
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
 ELSEIF (rcnt > size(reply->qual,5))
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
