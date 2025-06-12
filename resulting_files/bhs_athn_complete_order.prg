CREATE PROGRAM bhs_athn_complete_order
 FREE RECORD result
 RECORD result(
   1 encntr_id = f8
   1 person_id = f8
   1 catalog_cd = f8
   1 synonym_id = f8
   1 catalog_type_cd = f8
   1 oe_format_id = f8
   1 activity_type_cd = f8
   1 activity_subtype_cd = f8
   1 communication_type_cd = f8
   1 order_provider_id = f8
   1 need_nurse_review_ind = i2
   1 dcp_clin_cat_cd = f8
   1 ref_text_mask = i4
   1 abn_review_ind = i2
   1 review_hierarchy_id = f8
   1 dept_display_name = vc
   1 primary_mnemonic = vc
   1 cont_order_method_flag = i2
   1 dept_misc_line = vc
   1 print_req_ind = i2
   1 complete_upon_order_ind = i2
   1 requisition_format_cd = f8
   1 requisition_routing_cd = f8
   1 resource_route_lvl = i4
   1 consent_form_ind = i2
   1 consent_form_format_cd = f8
   1 consent_form_routing_cd = f8
   1 dept_dup_check_ind = i2
   1 dup_checking_ind = i2
   1 orderable_type_flag = i2
   1 dcp_clin_cat_cd = f8
   1 concept_cki = vc
   1 stop_type_cd = f8
   1 stop_duration = i4
   1 stop_duration_unit_cd = f8
   1 last_action_sequence = i4
   1 ordered_as_mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req560201
 RECORD req560201(
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
     2 originatingencounterid = f8
   1 errorlogoverrideflag = i2
   1 actionpersonnelgroupid = f8
   1 workflow[*]
     2 pharmacyind = i2
   1 trigger_app = i4
 ) WITH protect
 FREE RECORD rep560201
 RECORD rep560201(
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
 ) WITH protect
 DECLARE callorderwrite(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID ENCOUNTER ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $4 <= 0.0))
  CALL echo("INVALID ORDER ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET result->encntr_id =  $2
 SELECT INTO "NL:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=result->encntr_id)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < sysdate
    AND e.end_effective_dt_tm > sysdate)
  ORDER BY e.person_id
  HEAD e.person_id
   result->person_id = e.person_id
  WITH nocounter, time = 30
 ;end select
 DECLARE c_order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 SELECT INTO "NL:"
  FROM orders o,
   order_catalog oc,
   order_action oa
  PLAN (o
   WHERE (o.order_id= $4))
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd
    AND oc.active_ind=1)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=c_order_cd)
  ORDER BY o.order_id, oa.order_action_id DESC
  HEAD o.order_id
   result->catalog_type_cd = o.catalog_type_cd, result->oe_format_id = o.oe_format_id, result->
   catalog_cd = o.catalog_cd,
   result->synonym_id = o.synonym_id, result->need_nurse_review_ind = o.need_nurse_review_ind, result
   ->dcp_clin_cat_cd = o.dcp_clin_cat_cd,
   result->ref_text_mask = o.ref_text_mask, result->dept_misc_line = o.dept_misc_line, result->
   last_action_sequence = o.last_action_sequence,
   result->ordered_as_mnemonic = o.ordered_as_mnemonic
  HEAD oc.catalog_cd
   result->abn_review_ind = oc.abn_review_ind, result->review_hierarchy_id = oc.review_hierarchy_id,
   result->dept_display_name = oc.dept_display_name,
   result->primary_mnemonic = oc.primary_mnemonic, result->activity_type_cd = oc.activity_type_cd,
   result->activity_subtype_cd = oc.activity_subtype_cd,
   result->cont_order_method_flag = oc.cont_order_method_flag, result->print_req_ind = oc
   .print_req_ind, result->complete_upon_order_ind = oc.complete_upon_order_ind,
   result->requisition_format_cd = oc.requisition_format_cd, result->requisition_routing_cd = oc
   .requisition_routing_cd, result->resource_route_lvl = oc.resource_route_lvl,
   result->consent_form_ind = oc.consent_form_ind, result->consent_form_format_cd = oc
   .consent_form_format_cd, result->consent_form_routing_cd = oc.consent_form_routing_cd,
   result->dept_dup_check_ind = oc.dept_dup_check_ind, result->dup_checking_ind = oc.dup_checking_ind,
   result->orderable_type_flag = oc.orderable_type_flag,
   result->dcp_clin_cat_cd = oc.dcp_clin_cat_cd, result->concept_cki = oc.concept_cki, result->
   stop_type_cd = oc.stop_type_cd,
   result->stop_duration = oc.stop_duration, result->stop_duration_unit_cd = oc.stop_duration_unit_cd
  HEAD oa.order_id
   result->communication_type_cd = oa.communication_type_cd, result->order_provider_id = oa
   .action_personnel_id
  WITH nocounter, time = 30
 ;end select
 SET stat = callorderwrite(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1, col + 1,
    "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req560201
 FREE RECORD rep560201
 FREE RECORD i_request
 FREE RECORD i_reply
 SUBROUTINE callorderwrite(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(500196)
   DECLARE requestid = i4 WITH constant(560201)
   DECLARE c_complete_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"COMPLETE"))
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
   SET i_request->prsnl_id =  $3
   CALL echorecord(i_request)
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   SET req560201->personid = result->person_id
   SET req560201->replyinfoflag = 1
   SET stat = alterlist(req560201->orderlist,1)
   SET req560201->orderlist[1].orderid =  $4
   SET req560201->orderlist[1].actiontypecd = c_complete_cd
   SET req560201->orderlist[1].communicationtypecd = result->communication_type_cd
   SET req560201->orderlist[1].orderproviderid =  $3
   SET req560201->orderlist[1].orderdttm = cnvtdatetime( $5)
   SET req560201->orderlist[1].oeformatid = result->oe_format_id
   SET req560201->orderlist[1].catalogtypecd = result->catalog_type_cd
   SET req560201->orderlist[1].deptmiscline = result->dept_misc_line
   SET req560201->orderlist[1].catalogcd = result->catalog_cd
   SET req560201->orderlist[1].synonymid = result->synonym_id
   SET req560201->orderlist[1].primarymnemonic = result->primary_mnemonic
   SET req560201->orderlist[1].activitytypecd = result->activity_type_cd
   SET req560201->orderlist[1].activitysubtypecd = result->activity_subtype_cd
   SET req560201->orderlist[1].contordermethodflag = result->cont_order_method_flag
   SET req560201->orderlist[1].completeuponorderind = result->complete_upon_order_ind
   SET req560201->orderlist[1].orderreviewind = result->need_nurse_review_ind
   SET req560201->orderlist[1].printreqind = result->print_req_ind
   SET req560201->orderlist[1].requisitionformatcd = result->requisition_format_cd
   SET req560201->orderlist[1].requisitionroutingcd = result->requisition_routing_cd
   SET req560201->orderlist[1].resourceroutelevel = result->resource_route_lvl
   SET req560201->orderlist[1].consentformind = result->consent_form_ind
   SET req560201->orderlist[1].consentformformatcd = result->consent_form_format_cd
   SET req560201->orderlist[1].consentformroutingcd = result->consent_form_routing_cd
   SET req560201->orderlist[1].deptdupcheckind = result->dept_dup_check_ind
   SET req560201->orderlist[1].dupcheckingind = result->dup_checking_ind
   SET req560201->orderlist[1].deptdisplayname = result->dept_display_name
   SET req560201->orderlist[1].reftextmask = result->ref_text_mask
   SET req560201->orderlist[1].abnreviewind = result->abn_review_ind
   SET req560201->orderlist[1].reviewhierarchyid = result->review_hierarchy_id
   SET req560201->orderlist[1].orderabletypeflag = result->orderable_type_flag
   SET req560201->orderlist[1].dcpclincatcd = result->dcp_clin_cat_cd
   SET req560201->orderlist[1].cki = result->concept_cki
   SET req560201->orderlist[1].stoptypecd = result->stop_type_cd
   SET req560201->orderlist[1].stopduration = result->stop_duration
   SET req560201->orderlist[1].stopdurationunitcd = result->stop_duration_unit_cd
   SET req560201->orderlist[1].encntrid = result->encntr_id
   SET req560201->orderlist[1].orderedasmnemonic = result->ordered_as_mnemonic
   SET req560201->orderlist[1].lastupdateactionsequence = result->last_action_sequence
   SET req560201->errorlogoverrideflag = 1
   CALL echorecord(req560201)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req560201,
    "REC",rep560201,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep560201)
   IF ((rep560201->status_data.status="S"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
