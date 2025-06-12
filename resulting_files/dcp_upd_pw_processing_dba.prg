CREATE PROGRAM dcp_upd_pw_processing:dba
 RECORD reply(
   1 new_process_pw_list[*]
     2 pathway_id = f8
     2 tag_id = i4
   1 existing_process_pw_list[*]
     2 pathway_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD internal(
   1 pathway_list[*]
     2 pathway_id = f8
     2 encntr_id = f8
     2 pw_updt_cnt = i2
 )
 SET request_cnt = size(request->pathway_list,5)
 SET stale_in_min = 0
 SET check_updt_cnt = 0
 SET count = 0
 SET count2 = 0
 SET count3 = 0
 SET pathway_nmr = 0.0
 SET cfailed = "F"
 SET diff_in_min = 0
 SET cur_dt_tm = cnvtdatetime(curdate,curtime3)
 SET cur_date_in_min = cnvtmin2(cnvtdate(cur_dt_tm),cnvttime(cur_dt_tm))
 SET null_ptr = 0
 SET locked_cnt = 0
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 IF ((((request->stale_in_min=0)) OR ((request->stale_in_min=null))) )
  SET stale_in_min = 10
 ELSE
  SET stale_in_min = request->stale_in_min
 ENDIF
 IF (request->clear_ind)
  FOR (x = 1 TO request_cnt)
   SELECT INTO "nl:"
    ppa.pathway_id
    FROM pw_processing_action ppa
    WHERE (ppa.pathway_id=request->pathway_list[x].pathway_id)
    DETAIL
     check_updt_cnt = (ppa.processing_updt_cnt - 1)
    WITH forupdate(ppa), nocounter
   ;end select
   IF ((((request->pathway_list[x].pw_updt_cnt=check_updt_cnt)) OR (check_updt_cnt < 0)) )
    IF (check_updt_cnt < 0)
     DELETE  FROM pw_processing_action ppa2
      WHERE (ppa2.pathway_id=request->pathway_list[x].pathway_id)
     ;end delete
    ELSE
     UPDATE  FROM pw_processing_action ppa3
      SET ppa3.processing_updt_cnt = check_updt_cnt, ppa3.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       ppa3.updt_id = reqinfo->updt_id,
       ppa3.updt_task = reqinfo->updt_task, ppa3.updt_cnt = (ppa3.updt_cnt+ 1), ppa3.updt_applctx =
       reqinfo->updt_applctx
      WHERE (ppa3.pathway_id=request->pathway_list[x].pathway_id)
     ;end update
    ENDIF
   ENDIF
  ENDFOR
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ppa.pathway_id, ppa.pathway_id, pw.pathway_id
  FROM pw_processing_action ppa,
   pathway pw
  PLAN (ppa
   WHERE (ppa.person_id=request->person_id))
   JOIN (pw
   WHERE ppa.pathway_id=pw.pathway_id
    AND ppa.processing_updt_cnt != pw.updt_cnt)
  HEAD REPORT
   count = 0
  DETAIL
   IF (((cnvtmin2(cnvtdate(ppa.processing_start_dt_tm),cnvttime(ppa.processing_start_dt_tm))+
   stale_in_min) > cur_date_in_min))
    count = (count+ 1)
    IF (count > size(reply->existing_process_pw_list,5))
     stat = alterlist(reply->existing_process_pw_list,(count+ 5))
    ENDIF
    reply->existing_process_pw_list[count].pathway_id = ppa.pathway_id
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->existing_process_pw_list,count)
  WITH nocounter
 ;end select
 SET existing_process_nbr = size(reply->existing_process_pw_list,5)
 SET locked_cnt = 0
 IF ((request->ignore_ind=0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(request_cnt)),
    (dummyt d2  WITH seq = value(existing_process_nbr))
   PLAN (d)
    JOIN (d2
    WHERE (request->pathway_list[d.seq].pathway_id != 0)
     AND (request->pathway_list[d.seq].pathway_id=reply->existing_process_pw_list[d2.seq].pathway_id)
    )
   DETAIL
    locked_cnt = (locked_cnt+ 1)
   WITH nocounter
  ;end select
  IF (locked_cnt > 0)
   GO TO check_locking_failed
  ENDIF
  SET locked_cnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(request_cnt)),
    pathway p
   PLAN (d)
    JOIN (p
    WHERE (request->pathway_list[d.seq].pathway_id != 0)
     AND (request->pathway_list[d.seq].pathway_id=p.pathway_id)
     AND (request->pathway_list[d.seq].pw_updt_cnt != p.updt_cnt))
   DETAIL
    locked_cnt = (locked_cnt+ 1), existing_process_nbr = (existing_process_nbr+ 1)
    IF (existing_process_nbr > size(reply->existing_process_pw_list,5))
     stat = alterlist(reply->existing_process_pw_list,(existing_process_nbr+ 5))
    ENDIF
    reply->existing_process_pw_list[existing_process_nbr].pathway_id = request->pathway_list[d.seq].
    pathway_id
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->existing_process_pw_list,existing_process_nbr)
  IF (locked_cnt > 0)
   GO TO pw_check_locking_failed
  ENDIF
 ENDIF
 FOR (x = 1 TO request_cnt)
   IF ((request->pathway_list[x].pathway_id=0))
    SELECT INTO "nl:"
     nextseqnum = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      pathway_nmr = nextseqnum
     WITH format, nocounter
    ;end select
    IF (pathway_nmr=0.0)
     GO TO seq_failed
    ENDIF
    SET count2 = (count2+ 1)
    IF (count2 > size(reply->new_process_pw_list,5))
     SET stat = alterlist(reply->new_process_pw_list,(count2+ 5))
    ENDIF
    SET reply->new_process_pw_list[count2].pathway_id = pathway_nmr
    SET reply->new_process_pw_list[count2].tag_id = request->pathway_list[x].tag_id
    INSERT  FROM pw_processing_action ppa
     SET ppa.pathway_id = pathway_nmr, ppa.encntr_id = request->pathway_list[x].encntr_id, ppa
      .pathway_catalog_id = request->pathway_list[x].pathway_catalog_id,
      ppa.person_id = request->person_id, ppa.processing_start_dt_tm = cnvtdatetime(curdate,curtime3),
      ppa.processing_updt_cnt = 0,
      ppa.pw_group_nbr = request->pathway_list[x].pw_group_nbr, ppa.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), ppa.updt_id = reqinfo->updt_id,
      ppa.updt_task = reqinfo->updt_task, ppa.updt_cnt = 0, ppa.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->new_process_pw_list,count2)
 IF (request_cnt > size(internal->pathway_list,5))
  SET stat = alterlist(internal->pathway_list,request_cnt)
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(request_cnt)),
   pw_processing_action ppa,
   (dummyt d  WITH seq = 1),
   (dummyt d2  WITH seq = value(existing_process_nbr))
  PLAN (d1
   WHERE (request->pathway_list[d1.seq].pathway_id > 0))
   JOIN (ppa
   WHERE (ppa.pathway_id=request->pathway_list[d1.seq].pathway_id))
   JOIN (d)
   JOIN (d2
   WHERE (ppa.pathway_id=reply->existing_process_pw_list[d2.seq].pathway_id))
  DETAIL
   IF ((((ppa.processing_updt_cnt=request->pathway_list[d1.seq].pw_updt_cnt)) OR (((cnvtmin2(cnvtdate
    (ppa.processing_start_dt_tm),cnvttime(ppa.processing_start_dt_tm))+ stale_in_min) <
   cur_date_in_min))) )
    count3 = (count3+ 1), internal->pathway_list[count3].pathway_id = request->pathway_list[d1.seq].
    pathway_id, internal->pathway_list[count3].encntr_id = request->pathway_list[d1.seq].encntr_id,
    internal->pathway_list[count3].pw_updt_cnt = request->pathway_list[d1.seq].pw_updt_cnt
   ENDIF
  WITH outerjoin = d, dontexist, forupdate(ppa)
 ;end select
 SET stat = alterlist(internal->pathway_list,count3)
 IF (request_cnt > size(reply->new_process_pw_list,5))
  SET stat = alterlist(reply->new_process_pw_list,request_cnt)
 ENDIF
 IF (count3 > 0)
  FOR (x = 1 TO count3)
   UPDATE  FROM pw_processing_action ppa
    SET ppa.processing_updt_cnt =
     IF (((cnvtmin2(cnvtdate(ppa.processing_start_dt_tm),cnvttime(ppa.processing_start_dt_tm))+
     stale_in_min) < cur_date_in_min)) (internal->pathway_list[x].pw_updt_cnt+ 1)
     ELSE (ppa.processing_updt_cnt+ 1)
     ENDIF
     , ppa.encntr_id = internal->pathway_list[x].encntr_id, ppa.processing_start_dt_tm = cnvtdatetime
     (curdate,curtime3),
     ppa.updt_dt_tm = cnvtdatetime(curdate,curtime3), ppa.updt_id = reqinfo->updt_id, ppa.updt_task
      = reqinfo->updt_task,
     ppa.updt_cnt = (ppa.updt_cnt+ 1), ppa.updt_applctx = reqinfo->updt_applctx
    WHERE (ppa.pathway_id=internal->pathway_list[x].pathway_id)
   ;end update
   IF (curqual > 0)
    SET count2 = (count2+ 1)
    IF (count2 > size(reply->new_process_pw_list,5))
     SET stat = alterlist(reply->new_process_pw_list,(count2+ 5))
    ENDIF
    SET reply->new_process_pw_list[count2].pathway_id = internal->pathway_list[x].pathway_id
   ENDIF
  ENDFOR
 ENDIF
 SET stat = alterlist(reply->new_process_pw_list,count2)
 GO TO exit_script
#seq_failed
 CALL report_failure("der sequence","F","ref_seq","DCP_UPD_PW_PROCESSING")
 GO TO exit_script
#check_locking_failed
 CALL report_failure("check locking","F","check locking","DCP_UPD_PW_PROCESSING")
 SET reply->status_data.status = "P"
 GO TO exit_script
#pw_check_locking_failed
 CALL report_failure("pw check locking","F","pw check locking","DCP_UPD_PW_PROCESSING")
 SET reply->status_data.status = "P"
 GO TO exit_script
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   SET cfailed = "T"
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = trim(opname)
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (cfailed="T")
  ROLLBACK
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
