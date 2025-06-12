CREATE PROGRAM afc_ratestructure_query_gen:dba
 SET afc_ratestructure_query_gen_vrsn = "303270.FT.008"
 FREE RECORD reply
 RECORD reply(
   1 objarray[*]
     2 invalid = i2
     2 price_sched_item_id = f8
     2 price_sched_id = f8
     2 bill_item_id = f8
     2 bill_item_desc = vc
     2 bill_item_type_flag = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 price = f8
     2 price_interval_cd = f8
     2 price_interval_disp = vc
     2 price_interval_desc = vc
     2 price_interval_mean = vc
     2 activity_cd = f8
     2 activity_disp = vc
     2 activity_desc = vc
     2 activity_mean = vc
     2 billing_discount_priority_seq = i4
     2 bill_item_mod_id = f8
     2 charge_point_sched_cd = f8
     2 charge_point_sched_disp = vc
     2 charge_point_sched_desc = vc
     2 charge_point_sched_mean = vc
     2 charge_point_cd = f8
     2 charge_point_disp = vc
     2 charge_point_desc = vc
     2 charge_point_mean = vc
     2 charge_level_cd = f8
     2 charge_level_disp = vc
     2 charge_level_desc = vc
     2 charge_level_mean = vc
     2 bim1_int = f8
     2 bill_code_sched[*]
       3 bill_code_sched_type = vc
       3 bill_code_sched_disp = vc
       3 bill_code_sched_desc = vc
       3 bill_code_sched_value = vc
       3 bill_code_sched_cd = f8
     2 interval_qual[*]
       3 item_interval_id = f8
       3 price = f8
       3 interval_template_cd = f8
       3 interval_template_disp = vc
       3 interval_template_desc = vc
       3 interval_template_mean = vc
       3 parent_entity_id = f8
       3 interval_id = f8
       3 beg_value = f8
       3 end_value = f8
       3 unit_type_cd = f8
       3 unit_type_disp = vc
       3 unit_type_desc = vc
       3 unit_type_mean = vc
       3 calc_type_cd = f8
       3 calc_type_disp = vc
       3 calc_type_desc = vc
       3 calc_type_mean = vc
       3 bill_code_sched[*]
         4 bill_code_sched_type = vc
         4 bill_code_sched_disp = vc
         4 bill_code_sched_desc = vc
         4 bill_code_sched_value = vc
         4 bill_code_sched_cd = f8
         4 nomen_id = f8
         4 key5_id = f8
   1 items[*]
     2 bill_item_id = f8
     2 invalid = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temp
 RECORD temp(
   1 objarray[*]
     2 invalid = i2
     2 price_sched_item_id = f8
     2 price_sched_id = f8
     2 bill_item_id = f8
     2 bill_item_desc = vc
     2 bill_item_type_flag = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 price = f8
     2 price_interval_cd = f8
     2 price_interval_disp = vc
     2 price_interval_desc = vc
     2 price_interval_mean = vc
     2 activity_cd = f8
     2 activity_disp = vc
     2 activity_desc = vc
     2 activity_mean = vc
     2 billing_discount_priority_seq = i4
     2 bill_code_sched[*]
       3 bill_code_sched_type = vc
       3 bill_code_sched_disp = vc
       3 bill_code_sched_desc = vc
       3 bill_code_sched_value = vc
       3 bill_code_sched_cd = f8
 )
 FREE RECORD cpt
 RECORD cpt(
   1 arr[*]
     2 code_value = f8
 )
 FREE RECORD hcpcs
 RECORD hcpcs(
   1 arr[*]
     2 code_value = f8
 )
 FREE RECORD revenue
 RECORD revenue(
   1 arr[*]
     2 code_value = f8
 )
 SET reply->status_data.status = "F"
 DECLARE subgetcurrentprice1(dummy=i2) = i4 WITH noconstant(0)
 DECLARE subgetcurrentprice2(dummy=i2) = i4 WITH noconstant(0)
 DECLARE subchkinvalid(dummy=i2) = i4 WITH noconstant(0)
 DECLARE subgetpriceinterval(dummy=i2) = i4 WITH noconstant(0)
 DECLARE subrequery(dummy=i2) = i4 WITH noconstant(0)
 DECLARE subgetzeroprice1(dummy=i2) = i4 WITH noconstant(0)
 DECLARE subgetbilltype(dummy=i2) = i4 WITH noconstant(0)
 DECLARE subuarerror(codeset=vc,meaning=vc) = i4 WITH noconstant(0)
 DECLARE subgetchargepro1(dummy=i2) = i4 WITH noconstant(0)
 DECLARE getorgsecuritypreference(dummy=vc) = i2
 DECLARE initializeorgsecbillschedlist(dummy=vc) = i2
 DECLARE initializebillschedlist(dummy=vc) = i2
 DECLARE ncnt3 = i4 WITH noconstant(0)
 DECLARE ncnt = i4 WITH noconstant(0)
 DECLARE ncnt2 = i4 WITH noconstant(0)
 DECLARE ncpt = i4 WITH noconstant(0)
 DECLARE nhcpcs = i4 WITH noconstant(0)
 DECLARE nrevenue = i4 WITH noconstant(0)
 DECLARE dprice_sched_id = f8 WITH noconstant(0.0)
 DECLARE nfound = i2 WITH noconstant(0)
 DECLARE sparser_activity = vc WITH noconstant("")
 DECLARE sparser_price_interval = vc WITH noconstant("")
 DECLARE sparser_bill_item = vc WITH noconstant("")
 DECLARE sparser_bimtype = vc WITH noconstant("")
 DECLARE isbillitemsecurityon = i2 WITH noconstant(false)
 DECLARE isbillcodeschedsecurityon = i2 WITH noconstant(false)
 DECLARE billcode_13019 = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13019,"BILL CODE",1,billcode_13019)
 IF (billcode_13019 <= 0.0)
  CALL subuarerror("13019","BILL CODE")
  GO TO end_program
 ENDIF
 DECLARE chargepoint_13019 = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13019,"CHARGE POINT",1,chargepoint_13019)
 IF (chargepoint_13019 <= 0.0)
  CALL subuarerror("13019","CHARGE POINT")
  GO TO end_program
 ENDIF
 DECLARE ordcat_13016 = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13016,"ORD CAT",1,ordcat_13016)
 IF (ordcat_13016 <= 0.0)
  CALL subuarerror("13016","ORD_CAT")
  GO TO end_program
 ENDIF
 DECLARE alpharesp_13016 = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13016,"ALPHA RESP",1,alpharesp_13016)
 IF (alpharesp_13016 <= 0.0)
  CALL subuarerror("13016","ALPHA RESP")
  GO TO end_program
 ENDIF
 DECLARE 26078_bill_item = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(26078,"BILL_ITEM",1,26078_bill_item)
 IF (26078_bill_item <= 0.0)
  CALL subuarerror("26078","BILL ITEM")
  GO TO end_program
 ENDIF
 DECLARE 26078_bc_sched = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(26078,"BC_SCHED",1,26078_bc_sched)
 IF (26078_bc_sched <= 0.0)
  CALL subuarerror("26078","BILL CODE SCHEDULE")
  GO TO end_program
 ENDIF
 DECLARE 13019_intervalcode = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13019,"INTERVALCODE",1,13019_intervalcode)
 IF (13019_intervalcode <= 0.0)
  CALL subuarerror("13019","Interval Code")
  GO TO end_program
 ENDIF
 IF (validate(request->activity_cd,0.0) > 0.0)
  SET sparser_activity = "bi.ext_owner_cd+0 = request->activity_cd"
 ELSE
  SET sparser_activity = "0 = 0"
 ENDIF
 IF (validate(request->price_interval_cd,0.0) > 0.0)
  SET sparser_price_interval = "psi.interval_template_cd = request->price_interval_cd"
 ELSE
  SET sparser_price_interval = "0 = 0"
 ENDIF
 IF (validate(request->bill_item_id,0.0) > 0.0)
  SET sparser_bill_item = "psi.bill_item_id+0 = request->bill_item_id"
 ELSE
  SET sparser_bill_item = "0 = 0"
 ENDIF
 IF (validate(request->cpt4_from,"") != "")
  SET sparser_bimtype = "CPT4"
 ENDIF
 IF (validate(request->hcpcs_from,"") != "")
  SET sparser_bimtype = "HCPCS"
 ENDIF
 IF (validate(request->revenue_cd,0.0) > 0.0)
  SET sparser_bimtype = "REVENUE"
 ENDIF
 CALL getorgsecuritypreference(null)
 IF (isbillcodeschedsecurityon)
  CALL initializeorgsecbillschedlist(0)
 ELSE
  CALL initializebillschedlist(0)
 ENDIF
 CASE (request->query_type_flag)
  OF 1:
   CALL subgetcurrentprice1(0)
   CALL subgetcurrentprice2(0)
   CALL subchkinvalid(0)
   CALL subgetpriceinterval(0)
   CALL subgetbilltype(0)
  OF 2:
   IF (subrequery(0)=1)
    GO TO end_program
   ELSE
    CALL subgetcurrentprice1(0)
    CALL subgetcurrentprice2(0)
    CALL subchkinvalid(0)
    CALL subgetpriceinterval(0)
   ENDIF
  OF 3:
   CALL subgetzeroprice1(0)
   CALL subgetpriceinterval(0)
   CALL subgetbilltype(0)
  OF 4:
   CALL subgetchargepro1(0)
   CALL subgetbilltype(0)
 ENDCASE
 IF (size(reply->objarray,5) > 0)
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus.operationname = "Retrieve successful"
  SET reply->status_data.subeventstatus.operationstatus = "S"
  SET reply->status_data.subeventstatus.targetobjectname = ""
  SET reply->status_data.subeventstatus.targetobjectvalue = "AFC_RATESTRUCTURE_QUERY_GEN"
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "No records found"
  SET reply->status_data.subeventstatus.operationstatus = "Z"
  SET reply->status_data.subeventstatus.targetobjectname = ""
  SET reply->status_data.subeventstatus.targetobjectvalue = "AFC_RATESTRUCTURE_QUERY_GEN"
 ENDIF
 GO TO end_program
 SUBROUTINE subgetcurrentprice1(dummy)
   SET ncnt = 0
   SET ncnt2 = 0
   CALL echo(" Enter subgetcurrentprice1 ")
   SELECT
    IF (isbillitemsecurityon)
     FROM prsnl_org_reltn por,
      cs_org_reltn cor,
      price_sched_items psi,
      bill_item bi,
      bill_item_modifier bim
     PLAN (por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND por.active_ind=1)
      JOIN (cor
      WHERE cor.organization_id=por.organization_id
       AND cor.cs_org_reltn_type_cd=26078_bill_item
       AND cor.active_ind=1)
      JOIN (bi
      WHERE bi.bill_item_id=cor.key1_id
       AND parser(sparser_activity))
      JOIN (psi
      WHERE psi.bill_item_id=bi.bill_item_id
       AND (psi.price_sched_id=request->price_sched_id)
       AND psi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND psi.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND ((psi.bill_item_id+ 0) != 0.0)
       AND psi.active_ind=1
       AND parser(sparser_bill_item)
       AND parser(sparser_price_interval))
      JOIN (bim
      WHERE bim.bill_item_id=outerjoin(bi.bill_item_id)
       AND bim.bill_item_type_cd=outerjoin(billcode_13019)
       AND bim.bim1_int=outerjoin(1)
       AND bim.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND bim.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
       AND bim.active_ind=outerjoin(1))
    ELSE
     FROM price_sched_items psi,
      bill_item bi,
      bill_item_modifier bim
     PLAN (psi
      WHERE (psi.price_sched_id=request->price_sched_id)
       AND psi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND psi.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND ((psi.bill_item_id+ 0) != 0.0)
       AND psi.active_ind=1
       AND parser(sparser_bill_item)
       AND parser(sparser_price_interval))
      JOIN (bi
      WHERE bi.bill_item_id=psi.bill_item_id
       AND bi.active_ind=1
       AND parser(sparser_activity))
      JOIN (bim
      WHERE bim.bill_item_id=outerjoin(bi.bill_item_id)
       AND bim.bill_item_type_cd=outerjoin(billcode_13019)
       AND bim.bim1_int=outerjoin(1)
       AND bim.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND bim.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
       AND bim.active_ind=outerjoin(1))
    ENDIF
    INTO "nl:"
    ORDER BY bi.ext_description, bi.bill_item_id, cnvtdatetime(psi.beg_effective_dt_tm)
    HEAD REPORT
     ncnt = 0, ncnt2 = 0, stat = alterlist(temp->objarray,50)
    HEAD psi.bill_item_id
     ncnt = (ncnt+ 1)
     IF (mod(ncnt,50)=1
      AND ncnt > 1)
      stat = alterlist(temp->objarray,(ncnt+ 49))
     ENDIF
     temp->objarray[ncnt].invalid = 0, temp->objarray[ncnt].price_sched_item_id = psi
     .price_sched_items_id, temp->objarray[ncnt].price_sched_id = psi.price_sched_id,
     temp->objarray[ncnt].bill_item_id = bi.bill_item_id, temp->objarray[ncnt].bill_item_desc = trim(
      bi.ext_description), temp->objarray[ncnt].bill_item_type_flag =
     IF (bi.ext_parent_reference_id > 0.0
      AND bi.ext_child_reference_id=0.0) 1
     ELSEIF (bi.ext_parent_reference_id > 0.0
      AND bi.ext_child_reference_id > 0.0) 2
     ELSEIF (bi.ext_parent_reference_id=0.0
      AND bi.ext_child_reference_id > 0.0) 3
     ELSE 99
     ENDIF
     ,
     temp->objarray[ncnt].bill_item_type_flag =
     IF (bi.ext_child_contributor_cd=alpharesp_13016) 4
     ELSE temp->objarray[ncnt].bill_item_type_flag
     ENDIF
     , temp->objarray[ncnt].beg_effective_dt_tm = cnvtdatetime(psi.beg_effective_dt_tm), temp->
     objarray[ncnt].end_effective_dt_tm = cnvtdatetime(psi.end_effective_dt_tm),
     temp->objarray[ncnt].price = psi.price, temp->objarray[ncnt].price_interval_cd = psi
     .interval_template_cd, temp->objarray[ncnt].price_interval_disp = trim(uar_get_code_display(psi
       .interval_template_cd)),
     temp->objarray[ncnt].price_interval_desc = trim(uar_get_code_description(psi
       .interval_template_cd)), temp->objarray[ncnt].price_interval_mean = trim(uar_get_code_meaning(
       psi.interval_template_cd)), temp->objarray[ncnt].activity_cd = bi.ext_owner_cd,
     temp->objarray[ncnt].activity_disp = trim(uar_get_code_display(bi.ext_owner_cd)), temp->
     objarray[ncnt].activity_desc = trim(uar_get_code_description(bi.ext_owner_cd)), temp->objarray[
     ncnt].activity_mean = trim(uar_get_code_meaning(bi.ext_owner_cd)),
     temp->objarray[ncnt].billing_discount_priority_seq = psi.billing_discount_priority_seq, ncnt2 =
     0
    DETAIL
     IF (bim.bill_item_mod_id > 0.0)
      bcschedtype = trim(uar_get_code_meaning(cnvtreal(bim.key1_id)))
      IF (bcschedtype IN ("CPT4", "HCPCS", "REVENUE", "CDM_SCHED"))
       ncnt2 = (ncnt2+ 1), stat = alterlist(temp->objarray[ncnt].bill_code_sched,ncnt2), temp->
       objarray[ncnt].bill_code_sched[ncnt2].bill_code_sched_type = trim(uar_get_code_meaning(
         cnvtreal(bim.key1_id))),
       temp->objarray[ncnt].bill_code_sched[ncnt2].bill_code_sched_disp = trim(uar_get_code_display(
         cnvtreal(bim.key1_id))), temp->objarray[ncnt].bill_code_sched[ncnt2].bill_code_sched_cd =
       bim.key1_id, temp->objarray[ncnt].bill_code_sched[ncnt2].bill_code_sched_desc = trim(bim.key7),
       temp->objarray[ncnt].bill_code_sched[ncnt2].bill_code_sched_value = trim(bim.key6)
       IF (bcschedtype="REVENUE")
        temp->objarray[ncnt].bill_code_sched[ncnt2].bill_code_sched_value = trim(uar_get_code_display
         (cnvtreal(bim.key5_id)))
       ENDIF
      ENDIF
     ENDIF
    FOOT  psi.bill_item_id
     ncnt = ncnt
    FOOT REPORT
     stat = alterlist(temp->objarray,ncnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE subgetcurrentprice2(dummy)
   IF (size(temp->objarray,5) > 0)
    CALL echo(" Enter subgetcurrentprice2 ")
    SELECT
     IF (sparser_bimtype="CPT4")
      head_bill_item_id = temp->objarray[d.seq].bill_item_id
      FROM (dummyt d  WITH seq = size(temp->objarray,5)),
       bill_item_modifier bim
      PLAN (d)
       JOIN (bim
       WHERE (bim.bill_item_id=temp->objarray[d.seq].bill_item_id)
        AND expand(ncpt,1,size(cpt->arr,5),bim.key1_id,cpt->arr[ncpt].code_value)
        AND bim.key6 BETWEEN request->cpt4_from AND request->cpt4_to
        AND bim.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND bim.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND bim.active_ind=1)
     ELSEIF (sparser_bimtype="HCPCS")
      head_bill_item_id = temp->objarray[d.seq].bill_item_id
      FROM (dummyt d  WITH seq = size(temp->objarray,5)),
       bill_item_modifier bim
      PLAN (d)
       JOIN (bim
       WHERE (bim.bill_item_id=temp->objarray[d.seq].bill_item_id)
        AND expand(nhcpcs,1,size(hcpcs->arr,5),bim.key1_id,hcpcs->arr[nhcpcs].code_value)
        AND bim.key6 BETWEEN request->hcpcs_from AND request->hcpcs_to
        AND bim.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND bim.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND bim.active_ind=1)
     ELSEIF (sparser_bimtype="REVENUE")
      head_bill_item_id = temp->objarray[d.seq].bill_item_id
      FROM (dummyt d  WITH seq = size(temp->objarray,5)),
       bill_item_modifier bim
      PLAN (d)
       JOIN (bim
       WHERE (bim.bill_item_id=temp->objarray[d.seq].bill_item_id)
        AND expand(nrevenue,1,size(revenue->arr,5),bim.key1_id,revenue->arr[nrevenue].code_value)
        AND (bim.key5_id=request->revenue_cd)
        AND bim.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND bim.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND bim.active_ind=1)
     ELSE
      head_bill_item_id = temp->objarray[d.seq].bill_item_id
      FROM (dummyt d  WITH seq = size(temp->objarray,5))
     ENDIF
     INTO "nl:"
     HEAD REPORT
      ncnt = 0, stat = alterlist(reply->objarray,50)
     HEAD head_bill_item_id
      ncnt = (ncnt+ 1)
      IF (mod(ncnt,50)=1
       AND ncnt > 1)
       stat = alterlist(reply->objarray,(ncnt+ 49))
      ENDIF
      reply->objarray[ncnt].invalid = temp->objarray[d.seq].invalid, reply->objarray[ncnt].
      price_sched_item_id = temp->objarray[d.seq].price_sched_item_id, reply->objarray[ncnt].
      price_sched_id = temp->objarray[d.seq].price_sched_id,
      reply->objarray[ncnt].bill_item_id = temp->objarray[d.seq].bill_item_id, reply->objarray[ncnt].
      bill_item_desc = temp->objarray[d.seq].bill_item_desc, reply->objarray[ncnt].
      bill_item_type_flag = temp->objarray[d.seq].bill_item_type_flag,
      reply->objarray[ncnt].beg_effective_dt_tm = temp->objarray[d.seq].beg_effective_dt_tm, reply->
      objarray[ncnt].end_effective_dt_tm = temp->objarray[d.seq].end_effective_dt_tm, reply->
      objarray[ncnt].price = temp->objarray[d.seq].price,
      reply->objarray[ncnt].price_interval_cd = temp->objarray[d.seq].price_interval_cd, reply->
      objarray[ncnt].price_interval_disp = temp->objarray[d.seq].price_interval_disp, reply->
      objarray[ncnt].price_interval_desc = temp->objarray[d.seq].price_interval_desc,
      reply->objarray[ncnt].price_interval_mean = temp->objarray[d.seq].price_interval_mean, reply->
      objarray[ncnt].activity_cd = temp->objarray[d.seq].activity_cd, reply->objarray[ncnt].
      activity_disp = temp->objarray[d.seq].activity_disp,
      reply->objarray[ncnt].activity_desc = temp->objarray[d.seq].activity_desc, reply->objarray[ncnt
      ].activity_mean = temp->objarray[d.seq].activity_mean, reply->objarray[ncnt].
      billing_discount_priority_seq = temp->objarray[d.seq].billing_discount_priority_seq,
      stat = alterlist(reply->objarray[ncnt].bill_code_sched,size(temp->objarray[d.seq].
        bill_code_sched,5))
      FOR (ncnt2 = 1 TO size(temp->objarray[d.seq].bill_code_sched,5))
        reply->objarray[ncnt].bill_code_sched[ncnt2].bill_code_sched_type = temp->objarray[d.seq].
        bill_code_sched[ncnt2].bill_code_sched_type, reply->objarray[ncnt].bill_code_sched[ncnt2].
        bill_code_sched_disp = temp->objarray[d.seq].bill_code_sched[ncnt2].bill_code_sched_disp,
        reply->objarray[ncnt].bill_code_sched[ncnt2].bill_code_sched_cd = temp->objarray[d.seq].
        bill_code_sched[ncnt2].bill_code_sched_cd,
        reply->objarray[ncnt].bill_code_sched[ncnt2].bill_code_sched_value = temp->objarray[d.seq].
        bill_code_sched[ncnt2].bill_code_sched_value, reply->objarray[ncnt].bill_code_sched[ncnt2].
        bill_code_sched_desc = temp->objarray[d.seq].bill_code_sched[ncnt2].bill_code_sched_desc
      ENDFOR
     DETAIL
      ncnt = ncnt
     FOOT  head_bill_item_id
      ncnt = ncnt
     FOOT REPORT
      stat = alterlist(reply->objarray,ncnt)
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE subchkinvalid(dummy)
   IF (size(reply->objarray,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(reply->objarray,5)),
      price_sched_items psi
     PLAN (d)
      JOIN (psi
      WHERE ((psi.bill_item_id+ 0)=reply->objarray[d.seq].bill_item_id)
       AND (psi.price_sched_id=reply->objarray[d.seq].price_sched_id)
       AND psi.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND psi.active_ind=1)
     ORDER BY psi.bill_item_id, psi.price_sched_id, cnvtdatetime(psi.beg_effective_dt_tm)
     HEAD psi.bill_item_id
      dprice_sched_id = psi.price_sched_id, nfound = 0
     HEAD psi.price_sched_items_id
      IF (psi.price_sched_id=dprice_sched_id)
       nfound = (nfound+ 1)
      ENDIF
      IF (nfound > 1)
       reply->objarray[d.seq].invalid = 1
      ENDIF
     DETAIL
      nfound = nfound
     FOOT  psi.price_sched_items_id
      nfound = nfound
     FOOT  psi.bill_item_id
      nfound = nfound
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE subgetpriceinterval(dummy)
   IF (size(reply->objarray,5) > 0)
    SET ncnt = 0
    SELECT INTO "nl:"
     head_bill_item_id = reply->objarray[d.seq].bill_item_id
     FROM (dummyt d  WITH seq = size(reply->objarray,5)),
      item_interval_table it,
      interval_table i,
      bill_item_modifier bim
     PLAN (d
      WHERE (reply->objarray[d.seq].price_interval_cd != 0.0))
      JOIN (i
      WHERE (i.interval_template_cd=reply->objarray[d.seq].price_interval_cd)
       AND i.active_ind=1)
      JOIN (it
      WHERE (it.parent_entity_id=reply->objarray[d.seq].price_sched_item_id)
       AND it.interval_template_cd=i.interval_template_cd
       AND it.interval_id=i.interval_id
       AND it.active_ind=1)
      JOIN (bim
      WHERE bim.bill_item_id=outerjoin(reply->objarray[d.seq].bill_item_id)
       AND bim.key2_id=outerjoin(it.item_interval_id)
       AND bim.active_ind=outerjoin(1)
       AND bim.bill_item_type_cd=outerjoin(13019_intervalcode))
     ORDER BY head_bill_item_id, i.beg_value, it.item_interval_id
     HEAD head_bill_item_id
      ncnt = 0
     HEAD it.item_interval_id
      ncnt3 = 0, ncnt = (ncnt+ 1), stat = alterlist(reply->objarray[d.seq].interval_qual,ncnt),
      reply->objarray[d.seq].interval_qual[ncnt].interval_id = i.interval_id, reply->objarray[d.seq].
      interval_qual[ncnt].beg_value = i.beg_value, reply->objarray[d.seq].interval_qual[ncnt].
      end_value = i.end_value,
      reply->objarray[d.seq].interval_qual[ncnt].unit_type_cd = i.unit_type_cd, reply->objarray[d.seq
      ].interval_qual[ncnt].unit_type_disp = trim(uar_get_code_display(i.unit_type_cd)), reply->
      objarray[d.seq].interval_qual[ncnt].unit_type_desc = trim(uar_get_code_description(i
        .unit_type_cd)),
      reply->objarray[d.seq].interval_qual[ncnt].unit_type_mean = trim(uar_get_code_meaning(i
        .unit_type_cd)), reply->objarray[d.seq].interval_qual[ncnt].calc_type_cd = i.calc_type_cd,
      reply->objarray[d.seq].interval_qual[ncnt].calc_type_disp = trim(uar_get_code_display(i
        .calc_type_cd)),
      reply->objarray[d.seq].interval_qual[ncnt].calc_type_desc = trim(uar_get_code_description(i
        .calc_type_cd)), reply->objarray[d.seq].interval_qual[ncnt].calc_type_mean = trim(
       uar_get_code_meaning(i.calc_type_cd)), reply->objarray[d.seq].interval_qual[ncnt].
      item_interval_id = it.item_interval_id,
      reply->objarray[d.seq].interval_qual[ncnt].price = it.price, reply->objarray[d.seq].
      interval_qual[ncnt].interval_template_cd = it.interval_template_cd, reply->objarray[d.seq].
      interval_qual[ncnt].interval_template_disp = trim(uar_get_code_display(it.interval_template_cd)
       ),
      reply->objarray[d.seq].interval_qual[ncnt].interval_template_desc = trim(
       uar_get_code_description(it.interval_template_cd)), reply->objarray[d.seq].interval_qual[ncnt]
      .interval_template_mean = trim(uar_get_code_meaning(it.interval_template_cd)), reply->objarray[
      d.seq].interval_qual[ncnt].parent_entity_id = it.parent_entity_id
     DETAIL
      IF (bim.bill_item_mod_id > 0.0)
       bcschedtype = trim(uar_get_code_meaning(cnvtreal(bim.key1_id)))
       IF (bcschedtype IN ("CPT4", "HCPCS", "PROCCODE", "CDM_SCHED", "MODIFIER"))
        ncnt3 = (ncnt3+ 1), stat = alterlist(reply->objarray[d.seq].interval_qual[ncnt].
         bill_code_sched,ncnt3), reply->objarray[d.seq].interval_qual[ncnt].bill_code_sched[ncnt3].
        bill_code_sched_type = trim(uar_get_code_meaning(cnvtreal(bim.key1_id))),
        reply->objarray[d.seq].interval_qual[ncnt].bill_code_sched[ncnt3].bill_code_sched_disp = trim
        (uar_get_code_display(cnvtreal(bim.key1_id))), reply->objarray[d.seq].interval_qual[ncnt].
        bill_code_sched[ncnt3].bill_code_sched_cd = bim.key1_id, reply->objarray[d.seq].
        interval_qual[ncnt].bill_code_sched[ncnt3].bill_code_sched_desc = trim(bim.key7),
        reply->objarray[d.seq].interval_qual[ncnt].bill_code_sched[ncnt3].bill_code_sched_value =
        trim(bim.key6)
        IF (bcschedtype="MODIFIER")
         reply->objarray[d.seq].interval_qual[ncnt].bill_code_sched[ncnt3].bill_code_sched_value =
         trim(uar_get_code_display(cnvtreal(bim.key5_id))), reply->objarray[d.seq].interval_qual[ncnt
         ].bill_code_sched[ncnt3].key5_id = bim.key5_id
        ELSEIF (bcschedtype IN ("CPT4", "HCPCS", "PROCCODE"))
         reply->objarray[d.seq].interval_qual[ncnt].bill_code_sched[ncnt3].nomen_id = bim.key3_id
        ENDIF
       ENDIF
      ENDIF
     FOOT  head_bill_item_id
      ncnt = ncnt
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE subgetbilltype(dummy)
   IF (size(reply->objarray,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(reply->objarray,5)),
      bill_item bi,
      bill_item bi2
     PLAN (d)
      JOIN (bi
      WHERE (bi.bill_item_id=reply->objarray[d.seq].bill_item_id)
       AND bi.ext_parent_reference_id > 0.0
       AND bi.ext_child_reference_id=0.0)
      JOIN (bi2
      WHERE bi2.ext_parent_reference_id=bi.ext_parent_reference_id
       AND bi2.ext_parent_contributor_cd=ordcat_13016
       AND bi2.ext_child_reference_id != 0.0
       AND bi2.ext_child_contributor_cd=ordcat_13016)
     DETAIL
      IF (bi2.bill_item_id > 0.0)
       reply->objarray[d.seq].bill_item_type_flag = 5
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(reply->objarray,5)),
      bill_item bi,
      bill_item bi2
     PLAN (d)
      JOIN (bi
      WHERE (bi.bill_item_id=reply->objarray[d.seq].bill_item_id)
       AND bi.ext_parent_reference_id > 0.0
       AND bi.ext_child_reference_id > 0.0)
      JOIN (bi2
      WHERE bi2.ext_parent_reference_id=bi.ext_parent_reference_id
       AND bi2.ext_parent_contributor_cd=ordcat_13016
       AND bi2.ext_child_reference_id != 0.0
       AND bi2.ext_child_contributor_cd=ordcat_13016)
     DETAIL
      IF (bi2.bill_item_id > 0.0)
       reply->objarray[d.seq].bill_item_type_flag = 6
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE subrequery(dummy)
   CALL echo("subrequery")
   SELECT INTO "nl:"
    head_bill_item_id = request->items[d.seq].bill_item_id
    FROM (dummyt d  WITH seq = size(request->items,5)),
     dummyt d2,
     price_sched_items psi
    PLAN (d)
     JOIN (d2)
     JOIN (psi
     WHERE ((psi.bill_item_id+ 0)=request->items[d.seq].bill_item_id)
      AND (psi.price_sched_id=request->price_sched_id)
      AND psi.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND psi.active_ind=1)
    ORDER BY psi.bill_item_id, psi.price_sched_id, cnvtdatetime(psi.beg_effective_dt_tm)
    HEAD REPORT
     ncnt = 0, nfound = 0, dprice_sched_id = 0,
     stat = alterlist(reply->items,size(request->items,5))
    HEAD head_bill_item_id
     ncnt = (ncnt+ 1), reply->items[ncnt].bill_item_id = head_bill_item_id, reply->items[ncnt].
     invalid = 0,
     dprice_sched_id = psi.price_sched_id, nfound = 0
    HEAD psi.price_sched_items_id
     IF (psi.price_sched_id=dprice_sched_id)
      nfound = (nfound+ 1)
     ENDIF
     IF (nfound > 1)
      reply->items[ncnt].invalid = 1
     ELSE
      IF (nfound=1
       AND psi.beg_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->items[ncnt].invalid = 1
      ENDIF
     ENDIF
    DETAIL
     nfound = nfound
    FOOT  psi.price_sched_items_id
     nfound = nfound
    FOOT  psi.bill_item_id
     nfound = nfound
    FOOT REPORT
     nfound = nfound
    WITH nocounter, outerjoin = d2, dontcare = psi
   ;end select
   IF (curqual=0)
    SET reply->status_data.subeventstatus.operationname = "INSERT"
    SET reply->status_data.subeventstatus.operationstatus = "F"
    SET reply->status_data.subeventstatus.targetobjectname = ""
    SET reply->status_data.subeventstatus.targetobjectvalue = concat(
     "AFC_RATESTRUCTURE_QUERY_GEN error in subroutine subrequery - ","curqual = 0")
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE subgetzeroprice1(dummy)
   SET ncnt = 0
   SET ncnt2 = 0
   SELECT
    IF (isbillitemsecurityon)
     FROM prsnl_org_reltn por,
      cs_org_reltn cor,
      bill_item bi,
      bill_item_modifier bim,
      price_sched_items psi
     PLAN (por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND por.active_ind=1)
      JOIN (cor
      WHERE cor.organization_id=por.organization_id
       AND cor.cs_org_reltn_type_cd=26078_bill_item
       AND cor.active_ind=1)
      JOIN (bi
      WHERE bi.bill_item_id=cor.key1_id
       AND (bi.ext_owner_cd=request->activity_cd)
       AND ((bi.bill_item_id+ 0) != 0.0)
       AND ((bi.active_ind+ 0)=1))
      JOIN (bim
      WHERE bim.bill_item_id=outerjoin(bi.bill_item_id)
       AND bim.bill_item_type_cd=outerjoin(billcode_13019)
       AND bim.bim1_int=outerjoin(1)
       AND bim.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND bim.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
       AND bim.active_ind=outerjoin(1))
      JOIN (psi
      WHERE psi.bill_item_id=outerjoin(bi.bill_item_id)
       AND psi.price_sched_id=outerjoin(request->price_sched_id)
       AND psi.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
       AND psi.active_ind=outerjoin(1))
    ELSE
     FROM bill_item bi,
      bill_item_modifier bim,
      price_sched_items psi
     PLAN (bi
      WHERE (bi.ext_owner_cd=request->activity_cd)
       AND ((bi.bill_item_id+ 0) != 0.0)
       AND ((bi.active_ind+ 0)=1))
      JOIN (bim
      WHERE bim.bill_item_id=outerjoin(bi.bill_item_id)
       AND bim.bill_item_type_cd=outerjoin(billcode_13019)
       AND bim.bim1_int=outerjoin(1)
       AND bim.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND bim.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
       AND bim.active_ind=outerjoin(1))
      JOIN (psi
      WHERE psi.bill_item_id=outerjoin(bi.bill_item_id)
       AND psi.price_sched_id=outerjoin(request->price_sched_id)
       AND psi.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
       AND psi.active_ind=outerjoin(1))
    ENDIF
    INTO "nl:"
    ORDER BY bi.ext_description, bi.bill_item_id, bim.bill_item_mod_id,
     cnvtdatetime(psi.beg_effective_dt_tm)
    HEAD REPORT
     ncnt = 0, ncnt2 = 0, stat = alterlist(reply->objarray,50)
    HEAD bi.bill_item_id
     ncnt = (ncnt+ 1)
     IF (mod(ncnt,50)=1
      AND ncnt > 1)
      stat = alterlist(reply->objarray,(ncnt+ 49))
     ENDIF
     IF (psi.price_sched_items_id != 0.0)
      reply->objarray[ncnt].price_sched_id = request->price_sched_id, reply->objarray[ncnt].invalid
       = 1, reply->objarray[ncnt].price_sched_item_id = psi.price_sched_items_id,
      reply->objarray[ncnt].beg_effective_dt_tm = cnvtdatetime(psi.beg_effective_dt_tm), reply->
      objarray[ncnt].end_effective_dt_tm = cnvtdatetime(psi.end_effective_dt_tm), reply->objarray[
      ncnt].price = psi.price,
      reply->objarray[ncnt].price_interval_cd = psi.interval_template_cd, reply->objarray[ncnt].
      price_interval_disp = trim(uar_get_code_display(psi.interval_template_cd)), reply->objarray[
      ncnt].price_interval_desc = trim(uar_get_code_description(psi.interval_template_cd)),
      reply->objarray[ncnt].price_interval_mean = trim(uar_get_code_meaning(psi.interval_template_cd)
       ), reply->objarray[ncnt].billing_discount_priority_seq = psi.billing_discount_priority_seq
     ELSE
      reply->objarray[ncnt].invalid = 0, reply->objarray[ncnt].price_sched_id = request->
      price_sched_id
     ENDIF
     reply->objarray[ncnt].bill_item_id = bi.bill_item_id, reply->objarray[ncnt].bill_item_desc =
     trim(bi.ext_description), reply->objarray[ncnt].bill_item_type_flag =
     IF (bi.ext_parent_reference_id > 0.0
      AND bi.ext_child_reference_id=0.0) 1
     ELSEIF (bi.ext_parent_reference_id > 0.0
      AND bi.ext_child_reference_id > 0.0) 2
     ELSEIF (bi.ext_parent_reference_id=0.0
      AND bi.ext_child_reference_id > 0.0) 3
     ELSE 99
     ENDIF
     ,
     reply->objarray[ncnt].bill_item_type_flag =
     IF (bi.ext_child_contributor_cd=alpharesp_13016) 4
     ELSE reply->objarray[ncnt].bill_item_type_flag
     ENDIF
     , reply->objarray[ncnt].activity_cd = bi.ext_owner_cd, reply->objarray[ncnt].activity_disp =
     trim(uar_get_code_display(bi.ext_owner_cd)),
     reply->objarray[ncnt].activity_desc = trim(uar_get_code_description(bi.ext_owner_cd)), reply->
     objarray[ncnt].activity_mean = trim(uar_get_code_meaning(bi.ext_owner_cd)), ncnt2 = 0
    HEAD bim.bill_item_mod_id
     IF (bim.bill_item_mod_id != 0.0)
      bcschedtype = trim(uar_get_code_meaning(cnvtreal(bim.key1_id)))
      IF (bcschedtype IN ("CPT4", "HCPCS", "REVENUE", "CDM_SCHED"))
       ncnt2 = (ncnt2+ 1), stat = alterlist(reply->objarray[ncnt].bill_code_sched,ncnt2), reply->
       objarray[ncnt].bill_code_sched[ncnt2].bill_code_sched_type = trim(uar_get_code_meaning(
         cnvtreal(bim.key1_id))),
       reply->objarray[ncnt].bill_code_sched[ncnt2].bill_code_sched_disp = trim(uar_get_code_display(
         cnvtreal(bim.key1_id))), reply->objarray[ncnt].bill_code_sched[ncnt2].bill_code_sched_cd =
       bim.key1_id, reply->objarray[ncnt].bill_code_sched[ncnt2].bill_code_sched_desc = trim(bim.key7
        ),
       reply->objarray[ncnt].bill_code_sched[ncnt2].bill_code_sched_value = trim(bim.key6)
       IF (bcschedtype="REVENUE")
        reply->objarray[ncnt].bill_code_sched[ncnt2].bill_code_sched_value = trim(
         uar_get_code_display(cnvtreal(bim.key5_id)))
       ENDIF
      ENDIF
     ENDIF
    FOOT  bim.bill_item_mod_id
     ncnt = ncnt
    FOOT  bi.bill_item_id
     ncnt = ncnt
    FOOT REPORT
     stat = alterlist(reply->objarray,ncnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE subuarerror(codeset,meaning)
   SET reply->status_data.subeventstatus.operationname = "FAILED"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   SET reply->status_data.subeventstatus.targetobjectname = "UAR"
   SET reply->status_data.subeventstatus.targetobjectvalue = concat(
    "AFC_RATESTRUCTURE_QUERY_GEN UAR call Code Set ",codeset," Meaning ",meaning)
 END ;Subroutine
 SUBROUTINE subgetchargepro1(dummy)
   SET ncnt = 0
   SET ncnt2 = 0
   SELECT
    IF (isbillitemsecurityon)
     FROM prsnl_org_reltn por,
      cs_org_reltn cor,
      bill_item bi,
      bill_item_modifier bim
     PLAN (por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND por.active_ind=1)
      JOIN (cor
      WHERE cor.organization_id=por.organization_id
       AND cor.cs_org_reltn_type_cd=26078_bill_item
       AND cor.active_ind=1)
      JOIN (bi
      WHERE bi.bill_item_id=cor.key1_id
       AND (bi.ext_owner_cd=request->activity_cd)
       AND ((bi.bill_item_id+ 0) != 0.0)
       AND ((bi.active_ind+ 0)=1))
      JOIN (bim
      WHERE bim.bill_item_id=outerjoin(bi.bill_item_id)
       AND bim.bill_item_type_cd=outerjoin(chargepoint_13019)
       AND bim.key1_id=outerjoin(request->charge_point_sched_cd)
       AND bim.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND bim.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
       AND bim.active_ind=outerjoin(1))
    ELSE
     FROM bill_item bi,
      bill_item_modifier bim
     PLAN (bi
      WHERE (bi.ext_owner_cd=request->activity_cd)
       AND ((bi.bill_item_id+ 0) != 0.0)
       AND ((bi.active_ind+ 0)=1))
      JOIN (bim
      WHERE bim.bill_item_id=outerjoin(bi.bill_item_id)
       AND bim.bill_item_type_cd=outerjoin(chargepoint_13019)
       AND bim.key1_id=outerjoin(request->charge_point_sched_cd)
       AND bim.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND bim.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
       AND bim.active_ind=outerjoin(1))
    ENDIF
    INTO "nl:"
    ORDER BY bi.ext_description, bi.bill_item_id
    HEAD REPORT
     ncnt = 0, ncnt2 = 0, stat = alterlist(reply->objarray,50)
    HEAD bi.bill_item_id
     ncnt = (ncnt+ 1)
     IF (mod(ncnt,50)=1
      AND ncnt > 1)
      stat = alterlist(reply->objarray,(ncnt+ 49))
     ENDIF
     reply->objarray[ncnt].invalid = 0, reply->objarray[ncnt].bill_item_id = bi.bill_item_id, reply->
     objarray[ncnt].bill_item_desc = trim(bi.ext_description),
     reply->objarray[ncnt].bill_item_type_flag =
     IF (bi.ext_parent_reference_id > 0.0
      AND bi.ext_child_reference_id=0.0) 1
     ELSEIF (bi.ext_parent_reference_id > 0.0
      AND bi.ext_child_reference_id > 0.0) 2
     ELSEIF (bi.ext_parent_reference_id=0.0
      AND bi.ext_child_reference_id > 0.0) 3
     ELSE 99
     ENDIF
     , reply->objarray[ncnt].bill_item_type_flag =
     IF (bi.ext_child_contributor_cd=alpharesp_13016) 4
     ELSE reply->objarray[ncnt].bill_item_type_flag
     ENDIF
     , reply->objarray[ncnt].activity_cd = bi.ext_owner_cd,
     reply->objarray[ncnt].activity_disp = trim(uar_get_code_display(bi.ext_owner_cd)), reply->
     objarray[ncnt].activity_desc = trim(uar_get_code_description(bi.ext_owner_cd)), reply->objarray[
     ncnt].activity_mean = trim(uar_get_code_meaning(bi.ext_owner_cd)),
     ncnt2 = 0
    DETAIL
     IF (bim.bill_item_mod_id > 0.0)
      reply->objarray[ncnt].bill_item_mod_id = bim.bill_item_mod_id, reply->objarray[ncnt].
      charge_point_sched_cd = bim.key1_id, reply->objarray[ncnt].charge_point_sched_disp = trim(
       uar_get_code_display(bim.key1_id)),
      reply->objarray[ncnt].charge_point_sched_desc = trim(uar_get_code_description(bim.key1_id)),
      reply->objarray[ncnt].charge_point_sched_mean = trim(uar_get_code_meaning(bim.key1_id)), reply
      ->objarray[ncnt].charge_point_cd = bim.key2_id,
      reply->objarray[ncnt].charge_point_disp = trim(uar_get_code_display(bim.key2_id)), reply->
      objarray[ncnt].charge_point_desc = trim(uar_get_code_description(bim.key2_id)), reply->
      objarray[ncnt].charge_point_mean = trim(uar_get_code_meaning(bim.key2_id)),
      reply->objarray[ncnt].charge_level_cd = bim.key4_id, reply->objarray[ncnt].charge_level_disp =
      trim(uar_get_code_display(bim.key4_id)), reply->objarray[ncnt].charge_level_desc = trim(
       uar_get_code_description(bim.key4_id)),
      reply->objarray[ncnt].charge_level_mean = trim(uar_get_code_meaning(bim.key4_id)), reply->
      objarray[ncnt].bim1_int = bim.bim1_int
     ENDIF
    FOOT  bi.bill_item_id
     ncnt = ncnt
    FOOT REPORT
     stat = alterlist(reply->objarray,ncnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE initializeorgsecbillschedlist(dummy)
   DECLARE ncpt4cnt1 = i4 WITH noconstant(0)
   DECLARE nhcpcscnt1 = i4 WITH noconstant(0)
   DECLARE nrevenuecnt1 = i4 WITH noconstant(0)
   SET stat = initrec(cpt)
   SET stat = initrec(hcpcs)
   SET stat = initrec(revenue)
   SELECT INTO "nl:"
    FROM prsnl_org_reltn por,
     cs_org_reltn cor
    PLAN (por
     WHERE (por.person_id=reqinfo->updt_id)
      AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND por.active_ind=1)
     JOIN (cor
     WHERE cor.organization_id=por.organization_id
      AND cor.cs_org_reltn_type_cd=26078_bc_sched
      AND cor.active_ind=1)
    ORDER BY cor.key1_id
    HEAD cor.key1_id
     CASE (trim(uar_get_code_meaning(cnvtreal(cor.key1_id))))
      OF "CPT4":
       ncpt4cnt1 = (ncpt4cnt1+ 1),stat = alterlist(cpt->arr,ncpt4cnt1),cpt->arr[ncpt4cnt1].code_value
        = cor.key1_id
      OF "HCPCS":
       nhcpcscnt1 = (nhcpcscnt1+ 1),stat = alterlist(hcpcs->arr,nhcpcscnt1),hcpcs->arr[nhcpcscnt1].
       code_value = cor.key1_id
      OF "REVENUE":
       nrevenuecnt1 = (nrevenuecnt1+ 1),stat = alterlist(revenue->arr,nrevenuecnt1),revenue->arr[
       nrevenuecnt1].code_value = cor.key1_id
     ENDCASE
    WITH nocounter
   ;end select
   RETURN(true)
 END ;Subroutine
 SUBROUTINE getorgsecuritypreference(dummy)
   FREE RECORD afc_dm_request
   RECORD afc_dm_request(
     1 info_name_qual = i2
     1 info[*]
       2 info_name = vc
     1 info_name = vc
   )
   FREE RECORD afc_dm_reply
   RECORD afc_dm_reply(
     1 dm_info_qual = i2
     1 dm_info[*]
       2 info_name = vc
       2 info_date = dq8
       2 info_char = vc
       2 info_number = f8
       2 info_long_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c15
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = vc
   )
   SET afc_dm_request->info_name_qual = 1
   SET stat = alterlist(afc_dm_request->info,2)
   SET afc_dm_request->info[1].info_name = "BILL ITEM SECURITY"
   SET afc_dm_request->info[2].info_name = "BILL CODE SCHED SECURITY"
   EXECUTE afc_get_dm_info  WITH replace("REQUEST",afc_dm_request), replace("REPLY",afc_dm_reply)
   IF ((afc_dm_reply->status_data.status="S"))
    IF (cnvtupper(afc_dm_reply->dm_info[1].info_char)="Y")
     SET isbillitemsecurityon = true
    ENDIF
    IF (cnvtupper(afc_dm_reply->dm_info[2].info_char)="Y")
     SET isbillcodeschedsecurityon = true
    ENDIF
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE initializebillschedlist(dummy)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE iret = i4 WITH noconstant(0)
   DECLARE cpt_sched_value = f8 WITH noconstant(0.0)
   DECLARE hcpcs_sched_value = f8 WITH noconstant(0.0)
   DECLARE revenue_sched_value = f8 WITH noconstant(0.0)
   DECLARE ncpt4cnt1 = i4 WITH noconstant(1)
   DECLARE ncpt4cnt2 = i4 WITH noconstant(2)
   DECLARE nhcpcscnt1 = i4 WITH noconstant(1)
   DECLARE nhcpcscnt2 = i4 WITH noconstant(2)
   DECLARE nrevenuecnt1 = i4 WITH noconstant(1)
   DECLARE nrevenuecnt2 = i4 WITH noconstant(2)
   SET iret = uar_get_meaning_by_codeset(14002,"CPT4",ncpt4cnt1,cpt_sched_value)
   IF (iret=0)
    IF (ncpt4cnt1 > 0)
     SET stat = alterlist(cpt->arr,ncpt4cnt1)
     SET cpt->arr[1].code_value = cpt_sched_value
    ENDIF
   ELSE
    CALL subuarerror("14002","CPT4")
    GO TO end_program
   ENDIF
   IF (ncpt4cnt1 > 1)
    FOR (ncpt4cnt2 = 2 TO ncpt4cnt1)
      SET i = ncpt4cnt2
      SET iret = uar_get_meaning_by_codeset(14002,"CPT4",i,cpt_sched_value)
      IF (iret=0)
       SET cpt->arr[ncpt4cnt2].code_value = cpt_sched_value
      ELSE
       CALL subuarerror("14002","CPT4")
       GO TO end_program
      ENDIF
    ENDFOR
   ENDIF
   SET iret = uar_get_meaning_by_codeset(14002,"HCPCS",nhcpcscnt1,hcpcs_sched_value)
   IF (iret=0)
    IF (nhcpcscnt1 > 0)
     SET stat = alterlist(hcpcs->arr,nhcpcscnt1)
     SET hcpcs->arr[1].code_value = hcpcs_sched_value
    ENDIF
   ELSE
    CALL subuarerror("14002","HCPCS")
    GO TO end_program
   ENDIF
   IF (nhcpcscnt1 > 1)
    FOR (nhcpcscnt2 = 2 TO nhcpcscnt1)
      SET i = nhcpcscnt2
      SET iret = uar_get_meaning_by_codeset(14002,"HCPCS",i,hcpcs_sched_value)
      IF (iret=0)
       SET hcpcs->arr[nhcpcscnt2].code_value = hcpcs_sched_value
      ELSE
       CALL subuarerror("14002","HCPCS")
       GO TO end_program
      ENDIF
    ENDFOR
   ENDIF
   SET iret = uar_get_meaning_by_codeset(14002,"REVENUE",nrevenuecnt1,revenue_sched_value)
   IF (iret=0)
    IF (nrevenuecnt1 > 0)
     SET stat = alterlist(revenue->arr,nrevenuecnt1)
     SET revenue->arr[1].code_value = revenue_sched_value
    ENDIF
   ELSE
    CALL subuarerror("14002","REVENUE")
    GO TO end_program
   ENDIF
   IF (nrevenuecnt1 > 1)
    FOR (nrevenuecnt2 = 2 TO nrevenuecnt1)
      SET i = nrevenuecnt2
      SET iret = uar_get_meaning_by_codeset(14002,"REVENUE",i,revenue_sched_value)
      IF (iret=0)
       SET revenue->arr[nrevenuecnt2].code_value = revenue_sched_value
      ELSE
       CALL subuarerror("14002","REVENUE")
       GO TO end_program
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
#end_program
 IF (validate(debug,- (1)) > 0)
  CALL echo(concat("sparser_activity - ",sparser_activity))
  CALL echo(concat("sparser_price_interval - ",sparser_price_interval))
  CALL echo(concat("sparser_bill_item - ",sparser_bill_item))
  CALL echo(concat("sparser_bimtype - ",sparser_bimtype))
  CALL echorecord(request)
  CALL echorecord(reply)
  CALL echorecord(temp)
  CALL echorecord(cpt)
  CALL echorecord(hcpcs)
  CALL echorecord(revenue)
 ENDIF
 FREE RECORD temp
 FREE RECORD cpt
 FREE RECORD hcpcs
 FREE RECORD revenue
END GO
