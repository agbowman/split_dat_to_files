CREATE PROGRAM cp_upd_chart_category:dba
 RECORD reply(
   1 qual[*]
     2 chart_category_id = f8
     2 chart_category_name = c50
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (validate(gen_nbr_error,- (1)) != 3)
  DECLARE gen_nbr_error = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(insert_error,- (1)) != 4)
  DECLARE insert_error = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(update_error,- (1)) != 5)
  DECLARE update_error = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(replace_error,- (1)) != 6)
  DECLARE replace_error = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(delete_error,- (1)) != 7)
  DECLARE delete_error = i2 WITH protect, noconstant(7)
 ENDIF
 IF (validate(undelete_error,- (1)) != 8)
  DECLARE undelete_error = i2 WITH protect, noconstant(8)
 ENDIF
 IF (validate(remove_error,- (1)) != 9)
  DECLARE remove_error = i2 WITH protect, noconstant(9)
 ENDIF
 IF (validate(attribute_error,- (1)) != 10)
  DECLARE attribute_error = i2 WITH protect, noconstant(10)
 ENDIF
 IF (validate(lock_error,- (1)) != 11)
  DECLARE lock_error = i2 WITH protect, noconstant(11)
 ENDIF
 IF (validate(none_found,- (1)) != 12)
  DECLARE none_found = i2 WITH protect, noconstant(12)
 ENDIF
 IF (validate(select_error,- (1)) != 13)
  DECLARE select_error = i2 WITH protect, noconstant(13)
 ENDIF
 IF (validate(insert_duplicate,- (1)) != 14)
  DECLARE version_insert_error = i2 WITH protect, noconstant(16)
 ENDIF
 IF (validate(uar_error,- (1)) != 20)
  DECLARE uar_error = i2 WITH protect, noconstant(20)
 ENDIF
 IF (validate(failed,- (1)) != 0)
  DECLARE failed = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH protect, noconstant(" ")
 ELSE
  SET table_name = fillstring(50," ")
 ENDIF
 IF (validate(error_value,"ZZZ")="ZZZ")
  DECLARE error_value = vc WITH protect, noconstant(fillstring(150," "))
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE category_sequence = i2 WITH public, noconstant(0)
 DECLARE new_nbr = f8 WITH public, noconstant(0.0)
 DECLARE cnt = i2 WITH public, noconstant(0)
 DECLARE add_qual_size = i2 WITH public, noconstant(0)
 DECLARE chg_qual_size = i2 WITH public, noconstant(0)
 DECLARE chart_sect_size = i2 WITH public, noconstant(0)
 SET add_qual_size = size(request->add_qual,5)
 SET chg_qual_size = size(request->chg_qual,5)
 SET stat = alterlist(reply->qual,add_qual_size)
 FOR (cnt = 1 TO add_qual_size)
   SELECT INTO "nl:"
    w = seq(chart_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_nbr = cnvtreal(w)
    WITH format, counter
   ;end select
   INSERT  FROM chart_category c
    SET c.chart_category_id = new_nbr, c.category_name = request->add_qual[cnt].category_name, c
     .category_seq = request->add_qual[cnt].category_seq,
     c.sensitive_ind = request->add_qual[cnt].sensitive_ind, c.expandable_doc_ind = request->
     add_qual[cnt].expandable_doc_ind, c.parent_category_id = request->add_qual[cnt].
     parent_category_id,
     c.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), c.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     c.updt_id = reqinfo->updt_id, c.updt_cnt = 0, c.updt_applctx = reqinfo->updt_applctx,
     c.updt_task = reqinfo->updt_task, c.active_ind = 1, c.active_status_cd = reqdata->
     active_status_cd,
     c.active_status_dt_tm = cnvtdatetime(curdate,curtime3), c.active_status_prsnl_id = reqinfo->
     updt_id
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = insert_error
    GO TO check_error
   ENDIF
   SET reply->qual[cnt].chart_category_id = new_nbr
   SET reply->qual[cnt].chart_category_name = request->add_qual[cnt].category_name
 ENDFOR
 IF (chg_qual_size=0)
  GO TO check_error
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(chg_qual_size)),
   chart_category c
  SET c.seq = 1, c.category_name = request->chg_qual[d.seq].category_name, c.category_seq = request->
   chg_qual[d.seq].category_seq,
   c.sensitive_ind = request->chg_qual[d.seq].sensitive_ind, c.expandable_doc_ind = request->
   chg_qual[d.seq].expandable_doc_ind, c.parent_category_id = request->chg_qual[d.seq].
   parent_category_id,
   c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_cnt = (c
   .updt_cnt+ 1),
   c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (request->chg_qual[d.seq].chart_category_id > 0)
    AND (request->chg_qual[d.seq].active_ind=1))
   JOIN (c
   WHERE (c.chart_category_id=request->chg_qual[d.seq].chart_category_id))
  WITH nocounter
 ;end update
 FOR (cnt = 1 TO chg_qual_size)
   DELETE  FROM chart_category c
    WHERE (request->chg_qual[cnt].active_ind=0)
     AND (c.chart_category_id=request->chg_qual[cnt].chart_category_id)
   ;end delete
 ENDFOR
 UPDATE  FROM (dummyt d  WITH seq = value(chg_qual_size)),
   chart_category c
  SET c.seq = 1, c.category_seq = (c.category_seq - 1)
  PLAN (d
   WHERE (request->chg_qual[d.seq].chart_category_id > 0)
    AND (request->chg_qual[d.seq].active_ind=0))
   JOIN (c
   WHERE (c.category_seq > request->chg_qual[d.seq].category_seq))
 ;end update
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
END GO
