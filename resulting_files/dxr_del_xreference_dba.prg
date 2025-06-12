CREATE PROGRAM dxr_del_xreference:dba
 RECORD reply(
   1 rec_status = c1
   1 qual[1]
     2 del_status = c1
     2 dept_cat_xref_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET number_to_del = size(request->qual,5)
 SET cur_updt_cnt[value(number_to_del)] = 0
 SET y = 0
 SET stat = alter(reply->qual,value(number_to_del))
 SELECT INTO "nl:"
  dx.updt_cnt
  FROM dept_xreference dx,
   (dummyt d  WITH seq = value(number_to_del))
  PLAN (d)
   JOIN (dx
   WHERE (dx.dept_cat_xref_id=request->qual[d.seq].dept_cat_xref_id))
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), cur_updt_cnt[count1] = dx.updt_cnt
  WITH nocounter, forupdate(dx)
 ;end select
 IF (count1 != number_to_del)
  SET reply->rec_status = "N"
 ELSE
  FOR (x = 1 TO number_to_del)
    SET y = (y+ 1)
    SET reply->qual[y].dept_cat_xref_id = request->qual[x].dept_cat_xref_id
    IF ((cur_updt_cnt[x] != request->qual[x].updt_cnt))
     SET reply->qual[y].del_status = "U"
    ELSE
     UPDATE  FROM dept_xreference dx
      SET dx.updt_id = reqinfo->updt_id, dx.updt_cnt = (dx.updt_cnt+ 1), dx.updt_task = reqinfo->
       updt_task,
       dx.updt_dt_tm = cnvtdatetime(curdate,curtime3), dx.updt_applctx = reqinfo->updt_applctx, dx
       .active_ind = 0,
       dx.active_status_prsnl_id = reqinfo->updt_id, dx.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), dx.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (dx.dept_cat_xref_id=request->qual[x].dept_cat_xref_id)
      WITH nocounter
     ;end update
     IF (curqual != 1)
      SET reply->qual[y].del_status = "V"
      ROLLBACK
     ELSE
      SET reply->qual[y].del_status = "S"
      COMMIT
     ENDIF
    ENDIF
    CALL echo(build("Status:",reply->qual[x].del_status))
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
END GO
