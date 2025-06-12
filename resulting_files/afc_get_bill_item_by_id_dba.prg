CREATE PROGRAM afc_get_bill_item_by_id:dba
 EXECUTE srvrtl
 EXECUTE crmrtl
 SET afc_get_bill_item_by_id_vrsn = 002
 FREE RECORD reply
 RECORD reply(
   1 qual[*]
     2 bill_item_id = f8
     2 ext_owner_cd = f8
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_description = vc
     2 ext_short_desc = vc
     2 parent_qual_cd = f8
     2 charge_point_cd = f8
     2 physician_qual_cd = f8
     2 careset_ind = i2
     2 misc_ind = i2
     2 stats_only_ind = i2
     2 workload_only_ind = i2
     2 late_chrg_excl_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 diagnosis[*]
       3 bill_item_type_cd = f8
       3 key1_id = f8
       3 key3_id = f8
       3 bim1_int = i2
     2 service[*]
       3 bill_item_type_cd = f8
       3 key1_id = f8
       3 key3_id = f8
       3 bim1_int = i2
     2 modifier[*]
       3 bill_item_type_cd = f8
       3 key1_id = f8
       3 key5_id = f8
       3 bim1_int = i2
     2 revenue[*]
       3 bill_item_type_cd = f8
       3 key1_id = f8
       3 key5_id = f8
       3 bim1_int = i2
     2 cdm[*]
       3 bill_item_type_cd = f8
       3 key1_id = f8
       3 key6 = vc
       3 key7 = vc
       3 bim1_int = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF (size(request->qual,5) <= 0)
  SET reply->status_data.subeventstatus[1].operationname = "Qual Size Is <= 0"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "STRUCT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "REQUEST->QUAL"
  EXECUTE pft_log "afc_get_bill_item_by_id",
  "Returning Status F::No Bill Item Ids Received - No Search Will Be Performed", 0
  GO TO exitscript
 ENDIF
 DECLARE bgetanymodifiers = i2 WITH noconstant(false)
 DECLARE bgetbillitems = i2 WITH noconstant(false)
 DECLARE lbillitemcount = i4 WITH noconstant(0)
 DECLARE bgetdiagnosis = i2 WITH noconstant(false)
 DECLARE ldiagnosiscount = i4 WITH noconstant(0)
 DECLARE dcvicd9_14002 = f8 WITH noconstant(0.0)
 DECLARE bgetservice = i2 WITH noconstant(false)
 DECLARE lservicecount = i4 WITH noconstant(0)
 DECLARE dcvhcpcs_14002 = f8 WITH noconstant(0.0)
 DECLARE dcvcpt4_14002 = f8 WITH noconstant(0.0)
 DECLARE dcvproccode_14002 = f8 WITH noconstant(0.0)
 DECLARE bgetmodifier = i2 WITH noconstant(false)
 DECLARE lmodifiercount = i4 WITH noconstant(0)
 DECLARE dcvmodifier_14002 = f8 WITH noconstant(0.0)
 DECLARE bgetrevenue = i2 WITH noconstant(false)
 DECLARE lrevenuecount = i4 WITH noconstant(0)
 DECLARE dcvrevenue_14002 = f8 WITH noconstant(0.0)
 DECLARE bgetcdm = i2 WITH noconstant(false)
 DECLARE lcdmcount = i4 WITH noconstant(0)
 DECLARE dcvcdmsched_14002 = f8 WITH noconstant(0.0)
 DECLARE dcvordcat_13016 = f8 WITH noconstant(0.0)
 IF ((((request->load.diagnosis_ind=1)) OR ((((request->load.service_ind=1)) OR ((((request->load.
 modifier_ind=1)) OR ((((request->load.revenue_ind=1)) OR ((request->load.cdm_ind=1))) )) )) )) )
  SET bgetanymodifiers = true
  SET bgetdiagnosis = request->load.diagnosis_ind
  SET stat = uar_get_meaning_by_codeset(14002,"ICD9",1,dcvicd9_14002)
  SET bgetservice = request->load.service_ind
  SET stat = uar_get_meaning_by_codeset(14002,"HCPCS",1,dcvhcpcs_14002)
  SET stat = uar_get_meaning_by_codeset(14002,"CPT4",1,dcvcpt4_14002)
  SET stat = uar_get_meaning_by_codeset(14002,"PROCCODE",1,dcvproccode_14002)
  SET bgetmodifier = request->load.modifier_ind
  SET stat = uar_get_meaning_by_codeset(14002,"MODIFIER",1,dcvmodifier_14002)
  SET bgetrevenue = request->load.revenue_ind
  SET stat = uar_get_meaning_by_codeset(14002,"REVENUE",1,dcvrevenue_14002)
  SET bgetcdm = request->load.cdm_ind
  SET stat = uar_get_meaning_by_codeset(14002,"CDM_SCHED",1,dcvcdmsched_14002)
 ENDIF
 IF ((request->load.bill_item_ind=1))
  SET bgetbillitems = true
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13016,"ORD CAT",1,dcvordcat_13016)
 IF (bgetbillitems=true
  AND bgetanymodifiers=true)
  EXECUTE pft_log "afc_get_bill_item_by_id",
  "Bill Item Search Will Include BillItems Info And Modifiers Info", 4
  SELECT INTO "Nl:"
   FROM (dummyt d  WITH seq = value(size(request->qual,5))),
    bill_item bi,
    bill_item_modifier bim
   PLAN (d)
    JOIN (bi
    WHERE (bi.bill_item_id=request->qual[d.seq].bill_item_id)
     AND bi.active_ind=1
     AND bi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND bi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (bim
    WHERE outerjoin(bi.bill_item_id)=bim.bill_item_id
     AND outerjoin(1)=bim.active_ind
     AND outerjoin(reqdata->active_status_cd)=bim.active_status_cd
     AND outerjoin(cnvtdatetime(curdate,curtime3)) >= bim.beg_effective_dt_tm
     AND outerjoin(cnvtdatetime(curdate,curtime3)) <= bim.end_effective_dt_tm)
   ORDER BY request->qual[d.seq].bill_item_id DESC, bim.bill_item_id DESC, trim(uar_get_code_display(
      bim.key1_id),3) DESC
   HEAD bi.bill_item_id
    lbillitemcount = (lbillitemcount+ 1), stat = alterlist(reply->qual,lbillitemcount),
    ldiagnosiscount = 0,
    lservicecount = 0, lmodifiercount = 0, lrevenuecount = 0,
    lcdmcount = 0, reply->qual[lbillitemcount].bill_item_id = bi.bill_item_id, reply->qual[
    lbillitemcount].ext_owner_cd = bi.ext_owner_cd,
    reply->qual[lbillitemcount].ext_parent_reference_id = bi.ext_parent_reference_id, reply->qual[
    lbillitemcount].ext_parent_contributor_cd = bi.ext_parent_contributor_cd, reply->qual[
    lbillitemcount].ext_child_reference_id = bi.ext_child_reference_id,
    reply->qual[lbillitemcount].ext_child_contributor_cd = bi.ext_child_contributor_cd, reply->qual[
    lbillitemcount].ext_description = bi.ext_description, reply->qual[lbillitemcount].ext_short_desc
     = trim(bi.ext_short_desc,3),
    reply->qual[lbillitemcount].parent_qual_cd = bi.parent_qual_cd, reply->qual[lbillitemcount].
    charge_point_cd = bi.charge_point_cd, reply->qual[lbillitemcount].physician_qual_cd = bi
    .physician_qual_cd,
    reply->qual[lbillitemcount].misc_ind = bi.misc_ind, reply->qual[lbillitemcount].stats_only_ind =
    bi.stats_only_ind, reply->qual[lbillitemcount].workload_only_ind = bi.workload_only_ind,
    reply->qual[lbillitemcount].beg_effective_dt_tm = bi.beg_effective_dt_tm, reply->qual[
    lbillitemcount].end_effective_dt_tm = bi.end_effective_dt_tm, reply->qual[lbillitemcount].
    active_ind = bi.active_ind
   DETAIL
    IF (bgetdiagnosis=true)
     IF (bim.key1_id=dcvicd9_14002)
      ldiagnosiscount = (ldiagnosiscount+ 1), stat = alterlist(reply->qual[lbillitemcount].diagnosis,
       ldiagnosiscount), reply->qual[lbillitemcount].diagnosis[ldiagnosiscount].bill_item_type_cd =
      bim.bill_item_type_cd,
      reply->qual[lbillitemcount].diagnosis[ldiagnosiscount].key1_id = bim.key1_id, reply->qual[
      lbillitemcount].diagnosis[ldiagnosiscount].key3_id = bim.key3_id, reply->qual[lbillitemcount].
      diagnosis[ldiagnosiscount].bim1_int = bim.bim1_int
     ENDIF
    ENDIF
    IF (bgetservice=true)
     IF (bim.key1_id IN (dcvhcpcs_14002, dcvcpt4_14002, dcvproccode_14002))
      lservicecount = (lservicecount+ 1), stat = alterlist(reply->qual[lbillitemcount].service,
       lservicecount), reply->qual[lbillitemcount].service[lservicecount].bill_item_type_cd = bim
      .bill_item_type_cd,
      reply->qual[lbillitemcount].service[lservicecount].key1_id = bim.key1_id, reply->qual[
      lbillitemcount].service[lservicecount].key3_id = bim.key3_id, reply->qual[lbillitemcount].
      service[lservicecount].bim1_int = bim.bim1_int
     ENDIF
    ENDIF
    IF (bgetmodifier=true)
     IF (bim.key1_id=dcvmodifier_14002)
      lmodifiercount = (lmodifiercount+ 1), stat = alterlist(reply->qual[lbillitemcount].modifier,
       lmodifiercount), reply->qual[lbillitemcount].modifier[lmodifiercount].bill_item_type_cd = bim
      .bill_item_type_cd,
      reply->qual[lbillitemcount].modifier[lmodifiercount].key1_id = bim.key1_id, reply->qual[
      lbillitemcount].modifier[lmodifiercount].key5_id = bim.key5_id, reply->qual[lbillitemcount].
      modifier[lmodifiercount].bim1_int = bim.bim1_int
     ENDIF
    ENDIF
    IF (bgetrevenue=true)
     IF (bim.key1_id=dcvrevenue_14002)
      lrevenuecount = (lrevenuecount+ 1), stat = alterlist(reply->qual[lbillitemcount].revenue,
       lrevenuecount), reply->qual[lbillitemcount].revenue[lrevenuecount].bill_item_type_cd = bim
      .bill_item_type_cd,
      reply->qual[lbillitemcount].revenue[lrevenuecount].key1_id = bim.key1_id, reply->qual[
      lbillitemcount].revenue[lrevenuecount].key5_id = bim.key5_id, reply->qual[lbillitemcount].
      revenue[lrevenuecount].bim1_int = bim.bim1_int
     ENDIF
    ENDIF
    IF (bgetcdm=true)
     IF (bim.key1_id=dcvcdmsched_14002)
      lcdmcount = (lcdmcount+ 1), stat = alterlist(reply->qual[lbillitemcount].cdm,lcdmcount), reply
      ->qual[lbillitemcount].cdm[lcdmcount].bill_item_type_cd = bim.bill_item_type_cd,
      reply->qual[lbillitemcount].cdm[lcdmcount].key1_id = bim.key1_id, reply->qual[lbillitemcount].
      cdm[lcdmcount].key6 = trim(bim.key6,3), reply->qual[lbillitemcount].cdm[lcdmcount].key7 = trim(
       bim.key7,3),
      reply->qual[lbillitemcount].cdm[lcdmcount].bim1_int = bim.bim1_int
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SET reply->status_data.subeventstatus[1].operationname = "Select"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM"
   SET reply->status_data.status = "Z"
   EXECUTE pft_log "afc_get_bill_item_by_id", "Returning Status Z::No Matching Bill Items Found", 1
   GO TO exitscript
  ELSE
   EXECUTE pft_log "afc_get_bill_item_by_id", build("Returning Status S::# Of Bill Items Found = ",
    lbillitemcount), 4
  ENDIF
  CALL checkcareset(0)
 ELSEIF (bgetbillitems=true
  AND bgetanymodifiers=false)
  EXECUTE pft_log "afc_get_bill_item_by_id",
  "Bill Item Search Will Include BillItems Info And Not Modifiers Info", 4
  SELECT INTO "Nl:"
   FROM (dummyt d  WITH seq = value(size(request->qual,5))),
    bill_item bi
   PLAN (d)
    JOIN (bi
    WHERE (bi.bill_item_id=request->qual[d.seq].bill_item_id)
     AND bi.active_ind=1
     AND bi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND bi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY request->qual[d.seq].bill_item_id DESC
   HEAD bi.bill_item_id
    lbillitemcount = (lbillitemcount+ 1), stat = alterlist(reply->qual,lbillitemcount),
    ldiagnosiscount = 0,
    lservicecount = 0, lmodifiercount = 0, lrevenuecount = 0,
    lcdmcount = 0, reply->qual[lbillitemcount].bill_item_id = bi.bill_item_id, reply->qual[
    lbillitemcount].ext_owner_cd = bi.ext_owner_cd,
    reply->qual[lbillitemcount].ext_parent_reference_id = bi.ext_parent_reference_id, reply->qual[
    lbillitemcount].ext_parent_contributor_cd = bi.ext_parent_contributor_cd, reply->qual[
    lbillitemcount].ext_child_reference_id = bi.ext_child_reference_id,
    reply->qual[lbillitemcount].ext_child_contributor_cd = bi.ext_child_contributor_cd, reply->qual[
    lbillitemcount].ext_description = bi.ext_description, reply->qual[lbillitemcount].ext_short_desc
     = trim(bi.ext_short_desc,3),
    reply->qual[lbillitemcount].parent_qual_cd = bi.parent_qual_cd, reply->qual[lbillitemcount].
    charge_point_cd = bi.charge_point_cd, reply->qual[lbillitemcount].physician_qual_cd = bi
    .physician_qual_cd,
    reply->qual[lbillitemcount].misc_ind = bi.misc_ind, reply->qual[lbillitemcount].stats_only_ind =
    bi.stats_only_ind, reply->qual[lbillitemcount].workload_only_ind = bi.workload_only_ind,
    reply->qual[lbillitemcount].late_chrg_excl_ind = bi.late_chrg_excl_ind, reply->qual[
    lbillitemcount].beg_effective_dt_tm = bi.beg_effective_dt_tm, reply->qual[lbillitemcount].
    end_effective_dt_tm = bi.end_effective_dt_tm,
    reply->qual[lbillitemcount].active_ind = bi.active_ind
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SET reply->status_data.subeventstatus[1].operationname = "Select"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM"
   SET reply->status_data.status = "Z"
   EXECUTE pft_log "afc_get_bill_item_by_id", "Returning Status Z::No Matching Bill Items Found", 1
   GO TO exitscript
  ELSE
   EXECUTE pft_log "afc_get_bill_item_by_id", build("Returning Status S::# Of Bill Items Found = ",
    lbillitemcount), 4
  ENDIF
  CALL checkcareset(0)
 ELSEIF (bgetbillitems=false
  AND bgetanymodifiers=true)
  EXECUTE pft_log "afc_get_bill_item_by_id",
  "Bill Item Search Will Not Include BillItems Info And Will Include Modifiers Info", 4
  SELECT INTO "Nl:"
   FROM (dummyt d  WITH seq = value(size(request->qual,5))),
    bill_item bi,
    bill_item_modifier bim
   PLAN (d)
    JOIN (bi
    WHERE (bi.bill_item_id=request->qual[d.seq].bill_item_id)
     AND bi.active_ind=1
     AND bi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND bi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (bim
    WHERE outerjoin(bi.bill_item_id)=bim.bill_item_id
     AND outerjoin(1)=bim.active_ind
     AND outerjoin(reqdata->active_status_cd)=bim.active_status_cd
     AND outerjoin(cnvtdatetime(curdate,curtime3)) >= bim.beg_effective_dt_tm
     AND outerjoin(cnvtdatetime(curdate,curtime3)) <= bim.end_effective_dt_tm)
   ORDER BY request->qual[d.seq].bill_item_id DESC, bim.bill_item_id DESC, trim(uar_get_code_display(
      bim.key1_id),3) DESC
   HEAD bi.bill_item_id
    lbillitemcount = (lbillitemcount+ 1), stat = alterlist(reply->qual,lbillitemcount),
    ldiagnosiscount = 0,
    lservicecount = 0, lmodifiercount = 0, lrevenuecount = 0,
    lcdmcount = 0
   DETAIL
    IF (bgetdiagnosis=true)
     IF (bim.key1_id=dcvicd9_14002)
      ldiagnosiscount = (ldiagnosiscount+ 1), stat = alterlist(reply->qual[lbillitemcount].diagnosis,
       ldiagnosiscount), reply->qual[lbillitemcount].diagnosis[ldiagnosiscount].bill_item_type_cd =
      bim.bill_item_type_cd,
      reply->qual[lbillitemcount].diagnosis[ldiagnosiscount].key1_id = bim.key1_id, reply->qual[
      lbillitemcount].diagnosis[ldiagnosiscount].key3_id = bim.key3_id, reply->qual[lbillitemcount].
      diagnosis[ldiagnosiscount].bim1_int = bim.bim1_int
     ENDIF
    ENDIF
    IF (bgetservice=true)
     IF (bim.key1_id IN (dcvhcpcs_14002, dcvcpt4_14002, dcvproccode_14002))
      lservicecount = (lservicecount+ 1), stat = alterlist(reply->qual[lbillitemcount].service,
       lservicecount), reply->qual[lbillitemcount].service[lservicecount].bill_item_type_cd = bim
      .bill_item_type_cd,
      reply->qual[lbillitemcount].service[lservicecount].key1_id = bim.key1_id, reply->qual[
      lbillitemcount].service[lservicecount].key3_id = bim.key3_id, reply->qual[lbillitemcount].
      service[lservicecount].bim1_int = bim.bim1_int
     ENDIF
    ENDIF
    IF (bgetmodifier=true)
     IF (bim.key1_id=dcvmodifier_14002)
      lmodifiercount = (lmodifiercount+ 1), stat = alterlist(reply->qual[lbillitemcount].modifier,
       lmodifiercount), reply->qual[lbillitemcount].modifier[lmodifiercount].bill_item_type_cd = bim
      .bill_item_type_cd,
      reply->qual[lbillitemcount].modifier[lmodifiercount].key1_id = bim.key1_id, reply->qual[
      lbillitemcount].modifier[lmodifiercount].key5_id = bim.key5_id, reply->qual[lbillitemcount].
      modifier[lmodifiercount].bim1_int = bim.bim1_int
     ENDIF
    ENDIF
    IF (bgetrevenue=true)
     IF (bim.key1_id=dcvrevenue_14002)
      lrevenuecount = (lrevenuecount+ 1), stat = alterlist(reply->qual[lbillitemcount].revenue,
       lrevenuecount), reply->qual[lbillitemcount].revenue[lrevenuecount].bill_item_type_cd = bim
      .bill_item_type_cd,
      reply->qual[lbillitemcount].revenue[lrevenuecount].key1_id = bim.key1_id, reply->qual[
      lbillitemcount].revenue[lrevenuecount].key5_id = bim.key5_id, reply->qual[lbillitemcount].
      revenue[lrevenuecount].bim1_int = bim.bim1_int
     ENDIF
    ENDIF
    IF (bgetcdm=true)
     IF (bim.key1_id=dcvcdmsched_14002)
      lcdmcount = (lcdmcount+ 1), stat = alterlist(reply->qual[lbillitemcount].cdm,lcdmcount), reply
      ->qual[lbillitemcount].cdm[lcdmcount].bill_item_type_cd = bim.bill_item_type_cd,
      reply->qual[lbillitemcount].cdm[lcdmcount].key1_id = bim.key1_id, reply->qual[lbillitemcount].
      cdm[lcdmcount].key6 = trim(bim.key6,3), reply->qual[lbillitemcount].cdm[lcdmcount].key7 = trim(
       bim.key7,3),
      reply->qual[lbillitemcount].cdm[lcdmcount].bim1_int = bim.bim1_int
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SET reply->status_data.subeventstatus[1].operationname = "Select"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM"
   SET reply->status_data.status = "Z"
   EXECUTE pft_log "afc_get_bill_item_by_id", "Returning Status Z::No Matching Bill Items Found", 1
   GO TO exitscript
  ELSE
   EXECUTE pft_log "afc_get_bill_item_by_id", build("Returning Status S::# Of Bill Items Found = ",
    lbillitemcount), 4
  ENDIF
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "Select - No Operation Match Found"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM"
  EXECUTE pft_log "afc_get_bill_item_by_id", "No Operation Match Found", 0
  GO TO exitscript
 ENDIF
 SET reply->status_data.status = "S"
#exitscript
 CALL echorecord(reply)
 SUBROUTINE checkcareset(_null)
   SELECT INTO "Nl:"
    FROM (dummyt d  WITH seq = value(size(reply->qual,5))),
     bill_item bi
    PLAN (d)
     JOIN (bi
     WHERE (bi.ext_parent_reference_id=reply->qual[d.seq].ext_parent_reference_id)
      AND bi.ext_parent_contributor_cd=dcvordcat_13016
      AND bi.ext_child_reference_id != 0
      AND bi.ext_child_contributor_cd=dcvordcat_13016
      AND bi.active_ind=1)
    DETAIL
     IF ((reply->qual[d.seq].ext_child_reference_id=0))
      reply->qual[d.seq].careset_ind = 1
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
END GO
