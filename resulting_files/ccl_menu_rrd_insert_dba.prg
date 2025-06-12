CREATE PROGRAM ccl_menu_rrd_insert:dba
 SET nbr = 0
 SET menu_id = 99.9
 SELECT
  e.menu_id
  FROM explorer_menu e
  DETAIL
   nbr = (nbr+ 1), menu_id = e.menu_id
  WITH check, nocounter, noforms
 ;end select
 SET menu_empty = 1
 SET item_name = fillstring(25," ")
 SET item_desc = fillstring(40," ")
 IF (nbr=1)
  IF (menu_id=0)
   DELETE  FROM explorer_menu e
    WHERE e.menu_id=0
    WITH check, nocounter
   ;end delete
  ELSE
   SET menu_empty = 0
  ENDIF
 ELSEIF (nbr > 1)
  SET menu_empty = 0
 ENDIF
 SET item_name = "RRD"
 SET item_desc = "Remote Report Distribution"
 SET item_type = "M"
 SET parent_id = 0.0
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET parent_id = 0.00
 SELECT
  e.menu_id, e.item_name
  FROM explorer_menu e
  WHERE e.item_name="RRD"
  DETAIL
   parent_id = e.menu_id
  WITH check, nocounter, noforms
 ;end select
 SET item_name = "RRD_ADD_REQUEST_QUEUE"
 SET item_desc = "Add Test Report"
 SET item_type = "P"
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET item_name = "RRD_AUDIT_SESSION_BRIEF"
 SET item_desc = "Brief Session Log"
 SET item_type = "P"
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET item_name = "RRD_AUDIT_SESSION_LOG"
 SET item_desc = "Session Log"
 SET item_type = "P"
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET item_name = "RRD_AUDIT_DELIVERY_CLASS"
 SET item_desc = "Delivery Class Audit"
 SET item_type = "P"
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET item_name = "RRD_AUDIT_STATIONS"
 SET item_desc = "Station Audit"
 SET item_type = "P"
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET item_name = "RRD_AUDIT_REPORT_QUEUE"
 SET item_desc = "Report Queue Audit"
 SET item_type = "P"
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET item_name = "RRD_RETRANSMIT_SESSION"
 SET item_desc = "Retransmit Options"
 SET item_type = "P"
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SUBROUTINE item_on_file(name,type)
  SELECT
   e.menu_id
   FROM explorer_menu e
   WHERE e.item_name=name
    AND e.item_type=type
   WITH check, nocounter, noforms
  ;end select
  IF (curqual > 0)
   SET item_on_file = 1
  ELSE
   SET item_on_file = 0
  ENDIF
 END ;Subroutine
 SUBROUTINE insert_item(name,desc,type,parent)
   INSERT  FROM explorer_menu e
    SET e.menu_id = seq(explorer_menu_seq,nextval), e.menu_parent_id = parent, e.person_id = 0.0,
     e.item_name = name, e.item_desc = desc, e.item_type = type,
     e.active_ind = 1
    WITH check, nocounter
   ;end insert
 END ;Subroutine
 COMMIT
#end_add
END GO
