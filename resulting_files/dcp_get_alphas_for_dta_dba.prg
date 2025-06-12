CREATE PROGRAM dcp_get_alphas_for_dta:dba
 RECORD reply(
   1 alpha_responses[*]
     2 nomenclature_id = f8
     2 source_string = vc
     2 short_string = vc
     2 mnemonic = c25
     2 sequence = i4
     2 default_ind = i2
     2 description = vc
     2 result_value = f8
     2 multi_alpha_sort_order = i4
     2 concept_identifier = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD ref_range(
   1 qual[*]
     2 reference_range_factor_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE ref_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM reference_range_factor rrf
  WHERE (rrf.task_assay_cd=request->dta_cd)
   AND rrf.active_ind=1
  DETAIL
   ref_cnt += 1
   IF (mod(ref_cnt,5)=1)
    stat = alterlist(ref_range->qual,(ref_cnt+ 4))
   ENDIF
   ref_range->qual[ref_cnt].reference_range_factor_id = rrf.reference_range_factor_id
  FOOT REPORT
   stat = alterlist(ref_range->qual,ref_cnt)
  WITH nocounter
 ;end select
 CALL echo(build("ref_cnt:",ref_cnt))
 DECLARE alpha_cnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE nsize = i4 WITH protect, noconstant(20)
 DECLARE orig_size = i4 WITH protect, noconstant(size(ref_range->qual,5))
 DECLARE loop_cnt = i4 WITH protect, noconstant(ceil((cnvtreal(orig_size)/ nsize)))
 DECLARE ntotal = i4 WITH protect, noconstant((loop_cnt * nsize))
 SET stat = alterlist(ref_range->qual,ntotal)
 FOR (num = (orig_size+ 1) TO ntotal)
   SET ref_range->qual[num].reference_range_factor_id = ref_range->qual[orig_size].
   reference_range_factor_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loop_cnt)),
   alpha_responses ar,
   nomenclature n
  PLAN (d
   WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
   JOIN (ar
   WHERE expand(idx,nstart,((nstart+ nsize) - 1),ar.reference_range_factor_id,ref_range->qual[idx].
    reference_range_factor_id)
    AND ar.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=ar.nomenclature_id
    AND n.active_ind=1
    AND ((n.beg_effective_dt_tm=null) OR (n.beg_effective_dt_tm != null
    AND n.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ((n.end_effective_dt_tm=null) OR (n.end_effective_dt_tm != null
    AND n.end_effective_dt_tm >= cnvtdatetime(sysdate))) )) )
  DETAIL
   alpha_cnt += 1
   IF (mod(alpha_cnt,5)=1)
    stat = alterlist(reply->alpha_responses,(alpha_cnt+ 4))
   ENDIF
   reply->alpha_responses[alpha_cnt].concept_identifier = n.concept_identifier, reply->
   alpha_responses[alpha_cnt].default_ind = ar.default_ind, reply->alpha_responses[alpha_cnt].
   description = ar.description,
   reply->alpha_responses[alpha_cnt].mnemonic = n.mnemonic, reply->alpha_responses[alpha_cnt].
   multi_alpha_sort_order = ar.multi_alpha_sort_order, reply->alpha_responses[alpha_cnt].
   nomenclature_id = n.nomenclature_id,
   reply->alpha_responses[alpha_cnt].result_value = ar.result_value, reply->alpha_responses[alpha_cnt
   ].sequence = ar.sequence, reply->alpha_responses[alpha_cnt].short_string = n.short_string,
   reply->alpha_responses[alpha_cnt].source_string = n.source_string
  FOOT REPORT
   stat = alterlist(reply->alpha_responses,alpha_cnt)
  WITH nocounter
 ;end select
 CALL echo(build("alpha_cnt:",alpha_cnt))
 IF (((ref_cnt=0) OR (alpha_cnt=0)) )
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
