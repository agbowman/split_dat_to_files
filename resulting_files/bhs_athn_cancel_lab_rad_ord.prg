CREATE PROGRAM bhs_athn_cancel_lab_rad_ord
 RECORD replyout(
   1 badordercnt = i2
   1 grouprollbackind = i2
   1 groupbadorderindex = i2
   1 orderlist[*]
     2 orderid = f8
     2 orderstatuscd = f8
     2 accessionnbr = vc
     2 errorstr = vc
     2 errornbr = i4
     2 deptstatuscd = f8
     2 prevdeptstatuscd = f8
     2 schstatecd = f8
     2 orderdetaildisplayline = vc
     2 origorderdttm = dq8
     2 ordercommentind = i2
     2 neednursereviewind = i2
     2 needdoctorcosignind = i2
     2 actionsequence = i4
     2 reviewcnt = i4
     2 detailcnt = i4
     2 ingredcnt = i4
     2 ingreddetailcntlist[*]
       3 ingdetcnt = i4
     2 misclist[*]
       3 fieldmeaning = vc
       3 fieldmeaningid = f8
       3 fieldvalue = f8
       3 fielddisplayvalue = vc
       3 fielddttmvalue = dq8
       3 modifiedind = i2
     2 clinicaldisplayline = vc
     2 incompleteorderind = i2
     2 orderactionid = f8
     2 specificerrornbr = i4
     2 specificerrorstr = vc
     2 actionstatus = i2
     2 needrxclinreviewflag = i2
     2 needrxprodassignflag = i2
     2 simplifieddisplayline = vc
     2 errorreasoncd = f8
     2 externalservicescalledinfo
       3 poolroutingcalledind = i2
       3 receiptcreationcalledind = i2
       3 powerplanservicecalledind = i2
       3 schedulingscriptcalledind = i2
     2 lastactionsequence = i4
     2 needrxverifyind = i2
     2 projectedstopdttm = dq8
     2 projectedstoptz = i4
     2 stoptypecd = f8
   1 status_data
     2 status = vc
     2 subeventstatus[*]
       3 operationname = vc
       3 operationstatus = vc
       3 targetobjectname = vc
       3 targetobjectvalue = vc
       3 requestnumber = i4
       3 orderid = f8
       3 actionseq = i4
       3 substatus = vc
   1 errornbr = i4
   1 errorstr = vc
   1 specificerrornbr = i4
   1 specificerrorstr = vc
   1 transactionstatus = i2
 )
 FREE RECORD requestin
 RECORD requestin(
   1 productid = f8
   1 personid = f8
   1 encntrid = f8
   1 passingencntrinfoind = i2
   1 encntrfinancialid = f8
   1 locationcd = f8
   1 locfacilitycd = f8
   1 locnurseunitcd = f8
   1 locroomcd = f8
   1 locbedcd = f8
   1 actionpersonnelid = f8
   1 contributorsystemcd = f8
   1 orderlocncd = f8
   1 replyinfoflag = i2
   1 commitgroupind = i2
   1 needsatldupcheckind = i2
   1 ordersheetind = i2
   1 ordersheetprintername = vc
   1 logleveloverride = i2
   1 unlockprofileind = i2
   1 lockkeyid = i4
   1 orderlist[*]
     2 orderid = f8
     2 actiontypecd = f8
     2 communicationtypecd = f8
     2 orderproviderid = f8
     2 orderdttm = dq8
     2 currentstartdttm = dq8
     2 oeformatid = f8
     2 catalogtypecd = f8
     2 accessionnbr = vc
     2 accessionid = f8
     2 nochargeind = i2
     2 billonlyind = i2
     2 lastupdtcnt = i4
     2 detaillist[*]
       3 oefieldid = f8
       3 oefieldvalue = f8
       3 oefielddisplayvalue = vc
       3 oefielddttmvalue = dq8
       3 oefieldmeaning = vc
       3 oefieldmeaningid = f8
       3 valuerequiredind = i2
       3 groupseq = i4
       3 fieldseq = i4
       3 modifiedind = i2
       3 detailhistorylist[*]
         4 oefieldvalue = f8
         4 oefielddisplayvalue = vc
         4 oefielddttmvalue = dq8
         4 detailalterflag = i2
         4 detailaltertriggercd = f8
     2 misclist[*]
       3 fieldmeaning = vc
       3 fieldmeaningid = f8
       3 fieldvalue = f8
       3 fielddisplayvalue = vc
       3 fielddttmvalue = dq8
       3 modifiedind = i2
       3 groups[*]
         4 groupidentifier = i2
     2 prompttestlist[*]
       3 fieldvalue = f8
       3 fielddisplayvalue = vc
       3 fielddttmvalue = dq8
       3 promptentityname = vc
       3 promptentityid = f8
       3 modifiedind = i2
       3 fieldtypeflag = i2
       3 oefieldid = f8
     2 commentlist[*]
       3 commenttype = f8
       3 commenttext = vc
     2 reviewlist[*]
       3 reviewtypeflag = i2
       3 providerid = f8
       3 locationcd = f8
       3 rejectedind = i2
       3 reviewpersonnelid = f8
       3 proxypersonnelid = f8
       3 proxyreasoncd = f8
       3 catalogtypecd = f8
       3 actionsequence = i2
       3 override[*]
         4 value
           5 noreviewrequiredind = i2
           5 reviewrequiredind = i2
           5 systemdetermineind = i2
         4 overridereasoncd = f8
     2 deptmiscline = vc
     2 catalogcd = f8
     2 synonymid = f8
     2 ordermnemonic = vc
     2 passingorcinfoind = i2
     2 primarymnemonic = vc
     2 activitytypecd = f8
     2 activitysubtypecd = f8
     2 contordermethodflag = i2
     2 completeuponorderind = i2
     2 orderreviewind = i2
     2 printreqind = i2
     2 requisitionformatcd = f8
     2 requisitionroutingcd = f8
     2 resourceroutelevel = i4
     2 consentformind = i2
     2 consentformformatcd = f8
     2 consentformroutingcd = f8
     2 deptdupcheckind = i2
     2 dupcheckingind = i2
     2 deptdisplayname = vc
     2 reftextmask = i4
     2 abnreviewind = i2
     2 reviewhierarchyid = f8
     2 orderabletypeflag = i2
     2 dcpclincatcd = f8
     2 cki = vc
     2 stoptypecd = f8
     2 stopduration = i4
     2 stopdurationunitcd = f8
     2 needsintervalcalcind = i2
     2 templateorderflag = i2
     2 templateorderid = f8
     2 grouporderflag = i2
     2 groupcompcount = i4
     2 linkorderflag = i2
     2 linkcompcount = i4
     2 linktypecd = f8
     2 linkelementflag = i2
     2 linkelementcd = f8
     2 processingflag = i2
     2 origordasflag = i2
     2 orderstatuscd = f8
     2 deptstatuscd = f8
     2 schstatecd = f8
     2 discontinuetypecd = f8
     2 rxmask = i4
     2 scheventid = f8
     2 encntrid = f8
     2 passingencntrinfoind = i2
     2 encntrfinancialid = f8
     2 locationcd = f8
     2 locfacilitycd = f8
     2 locnurseunitcd = f8
     2 locroomcd = f8
     2 locbedcd = f8
     2 medordertypecd = f8
     2 undoactiontypecd = f8
     2 orderedasmnemonic = vc
     2 getlatestdetailsind = i2
     2 studentactiontypecd = f8
     2 aliaslist[*]
       3 alias = vc
       3 orderaliastypecd = f8
       3 orderaliassubtypecd = f8
       3 aliaspoolcd = f8
       3 checkdigit = i4
       3 checkdigitmethodcd = f8
       3 begeffectivedttm = dq8
       3 endeffectivedttm = dq8
       3 datastatuscd = f8
       3 activestatuscd = f8
       3 activeind = i2
       3 billordnbrind = i2
       3 primarydisplayind = i2
     2 subcomponentlist[*]
       3 sccatalogcd = f8
       3 scsynonymid = f8
       3 scordermnemonic = vc
       3 scoeformatid = f8
       3 scstrengthdose = f8
       3 scstrengthdosedisp = vc
       3 scstrengthunit = f8
       3 scstrengthunitdisp = vc
       3 scvolumedose = f8
       3 scvolumedosedisp = vc
       3 scvolumeunit = f8
       3 scvolumeunitdisp = vc
       3 scfreetextdose = vc
       3 scfrequency = f8
       3 scfrequencydisp = vc
       3 scivseq = i4
       3 scdosequantity = f8
       3 scdosequantitydisp = vc
       3 scdosequantityunit = f8
       3 scdosequantityunitdisp = vc
       3 scorderedasmnemonic = vc
       3 schnaordermnemonic = vc
       3 scdetaillist[*]
         4 oefieldid = f8
         4 oefieldvalue = f8
         4 oefielddisplayvalue = vc
         4 oefielddttmvalue = dq8
         4 oefieldmeaning = vc
         4 oefieldmeaningid = f8
         4 valuerequiredind = i2
         4 groupseq = i4
         4 fieldseq = i4
         4 modifiedind = i2
       3 scproductlist[*]
         4 item_id = f8
         4 dose_quantity = f8
         4 dose_quantity_unit_cd = f8
         4 tnf_id = f8
         4 tnf_description = vc
         4 tnf_cost = f8
         4 tnf_ndc = vc
         4 tnflegalstatuscd = f8
         4 packagetypeid = f8
         4 medproductid = f8
         4 manfitemid = f8
         4 dispqty = f8
         4 dispqtyunitcd = f8
         4 ignoreind = i2
         4 compoundflag = i2
         4 cmpdbaseind = i2
         4 premanfind = i2
         4 productseq = i2
         4 parentproductseq = i2
         4 labeldesc = vc
         4 branddesc = vc
         4 genericdesc = vc
         4 drugidentifier = vc
         4 pkg_qty_per_pkg = f8
         4 pkg_disp_more_ind = i2
         4 unrounded_dose_quantity = f8
         4 overfillstrengthdose = f8
         4 overfillstrengthunitcd = f8
         4 overfillstrengthunitdisp = vc
         4 overfillvolumedose = f8
         4 overfillvolumeunitcd = f8
         4 overfillvolumeunitdisp = vc
         4 doselist[*]
           5 schedulesequence = i2
           5 dosequantity = f8
           5 dosequantityunitcd = f8
           5 unroundeddosequantity = f8
       3 scingredienttypeflag = i2
       3 scprevingredientseq = i4
       3 scmodifiedflag = i2
       3 scincludeintotalvolumeflag = i2
       3 scclinicallysignificantflag = i2
       3 scautoassignflag = i2
       3 scordereddose = f8
       3 scordereddosedisp = vc
       3 scordereddoseunitcd = f8
       3 scordereddoseunitdisp = vc
       3 scdosecalculatorlongtext = c32000
       3 scingredientsourceflag = i2
       3 scnormalizedrate = f8
       3 scnormalizedratedisp = vc
       3 scnormalizedrateunitcd = f8
       3 scnormalizedrateunitdisp = vc
       3 scconcentration = f8
       3 scconcentrationdisp = vc
       3 scconcentrationunitcd = f8
       3 scconcentrationunitdisp = vc
       3 sctherapeuticsbsttnlist[*]
         4 therapsbsttnid = f8
         4 acceptflag = i2
         4 overridereasoncd = f8
         4 itemid = f8
       3 schistorylist[*]
         4 scaltertriggercd = f8
         4 scsynonymid = f8
         4 scstrengthdose = f8
         4 scstrengthunit = f8
         4 scvolumedose = f8
         4 scvolumeunit = f8
         4 scfreetextdose = vc
         4 scmodifiedflag = i2
       3 scdosinginfo[*]
         4 dosingcapacity = i2
         4 daysofadministrationdisplay = vc
         4 doselist[*]
           5 scheduleinfo
             6 dosesequence = i2
             6 schedulesequence = i2
           5 strengthdose[*]
             6 value = f8
             6 valuedisplay = vc
             6 unitofmeasurecd = f8
           5 volumedose[*]
             6 value = f8
             6 valuedisplay = vc
             6 unitofmeasurecd = f8
           5 ordereddose[*]
             6 value = f8
             6 valuedisplay = vc
             6 unitofmeasurecd = f8
             6 dosetype
               7 strengthind = i2
               7 volumeind = i2
       3 scdoseadjustmentinfo[*]
         4 doseadjustmentdisplay = vc
         4 carryforwardoverrideind = i2
       3 scorderedassynonymid = f8
     2 resourcelist[*]
       3 serviceresourcecd = f8
       3 csloginloccd = f8
       3 serviceareacd = f8
       3 assaylist[*]
         4 taskassaycd = f8
     2 relationshiplist[*]
       3 relationshipmeaning = vc
       3 valuelist[*]
         4 entityid = f8
         4 entitydisplay = vc
         4 ranksequence = i4
       3 inactivateallind = i2
     2 misclongtextlist[*]
       3 textid = f8
       3 texttypecd = f8
       3 text = vc
       3 textmodifier1 = i4
       3 textmodified2 = i4
     2 deptcommentlist[*]
       3 commenttypecd = f8
       3 commentseq = i4
       3 commentid = f8
       3 longtextid = f8
       3 deptcommentmisc = i4
       3 deptcommenttext = vc
     2 adhocfreqtimelist[*]
       3 adhoctime = i4
     2 ingredientreviewind = i2
     2 taskstatusreasonmean = f8
     2 badorderind = i2
     2 origorderdttm = dq8
     2 validdosedttm = dq8
     2 useroverridetz = i4
     2 linknbr = f8
     2 linktypeflag = i2
     2 supervisingproviderid = f8
     2 digitalsignatureident = c64
     2 bypassprescriptionreqprinting = i2
     2 pathwaycatalogid = f8
     2 patientoverridetz = i4
     2 actionqualifiercd = f8
     2 acceptproposalid = f8
     2 addorderreltnlist[*]
       3 relatedfromorderid = f8
       3 relatedfromactionseq = i4
       3 relationtypecd = f8
     2 scheduleexceptionlist[*]
       3 scheduleexceptiontypecd = f8
       3 originstancedttm = dq8
       3 newinstancedttm = dq8
       3 scheduleexceptionorderid = f8
     2 inactivescheduleexceptionlist[*]
       3 orderscheduleexceptionid = f8
       3 scheduleexceptionorderid = f8
     2 actioninitiateddttm = dq8
     2 ivsetsynonymid = f8
     2 futureinfo[*]
       3 scheduleneworderasestimated[*]
         4 startdatetimeind = i2
         4 stopdatetimeind = i2
       3 changescheduletoprecise[*]
         4 startdatetimeind = i2
         4 stopdatetimeind = i2
       3 location[*]
         4 facilitycd = f8
         4 nurseunitcd = f8
       3 applystartrange[*]
         4 value = i4
         4 unit
           5 daysind = i2
           5 weeksind = i2
           5 monthsind = i2
         4 rangeanchorpoint
           5 startind = i2
           5 centerind = i2
       3 encountertypecd = f8
     2 addtoprescriptiongroup[*]
       3 relatedorderid = f8
     2 dayoftreatmentinfo[*]
       3 protocolorderid = f8
       3 dayoftreatmentsequence = i4
       3 protocolversioncheck[*]
         4 protocolversion = i4
     2 billingproviderinfo[*]
       3 orderproviderind = i2
       3 supervisingproviderind = i2
     2 tracingticket = vc
     2 lastupdateactionsequence = i4
     2 protocolinfo[*]
       3 protocoltype = i2
     2 incompletetopharmacy[*]
       3 neworder[*]
         4 nosynonymmatchind = i2
         4 missingorderdetailsind = i2
       3 resolveorder[*]
         4 resolvedind = i2
     2 actionqualifiers[*]
       3 autoverificationind = i2
   1 errorlogoverrideflag = i2
   1 actionpersonnelgroupid = f8
   1 workflow[*]
     2 pharmacyind = i2
   1 trigger_app = i4
 )
 SET order_id = cnvtint( $2)
 SET action_prsnl_id = cnvtint( $3)
 SET action_type = cnvtint( $4)
 SET action_reason_cd = cnvtint( $5)
 SET action_dt_tm =  $6
 DECLARE comm_type_cd = f8 WITH protect
 DECLARE ord_provider_id = f8 WITH protect
 DECLARE ord_dt_tm = dq8
 DECLARE cur_start_dt_tm = dq8
 DECLARE oe_format_id = f8
 DECLARE catalog_type_cd = f8
 DECLARE bill_only_ind = i2
 DECLARE last_updt_cnt = i2
 DECLARE last_updt_action_seq = i2
 DECLARE depstatdispkey = vc WITH protect
 DECLARE contributor_sys_cd = maxval(0.0,uar_get_code_by("DISPLAY_KEY",89,"PRAXIFY"))
 SELECT INTO "NL:"
  FROM orders o,
   encounter e,
   order_catalog oc
  PLAN (o
   WHERE o.order_id=order_id)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
  DETAIL
   requestin->productid = o.product_id, requestin->personid = e.person_id, requestin->encntrid = e
   .encntr_id,
   requestin->passingencntrinfoind = 0, requestin->encntrfinancialid = e.encntr_financial_id,
   requestin->locationcd = e.location_cd,
   requestin->locfacilitycd = e.loc_facility_cd, requestin->locnurseunitcd = e.loc_nurse_unit_cd,
   requestin->locroomcd = e.loc_room_cd,
   requestin->locbedcd = e.loc_bed_cd, ord_dt_tm = cnvtdatetime(o.orig_order_dt_tm), cur_start_dt_tm
    = cnvtdatetime(o.current_start_dt_tm),
   oe_format_id = o.oe_format_id, catalog_type_cd = o.catalog_type_cd, bill_only_ind = oc
   .bill_only_ind,
   last_updt_cnt = o.updt_cnt, last_updt_action_seq = o.last_action_sequence
  WITH time = 10
 ;end select
 SELECT INTO "NL:"
  FROM order_action oa
  PLAN (oa
   WHERE oa.order_id=order_id
    AND oa.action_type_cd=2534)
  DETAIL
   requestin->contributorsystemcd = contributor_sys_cd, requestin->orderlocncd = oa.order_locn_cd,
   comm_type_cd = oa.communication_type_cd,
   ord_provider_id = oa.action_personnel_id
  WITH time = 10
 ;end select
 SET requestin->replyinfoflag = 0
 SET requestin->commitgroupind = 0
 SET requestin->needsatldupcheckind = 0
 SET requestin->ordersheetind = 0
 SET requestin->lockkeyid = 0
 SET stat = alterlist(requestin->orderlist,1)
 SET requestin->orderlist[1].orderid = order_id
 SET requestin->orderlist[1].actiontypecd = action_type
 SET requestin->orderlist[1].communicationtypecd = cnvtint(comm_type_cd)
 SET requestin->orderlist[1].orderproviderid = ord_provider_id
 SET requestin->orderlist[1].orderdttm = cnvtdatetime(action_dt_tm)
 SET requestin->orderlist[1].currentstartdttm = cur_start_dt_tm
 SET requestin->orderlist[1].oeformatid = oe_format_id
 SET requestin->orderlist[1].catalogtypecd = catalog_type_cd
 SELECT INTO "NL:"
  FROM orders o,
   accession_order_r aor,
   accession a
  PLAN (o
   WHERE o.order_id=order_id)
   JOIN (aor
   WHERE aor.order_id=o.order_id)
   JOIN (a
   WHERE a.accession_id=aor.accession_id)
  DETAIL
   requestin->orderlist[1].accessionnbr = a.accession, requestin->orderlist[1].accessionid = a
   .accession_id
  WITH time = 10
 ;end select
 SELECT INTO "NL:"
  FROM processing_task pt
  WHERE pt.order_id=order_id
  DETAIL
   requestin->orderlist[1].nochargeind = pt.no_charge_ind
  WITH nocounter, time = 10
 ;end select
 SET requestin->orderlist[1].billonlyind = bill_only_ind
 SET requestin->orderlist[1].lastupdtcnt = last_updt_cnt
 SET action_reason_codeset = 0
 SELECT DISTINCT INTO "NL:"
  oef2.group_seq, oef2.field_seq, oef3.codeset,
  oef4.oe_field_meaning_id, oef4.oe_field_meaning
  FROM orders o,
   order_catalog oc,
   order_catalog_synonym ocs,
   order_entry_format oef1,
   oe_format_fields oef2,
   order_entry_fields oef3,
   oe_field_meaning oef4,
   code_value cv
  PLAN (o
   WHERE o.order_id=order_id)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd)
   JOIN (oef1
   WHERE oef1.oe_format_id=ocs.oe_format_id
    AND oef1.action_type_cd=action_type)
   JOIN (oef2
   WHERE oef2.oe_format_id=oef1.oe_format_id
    AND oef2.action_type_cd=action_type)
   JOIN (oef3
   WHERE oef3.oe_field_id=oef2.oe_field_id)
   JOIN (oef4
   WHERE oef4.oe_field_meaning_id=oef3.oe_field_meaning_id)
   JOIN (cv
   WHERE cv.code_set=outerjoin(oef3.codeset)
    AND cv.code_value=outerjoin(cnvtint(action_reason_cd)))
  ORDER BY oef2.group_seq
  HEAD REPORT
   i = 0
  DETAIL
   i = (i+ 1), stat = alterlist(requestin->orderlist[1].detaillist,i)
   IF (oef3.field_type_flag=5)
    requestin->orderlist[1].detaillist[i].oefieldid = oef3.oe_field_id, requestin->orderlist[1].
    detaillist[i].oefieldvalue = 0, requestin->orderlist[1].detaillist[i].oefielddisplayvalue =
    cnvtstring(cnvtdatetime(action_dt_tm)),
    requestin->orderlist[1].detaillist[i].oefielddttmvalue = cnvtdatetime(action_dt_tm), requestin->
    orderlist[1].detaillist[i].oefieldmeaning = oef4.oe_field_meaning, requestin->orderlist[1].
    detaillist[i].oefieldmeaningid = oef4.oe_field_meaning_id,
    requestin->orderlist[1].detaillist[i].valuerequiredind = oef2.accept_flag, requestin->orderlist[1
    ].detaillist[i].groupseq = oef2.group_seq, requestin->orderlist[1].detaillist[i].fieldseq = oef2
    .field_seq,
    requestin->orderlist[1].detaillist[i].modifiedind = 1
   ELSEIF (oef3.field_type_flag=6)
    requestin->orderlist[1].detaillist[i].oefieldid = oef3.oe_field_id, requestin->orderlist[1].
    detaillist[i].oefieldvalue = cnvtint(action_reason_cd), requestin->orderlist[1].detaillist[i].
    oefielddisplayvalue = cv.display,
    requestin->orderlist[1].detaillist[i].oefieldmeaning = oef4.oe_field_meaning, requestin->
    orderlist[1].detaillist[i].oefieldmeaningid = oef4.oe_field_meaning_id, requestin->orderlist[1].
    detaillist[i].valuerequiredind = oef2.accept_flag,
    requestin->orderlist[1].detaillist[i].groupseq = oef2.group_seq, requestin->orderlist[1].
    detaillist[i].fieldseq = oef2.field_seq, requestin->orderlist[1].detaillist[i].modifiedind = 1
   ENDIF
  WITH time = 10
 ;end select
 SET stat = alterlist(requestin->orderlist[1].misclist,0)
 SET stat = alterlist(requestin->orderlist[1].prompttestlist,0)
 SET stat = alterlist(requestin->orderlist[1].commentlist,0)
 SET stat = alterlist(requestin->orderlist[1].reviewlist,0)
 SELECT INTO "NL:"
  FROM orders o,
   order_catalog_synonym ocs,
   encounter e
  PLAN (o
   WHERE o.order_id=order_id)
   JOIN (ocs
   WHERE ocs.synonym_id=o.synonym_id
    AND ocs.mnemonic_type_cd=2583)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
  DETAIL
   requestin->orderlist[1].deptmiscline = o.dept_misc_line, requestin->orderlist[1].catalogcd = o
   .catalog_cd, requestin->orderlist[1].synonymid = o.synonym_id,
   requestin->orderlist[1].ordermnemonic = o.order_mnemonic, requestin->orderlist[1].
   passingorcinfoind = 0, requestin->orderlist[1].primarymnemonic = ocs.mnemonic,
   requestin->orderlist[1].activitytypecd = ocs.activity_type_cd, requestin->orderlist[1].
   activitysubtypecd = ocs.activity_subtype_cd, requestin->orderlist[1].completeuponorderind = 0,
   requestin->orderlist[1].orderreviewind = 1, requestin->orderlist[1].printreqind = 0, requestin->
   orderlist[1].requisitionformatcd = 0,
   requestin->orderlist[1].requisitionroutingcd = 0, requestin->orderlist[1].consentformind = 0,
   requestin->orderlist[1].consentformformatcd = 0,
   requestin->orderlist[1].consentformroutingcd = 0, requestin->orderlist[1].deptdupcheckind = 0,
   requestin->orderlist[1].dupcheckingind = 0,
   requestin->orderlist[1].deptdisplayname = "", requestin->orderlist[1].reftextmask = 0, requestin->
   orderlist[1].abnreviewind = 0,
   requestin->orderlist[1].reviewhierarchyid = 0, requestin->orderlist[1].dcpclincatcd = o
   .dcp_clin_cat_cd, requestin->orderlist[1].cki = o.cki,
   requestin->orderlist[1].stoptypecd = o.stop_type_cd, requestin->orderlist[1].needsintervalcalcind
    = 0, requestin->orderlist[1].templateorderflag = o.template_order_flag,
   requestin->orderlist[1].templateorderid = 0.00, requestin->orderlist[1].grouporderflag = o
   .group_order_flag, requestin->orderlist[1].linkorderflag = o.link_order_flag,
   requestin->orderlist[1].linktypecd = o.link_type_flag, requestin->orderlist[1].origordasflag = o
   .orig_ord_as_flag, requestin->orderlist[1].schstatecd = o.sch_state_cd,
   requestin->orderlist[1].discontinuetypecd = o.discontinue_type_cd, requestin->orderlist[1].rxmask
    = o.rx_mask, requestin->orderlist[1].scheventid = 0.00,
   requestin->orderlist[1].encntrid = o.encntr_id, requestin->orderlist[1].passingencntrinfoind = 1,
   requestin->orderlist[1].encntrfinancialid = o.encntr_financial_id,
   requestin->orderlist[1].locationcd = e.location_cd, requestin->orderlist[1].locfacilitycd = e
   .loc_facility_cd, requestin->orderlist[1].locnurseunitcd = e.loc_nurse_unit_cd,
   requestin->orderlist[1].locroomcd = e.loc_room_cd, requestin->orderlist[1].locbedcd = e.loc_bed_cd,
   requestin->orderlist[1].medordertypecd = o.med_order_type_cd,
   requestin->orderlist[1].undoactiontypecd = 0.00, requestin->orderlist[1].orderedasmnemonic = o
   .ordered_as_mnemonic, requestin->orderlist[1].getlatestdetailsind = 0,
   requestin->orderlist[1].studentactiontypecd = 0
  WITH time = 10
 ;end select
 IF (action_type=2532)
  SET depstatdispkey = "DISCONTINUED"
  SET ordstatcd = 2545
 ELSEIF (action_type=2526)
  SET depstatdispkey = "CANCELED"
  SET ordstatcd = 2542
 ELSEIF (action_type=2530)
  SET depstatdispkey = "DELETED"
  SET ordstatcd = 2544
 ELSEIF (action_type=2540)
  SET disp_key = ""
  SELECT INTO "NL:"
   disp_key = uar_get_displaykey(oa.dept_status_cd)
   FROM order_action oa
   WHERE oa.order_id=order_id
    AND oa.action_sequence=1
   DETAIL
    depstatdispkey = disp_key
   WITH nocounter
  ;end select
  SET ordstatcd = 2552
 ELSEIF (action_type=2537)
  SET depstatdispkey = "ORDERED"
  SET ordstatcd = 2550
 ENDIF
 SET requestin->orderlist[1].orderstatuscd = ordstatcd
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=14281
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.display_key=depstatdispkey
  DETAIL
   requestin->orderlist[1].deptstatuscd = cv.code_value
  WITH nocounter, time = 10
 ;end select
 SELECT INTO "NL:"
  FROM order_alias oa
  PLAN (oa
   WHERE oa.order_id=order_id)
  HEAD REPORT
   i = 0
  DETAIL
   i = (i+ 1), stat = alterlist(requestin->orderlist[1].aliaslist,i), requestin->orderlist[1].
   aliaslist[i].alias = oa.alias,
   requestin->orderlist[1].aliaslist[i].orderaliastypecd = oa.order_alias_type_cd, requestin->
   orderlist[1].aliaslist[i].orderaliassubtypecd = oa.order_alias_sub_type_cd, requestin->orderlist[1
   ].aliaslist[i].aliaspoolcd = oa.alias_pool_cd,
   requestin->orderlist[1].aliaslist[i].checkdigit = oa.check_digit, requestin->orderlist[1].
   aliaslist[i].checkdigitmethodcd = oa.check_digit_method_cd, requestin->orderlist[1].aliaslist[i].
   begeffectivedttm = oa.beg_effective_dt_tm,
   requestin->orderlist[1].aliaslist[i].endeffectivedttm = oa.end_effective_dt_tm, requestin->
   orderlist[1].aliaslist[i].datastatuscd = oa.data_status_cd, requestin->orderlist[1].aliaslist[i].
   activestatuscd = oa.active_status_cd,
   requestin->orderlist[1].aliaslist[i].activeind = oa.active_ind, requestin->orderlist[1].aliaslist[
   i].billordnbrind = oa.bill_ord_nbr_ind, requestin->orderlist[1].aliaslist[i].primarydisplayind =
   oa.primary_display_ind
  WITH time = 10, format
 ;end select
 SET stat = alterlist(requestin->orderlist[1].subcomponentlist,0)
 SET stat = alterlist(requestin->orderlist[1].resourcelist,0)
 SET stat = alterlist(requestin->orderlist[1].relationshiplist,0)
 SET stat = alterlist(requestin->orderlist[1].deptcommentlist,0)
 SET stat = alterlist(requestin->orderlist[1].adhocfreqtimelist,0)
 SET requestin->orderlist[1].ingredientreviewind = 0
 SET requestin->orderlist[1].badorderind = 0
 SET requestin->orderlist[1].origorderdttm = ord_dt_tm
 SET requestin->orderlist[1].supervisingproviderid = 0.00
 SET stat = alterlist(requestin->orderlist[1].addorderreltnlist,0)
 SET stat = alterlist(requestin->orderlist[1].scheduleexceptionlist,0)
 SET stat = alterlist(requestin->orderlist[1].inactivescheduleexceptionlist,0)
 SET requestin->orderlist[1].actioninitiateddttm = cnvtdatetime(curdate,curtime)
 SET stat = alterlist(requestin->orderlist[1].futureinfo,0)
 SET stat = alterlist(requestin->orderlist[1].addtoprescriptiongroup,0)
 SET stat = alterlist(requestin->orderlist[1].dayoftreatmentinfo,0)
 SET stat = alterlist(requestin->orderlist[1].billingproviderinfo,0)
 SET requestin->orderlist[1].lastupdateactionsequence = (last_updt_action_seq+ 1)
 SET stat = alterlist(requestin->orderlist[1].protocolinfo,0)
 SET stat = alterlist(requestin->orderlist[1].incompletetopharmacy,0)
 SET stat = alterlist(requestin->orderlist[1].actionqualifiers,0)
 SET stat = alterlist(requestin->workflow,0)
 SET requestin->trigger_app = 0
 FREE RECORD i_request
 RECORD i_request(
   1 prsnl_id = f8
 ) WITH protect
 FREE RECORD i_reply
 RECORD i_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 SET i_request->prsnl_id = (action_prsnl_id * 1.00)
 CALL echorecord(i_request)
 EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
 IF ((i_reply->status_data.status != "S"))
  CALL echo("IMPERSONATE USER FAILED!")
 ENDIF
 CALL echorecord(requestin)
 SET stat = tdbexecute(600005,500196,560201,"REC",requestin,
  "REC",replyout)
 CALL echorecord(replyout)
 SELECT INTO  $1
  FROM (dummyt d1  WITH seq = size(replyout->orderlist,5))
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  DETAIL
   v1 = concat("<CodeValue>",substring(1,10,replyout->status_data.status),"</CodeValue>"), col + 1,
   v1,
   row + 1, v2 = concat("<Display>",substring(1,439,replyout->orderlist[d1.seq].specificerrorstr),
    "</Display>"), col + 1,
   v2, row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH maxcol = 32000, nocounter, nullreport,
   formfeed = none, format = variable, time = 30
 ;end select
#exit_script
END GO
