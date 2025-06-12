CREATE PROGRAM bb_get_qc_inquiry_results:dba
 SET modify = predeclare
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 group_qual[*]
      2 group_id = f8
      2 group_name = c40
      2 service_resource_cd = f8
      2 service_resource_disp = c40
      2 require_validation_ind = i2
      2 schedule_cd = f8
      2 schedule_disp = c40
      2 group_activity_qual[*]
        3 scheduled_dt_tm = dq8
        3 reagent_qual[*]
          4 group_reagent_lot_id = f8
          4 related_reagent_id = f8
          4 lot_ident = c40
          4 status_cd = f8
          4 status_disp = c40
          4 parent_entity_cd = f8
          4 parent_entity_disp = c40
          4 manufacturer_cd = f8
          4 manufacturer_disp = c40
          4 group_reagent_activity_id = f8
          4 visual_inspection_cd = f8
          4 visual_inspection_disp = c40
          4 interpretation_cd = f8
          4 interpretation_disp = c40
          4 result_qual[*]
            5 qc_result_id = f8
            5 enhancement_activity_id = f8
            5 enhancement_media_cd = f8
            5 enhancement_media_disp = c40
            5 enhancement_manf_cd = f8
            5 enhancement_manf_disp = c40
            5 enhancement_lot_number = vc
            5 enhancement_status_cd = f8
            5 enhancement_status_disp = c40
            5 control_activity_id = f8
            5 control_media_cd = f8
            5 control_media_disp = c40
            5 control_manf_cd = f8
            5 control_manf_disp = c40
            5 control_lot_number = vc
            5 control_status_cd = f8
            5 control_status_disp = c40
            5 mnemonic = c25
            5 result_dt_tm = dq8
            5 result_prsnl_id = f8
            5 result_prsnl_username = c20
            5 abnormal_ind = i2
            5 reason_cd = f8
            5 reason_disp = c40
            5 status_cd = f8
            5 status_disp = c40
            5 status_mean = c12
            5 phase_cd = f8
            5 phase_disp = c40
            5 primary_review_prsnl_id = f8
            5 primary_review_username = c20
            5 primary_review_dt_tm = dq8
            5 secondary_review_prsnl_id = f8
            5 secondary_review_username = c20
            5 secondary_review_dt_tm = dq8
            5 comment_text_id = f8
            5 comment_text = vc
            5 troubleshooting_qual[*]
              6 troubleshooting_id = f8
              6 troubleshooting_text_id = f8
              6 active_ind = i2
              6 updt_cnt = i4
              6 beg_effective_dt_tm = dq8
              6 end_effective_dt_tm = dq8
              6 long_text = vc
            5 action_prsnl_id = f8
            5 action_prsnl_username = c20
            5 action_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(test_reply,0)))
  RECORD temp_reply(
    1 group_qual[*]
      2 group_id = f8
      2 group_name = c40
      2 service_resource_cd = f8
      2 require_validation_ind = i2
      2 schedule_cd = f8
      2 discard_ind = i2
      2 group_activity_qual[*]
        3 scheduled_dt_tm = dq8
        3 discard_ind = i2
        3 reagent_qual[*]
          4 group_reagent_lot_id = f8
          4 related_reagent_id = f8
          4 lot_ident = c40
          4 status_cd = f8
          4 parent_entity_cd = f8
          4 manufacturer_cd = f8
          4 group_reagent_activity_id = f8
          4 visual_inspection_cd = f8
          4 interpretation_cd = f8
          4 discard_ind = i2
          4 result_qual[*]
            5 qc_result_id = f8
            5 enhancement_activity_id = f8
            5 enhancement_media_cd = f8
            5 enhancement_manf_cd = f8
            5 enhancement_lot_number = vc
            5 enhancement_status_cd = f8
            5 control_activity_id = f8
            5 control_media_cd = f8
            5 control_manf_cd = f8
            5 control_lot_number = vc
            5 control_status_cd = f8
            5 mnemonic = c25
            5 result_dt_tm = dq8
            5 result_prsnl_id = f8
            5 result_prsnl_username = c20
            5 abnormal_ind = i2
            5 reason_cd = f8
            5 status_cd = f8
            5 phase_cd = f8
            5 primary_review_prsnl_id = f8
            5 primary_review_username = c20
            5 primary_review_dt_tm = dq8
            5 secondary_review_prsnl_id = f8
            5 secondary_review_username = c20
            5 secondary_review_dt_tm = dq8
            5 comment_text_id = f8
            5 comment_text = vc
            5 discard_ind = i2
            5 troubleshooting_qual[*]
              6 troubleshooting_id = f8
              6 troubleshooting_text_id = f8
              6 active_ind = i2
              6 updt_cnt = i4
              6 beg_effective_dt_tm = dq8
              6 end_effective_dt_tm = dq8
              6 long_text = vc
            5 action_prsnl_id = f8
            5 action_prsnl_username = c20
            5 action_dt_tm = dq8
    1 select_qual[*]
      2 text = vc
    1 select2_qual[*]
      2 text = vc
  )
 ENDIF
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE j = i4 WITH protect, noconstant(0)
 DECLARE k = i4 WITH protect, noconstant(0)
 DECLARE l = i4 WITH protect, noconstant(0)
 DECLARE lselectcount = i4 WITH protect, noconstant(0)
 DECLARE lselect2count = i4 WITH protect, noconstant(0)
 DECLARE lgroupcount = i4 WITH protect, noconstant(0)
 DECLARE lgroupactivitycount = i4 WITH protect, noconstant(0)
 DECLARE lreagentcount = i4 WITH protect, noconstant(0)
 DECLARE lresultcount = i4 WITH protect, noconstant(0)
 DECLARE ltroubleshootingcount = i4 WITH protect, noconstant(0)
 DECLARE nresultfound = i2 WITH protect, noconstant(0)
 DECLARE nfirst = i2 WITH protect, noconstant(1)
 DECLARE ndiscardgroup = i2 WITH protect, noconstant(0)
 DECLARE ndiscardgroupactivity = i2 WITH protect, noconstant(0)
 DECLARE ndiscardreagent = i2 WITH protect, noconstant(0)
 DECLARE nstatus = i2 WITH protect, noconstant(0)
 DECLARE nskip = i2 WITH protect, noconstant(0)
 DECLARE dbegindttm = f8 WITH protect, noconstant(0.0)
 DECLARE denddttm = f8 WITH protect, noconstant(0.0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE sblank = vc WITH protect, constant("")
 DECLARE sbegindttm = vc WITH protect, noconstant("")
 DECLARE senddttm = vc WITH protect, noconstant("")
 DECLARE group_name_flag = i4 WITH protect, noconstant(0)
 DECLARE reagent_flag = i4 WITH protect, noconstant(0)
 DECLARE reagent_lot_flag = i4 WITH protect, noconstant(0)
 DECLARE control_material_flag = i4 WITH protect, noconstant(0)
 DECLARE control_lot_flag = i4 WITH protect, noconstant(0)
 DECLARE enhancement_flag = i4 WITH protect, noconstant(0)
 DECLARE enhancement_lot_flag = i4 WITH protect, noconstant(0)
 DECLARE result_flag = i4 WITH protect, noconstant(0)
 DECLARE service_resource_flag = i4 WITH protect, noconstant(0)
 DECLARE abnormal_flag = i4 WITH protect, noconstant(0)
 DECLARE primary_signoff_flag = i4 WITH protect, noconstant(0)
 DECLARE secondary_signoff_flag = i4 WITH protect, noconstant(0)
 DECLARE sgroupids = vc WITH protect, noconstant("0")
 DECLARE sreagentcds = vc WITH protect, noconstant("0")
 DECLARE sreagentlotstatuscds = vc WITH protect, noconstant("0")
 DECLARE scontrolmaterialcds = vc WITH protect, noconstant("0")
 DECLARE scontrollotstatuscds = vc WITH protect, noconstant("0")
 DECLARE senhancementmediacds = vc WITH protect, noconstant("0")
 DECLARE senhancementmedialotstatuscds = vc WITH protect, noconstant("0")
 DECLARE sresultstatuscds = vc WITH protect, noconstant("0")
 DECLARE sserviceresourcecds = vc WITH protect, noconstant("0")
 SET reply->status_data.status = "F"
 FOR (x = 1 TO size(request->filter_qual,5))
   CASE (request->filter_qual[x].filter_mean)
    OF "B_GRP_NAME":
     SET nskip = 0
     FOR (i = 1 TO size(request->filter_qual[x].filter_value,5))
       IF ((request->filter_qual[x].filter_value[i].value_nbr=0))
        SET nskip = 1
       ENDIF
     ENDFOR
     IF (size(request->filter_qual[x].filter_value,5) > 0
      AND nskip=0)
      SET group_name_flag = x
     ENDIF
    OF "B_REAGENT":
     SET nskip = 0
     FOR (i = 1 TO size(request->filter_qual[x].filter_value,5))
       IF ((request->filter_qual[x].filter_value[i].value_nbr=0))
        SET nskip = 1
       ENDIF
     ENDFOR
     IF (size(request->filter_qual[x].filter_value,5) > 0
      AND nskip=0)
      SET reagent_flag = x
     ENDIF
    OF "B_REAGNT_LOT":
     IF (size(request->filter_qual[x].filter_value,5) > 0)
      SET reagent_lot_flag = x
     ENDIF
    OF "B_CNTRL_MTRL":
     SET nskip = 0
     FOR (i = 1 TO size(request->filter_qual[x].filter_value,5))
       IF ((request->filter_qual[x].filter_value[i].value_nbr=0))
        SET nskip = 1
       ENDIF
     ENDFOR
     IF (size(request->filter_qual[x].filter_value,5) > 0
      AND nskip=0)
      SET control_material_flag = x
     ENDIF
    OF "B_CNTRL_LOT":
     IF (size(request->filter_qual[x].filter_value,5) > 0)
      SET control_lot_flag = x
     ENDIF
    OF "B_ENHCMT_MED":
     SET nskip = 0
     FOR (i = 1 TO size(request->filter_qual[x].filter_value,5))
       IF ((request->filter_qual[x].filter_value[i].value_nbr=0))
        SET nskip = 1
       ENDIF
     ENDFOR
     IF (size(request->filter_qual[x].filter_value,5) > 0
      AND nskip=0)
      SET enhancement_flag = x
     ENDIF
    OF "B_ENHCMT_LOT":
     IF (size(request->filter_qual[x].filter_value,5) > 0)
      SET enhancement_lot_flag = x
     ENDIF
    OF "B_RSLT_STAT":
     IF (size(request->filter_qual[x].filter_value,5) > 0)
      SET result_flag = x
     ENDIF
    OF "B_SERV_RES":
     SET nskip = 0
     FOR (i = 1 TO size(request->filter_qual[x].filter_value,5))
       IF ((request->filter_qual[x].filter_value[i].value_nbr=0))
        SET nskip = 1
       ENDIF
     ENDFOR
     IF (size(request->filter_qual[x].filter_value,5) > 0
      AND nskip=0)
      SET service_resource_flag = x
     ENDIF
    OF "B_ABN_IND":
     IF (size(request->filter_qual[x].filter_value,5) > 0)
      IF ((request->filter_qual[x].filter_value[1].value_ind=1))
       SET abnormal_flag = x
      ENDIF
     ENDIF
    OF "B_SIGNOFF":
     IF (size(request->filter_qual[x].filter_value,5) > 0)
      IF ((request->filter_qual[x].filter_value[1].value_ind=1))
       SET primary_signoff_flag = x
      ENDIF
     ENDIF
    OF "B_SIGNOFF2":
     IF (size(request->filter_qual[x].filter_value,5) > 0)
      IF ((request->filter_qual[x].filter_value[1].value_ind=1))
       SET secondary_signoff_flag = x
      ENDIF
     ENDIF
   ENDCASE
 ENDFOR
 SET nskip = 0
 IF (group_name_flag > 0)
  FOR (i = 1 TO size(request->filter_qual[group_name_flag].filter_value,5))
    IF (i=1)
     SET sgroupids = build(request->filter_qual[group_name_flag].filter_value[i].value_nbr)
    ELSE
     SET sgroupids = build(sgroupids,",",request->filter_qual[group_name_flag].filter_value[i].
      value_nbr)
    ENDIF
  ENDFOR
 ENDIF
 IF (reagent_flag > 0)
  FOR (i = 1 TO size(request->filter_qual[reagent_flag].filter_value,5))
    IF (i=1)
     SET sreagentcds = build(request->filter_qual[reagent_flag].filter_value[i].value_nbr)
    ELSE
     SET sreagentcds = build(sreagentcds,",",request->filter_qual[reagent_flag].filter_value[i].
      value_nbr)
    ENDIF
  ENDFOR
 ENDIF
 IF (reagent_lot_flag > 0)
  FOR (i = 1 TO size(request->filter_qual[reagent_lot_flag].filter_value,5))
    IF (i=1)
     SET sreagentlotstatuscds = build(request->filter_qual[reagent_lot_flag].filter_value[i].
      value_nbr)
    ELSE
     SET sreagentlotstatuscds = build(sreagentlotstatuscds,",",request->filter_qual[reagent_lot_flag]
      .filter_value[i].value_nbr)
    ENDIF
  ENDFOR
 ENDIF
 IF (control_material_flag > 0)
  FOR (i = 1 TO size(request->filter_qual[control_material_flag].filter_value,5))
    IF (i=1)
     SET scontrolmaterialcds = build(request->filter_qual[control_material_flag].filter_value[i].
      value_nbr)
    ELSE
     SET scontrolmaterialcds = build(scontrolmaterialcds,",",request->filter_qual[
      control_material_flag].filter_value[i].value_nbr)
    ENDIF
  ENDFOR
 ENDIF
 IF (control_lot_flag > 0)
  FOR (i = 1 TO size(request->filter_qual[control_lot_flag].filter_value,5))
    IF (i=1)
     SET scontrollotstatuscds = build(request->filter_qual[control_lot_flag].filter_value[i].
      value_nbr)
    ELSE
     SET scontrollotstatuscds = build(scontrollotstatuscds,",",request->filter_qual[control_lot_flag]
      .filter_value[i].value_nbr)
    ENDIF
  ENDFOR
 ENDIF
 IF (enhancement_flag > 0)
  FOR (i = 1 TO size(request->filter_qual[enhancement_flag].filter_value,5))
    IF (i=1)
     SET senhancementmediacds = build(request->filter_qual[enhancement_flag].filter_value[i].
      value_nbr)
    ELSE
     SET senhancementmediacds = build(senhancementmediacds,",",request->filter_qual[enhancement_flag]
      .filter_value[i].value_nbr)
    ENDIF
  ENDFOR
 ENDIF
 IF (enhancement_lot_flag > 0)
  FOR (i = 1 TO size(request->filter_qual[enhancement_lot_flag].filter_value,5))
    IF (i=1)
     SET senhancementmedialotstatuscds = build(request->filter_qual[enhancement_lot_flag].
      filter_value[i].value_nbr)
    ELSE
     SET senhancementmedialotstatuscds = build(senhancementmedialotstatuscds,",",request->
      filter_qual[enhancement_lot_flag].filter_value[i].value_nbr)
    ENDIF
  ENDFOR
 ENDIF
 IF (result_flag > 0)
  FOR (i = 1 TO size(request->filter_qual[result_flag].filter_value,5))
    IF (i=1)
     SET sresultstatuscds = build(request->filter_qual[result_flag].filter_value[i].value_nbr)
    ELSE
     SET sresultstatuscds = build(sresultstatuscds,",",request->filter_qual[result_flag].
      filter_value[i].value_nbr)
    ENDIF
  ENDFOR
 ENDIF
 IF (service_resource_flag > 0)
  FOR (i = 1 TO size(request->filter_qual[service_resource_flag].filter_value,5))
    IF (i=1)
     SET sserviceresourcecds = build(request->filter_qual[service_resource_flag].filter_value[i].
      value_nbr)
    ELSE
     SET sserviceresourcecds = build(sserviceresourcecds,",",request->filter_qual[
      service_resource_flag].filter_value[i].value_nbr)
    ENDIF
  ENDFOR
 ENDIF
 CALL addselecttext("SELECT INTO 'nl:'")
 CALL addselecttext("     *")
 CALL addselecttext("FROM bb_qc_group g")
 CALL addselecttext("    , bb_qc_group_activity ga")
 CALL addselecttext("    , bb_qc_grp_reagent_activity gra")
 CALL addselecttext("    , bb_qc_grp_reagent_lot grl")
 CALL addselecttext("    , pcs_lot_information pli")
 CALL addselecttext("    , pcs_lot_definition pld")
 CALL addselecttext("    , bb_qc_result r")
 CALL addselecttext("    , bb_qc_result_troubleshooting_r rtr")
 CALL addselecttext("    , bb_qc_troubleshooting t")
 CALL addselecttext("    , long_text_reference ltr")
 CALL addselecttext("    , nomenclature n")
 CALL addselecttext("    , prsnl p1")
 CALL addselecttext("    , prsnl p2")
 CALL addselecttext("    , prsnl p3")
 CALL addselecttext("    , prsnl p4")
 CALL addselecttext("    , long_text lt")
 CALL addselecttext("    , bb_qc_grp_reagent_activity gra2")
 CALL addselecttext("    , bb_qc_grp_reagent_lot grl2")
 CALL addselecttext("    , pcs_lot_information pli2")
 CALL addselecttext("    , pcs_lot_definition pld2")
 CALL addselecttext("    , bb_qc_grp_reagent_activity gra3")
 CALL addselecttext("    , bb_qc_grp_reagent_lot grl3")
 CALL addselecttext("    , pcs_lot_information pli3")
 CALL addselecttext("    , pcs_lot_definition pld3")
 SET dbegindttm = cnvtdatetime(request->begin_dt_tm)
 SET denddttm = cnvtdatetime(request->end_dt_tm)
 CALL addselecttext("plan g where g.group_id > 0.0")
 IF (group_name_flag > 0)
  CALL addselecttext(build("            and g.group_id in (",sgroupids,")"))
 ENDIF
 IF (service_resource_flag > 0)
  CALL addselecttext(build("            and g.service_resource_cd in (",sserviceresourcecds,")"))
 ENDIF
 CALL addselecttext("            and g.active_ind = 1")
 CALL addselecttext("join ga where ga.group_id = g.group_id")
 IF ((request->number_of_results=0))
  SET sbegindttm = format(request->begin_dt_tm,";;Q")
  SET senddttm = format(request->end_dt_tm,";;Q")
  CALL addselecttext(concat("and ga.scheduled_dt_tm >=",concat("cnvtdatetime('",sbegindttm,"')")))
  CALL addselecttext(concat("            and ga.scheduled_dt_tm <=",concat("cnvtdatetime('",senddttm,
     "')")))
 ENDIF
 CALL addselecttext("join gra where gra.group_activity_id = ga.group_activity_id")
 CALL addselecttext("join grl where grl.prev_group_reagent_lot_id = gra.group_reagent_lot_id")
 CALL addselecttext("           and grl.beg_effective_dt_tm <= gra.activity_dt_tm")
 CALL addselecttext("           and grl.end_effective_dt_tm >  gra.activity_dt_tm")
 CALL addselecttext("           and grl.active_ind = 1")
 CALL addselecttext("join pli where pli.lot_information_id = grl.lot_information_id")
 CALL addselecttext("join pld where pld.lot_definition_id = pli.lot_definition_id")
 CALL addselecttext("join r where r.group_reagent_activity_id = gra.group_reagent_activity_id")
 IF (result_flag > 0)
  CALL addselecttext(build("         and r.status_cd in (",sresultstatuscds,")"))
 ENDIF
 IF (abnormal_flag > 0)
  CALL addselecttext(build("         and r.abnormal_ind = 1"))
 ENDIF
 IF (((primary_signoff_flag > 0) OR (secondary_signoff_flag > 0)) )
  IF (primary_signoff_flag > 0)
   CALL addselecttext("         and r.primary_review_prsnl_id = 0")
  ELSE
   CALL addselecttext("         and r.secondary_review_prsnl_id = 0")
   CALL addselecttext("         and r.primary_review_prsnl_id > 0")
  ENDIF
 ENDIF
 CALL addselecttext("join rtr where rtr.qc_result_id = outerjoin(r.qc_result_id)")
 CALL addselecttext("join t where t.troubleshooting_id = outerjoin(rtr.troubleshooting_id)")
 CALL addselecttext("join ltr where ltr.long_text_id = outerjoin(t.troubleshooting_text_id)")
 CALL addselecttext(
  "join gra2 where gra2.group_reagent_activity_id = outerjoin(r.enhancement_activity_id)")
 CALL addselecttext(
  "join grl2 where grl2.prev_group_reagent_lot_id = outerjoin(gra2.group_reagent_lot_id)")
 CALL addselecttext("            and grl2.beg_effective_dt_tm <= outerjoin(gra2.activity_dt_tm)")
 CALL addselecttext("            and grl2.end_effective_dt_tm >  outerjoin(gra2.activity_dt_tm)")
 CALL addselecttext("join pli2 where pli2.lot_information_id = outerjoin(grl2.lot_information_id)")
 CALL addselecttext("join pld2 where pld2.lot_definition_id = outerjoin(pli2.lot_definition_id)")
 CALL addselecttext("join gra3 where gra3.group_reagent_activity_id = r.control_activity_id")
 CALL addselecttext("join grl3 where grl3.prev_group_reagent_lot_id = gra3.group_reagent_lot_id")
 CALL addselecttext("            and grl3.beg_effective_dt_tm <= gra3.activity_dt_tm")
 CALL addselecttext("            and grl3.end_effective_dt_tm > gra3.activity_dt_tm")
 CALL addselecttext("join pli3 where pli3.lot_information_id = grl3.lot_information_id")
 CALL addselecttext("join pld3 where pld3.lot_definition_id = pli3.lot_definition_id")
 CALL addselecttext("join p1 where p1.person_id = outerjoin(r.result_prsnl_id)")
 CALL addselecttext("join p2 where p2.person_id = outerjoin(r.primary_review_prsnl_id)")
 CALL addselecttext("join p3 where p3.person_id = outerjoin(r.secondary_review_prsnl_id)")
 CALL addselecttext("join p4 where p4.person_id = outerjoin(r.action_prsnl_id)")
 CALL addselecttext("join lt where lt.long_text_id = outerjoin(r.comment_text_id)")
 CALL addselecttext("join n where n.nomenclature_id = r.nomenclature_id")
 CALL addselecttext("order by g.group_id")
 CALL addselecttext("        , ga.group_activity_id")
 CALL addselecttext("        , gra.group_reagent_activity_id")
 CALL addselecttext("        , r.qc_result_id")
 CALL addselecttext("        , rtr.result_troubleshooting_id")
 CALL addselecttext("HEAD REPORT")
 CALL addselecttext("  lGroupCount = 0")
 CALL addselecttext("HEAD g.group_id")
 CALL addselecttext("  lGroupCount = lGroupCount + 1")
 CALL addselecttext("  if (lGroupCount >= size(temp_reply->group_qual, 5))")
 CALL addselecttext("    nStatus = alterlist(temp_reply->group_qual, lGroupCount + 9)")
 CALL addselecttext("  endif")
 CALL addselecttext("  lGroupActivityCount = 0")
 CALL addselecttext("  temp_reply->group_qual[lGroupCount].group_id = g.group_id")
 CALL addselecttext("  temp_reply->group_qual[lGroupCount].group_name = g.group_name")
 CALL addselecttext(
  "  temp_reply->group_qual[lGroupCount].service_resource_cd = g.service_resource_cd")
 CALL addselecttext(
  "  temp_reply->group_qual[lGroupCount].require_validation_ind = g.require_validation_ind")
 CALL addselecttext("  temp_reply->group_qual[lGroupCount].schedule_cd = g.schedule_cd")
 CALL addselecttext("  HEAD ga.group_activity_id")
 CALL addselecttext("    lGroupActivityCount = lGroupActivityCount + 1")
 CALL addselecttext(
  "    if (lGroupActivityCount >= size(temp_reply->group_qual[lGroupCount]->group_activity_qual, 5))"
  )
 CALL addselecttext(
  "      nStatus = alterlist(temp_reply->group_qual[lGroupCount]->group_activity_qual, lGroupActivityCount + 9)"
  )
 CALL addselecttext("    endif")
 CALL addselecttext("    lReagentCount = 0")
 CALL addselecttext("    temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "      group_activity_qual[lGroupActivityCount].scheduled_dt_tm = ga.scheduled_dt_tm")
 CALL addselecttext("    HEAD gra.group_reagent_activity_id")
 CALL addselecttext("      lReagentCount = lReagentCount + 1")
 CALL addselecttext("      if (lReagentCount >= size(temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("        group_activity_qual[lGroupActivityCount]->reagent_qual, 5))")
 CALL addselecttext("        nStatus = alterlist(temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "          group_activity_qual[lGroupActivityCount]->reagent_qual, lReagentCount + 9)")
 CALL addselecttext("      endif")
 CALL addselecttext("      lResultCount = 0")
 CALL addselecttext("      temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("        group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext("        .group_reagent_lot_id = grl.group_reagent_lot_id")
 CALL addselecttext("      temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("        group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext("        .related_reagent_id = grl.related_reagent_id")
 CALL addselecttext("      temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("        group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext("        .lot_ident = pli.lot_ident")
 CALL addselecttext("      temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("        group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext("        .status_cd = pli.status_cd")
 CALL addselecttext("      temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("        group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext("        .parent_entity_cd = pld.parent_entity_id")
 CALL addselecttext("      temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("        group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext("        .manufacturer_cd = pld.manufacturer_cd")
 CALL addselecttext("      temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("        group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext("        .group_reagent_activity_id = gra.group_reagent_activity_id")
 CALL addselecttext("      temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("        group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext("        .visual_inspection_cd = gra.visual_inspection_cd")
 CALL addselecttext("      temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("        group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext("        .interpretation_cd = gra.interpretation_cd")
 CALL addselecttext("      HEAD r.qc_result_id")
 CALL addselecttext("        lResultCount = lResultCount + 1")
 CALL addselecttext("        nResultFound = 1")
 CALL addselecttext("        if (lResultCount >= size(temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]->result_qual, 5))"
  )
 CALL addselecttext("          nStatus = alterlist(temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "            group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]->")
 CALL addselecttext("              result_qual, lResultCount + 9)")
 CALL addselecttext("        endif")
 CALL addselecttext("        lTroubleshootingCount = 0")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].qc_result_id = r.qc_result_id")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext(
  "          ->result_qual[lResultCount].enhancement_activity_id = r.enhancement_activity_id")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext(
  "          ->result_qual[lResultCount].control_activity_id = r.control_activity_id")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].mnemonic = n.source_string")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].result_dt_tm = r.result_dt_tm")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].result_prsnl_id = r.result_prsnl_id")
 CALL addselecttext("        if (r.result_prsnl_id > 0)")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].result_prsnl_username = p1.username")
 CALL addselecttext("        else")
 CALL addselecttext("          temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "            group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext(build("            ->result_qual[lResultCount].result_prsnl_username = ' '"))
 CALL addselecttext("        endif")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].abnormal_ind = r.abnormal_ind")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].reason_cd = r.reason_cd")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].status_cd = r.status_cd")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].phase_cd = r.phase_cd")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext(
  "          ->result_qual[lResultCount].primary_review_prsnl_id = r.primary_review_prsnl_id")
 CALL addselecttext("        if (r.primary_review_prsnl_id > 0)")
 CALL addselecttext("          temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "            group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext("            ->result_qual[lResultCount].primary_review_username = p2.username")
 CALL addselecttext("        else")
 CALL addselecttext("          temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "            group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext(build("            ->result_qual[lResultCount].primary_review_username = ' '"))
 CALL addselecttext("        endif")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext(
  "          ->result_qual[lResultCount].primary_review_dt_tm = r.primary_review_dt_tm")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext(
  "          ->result_qual[lResultCount].secondary_review_prsnl_id = r.secondary_review_prsnl_id")
 CALL addselecttext("        if (r.secondary_review_prsnl_id > 0)")
 CALL addselecttext("          temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "            group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext("            ->result_qual[lResultCount].secondary_review_username = p3.username"
  )
 CALL addselecttext("        else")
 CALL addselecttext("          temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "            group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext(build("            ->result_qual[lResultCount].secondary_review_username = ' '"))
 CALL addselecttext("        endif")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext(
  "          ->result_qual[lResultCount].secondary_review_dt_tm = r.secondary_review_dt_tm")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].action_prsnl_id = r.action_prsnl_id")
 CALL addselecttext("        if (r.action_prsnl_id > 0)")
 CALL addselecttext("          temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "            group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext("            ->result_qual[lResultCount].action_prsnl_username = p4.username")
 CALL addselecttext("        else")
 CALL addselecttext("          temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "            group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext(build("            ->result_qual[lResultCount].action_prsnl_username = ' '"))
 CALL addselecttext("        endif")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].action_dt_tm = r.action_dt_tm")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].comment_text_id = r.comment_text_id")
 CALL addselecttext("        if (r.comment_text_id > 0)")
 CALL addselecttext("          temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "            group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext("            ->result_qual[lResultCount].comment_text = lt.long_text")
 CALL addselecttext("        else")
 CALL addselecttext("          temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "            group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext(build("            ->result_qual[lResultCount].comment_text = ' '"))
 CALL addselecttext("        endif")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext(
  "          ->result_qual[lResultCount].enhancement_media_cd = pld2.parent_entity_id")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext(
  "          ->result_qual[lResultCount].enhancement_manf_cd = pld2.manufacturer_cd")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].enhancement_lot_number = pli2.lot_ident")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].enhancement_status_cd = pli2.status_cd")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].control_media_cd = pld3.parent_entity_id")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].control_manf_cd = pld3.manufacturer_cd")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].control_lot_number = pli3.lot_ident")
 CALL addselecttext("        temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("          group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]"
  )
 CALL addselecttext("          ->result_qual[lResultCount].control_status_cd = pli3.status_cd")
 CALL addselecttext("        HEAD rtr.result_troubleshooting_id")
 CALL addselecttext("          if (rtr.result_troubleshooting_id >0)")
 CALL addselecttext("            lTroubleshootingCount = lTroubleshootingCount + 1")
 CALL addselecttext(
  "            if (lTroubleshootingCount >= size(temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "              group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]->")
 CALL addselecttext("              result_qual[lResultCount]->troubleshooting_qual, 5))")
 CALL addselecttext("              nStatus = alterlist(temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "                group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]->")
 CALL addselecttext(
  "                 result_qual[lResultCount]->troubleshooting_qual, lTroubleshootingCount + 9)")
 CALL addselecttext("            endif")
 CALL addselecttext("            temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "              group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext(
  "              ->result_qual[lResultCount]->troubleshooting_qual[lTroubleshootingCount].troubleshooting_id"
  )
 CALL addselecttext("              = t.troubleshooting_id")
 CALL addselecttext("            temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "              group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext(
  "              ->result_qual[lResultCount]->troubleshooting_qual[lTroubleshootingCount]")
 CALL addselecttext("              .troubleshooting_text_id")
 CALL addselecttext("              = t.troubleshooting_text_id")
 CALL addselecttext("            temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "              group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext(
  "              ->result_qual[lResultCount]->troubleshooting_qual[lTroubleshootingCount].active_ind"
  )
 CALL addselecttext("              = t.active_ind")
 CALL addselecttext("            temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "              group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext(
  "              ->result_qual[lResultCount]->troubleshooting_qual[lTroubleshootingCount].updt_cnt")
 CALL addselecttext("              = t.updt_cnt")
 CALL addselecttext("            temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "              group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext(
  "              ->result_qual[lResultCount]->troubleshooting_qual[lTroubleshootingCount].beg_effective_dt_tm"
  )
 CALL addselecttext("              = t.beg_effective_dt_tm")
 CALL addselecttext("            temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "              group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext(
  "              ->result_qual[lResultCount]->troubleshooting_qual[lTroubleshootingCount].end_effective_dt_tm"
  )
 CALL addselecttext("              = t.end_effective_dt_tm")
 CALL addselecttext("            temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "              group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext(
  "              ->result_qual[lResultCount]->troubleshooting_qual[lTroubleshootingCount].long_text")
 CALL addselecttext("              = ltr.long_text")
 CALL addselecttext("           endif")
 CALL addselecttext("        FOOT rtr.result_troubleshooting_id")
 CALL addselecttext("          nStatus = alterlist(temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "              group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext(
  "              ->result_qual[lResultCount]->troubleshooting_qual, lTroubleshootingCount)")
 CALL addselecttext("      FOOT r.qc_result_id")
 CALL addselecttext("        nStatus = alterlist(temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "            group_activity_qual[lGroupActivityCount]->reagent_qual[lReagentCount]")
 CALL addselecttext("            ->result_qual, lResultCount)")
 CALL addselecttext("    FOOT gra.group_reagent_activity_id")
 CALL addselecttext("      nStatus = alterlist(temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext(
  "          group_activity_qual[lGroupActivityCount]->reagent_qual, lReagentCount)")
 CALL addselecttext("  FOOT ga.group_activity_id")
 CALL addselecttext("    nStatus = alterlist(temp_reply->group_qual[lGroupCount]->")
 CALL addselecttext("        group_activity_qual, lGroupActivityCount)")
 CALL addselecttext("FOOT REPORT")
 CALL addselecttext("  nStatus = alterlist(temp_reply->group_qual, lGroupCount)")
 CALL addselecttext("WITH nocounter GO")
 CALL performselect(null)
 IF (error(serrormsg,0) != 0)
  GO TO exit_script
 ENDIF
 IF (nresultfound=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 CALL addselect2text("select into 'nl:'")
 CALL addselect2text("     *")
 CALL addselect2text("from (dummyt d1 with seq = value(size(temp_reply->group_qual, 5)))")
 CALL addselect2text("     , (dummyt d2 with seq = 1)")
 CALL addselect2text("     , (dummyt d3 with seq = 1)")
 CALL addselect2text("     , (dummyt d4 with seq = 1)")
 CALL addselect2text("     , bb_qc_result r")
 CALL addselect2text("plan d1")
 CALL addselect2text(
  "  where maxrec(d2, size(temp_reply->group_qual[d1.seq]->group_activity_qual, 5))")
 CALL addselect2text("join d2")
 CALL addselect2text(
  "  where maxrec(d3, size(temp_reply->group_qual[d1.seq]->group_activity_qual[d2.seq]->reagent_qual, 5))"
  )
 CALL addselect2text("join d3")
 CALL addselect2text(
  "  where maxrec(d4, size(temp_reply->group_qual[d1.seq]->group_activity_qual[d2.seq]->reagent_qual[d3.seq]->"
  )
 CALL addselect2text("  result_qual, 5))")
 CALL addselect2text("join d4")
 CALL addselect2text("join r")
 CALL addselect2text("  where r.qc_result_id = temp_reply->group_qual[d1.seq]->")
 CALL addselect2text(
  "        group_activity_qual[d2.seq]->reagent_qual[d3.seq]->result_qual[d4.seq].qc_result_id")
 CALL addselect2text("order by r.result_dt_tm desc")
 CALL addselect2text("head report")
 CALL addselect2text("  nCount = 0")
 CALL addselect2text("detail")
 CALL addselect2text("  nSkip = 0")
 CALL addselect2text("  if ((reagent_flag > 0) and (nSkip = 0))")
 CALL addselect2text(
  "    if (not(temp_reply->group_qual[d1.seq]->group_activity_qual[d2.seq]->reagent_qual[d3.seq].")
 CALL addselect2text(build("      parent_entity_cd in (",sreagentcds,")))"))
 CALL addselect2text(
  "      temp_reply->group_qual[d1.seq]->group_activity_qual[d2.seq]->reagent_qual[d3.seq]->")
 CALL addselect2text("        result_qual[d4.seq].discard_ind = 1")
 CALL addselect2text("      nSkip = 1")
 CALL addselect2text("    endif")
 CALL addselect2text("  endif")
 CALL addselect2text("  if (reagent_lot_flag > 0 and nSkip = 0)")
 CALL addselect2text(
  "    if (not(temp_reply->group_qual[d1.seq]->group_activity_qual[d2.seq]->reagent_qual[d3.seq].")
 CALL addselect2text(build("      status_cd in (",sreagentlotstatuscds,")))"))
 CALL addselect2text(
  "      temp_reply->group_qual[d1.seq]->group_activity_qual[d2.seq]->reagent_qual[d3.seq]->")
 CALL addselect2text("        result_qual[d4.seq].discard_ind = 1")
 CALL addselect2text("      nSkip = 1")
 CALL addselect2text("    endif")
 CALL addselect2text("  endif")
 CALL addselect2text("  if (enhancement_flag > 0 and nSkip = 0)")
 CALL addselect2text(
  "    if (not(temp_reply->group_qual[d1.seq]->group_activity_qual[d2.seq]->reagent_qual[d3.seq]->result_qual"
  )
 CALL addselect2text(build("      [d4.seq].enhancement_media_cd in (",senhancementmediacds,")))"))
 CALL addselect2text(
  "      temp_reply->group_qual[d1.seq]->group_activity_qual[d2.seq]->reagent_qual[d3.seq]->")
 CALL addselect2text("        result_qual[d4.seq].discard_ind = 1")
 CALL addselect2text("      nSkip = 1")
 CALL addselect2text("    endif")
 CALL addselect2text("  endif")
 CALL addselect2text("  if (enhancement_lot_flag > 0 and nSkip = 0)")
 CALL addselect2text(
  "    if (not(temp_reply->group_qual[d1.seq]->group_activity_qual[d2.seq]->reagent_qual[d3.seq]->result_qual"
  )
 CALL addselect2text(build("      [d4.seq].enhancement_status_cd in (",senhancementmedialotstatuscds,
   ")))"))
 CALL addselect2text(
  "      temp_reply->group_qual[d1.seq]->group_activity_qual[d2.seq]->reagent_qual[d3.seq]->")
 CALL addselect2text("        result_qual[d4.seq].discard_ind = 1")
 CALL addselect2text("      nSkip = 1")
 CALL addselect2text("    endif")
 CALL addselect2text("  endif")
 CALL addselect2text("  if (control_material_flag > 0 and nSkip = 0)")
 CALL addselect2text(
  "    if (not(temp_reply->group_qual[d1.seq]->group_activity_qual[d2.seq]->reagent_qual[d3.seq]->result_qual"
  )
 CALL addselect2text(build("      [d4.seq].control_media_cd in (",scontrolmaterialcds,")))"))
 CALL addselect2text(
  "      temp_reply->group_qual[d1.seq]->group_activity_qual[d2.seq]->reagent_qual[d3.seq]->")
 CALL addselect2text("        result_qual[d4.seq].discard_ind = 1")
 CALL addselect2text("      nSkip = 1")
 CALL addselect2text("    endif")
 CALL addselect2text("  endif")
 CALL addselect2text("  if (control_lot_flag > 0 and nSkip = 0)")
 CALL addselect2text(
  "    if (not(temp_reply->group_qual[d1.seq]->group_activity_qual[d2.seq]->reagent_qual[d3.seq]->result_qual"
  )
 CALL addselect2text(build("      [d4.seq].control_status_cd in (",scontrollotstatuscds,")))"))
 CALL addselect2text(
  "      temp_reply->group_qual[d1.seq]->group_activity_qual[d2.seq]->reagent_qual[d3.seq]->")
 CALL addselect2text("        result_qual[d4.seq].discard_ind = 1")
 CALL addselect2text("      nSkip = 1")
 CALL addselect2text("    endif")
 CALL addselect2text("  endif")
 CALL addselect2text("  if (request->number_of_results > 0 and nSkip = 0)")
 CALL addselect2text("      nCount = nCount + 1")
 CALL addselect2text("      if (nCount > request->number_of_results)")
 CALL addselect2text(
  "        temp_reply->group_qual[d1.seq]->group_activity_qual[d2.seq]->reagent_qual[d3.seq]->")
 CALL addselect2text("          result_qual[d4.seq].discard_ind = 1")
 CALL addselect2text("      else")
 CALL addselect2text(
  "        temp_reply->group_qual[d1.seq]->group_activity_qual[d2.seq]->reagent_qual[d3.seq]->")
 CALL addselect2text("          result_qual[d4.seq].discard_ind = 0")
 CALL addselect2text("      endif")
 CALL addselect2text("  endif")
 CALL addselect2text("foot report")
 CALL addselect2text("  row + 0")
 CALL addselect2text("with nocounter go")
 CALL performselect2(null)
 IF (error(serrormsg,0) != 0)
  GO TO exit_script
 ENDIF
 CALL echorecord(temp_reply)
 FOR (i = 1 TO size(temp_reply->group_qual,5))
   SET ndiscardgroup = 1
   FOR (j = 1 TO size(temp_reply->group_qual[i].group_activity_qual,5))
     SET ndiscardgroupactivity = 1
     FOR (k = 1 TO size(temp_reply->group_qual[i].group_activity_qual[j].reagent_qual,5))
       SET ndiscardreagent = 1
       FOR (l = 1 TO size(temp_reply->group_qual[i].group_activity_qual[j].reagent_qual[k].
        result_qual,5))
         IF ((temp_reply->group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].
         discard_ind=0))
          SET ndiscardreagent = 0
         ENDIF
       ENDFOR
       IF (ndiscardreagent=1)
        SET temp_reply->group_qual[i].group_activity_qual[j].reagent_qual[k].discard_ind = 1
       ELSE
        SET ndiscardgroupactivity = 0
       ENDIF
     ENDFOR
     IF (ndiscardgroupactivity=1)
      SET temp_reply->group_qual[i].group_activity_qual[j].discard_ind = 1
     ELSE
      SET ndiscardgroup = 0
     ENDIF
   ENDFOR
   IF (ndiscardgroup=1)
    SET temp_reply->group_qual[i].discard_ind = 1
   ENDIF
 ENDFOR
 SET nresultfound = 0
 SET lgroupcount = 0
 FOR (i = 1 TO size(temp_reply->group_qual,5))
   IF ((temp_reply->group_qual[i].discard_ind=0))
    SET lgroupcount = (lgroupcount+ 1)
    IF (lgroupcount >= size(reply->group_qual,5))
     SET nstatus = alterlist(reply->group_qual,(lgroupcount+ 9))
    ENDIF
    SET reply->group_qual[lgroupcount].group_id = temp_reply->group_qual[i].group_id
    SET reply->group_qual[lgroupcount].group_name = temp_reply->group_qual[i].group_name
    SET reply->group_qual[lgroupcount].service_resource_cd = temp_reply->group_qual[i].
    service_resource_cd
    SET reply->group_qual[lgroupcount].require_validation_ind = temp_reply->group_qual[i].
    require_validation_ind
    SET reply->group_qual[lgroupcount].schedule_cd = temp_reply->group_qual[i].schedule_cd
    SET lgroupactivitycount = 0
    FOR (j = 1 TO size(temp_reply->group_qual[i].group_activity_qual,5))
      IF ((temp_reply->group_qual[i].group_activity_qual[j].discard_ind=0))
       SET lgroupactivitycount = (lgroupactivitycount+ 1)
       IF (lgroupactivitycount >= size(reply->group_qual[lgroupcount].group_activity_qual,5))
        SET nstatus = alterlist(reply->group_qual[lgroupcount].group_activity_qual,(
         lgroupactivitycount+ 9))
       ENDIF
       SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].scheduled_dt_tm =
       temp_reply->group_qual[i].group_activity_qual[j].scheduled_dt_tm
       SET lreagentcount = 0
       FOR (k = 1 TO size(temp_reply->group_qual[i].group_activity_qual[j].reagent_qual,5))
         IF ((temp_reply->group_qual[i].group_activity_qual[j].reagent_qual[k].discard_ind=0))
          SET lreagentcount = (lreagentcount+ 1)
          IF (lreagentcount >= size(reply->group_qual[lgroupcount].group_activity_qual[
           lgroupactivitycount].reagent_qual,5))
           SET nstatus = alterlist(reply->group_qual[lgroupcount].group_activity_qual[
            lgroupactivitycount].reagent_qual,(lreagentcount+ 9))
          ENDIF
          SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].reagent_qual[
          lreagentcount].group_reagent_lot_id = temp_reply->group_qual[i].group_activity_qual[j].
          reagent_qual[k].group_reagent_lot_id
          SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].reagent_qual[
          lreagentcount].related_reagent_id = temp_reply->group_qual[i].group_activity_qual[j].
          reagent_qual[k].related_reagent_id
          SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].reagent_qual[
          lreagentcount].lot_ident = temp_reply->group_qual[i].group_activity_qual[j].reagent_qual[k]
          .lot_ident
          SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].reagent_qual[
          lreagentcount].status_cd = temp_reply->group_qual[i].group_activity_qual[j].reagent_qual[k]
          .status_cd
          SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].reagent_qual[
          lreagentcount].parent_entity_cd = temp_reply->group_qual[i].group_activity_qual[j].
          reagent_qual[k].parent_entity_cd
          SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].reagent_qual[
          lreagentcount].manufacturer_cd = temp_reply->group_qual[i].group_activity_qual[j].
          reagent_qual[k].manufacturer_cd
          SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].reagent_qual[
          lreagentcount].group_reagent_activity_id = temp_reply->group_qual[i].group_activity_qual[j]
          .reagent_qual[k].group_reagent_activity_id
          SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].reagent_qual[
          lreagentcount].visual_inspection_cd = temp_reply->group_qual[i].group_activity_qual[j].
          reagent_qual[k].visual_inspection_cd
          SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].reagent_qual[
          lreagentcount].interpretation_cd = temp_reply->group_qual[i].group_activity_qual[j].
          reagent_qual[k].interpretation_cd
          SET lresultcount = 0
          FOR (l = 1 TO size(temp_reply->group_qual[i].group_activity_qual[j].reagent_qual[k].
           result_qual,5))
            IF ((temp_reply->group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].
            discard_ind=0))
             SET lresultcount = (lresultcount+ 1)
             IF (lresultcount >= size(reply->group_qual[lgroupcount].group_activity_qual[
              lgroupactivitycount].reagent_qual[lreagentcount].result_qual,5))
              SET nstatus = alterlist(reply->group_qual[lgroupcount].group_activity_qual[
               lgroupactivitycount].reagent_qual[lreagentcount].result_qual,(lresultcount+ 9))
             ENDIF
             SET nresultfound = 1
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].qc_result_id = temp_reply->
             group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].qc_result_id
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].enhancement_activity_id =
             temp_reply->group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].
             enhancement_activity_id
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].control_activity_id = temp_reply->
             group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].control_activity_id
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].mnemonic = temp_reply->group_qual[
             i].group_activity_qual[j].reagent_qual[k].result_qual[l].mnemonic
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].result_dt_tm = temp_reply->
             group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].result_dt_tm
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].result_prsnl_id = temp_reply->
             group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].result_prsnl_id
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].result_prsnl_username = temp_reply
             ->group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].
             result_prsnl_username
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].abnormal_ind = temp_reply->
             group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].abnormal_ind
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].reason_cd = temp_reply->
             group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].reason_cd
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].status_cd = temp_reply->
             group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].status_cd
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].phase_cd = temp_reply->group_qual[
             i].group_activity_qual[j].reagent_qual[k].result_qual[l].phase_cd
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].primary_review_prsnl_id =
             temp_reply->group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].
             primary_review_prsnl_id
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].primary_review_username =
             temp_reply->group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].
             primary_review_username
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].primary_review_dt_tm = temp_reply
             ->group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].
             primary_review_dt_tm
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].secondary_review_prsnl_id =
             temp_reply->group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].
             secondary_review_prsnl_id
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].secondary_review_username =
             temp_reply->group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].
             secondary_review_username
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].secondary_review_dt_tm =
             temp_reply->group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].
             secondary_review_dt_tm
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].action_prsnl_id = temp_reply->
             group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].action_prsnl_id
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].action_prsnl_username = temp_reply
             ->group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].
             action_prsnl_username
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].action_dt_tm = temp_reply->
             group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].action_dt_tm
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].comment_text_id = temp_reply->
             group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].comment_text_id
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].comment_text = temp_reply->
             group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].comment_text
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].enhancement_media_cd = temp_reply
             ->group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].
             enhancement_media_cd
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].enhancement_manf_cd = temp_reply->
             group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].enhancement_manf_cd
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].enhancement_lot_number =
             temp_reply->group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].
             enhancement_lot_number
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].enhancement_status_cd = temp_reply
             ->group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].
             enhancement_status_cd
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].control_media_cd = temp_reply->
             group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].control_media_cd
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].control_manf_cd = temp_reply->
             group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].control_manf_cd
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].control_lot_number = temp_reply->
             group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].control_lot_number
             SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
             reagent_qual[lreagentcount].result_qual[lresultcount].control_status_cd = temp_reply->
             group_qual[i].group_activity_qual[j].reagent_qual[k].result_qual[l].control_status_cd
             SET ltroubleshootingcount = 0
             FOR (m = 1 TO size(temp_reply->group_qual[i].group_activity_qual[j].reagent_qual[k].
              result_qual[l].troubleshooting_qual,5))
               SET ltroubleshootingcount = (ltroubleshootingcount+ 1)
               IF (ltroubleshootingcount >= size(reply->group_qual[lgroupcount].group_activity_qual[
                lgroupactivitycount].reagent_qual[lreagentcount].result_qual[lresultcount].
                troubleshooting_qual,5))
                SET nstatus = alterlist(reply->group_qual[lgroupcount].group_activity_qual[
                 lgroupactivitycount].reagent_qual[lreagentcount].result_qual[lresultcount].
                 troubleshooting_qual,(ltroubleshootingcount+ 9))
               ENDIF
               SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
               reagent_qual[lreagentcount].result_qual[lresultcount].troubleshooting_qual[
               ltroubleshootingcount].troubleshooting_id = temp_reply->group_qual[i].
               group_activity_qual[j].reagent_qual[k].result_qual[l].troubleshooting_qual[m].
               troubleshooting_id
               SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
               reagent_qual[lreagentcount].result_qual[lresultcount].troubleshooting_qual[
               ltroubleshootingcount].troubleshooting_text_id = temp_reply->group_qual[i].
               group_activity_qual[j].reagent_qual[k].result_qual[l].troubleshooting_qual[m].
               troubleshooting_text_id
               SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
               reagent_qual[lreagentcount].result_qual[lresultcount].troubleshooting_qual[
               ltroubleshootingcount].active_ind = temp_reply->group_qual[i].group_activity_qual[j].
               reagent_qual[k].result_qual[l].troubleshooting_qual[m].active_ind
               SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
               reagent_qual[lreagentcount].result_qual[lresultcount].troubleshooting_qual[
               ltroubleshootingcount].updt_cnt = temp_reply->group_qual[i].group_activity_qual[j].
               reagent_qual[k].result_qual[l].troubleshooting_qual[m].updt_cnt
               SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
               reagent_qual[lreagentcount].result_qual[lresultcount].troubleshooting_qual[
               ltroubleshootingcount].beg_effective_dt_tm = temp_reply->group_qual[i].
               group_activity_qual[j].reagent_qual[k].result_qual[l].troubleshooting_qual[m].
               beg_effective_dt_tm
               SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
               reagent_qual[lreagentcount].result_qual[lresultcount].troubleshooting_qual[
               ltroubleshootingcount].end_effective_dt_tm = temp_reply->group_qual[i].
               group_activity_qual[j].reagent_qual[k].result_qual[l].troubleshooting_qual[m].
               end_effective_dt_tm
               SET reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount].
               reagent_qual[lreagentcount].result_qual[lresultcount].troubleshooting_qual[
               ltroubleshootingcount].long_text = temp_reply->group_qual[i].group_activity_qual[j].
               reagent_qual[k].result_qual[l].troubleshooting_qual[m].long_text
             ENDFOR
             SET nstatus = alterlist(reply->group_qual[lgroupcount].group_activity_qual[
              lgroupactivitycount].reagent_qual[lreagentcount].result_qual[lresultcount].
              troubleshooting_qual,ltroubleshootingcount)
            ENDIF
          ENDFOR
          SET nstatus = alterlist(reply->group_qual[lgroupcount].group_activity_qual[
           lgroupactivitycount].reagent_qual[lreagentcount].result_qual,lresultcount)
         ENDIF
       ENDFOR
       SET nstatus = alterlist(reply->group_qual[lgroupcount].group_activity_qual[lgroupactivitycount
        ].reagent_qual,lreagentcount)
      ENDIF
    ENDFOR
    SET nstatus = alterlist(reply->group_qual[lgroupcount].group_activity_qual,lgroupactivitycount)
   ENDIF
 ENDFOR
 SET nstatus = alterlist(reply->group_qual,lgroupcount)
 IF (nresultfound=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 DECLARE addselecttext(sselecttext=vc(value)) = null WITH protect
 SUBROUTINE addselecttext(sselecttext)
   DECLARE nstatus = i2 WITH protect, noconstant(0)
   SET lselectcount = (lselectcount+ 1)
   IF (lselectcount >= size(temp_reply->select_qual,5))
    SET nstatus = alterlist(temp_reply->select_qual,(lselectcount+ 10))
   ENDIF
   SET temp_reply->select_qual[lselectcount].text = sselecttext
 END ;Subroutine
 DECLARE addselect2text(sselecttext=vc(value)) = null WITH protect
 SUBROUTINE addselect2text(sselecttext)
   DECLARE nstatus = i2 WITH protect, noconstant(0)
   SET lselect2count = (lselect2count+ 1)
   IF (lselect2count >= size(temp_reply->select2_qual,5))
    SET nstatus = alterlist(temp_reply->select2_qual,(lselect2count+ 10))
   ENDIF
   SET temp_reply->select2_qual[lselect2count].text = sselecttext
 END ;Subroutine
 DECLARE performselect() = null WITH protect
 SUBROUTINE performselect(null)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE nstatus = i2 WITH protect, noconstant(0)
   SET nstatus = alterlist(temp_reply->select_qual,lselectcount)
   FOR (i = 1 TO lselectcount)
     CALL parser(temp_reply->select_qual[i].text)
   ENDFOR
 END ;Subroutine
 DECLARE performselect2() = null WITH protect
 SUBROUTINE performselect2(null)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE nstatus = i2 WITH protect, noconstant(0)
   SET nstatus = alterlist(temp_reply->select2_qual,lselect2count)
   FOR (i = 1 TO lselect2count)
     CALL parser(temp_reply->select2_qual[i].text)
   ENDFOR
 END ;Subroutine
#exit_script
END GO
