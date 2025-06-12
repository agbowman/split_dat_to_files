CREATE PROGRAM cp_get_proc_hist:dba
 RECORD temp(
   1 procedures[*]
     2 long_text_id = f8
 )
 RECORD reply(
   1 procedures[*]
     2 encntr_id = f8
     2 procedure_id = f8
     2 active_ind = i2
     2 nomenclature_id = f8
     2 name = vc
     2 proc_ft_dt_tm_ind = i2
     2 proc_dt_tm = dq8
     2 proc_tz = i4
     2 proc_dt_freetxt = c40
     2 prsnl_person_id = f8
     2 proc_prsnl_name = vc
     2 proc_loc_ft_ind = i2
     2 location = vc
     2 comments[*]
       3 comment = vc
       3 comment_id = f8
       3 author_id = f8
       3 comment_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE contributor_clause = vc
 DECLARE powerchart_contrib_cd = f8
 DECLARE profile_contrib_cd = f8
 DECLARE commentcnt = i4 WITH noconstant(0), public
 DECLARE proccnt = i4 WITH noconstant(0), public
 DECLARE expand_size = i4 WITH protect, constant(20)
 DECLARE num = i4 WITH noconstant(0), public
 DECLARE d_start = i4 WITH noconstant(1)
 DECLARE tempcnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 SET stat = uar_get_meaning_by_codeset(89,"POWERCHART",1,powerchart_contrib_cd)
 SET stat = uar_get_meaning_by_codeset(89,"PROFILE",1,profile_contrib_cd)
 IF ((request->contributor_flag=0))
  SET contributor_clause = "1 = 1"
 ELSEIF ((request->contributor_flag=1))
  SET contributor_clause = build("pc.contributor_system_cd =",powerchart_contrib_cd)
 ELSE
  SET contributor_clause = build("pc.contributor_system_cd =",profile_contrib_cd)
 ENDIF
 CALL echo(concat("contributor_clause = ",contributor_clause))
 SELECT INTO "nl:"
  FROM encounter e,
   procedure pc,
   nomenclature n,
   proc_prsnl_reltn ppr,
   long_text lt
  PLAN (e
   WHERE (e.person_id=request->person_id)
    AND e.active_ind=1)
   JOIN (pc
   WHERE pc.encntr_id=e.encntr_id
    AND parser(contributor_clause))
   JOIN (n
   WHERE n.nomenclature_id=pc.nomenclature_id)
   JOIN (ppr
   WHERE ppr.procedure_id=outerjoin(pc.procedure_id)
    AND ppr.proc_prsnl_reltn_cd=outerjoin(0)
    AND ppr.active_ind=outerjoin(1)
    AND ppr.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(pc.long_text_id))
  ORDER BY pc.proc_dt_tm, pc.proc_ft_time_frame, pc.procedure_id,
   pc.end_effective_dt_tm DESC
  HEAD REPORT
   proccnt = 0, tempcnt = 0
  HEAD pc.procedure_id
   proccnt = (proccnt+ 1)
   IF (mod(proccnt,10)=1)
    stat = alterlist(reply->procedures,(proccnt+ 9))
   ENDIF
   reply->procedures[proccnt].encntr_id = e.encntr_id, reply->procedures[proccnt].procedure_id = pc
   .procedure_id, reply->procedures[proccnt].active_ind = pc.active_ind,
   reply->procedures[proccnt].proc_ft_dt_tm_ind = pc.proc_ft_dt_tm_ind, reply->procedures[proccnt].
   proc_dt_tm = pc.proc_dt_tm, reply->procedures[proccnt].proc_tz = validate(pc.proc_tz,0),
   reply->procedures[proccnt].proc_dt_freetxt = pc.proc_ft_time_frame
   IF (lt.long_text_id > 0.0)
    stat = alterlist(reply->procedures[proccnt].comments,1), reply->procedures[proccnt].comments[1].
    comment = lt.long_text, reply->procedures[proccnt].comments[1].comment_id = lt.long_text_id,
    reply->procedures[proccnt].comments[1].comment_dt_tm = lt.active_status_dt_tm, reply->procedures[
    proccnt].comments[1].author_id = lt.active_status_prsnl_id, tempcnt = (tempcnt+ 1)
    IF (mod(tempcnt,10)=1)
     stat = alterlist(temp->procedures,(tempcnt+ 9))
    ENDIF
    temp->procedures[tempcnt].long_text_id = pc.long_text_id
   ENDIF
   reply->procedures[proccnt].nomenclature_id = pc.nomenclature_id
   IF (pc.nomenclature_id > 0)
    reply->procedures[proccnt].name = n.source_string
   ELSE
    reply->procedures[proccnt].name = pc.proc_ftdesc
   ENDIF
   reply->procedures[proccnt].prsnl_person_id = ppr.prsnl_person_id
   IF (ppr.prsnl_person_id=0)
    reply->procedures[proccnt].proc_prsnl_name = ppr.proc_ft_prsnl
   ENDIF
   reply->procedures[proccnt].beg_effective_dt_tm = ppr.beg_effective_dt_tm, reply->procedures[
   proccnt].proc_loc_ft_ind = pc.proc_loc_ft_ind
   IF (pc.proc_loc_ft_ind=0)
    reply->procedures[proccnt].location = uar_get_code_display(pc.proc_loc_cd)
   ELSE
    reply->procedures[proccnt].location = pc.proc_ft_loc
   ENDIF
  FOOT  pc.procedure_id
   do_nothing = 0
  FOOT REPORT
   stat = alterlist(reply->procedures,proccnt), stat = alterlist(temp->procedures,tempcnt)
  WITH nocounter, memsort
 ;end select
 IF (proccnt > 0)
  DECLARE d_loop_cnt = i4 WITH noconstant(ceil((cnvtreal(proccnt)/ expand_size)))
  DECLARE d_total = i4 WITH noconstant((d_loop_cnt * expand_size))
  SET stat = alterlist(reply->procedures,d_total)
  FOR (i = (proccnt+ 1) TO d_total)
    SET reply->procedures[i].procedure_id = reply->procedures[1].procedure_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(d_loop_cnt)),
    long_text lt
   PLAN (d
    WHERE assign(d_start,evaluate(d.seq,1,1,(d_start+ expand_size))))
    JOIN (lt
    WHERE expand(num,d_start,((d_start+ expand_size) - 1),lt.parent_entity_id,reply->procedures[num].
     procedure_id)
     AND lt.parent_entity_name="PROCEDURE"
     AND lt.active_ind=1)
   ORDER BY lt.parent_entity_id
   HEAD REPORT
    commentcnt = 0, index = 0
   HEAD lt.parent_entity_id
    index = locateval(num,1,proccnt,lt.parent_entity_id,reply->procedures[num].procedure_id),
    commentcnt = size(reply->procedures[index].comments,5)
    IF (commentcnt=1)
     stat = alterlist(reply->procedures[index].comments,10)
    ENDIF
   DETAIL
    dupecheckindex = locateval(num,1,tempcnt,lt.long_text_id,temp->procedures[num].long_text_id)
    IF (dupecheckindex=0)
     commentcnt = (commentcnt+ 1)
     IF (mod(commentcnt,10)=1)
      stat = alterlist(reply->procedures[index].comments,(commentcnt+ 9))
     ENDIF
     reply->procedures[index].comments[commentcnt].comment_id = lt.long_text_id, reply->procedures[
     index].comments[commentcnt].comment = lt.long_text, reply->procedures[index].comments[commentcnt
     ].comment_dt_tm = lt.active_status_dt_tm,
     reply->procedures[index].comments[commentcnt].author_id = lt.active_status_prsnl_id
    ENDIF
   FOOT  lt.parent_entity_id
    stat = alterlist(reply->procedures[index].comments,commentcnt), commentcnt = 0
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->procedures,proccnt)
 ENDIF
 IF (size(reply->procedures,5)=0)
  SET errorcode = error(errmsg,0)
  IF (errorcode != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.operationname = "Select"
   SET reply->status_data.operationstatus = "F"
   SET reply->status_data.targetobjectname = "ErrorMessage"
   SET reply->status_data.targetobjectvalue = errmsg
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->status_data.operationname = "Select"
   SET reply->status_data.operationstatus = "Z"
   SET reply->status_data.targetobjectname = "Qualifications"
   SET reply->status_data.targetobjectvalue = "No matching records"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
