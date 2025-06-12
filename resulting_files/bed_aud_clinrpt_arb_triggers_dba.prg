CREATE PROGRAM bed_aud_clinrpt_arb_triggers:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD triggers
 RECORD triggers(
   1 qual[*]
     2 chart_trigger_id = f8
     2 trigger_name = vc
     2 discharge_type_flag = i2
     2 scope_flag = i2
     2 pending_flag = i2
     2 report_template_id = f8
     2 template_name = vc
     2 chart_format_id = f8
     2 chart_format_name = vc
     2 print_range_flag = i2
     2 days_nbr = i4
     2 date_dt_tm = dq8
     2 route_location_bit_map = i4
     2 default_output_dest_cd = f8
     2 default_output_dest_name = vc
     2 dms_service_name = vc
     2 expired_reltn_ind = i2
     2 file_storage_cd = f8
     2 file_storage_location = vc
     2 addl_copy_nbr = i4
     2 params[*]
       3 include_ind = i2
       3 include_disp = vc
       3 param_type_flag = i2
       3 param_display = vc
     2 organizations[*]
       3 org_id = f8
       3 org_name = vc
     2 sending_org_id = f8
     2 sending_org_name = vc
     2 sending_org_email = vc
     2 copy_to_providers[*]
       3 person_id = f8
       3 name_full_formatted = vc
 )
 FREE RECORD trigger_service_resources
 RECORD trigger_service_resources(
   1 qual[*]
     2 chart_trigger_id = f8
     2 service_resources[*]
       3 service_resource_cd = f8
       3 isparent = i2
 )
 DECLARE trig_nbr = i4 WITH noconstant(0)
 DECLARE param_display = vc WITH noconstant(" ")
 DECLARE param_orgs_disp = vc WITH noconstant(" ")
 DECLARE param_routes_disp = vc WITH noconstant(" ")
 DECLARE param_prsnls_disp = vc WITH noconstant(" ")
 DECLARE intsecemail_cd = f8 WITH noconstant(0.0)
 DECLARE charttriggersize = i2
 DECLARE chartparser = vc
 DECLARE encountertypessize = i2
 DECLARE encntlocparser = vc
 DECLARE locationsize = i2
 DECLARE child_srv_num = i2
 DECLARE stidx = i2
 DECLARE numt = i4
 DECLARE post = i4
 DECLARE posp = i4
 DECLARE routing_nbr = i4
 DECLARE pos = i4
 DECLARE high_data_limit = i4 WITH protect, constant(5000)
 DECLARE medium_data_limit = i4 WITH protect, constant(3000)
 DECLARE high_volume_cnt = i4 WITH protect, noconstant(0)
 DECLARE max_copy_to_providers = i4 WITH constant(250)
 DECLARE createcolumnheader(null) = null
 DECLARE getactivetriggers(null) = null
 DECLARE gettriggerparams(null) = null
 DECLARE generatetriggerreport(null) = null
 DECLARE getdmsservicename(service_ident=vc(value," "),output_dest_cd=f8(ref)) = vc
 DECLARE getsendingorgname(null) = null
 DECLARE getsendingorgemail(null) = null
 DECLARE hi18n = i4 WITH noconstant(0)
 SET stat = uar_i18nlocalizationinit(hi18n,curprog,"",curcclrev)
 DECLARE scope_encntr = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.SCOPE_ENCNTR","Encounter"))
 DECLARE scope_accn = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.SCOPE_ACCN","Accession"))
 DECLARE scope_doc = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.SCOPE_DOC","Document"))
 DECLARE dischg_only = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.DISCHG_ONLY","Discharged patients only"))
 DECLARE nondischg_only = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.NONDISCHG_ONLY","Non-discharged patients only"))
 DECLARE dischg_type_both = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.DISCHG_TYPE_BOTH","Both discharged and non-discharged patients"))
 DECLARE print_recent = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.PRINT_RECENT","Recent"))
 DECLARE print_cum = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.PRINT_CUM","Cumulative"))
 DECLARE print_dischg_dt = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.PRINT_DISCHG_DT","Discharge date"))
 DECLARE print_days = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.PRINT_DAYS","Number of days"))
 DECLARE print_from_dt = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.PRINT_FROM_DT","Date from"))
 DECLARE route_device = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.ROUTE_DEVICE","Assigned device"))
 DECLARE route_prov = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.ROUTE_PROV","Selected provider types"))
 DECLARE route_pat_loc = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.ROUTE_PAT_LOC","Patient location"))
 DECLARE route_org = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.ROUTE_ORG","Organization"))
 DECLARE route_ord_loc = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.ROUTE_ORD_LOC","Order location"))
 DECLARE val_yes = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.VAL_YES","Yes"))
 DECLARE val_no = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.VAL_NO","No"))
 DECLARE val_include = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.VAL_INCLUDE","Include"))
 DECLARE val_exclude = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.VAL_EXCLUDE","Exclude"))
 DECLARE author = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.AUTHOR","Author"))
 DECLARE reviewer = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.REVIEWER","Reviewer"))
 DECLARE signer = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.SIGNER","Signer"))
 DECLARE cosigner = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "BED_AUD_CLINRPT_ARB_TRIGGERS.COSIGNER","Cosigner"))
 DECLARE param_type_encntr_type = i2 WITH constant(1), protect
 DECLARE param_type_org = i2 WITH constant(2), protect
 DECLARE param_type_loc = i2 WITH constant(3), protect
 DECLARE param_type_sevice_res = i2 WITH constant(4), protect
 DECLARE param_type_contrib_sys = i2 WITH constant(5), protect
 DECLARE param_type_interp = i2 WITH constant(6), protect
 DECLARE param_type_event_set = i2 WITH constant(7), protect
 DECLARE param_type_prsnl = i2 WITH constant(8), protect
 DECLARE param_type_prsnl_type = i2 WITH constant(9), protect
 DECLARE param_type_event_action = i2 WITH constant(10), protect
 DECLARE flag_encntr_scope = i2 WITH constant(2), protect
 DECLARE flag_accn_scope = i2 WITH constant(4), protect
 DECLARE flag_doc_scope = i2 WITH constant(6), protect
 DECLARE flag_nondischg_only = i2 WITH constant(1), protect
 DECLARE flag_dischg_only = i2 WITH constant(2), protect
 DECLARE flag_dischg_type_both = i2 WITH constant(3), protect
 DECLARE flag_print_recent = i2 WITH constant(1), protect
 DECLARE flag_print_cum = i2 WITH constant(2), protect
 DECLARE flag_print_dischg_dt = i2 WITH constant(3), protect
 DECLARE flag_print_days = i2 WITH constant(4), protect
 DECLARE flag_print_from_dt = i2 WITH constant(5), protect
 SET stat = uar_get_meaning_by_codeset(43,"INTSECEMAIL",1,intsecemail_cd)
 SET reply->status_data.status = "F"
 SET charttriggersize = size(request->trigger_list,5)
 SET locationsize = size(request->location_list,5)
 SET encountertypessize = size(request->encounter_list,5)
 IF (charttriggersize > 0)
  SET chartparser = build(chartparser," ct.chart_trigger_id IN ( ")
  FOR (pt = 1 TO charttriggersize)
    SET chartparser = build(chartparser,request->trigger_list[pt].trigger_id,",")
  ENDFOR
  SET chartparser = replace(chartparser,",","",2)
  SET chartparser = build(chartparser,")")
 ELSE
  SET chartparser = build(chartparser,"1 = 1")
 ENDIF
 IF (encountertypessize > 0)
  SET encntlocparser = build(encntlocparser,"ctp.parent_entity_id IN (")
  FOR (pt = 1 TO encountertypessize)
    SET encntlocparser = build(encntlocparser,request->encounter_list[pt].encounter_cd,",")
  ENDFOR
  IF (locationsize=0)
   SET encntlocparser = replace(encntlocparser,",","",2)
   SET encntlocparser = build(encntlocparser,")")
  ENDIF
 ENDIF
 IF (locationsize > 0)
  IF (encountertypessize=0)
   SET encntlocparser = build(encntlocparser,"ctp.parent_entity_id IN (")
  ENDIF
  FOR (pt = 1 TO locationsize)
    SET encntlocparser = build(encntlocparser,request->location_list[pt].location_cd,",")
  ENDFOR
  SET encntlocparser = replace(encntlocparser,",","",2)
  SET encntlocparser = build(encntlocparser,")")
 ENDIF
 IF (locationsize=0
  AND encountertypessize=0)
  SET encntlocparser = build(encntlocparser," 1 = 1")
 ENDIF
 CALL getactivetriggers(null)
 CALL getsendingorgname(null)
 CALL getsendingorgemail(null)
 CALL createcolumnheader(null)
 IF (trig_nbr=0)
  GO TO exit_script
 ENDIF
 CALL gettriggerparams(null)
 CALL generatetriggerreport(null)
 SUBROUTINE getactivetriggers(null)
   SELECT INTO "nl:"
    FROM chart_trigger ct,
     chart_format cf,
     cr_report_template cr,
     chart_trigger_param ctp
    PLAN (ctp
     WHERE parser(encntlocparser))
     JOIN (ct
     WHERE ct.active_ind=1
      AND ct.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ct.chart_trigger_id=ctp.chart_trigger_id
      AND parser(chartparser))
     JOIN (cf
     WHERE cf.chart_format_id=ct.chart_format_id)
     JOIN (cr
     WHERE cr.template_id=ct.report_template_id)
    ORDER BY cnvtupper(ct.trigger_name)
    HEAD REPORT
     trig_nbr = 0
    HEAD ct.trigger_name
     trig_nbr = (trig_nbr+ 1)
     IF (mod(trig_nbr,10)=1)
      stat = alterlist(triggers->qual,(trig_nbr+ 9))
     ENDIF
     triggers->qual[trig_nbr].chart_trigger_id = ct.chart_trigger_id, triggers->qual[trig_nbr].
     trigger_name = ct.trigger_name, triggers->qual[trig_nbr].discharge_type_flag = ct
     .discharge_type_flag,
     triggers->qual[trig_nbr].scope_flag = ct.scope_flag, triggers->qual[trig_nbr].pending_flag = ct
     .pending_flag, triggers->qual[trig_nbr].chart_format_id = ct.chart_format_id,
     triggers->qual[trig_nbr].chart_format_name = cf.chart_format_desc, triggers->qual[trig_nbr].
     report_template_id = ct.report_template_id, triggers->qual[trig_nbr].template_name = cr
     .template_name,
     triggers->qual[trig_nbr].print_range_flag = ct.print_range_flag, triggers->qual[trig_nbr].
     days_nbr =
     IF (ct.print_range_flag=4) ct.days_nbr
     ELSE 0
     ENDIF
     IF (ct.print_range_flag=5)
      triggers->qual[trig_nbr].date_dt_tm = ct.date_dt_tm
     ENDIF
     triggers->qual[trig_nbr].route_location_bit_map = ct.route_location_bit_map, triggers->qual[
     trig_nbr].default_output_dest_cd = ct.default_output_dest_cd, triggers->qual[trig_nbr].
     default_output_dest_name = getdmsservicename(trim(ct.dms_service_name,3),triggers->qual[trig_nbr
      ].default_output_dest_cd),
     triggers->qual[trig_nbr].dms_service_name = ct.dms_service_name, triggers->qual[trig_nbr].
     expired_reltn_ind = ct.expired_reltn_ind, triggers->qual[trig_nbr].file_storage_cd = ct
     .file_storage_cd,
     triggers->qual[trig_nbr].file_storage_location = ct.file_storage_location, triggers->qual[
     trig_nbr].addl_copy_nbr = ct.additional_copy_nbr, triggers->qual[trig_nbr].sending_org_id = ct
     .sending_org_id
    DETAIL
     do_nothing = 0
    FOOT REPORT
     stat = alterlist(triggers->qual,trig_nbr)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE gettriggerparams(null)
   DECLARE max_org_cnt = i4 WITH noconstant(0)
   DECLARE max_prsnl_cnt = i4 WITH noconstant(0)
   DECLARE max_sr_cnt = i4 WITH noconstant(0)
   DECLARE tsr_cnt = i4 WITH noconstant(0)
   DECLARE loc_cnt = i4 WITH noconstant(0)
   DECLARE max_loc_cnt = i4 WITH noconstant(0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = trig_nbr),
     chart_trigger_param ctp,
     output_dest od,
     device dv
    PLAN (d)
     JOIN (ctp
     WHERE (ctp.chart_trigger_id=triggers->qual[d.seq].chart_trigger_id)
      AND ctp.active_ind=1
      AND ctp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (od
     WHERE od.output_dest_cd=outerjoin(triggers->qual[d.seq].default_output_dest_cd))
     JOIN (dv
     WHERE dv.device_cd=outerjoin(od.device_cd))
    ORDER BY d.seq, ctp.param_type_flag
    HEAD REPORT
     high_volume_cnt = (high_volume_cnt+ 1), tsr_cnt = 0
    HEAD d.seq
     param_types = 0, org_cnt = 0, prsnl_cnt = 0,
     sr_cnt = 0
     IF ((triggers->qual[d.seq].default_output_dest_cd > 0))
      triggers->qual[d.seq].default_output_dest_name = dv.name
     ENDIF
    HEAD ctp.param_type_flag
     param_types = (param_types+ 1), stat = alterlist(triggers->qual[d.seq].params,param_types),
     triggers->qual[d.seq].params[param_types].include_ind = ctp.include_ind,
     triggers->qual[d.seq].params[param_types].include_disp =
     IF (ctp.include_ind=1) val_include
     ELSE val_exclude
     ENDIF
     , triggers->qual[d.seq].params[param_types].param_type_flag = ctp.param_type_flag, param_vals =
     0,
     param_display = " "
     IF (ctp.param_type_flag=param_type_sevice_res)
      tsr_cnt = (tsr_cnt+ 1), stat = alterlist(trigger_service_resources->qual,tsr_cnt),
      trigger_service_resources->qual[tsr_cnt].chart_trigger_id = triggers->qual[d.seq].
      chart_trigger_id
     ENDIF
    DETAIL
     param_vals = (param_vals+ 1)
     CASE (ctp.param_type_flag)
      OF param_type_org:
       stat = alterlist(triggers->qual[d.seq].organizations,param_vals),triggers->qual[d.seq].
       organizations[param_vals].org_id = ctp.parent_entity_id,org_cnt = (org_cnt+ 1)
      OF param_type_sevice_res:
       sr_cnt = (sr_cnt+ 1),stat = alterlist(trigger_service_resources->qual[tsr_cnt].
        service_resources,sr_cnt),trigger_service_resources->qual[tsr_cnt].service_resources[sr_cnt].
       service_resource_cd = ctp.parent_entity_id
      OF param_type_prsnl:
       stat = alterlist(triggers->qual[d.seq].copy_to_providers,param_vals),triggers->qual[d.seq].
       copy_to_providers[param_vals].person_id = ctp.parent_entity_id,prsnl_cnt = (prsnl_cnt+ 1)
      OF param_type_event_action:
       IF (param_vals > 1)
        param_display = notrim(concat(param_display,"; "))
       ENDIF
       ,
       IF (uar_get_code_meaning(ctp.parent_entity_id)="PERFORM")
        param_display = concat(param_display,author)
       ELSEIF (uar_get_code_meaning(ctp.parent_entity_id)="REVIEW")
        param_display = concat(param_display,reviewer)
       ELSEIF (uar_get_code_meaning(ctp.parent_entity_id)="SIGN")
        param_display = concat(param_display,signer)
       ELSEIF (uar_get_code_meaning(ctp.parent_entity_id)="COSIGN")
        param_display = concat(param_display,cosigner)
       ENDIF
      ELSE
       IF (ctp.param_type_flag IN (param_type_loc, param_type_interp))
        IF (param_vals > 1)
         param_display = build2(trim(param_display),"; ",trim(uar_get_code_description(ctp
            .parent_entity_id)))
        ELSE
         param_display = trim(uar_get_code_description(ctp.parent_entity_id))
        ENDIF
        IF (ctp.param_type_flag=param_type_loc)
         loc_cnt = (loc_cnt+ 1)
        ENDIF
       ELSE
        IF (param_vals > 1)
         param_display = build2(trim(param_display),"; ",trim(uar_get_code_display(ctp
            .parent_entity_id)))
        ELSE
         param_display = trim(uar_get_code_display(ctp.parent_entity_id))
        ENDIF
       ENDIF
       ,param_display = build2(trim(param_display)," (",trim(cnvtstringchk(ctp.parent_entity_id)),")"
        )
     ENDCASE
    FOOT  ctp.param_type_flag
     triggers->qual[d.seq].params[param_types].param_display = param_display
    FOOT  d.seq
     IF (org_cnt > max_org_cnt)
      max_org_cnt = org_cnt
     ENDIF
     IF (prsnl_cnt > max_prsnl_cnt)
      max_prsnl_cnt = prsnl_cnt
     ENDIF
     IF (sr_cnt > max_sr_cnt)
      max_sr_cnt = sr_cnt
     ENDIF
     IF (loc_cnt > max_loc_cnt)
      max_loc_cnt = loc_cnt
     ENDIF
    WITH nocounter
   ;end select
   IF ((request->skip_volume_check_ind=0))
    IF (((max_prsnl_cnt > max_copy_to_providers) OR (((max_loc_cnt > max_copy_to_providers) OR (
    high_volume_cnt > high_data_limit)) )) )
     SET reply->high_volume_flag = 2
     GO TO exit_script
    ELSEIF (high_volume_cnt > medium_data_limit)
     SET reply->high_volume_flag = 1
     GO TO exit_script
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = trig_nbr),
     (dummyt d2  WITH seq = value(max_org_cnt)),
     organization o
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(triggers->qual[d1.seq].organizations,5))
     JOIN (o
     WHERE (o.organization_id=triggers->qual[d1.seq].organizations[d2.seq].org_id))
    ORDER BY d1.seq
    DETAIL
     triggers->qual[d1.seq].organizations[d2.seq].org_name = o.org_name
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = trig_nbr),
     (dummyt d2  WITH seq = value(max_prsnl_cnt)),
     prsnl p
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(triggers->qual[d1.seq].copy_to_providers,5))
     JOIN (p
     WHERE (p.person_id=triggers->qual[d1.seq].copy_to_providers[d2.seq].person_id))
    ORDER BY d1.seq
    DETAIL
     triggers->qual[d1.seq].copy_to_providers[d2.seq].name_full_formatted = p.name_full_formatted
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = tsr_cnt),
     (dummyt d2  WITH seq = value(max_sr_cnt)),
     resource_group rg
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(trigger_service_resources->qual[d1.seq].service_resources,5))
     JOIN (rg
     WHERE (rg.parent_service_resource_cd=trigger_service_resources->qual[d1.seq].service_resources[
     d2.seq].service_resource_cd))
    ORDER BY d1.seq
    HEAD d1.seq
     do_nothing = 0
    DETAIL
     num = 0, sidx = 1, pos = locateval(num,sidx,size(trigger_service_resources->qual[d1.seq].
       service_resources,5),rg.parent_service_resource_cd,trigger_service_resources->qual[d1.seq].
      service_resources[num].service_resource_cd)
     IF (pos > 0)
      trigger_service_resources->qual[d1.seq].service_resources[pos].isparent = 1
     ENDIF
    WITH nocounter
   ;end select
   FOR (d1 = 1 TO tsr_cnt)
     SET param_display = " "
     SET child_srv_num = 0
     FOR (x = 1 TO size(trigger_service_resources->qual[d1].service_resources,5))
       IF ((trigger_service_resources->qual[d1].service_resources[x].isparent=0))
        SET child_srv_num = (child_srv_num+ 1)
        IF (child_srv_num > 1)
         SET param_display = build2(trim(param_display),"; ",trim(uar_get_code_description(
            trigger_service_resources->qual[d1].service_resources[x].service_resource_cd)))
        ELSE
         SET param_display = trim(uar_get_code_description(trigger_service_resources->qual[d1].
           service_resources[x].service_resource_cd))
        ENDIF
        SET param_display = build2(param_display," (",trim(cnvtstringchk(trigger_service_resources->
           qual[d1].service_resources[x].service_resource_cd)),")")
       ENDIF
     ENDFOR
     SET numt = 0
     SET stidx = 1
     SET post = locateval(numt,stidx,trig_nbr,trigger_service_resources->qual[d1].chart_trigger_id,
      triggers->qual[numt].chart_trigger_id)
     SET numt = 0
     SET stidx = 1
     SET posp = locateval(numt,stidx,size(triggers->qual[post].params,5),4,triggers->qual[post].
      params[numt].param_type_flag)
     SET triggers->qual[post].params[posp].param_display = param_display
   ENDFOR
 END ;Subroutine
 SUBROUTINE getdmsservicename(service_ident,output_dest_cd)
   DECLARE service_name = vc
   DECLARE atpos = i4 WITH noconstant(0)
   DECLARE spos = i4 WITH noconstant(0)
   SET atpos = findstring("@OUTPUT_DEST@FAX",service_ident)
   IF (atpos > 0)
    SET output_dest_cd = cnvtreal(substring(1,(atpos - 1),service_ident))
   ELSE
    SET atpos = findstring("@DMS@PRINTER",service_ident)
    IF (atpos > 0)
     SET service_name = substring(1,(atpos - 1),service_ident)
    ELSE
     SET atpos = findstring("@LOCAL@PRINTER",service_ident)
     IF (atpos > 0)
      SET service_name = substring(1,(atpos - 1),service_ident)
      SET spos = findstring("\",service_name,1,1)
      IF (spos > 0)
       SET service_name = substring((spos+ 1),(size(service_name,1) - spos),service_name)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(service_name)
 END ;Subroutine
 SUBROUTINE getsendingorgname(null)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = trig_nbr),
     organization o
    PLAN (d)
     JOIN (o
     WHERE (o.organization_id=triggers->qual[d.seq].sending_org_id)
      AND o.active_ind=1)
    DETAIL
     triggers->qual[d.seq].sending_org_name = o.org_name
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getsendingorgemail(null)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = trig_nbr),
     phone p
    PLAN (d)
     JOIN (p
     WHERE (p.parent_entity_id=triggers->qual[d.seq].sending_org_id)
      AND p.phone_type_cd=intsecemail_cd
      AND p.active_ind=1)
    DETAIL
     triggers->qual[d.seq].sending_org_email = p.phone_num
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE createcolumnheader(null)
   IF ( NOT (validate(trig_name)))
    DECLARE trig_name = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.TRIG_NAME","Trigger Name"))
   ENDIF
   IF ( NOT (validate(report_template)))
    DECLARE report_template = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.REPORT_TEMPLATE","Report Template"))
   ENDIF
   IF ( NOT (validate(event_set)))
    DECLARE event_set = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.EVENT_SET","Event Set"))
   ENDIF
   IF ( NOT (validate(chart_format)))
    DECLARE chart_format = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.CHART_FORMAT","Chart Format"))
   ENDIF
   IF ( NOT (validate(scope)))
    DECLARE scope = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.SCOPE","Scope"))
   ENDIF
   IF ( NOT (validate(discharge_type)))
    DECLARE discharge_type = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.DISCHARGE_TYPE","Discharge Type"))
   ENDIF
   IF ( NOT (validate(print_range)))
    DECLARE print_range = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.PRINT_RANGE","Print Range Option"))
   ENDIF
   IF ( NOT (validate(routing)))
    DECLARE routing = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.ROUTING","Routing Options"))
   ENDIF
   IF ( NOT (validate(sending_organization)))
    DECLARE sending_organization = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.SENDING_ORGANIZATION","Sending Organization"))
   ENDIF
   IF ( NOT (validate(copy_nbr)))
    DECLARE copy_nbr = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.COPY_NBR","Number of Copies"))
   ENDIF
   IF ( NOT (validate(default_device)))
    DECLARE default_device = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.DEFAULT_DEVICE","Default Device"))
   ENDIF
   IF ( NOT (validate(file_storage)))
    DECLARE file_storage = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.FILE_STORAGE","File Storage"))
   ENDIF
   IF ( NOT (validate(file_location)))
    DECLARE file_location = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.FILE_LOCATION","File Location"))
   ENDIF
   IF ( NOT (validate(verified_only)))
    DECLARE verified_only = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.VERIFIED_ONLY","Verified Only"))
   ENDIF
   IF ( NOT (validate(excl_exp_reltn)))
    DECLARE excl_exp_reltn = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.EXCL_EXP_RELTN","Exclude Expired Relationship"))
   ENDIF
   IF ( NOT (validate(copy_to_reltn)))
    DECLARE copy_to_reltn = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.COPY_TO_RELTN","Copies to Providers Types"))
   ENDIF
   IF ( NOT (validate(copyto_providers)))
    DECLARE copyto_providers = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.COPYTO_PROVIDERS","Copy to Providers"))
   ENDIF
   IF ( NOT (validate(encntr_types)))
    DECLARE encntr_types = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.ENCNTR_TYPES","Encounter Types"))
   ENDIF
   IF ( NOT (validate(interpretations)))
    DECLARE interpretations = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.INTERPRETATIONS","Interpretations"))
   ENDIF
   IF ( NOT (validate(locations)))
    DECLARE locations = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.LOCATIONS","Locations"))
   ENDIF
   IF ( NOT (validate(organizations)))
    DECLARE organizations = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.ORGANIZATIONS","Organizations"))
   ENDIF
   IF ( NOT (validate(service_resources)))
    DECLARE service_resources = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.SERVICE_RESOURCES","Service Resources"))
   ENDIF
   IF ( NOT (validate(contrib_sys)))
    DECLARE contrib_sys = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
      "BED_AUD_CLINRPT_ARB_TRIGGERS.CONTRIB_SYS","Contributor Systems"))
   ENDIF
   SET stat = alterlist(reply->collist,23)
   SET reply->collist[1].header_text = trig_name
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = report_template
   SET reply->collist[2].data_type = 1
   SET reply->collist[2].hide_ind = 0
   SET reply->collist[3].header_text = event_set
   SET reply->collist[3].data_type = 1
   SET reply->collist[3].hide_ind = 0
   SET reply->collist[4].header_text = chart_format
   SET reply->collist[4].data_type = 1
   SET reply->collist[4].hide_ind = 0
   SET reply->collist[5].header_text = scope
   SET reply->collist[5].data_type = 1
   SET reply->collist[5].hide_ind = 0
   SET reply->collist[6].header_text = discharge_type
   SET reply->collist[6].data_type = 1
   SET reply->collist[6].hide_ind = 0
   SET reply->collist[7].header_text = print_range
   SET reply->collist[7].data_type = 1
   SET reply->collist[7].hide_ind = 0
   SET reply->collist[8].header_text = routing
   SET reply->collist[8].data_type = 1
   SET reply->collist[8].hide_ind = 0
   SET reply->collist[9].header_text = sending_organization
   SET reply->collist[9].data_type = 1
   SET reply->collist[9].hide_ind = 0
   SET reply->collist[10].header_text = copy_nbr
   SET reply->collist[10].data_type = 1
   SET reply->collist[10].hide_ind = 0
   SET reply->collist[11].header_text = default_device
   SET reply->collist[11].data_type = 1
   SET reply->collist[11].hide_ind = 0
   SET reply->collist[12].header_text = file_storage
   SET reply->collist[12].data_type = 1
   SET reply->collist[12].hide_ind = 0
   SET reply->collist[13].header_text = file_location
   SET reply->collist[13].data_type = 1
   SET reply->collist[13].hide_ind = 0
   SET reply->collist[14].header_text = verified_only
   SET reply->collist[14].data_type = 1
   SET reply->collist[14].hide_ind = 0
   SET reply->collist[15].header_text = excl_exp_reltn
   SET reply->collist[15].data_type = 1
   SET reply->collist[15].hide_ind = 0
   SET reply->collist[16].header_text = copy_to_reltn
   SET reply->collist[16].data_type = 1
   SET reply->collist[16].hide_ind = 0
   SET reply->collist[17].header_text = copyto_providers
   SET reply->collist[17].data_type = 1
   SET reply->collist[17].hide_ind = 0
   SET reply->collist[18].header_text = encntr_types
   SET reply->collist[18].data_type = 1
   SET reply->collist[18].hide_ind = 0
   SET reply->collist[19].header_text = interpretations
   SET reply->collist[19].data_type = 1
   SET reply->collist[19].hide_ind = 0
   SET reply->collist[20].header_text = locations
   SET reply->collist[20].data_type = 1
   SET reply->collist[20].hide_ind = 0
   SET reply->collist[21].header_text = organizations
   SET reply->collist[21].data_type = 1
   SET reply->collist[21].hide_ind = 0
   SET reply->collist[22].header_text = service_resources
   SET reply->collist[22].data_type = 1
   SET reply->collist[22].hide_ind = 0
   SET reply->collist[23].header_text = contrib_sys
   SET reply->collist[23].data_type = 1
   SET reply->collist[23].hide_ind = 0
 END ;Subroutine
 SUBROUTINE generatetriggerreport(null)
   DECLARE row_nbr = i4 WITH noconstant(0)
   SET stat = alterlist(reply->rowlist,trig_nbr)
   FOR (row_nbr = 1 TO trig_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,23)
     SET reply->rowlist[row_nbr].celllist[1].string_value = build2(triggers->qual[row_nbr].
      trigger_name," (",trim(cnvtstringchk(triggers->qual[row_nbr].chart_trigger_id)),")")
     IF ((triggers->qual[row_nbr].report_template_id > 0))
      SET reply->rowlist[row_nbr].celllist[2].string_value = build2(triggers->qual[row_nbr].
       template_name," (",trim(cnvtstringchk(triggers->qual[row_nbr].report_template_id)),")")
     ENDIF
     IF ((triggers->qual[row_nbr].chart_format_id > 0))
      SET reply->rowlist[row_nbr].celllist[4].string_value = build2(triggers->qual[row_nbr].
       chart_format_name," (",trim(cnvtstringchk(triggers->qual[row_nbr].chart_format_id)),")")
     ENDIF
     CASE (triggers->qual[row_nbr].scope_flag)
      OF flag_encntr_scope:
       SET reply->rowlist[row_nbr].celllist[5].string_value = scope_encntr
      OF flag_accn_scope:
       SET reply->rowlist[row_nbr].celllist[5].string_value = scope_accn
      OF flag_doc_scope:
       SET reply->rowlist[row_nbr].celllist[5].string_value = scope_doc
     ENDCASE
     CASE (triggers->qual[row_nbr].discharge_type_flag)
      OF flag_dischg_only:
       SET reply->rowlist[row_nbr].celllist[6].string_value = dischg_only
      OF flag_nondischg_only:
       SET reply->rowlist[row_nbr].celllist[6].string_value = nondischg_only
      OF flag_dischg_type_both:
       SET reply->rowlist[row_nbr].celllist[6].string_value = dischg_type_both
     ENDCASE
     CASE (triggers->qual[row_nbr].print_range_flag)
      OF flag_print_recent:
       SET reply->rowlist[row_nbr].celllist[7].string_value = print_recent
      OF flag_print_cum:
       SET reply->rowlist[row_nbr].celllist[7].string_value = print_cum
      OF flag_print_dischg_dt:
       SET reply->rowlist[row_nbr].celllist[7].string_value = print_dischg_dt
      OF flag_print_days:
       SET reply->rowlist[row_nbr].celllist[7].string_value = build2(print_days," ",trim(
         cnvtstringchk(triggers->qual[row_nbr].days_nbr)))
      OF flag_print_from_dt:
       SET reply->rowlist[row_nbr].celllist[7].string_value = build2(print_from_dt," ",format(
         triggers->qual[row_nbr].date_dt_tm,"mm/dd/yyyy;;d"))
     ENDCASE
     SET routing_nbr = 0
     SET pos = 0
     SET param_routes_disp = " "
     FOR (pos = 0 TO 4)
       IF (btest(triggers->qual[row_nbr].route_location_bit_map,pos))
        SET routing_nbr = (routing_nbr+ 1)
        IF (routing_nbr > 1)
         SET param_routes_disp = notrim(concat(param_routes_disp,"; "))
        ENDIF
        CASE (pos)
         OF 0:
          SET param_routes_disp = concat(param_routes_disp,route_device)
         OF 1:
          SET param_routes_disp = concat(param_routes_disp,route_prov)
         OF 2:
          SET param_routes_disp = concat(param_routes_disp,route_pat_loc)
         OF 3:
          SET param_routes_disp = concat(param_routes_disp,route_org)
         OF 4:
          SET param_routes_disp = concat(param_routes_disp,route_ord_loc)
        ENDCASE
       ENDIF
     ENDFOR
     SET reply->rowlist[row_nbr].celllist[8].string_value = param_routes_disp
     IF ((triggers->qual[row_nbr].sending_org_name=null))
      SET reply->rowlist[row_nbr].celllist[9].string_value = " "
     ELSEIF ((triggers->qual[row_nbr].sending_org_email=null))
      SET reply->rowlist[row_nbr].celllist[9].string_value = triggers->qual[row_nbr].sending_org_name
     ELSE
      SET reply->rowlist[row_nbr].celllist[9].string_value = build2(triggers->qual[row_nbr].
       sending_org_name," (",triggers->qual[row_nbr].sending_org_email,")")
     ENDIF
     SET reply->rowlist[row_nbr].celllist[10].string_value = cnvtstringchk(triggers->qual[row_nbr].
      addl_copy_nbr)
     IF ((triggers->qual[row_nbr].default_output_dest_cd > 0))
      SET reply->rowlist[row_nbr].celllist[11].string_value = build2(triggers->qual[row_nbr].
       default_output_dest_name," (",trim(cnvtstringchk(triggers->qual[row_nbr].
         default_output_dest_cd)),")")
     ELSE
      SET reply->rowlist[row_nbr].celllist[11].string_value = triggers->qual[row_nbr].
      default_output_dest_name
     ENDIF
     IF ((triggers->qual[row_nbr].file_storage_cd > 0))
      SET reply->rowlist[row_nbr].celllist[12].string_value = build2(trim(uar_get_code_display(
         triggers->qual[row_nbr].file_storage_cd))," (",trim(cnvtstringchk(triggers->qual[row_nbr].
         file_storage_cd)),")")
     ENDIF
     SET reply->rowlist[row_nbr].celllist[13].string_value = trim(triggers->qual[row_nbr].
      file_storage_location)
     IF ((triggers->qual[row_nbr].pending_flag=0))
      SET reply->rowlist[row_nbr].celllist[14].string_value = val_yes
     ELSE
      SET reply->rowlist[row_nbr].celllist[14].string_value = val_no
     ENDIF
     IF ((triggers->qual[row_nbr].expired_reltn_ind=1))
      SET reply->rowlist[row_nbr].celllist[15].string_value = val_yes
     ELSE
      SET reply->rowlist[row_nbr].celllist[15].string_value = val_no
     ENDIF
     FOR (par_nbr = 1 TO size(triggers->qual[row_nbr].params,5))
       CASE (triggers->qual[row_nbr].params[par_nbr].param_type_flag)
        OF param_type_event_set:
         SET reply->rowlist[row_nbr].celllist[3].string_value = triggers->qual[row_nbr].params[
         par_nbr].param_display
        OF param_type_prsnl_type:
         SET reply->rowlist[row_nbr].celllist[16].string_value = triggers->qual[row_nbr].params[
         par_nbr].param_display
        OF param_type_event_action:
         IF (size(reply->rowlist[row_nbr].celllist[16].string_value,1)=0)
          SET reply->rowlist[row_nbr].celllist[16].string_value = triggers->qual[row_nbr].params[
          par_nbr].param_display
         ELSE
          SET reply->rowlist[row_nbr].celllist[16].string_value = concat(reply->rowlist[row_nbr].
           celllist[15].string_value,"; ",triggers->qual[row_nbr].params[par_nbr].param_display)
         ENDIF
        OF param_type_prsnl:
         SET param_prsnls_disp = " "
         FOR (prsnl_nbr = 1 TO size(triggers->qual[row_nbr].copy_to_providers,5))
          IF (prsnl_nbr > 1)
           SET param_prsnls_disp = notrim(concat(param_prsnls_disp,"; "))
          ENDIF
          SET param_prsnls_disp = build2(param_prsnls_disp,trim(triggers->qual[row_nbr].
            copy_to_providers[prsnl_nbr].name_full_formatted)," (",trim(cnvtstringchk(triggers->qual[
             row_nbr].copy_to_providers[prsnl_nbr].person_id)),")")
         ENDFOR
         SET reply->rowlist[row_nbr].celllist[17].string_value = build2(triggers->qual[row_nbr].
          params[par_nbr].include_disp,": ",param_prsnls_disp)
        OF param_type_encntr_type:
         SET reply->rowlist[row_nbr].celllist[18].string_value = build2(triggers->qual[row_nbr].
          params[par_nbr].include_disp,": ",triggers->qual[row_nbr].params[par_nbr].param_display)
        OF param_type_interp:
         SET reply->rowlist[row_nbr].celllist[19].string_value = build2(triggers->qual[row_nbr].
          params[par_nbr].include_disp,": ",triggers->qual[row_nbr].params[par_nbr].param_display)
        OF param_type_loc:
         SET reply->rowlist[row_nbr].celllist[20].string_value = build2(triggers->qual[row_nbr].
          params[par_nbr].include_disp,": ",triggers->qual[row_nbr].params[par_nbr].param_display)
        OF param_type_org:
         SET param_orgs_disp = " "
         FOR (org_nbr = 1 TO size(triggers->qual[row_nbr].organizations,5))
          IF (org_nbr > 1)
           SET param_orgs_disp = notrim(concat(param_orgs_disp,"; "))
          ENDIF
          SET param_orgs_disp = build2(param_orgs_disp,trim(triggers->qual[row_nbr].organizations[
            org_nbr].org_name)," (",trim(cnvtstringchk(triggers->qual[row_nbr].organizations[org_nbr]
             .org_id)),")")
         ENDFOR
         SET reply->rowlist[row_nbr].celllist[21].string_value = build2(triggers->qual[row_nbr].
          params[par_nbr].include_disp,": ",param_orgs_disp)
        OF param_type_sevice_res:
         SET reply->rowlist[row_nbr].celllist[22].string_value = build2(triggers->qual[row_nbr].
          params[par_nbr].include_disp,": ",triggers->qual[row_nbr].params[par_nbr].param_display)
        OF param_type_contrib_sys:
         SET reply->rowlist[row_nbr].celllist[23].string_value = build2(triggers->qual[row_nbr].
          params[par_nbr].include_disp,": ",triggers->qual[row_nbr].params[par_nbr].param_display)
       ENDCASE
     ENDFOR
     IF ((request->skip_volume_check_ind=0))
      IF (row_nbr > high_data_limit)
       SET reply->high_volume_flag = 2
       SET stat = alterlist(reply->rowlist,0)
       GO TO exit_script
      ELSEIF (row_nbr > medium_data_limit)
       SET reply->high_volume_flag = 1
       SET stat = alterlist(reply->rowlist,0)
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("clinrpt_arb_triggers.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(triggers)
 CALL echorecord(reply)
END GO
