CREATE PROGRAM bed_ens_of_start_parent_rel:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 tlist[*]
     2 alt_sel_category_id = f8
 )
 SET reply->status_data.status = "F"
 SET stat = alterlist(temp->tlist,10)
 SET tcnt = 0
 SET alterlist_tcnt = 0
 SELECT INTO "NL:"
  FROM alt_sel_cat a,
   br_of_parent_reltn b
  PLAN (a
   WHERE a.alt_sel_category_id > 0)
   JOIN (b
   WHERE b.alt_sel_category_id=outerjoin(a.alt_sel_category_id))
  DETAIL
   IF (b.source_name > " ")
    tcnt = tcnt
   ELSE
    alterlist_tcnt = (alterlist_tcnt+ 1)
    IF (alterlist_tcnt > 10)
     stat = alterlist(temp->tlist,(tcnt+ 10)), alterlist_tcnt = 1
    ENDIF
    tcnt = (tcnt+ 1), temp->tlist[tcnt].alt_sel_category_id = a.alt_sel_category_id
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(temp->tlist,tcnt)
 FOR (t = 1 TO tcnt)
   INSERT  FROM br_of_parent_reltn b
    SET b.alt_sel_category_id = temp->tlist[t].alt_sel_category_id, b.source_id = 0.0, b.source_name
      = "START",
     b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 CALL echorecord(reply)
END GO
