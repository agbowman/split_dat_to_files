CREATE PROGRAM cp_get_dup_events:dba
 RECORD reply(
   1 qual[1]
     2 line = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE dta_chart_format_id = f8 WITH constant(request->chart_format_id)
 DECLARE dta_chart_section_id = f8 WITH constant(0.0)
 DECLARE dta_get_ap_history = i2 WITH constant(0)
 DECLARE dta_check_ap_flag = i2 WITH constant(0)
 RECORD dta_specific_event_cds(
   1 qual[*]
     2 event_cd = f8
 )
 FREE RECORD activity_rec
 RECORD activity_rec(
   1 activity[*]
     2 chart_section_id = f8
     2 section_seq = i4
     2 section_type_flag = i2
     2 chart_group_id = f8
     2 group_seq = i4
     2 zone = i4
     2 flex_type_flag = i2
     2 doc_type_flag = i2
     2 procedure_seq = i4
     2 procedure_type_flag = i2
     2 event_set_name = vc
     2 dcp_forms_ref_id = f8
     2 catalog_cd = f8
     2 event_cds[*]
       3 event_cd = f8
       3 task_assay_cd = f8
       3 suppressed_ind = i2
   1 parent_event_ids[*]
     2 parent_event_id = f8
   1 inerr_events[*]
     2 event_id = f8
 )
 DECLARE parser_clause = vc WITH private
 DECLARE hit_bbxm_section = i2 WITH noconstant(0)
 DECLARE added_ec_for_es_bbxm_section = i2 WITH noconstant(0)
 DECLARE bbproduct = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"BBPRODUCT")), protect
 IF (dta_chart_section_id > 0)
  SET parser_clause = build("cfs.chart_format_id = ",dta_chart_format_id,
   " and cfs.chart_section_id = ",dta_chart_section_id)
 ELSE
  SET parser_clause = build("cfs.chart_format_id = ",dta_chart_format_id)
 ENDIF
 IF (dta_get_ap_history=0)
  IF (size(dta_specific_event_cds->qual,5)=0)
   SELECT DISTINCT INTO "nl:"
    check = decode(esc.seq,"esc",cver.seq,"orc")
    FROM chart_form_sects cfs,
     chart_section cs,
     chart_group cg,
     chart_ap_format caf,
     chart_flex_format cff,
     chart_grp_evnt_set cges,
     v500_event_set_code esc,
     v500_event_set_explode ese,
     profile_task_r ptr,
     code_value_event_r cver,
     chart_grp_evnt_suppress cgess,
     chart_doc_format cdf,
     dummyt d1,
     dummyt d2
    PLAN (cfs
     WHERE parser(parser_clause))
     JOIN (cs
     WHERE cs.chart_section_id=cfs.chart_section_id)
     JOIN (cg
     WHERE cg.chart_section_id=cs.chart_section_id)
     JOIN (caf
     WHERE caf.chart_group_id=outerjoin(cg.chart_group_id))
     JOIN (cff
     WHERE cff.chart_group_id=outerjoin(cg.chart_group_id))
     JOIN (cges
     WHERE cges.chart_group_id=cg.chart_group_id)
     JOIN (cdf
     WHERE cdf.chart_group_id=outerjoin(cg.chart_group_id))
     JOIN (d1)
     JOIN (((esc
     WHERE cges.procedure_type_flag=0
      AND esc.event_set_name=cges.event_set_name)
     JOIN (ese
     WHERE ese.event_set_cd=esc.event_set_cd)
     ) ORJOIN ((d2)
     JOIN (ptr
     WHERE cges.procedure_type_flag=1
      AND ptr.catalog_cd=cges.order_catalog_cd
      AND ptr.catalog_cd > 0)
     JOIN (cgess
     WHERE cgess.chart_group_id=outerjoin(cges.chart_group_id)
      AND cgess.order_catalog_cd=outerjoin(ptr.catalog_cd)
      AND cgess.task_assay_cd=outerjoin(ptr.task_assay_cd))
     JOIN (cver
     WHERE ((cver.parent_cd=ptr.task_assay_cd) OR (cver.parent_cd=ptr.catalog_cd))
      AND cver.parent_cd > 0)
     ))
    ORDER BY cfs.cs_sequence_num, cg.cg_sequence, cges.zone,
     cges.event_set_seq, ese.event_cd, cver.event_cd
    HEAD REPORT
     activitycnt = 0, codecnt = 0
    HEAD cfs.cs_sequence_num
     IF (cs.section_type_flag=6
      AND cff.flex_type=0)
      hit_bbxm_section = 1, added_ec_for_es_bbxm_section = 0
     ENDIF
    HEAD cg.cg_sequence
     do_nothing = 0
    HEAD cges.zone
     do_nothing = 0
    HEAD cges.event_set_seq
     IF (((dta_check_ap_flag=1
      AND caf.ap_history_flag=0) OR (dta_check_ap_flag=0)) )
      activitycnt = (activitycnt+ 1)
      IF (mod(activitycnt,10)=1)
       stat = alterlist(activity_rec->activity[activitycnt],(activitycnt+ 9))
      ENDIF
      activity_rec->activity[activitycnt].chart_section_id = cfs.chart_section_id, activity_rec->
      activity[activitycnt].section_seq = cfs.cs_sequence_num, activity_rec->activity[activitycnt].
      section_type_flag = cs.section_type_flag,
      activity_rec->activity[activitycnt].chart_group_id = cg.chart_group_id, activity_rec->activity[
      activitycnt].group_seq = cg.cg_sequence, activity_rec->activity[activitycnt].zone = cges.zone,
      activity_rec->activity[activitycnt].procedure_seq = cges.event_set_seq, activity_rec->activity[
      activitycnt].procedure_type_flag = cges.procedure_type_flag, activity_rec->activity[activitycnt
      ].event_set_name = cges.event_set_name,
      activity_rec->activity[activitycnt].catalog_cd = cges.order_catalog_cd, activity_rec->activity[
      activitycnt].flex_type_flag = cff.flex_type, activity_rec->activity[activitycnt].doc_type_flag
       = cdf.doc_type_flag
     ENDIF
    DETAIL
     IF (((dta_check_ap_flag=1
      AND caf.ap_history_flag=0) OR (dta_check_ap_flag=0)) )
      IF (cgess.task_assay_cd=0
       AND cgess.event_cd=0)
       codecnt = (codecnt+ 1)
       IF (mod(codecnt,10)=1)
        stat = alterlist(activity_rec->activity[activitycnt].event_cds,(codecnt+ 9))
       ENDIF
       IF (check="esc")
        IF (hit_bbxm_section=0)
         activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = ese.event_cd
        ELSE
         IF (added_ec_for_es_bbxm_section=0)
          activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = bbproduct,
          added_ec_for_es_bbxm_section = 1
         ENDIF
        ENDIF
       ELSE
        IF (hit_bbxm_section=0)
         activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = cver.event_cd
        ELSE
         activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = bbproduct
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    FOOT  cges.event_set_seq
     IF (((dta_check_ap_flag=1
      AND caf.ap_history_flag=0) OR (dta_check_ap_flag=0)) )
      stat = alterlist(activity_rec->activity[activitycnt].event_cds,codecnt), codecnt = 0
     ENDIF
    FOOT  cges.zone
     do_nothing = 0
    FOOT  cg.cg_sequence
     do_nothing = 0
    FOOT  cfs.cs_sequence_num
     hit_bbxm_section = 0
    FOOT REPORT
     stat = alterlist(activity_rec->activity,activitycnt)
    WITH nocounter
   ;end select
  ELSE
   SELECT DISTINCT INTO "nl:"
    FROM chart_form_sects cfs,
     chart_section cs,
     chart_group cg,
     chart_grp_evnt_set cges,
     v500_event_set_code esc,
     v500_event_set_explode ese,
     chart_doc_format cdf,
     (dummyt d  WITH seq = value(size(dta_specific_event_cds->qual,5)))
    PLAN (d)
     JOIN (ese
     WHERE (ese.event_cd=dta_specific_event_cds->qual[d.seq].event_cd))
     JOIN (esc
     WHERE esc.event_set_cd=ese.event_set_cd)
     JOIN (cges
     WHERE cges.event_set_name=esc.event_set_name
      AND cges.procedure_type_flag=0)
     JOIN (cg
     WHERE cg.chart_group_id=cges.chart_group_id)
     JOIN (cdf
     WHERE cdf.chart_group_id=cges.chart_group_id)
     JOIN (cfs
     WHERE parser(parser_clause)
      AND cfs.chart_section_id=cg.chart_section_id)
     JOIN (cs
     WHERE cs.chart_section_id=cfs.chart_section_id)
    ORDER BY cfs.cs_sequence_num, cg.cg_sequence, cges.zone,
     cges.event_set_seq, ese.event_cd
    HEAD REPORT
     activitycnt = 0, codecnt = 0
    HEAD cfs.cs_sequence_num
     do_nothing = 0
    HEAD cg.cg_sequence
     do_nothing = 0
    HEAD cges.zone
     do_nothing = 0
    HEAD cges.event_set_seq
     activitycnt = (activitycnt+ 1)
     IF (mod(activitycnt,5)=1)
      stat = alterlist(activity_rec->activity[activitycnt],(activitycnt+ 4))
     ENDIF
     activity_rec->activity[activitycnt].chart_section_id = cfs.chart_section_id, activity_rec->
     activity[activitycnt].section_seq = cfs.cs_sequence_num, activity_rec->activity[activitycnt].
     section_type_flag = cs.section_type_flag,
     activity_rec->activity[activitycnt].chart_group_id = cg.chart_group_id, activity_rec->activity[
     activitycnt].group_seq = cg.cg_sequence, activity_rec->activity[activitycnt].zone = cges.zone,
     activity_rec->activity[activitycnt].procedure_seq = cges.event_set_seq, activity_rec->activity[
     activitycnt].procedure_type_flag = cges.procedure_type_flag, activity_rec->activity[activitycnt]
     .event_set_name = cges.event_set_name,
     activity_rec->activity[activitycnt].catalog_cd = cges.order_catalog_cd, activity_rec->activity[
     activitycnt].flex_type_flag = 0, activity_rec->activity[activitycnt].doc_type_flag = cdf
     .doc_type_flag
    DETAIL
     codecnt = (codecnt+ 1)
     IF (mod(codecnt,5)=1)
      stat = alterlist(activity_rec->activity[activitycnt].event_cds,(codecnt+ 4))
     ENDIF
     activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = ese.event_cd
    FOOT  cges.event_set_seq
     stat = alterlist(activity_rec->activity[activitycnt].event_cds,codecnt), codecnt = 0
    FOOT  cges.zone
     do_nothing = 0
    FOOT  cg.cg_sequence
     do_nothing = 0
    FOOT  cfs.cs_sequence_num
     do_nothing = 0
    FOOT REPORT
     stat = alterlist(activity_rec->activity,activitycnt)
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SELECT DISTINCT INTO "nl:"
   check = decode(esc.seq,"esc",ptr.seq,"orc")
   FROM chart_format cf,
    chart_section cs,
    chart_form_sects cfs,
    chart_group cg,
    chart_ap_format caf,
    chart_grp_evnt_set cges,
    v500_event_set_code esc,
    v500_event_set_explode ese,
    profile_task_r ptr,
    code_value_event_r cver,
    dummyt d1,
    dummyt d2
   PLAN (cf
    WHERE cf.chart_format_id=dta_chart_format_id)
    JOIN (cs
    WHERE cs.section_type_flag=18)
    JOIN (cfs
    WHERE cfs.chart_format_id=cf.chart_format_id
     AND cfs.chart_section_id=cs.chart_section_id)
    JOIN (cg
    WHERE cg.chart_section_id=cfs.chart_section_id)
    JOIN (caf
    WHERE caf.chart_group_id=cg.chart_group_id
     AND caf.ap_history_flag=1)
    JOIN (cges
    WHERE cges.chart_group_id=cg.chart_group_id)
    JOIN (d1)
    JOIN (((esc
    WHERE cges.procedure_type_flag=0
     AND esc.event_set_name=cges.event_set_name)
    JOIN (ese
    WHERE ese.event_set_cd=esc.event_set_cd)
    ) ORJOIN ((d2)
    JOIN (ptr
    WHERE cges.procedure_type_flag=1
     AND ptr.catalog_cd=cges.order_catalog_cd
     AND ptr.catalog_cd > 0)
    JOIN (cver
    WHERE ((cver.parent_cd=ptr.task_assay_cd) OR (cver.parent_cd=ptr.catalog_cd))
     AND cver.parent_cd > 0)
    ))
   ORDER BY cfs.cs_sequence_num, cg.cg_sequence, cges.zone,
    cges.event_set_seq, ese.event_cd, cver.event_cd
   HEAD REPORT
    activitycnt = 0, codecnt = 0
   HEAD cfs.cs_sequence_num
    do_nothing = 0
   HEAD cg.cg_sequence
    do_nothing = 0
   HEAD cges.zone
    do_nothing = 0
   HEAD cges.event_set_seq
    activitycnt = (activitycnt+ 1)
    IF (mod(activitycnt,10)=1)
     stat = alterlist(activity_rec->activity[activitycnt],(activitycnt+ 9))
    ENDIF
    activity_rec->activity[activitycnt].chart_section_id = cfs.chart_section_id, activity_rec->
    activity[activitycnt].section_seq = cfs.cs_sequence_num, activity_rec->activity[activitycnt].
    section_type_flag = 18,
    activity_rec->activity[activitycnt].chart_group_id = cg.chart_group_id, activity_rec->activity[
    activitycnt].group_seq = cg.cg_sequence, activity_rec->activity[activitycnt].zone = cges.zone,
    activity_rec->activity[activitycnt].procedure_seq = cges.event_set_seq, activity_rec->activity[
    activitycnt].procedure_type_flag = cges.procedure_type_flag, activity_rec->activity[activitycnt].
    event_set_name = cges.event_set_name,
    activity_rec->activity[activitycnt].catalog_cd = cges.order_catalog_cd
   DETAIL
    codecnt = (codecnt+ 1)
    IF (mod(codecnt,10)=1)
     stat = alterlist(activity_rec->activity[activitycnt].event_cds,(codecnt+ 9))
    ENDIF
    IF (check="esc")
     activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = ese.event_cd
    ELSE
     activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = cver.event_cd
    ENDIF
   FOOT  cges.event_set_seq
    stat = alterlist(activity_rec->activity[activitycnt].event_cds,codecnt), codecnt = 0
   FOOT  cges.zone
    do_nothing = 0
   FOOT  cg.cg_sequence
    do_nothing = 0
   FOOT  cfs.cs_sequence_num
    do_nothing = 0
   FOOT REPORT
    stat = alterlist(activity_rec->activity,activitycnt)
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 section_id = vc
     2 section_desc = vc
     2 sec_seq = i2
     2 group_id = vc
     2 grp_seq = i2
     2 procedure_name = vc
 )
 DECLARE outfile = c12 WITH constant(build("dup_evnt",format(curdate,"mmdd;;d")))
 DECLARE event_nbr = i4
 DECLARE event_cd_str = c15
 DECLARE format_desc = c64
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
 DECLARE h = i4
 DECLARE i18nhandle = i4 WITH noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE report_str = vc WITH constant(uar_i18ngetmessage(i18nhandle,"REPORT",
   "Duplicated Event Codes Report"))
 DECLARE page_str = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PAGE","Page:"))
 DECLARE print_dttm_str = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PRINT_DTTM",
   "Print Date/Time:"))
 DECLARE chart_format_str = vc WITH constant(uar_i18ngetmessage(i18nhandle,"CHART_FORMAT",
   "Chart Format:"))
 DECLARE evnt_cd_str = vc WITH constant(uar_i18ngetmessage(i18nhandle,"EVENT_CD","Event CD:"))
 DECLARE section_seq_str = vc WITH constant(uar_i18ngetmessage(i18nhandle,"SECTION_SEQ","Section Seq"
   ))
 DECLARE section_id_str = vc WITH constant(uar_i18ngetmessage(i18nhandle,"SECTION_ID","Section ID"))
 DECLARE group_seq_str = vc WITH constant(uar_i18ngetmessage(i18nhandle,"GROUP_SEQ","Group Seq"))
 DECLARE group_id_str = vc WITH constant(uar_i18ngetmessage(i18nhandle,"GROUP_ID","Group ID"))
 DECLARE proc_name_str = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PROC_NAME","Procedure Name")
  )
 SELECT INTO "nl:"
  FROM chart_format cf
  WHERE (cf.chart_format_id=request->chart_format_id)
  DETAIL
   format_desc = cf.chart_format_desc
  WITH nocounter
 ;end select
 SELECT INTO value(outfile)
  section_seq = activity_rec->activity[d1.seq].section_seq, group_seq = activity_rec->activity[d1.seq
  ].group_seq, event_cd = activity_rec->activity[d1.seq].event_cds[d2.seq].event_cd,
  procedure_name =
  IF ((activity_rec->activity[d1.seq].procedure_type_flag=0)) activity_rec->activity[d1.seq].
   event_set_name
  ELSE uar_get_code_display(activity_rec->activity[d1.seq].catalog_cd)
  ENDIF
  FROM chart_section cs,
   chart_group cg,
   (dummyt d1  WITH seq = value(size(activity_rec->activity,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(activity_rec->activity[d1.seq].event_cds,5)))
   JOIN (cs
   WHERE (cs.chart_section_id=activity_rec->activity[d1.seq].chart_section_id))
   JOIN (cg
   WHERE (cg.chart_group_id=activity_rec->activity[d1.seq].chart_group_id))
   JOIN (d2)
  ORDER BY event_cd
  HEAD REPORT
   line1 = fillstring(100,"*"), line2 = fillstring(100,"~"), line3 = fillstring(50,"-"),
   event_nbr = 0, event_cd_nbr = 0, print_dt_tm = cnvtdatetime(curdate,curtime3),
   row 1,
   CALL center(report_str,0,100), col 80,
   page_str, col + 2, curpage"####",
   row + 2, col 1, print_dttm_str,
   col + 2, print_dt_tm";;q", row + 2,
   line1, row + 1
  HEAD PAGE
   IF (curpage > 1)
    row 1, col 80, page_str,
    col + 2, curpage"####", row + 1
   ENDIF
  HEAD event_cd
   event_cd_nbr = 0
  DETAIL
   event_cd_nbr = (event_cd_nbr+ 1)
   IF (mod(event_cd_nbr,10)=1)
    stat = alterlist(temp->qual,(event_cd_nbr+ 9))
   ENDIF
   temp->qual[event_cd_nbr].section_id = cnvtstring(cs.chart_section_id), temp->qual[event_cd_nbr].
   section_desc = cs.chart_section_desc, temp->qual[event_cd_nbr].sec_seq = section_seq,
   temp->qual[event_cd_nbr].group_id = cnvtstring(cg.chart_group_id), temp->qual[event_cd_nbr].
   grp_seq = group_seq, temp->qual[event_cd_nbr].procedure_name = procedure_name
  FOOT  event_cd
   stat = alterlist(temp->qual,event_cd_nbr)
   IF (event_cd_nbr > 1)
    format_id_str = cnvtstring(request->chart_format_id), event_cd_str = cnvtstring(event_cd),
    event_cd_desc = uar_get_code_description(event_cd),
    event_nbr = (event_nbr+ 1), row + 1
    IF (event_nbr=1)
     col 1, chart_format_str, col + 2,
     format_desc, col + 2, format_id_str,
     row + 1, line2, row + 1
    ENDIF
    col 1, evnt_cd_str, col + 2,
    event_cd_str, col + 2, event_cd_desc,
    row + 1, line3, row + 1,
    col 1, section_seq_str, col 15,
    section_id_str, col 30, group_seq_str,
    col 45, group_id_str, col 60,
    proc_name_str, row + 1
    FOR (count = 1 TO event_cd_nbr)
      col 1, temp->qual[count].sec_seq"###", col 15,
      temp->qual[count].section_id, col 30, temp->qual[count].grp_seq"###",
      col 45, temp->qual[count].group_id, col 60,
      temp->qual[count].procedure_name, row + 1
    ENDFOR
   ENDIF
  FOOT PAGE
   do_nothing = 0
  FOOT REPORT
   do_nothing = 0
  WITH compress, maxrow = 55, counter
 ;end select
 SET outfile1 = fillstring(150," ")
 SET outfile1 = build("ccluserdir:",outfile)
 SET outfile1 = concat(outfile1,".dat")
 FREE DEFINE rtl
 DEFINE rtl value(outfile1)
 SELECT INTO "nl:"
  r.line
  FROM rtlt r
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1), stat = alter(reply->qual,count), reply->qual[count].line = r.line
  WITH nocounter
 ;end select
 IF (event_nbr=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
