CREATE PROGRAM bhs_rx_util_autoverify_orders:dba
 PROMPT
  "Output to File/Printer/MINE(Default = MINE)" = "MINE",
  "From Order_id:" = "",
  "To Order_id:" = "",
  "Personnel id:" = "",
  "Include orders needing product assignment(Y/N, Default = N):" = "N",
  "Update or Report (U/R):" = ""
  WITH outdev, fromorderid, toorderid,
  personnelid, includeprod, updatereport
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD verify_request(
   1 qual[*]
     2 orderid = f8
     2 display_line = c35
     2 order_status_cd = f8
     2 order_status_disp = c25
     2 ows_status = c7
     2 productid = f8
     2 personid = f8
     2 encntrid = f8
     2 passingencntrinfoind = i2
     2 encntrfinancialid = vc
     2 locationcd = vc
     2 locfacilitycd = f8
     2 locnurseunitcd = f8
     2 locroomcd = f8
     2 locbedcd = f8
     2 adm_dt = vc
     2 disch_dt = vc
     2 encntr_type = vc
     2 actionpersonnelid = f8
     2 contributorsystemcd = f8
     2 orderlocncd = f8
     2 replyinfoflag = i2
     2 commitgroupind = i2
     2 needsatldupcheckind = i2
     2 ordersheetind = i2
     2 ordersheetprintername = vc
     2 logleveloverride = i2
     2 unlockprofileind = i2
     2 lockkeyid = i4
     2 orderlist[*]
       3 orderid = f8
       3 actiontypecd = f8
       3 communicationtypecd = f8
       3 orderproviderid = f8
       3 orderdttm = dq8
       3 currentstartdttm = dq8
       3 oeformatid = f8
       3 catalogtypecd = f8
       3 accessionnbr = vc
       3 accessionid = f8
       3 nochargeind = i2
       3 billonlyind = i2
       3 lastupdtcnt = i4
       3 detaillist[*]
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
       3 misclist[*]
         4 fieldmeaning = vc
         4 fieldmeaningid = f8
         4 fieldvalue = f8
         4 fielddisplayvalue = vc
         4 fielddttmvalue = dq8
         4 modifiedind = i2
       3 prompttestlist[*]
         4 fieldvalue = f8
         4 fielddisplayvalue = vc
         4 fielddttmvalue = dq8
         4 promptentityname = vc
         4 promptentityid = f8
         4 modifiedind = i2
         4 fieldtypeflag = i2
         4 oefieldid = f8
       3 commentlist[*]
         4 commenttype = f8
         4 commenttext = vc
       3 reviewlist[*]
         4 reviewtypeflag = i2
         4 providerid = f8
         4 locationcd = f8
         4 rejectedind = i2
         4 reviewpersonnelid = f8
         4 proxypersonnelid = f8
         4 proxyreasoncd = f8
         4 catalogtypecd = f8
         4 actionsequence = i2
       3 deptmiscline = vc
       3 catalogcd = f8
       3 synonymid = f8
       3 ordermnemonic = vc
       3 passingorcinfoind = i2
       3 primarymnemonic = vc
       3 activitytypecd = f8
       3 activitysubtypecd = f8
       3 contordermethodflag = i2
       3 completeuponorderind = i2
       3 orderreviewind = i2
       3 printreqind = i2
       3 requisitionformatcd = f8
       3 requisitionroutingcd = f8
       3 resourceroutelevel = i4
       3 consentformind = i2
       3 consentformformatcd = f8
       3 consentformroutingcd = f8
       3 deptdupcheckind = i2
       3 dupcheckingind = i2
       3 deptdisplayname = vc
       3 reftextmask = i4
       3 abnreviewind = i2
       3 reviewhierarchyid = f8
       3 orderabletypeflag = i2
       3 dcpclincatcd = f8
       3 cki = vc
       3 stoptypecd = f8
       3 stopduration = i4
       3 stopdurationunitcd = f8
       3 needsintervalcalcind = i2
       3 templateorderflag = i2
       3 templateorderid = f8
       3 grouporderflag = i2
       3 groupcompcount = i4
       3 linkorderflag = i2
       3 linkcompcount = i4
       3 linktypecd = f8
       3 linkelementflag = i2
       3 linkelementcd = f8
       3 processingflag = i2
       3 origordasflag = i2
       3 orderstatuscd = f8
       3 deptstatuscd = f8
       3 schstatecd = f8
       3 discontinuetypecd = f8
       3 rxmask = i4
       3 scheventid = f8
       3 encntrid = f8
       3 passingencntrinfoind = i2
       3 encntrfinancialid = f8
       3 locationcd = f8
       3 locfacilitycd = f8
       3 locnurseunitcd = f8
       3 locroomcd = f8
       3 locbedcd = f8
       3 medordertypecd = f8
       3 undoactiontypecd = f8
       3 orderedasmnemonic = vc
       3 getlatestdetailsind = i2
       3 studentactiontypecd = f8
       3 aliaslist[*]
         4 alias = vc
         4 orderaliastypecd = f8
         4 orderaliassubtypecd = f8
         4 aliaspoolcd = f8
         4 checkdigit = i4
         4 checkdigitmethodcd = f8
         4 begeffectivedttm = dq8
         4 endeffectivedttm = dq8
         4 datastatuscd = f8
         4 activestatuscd = f8
         4 activeind = i2
         4 billordnbrind = i2
         4 primarydisplayind = i2
       3 subcomponentlist[*]
         4 sccatalogcd = f8
         4 scsynonymid = f8
         4 scordermnemonic = vc
         4 scoeformatid = f8
         4 scstrengthdose = f8
         4 scstrengthdosedisp = vc
         4 scstrengthunit = f8
         4 scstrengthunitdisp = vc
         4 scvolumedose = f8
         4 scvolumedosedisp = vc
         4 scvolumeunit = f8
         4 scvolumeunitdisp = vc
         4 scfreetextdose = vc
         4 scfrequency = f8
         4 scfrequencydisp = vc
         4 scivseq = i4
         4 scdosequantity = f8
         4 scdosequantitydisp = vc
         4 scdosequantityunit = f8
         4 scdosequantityunitdisp = vc
         4 scorderedasmnemonic = vc
         4 schnaordermnemonic = vc
         4 scdetaillist[*]
           5 oefieldid = f8
           5 oefieldvalue = f8
           5 oefielddisplayvalue = vc
           5 oefielddttmvalue = dq8
           5 oefieldmeaning = vc
           5 oefieldmeaningid = f8
           5 valuerequiredind = i2
           5 groupseq = i4
           5 fieldseq = i4
           5 modifiedind = i2
         4 scproductlist[*]
           5 item_id = f8
           5 dose_quantity = f8
           5 dose_quantity_unit_cd = f8
           5 tnf_id = f8
           5 tnf_description = vc
           5 tnf_cost = f8
           5 tnf_ndc = vc
           5 tnflegalstatuscd = f8
           5 packagetypeid = f8
           5 medproductid = f8
           5 manfitemid = f8
           5 dispqty = f8
           5 dispqtyunitcd = f8
           5 ignoreind = i2
           5 compoundflag = i2
           5 cmpdbaseind = i2
           5 premanfind = i2
           5 productseq = i2
           5 parentproductseq = i2
           5 labeldesc = vc
           5 branddesc = vc
           5 genericdesc = vc
           5 drugidentifier = vc
         4 scingredienttypeflag = i2
         4 scprevingredientseq = i4
         4 scmodifiedflag = i2
         4 scincludeintotalvolumeflag = i2
         4 scclinicallysignificantflag = i2
         4 scautoassignflag = i2
         4 scordereddose = f8
         4 scordereddosedisp = vc
         4 scordereddoseunitcd = f8
         4 scordereddoseunitdisp = vc
       3 resourcelist[*]
         4 serviceresourcecd = f8
         4 csloginloccd = f8
         4 serviceareacd = f8
         4 assaylist[*]
           5 taskassaycd = f8
       3 relationshiplist[*]
         4 relationshipmeaning = vc
         4 valuelist[*]
           5 entityid = f8
           5 entitydisplay = vc
         4 ranksequence = i4
       3 misclongtextlist[*]
         4 textid = f8
         4 texttypecd = f8
         4 text = vc
         4 textmodifier1 = i4
         4 textmodified2 = i4
       3 deptcommentlist[*]
       3 commenttypecd = f8
       3 commentseq = i4
       3 commentid = f8
       3 longtextid = f8
       3 deptcommentmisc = i4
       3 deptcommenttext = vc
       3 adhocfreqtimelist[*]
         4 adhoctime = i4
       3 ingredientreviewind = i2
       3 taskstatusreasonmean = f8
       3 badorderind = i2
       3 origorderdttm = dq8
       3 validdosedttm = dq8
       3 useroverridetz = i4
       3 linknbr = f8
       3 linktypeflag = i2
     2 errorlogoverrideflag = i2
 )
 RECORD verify_ows_reply(
   1 qual[*]
     2 order_id = f8
     2 badordercnt = i4
     2 grouprollbackind = i4
     2 groupbadorderindex = i4
     2 orderlist[*]
       3 orderid = f8
       3 orderstatuscd = f8
       3 accessionnbr = vc
       3 errorstr = vc
       3 errornbr = i4
       3 deptstatuscd = f8
       3 prevdeptstatuscd = f8
       3 schstatecd = f8
       3 orderdetaildisplayline = vc
       3 origorderdttm = dq8
       3 ordercommentind = i4
       3 neednursereviewind = i4
       3 needdoctorcosignind = i4
       3 actionsequence = i4
       3 reviewcnt = i4
       3 detailcnt = i4
       3 ingredcnt = i4
       3 ingreddetailcntlist[*]
         4 ingdetcnt = i4
       3 misclist[*]
         4 fieldmeaning = vc
         4 fieldmeaningid = f8
         4 fieldvalue = f8
         4 fielddisplayvalue = vc
         4 fielddttmvalue = dq8
         4 modifiedind = i4
       3 clinicaldisplayline = vc
       3 incompleteorderind = i4
       3 orderactionid = f8
       3 specificerrornbr = i4
       3 specificerrorstr = vc
       3 actionstatus = i4
     2 status_data
       3 status = vc
       3 subeventstatus[*]
         4 operationname = vc
         4 operationstatus = vc
         4 targetobjectname = vc
         4 targetobjectvalue = vc
         4 requestnumber = i4
         4 orderid = f8
         4 actionseq = i4
         4 substatus = vc
     2 errornbr = i4
     2 errorstr = vc
     2 specificerrornbr = i4
     2 specificerrorstr = vc
     2 transactionstatus = i4
 )
 DECLARE from_order_id = f8 WITH protect, noconstant(0.00)
 DECLARE to_order_id = f8 WITH protect, noconstant(0.00)
 DECLARE personnel_id = f8 WITH protect, noconstant(0.00)
 DECLARE void_cd = f8 WITH protect, noconstant(0.00)
 DECLARE voidwithresults_cd = f8 WITH protect, noconstant(0.00)
 DECLARE transfer_cancel_cd = f8 WITH protect, noconstant(0.00)
 DECLARE discontinued_cd = f8 WITH protect, noconstant(0.00)
 DECLARE canceled_cd = f8 WITH protect, noconstant(0.00)
 DECLARE pending_cd = f8 WITH protect, noconstant(0.00)
 DECLARE completed_cd = f8 WITH protect, noconstant(0.00)
 DECLARE review_cd = f8 WITH protect, noconstant(0.00)
 DECLARE ordered_cd = f8 WITH protect, noconstant(0.00)
 DECLARE suspended_cd = f8 WITH protect, noconstant(0.00)
 DECLARE soft_cd = f8 WITH protect, noconstant(0.00)
 DECLARE od_idx = i4 WITH protect, noconstant(0)
 DECLARE oa_idx = i4 WITH protect, noconstant(0)
 DECLARE primary_format_id = f8 WITH protect, noconstant(0.00)
 DECLARE currentorderactionseq = i2 WITH protect, noconstant(0)
 DECLARE norderlistcnt = i2 WITH protect, noconstant(0)
 DECLARE ningredlistcnt = i2 WITH protect, noconstant(0)
 DECLARE nmisclistcnt = i2 WITH protect, noconstant(0)
 DECLARE norderstatuscnt = i2 WITH protect, noconstant(0)
 DECLARE nsubeventstatuscnt = i2 WITH protect, noconstant(0)
 DECLARE applicationid = i4 WITH protect, noconstant(0)
 DECLARE happ = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hreq = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hxfc = i4 WITH protect, noconstant(0)
 DECLARE taskid = i4 WITH protect, noconstant(0)
 DECLARE iret = i4 WITH protect, noconstant(0)
 DECLARE stepid = i4 WITH protect, noconstant(0)
 DECLARE requestid = i4 WITH protect, noconstant(0)
 DECLARE requestcnt = i4 WITH protect, noconstant(0)
 DECLARE orderactioncnt = i4 WITH protect, noconstant(0)
 DECLARE horderaction = i4 WITH protect, noconstant(0)
 DECLARE hmisc = i4 WITH protect, noconstant(0)
 DECLARE hreview = i4 WITH protect, noconstant(0)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE update_flag = c1 WITH protect
 DECLARE curupdtcnt = i4 WITH protect, noconstant(0)
 DECLARE include_flag = c1 WITH protect
 DECLARE from_order_invalid = i2 WITH private, constant(1)
 DECLARE to_order_invalid = i2 WITH private, constant(2)
 DECLARE personnel_invalid = i2 WITH private, constant(3)
 DECLARE personnel_not_pharm = i2 WITH private, constant(4)
 DECLARE from_to_invalid = i2 WITH private, constant(5)
 DECLARE no_orders = i2 WITH private, constant(6)
 DECLARE begin_app_fail = i2 WITH private, constant(7)
 DECLARE begin_task_fail = i2 WITH private, constant(8)
 DECLARE begin_req_fail = i2 WITH private, constant(9)
 DECLARE perform_fail = i2 WITH private, constant(10)
 DECLARE update_invalid = i2 WITH private, constant(11)
 DECLARE option_invalid = i2 WITH private, constant(12)
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(6004,"VOIDEDWRSLT",1,voidwithresults_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"DELETED",1,void_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"TRANS/CANCEL",1,transfer_cancel_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"DISCONTINUED",1,discontinued_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"CANCELED",1,canceled_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"COMPLETED",1,completed_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"PENDING",1,pending_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"REVIEW",1,review_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"ORDERED",1,ordered_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"SUSPENDED",1,suspended_cd)
 SET stat = uar_get_meaning_by_codeset(4009,"SOFT",1,soft_cd)
 SET stat = isnumeric( $2)
 IF (stat=0)
  SET fail_flag = from_order_invalid
  GO TO check_error
 ENDIF
 SET stat = isnumeric( $3)
 IF (stat=0)
  SET fail_flag = to_order_invalid
  GO TO check_error
 ENDIF
 SET stat = isnumeric( $4)
 IF (stat=0)
  SET fail_flag = personnel_invalid
  GO TO check_error
 ENDIF
 SET include_flag = cnvtupper( $5)
 IF (include_flag != "Y")
  IF (include_flag != "N")
   SET fail_flag = option_invalid
   GO TO check_error
  ENDIF
 ENDIF
 SET update_flag = cnvtupper( $6)
 IF (update_flag != "U")
  IF (update_flag != "R")
   SET fail_flag = update_invalid
   GO TO check_error
  ENDIF
 ENDIF
 SET personnel_id = 22003465
 SET crxverify = 0.00
 SET cyes = 0.00
 SET stat = uar_get_meaning_by_codeset(6016,"RXVERIFY",1,crxverify)
 SET stat = uar_get_meaning_by_codeset(6017,"YES",1,cyes)
 SELECT INTO "nl:"
  p.person_id, p.name_full_formatted
  FROM person p,
   priv_loc_reltn pl,
   privilege pr
  PLAN (pr
   WHERE pr.privilege_cd=crxverify
    AND ((pr.priv_value_cd+ 0)=cyes))
   JOIN (pl
   WHERE pl.priv_loc_reltn_id=pr.priv_loc_reltn_id
    AND pl.location_cd=0.0
    AND pl.person_id=personnel_id)
   JOIN (p
   WHERE p.person_id=pl.person_id
    AND ((p.active_ind+ 0)=1)
    AND ((p.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((p.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "NL:"
   FROM prsnl p,
    priv_loc_reltn pl,
    privilege pr
   PLAN (pr
    WHERE pr.privilege_cd=crxverify
     AND ((pr.priv_value_cd+ 0)=cyes))
    JOIN (pl
    WHERE pr.priv_loc_reltn_id=pl.priv_loc_reltn_id
     AND pl.location_cd=0.0)
    JOIN (p
    WHERE p.person_id=personnel_id
     AND ((p.position_cd+ 0)=pl.position_cd)
     AND ((p.active_ind+ 0)=1)
     AND ((p.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
     AND ((p.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET fail_flag = personnel_not_pharm
   GO TO check_error
  ENDIF
 ENDIF
 SET from_order_id = cnvtreal( $2)
 SET to_order_id = cnvtreal( $3)
 IF (from_order_id > to_order_id)
  SET fail_flag = from_to_invalid
  GO TO check_error
 ENDIF
 SET now_today = cnvtdatetime("01-Jan-2010")
 CALL echo(build("now_today",format(now_today,"MM/DD/YY HH:SS;;d")))
 SELECT INTO "nl:"
  od.order_id, od.display_line, o.order_status_cd,
  o.need_rx_verify_ind
  FROM order_dispense od,
   orders o,
   order_action oa,
   encounter e,
   encntr_alias ea
  PLAN (od
   WHERE od.order_id >= from_order_id
    AND od.order_id <= to_order_id
    AND ((od.need_rx_verify_ind+ 0)=1)
    AND ((include_flag="Y") OR (include_flag="N"
    AND ((od.need_rx_prod_assign_flag+ 0) != 1))) )
   JOIN (e
   WHERE e.encntr_id=od.encntr_id
    AND e.disch_dt_tm >= cnvtdatetime(now_today))
   JOIN (o
   WHERE o.order_id=od.order_id
    AND o.order_status_cd IN (void_cd, transfer_cancel_cd, canceled_cd)
    AND o.projected_stop_dt_tm >= cnvtdatetime(now_today)
    AND o.projected_stop_dt_tm != null
    AND o.stop_type_cd != soft_cd)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(1077))
   JOIN (oa
   WHERE oa.order_id=o.order_id)
  ORDER BY od.encntr_id, o.orig_order_dt_tm, oa.order_id,
   oa.action_sequence
  HEAD REPORT
   od_idx = 0, oa_idx = 0, curupdtcnt = o.updt_cnt
  HEAD oa.order_id
   od_idx = (od_idx+ 1)
   IF (mod(od_idx,10)=1)
    stat = alterlist(verify_request->qual,(od_idx+ 9))
   ENDIF
   verify_request->qual[od_idx].orderid = od.order_id, verify_request->qual[od_idx].personid = o
   .person_id
   IF (od.encntr_id != 0.00)
    verify_request->qual[od_idx].encntrid = od.encntr_id
   ELSE
    verify_request->qual[od_idx].encntrid = o.encntr_id
   ENDIF
   verify_request->qual[od_idx].display_line = substring(1,35,od.display_line), verify_request->qual[
   od_idx].order_status_cd = o.order_status_cd, verify_request->qual[od_idx].order_status_disp =
   substring(1,25,uar_get_code_display(o.order_status_cd)),
   verify_request->qual[od_idx].encntr_type = uar_get_code_display(e.encntr_type_cd), verify_request
   ->qual[od_idx].disch_dt = format(cnvtdatetime(e.disch_dt_tm),"MM/DD/YY;;D")
   IF (e.disch_dt_tm=0.00
    AND e.encntr_id=0.00)
    verify_request->qual[od_idx].disch_dt = format(cnvtdatetime(o.orig_order_dt_tm),"MM/DD/YY-OD;;D")
   ENDIF
   IF (e.encntr_type_cd IN (679668.00, 679654.00, 679656.00, 309312.00, 309308.00))
    verify_request->qual[od_idx].adm_dt = format(cnvtdatetime(e.inpatient_admit_dt_tm),"MM/DD/YY;;D")
   ELSE
    verify_request->qual[od_idx].adm_dt = format(cnvtdatetime(e.arrive_dt_tm),"MM/DD/YY;;D")
   ENDIF
   verify_request->qual[od_idx].encntrfinancialid = trim(ea.alias), verify_request->qual[od_idx].
   locationcd = uar_get_code_display(e.location_cd), verify_request->qual[od_idx].commitgroupind = 1,
   verify_request->qual[od_idx].ordersheetind = 1, oa_idx = 0
  HEAD oa.action_sequence
   IF (currentorderactionseq=0)
    currentorderactionseq = o.last_action_sequence, curupdtcnt = o.updt_cnt
   ELSE
    curupdtcnt = (curupdtcnt+ 1)
   ENDIF
   oa_idx = (oa_idx+ 1)
   IF (mod(oa_idx,10)=1)
    stat = alterlist(verify_request->qual[od_idx].orderlist,(oa_idx+ 9))
   ENDIF
   verify_request->qual[od_idx].orderlist[oa_idx].orderid = o.order_id, verify_request->qual[od_idx].
   orderlist[oa_idx].actiontypecd = review_cd, verify_request->qual[od_idx].orderlist[oa_idx].
   catalogtypecd = o.catalog_type_cd,
   verify_request->qual[od_idx].orderlist[oa_idx].lastupdtcnt = curupdtcnt, verify_request->qual[
   od_idx].orderlist[oa_idx].deptmiscline = o.dept_misc_line, verify_request->qual[od_idx].orderlist[
   oa_idx].catalogcd = o.catalog_cd,
   verify_request->qual[od_idx].orderlist[oa_idx].synonymid = o.synonym_id
  DETAIL
   stat = alterlist(verify_request->qual[od_idx].orderlist[oa_idx].misclist,1), verify_request->qual[
   od_idx].orderlist[oa_idx].misclist[1].fieldmeaning = "WRITEORDDISP", verify_request->qual[od_idx].
   orderlist[oa_idx].misclist[1].fieldmeaningid = 2093,
   verify_request->qual[od_idx].orderlist[oa_idx].misclist[1].modifiedind = 1, stat = alterlist(
    verify_request->qual[od_idx].orderlist[oa_idx].reviewlist,1), verify_request->qual[od_idx].
   orderlist[oa_idx].reviewlist[1].reviewtypeflag = 3
   IF (currentorderactionseq=oa.action_sequence)
    verify_request->qual[od_idx].orderlist[oa_idx].reviewlist[1].rejectedind = 0
   ELSE
    verify_request->qual[od_idx].orderlist[oa_idx].reviewlist[1].rejectedind = 2
   ENDIF
   verify_request->qual[od_idx].orderlist[oa_idx].reviewlist[1].reviewpersonnelid = personnel_id,
   verify_request->qual[od_idx].orderlist[oa_idx].reviewlist[1].actionsequence = oa.action_sequence
  FOOT  oa.order_id
   stat = alterlist(verify_request->qual[od_idx].orderlist,oa_idx)
  FOOT REPORT
   stat = alterlist(verify_request->qual,od_idx)
  WITH counter
 ;end select
 IF (od_idx=0)
  SET fail_flag = no_orders
  GO TO check_error
 ENDIF
 IF (update_flag="U")
  SET applicationid = 380000
  SET taskid = 395308
  SET requestid = 560201
  SET stepid = 305605
  EXECUTE crmrtl
  EXECUTE srvrtl
  SET iret = uar_crmbeginapp(applicationid,happ)
  IF (iret=0)
   SET iret = uar_crmbegintask(happ,taskid,htask)
   IF (iret=0)
    SET requestcnt = size(verify_request->qual,5)
    SET srvstat = alterlist(verify_ows_reply->qual,requestcnt)
    FOR (i = 1 TO requestcnt)
     SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
     IF (iret=0)
      SET hreq = uar_crmgetrequest(hstep)
      SET srvstat = uar_srvsetdouble(hreq,"personId",verify_request->qual[i].personid)
      SET srvstat = uar_srvsetdouble(hreq,"encntrId",verify_request->qual[i].encntrid)
      SET srvstat = uar_srvsetshort(hreq,"commitGroupInd",verify_request->qual[i].commitgroupind)
      SET srvstat = uar_srvsetshort(hreq,"orderSheetInd",verify_request->qual[i].ordersheetind)
      SET srvstat = uar_srvsetshort(hreq,"passingEncntrInfoInd",verify_request->qual[i].
       passingencntrinfoind)
      SET orderactioncnt = size(verify_request->qual[i].orderlist,5)
      FOR (j = 1 TO orderactioncnt)
        SET horderaction = uar_srvadditem(hreq,"orderList")
        SET srvstat = uar_srvsetdouble(horderaction,"orderId",verify_request->qual[i].orderlist[j].
         orderid)
        SET srvstat = uar_srvsetdouble(horderaction,"actionTypeCd",verify_request->qual[i].orderlist[
         j].actiontypecd)
        SET srvstat = uar_srvsetdouble(horderaction,"catalogTypeCd",verify_request->qual[i].
         orderlist[j].catalogtypecd)
        SET srvstat = uar_srvsetlong(horderaction,"lastUpdtCnt",verify_request->qual[i].orderlist[j].
         lastupdtcnt)
        SET hmisc = uar_srvadditem(horderaction,"miscList")
        SET srvstat = uar_srvsetstring(hmisc,"fieldMeaning",verify_request->qual[i].orderlist[j].
         misclist[1].fieldmeaning)
        SET srvstat = uar_srvsetdouble(hmisc,"fieldMeaningId",verify_request->qual[i].orderlist[j].
         misclist[1].fieldmeaningid)
        SET srvstat = uar_srvsetshort(hmisc,"modifiedInd",verify_request->qual[i].orderlist[j].
         misclist[1].modifiedind)
        SET hreview = uar_srvadditem(horderaction,"reviewList")
        SET srvstat = uar_srvsetshort(hreview,"reviewTypeFlag",verify_request->qual[i].orderlist[j].
         reviewlist[1].reviewtypeflag)
        SET srvstat = uar_srvsetdouble(hreview,"reviewPersonnelId",verify_request->qual[i].orderlist[
         j].reviewlist[1].reviewpersonnelid)
        SET srvstat = uar_srvsetshort(hreview,"actionSequence",verify_request->qual[i].orderlist[j].
         reviewlist[1].actionsequence)
        SET srvstat = uar_srvsetshort(hreview,"rejectedInd",verify_request->qual[i].orderlist[j].
         reviewlist[1].rejectedind)
        SET srvstat = uar_srvsetstring(horderaction,"deptMiscLine",verify_request->qual[i].orderlist[
         j].deptmiscline)
        SET srvstat = uar_srvsetdouble(horderaction,"catalogCd",verify_request->qual[i].orderlist[j].
         catalogcd)
        SET srvstat = uar_srvsetdouble(horderaction,"synonymId",verify_request->qual[i].orderlist[j].
         synonymid)
      ENDFOR
      SET iret = uar_crmperform(hstep)
      IF (iret=0)
       SET hrep = uar_crmgetreply(hstep)
       SET verify_ows_reply->qual[i].badordercnt = uar_srvgetshort(hrep,"badOrderCnt")
       SET verify_ows_reply->qual[i].grouprollbackind = uar_srvgetshort(hrep,"groupRollbackInd")
       SET verify_ows_reply->qual[i].groupbadorderindex = uar_srvgetshort(hrep,"groupBadOrderIndex")
       SET norderlistcnt = uar_srvgetitemcount(hrep,"orderList")
       IF (norderlistcnt > 0)
        SET srvstat = alterlist(verify_ows_reply->qual[i].orderlist,norderlistcnt)
        FOR (j = 1 TO norderlistcnt)
          SET horderlist = uar_srvgetitem(hrep,"orderList",i)
          SET verify_ows_reply->qual[i].orderlist[j].orderid = uar_srvgetdouble(horderlist,"orderId")
          SET verify_ows_reply->qual[i].orderlist[j].orderstatuscd = uar_srvgetdouble(horderlist,
           "orderStatusCd")
          SET verify_ows_reply->qual[i].orderlist[j].accessionnbr = uar_srvgetstringptr(horderlist,
           "accessionNbr")
          SET verify_ows_reply->qual[i].orderlist[j].errorstr = uar_srvgetstringptr(horderlist,
           "errorStr")
          SET verify_ows_reply->qual[i].orderlist[j].errornbr = uar_srvgetshort(horderlist,"errorNbr"
           )
          SET verify_ows_reply->qual[i].orderlist[j].deptstatuscd = uar_srvgetdouble(horderlist,
           "deptStatusCd")
          SET verify_ows_reply->qual[i].orderlist[j].prevdeptstatuscd = uar_srvgetdouble(horderlist,
           "prevDeptStatusCd")
          SET verify_ows_reply->qual[i].orderlist[j].schstatecd = uar_srvgetdouble(horderlist,
           "schStateCd")
          SET verify_ows_reply->qual[i].orderlist[j].orderdetaildisplayline = uar_srvgetstringptr(
           horderlist,"orderDetailDisplayLine")
          SET verify_ows_reply->qual[i].orderlist[j].origorderdttm = uar_srvgetdateptr(horderlist,
           "origOrderDtTm")
          SET verify_ows_reply->qual[i].orderlist[j].ordercommentind = uar_srvgetshort(horderlist,
           "orderCommentInd")
          SET verify_ows_reply->qual[i].orderlist[j].neednursereviewind = uar_srvgetshort(horderlist,
           "needNurseReviewInd")
          SET verify_ows_reply->qual[i].orderlist[j].needdoctorcosignind = uar_srvgetshort(horderlist,
           "needDoctorCosignInd")
          SET verify_ows_reply->qual[i].orderlist[j].actionsequence = uar_srvgetshort(horderlist,
           "actionSequence")
          SET verify_ows_reply->qual[i].orderlist[j].reviewcnt = uar_srvgetshort(horderlist,
           "reviewCnt")
          SET verify_ows_reply->qual[i].orderlist[j].detailcnt = uar_srvgetshort(horderlist,
           "detailCnt")
          SET verify_ows_reply->qual[i].orderlist[j].ingredcnt = uar_srvgetshort(horderlist,
           "ingredCnt")
          SET ningredlistcnt = uar_srvgetitemcount(horderlist,"ingredDetailCntList")
          SET srvstat = alterlist(verify_ows_reply->qual[i].orderlist[j].ingreddetailcntlist,
           ningredlistcnt)
          FOR (k = 1 TO ningredlistcnt)
            CALL echo("For loop for K")
            SET hingredlist = uar_srvgetitem(horderlist,"ingredDetailCntList",k)
            SET verify_ows_reply->qual[i].orderlist[j].ingreddetailcntlist[k].ingdetcnt =
            uar_srvgetshort(hingredlist,"ingDetCnt")
          ENDFOR
          SET nmisclistcnt = uar_srvgetitemcount(horderlist,"miscList")
          SET srvstat = alterlist(verify_ows_reply->qual[i].orderlist[j].misclist,nmisclistcnt)
          FOR (k = 1 TO nmisclistcnt)
            CALL echo("For loop for K=nmisclistcnt")
            SET hmisclist = uar_srvgetitem(horderlist,"miscList",k)
            SET verify_ows_reply->qual[i].orderlist[j].ingreddetailcntlist[k].fieldmeaning =
            uar_srvgetshort(hmisclist,"fieldMeaning")
            SET verify_ows_reply->qual[i].orderlist[j].ingreddetailcntlist[k].fieldmeaning =
            uar_srvgetstringptr(hmisclist,"fieldMeaning")
            SET verify_ows_reply->qual[i].orderlist[j].ingreddetailcntlist[k].fieldmeaningid =
            uar_srvgetdouble(hmisclist,"fieldMeaningId")
            SET verify_ows_reply->qual[i].orderlist[j].ingreddetailcntlist[k].fieldvalue =
            uar_srvgetdouble(hmisclist,"fieldValue")
            SET verify_ows_reply->qual[i].orderlist[j].ingreddetailcntlist[k].fielddisplayvalue =
            uar_srvgetstringptr(hmisclist,"fieldDisplayValue")
            SET verify_ows_reply->qual[i].orderlist[j].ingreddetailcntlist[k].fielddttmvalue =
            uar_srvgetdateptr(hmisclist,"fieldDtTmValue")
            SET verify_ows_reply->qual[i].orderlist[j].ingreddetailcntlist[k].modifiedind =
            uar_srvgetshort(hmisclist,"modifiedInd")
          ENDFOR
          SET verify_ows_reply->qual[i].orderlist[j].clinicaldisplayline = uar_srvgetstringptr(
           horderlist,"clinicalDisplayLine")
          SET verify_ows_reply->qual[i].orderlist[j].incompleteorderind = uar_srvgetshort(horderlist,
           "incompleteOrderInd")
          SET verify_ows_reply->qual[i].orderlist[j].orderactionid = uar_srvgetdouble(horderlist,
           "orderActionId")
          SET verify_ows_reply->qual[i].orderlist[j].specificerrornbr = uar_srvgetshort(horderlist,
           "specificErrorNbr")
          SET verify_ows_reply->qual[i].orderlist[j].specificerrorstr = uar_srvgetstringptr(
           horderlist,"specificErrorStr")
          SET verify_ows_reply->qual[i].orderlist[j].actionstatus = uar_srvgetshort(horderlist,
           "actionStatus")
        ENDFOR
       ENDIF
       SET horderstatusdata = uar_srvgetstruct(hrep,"status_data")
       SET verify_ows_reply->qual[i].status_data[k].status = uar_srvgetstringptr(horderstatusdata,
        "status")
       SET nsubeventstatuscnt = uar_srvgetitemcount(horderstatusdata,"subEventStatus")
       IF (nsubeventstatuscnt > 0)
        SET srvstat = alterlist(verify_ows_reply->qual[i].status_data.subeventstatus,
         nsubeventstatuscnt)
        FOR (m = 1 TO nsubeventstatuscnt)
          SET hsubeventstatus = uar_srvgetitem(horderstatusdata,"subEventStatus",m)
          SET verify_ows_reply->qual[i].status_data.subeventstatus[m].operationname =
          uar_srvgetstringptr(hsubeventstatus,"OperationName")
          SET verify_ows_reply->qual[i].status_data.subeventstatus[m].operationstatus =
          uar_srvgetstringptr(hsubeventstatus,"OperationStatus")
          SET verify_ows_reply->qual[i].status_data.subeventstatus[m].targetobjectname =
          uar_srvgetstringptr(hsubeventstatus,"TargetObjectName")
          SET verify_ows_reply->qual[i].status_data.subeventstatus[m].targetobjectvalue =
          uar_srvgetstringptr(hsubeventstatus,"TargetObjectValue")
          SET verify_ows_reply->qual[i].status_data.subeventstatus[m].requestnumber = uar_srvgetshort
          (hsubeventstatus,"RequestNumber")
          SET verify_ows_reply->qual[i].status_data.subeventstatus[m].orderid = uar_srvgetdouble(
           hsubeventstatus,"OrderId")
          SET verify_ows_reply->qual[i].status_data.subeventstatus[m].actionseq = uar_srvgetshort(
           hsubeventstatus,"ActionSeq")
          SET verify_ows_reply->qual[i].status_data.subeventstatus[m].substatus = uar_srvgetstringptr
          (hsubeventstatus,"accessionNbr")
        ENDFOR
       ENDIF
       SET verify_ows_reply->qual[i].errornbr = uar_srvgetshort(hrep,"errorNbr")
       SET verify_ows_reply->qual[i].errorstr = uar_srvgetstringptr(hrep,"errorStr")
       SET verify_ows_reply->qual[i].specificerrornbr = uar_srvgetshort(hrep,"specificErrorNbr")
       SET verify_ows_reply->qual[i].specificerrorstr = uar_srvgetstringptr(hrep,"specificErrorStr")
       SET verify_ows_reply->qual[i].transactionstatus = uar_srvgetshort(hrep,"transactionStatus")
       IF ((verify_ows_reply->qual[i].status_data[k].status="S"))
        SET verify_request->qual[i].ows_status = "Success"
       ELSE
        SET verify_request->qual[i].ows_status = "Failure"
       ENDIF
       SET srvstat = uar_srvdestroyhandle(hrep)
      ELSE
       CALL echo("Perform Failure")
       SET fail_flag = perform_fail
       GO TO check_error
      ENDIF
      SET srvstat = uar_srvdestroyhandle(hrep)
     ELSE
      CALL echo("Req_failure")
      SET fail_flag = begin_req_fail
      GO TO check_error
     ENDIF
    ENDFOR
   ELSE
    CALL echo("task_failure")
    SET fail_flag = begin_task_fail
    GO TO check_error
   ENDIF
  ELSE
   CALL echo("App_failure")
   SET fail_flag = begin_app_fail
   GO TO check_error
  ENDIF
  CALL uar_crmendapp(happ)
  CALL uar_crmendtask(htask)
  CALL uar_crmendreq(hstep)
  SET srvstat = uar_srvdestroyhandle(hreq)
  SET srvstat = uar_srvdestroyhandle(happ)
  SET srvstat = uar_srvdestroyhandle(htask)
  SET srvstat = uar_srvdestroyhandle(hstep)
 ENDIF
 SELECT INTO  $1
  FROM (dummyt d  WITH seq = value(od_idx))
  HEAD REPORT
   line = fillstring(140,"-"), today = format(curdate,"MM/DD/YYYY;;D"), now = format(curtime,
    "HH:MM:SS;;S"),
   grand_tot_orders = 0, row 3
   IF (update_flag="U")
    col 10, "Autoverify Orders Update Report",
    CALL echo("Update Flag= U - report section")
   ELSE
    col 10, "Autoverify Orders Report"
   ENDIF
   row + 1, col 10, "Report Date: ",
   col + 1, today, row + 1,
   col 10, "Report Time: ", col + 1,
   now, row + 1, col 0,
   line, row + 1
  HEAD PAGE
   col 0, "Page: ", col + 1,
   curpage, row + 1, col 0,
   "Order_Id", col 16, "Display_line",
   col 53, "Acct #", col 65,
   "Encntr Type", col 80, "Location",
   col 97, "Adm Dt", col 108,
   "Dis Dt", col 118, "Ord Stat"
   IF (update_flag="U")
    col 130, "Order Write Server Status",
    CALL echo("Update Flag= U - Order Write Server Status section")
   ENDIF
   row + 1, col 0, line,
   row + 1
  HEAD d.seq
   col 0, verify_request->qual[d.seq].orderid, col 16,
   verify_request->qual[d.seq].display_line, col 50, verify_request->qual[d.seq].encntrfinancialid,
   col 63, verify_request->qual[d.seq].encntr_type, col 83,
   verify_request->qual[d.seq].locationcd, col 96, verify_request->qual[d.seq].adm_dt,
   col 107, verify_request->qual[d.seq].disch_dt, col 120,
   verify_request->qual[d.seq].order_status_disp
   IF (update_flag="U")
    col 130, verify_request->qual[d.seq].ows_status,
    CALL echo("Update Flag= U - OWS Status section")
   ENDIF
   row + 1
  FOOT REPORT
   grand_tot_orders = count(d.seq), row + 1, col 16,
   "Number of orders: ", col + 1, grand_tot_orders,
   row + 2, col 10, "***** END OF REPORT *****"
  WITH maxcol = 200
 ;end select
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF update_invalid:
    SET reply->status_data.subeventstatus[1].operationname = "CHECK"
    SET reply->status_data.subeventstatus[1].targetobjectname = "UPDATE_REPORT"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Update or Report is not U or R - please retry"
   OF from_order_invalid:
    SET reply->status_data.subeventstatus[1].operationname = "CHECK"
    SET reply->status_data.subeventstatus[1].targetobjectname = "FROM_ORDER_ID"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "From Order_id is not numeric - please retry"
   OF to_order_invalid:
    SET reply->status_data.subeventstatus[1].operationname = "CHECK"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TO_ORDER_ID"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "To Order_id is not numeric - please retry"
   OF personnel_invalid:
    SET reply->status_data.subeventstatus[1].operationname = "CHECK"
    SET reply->status_data.subeventstatus[1].targetobjectname = "PERSONNEL_ID"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Personnel_id is not numeric - please retry"
   OF personnel_not_pharm:
    SET reply->status_data.subeventstatus[1].operationname = "CHECK"
    SET reply->status_data.subeventstatus[1].targetobjectname = "PERSONNEL_ID"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Personnel_id is not a Pharmacist - please retry"
   OF from_to_invalid:
    SET reply->status_data.subeventstatus[1].operationname = "CHECK"
    SET reply->status_data.subeventstatus[1].targetobjectname = "FROM_ORDER_ID"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "From Order_id > To Order_id - please retry"
   OF no_orders:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "No orders were found to update."
   OF begin_app_fail:
    SET reply->status_data.subeventstatus[1].operationname = "BeginApp"
    SET reply->status_data.subeventstatus[1].targetobjectname = "APPLICATION"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("BeginAppFailure: ",cnvtstring
     (applicationid))
   OF begin_task_fail:
    SET reply->status_data.subeventstatus[1].operationname = "BeginTask"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TASK"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("BeginTask Failure: ",
     cnvtstring(taskid))
    CALL uar_crmendapp(happ)
    SET srvstat = uar_srvdestroyhandle(happ)
   OF begin_req_fail:
    SET reply->status_data.subeventstatus[1].operationname = "BeginReq"
    SET reply->status_data.subeventstatus[1].targetobjectname = "REQUEST"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("BeginReq Failure: ",
     cnvtstring(requestid))
    CALL uar_crmendapp(happ)
    CALL uar_crmendtask(htask)
    SET srvstat = uar_srvdestroyhandle(happ)
    SET srvstat = uar_srvdestroyhandle(htask)
   OF perform_fail:
    SET reply->status_data.subeventstatus[1].operationname = "Perform"
    SET reply->status_data.subeventstatus[1].targetobjectname = "STEP"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("Perform Failure: ",cnvtstring
     (requestid))
    CALL uar_crmendapp(happ)
    CALL uar_crmendtask(htask)
    CALL uar_crmendreq(hstep)
    SET srvstat = uar_srvdestroyhandle(hreq)
    SET srvstat = uar_srvdestroyhandle(happ)
    SET srvstat = uar_srvdestroyhandle(htask)
    SET srvstat = uar_srvdestroyhandle(hstep)
   OF option_invalid:
    SET reply->status_data.subeventstatus[1].operationname = "CHECK"
    SET reply->status_data.subeventstatus[1].targetobjectname = "INCLUDE_ORD"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Include orders needing product assignment is not Y or N - please retry"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ENDIF
 IF ((reply->status_data.subeventstatus[1].operationstatus="F"))
  CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 ENDIF
END GO
