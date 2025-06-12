CREATE PROGRAM bhs_orm_rpt_erx_activity_ops:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD aralist(
   1 qual[*]
     2 dea = vc
     2 npi = vc
     2 statelicense = vc
     2 state = vc
     2 zipcode = vc
     2 date = vc
     2 electroniccount = vc
     2 faxcount = vc
     2 printcount = vc
     2 rxhubcount = vc
 )
 DECLARE sftp_file(null) = i2
 DECLARE validaterequiredprsnldetails(null) = i2
 DECLARE validaterequireddetails(null) = i2
 DECLARE getbatchparameters(null) = i2
 DECLARE failed_ind = i2 WITH protect, noconstant(0)
 DECLARE prsnlid = vc WITH protect
 DECLARE deanum = vc WITH protect
 DECLARE npinum = vc WITH protect
 DECLARE statelicensenum = vc WITH protect
 DECLARE state = vc WITH protect
 DECLARE zipcode = vc WITH protect
 DECLARE fname = vc WITH protect
 DECLARE lname = vc WITH protect
 DECLARE date = vc WITH protect
 DECLARE orderid = vc WITH protect
 DECLARE orderedasmnemonic = vc WITH protect
 DECLARE strengthdose = vc WITH protect
 DECLARE strengthunit = vc WITH protect
 DECLARE drugstrength = vc WITH protect
 DECLARE doseform = vc WITH protect
 DECLARE prescribeddate = vc WITH protect
 DECLARE prescribedqty = vc WITH protect
 DECLARE prescribedrefills = vc WITH protect
 DECLARE daw = vc WITH protect
 DECLARE outputdest = i4 WITH protect
 DECLARE prescriptiondeliverymthd = vc WITH protect
 DECLARE formularystatus = vc WITH protect
 DECLARE flatcopayamt = vc WITH protect
 DECLARE pctcopayrate = vc WITH protect
 DECLARE copaymthd = vc WITH protect
 DECLARE copaytier = vc WITH protect
 DECLARE ageind = vc WITH protect
 DECLARE prodexcind = vc WITH protect
 DECLARE genderind = vc WITH protect
 DECLARE mednecessityind = vc WITH protect
 DECLARE priorauthind = vc WITH protect
 DECLARE qtyind = vc WITH protect
 DECLARE rsrcdrugind = vc WITH protect
 DECLARE rsrcsmryind = vc WITH protect
 DECLARE stepmedsind = vc WITH protect
 DECLARE steptherapyind = vc WITH protect
 DECLARE txtmsgind = vc WITH protect
 DECLARE coverageind = vc WITH protect
 DECLARE healthplanid = vc WITH protect
 DECLARE groupident = vc WITH protect
 DECLARE altid = vc WITH protect
 DECLARE coverageid = vc WITH protect
 DECLARE copayid = vc WITH protect
 DECLARE aracount = i4 WITH protect, noconstant(0)
 DECLARE electroniccount = i4 WITH protect, noconstant(0)
 DECLARE faxcount = i4 WITH protect, noconstant(0)
 DECLARE printcount = i4 WITH protect, noconstant(0)
 DECLARE rxhubcount = i4 WITH protect, noconstant(0)
 DECLARE docdeacd = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"DOCDEA"))
 DECLARE npicd = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"NPI"))
 DECLARE licensenbrcd = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"LICENSENBR"))
 DECLARE orderactioncd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE businessaddresscd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"BUSINESS"))
 DECLARE demogreltncd = f8 WITH protect, constant(uar_get_code_by("MEANING",30300,"DEMOGRELTN"))
 DECLARE remotehost = vc WITH noconstant("")
 DECLARE remotepath = vc WITH noconstant("")
 DECLARE remoteuser = vc WITH noconstant("")
 DECLARE homepath = vc WITH noconstant("CCLUSERDIR")
 DECLARE filename = vc WITH noconstant("")
 DECLARE startdate = dq8 WITH protect
 DECLARE enddate = dq8 WITH protect
 DECLARE clientmnemonic = vc WITH protect, noconstant("")
 SET bstatus = getbatchparameters(null)
 IF (bstatus != 1)
  SET failed_ind = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  dmi.info_char
  FROM dm_info dmi
  WHERE dmi.info_name="CLIENT MNEMONIC"
   AND dmi.info_domain="DATA MANAGEMENT"
  DETAIL
   clientmnemonic = trim(cnvtlower(dmi.info_char),7)
  WITH nocounter
 ;end select
 IF (((clientmnemonic="") OR (trim(clientmnemonic,7)="")) )
  SET failed_ind = 1
  GO TO exit_script
 ENDIF
 SET filename = concat("ear_",clientmnemonic,"_",trim(curnode),"_",
  trim(format(startdate,"YYYYMMDD;;d"),7),"_",trim(format(enddate,"YYYYMMDD;;d"),7),"_",trim(format(
    curdate,"YYYYMMDD;;d"),7),
  "_",trim(format(curtime2,"HHMMSS;;M"),7),".rxh")
 SELECT INTO value(filename)
  eal.*, pa.alias, adr.zipcode,
  prsnl.person_id, prsnl.name_first, prsnl.name_last,
  date = format(o.orig_order_dt_tm,"yyyymmdd"), o.orig_order_dt_tm, o.order_id,
  o.ordered_as_mnemonic, ered.copay_list_key, ered.coverage_list_key,
  ered.formulary_list_key, ered.group_ident, ered.health_plan_id,
  od.oe_field_display_value, od.oe_field_meaning_id, od.oe_field_value
  FROM orm_erx_activity_log eal,
   address adr,
   prsnl prsnl,
   orders o,
   order_action oa,
   encounter enc,
   prsnl_alias pa,
   eem_rx_elig_detail ered,
   order_detail od
  PLAN (eal
   WHERE eal.updt_dt_tm >= cnvtdatetime(startdate)
    AND eal.updt_dt_tm <= cnvtdatetime(enddate))
   JOIN (o
   WHERE o.order_id=eal.order_id)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=orderactioncd)
   JOIN (prsnl
   WHERE prsnl.person_id=oa.order_provider_id)
   JOIN (enc
   WHERE enc.encntr_id=o.encntr_id)
   JOIN (pa
   WHERE pa.person_id=prsnl.person_id
    AND pa.prsnl_alias_type_cd IN (docdeacd, npicd, licensenbrcd)
    AND pa.active_ind=1
    AND (( EXISTS (
   (SELECT
    pr.prsnl_reltn_id
    FROM prsnl_reltn pr,
     prsnl_reltn_child prc
    WHERE pr.person_id=pa.person_id
     AND pr.parent_entity_name="ORGANIZATION"
     AND pr.parent_entity_id=enc.organization_id
     AND pr.reltn_type_cd=demogreltncd
     AND pr.active_ind=1
     AND prc.prsnl_reltn_id=pr.prsnl_reltn_id
     AND prc.parent_entity_name="PRSNL_ALIAS"
     AND prc.parent_entity_id=pa.prsnl_alias_id))) OR ( NOT ( EXISTS (
   (SELECT
    prc.prsnl_reltn_child_id
    FROM prsnl_reltn_child prc,
     prsnl_reltn pr
    WHERE prc.parent_entity_name="PRSNL_ALIAS"
     AND prc.parent_entity_id=pa.prsnl_alias_id
     AND pr.prsnl_reltn_id=prc.prsnl_reltn_id
     AND pr.person_id=pa.person_id
     AND pr.parent_entity_name="ORGANIZATION"
     AND pr.reltn_type_cd=demogreltncd
     AND pr.active_ind=1)))
    AND  NOT ( EXISTS (
   (SELECT
    pr.prsnl_reltn_id
    FROM prsnl_reltn pr,
     prsnl_reltn_child prc,
     prsnl_alias pa2
    WHERE pr.person_id=pa.person_id
     AND pr.parent_entity_name="ORGANIZATION"
     AND pr.parent_entity_id=enc.organization_id
     AND pr.reltn_type_cd=demogreltncd
     AND pr.active_ind=1
     AND prc.prsnl_reltn_id=pr.prsnl_reltn_id
     AND prc.parent_entity_name="PRSNL_ALIAS"
     AND prc.parent_entity_id=pa2.prsnl_alias_id
     AND pa2.person_id=pa.person_id
     AND pa2.prsnl_alias_type_cd=pa.prsnl_alias_type_cd
     AND pa2.active_ind=1))))) )
   JOIN (ered
   WHERE ered.person_id=outerjoin(o.person_id)
    AND ered.reply_dt_tm <= outerjoin(o.orig_order_dt_tm)
    AND ered.data_expire_dt_tm > outerjoin(o.orig_order_dt_tm))
   JOIN (adr
   WHERE adr.parent_entity_name="ORGANIZATION"
    AND adr.parent_entity_id=enc.organization_id
    AND adr.address_type_cd=businessaddresscd)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND ((od.oe_field_meaning_id=2056) OR (((od.oe_field_meaning_id=2057) OR (((od
   .oe_field_meaning_id=2014) OR (((od.oe_field_meaning_id=2022) OR (((od.oe_field_meaning_id=67) OR
   (((od.oe_field_meaning_id=2017) OR (((od.oe_field_meaning_id=1563) OR (od.oe_field_meaning_id=138
   )) )) )) )) )) )) )) )
  ORDER BY prsnl.person_id, enc.organization_id, date,
   o.order_id, ered.interchange_id DESC
  HEAD prsnl.person_id
   prsnlid = trim(cnvtstring(prsnl.person_id),7), fname = trim(substring(0,35,prsnl.name_first),7),
   lname = trim(substring(0,35,prsnl.name_last),7),
   count = 0
  HEAD enc.organization_id
   dummyvar = ""
  HEAD date
   electroniccount = 0, faxcount = 0, printcount = 0,
   rxhubcount = 0
  HEAD o.order_id
   orderid = trim(cnvtstring(o.order_id),7), prescribeddate = trim(format(o.orig_order_dt_tm,
     "yyyymmdd"),7), flatcopayamt = "",
   pctcopayrate = "", copaymthd = "", copaytier = "",
   formularystatus = trim(substring(0,2,cnvtstring(eal.fb_formulary_status)),7)
   IF (formularystatus="-1")
    formularystatus = "U"
   ENDIF
   IF (eal.fb_copay_fixed_amt > 0)
    flatcopayamt = trim(substring(0,10,cnvtstring(eal.fb_copay_fixed_amt,10,2)),7)
   ENDIF
   IF (eal.fb_copay_pct_nbr > 0)
    pctcopayrate = trim(substring(0,10,cnvtstring(eal.fb_copay_pct_nbr,10,2)),7)
   ENDIF
   copaymthd = trim(eal.fb_copay_mthd_txt)
   IF (copaymthd != "F"
    AND copaymthd != "P")
    copaymthd = ""
   ENDIF
   IF (eal.fb_copay_tier_nbr >= 0)
    copaytier = trim(substring(0,2,cnvtstring(eal.fb_copay_tier_nbr)),7)
   ENDIF
   ageind = "N", prodexcind = "N", genderind = "N",
   mednecessityind = "N", priorauthind = "N", qtyind = "N",
   rsrcdrugind = "N", rsrcsmryind = "N", stepmedsind = "N",
   steptherapyind = "N", txtmsgind = "N", coverageind = "N"
   IF (eal.fb_detail_viewed_ind=1)
    IF (eal.fb_age_limit_ind=1)
     ageind = "Y"
    ENDIF
    IF (eal.fb_prod_exc_ind=1)
     prodexcind = "Y"
    ENDIF
    IF (eal.fb_gender_limit_ind=1)
     genderind = "Y"
    ENDIF
    IF (eal.fb_med_necessity_ind=1)
     mednecessityind = "Y"
    ENDIF
    IF (eal.fb_prior_auth_ind=1)
     priorauthind = "Y"
    ENDIF
    IF (eal.fb_qty_limit_ind=1)
     qtyind = "Y"
    ENDIF
    IF (eal.fb_rsrc_drug_ind=1)
     rsrcdrugind = "Y"
    ENDIF
    IF (eal.fb_rsrc_smry_ind=1)
     rsrcsmryind = "Y"
    ENDIF
    IF (eal.fb_step_meds_ind=1)
     stepmedsind = "Y"
    ENDIF
    IF (eal.fb_step_therapy_ind=1)
     steptherapyind = "Y"
    ENDIF
    IF (eal.fb_txt_msg_ind=1)
     txtmsgind = "Y"
    ENDIF
   ENDIF
   IF (((ageind="Y") OR (((prodexcind="Y") OR (((genderind="Y") OR (((mednecessityind="Y") OR (((
   priorauthind="Y") OR (((qtyind="Y") OR (((rsrcdrugind="Y") OR (((rsrcsmryind="Y") OR (((
   stepmedsind="Y") OR (((steptherapyind="Y") OR (txtmsgind="Y")) )) )) )) )) )) )) )) )) )) )
    coverageind = "Y"
   ENDIF
   orderedasmnemonic = trim(substring(0,35,o.ordered_as_mnemonic),7), healthplanid = "", groupident
    = "",
   altid = "", coverageid = "", copayid = ""
   IF (ered.health_plan_id > 0)
    healthplanid = trim(substring(0,35,cnvtstring(ered.health_plan_id)),7), groupident = trim(
     substring(0,35,ered.group_ident),7), altid = trim(substring(0,10,ered.formulary_alt_list_key),7),
    coverageid = trim(substring(0,10,ered.coverage_list_key),7), copayid = trim(substring(0,10,ered
      .copay_list_key),7)
   ENDIF
   strengthdose = "", strengthunit = "", doseform = "",
   prescribedqty = "", prescribedrefills = "", daw = "",
   prescriptiondeliverymthd = "", outputdest = 0, deanum = "",
   npinum = "", statelicensenum = "", state = "",
   zipcode = ""
  HEAD pa.prsnl_alias_id
   IF (pa.prsnl_alias_type_cd=docdeacd)
    deanum = substring(0,35,pa.alias)
   ELSEIF (pa.prsnl_alias_type_cd=npicd)
    npinum = substring(0,35,pa.alias)
   ELSEIF (pa.prsnl_alias_type_cd=licensenbrcd
    AND adr.state_cd > 0
    AND adr.zipcode != ""
    AND size(adr.zipcode)=5)
    statelicensenum = substring(0,35,pa.alias), state = uar_get_code_meaning(adr.state_cd), zipcode
     = adr.zipcode
   ENDIF
  HEAD od.oe_field_meaning_id
   IF (od.oe_field_meaning_id=2056)
    strengthdose = trim(substring(0,35,od.oe_field_display_value),7)
   ELSEIF (od.oe_field_meaning_id=2057)
    strengthunit = trim(substring(0,35,od.oe_field_display_value),7)
   ELSEIF (od.oe_field_meaning_id=2014)
    doseform = trim(substring(0,35,od.oe_field_display_value),7)
   ELSEIF (od.oe_field_meaning_id=2022)
    prescribedqty = trim(substring(0,35,od.oe_field_display_value),7)
   ELSEIF (od.oe_field_meaning_id=67)
    prescribedrefills = trim(substring(0,35,od.oe_field_display_value),7)
   ELSEIF (od.oe_field_meaning_id=2017)
    daw = trim(substring(0,1,od.oe_field_display_value),7)
   ELSEIF (od.oe_field_meaning_id=1563)
    IF (od.oe_field_value=uar_get_code_by("MEANING",3575,"PRINT"))
     prescriptiondeliverymthd = "P"
    ELSEIF (od.oe_field_value=uar_get_code_by("MEANING",3575,"PHARMEDI"))
     prescriptiondeliverymthd = "E"
    ELSEIF (od.oe_field_value=uar_get_code_by("MEANING",3575,"DONOTROUTE"))
     prescriptiondeliverymthd = "F"
    ENDIF
   ELSEIF (od.oe_field_meaning_id=138)
    outputdest = cnvtint(od.oe_field_display_value)
   ENDIF
  FOOT  o.order_id
   len = (size(strengthdose)+ size(strengthunit))
   IF (len <= 35)
    drugstrength = concat(strengthdose," ",strengthunit)
   ENDIF
   IF (prescriptiondeliverymthd="P")
    IF (outputdest > 0)
     prescriptiondeliverymthd = "F", faxcount = (faxcount+ 1)
    ELSE
     printcount = (printcount+ 1)
    ENDIF
   ELSEIF (prescriptiondeliverymthd="F")
    faxcount = (faxcount+ 1)
   ELSEIF (prescriptiondeliverymthd="E")
    electroniccount = (electroniccount+ 1)
   ELSEIF (prescriptiondeliverymthd="R")
    rxhubcount = (rxhubcount+ 1)
   ENDIF
   bstatus = validaterequireddetails(null)
   IF (bstatus)
    col + 0, "ARD", col + 0,
    "|", col + 0, col + 0,
    "|", col + 0, col + 0,
    "|", col + 0
    IF (deanum != "")
     deanum
    ENDIF
    col + 0, "|", col + 0
    IF (npinum != "")
     npinum
    ENDIF
    col + 0, "|", col + 0
    IF (statelicensenum != "")
     statelicensenum
    ENDIF
    col + 0, "|", col + 0
    IF (state != "")
     state
    ENDIF
    col + 0, "|", col + 0
    IF (zipcode != "")
     zipcode
    ENDIF
    col + 0, "|", col + 0,
    prsnlid, col + 0, "|",
    col + 0, prescribeddate, col + 0,
    "|", col + 0, fname,
    col + 0, "|", col + 0,
    lname, col + 0, "|",
    col + 0
    IF (healthplanid != "")
     healthplanid
    ENDIF
    col + 0, "|", col + 0
    IF (groupident != "")
     groupident
    ENDIF
    col + 0, "|", col + 0,
    orderid, col + 0, "|",
    col + 0, col + 0, "|",
    col + 0
    IF (altid != "")
     altid
    ENDIF
    col + 0, "|", col + 0
    IF (coverageid != "")
     coverageid
    ENDIF
    col + 0, "|", col + 0
    IF (copayid != "")
     copayid
    ENDIF
    col + 0, "|", col + 0,
    formularystatus, col + 0, "|",
    col + 0
    IF (flatcopayamt != "")
     flatcopayamt
    ENDIF
    col + 0, "|", col + 0
    IF (pctcopayrate != "")
     pctcopayrate
    ENDIF
    col + 0, "|", col + 0
    IF (copaymthd != "")
     copaymthd
    ENDIF
    col + 0, "|", col + 0
    IF (copaytier != "")
     copaytier
    ENDIF
    col + 0, "|", col + 0,
    ageind, col + 0, "|",
    col + 0, prodexcind, col + 0,
    "|", col + 0, genderind,
    col + 0, "|", col + 0,
    mednecessityind, col + 0, "|",
    col + 0, priorauthind, col + 0,
    "|", col + 0, qtyind,
    col + 0, "|", col + 0,
    rsrcdrugind, col + 0, "|",
    col + 0, rsrcsmryind, col + 0,
    "|", col + 0, stepmedsind,
    col + 0, "|", col + 0,
    steptherapyind, col + 0, "|",
    col + 0, txtmsgind, col + 0,
    "|", col + 0, col + 0,
    "|", col + 0, col + 0,
    "|", col + 0
    IF (orderedasmnemonic != "")
     orderedasmnemonic
    ENDIF
    col + 0, "|", col + 0
    IF (drugstrength != "")
     drugstrength
    ENDIF
    col + 0, "|", col + 0
    IF (doseform != "")
     doseform
    ENDIF
    col + 0, "|", col + 0
    IF (prescribedqty != "")
     prescribedqty
    ENDIF
    col + 0, "|", col + 0,
    col + 0, "|", col + 0
    IF (prescribedrefills != "")
     prescribedrefills
    ENDIF
    col + 0, "|", col + 0
    IF (daw != "")
     daw
    ENDIF
    col + 0, "|", col + 0,
    col + 0, "|", col + 0,
    col + 0, "|", col + 0,
    "APP", col + 0, "|",
    col + 0, prescriptiondeliverymthd, col + 0,
    "|", col + 0, col + 0,
    "|", col + 0
    IF (formularystatus != "")
     formularystatus
    ENDIF
    col + 0, "|", col + 0
    IF (flatcopayamt != "")
     flatcopayamt
    ENDIF
    col + 0, "|", col + 0
    IF (pctcopayrate != "")
     pctcopayrate
    ENDIF
    col + 0, "|", col + 0
    IF (copaymthd != "")
     copaymthd
    ENDIF
    col + 0, "|", col + 0
    IF (copaytier != "")
     copaytier
    ENDIF
    col + 0, "|", col + 0,
    col + 0, "|", col + 0,
    col + 0, "|", col + 0
    IF (orderedasmnemonic != "")
     orderedasmnemonic
    ENDIF
    col + 0, "|", col + 0,
    coverageind, col + 0, "|",
    col + 0, txtmsgind, col + 0,
    "|", col + 0, rsrcsmryind,
    row + 1
   ENDIF
  FOOT  date
   IF (((electroniccount > 0) OR (((faxcount > 0) OR (((printcount > 0) OR (rxhubcount > 0)) )) )) )
    aracount = (aracount+ 1), stat = alterlist(aralist->qual,aracount), aralist->qual[aracount].date
     = format(o.orig_order_dt_tm,"yyyymmdd"),
    aralist->qual[aracount].dea = deanum, aralist->qual[aracount].npi = npinum, aralist->qual[
    aracount].statelicense = statelicensenum,
    aralist->qual[aracount].state = state, aralist->qual[aracount].zipcode = zipcode, aralist->qual[
    aracount].electroniccount = trim(cnvtstring(electroniccount),7),
    aralist->qual[aracount].faxcount = trim(cnvtstring(faxcount),7), aralist->qual[aracount].
    printcount = trim(cnvtstring(printcount),7), aralist->qual[aracount].rxhubcount = trim(cnvtstring
     (rxhubcount),7)
   ENDIF
  FOOT REPORT
   row + 3
   FOR (x = 1 TO aracount)
     col + 0, "ARA", col + 0,
     "|", col + 0, col + 0,
     "|", col + 0, col + 0,
     "|", col + 0
     IF ((aralist->qual[x].dea != ""))
      aralist->qual[x].dea
     ENDIF
     col + 0, "|", col + 0
     IF ((aralist->qual[x].npi != ""))
      aralist->qual[x].npi
     ENDIF
     col + 0, "|", col + 0
     IF ((aralist->qual[x].statelicense != ""))
      aralist->qual[x].statelicense
     ENDIF
     col + 0, "|", col + 0
     IF ((aralist->qual[x].state != ""))
      aralist->qual[x].state
     ENDIF
     col + 0, "|", col + 0
     IF ((aralist->qual[x].zipcode != ""))
      aralist->qual[x].zipcode
     ENDIF
     col + 0, "|", col + 0,
     col + 0, "|", col + 0,
     aralist->qual[x].date, col + 0, "|",
     col + 0, aralist->qual[x].electroniccount, col + 0,
     "|", col + 0, aralist->qual[x].faxcount,
     col + 0, "|", col + 0,
     aralist->qual[x].printcount, col + 0, "|",
     col + 0, aralist->qual[x].rxhubcount, row + 1
   ENDFOR
   bstatus = sftp_file(null)
   IF (bstatus != 1)
    failed_ind = 1
   ENDIF
  WITH nocounter, maxcol = 32720, maxrow = 1,
   memsort, format = variable, nullreport
 ;end select
 GO TO exit_script
 SUBROUTINE sftp_file(null)
   DECLARE command = vc WITH private, noconstant("")
   DECLARE connectstring = vc WITH private, noconstant("")
   DECLARE logfile = vc WITH private, constant("orm_rpt_erx_activity_log.log")
   SET cmd_status = 0
   SET connectstring = remotehost
   IF (remoteuser != "")
    SET connectstring = concat(remoteuser,"@",remotehost)
   ENDIF
   IF (cursys2="AXP")
    SET command = concat("PIPE WRITE SYS$OUTPUT ",'"',"put /",homepath,"/",
     filename,'"'," | sftp ",'"',"-B",
     '"'," - ",connectstring)
   ELSE
    SET command = concat("echo ",'"put $',homepath,"/",filename,
     " ",remotepath,"\n",'exit\n"'," | ",
     "sftp -v -b - ",connectstring," > $",homepath,"/",
     logfile," 2>&1")
   ENDIF
   CALL dcl(command,size(trim(command)),cmd_status)
   IF (cmd_status != 1)
    RETURN(false)
   ELSE
    RETURN(true)
   ENDIF
 END ;Subroutine
 SUBROUTINE validaterequiredprsnldetails(null)
  IF (((deanum != "") OR (((npinum != "") OR (statelicensenum != ""
   AND state != ""
   AND zipcode != "")) )) )
   RETURN(true)
  ENDIF
  RETURN(false)
 END ;Subroutine
 SUBROUTINE validaterequireddetails(null)
   SET bstatus = validaterequiredprsnldetails(null)
   IF (bstatus)
    IF (size(prescribeddate)=8
     AND fname != ""
     AND size(fname) <= 35
     AND lname != ""
     AND size(lname) <= 35
     AND orderid != ""
     AND size(orderid) <= 50
     AND formularystatus != ""
     AND size(formularystatus) <= 2
     AND prescriptiondeliverymthd != ""
     AND size(prescriptiondeliverymthd)=1)
     RETURN(true)
    ENDIF
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE getbatchparameters(null)
   DECLARE ops_ind = c1 WITH noconstant(" ")
   DECLARE idx = i4 WITH private, noconstant(1)
   DECLARE start_idx = i4 WITH private, noconstant(1)
   SET ops_ind = validate(request->batch_selection,"N")
   IF (ops_ind != "N")
    SET idx = findstring(";",request->batch_selection,start_idx)
    IF (idx < 1)
     RETURN(false)
    ENDIF
    SET remotehost = trim(substring(start_idx,(idx - start_idx),request->batch_selection),3)
    SET start_idx = (idx+ 1)
    SET idx = findstring(";",request->batch_selection,start_idx)
    IF (idx < 1)
     RETURN(false)
    ENDIF
    SET remoteuser = trim(substring(start_idx,(idx - start_idx),request->batch_selection),3)
    SET start_idx = (idx+ 1)
    SET idx = findstring(";",request->batch_selection,start_idx)
    IF (idx < 1)
     RETURN(false)
    ENDIF
    SET remotepath = trim(substring(start_idx,(idx - start_idx),request->batch_selection),3)
    SET startdate = cnvtdatetime((curdate - 7),0)
    SET enddate = cnvtdatetime((curdate - 1),235959)
   ELSE
    SET remotehost = request->sftp_host
    SET remoteuser = request->sftp_user
    SET remotepath = request->sftp_remotepath
    SET startdate = cnvtdatetime(cnvtdate2(request->start_date,"MMDDYYYY"),0)
    SET enddate = cnvtdatetime(cnvtdate2(request->end_date,"MMDDYYYY"),235959)
   ENDIF
   IF (remotehost=""
    AND remoteuser=""
    AND remotepath="")
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
#exit_script
 IF (failed_ind=0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  CALL echo("The script failed.")
 ENDIF
 SET script_version = "MOD 001 JT018805 12/1/2009"
END GO
