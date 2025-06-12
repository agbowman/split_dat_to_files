CREATE PROGRAM bbt_get_fou_discard_return:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter the product number of re-received product" = "",
  "Select the product from the list" = 0
  WITH outdev, prodnum, productid
 SET modify = predeclare
 DECLARE retrievertsfordr(no_param=i2) = i2
 RECORD reply(
   1 destination_org_id = f8
   1 source_loc_cd = f8
   1 execution_dt_tm = dq8
   1 product_list[*]
     2 product_id = f8
     2 product_nbr = vc
     2 product_type = vc
     2 pooled_product_ind = i2
     2 abo_cd = f8
     2 rh_cd = f8
     2 product_event_cd = f8
     2 dispose_reason_cd = f8
     2 wasted_dt_tm = dq8
     2 person_id = f8
     2 patient_age = i2
     2 sex_cd = f8
     2 product_event_id = f8
     2 product_cd = f8
     2 blood_component_ind = i2
     2 expire_dt_tm = dq8
     2 event_dt_tm = dq8
     2 quantity = i4
     2 reason_cd = f8
     2 location_txt = vc
     2 cur_inv_area_cd = f8
     2 contributor_system_cd = f8
     2 ship_org_id = f8
     2 person_abo_cd = f8
     2 person_rh_cd = f8
     2 person_name_full_formatted = vc
     2 product_type_ident = vc
     2 encounter_id = f8
     2 modified_product_id = f8
     2 interface_product_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 modeind = i2
 )
 SET reply->status_data.status = "F"
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE uar_error = vc WITH protect, noconstant("")
 DECLARE hreq = i4 WITH protect, noconstant(0)
 DECLARE hcqmstruct = i4 WITH protect, noconstant(0)
 DECLARE holist = i4 WITH protect, noconstant(0)
 DECLARE horec = i4 WITH protect, noconstant(0)
 DECLARE hmsg = i4 WITH protect, noconstant(0)
 DECLARE hmsgstruct = i4 WITH protect, noconstant(0)
 DECLARE hprod = i4 WITH protect, noconstant(0)
 DECLARE hpers = i4 WITH protect, noconstant(0)
 DECLARE htrig = i4 WITH protect, noconstant(0)
 DECLARE dqueueid = f8 WITH protect, noconstant(0.0)
 DECLARE nidx = i4 WITH protect, noconstant(0)
 DECLARE hmsg1202007 = i4 WITH protect, noconstant(0)
 DECLARE hreq1202007 = i4 WITH protect, noconstant(0)
 DECLARE hrep1202007 = i4 WITH protect, noconstant(0)
 DECLARE hstatus_data = i4 WITH protect, noconstant(0)
 DECLARE replystatus = vc WITH protect, noconstant("")
 DECLARE debugind = i2 WITH protect, noconstant(0)
 DECLARE debuglogfile = vc WITH protect, noconstant("bb_fate_log")
 DECLARE transferred_from_only = i2 WITH protect, noconstant(1)
 DECLARE prod_cnt = i4 WITH protect, noconstant(0)
 DECLARE product_count = i4 WITH protect, noconstant(0)
 SUBROUTINE (errorhandler(operationstatus=c1(value),targetobjectname=vc(value),targetobjectvalue=vc(
   value)) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = substring(1,25,
    targetobjectname)
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE (fsi1202007(no_param=i2) =i2)
   SET hmsg1202007 = uar_srvselectmessage(1202007)
   IF (hmsg1202007=0)
    CALL errorhandler("F","set hMsg1202007","hMsg1202007 returns 0")
   ENDIF
   SET hreq1202007 = uar_srvcreaterequest(hmsg1202007)
   IF (hreq1202007=0)
    CALL uar_srvdestroyinstance(hmsg1202007)
    CALL errorhandler("F","set hReq1202007","hReq1202007 returns 0")
   ENDIF
   SET hrep1202007 = uar_srvcreatereply(hmsg1202007)
   IF (hrep1202007=0)
    CALL uar_srvdestroyinstance(hmsg1202007)
    CALL uar_srvdestroyinstance(hreq1202007)
    CALL errorhandler("F","set hRep1202007","hRep1202007 returns 0")
   ENDIF
   FOR (nidx = 1 TO product_count)
     IF ((reply->product_list[nidx].pooled_product_ind != 1)
      AND size(trim(reply->product_list[nidx].product_type_ident)) > 0)
      SET hprod = uar_srvadditem(hreq1202007,"products")
      SET stat = uar_srvsetstring(hprod,"product_nbr",nullterm(reply->product_list[nidx].product_nbr)
       )
      SET stat = uar_srvsetstring(hprod,"product_type_identifier",nullterm(reply->product_list[nidx].
        product_type_ident))
      SET stat = uar_srvsetshort(hprod,"blood_component_ind",reply->product_list[nidx].
       blood_component_ind)
      SET stat = uar_srvsetdate(hprod,"expire_dt_tm",cnvtdatetime(reply->product_list[nidx].
        expire_dt_tm))
      IF (isreturntostockevent(reply->product_list[nidx].product_event_cd)=1)
       SET stat = uar_srvsetdouble(hprod,"product_event_cd",available_event_type_cd)
      ELSE
       SET stat = uar_srvsetdouble(hprod,"product_event_cd",reply->product_list[nidx].
        product_event_cd)
      ENDIF
      SET stat = uar_srvsetdate(hprod,"event_dt_tm",cnvtdatetime(reply->product_list[nidx].
        event_dt_tm))
      SET stat = uar_srvsetlong(hprod,"quantity",reply->product_list[nidx].quantity)
      SET stat = uar_srvsetdouble(hprod,"reason_cd",reply->product_list[nidx].reason_cd)
      SET stat = uar_srvsetstring(hprod,"location_txt",nullterm(reply->product_list[nidx].
        location_txt))
      SET stat = uar_srvsetdouble(hprod,"cur_inv_area_cd",reply->product_list[nidx].cur_inv_area_cd)
      SET stat = uar_srvsetdouble(hprod,"contributor_system_cd",reply->product_list[nidx].
       contributor_system_cd)
      SET stat = uar_srvsetdouble(hprod,"ship_org_id",reply->product_list[nidx].ship_org_id)
      IF ((reply->product_list[nidx].person_id > 0))
       SET hpers = uar_srvadditem(hprod,"persons")
       SET stat = uar_srvsetdouble(hpers,"person_id",reply->product_list[nidx].person_id)
       SET stat = uar_srvsetdouble(hpers,"encounter_id",reply->product_list[nidx].encounter_id)
       SET stat = uar_srvsetdouble(hpers,"abo_cd",reply->product_list[nidx].person_abo_cd)
       SET stat = uar_srvsetdouble(hpers,"rh_cd",reply->product_list[nidx].person_rh_cd)
      ENDIF
     ENDIF
   ENDFOR
   SET stat = uar_srvexecute(hmsg1202007,hreq1202007,hrep1202007)
   SET hstatus_data = uar_srvgetstruct(hrep1202007,"status_data")
   CALL uar_srvgetstring(hstatus_data,"status",replystatus,uar_srvgetstringlen(hstatus_data,"status")
    )
   IF (debugind=1)
    CALL uar_crmlogmessage(hreq1202007,"BBT_REQ_1202007.dat")
    CALL uar_crmlogmessage(hrep1202007,"BBT_REPLY_1202007.dat")
    CALL echorecord(request,debuglogfile,1)
    CALL echorecord(reply,debuglogfile,1)
    CALL echorecord(request)
    CALL echorecord(reply)
   ENDIF
   CALL uar_srvdestroyinstance(hreq1202007)
   CALL uar_srvdestroyinstance(hmsg1202007)
   CALL uar_srvdestroyinstance(hrep1202007)
   IF (replystatus="F")
    CALL errorhandler("F","FSI-Bloodet","Failure executing server step 1202007")
   ENDIF
 END ;Subroutine
 SUBROUTINE (isreturntostockevent(eventtypecd=f8) =i2)
   DECLARE ret = i2 WITH protect, noconstant(0)
   IF (eventtypecd < 0)
    SET ret = 1
   ENDIF
   RETURN(ret)
 END ;Subroutine
 SUBROUTINE (getpooledcomponents(no_param=i2) =i2)
   SELECT INTO "nl:"
    prd.product_id, prd.product_nbr, prd.product_sub_nbr,
    prd.pooled_product_ind, bp.supplier_prefix, bp.cur_abo_cd,
    bp.cur_rh_cd, bep.product_type_txt
    FROM (dummyt d1  WITH seq = value(size(reply->product_list,5))),
     product prd,
     blood_product bp,
     bb_edn_product bep,
     bb_edn_admin bea
    PLAN (d1
     WHERE (reply->product_list[d1.seq].pooled_product_ind=1))
     JOIN (prd
     WHERE (prd.pooled_product_id=reply->product_list[d1.seq].product_id))
     JOIN (bp
     WHERE bp.product_id=prd.product_id)
     JOIN (bep
     WHERE bep.product_id=bp.product_id)
     JOIN (bea
     WHERE (bea.bb_edn_admin_id= Outerjoin(bep.bb_edn_admin_id)) )
    HEAD REPORT
     row + 0
    DETAIL
     product_count += 1
     IF (product_count > size(reply->product_list,5))
      stat = alterlist(reply->product_list,(product_count+ 9))
     ENDIF
     reply->product_list[product_count].product_id = prd.product_id, reply->product_list[
     product_count].product_nbr = concat(trim(bp.supplier_prefix),trim(prd.product_nbr),trim(prd
       .product_sub_nbr))
     IF (size(trim(prd.product_nbr,3),1)=13
      AND substring(1,1,prd.product_nbr) != "!")
      reply->product_list[product_count].product_nbr = concat(reply->product_list[product_count].
       product_nbr,calculatecheckdigit(reply->product_list[product_count].product_nbr))
     ENDIF
     reply->product_list[product_count].pooled_product_ind = 0, reply->product_list[product_count].
     abo_cd = bp.cur_abo_cd, reply->product_list[product_count].rh_cd = bp.cur_rh_cd,
     reply->product_list[product_count].product_event_cd = reply->product_list[d1.seq].
     product_event_cd, reply->product_list[product_count].person_id = reply->product_list[d1.seq].
     person_id, reply->product_list[product_count].encounter_id = reply->product_list[d1.seq].
     encounter_id,
     reply->product_list[product_count].product_type = bep.product_type_txt
     IF ((reply->modeind=1))
      reply->product_list[product_count].product_type_ident = bep.product_type_ident, reply->
      product_list[product_count].contributor_system_cd = bea.contributor_system_cd, reply->
      product_list[product_count].product_cd = prd.product_cd
      IF (bep.expiration_dt_tm > 0.0)
       reply->product_list[product_count].expire_dt_tm = bep.expiration_dt_tm
      ELSE
       reply->product_list[product_count].expire_dt_tm = prd.cur_expire_dt_tm
      ENDIF
      reply->product_list[product_count].event_dt_tm = reply->product_list[d1.seq].event_dt_tm, reply
      ->product_list[product_count].person_name_full_formatted = reply->product_list[d1.seq].
      person_name_full_formatted, reply->product_list[product_count].person_abo_cd = reply->
      product_list[d1.seq].person_abo_cd,
      reply->product_list[product_count].person_rh_cd = reply->product_list[d1.seq].person_rh_cd,
      reply->product_list[product_count].quantity = reply->product_list[d1.seq].quantity, reply->
      product_list[product_count].reason_cd = reply->product_list[d1.seq].reason_cd,
      reply->product_list[product_count].cur_inv_area_cd = reply->product_list[d1.seq].
      cur_inv_area_cd, reply->product_list[product_count].location_txt = reply->product_list[d1.seq].
      location_txt, reply->product_list[product_count].ship_org_id = reply->product_list[d1.seq].
      ship_org_id,
      reply->product_list[product_count].blood_component_ind = reply->product_list[d1.seq].
      blood_component_ind
     ELSE
      reply->product_list[product_count].patient_age = reply->product_list[d1.seq].patient_age, reply
      ->product_list[product_count].sex_cd = reply->product_list[d1.seq].sex_cd, reply->product_list[
      product_count].dispose_reason_cd = reply->product_list[d1.seq].dispose_reason_cd,
      reply->product_list[product_count].wasted_dt_tm = reply->product_list[d1.seq].wasted_dt_tm
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->product_list,product_count)
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select pooled components",errmsg)
   ENDIF
 END ;Subroutine
 SUBROUTINE (writeoutputtofile(no_param=i2) =i2)
   EXECUTE cpm_create_file_name_logical "bb_get_fod_prods", "txt", "x"
   IF ((reply->modeind=1))
    SELECT INTO cpm_cfn_info->file_name_logical
     prod_number = substring(1,25,reply->product_list[d1.seq].product_nbr), prod_id = reply->
     product_list[d1.seq].product_id, product_type_ident = reply->product_list[d1.seq].
     product_type_ident,
     prod_event_cd = reply->product_list[d1.seq].product_event_cd, prod_event_disp = substring(1,15,
      uar_get_code_display(abs(reply->product_list[d1.seq].product_event_cd))), blood_component_ind
      = reply->product_list[d1.seq].blood_component_ind,
     expire_dt_tm = format(reply->product_list[d1.seq].expire_dt_tm,";;Q"), event_dt_tm = format(
      reply->product_list[d1.seq].event_dt_tm,";;Q"), reason_cd = reply->product_list[d1.seq].
     reason_cd,
     reason_disp = substring(1,25,uar_get_code_display(reply->product_list[d1.seq].reason_cd)),
     quantity = reply->product_list[d1.seq].quantity, location_txt = substring(1,25,reply->
      product_list[d1.seq].location_txt),
     cur_inv_area_cd = reply->product_list[d1.seq].cur_inv_area_cd, cur_inv_area_disp = substring(1,
      25,uar_get_code_display(reply->product_list[d1.seq].cur_inv_area_cd)), ship_org_id = reply->
     product_list[d1.seq].ship_org_id,
     ship_org_name = o.org_name, contributor_system_cd = reply->product_list[d1.seq].
     contributor_system_cd, contributor_system_disp = substring(1,15,uar_get_code_display(reply->
       product_list[d1.seq].contributor_system_cd)),
     person_id = reply->product_list[d1.seq].person_id, encounter_id = reply->product_list[d1.seq].
     encounter_id, person_name_full_formatted = substring(1,25,reply->product_list[d1.seq].
      person_name_full_formatted),
     person_abo_cd = reply->product_list[d1.seq].person_abo_cd, person_abo_disp = substring(1,10,
      uar_get_code_display(reply->product_list[d1.seq].person_abo_cd)), person_rh_cd = reply->
     product_list[d1.seq].person_rh_cd,
     person_rh_disp = substring(1,10,uar_get_code_display(reply->product_list[d1.seq].person_rh_cd)),
     prod_pooled_ind = reply->product_list[d1.seq].pooled_product_ind, edn_prod_type = substring(1,15,
      reply->product_list[d1.seq].product_type)
     FROM (dummyt d1  WITH seq = value(size(reply->product_list,5))),
      organization o
     PLAN (d1)
      JOIN (o
      WHERE (o.organization_id= Outerjoin(reply->product_list[d1.seq].ship_org_id)) )
     WITH format, format = pcformat
    ;end select
   ELSE
    SELECT INTO cpm_cfn_info->file_name_logical
     prod_number = substring(1,25,reply->product_list[d1.seq].product_nbr), prod_id = reply->
     product_list[d1.seq].product_id, prod_type = substring(1,15,reply->product_list[d1.seq].
      product_type),
     prod_event_cd = reply->product_list[d1.seq].product_event_cd, prod_event_disp = substring(1,15,
      uar_get_code_display(reply->product_list[d1.seq].product_event_cd)), prod_pooled_ind = reply->
     product_list[d1.seq].pooled_product_ind,
     prod_abo_cd = reply->product_list[d1.seq].abo_cd, prod_abo_disp = substring(1,10,
      uar_get_code_display(reply->product_list[d1.seq].abo_cd)), prod_rh_cd = reply->product_list[d1
     .seq].rh_cd,
     prod_rh_disp = substring(1,10,uar_get_code_display(reply->product_list[d1.seq].rh_cd)),
     prod_dispose_cd = reply->product_list[d1.seq].dispose_reason_cd, prod_dispose_disp = substring(1,
      20,uar_get_code_display(reply->product_list[d1.seq].dispose_reason_cd)),
     prod_wasted_dt_tm = format(reply->product_list[d1.seq].wasted_dt_tm,";;q"), person_id = reply->
     product_list[d1.seq].person_id, encounter_id = reply->product_list[d1.seq].encounter_id,
     person_age = reply->product_list[d1.seq].patient_age, person_sex_cd = reply->product_list[d1.seq
     ].sex_cd, person_sex_disp = substring(1,10,uar_get_code_display(reply->product_list[d1.seq].
       sex_cd))
     FROM (dummyt d1  WITH seq = value(size(reply->product_list,5)))
     ORDER BY prod_number, prod_id
     WITH format, format = pcformat
    ;end select
   ENDIF
   RETURN(0)
 END ;Subroutine
 DECLARE chartable[37] = c1 WITH protect, noconstant
 SET chartable[1] = "0"
 SET chartable[2] = "1"
 SET chartable[3] = "2"
 SET chartable[4] = "3"
 SET chartable[5] = "4"
 SET chartable[6] = "5"
 SET chartable[7] = "6"
 SET chartable[8] = "7"
 SET chartable[9] = "8"
 SET chartable[10] = "9"
 SET chartable[11] = "A"
 SET chartable[12] = "B"
 SET chartable[13] = "C"
 SET chartable[14] = "D"
 SET chartable[15] = "E"
 SET chartable[16] = "F"
 SET chartable[17] = "G"
 SET chartable[18] = "H"
 SET chartable[19] = "I"
 SET chartable[20] = "J"
 SET chartable[21] = "K"
 SET chartable[22] = "L"
 SET chartable[23] = "M"
 SET chartable[24] = "N"
 SET chartable[25] = "O"
 SET chartable[26] = "P"
 SET chartable[27] = "Q"
 SET chartable[28] = "R"
 SET chartable[29] = "S"
 SET chartable[30] = "T"
 SET chartable[31] = "U"
 SET chartable[32] = "V"
 SET chartable[33] = "W"
 SET chartable[34] = "X"
 SET chartable[35] = "Y"
 SET chartable[36] = "Z"
 SET chartable[37] = "*"
 SUBROUTINE (calculatecheckdigit(productnumber=vc(value)) =c1)
   DECLARE productnbrlen = i2 WITH protect, noconstant(0)
   DECLARE avgoffset = i2 WITH protect, noconstant(0)
   DECLARE idx = i2 WITH protect, noconstant(0)
   DECLARE offset = i2 WITH protect, noconstant(0)
   DECLARE digit = c1 WITH protect, noconstant(" ")
   SET productnbrlen = size(productnumber,1)
   FOR (idx = 1 TO productnbrlen)
     SET digit = substring(idx,1,productnumber)
     IF (isnumeric(digit)=1)
      SET offset = (ichar(digit) - ichar("0"))
     ELSE
      SET offset = ((ichar(digit) - ichar("A"))+ 10)
     ENDIF
     SET avgoffset = mod(((avgoffset+ offset) * 2),37)
   ENDFOR
   SET offset = (mod((38 - avgoffset),37)+ 1)
   RETURN(chartable[offset])
 END ;Subroutine
 DECLARE script_name = c26 WITH constant("bbt_get_fou_discard_return")
 DECLARE prd_typ = vc WITH protect, noconstant("XX")
 DECLARE pooledproductexistsind = i2 WITH protect, noconstant(0)
 DECLARE lastreceipteventid = f8 WITH protect, noconstant(0)
 DECLARE event_type_cs = i4 WITH protect, constant(1610)
 DECLARE available_event_type_mean = c12 WITH protect, constant("12")
 DECLARE available_event_type_cd = f8 WITH protect, noconstant(0.0)
 SET available_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(
   available_event_type_mean))
 IF (available_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    available_event_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET reply->modeind = 1
 CALL retrievelastreceipt(0)
 IF (curqual=0)
  GO TO exit_script
 ELSE
  CALL retrievertsfordiscardreturn(0)
 ENDIF
 IF (pooledproductexistsind=1)
  CALL getpooledcomponents(0)
 ENDIF
 CALL writeoutputtofile(0)
 CALL fsi1202007(0)
 SUBROUTINE (retrievelastreceipt(no_param=i2) =i2)
   SELECT INTO "nl:"
    p.product_nbr, pe.event_dt_tm, pe.product_event_id
    FROM product p,
     receipt r,
     product_event pe
    PLAN (p
     WHERE (p.product_id= $PRODUCTID))
     JOIN (pe
     WHERE pe.product_id=p.product_id)
     JOIN (r
     WHERE r.product_event_id=pe.product_event_id)
    ORDER BY pe.event_dt_tm DESC
    DETAIL
     lastreceipteventid = pe.product_event_id
    WITH nocounter, separator = " ", format,
     maxrec = 1
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select latest receive event(BN)",errmsg)
   ENDIF
 END ;Subroutine
 SUBROUTINE retrievertsfordiscardreturn(no_param)
   SELECT INTO "nl:"
    pe.event_type_cd, prd.product_id, prd.interface_product_id,
    pe.product_id, bep.product_id, prd.product_nbr,
    prd.product_sub_nbr, prd.pooled_product_ind, bp.supplier_prefix,
    bp.cur_abo_cd, bp.cur_rh_cd, bep.product_type_txt,
    ret_qty = r.orig_rcvd_qty, ret_dt_tm = pe.event_dt_tm
    FROM product_event pe,
     product prd,
     blood_product bp,
     bb_edn_product bep,
     bb_edn_admin eda,
     derivative de,
     receipt r
    PLAN (pe
     WHERE pe.product_event_id=lastreceipteventid)
     JOIN (prd
     WHERE prd.product_id=pe.product_id
      AND prd.pooled_product_id=0.0)
     JOIN (bep
     WHERE (bep.product_id= Outerjoin(evaluate2(
      IF (prd.interface_product_id > 0.0) prd.interface_product_id
      ELSEIF (prd.modified_product_id > 0) prd.modified_product_id
      ELSE prd.product_id
      ENDIF
      ))) )
     JOIN (eda
     WHERE (eda.bb_edn_admin_id= Outerjoin(bep.bb_edn_admin_id)) )
     JOIN (bp
     WHERE (bp.product_id= Outerjoin(prd.product_id)) )
     JOIN (de
     WHERE (de.product_id= Outerjoin(prd.product_id)) )
     JOIN (r
     WHERE r.product_event_id=pe.product_event_id)
    HEAD REPORT
     stat = alterlist(reply->product_list,1)
    DETAIL
     IF (de.product_id > 0.0)
      prd_typ = "DE"
     ELSEIF (bp.product_id > 0.0)
      prd_typ = "BP"
     ELSE
      prd_typ = "XX"
     ENDIF
     IF (((bep.product_id > 0.0) OR (prd.pooled_product_ind=1)) )
      product_count += 1, reply->product_list[1].product_event_id = pe.product_event_id, reply->
      product_list[1].product_id = prd.product_id,
      reply->product_list[1].product_nbr = concat(trim(bp.supplier_prefix),trim(prd.product_nbr),trim
       (prd.product_sub_nbr))
      IF (size(trim(prd.product_nbr,3),1)=13
       AND substring(1,1,prd.product_nbr) != "!"
       AND prd_typ="BP")
       reply->product_list[1].product_nbr = concat(reply->product_list[1].product_nbr,
        calculatecheckdigit(reply->product_list[1].product_nbr))
      ENDIF
      IF (prd.pooled_product_ind=1)
       pooledproductexistsind = 1
      ENDIF
      reply->product_list[1].pooled_product_ind = prd.pooled_product_ind, reply->product_list[1].
      product_type = bep.product_type_txt, reply->product_list[1].abo_cd = bp.cur_abo_cd,
      reply->product_list[1].rh_cd = bp.cur_rh_cd, reply->product_list[1].product_cd = prd.product_cd,
      reply->product_list[1].product_type_ident = bep.product_type_ident,
      reply->product_list[1].product_event_cd = - (pe.event_type_cd), reply->product_list[1].
      event_dt_tm = ret_dt_tm, reply->product_list[1].contributor_system_cd = eda
      .contributor_system_cd,
      reply->product_list[1].interface_product_id = prd.interface_product_id
      IF (bep.expiration_dt_tm > 0.0)
       reply->product_list[1].expire_dt_tm = bep.expiration_dt_tm
      ELSE
       reply->product_list[1].expire_dt_tm = prd.cur_expire_dt_tm
      ENDIF
      IF (prd_typ="DE")
       reply->product_list[1].quantity = ret_qty, reply->product_list[1].blood_component_ind = 0
      ELSEIF (prd_typ="BP")
       reply->product_list[1].quantity = 1, reply->product_list[1].blood_component_ind = 1
      ENDIF
      reply->product_list[1].cur_inv_area_cd = prd.cur_inv_area_cd
     ENDIF
    WITH nocounter, separator = " ", format
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select Discard Return(BN)",errmsg)
   ENDIF
 END ;Subroutine
 SUBROUTINE (printmessage(no_param=i2) =i2)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    IF ((reply->status_data.status="S"))
     col 0, " Fate sent successfully"
    ELSE
     col 0, "Fate could not be sent"
    ENDIF
   WITH nocounter
  ;end select
  RETURN(0)
 END ;Subroutine
#set_status
 IF (product_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL printmessage(0)
END GO
