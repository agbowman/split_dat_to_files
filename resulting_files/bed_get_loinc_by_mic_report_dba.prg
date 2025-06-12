CREATE PROGRAM bed_get_loinc_by_mic_report:dba
 SET modify = predeclare
 RECORD reply(
   1 codes[*]
     2 catalog_cd = f8
     2 catalog_disp = vc
     2 source_cd = f8
     2 source_disp = vc
     2 concept_ident_mic_rpt_id = f8
     2 concept_cki = vc
     2 ignore_ind = i2
     2 loinc_code = vc
     2 loinc_short_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_check = i4 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE cur_size = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, noconstant(0)
 DECLARE expand_idx = i4 WITH protect, noconstant(0)
 DECLARE new_size = i4 WITH protect, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(0)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->codes,size(request->procedures,5))
 FOR (x = 1 TO size(request->procedures,5))
  SET reply->codes[x].catalog_cd = request->procedures[x].catalog_cd
  SET reply->codes[x].source_cd = request->procedures[x].source_cd
 ENDFOR
 SET cur_size = size(reply->codes,5)
 IF (cur_size < 100)
  SET batch_size = cur_size
 ELSE
  SET batch_size = 100
 ENDIF
 SET loop_cnt = ceil((cnvtreal(cur_size)/ batch_size))
 SET new_size = (loop_cnt * batch_size)
 SET start = 1
 SET stat = alterlist(reply->codes,new_size)
 FOR (x = (cur_size+ 1) TO new_size)
  SET reply->codes[x].catalog_cd = reply->codes[cur_size].catalog_cd
  SET reply->codes[x].source_cd = reply->codes[cur_size].source_cd
 ENDFOR
 SELECT INTO "nl:"
  loc_start = start
  FROM (dummyt d  WITH seq = value(loop_cnt)),
   concept_ident_mic_rpt cimr,
   nomenclature n
  PLAN (d
   WHERE initarray(start,evaluate(d.seq,1,1,(start+ batch_size))))
   JOIN (cimr
   WHERE expand(expand_idx,start,((start+ batch_size) - 1),cimr.catalog_cd,reply->codes[expand_idx].
    catalog_cd,
    cimr.source_cd,reply->codes[expand_idx].source_cd)
    AND cimr.active_ind=1
    AND cimr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cimr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND (cimr.service_resource_cd=request->service_resource_cd)
    AND (cimr.task_cd=request->task_cd)
    AND (cimr.org_class_flag=request->org_class_flag)
    AND (cimr.concept_type_flag=request->concept_type_flag))
   JOIN (n
   WHERE ((n.concept_cki=cimr.concept_cki
    AND trim(cimr.concept_cki) > " "
    AND n.primary_vterm_ind=1
    AND n.disallowed_ind=0
    AND n.active_ind=1
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)) OR (n.nomenclature_id=0.0)) )
  DETAIL
   pos = locateval(idx,loc_start,((loc_start+ batch_size) - 1),cimr.catalog_cd,reply->codes[idx].
    catalog_cd,
    cimr.source_cd,reply->codes[idx].source_cd)
   IF (pos > 0)
    reply->codes[pos].concept_ident_mic_rpt_id = cimr.concept_ident_mic_rpt_id, reply->codes[pos].
    concept_cki = cimr.concept_cki, reply->codes[pos].ignore_ind = cimr.ignore_ind
    IF (n.nomenclature_id > 0.0)
     reply->codes[pos].loinc_code = n.source_identifier, reply->codes[pos].loinc_short_name = n
     .short_string
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET error_check = error(error_msg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
 ELSEIF (size(reply->codes,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET modify = nopredeclare
END GO
