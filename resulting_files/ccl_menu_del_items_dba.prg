CREATE PROGRAM ccl_menu_del_items:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((request->menu_id_f8=0))
  SET request->menu_id_f8 = request->menu_id
 ENDIF
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET errmsg = fillstring(255," ")
 SET save_curqual = 0
 SET itemsize = 10
 SET menusize = 10
 SET stat = memalloc(item,itemsize,"I4")
 SET stat = memalloc(menu,menusize,"I4")
 SET itemct = 0
 SET menuct = 0
 SET ct = 0
 SET xx = initarray(item,0)
 SET xx = initarray(menu,0)
 SET id = request->menu_id_f8
 UPDATE  FROM explorer_menu e
  SET e.active_ind = 0, e.updt_dt_tm = cnvtdatetime(sysdate), e.updt_id = reqinfo->updt_id,
   e.updt_task = reqinfo->updt_task, e.updt_cnt = (e.updt_cnt+ 1), e.updt_applctx = reqinfo->
   updt_applctx
  WHERE (e.menu_id=request->menu_id_f8)
  WITH nocounter
 ;end update
 IF (curqual > 0)
  SET save_curqual = curqual
 ENDIF
 IF ((request->item_type IN ("M", "N")))
  CALL submenu(id)
  WHILE (menuct > ct)
    SET ct += 1
    SET id = menu[ct]
    CALL submenu(id)
  ENDWHILE
  FOR (n = 1 TO itemsize)
    IF ((item[n] > 0))
     UPDATE  FROM explorer_menu e
      SET e.active_ind = 0, e.updt_dt_tm = cnvtdatetime(sysdate), e.updt_id = reqinfo->updt_id,
       e.updt_task = reqinfo->updt_task, e.updt_cnt = (e.updt_cnt+ 1), e.updt_applctx = reqinfo->
       updt_applctx
      WHERE (e.menu_id=item[n])
      WITH nocounter
     ;end update
     SET save_curqual += curqual
    ENDIF
  ENDFOR
 ENDIF
 DELETE  FROM explorer_menu_security es
  WHERE (es.menu_id=request->menu_id_f8)
  WITH nocounter
 ;end delete
 IF (curqual > 0)
  SET save_curqual += curqual
 ENDIF
 IF (save_curqual > 0)
  SET reply->status_data.status = "S"
  SET failed = "F"
  GO TO exit_del_items
 ELSE
  SET errcode = error(errmsg,1)
  SET failed = "T"
  GO TO exit_del_items
 ENDIF
 SUBROUTINE submenu(idx)
   SELECT
    e.menu_id, e.item_type
    FROM explorer_menu e
    WHERE e.menu_parent_id=idx
    DETAIL
     IF (itemct=itemsize)
      itemsize += 10, stat = memrealloc(item,itemsize,"I4")
     ENDIF
     itemct += 1, item[itemct] = e.menu_id
     IF (e.item_type IN ("M", "N"))
      IF (menuct=menusize)
       menusize += 10, stat = memrealloc(menu,menusize,"I4")
      ENDIF
      menuct += 1, menu[menuct] = e.menu_id
     ENDIF
    WITH check, nocounter
   ;end select
 END ;Subroutine
#exit_del_items
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[0].operationname = "delete"
  SET reply->status_data.subeventstatus[0].operationstatus = "F"
  SET reply->status_data.subeventstatus[0].targetobjectname = "ccl_menu_del_items"
  SET reply->status_data.subeventstatus[0].targetobjectvalue = errmsg
  GO TO endit
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  GO TO endit
 ENDIF
#endit
 CALL echorecord(reply)
END GO
