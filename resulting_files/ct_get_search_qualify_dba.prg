CREATE PROGRAM ct_get_search_qualify:dba
 RECORD reply(
   1 qual[*]
     2 amend_nbr = i4
     2 prot_id = f8
     2 description = vc
     2 amend_dt_tm = dq8
     2 gw_targ_acc = i4
     2 targ_acc = i4
     2 prot_title = vc
     2 prot_dur = i4
     2 prot_dur_umo_dis = vc
     2 accr_req_indc_dis = vc
     2 cdus_class_dis = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((request->start_num <= 1))
  FREE SET context
  RECORD context(
    1 qual[*]
      2 amend_nbr = i4
      2 prot_id = f8
      2 description = vc
      2 amend_dt_tm = dq8
      2 gw_targ_acc = i4
      2 targ_acc = i4
      2 prot_title = vc
      2 prot_dur = i4
      2 prot_dur_umo_dis = vc
      2 accr_req_indc_dis = vc
      2 cdus_class_dis = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ELSE
  GO TO 7000_fill_reply
 ENDIF
 SET reply->status_data.status = "F"
 SET cnt = 0
#5000_execute_select
 SET sselect = concat("Select distinct into ",char(34),"nl:",char(34))
 SET sitem1 = "am.prot_master_id, am.amendment_nbr, am.groupwide_targeted_accrual,"
 SET sitem2 = "am.amendment_dt_tm, am.amendment_description, am.targeted_accrual,"
 SET sitem3 = "am.prot_title, am.anticipated_prot_dur_value, am.CDUS_class_cd,"
 SET sitem4 = "am.accrual_required_indc_cd, am.anticipated_prot_dur_uom_cd"
 SET sfromtable = "From"
 SET sdetail1 = "detail"
 SET sdetail2 = "cnt = cnt +1"
 SET sdetail3 = "bstat = alterlist(context->qual,cnt)"
 SET sdetail4 = "context->qual[cnt]->amend_nbr = am.amendment_nbr"
 SET sdetail5 = "context->qual[cnt]->prot_id = am.prot_master_id"
 SET sdetail6 = "context->qual[cnt]->description = am.amendment_description"
 SET sdetail7 = "context->qual[cnt]->amend_dt_tm = am.amendment_dt_tm"
 SET sdetail8 = "context->qual[cnt]->gw_targ_acc=am.groupwide_targeted_accrual"
 SET sdetail9 = "context->qual[cnt]->targ_acc = am.targeted_accrual"
 SET sdetail10 = "context->qual[cnt]->prot_title = am.prot_title"
 SET sdetail11 = "context->qual[cnt]->prot_dur = am.anticipated_prot_dur_value"
 SET sdetail12 = "context->qual[cnt]->prot_dur_umo_dis = "
 SET sdetail13 = "uar_get_code_display(am.anticipated_prot_dur_uom_cd)"
 SET sdetail14 = "context->qual[cnt]->accr_req_indc_dis = "
 SET sdetail15 = "uar_get_code_display(am.accrual_required_indc_cd)"
 SET sdetail16 = "context->qual[cnt]->cdus_class_dis = "
 SET sdetail17 = "uar_get_code_display(am.CDUS_class_cd)"
 SET sdetail18 = "with nocounter go"
 SET wcount = size(request->qual_where,5)
 SET tcount = size(request->qual_table,5)
 IF (wcount > 0
  AND tcount > 0)
  CALL parser(sselect)
  CALL parser(sitem1)
  CALL parser(sitem2)
  CALL parser(sitem3)
  CALL parser(sitem4)
  CALL parser(sfromtable)
  FOR (i = 1 TO tcount)
    CALL parser(request->qual_table[i].q_str)
  ENDFOR
  FOR (i = 1 TO wcount)
    CALL parser(request->qual_where[i].q_str)
  ENDFOR
  CALL parser(sdetail1)
  CALL parser(sdetail2)
  CALL parser(sdetail3)
  CALL parser(sdetail4)
  CALL parser(sdetail5)
  CALL parser(sdetail6)
  CALL parser(sdetail7)
  CALL parser(sdetail8)
  CALL parser(sdetail9)
  CALL parser(sdetail10)
  CALL parser(sdetail11)
  CALL parser(sdetail12)
  CALL parser(sdetail13)
  CALL parser(sdetail14)
  CALL parser(sdetail15)
  CALL parser(sdetail16)
  CALL parser(sdetail17)
  CALL parser(sdetail18)
 ENDIF
#7000_fill_reply
 SET ccount = size(context->qual,5)
 SET cnt = 0
 IF ((request->start_num <= 0))
  SET request->start_num = 1
 ENDIF
 FOR (i = request->start_num TO ccount)
   SET cnt = (cnt+ 1)
   SET bstat = alterlist(reply->qual,cnt)
   SET reply->qual[cnt].amend_nbr = context->qual[i].amend_nbr
   SET reply->qual[cnt].prot_id = context->qual[i].prot_id
   SET reply->qual[cnt].description = context->qual[i].description
   SET reply->qual[cnt].amend_dt_tm = context->qual[i].amend_dt_tm
   SET reply->qual[cnt].gw_targ_acc = context->qual[i].gw_targ_acc
   SET reply->qual[cnt].targ_acc = context->qual[i].targ_acc
   SET reply->qual[cnt].prot_title = context->qual[i].prot_title
   SET reply->qual[cnt].prot_dur = context->qual[i].prot_dur
   SET reply->qual[cnt].prot_dur_umo_dis = context->qual[i].prot_dur_umo_dis
   SET reply->qual[cnt].accr_req_indc_dis = context->qual[i].accr_req_indc_dis
   SET reply->qual[cnt].cdus_class_dis = context->qual[i].cdus_class_dis
   CALL echo(reply->qual[cnt].prot_id)
   IF ((cnt=request->retrn_num))
    SET i = ccount
   ENDIF
 ENDFOR
 IF ((i > request->start_num))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echo(ccount)
#9999_exit
END GO
