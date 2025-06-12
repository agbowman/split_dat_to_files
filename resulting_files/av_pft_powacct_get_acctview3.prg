CREATE PROGRAM av_pft_powacct_get_acctview3
 SET pft_powacct_getacctview3 = "67416.FT.020"
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 RECORD reply(
   1 dacct_id = f8
   1 ainvoice[*]
     2 dcorsp_activity_id = f8
     2 ibill_vrsn_nbr = i4
     2 sbill_nbr_disp = c40
     2 sbill_type_cdf = c40
     2 dbalance = f8
     2 sbill_status_cd = c50
     2 sbill_status_reason_cd = c50
     2 dtsubmit_dt_tm = dq8
     2 dtgen_dt_tm = dq8
     2 ifinchg_ind = i2
     2 ipayadj_ind = i2
     2 iadj_ind = i2
     2 ipay_ind = i2
     2 icomment_ind = i2
     2 icorsp_ind = i2
     2 iimage_flag = i2
     2 smedia_type_disp = c50
     2 smedia_sub_type_disp = c50
     2 sgen_reason_disp = c50
     2 ipage_cnt = i2
     2 spayor_ctrl_nbr_txt = c40
     2 dcurrentbalance = f8
   1 aencntr[*]
     2 dencntr_id = f8
     2 iconv_ind = i2
     2 sconv_disp = vc
     2 spatient_name = c255
     2 dpatientid = f8
     2 sencntr_nbr = c255
     2 sencntr_type = c255
     2 dtencntr_date = dq8
     2 dtdsch_date = dq8
     2 sencntr_loc = c255
     2 svip_disp = c40
     2 dvip_cd = f8
     2 sphone = c255
     2 saddr1 = c255
     2 saddr2 = c255
     2 scity = c255
     2 sstate = c255
     2 szip = c255
     2 icomment_ind = i2
     2 icorsp_ind = i2
     2 sssn = c20
     2 apftencntr[*]
       3 dpftencntr_id = f8
       3 dtbeg_dt_tm = dq8
       3 dtdisch_dt_tm = dq8
       3 iinterim_ind = i2
       3 spft_encntr_status_cd = c50
       3 dchg_balance = f8
       3 nchg_dr_cr_flag = i2
       3 dadj_balance = f8
       3 nadj_dr_cr_flag = i2
       3 dapppay_balance = f8
       3 dunapay_balance = f8
       3 ifinchg_ind = i2
       3 ipayadj_ind = i2
       3 iadj_ind = i2
       3 ipay_ind = i2
       3 icomment_ind = i2
       3 icorsp_ind = i2
       3 dtlastpaymentdate = dq8
       3 dtlastchargedate = dq8
       3 ipaymentplan_flag = i2
       3 ibankruptcy_flag = i2
       3 ddunning_level_cd = f8
       3 sdunning_level_disp = c40
       3 sdunning_level_cdf = c40
       3 dpaymentplan_status_cd = f8
       3 spaymentplan_status_disp = c50
       3 spaymentplan_status_cdf = c40
       3 dbalance = f8
       3 nbalance_dr_cr_flag = i2
       3 dbad_debt_balance = f8
       3 dbenefit_order_id = f8
       3 drelated_corsp_act_id = f8
       3 iconv_ind = i2
       3 sconv_disp = vc
       3 acorsp_act_qual[*]
         4 drelated_corsp_act_id = f8
       3 aholds[*]
         4 dhold_id = f8
         4 shold_desc = c100
         4 dthold_dt_tm = dq8
         4 dhold_cd = f8
         4 sreason_comment = c40
         4 iclaim_suppress_ind = i2
         4 istmt_suppress_ind = i2
         4 ibill_hold_rpts_suppress_ind = i2
       3 acharge[*]
         4 dcharge_item_id = f8
         4 dcharge_event_id = f8
         4 dcharge_event_act_id = f8
   1 icontext_ind = i2
   1 icontext_cur_cnt = i2
   1 icontext_tot_cnt = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET tmp_inv
 RECORD tmp_inv(
   1 atmp[*]
     2 dcorps_activity_id = f8
 )
 IF ((validate(context->context_ind,- (1))=- (1)))
  IF ("Z"=validate(pft_context_vrsn,"Z"))
   DECLARE pft_context_vrsn = vc WITH noconstant("000"), public
   SET pft_context_vrsn = "000"
   IF (validate(initcontext,char(128))=char(128))
    DECLARE initcontext(maxrec=i4,totrec=i4,currec=i4) = null
    SUBROUTINE initcontext(maxrec,totrec)
      IF ((- (1)=validate(context->context_ind,- (1))))
       SET trace = recpersist
       RECORD context(
         1 context_ind = i2
         1 maxqual = i4
         1 context_tot_cnt = i4
         1 context_last_rec = i4
         1 qual[*]
           2 context_id = f8
           2 context_cd = f8
           2 context_dt_tm = dq8
       )
       SET trace = norecpersist
       SET context->context_ind = 1
       SET context->maxqual = maxrec
       SET context->context_tot_cnt = totrec
       SET context->context_last_rec = 0
       SET stat = alterlist(context->qual,1)
       SET context->qual[1].context_cd = 0
       SET context->qual[1].context_id = 0
       SET context->qual[1].context_dt_tm = null
      ENDIF
    END ;Subroutine
   ENDIF
   IF (validate(contextlastrec,char(128))=char(128))
    DECLARE contextlastrec(dummyvar=i4) = i4
    SUBROUTINE contextlastrec(dummyvar)
      IF ((- (1)=validate(context->context_last_rec,- (1))))
       RETURN(0)
      ELSE
       RETURN(context->context_last_rec)
      ENDIF
    END ;Subroutine
   ENDIF
   IF (validate(contexttotalrecs,char(128))=char(128))
    DECLARE contexttotalrecs(dummyvar=i4) = i4
    SUBROUTINE contexttotalrecs(dummyvar)
      IF ((- (1)=validate(context->context_tot_cnt,- (1))))
       RETURN(0)
      ELSE
       RETURN(context->context_tot_cnt)
      ENDIF
    END ;Subroutine
   ENDIF
   IF (validate(contextmaxqual,char(128))=char(128))
    DECLARE contextmaxqual(dummyvar=i4) = i4
    SUBROUTINE contextmaxqual(dummyvar)
      IF ((- (1)=validate(context->maxqual,- (1))))
       RETURN(0)
      ELSE
       RETURN(context->maxqual)
      ENDIF
    END ;Subroutine
   ENDIF
   IF (validate(incrementcontext,char(128))=char(128))
    DECLARE incrementcontext(num_of_recs=i4) = null
    SUBROUTINE incrementcontext(num_of_recs)
      IF (1=validate(context->context_ind,- (1)))
       SET context->context_last_rec = lastrec
      ENDIF
    END ;Subroutine
   ENDIF
  ENDIF
  CALL initcontext(10,0)
 ENDIF
 IF (size(trim(request->sbegdttm)) <= 0)
  SET request->sbegdttm = "18000101"
 ENDIF
 IF (size(trim(request->senddttm)) <= 0)
  SET request->senddttm = "21001231"
 ENDIF
 SET reply->status_data.status = "F"
 SET iencntr_qual = 0
 SET cdf_meaning = fillstring(12," ")
 DECLARE pm_inp_admit_dt_tm() = c20
 DECLARE dfinnbr_value = f8 WITH noconstant(0.0)
 DECLARE ddefgaur_value = f8 WITH noconstant(0.0)
 DECLARE dperrel_value = f8 WITH noconstant(0.0)
 DECLARE dperplan_value = f8 WITH noconstant(0.0)
 DECLARE dcomment_value = f8 WITH noconstant(0.0)
 DECLARE dadj_value = f8 WITH noconstant(0.0)
 DECLARE dpay_value = f8 WITH noconstant(0.0)
 DECLARE dinvoice_cd = f8 WITH noconstant(0.0)
 DECLARE daddr_value = f8 WITH noconstant(0.0)
 DECLARE dphone_value = f8 WITH noconstant(0.0)
 DECLARE dssn_value = f8 WITH noconstant(0.0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE nstart = i4 WITH noconstant(0)
 DECLARE nend = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE z = i4 WITH noconstant(0)
 DECLARE nsize = i4 WITH noconstant(200)
 DECLARE ntotal = i4 WITH noconstant(0)
 DECLARE ntotal2 = i4 WITH noconstant(0)
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,dfinnbr_value)
 SET stat = uar_get_meaning_by_codeset(351,"DEFGUAR",1,ddefgaur_value)
 SET stat = uar_get_meaning_by_codeset(351,"GUARANTOR",1,dperrel_value)
 SET stat = uar_get_meaning_by_codeset(353,"SUBSCRIBER",1,dperplan_value)
 SET stat = uar_get_meaning_by_codeset(18669,"COMMENT",1,dcomment_value)
 SET stat = uar_get_meaning_by_codeset(18649,"ADJUST",1,dadj_value)
 SET stat = uar_get_meaning_by_codeset(18649,"PAYMENT",1,dpay_value)
 SET stat = uar_get_meaning_by_codeset(21849,"STATEMENTINV",1,dinvoice_cd)
 SET stat = uar_get_meaning_by_codeset(212,"HOME",1,daddr_value)
 SET stat = uar_get_meaning_by_codeset(43,"HOME",1,dphone_value)
 SET stat = uar_get_meaning_by_codeset(4,"SSN",1,dssn_value)
 SET reply->dacct_id = request->did
 IF ((request->did > 0))
  SELECT INTO "nl:"
   br.corsp_activity_id
   FROM bill_reltn bbr,
    bill_rec br
   PLAN (bbr
    WHERE (bbr.parent_entity_id=request->did)
     AND bbr.parent_entity_name="ACCOUNT"
     AND bbr.active_ind=1)
    JOIN (br
    WHERE br.corsp_activity_id=bbr.corsp_activity_id
     AND br.bill_vrsn_nbr=bbr.bill_vrsn_nbr
     AND br.bill_class_cd=dinvoice_cd
     AND br.gen_dt_tm >= cnvtdatetime(cnvtdate2(request->sbegdttm,"YYYYMMDD"),000000)
     AND br.gen_dt_tm <= cnvtdatetime(cnvtdate2(request->senddttm,"YYYYMMDD"),235959)
     AND br.active_ind=1)
   ORDER BY br.corsp_activity_id DESC
   DETAIL
    z = (z+ 1)
    IF (mod(z,50)=1)
     stat = alterlist(tmp_inv->atmp,(z+ 49))
    ENDIF
    tmp_inv->atmp[z].dcorps_activity_id = br.corsp_activity_id
   WITH nocounter
  ;end select
  SET stat = alterlist(tmp_inv->atmp,z)
  SET reply->icontext_tot_cnt = z
  SET context->context_tot_cnt = z
  SET nstart = (context->context_last_rec+ 1)
  SET nend = (context->context_last_rec+ context->maxqual)
  IF ((nend > context->context_tot_cnt))
   SET nend = context->context_tot_cnt
  ENDIF
  SET context->context_ind = 1
  SET reply->icontext_ind = 1
  SET z = 0
  SELECT INTO "nl:"
   FROM bill_rec br
   PLAN (br
    WHERE expand(idx,nstart,nend,br.corsp_activity_id,tmp_inv->atmp[idx].dcorps_activity_id)
     AND br.active_ind=1)
   ORDER BY br.corsp_activity_id DESC
   HEAD br.corsp_activity_id
    z = (z+ 1)
    IF (mod(z,50)=1)
     stat = alterlist(reply->ainvoice,(z+ 49))
    ENDIF
    reply->ainvoice[z].dcorsp_activity_id = br.corsp_activity_id, reply->ainvoice[z].ibill_vrsn_nbr
     = br.bill_vrsn_nbr, reply->ainvoice[z].sbill_nbr_disp = br.bill_nbr_disp,
    reply->ainvoice[z].iimage_flag = br.image_flag, reply->ainvoice[z].sbill_type_cdf =
    uar_get_code_meaning(br.bill_type_cd)
    IF (br.balance_due_dr_cr_flag=2)
     reply->ainvoice[z].dcurrentbalance = (- (1) * br.balance_due)
    ELSE
     reply->ainvoice[z].dcurrentbalance = br.balance_due
    ENDIF
    IF (br.balance_dr_cr_flag=2)
     reply->ainvoice[z].dbalance = (- (1) * br.balance)
    ELSE
     reply->ainvoice[z].dbalance = br.balance
    ENDIF
    reply->ainvoice[z].sbill_status_cd = uar_get_code_display(br.bill_status_cd), reply->ainvoice[z].
    sbill_status_reason_cd = uar_get_code_display(br.bill_status_reason_cd), reply->ainvoice[z].
    dtgen_dt_tm = br.gen_dt_tm,
    reply->ainvoice[z].smedia_type_disp = uar_get_code_display(br.media_type_cd), reply->ainvoice[z].
    smedia_sub_type_disp = uar_get_code_display(br.media_sub_type_cd), reply->ainvoice[z].
    sgen_reason_disp = uar_get_code_display(br.gen_reason_cd),
    reply->ainvoice[z].ipage_cnt = br.page_cnt, reply->ainvoice[z].spayor_ctrl_nbr_txt = br
    .payor_ctrl_nbr_txt
   FOOT REPORT
    stat = alterlist(reply->ainvoice,z)
   WITH nocounter
  ;end select
  SET context->context_last_rec = (context->context_last_rec+ z)
  SET reply->icontext_cur_cnt = context->context_last_rec
  SELECT INTO "nl:"
   FROM corsp_log_reltn clr,
    corsp_log cl
   PLAN (clr
    WHERE expand(idx,1,size(reply->ainvoice,5),clr.parent_entity_id,reply->ainvoice[idx].
     dcorsp_activity_id)
     AND clr.parent_entity_name="BILL_RECORD"
     AND clr.active_ind=1)
    JOIN (cl
    WHERE cl.activity_id=clr.activity_id
     AND cl.active_ind=1)
   DETAIL
    index = locateval(num,1,size(reply->ainvoice,5),clr.parent_entity_id,reply->ainvoice[num].
     dcorsp_activity_id)
    IF (cl.activity_id=clr.activity_id)
     IF (cl.corsp_type_cd=dcomment_value)
      reply->ainvoice[index].icomment_ind = 1
     ELSE
      reply->ainvoice[index].icorsp_ind = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   admit_dt_tm = cnvtdatetimeutc(pm_inp_admit_dt_tm(e.encntr_id,1,sysdate))
   FROM pft_encntr pe,
    encounter e,
    encntr_alias ea,
    person p1,
    person_alias pa,
    corsp_log_reltn cer,
    corsp_log cl,
    pe_status_reason psr,
    corsp_log_reltn clr,
    corsp_log cl2
   PLAN (pe
    WHERE (pe.acct_id=request->did)
     AND pe.active_ind=1
     AND pe.last_stmt_dt_tm=null)
    JOIN (e
    WHERE pe.encntr_id=e.encntr_id)
    JOIN (p1
    WHERE p1.person_id=e.person_id)
    JOIN (pa
    WHERE pa.person_id=outerjoin(p1.person_id)
     AND pa.active_ind=outerjoin(1)
     AND pa.person_alias_type_cd=outerjoin(dssn_value))
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(e.encntr_id)
     AND ea.encntr_alias_type_cd=outerjoin(dfinnbr_value)
     AND ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
    JOIN (cer
    WHERE cer.parent_entity_id=outerjoin(e.encntr_id)
     AND cer.parent_entity_name=outerjoin("ENCOUNTER"))
    JOIN (cl
    WHERE cl.activity_id=outerjoin(cer.activity_id)
     AND cl.active_ind=outerjoin(1))
    JOIN (clr
    WHERE clr.parent_entity_id=outerjoin(pe.pft_encntr_id)
     AND clr.parent_entity_name=outerjoin("ENCOUNTER")
     AND clr.active_ind=outerjoin(1))
    JOIN (cl2
    WHERE cl2.activity_id=outerjoin(clr.activity_id)
     AND cl2.active_ind=outerjoin(1))
    JOIN (psr
    WHERE psr.pft_encntr_id=outerjoin(pe.pft_encntr_id)
     AND psr.active_ind=outerjoin(1))
   ORDER BY e.encntr_id, pe.pft_encntr_id, psr.pe_status_reason_id
   HEAD e.encntr_id
    x = (x+ 1)
    IF (mod(x,10)=1)
     stat = alterlist(reply->aencntr,(x+ 9))
    ENDIF
    reply->aencntr[x].dencntr_id = e.encntr_id, reply->aencntr[x].sencntr_nbr = ea.alias, reply->
    aencntr[x].sencntr_type = uar_get_code_display(e.encntr_type_cd),
    reply->aencntr[x].dtencntr_date = admit_dt_tm, reply->aencntr[x].dtdsch_date = e.disch_dt_tm,
    reply->aencntr[x].sencntr_loc = uar_get_code_display(e.loc_facility_cd),
    reply->aencntr[x].dvip_cd = e.vip_cd, reply->aencntr[x].svip_disp = uar_get_code_display(e.vip_cd
     ), reply->aencntr[x].spatient_name = p1.name_full_formatted,
    reply->aencntr[x].dpatientid = p1.person_id
    IF (pa.person_alias_type_cd=dssn_value)
     reply->aencntr[x].sssn = pa.alias
    ENDIF
    IF (cer.parent_entity_id=e.encntr_id
     AND cl.activity_id=cer.activity_id)
     IF (cl.corsp_type_cd=dcomment_value)
      reply->aencntr[x].icomment_ind = 1
     ELSE
      reply->aencntr[x].icorsp_ind = 1
     ENDIF
    ENDIF
    y = 0
   HEAD pe.pft_encntr_id
    z = 0
    IF (pe.pft_encntr_id > 0)
     y = (y+ 1), stat = alterlist(reply->aencntr[x].apftencntr,y), reply->aencntr[x].apftencntr[y].
     dpftencntr_id = pe.pft_encntr_id,
     reply->aencntr[x].apftencntr[y].dtbeg_dt_tm = reply->aencntr[x].dtencntr_date, reply->aencntr[x]
     .apftencntr[y].dtdisch_dt_tm = pe.disch_dt_tm, reply->aencntr[x].apftencntr[y].iinterim_ind = pe
     .interim_ind,
     reply->aencntr[x].apftencntr[y].spft_encntr_status_cd = uar_get_code_display(pe
      .pft_encntr_status_cd), reply->aencntr[x].apftencntr[y].dchg_balance = pe.charge_balance, reply
     ->aencntr[x].apftencntr[y].nchg_dr_cr_flag = pe.chrg_bal_dr_cr_flag,
     reply->aencntr[x].apftencntr[y].dadj_balance = pe.adjustment_balance, reply->aencntr[x].
     apftencntr[y].nadj_dr_cr_flag = pe.adj_bal_dr_cr_flag, reply->aencntr[x].apftencntr[y].
     dapppay_balance = pe.applied_payment_balance,
     reply->aencntr[x].apftencntr[y].dunapay_balance = pe.unapplied_payment_balance, reply->aencntr[x
     ].apftencntr[y].dtlastpaymentdate = pe.last_payment_dt_tm, reply->aencntr[x].apftencntr[y].
     dtlastchargedate = pe.last_charge_dt_tm
     IF (pe.payment_plan_flag=4)
      reply->aencntr[x].apftencntr[y].ibankruptcy_flag = 1, reply->aencntr[x].apftencntr[y].
      ipaymentplan_flag = 0
     ELSE
      reply->aencntr[x].apftencntr[y].ibankruptcy_flag = 0, reply->aencntr[x].apftencntr[y].
      ipaymentplan_flag = pe.payment_plan_flag
     ENDIF
     reply->aencntr[x].apftencntr[y].dpaymentplan_status_cd = pe.payment_plan_status_cd, reply->
     aencntr[x].apftencntr[y].spaymentplan_status_disp = uar_get_code_display(pe
      .payment_plan_status_cd), reply->aencntr[x].apftencntr[y].spaymentplan_status_cdf =
     uar_get_code_meaning(pe.payment_plan_status_cd),
     reply->aencntr[x].apftencntr[y].ddunning_level_cd = pe.dunning_level_cd, reply->aencntr[x].
     apftencntr[y].sdunning_level_disp = uar_get_code_display(pe.dunning_level_cd), reply->aencntr[x]
     .apftencntr[y].sdunning_level_cdf = uar_get_code_meaning(pe.dunning_level_cd),
     reply->aencntr[x].apftencntr[y].dbalance = pe.balance, reply->aencntr[x].apftencntr[y].
     nbalance_dr_cr_flag = pe.dr_cr_flag, reply->aencntr[x].apftencntr[y].dbad_debt_balance = pe
     .bad_debt_balance,
     reply->aencntr[x].apftencntr[y].iconv_ind = pe.conversion_ind, reply->aencntr[x].apftencntr[y].
     sconv_disp =
     IF (pe.conversion_ind=1) "Converted Encounter"
     ELSE ""
     ENDIF
     IF (clr.parent_entity_id=pe.pft_encntr_id
      AND cl2.activity_id=clr.activity_id)
      IF (cl2.corsp_type_cd=dcomment_value)
       reply->aencntr[x].apftencntr[y].icomment_ind = 1
      ELSE
       reply->aencntr[x].apftencntr[y].icorsp_ind = 1
      ENDIF
     ENDIF
    ENDIF
   HEAD psr.pe_status_reason_id
    IF (psr.pft_encntr_id=pe.pft_encntr_id
     AND psr.pft_encntr_id > 0)
     z = (z+ 1), stat = alterlist(reply->aencntr[x].apftencntr[y].aholds,z), reply->aencntr[x].
     apftencntr[y].aholds[z].dhold_id = psr.pe_status_reason_id,
     reply->aencntr[x].apftencntr[y].aholds[z].shold_desc = uar_get_code_display(psr
      .pe_status_reason_cd), reply->aencntr[x].apftencntr[y].aholds[z].dthold_dt_tm = psr
     .pe_hold_dt_tm, reply->aencntr[x].apftencntr[y].aholds[z].dhold_cd = psr.pe_status_reason_cd,
     reply->aencntr[x].apftencntr[y].aholds[z].sreason_comment = psr.reason_comment, reply->aencntr[x
     ].apftencntr[y].aholds[z].iclaim_suppress_ind = psr.claim_suppress_ind, reply->aencntr[x].
     apftencntr[y].aholds[z].istmt_suppress_ind = psr.stmt_suppress_ind,
     reply->aencntr[x].apftencntr[y].aholds[z].ibill_hold_rpts_suppress_ind = psr
     .bill_hold_rpts_suppress_ind
    ENDIF
   DETAIL
    null
   FOOT  pe.pft_encntr_id
    row + 0
   FOOT REPORT
    stat = alterlist(reply->aencntr,x)
   WITH nocounter
  ;end select
 ELSEIF ((request->dcorsp_activity_id > 0))
  SELECT INTO "NL:"
   admit_dt_tm = cnvtdatetimeutc(pm_inp_admit_dt_tm(e.encntr_id,1,sysdate))
   FROM pft_encntr pe,
    encounter e,
    encntr_alias ea,
    person p1,
    bill_reltn br,
    person_alias pa,
    corsp_log_reltn cer,
    corsp_log cl
   PLAN (br
    WHERE (br.corsp_activity_id=request->dcorsp_activity_id)
     AND br.parent_entity_name="PFTENCNTR"
     AND br.active_ind=1)
    JOIN (pe
    WHERE pe.pft_encntr_id=br.parent_entity_id
     AND pe.active_ind=1)
    JOIN (e
    WHERE pe.encntr_id=e.encntr_id)
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(e.encntr_id)
     AND ea.encntr_alias_type_cd=outerjoin(dfinnbr_value)
     AND ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
    JOIN (p1
    WHERE p1.person_id=outerjoin(e.person_id))
    JOIN (pa
    WHERE pa.person_id=outerjoin(p1.person_id)
     AND pa.active_ind=outerjoin(1)
     AND pa.person_alias_type_cd=outerjoin(dssn_value))
    JOIN (cer
    WHERE cer.parent_entity_id=outerjoin(e.encntr_id)
     AND cer.parent_entity_name=outerjoin("ENCOUNTER"))
    JOIN (cl
    WHERE cl.activity_id=outerjoin(cer.activity_id)
     AND cl.active_ind=outerjoin(1))
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    x = (x+ 1), iencntr_qual = (iencntr_qual+ 1)
    IF (mod(x,10)=1)
     stat = alterlist(reply->aencntr,(x+ 9))
    ENDIF
    reply->aencntr[x].dencntr_id = e.encntr_id, reply->aencntr[x].sencntr_nbr = ea.alias, reply->
    aencntr[x].sencntr_type = uar_get_code_display(e.encntr_type_cd),
    reply->aencntr[x].dtencntr_date = admit_dt_tm, reply->aencntr[x].dtdsch_date = e.disch_dt_tm,
    reply->aencntr[x].sencntr_loc = uar_get_code_display(e.loc_facility_cd),
    reply->aencntr[x].dvip_cd = e.vip_cd, reply->aencntr[x].svip_disp = uar_get_code_display(e.vip_cd
     )
   DETAIL
    reply->aencntr[x].spatient_name = p1.name_full_formatted, reply->aencntr[x].dpatientid = p1
    .person_id, request->did = pe.acct_id
    IF (pa.person_alias_type_cd=dssn_value)
     reply->aencntr[x].sssn = pa.alias
    ENDIF
    IF (cl.activity_id=cer.activity_id
     AND cer.parent_entity_id=e.encntr_id)
     IF (cl.corsp_type_cd=dcomment_value)
      reply->aencntr[x].icomment_ind = 1
     ELSE
      reply->aencntr[x].icorsp_ind = 1
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->aencntr,x)
   WITH nocounter
  ;end select
  IF (iencntr_qual > 0)
   SET y = 0
   FREE RECORD temp
   RECORD temp(
     1 l[*]
       2 dpftencntrid = f8
       2 e_ind = i4
       2 pfte_ind = i4
   )
   SET nstart = 1
   SET ntotal2 = size(reply->aencntr,5)
   SET ntotal = (ntotal2+ (nsize - mod(ntotal2,nsize)))
   SET stat = alterlist(reply->aencntr,ntotal)
   FOR (idx = (ntotal2+ 1) TO ntotal)
     SET reply->aencntr[idx].dencntr_id = reply->aencntr[ntotal2].dencntr_id
   ENDFOR
   SELECT INTO "nl:"
    FROM pft_encntr pe,
     bill_reltn br,
     (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize))))
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (br
     WHERE (br.corsp_activity_id=request->dcorsp_activity_id))
     JOIN (pe
     WHERE expand(num,nstart,((nstart+ nsize) - 1),pe.encntr_id,reply->aencntr[num].dencntr_id)
      AND pe.pft_encntr_id=br.parent_entity_id
      AND br.parent_entity_name="PFTENCNTR")
    ORDER BY pe.encntr_id, pe.pft_encntr_id
    HEAD REPORT
     cnt = 0
    HEAD pe.encntr_id
     index = locateval(num,nstart,((nstart+ nsize) - 1),pe.encntr_id,reply->aencntr[num].dencntr_id),
     y = 0
    HEAD pe.pft_encntr_id
     IF (pe.pft_encntr_id > 0)
      y = (y+ 1), cnt = (cnt+ 1)
      IF (mod(cnt,50)=1)
       stat = alterlist(temp->l,(cnt+ 49))
      ENDIF
      temp->l[cnt].dpftencntrid = pe.pft_encntr_id, temp->l[cnt].e_ind = index, temp->l[cnt].pfte_ind
       = y,
      stat = alterlist(reply->aencntr[index].apftencntr,y), reply->aencntr[index].apftencntr[y].
      dpftencntr_id = pe.pft_encntr_id, reply->aencntr[index].apftencntr[y].dtbeg_dt_tm = reply->
      aencntr[index].dtencntr_date,
      reply->aencntr[index].apftencntr[y].dtdisch_dt_tm = pe.disch_dt_tm, reply->aencntr[index].
      apftencntr[y].iinterim_ind = pe.interim_ind, reply->aencntr[index].apftencntr[y].
      spft_encntr_status_cd = uar_get_code_display(pe.pft_encntr_status_cd),
      reply->aencntr[index].apftencntr[y].dchg_balance = pe.charge_balance, reply->aencntr[index].
      apftencntr[y].nchg_dr_cr_flag = pe.chrg_bal_dr_cr_flag, reply->aencntr[index].apftencntr[y].
      dadj_balance = pe.adjustment_balance,
      reply->aencntr[index].apftencntr[y].nadj_dr_cr_flag = pe.adj_bal_dr_cr_flag, reply->aencntr[
      index].apftencntr[y].dapppay_balance = pe.applied_payment_balance, reply->aencntr[index].
      apftencntr[y].dunapay_balance = pe.unapplied_payment_balance,
      reply->aencntr[index].apftencntr[y].dtlastpaymentdate = pe.last_payment_dt_tm, reply->aencntr[
      index].apftencntr[y].dtlastchargedate = pe.last_charge_dt_tm
      IF (pe.payment_plan_flag=4)
       reply->aencntr[index].apftencntr[y].ibankruptcy_flag = 1, reply->aencntr[index].apftencntr[y].
       ipaymentplan_flag = 0
      ELSE
       reply->aencntr[index].apftencntr[y].ibankruptcy_flag = 0, reply->aencntr[index].apftencntr[y].
       ipaymentplan_flag = pe.payment_plan_flag
      ENDIF
      reply->aencntr[index].apftencntr[y].dpaymentplan_status_cd = pe.payment_plan_status_cd, reply->
      aencntr[index].apftencntr[y].spaymentplan_status_disp = uar_get_code_display(pe
       .payment_plan_status_cd), reply->aencntr[index].apftencntr[y].spaymentplan_status_cdf =
      uar_get_code_meaning(pe.payment_plan_status_cd),
      reply->aencntr[index].apftencntr[y].ddunning_level_cd = pe.dunning_level_cd, reply->aencntr[
      index].apftencntr[y].sdunning_level_disp = uar_get_code_display(pe.dunning_level_cd), reply->
      aencntr[index].apftencntr[y].sdunning_level_cdf = uar_get_code_meaning(pe.dunning_level_cd),
      reply->aencntr[index].apftencntr[y].dbalance = pe.balance, reply->aencntr[index].apftencntr[y].
      nbalance_dr_cr_flag = pe.dr_cr_flag, reply->aencntr[index].apftencntr[y].dbad_debt_balance = pe
      .bad_debt_balance,
      stat = alterlist(reply->aencntr[index].apftencntr[y].acorsp_act_qual,1), reply->aencntr[index].
      apftencntr[y].acorsp_act_qual[1].drelated_corsp_act_id = request->dcorsp_activity_id
     ENDIF
    FOOT REPORT
     stat = alterlist(temp->l,cnt)
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->aencntr,ntotal2)
   SET ntotal2 = size(temp->l,5)
   SET ntotal = (ntotal2+ (nsize - mod(ntotal2,nsize)))
   SET nstart = 1
   SET stat = alterlist(temp->l,ntotal)
   FOR (idx = (ntotal2+ 1) TO ntotal)
     SET temp->l[idx].dpftencntrid = temp->l[ntotal2].dpftencntrid
   ENDFOR
   SET z = 0
   SELECT INTO "nl:"
    FROM pe_status_reason psr,
     (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize))))
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (psr
     WHERE expand(num,nstart,((nstart+ nsize) - 1),psr.pft_encntr_id,temp->l[num].dpftencntrid)
      AND psr.active_ind=1)
    HEAD psr.pft_encntr_id
     z = 0, index = locateval(num,nstart,ntotal2,psr.pft_encntr_id,temp->l[num].dpftencntrid), x =
     temp->l[index].e_ind,
     y = temp->l[index].pfte_ind
    DETAIL
     z = (z+ 1), stat = alterlist(reply->aencntr[x].apftencntr[d1.seq].aholds,z), reply->aencntr[x].
     apftencntr[y].aholds[z].dhold_id = psr.pe_status_reason_id,
     reply->aencntr[x].apftencntr[y].aholds[z].shold_desc = uar_get_code_display(psr
      .pe_status_reason_cd), reply->aencntr[x].apftencntr[y].aholds[z].dthold_dt_tm = psr
     .pe_hold_dt_tm, reply->aencntr[x].apftencntr[y].aholds[z].dhold_cd = psr.pe_status_reason_cd,
     reply->aencntr[x].apftencntr[y].aholds[z].sreason_comment = psr.reason_comment, reply->aencntr[x
     ].apftencntr[y].aholds[z].iclaim_suppress_ind = psr.claim_suppress_ind, reply->aencntr[x].
     apftencntr[y].aholds[z].istmt_suppress_ind = psr.stmt_suppress_ind,
     reply->aencntr[x].apftencntr[y].aholds[z].ibill_hold_rpts_suppress_ind = psr
     .bill_hold_rpts_suppress_ind
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM corsp_log_reltn clr,
     corsp_log cl,
     (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize))))
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (clr
     WHERE expand(num,nstart,((nstart+ nsize) - 1),clr.parent_entity_id,temp->l[num].dpftencntrid)
      AND clr.parent_entity_name="ENCOUNTER"
      AND clr.active_ind=1)
     JOIN (cl
     WHERE cl.activity_id=clr.activity_id
      AND cl.active_ind=1)
    HEAD clr.parent_entity_id
     index = locateval(num,nstart,ntotal2,clr.parent_entity_id,temp->l[num].dpftencntrid), x = temp->
     l[index].e_ind, y = temp->l[index].pfte_ind
    DETAIL
     IF (cl.corsp_type_cd=dcomment_value)
      reply->aencntr[x].apftencntr[y].icomment_ind = 1
     ELSE
      reply->aencntr[x].apftencntr[y].icorsp_ind = 1
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#end_program
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
