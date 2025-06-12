CREATE PROGRAM dcp_del_orphan_except_id:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD priv_without_except
 RECORD priv_without_except(
   1 qual[*]
     2 privilege_id = f8
     2 new_privilege_value_cd = f8
 )
 FREE RECORD except_group_to_delete
 RECORD except_group_to_delete(
   1 dellist[*]
     2 log_grouping_cd = f8
 )
 DECLARE deleteprivilegeexception(null) = null
 DECLARE deleteexceptiongroupexceptions(null) = null
 DECLARE deleteexceptiongroup(null) = null
 DECLARE findprivilegewithoutexceptions(null) = null
 DECLARE updateprivilegewithoutexceptions(null) = null
 DECLARE exitscript(scriptstatus=vc) = null
 DECLARE stat2 = i4
 SET reply->status_data.status = "F"
 CALL deleteprivilegeexception(null)
 CALL deleteexceptiongroupexceptions(null)
 CALL deleteexceptiongroup(null)
 CALL findprivilegewithoutexceptions(null)
 CALL updateprivilegewithoutexceptions(null)
 CALL exitscript("S")
 SUBROUTINE deleteprivilegeexception(null)
   DELETE  FROM privilege_exception pe
    WHERE pe.exception_entity_name="V500_EVENT_SET_CODE"
     AND pe.exception_id != 0
     AND pe.active_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     ese.event_set_cd
     FROM v500_event_set_explode ese
     WHERE pe.exception_id=ese.event_set_cd)))
   ;end delete
 END ;Subroutine
 SUBROUTINE deleteexceptiongroupexceptions(null)
   DELETE  FROM log_group_entry lge
    WHERE lge.exception_entity_name="V500_EVENT_SET_CODE"
     AND lge.log_grouping_cd != 0
     AND lge.log_grouping_cd IN (
    (SELECT
     lg.log_grouping_cd
     FROM logical_grouping lg
     WHERE lg.log_grouping_cd != 0))
     AND  NOT ( EXISTS (
    (SELECT
     ese.event_set_cd
     FROM v500_event_set_explode ese
     WHERE lge.item_cd=ese.event_set_cd)))
   ;end delete
 END ;Subroutine
 SUBROUTINE deleteexceptiongroup(null)
   DECLARE loop_counter = i4 WITH noconstant(0)
   SELECT DISTINCT INTO "NL:"
    FROM logical_grouping lg
    WHERE lg.log_grouping_cd != 0
     AND  NOT (lg.log_grouping_cd IN (
    (SELECT DISTINCT
     lge.log_grouping_cd
     FROM log_group_entry lge
     WHERE lge.log_grouping_cd != 0)))
    ORDER BY lg.log_grouping_cd
    DETAIL
     lg.log_grouping_cd, loop_counter = (loop_counter+ 1)
     IF (mod(loop_counter,10)=1)
      stat2 = alterlist(except_group_to_delete->dellist,(loop_counter+ 9))
     ENDIF
     except_group_to_delete->dellist[loop_counter].log_grouping_cd = lg.log_grouping_cd
    WITH nocounter
   ;end select
   SET stat2 = alterlist(except_group_to_delete->dellist,loop_counter)
   IF (loop_counter > 0)
    EXECUTE dcp_del_group  WITH replace("REQUEST","EXCEPT_GROUP_TO_DELETE"), replace("REPLY",
     "EXCEPT_GROUP_REPLY")
    IF ((except_group_delete->status_data.status="F"))
     CALL exitscript("F")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE findprivilegewithoutexceptions(null)
   DECLARE yes_priv_value_cd = f8 WITH protect
   SET yes_priv_value_cd = uar_get_code_by("MEANING",6017,"YES")
   DECLARE no_priv_value_cd = f8 WITH protect
   SET no_priv_value_cd = uar_get_code_by("MEANING",6017,"NO")
   DECLARE yes_except_priv_value_cd = f8 WITH protect
   SET yes_except_priv_value_cd = uar_get_code_by("MEANING",6017,"EXCLUDE")
   DECLARE no_except_priv_value_cd = f8 WITH protect
   SET no_except_priv_value_cd = uar_get_code_by("MEANING",6017,"INCLUDE")
   SET stat2 = initrec(priv_without_except)
   DECLARE loop_counter = i4 WITH noconstant(0)
   SELECT INTO "NL:"
    FROM privilege p,
     priv_loc_reltn plr
    PLAN (p
     WHERE p.priv_value_cd IN (yes_except_priv_value_cd, no_except_priv_value_cd)
      AND  NOT (p.privilege_id IN (
     (SELECT
      pe1.privilege_id
      FROM privilege_exception pe1
      WHERE pe1.active_ind=1)))
      AND p.active_ind=1)
     JOIN (plr
     WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id)
    ORDER BY p.privilege_id
    DETAIL
     loop_counter = (loop_counter+ 1)
     IF (mod(loop_counter,50)=1)
      stat2 = alterlist(priv_without_except->qual,(loop_counter+ 49))
     ENDIF
     priv_without_except->qual[loop_counter].privilege_id = p.privilege_id
     IF (p.priv_value_cd=yes_except_priv_value_cd)
      priv_without_except->qual[loop_counter].new_privilege_value_cd = yes_priv_value_cd
     ELSEIF (p.priv_value_cd=no_except_priv_value_cd)
      priv_without_except->qual[loop_counter].new_privilege_value_cd = no_priv_value_cd
     ENDIF
    WITH nocounter
   ;end select
   SET stat2 = alterlist(priv_without_except->qual,loop_counter)
 END ;Subroutine
 SUBROUTINE updateprivilegewithoutexceptions(null)
   IF (value(size(priv_without_except->qual,5)) > 0)
    UPDATE  FROM privilege p,
      (dummyt d  WITH seq = value(size(priv_without_except->qual,5)))
     SET p.priv_value_cd = priv_without_except->qual[d.seq].new_privilege_value_cd, p.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1),
      p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
      updt_applctx
     PLAN (d
      WHERE (priv_without_except->qual[d.seq].new_privilege_value_cd != 0))
      JOIN (p
      WHERE (p.privilege_id=priv_without_except->qual[d.seq].privilege_id)
       AND p.active_ind=1)
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE exitscript(scriptstatus)
  IF (scriptstatus="F")
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
  ELSEIF (scriptstatus="S")
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ENDIF
  GO TO endscript
 END ;Subroutine
#endscript
 FREE RECORD priv_without_except
 FREE RECORD except_group_to_delete
END GO
