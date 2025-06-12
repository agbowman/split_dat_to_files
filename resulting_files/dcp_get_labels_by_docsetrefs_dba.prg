CREATE PROGRAM dcp_get_labels_by_docsetrefs:dba
 RECORD tmp_docsetref(
   1 qual[*]
     2 docsetnamekey = vc
 )
 RECORD reply(
   1 label_list[*]
     2 dynamic_label_id = f8
     2 label_name = vc
     2 result_set_id = f8
   1 label_template_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE valcnt = i4 WITH protect, noconstant(size(request->docsetref_list,5))
 DECLARE failure_ind = i2 WITH protect, noconstant(0)
 DECLARE zero_ind = i2 WITH protect, noconstant(1)
 DECLARE copycnt = i4 WITH protect, noconstant(0)
 IF (valcnt=0)
  GO TO failure
 ENDIF
 DECLARE maxexpcnt = i4 WITH protect, constant(20)
 DECLARE expblocksize = i4 WITH protect, constant(ceil(((valcnt * 1.0)/ maxexpcnt)))
 DECLARE ex_start = i4 WITH protect, noconstant(1)
 DECLARE ex_idx = i4 WITH protect, noconstant(1)
 DECLARE grp_cnt = i4 WITH protect, noconstant(0)
 DECLARE active_status = f8 WITH protect, constant(uar_get_code_by("MEANING",4002015,"ACTIVE"))
 DECLARE expmaxsize = i4 WITH protect, noconstant((expblocksize * maxexpcnt))
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE script_version = vc WITH protect, noconstant("")
 DECLARE ierrcode = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = vc WITH protect, noconstant("")
 IF (active_status <= 0)
  SET failure_ind = 1
  GO TO failure
 ENDIF
 SET stat = alterlist(tmp_docsetref->qual,expmaxsize)
 FOR (copycnt = 1 TO valcnt)
   SET tmp_docsetref->qual[copycnt].docsetnamekey = cnvtupper(trim(request->docsetref_list[copycnt].
     docsetname,3))
 ENDFOR
 FOR (copycnt = (valcnt+ 1) TO expmaxsize)
   SET tmp_docsetref->qual[copycnt].docsetnamekey = cnvtupper(trim(request->docsetref_list[valcnt].
     docsetname,3))
 ENDFOR
 DECLARE idx = i4 WITH protect, noconstant(0)
 SET stat = alterlist(reply->label_list,valcnt)
 IF (validate(request->addbabylabel_ind,0))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(expblocksize)),
    dynamic_label_template dlt,
    doc_set_ref dsr
   PLAN (d1
    WHERE assign(ex_start,evaluate(d1.seq,1,1,(ex_start+ maxexpcnt))))
    JOIN (dsr
    WHERE expand(ex_idx,ex_start,((ex_start+ maxexpcnt) - 1),dsr.doc_set_name_key,tmp_docsetref->
     qual[ex_idx].docsetnamekey)
     AND dsr.active_ind=1)
    JOIN (dlt
    WHERE dsr.doc_set_ref_id=dlt.doc_set_ref_id)
   HEAD dlt.label_template_id
    reply->label_template_id = dlt.label_template_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cdl.ce_dynamic_label_id, cdl.label_name
   FROM ce_dynamic_label cdl
   PLAN (cdl
    WHERE (cdl.label_template_id=reply->label_template_id)
     AND cdl.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
     AND (cdl.person_id=request->person_id)
     AND cdl.label_status_cd=active_status)
   ORDER BY cdl.ce_dynamic_label_id
   HEAD cdl.ce_dynamic_label_id
    idx = (idx+ 1)
    IF (idx > size(reply->label_list,5))
     stat = alterlist(reply->label_list,idx)
    ENDIF
    reply->label_list[idx].dynamic_label_id = cdl.ce_dynamic_label_id, reply->label_list[idx].
    label_name = cdl.label_name, reply->label_list[idx].result_set_id = cdl.result_set_id
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   cdl.ce_dynamic_label_id, cdl.label_name
   FROM (dummyt d1  WITH seq = value(expblocksize)),
    ce_dynamic_label cdl,
    dynamic_label_template dlt,
    doc_set_ref dsr
   PLAN (d1
    WHERE assign(ex_start,evaluate(d1.seq,1,1,(ex_start+ maxexpcnt))))
    JOIN (dsr
    WHERE expand(ex_idx,ex_start,((ex_start+ maxexpcnt) - 1),dsr.doc_set_name_key,tmp_docsetref->
     qual[ex_idx].docsetnamekey)
     AND dsr.active_ind=1)
    JOIN (dlt
    WHERE dsr.doc_set_ref_id=dlt.doc_set_ref_id)
    JOIN (cdl
    WHERE cdl.label_template_id=dlt.label_template_id
     AND cdl.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
     AND (cdl.person_id=request->person_id)
     AND cdl.label_status_cd=active_status)
   ORDER BY cdl.ce_dynamic_label_id
   HEAD cdl.ce_dynamic_label_id
    idx = (idx+ 1),
    CALL echo(build("idx:  ",idx))
    IF (idx > size(reply->label_list,5))
     stat = alterlist(reply->label_list,idx)
    ENDIF
    reply->label_list[idx].dynamic_label_id = cdl.ce_dynamic_label_id, reply->label_list[idx].
    label_name = cdl.label_name, reply->label_list[idx].result_set_id = cdl.result_set_id
   WITH nocounter
  ;end select
 ENDIF
 IF (idx > 0)
  SET zero_ind = 0
 ELSE
  SET failure_ind = 0
 ENDIF
#failure
 IF (failure_ind=1)
  SET reply->status_data.status = "F"
  SET ierrcode = error(serrmsg,0)
  IF (ierrcode > 0)
   CALL echo(concat("Error = ",serrmsg))
  ENDIF
 ELSEIF (zero_ind=1)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "002 20/01/2017 PB030754"
 FREE SET tmp_docsetref
 SET modify = nopredeclare
END GO
