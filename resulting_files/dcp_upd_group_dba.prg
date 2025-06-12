CREATE PROGRAM dcp_upd_group:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD privids(
   1 qual[*]
     2 privilege_id = f8
 )
 RECORD privilegeaddexempt(
   1 privileges[*]
     2 privilege_id = f8
     2 item_cd = f8
     2 exception_type_cd = f8
     2 event_set_name = c100
     2 exception_entity_name = c40
 )
 RECORD privstoadd(
   1 privileges[*]
     2 privilege_id = f8
     2 item_cd = f8
     2 exception_type_cd = f8
     2 event_set_name = c100
     2 exception_entity_name = c40
 )
 RECORD privsdeleteexempt(
   1 privileges[*]
     2 privilege_id = f8
     2 item_cd = f8
 )
 RECORD privstodelete(
   1 privileges[*]
     2 privilege_id = f8
     2 item_cd = f8
 )
 RECORD reqtemp(
   1 addlist[*]
     2 item_cd = f8
     2 exception_type_cd = f8
     2 event_set_name = c100
     2 exception_entity_name = c40
   1 dellist[*]
     2 item_cd = f8
 )
 SET modify = predeclare
 DECLARE dcp_script_version = vc
 DECLARE errstr = vc WITH noconstant(fillstring(132," "))
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE dellistcnt = i2 WITH constant(value(size(request->dellist,5)))
 DECLARE addlistcnt = i2 WITH constant(value(size(request->addlist,5)))
 DECLARE privcnt = i2 WITH noconstant(0)
 DECLARE addexemptcount = i2 WITH noconstant(0)
 DECLARE delexemptcount = i2 WITH noconstant(0)
 DECLARE stat = i4
 DECLARE batch_size = i4 WITH constant(40)
 DECLARE preprocessrequest(null) = null
 DECLARE getprivilegeid(null) = null
 DECLARE updateloggrouping(null) = null
 DECLARE insertprivexcept(null) = null
 DECLARE deleteallprivexcept(null) = null
 DECLARE insertprivilegedeletion(null) = null
 DECLARE retrieveaddexemptions(null) = null
 DECLARE retrievedeleteexemptions(null) = null
 CALL preprocessrequest(null)
 CALL getprivilegeid(null)
 CALL updateloggrouping(null)
 IF (addlistcnt > 0)
  CALL insertloggroup(null)
  IF (privcnt > 0)
   CALL retrieveaddexemptions(null)
   CALL insertprivexcept(null)
  ENDIF
 ENDIF
 IF (dellistcnt > 0)
  CALL deleteloggroup(null)
  IF (privcnt > 0)
   CALL retrievedeleteexemptions(null)
   CALL deleteallprivexcept(null)
  ENDIF
  CALL insertprivilegedeletion(null)
 ENDIF
#exit_script
 FREE RECORD privids
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
   SET stat = alterlist(reqtemp->addlist,size(request->addlist,5))
   SET stat = alterlist(reqtemp->dellist,size(request->dellist,5))
   FOR (i = 1 TO size(request->addlist,5))
     SET reqtemp->addlist[i].item_cd = request->addlist[i].item_cd
     SET reqtemp->addlist[i].exception_type_cd = request->addlist[i].exception_type_cd
     SET reqtemp->addlist[i].event_set_name = request->addlist[i].event_set_name
     SET reqtemp->addlist[i].exception_entity_name = request->addlist[i].exception_entity_name
   ENDFOR
   SET cur_list_size = size(reqtemp->addlist,5)
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(reqtemp->addlist,new_list_size)
   FOR (i = 1 TO size(request->dellist,5))
     SET reqtemp->dellist[i].item_cd = request->dellist[i].item_cd
   ENDFOR
   SET cur_list_size = size(reqtemp->dellist,5)
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(reqtemp->dellist,new_list_size)
 END ;Subroutine
 SUBROUTINE getprivilegeid(null)
   SELECT INTO "nl:"
    FROM privilege p
    WHERE (p.log_grouping_cd=request->log_grouping_cd)
    HEAD REPORT
     privcnt = 0
    DETAIL
     privcnt = (privcnt+ 1)
     IF (mod(privcnt,10)=1)
      stat = alterlist(privids->qual,(privcnt+ 9))
     ENDIF
     privids->qual[privcnt].privilege_id = p.privilege_id
    FOOT REPORT
     stat = alterlist(privids->qual,privcnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM priv_group_reltn pgr
    WHERE (pgr.log_grouping_cd=request->log_grouping_cd)
    DETAIL
     privcnt = (privcnt+ 1), stat = alterlist(privids->qual,privcnt), privids->qual[privcnt].
     privilege_id = pgr.privilege_id
    WITH nocounter
   ;end select
   DECLARE new_list_size = i4
   DECLARE loop_cnt = i4
   SET loop_cnt = ceil((cnvtreal(privcnt)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(privids->qual,new_list_size)
 END ;Subroutine
 SUBROUTINE updateloggrouping(null)
   SELECT INTO "nl:"
    FROM logical_grouping lg
    WHERE (lg.log_grouping_cd=request->log_grouping_cd)
    WITH nocounter, forupdate(lg)
   ;end select
   IF (curqual=0)
    SET errstr = "Failed to lock row for update"
    SET reply->status_data.subeventstatus[1].targetobjectname = "logical_grouping"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "lock"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errstr
    SET failed = "T"
    GO TO exit_script
   ENDIF
   UPDATE  FROM logical_grouping lg
    SET lg.logical_group_desc = request->logical_group_desc, lg.comp_type_cd = request->comp_type_cd,
     lg.updt_id = reqinfo->updt_id,
     lg.updt_dt_tm = cnvtdatetime(curdate,curtime3), lg.updt_task = reqinfo->updt_task, lg
     .updt_applctx = reqinfo->updt_applctx,
     lg.updt_cnt = (lg.updt_cnt+ 1)
    WHERE (lg.log_grouping_cd=request->log_grouping_cd)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET errstr = "Failed updating table"
    SET reply->status_data.subeventstatus[1].targetobjectname = "logical_grouping"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "update"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errstr
    SET failed = "T"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE insertloggroup(null)
   INSERT  FROM log_group_entry lge,
     (dummyt d  WITH seq = addlistcnt)
    SET lge.log_grouping_comp_cd = cnvtreal(seq(reference_seq,nextval)), lge.log_grouping_cd =
     request->log_grouping_cd, lge.item_cd = request->addlist[d.seq].item_cd,
     lge.event_set_name = request->addlist[d.seq].event_set_name, lge.exception_entity_name = request
     ->addlist[d.seq].exception_entity_name, lge.exception_type_cd = request->addlist[d.seq].
     exception_type_cd,
     lge.updt_applctx = reqinfo->updt_applctx, lge.updt_id = reqinfo->updt_id, lge.updt_cnt = 0,
     lge.updt_task = reqinfo->updt_task, lge.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (d)
     JOIN (lge)
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE deleteloggroup(null)
   DELETE  FROM log_group_entry lge,
     (dummyt d  WITH seq = dellistcnt)
    SET lge.seq = 1
    PLAN (d)
     JOIN (lge
     WHERE (lge.item_cd=request->dellist[d.seq].item_cd)
      AND (lge.log_grouping_cd=request->log_grouping_cd))
    WITH nocounter
   ;end delete
 END ;Subroutine
 SUBROUTINE retrieveaddexemptions(null)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH noconstant(1)
   DECLARE idx2 = i4 WITH noconstant(0)
   DECLARE nstart2 = i4 WITH noconstant(1)
   DECLARE loop_cnt = i4
   DECLARE loop_cnt2 = i4
   SET loop_cnt = ceil((cnvtreal(size(privids->qual,5))/ batch_size))
   SET loop_cnt2 = ceil((cnvtreal(size(reqtemp->addlist,5))/ batch_size))
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE pos = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     (dummyt d2  WITH seq = value(loop_cnt2)),
     privilege_exception pe
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (d2
     WHERE initarray(nstart2,evaluate(d2.seq,1,1,(nstart2+ batch_size))))
     JOIN (pe
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),pe.privilege_id,privids->qual[idx].
      privilege_id)
      AND pe.privilege_id > 0
      AND expand(idx2,nstart2,(nstart2+ (batch_size - 1)),pe.exception_id,reqtemp->addlist[idx2].
      item_cd)
      AND pe.exception_id > 0)
    HEAD REPORT
     addexemptcount = 0
    DETAIL
     addexemptcount = (addexemptcount+ 1)
     IF (mod(addexemptcount,10)=1)
      stat = alterlist(privilegeaddexempt->privileges,(addexemptcount+ 9))
     ENDIF
     privilegeaddexempt->privileges[addexemptcount].privilege_id = pe.privilege_id,
     privilegeaddexempt->privileges[addexemptcount].item_cd = pe.exception_id, privilegeaddexempt->
     privileges[addexemptcount].exception_type_cd = pe.exception_type_cd,
     privilegeaddexempt->privileges[addexemptcount].event_set_name = pe.event_set_name,
     privilegeaddexempt->privileges[addexemptcount].exception_entity_name = pe.exception_entity_name
    FOOT REPORT
     stat = alterlist(privilegeaddexempt->privileges,addexemptcount)
    WITH nocounter
   ;end select
   DECLARE i = i4 WITH noconstant(0), private
   DECLARE j = i4 WITH noconstant(0), private
   DECLARE p_cnt = i4 WITH noconstant(0), private
   FOR (i = 1 TO size(privids->qual,5))
     IF ((privids->qual[i].privilege_id > 0))
      FOR (j = 1 TO size(request->addlist,5))
        SET num = 0
        SET pos = locateval(num,start,size(privilegeaddexempt->privileges,5),privids->qual[i].
         privilege_id,privilegeaddexempt->privileges[num].privilege_id,
         request->addlist[j].item_cd,privilegeaddexempt->privileges[num].item_cd)
        IF (pos <= 0)
         SET p_cnt = (p_cnt+ 1)
         IF (mod(p_cnt,10)=1)
          SET stat = alterlist(privstoadd->privileges,(p_cnt+ 9))
         ENDIF
         SET privstoadd->privileges[p_cnt].privilege_id = privids->qual[i].privilege_id
         SET privstoadd->privileges[p_cnt].item_cd = request->addlist[j].item_cd
         SET privstoadd->privileges[p_cnt].exception_type_cd = request->addlist[j].exception_type_cd
         SET privstoadd->privileges[p_cnt].event_set_name = request->addlist[j].event_set_name
         SET privstoadd->privileges[p_cnt].exception_entity_name = request->addlist[j].
         exception_entity_name
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   SET stat = alterlist(privstoadd->privileges,p_cnt)
 END ;Subroutine
 SUBROUTINE insertprivexcept(null)
   IF (size(privstoadd->privileges,5) > 0)
    INSERT  FROM privilege_exception pe,
      (dummyt d  WITH seq = size(privstoadd->privileges,5))
     SET pe.privilege_exception_id = cnvtreal(seq(reference_seq,nextval)), pe.privilege_id =
      privstoadd->privileges[d.seq].privilege_id, pe.exception_type_cd = privstoadd->privileges[d.seq
      ].exception_type_cd,
      pe.exception_id = privstoadd->privileges[d.seq].item_cd, pe.exception_entity_name = privstoadd
      ->privileges[d.seq].exception_entity_name, pe.event_set_name = privstoadd->privileges[d.seq].
      event_set_name,
      pe.updt_applctx = reqinfo->updt_applctx, pe.updt_id = reqinfo->updt_id, pe.updt_cnt = 0,
      pe.updt_task = reqinfo->updt_task, pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      pe.active_status_prsnl_id = reqinfo->updt_id, pe.active_ind = 1
     PLAN (d)
      JOIN (pe)
     WITH nocounter
    ;end insert
   ENDIF
 END ;Subroutine
 SUBROUTINE retrievedeleteexemptions(null)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH noconstant(1)
   DECLARE loop_cnt = i4
   SET loop_cnt = ceil((cnvtreal(size(privids->qual,5))/ batch_size))
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE pos = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     priv_group_reltn pgr,
     log_group_entry lge
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (pgr
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),pgr.privilege_id,privids->qual[idx].
      privilege_id)
      AND pgr.privilege_id > 0
      AND pgr.log_grouping_cd > 0
      AND (pgr.log_grouping_cd != request->log_grouping_cd))
     JOIN (lge
     WHERE lge.log_grouping_cd=pgr.log_grouping_cd)
    HEAD REPORT
     delexemptcount = 0
    DETAIL
     num = 0, pos = locateval(num,start,size(request->dellist,5),lge.item_cd,request->dellist[num].
      item_cd)
     IF (pos != 0)
      num = 0, pos = locateval(num,start,size(privsdeleteexempt->privileges,5),pgr.privilege_id,
       privsdeleteexempt->privileges[num].privilege_id,
       lge.item_cd,privsdeleteexempt->privileges[num].item_cd)
      IF (pos <= 0)
       delexemptcount = (delexemptcount+ 1)
       IF (mod(delexemptcount,10)=1)
        stat = alterlist(privsdeleteexempt->privileges,(delexemptcount+ 9))
       ENDIF
       privsdeleteexempt->privileges[delexemptcount].privilege_id = pgr.privilege_id,
       privsdeleteexempt->privileges[delexemptcount].item_cd = lge.item_cd
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(privsdeleteexempt->privileges,delexemptcount)
    WITH nocounter
   ;end select
   DECLARE i = i4 WITH noconstant(0), private
   DECLARE j = i4 WITH noconstant(0), private
   DECLARE p_cnt = i4 WITH noconstant(0), private
   FOR (i = 1 TO size(privids->qual,5))
     IF ((privids->qual[i].privilege_id > 0))
      FOR (j = 1 TO size(request->dellist,5))
        SET num = 0
        SET pos = locateval(num,start,size(privsdeleteexempt->privileges,5),privids->qual[i].
         privilege_id,privsdeleteexempt->privileges[num].privilege_id,
         request->dellist[j].item_cd,privsdeleteexempt->privileges[num].item_cd)
        IF (pos <= 0)
         SET p_cnt = (p_cnt+ 1)
         IF (mod(p_cnt,10)=1)
          SET stat = alterlist(privstodelete->privileges,(p_cnt+ 9))
         ENDIF
         SET privstodelete->privileges[p_cnt].privilege_id = privids->qual[i].privilege_id
         SET privstodelete->privileges[p_cnt].item_cd = request->dellist[j].item_cd
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   SET stat = alterlist(privstodelete->privileges,p_cnt)
 END ;Subroutine
 SUBROUTINE deleteallprivexcept(null)
   IF (size(privstodelete->privileges,5) > 0)
    DELETE  FROM privilege_exception pe,
      (dummyt d  WITH seq = size(privstodelete->privileges,5))
     SET pe.seq = 1
     PLAN (d)
      JOIN (pe
      WHERE (pe.privilege_id=privstodelete->privileges[d.seq].privilege_id)
       AND (pe.exception_id=privstodelete->privileges[d.seq].item_cd))
     WITH nocounter
    ;end delete
   ENDIF
 END ;Subroutine
 SUBROUTINE insertprivilegedeletion(null)
   INSERT  FROM privilege_deletion pd,
     (dummyt d  WITH seq = dellistcnt)
    SET pd.privilege_deletion_id = cnvtreal(seq(reference_seq,nextval)), pd.log_grouping_cd = request
     ->log_grouping_cd, pd.updt_id = reqinfo->updt_id,
     pd.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (d)
     JOIN (pd)
    WITH nocounter
   ;end insert
 END ;Subroutine
 SET dcp_script_version = "003 11/21/08 NC014668"
END GO
