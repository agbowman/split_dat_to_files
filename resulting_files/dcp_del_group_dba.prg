CREATE PROGRAM dcp_del_group:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD privdellist(
   1 qual[*]
     2 privilege_id = f8
     2 exception_id = f8
 )
 RECORD orphanlist(
   1 qual[*]
     2 privilege_id = f8
 )
 RECORD undeleteableprivilegeexceptions(
   1 privileges[*]
     2 privilege_id = f8
     2 exception_cnt = i4
     2 exceptions[*]
       3 item_cd = f8
 )
 RECORD reqtemp(
   1 dellist[*]
     2 log_grouping_cd = f8
 )
 SET modify = predeclare
 DECLARE dellistcnt = i2 WITH constant(value(size(request->dellist,5)))
 DECLARE privdellistcnt = i2 WITH noconstant(0)
 DECLARE orphanlistcnt = i2 WITH noconstant(0)
 DECLARE privilegecount = i2 WITH noconstant(0)
 DECLARE exceptioncnt = i2 WITH noconstant(0)
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE stat = i4
 DECLARE batch_size = i4 WITH constant(40)
 DECLARE deletelogicalgrouping(null) = null
 DECLARE deleteloggroupentry(null) = null
 DECLARE fillprivdellist(null) = null
 DECLARE deleteprivilegeexception(null) = null
 DECLARE updateprivilege(null) = null
 DECLARE deleteloggrouptype(null) = null
 DECLARE insertprivilegedeletion(null) = null
 DECLARE deleteprivgroupreltns(null) = null
 DECLARE undeleteableprivilegeexceptions(null) = null
 DECLARE fillprivdellistmultiplegroups(null) = null
 DECLARE preprocessrequest(null) = null
 DECLARE dcp_script_version = vc
 DECLARE audittransaction(null) = null
 DECLARE audit_string = vc WITH public, noconstant(fillstring(132," "))
 DECLARE position = vc WITH public, noconstant(fillstring(132," "))
 DECLARE location = vc WITH public, noconstant(fillstring(132," "))
 DECLARE ppr = vc WITH public, noconstant(fillstring(132," "))
 DECLARE exception_audit_flag = i2 WITH public, noconstant(0)
 CALL preprocessrequest(null)
 CALL fillprivdellist(null)
 CALL retrieveundeletableexceptions(null)
 IF (size(undeleteableprivilegeexceptions->privileges,5) > 0)
  CALL fillprivdellistmultiplegroups(null)
 ENDIF
 IF (size(privdellist->qual,5) > 0)
  CALL deleteprivilegeexception(null)
 ENDIF
 CALL deleteprivgroupreltns(null)
 CALL deleteorphanedprivileges(null)
 CALL updateprivilege(null)
 CALL deleteloggroupentry(null)
 CALL deleteloggrouptype(null)
 CALL deletelogicalgrouping(null)
 CALL insertprivilegedeletion(null)
#exit_script
 FREE RECORD privdellist
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE preprocessrequest(null)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE new_list_size = i4
   DECLARE cur_list_size = i4
   DECLARE loop_cnt = i4
   SET stat = alterlist(reqtemp->dellist,size(request->dellist,5))
   FOR (i = 1 TO size(request->dellist,5))
     SET reqtemp->dellist[i].log_grouping_cd = request->dellist[i].log_grouping_cd
   ENDFOR
   SET cur_list_size = size(reqtemp->dellist,5)
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(reqtemp->dellist,new_list_size)
 END ;Subroutine
 SUBROUTINE insertprivilegedeletion(null)
   INSERT  FROM privilege_deletion pd,
     (dummyt d  WITH seq = dellistcnt)
    SET pd.privilege_deletion_id = cnvtreal(seq(reference_seq,nextval)), pd.log_grouping_cd = request
     ->dellist[d.seq].log_grouping_cd, pd.updt_id = reqinfo->updt_id,
     pd.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (d)
     JOIN (pd)
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE deletelogicalgrouping(null)
   DELETE  FROM logical_grouping lg,
     (dummyt d  WITH seq = dellistcnt)
    SET lg.seq = 1
    PLAN (d)
     JOIN (lg
     WHERE (lg.log_grouping_cd=request->dellist[d.seq].log_grouping_cd)
      AND lg.log_grouping_cd > 0)
   ;end delete
 END ;Subroutine
 SUBROUTINE deleteloggroupentry(null)
   DELETE  FROM log_group_entry lge,
     (dummyt d  WITH seq = dellistcnt)
    SET lge.seq = 1
    PLAN (d)
     JOIN (lge
     WHERE (lge.log_grouping_cd=request->dellist[d.seq].log_grouping_cd)
      AND lge.log_grouping_cd > 0)
    WITH nocounter
   ;end delete
 END ;Subroutine
 SUBROUTINE deleteloggrouptype(null)
   DELETE  FROM log_group_type lgt,
     (dummyt d  WITH seq = dellistcnt)
    SET lgt.seq = 1
    PLAN (d)
     JOIN (lgt
     WHERE (lgt.log_grouping_cd=request->dellist[d.seq].log_grouping_cd)
      AND lgt.log_grouping_cd > 0)
    WITH nocounter
   ;end delete
 END ;Subroutine
 SUBROUTINE deleteprivgroupreltns(null)
   DELETE  FROM priv_group_reltn pgr,
     (dummyt d  WITH seq = dellistcnt)
    SET pgr.seq = 1
    PLAN (d)
     JOIN (pgr
     WHERE (pgr.log_grouping_cd=request->dellist[d.seq].log_grouping_cd)
      AND pgr.log_grouping_cd > 0)
    WITH nocounter
   ;end delete
 END ;Subroutine
 SUBROUTINE fillprivdellist(null)
   SELECT INTO "nl:"
    FROM privilege p,
     log_group_entry lge,
     (dummyt d  WITH seq = dellistcnt)
    PLAN (d)
     JOIN (p
     WHERE (p.log_grouping_cd=request->dellist[d.seq].log_grouping_cd)
      AND p.privilege_id > 0)
     JOIN (lge
     WHERE (lge.log_grouping_cd=request->dellist[d.seq].log_grouping_cd)
      AND lge.item_cd > 0)
    HEAD REPORT
     privdellistcnt = 0
    DETAIL
     privdellistcnt = (privdellistcnt+ 1)
     IF (mod(privdellistcnt,10)=1)
      stat = alterlist(privdellist->qual,(privdellistcnt+ 9))
     ENDIF
     privdellist->qual[privdellistcnt].privilege_id = p.privilege_id, privdellist->qual[
     privdellistcnt].exception_id = lge.item_cd
    FOOT REPORT
     stat = alterlist(privdellist->qual,privdellistcnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE retrieveundeletableexceptions(null)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH noconstant(1)
   DECLARE loop_cnt = i4
   SET loop_cnt = ceil((cnvtreal(size(reqtemp->dellist,5))/ batch_size))
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE num2 = i4 WITH noconstant(0)
   DECLARE start2 = i4 WITH noconstant(1)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     priv_group_reltn pgr
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (pgr
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),pgr.log_grouping_cd,reqtemp->dellist[idx].
      log_grouping_cd)
      AND pgr.log_grouping_cd > 0)
    HEAD REPORT
     privilegecount = 0
    DETAIL
     num = 0, pos = locateval(num,start,size(undeleteableprivilegeexceptions->privileges,5),pgr
      .privilege_id,undeleteableprivilegeexceptions->privileges[num].privilege_id)
     IF (pos <= 0)
      privilegecount = (privilegecount+ 1)
      IF (mod(privilegecount,10)=1)
       stat = alterlist(undeleteableprivilegeexceptions->privileges,(privilegecount+ 9))
      ENDIF
      undeleteableprivilegeexceptions->privileges[privilegecount].privilege_id = pgr.privilege_id,
      undeleteableprivilegeexceptions->privileges[privilegecount].exception_cnt = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(undeleteableprivilegeexceptions->privileges,privilegecount)
    WITH nocounter
   ;end select
   DECLARE new_list_size = i4
   DECLARE cur_list_size = i4
   SET loop_cnt = ceil((cnvtreal(privilegecount)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(undeleteableprivilegeexceptions->privileges,new_list_size)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     priv_group_reltn pgr,
     log_group_entry lge
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (pgr
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),pgr.privilege_id,
      undeleteableprivilegeexceptions->privileges[idx].privilege_id)
      AND pgr.privilege_id > 0
      AND pgr.log_grouping_cd > 0)
     JOIN (lge
     WHERE lge.log_grouping_cd=pgr.log_grouping_cd)
    DETAIL
     num = 0, pos = locateval(num,start,size(request->dellist,5),lge.log_grouping_cd,request->
      dellist[num].log_grouping_cd)
     IF (pos <= 0)
      num = 0, pos = locateval(num,start,size(undeleteableprivilegeexceptions->privileges,5),pgr
       .privilege_id,undeleteableprivilegeexceptions->privileges[num].privilege_id)
      IF (pos != 0)
       num2 = 0, pos2 = locateval(num2,start2,size(undeleteableprivilegeexceptions->privileges[pos].
         exceptions,5),lge.item_cd,undeleteableprivilegeexceptions->privileges[pos].exceptions[num2].
        item_cd)
       IF (pos2 <= 0)
        undeleteableprivilegeexceptions->privileges[pos].exception_cnt = (
        undeleteableprivilegeexceptions->privileges[pos].exception_cnt+ 1), stat = alterlist(
         undeleteableprivilegeexceptions->privileges[pos].exceptions,undeleteableprivilegeexceptions
         ->privileges[pos].exception_cnt), undeleteableprivilegeexceptions->privileges[pos].
        exceptions[undeleteableprivilegeexceptions->privileges[pos].exception_cnt].item_cd = lge
        .item_cd
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE fillprivdellistmultiplegroups(null)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH noconstant(1)
   DECLARE loop_cnt = i4
   SET loop_cnt = ceil((cnvtreal(size(undeleteableprivilegeexceptions->privileges,5))/ batch_size))
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE num2 = i4 WITH noconstant(0)
   DECLARE start2 = i4 WITH noconstant(1)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     priv_group_reltn pgr,
     log_group_entry lge
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (pgr
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),pgr.privilege_id,
      undeleteableprivilegeexceptions->privileges[idx].privilege_id)
      AND pgr.privilege_id > 0
      AND pgr.log_grouping_cd > 0)
     JOIN (lge
     WHERE lge.log_grouping_cd=pgr.log_grouping_cd)
    DETAIL
     num = 0, pos = locateval(num,start,size(undeleteableprivilegeexceptions->privileges,5),pgr
      .privilege_id,undeleteableprivilegeexceptions->privileges[num].privilege_id)
     IF (pos != 0)
      num2 = 0, pos2 = locateval(num2,start2,size(undeleteableprivilegeexceptions->privileges[pos].
        exceptions,5),lge.item_cd,undeleteableprivilegeexceptions->privileges[pos].exceptions[num2].
       item_cd)
      IF (pos2 <= 0)
       privdellistcnt = (privdellistcnt+ 1), stat = alterlist(privdellist->qual,privdellistcnt),
       privdellist->qual[privdellistcnt].privilege_id = pgr.privilege_id,
       privdellist->qual[privdellistcnt].exception_id = lge.item_cd
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(privdellist->qual,privdellistcnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE deleteprivilegeexception(null)
   DELETE  FROM privilege_exception pe,
     (dummyt d  WITH seq = size(privdellist->qual,5))
    SET pe.seq = 1
    PLAN (d)
     JOIN (pe
     WHERE (pe.privilege_id=privdellist->qual[d.seq].privilege_id)
      AND (pe.exception_id=privdellist->qual[d.seq].exception_id))
    WITH nocounter
   ;end delete
 END ;Subroutine
 SUBROUTINE deleteorphanedprivileges(null)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = dellistcnt),
     dummyt d2,
     privilege p,
     privilege_exception pe
    PLAN (d)
     JOIN (p
     WHERE (p.log_grouping_cd=request->dellist[d.seq].log_grouping_cd)
      AND p.log_grouping_cd > 0)
     JOIN (d2)
     JOIN (pe
     WHERE pe.privilege_id=p.privilege_id
      AND pe.privilege_id > 0)
    HEAD REPORT
     orphanlistcnt = 0
    DETAIL
     orphanlistcnt = (orphanlistcnt+ 1)
     IF (mod(orphanlistcnt,10)=1)
      stat = alterlist(orphanlist->qual,(orphanlistcnt+ 9))
     ENDIF
     orphanlist->qual[orphanlistcnt].privilege_id = p.privilege_id
    FOOT REPORT
     stat = alterlist(orphanlist->qual,orphanlistcnt)
    WITH outerjoin = d2, dontexist
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(undeleteableprivilegeexceptions->privileges,5)),
     dummyt d2,
     privilege p,
     privilege_exception pe
    PLAN (d)
     JOIN (p
     WHERE (p.privilege_id=undeleteableprivilegeexceptions->privileges[d.seq].privilege_id))
     JOIN (d2)
     JOIN (pe
     WHERE pe.privilege_id=p.privilege_id
      AND pe.privilege_id > 0)
    DETAIL
     IF ((undeleteableprivilegeexceptions->privileges[d.seq].privilege_id > 0))
      orphanlistcnt = (orphanlistcnt+ 1), stat = alterlist(orphanlist->qual,orphanlistcnt),
      orphanlist->qual[orphanlistcnt].privilege_id = p.privilege_id
     ENDIF
    FOOT REPORT
     stat = alterlist(orphanlist->qual,orphanlistcnt)
    WITH outerjoin = d2, dontexist
   ;end select
   IF (orphanlistcnt > 0)
    DELETE  FROM privilege p,
      (dummyt d  WITH seq = orphanlistcnt)
     SET p.seq = 1
     PLAN (d)
      JOIN (p
      WHERE (p.privilege_id=orphanlist->qual[d.seq].privilege_id)
       AND p.privilege_id > 0)
     WITH nocounter
    ;end delete
   ENDIF
 END ;Subroutine
 SUBROUTINE updateprivilege(null)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = dellistcnt),
    privilege p
   PLAN (d)
    JOIN (p
    WHERE (p.log_grouping_cd=request->dellist[d.seq].log_grouping_cd)
     AND p.log_grouping_cd > 0)
   WITH nocounter, forupdate(p)
  ;end select
  UPDATE  FROM privilege p,
    (dummyt d  WITH seq = dellistcnt)
   SET p.log_grouping_cd = 0
   PLAN (d)
    JOIN (p
    WHERE (p.log_grouping_cd=request->dellist[d.seq].log_grouping_cd))
   WITH nocounter
  ;end update
 END ;Subroutine
 SUBROUTINE audittransaction(null)
   SET audit_string = ""
   IF (privdellistcnt > 0)
    SELECT INTO "nl:"
     FROM privilege p,
      priv_loc_reltn plr,
      (dummyt d  WITH seq = privdellistcnt)
     PLAN (d)
      JOIN (p
      WHERE (p.privilege_id=privdellist->qual[d.seq].privilege_id))
      JOIN (plr
      WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id)
     DETAIL
      person_name = trim(uar_get_code_display(plr.person_id)), position = trim(uar_get_code_display(
        plr.position_cd)), location = trim(uar_get_code_display(plr.location_cd)),
      ppr = trim(uar_get_code_display(plr.ppr_cd))
     WITH nocounter
    ;end select
    IF (person_name > "")
     SET audit_string = person_name
    ENDIF
    IF (location > "")
     IF (audit_string > "")
      SET audit_string = concat(audit_string,"/",location)
     ELSE
      SET audit_string = concat(audit_string,location)
     ENDIF
    ENDIF
    IF (position > "")
     IF (audit_string > "")
      SET audit_string = concat(audit_string,"/",position)
     ELSE
      SET audit_string = concat(audit_string,position)
     ENDIF
    ENDIF
    IF (ppr > "")
     IF (audit_string > "")
      SET audit_string = concat(audit_string,"/",ppr)
     ELSE
      SET audit_string = concat(audit_string,ppr)
     ENDIF
    ENDIF
   ENDIF
   EXECUTE cclaudit 0, "Maintain Reference Data", "Privileges",
   "Privilege", "Security Granularity Definition", "Privilege",
   "Origination", priv_id, audit_string
   IF (exception_audit_flag=1)
    EXECUTE cclaudit 0, "Maintain Reference Data", "Exception",
    "Privilege", "Security Granularity Definition", "Privilege",
    "Origination", priv_id, audit_string
   ENDIF
 END ;Subroutine
 SET dcp_script_version = "002 11/21/08 NC014668"
END GO
