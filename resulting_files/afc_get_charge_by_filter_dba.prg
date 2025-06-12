CREATE PROGRAM afc_get_charge_by_filter:dba
 SET afc_get_charge_by_filter_vrsn = 000
 FREE RECORD temp
 RECORD temp(
   1 itemlist[*]
     2 charge_item_id = f8
     2 charge_event_id = f8
     2 interface_file_id = f8
     2 removeitind = i2
     2 suspended = i2
 )
 FREE RECORD reply
 RECORD reply(
   1 encntrs[*]
     2 encntr_id = f8
   1 department_cd = f8
   1 service_dt_tm_from = dq8
   1 service_dt_tm_to = dq8
   1 nomen_id = f8
   1 charge_type_cd = f8
   1 accession_nbr = vc
   1 admit_type = f8
   1 tier_group_cd = f8
   1 interface_file_id = f8
   1 cost_center_cd = f8
   1 payor_id = f8
   1 building_cd = f8
   1 perf_loc_cd = f8
   1 ord_phys_id = f8
   1 verify_phys_id = f8
   1 activity_type_cd = f8
   1 bill_item_id = f8
   1 process_flags[*]
     2 process_flag = i4
   1 suspense_reasons[*]
     2 suspense_rsn_cd = f8
   1 qual[*]
     2 charge_item_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE lcount = i4 WITH noconstant(0)
 DECLARE lcount1 = i4 WITH noconstant(0)
 DECLARE lcount2 = i4 WITH noconstant(0)
 DECLARE lcount3 = i4 WITH noconstant(0)
 DECLARE sencntrparser = vc WITH noconstant("1=1")
 DECLARE sprocessflagparser = vc WITH noconstant("1=1")
 DECLARE ssuspensereasonparser = vc WITH noconstant("1=1")
 DECLARE dcvsuspensereasoncd13019 = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13019,"SUSPENSE",1,dcvsuspensereasoncd13019)
 IF (size(request->encntrs,5) > 0)
  SET sencntrparser = "C.Encntr_Id In ("
  FOR (lcount = 1 TO size(request->encntrs,5))
    SET sencntrparser = build(sencntrparser,request->encntrs[lcount].encntr_id,",")
    SET lcount1 = (lcount1+ 1)
    SET stat = alterlist(reply->encntrs,lcount1)
    SET reply->encntrs[lcount1].encntr_id = request->encntrs[lcount].encntr_id
  ENDFOR
  SET sencntrparser = build(sencntrparser,- (999999),")")
 ENDIF
 EXECUTE pft_log "Afc_Get_Charge_By_Filter", build("Number Of Encntr_Ids = ",lcount), 4
 IF (size(request->process_flags,5) > 0)
  SET sprocessflagparser = "C.Process_Flg In ("
  FOR (lcount = 1 TO size(request->process_flags,5))
    SET sprocessflagparser = build(sprocessflagparser,request->process_flags[lcount].process_flag,","
     )
    SET lcount2 = (lcount2+ 1)
    SET stat = alterlist(reply->process_flags,lcount2)
    SET reply->process_flags[lcount2].process_flag = request->process_flags[lcount].process_flag
  ENDFOR
  SET sprocessflagparser = build(sprocessflagparser,- (999999),")")
 ENDIF
 EXECUTE pft_log "Afc_Get_Charge_By_Filter", build("Number Of Process_Flags = ",lcount), 4
 IF (size(request->suspense_reasons,5) > 0)
  SET ssuspensereasonparser = "CM.FIELD1_ID Not In ("
  FOR (lcount = 1 TO size(request->suspense_reasons,5))
    SET ssuspensereasonparser = build(ssuspensereasonparser,request->suspense_reasons[lcount].
     suspense_rsn_cd,",")
    SET lcount3 = (lcount3+ 1)
    SET stat = alterlist(reply->suspense_reasons,lcount3)
    SET reply->suspense_reasons[lcount3].suspense_rsn_cd = request->suspense_reasons[lcount].
    suspense_rsn_cd
  ENDFOR
  SET ssuspensereasonparser = build(ssuspensereasonparser,- (999999),")")
 ENDIF
 EXECUTE pft_log "Afc_Get_Charge_By_Filter", build("Number Of Suspense_Reasons = ",lcount), 4
 SET lcount = 0
 SET reply->department_cd = request->department_cd
 SET reply->service_dt_tm_from = request->service_dt_tm_from
 SET reply->service_dt_tm_to = request->service_dt_tm_to
 SET reply->nomen_id = request->nomen_id
 SET reply->charge_type_cd = request->charge_type_cd
 SET reply->accession_nbr = request->accession_nbr
 SET reply->admit_type = request->admit_type
 SET reply->tier_group_cd = request->tier_group_cd
 SET reply->interface_file_id = request->interface_file_id
 SET reply->cost_center_cd = request->cost_center_cd
 SET reply->payor_id = request->payor_id
 SET reply->building_cd = request->building_cd
 SET reply->perf_loc_cd = request->perf_loc_cd
 SET reply->ord_phys_id = request->ord_phys_id
 SET reply->verify_phys_id = request->verify_phys_id
 SET reply->activity_type_cd = request->activity_type_cd
 SET reply->bill_item_id = request->bill_item_id
 SELECT INTO "Nl:"
  FROM charge c
  PLAN (c
   WHERE parser(sencntrparser)
    AND parser(sprocessflagparser)
    AND (c.department_cd=
   IF ((request->department_cd > 0)) request->department_cd
   ELSE c.department_cd
   ENDIF
   )
    AND (c.service_dt_tm >=
   IF ((request->service_dt_tm_from > 0)) cnvtdatetime(request->service_dt_tm_from)
   ELSE c.service_dt_tm
   ENDIF
   )
    AND (c.service_dt_tm <=
   IF ((request->service_dt_tm_to > 0)) cnvtdatetime(request->service_dt_tm_to)
   ELSE c.service_dt_tm
   ENDIF
   )
    AND (c.charge_type_cd=
   IF ((request->charge_type_cd > 0)) request->charge_type_cd
   ELSE c.charge_type_cd
   ENDIF
   )
    AND (c.admit_type_cd=
   IF ((request->admit_type > 0)) request->admit_type
   ELSE c.admit_type_cd
   ENDIF
   )
    AND (c.tier_group_cd=
   IF ((request->tier_group_cd > 0)) request->tier_group_cd
   ELSE c.tier_group_cd
   ENDIF
   )
    AND (c.interface_file_id=
   IF ((request->interface_file_id > 0)) request->interface_file_id
   ELSE c.interface_file_id
   ENDIF
   )
    AND (c.cost_center_cd=
   IF ((request->cost_center_cd > 0)) request->cost_center_cd
   ELSE c.cost_center_cd
   ENDIF
   )
    AND (c.payor_id=
   IF ((request->payor_id > 0)) request->payor_id
   ELSE c.payor_id
   ENDIF
   )
    AND (c.perf_loc_cd=
   IF ((request->perf_loc_cd > 0)) request->perf_loc_cd
   ELSE c.perf_loc_cd
   ENDIF
   )
    AND (c.ord_phys_id=
   IF ((request->ord_phys_id > 0)) request->ord_phys_id
   ELSE c.ord_phys_id
   ENDIF
   )
    AND (c.verify_phys_id=
   IF ((request->verify_phys_id > 0)) request->verify_phys_id
   ELSE c.verify_phys_id
   ENDIF
   )
    AND (c.activity_type_cd=
   IF ((request->activity_type_cd > 0)) request->activity_type_cd
   ELSE c.activity_type_cd
   ENDIF
   )
    AND (c.bill_item_id=
   IF ((request->bill_item_id > 0)) request->bill_item_id
   ELSE c.bill_item_id
   ENDIF
   )
    AND c.active_ind=1)
  ORDER BY c.encntr_id DESC, c.process_flg DESC, c.suspense_rsn_cd DESC
  DETAIL
   lcount = (lcount+ 1), stat = alterlist(temp->itemlist,lcount), temp->itemlist[lcount].
   charge_item_id = c.charge_item_id,
   temp->itemlist[lcount].charge_event_id = c.charge_event_id, temp->itemlist[lcount].
   interface_file_id = c.interface_file_id
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  EXECUTE pft_log "Afc_Get_Charge_By_Filter", "No Charge Item Ids Qualify", 1
  SET reply->status_data.status = "Z"
  GO TO exitscript
 ENDIF
 IF (trim(request->accession_nbr,3) != "")
  SELECT INTO "Nl:"
   FROM (dummyt d  WITH seq = lcount),
    charge_event ce
   PLAN (d
    WHERE (temp->itemlist[d.seq].removeitind=0))
    JOIN (ce
    WHERE ((trim(ce.accession,3) != trim(request->accession_nbr,3)) OR (ce.accession=null))
     AND ce.active_ind=1
     AND (ce.charge_event_id=temp->itemlist[d.seq].charge_event_id))
   DETAIL
    temp->itemlist[d.seq].removeitind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->nomen_id > 0))
  SELECT INTO "Nl:"
   FROM (dummyt d  WITH seq = lcount),
    charge_mod cm
   PLAN (d
    WHERE (temp->itemlist[d.seq].removeitind=0))
    JOIN (cm
    WHERE (cm.nomen_id != request->nomen_id)
     AND cm.active_ind=1
     AND (cm.charge_item_id=temp->itemlist[d.seq].charge_item_id))
   DETAIL
    temp->itemlist[d.seq].removeitind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (size(request->suspense_reasons,5) > 0)
  SELECT INTO "Nl:"
   FROM (dummyt d  WITH seq = lcount),
    charge_mod cm
   PLAN (d
    WHERE (temp->itemlist[d.seq].removeitind=0))
    JOIN (cm
    WHERE outerjoin(1)=cm.active_ind
     AND outerjoin(temp->itemlist[d.seq].charge_item_id)=cm.charge_item_id
     AND outerjoin(dcvsuspensereasoncd13019)=cm.charge_mod_type_cd)
   ORDER BY cm.charge_item_id
   HEAD cm.charge_item_id
    IF (cm.charge_item_id > 0)
     temp->itemlist[d.seq].suspended = 1
    ELSE
     temp->itemlist[d.seq].removeitind = 1
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "Nl:"
   FROM (dummyt d  WITH seq = lcount),
    charge_mod cm
   PLAN (d
    WHERE (temp->itemlist[d.seq].removeitind=0))
    JOIN (cm
    WHERE parser(ssuspensereasonparser)
     AND cm.active_ind=1
     AND (cm.charge_item_id=temp->itemlist[d.seq].charge_item_id)
     AND cm.charge_mod_type_cd=dcvsuspensereasoncd13019)
   DETAIL
    temp->itemlist[d.seq].removeitind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->building_cd > 0))
  SELECT INTO "Nl:"
   FROM (dummyt d  WITH seq = lcount),
    interface_charge ifl
   PLAN (d
    WHERE (temp->itemlist[d.seq].removeitind=0))
    JOIN (ifl
    WHERE (ifl.charge_item_id=temp->itemlist[d.seq].charge_item_id)
     AND (ifl.building_cd != request->building_cd)
     AND ifl.active_ind=1)
   DETAIL
    temp->itemlist[d.seq].removeitind = 1
   WITH nocounter
  ;end select
 ENDIF
 SET lcount1 = 0
 SELECT INTO "Nl:"
  FROM (dummyt d  WITH seq = lcount)
  PLAN (d
   WHERE (temp->itemlist[d.seq].removeitind=0))
  DETAIL
   lcount1 = (lcount1+ 1), stat = alterlist(reply->qual,lcount1), reply->qual[lcount1].charge_item_id
    = temp->itemlist[d.seq].charge_item_id
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  EXECUTE pft_log "Afc_Get_Charge_By_Filter", "No Charge Item Ids Qualify", 1
  SET reply->status_data.status = "Z"
  GO TO exitscript
 ENDIF
 SET reply->status_data.status = "S"
#exitscript
 CALL echo(sencntrparser)
 CALL echo(sprocessflagparser)
 CALL echo(ssuspensereasonparser)
 CALL echorecord(temp)
 CALL echorecord(reply)
END GO
