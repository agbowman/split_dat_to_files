CREATE PROGRAM ce_event_set_priv_sync:dba
 RECORD reply(
   1 reply_list[*]
     2 table_details = vc
     2 error_code = i4
     2 error_msg = vc
 )
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 DECLARE errorcnt = i4 WITH noconstant(0)
 RECORD list1(
   1 qual[*]
     2 event_set_name = vc
     2 event_set_cd = f8
     2 privilege_id = f8
     2 exception_type_cd = f8
 )
 DECLARE cnt1 = i4 WITH noconstant(0)
 SELECT DISTINCT INTO "nl:"
  es.event_set_cd, pe.event_set_name, pe.privilege_id,
  pe.exception_type_cd
  FROM privilege_exception pe,
   v500_event_set_code es,
   dummyt d
  PLAN (pe
   WHERE pe.exception_entity_name="V500_EVENT_SET_CODE")
   JOIN (d)
   JOIN (es
   WHERE cnvtupper(pe.event_set_name)=cnvtupper(es.event_set_name))
  DETAIL
   cnt1 += 1
   IF (mod(cnt1,10)=1)
    stat = alterlist(list1->qual,(cnt1+ 9))
   ENDIF
   list1->qual[cnt1].event_set_name = pe.event_set_name, list1->qual[cnt1].event_set_cd = es
   .event_set_cd, list1->qual[cnt1].privilege_id = pe.privilege_id,
   list1->qual[cnt1].exception_type_cd = pe.exception_type_cd
  WITH outerjoin = d, nocounter
 ;end select
 SET stat = alterlist(list1->qual,cnt1)
 FOR (forcount = 1 TO size(list1->qual,5))
   UPDATE  FROM privilege_exception pe
    SET pe.exception_id = list1->qual[forcount].event_set_cd, pe.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE (pe.event_set_name=list1->qual[forcount].event_set_name)
     AND (pe.privilege_id=list1->qual[forcount].privilege_id)
     AND (pe.exception_type_cd=list1->qual[forcount].exception_type_cd)
    WITH nocounter
   ;end update
   SET error_code = error(error_msg,0)
   IF (findstring("XUKPRIVILEGE_EXCEPTION",error_msg,1,1))
    UPDATE  FROM privilege_exception pe
     SET pe.exception_id = list1->qual[forcount].event_set_cd, pe.updt_dt_tm = cnvtdatetime(sysdate)
     WHERE (pe.event_set_name=list1->qual[forcount].event_set_name)
      AND (pe.privilege_id=list1->qual[forcount].privilege_id)
      AND (pe.exception_type_cd=list1->qual[forcount].exception_type_cd)
     WITH maxqual(pe,1), nocounter
    ;end update
    DELETE  FROM privilege_exception pe
     WHERE (pe.exception_id != list1->qual[forcount].event_set_cd)
      AND (pe.event_set_name=list1->qual[forcount].event_set_name)
      AND (pe.privilege_id=list1->qual[forcount].privilege_id)
      AND (pe.exception_type_cd=list1->qual[forcount].exception_type_cd)
     WITH nocounter
    ;end delete
   ELSEIF (error_code)
    CALL errorprocess(error_code,error_msg,"PRIVILEGE_EXCEPTION","Privilege_id",cnvtstring(list1->
      qual[forcount].privilege_id))
   ENDIF
 ENDFOR
 RECORD log_group_entry_list(
   1 qual[*]
     2 event_set_name = vc
     2 event_set_cd = f8
     2 log_grouping_comp_cd = f8
 )
 DECLARE cnt = i4 WITH noconstant(0)
 SELECT DISTINCT INTO "nl:"
  FROM log_group_entry lge,
   v500_event_set_code es
  WHERE lge.event_set_name=es.event_set_name
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(log_group_entry_list->qual,(cnt+ 9))
   ENDIF
   log_group_entry_list->qual[cnt].event_set_name = lge.event_set_name, log_group_entry_list->qual[
   cnt].event_set_cd = es.event_set_cd, log_group_entry_list->qual[cnt].log_grouping_comp_cd = lge
   .log_grouping_comp_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(log_group_entry_list->qual,cnt)
 FOR (forcount = 1 TO size(log_group_entry_list->qual,5))
   UPDATE  FROM log_group_entry lge
    SET lge.item_cd = log_group_entry_list->qual[forcount].event_set_cd, lge.updt_dt_tm =
     cnvtdatetime(sysdate)
    WHERE (lge.event_set_name=log_group_entry_list->qual[forcount].event_set_name)
    WITH nocounter
   ;end update
   SET error_code = error(error_msg,0)
   IF (error_code)
    CALL errorprocess(error_code,error_msg,"LOG_GROUP_ENTRY","Log_Group_Comp_Cd",cnvtstring(
      log_group_entry_list->qual[forcount].log_grouping_comp_cd))
   ENDIF
 ENDFOR
 RECORD inactiveprivexceptions(
   1 qual[*]
     2 privilege_id = f8
 )
 DECLARE cnt2 = i4 WITH noconstant(0)
 DECLARE deletepriv = i4 WITH noconstant(0)
 SELECT DISTINCT INTO "nl:"
  pe.privilege_id
  FROM privilege_exception pe
  PLAN (pe
   WHERE pe.exception_id=0
    AND pe.exception_entity_name="V500_EVENT_SET_CODE")
  DETAIL
   cnt2 += 1
   IF (mod(cnt2,10)=1)
    stat = alterlist(inactiveprivexceptions->qual,(cnt2+ 9))
   ENDIF
   inactiveprivexceptions->qual[cnt2].privilege_id = pe.privilege_id
  WITH nocounter
 ;end select
 SET stat = alterlist(inactiveprivexceptions->qual,cnt2)
 DELETE  FROM privilege_exception pe
  WHERE pe.exception_id=0
   AND pe.exception_entity_name="V500_EVENT_SET_CODE"
  WITH nocounter
 ;end delete
 SET error_code = error(error_msg,0)
 IF (error_code)
  CALL errorprocess(error_code,error_msg,"PRIVILEGE_EXCEPTION","EXCEPTION_ENTITY_NAME",
   "V500_EVENT_SET_CODE")
 ENDIF
 FOR (forcount = 1 TO size(inactiveprivexceptions->qual,5))
   SET deletepriv = 1
   SELECT INTO "nl:"
    FROM privilege_exception ped
    PLAN (ped
     WHERE (ped.privilege_id=inactiveprivexceptions->qual[forcount].privilege_id))
    DETAIL
     deletepriv = 0
    WITH maxqual(ped,1), nocounter
   ;end select
   IF (deletepriv)
    CALL echo("*****DELETE privilege_id*******")
    CALL echo(inactiveprivexceptions->qual[forcount].privilege_id)
    DELETE  FROM privilege
     WHERE (privilege_id=inactiveprivexceptions->qual[forcount].privilege_id)
     WITH nocounter
    ;end delete
    SET error_code = error(error_msg,0)
    IF (error_code)
     CALL errorprocess(error_code,error_msg,"PRIVILEGE","Privilege_id",cnvtstring(
       inactiveprivexceptions->qual[forcount].privilege_id))
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE errorprocess(error_code,error_msg,table_name,id_name,table_id)
   SET errorcnt += 1
   SET stat = alterlist(reply->reply_list,errorcnt)
   SET reply->reply_list[errorcnt].error_code = error_code
   SET reply->reply_list[errorcnt].error_msg = error_msg
   SET reply->reply_list[errorcnt].table_details = concat("Error from table ",table_name,". ",id_name,
    " is ",
    table_id)
   RETURN
 END ;Subroutine
 COMMIT
#exit_script
 IF (value(size(reply->reply_list,5)))
  CALL echorecord(reply)
 ENDIF
END GO
