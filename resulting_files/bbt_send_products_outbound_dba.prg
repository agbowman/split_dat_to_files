CREATE PROGRAM bbt_send_products_outbound:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD pat_prod_info
 RECORD pat_prod_info(
   1 products[*]
     2 product_id = f8
     2 product_nbr = vc
     2 prod_type_bc = vc
     2 expire_dt_tm = dq8
     2 unit_abo_cd = f8
     2 unit_rh_cd = f8
     2 donation_type = i2
     2 unit_volume = f8
     2 unit_leuko_ind = i2
     2 unit_cmv_neg_ind = i2
     2 unit_irr_ind = i2
     2 dereservation_dt_tm = dq8
     2 person_id = f8
     2 pat_abo_cd = f8
     2 pat_rh_cd = f8
     2 pat_leuko_ind = i2
     2 pat_cmv_neg_ind = i2
     2 pat_irr_ind = i2
     2 device_id = f8
     2 device_desc = vc
     2 org_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE nproductcnt = i4 WITH protect, noconstant(0)
 DECLARE nitem = i4 WITH protect, noconstant(0)
 DECLARE nidx = i4 WITH protect, noconstant(0)
 DECLARE scmv_neg = vc WITH protect, constant("CMV-")
 DECLARE sirradiated = vc WITH protect, constant("IRRADIATED")
 DECLARE sleuko = vc WITH protect, constant("RESLEU")
 DECLARE errorhandler(operationstatus=c1(value),targetobjectname=vc(value),targetobjectvalue=vc(value
   )) = null
 DECLARE get_patient_information(null) = null
 DECLARE get_product_information(null) = null
 DECLARE get_device_infomation(null) = null
 DECLARE write_message_to_file(null) = null
 DECLARE make_fsi_call_for_reserve_stock(null) = null
 DECLARE make_fsi_call_for_stock_update(null) = null
 DECLARE make_fsi_call_for_return_to_stock(null) = null
 DECLARE set_interface_flag_for_products(null) = null
 DECLARE nremoteallocationflag = i2 WITH protect, noconstant(0)
 DECLARE calculatecheckdigit(productnumber=vc(value)) = c1
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
 SUBROUTINE calculatecheckdigit(productnumber)
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
 SET nproductcnt = size(request->products,5)
 SET stat = alterlist(pat_prod_info->products,nproductcnt)
 CALL get_product_information(null)
 IF ((request->message_name="RS"))
  CALL get_patient_information(null)
 ENDIF
 CALL get_device_information(null)
 IF (validate(request->debug_ind,0) > 0)
  CALL write_message_to_file(null)
  CALL echorecord(pat_prod_info)
 ENDIF
 IF ((request->message_name="RS"))
  FOR (nidx = 1 TO nproductcnt)
    CALL make_fsi_call_for_reserve_stock(null)
  ENDFOR
 ELSEIF ((request->message_name="SU"))
  FOR (nidx = 1 TO nproductcnt)
    CALL make_fsi_call_for_stock_update(null)
  ENDFOR
 ELSEIF ((request->message_name="RTS"))
  FOR (nidx = 1 TO nproductcnt)
    CALL make_fsi_call_for_return_to_stock(null)
  ENDFOR
 ENDIF
 IF ((((request->message_name="SU")) OR ((request->message_name="RS"))) )
  CALL set_interface_flag_for_products(null)
 ENDIF
 GO TO set_status
 SUBROUTINE set_interface_flag_for_products(null)
   UPDATE  FROM product p,
     (dummyt d  WITH seq = value(nproductcnt))
    SET p.interfaced_device_flag = 1
    PLAN (d)
     JOIN (p
     WHERE (p.product_id=request->products[d.seq].product_id))
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE get_patient_information(null)
  DECLARE expand_idx = i4 WITH protect, noconstant(0)
  SELECT
   p.person_id, pa.abo_cd, pa.rh_cd,
   c.crossmatch_exp_dt_tm, st_mean = uar_get_code_meaning(trr.special_testing_cd)
   FROM (dummyt d  WITH seq = value(nproductcnt)),
    person p,
    person_aborh pa,
    crossmatch c,
    person_trans_req ptr,
    trans_req_r trr,
    bb_isbt_attribute_r biar,
    bb_isbt_attribute bia
   PLAN (d)
    JOIN (p
    WHERE (request->products[d.seq].person_id=p.person_id))
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND pa.active_ind=1)
    JOIN (c
    WHERE c.person_id=outerjoin(p.person_id)
     AND c.product_id=outerjoin(request->products[d.seq].product_id)
     AND c.active_ind=outerjoin(1))
    JOIN (ptr
    WHERE ptr.person_id=outerjoin(p.person_id)
     AND ptr.active_ind=outerjoin(1))
    JOIN (trr
    WHERE trr.requirement_cd=outerjoin(ptr.requirement_cd)
     AND trr.active_ind=outerjoin(1))
    JOIN (biar
    WHERE biar.attribute_cd=outerjoin(trr.special_testing_cd)
     AND biar.active_ind=outerjoin(1))
    JOIN (bia
    WHERE bia.bb_isbt_attribute_id=outerjoin(biar.bb_isbt_attribute_id)
     AND bia.active_ind=outerjoin(1))
   ORDER BY d.seq, c.product_event_id, trr.special_testing_cd
   HEAD d.seq
    pat_prod_info->products[d.seq].person_id = p.person_id, pat_prod_info->products[d.seq].pat_abo_cd
     = pa.abo_cd, pat_prod_info->products[d.seq].pat_rh_cd = pa.rh_cd
   HEAD c.product_event_id
    IF (c.product_event_id > 0)
     pat_prod_info->products[d.seq].dereservation_dt_tm = c.crossmatch_exp_dt_tm
    ENDIF
   HEAD trr.special_testing_cd
    IF (trr.special_testing_cd > 0)
     IF (cnvtupper(substring(1,4,bia.standard_display))=scmv_neg)
      pat_prod_info->products[d.seq].pat_cmv_neg_ind = 1
     ELSEIF (cnvtupper(substring(1,10,bia.standard_display))=sirradiated)
      pat_prod_info->products[d.seq].pat_irr_ind = 1
     ELSEIF (cnvtupper(substring(1,6,bia.standard_display))=sleuko)
      pat_prod_info->products[d.seq].pat_leuko_ind = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE get_product_information(null)
  DECLARE expand_idx = i4 WITH protect, noconstant(0)
  SELECT
   p.product_nbr, p.product_type_barcode, p.cur_expire_dt_tm,
   bp.cur_abo_cd, bp.cur_rh_cd, bp.cur_volume,
   pi.autologous_ind, pi.directed_ind, st_mean = uar_get_code_meaning(st.special_testing_cd),
   l.organization_id
   FROM (dummyt d  WITH seq = value(nproductcnt)),
    product p,
    blood_product bp,
    product_index pi,
    special_testing st,
    bb_isbt_attribute_r biar,
    bb_isbt_attribute bia,
    location l
   PLAN (d)
    JOIN (p
    WHERE (request->products[d.seq].product_id=p.product_id))
    JOIN (bp
    WHERE bp.product_id=p.product_id)
    JOIN (pi
    WHERE pi.product_cd=p.product_cd)
    JOIN (st
    WHERE st.product_id=outerjoin(p.product_id)
     AND st.active_ind=outerjoin(1))
    JOIN (biar
    WHERE biar.attribute_cd=outerjoin(st.special_testing_cd)
     AND biar.active_ind=outerjoin(1))
    JOIN (bia
    WHERE bia.bb_isbt_attribute_id=outerjoin(biar.bb_isbt_attribute_id)
     AND bia.active_ind=outerjoin(1))
    JOIN (l
    WHERE l.location_cd=outerjoin(p.cur_inv_area_cd))
   ORDER BY d.seq, st.special_testing_cd
   HEAD d.seq
    pat_prod_info->products[d.seq].product_id = p.product_id, pat_prod_info->products[d.seq].
    product_nbr = p.product_nbr, pat_prod_info->products[d.seq].prod_type_bc = p.product_type_barcode,
    pat_prod_info->products[d.seq].expire_dt_tm = p.cur_expire_dt_tm, pat_prod_info->products[d.seq].
    dereservation_dt_tm = p.cur_expire_dt_tm, pat_prod_info->products[d.seq].unit_abo_cd = bp
    .cur_abo_cd,
    pat_prod_info->products[d.seq].unit_rh_cd = bp.cur_rh_cd, pat_prod_info->products[d.seq].
    unit_volume = bp.cur_volume, pat_prod_info->products[d.seq].org_id = l.organization_id
    IF (pi.autologous_ind > 0)
     pat_prod_info->products[d.seq].donation_type = 2
    ELSEIF (pi.directed_ind > 0)
     pat_prod_info->products[d.seq].donation_type = 3
    ENDIF
   HEAD st.special_testing_cd
    IF (st_mean != "+"
     AND st.special_testing_cd > 0)
     IF (cnvtupper(substring(1,4,bia.standard_display))=scmv_neg)
      pat_prod_info->products[d.seq].unit_cmv_neg_ind = 1
     ELSEIF (cnvtupper(substring(1,10,bia.standard_display))=sirradiated)
      pat_prod_info->products[d.seq].unit_irr_ind = 1
     ELSEIF (cnvtupper(substring(1,6,bia.standard_display))=sleuko)
      pat_prod_info->products[d.seq].unit_leuko_ind = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE get_device_information(null)
  DECLARE expand_idx = i4 WITH protect, noconstant(0)
  SELECT
   bbid.description
   FROM (dummyt d  WITH seq = value(nproductcnt)),
    bb_inv_device bbid
   PLAN (d)
    JOIN (bbid
    WHERE (request->products[d.seq].device_id=bbid.bb_inv_device_id))
   ORDER BY d.seq
   HEAD d.seq
    pat_prod_info->products[d.seq].device_id = bbid.bb_inv_device_id, pat_prod_info->products[d.seq].
    device_desc = bbid.description
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE write_message_to_file(null)
  EXECUTE cpm_create_file_name_logical "bbt_send_prods_out", "txt", "x"
  SELECT INTO cpm_cfn_info->file_name_logical
   prod_number = substring(1,25,pat_prod_info->products[d1.seq].product_nbr), prod_id = pat_prod_info
   ->products[d1.seq].product_id, prod_type_barcode = pat_prod_info->products[d1.seq].prod_type_bc,
   donation_type = pat_prod_info->products[d1.seq].donation_type, unit_volume = pat_prod_info->
   products[d1.seq].unit_volume, prod_abo_cd = pat_prod_info->products[d1.seq].unit_abo_cd,
   prod_abo_disp = substring(1,10,uar_get_code_display(pat_prod_info->products[d1.seq].unit_abo_cd)),
   prod_rh_cd = pat_prod_info->products[d1.seq].unit_rh_cd, prod_rh_disp = substring(1,10,
    uar_get_code_display(pat_prod_info->products[d1.seq].unit_rh_cd)),
   prod_leuko_ind = pat_prod_info->products[d1.seq].unit_leuko_ind, prod_irr_ind = pat_prod_info->
   products[d1.seq].unit_irr_ind, prod_cmv_neg_ind = pat_prod_info->products[d1.seq].unit_cmv_neg_ind,
   person_id = pat_prod_info->products[d1.seq].person_id, pat_abo_cd = pat_prod_info->products[d1.seq
   ].pat_abo_cd, pat_abo_disp = substring(1,10,uar_get_code_display(pat_prod_info->products[d1.seq].
     pat_abo_cd)),
   pat_rh_cd = pat_prod_info->products[d1.seq].pat_rh_cd, pat_rh_disp = substring(1,10,
    uar_get_code_display(pat_prod_info->products[d1.seq].pat_rh_cd)), pat_leuko_ind = pat_prod_info->
   products[d1.seq].pat_leuko_ind,
   pat_irr_ind = pat_prod_info->products[d1.seq].pat_irr_ind, pat_cmv_neg_ind = pat_prod_info->
   products[d1.seq].pat_cmv_neg_ind, device_id = pat_prod_info->products[d1.seq].device_id,
   device_desc = substring(1,10,pat_prod_info->products[d1.seq].device_desc), expire_dt_tm = format(
    pat_prod_info->products[d1.seq].expire_dt_tm,";;Q"), dereservation_dt_tm = format(pat_prod_info->
    products[d1.seq].dereservation_dt_tm,";;Q"),
   org_id = pat_prod_info->products[d1.seq].org_id
   FROM (dummyt d1  WITH seq = value(size(pat_prod_info->products,5)))
   WITH format, format = pcformat
  ;end select
 END ;Subroutine
 SUBROUTINE errorhandler(operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
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
 SUBROUTINE make_fsi_call_for_reserve_stock(null)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hcqmstruct = i4 WITH protect, noconstant(0)
   DECLARE holist = i4 WITH protect, noconstant(0)
   DECLARE horec = i4 WITH protect, noconstant(0)
   DECLARE hmsg = i4 WITH protect, noconstant(0)
   DECLARE hmsgstruct = i4 WITH protect, noconstant(0)
   DECLARE htrig = i4 WITH protect, noconstant(0)
   DECLARE hprod = i4 WITH protect, noconstant(0)
   DECLARE hpat = i4 WITH protect, noconstant(0)
   DECLARE dqueueid = f8 WITH protect, noconstant(0.0)
   DECLARE prodnbr = vc WITH protect, noconstant("")
   EXECUTE si_esocallsrtl
   SET hmsg = uar_srvselectmessage(1215066)
   SET hreq = uar_srvcreaterequest(hmsg)
   SET hmsgstruct = uar_srvgetstruct(hreq,"message")
   SET hcqmstruct = uar_srvgetstruct(hmsgstruct,"CQMInfo")
   SET stat = uar_srvsetstring(hcqmstruct,"AppName",nullterm("FSIESO"))
   SET stat = uar_srvsetstring(hcqmstruct,"ContribAlias",nullterm("PATHNET_BB"))
   SET stat = uar_srvsetstring(hcqmstruct,"ContribRefnum",nullterm(concat(format(cnvtdatetime(curdate,
        curtime3),";;q")," ",request->message_name)))
   SET stat = uar_srvsetdate(hcqmstruct,"ContribDtTm",cnvtdatetime(curdate,curtime3))
   SET stat = uar_srvsetlong(hcqmstruct,"Priority",99)
   SET stat = uar_srvsetstring(hcqmstruct,"Class",nullterm("BB"))
   SET stat = uar_srvsetstring(hcqmstruct,"Type",nullterm("BLOODTRACK"))
   SET stat = uar_srvsetstring(hcqmstruct,"Subtype",nullterm(request->message_name))
   SET stat = uar_srvsetstring(hcqmstruct,"Subtype_Detail",nullterm(""))
   SET stat = uar_srvsetlong(hcqmstruct,"Debug_Ind",0)
   SET stat = uar_srvsetlong(hcqmstruct,"Verbosity_Flag",0)
   SET htrig = uar_srvadditem(hmsgstruct,"TRIGInfo")
   SET stat = uar_srvsetdouble(htrig,"organization_id",pat_prod_info->products[nidx].org_id)
   SET hprod = uar_srvgetstruct(htrig,"blood_unit")
   IF (size(trim(pat_prod_info->products[nidx].product_nbr))=13)
    IF (substring(1,1,pat_prod_info->products[nidx].product_nbr)="!")
     SET prodnbr = pat_prod_info->products[nidx].product_nbr
    ELSE
     SET prodnbr = concat(pat_prod_info->products[nidx].product_nbr,calculatecheckdigit(pat_prod_info
       ->products[nidx].product_nbr))
    ENDIF
   ELSE
    SET prodnbr = pat_prod_info->products[nidx].product_nbr
   ENDIF
   SET stat = uar_srvsetstring(hprod,"unit_number",nullterm(prodnbr))
   SET stat = uar_srvsetstring(hprod,"unit_product_code",nullterm(pat_prod_info->products[nidx].
     prod_type_bc))
   SET stat = uar_srvsetstring(hprod,"storage_location",nullterm(pat_prod_info->products[nidx].
     device_desc))
   SET stat = uar_srvsetdate(hprod,"expiry_dt_tm",cnvtdatetime(pat_prod_info->products[nidx].
     expire_dt_tm))
   SET stat = uar_srvsetdouble(hprod,"abo_cd",pat_prod_info->products[nidx].unit_abo_cd)
   SET stat = uar_srvsetdouble(hprod,"rh_cd",pat_prod_info->products[nidx].unit_rh_cd)
   SET stat = uar_srvsetshort(hprod,"donation_type_flag",pat_prod_info->products[nidx].donation_type)
   SET stat = uar_srvsetdouble(hprod,"volume",pat_prod_info->products[nidx].unit_volume)
   SET stat = uar_srvsetshort(hprod,"leukoreduced_ind",pat_prod_info->products[nidx].unit_leuko_ind)
   SET stat = uar_srvsetshort(hprod,"cmv_negative_ind",pat_prod_info->products[nidx].unit_cmv_neg_ind
    )
   SET stat = uar_srvsetshort(hprod,"irradiated_ind",pat_prod_info->products[nidx].unit_irr_ind)
   SET hpat = uar_srvgetstruct(htrig,"patient")
   SET stat = uar_srvsetdouble(hpat,"person_id",pat_prod_info->products[nidx].person_id)
   SET stat = uar_srvsetdouble(hpat,"abo_cd",pat_prod_info->products[nidx].pat_abo_cd)
   SET stat = uar_srvsetdouble(hpat,"rh_cd",pat_prod_info->products[nidx].pat_rh_cd)
   SET stat = uar_srvsetdate(hpat,"dereservation_dt_tm",cnvtdatetime(pat_prod_info->products[nidx].
     dereservation_dt_tm))
   SET stat = uar_srvsetshort(hpat,"leukoreduced_ind",pat_prod_info->products[nidx].pat_leuko_ind)
   SET stat = uar_srvsetshort(hpat,"cmv_negative_ind",pat_prod_info->products[nidx].pat_cmv_neg_ind)
   SET stat = uar_srvsetshort(hpat,"irradiated_ind",pat_prod_info->products[nidx].pat_irr_ind)
   SET stat = uar_srvsetshort(hpat,"remove_alloc_elig_flag",nremoteallocationflag)
   IF (nremoteallocationflag > 0)
    SET stat = uar_srvsetdate(hpat,"remote_alloc_exp_dt_tm",cnvtdatetime(curdate,curtime3))
   ENDIF
   SET stat = uar_siscriptesoinsertcqm(hreq,dqueueid)
   CALL uar_srvdestroyinstance(hreq)
   IF (dqueueid <= 0.0)
    CALL errorhandler("F","FSI uar Call","FSI api call failed.")
   ENDIF
 END ;Subroutine
 SUBROUTINE make_fsi_call_for_stock_update(null)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hcqmstruct = i4 WITH protect, noconstant(0)
   DECLARE holist = i4 WITH protect, noconstant(0)
   DECLARE horec = i4 WITH protect, noconstant(0)
   DECLARE hmsg = i4 WITH protect, noconstant(0)
   DECLARE hmsgstruct = i4 WITH protect, noconstant(0)
   DECLARE htrig = i4 WITH protect, noconstant(0)
   DECLARE hprod = i4 WITH protect, noconstant(0)
   DECLARE hpat = i4 WITH protect, noconstant(0)
   DECLARE dqueueid = f8 WITH protect, noconstant(0.0)
   DECLARE prodnbr = vc WITH protect, noconstant("")
   EXECUTE si_esocallsrtl
   SET hmsg = uar_srvselectmessage(1215066)
   SET hreq = uar_srvcreaterequest(hmsg)
   SET hmsgstruct = uar_srvgetstruct(hreq,"message")
   SET hcqmstruct = uar_srvgetstruct(hmsgstruct,"CQMInfo")
   SET stat = uar_srvsetstring(hcqmstruct,"AppName",nullterm("FSIESO"))
   SET stat = uar_srvsetstring(hcqmstruct,"ContribAlias",nullterm("PATHNET_BB"))
   SET stat = uar_srvsetstring(hcqmstruct,"ContribRefnum",nullterm(concat(format(cnvtdatetime(curdate,
        curtime3),";;q")," ",request->message_name)))
   SET stat = uar_srvsetdate(hcqmstruct,"ContribDtTm",cnvtdatetime(curdate,curtime3))
   SET stat = uar_srvsetlong(hcqmstruct,"Priority",99)
   SET stat = uar_srvsetstring(hcqmstruct,"Class",nullterm("BB"))
   SET stat = uar_srvsetstring(hcqmstruct,"Type",nullterm("BLOODTRACK"))
   SET stat = uar_srvsetstring(hcqmstruct,"Subtype",nullterm(request->message_name))
   SET stat = uar_srvsetstring(hcqmstruct,"Subtype_Detail",nullterm(""))
   SET stat = uar_srvsetlong(hcqmstruct,"Debug_Ind",0)
   SET stat = uar_srvsetlong(hcqmstruct,"Verbosity_Flag",0)
   SET htrig = uar_srvadditem(hmsgstruct,"TRIGInfo")
   SET stat = uar_srvsetdouble(htrig,"organization_id",pat_prod_info->products[nidx].org_id)
   SET hprod = uar_srvgetstruct(htrig,"blood_unit")
   IF (size(trim(pat_prod_info->products[nidx].product_nbr))=13)
    IF (substring(1,1,pat_prod_info->products[nidx].product_nbr)="!")
     SET prodnbr = pat_prod_info->products[nidx].product_nbr
    ELSE
     SET prodnbr = concat(pat_prod_info->products[nidx].product_nbr,calculatecheckdigit(pat_prod_info
       ->products[nidx].product_nbr))
    ENDIF
   ELSE
    SET prodnbr = pat_prod_info->products[nidx].product_nbr
   ENDIF
   SET stat = uar_srvsetstring(hprod,"unit_number",nullterm(prodnbr))
   SET stat = uar_srvsetstring(hprod,"unit_product_code",nullterm(pat_prod_info->products[nidx].
     prod_type_bc))
   SET stat = uar_srvsetstring(hprod,"storage_location",nullterm(pat_prod_info->products[nidx].
     device_desc))
   SET stat = uar_srvsetdate(hprod,"expiry_dt_tm",cnvtdatetime(pat_prod_info->products[nidx].
     expire_dt_tm))
   SET stat = uar_srvsetdouble(hprod,"abo_cd",pat_prod_info->products[nidx].unit_abo_cd)
   SET stat = uar_srvsetdouble(hprod,"rh_cd",pat_prod_info->products[nidx].unit_rh_cd)
   SET stat = uar_srvsetdouble(hprod,"volume",pat_prod_info->products[nidx].unit_volume)
   SET stat = uar_srvsetshort(hprod,"leukoreduced_ind",pat_prod_info->products[nidx].unit_leuko_ind)
   SET stat = uar_srvsetshort(hprod,"cmv_negative_ind",pat_prod_info->products[nidx].unit_cmv_neg_ind
    )
   SET stat = uar_srvsetshort(hprod,"irradiated_ind",pat_prod_info->products[nidx].unit_irr_ind)
   SET stat = uar_siscriptesoinsertcqm(hreq,dqueueid)
   CALL uar_srvdestroyinstance(hreq)
   IF (dqueueid <= 0.0)
    CALL errorhandler("F","FSI uar Call","FSI api call failed.")
   ENDIF
 END ;Subroutine
 SUBROUTINE make_fsi_call_for_return_to_stock(null)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hcqmstruct = i4 WITH protect, noconstant(0)
   DECLARE holist = i4 WITH protect, noconstant(0)
   DECLARE horec = i4 WITH protect, noconstant(0)
   DECLARE hmsg = i4 WITH protect, noconstant(0)
   DECLARE hmsgstruct = i4 WITH protect, noconstant(0)
   DECLARE htrig = i4 WITH protect, noconstant(0)
   DECLARE hprod = i4 WITH protect, noconstant(0)
   DECLARE hpat = i4 WITH protect, noconstant(0)
   DECLARE dqueueid = f8 WITH protect, noconstant(0.0)
   DECLARE prodnbr = vc WITH protect, noconstant("")
   EXECUTE si_esocallsrtl
   SET hmsg = uar_srvselectmessage(1215082)
   SET hreq = uar_srvcreaterequest(hmsg)
   SET hmsgstruct = uar_srvgetstruct(hreq,"message")
   SET hcqmstruct = uar_srvgetstruct(hmsgstruct,"CQMInfo")
   SET stat = uar_srvsetstring(hcqmstruct,"AppName",nullterm("FSIESO"))
   SET stat = uar_srvsetstring(hcqmstruct,"ContribAlias",nullterm("PATHNET_BB"))
   SET stat = uar_srvsetstring(hcqmstruct,"ContribRefnum",nullterm(concat(format(cnvtdatetime(curdate,
        curtime3),";;q")," ",request->message_name)))
   SET stat = uar_srvsetdate(hcqmstruct,"ContribDtTm",cnvtdatetime(curdate,curtime3))
   SET stat = uar_srvsetlong(hcqmstruct,"Priority",99)
   SET stat = uar_srvsetstring(hcqmstruct,"Class",nullterm("BB"))
   SET stat = uar_srvsetstring(hcqmstruct,"Type",nullterm("BLOODTRACK"))
   SET stat = uar_srvsetstring(hcqmstruct,"Subtype",nullterm(request->message_name))
   SET stat = uar_srvsetstring(hcqmstruct,"Subtype_Detail",nullterm(""))
   SET stat = uar_srvsetlong(hcqmstruct,"Debug_Ind",0)
   SET stat = uar_srvsetlong(hcqmstruct,"Verbosity_Flag",0)
   SET htrig = uar_srvadditem(hmsgstruct,"TRIGInfo")
   SET stat = uar_srvsetdouble(htrig,"organization_id",pat_prod_info->products[nidx].org_id)
   SET hprod = uar_srvgetstruct(htrig,"blood_unit")
   IF (size(trim(pat_prod_info->products[nidx].product_nbr))=13)
    IF (substring(1,1,pat_prod_info->products[nidx].product_nbr)="!")
     SET prodnbr = pat_prod_info->products[nidx].product_nbr
    ELSE
     SET prodnbr = concat(pat_prod_info->products[nidx].product_nbr,calculatecheckdigit(pat_prod_info
       ->products[nidx].product_nbr))
    ENDIF
   ELSE
    SET prodnbr = pat_prod_info->products[nidx].product_nbr
   ENDIF
   SET stat = uar_srvsetstring(hprod,"unit_number",nullterm(prodnbr))
   SET stat = uar_srvsetstring(hprod,"unit_product_code",nullterm(pat_prod_info->products[nidx].
     prod_type_bc))
   SET stat = uar_srvsetstring(hprod,"storage_location",nullterm(pat_prod_info->products[nidx].
     device_desc))
   SET stat = uar_siscriptesoinsertcqm(hreq,dqueueid)
   CALL uar_srvdestroyinstance(hreq)
   IF (dqueueid <= 0.0)
    CALL errorhandler("F","FSI uar Call 1215082","FSI api call failed.")
   ENDIF
 END ;Subroutine
#set_status
 SET reply->status_data.status = "S"
 FREE SET pat_prod_info
 SET reqinfo->commit_ind = 1
#exit_script
END GO
