CREATE PROGRAM cv_add_fld_xref:dba
 IF (validate(cv_trns_del)=0)
  DECLARE cv_trns_add = i2 WITH protect, constant(1)
  DECLARE cv_trns_chg = i2 WITH protect, constant(2)
  DECLARE cv_trns_del = i2 WITH protect, constant(3)
 ENDIF
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 return_rec[*]
      2 xref_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD holder
 RECORD holder(
   1 rec[*]
     2 task_assay_cd = f8
     2 event_cd = f8
 )
 DECLARE xref_id = f8 WITH protect
 DECLARE failed = c1 WITH protect, noconstant("T")
 DECLARE event_cd = f8 WITH protect
 DECLARE init = i4 WITH protect
 DECLARE meaningval = vc WITH protect
 DECLARE codeset = i4 WITH protect, constant(14003)
 DECLARE ieventcnt = i4 WITH protect
 DECLARE irecordsize = i4 WITH protect, noconstant(size(request->cv_xref_rec,5))
 DECLARE stat = i4 WITH protect
 SET stat = alterlist(reply->return_rec,irecordsize)
 SET stat = alterlist(holder->rec,irecordsize)
 SET reply->status_data.status = "F"
 DECLARE idx = i4 WITH protect
 DECLARE new_list_size = i4 WITH protect
 DECLARE cur_list_size = i4 WITH protect
 DECLARE batch_size = i4 WITH protect, constant(10)
 DECLARE nstart = i4 WITH protect
 DECLARE loop_cnt = i4 WITH protect
 SET cur_list_size = size(request->cv_xref_rec,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(request->cv_xref_rec,new_list_size)
 SET nstart = 1
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET request->cv_xref_rec[idx].cdf_meaning = request->cv_xref_rec[cur_list_size].cdf_meaning
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   code_value cv
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cv
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cv.cdf_meaning,request->cv_xref_rec[idx].
    cdf_meaning)
    AND cv.code_set=codeset
    AND cv.active_ind=1
    AND cv.cdf_meaning > " ")
  HEAD REPORT
   num1 = 0
  DETAIL
   index = locateval(num1,1,cur_list_size,cv.cdf_meaning,request->cv_xref_rec[num1].cdf_meaning)
   WHILE (index != 0)
    holder->rec[index].task_assay_cd = cv.code_value,index = locateval(num1,(index+ 1),cur_list_size,
     cv.cdf_meaning,request->cv_xref_rec[num1].cdf_meaning)
   ENDWHILE
  WITH nocounter
 ;end select
 SET stat = alterlist(request->cv_xref_rec,cur_list_size)
 SET cur_list_size = size(holder->rec,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(holder->rec,new_list_size)
 SET nstart = 1
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET holder->rec[idx].task_assay_cd = holder->rec[cur_list_size].task_assay_cd
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   discrete_task_assay dta
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (dta
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),dta.task_assay_cd,holder->rec[idx].
    task_assay_cd)
    AND dta.task_assay_cd != 0.0)
  HEAD REPORT
   num1 = 0
  DETAIL
   index = locateval(num1,1,cur_list_size,dta.task_assay_cd,holder->rec[num1].task_assay_cd)
   WHILE (index != 0)
    holder->rec[index].event_cd = dta.event_cd,index = locateval(num1,(index+ 1),cur_list_size,dta
     .task_assay_cd,holder->rec[num1].task_assay_cd)
   ENDWHILE
  WITH nocounter
 ;end select
 SET stat = alterlist(holder->rec,cur_list_size)
 FOR (x = 1 TO irecordsize)
   IF ((request->cv_xref_rec[x].transaction=cv_trns_add))
    SELECT INTO "nl:"
     nextseqnum = seq(card_vas_seq,nextval)
     FROM dual
     DETAIL
      reply->return_rec[x].xref_id = nextseqnum
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 INSERT  FROM cv_xref m,
   (dummyt d3  WITH seq = value(irecordsize))
  SET m.dataset_id = request->cv_xref_rec[d3.seq].dataset_id, m.registry_field_name = request->
   cv_xref_rec[d3.seq].registry_field_name, m.cern_source_table_name = request->cv_xref_rec[d3.seq].
   cern_source_table_name,
   m.cern_source_field_name = request->cv_xref_rec[d3.seq].cern_source_field_name, m
   .xref_internal_name = request->cv_xref_rec[d3.seq].xref_internal_name, m.xref_id = reply->
   return_rec[d3.seq].xref_id,
   m.event_cd = holder->rec[d3.seq].event_cd, m.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   m.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
   m.data_status_cd = reqdata->data_status_cd, m.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
   m.data_status_prsnl_id = reqinfo->updt_id,
   m.updt_id = reqinfo->updt_id, m.updt_dt_tm = cnvtdatetime(curdate,curtime3), m.updt_task = reqinfo
   ->updt_task,
   m.updt_applctx = reqinfo->updt_applctx, m.updt_cnt = 0, m.updt_app = reqinfo->updt_app,
   m.updt_req = reqinfo->updt_req, m.active_ind = 1, m.active_status_cd = reqdata->active_status_cd,
   m.active_status_prsnl_id = reqinfo->updt_id, m.active_status_dt_tm = cnvtdatetime(curdate,curtime3
    ), m.event_type_cd = request->cv_xref_rec[d3.seq].event_type_cd,
   m.group_type_cd = request->cv_xref_rec[d3.seq].group_type_cd, m.task_assay_cd = holder->rec[d3.seq
   ].task_assay_cd, m.field_type_cd = request->cv_xref_rec[d3.seq].field_type_cd,
   m.reqd_flag = request->cv_xref_rec[d3.seq].reqdflag, m.sub_event_type_cd = request->cv_xref_rec[d3
   .seq].sub_event_type_cd, m.display_field_ind = request->cv_xref_rec[d3.seq].display_fld_ind,
   m.collect_start_dt_tm = cnvtdatetime(request->cv_xref_rec[d3.seq].collect_start_dt_tm), m
   .collect_stop_dt_tm = cnvtdatetime(request->cv_xref_rec[d3.seq].collect_stop_dt_tm), m.audit_flag
    = request->cv_xref_rec[d3.seq].audit_flag,
   m.element_nbr = request->cv_xref_rec[d3.seq].element_nbr
  PLAN (d3
   WHERE (request->cv_xref_rec[d3.seq].transaction=cv_trns_add))
   JOIN (m)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "F"
  GO TO exit_script
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 DECLARE cv_add_fld_xref_vrsn = vc WITH private, constant("MOD 012 - MH9140 - 12/30/2004")
END GO
