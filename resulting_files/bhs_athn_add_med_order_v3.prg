CREATE PROGRAM bhs_athn_add_med_order_v3
 FREE RECORD result
 RECORD result(
   1 encntr_id = f8
   1 person_id = f8
   1 organization_id = f8
   1 cont_order_method_flag = i2
   1 rx_mask = i4
   1 intermittent_ind = i2
   1 primary_mnemonic = vc
   1 synonym_mnemonic = vc
   1 orderable_type_flag = i2
   1 strength_dose = f8
   1 strength_dose_disp = vc
   1 strength_dose_unit = f8
   1 strength_dose_unit_disp = vc
   1 volume_dose = f8
   1 volume_dose_disp = vc
   1 volume_dose_unit = f8
   1 volume_dose_unit_disp = vc
   1 free_text_dose = vc
   1 route_disp = vc
   1 frequency_disp = vc
   1 adhoc_frequency_ind = i2
   1 prn_ind = i2
   1 prn_reason = vc
   1 prn_instructions = vc
   1 treatment_period_disp = vc
   1 dose_disp = vc
   1 dose_form_disp = vc
   1 dept_misc_line = vc
   1 pref_dosage_form_position = vc
   1 diagnosisreltns[*]
     2 orig_string = vc
     2 diagnosis_id = f8
     2 display = vc
     2 rank_sequence = i4
   1 order_comment = vc
   1 order_id = f8
   1 synonym_id = f8
   1 error_message = vc
   1 subcomponents[*]
     2 catalog_cd = f8
     2 synonym_id = f8
     2 str_dose = f8
     2 str_dose_unit_cd = f8
     2 vol_dose = f8
     2 vol_dose_unit_cd = f8
     2 free_text_dose = vc
     2 frequency_cd = f8
     2 normalized_rate = f8
     2 normalized_rate_unit_cd = f8
     2 concentration = f8
     2 concentration_unit_cd = f8
     2 ordered_dose = f8
     2 ordered_dose_unit_cd = f8
     2 cont_order_method_flag = i4
     2 primary_mnemonic = vc
     2 rx_mask = i4
     2 intermittent_ind = i2
     2 synonym_mnemonic = vc
     2 orderable_type_flag = i2
     2 comp_seq = i4
     2 ingredient_rate_conversion_ind = i2
     2 display_additives_first_ind = i2
     2 ingredient_type_flag = i2
     2 included_in_total_volume_flag = i2
   1 order_type_cd = f8
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
 FREE RECORD req560251
 RECORD req560251(
   1 productid = f8
   1 personid = f8
   1 encntrid = f8
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
     2 deptmiscline = vc
     2 catalogcd = f8
     2 synonymid = f8
     2 ordermnemonic = vc
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
     2 badorderind = i2
     2 origorderdttm = dq8
     2 validdosedttm = dq8
     2 useroverridetz = i4
     2 linknbr = f8
     2 linktypeflag = i2
     2 digitalsignatureident = c64
     2 bypassprescriptionreqprinting = i2
     2 pathwaycatalogid = f8
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
         4 sourcemodifiers[*]
           5 scheduledappointmentlocationind = i2
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
       3 applyprotocolupdate[*]
         4 treatmentperioddisplay = vc
     2 billingproviderinfo[*]
       3 orderproviderind = i2
       3 supervisingproviderind = i2
     2 actionqualifiercd = f8
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
 ) WITH protect
 FREE RECORD rep560251
 RECORD rep560251(
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
     2 simplifieddisplayline = vc
     2 errorreasoncd = f8
     2 lastactionsequence = i4
   1 status_data
     2 status = vc
     2 subeventstatus[*]
       3 operationname = vc
       3 operationstatus = vc
       3 targetobjectname = vc
       3 targetobjectvalue = vc
   1 errornbr = i4
   1 errorstr = vc
   1 specificerrornbr = i4
   1 specificerrorstr = vc
   1 transactionstatus = i2
 ) WITH protect
 FREE RECORD req3011001
 RECORD req3011001(
   1 module_dir = vc
   1 module_name = vc
   1 basblob = i2
 ) WITH protect
 FREE RECORD rep3011001
 RECORD rep3011001(
   1 info_line[*]
     2 new_line = vc
   1 data_blob = gvc
   1 data_blob_size = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE calladdorder(null) = i2
 DECLARE calladdorderautoverify(null) = i2
 DECLARE sortsubcomponents(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE sdx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE ingredient_type_med = i2 WITH protect, constant(1)
 DECLARE ingredient_type_diluent = i2 WITH protect, constant(2)
 DECLARE ingredient_type_additive = i2 WITH protect, constant(3)
 DECLARE ingredient_type_compound_parent = i2 WITH protect, constant(4)
 DECLARE ingredient_type_compound_child = i2 WITH protect, constant(5)
 DECLARE not_clinically_significant = i2 WITH protect, constant(1)
 DECLARE clinically_significant = i2 WITH protect, constant(2)
 DECLARE not_included_in_total_volume = i2 WITH protect, constant(1)
 DECLARE included_in_total_volume = i2 WITH protect, constant(2)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE orderable_type_flag_normal = i4 WITH protect, constant(0)
 DECLARE orderable_type_flag_normal1 = i4 WITH protect, constant(1)
 SET result->order_id =  $6
 SET result->synonym_id =  $4
 SET result->order_type_cd =  $15
 SET result->status_data.status = "F"
 DECLARE c_praxify_cd = f8 WITH protect, constant(maxval(0.0,uar_get_code_by("DISPLAY_KEY",89,
    "PRAXIFY")))
 DECLARE c_iv_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"IV"))
 IF (( $2 <= 0.0))
  CALL echo("INVALID ENCOUNTER ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
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
   result->person_id = e.person_id, result->organization_id = e.organization_id
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "NL:"
  FROM order_catalog oc,
   order_catalog_synonym ocs
  PLAN (oc
   WHERE (oc.catalog_cd= $5)
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND (ocs.synonym_id=result->synonym_id)
    AND ocs.active_ind=1)
  ORDER BY oc.catalog_cd
  HEAD oc.catalog_cd
   result->cont_order_method_flag = oc.cont_order_method_flag, result->primary_mnemonic = oc
   .primary_mnemonic, result->rx_mask = ocs.rx_mask,
   result->intermittent_ind = ocs.intermittent_ind, result->synonym_mnemonic = ocs.mnemonic, result->
   orderable_type_flag = oc.orderable_type_flag
  WITH nocounter, time = 30
 ;end select
 IF ((result->orderable_type_flag != orderable_type_flag_normal)
  AND (result->orderable_type_flag != orderable_type_flag_normal1))
  SET result->error_message = build("INVALID ORDERABLE_TYPE_FLAG (",trim(cnvtstring(result->
     orderable_type_flag),3),") FOR CATALOG_CD (",trim(cnvtstring( $5),3),")")
  GO TO exit_script
 ELSEIF ((result->intermittent_ind=1)
  AND size(trim( $22,3)) > 0
  AND band(result->rx_mask,1) <= 0)
  SET result->error_message = "INTERMITTENT ORDERS ARE NOT SUPPORTED AT THIS TIME"
  GO TO exit_script
 ENDIF
 CALL echo("PARSING ORDER ENTRY DETAILS PARAMETER")
 FREE RECORD req_oeparse
 RECORD req_oeparse(
   1 oe_params = vc
 ) WITH protect
 FREE RECORD rep_oeparse
 RECORD rep_oeparse(
   1 detaillist[*]
     2 oefieldid = f8
     2 oefieldvalue = f8
     2 oefielddisplayvalue = vc
     2 oefielddttmvalue = dq8
     2 oefieldmeaning = vc
     2 modified_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 SET req_oeparse->oe_params = trim( $9,3)
 EXECUTE bhs_athn_parse_oe_details_v2  WITH replace("REQUEST","REQ_OEPARSE"), replace("REPLY",
  "REP_OEPARSE")
 IF ((rep_oeparse->status_data.status != "S"))
  CALL echo("PARSE_OE_DETAILS FAILED...EXITING!")
  GO TO exit_script
 ENDIF
 DECLARE diagnosiscnt = i4 WITH protect, constant(cnvtint( $18))
 DECLARE diagnosislistparam = vc WITH protect, constant(replace(replace(replace(replace(replace( $19,
       "ltpercgt","%",0),"ltampgt","&",0),"ltsquotgt","'",0),"ltscolgt",";",0),"ltpipgt","|",0))
 IF (diagnosiscnt > 0)
  SET stat = alterlist(result->diagnosisreltns,diagnosiscnt)
  FOR (idx = 1 TO diagnosiscnt)
    SET result->diagnosisreltns[idx].orig_string = piece(diagnosislistparam,"|",idx,"N/A")
    SET result->diagnosisreltns[idx].diagnosis_id = cnvtint(substring(1,(findstring(";",result->
       diagnosisreltns[idx].orig_string,0) - 1),result->diagnosisreltns[idx].orig_string))
    SET result->diagnosisreltns[idx].display = substring((findstring(";",result->diagnosisreltns[idx]
      .orig_string,1,0)+ 1),(findstring(";",result->diagnosisreltns[idx].orig_string,1,1) - (
     findstring(";",result->diagnosisreltns[idx].orig_string,1,0)+ 1)),result->diagnosisreltns[idx].
     orig_string)
    SET result->diagnosisreltns[idx].rank_sequence = cnvtint(substring((findstring(";",result->
       diagnosisreltns[idx].orig_string,1,1)+ 1),size(trim(result->diagnosisreltns[idx].orig_string,3
        )),result->diagnosisreltns[idx].orig_string))
  ENDFOR
 ENDIF
 FOR (idx = 1 TO size(rep_oeparse->detaillist,5))
   IF ((rep_oeparse->detaillist[idx].oefieldmeaning="STRENGTHDOSEUNIT"))
    SET result->strength_dose_unit = rep_oeparse->detaillist[idx].oefieldvalue
    SET result->strength_dose_unit_disp = rep_oeparse->detaillist[idx].oefielddisplayvalue
   ELSEIF ((rep_oeparse->detaillist[idx].oefieldmeaning="STRENGTHDOSE"))
    SET result->strength_dose = rep_oeparse->detaillist[idx].oefieldvalue
    SET result->strength_dose_disp = rep_oeparse->detaillist[idx].oefielddisplayvalue
   ELSEIF ((rep_oeparse->detaillist[idx].oefieldmeaning="VOLUMEDOSEUNIT"))
    SET result->volume_dose_unit = rep_oeparse->detaillist[idx].oefieldvalue
    SET result->volume_dose_unit_disp = rep_oeparse->detaillist[idx].oefielddisplayvalue
   ELSEIF ((rep_oeparse->detaillist[idx].oefieldmeaning="VOLUMEDOSE"))
    SET result->volume_dose = rep_oeparse->detaillist[idx].oefieldvalue
    SET result->volume_dose_disp = rep_oeparse->detaillist[idx].oefielddisplayvalue
   ELSEIF ((rep_oeparse->detaillist[idx].oefieldmeaning="RXROUTE"))
    SET result->route_disp = rep_oeparse->detaillist[idx].oefielddisplayvalue
   ELSEIF ((rep_oeparse->detaillist[idx].oefieldmeaning="FREQ"))
    SET result->frequency_disp = rep_oeparse->detaillist[idx].oefielddisplayvalue
   ELSEIF ((rep_oeparse->detaillist[idx].oefieldmeaning="SCH/PRN"))
    SET result->prn_ind = cnvtint(rep_oeparse->detaillist[idx].oefieldvalue)
   ELSEIF ((rep_oeparse->detaillist[idx].oefieldmeaning="PRNREASON"))
    SET result->prn_reason = rep_oeparse->detaillist[idx].oefielddisplayvalue
   ELSEIF ((rep_oeparse->detaillist[idx].oefieldmeaning="PRNINSTRUCTIONS"))
    SET result->prn_instructions = rep_oeparse->detaillist[idx].oefielddisplayvalue
   ELSEIF ((rep_oeparse->detaillist[idx].oefieldmeaning="TREATMENTPERIOD"))
    SET result->treatment_period_disp = rep_oeparse->detaillist[idx].oefielddisplayvalue
   ELSEIF ((rep_oeparse->detaillist[idx].oefieldmeaning="DRUGFORM"))
    SET result->dose_form_disp = rep_oeparse->detaillist[idx].oefielddisplayvalue
   ELSEIF ((rep_oeparse->detaillist[idx].oefieldmeaning="ADHOCFREQINSTANCE")
    AND (rep_oeparse->detaillist[idx].oefieldvalue > 0))
    SET result->adhoc_frequency_ind = 1
   ELSEIF ((rep_oeparse->detaillist[idx].oefieldmeaning="FREETXTDOSE"))
    SET result->free_text_dose = rep_oeparse->detaillist[idx].oefielddisplayvalue
   ENDIF
 ENDFOR
 IF ((result->strength_dose > 0.0)
  AND (result->volume_dose > 0.0))
  SET result->dose_disp = concat(result->strength_dose_disp," ",result->strength_dose_unit_disp," / ",
   result->volume_dose_disp,
   " ",result->volume_dose_unit_disp)
 ELSEIF ((result->volume_dose > 0.0))
  SET result->dose_disp = concat(result->volume_dose_disp," ",result->volume_dose_unit_disp)
 ELSE
  SET result->dose_disp = concat(result->strength_dose_disp," ",result->strength_dose_unit_disp)
 ENDIF
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 IF (textlen(trim( $17,3)))
  SET req_format_str->param =  $17
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET result->order_comment = rep_format_str->param
 ENDIF
 IF (size(trim( $22,3)) > 0)
  DECLARE scdetailparam = vc WITH protect, noconstant("")
  DECLARE scscblockcnt = i4 WITH protect, noconstant(0)
  DECLARE scstartpos = i4 WITH protect, noconstant(0)
  DECLARE scendpos = i4 WITH protect, noconstant(0)
  DECLARE scparam = vc WITH protect, noconstant("")
  DECLARE scblock = vc WITH protect, noconstant("")
  DECLARE scfieldcnt = i4 WITH protect, noconstant(0)
  DECLARE scfieldcntvalidind = i2 WITH protect, noconstant(0)
  FREE RECORD scblocks
  RECORD scblocks(
    1 list[*]
      2 value = vc
  ) WITH protect
  SET scstartpos = 1
  SET scdetailparam = trim( $22,3)
  WHILE (size(scdetailparam) > 0)
    SET scendpos = (findstring("|",scdetailparam,1) - 1)
    IF (scendpos <= 0)
     SET scendpos = size(scdetailparam)
    ENDIF
    CALL echo(build("SCENDPOS:",scendpos))
    IF (scstartpos < scendpos)
     SET scparam = substring(1,scendpos,scdetailparam)
     CALL echo(build("SCPARAM:",scparam))
     IF (size(scparam) > 0)
      SET scparam = replace(scparam,"-!pipe!-","|",0)
      CALL echo(build("ADDING VALUE TO LIST: ",scparam))
      SET scscblockcnt += 1
      CALL echo(build("SCSCBLOCKCNT:",scscblockcnt))
      SET stat = alterlist(scblocks->list,scscblockcnt)
      SET scblocks->list[scscblockcnt].value = scparam
     ENDIF
    ENDIF
    SET scdetailparam = substring((scendpos+ 2),(size(scdetailparam) - scendpos),scdetailparam)
    CALL echo(build("SCDETAILPARAM:",scdetailparam))
    CALL echo(build("SIZE(SCDETAILPARAM):",size(scdetailparam)))
  ENDWHILE
  SET stat = alterlist(result->subcomponents,scscblockcnt)
  FOR (idx = 1 TO scscblockcnt)
    SET scblock = scblocks->list[idx].value
    SET scfieldcnt = 0
    SET scstartpos = 0
    IF (((idx=1) OR (scfieldcntvalidind=1)) )
     SET scfieldcntvalidind = 0
     WHILE (size(scblock) > 0)
       SET scendpos = findstring(";",scblock,1)
       IF (scendpos=1)
        SET scparam = ""
        SET scblock = substring(2,(size(scblock) - 1),scblock)
        CALL echo(build("SCBLOCK:",scblock))
        CALL echo(size(scblock))
       ELSE
        SET scendpos -= 1
        IF (scendpos <= 0)
         SET scendpos = size(scblock)
        ENDIF
        CALL echo(build("SCENDPOS:",scendpos))
        IF (scstartpos < scendpos)
         SET scparam = substring(1,scendpos,scblock)
         CALL echo(build("SCPARAM:",scparam))
        ENDIF
        SET scblock = substring((scendpos+ 2),(size(scblock) - scendpos),scblock)
        CALL echo(build("SCBLOCK:",scblock))
        CALL echo(size(scblock))
       ENDIF
       SET scparam = replace(scparam,"ltscolgt",";",0)
       CALL echo(build("ADDING VALUE TO LIST: ",scparam))
       SET scfieldcnt += 1
       CALL echo(build("SCFIELDCNT:",scfieldcnt))
       IF (scfieldcnt=1)
        SET result->subcomponents[idx].catalog_cd = cnvtreal(scparam)
       ELSEIF (scfieldcnt=2)
        SET result->subcomponents[idx].synonym_id = cnvtreal(scparam)
       ELSEIF (scfieldcnt=3)
        SET result->subcomponents[idx].str_dose = cnvtreal(scparam)
       ELSEIF (scfieldcnt=4)
        SET result->subcomponents[idx].str_dose_unit_cd = cnvtreal(scparam)
       ELSEIF (scfieldcnt=5)
        SET result->subcomponents[idx].vol_dose = cnvtreal(scparam)
       ELSEIF (scfieldcnt=6)
        SET result->subcomponents[idx].vol_dose_unit_cd = cnvtreal(scparam)
       ELSEIF (scfieldcnt=7)
        IF (size(trim(scparam,3)) > 0)
         SET req_format_str->param = scparam
         EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
          "REP_FORMAT_STR")
         SET result->subcomponents[idx].free_text_dose = rep_format_str->param
        ENDIF
       ELSEIF (scfieldcnt=8)
        SET result->subcomponents[idx].frequency_cd = cnvtreal(scparam)
       ELSEIF (scfieldcnt=9)
        SET result->subcomponents[idx].normalized_rate = cnvtreal(scparam)
       ELSEIF (scfieldcnt=10)
        SET result->subcomponents[idx].normalized_rate_unit_cd = cnvtreal(scparam)
       ELSEIF (scfieldcnt=11)
        SET result->subcomponents[idx].concentration = cnvtreal(scparam)
       ELSEIF (scfieldcnt=12)
        SET result->subcomponents[idx].concentration_unit_cd = cnvtreal(scparam)
       ELSEIF (scfieldcnt=13)
        SET result->subcomponents[idx].ordered_dose = cnvtreal(scparam)
       ELSEIF (scfieldcnt=14)
        SET result->subcomponents[idx].ordered_dose_unit_cd = cnvtreal(scparam)
        SET scfieldcntvalidind = 1
       ELSEIF (scfieldcnt > 14)
        CALL echorecord(scblocks)
        CALL echo("INVALID NUMBER OF SUBCOMPONENT FIELDS (TOO MANY)...EXITING")
        CALL echo("CHECK THAT VALUES CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE")
        GO TO exit_script
       ENDIF
     ENDWHILE
    ENDIF
  ENDFOR
  IF (scfieldcntvalidind=0)
   CALL echo("INVALID NUMBER OF SUBCOMPONENT FIELDS (TOO FEW)...EXITING")
   CALL echo("CHECK THAT VALUES CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE")
   GO TO exit_script
  ENDIF
  FOR (idx = 1 TO size(result->subcomponents,5))
    SET result->subcomponents[idx].comp_seq = idx
  ENDFOR
 ENDIF
 IF (size(result->subcomponents,5) > 0)
  SELECT INTO "NL:"
   FROM order_catalog oc,
    order_catalog_synonym ocs
   PLAN (ocs
    WHERE expand(idx,1,size(result->subcomponents,5),ocs.catalog_cd,result->subcomponents[idx].
     catalog_cd,
     ocs.synonym_id,result->subcomponents[idx].synonym_id)
     AND ocs.active_ind=1)
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd
     AND oc.active_ind=1)
   ORDER BY oc.catalog_cd
   HEAD oc.catalog_cd
    pos = locateval(locidx,1,size(result->subcomponents,5),ocs.catalog_cd,result->subcomponents[
     locidx].catalog_cd,
     ocs.synonym_id,result->subcomponents[locidx].synonym_id)
    IF (pos > 0)
     result->subcomponents[pos].cont_order_method_flag = oc.cont_order_method_flag, result->
     subcomponents[pos].primary_mnemonic = oc.primary_mnemonic, result->subcomponents[pos].rx_mask =
     ocs.rx_mask,
     result->subcomponents[pos].intermittent_ind = ocs.intermittent_ind, result->subcomponents[pos].
     synonym_mnemonic = ocs.mnemonic, result->subcomponents[pos].orderable_type_flag = oc
     .orderable_type_flag,
     result->subcomponents[pos].ingredient_rate_conversion_ind = ocs.ingredient_rate_conversion_ind,
     result->subcomponents[pos].display_additives_first_ind = ocs.display_additives_first_ind
     IF (band(ocs.rx_mask,1) > 0)
      result->subcomponents[pos].ingredient_type_flag = ingredient_type_diluent, result->
      subcomponents[pos].included_in_total_volume_flag = included_in_total_volume
     ELSE
      result->subcomponents[pos].ingredient_type_flag = ingredient_type_additive, result->
      subcomponents[pos].included_in_total_volume_flag = 0
     ENDIF
    ENDIF
   WITH nocounter, time = 30
  ;end select
  FOR (idx = 1 TO size(result->subcomponents,5))
    IF ((result->subcomponents[idx].orderable_type_flag != orderable_type_flag_normal)
     AND (result->subcomponents[idx].orderable_type_flag != orderable_type_flag_normal1))
     SET result->error_message = build("INVALID ORDERABLE_TYPE_FLAG (",trim(cnvtstring(result->
        subcomponents[idx].orderable_type_flag),3),") FOR SUBCOMPONENT CATALOG_CD (",trim(cnvtstring(
        result->subcomponents[idx].catalog_cd),3),")")
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDIF
 SET stat = sortsubcomponents(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 IF (( $20=1))
  SET stat = calladdorderautoverify(null)
  IF (stat=fail)
   GO TO exit_script
  ENDIF
 ELSE
  SET stat = calladdorder(null)
  IF (stat=fail)
   GO TO exit_script
  ENDIF
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1, v2 = build("<CodeValue>",result->status_data.status,"</CodeValue>"),
    col + 1, v2, row + 1,
    v3 = build("<Display>",result->error_message,"</Display>"), col + 1, v3,
    row + 1, col + 1, "</ReplyMessage>",
    row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req560201
 FREE RECORD rep560201
 FREE RECORD req560251
 FREE RECORD rep560251
 FREE RECORD req3011001
 FREE RECORD rep3011001
 FREE RECORD i_request
 FREE RECORD i_reply
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
 SUBROUTINE calladdorder(null)
   DECLARE applicationid = i4 WITH constant(380000)
   DECLARE taskid = i4 WITH constant(380002)
   DECLARE requestid = i4 WITH constant(560201)
   DECLARE c_order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
   DECLARE c_pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
   DECLARE c_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
   DECLARE c_ord_comment_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
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
   SET req560201->encntrid = result->encntr_id
   SET req560201->commitgroupind = 0
   SET req560201->ordersheetind = 0
   SET req560201->unlockprofileind = 1
   SET req560201->lockkeyid =  $10
   SET req560201->replyinfoflag = 1
   SET req560201->contributorsystemcd = c_praxify_cd
   SET stat = alterlist(req560201->orderlist,1)
   SET req560201->orderlist[1].orderid = result->order_id
   SET req560201->orderlist[1].actiontypecd = c_order_cd
   SET req560201->orderlist[1].communicationtypecd =  $12
   SET req560201->orderlist[1].orderproviderid =  $11
   SET req560201->orderlist[1].orderdttm = cnvtdatetime( $13)
   SET req560201->orderlist[1].currentstartdttm = cnvtdatetime( $7)
   SET req560201->orderlist[1].oeformatid =  $14
   SET req560201->orderlist[1].catalogtypecd = c_pharmacy_cd
   SET stat = alterlist(req560201->orderlist[1].detaillist,size(rep_oeparse->detaillist,5))
   FOR (idx = 1 TO size(rep_oeparse->detaillist,5))
     SET req560201->orderlist[1].detaillist[idx].oefieldid = rep_oeparse->detaillist[idx].oefieldid
     SET req560201->orderlist[1].detaillist[idx].oefieldvalue = rep_oeparse->detaillist[idx].
     oefieldvalue
     SET req560201->orderlist[1].detaillist[idx].oefielddisplayvalue = rep_oeparse->detaillist[idx].
     oefielddisplayvalue
     SET req560201->orderlist[1].detaillist[idx].oefielddttmvalue = rep_oeparse->detaillist[idx].
     oefielddttmvalue
     SET req560201->orderlist[1].detaillist[idx].oefieldmeaning = rep_oeparse->detaillist[idx].
     oefieldmeaning
     SET req560201->orderlist[1].detaillist[idx].modifiedind = rep_oeparse->detaillist[idx].
     modified_ind
     IF ((rep_oeparse->detaillist[idx].oefieldid=12771))
      SET req560201->orderlist[1].detaillist[idx].modifiedind = 1
      IF (band(result->rx_mask,1) > 0)
       SET req560201->orderlist[1].detaillist[idx].oefieldvalue = 2
       SET req560201->orderlist[1].detaillist[idx].oefielddisplayvalue = "2"
      ELSEIF ((result->intermittent_ind=1))
       SET req560201->orderlist[1].detaillist[idx].oefieldvalue = 3
       SET req560201->orderlist[1].detaillist[idx].oefielddisplayvalue = "3"
      ELSE
       SET req560201->orderlist[1].detaillist[idx].oefieldvalue = 1
       SET req560201->orderlist[1].detaillist[idx].oefielddisplayvalue = "1"
      ENDIF
     ENDIF
   ENDFOR
   SELECT INTO "NL:"
    FROM oe_format_fields off,
     order_entry_fields oef
    PLAN (off
     WHERE (off.oe_format_id= $14)
      AND expand(idx,1,size(rep_oeparse->detaillist,5),off.oe_field_id,rep_oeparse->detaillist[idx].
      oefieldid))
     JOIN (oef
     WHERE oef.oe_field_id=off.oe_field_id)
    HEAD off.oe_field_id
     pos = locateval(locidx,1,size(rep_oeparse->detaillist,5),off.oe_field_id,rep_oeparse->
      detaillist[locidx].oefieldid)
     WHILE (pos > 0)
       req560201->orderlist[1].detaillist[pos].oefieldmeaningid = oef.oe_field_meaning_id, req560201
       ->orderlist[1].detaillist[pos].valuerequiredind = off.value_required_ind, req560201->
       orderlist[1].detaillist[pos].groupseq = off.group_seq,
       req560201->orderlist[1].detaillist[pos].fieldseq = off.field_seq, pos = locateval(locidx,(pos
        + 1),size(rep_oeparse->detaillist,5),oef.oe_field_id,rep_oeparse->detaillist[locidx].
        oefieldid)
     ENDWHILE
    WITH nocounter, expand = 1, time = 30
   ;end select
   SET stat = alterlist(req560201->orderlist[1].misclist,1)
   SET req560201->orderlist[1].misclist[1].fieldmeaning = "WRITEORDDISP"
   SET req560201->orderlist[1].misclist[1].fieldmeaningid = 2093
   SET req560201->orderlist[1].misclist[1].modifiedind = 1
   SET req560201->orderlist[1].catalogcd =  $5
   SET req560201->orderlist[1].synonymid = result->synonym_id
   SET req560201->orderlist[1].passingorcinfoind = 0
   SET req560201->orderlist[1].contordermethodflag = result->cont_order_method_flag
   SET req560201->orderlist[1].orderstatuscd = c_ordered_cd
   SET req560201->orderlist[1].rxmask = result->rx_mask
   SET req560201->orderlist[1].medordertypecd = result->order_type_cd
   SET req560201->orderlist[1].orderedasmnemonic = result->synonym_mnemonic
   SET req560201->orderlist[1].validdosedttm = cnvtdatetime( $21)
   SET req560201->orderlist[1].actioninitiateddttm = cnvtdatetime(sysdate)
   IF (size(trim(result->order_comment,3)) > 0)
    SET stat = alterlist(req560201->orderlist[1].commentlist,1)
    SET req560201->orderlist[1].commentlist[1].commenttype = c_ord_comment_cd
    SET req560201->orderlist[1].commentlist[1].commenttext = result->order_comment
   ENDIF
   IF (size(result->subcomponents,5) > 0)
    SET stat = alterlist(req560201->orderlist[1].subcomponentlist,size(result->subcomponents,5))
    FOR (idx = 1 TO size(result->subcomponents,5))
      SET sdx = result->subcomponents[idx].comp_seq
      SET req560201->orderlist[1].subcomponentlist[sdx].sccatalogcd = result->subcomponents[idx].
      catalog_cd
      SET req560201->orderlist[1].subcomponentlist[sdx].scsynonymid = result->subcomponents[idx].
      synonym_id
      SET req560201->orderlist[1].subcomponentlist[sdx].scorderedasmnemonic = result->subcomponents[
      idx].synonym_mnemonic
      IF (size(trim(result->subcomponents[idx].free_text_dose,3))=0)
       IF ((result->subcomponents[idx].str_dose > 0))
        SET req560201->orderlist[1].subcomponentlist[sdx].scstrengthdose = result->subcomponents[idx]
        .str_dose
        SET req560201->orderlist[1].subcomponentlist[sdx].scstrengthdosedisp = trim(formatdosevalue(
          result->subcomponents[idx].str_dose),3)
        SET req560201->orderlist[1].subcomponentlist[sdx].scstrengthunit = result->subcomponents[idx]
        .str_dose_unit_cd
        SET req560201->orderlist[1].subcomponentlist[sdx].scstrengthunitdisp = uar_get_code_display(
         result->subcomponents[idx].str_dose_unit_cd)
       ENDIF
       IF ((result->subcomponents[idx].vol_dose > 0))
        SET req560201->orderlist[1].subcomponentlist[sdx].scvolumedose = result->subcomponents[idx].
        vol_dose
        SET req560201->orderlist[1].subcomponentlist[sdx].scvolumedosedisp = trim(formatdosevalue(
          result->subcomponents[idx].vol_dose),3)
        SET req560201->orderlist[1].subcomponentlist[sdx].scvolumeunit = result->subcomponents[idx].
        vol_dose_unit_cd
        SET req560201->orderlist[1].subcomponentlist[sdx].scvolumeunitdisp = uar_get_code_display(
         result->subcomponents[idx].vol_dose_unit_cd)
       ENDIF
      ELSE
       SET req560201->orderlist[1].subcomponentlist[sdx].scfreetextdose = result->subcomponents[idx].
       free_text_dose
      ENDIF
      SET req560201->orderlist[1].subcomponentlist[sdx].scfrequency = result->subcomponents[idx].
      frequency_cd
      SET req560201->orderlist[1].subcomponentlist[sdx].scfrequencydisp = uar_get_code_display(result
       ->subcomponents[idx].frequency_cd)
      SET req560201->orderlist[1].subcomponentlist[sdx].scclinicallysignificantflag =
      clinically_significant
      SET req560201->orderlist[1].subcomponentlist[sdx].schnaordermnemonic = result->subcomponents[
      idx].primary_mnemonic
      SET req560201->orderlist[1].subcomponentlist[sdx].scingredienttypeflag = result->subcomponents[
      idx].ingredient_type_flag
      SET req560201->orderlist[1].subcomponentlist[sdx].scincludeintotalvolumeflag = result->
      subcomponents[idx].included_in_total_volume_flag
      SET req560201->orderlist[1].subcomponentlist[sdx].scmodifiedflag = 1
      SET req560201->orderlist[1].subcomponentlist[sdx].scdosecalculatorlongtext = getdosecalctext(
       result->order_id,result->subcomponents[idx].synonym_id)
      IF ((result->subcomponents[idx].normalized_rate > 0))
       SET req560201->orderlist[1].subcomponentlist[sdx].scnormalizedrate = result->subcomponents[idx
       ].normalized_rate
       SET req560201->orderlist[1].subcomponentlist[sdx].scnormalizedratedisp = trim(formatdosevalue(
         result->subcomponents[idx].normalized_rate),3)
       SET req560201->orderlist[1].subcomponentlist[sdx].scnormalizedrateunitcd = result->
       subcomponents[idx].normalized_rate_unit_cd
       SET req560201->orderlist[1].subcomponentlist[sdx].scnormalizedrateunitdisp =
       uar_get_code_display(result->subcomponents[idx].normalized_rate_unit_cd)
      ENDIF
      IF ((result->subcomponents[idx].concentration > 0))
       SET req560201->orderlist[1].subcomponentlist[sdx].scconcentration = result->subcomponents[idx]
       .concentration
       SET req560201->orderlist[1].subcomponentlist[sdx].scconcentrationdisp = trim(formatdosevalue(
         result->subcomponents[idx].concentration),3)
       SET req560201->orderlist[1].subcomponentlist[sdx].scconcentrationunitcd = result->
       subcomponents[idx].concentration_unit_cd
       SET req560201->orderlist[1].subcomponentlist[sdx].scconcentrationunitdisp =
       uar_get_code_display(result->subcomponents[idx].concentration_unit_cd)
      ENDIF
      IF ((result->subcomponents[idx].ordered_dose > 0))
       SET req560201->orderlist[1].subcomponentlist[sdx].scordereddose = result->subcomponents[idx].
       ordered_dose
       SET req560201->orderlist[1].subcomponentlist[sdx].scordereddosedisp = trim(formatdosevalue(
         result->subcomponents[idx].ordered_dose),3)
       SET req560201->orderlist[1].subcomponentlist[sdx].scordereddoseunitcd = result->subcomponents[
       idx].ordered_dose_unit_cd
       SET req560201->orderlist[1].subcomponentlist[sdx].scordereddoseunitdisp = uar_get_code_display
       (result->subcomponents[idx].ordered_dose_unit_cd)
      ENDIF
      SET req560201->orderlist[1].subcomponentlist[sdx].scorderedassynonymid = result->subcomponents[
      idx].synonym_id
    ENDFOR
    SET req560201->orderlist[1].ingredientreviewind = cnvtint( $24)
    SET req560201->orderlist[1].ivsetsynonymid =  $23
   ELSE
    SET stat = alterlist(req560201->orderlist[1].subcomponentlist,1)
    SET req560201->orderlist[1].subcomponentlist[1].sccatalogcd =  $5
    SET req560201->orderlist[1].subcomponentlist[1].scsynonymid = result->synonym_id
    SET req560201->orderlist[1].subcomponentlist[1].scorderedasmnemonic = result->synonym_mnemonic
    SET req560201->orderlist[1].subcomponentlist[1].scstrengthdose = result->strength_dose
    SET req560201->orderlist[1].subcomponentlist[1].scstrengthdosedisp = result->strength_dose_disp
    SET req560201->orderlist[1].subcomponentlist[1].scstrengthunit = result->strength_dose_unit
    SET req560201->orderlist[1].subcomponentlist[1].scstrengthunitdisp = result->
    strength_dose_unit_disp
    SET req560201->orderlist[1].subcomponentlist[1].scvolumedose = result->volume_dose
    SET req560201->orderlist[1].subcomponentlist[1].scvolumedosedisp = result->volume_dose_disp
    SET req560201->orderlist[1].subcomponentlist[1].scvolumeunit = result->volume_dose_unit
    SET req560201->orderlist[1].subcomponentlist[1].scvolumeunitdisp = result->volume_dose_unit_disp
    SET req560201->orderlist[1].subcomponentlist[1].schnaordermnemonic = result->primary_mnemonic
    SET req560201->orderlist[1].subcomponentlist[1].scingredienttypeflag = ingredient_type_med
    SET req560201->orderlist[1].subcomponentlist[1].scmodifiedflag = 1
    IF (size(trim(result->free_text_dose,3)) > 0)
     SET req560201->orderlist[1].subcomponentlist[1].scfreetextdose = result->free_text_dose
    ENDIF
    SET req560201->orderlist[1].subcomponentlist[1].scorderedassynonymid = result->synonym_id
    SET req560201->orderlist[1].subcomponentlist[1].scdosecalculatorlongtext = getdosecalctext(result
     ->order_id,result->synonym_id)
    IF (size(trim(req560201->orderlist[1].subcomponentlist[1].scdosecalculatorlongtext,3))=0)
     SET req560201->orderlist[1].subcomponentlist[1].scdosecalculatorlongtext = getdosecalctext(
      result->order_id,0.0)
    ENDIF
   ENDIF
   SET req560201->orderlist[1].originatingencounterid = result->encntr_id
   IF (size(result->diagnosisreltns,5) > 0)
    SET stat = alterlist(req560201->orderlist[1].relationshiplist,1)
    SET req560201->orderlist[1].relationshiplist[1].relationshipmeaning = "ORDERS/DIAGN"
    SET req560201->orderlist[1].relationshiplist[1].inactivateallind = 0
    SET stat = alterlist(req560201->orderlist[1].relationshiplist[1].valuelist,size(result->
      diagnosisreltns,5))
    FOR (idx = 1 TO size(result->diagnosisreltns,5))
      SET req560201->orderlist[1].relationshiplist[1].valuelist[idx].entityid = result->
      diagnosisreltns[idx].diagnosis_id
      SET req560201->orderlist[1].relationshiplist[1].valuelist[idx].entitydisplay = result->
      diagnosisreltns[idx].display
      SET req560201->orderlist[1].relationshiplist[1].valuelist[idx].ranksequence = result->
      diagnosisreltns[idx].rank_sequence
    ENDFOR
   ENDIF
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
   IF (size(rep560201->orderlist,5) > 0)
    IF (size(trim(rep560201->orderlist[1].specificerrorstr,3)) > 0)
     SET result->error_message = rep560201->orderlist[1].specificerrorstr
    ELSEIF (size(trim(rep560201->orderlist[1].errorstr,3)) > 0)
     SET result->error_message = rep560201->orderlist[1].errorstr
    ENDIF
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE (getsystempreference(entry=vc) =vc)
   DECLARE val = vc WITH protect, noconstant("")
   SELECT INTO "NL:"
    FROM dm_prefs dp
    PLAN (dp
     WHERE dp.application_nbr=300000
      AND dp.pref_domain="PHARMNET-INPATIENT"
      AND dp.pref_section="SYSTEM"
      AND dp.pref_name=cnvtupper(entry))
    DETAIL
     val = trim(cnvtstring(dp.pref_nbr),3)
    WITH nocounter, time = 30
   ;end select
   RETURN(val)
 END ;Subroutine
 SUBROUTINE (getdosecalctext(order_id=f8,synonym_id=f8) =vc)
   DECLARE ilidx = i4 WITH protect, noconstant(0)
   DECLARE dosecalctext = vc WITH protect, noconstant("")
   DECLARE tmp_filename = vc WITH protect, noconstant("")
   IF (synonym_id > 0)
    SET tmp_filename = concat("ATHN_SCDOSECALCLONGTEXT_",trim(cnvtstring(order_id),3),"_",trim(
      cnvtstring(synonym_id),3),".TMP")
   ELSE
    SET tmp_filename = concat("ATHN_SCDOSECALCLONGTEXT_",trim(cnvtstring(order_id),3),".TMP")
   ENDIF
   SET req3011001->module_dir = concat("CER_TEMP:",tmp_filename)
   EXECUTE eks_get_source  WITH replace(request,req3011001), replace(reply,rep3011001)
   IF ((rep3011001->status_data.status="S"))
    FOR (ilidx = 1 TO size(rep3011001->info_line,5))
      SET dosecalctext = evaluate(size(trim(dosecalctext,3)),0,rep3011001->info_line[ilidx].new_line,
       concat(dosecalctext,rep3011001->info_line[ilidx].new_line))
    ENDFOR
   ENDIF
   CALL echo(build("DOSECALCTEXT:",dosecalctext))
   RETURN(dosecalctext)
 END ;Subroutine
 SUBROUTINE calladdorderautoverify(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(500196)
   DECLARE requestid = i4 WITH constant(560251)
   DECLARE c_order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
   DECLARE c_pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
   DECLARE c_ord_comment_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
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
   SET req560251->personid = result->person_id
   SET req560251->ordersheetind = 0
   SET req560251->unlockprofileind = 1
   SET req560251->lockkeyid =  $10
   SET req560251->replyinfoflag = 1
   SET req560251->contributorsystemcd = c_praxify_cd
   SET stat = alterlist(req560251->orderlist,1)
   SET req560251->orderlist[1].orderid = result->order_id
   SET req560251->orderlist[1].actiontypecd = c_order_cd
   SET req560251->orderlist[1].communicationtypecd =  $12
   SET req560251->orderlist[1].orderproviderid =  $11
   SET req560251->orderlist[1].orderdttm = cnvtdatetime( $13)
   SET req560251->orderlist[1].oeformatid =  $14
   SET req560251->orderlist[1].catalogtypecd = c_pharmacy_cd
   SET stat = alterlist(req560251->orderlist[1].detaillist,size(rep_oeparse->detaillist,5))
   FOR (idx = 1 TO size(rep_oeparse->detaillist,5))
     SET req560251->orderlist[1].detaillist[idx].oefieldid = rep_oeparse->detaillist[idx].oefieldid
     SET req560251->orderlist[1].detaillist[idx].oefieldvalue = rep_oeparse->detaillist[idx].
     oefieldvalue
     SET req560251->orderlist[1].detaillist[idx].oefielddisplayvalue = rep_oeparse->detaillist[idx].
     oefielddisplayvalue
     SET req560251->orderlist[1].detaillist[idx].oefielddttmvalue = rep_oeparse->detaillist[idx].
     oefielddttmvalue
     SET req560251->orderlist[1].detaillist[idx].oefieldmeaning = rep_oeparse->detaillist[idx].
     oefieldmeaning
     SET req560251->orderlist[1].detaillist[idx].modifiedind = rep_oeparse->detaillist[idx].
     modified_ind
     IF ((rep_oeparse->detaillist[idx].oefieldid=12771))
      SET req560251->orderlist[1].detaillist[idx].modifiedind = 1
      IF (band(result->rx_mask,1) > 0)
       SET req560251->orderlist[1].detaillist[idx].oefieldvalue = 2
       SET req560251->orderlist[1].detaillist[idx].oefielddisplayvalue = "2"
      ELSEIF ((result->intermittent_ind=1))
       SET req560251->orderlist[1].detaillist[idx].oefieldvalue = 3
       SET req560251->orderlist[1].detaillist[idx].oefielddisplayvalue = "3"
      ELSE
       SET req560251->orderlist[1].detaillist[idx].oefieldvalue = 1
       SET req560251->orderlist[1].detaillist[idx].oefielddisplayvalue = "1"
      ENDIF
     ENDIF
   ENDFOR
   SELECT INTO "NL:"
    FROM oe_format_fields off,
     order_entry_fields oef
    PLAN (off
     WHERE (off.oe_format_id= $14)
      AND expand(idx,1,size(rep_oeparse->detaillist,5),off.oe_field_id,rep_oeparse->detaillist[idx].
      oefieldid))
     JOIN (oef
     WHERE oef.oe_field_id=off.oe_field_id)
    HEAD off.oe_field_id
     pos = locateval(locidx,1,size(rep_oeparse->detaillist,5),off.oe_field_id,rep_oeparse->
      detaillist[locidx].oefieldid)
     WHILE (pos > 0)
       req560251->orderlist[1].detaillist[pos].oefieldmeaningid = oef.oe_field_meaning_id, req560251
       ->orderlist[1].detaillist[pos].valuerequiredind = off.value_required_ind, req560251->
       orderlist[1].detaillist[pos].groupseq = off.group_seq,
       req560251->orderlist[1].detaillist[pos].fieldseq = off.field_seq, pos = locateval(locidx,(pos
        + 1),size(rep_oeparse->detaillist,5),oef.oe_field_id,rep_oeparse->detaillist[locidx].
        oefieldid)
     ENDWHILE
    WITH nocounter, expand = 1, time = 30
   ;end select
   SET req560251->orderlist[1].catalogcd =  $5
   SET req560251->orderlist[1].synonymid = result->synonym_id
   SET req560251->orderlist[1].orderstatuscd = 0
   SET req560251->orderlist[1].rxmask = result->rx_mask
   SET req560251->orderlist[1].encntrid = result->encntr_id
   SET req560251->orderlist[1].medordertypecd = result->order_type_cd
   SET req560251->orderlist[1].orderedasmnemonic = result->synonym_mnemonic
   SET req560251->orderlist[1].originatingencounterid = result->encntr_id
   SET req560251->orderlist[1].validdosedttm = cnvtdatetime( $21)
   SET req560251->orderlist[1].actioninitiateddttm = cnvtdatetime(sysdate)
   IF (size(trim(result->order_comment,3)) > 0)
    SET stat = alterlist(req560251->orderlist[1].commentlist,1)
    SET req560251->orderlist[1].commentlist[1].commenttype = c_ord_comment_cd
    SET req560251->orderlist[1].commentlist[1].commenttext = result->order_comment
   ENDIF
   IF (size(result->subcomponents,5) > 0)
    SET stat = alterlist(req560251->orderlist[1].subcomponentlist,size(result->subcomponents,5))
    FOR (idx = 1 TO size(result->subcomponents,5))
      SET sdx = result->subcomponents[idx].comp_seq
      SET req560251->orderlist[1].subcomponentlist[sdx].sccatalogcd = result->subcomponents[idx].
      catalog_cd
      SET req560251->orderlist[1].subcomponentlist[sdx].scsynonymid = result->subcomponents[idx].
      synonym_id
      SET req560251->orderlist[1].subcomponentlist[sdx].scorderedasmnemonic = result->subcomponents[
      idx].synonym_mnemonic
      IF (size(trim(result->subcomponents[idx].free_text_dose,3))=0)
       IF ((result->subcomponents[idx].str_dose > 0))
        SET req560251->orderlist[1].subcomponentlist[sdx].scstrengthdose = result->subcomponents[idx]
        .str_dose
        SET req560251->orderlist[1].subcomponentlist[sdx].scstrengthdosedisp = trim(formatdosevalue(
          result->subcomponents[idx].str_dose),3)
        SET req560251->orderlist[1].subcomponentlist[sdx].scstrengthunit = result->subcomponents[idx]
        .str_dose_unit_cd
        SET req560251->orderlist[1].subcomponentlist[sdx].scstrengthunitdisp = uar_get_code_display(
         result->subcomponents[idx].str_dose_unit_cd)
       ENDIF
       IF ((result->subcomponents[idx].vol_dose > 0))
        SET req560251->orderlist[1].subcomponentlist[sdx].scvolumedose = result->subcomponents[idx].
        vol_dose
        SET req560251->orderlist[1].subcomponentlist[sdx].scvolumedosedisp = trim(formatdosevalue(
          result->subcomponents[idx].vol_dose),3)
        SET req560251->orderlist[1].subcomponentlist[sdx].scvolumeunit = result->subcomponents[idx].
        vol_dose_unit_cd
        SET req560251->orderlist[1].subcomponentlist[sdx].scvolumeunitdisp = uar_get_code_display(
         result->subcomponents[idx].vol_dose_unit_cd)
       ENDIF
      ELSE
       SET req560251->orderlist[1].subcomponentlist[sdx].scfreetextdose = result->subcomponents[idx].
       free_text_dose
      ENDIF
      SET req560251->orderlist[1].subcomponentlist[sdx].scfrequency = result->subcomponents[idx].
      frequency_cd
      SET req560251->orderlist[1].subcomponentlist[sdx].scfrequencydisp = uar_get_code_display(result
       ->subcomponents[idx].frequency_cd)
      SET req560251->orderlist[1].subcomponentlist[sdx].scclinicallysignificantflag =
      clinically_significant
      SET req560251->orderlist[1].subcomponentlist[sdx].schnaordermnemonic = result->subcomponents[
      idx].primary_mnemonic
      SET req560251->orderlist[1].subcomponentlist[sdx].scingredienttypeflag = result->subcomponents[
      idx].ingredient_type_flag
      SET req560251->orderlist[1].subcomponentlist[sdx].scincludeintotalvolumeflag = result->
      subcomponents[idx].included_in_total_volume_flag
      SET req560251->orderlist[1].subcomponentlist[sdx].scmodifiedflag = 1
      SET req560251->orderlist[1].subcomponentlist[sdx].scdosecalculatorlongtext = getdosecalctext(
       result->order_id,result->subcomponents[idx].synonym_id)
      IF ((result->subcomponents[idx].normalized_rate > 0))
       SET req560251->orderlist[1].subcomponentlist[sdx].scnormalizedrate = result->subcomponents[idx
       ].normalized_rate
       SET req560251->orderlist[1].subcomponentlist[sdx].scnormalizedratedisp = trim(formatdosevalue(
         result->subcomponents[idx].normalized_rate),3)
       SET req560251->orderlist[1].subcomponentlist[sdx].scnormalizedrateunitcd = result->
       subcomponents[idx].normalized_rate_unit_cd
       SET req560251->orderlist[1].subcomponentlist[sdx].scnormalizedrateunitdisp =
       uar_get_code_display(result->subcomponents[idx].normalized_rate_unit_cd)
      ENDIF
      IF ((result->subcomponents[idx].ordered_dose > 0))
       SET req560251->orderlist[1].subcomponentlist[sdx].scordereddose = result->subcomponents[idx].
       ordered_dose
       SET req560251->orderlist[1].subcomponentlist[sdx].scordereddosedisp = trim(formatdosevalue(
         result->subcomponents[idx].ordered_dose),3)
       SET req560251->orderlist[1].subcomponentlist[sdx].scordereddoseunitcd = result->subcomponents[
       idx].ordered_dose_unit_cd
       SET req560251->orderlist[1].subcomponentlist[sdx].scordereddoseunitdisp = uar_get_code_display
       (result->subcomponents[idx].ordered_dose_unit_cd)
      ENDIF
      IF ((result->subcomponents[idx].concentration > 0))
       SET req560251->orderlist[1].subcomponentlist[sdx].scconcentration = result->subcomponents[idx]
       .concentration
       SET req560251->orderlist[1].subcomponentlist[sdx].scconcentrationdisp = trim(formatdosevalue(
         result->subcomponents[idx].concentration),3)
       SET req560251->orderlist[1].subcomponentlist[sdx].scconcentrationunitcd = result->
       subcomponents[idx].concentration_unit_cd
       SET req560251->orderlist[1].subcomponentlist[sdx].scconcentrationunitdisp =
       uar_get_code_display(result->subcomponents[idx].concentration_unit_cd)
      ENDIF
      SET req560251->orderlist[1].subcomponentlist[sdx].scorderedassynonymid = result->subcomponents[
      idx].synonym_id
    ENDFOR
    SET req560251->orderlist[1].ingredientreviewind = cnvtint( $24)
    SET req560251->orderlist[1].ivsetsynonymid =  $23
   ELSE
    SET stat = alterlist(req560251->orderlist[1].subcomponentlist,1)
    SET req560251->orderlist[1].subcomponentlist[1].sccatalogcd =  $5
    SET req560251->orderlist[1].subcomponentlist[1].scsynonymid = result->synonym_id
    SET req560251->orderlist[1].subcomponentlist[1].scorderedasmnemonic = result->synonym_mnemonic
    SET req560251->orderlist[1].subcomponentlist[1].scstrengthdose = result->strength_dose
    SET req560251->orderlist[1].subcomponentlist[1].scstrengthdosedisp = result->strength_dose_disp
    SET req560251->orderlist[1].subcomponentlist[1].scstrengthunit = result->strength_dose_unit
    SET req560251->orderlist[1].subcomponentlist[1].scstrengthunitdisp = result->
    strength_dose_unit_disp
    SET req560251->orderlist[1].subcomponentlist[1].scvolumedose = result->volume_dose
    SET req560251->orderlist[1].subcomponentlist[1].scvolumedosedisp = result->volume_dose_disp
    SET req560251->orderlist[1].subcomponentlist[1].scvolumeunit = result->volume_dose_unit
    SET req560251->orderlist[1].subcomponentlist[1].scvolumeunitdisp = result->volume_dose_unit_disp
    SET req560251->orderlist[1].subcomponentlist[1].schnaordermnemonic = result->primary_mnemonic
    SET req560251->orderlist[1].subcomponentlist[1].scingredienttypeflag = ingredient_type_med
    SET req560251->orderlist[1].subcomponentlist[1].scmodifiedflag = 1
    IF (size(trim(result->free_text_dose,3)) > 0)
     SET req560251->orderlist[1].subcomponentlist[1].scfreetextdose = result->free_text_dose
    ENDIF
    SET req560251->orderlist[1].subcomponentlist[1].scorderedassynonymid = result->synonym_id
    SET req560251->orderlist[1].subcomponentlist[1].scdosecalculatorlongtext = getdosecalctext(result
     ->order_id,result->synonym_id)
    IF (size(trim(req560251->orderlist[1].subcomponentlist[1].scdosecalculatorlongtext,3))=0)
     SET req560251->orderlist[1].subcomponentlist[1].scdosecalculatorlongtext = getdosecalctext(
      result->order_id,0.0)
    ENDIF
   ENDIF
   IF (size(result->diagnosisreltns,5) > 0)
    SET stat = alterlist(req560251->orderlist[1].relationshiplist,1)
    SET req560251->orderlist[1].relationshiplist[1].relationshipmeaning = "ORDERS/DIAGN"
    SET req560251->orderlist[1].relationshiplist[1].inactivateallind = 0
    SET stat = alterlist(req560251->orderlist[1].relationshiplist[1].valuelist,size(result->
      diagnosisreltns,5))
    FOR (idx = 1 TO size(result->diagnosisreltns,5))
      SET req560251->orderlist[1].relationshiplist[1].valuelist[idx].entityid = result->
      diagnosisreltns[idx].diagnosis_id
      SET req560251->orderlist[1].relationshiplist[1].valuelist[idx].entitydisplay = result->
      diagnosisreltns[idx].display
      SET req560251->orderlist[1].relationshiplist[1].valuelist[idx].ranksequence = result->
      diagnosisreltns[idx].rank_sequence
    ENDFOR
   ENDIF
   SET req560251->errorlogoverrideflag = 1
   CALL echorecord(req560251)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req560251,
    "REC",rep560251,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep560251)
   IF ((rep560251->status_data.status="S"))
    RETURN(success)
   ENDIF
   IF (size(rep560251->orderlist,5) > 0)
    IF (size(trim(rep560251->orderlist[1].specificerrorstr,3)) > 0)
     SET result->error_message = rep560251->orderlist[1].specificerrorstr
    ELSEIF (size(trim(rep560251->orderlist[1].errorstr,3)) > 0)
     SET result->error_message = rep560251->orderlist[1].errorstr
    ENDIF
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE (formatdosevalue(input=f8) =vc)
   DECLARE formatted_val = vc WITH protect, noconstant("")
   IF (input <= 0)
    RETURN("0")
   ENDIF
   SET formatted_val = replace(trim(build(input),3),"0"," ",0)
   SET formatted_val = trim(formatted_val,3)
   SET formatted_val = replace(formatted_val," ","0",0)
   IF (substring(size(formatted_val),1,formatted_val)=".")
    SET formatted_val = replace(formatted_val,".","",0)
   ENDIF
   IF (substring(0,1,formatted_val)=".")
    SET formatted_val = replace(formatted_val,".","0.",0)
   ENDIF
   RETURN(formatted_val)
 END ;Subroutine
 SUBROUTINE sortsubcomponents(null)
   DECLARE subcomponents_size = i4 WITH protect, constant(size(result->subcomponents,5))
   DECLARE order_level_display_additives_first_ind = i2 WITH protect, noconstant(0)
   DECLARE dcnt = i4 WITH protect, noconstant(0)
   DECLARE acnt = i4 WITH protect, noconstant(0)
   DECLARE cur_seq = i4 WITH protect, noconstant(1)
   DECLARE normalized_rate_ingredient_idx = i4 WITH protect, noconstant(0)
   IF (((subcomponents_size=0) OR ((result->order_type_cd != c_iv_cd))) )
    RETURN(success)
   ENDIF
   FREE RECORD diluents
   RECORD diluents(
     1 list[*]
       2 ref_idx = i4
   ) WITH protect
   FREE RECORD additives
   RECORD additives(
     1 list[*]
       2 ref_idx = i4
   ) WITH protect
   FOR (idx = 1 TO subcomponents_size)
     SET result->subcomponents[idx].comp_seq = 0
     IF ((((result->subcomponents[idx].ingredient_rate_conversion_ind=1)) OR ((result->subcomponents[
     idx].display_additives_first_ind=1))) )
      SET order_level_display_additives_first_ind = 1
     ENDIF
     IF ((result->subcomponents[idx].ingredient_type_flag=ingredient_type_diluent))
      SET dcnt += 1
      SET stat = alterlist(diluents->list,dcnt)
      SET diluents->list[dcnt].ref_idx = idx
     ELSE
      SET acnt += 1
      SET stat = alterlist(additives->list,acnt)
      SET additives->list[acnt].ref_idx = idx
      IF (normalized_rate_ingredient_idx=0
       AND (result->subcomponents[idx].normalized_rate > 0.0)
       AND (result->subcomponents[idx].normalized_rate_unit_cd > 0.0))
       SET normalized_rate_ingredient_idx = idx
      ENDIF
     ENDIF
   ENDFOR
   CALL echorecord(additives)
   CALL echorecord(diluents)
   IF (normalized_rate_ingredient_idx > 0
    AND order_level_display_additives_first_ind=1)
    SET result->subcomponents[normalized_rate_ingredient_idx].comp_seq = cur_seq
    SET cur_seq += 1
   ENDIF
   IF (order_level_display_additives_first_ind=1)
    FOR (idx = 1 TO acnt)
     SET pos = additives->list[idx].ref_idx
     IF ((result->subcomponents[pos].comp_seq <= 0))
      SET result->subcomponents[pos].comp_seq = cur_seq
      SET cur_seq += 1
     ENDIF
    ENDFOR
   ENDIF
   FOR (idx = 1 TO dcnt)
    SET pos = diluents->list[idx].ref_idx
    IF ((result->subcomponents[pos].comp_seq <= 0))
     SET result->subcomponents[pos].comp_seq = cur_seq
     SET cur_seq += 1
    ENDIF
   ENDFOR
   IF (order_level_display_additives_first_ind=0)
    FOR (idx = 1 TO acnt)
     SET pos = additives->list[idx].ref_idx
     IF ((result->subcomponents[pos].comp_seq <= 0))
      SET result->subcomponents[pos].comp_seq = cur_seq
      SET cur_seq += 1
     ENDIF
    ENDFOR
   ENDIF
   FREE RECORD diluents
   FREE RECORD additives
   RETURN(success)
 END ;Subroutine
END GO
