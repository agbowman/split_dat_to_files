CREATE PROGRAM dcp_get_dta_list_info:dba
 RECORD tempreco(
   1 dta_qual[*]
     2 task_assay_cd = f8
 )
 RECORD reply(
   1 dta_qual[*]
     2 activity_type_cd = f8
     2 task_assay_cd = f8
     2 mnemonic = vc
     2 description = vc
     2 offset_min_nbr = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE valcnt = i4 WITH protect, noconstant(size(request->dta_list,5))
 DECLARE failure_ind = i2 WITH protect, noconstant(0)
 DECLARE zero_ind = i2 WITH protect, noconstant(0)
 IF (valcnt=0)
  SET failure_ind = 1
  GO TO failure
 ENDIF
 DECLARE ack_result_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002164,
   "ACKRESULTMIN"))
 DECLARE maxexpcnt = i4 WITH protect, constant(20)
 DECLARE expblocksize = i4 WITH protect, constant(ceil(((valcnt * 1.0)/ maxexpcnt)))
 DECLARE ex_start = i4 WITH protect, noconstant(1)
 DECLARE ex_idx = i4 WITH protect, noconstant(1)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE expmaxsize = i4 WITH protect, noconstant((expblocksize * maxexpcnt))
 SET stat = alterlist(tempreco->dta_qual,expmaxsize)
 FOR (i = 1 TO valcnt)
   SET tempreco->dta_qual[i].task_assay_cd = request->dta_list[i].task_assay_cd
 ENDFOR
 FOR (i = (valcnt+ 1) TO expmaxsize)
   SET tempreco->dta_qual[i].task_assay_cd = request->dta_list[valcnt].task_assay_cd
 ENDFOR
 DECLARE idx = i4 WITH protect, noconstant(0)
 SET stat = alterlist(reply->dta_qual,expmaxsize)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(expblocksize)),
   discrete_task_assay dta,
   dta_offset_min dom
  PLAN (d1
   WHERE assign(ex_start,evaluate(d1.seq,1,1,(ex_start+ maxexpcnt))))
   JOIN (dta
   WHERE expand(ex_idx,ex_start,((ex_start+ maxexpcnt) - 1),dta.task_assay_cd,tempreco->dta_qual[
    ex_idx].task_assay_cd)
    AND dta.active_ind=1)
   JOIN (dom
   WHERE dom.task_assay_cd=outerjoin(dta.task_assay_cd)
    AND dom.active_ind=outerjoin(1)
    AND dom.offset_min_type_cd=outerjoin(ack_result_type_cd)
    AND dom.end_effective_dt_tm >= outerjoin(cnvtdatetime("31-DEC-2100")))
  DETAIL
   idx = (idx+ 1),
   CALL echo(build("idx:  ",idx)), reply->dta_qual[idx].task_assay_cd = dta.task_assay_cd,
   reply->dta_qual[idx].mnemonic = dta.mnemonic, reply->dta_qual[idx].description = dta.description,
   reply->dta_qual[idx].activity_type_cd = dta.activity_type_cd,
   reply->dta_qual[idx].offset_min_nbr = dom.offset_min_nbr
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->dta_qual,idx)
 IF (idx=0)
  SET zero_ind = 1
 ELSE
  SET failure_ind = 0
 ENDIF
#failure
 IF (failure_ind=1)
  SET reply->status_data.status = "F"
 ELSEIF (zero_ind=1)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE SET tempreco
END GO
