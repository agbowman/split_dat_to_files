CREATE PROGRAM bbd_get_shipment_search:dba
 RECORD reply(
   1 shipment[*]
     2 shipment_nbr = i4
     2 shipment_id = f8
     2 needed_dt_tm = dq8
     2 shipment_dt_tm = dq8
     2 order_dt_tm = dq8
     2 shipment_status_flag = i2
     2 courier_cd = f8
     2 courier_disp = c40
     2 order_placed_by = vc
     2 comments_ind = i2
     2 organization_name = vc
     2 organization_id = f8
     2 inventory_area_cd = f8
     2 inventory_area_display = c40
     2 inventory_area_desc = vc
     2 owner_area_cd = f8
     2 owner_area_display = c40
     2 owner_area_desc = vc
     2 order_priority_cd = f8
     2 from_facility_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 RECORD areatemp(
   1 area[*]
     2 area_cd = f8
 )
 RECORD orgtemp(
   1 organization[*]
     2 org_id = f8
 )
 RECORD producttemp(
   1 product[*]
     2 product_id = f8
 )
 DECLARE determineexpandtotal(lactualsize=i4,lexpandsize=i4) = i4 WITH protect, noconstant(0)
 DECLARE determineexpandsize(lrecordsize=i4,lmaximumsize=i4) = i4 WITH protect, noconstant(0)
 SUBROUTINE determineexpandtotal(lactualsize,lexpandsize)
   RETURN((ceil((cnvtreal(lactualsize)/ lexpandsize)) * lexpandsize))
 END ;Subroutine
 SUBROUTINE determineexpandsize(lrecordsize,lmaximumsize)
   DECLARE lreturn = i4 WITH protect, noconstant(0)
   IF (lrecordsize <= 1)
    SET lreturn = 1
   ELSEIF (lrecordsize <= 10)
    SET lreturn = 10
   ELSEIF (lrecordsize <= 500)
    SET lreturn = 50
   ELSE
    SET lreturn = 100
   ENDIF
   IF (lmaximumsize < lreturn)
    SET lreturn = lmaximumsize
   ENDIF
   RETURN(lreturn)
 END ;Subroutine
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lactualsize = i4 WITH protect, noconstant(0)
 DECLARE lexpandsize = i4 WITH protect, noconstant(0)
 DECLARE lexpandtotal = i4 WITH protect, noconstant(0)
 DECLARE lexpandstart = i4 WITH protect, noconstant(1)
 SET failed = "F"
 SET code_set = 0
 SET code_cnt = 0
 SET code_cnt2 = 0
 SET cdf_mean = fillstring(12," ")
 SET orgcount = 0
 SET prodcount = 0
 SET inventory_cd = 0.0
 SET supplier_cd = 0.0
 SET manufacture_cd = 0.0
 SET client_cd = 0.0
 SET areacount = 1
 SET shipcount = 0
 SET all_products = "F"
 SET all_patients = "F"
 SET use_product_list_ind = 0
 IF (substring(1,1,request->product_nbr)="\*")
  SET all_products = "T"
 ENDIF
 IF (substring(1,1,request->patient_name)="\*")
  SET all_patients = "T"
 ENDIF
 IF (size(trim(request->product_nbr),1) > 0
  AND all_products="F")
  IF (size(trim(request->patient_name),1) > 0
   AND all_patients="F")
   SET use_product_list_ind = 1
   SELECT INTO "nl"
    FROM person p,
     product p2,
     product_event pe
    PLAN (p2
     WHERE p2.product_nbr=patstring(cnvtupper(request->product_nbr))
      AND p2.active_ind=1)
     JOIN (pe
     WHERE pe.product_id=p2.product_id
      AND pe.active_ind=1)
     JOIN (p
     WHERE p.name_last_key=patstring(cnvtupper(request->patient_name))
      AND p.active_ind=1
      AND ((p.person_id+ 0.0) > 0.0)
      AND p.person_id=pe.person_id)
    ORDER BY p2.product_id
    HEAD p2.product_id
     IF (p2.product_id > 0.0)
      prodcount = (prodcount+ 1), stat = alterlist(producttemp->product,prodcount), producttemp->
      product[prodcount].product_id = p2.product_id
     ENDIF
    DETAIL
     row + 0
    FOOT  p2.product_id
     row + 0
    WITH nocounter
   ;end select
  ELSE
   SET use_product_list_ind = 1
   SELECT INTO "nl:"
    p.product_id
    FROM product p
    PLAN (p
     WHERE p.product_nbr=patstring(cnvtupper(request->product_nbr))
      AND p.active_ind=1)
    ORDER BY p.product_id
    HEAD p.product_id
     IF (p.product_id > 0.0)
      prodcount = (prodcount+ 1), stat = alterlist(producttemp->product,prodcount), producttemp->
      product[prodcount].product_id = p.product_id
     ENDIF
    FOOT  p.product_id
     row + 1
    WITH nocounter
   ;end select
  ENDIF
 ELSEIF (size(trim(request->patient_name),1) > 0
  AND all_patients="F")
  SET use_product_list_ind = 1
  SELECT INTO "nl:"
   FROM product_event pe,
    person p
   PLAN (p
    WHERE p.name_last_key=patstring(cnvtupper(request->patient_name))
     AND p.active_ind=1
     AND ((p.person_id+ 0.0) > 0.0))
    JOIN (pe
    WHERE pe.person_id=p.person_id
     AND pe.active_ind=1)
   ORDER BY pe.product_id
   HEAD pe.product_id
    IF (pe.product_id > 0.0)
     prodcount = (prodcount+ 1), stat = alterlist(producttemp->product,prodcount), producttemp->
     product[prodcount].product_id = pe.product_id
    ENDIF
   DETAIL
    row + 0
   FOOT  pe.product_id
    row + 0
   WITH nocounter
  ;end select
 ENDIF
 IF (size(trim(request->organization_name),1) > 0)
  SET code_set = 278
  SET cdf_mean = "BBSUPPL"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,supplier_cd)
  SET cdf_mean = "BBMANUF"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,manufacture_cd)
  SET cdf_mean = "BBCLIENT"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,client_cd)
  IF (((supplier_cd=0.0) OR (((manufacture_cd=0.0) OR (client_cd=0.0)) )) )
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_get_shipment_search.prg"
   SET reply->status_data.subeventstatus[1].operationname = "Select"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
   IF (supplier_cd=0.0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to read blood bank supplier organization type code value."
   ELSEIF (manufacture_cd=0.0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to read blood bank manufacturer organization type code value."
   ELSEIF (client_cd=0.0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to read blood bank client organization type code value."
   ENDIF
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
  SET code_set = 220
  SET code_cnt = 1
  SET cdf_mean = "BBINVAREA"
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,inventory_cd)
  IF (stat=0)
   SET stat = alterlist(areatemp->area,areacount)
   SET areatemp->area[areacount].area_cd = inventory_cd
  ENDIF
  IF (code_cnt > 1)
   FOR (code_cnt2 = 2 TO code_cnt)
     SET areacount = (areacount+ 1)
     SET i = code_cnt2
     SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,i,inventory_cd)
     IF (stat=0)
      SET stat = alterlist(areatemp->area,areacount)
      SET areatemp->area[areacount].area_cd = inventory_cd
     ENDIF
   ENDFOR
  ENDIF
  FOR (i = 1 TO areacount)
   SET display = uar_get_code_display(areatemp->area[i].area_cd)
   IF (cnvtupper(display)=patstring(cnvtupper(request->organization_name)))
    SET orgcount = (orgcount+ 1)
    SET stat = alterlist(orgtemp->organization,orgcount)
    SET orgtemp->organization[orgcount].org_id = areatemp->area[i].area_cd
   ENDIF
  ENDFOR
  SELECT INTO "nl:"
   o.organization_id, o.org_name
   FROM organization o,
    org_type_reltn r
   PLAN (r
    WHERE r.org_type_cd IN (supplier_cd, manufacture_cd, client_cd)
     AND r.active_ind=1)
    JOIN (o
    WHERE o.organization_id=r.organization_id
     AND cnvtupper(o.org_name)=patstring(cnvtupper(request->organization_name))
     AND o.active_ind=1)
   ORDER BY o.organization_id
   HEAD o.organization_id
    IF (o.organization_id > 0.0)
     orgcount = (orgcount+ 1), stat = alterlist(orgtemp->organization,orgcount), orgtemp->
     organization[orgcount].org_id = o.organization_id
    ENDIF
   FOOT  o.organization_id
    row + 1
  ;end select
 ENDIF
 SET num_org = size(orgtemp->organization,5)
 SET num_prod = size(producttemp->product,5)
 SET req_org_size = size(request->organization_name,1)
 SET req_ship_size = size(request->shipment_nbr,1)
 SET lexpandstart = 1
 SET lactualsize = size(producttemp->product,5)
 SET lexpandsize = determineexpandsize(lactualsize,100)
 SET lexpandtotal = determineexpandtotal(lactualsize,lexpandsize)
 SET stat = alterlist(producttemp->product,lexpandtotal)
 FOR (i = (lactualsize+ 1) TO lexpandtotal)
   SET producttemp->product[i].product_id = producttemp->product[lactualsize].product_id
 ENDFOR
 SELECT
  IF (((use_product_list_ind=0) OR (all_products="T"
   AND all_patients="T")) )
   WITH dontcare = e
  ELSE
  ENDIF
  INTO "nl:"
  s.shipment_nbr, s.shipment_id, s.courier_cd,
  s.needed_dt_tm, s.order_dt_tm, s.shipment_dt_tm,
  s.shipment_status_flag, s.order_placed_by, s.recorded_by_prsnl_id,
  s.organization_id, owner_area = uar_get_code_display(s.owner_area_cd), inventory_area =
  uar_get_code_display(s.inventory_area_cd),
  o.org_name
  FROM bb_shipment s,
   (dummyt d1  WITH seq = value(num_org)),
   organization o,
   (dummyt d2  WITH seq = value((lexpandtotal/ lexpandsize))),
   bb_ship_event e
  PLAN (d1)
   JOIN (s
   WHERE ((req_org_size=0
    AND ((s.shipment_id+ 0) > 0.0)) OR (((num_org > 0
    AND (((s.organization_id=orgtemp->organization[d1.seq].org_id)) OR ((s.inventory_area_cd=orgtemp
   ->organization[d1.seq].org_id))) ) OR (req_org_size > 0
    AND num_org=0
    AND ((s.shipment_id+ 0)=0.0))) ))
    AND ((req_ship_size > 0
    AND trim(cnvtstring(s.shipment_nbr))=patstring(request->shipment_nbr)) OR (req_ship_size=0
    AND ((s.shipment_id+ 0) > 0.0)))
    AND (((request->shipment_status_flag > - (1))
    AND (s.shipment_status_flag=request->shipment_status_flag)) OR ((request->shipment_status_flag=
   - (1))
    AND ((s.shipment_id+ 0) > 0.0)))
    AND (((request->time_ind=1)
    AND s.needed_dt_tm BETWEEN cnvtdatetime(request->from_dt_tm) AND cnvtdatetime(request->to_dt_tm))
    OR ((request->time_ind=0)
    AND ((s.shipment_id+ 0) > 0.0)))
    AND (((request->from_facility_cd > 0.0)
    AND (((s.from_facility_cd=request->from_facility_cd)) OR (s.from_facility_cd=0.0)) ) OR ((request
   ->from_facility_cd=0.0)
    AND ((s.shipment_id+ 0) > 0.0)))
    AND s.active_ind=1)
   JOIN (d2
   WHERE assign(lexpandstart,evaluate(d2.seq,1,1,(lexpandstart+ lexpandsize))))
   JOIN (e
   WHERE ((use_product_list_ind=0
    AND e.shipment_id=0.0) OR (((num_prod > 0
    AND expand(lcnt,lexpandstart,(lexpandstart+ (lexpandsize - 1)),e.product_id,producttemp->product[
    lcnt].product_id)
    AND e.active_ind=1
    AND e.shipment_id=s.shipment_id) OR (((num_prod=0
    AND use_product_list_ind=1
    AND e.shipment_id=0.0
    AND e.shipment_id=s.shipment_id) OR (all_products="T"
    AND all_patients="T"
    AND e.shipment_id=s.shipment_id)) )) )) )
   JOIN (o
   WHERE o.organization_id=s.organization_id)
  ORDER BY s.shipment_nbr
  HEAD s.shipment_nbr
   IF (s.shipment_id > 0)
    shipcount = (shipcount+ 1), stat = alterlist(reply->shipment,shipcount), reply->shipment[
    shipcount].shipment_nbr = s.shipment_nbr,
    reply->shipment[shipcount].shipment_id = s.shipment_id, reply->shipment[shipcount].needed_dt_tm
     = s.needed_dt_tm, reply->shipment[shipcount].shipment_dt_tm = s.shipment_dt_tm,
    reply->shipment[shipcount].order_dt_tm = s.order_dt_tm, reply->shipment[shipcount].
    organization_id = s.organization_id, reply->shipment[shipcount].courier_cd = s.courier_cd,
    reply->shipment[shipcount].shipment_status_flag = s.shipment_status_flag, reply->shipment[
    shipcount].order_placed_by = s.order_placed_by, reply->shipment[shipcount].owner_area_cd = s
    .owner_area_cd,
    reply->shipment[shipcount].owner_area_display = owner_area, reply->shipment[shipcount].
    owner_area_desc = uar_get_code_description(s.owner_area_cd), reply->shipment[shipcount].
    inventory_area_cd = s.inventory_area_cd,
    reply->shipment[shipcount].inventory_area_display = inventory_area, reply->shipment[shipcount].
    inventory_area_desc = uar_get_code_description(s.inventory_area_cd), reply->shipment[shipcount].
    organization_id = s.organization_id,
    reply->shipment[shipcount].organization_name = o.org_name, reply->shipment[shipcount].
    order_priority_cd = s.order_priority_cd, reply->shipment[shipcount].from_facility_cd = s
    .from_facility_cd
    IF (s.long_text_id > 0)
     reply->shipment[shipcount].comments_ind = 1
    ELSE
     reply->shipment[shipcount].comments_ind = 0
    ENDIF
   ENDIF
  FOOT  s.shipment_nbr
   row + 1
  WITH counter, dontcare = o
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 FREE SET areatemp
 FREE SET orgtemp
 FREE SET producttemp
#exit_script
END GO
