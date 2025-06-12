CREATE PROGRAM bhs_prax_add_all_order_dg
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SET catalog_cd = cnvtint( $2)
 SET person_id = cnvtint( $3)
 SET product_id =  $4
 SET encntr_id = cnvtint( $5)
 SET action_prsnl_id = cnvtint( $6)
 SET comm_type_cd = cnvtint( $7)
 SET order_prov_id = cnvtint( $8)
 SET order_dt_tm = cnvtdatetime( $9)
 SET curr_start_dt_tm = cnvtdatetime( $10)
 SET comment_type =  $11
 SET comment_text = replace(replace(replace(replace(replace( $12,"ltpercgt","%",0),"ltampgt","&",0),
    "ltsquotgt","'",0),"ltscolgt",";",0),"ltpipgt","|",0)
 SET orig_ord_dt_tm = cnvtdatetime( $13)
 SET no_of_pairs =  $14
 SET list_params =  $15
 SET syn_id = cnvtint( $16)
 SET no_diag_pairs = cnvtint( $17)
 SET list_of_diag =  $18
 SET order_id =  $19
 DECLARE ord_action_cd_cv6003 = f8 WITH noconstant(uar_get_code_by("DISPLAYKEY",6003,"ORDER")),
 protect
 CALL echo(" Begin Add Order Main Record-------------------------")
 FREE RECORD replyout
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
 SET requestin->productid = product_id
 SET requestin->personid = person_id
 SET requestin->encntrid = encntr_id
 SET requestin->passingencntrinfoind = 0
 SET requestin->encntrfinancialid = 0.00
 SET loclocationcd = 0
 SET locfacilitycd = 0
 SET locnurseunitcd = 0
 SET locroomcd = 0
 SET locbedcd = 0
 SELECT INTO "NL:"
  FROM encounter e
  WHERE e.encntr_id=encntr_id
  DETAIL
   loclocationcd = e.location_cd, locfacilitycd = e.loc_facility_cd, locnurseunitcd = e
   .loc_nurse_unit_cd,
   locroomcd = e.loc_room_cd, locbedcd = e.loc_bed_cd
  WITH nocounter
 ;end select
 SET requestin->locationcd = loclocationcd
 SET requestin->locfacilitycd = locfacilitycd
 SET requestin->locnurseunitcd = locnurseunitcd
 SET requestin->locroomcd = locroomcd
 SET requestin->locbedcd = locbedcd
 SET requestin->actionpersonnelid = action_prsnl_id
 SET requestin->contributorsystemcd = 621179432
 SET requestin->orderlocncd = 0
 SET requestin->replyinfoflag = 0
 SET requestin->commitgroupind = 0
 SET requestin->needsatldupcheckind = 0
 SET requestin->ordersheetind = 0
 SET requestin->ordersheetprintername = ""
 SET requestin->logleveloverride = 0
 SET requestin->unlockprofileind = 0
 SET requestin->lockkeyid = 0
 SET stat = alterlist(requestin->orderlist,1)
 SET requestin->orderlist[1].orderid = order_id
 SET requestin->orderlist[1].actiontypecd = ord_action_cd_cv6003
 SET requestin->orderlist[1].communicationtypecd = comm_type_cd
 SET requestin->orderlist[1].orderproviderid = order_prov_id
 SET requestin->orderlist[1].orderdttm = order_dt_tm
 SET requestin->orderlist[1].currentstartdttm = curr_start_dt_tm
 SET oeformatid = 0.00
 SET catalogtypecd = 0.00
 SET synonymid = 0.00
 DECLARE ordermnemonic = vc
 SET activity_type_cd = 0.00
 SET activity_sub_type_cd = 0.00
 DECLARE dept_disp_name = vc
 SET dcp_clin_cat_cd = 0.00
 DECLARE cki = vc
 SET stoptypecd = 0.00
 SET rxmask = 0
 SELECT INTO "NL:"
  FROM order_catalog oc,
   order_catalog_synonym ocs
  PLAN (oc
   WHERE oc.catalog_cd=catalog_cd)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.synonym_id=syn_id)
  DETAIL
   oeformatid = oc.oe_format_id, catalogtypecd = oc.catalog_type_cd, synonymid = ocs.synonym_id,
   ordermnemonic = ocs.mnemonic, activity_type_cd = oc.activity_type_cd, activity_sub_type_cd = oc
   .activity_subtype_cd,
   dept_disp_name = oc.dept_display_name, dcp_clin_cat_cd = oc.dcp_clin_cat_cd, cki = oc.cki,
   stoptypecd = oc.stop_type_cd, rxmask = ocs.rx_mask, requestin->orderlist[1].billonlyind = oc
   .bill_only_ind
  WITH nocounter
 ;end select
 SET requestin->orderlist[1].oeformatid = oeformatid
 SET requestin->orderlist[1].catalogtypecd = catalogtypecd
 SET requestin->orderlist[1].nochargeind = 0
 SET requestin->orderlist[1].lastupdtcnt = 0
 DECLARE freqcd = f8
 DECLARE frqtypeflag = i4
 SUBROUTINE freqtype(freqcd)
   SELECT INTO "NL:"
    FROM frequency_schedule fs
    WHERE fs.frequency_cd=freqcd
     AND fs.activity_type_cd=activity_type_cd
    DETAIL
     frqtypeflag =
     IF (fs.frequency_type != 4) 1
     ELSE 0
     ENDIF
    WITH nocounter, time = 05
   ;end select
 END ;Subroutine
 DECLARE coll = f8
 DECLARE freqind = f8
 DECLARE frqtypeflag1 = i4
 DECLARE collacceptflag = c20
 SET coll = 2
 SET freqind = 2
 SET frqtypeflag1 = 2
 SET collacceptflag = "xx"
 SET no_of_od_pairs = no_of_pairs
 SET param_list = replace(replace(replace(replace(replace(list_params,"ltpercgt","%",0),"ltampgt",
     "&",0),"ltsquotgt","'",0),"ltscolgt",";",0),"ltpipgt","|",0)
 IF (no_of_od_pairs > 0)
  FREE RECORD param
  RECORD param(
    1 qual[*]
      2 orig_string = c300
      2 oe_field_id = f8
      2 oe_field_val = f8
      2 oe_field_disp_val = c200
  )
  FOR (i = 1 TO no_of_od_pairs)
    SET stat = alterlist(param->qual,i)
    SET param->qual[i].orig_string = piece(param_list,"|",i,"N/A")
    SET param->qual[i].oe_field_id = cnvtint(substring(1,(findstring(";",param->qual[i].orig_string,0
       ) - 1),param->qual[i].orig_string))
    SET param->qual[i].oe_field_val = cnvtint(substring((findstring(";",param->qual[i].orig_string,1,
       0)+ 1),(findstring(";",param->qual[i].orig_string,1,1) - (findstring(";",param->qual[i].
       orig_string,1,0)+ 1)),param->qual[i].orig_string))
    SET param->qual[i].oe_field_disp_val = substring((findstring(";",param->qual[i].orig_string,size(
       substring(1,(findstring(";",param->qual[i].orig_string,0) - 1),param->qual[i].orig_string)),1)
     + 1),size(param->qual[i].orig_string),param->qual[i].orig_string)
    IF ((param->qual[i].oe_field_id=12766))
     IF ((param->qual[i].oe_field_disp_val="Yes"))
      SET coll = 1
     ELSEIF ((param->qual[i].oe_field_disp_val="No"))
      SET coll = 0
     ENDIF
    ELSE
     IF ( NOT (coll IN (0, 1)))
      SET coll = 2
     ENDIF
    ENDIF
    IF ((param->qual[i].oe_field_id=12690))
     CALL freqtype(param->qual[i].oe_field_val)
     SET frqtypeflag1 = frqtypeflag
     SET freqind = 1
    ELSE
     IF (freqind != 1)
      SET freqind = 0
     ENDIF
    ENDIF
  ENDFOR
 ELSE
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "NL:"
  oef4.oe_field_meaning, oef4.oe_field_meaning_id
  FROM (dummyt d1  WITH seq = size(param->qual,5)),
   order_catalog oc,
   order_catalog_synonym ocs,
   order_entry_format oef1,
   oe_format_fields oef2,
   order_entry_fields oef3,
   oe_field_meaning oef4
  PLAN (oc
   WHERE oc.catalog_cd=catalog_cd
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.synonym_id=syn_id)
   JOIN (oef1
   WHERE oef1.oe_format_id=oc.oe_format_id
    AND oef1.action_type_cd=2534)
   JOIN (oef2
   WHERE oef2.oe_format_id=oef1.oe_format_id)
   JOIN (d1
   WHERE (param->qual[d1.seq].oe_field_id=oef2.oe_field_id))
   JOIN (oef3
   WHERE (oef3.oe_field_id=param->qual[d1.seq].oe_field_id))
   JOIN (oef4
   WHERE oef4.oe_field_meaning_id=oef3.oe_field_meaning_id)
  HEAD REPORT
   i = 0
  DETAIL
   i = (i+ 1), stat = alterlist(requestin->orderlist[1].detaillist,i), requestin->orderlist[1].
   detaillist[i].oefieldid = param->qual[d1.seq].oe_field_id,
   requestin->orderlist[1].detaillist[i].oefieldvalue = param->qual[d1.seq].oe_field_val, requestin->
   orderlist[1].detaillist[i].oefielddisplayvalue = replace(replace(param->qual[d1.seq].
     oe_field_disp_val,"ltscolgt",";",0),"ltpipgt","|",0)
   IF (oef3.field_type_flag=5)
    requestin->orderlist[1].detaillist[i].oefielddttmvalue = cnvtdatetime(param->qual[d1.seq].
     oe_field_disp_val)
   ELSEIF (oef3.field_type_flag=3)
    requestin->orderlist[1].detaillist[i].oefielddttmvalue = cnvtdatetime(substring(1,11,param->qual[
      d1.seq].oe_field_disp_val))
   ELSE
    requestin->orderlist[1].detaillist[i].oefielddttmvalue = 0
   ENDIF
   requestin->orderlist[1].detaillist[i].oefieldmeaning = oef4.oe_field_meaning, requestin->
   orderlist[1].detaillist[i].oefieldmeaningid = oef4.oe_field_meaning_id, requestin->orderlist[1].
   detaillist[i].valuerequiredind = oef2.accept_flag
   IF ((requestin->orderlist[1].detaillist[i].oefieldid=12766)
    AND (requestin->orderlist[1].detaillist[i].valuerequiredind=2))
    collacceptflag = "DisplayOnly"
   ENDIF
   requestin->orderlist[1].detaillist[i].groupseq = oef2.group_seq, requestin->orderlist[1].
   detaillist[i].fieldseq = oef2.field_seq, requestin->orderlist[1].detaillist[i].modifiedind = 1
  WITH time = 10, format, separator = " "
 ;end select
 SET stat = alterlist(requestin->orderlist[1].misclist,0)
 SET stat = alterlist(requestin->orderlist[1].prompttestlist,0)
 IF (textlen(trim(comment_text,3)) > 0)
  SET stat = alterlist(requestin->orderlist[1].commentlist,1)
  SET requestin->orderlist[1].commentlist[1].commenttype = comment_type
  SET requestin->orderlist[1].commentlist[1].commenttext = comment_text
 ELSE
  SET stat = alterlist(requestin->orderlist[1].commentlist,0)
 ENDIF
 SET requestin->orderlist[1].catalogcd = catalog_cd
 SET requestin->orderlist[1].synonymid = synonymid
 SET requestin->orderlist[1].ordermnemonic = ordermnemonic
 SET requestin->orderlist[1].passingorcinfoind = 0
 SET requestin->orderlist[1].primarymnemonic = ordermnemonic
 SET requestin->orderlist[1].activitytypecd = activity_type_cd
 SET requestin->orderlist[1].activitysubtypecd = activity_sub_type_cd
 SELECT INTO "NL:"
  FROM order_catalog oc
  WHERE oc.catalog_cd=catalog_cd
   AND oc.active_ind=1
  DETAIL
   requestin->orderlist[1].contordermethodflag = oc.cont_order_method_flag, requestin->orderlist[1].
   completeuponorderind = oc.complete_upon_order_ind, requestin->orderlist[1].orderreviewind = oc
   .order_review_ind,
   requestin->orderlist[1].printreqind = oc.print_req_ind, requestin->orderlist[1].
   requisitionformatcd = oc.requisition_format_cd, requestin->orderlist[1].requisitionroutingcd = oc
   .requisition_routing_cd,
   requestin->orderlist[1].resourceroutelevel = oc.resource_route_lvl, requestin->orderlist[1].
   consentformind = oc.consent_form_ind, requestin->orderlist[1].consentformformatcd = oc
   .consent_form_format_cd,
   requestin->orderlist[1].consentformroutingcd = oc.consent_form_routing_cd, requestin->orderlist[1]
   .deptdupcheckind = oc.dept_dup_check_ind, requestin->orderlist[1].dupcheckingind = oc
   .dup_checking_ind,
   requestin->orderlist[1].reftextmask = oc.ref_text_mask, requestin->orderlist[1].abnreviewind = oc
   .abn_review_ind, requestin->orderlist[1].reviewhierarchyid = oc.review_hierarchy_id,
   requestin->orderlist[1].orderabletypeflag = oc.orderable_type_flag
  WITH time = 10
 ;end select
 SET requestin->orderlist[1].needsintervalcalcind = 0
 SET requestin->orderlist[1].templateorderflag = 0
 SET requestin->orderlist[1].templateorderid = 0.00
 SET requestin->orderlist[1].grouporderflag = 0
 SET requestin->orderlist[1].groupcompcount = 0
 SET requestin->orderlist[1].linkorderflag = 0
 SET requestin->orderlist[1].linkcompcount = 0
 SET requestin->orderlist[1].linktypecd = 0.00
 SET requestin->orderlist[1].linkelementflag = 0
 SET requestin->orderlist[1].linkelementcd = 0.00
 SET requestin->orderlist[1].processingflag = 0
 SET requestin->orderlist[1].origordasflag = 0
 SET requestin->orderlist[1].deptdisplayname = dept_disp_name
 SET requestin->orderlist[1].dcpclincatcd = dcp_clin_cat_cd
 SET requestin->orderlist[1].cki = cki
 SET requestin->orderlist[1].stoptypecd = stoptypecd
 SET requestin->orderlist[1].stopduration = 0.00
 SET requestin->orderlist[1].stopdurationunitcd = 0.00
 SET requestin->orderlist[1].orderstatuscd = 2550
 CALL echo(freqind)
 CALL echo(frqtypeflag1)
 IF (catalogtypecd=2513)
  IF (coll=1)
   SET requestin->orderlist[1].deptstatuscd = 9311
  ELSEIF (coll=0)
   IF (freqind=1)
    SET requestin->orderlist[1].deptstatuscd = 9328
   ELSEIF (freqind != 1
    AND collacceptflag != "DisplayOnly")
    SET requestin->orderlist[1].deptstatuscd = 625501
   ELSE
    SET requestin->orderlist[1].deptstatuscd = 9328
   ENDIF
  ELSE
   SET requestin->orderlist[1].deptstatuscd = 9328
  ENDIF
 ELSEIF (catalogtypecd=2517)
  IF (freqind=1
   AND frqtypeflag1=1)
   SET requestin->orderlist[1].deptstatuscd = 9328
  ELSE
   SET requestin->orderlist[1].deptstatuscd = 9317
  ENDIF
 ELSE
  SET requestin->orderlist[1].deptstatuscd = 9328
 ENDIF
 FOR (y = 1 TO size(param->qual,5))
   IF ((param->qual[y].oe_field_id=12651)
    AND (param->qual[y].oe_field_val=1))
    SET requestin->orderlist[1].orderstatuscd = 2546
    SET requestin->orderlist[1].deptstatuscd = 9327
   ENDIF
 ENDFOR
 SET requestin->orderlist[1].discontinuetypecd = 0.00
 SET requestin->orderlist[1].rxmask = rxmask
 SET requestin->orderlist[1].scheventid = 0.00
 SET requestin->orderlist[1].encntrid = encntr_id
 SET requestin->orderlist[1].passingencntrinfoind = 0
 SET requestin->orderlist[1].encntrfinancialid = 0.00
 SET requestin->orderlist[1].locationcd = loclocationcd
 SET requestin->orderlist[1].locfacilitycd = locfacilitycd
 SET requestin->orderlist[1].locnurseunitcd = locnurseunitcd
 SET requestin->orderlist[1].locroomcd = locroomcd
 SET requestin->orderlist[1].locbedcd = locbedcd
 SET requestin->orderlist[1].medordertypecd = 0
 SET requestin->orderlist[1].undoactiontypecd = 0
 SET requestin->orderlist[1].orderedasmnemonic = ordermnemonic
 SET requestin->orderlist[1].getlatestdetailsind = 0
 SET requestin->orderlist[1].studentactiontypecd = 0.00
 SET stat = alterlist(requestin->orderlist[1].aliaslist,0)
 SET stat = alterlist(requestin->orderlist[1].subcomponentlist,0)
 SET no_of_diag_pairs = no_diag_pairs
 SET diag_list = replace(replace(replace(replace(replace(list_of_diag,"ltpercgt","%",0),"ltampgt",
     "&",0),"ltsquotgt","'",0),"ltscolgt",";",0),"ltpipgt","|",0)
 IF (no_of_diag_pairs > 0)
  FREE RECORD diagn
  RECORD diagn(
    1 qual[*]
      2 orig_string = c300
      2 entity_id = f8
      2 entity_disp = c200
      2 rank_seq = i4
  )
  FOR (i = 1 TO no_of_diag_pairs)
    SET stat = alterlist(diagn->qual,i)
    SET diagn->qual[i].orig_string = piece(diag_list,"|",i,"N/A")
    SET diagn->qual[i].entity_id = cnvtint(substring(1,(findstring(";",diagn->qual[i].orig_string,0)
       - 1),diagn->qual[i].orig_string))
    SET diagn->qual[i].entity_disp = substring((findstring(";",diagn->qual[i].orig_string,1,0)+ 1),(
     findstring(";",diagn->qual[i].orig_string,1,1) - (findstring(";",diagn->qual[i].orig_string,1,0)
     + 1)),diagn->qual[i].orig_string)
    SET diagn->qual[i].rank_seq = cnvtint(substring((findstring(";",diagn->qual[i].orig_string,1,1)+
      1),size(trim(diagn->qual[i].orig_string,3)),diagn->qual[i].orig_string))
  ENDFOR
  SET stat = alterlist(requestin->orderlist[1].relationshiplist,1)
  SET requestin->orderlist[1].relationshiplist[1].relationshipmeaning = "ORDERS/DIAGN"
  SET requestin->orderlist[1].relationshiplist[1].inactivateallind = 0
  FOR (z = 1 TO size(diagn->qual,5))
    SET stat = alterlist(requestin->orderlist[1].relationshiplist[1].valuelist,z)
    SET requestin->orderlist[1].relationshiplist[1].valuelist[z].entityid = diagn->qual[z].entity_id
    SET requestin->orderlist[1].relationshiplist[1].valuelist[z].entitydisplay = diagn->qual[z].
    entity_disp
    SET requestin->orderlist[1].relationshiplist[1].valuelist[z].ranksequence = diagn->qual[z].
    rank_seq
  ENDFOR
 ELSE
  SET stat = alterlist(requestin->orderlist[1].relationshiplist,0)
 ENDIF
 SET stat = alterlist(requestin->orderlist[1].misclongtextlist,0)
 SET stat = alterlist(requestin->orderlist[1].deptcommentlist,0)
 SET stat = alterlist(requestin->orderlist[1].adhocfreqtimelist,0)
 SET requestin->orderlist[1].ingredientreviewind = 0
 SET requestin->orderlist[1].taskstatusreasonmean = 0
 SET requestin->orderlist[1].badorderind = 0
 SET requestin->orderlist[1].origorderdttm = orig_ord_dt_tm
 SET requestin->orderlist[1].validdosedttm = null
 SET requestin->orderlist[1].linknbr = 0.00
 SET requestin->orderlist[1].linktypeflag = 0
 SET requestin->orderlist[1].supervisingproviderid = 0.00
 SET requestin->orderlist[1].bypassprescriptionreqprinting = 1
 SET requestin->orderlist[1].pathwaycatalogid = 0.00
 SET requestin->orderlist[1].actionqualifiercd = 0.00
 SET requestin->orderlist[1].acceptproposalid = 0.00
 SET stat = alterlist(requestin->orderlist[1].addorderreltnlist,0)
 SET stat = alterlist(requestin->orderlist[1].scheduleexceptionlist,0)
 SET stat = alterlist(requestin->orderlist[1].inactivescheduleexceptionlist,0)
 SET requestin->orderlist[1].actioninitiateddttm = cnvtdatetime(curdate,curtime)
 SET requestin->orderlist[1].ivsetsynonymid = 0.00
 SET stat = alterlist(requestin->orderlist[1].addtoprescriptiongroup,0)
 SET stat = alterlist(requestin->orderlist[1].dayoftreatmentinfo,0)
 SET stat = alterlist(requestin->orderlist[1].billingproviderinfo,0)
 SET requestin->orderlist[1].lastupdateactionsequence = 0
 SET stat = alterlist(requestin->orderlist[1].protocolinfo,0)
 SET stat = alterlist(requestin->orderlist[1].incompletetopharmacy,0)
 SET stat = alterlist(requestin->orderlist[1].actionqualifiers,0)
 SET requestin->errorlogoverrideflag = 1
 SET requestin->actionpersonnelgroupid = 0.00
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
 EXECUTE bhs_prax_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
 IF ((i_reply->status_data.status != "S"))
  CALL echo("IMPERSONATE USER FAILED!")
 ENDIF
 SET stat = tdbexecute(600005,500196,560201,"REC",requestin,
  "REC",replyout)
 CALL echorecord(replyout)
 CALL echo("End Add Order Main Record---------------------------")
#exit_script
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
   row + 1, v2 = concat("<Display>",trim(substring(1,439,replyout->specificerrorstr),3),"</Display>"),
   col + 1,
   v2, row + 1, v3 = build("<OrderId>",replyout->orderlist[d1.seq].orderid,"</OrderId>"),
   col + 1, v3, row + 1
  FOOT REPORT
   row + 1, col + 1, "</ReplyMessage>",
   row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 30
 ;end select
 FREE RECORD param
 FREE RECORD diagn
 FREE RECORD requestin
END GO
