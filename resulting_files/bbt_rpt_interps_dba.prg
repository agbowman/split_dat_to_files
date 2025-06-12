CREATE PROGRAM bbt_rpt_interps:dba
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 cerner_hlth_systems = vc
   1 interp_audit = vc
   1 time = vc
   1 as_of_date = vc
   1 interp_detail = vc
   1 order_procedure = vc
   1 service_resource = vc
   1 interp_type = vc
   1 text_option = vc
   1 phase_group = vc
   1 system = vc
   1 generated = vc
   1 validated = vc
   1 assay = vc
   1 active = vc
   1 yes = vc
   1 no = vc
   1 cross_draws = vc
   1 time_window = vc
   1 time_window_na = vc
   1 results_required = vc
   1 result_status = vc
   1 performed = vc
   1 verified = vc
   1 range_info = vc
   1 species = vc
   1 gender = vc
   1 race = vc
   1 unknown_age = vc
   1 from_age = vc
   1 to_age = vc
   1 from_result = vc
   1 to_result = vc
   1 result_hash = vc
   1 result = vc
   1 rpt_active = vc
   1 interp_patterns = vc
   1 result_text = vc
   1 pattern_reasons = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 cross_reactive = vc
   1 reactive_task = vc
   1 reactive_result = vc
   1 end_of_report = vc
   1 all = vc
 )
 SET captions->cerner_hlth_systems = uar_i18ngetmessage(i18nhandle,"cerner_hlth_systems",
  "Cerner Health Systems")
 SET captions->interp_audit = uar_i18ngetmessage(i18nhandle,"interp_audit",
  "I N T E R P R E T A T I O N   A U D I T")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->interp_detail = uar_i18ngetmessage(i18nhandle,"interp_detail","Interp Detail:  ")
 SET captions->order_procedure = uar_i18ngetmessage(i18nhandle,"order_procedure","Order Procedure:  "
  )
 SET captions->service_resource = uar_i18ngetmessage(i18nhandle,"service_resource",
  "Service Resource:  ")
 SET captions->interp_type = uar_i18ngetmessage(i18nhandle,"interp_type","Interp Type:  ")
 SET captions->text_option = uar_i18ngetmessage(i18nhandle,"text_option","Text Option:  ")
 SET captions->phase_group = uar_i18ngetmessage(i18nhandle,"phase_group","Phase Group:  ")
 SET captions->system = uar_i18ngetmessage(i18nhandle,"system","System: ")
 SET captions->generated = uar_i18ngetmessage(i18nhandle,"generated","GENERATED")
 SET captions->validated = uar_i18ngetmessage(i18nhandle,"validated","VALIDATED")
 SET captions->assay = uar_i18ngetmessage(i18nhandle,"assay","Assay:  ")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","Active:  ")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->cross_draws = uar_i18ngetmessage(i18nhandle,"cross_draws","Cross Draws:  ")
 SET captions->time_window = uar_i18ngetmessage(i18nhandle,"time_window","Time Window:  ")
 SET captions->time_window_na = uar_i18ngetmessage(i18nhandle,"time_window_na","Time Window:  N/A")
 SET captions->results_required = uar_i18ngetmessage(i18nhandle,"results_required",
  "Results Required:  ")
 SET captions->result_status = uar_i18ngetmessage(i18nhandle,"result_status","Result Status:  ")
 SET captions->performed = uar_i18ngetmessage(i18nhandle,"performed","PERFORMED")
 SET captions->verified = uar_i18ngetmessage(i18nhandle,"verified","VERIFIED")
 SET captions->range_info = uar_i18ngetmessage(i18nhandle,"range_info","Range Information:")
 SET captions->species = uar_i18ngetmessage(i18nhandle,"species","Species:  ")
 SET captions->gender = uar_i18ngetmessage(i18nhandle,"gender","Gender:  ")
 SET captions->race = uar_i18ngetmessage(i18nhandle,"race","Race:  ")
 SET captions->unknown_age = uar_i18ngetmessage(i18nhandle,"unknown_age","Unknown Age: ")
 SET captions->from_age = uar_i18ngetmessage(i18nhandle,"from_age","From Age:  ")
 SET captions->to_age = uar_i18ngetmessage(i18nhandle,"to_age","To Age:  ")
 SET captions->from_result = uar_i18ngetmessage(i18nhandle,"from_result","From Result")
 SET captions->to_result = uar_i18ngetmessage(i18nhandle,"to_result","To Result")
 SET captions->result_hash = uar_i18ngetmessage(i18nhandle,"result_hash","Result Hash")
 SET captions->result = uar_i18ngetmessage(i18nhandle,"result","Result")
 SET captions->rpt_active = uar_i18ngetmessage(i18nhandle,"rpt_active","Active")
 SET captions->interp_patterns = uar_i18ngetmessage(i18nhandle,"interp_patterns",
  "Interpretation Patterns")
 SET captions->result_text = uar_i18ngetmessage(i18nhandle,"result_text","Result Text:  ")
 SET captions->pattern_reasons = uar_i18ngetmessage(i18nhandle,"pattern_reasons","Pattern Reasons")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_INTERPS")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->cross_reactive = uar_i18ngetmessage(i18nhandle,"cross_reactive",
  "Cross Reactive Results #")
 SET captions->reactive_task = uar_i18ngetmessage(i18nhandle,"reactive_task","Cross Reactive Task")
 SET captions->reactive_result = uar_i18ngetmessage(i18nhandle,"reactive_result",
  "Cross Reactive Result")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","All")
 RECORD store_pattern(
   1 new = vc
   1 hold = vc
 )
 RECORD cross_rr(
   1 interps[*]
     2 interp_id = f8
 )
 SET pattern_line = fillstring(100,"-")
 SET z = 0
 SET hold_cross_headers_id = 0.0
 SET hold_cross_task_headers_id = 0.0
 SET ncount = 0
 SET i_cnt = 0
 SET c_cnt = 0
 SET interp_total = 0
 SET reactive_total = 0
 SET results_total = 0
 SET i_idx = 0
 SET c_idx = 0
 RECORD data_map(
   1 qual[*]
     2 result_hash_id = f8
     2 min_digits = i4
     2 max_digits = i4
     2 min_dec_places = i4
 )
 RECORD tmptext(
   1 qual[*]
     2 text = vc
 )
 DECLARE uar_get_ceblobsize(p1=f8(ref),p2=vc(ref)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblobsize", persist
 DECLARE uar_get_ceblob(p1=f8(ref),p2=vc(ref),p3=vc(ref),p4=i4(value)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblob", persist
 RECORD recdate(
   1 datetime = dq8
 ) WITH protect
 DECLARE format = i2
 DECLARE outbuffer = vc
 DECLARE nortftext = vc
 SET format = 0
 DECLARE txt_pos = i4
 DECLARE start = i4
 DECLARE len = i4
 DECLARE linecnt = i4
 SUBROUTINE (rtf_to_text(rtftext=vc,format=i2,line_len=i2) =null)
   SET all_len = 0
   SET start = 0
   SET len = 0
   SET text_pos = 0
   SET linecnt = 0
   SET inbuffer = fillstring(value(size(rtftext))," ")
   SET outbufferlen = 0
   SET bfl = 0
   SET bfl2 = 1
   SET outbuffer = ""
   SET nortftext = ""
   SET stat = memrealloc(outbuffer,1,build("C",value(size(rtftext))))
   SET stat = memrealloc(nortftext,1,build("C",value(size(rtftext))))
   IF (substring(1,5,rtftext)=asis("{\rtf"))
    SET inbuffer = trim(rtftext)
    CALL uar_rtf2(inbuffer,size(inbuffer),outbuffer,size(outbuffer),outbufferlen,
     bfl)
   ELSE
    SET outbuffer = trim(rtftext)
   ENDIF
   SET nortftext = trim(outbuffer)
   SET stat = alterlist(tmptext->qual,0)
   SET crchar = concat(char(13),char(10))
   SET lfchar = char(10)
   SET ffchar = char(12)
   IF (format > 0)
    SET all_len = cnvtint(size(trim(outbuffer)))
    SET tot_len = 0
    SET start = 1
    SET bigfirst = "Y"
    SET crstart = start
    WHILE (all_len > tot_len)
      SET crpos = crstart
      SET crfirst = "Y"
      SET loaded = "N"
      WHILE ((crpos <= ((crstart+ line_len)+ 1))
       AND loaded="N"
       AND all_len > tot_len)
       IF ((crpos=((crstart+ line_len)+ 1))
        AND crfirst="N")
        SET start = crstart
        SET first = "Y"
        SET text_pos = ((start+ line_len) - 1)
        IF (bigfirst="Y"
         AND text_pos >= all_len)
         SET text_pos = start
        ENDIF
        SET bigfirst = "N"
        WHILE (text_pos >= start
         AND all_len > tot_len)
          IF (text_pos=start)
           SET text_pos = ((start+ line_len) - 1)
           SET linecnt += 1
           SET stat = alterlist(tmptext->qual,linecnt)
           SET len = ((text_pos - start)+ 1)
           SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
           SET start = (text_pos+ 1)
           SET crstart = (text_pos+ 1)
           SET text_pos = 0
           SET tot_len = ((tot_len+ len) - 1)
           SET loaded = "Y"
          ELSE
           IF (substring(text_pos,1,outbuffer)=" ")
            SET len = (text_pos - start)
            IF (cnvtint(size(trim(substring(start,len,outbuffer)))) > 0)
             SET linecnt += 1
             SET stat = alterlist(tmptext->qual,linecnt)
             SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
             SET loaded = "Y"
            ENDIF
            SET start = (text_pos+ 1)
            SET crstart = (text_pos+ 1)
            SET text_pos = 0
            SET tot_len += len
           ELSE
            IF (first="Y")
             SET first = "N"
             SET tot_len += 1
            ENDIF
            SET text_pos -= 1
           ENDIF
          ENDIF
        ENDWHILE
       ELSE
        SET crfirst = "N"
        IF (((substring(crpos,1,outbuffer)=crchar) OR (((substring(crpos,1,outbuffer)=lfchar) OR (
        substring(crpos,1,outbuffer)=ffchar)) )) )
         SET crlen = (crpos - crstart)
         SET linecnt += 1
         SET stat = alterlist(tmptext->qual,linecnt)
         SET tmptext->qual[linecnt].text = substring(crstart,crlen,outbuffer)
         SET loaded = "Y"
         IF (substring(crpos,1,outbuffer)=crchar)
          SET crstart = (crpos+ textlen(crchar))
         ELSEIF (substring(crpos,1,outbuffer)=lfchar)
          SET crstart = (crpos+ textlen(lfchar))
         ELSEIF (substring(crpos,1,outbuffer)=ffchar)
          SET crstart = (crpos+ textlen(ffchar))
         ENDIF
         SET tot_len += crlen
        ENDIF
       ENDIF
       SET crpos += 1
      ENDWHILE
    ENDWHILE
   ENDIF
   SET rtftext = fillstring(value(size(rtftext))," ")
   SET inbuffer = fillstring(value(size(rtftext))," ")
 END ;Subroutine
 DECLARE outbufmaxsiz = i2
 DECLARE tblobin = c32000
 DECLARE tblobout = c32000
 DECLARE blobin = c32000
 DECLARE blobout = c32000
 SUBROUTINE (decompress_text(tblobin=vc) =null)
   SET tblobout = fillstring(32000," ")
   SET blobout = fillstring(32000," ")
   SET outbufmaxsiz = 0
   SET blobin = trim(tblobin)
   CALL uar_ocf_uncompress(blobin,size(blobin),blobout,size(blobout),outbufmaxsiz)
   SET tblobout = blobout
   SET tblobin = fillstring(32000," ")
   SET blobin = fillstring(32000," ")
 END ;Subroutine
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_hna_interps", "txt", "x"
 SET subsection_group_cd = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(223,nullterm("SUBSECTION"),code_cnt,subsection_group_cd)
 DECLARE index_data_map = i4 WITH noconstant(0)
 DECLARE index2_data_map = i4 WITH noconstant(0)
 DECLARE min_digits_default = i4 WITH constant(1)
 DECLARE max_digits_default = i4 WITH constant(8)
 DECLARE min_dec_places_default = i4 WITH constant(0)
 DECLARE no_greater_less_than_applied = i2 WITH constant(0)
 DECLARE arg_min_digits = i4 WITH noconstant(0)
 DECLARE arg_max_digits = i4 WITH noconstant(0)
 DECLARE arg_min_dec_places = i4 WITH noconstant(0)
 SELECT
  IF ((request->interp_id=0))
   PLAN (ita
    WHERE ita.interp_id > 0)
    JOIN (ic
    WHERE ic.interp_id=ita.interp_id)
    JOIN (ir
    WHERE ir.interp_id=ita.interp_id
     AND ir.interp_detail_id=ic.interp_detail_id
     AND ir.included_assay_cd=ic.included_assay_cd)
    JOIN (rh
    WHERE rh.interp_id=ita.interp_id
     AND rh.interp_detail_id=ir.interp_detail_id
     AND rh.interp_range_id=ir.interp_range_id
     AND rh.included_assay_cd=ir.included_assay_cd
     AND rh.nomenclature_id=0)
    JOIN (d_dm
    WHERE d_dm.seq=1)
    JOIN (dm
    WHERE dm.task_assay_cd=ir.included_assay_cd
     AND dm.data_map_type_flag=0
     AND dm.active_ind=1)
    JOIN (d_rg
    WHERE d_rg.seq=1)
    JOIN (rg
    WHERE rg.parent_service_resource_cd=dm.service_resource_cd
     AND rg.child_service_resource_cd=ita.service_resource_cd
     AND rg.resource_group_type_cd=subsection_group_cd
     AND ((rg.root_service_resource_cd+ 0)=0.0))
  ELSE
   PLAN (ita
    WHERE (ita.interp_id=request->interp_id))
    JOIN (ic
    WHERE ic.interp_id=ita.interp_id)
    JOIN (ir
    WHERE ir.interp_id=ita.interp_id
     AND ir.interp_detail_id=ic.interp_detail_id
     AND ir.included_assay_cd=ic.included_assay_cd)
    JOIN (rh
    WHERE rh.interp_id=ita.interp_id
     AND rh.interp_detail_id=ir.interp_detail_id
     AND rh.interp_range_id=ir.interp_range_id
     AND rh.included_assay_cd=ir.included_assay_cd
     AND rh.nomenclature_id=0)
    JOIN (d_dm
    WHERE d_dm.seq=1)
    JOIN (dm
    WHERE dm.task_assay_cd=ir.included_assay_cd
     AND dm.data_map_type_flag=0
     AND dm.active_ind=1)
    JOIN (d_rg
    WHERE d_rg.seq=1)
    JOIN (rg
    WHERE rg.parent_service_resource_cd=dm.service_resource_cd
     AND rg.child_service_resource_cd=ita.service_resource_cd
     AND rg.resource_group_type_cd=subsection_group_cd
     AND ((rg.root_service_resource_cd+ 0)=0.0))
  ENDIF
  INTO "nl:"
  dm.task_assay_cd, dm.service_resource_cd, data_map_exists = decode(dm.seq,"Y","N"),
  rg_exists = decode(rg.seq,"Y","N"), ic_unique = build(ic.sequence,"_",ic.interp_detail_id)
  FROM interp_task_assay ita,
   interp_component ic,
   interp_range ir,
   result_hash rh,
   (dummyt d_dm  WITH seq = 1),
   data_map dm,
   (dummyt d_rg  WITH seq = 1),
   resource_group rg
  ORDER BY ita.interp_id, ic_unique, ir.interp_range_id,
   rh.result_hash_id, dm.service_resource_cd
  HEAD REPORT
   index_data_map = 0
  HEAD rh.result_hash_id
   index_data_map += 1, stat = alterlist(data_map->qual,index_data_map), data_map->qual[
   index_data_map].result_hash_id = rh.result_hash_id,
   data_map_level = 0, data_map->qual[index_data_map].min_digits = min_digits_default, data_map->
   qual[index_data_map].max_digits = max_digits_default,
   data_map->qual[index_data_map].min_dec_places = min_dec_places_default
  HEAD dm.service_resource_cd
   IF (data_map_exists="Y")
    IF (data_map_level <= 2
     AND dm.service_resource_cd > 0
     AND dm.service_resource_cd=ita.service_resource_cd)
     data_map_level = 3, data_map->qual[index_data_map].min_digits = dm.min_digits, data_map->qual[
     index_data_map].max_digits = dm.max_digits,
     data_map->qual[index_data_map].min_dec_places = dm.min_decimal_places
    ENDIF
    IF (data_map_level <= 1
     AND dm.service_resource_cd > 0
     AND rg_exists="Y"
     AND rg.parent_service_resource_cd=dm.service_resource_cd
     AND rg.child_service_resource_cd=ita.service_resource_cd)
     data_map_level = 2, data_map->qual[index_data_map].min_digits = dm.min_digits, data_map->qual[
     index_data_map].max_digits = dm.max_digits,
     data_map->qual[index_data_map].min_dec_places = dm.min_decimal_places
    ENDIF
    IF (data_map_level=0
     AND dm.service_resource_cd=0)
     data_map_level = 1, data_map->qual[index_data_map].min_digits = dm.min_digits, data_map->qual[
     index_data_map].max_digits = dm.max_digits,
     data_map->qual[index_data_map].min_dec_places = dm.min_decimal_places
    ENDIF
   ENDIF
  WITH nocounter, outerjoin(d_dm), outerjoin(d_rg)
 ;end select
 SELECT
  IF ((request->interp_id=0))
   PLAN (ita
    WHERE ita.interp_id > 0)
    JOIN (((dita
    WHERE dita.seq=1)
    JOIN (ic
    WHERE ic.interp_id=ita.interp_id)
    JOIN (dic
    WHERE dic.seq=1)
    JOIN (ir
    WHERE ir.interp_id=ita.interp_id
     AND ir.interp_detail_id=ic.interp_detail_id
     AND ir.included_assay_cd=ic.included_assay_cd)
    JOIN (dir
    WHERE dir.seq=1)
    JOIN (rh
    WHERE rh.interp_id=ita.interp_id
     AND rh.interp_detail_id=ir.interp_detail_id
     AND rh.interp_range_id=ir.interp_range_id
     AND rh.included_assay_cd=ir.included_assay_cd)
    JOIN (nm
    WHERE nm.nomenclature_id=rh.nomenclature_id)
    ) ORJOIN ((dita2
    WHERE dita2.seq=1)
    JOIN (ires
    WHERE ires.interp_id=ita.interp_id
     AND ires.active_ind=1)
    JOIN (dires
    WHERE dires.seq=1)
    JOIN (d15
    WHERE d15.seq=1)
    JOIN (nmir
    WHERE nmir.nomenclature_id=ires.result_nomenclature_id)
    JOIN (d16
    WHERE d16.seq=1)
    JOIN (lt
    WHERE lt.long_text_id=ires.long_text_id
     AND lt.parent_entity_name="INTERP_RESULT")
    ))
  ELSE
   PLAN (ita
    WHERE (ita.interp_id=request->interp_id))
    JOIN (((dita
    WHERE dita.seq=1)
    JOIN (ic
    WHERE ic.interp_id=ita.interp_id)
    JOIN (dic
    WHERE dic.seq=1)
    JOIN (ir
    WHERE ir.interp_id=ita.interp_id
     AND ir.interp_detail_id=ic.interp_detail_id
     AND ir.included_assay_cd=ic.included_assay_cd)
    JOIN (dir
    WHERE dir.seq=1)
    JOIN (rh
    WHERE rh.interp_id=ita.interp_id
     AND rh.interp_detail_id=ir.interp_detail_id
     AND rh.interp_range_id=ir.interp_range_id
     AND rh.included_assay_cd=ir.included_assay_cd)
    JOIN (d15
    WHERE d15.seq=1)
    JOIN (nm
    WHERE nm.nomenclature_id=rh.nomenclature_id)
    ) ORJOIN ((dita2
    WHERE dita2.seq=1)
    JOIN (ires
    WHERE ires.interp_id=ita.interp_id
     AND ires.active_ind=1)
    JOIN (dires
    WHERE dires.seq=1)
    JOIN (nmir
    WHERE nmir.nomenclature_id=ires.result_nomenclature_id)
    JOIN (d16
    WHERE d16.seq=1)
    JOIN (lt
    WHERE lt.long_text_id=ires.long_text_id
     AND lt.parent_entity_name="INTERP_RESULT")
    ))
  ENDIF
  INTO cpm_cfn_info->file_name_logical
  result_disp = substring(1,10,uar_get_code_display(ires.result_cd)), interp_task_disp = substring(1,
   10,uar_get_code_display(ita.task_assay_cd)), interp_type_disp = substring(1,15,
   uar_get_code_display(ita.interp_type_cd)),
  interp_option_disp = substring(1,15,uar_get_code_display(ita.interp_option_cd)),
  service_resource_disp = substring(1,15,uar_get_code_display(ita.service_resource_cd)),
  order_catalog_disp = substring(1,15,uar_get_code_display(ita.order_cat_cd)),
  phase_disp = substring(1,15,uar_get_code_display(ita.phase_cd)), included_assay_disp = substring(1,
   10,uar_get_code_display(ic.included_assay_cd)), comp_time_units_disp = substring(1,10,
   uar_get_code_display(ic.time_window_units_cd)),
  age_from_units_disp = substring(1,10,uar_get_code_display(ir.age_from_units_cd)), age_to_units_disp
   = substring(1,10,uar_get_code_display(ir.age_to_units_cd)), species_disp = substring(1,10,
   uar_get_code_display(ir.species_cd)),
  gender_disp = substring(1,8,uar_get_code_display(ir.gender_cd)), race_disp = substring(1,15,
   uar_get_code_display(ir.race_cd)), result_hash_disp = substring(1,15,uar_get_code_display(rh
    .result_cd)),
  comp_twu_mean = substring(1,8,uar_get_code_meaning(ic.time_window_units_cd)), comp_ir_age_from_mean
   = substring(1,8,uar_get_code_meaning(ir.age_from_units_cd)), comp_ir_age_to_mean = substring(1,8,
   uar_get_code_meaning(ir.age_to_units_cd)),
  hold_long_text_display = substring(1,4000,lt.long_text), ic_unique = build(ic.sequence,"_",ic
   .interp_detail_id), ita.interp_id,
  ic.interp_detail_id, ic.sequence, ir.interp_range_id,
  rh.result_hash_id, ires.interp_result_id
  FROM interp_task_assay ita,
   dummyt dita,
   interp_component ic,
   dummyt dic,
   interp_range ir,
   dummyt dir,
   result_hash rh,
   nomenclature nm,
   dummyt dita2,
   interp_result ires,
   dummyt dires,
   dummyt d15,
   nomenclature nmir,
   dummyt d16,
   long_text_reference lt
  ORDER BY ita.interp_id, ic_unique, ir.interp_range_id,
   rh.result_hash_id, ires.interp_result_id
  HEAD REPORT
   hold10 = fillstring(10," "), hold15 = fillstring(15," "), hold18 = fillstring(18," "),
   hold20 = fillstring(20," "), hold25 = fillstring(25," "), print_headers = "Y",
   print_cross_task_headers = "Y", print_cross_headers = "Y", hold = "",
   hold40 = fillstring(40," "), hold100 = fillstring(100," "), hold112 = fillstring(112," "),
   textcnt = 0000000000, placehldr = 0000000000, line = fillstring(124,"-"),
   separator = fillstring(124,"="), select_ok_ind = 0, index2_data_map = 0
  HEAD PAGE
   row 2, col 1, captions->cerner_hlth_systems,
   CALL center(captions->interp_audit,1,125), col 107, captions->time,
   col 119, curtime"@TIMENOSECONDS;;M", row + 1,
   col 107, captions->as_of_date, col 119,
   curdate"@DATECONDENSED;;d"
  HEAD ita.interp_id
   IF (row > 53)
    BREAK
   ENDIF
   i_cnt += 1, c_cnt = 0, stat = alterlist(cross_rr->interps,i_cnt),
   cross_rr->interps[i_cnt].interp_id = ita.interp_id, row + 1, hold15 = substring(1,15,
    interp_task_disp),
   col 2, captions->interp_detail, hold15,
   hold15 = substring(1,15,order_catalog_disp), col 37, captions->order_procedure,
   hold15, hold20 = substring(1,20,service_resource_disp), col 74,
   captions->service_resource, hold20, row + 1,
   hold15 = substring(1,15,interp_type_disp), col 4, captions->interp_type,
   hold15
   IF (ita.interp_option_cd > 0)
    hold15 = substring(1,15,interp_option_disp)
   ELSE
    hold15 = substring(1,15,"N/A")
   ENDIF
   col 37, captions->text_option, hold15
   IF (ita.phase_cd > 0)
    hold15 = substring(1,15,phase_disp)
   ELSE
    hold15 = substring(1,15,"N/A")
   ENDIF
   col 74, captions->phase_group, hold15
   IF (ita.generate_interp_flag=1)
    col 107, captions->system, captions->generated
   ELSE
    col 107, captions->system, captions->validated
   ENDIF
   print_headers = "Y"
  HEAD ic_unique
   IF (row > 53)
    BREAK
   ENDIF
   row + 2, hold20 = included_assay_disp, col 6,
   captions->assay, hold20
   IF (ic.active_ind=1)
    col 37, captions->active, captions->yes
   ELSE
    col 37, captions->active, captions->no
   ENDIF
   row + 1
   IF (row > 53)
    BREAK
   ENDIF
   IF (ic.cross_drawn_dt_tm_ind=1)
    col 6, captions->cross_draws, captions->yes
   ELSE
    col 6, captions->cross_draws, captions->no
   ENDIF
   IF (ic.cross_drawn_dt_tm_ind=1)
    hold15 = comp_time_units_disp
    IF (comp_twu_mean="HSECONDS")
     hold18 = concat(trim(cnvtstring((ic.time_window_minutes * 6000)))," ",trim(hold15))
    ELSEIF (comp_twu_mean="SECONDS")
     hold18 = concat(trim(cnvtstring((ic.time_window_minutes * 60)))," ",trim(hold15))
    ELSEIF (comp_twu_mean="MINUTES")
     hold18 = concat(trim(cnvtstring(ic.time_window_minutes))," ",trim(hold15))
    ELSEIF (comp_twu_mean="HOURS")
     hold18 = concat(trim(cnvtstring((ic.time_window_minutes/ 60)))," ",trim(hold15))
    ELSEIF (comp_twu_mean="DAYS")
     hold18 = concat(trim(cnvtstring((ic.time_window_minutes/ 1440)))," ",trim(hold15))
    ELSEIF (comp_twu_mean="WEEKS")
     hold18 = concat(trim(cnvtstring((ic.time_window_minutes/ 10080)))," ",trim(hold15))
    ELSEIF (comp_twu_mean="MONTHS")
     hold18 = concat(trim(cnvtstring((ic.time_window_minutes/ 43200)))," ",trim(hold15))
    ELSEIF (comp_twu_mean="YEARS")
     hold18 = concat(trim(cnvtstring((ic.time_window_minutes/ 525600)))," ",trim(hold15))
    ELSE
     hold18 = concat(trim(cnvtstring(ic.time_window_minutes))," ",trim(hold15))
    ENDIF
    col 26, captions->time_window, hold18
   ELSE
    col 26, captions->time_window_na
   ENDIF
   IF (ic.result_req_flag=1)
    col 62, captions->results_required, captions->yes
   ELSE
    col 62, captions->results_required, captions->no
   ENDIF
   IF (ic.verified_flag=0)
    col 95, captions->result_status, captions->performed
   ELSE
    col 95, captions->result_status, captions->verified
   ENDIF
  HEAD ir.interp_range_id
   IF (row > 53)
    BREAK
   ENDIF
   row + 1
   IF (row > 53)
    BREAK
   ENDIF
   col 8, captions->range_info
   IF (ir.species_cd=0)
    hold15 = captions->all
   ELSE
    hold15 = species_disp
   ENDIF
   col 30, captions->species, hold15
   IF (ir.gender_cd=0)
    hold15 = captions->all
   ELSE
    hold15 = gender_disp
   ENDIF
   col 72, captions->gender, hold15
   IF (ir.active_ind=1)
    col 102, captions->active, captions->yes
   ELSE
    col 102, captions->active, captions->no
   ENDIF
   row + 1
   IF (row > 53)
    BREAK
   ENDIF
   IF (ir.race_cd=0)
    hold15 = captions->all
   ELSE
    hold15 = race_disp
   ENDIF
   col 33, captions->race, hold15,
   col 67, captions->unknown_age
   IF (ir.unknown_age_ind=1)
    col 81, captions->yes
   ELSE
    col 81, captions->no
   ENDIF
   row + 1, hold15 = trim(substring(1,10,age_from_units_disp))
   IF (comp_ir_age_from_mean="HSECONDS")
    hold20 = concat(trim(cnvtstring((ir.age_from_minutes * 6000)))," ",trim(hold15))
   ELSEIF (comp_ir_age_from_mean="SECONDS")
    hold20 = concat(trim(cnvtstring((ir.age_from_minutes * 60)))," ",trim(hold15))
   ELSEIF (comp_ir_age_from_mean="MINUTES")
    hold20 = concat(trim(cnvtstring(ir.age_from_minutes))," ",trim(hold15))
   ELSEIF (comp_ir_age_from_mean="HOURS")
    hold20 = concat(trim(cnvtstring((ir.age_from_minutes/ 60)))," ",trim(hold15))
   ELSEIF (comp_ir_age_from_mean="DAYS")
    hold20 = concat(trim(cnvtstring((ir.age_from_minutes/ 1440)))," ",trim(hold15))
   ELSEIF (comp_ir_age_from_mean="WEEKS")
    hold20 = concat(trim(cnvtstring((ir.age_from_minutes/ 10080)))," ",trim(hold15))
   ELSEIF (comp_ir_age_from_mean="MONTHS")
    hold20 = concat(trim(cnvtstring((ir.age_from_minutes/ 43200)))," ",trim(hold15))
   ELSEIF (comp_ir_age_from_mean="YEARS")
    hold20 = concat(trim(cnvtstring((ir.age_from_minutes/ 525600)))," ",trim(hold15))
   ELSE
    hold20 = concat(trim(cnvtstring(ir.age_from_minutes))," ",trim(hold15))
   ENDIF
   col 65, captions->from_age, hold20,
   hold15 = trim(substring(1,10,age_to_units_disp))
   IF (comp_ir_age_to_mean="HSECONDS")
    hold20 = concat(trim(cnvtstring((ir.age_to_minutes * 6000)))," ",trim(hold15))
   ELSEIF (comp_ir_age_to_mean="SECONDS")
    hold20 = concat(trim(cnvtstring((ir.age_to_minutes * 60)))," ",trim(hold15))
   ELSEIF (comp_ir_age_to_mean="MINUTES")
    hold20 = concat(trim(cnvtstring(ir.age_to_minutes))," ",trim(hold15))
   ELSEIF (comp_ir_age_to_mean="HOURS")
    hold20 = concat(trim(cnvtstring((ir.age_to_minutes/ 60)))," ",trim(hold15))
   ELSEIF (comp_ir_age_to_mean="DAYS")
    hold20 = concat(trim(cnvtstring((ir.age_to_minutes/ 1440)))," ",trim(hold15))
   ELSEIF (comp_ir_age_to_mean="WEEKS")
    hold20 = concat(trim(cnvtstring((ir.age_to_minutes/ 10080)))," ",trim(hold15))
   ELSEIF (comp_ir_age_to_mean="MONTHS")
    hold20 = concat(trim(cnvtstring((ir.age_to_minutes/ 43200)))," ",trim(hold15))
   ELSEIF (comp_ir_age_to_mean="YEARS")
    hold20 = concat(trim(cnvtstring((ir.age_to_minutes/ 525600)))," ",trim(hold15))
   ELSE
    hold20 = concat(trim(cnvtstring(ir.age_to_minutes))," ",trim(hold15))
   ENDIF
   col 97, captions->to_age, hold20,
   row + 1
   IF (row > 52)
    BREAK
   ENDIF
   col 8, captions->from_result, col 21,
   captions->to_result, col 33, captions->result_hash,
   col 50, captions->result, col 74,
   captions->rpt_active, row + 1, col 8,
   "-----------", col 21, "----------",
   col 33, "---------------", col 50,
   "----------------------", col 74, "------"
  HEAD rh.result_hash_id
   row + 1
   IF (row > 53)
    BREAK
   ENDIF
   IF (rh.result_cd=0
    AND rh.nomenclature_id=0)
    IF (rh.result_hash_id > 0)
     index2_data_map += 1
     IF ((rh.result_hash_id=data_map->qual[index2_data_map].result_hash_id))
      arg_min_digits = data_map->qual[index2_data_map].min_digits, arg_max_digits = data_map->qual[
      index2_data_map].max_digits, arg_min_dec_places = data_map->qual[index2_data_map].
      min_dec_places
     ELSE
      arg_min_digits = min_digits_default, arg_max_digits = max_digits_default, arg_min_dec_places =
      min_dec_places_default
     ENDIF
     hold10 = uar_fmt_result(arg_min_digits,arg_max_digits,arg_min_dec_places,
      no_greater_less_than_applied,rh.from_result_range), col 8, hold10"##########",
     hold10 = uar_fmt_result(arg_min_digits,arg_max_digits,arg_min_dec_places,
      no_greater_less_than_applied,rh.to_result_range), col 21, hold10"##########"
    ELSE
     hold10 = trim(cnvtstring(rh.from_result_range)), col 8, hold10,
     hold10 = trim(cnvtstring(rh.to_result_range)), col 21, hold10
    ENDIF
   ENDIF
   col 33, rh.result_hash"###############"
   IF (((null(rh.result_cd)=1) OR (rh.result_cd=0)) )
    hold40 = trim(substring(1,32,nm.short_string)), col 50, hold40
   ELSE
    hold40 = trim(substring(1,32,result_hash_disp)), col 50, hold40
   ENDIF
   IF (rh.active_ind=1)
    col 74, captions->yes
   ELSE
    col 74, captions->no
   ENDIF
   IF (row > 53)
    BREAK
   ENDIF
  HEAD ires.interp_result_id
   IF (ires.interp_result_id > 0)
    IF (print_headers="Y")
     print_headers = "N", row + 2
     IF (row > 53)
      BREAK
     ENDIF
     col 8, captions->interp_patterns, col 110,
     captions->result, row + 1, col 8,
     pattern_line, col 110, "---------------"
    ENDIF
    IF (ires.result_cd=0)
     hold15 = trim(substring(1,15,nmir.short_string))
    ELSE
     hold15 = trim(substring(1,15,result_disp))
    ENDIF
    pattern = ires.hash_pattern, pattern_len = cnvtint(size(trim(pattern))), pos = 0
    WHILE ((pos < (pattern_len+ 1)))
     pos += 1,
     IF (pos=1)
      IF (substring(pos,1,pattern)="$")
       store_pattern->new = "No Result"
      ELSE
       IF (substring(pos,1,pattern)="@")
        store_pattern->new = "Any Result"
       ELSE
        store_pattern->new = substring(pos,1,pattern)
       ENDIF
      ENDIF
     ELSE
      store_pattern->hold = store_pattern->new
      IF (substring(pos,1,pattern)="$")
       store_pattern->new = concat(store_pattern->hold,"No Result")
      ELSE
       IF (substring(pos,1,pattern)="@")
        store_pattern->new = concat(store_pattern->hold,"Any Result")
       ELSE
        store_pattern->new = concat(store_pattern->hold,substring(pos,1,pattern))
       ENDIF
      ENDIF
     ENDIF
    ENDWHILE
    IF (size(trim(store_pattern->new)) > 100)
     hold100 = substring(1,100,store_pattern->new), row + 1
     IF (row > 53)
      BREAK
     ENDIF
     col 8, hold100
     IF (((size(trim(store_pattern->new)) - 100) > 200))
      hold100 = substring(101,100,store_pattern->new), row + 1
      IF (row > 53)
       BREAK
      ENDIF
      col 8, hold100, hold100 = trim(substring(201,55,store_pattern->new)),
      row + 1
      IF (row > 53)
       BREAK
      ENDIF
      col 8, hold100, col 110,
      hold15
     ELSE
      hold100 = trim(substring(101,100,store_pattern->new)), row + 1
      IF (row > 53)
       BREAK
      ENDIF
      col 8, hold100, col 110,
      hold15
     ENDIF
    ELSE
     hold100 = trim(substring(1,100,store_pattern->new)), row + 1
     IF (row > 53)
      BREAK
     ENDIF
     col 8, hold100, col 110,
     hold15
    ENDIF
    IF (ires.long_text_id > 0)
     row + 1
     IF (row > 53)
      BREAK
     ENDIF
     col 8, captions->result_text, row + 1
     IF (row > 53)
      BREAK
     ENDIF
     CALL rtf_to_text(hold_long_text_display,1,100)
     FOR (z = 1 TO size(tmptext->qual,5))
       col 12, tmptext->qual[z].text, row + 1
       IF (row > 53)
        BREAK
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF (row > 53)
    BREAK
   ENDIF
   print_reason_headers = "Y"
  FOOT PAGE
   row 57, col 1, line,
   row + 1, col 1, captions->report_id,
   col 58, captions->page_no, col 64,
   curpage"#####", col 100, captions->printed,
   col 110, curdate"@DATECONDENSED;;d", col 120,
   curtime"@TIMENOSECONDS;;M"
  FOOT  ita.interp_id
   row + 1, col 1, separator,
   row + 1
  FOOT REPORT
   row 60, col 51, captions->end_of_report,
   select_ok_ind = 1
  WITH nullreport, compress, nolandscape,
   outerjoin = d15, outerjoin = d16, outerjoin = dita,
   outerjoin = dic, outerjoin = dir, outerjoin = dita2,
   outerjoin = dires, nocounter, maxrow = 61
 ;end select
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
