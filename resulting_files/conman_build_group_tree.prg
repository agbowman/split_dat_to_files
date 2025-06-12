CREATE PROGRAM conman_build_group_tree
 PROMPT
  "Output Device: " = "MINE"
  WITH outdev
 IF (validate(optimers)=0)
  RECORD optimers(
    1 cnt = i4
    1 qual[*]
      2 operationdisplay = vc
      2 operationtype = vc
      2 operationmeaning = vc
      2 begintime = dq8
      2 endtime = dq8
      2 elapsedhsec = f8
  ) WITH protect
 ENDIF
 IF (validate(prim_event_cd)=0)
  RECORD prim_event_cd(
    1 prim_event_cd_cnt = i4
    1 prim_event_cds[*]
      2 event_cat_mean = vc
      2 event_cd = f8
      2 event_cd_disp = vc
  ) WITH protect
 ENDIF
 IF (validate(encntrs)=0)
  FREE RECORD encntrs
  RECORD encntrs(
    1 prsnl_cnt = i4
    1 prsnl_list[*]
      2 prsnl_id = f8
      2 person_cnt = i4
      2 person_list[*]
        3 person_id = f8
        3 last_updt_dt_tm = dq8
        3 encntr_cnt = i4
        3 encntr_list[*]
          4 value = f8
  ) WITH persist
 ENDIF
 DECLARE execute_cust_prg(_proj=vc,_page=vc,_recname=vc) = vc
 DECLARE initoptimers(null) = null WITH protect
 DECLARE initprimeventsets(null) = null WITH protect
 DECLARE loadprimeventsets(null) = null WITH protect
 DECLARE tempchar = vc WITH protect, noconstant("")
 DECLARE tempdttm = dq8 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE requestblobin = vc WITH protect, noconstant("")
 IF (validate(request->blob_in))
  SET request->blob_in = trim(request->blob_in,3)
  IF ((request->blob_in > ""))
   SET requestblobin = request->blob_in
  ENDIF
 ENDIF
 SUBROUTINE (formatfreetext(freetext=vc) =vc)
   DECLARE formattedfreetext = vc WITH protect, noconstant(freetext)
   SET formattedfreetext = replace(formattedfreetext,char(9),"    ",0)
   SET formattedfreetext = replace(formattedfreetext,char(10),char(13),0)
   SET formattedfreetext = replace(formattedfreetext,concat(char(13),char(13)),char(13),0)
   SET formattedfreetext = replace(formattedfreetext,char(13)," <br/>",0)
   RETURN(formattedfreetext)
 END ;Subroutine
 SUBROUTINE (formathtmlcharactercodes(freetext=vc) =vc)
   DECLARE formattedfreetext = vc WITH protect, noconstant(freetext)
   SET formattedfreetext = replace(formattedfreetext,"&#34;",'"',0)
   SET formattedfreetext = replace(formattedfreetext,"&#94;","^",0)
   SET formattedfreetext = replace(formattedfreetext,"&#10;",char(10),0)
   SET formattedfreetext = replace(formattedfreetext,"&#13;",char(13),0)
   RETURN(formattedfreetext)
 END ;Subroutine
 SUBROUTINE (errorhandler(operationname=vc,operationstatus=c1,targetobjectname=vc,recorddata=vc(ref)
  ) =null)
   DECLARE serrmsg = c132 WITH protect, noconstant(" ")
   DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(recorddata->status_data.subeventstatus,5)
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     IF (((error_cnt > 1) OR (error_cnt=1
      AND (recorddata->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
      SET error_cnt += 1
     ENDIF
     SET lstat = alter(recorddata->status_data.subeventstatus,error_cnt)
     SET recorddata->status_data.status = "F"
     SET recorddata->status_data.subeventstatus[error_cnt].operationname = trim(operationname)
     SET recorddata->status_data.subeventstatus[error_cnt].operationstatus = trim(operationstatus)
     SET recorddata->status_data.subeventstatus[error_cnt].targetobjectname = trim(targetobjectname)
     SET recorddata->status_data.subeventstatus[error_cnt].targetobjectvalue = trim(serrmsg)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
 END ;Subroutine
 SUBROUTINE (ajaxreply(jsonstr=vc) =null)
   IF (trim(jsonstr) != "")
    IF (validate(_memory_reply_string))
     SET _memory_reply_string = jsonstr
    ELSE
     FREE SET putrequest
     RECORD putrequest(
       1 source_dir = vc
       1 source_filename = vc
       1 nbrlines = i4
       1 line[*]
         2 linedata = vc
       1 overflowpage[*]
         2 ofr_qual[*]
           3 ofr_line = vc
       1 isblob = c1
       1 document_size = i4
       1 document = gvc
     )
     FREE SET putreply
     RECORD putreply(
       1 info_line[*]
         2 new_line = vc
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     SET putrequest->source_dir =  $OUTDEV
     SET putrequest->isblob = "1"
     SET putrequest->document_size = size(jsonstr)
     SET putrequest->document = jsonstr
     EXECUTE eks_put_source  WITH replace(request,"PUTREQUEST"), replace(reply,"PUTREPLY")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (loadeventcodes(eventsetcd=f8) =null)
   SELECT INTO "nl:"
    FROM v500_event_set_explode e
    PLAN (e
     WHERE e.event_set_cd=eventsetcd)
    ORDER BY e.event_cd
    DETAIL
     CALL loadeventcd(e.event_cd)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE execute_cust_prg(_proj,_page,_recname,_page2,_recname2)
   FREE RECORD ic_exec_cmds
   RECORD ic_exec_cmds(
     1 cnt = i4
     1 qual[*]
       2 cmd = vc
   )
   SET stat = initrec(ic_exec_cmds)
   DECLARE execstr = vc WITH protect, noconstant(" ")
   IF (checkdic("CUST_COND_SUMMARY_DATA","T",0) != 0)
    SELECT INTO "nl:"
     FROM cust_cond_summary_data c
     PLAN (c
      WHERE c.project=_proj
       AND c.section_name=_page
       AND c.data_type="XTRA")
     ORDER BY c.long_desc
     HEAD REPORT
      row + 0, cntr = 0,
      CALL echo(build("MPAGE ---->",_page)),
      CALL echo(build("RECORD ---->",_recname))
     HEAD c.long_desc
      IF (checkprg(cnvtupper(trim(c.long_desc))) > 0)
       cntr += 1
       IF (mod(cntr,10)=1)
        now = alterlist(ic_exec_cmds->qual,(cntr+ 9))
       ENDIF
       execstr = build2("execute ",trim(c.long_desc),' with replace ("',_page,'","',
        _recname,'") ',', replace ("',_page2,'","',
        _recname2,'") go'), ic_exec_cmds->qual[cntr].cmd = execstr,
       CALL echo(build("EXECUTING ---->",execstr))
      ELSE
       CALL echo(build("PROGRAM NOT FOUND ---->",trim(c.long_desc)))
      ENDIF
     FOOT REPORT
      now = alterlist(ic_exec_cmds->qual,cntr), ic_exec_cmds->cnt = cntr
     WITH nocounter
    ;end select
    CALL echorecord(ic_exec_cmds)
    FOR (i = 1 TO ic_exec_cmds->cnt)
      CALL parser(ic_exec_cmds->qual[i].cmd)
    ENDFOR
    IF ((ic_exec_cmds->cnt > 0))
     CALL parser(concat("call echorecord( ",_recname," ) go"))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE initprimeventsets(null)
   SET stat = initrec(prim_event_cd)
 END ;Subroutine
 SUBROUTINE (addprimeventsetcd(event_cd=f8) =null WITH protect)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET prim_event_cd->prim_event_cd_cnt += 1
   SET cnt = prim_event_cd->prim_event_cd_cnt
   IF (mod(cnt,10)=1)
    SET stat = alterlist(prim_event_cd->prim_event_cds,(cnt+ 9))
   ENDIF
   SET prim_event_cd->prim_event_cds[cnt].event_cd = event_cd
   SET prim_event_cd->prim_event_cds[cnt].event_cd_disp = trim(uar_get_code_display(event_cd))
   SET prim_event_cd->prim_event_cds[cnt].event_cat_mean = cur_event_cat_mean
 END ;Subroutine
 SUBROUTINE loadprimeventsets(null)
   SET stat = alterlist(prim_event_cd->prim_event_cds,prim_event_cd->prim_event_cd_cnt)
   CALL echorecord(prim_event_cd)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = prim_event_cd->prim_event_cd_cnt),
     v500_event_set_explode e
    PLAN (d1)
     JOIN (e
     WHERE (e.event_set_cd=prim_event_cd->prim_event_cds[d1.seq].event_cd)
      AND e.event_cd > 0.0)
    ORDER BY e.event_cd
    DETAIL
     cur_event_cat_mean = prim_event_cd->prim_event_cds[d1.seq].event_cat_mean,
     CALL loadeventcd(e.event_cd)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (addnewrequesteventcd(event_cd=f8,event_cat_mean=vc,event_cat_seq=i4) =f8 WITH protect)
   DECLARE event_cd_index = i4 WITH protect, noconstant(0)
   SET request->event_cd_cnt += 1
   SET event_cd_index = request->event_cd_cnt
   IF ((size(request->event_cds,5) < request->event_cd_cnt))
    SET stat = alterlist(request->event_cds,(event_cd_index+ 9))
   ENDIF
   SET request->event_cds[event_cd_index].event_cd = event_cd
   SET request->event_cds[event_cd_index].event_cd_disp = trim(uar_get_code_display(event_cd))
   SET request->event_cds[event_cd_index].event_cat_mean = event_cat_mean
   SET request->event_cds[event_cd_index].event_cat_seq = event_cat_seq
   RETURN(event_cd_index)
 END ;Subroutine
 SUBROUTINE (addnewrequesteventcdcatmean(event_cd_index=i4,event_cat_mean=vc,event_cat_seq=i4) =null
  WITH protect)
   DECLARE cat_mean_cnt = i4 WITH protect, noconstant(0)
   SET cat_mean_cnt = (request->event_cds[event_cd_index].event_cat_mean_cnt+ 1)
   SET request->event_cds[event_cd_index].event_cat_mean_cnt = cat_mean_cnt
   SET stat = alterlist(request->event_cds[event_cd_index].event_cat_means,cat_mean_cnt)
   SET request->event_cds[event_cd_index].event_cat_means[cat_mean_cnt].event_cat_mean =
   event_cat_mean
   SET request->event_cds[event_cd_index].event_cat_means[cat_mean_cnt].event_cat_seq = event_cat_seq
 END ;Subroutine
 SUBROUTINE (addnewrequestmicroeventcd(event_cd=f8,event_cat_mean=vc,event_cat_seq=i4) =f8 WITH
  protect)
   DECLARE event_cd_index = i4 WITH protect, noconstant(0)
   SET request->micro_event_cnt += 1
   SET event_cd_index = request->micro_event_cnt
   IF ((size(request->micro_event_cds,5) < request->micro_event_cnt))
    SET stat = alterlist(request->micro_event_cds,(event_cd_index+ 9))
   ENDIF
   SET request->micro_event_cds[event_cd_index].event_cd = event_cd
   SET request->micro_event_cds[event_cd_index].event_cd_disp = trim(uar_get_code_display(event_cd))
   SET request->micro_event_cds[event_cd_index].event_cat_mean = event_cat_mean
   SET request->micro_event_cds[event_cd_index].event_cat_seq = event_cat_seq
   RETURN(event_cd_index)
 END ;Subroutine
 SUBROUTINE (addnewrequestmicroeventcdcatmean(event_cd_index=i4,event_cat_mean=vc,event_cat_seq=i4) =
  null WITH protect)
   DECLARE cat_mean_cnt = i4 WITH protect, noconstant(0)
   SET cat_mean_cnt = (request->micro_event_cds[event_cd_index].event_cat_mean_cnt+ 1)
   SET request->micro_event_cds[event_cd_index].event_cat_mean_cnt = cat_mean_cnt
   SET stat = alterlist(request->micro_event_cds[event_cd_index].event_cat_means,cat_mean_cnt)
   SET request->micro_event_cds[event_cd_index].event_cat_means[cat_mean_cnt].event_cat_mean =
   event_cat_mean
   SET request->micro_event_cds[event_cd_index].event_cat_means[cat_mean_cnt].event_cat_seq =
   event_cat_seq
 END ;Subroutine
 SUBROUTINE (findreplyeventcdcatmean(pt_index=i4,ce_index=i4,event_cat_mean=vc) =i4 WITH protect)
   DECLARE search_num = i4 WITH protect, noconstant(0)
   DECLARE event_cat_mean_index = i4 WITH protect, noconstant(0)
   SET event_cat_mean_index = locateval(search_num,1,reply->pts[pt_index].ce[ce_index].
    event_cat_mean_cnt,event_cat_mean,reply->pts[pt_index].ce[ce_index].event_cat_means[search_num].
    event_cat_mean)
   RETURN(event_cat_mean_index)
 END ;Subroutine
 SUBROUTINE (findreplymicroeventcdcatmean(pt_index=i4,ce_index=i4,event_cat_mean=vc) =i4 WITH protect
  )
   DECLARE search_num = i4 WITH protect, noconstant(0)
   DECLARE event_cat_mean_index = i4 WITH protect, noconstant(0)
   SET event_cat_mean_index = locateval(search_num,1,reply->pts[pt_index].micro_ce[ce_index].
    event_cat_mean_cnt,event_cat_mean,reply->pts[pt_index].micro_ce[ce_index].event_cat_means[
    search_num].event_cat_mean)
   RETURN(event_cat_mean_index)
 END ;Subroutine
 SUBROUTINE (loadclinicaleventcd(event_cd=f8,event_cat_mean=vc,event_cat_seq=i4) =null WITH protect)
   DECLARE search_num = i4 WITH protect, noconstant(0)
   DECLARE event_cd_index = i4 WITH protect, noconstant(0)
   SET event_cd_index = locateval(search_num,1,request->event_cd_cnt,event_cd,request->event_cds[
    search_num].event_cd)
   IF (event_cd_index > 0)
    IF (locateval(search_num,1,request->event_cds[event_cd_index].event_cat_mean_cnt,event_cat_mean,
     request->event_cds[event_cd_index].event_cat_means[search_num].event_cat_mean) > 0)
     RETURN(null)
    ENDIF
   ELSE
    SET event_cd_index = addnewrequesteventcd(event_cd,event_cat_mean,event_cat_seq)
   ENDIF
   CALL addnewrequesteventcdcatmean(event_cd_index,event_cat_mean,event_cat_seq)
   SET event_cd_index = locateval(search_num,1,request->micro_event_cnt,event_cd,request->
    micro_event_cds[search_num].event_cd)
   IF (event_cd_index > 0)
    CALL addnewrequestmicroeventcdcatmean(event_cd_index,event_cat_mean,event_cat_seq)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE (loadmicroclinicaleventcd(event_cd=f8,event_cat_mean=vc,event_cat_seq=i4) =null WITH
  protect)
   DECLARE search_num = i4 WITH protect, noconstant(0)
   DECLARE cat_mean_cnt = i4 WITH protect, noconstant(0)
   DECLARE event_cd_index = i4 WITH protect, noconstant(0)
   SET event_cd_index = locateval(search_num,1,request->micro_event_cnt,event_cd,request->
    micro_event_cds[search_num].event_cd)
   IF (event_cd_index > 0)
    IF (locateval(search_num,1,request->micro_event_cds[event_cd_index].event_cat_mean_cnt,
     event_cat_mean,request->micro_event_cds[event_cd_index].event_cat_means[search_num].
     event_cat_mean) > 0)
     RETURN(null)
    ENDIF
   ELSE
    SET event_cd_index = addnewrequestmicroeventcd(event_cd,event_cat_mean,event_cat_seq)
   ENDIF
   CALL addnewrequestmicroeventcdcatmean(event_cd_index,event_cat_mean,event_cat_seq)
   SET event_cd_index = locateval(search_num,1,request->event_cd_cnt,event_cd,request->event_cds[
    search_num].event_cd)
   IF (event_cd_index > 0)
    CALL addnewrequesteventcdcatmean(event_cd_index,event_cat_mean,event_cat_seq)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE initoptimers(null)
   SET stat = initrec(optimers)
 END ;Subroutine
 SUBROUTINE (startoptimer(operationmeaning=vc,operationtype=vc,operationdisplay=vc,updateind=i2) =i4
  WITH protect)
   DECLARE timerseq = i4 WITH protect, noconstant(0)
   DECLARE createind = i4 WITH protect, noconstant(0)
   IF (updateind)
    SET createind = 0
   ELSE
    SET createind = 1
   ENDIF
   SET timerseq = getoptimerseq(operationmeaning,1)
   IF (timerseq > 0)
    SET optimers->qual[timerseq].operationmeaning = operationmeaning
    SET optimers->qual[timerseq].operationtype = operationtype
    SET optimers->qual[timerseq].operationdisplay = operationdisplay
    SET optimers->qual[timerseq].begintime = cnvtdatetime(sysdate)
   ENDIF
   RETURN(timerseq)
 END ;Subroutine
 SUBROUTINE (stopoptimer(operationmeaning=vc) =i4 WITH protect)
   DECLARE timerseq = i4 WITH protect, noconstant(0)
   SET timerseq = getoptimerseq(operationmeaning,0)
   IF (timerseq > 0)
    SET optimers->qual[timerseq].endtime = cnvtdatetime(sysdate)
    SET optimers->qual[timerseq].elapsedhsec = datetimediff(optimers->qual[timerseq].endtime,optimers
     ->qual[timerseq].begintime,6)
   ENDIF
   RETURN(timerseq)
 END ;Subroutine
 SUBROUTINE (getoptimerseq(operationmeaning=vc,createind=i2) =i4 WITH protect)
   DECLARE timerseq = i4 WITH protect, noconstant(0)
   DECLARE tcntr = i4 WITH protect, noconstant(0)
   IF (createind=1)
    SET optimers->cnt += 1
    SET stat = alterlist(optimers->qual,optimers->cnt)
    SET timerseq = optimers->cnt
   ELSE
    SET timerseq = locateval(tcntr,1,optimers->cnt,operationmeaning,optimers->qual[tcntr].
     operationmeaning)
   ENDIF
   RETURN(timerseq)
 END ;Subroutine
 SUBROUTINE (addcatalogcd(referencerecord=vc(ref),code=f8,event_cat_mean=vc) =null WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->catalog_cd_cnt,code,referencerecord
     ->catalog_cds[search_cntr].catalog_cd)
    IF (cur_code_index=0)
     SET referencerecord->catalog_cd_cnt += 1
     SET cur_code_index = referencerecord->catalog_cd_cnt
     SET stat = alterlist(referencerecord->catalog_cds,referencerecord->catalog_cd_cnt)
     SET referencerecord->catalog_cds[cur_code_index].catalog_cd = code
     SET referencerecord->catalog_cds[cur_code_index].catalog_cd_disp = trim(uar_get_code_display(
       code))
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->catalog_cds[cur_code_index].event_cat_mean_cnt,trim(
      event_cat_mean),referencerecord->catalog_cds[cur_code_index].event_cat_means[search_cntr].
     event_cat_mean)=0)
     SET referencerecord->catalog_cds[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->catalog_cds[cur_code_index].event_cat_mean_cnt
     SET stat = alterlist(referencerecord->catalog_cds[cur_code_index].event_cat_means,
      referencerecord->catalog_cds[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->catalog_cds[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (addactivitytypecd(referencerecord=vc(ref),code=f8,event_cat_mean=vc) =null WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->activity_type_cd_cnt,code,
     referencerecord->activity_type_cds[search_cntr].activity_type_cd)
    IF (cur_code_index=0)
     SET referencerecord->activity_type_cd_cnt += 1
     SET cur_code_index = referencerecord->activity_type_cd_cnt
     SET stat = alterlist(referencerecord->activity_type_cds,referencerecord->activity_type_cd_cnt)
     SET referencerecord->activity_type_cds[cur_code_index].activity_type_cd = code
     SET referencerecord->activity_type_cds[cur_code_index].activity_type_cd_disp = trim(
      uar_get_code_display(code))
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->activity_type_cds[cur_code_index].event_cat_mean_cnt,
     trim(event_cat_mean),referencerecord->activity_type_cds[cur_code_index].event_cat_means[
     search_cntr].event_cat_mean)=0)
     SET referencerecord->activity_type_cds[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->activity_type_cds[cur_code_index].
     event_cat_mean_cnt
     SET stat = alterlist(referencerecord->activity_type_cds[cur_code_index].event_cat_means,
      referencerecord->activity_type_cds[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->activity_type_cds[cur_code_index].event_cat_means[cur_event_cat_mean_index]
     .event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (addcatalogtypecd(referencerecord=vc(ref),code=f8,event_cat_mean=vc) =null WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->catalog_type_cd_cnt,code,
     referencerecord->catalog_type_cds[search_cntr].catalog_type_cd)
    IF (cur_code_index=0)
     SET referencerecord->catalog_type_cd_cnt += 1
     SET cur_code_index = referencerecord->catalog_type_cd_cnt
     SET stat = alterlist(referencerecord->catalog_type_cds,referencerecord->catalog_type_cd_cnt)
     SET referencerecord->catalog_type_cds[cur_code_index].catalog_type_cd = code
     SET referencerecord->catalog_type_cds[cur_code_index].catalog_type_cd_disp = trim(
      uar_get_code_display(code))
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->catalog_type_cds[cur_code_index].event_cat_mean_cnt,
     trim(event_cat_mean),referencerecord->catalog_type_cds[cur_code_index].event_cat_means[
     search_cntr].event_cat_mean)=0)
     SET referencerecord->catalog_type_cds[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->catalog_type_cds[cur_code_index].
     event_cat_mean_cnt
     SET stat = alterlist(referencerecord->catalog_type_cds[cur_code_index].event_cat_means,
      referencerecord->catalog_type_cds[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->catalog_type_cds[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (getbedrockfilterindexbymeaning(filtermeaning=vc) =i4 WITH protect)
   DECLARE filter_index = i4 WITH protect, noconstant(0)
   DECLARE filter_size = i4 WITH protect, noconstant(0)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   SET filter_size = size(filter->filters,5)
   SET filter_index = locateval(search_cntr,1,filter_size,filtermeaning,filter->filters[search_cntr].
    fileventmean)
   RETURN(filter_index)
 END ;Subroutine
 SUBROUTINE (loadbedrockcodevalues(filtermeaning=vc,referencerecord=vc(ref),event_cat_mean=vc) =null
  WITH protect)
   DECLARE filter_index = i4 WITH protect, noconstant(0)
   DECLARE val_cntr = i4 WITH protect, noconstant(0)
   DECLARE val_size = i4 WITH protect, noconstant(0)
   DECLARE val_idx = i4 WITH protect, noconstant(0)
   SET filter_index = getbedrockfilterindexbymeaning(filtermeaning)
   IF (filter_index > 0)
    SET val_size = size(filter->filters[filter_index].values,5)
    FOR (val_cntr = 1 TO val_size)
      CASE (filter->filters[filter_index].fileventcatmean)
       OF "ACTIVITY_TYPE_CDS":
        CALL addactivitytypecd(referencerecord,filter->filters[filter_index].values[val_cntr].
         valeventcd,event_cat_mean)
       OF "CATALOG_TYPE_CDS":
        CALL addcatalogtypecd(referencerecord,filter->filters[filter_index].values[val_cntr].
         valeventcd,event_cat_mean)
       OF "ORDER":
        CALL addcatalogcd(referencerecord,filter->filters[filter_index].values[val_cntr].valeventcd,
         event_cat_mean)
       OF "PRIM_EVENT_SET":
       OF "EVENT_SET":
        CALL addeventsetcd(referencerecord,filter->filters[filter_index].values[val_cntr].valeventcd,
         event_cat_mean)
       OF "EVENT":
        CALL addeventcd(referencerecord,filter_index,val_cntr,event_cat_mean)
       OF "ORDER_ENTRY_FIELD_CDS":
        CALL addorderentryfieldcd(referencerecord,filter->filters[filter_index].values[val_cntr].
         valeventcd,event_cat_mean)
       ELSE
        CALL addcodevalue(referencerecord,filter->filters[filter_index].values[val_cntr].valeventcd,
         event_cat_mean)
      ENDCASE
    ENDFOR
    IF ((filter->filters[filter_index].fileventcatmean IN ("PRIM_EVENT_SET", "EVENT_SET")))
     SET val_size = size(referencerecord->event_set_cds,5)
     IF (val_size > 0
      AND validate(referencerecord->event_set_cds[1].event_set_name))
      SELECT INTO "nl:"
       FROM v500_event_set_code v
       PLAN (v
        WHERE expand(val_cntr,1,val_size,v.event_set_cd,referencerecord->event_set_cds[val_cntr].
         event_set_cd))
       ORDER BY v.event_set_cd
       HEAD v.event_set_cd
        val_idx = locateval(val_cntr,1,val_size,v.event_set_cd,referencerecord->event_set_cds[
         val_cntr].event_set_cd), referencerecord->event_set_cds[val_idx].event_set_name = trim(v
         .event_set_name,3)
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (loadbedrockfreetextvalue(filtermeaning=vc,valuetype=vc,referencevariable=vc(ref)) =null
  WITH protect)
   DECLARE filter_index = i4 WITH protect, noconstant(0)
   SET filter_index = getbedrockfilterindexbymeaning(filtermeaning)
   IF (filter_index > 0)
    IF (size(filter->filters[filter_index].values,5)=1)
     CASE (cnvtupper(valuetype))
      OF "ALPHA":
       SET referencevariable = trim(filter->filters[filter_index].values[1].valeventftx,3)
      OF "FLOAT":
       SET referencevariable = cnvtreal(filter->filters[filter_index].values[1].valeventftx)
      OF "INTEGER":
       SET referencevariable = cnvtint(filter->filters[filter_index].values[1].valeventftx)
     ENDCASE
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (populatepatientupdateeventlist(updatedata=vc(ref),pt_index=i4,eventset_list=vc(ref)) =
  null WITH protect)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE evtsetcnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    evt_cd = updatedata->data[pt_index].clineventlist[d.seq].event_cd
    FROM (dummyt d  WITH seq = size(updatedata->data[pt_index].clineventlist,5)),
     v500_event_set_explode vese
    PLAN (d)
     JOIN (vese
     WHERE (vese.event_cd=updatedata->data[pt_index].clineventlist[d.seq].event_cd))
    ORDER BY evt_cd
    HEAD evt_cd
     evtsetcnt += 1, stat = alterlist(eventset_list->qual,evtsetcnt), eventset_list->qual[evtsetcnt].
     value = updatedata->data[pt_index].clineventlist[d.seq].event_cd
    DETAIL
     evtsetcnt += 1, stat = alterlist(eventset_list->qual,evtsetcnt), eventset_list->qual[evtsetcnt].
     value = vese.event_set_cd
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (checkcelistinbrfilters(eventset_list=vc(ref),filter_record=vc(ref)) =i2 WITH protect)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE checkcelist = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    br_val = filter_record->filters[d.seq].values[d1.seq].valeventcd
    FROM (dummyt d  WITH seq = size(filter_record->filters,5)),
     (dummyt d1  WITH seq = 1),
     (dummyt d2  WITH seq = size(eventset_list->qual,5))
    PLAN (d
     WHERE maxrec(d1,size(filter_record->filters[d.seq].values,5))
      AND (filter_record->filters[d.seq].fileventcatmean IN ("EVENT", "EVENT_SET", "PRIM_EVENT_SET"))
     )
     JOIN (d1)
     JOIN (d2
     WHERE (eventset_list->qual[d2.seq].value=filter_record->filters[d.seq].values[d1.seq].valeventcd
     ))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET checkcelist = 1
   ENDIF
   RETURN(checkcelist)
 END ;Subroutine
 SUBROUTINE (populatepatientupdateorderlist(updatedata=vc(ref),pt_index=i4,ordercd_list=vc(ref)) =
  null WITH protect)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE ordcdcnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    order_id = updatedata->data[pt_index].orderlist[d.seq].order_id
    FROM (dummyt d  WITH seq = size(updatedata->data[pt_index].orderlist,5)),
     orders o
    PLAN (d)
     JOIN (o
     WHERE (o.order_id=updatedata->data[pt_index].orderlist[d.seq].order_id))
    ORDER BY o.catalog_type_cd, o.activity_type_cd, o.catalog_cd
    HEAD o.catalog_type_cd
     ordcdcnt += 1, stat = alterlist(ordercd_list->qual,ordcdcnt), ordercd_list->qual[ordcdcnt].value
      = o.catalog_type_cd
    HEAD o.activity_type_cd
     ordcdcnt += 1, stat = alterlist(ordercd_list->qual,ordcdcnt), ordercd_list->qual[ordcdcnt].value
      = o.activity_type_cd
    HEAD o.catalog_cd
     ordcdcnt += 1, stat = alterlist(ordercd_list->qual,ordcdcnt), ordercd_list->qual[ordcdcnt].value
      = o.catalog_cd
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (checkorderlistinbrfilters(ordercd_list=vc(ref),filter_record=vc(ref)) =i2 WITH protect)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE checkorderlist = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    br_val = filter_record->filters[d.seq].values[d1.seq].valeventcd
    FROM (dummyt d  WITH seq = size(filter_record->filters,5)),
     (dummyt d1  WITH seq = 1),
     (dummyt d2  WITH seq = size(ordercd_list->qual,5))
    PLAN (d
     WHERE maxrec(d1,size(filter_record->filters[d.seq].values,5))
      AND (filter_record->filters[d.seq].fileventcatmean IN ("ACTIVITY_TYPE_CDS", "CATALOG_TYPE_CDS",
     "ORDER")))
     JOIN (d1)
     JOIN (d2
     WHERE (ordercd_list->qual[d2.seq].value=filter_record->filters[d.seq].values[d1.seq].valeventcd)
     )
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET checkorderlist = 1
   ENDIF
   RETURN(checkorderlist)
 END ;Subroutine
 SUBROUTINE (getbestbatchsize(querysize=i4) =i4 WITH protect)
   IF (querysize <= 1)
    RETURN(querysize)
   ELSEIF (querysize <= 5)
    RETURN(5)
   ELSEIF (querysize <= 10)
    RETURN(10)
   ENDIF
   DECLARE minquerycount = i4 WITH constant(((querysize+ 199)/ 200))
   DECLARE bestbatchsize = i4 WITH constant(ceil((cnvtreal(querysize)/ minquerycount)))
   RETURN((20 * ceil((cnvtreal(bestbatchsize)/ 20))))
 END ;Subroutine
 SUBROUTINE (addproblemnomenclature(referencerecord=vc(ref),nomenclature_id=f8,display=vc,
  event_cat_mean=vc) =null WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->nomenclature_id_cnt,nomenclature_id,
     referencerecord->nomenclature_ids[search_cntr].nomenclature_id)
    IF (cur_code_index=0)
     SET referencerecord->nomenclature_id_cnt += 1
     SET cur_code_index = referencerecord->nomenclature_id_cnt
     SET stat = alterlist(referencerecord->nomenclature_ids,referencerecord->nomenclature_id_cnt)
     SET referencerecord->nomenclature_ids[cur_code_index].nomenclature_id = nomenclature_id
     SET referencerecord->nomenclature_ids[cur_code_index].nomenclature_disp = trim(display,3)
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->nomenclature_ids[cur_code_index].event_cat_mean_cnt,
     trim(event_cat_mean),referencerecord->nomenclature_ids[cur_code_index].event_cat_means[
     search_cntr].event_cat_mean)=0)
     SET referencerecord->nomenclature_ids[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->nomenclature_ids[cur_code_index].
     event_cat_mean_cnt
     SET stat = alterlist(referencerecord->nomenclature_ids[cur_code_index].event_cat_means,
      referencerecord->nomenclature_ids[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->nomenclature_ids[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (loadbedrocknomenclaturevalues(filtermeaning=vc,referencerecord=vc(ref),event_cat_mean=vc
  ) =null WITH protect)
   DECLARE filter_index = i4 WITH protect, noconstant(0)
   DECLARE val_cntr = i4 WITH protect, noconstant(0)
   DECLARE val_size = i4 WITH protect, noconstant(0)
   SET filter_index = getbedrockfilterindexbymeaning(filtermeaning)
   IF (filter_index > 0)
    SET val_size = size(filter->filters[filter_index].values,5)
    FOR (val_cntr = 1 TO val_size)
      CASE (filter->filters[filter_index].fileventcatmean)
       OF "PROBLEM":
        CALL addproblemnomenclature(referencerecord,filter->filters[filter_index].values[val_cntr].
         valeventcd,filter->filters[filter_index].values[val_cntr].valeventnomdisp,event_cat_mean)
      ENDCASE
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (addeventsetcd(referencerecord=vc(ref),code=f8,event_cat_mean=vc) =null WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->event_set_cd_cnt,code,
     referencerecord->event_set_cds[search_cntr].event_set_cd)
    IF (cur_code_index=0)
     SET referencerecord->event_set_cd_cnt += 1
     SET cur_code_index = referencerecord->event_set_cd_cnt
     SET stat = alterlist(referencerecord->event_set_cds,referencerecord->event_set_cd_cnt)
     SET referencerecord->event_set_cds[cur_code_index].event_set_cd = code
     SET referencerecord->event_set_cds[cur_code_index].event_set_cd_disp = trim(uar_get_code_display
      (code))
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->event_set_cds[cur_code_index].event_cat_mean_cnt,
     trim(event_cat_mean),referencerecord->event_set_cds[cur_code_index].event_cat_means[search_cntr]
     .event_cat_mean)=0)
     SET referencerecord->event_set_cds[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->event_set_cds[cur_code_index].event_cat_mean_cnt
     SET stat = alterlist(referencerecord->event_set_cds[cur_code_index].event_cat_means,
      referencerecord->event_set_cds[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->event_set_cds[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (addeventcd(referencerecord=vc(ref),filter_index=i4,value_index=i4,event_cat_mean=vc) =
  null WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   DECLARE event_cd = f8 WITH protect, noconstant(filter->filters[filter_index].values[value_index].
    valeventcd)
   DECLARE filter_event_seq = i4 WITH protect, noconstant(filter->filters[filter_index].fileventseq)
   DECLARE value_event_seq = i4 WITH protect, noconstant(filter->filters[filter_index].values[
    value_index].valeventseq)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->event_cd_cnt,event_cd,
     referencerecord->event_cds[search_cntr].event_cd)
    IF (cur_code_index=0)
     SET referencerecord->event_cd_cnt += 1
     SET cur_code_index = referencerecord->event_cd_cnt
     SET stat = alterlist(referencerecord->event_cds,referencerecord->event_cd_cnt)
     SET referencerecord->event_cds[cur_code_index].event_cd = event_cd
     SET referencerecord->event_cds[cur_code_index].event_cd_disp = trim(uar_get_code_display(
       event_cd))
     CALL addeventnomenclature(filter_index,filter_event_seq,value_event_seq)
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->event_cds[cur_code_index].event_cat_mean_cnt,trim(
      event_cat_mean),referencerecord->event_cds[cur_code_index].event_cat_means[search_cntr].
     event_cat_mean)=0)
     SET referencerecord->event_cds[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->event_cds[cur_code_index].event_cat_mean_cnt
     SET stat = alterlist(referencerecord->event_cds[cur_code_index].event_cat_means,referencerecord
      ->event_cds[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->event_cds[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (addeventnomenclature(eventfilterindex=i4,filtereventseq=i4,valueeventseq=i4) =null)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE nomen_filter_index = i4 WITH protect, noconstant((eventfilterindex+ 1))
   DECLARE value_cntr = i4 WITH protect, noconstant(0)
   DECLARE value_size = i4 WITH protect, noconstant(0)
   DECLARE event_nomen_index = i4 WITH protect, noconstant(0)
   WHILE (nomen_filter_index > 0
    AND (nomen_filter_index <= filter->filterscnt))
    SET nomen_filter_index = locateval(search_cntr,nomen_filter_index,filter->filterscnt,
     filtereventseq,filter->filters[search_cntr].fileventseq)
    IF (nomen_filter_index > 0)
     SET value_size = size(filter->filters[nomen_filter_index].values,5)
     FOR (value_cntr = 1 TO value_size)
       IF ((filter->filters[nomen_filter_index].values[value_cntr].valeventseq=valueeventseq))
        SET referencerecord->event_cds[cur_code_index].event_nomen_cnt += 1
        SET event_nomen_index = referencerecord->event_cds[cur_code_index].event_nomen_cnt
        IF ((referencerecord->event_cds[cur_code_index].event_nomen_cnt > size(referencerecord->
         event_cds[cur_code_index].event_nomens,5)))
         SET stat = alterlist(referencerecord->event_cds[cur_code_index].event_nomens,(
          referencerecord->event_cds[cur_code_index].event_nomen_cnt+ 10))
        ENDIF
        SET referencerecord->event_cds[cur_code_index].event_nomens[event_nomen_index].
        nomenclature_id = filter->filters[nomen_filter_index].values[value_cntr].valeventcd
        SET referencerecord->event_cds[cur_code_index].event_nomens[event_nomen_index].
        nomenclature_disp = filter->filters[nomen_filter_index].values[value_cntr].valeventnomdisp
        SET referencerecord->event_cds[cur_code_index].event_nomens[event_nomen_index].operation =
        filter->filters[nomen_filter_index].values[value_cntr].valeventoper
        SET referencerecord->event_cds[cur_code_index].event_nomens[event_nomen_index].
        operation_qual_flag = filter->filters[nomen_filter_index].values[value_cntr].valqualflag
        SET referencerecord->event_cds[cur_code_index].event_nomens[event_nomen_index].freetext_value
         = filter->filters[nomen_filter_index].values[value_cntr].valeventftx
        SET referencerecord->event_cds[cur_code_index].event_nomens[event_nomen_index].event_type =
        filter->filters[nomen_filter_index].values[value_cntr].valeventtype
        SET referencerecord->event_cds[cur_code_index].event_nomens[event_nomen_index].filter_mean =
        filter->filters[nomen_filter_index].fileventmean
       ENDIF
     ENDFOR
     SET nomen_filter_index += 1
    ENDIF
   ENDWHILE
   SET stat = alterlist(referencerecord->event_cds[cur_code_index].event_nomens,referencerecord->
    event_cds[cur_code_index].event_nomen_cnt)
 END ;Subroutine
 SUBROUTINE (evaluatebedrockeventresult(referencerecord=vc(ref),eventcode=f8,resultfiltermeaning=vc,
  resultvalue=vc,nomenclaturerecord=vc(ref),enforcecriteria=i2) =i2 WITH protect)
   DECLARE event_cd_index = i4 WITH protect, noconstant(0)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE retval = i2 WITH protect, noconstant(0)
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE nomloc = i2 WITH protect, noconstant(0)
   DECLARE nomenclatureid = f8 WITH protect, noconstant(0)
   DECLARE nomcntr = i4 WITH protect, noconstant(0)
   SET retval = 0
   SET event_cd_index = locateval(search_cntr,1,referencerecord->event_cd_cnt,eventcode,
    referencerecord->event_cds[search_cntr].event_cd)
   IF (event_cd_index > 0)
    IF ((referencerecord->event_cds[event_cd_index].event_nomen_cnt=0))
     IF (enforcecriteria=1)
      SET retval = 2
     ELSE
      SET retval = 1
     ENDIF
    ELSE
     FOR (x = 1 TO referencerecord->event_cds[event_cd_index].event_nomen_cnt)
       IF ((referencerecord->event_cds[event_cd_index].event_nomens[x].operation > " "))
        IF ((referencerecord->event_cds[event_cd_index].event_nomens[x].filter_mean=
        resultfiltermeaning))
         IF ((referencerecord->event_cds[event_cd_index].event_nomens[x].event_type=1))
          IF ((referencerecord->event_cds[event_cd_index].event_nomens[x].nomenclature_id > 0))
           IF (operator(cnvtreal(resultvalue),referencerecord->event_cds[event_cd_index].
            event_nomens[x].operation,cnvtreal(referencerecord->event_cds[event_cd_index].
             event_nomens[x].nomenclature_disp)))
            SET retval = x
            SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
           ENDIF
          ELSEIF ((referencerecord->event_cds[event_cd_index].event_nomens[x].freetext_value > " "))
           IF (operator(cnvtreal(resultvalue),referencerecord->event_cds[event_cd_index].
            event_nomens[x].operation,cnvtreal(referencerecord->event_cds[event_cd_index].
             event_nomens[x].freetext_value)))
            SET retval = x
            SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
           ENDIF
          ENDIF
         ELSEIF ((referencerecord->event_cds[event_cd_index].event_nomens[x].event_type=2))
          IF (cnvtreal(referencerecord->event_cds[event_cd_index].event_nomens[x].freetext_value) > 0
          )
           IF (operator(cnvtreal(resultvalue),referencerecord->event_cds[event_cd_index].
            event_nomens[x].operation,cnvtreal(referencerecord->event_cds[event_cd_index].
             event_nomens[x].freetext_value)))
            SET retval = x
            SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
           ENDIF
          ELSEIF ((referencerecord->event_cds[event_cd_index].event_nomens[x].freetext_value > " "))
           IF (operator(resultvalue,referencerecord->event_cds[event_cd_index].event_nomens[x].
            operation,referencerecord->event_cds[event_cd_index].event_nomens[x].freetext_value))
            SET retval = x
            SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
           ENDIF
          ENDIF
         ELSEIF ((referencerecord->event_cds[event_cd_index].event_nomens[x].event_type=0))
          FOR (nomcntr = 1 TO nomenclaturerecord->cnt)
           SET nomenclatureid = nomenclaturerecord->qual[nomcntr].nomenclature_id
           IF (nomenclatureid > 0
            AND (referencerecord->event_cds[event_cd_index].event_nomens[x].nomenclature_id > 0))
            IF (operator(nomenclatureid,referencerecord->event_cds[event_cd_index].event_nomens[x].
             operation,referencerecord->event_cds[event_cd_index].event_nomens[x].nomenclature_id))
             SET retval = x
             SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
            ENDIF
           ELSEIF (nomenclatureid > 0
            AND (referencerecord->event_cds[event_cd_index].event_nomens[x].freetext_value > " "))
            IF (operator(resultvalue,referencerecord->event_cds[event_cd_index].event_nomens[x].
             operation,referencerecord->event_cds[event_cd_index].event_nomens[x].freetext_value))
             SET retval = x
             SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
            ENDIF
           ELSEIF (resultvalue > " "
            AND (referencerecord->event_cds[event_cd_index].event_nomens[x].freetext_value > " "))
            IF (operator(resultvalue,referencerecord->event_cds[event_cd_index].event_nomens[x].
             operation,referencerecord->event_cds[event_cd_index].event_nomens[x].freetext_value))
             SET retval = x
             SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
            ENDIF
           ELSEIF (resultvalue > " "
            AND (referencerecord->event_cds[event_cd_index].event_nomens[x].nomenclature_id > 0))
            IF (operator(resultvalue,referencerecord->event_cds[event_cd_index].event_nomens[x].
             operation,referencerecord->event_cds[event_cd_index].event_nomens[x].nomenclature_disp))
             SET retval = x
             SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
            ENDIF
           ENDIF
          ENDFOR
         ENDIF
        ENDIF
       ELSE
        SET retval = 1
        SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE (getidbysequence(seq_type=vc,refrecord=vc(ref)) =f8)
   CALL echo(build("seq_type...",seq_type))
   DECLARE new_id = f8 WITH protect, noconstant(0.0)
   IF (seq_type="LONG_DATA_SEQ")
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)"###########################;rp0"
     FROM dual
     DETAIL
      new_id = nextseqnum
     WITH format, nocounter
    ;end select
   ELSEIF (seq_type="EKS_SEQ")
    SELECT INTO "nl:"
     nextseqnum = seq(eks_seq,nextval)"###########################;rp0"
     FROM dual
     DETAIL
      new_id = nextseqnum
     WITH format, nocounter
    ;end select
   ELSEIF (seq_type="ORDER_SEQ")
    SELECT INTO "nl:"
     nextseqnum = seq(order_seq,nextval)"###########################;rp0"
     FROM dual
     DETAIL
      new_id = nextseqnum
     WITH format, nocounter
    ;end select
   ELSEIF (seq_type="MPAGES_SEQ")
    SELECT INTO "nl:"
     nextseqnum = seq(mpages_seq,nextval)"###########################;rp0"
     FROM dual
     DETAIL
      new_id = nextseqnum
     WITH format, nocounter
    ;end select
   ELSEIF (seq_type="REFERENCE_SEQ")
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)"###########################;rp0"
     FROM dual
     DETAIL
      new_id = nextseqnum
     WITH format, nocounter
    ;end select
   ENDIF
   CALL echo(build(seq_type,"...",new_id))
   CALL errorhandler("Generate New ID","F",script_name,refrecord)
   RETURN(new_id)
 END ;Subroutine
 SUBROUTINE (loadbedrocksynonyms(filtermeaning=vc,referencerecord=vc(ref),event_cat_mean=vc) =null
  WITH protect)
   DECLARE filter_index = i4 WITH protect, noconstant(0)
   DECLARE val_cntr = i4 WITH protect, noconstant(0)
   DECLARE val_size = i4 WITH protect, noconstant(0)
   SET filter_index = getbedrockfilterindexbymeaning(filtermeaning)
   IF (filter_index > 0)
    SET val_size = size(filter->filters[filter_index].values,5)
    FOR (val_cntr = 1 TO val_size)
      CASE (filter->filters[filter_index].fileventcatmean)
       OF "SYNONYM":
        CALL addsynonymid(referencerecord,filter->filters[filter_index].values[val_cntr].valeventcd,
         filter->filters[filter_index].values[val_cntr].valeventnomdisp,event_cat_mean)
      ENDCASE
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (addsynonymid(referencerecord=vc(ref),synonym_id=f8,display=vc,event_cat_mean=vc) =null
  WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->synonym_id_cnt,synonym_id,
     referencerecord->synonym_ids[search_cntr].synonym_id)
    IF (cur_code_index=0)
     SET referencerecord->synonym_id_cnt += 1
     SET cur_code_index = referencerecord->synonym_id_cnt
     SET stat = alterlist(referencerecord->synonym_ids,referencerecord->synonym_id_cnt)
     SET referencerecord->synonym_ids[cur_code_index].synonym_id = synonym_id
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->synonym_ids[cur_code_index].event_cat_mean_cnt,trim(
      event_cat_mean),referencerecord->synonym_ids[cur_code_index].event_cat_means[search_cntr].
     event_cat_mean)=0)
     SET referencerecord->synonym_ids[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->synonym_ids[cur_code_index].event_cat_mean_cnt
     SET stat = alterlist(referencerecord->synonym_ids[cur_code_index].event_cat_means,
      referencerecord->synonym_ids[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->synonym_ids[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (loadbedrockdrugclasses(filtermeaning=vc,referencerecord=vc(ref),event_cat_mean=vc) =null
   WITH protect)
   DECLARE filter_index = i4 WITH protect, noconstant(0)
   DECLARE val_cntr = i4 WITH protect, noconstant(0)
   DECLARE val_size = i4 WITH protect, noconstant(0)
   SET filter_index = getbedrockfilterindexbymeaning(filtermeaning)
   IF (filter_index > 0)
    SET val_size = size(filter->filters[filter_index].values,5)
    FOR (val_cntr = 1 TO val_size)
      CASE (filter->filters[filter_index].fileventcatmean)
       OF "MULTUM_CAT":
        CALL adddrugclassid(referencerecord,filter->filters[filter_index].values[val_cntr].valeventcd,
         filter->filters[filter_index].values[val_cntr].valeventnomdisp,event_cat_mean)
      ENDCASE
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (adddrugclassid(referencerecord=vc(ref),drug_class_id=f8,display=vc,event_cat_mean=vc) =
  null WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->drug_class_id_cnt,drug_class_id,
     referencerecord->drug_class_ids[search_cntr].drug_class_id)
    IF (cur_code_index=0)
     SET referencerecord->drug_class_id_cnt += 1
     SET cur_code_index = referencerecord->drug_class_id_cnt
     SET stat = alterlist(referencerecord->drug_class_ids,referencerecord->drug_class_id_cnt)
     SET referencerecord->drug_class_ids[cur_code_index].drug_class_id = drug_class_id
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->drug_class_ids[cur_code_index].event_cat_mean_cnt,
     trim(event_cat_mean),referencerecord->drug_class_ids[cur_code_index].event_cat_means[search_cntr
     ].event_cat_mean)=0)
     SET referencerecord->drug_class_ids[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->drug_class_ids[cur_code_index].
     event_cat_mean_cnt
     SET stat = alterlist(referencerecord->drug_class_ids[cur_code_index].event_cat_means,
      referencerecord->drug_class_ids[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->drug_class_ids[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (loadretrieveceresultvalue(cereply=vc(ref),eventresults=vc(ref),resultindex=i4) =null
  WITH protect)
   DECLARE resultdisplay = vc WITH protect, noconstant("")
   DECLARE resultvalue = vc WITH protect, noconstant("")
   DECLARE event_result_value = vc WITH protect, noconstant("")
   DECLARE eventcd = f8 WITH protect, noconstant(0.0)
   DECLARE eventsearchindex = i4 WITH protect, noconstant(0)
   IF (size(cereply->results[resultindex].clinical_events,5) > 0)
    IF (size(cereply->results[resultindex].clinical_events[1].unclassifieds,5))
     SET eventcd = cereply->results[resultindex].clinical_events[1].unclassifieds[1].event_cd
     SET resultdisplay = trim(cereply->results[resultindex].clinical_events[1].unclassifieds[1].
      event_title_text,3)
     IF (textlen(resultdisplay)=0)
      SET eventfilterindex = locateval(eventsearchindex,1,size(cereply->codes,5),eventcd,cereply->
       codes[eventsearchindex].code)
      IF (eventfilterindex > 0)
       SET resultdisplay = cereply->codes[eventfilterindex].display
      ENDIF
     ENDIF
     SET eventresults->event_result_display = resultdisplay
     SET eventresults->event_result_value = resultdisplay
     SET eventresults->event_result_dt_tm = cereply->results[resultindex].clinical_events[1].
     unclassifieds[1].effective_dt_tm
    ENDIF
    IF (size(cereply->results[resultindex].clinical_events[1].documents,5))
     SET eventcd = cereply->results[resultindex].clinical_events[1].documents[1].event_cd
     SET resultdisplay = trim(cereply->results[resultindex].clinical_events[1].documents[1].
      custom_display,3)
     IF (textlen(resultdisplay)=0)
      SET eventfilterindex = locateval(eventsearchindex,1,size(cereply->codes,5),eventcd,cereply->
       codes[eventsearchindex].code)
      IF (eventfilterindex > 0)
       SET resultdisplay = cereply->codes[eventfilterindex].display
      ENDIF
     ENDIF
     SET eventresults->event_result_display = resultdisplay
     SET eventresults->event_result_value = resultdisplay
     SET eventresults->event_result_dt_tm = cereply->results[resultindex].clinical_events[1].
     documents[1].effective_dt_tm
    ENDIF
    IF (size(cereply->results[resultindex].clinical_events[1].measurements,5))
     SET eventcd = cereply->results[resultindex].clinical_events[1].measurements[1].event_cd
     CALL getmeasurementresult(cereply,resultindex,1,1)
     SET eventfilterindex = locateval(eventsearchindex,1,size(cereply->codes,5),eventcd,cereply->
      codes[eventsearchindex].code)
     SET eventresults->event_result_dt_tm = cereply->results[resultindex].clinical_events[1].
     measurements[1].effective_dt_tm
     IF ((temp_meas_res_rec->res_type != 3))
      SET eventresults->event_result_value = temp_meas_res_rec->result
      IF (eventfilterindex > 0)
       SET eventresults->event_result_display = build2(cereply->codes[eventfilterindex].display," = ",
        eventresults->event_result_value)
      ENDIF
     ELSE
      IF (eventfilterindex > 0)
       SET eventresults->event_result_value = cereply->codes[eventfilterindex].display
       SET eventresults->event_result_display = eventresults->event_result_value
      ENDIF
      SET eventresults->event_result_display = build2(eventresults->event_result_display," = ",format
       (cereply->results[resultindex].clinical_events[1].measurements[1].date_value[1].dt_tm,
        "mm/dd/yyyy hh:mm;;d"))
     ENDIF
     IF (validate(debug_ind,0)=1)
      CALL echorecord(eventresults)
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (getceresultnomenclatureids(cereply=vc(ref),nomenclaturerecord=vc(ref),resultindex=i4) =
  null WITH protect)
   DECLARE event_nomenclature_id = f8 WITH protect, noconstant(0.0)
   DECLARE nomen_cntr = i4 WITH protect, noconstant(0)
   DECLARE nomen_size = i4 WITH protect, noconstant(0)
   SET stat = initrec(nomenclaturerecord)
   IF (size(cereply->results[resultindex].clinical_events,5) > 0)
    IF (size(cereply->results[resultindex].clinical_events[1].measurements,5) > 0)
     IF (size(cereply->results[resultindex].clinical_events[1].measurements[1].code_value,5) > 0)
      IF (size(cereply->results[resultindex].clinical_events[1].measurements[1].code_value[1].values,
       5) > 0)
       SET nomen_size = size(cereply->results[resultindex].clinical_events[1].measurements[1].
        code_value[1].values,5)
       SET nomenclaturerecord->cnt = nomen_size
       SET stat = alterlist(nomenclaturerecord->qual,nomenclaturerecord->cnt)
       FOR (nomen_cntr = 1 TO nomen_size)
         SET nomenclaturerecord->qual[nomen_cntr].nomenclature_id = cereply->results[resultindex].
         clinical_events[1].measurements[1].code_value[1].values[nomen_cntr].nomenclature_id
       ENDFOR
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((nomenclaturerecord->cnt=0))
    SET nomenclaturerecord->cnt = 1
    SET stat = alterlist(nomenclaturerecord->qual,1)
    SET nomenclaturerecord->qual[1].nomenclature_id = event_nomenclature_id
   ENDIF
 END ;Subroutine
 SUBROUTINE (getbedrockflexparententityid(encntr_id=f8,personnel_id=f8,category_meaning=vc) =f8 WITH
  protect)
   DECLARE flex_parent_entity_id = f8 WITH protect, noconstant(0)
   DECLARE flex_flag = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_category b
    PLAN (b
     WHERE b.category_mean=category_meaning)
    DETAIL
     flex_flag = b.flex_flag
    WITH nocounter
   ;end select
   CASE (flex_flag)
    OF 1:
     SELECT INTO "nl:"
      FROM prsnl p
      PLAN (p
       WHERE p.person_id=personnel_id)
      DETAIL
       flex_parent_entity_id = p.position_cd
      WITH nocounter
     ;end select
    OF 2:
     SELECT INTO "nl:"
      FROM encounter e
      PLAN (e
       WHERE e.encntr_id=encntr_id)
      DETAIL
       flex_parent_entity_id = e.loc_facility_cd
      WITH nocounter
     ;end select
   ENDCASE
   RETURN(flex_parent_entity_id)
 END ;Subroutine
 SUBROUTINE (loadbedrockmultifreetext(filtermeaning=vc,referencerecord=vc(ref),event_cat_mean=vc) =
  null WITH protect)
   DECLARE filter_index = i4 WITH protect, noconstant(0)
   DECLARE f_cntr = i4 WITH protect, noconstant(0)
   DECLARE val_size = i4 WITH protect, noconstant(0)
   DECLARE cur_freetext_value = vc WITH protect, noconstant("")
   SET filter_index = getbedrockfilterindexbymeaning(filtermeaning)
   IF (filter_index > 0)
    SET val_size = size(filter->filters[filter_index].values,5)
    SELECT
     group_seq = filter->filters[filter_index].values[d1.seq].valeventgrpseq, value_seq = filter->
     filters[filter_index].values[d1.seq].valeventseq
     FROM (dummyt d1  WITH seq = val_size)
     ORDER BY group_seq, value_seq
     HEAD group_seq
      f_cntr += 1
      IF ((f_cntr > br_multi_freetext->freetext_cnt))
       stat = alterlist(br_multi_freetext->freetexts,(f_cntr+ 10))
      ENDIF
     HEAD value_seq
      cur_freetext_value = trim(filter->filters[filter_index].values[d1.seq].valeventftx,3)
      CASE (value_seq)
       OF 0:
        br_multi_freetext->freetexts[f_cntr].long_name = cur_freetext_value
       OF 1:
        br_multi_freetext->freetexts[f_cntr].display_name = cur_freetext_value
      ENDCASE
     FOOT REPORT
      br_multi_freetext->freetext_cnt = f_cntr, stat = alterlist(br_multi_freetext->freetexts,
       br_multi_freetext->freetext_cnt)
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE (addorderentryfieldcd(referencerecord=vc(ref),code=f8,event_cat_mean=vc) =null WITH
  protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->oe_field_cd_cnt,code,
     referencerecord->oe_field_cds[search_cntr].oe_field_cd)
    IF (cur_code_index=0)
     SET referencerecord->oe_field_cd_cnt += 1
     SET cur_code_index = referencerecord->oe_field_cd_cnt
     SET stat = alterlist(referencerecord->oe_field_cds,referencerecord->oe_field_cd_cnt)
     SET referencerecord->oe_field_cds[cur_code_index].oe_field_cd = code
     SET referencerecord->oe_field_cds[cur_code_index].oe_field_cd_disp = trim(uar_get_code_display(
       code))
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->oe_field_cds[cur_code_index].event_cat_mean_cnt,trim
     (event_cat_mean),referencerecord->oe_field_cds[cur_code_index].event_cat_means[search_cntr].
     event_cat_mean)=0)
     SET referencerecord->oe_field_cds[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->oe_field_cds[cur_code_index].event_cat_mean_cnt
     SET stat = alterlist(referencerecord->oe_field_cds[cur_code_index].event_cat_means,
      referencerecord->oe_field_cds[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->oe_field_cds[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (addcodevalue(referencerecord=vc(ref),code=f8,event_cat_mean=vc) =null WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->code_value_cnt,code,referencerecord
     ->code_values[search_cntr].code_value)
    IF (cur_code_index=0)
     SET referencerecord->code_value_cnt += 1
     SET cur_code_index = referencerecord->code_value_cnt
     SET stat = alterlist(referencerecord->code_values,referencerecord->code_value_cnt)
     SET referencerecord->code_values[cur_code_index].code_value = code
     SET referencerecord->code_values[cur_code_index].code_value_disp = trim(uar_get_code_display(
       code))
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->code_values[cur_code_index].event_cat_mean_cnt,trim(
      event_cat_mean),referencerecord->code_values[cur_code_index].event_cat_means[search_cntr].
     event_cat_mean)=0)
     SET referencerecord->code_values[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->code_values[cur_code_index].event_cat_mean_cnt
     SET stat = alterlist(referencerecord->code_values[cur_code_index].event_cat_means,
      referencerecord->code_values[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->code_values[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (getviewableencounters(personid=f8,prsnlid=f8,encntr_rec=vc(ref)) =null WITH protect)
   CALL log_message("In GetViewableEncounters()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE num = i4 WITH noconstant(0), protect
   DECLARE prsnl_pos = i4 WITH noconstant(0), protect
   DECLARE person_pos = i4 WITH noconstant(0), protect
   DECLARE retrieve_encntrs = i4 WITH noconstant(0), protect
   DECLARE last_encntr_updt_dt_tm = dq8 WITH noconstant(0), protect
   SET prsnl_pos = locateval(num,1,encntrs->prsnl_cnt,prsnlid,encntrs->prsnl_list[num].prsnl_id)
   IF (prsnl_pos=0)
    CALL log_message(build2("IN GetViewableEncounters: ","PRSNL NOT FOUND"),log_level_debug)
    CALL log_message(cnvtstring(prsnlid),log_level_debug)
    SET encntrs->prsnl_cnt += 1
    SET stat = alterlist(encntrs->prsnl_list,encntrs->prsnl_cnt)
    SET prsnl_pos = encntrs->prsnl_cnt
    SET encntrs->prsnl_list[prsnl_pos].prsnl_id = prsnlid
   ENDIF
   SET person_pos = locateval(num,1,encntrs->prsnl_list[prsnl_pos].person_cnt,personid,encntrs->
    prsnl_list[prsnl_pos].person_list[num].person_id)
   SELECT INTO "NL:"
    FROM encounter e
    WHERE e.person_id=personid
    ORDER BY e.updt_dt_tm DESC
    HEAD REPORT
     last_encntr_updt_dt_tm = e.updt_dt_tm
    WITH nocounter
   ;end select
   IF (person_pos=0)
    SET retrieve_encntrs = 1
    SET encntrs->prsnl_list[prsnl_pos].person_cnt += 1
    SET person_pos = encntrs->prsnl_list[prsnl_pos].person_cnt
    SET stat = alterlist(encntrs->prsnl_list[prsnl_pos].person_list,person_pos)
    SET encntrs->prsnl_list[prsnl_pos].person_list[person_pos].person_id = personid
    SET encntrs->prsnl_list[prsnl_pos].person_list[person_pos].last_updt_dt_tm =
    last_encntr_updt_dt_tm
   ELSEIF (cnvtdatetime(last_encntr_updt_dt_tm) > cnvtdatetime(encntrs->prsnl_list[prsnl_pos].
    person_list[person_pos].last_updt_dt_tm))
    CALL echo(build2("last_encntr_updt_dt_tm:",cnvtdatetime(last_encntr_updt_dt_tm)))
    CALL echo(build2("last_updt_dt_tm:",cnvtdatetime(encntrs->prsnl_list[prsnl_pos].person_list[
       person_pos].last_updt_dt_tm)))
    SET retrieve_encntrs = 1
    SET encntrs->prsnl_list[prsnl_pos].person_list[person_pos].last_updt_dt_tm =
    last_encntr_updt_dt_tm
   ENDIF
   IF (retrieve_encntrs=1)
    CALL log_message(build2("IN GetViewableEncounters-encntrs: ","Refreshing"),log_level_debug)
    CALL log_message(cnvtstring(personid),log_level_debug)
    RECORD 115424_request(
      1 read_not_active_ind = i2
      1 read_not_effective_ind = i2
      1 person_qual[*]
        2 person_id = f8
      1 filters
        2 encntr_type_class_cds[*]
          3 encntr_type_class_cd = f8
        2 facility_cds[*]
          3 facility_cd = f8
        2 organization_ids[*]
          3 organization_id = f8
      1 skip_org_security_ind = i2
      1 user_id = f8
      1 debug_ind = i2
      1 debug
        2 org_security_level = i4
        2 lifetime_reltn_override_level = i4
        2 use_dynamic_security_ind = i2
        2 trust_id = f8
      1 load
        2 encntr_prsnl_reltns_ind = i2
    )
    RECORD 115424_reply(
      1 person_qual_cnt = i4
      1 person_qual[*]
        2 person_id = f8
        2 encounter_qual_cnt = i4
        2 encounter_qual[*]
          3 encounter_id = f8
          3 encounter_prsnl_reltn_qual[*]
            4 encntr_prsnl_reltn_id = f8
            4 encntr_prsnl_r_cd = f8
            4 beg_effective_dt_tm = dq8
            4 end_effective_dt_tm = dq8
        2 active_encounter_cnt = i4
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET stat = alterlist(115424_request->person_qual,1)
    SET 115424_request->person_qual[1].person_id = personid
    SET 115424_request->user_id = prsnlid
    EXECUTE pm_get_encounter_by_person  WITH replace("REQUEST","115424_REQUEST"), replace("REPLY",
     "115424_REPLY")
    IF ((115424_reply->person_qual_cnt=1))
     IF ((115424_reply->person_qual[1].encounter_qual_cnt > 0))
      SET stat = alterlist(encntrs->prsnl_list[prsnl_pos].person_list[person_pos].encntr_list,
       115424_reply->person_qual[1].encounter_qual_cnt)
      SET encntrs->prsnl_list[prsnl_pos].person_list[person_pos].encntr_cnt = 115424_reply->
      person_qual[1].encounter_qual_cnt
      FOR (x = 1 TO 115424_reply->person_qual[1].encounter_qual_cnt)
        SET encntrs->prsnl_list[prsnl_pos].person_list[person_pos].encntr_list[x].value =
        115424_reply->person_qual[1].encounter_qual[x].encounter_id
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
   SET dencntr_vc = cnvtrectojson(encntrs)
   CALL log_message(build2("IN GetViewableEncounters-encntrs: ",dencntr_vc),log_level_debug)
   SET stat = moverec(encntrs->prsnl_list[prsnl_pos].person_list[person_pos].encntr_list,encntr_rec->
    qual)
   SET encntr_rec->cnt = encntrs->prsnl_list[prsnl_pos].person_list[person_pos].encntr_cnt
   CALL log_message(build("Exit GetViewableEncounters(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 RECORD conmantree(
   1 group[*]
     2 group_id = f8
     2 collation_seq = i4
     2 title_text = vc
     2 parent_idx = i4
     2 children[*]
       3 idx = i4
     2 tool[*]
       3 idx = i4
   1 tool[*]
     2 tool_id = f8
     2 group_idx = i4
     2 collation_seq = i4
     2 title_text = vc
     2 help_text = vc
     2 report_name = vc
     2 param_string = vc
     2 tool_key_text = vc
 )
 DECLARE createtree(null) = null
 DECLARE createlevelone(null) = null
 SUBROUTINE createtree(null)
   RECORD groups(
     1 group[*]
       2 id = f8
   ) WITH protect
   DECLARE treeheight = i4 WITH protect, noconstant(0)
   DECLARE treeheightlast = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE idxtree = i4 WITH protect, noconstant(0)
   CALL createlevelone(null)
   SET treeheight = size(conmantree->group,5)
   WHILE (treeheight > treeheightlast)
     SET stat = alterlist(groups->group,(treeheight - treeheightlast))
     SET idx = 0
     FOR (idxtree = (1+ treeheightlast) TO treeheight)
      SET idx += 1
      SET groups->group[idx].id = conmantree->group[idxtree].group_id
     ENDFOR
     SET treeheightlast = treeheight
     CALL extendtree(groups)
     SET treeheight = size(conmantree->group,5)
   ENDWHILE
 END ;Subroutine
 SUBROUTINE createlevelone(null)
   DECLARE groupidx = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   RECORD groups(
     1 group[*]
       2 id = f8
   ) WITH protect
   SELECT INTO "nl:"
    FROM cnfg_mgr_grp grp
    WHERE ((grp.parent_grp_id=grp.cnfg_mgr_grp_id) OR ( NOT ( EXISTS (
    (SELECT
     parent.cnfg_mgr_grp_id
     FROM cnfg_mgr_grp parent
     WHERE grp.parent_grp_id=parent.cnfg_mgr_grp_id)))))
    ORDER BY grp.collation_seq, grp.title_txt
    DETAIL
     groupidx += 1, stat = alterlist(conmantree->group,groupidx), conmantree->group[groupidx].
     group_id = grp.cnfg_mgr_grp_id,
     conmantree->group[groupidx].collation_seq = grp.collation_seq, conmantree->group[groupidx].
     title_text = grp.title_txt, stat = alterlist(groups->group,groupidx),
     groups->group[groupidx].id = grp.cnfg_mgr_grp_id
    WITH nocounter
   ;end select
   CALL addtools(groups)
 END ;Subroutine
 SUBROUTINE (addtools(groups=vc(ref)) =null)
   IF (size(groups->group,5)=0)
    RETURN(null)
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE toolidx = i4 WITH protect, noconstant(size(conmantree->tool,5))
   DECLARE groupidx = i4 WITH protect, noconstant(0)
   DECLARE grouptoolidx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM cnfg_mgr_grp grp,
     cnfg_mgr_tool tool
    WHERE expand(idx,1,size(groups->group,5),grp.cnfg_mgr_grp_id,groups->group[idx].id)
     AND grp.cnfg_mgr_grp_id=tool.cnfg_mgr_grp_id
     AND tool.cnfg_mgr_tool_id != 0.0
     AND tool.active_ind=1
    ORDER BY grp.collation_seq, grp.title_txt, tool.collation_seq,
     tool.title_txt
    HEAD grp.cnfg_mgr_grp_id
     groupidx = locateval(idx,1,size(conmantree->group,5),grp.cnfg_mgr_grp_id,conmantree->group[idx].
      group_id), grouptoolidx = size(conmantree->group[groupidx].tool,5)
    DETAIL
     toolidx += 1, grouptoolidx += 1, stat = alterlist(conmantree->tool,toolidx),
     conmantree->tool[toolidx].group_idx = (groupidx - 1), conmantree->tool[toolidx].tool_id = tool
     .cnfg_mgr_tool_id, conmantree->tool[toolidx].collation_seq = tool.collation_seq,
     conmantree->tool[toolidx].title_text = tool.title_txt, conmantree->tool[toolidx].report_name =
     tool.report_name, conmantree->tool[toolidx].param_string = tool.report_param,
     conmantree->tool[toolidx].tool_key_text = tool.tool_key_txt, conmantree->tool[toolidx].help_text
      = tool.help_txt, stat = alterlist(conmantree->group[groupidx].tool,grouptoolidx),
     conmantree->group[groupidx].tool[grouptoolidx].idx = (toolidx - 1)
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE (extendtree(groups=vc(ref)) =null)
   DECLARE treeheight = i4 WITH protect, noconstant(size(conmantree->group,5))
   DECLARE groupidx = i4 WITH protect, noconstant(size(conmantree->group,5))
   DECLARE groupidx2 = i4 WITH protect, noconstant(0)
   DECLARE parentpos = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   RECORD groupstools(
     1 group[*]
       2 id = f8
   ) WITH protect
   SELECT INTO "nl:"
    FROM cnfg_mgr_grp grp
    WHERE expand(idx,1,size(groups->group,5),grp.parent_grp_id,groups->group[idx].id)
     AND grp.cnfg_mgr_grp_id != 0.0
    ORDER BY grp.collation_seq, grp.title_txt
    DETAIL
     groupidx += 1, groupidx2 += 1, stat = alterlist(conmantree->group,groupidx),
     conmantree->group[groupidx].group_id = grp.cnfg_mgr_grp_id, conmantree->group[groupidx].
     collation_seq = grp.collation_seq, conmantree->group[groupidx].title_text = grp.title_txt,
     parentpos = locateval(idx,1,treeheight,grp.parent_grp_id,conmantree->group[idx].group_id),
     conmantree->group[groupidx].parent_idx = (parentpos - 1), stat = alterlist(groupstools->group,
      groupidx2),
     groupstools->group[groupidx2].id = grp.cnfg_mgr_grp_id, stat = alterlist(conmantree->group[
      parentpos].children,(1+ size(conmantree->group[parentpos].children,5))), conmantree->group[
     parentpos].children[size(conmantree->group[parentpos].children,5)].idx = (groupidx - 1)
    WITH nocounter, expand = 1
   ;end select
   CALL addtools(groupstools)
 END ;Subroutine
 CALL createtree(null)
 IF (validate(debug_ind,0)=1)
  CALL echorecord(conmantree)
 ENDIF
 CALL ajaxreply(trim(cnvtrectojson(conmantree)))
END GO
