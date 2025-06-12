CREATE PROGRAM apscassformat2:dba
 SET service_resource_display = "N"
 SET worklist_nbr = "N"
 SET request_dt_tm_string = "N"
 SET priority_display = "N"
 SET case_specimen_tag_display = "Y"
 SET cassette_tag_display = "Y"
 SET cassette_sep_display = "Y"
 SET slide_tag_display = "N"
 SET slide_sep_display = "N"
 SET spec_blk_slide_tag_display = "N"
 SET spec_blk_tag_display = "Y"
 SET blk_slide_tag_display = "N"
 SET acc_site_pre_yy_nbr = "N"
 SET acc_site = "N"
 SET acc_pre = "N"
 SET acc_yy = "N"
 SET acc_yyyy = "N"
 SET acc_nbr = "N"
 SET responsible_pathologist = "N"
 SET responsible_resident = "N"
 SET requesting_physician = "N"
 SET case_received_dt_tm_string = "N"
 SET case_collect_dt_tm_string = "N"
 SET mrn_alias = "N"
 SET fin_nbr_alias = "N"
 SET birth_dt_tm_string = "N"
 SET sex = "N"
 SET admit_doctor = "N"
 SET bed = "N"
 SET building = "N"
 SET facility = "N"
 SET location = "N"
 SET nurse_unit = "N"
 SET room = "N"
 SET encounter_type = "N"
 SET specimen_display = "Y"
 SET received_fixative = "N"
 SET fixative_added = "N"
 SET fixative = "N"
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
   1 unknown = vc
 )
 SET captions->unknown = uar_i18ngetmessage(i18nhandle,"UNKNOWN","Unknown")
#script
 IF (validate(inventory_2dbarcode,"N")="Y")
  EXECUTE pcs_label_integration_util
 ENDIF
 DECLARE mrn_alias_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE encounter_alias_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE epr_admit_doc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE prsnl_name_type_cd = f8 WITH protect, noconstant(0.0)
 IF (((mrn_alias="Y") OR (fin_nbr_alias="Y")) )
  SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn_alias_type_cd)
  SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,encounter_alias_type_cd)
 ENDIF
 IF (admit_doctor="Y")
  SET stat = uar_get_meaning_by_codeset(333,"ADMITDOC",1,epr_admit_doc_cd)
 ENDIF
 SET stat = uar_get_meaning_by_codeset(213,"PRSNL",1,prsnl_name_type_cd)
 FOR (r = 1 TO size(data->resrc,5))
  IF (service_resource_display="Y")
   SET data->resrc[r].service_resource_disp = uar_get_code_display(data->resrc[r].service_resource_cd
    )
  ENDIF
  FOR (l = 1 TO size(data->resrc[r].label,5))
    IF (((mrn_alias="Y") OR (fin_nbr_alias="Y")) )
     SELECT INTO "nl:"
      alias_type = decode(pa.seq,"P",ea.seq,"E"," ")
      FROM org_alias_pool_reltn oa,
       (dummyt d1  WITH seq = 1),
       person_alias pa,
       (dummyt d2  WITH seq = 1),
       encntr_alias ea
      PLAN (oa
       WHERE (oa.organization_id=data->resrc[r].label[l].organization_id)
        AND ((oa.alias_entity_name="PERSON_ALIAS"
        AND oa.alias_entity_alias_type_cd=mrn_alias_type_cd) OR (oa.alias_entity_name="ENCNTR_ALIAS"
        AND oa.alias_entity_alias_type_cd=encounter_alias_type_cd))
        AND oa.active_ind=1
        AND oa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND ((oa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (oa.end_effective_dt_tm=
       null)) )
       JOIN (((d1
       WHERE d1.seq=1)
       JOIN (pa
       WHERE oa.alias_entity_name="PERSON_ALIAS"
        AND (pa.person_id=data->resrc[r].label[l].person_id)
        AND pa.alias_pool_cd=oa.alias_pool_cd
        AND pa.active_ind=1
        AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND ((pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (pa.end_effective_dt_tm=
       null)) )
       ) ORJOIN ((d2
       WHERE d2.seq=1)
       JOIN (ea
       WHERE oa.alias_entity_name="ENCNTR_ALIAS"
        AND (ea.encntr_id=data->resrc[r].label[l].encntr_id)
        AND ea.alias_pool_cd=oa.alias_pool_cd
        AND ea.active_ind=1
        AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND ((ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (ea.end_effective_dt_tm=
       null)) )
       ))
      DETAIL
       IF (textlen(trim(data->resrc[r].label[l].mrn_alias))=0)
        data->resrc[r].label[l].mrn_alias = captions->unknown
       ENDIF
       IF (alias_type="P")
        data->resrc[r].label[l].mrn_alias = pa.alias
       ELSEIF (alias_type="E")
        data->resrc[r].label[l].fin_nbr_alias = ea.alias
       ENDIF
      WITH nocounter, outerjoin = d1, outerjoin = d2
     ;end select
    ENDIF
    IF (admit_doctor="Y")
     SELECT INTO "nl:"
      FROM encntr_prsnl_reltn epr,
       prsnl p
      PLAN (epr
       WHERE (epr.encntr_id=data->resrc[r].label[l].encntr_id)
        AND epr.encntr_prsnl_r_cd=epr_admit_doc_cd
        AND epr.active_ind=1
        AND epr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND ((epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (epr.end_effective_dt_tm=
       null)) )
       JOIN (p
       WHERE p.person_id=epr.prsnl_person_id)
      DETAIL
       data->resrc[r].label[l].admit_doc_name = p.name_full_formatted, data->resrc[r].label[l].
       admit_doc_name_last = p.name_last
      WITH nocounter
     ;end select
    ENDIF
    IF (request_dt_tm_string="Y")
     SET data->resrc[r].label[l].request_dt_tm_string = format(cnvtdatetime(data->resrc[r].label[l].
       request_dt_tm),"@MEDIUMDATE")
    ENDIF
    IF (priority_display="Y")
     SET data->resrc[r].label[l].priority_disp = uar_get_code_display(data->resrc[r].label[l].
      priority_cd)
    ENDIF
    IF (((case_specimen_tag_display="Y") OR (validate(inventory_2dbarcode,"N")="Y")) )
     SELECT INTO "nl:"
      FROM ap_tag a
      WHERE (a.tag_id=data->resrc[r].label[l].case_specimen_tag_cd)
       AND (data->resrc[r].label[l].case_specimen_tag_cd > 0)
      DETAIL
       data->resrc[r].label[l].case_specimen_tag_disp = a.tag_disp, data->resrc[r].label[l].
       case_specimen_tag_seq = a.tag_sequence
      WITH nocounter
     ;end select
    ENDIF
    IF (((cassette_tag_display="Y") OR (validate(inventory_2dbarcode,"N")="Y")) )
     SELECT INTO "nl:"
      FROM ap_tag a
      PLAN (a
       WHERE (a.tag_id=data->resrc[r].label[l].cassette_tag_cd)
        AND (data->resrc[r].label[l].cassette_tag_cd > 0))
      DETAIL
       data->resrc[r].label[l].cassette_tag_disp = a.tag_disp, data->resrc[r].label[l].
       cassette_tag_seq = a.tag_sequence
      WITH nocounter
     ;end select
    ENDIF
    IF (cassette_sep_display="Y")
     SELECT INTO "nl:"
      FROM ap_prefix_tag_group_r aptgr
      WHERE (aptgr.prefix_id=data->resrc[r].label[l].prefix_cd)
       AND aptgr.tag_type_flag=2
       AND (data->resrc[r].label[l].cassette_tag_cd > 0)
      DETAIL
       data->resrc[r].label[l].cassette_sep_disp = aptgr.tag_separator
      WITH nocounter
     ;end select
    ENDIF
    IF (spec_blk_tag_display="Y")
     SET data->resrc[r].label[l].spec_blk_tag_disp = build(data->resrc[r].label[l].
      case_specimen_tag_disp,data->resrc[r].label[l].cassette_sep_disp,data->resrc[r].label[l].
      cassette_tag_disp)
    ENDIF
    IF (acc_site_pre_yy_nbr="Y")
     SET data->resrc[r].label[l].acc_site_pre_yy_nbr = build(substring(1,5,data->resrc[r].label[l].
       accession_nbr),"-",substring(6,2,data->resrc[r].label[l].accession_nbr),"-",substring(10,2,
       data->resrc[r].label[l].accession_nbr),
      "-",substring(12,7,data->resrc[r].label[l].accession_nbr))
    ENDIF
    IF (acc_site="Y")
     SET data->resrc[r].label[l].acc_site = substring(1,5,data->resrc[r].label[l].accession_nbr)
    ENDIF
    IF (acc_pre="Y")
     SET data->resrc[r].label[l].acc_pre = substring(6,2,data->resrc[r].label[l].accession_nbr)
    ENDIF
    IF (acc_yy="Y")
     SET data->resrc[r].label[l].acc_yy = substring(10,2,data->resrc[r].label[l].accession_nbr)
    ENDIF
    IF (acc_yyyy="Y")
     SET data->resrc[r].label[l].acc_yyyy = substring(8,4,data->resrc[r].label[l].accession_nbr)
    ENDIF
    IF (acc_nbr="Y")
     SET data->resrc[r].label[l].acc_nbr = substring(12,7,data->resrc[r].label[l].accession_nbr)
    ENDIF
    IF (responsible_pathologist="Y")
     SELECT INTO "nl:"
      FROM person_name p
      WHERE (p.person_id=data->resrc[r].label[l].responsible_pathologist_id)
       AND p.name_type_cd=prsnl_name_type_cd
       AND p.active_ind=1
       AND p.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND ((p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null
      ))
      DETAIL
       data->resrc[r].label[l].responsible_pathologist_name_full = p.name_full, data->resrc[r].label[
       l].responsible_pathologist_name_last = p.name_last, data->resrc[r].label[l].
       responsible_pathologist_initial = p.name_initials
      WITH nocounter
     ;end select
    ENDIF
    IF (responsible_resident="Y")
     SELECT INTO "nl:"
      FROM person_name p
      WHERE (p.person_id=data->resrc[r].label[l].responsible_resident_id)
       AND p.name_type_cd=prsnl_name_type_cd
       AND p.active_ind=1
       AND p.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND ((p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null
      ))
      DETAIL
       data->resrc[r].label[l].responsible_resident_name_full = p.name_full, data->resrc[r].label[l].
       responsible_resident_name_last = p.name_last, data->resrc[r].label[l].
       responsible_resident_initial = p.name_initials
      WITH nocounter
     ;end select
    ENDIF
    IF (((validate(responsible_physician,"N")="Y") OR (validate(requesting_physician,"N")="Y")) )
     SELECT INTO "nl:"
      FROM prsnl p
      WHERE (p.person_id=data->resrc[r].label[l].requesting_physician_id)
      DETAIL
       data->resrc[r].label[l].requesting_physician_name_full = p.name_full_formatted, data->resrc[r]
       .label[l].requesting_physician_name_last = p.name_last
      WITH nocounter
     ;end select
    ENDIF
    IF (case_received_dt_tm_string="Y")
     SET data->resrc[r].label[l].case_received_dt_tm_string = format(cnvtdatetime(data->resrc[r].
       label[l].case_received_dt_tm),"@MEDIUMDATE")
    ENDIF
    IF (case_collect_dt_tm_string="Y")
     SET data->resrc[r].label[l].case_collect_dt_tm_string = format(data->resrc[r].label[l].
      case_collect_dt_tm,"@MEDIUMDATE")
    ENDIF
    IF (birth_dt_tm_string="Y")
     SET data->resrc[r].label[l].birth_dt_tm_string = format(cnvtdatetime(data->resrc[r].label[l].
       birth_dt_tm),"@MEDIUMDATE")
    ENDIF
    IF (sex="Y")
     SET data->resrc[r].label[l].sex_disp = uar_get_code_display(data->resrc[r].label[l].sex_cd)
     SET data->resrc[r].label[l].sex_desc = uar_get_code_description(data->resrc[r].label[l].sex_cd)
    ENDIF
    IF (bed="Y")
     SET data->resrc[r].label[l].loc_bed_disp = uar_get_code_display(data->resrc[r].label[l].
      loc_bed_cd)
    ENDIF
    IF (building="Y")
     SET data->resrc[r].label[l].loc_building_disp = uar_get_code_display(data->resrc[r].label[l].
      loc_building_cd)
    ENDIF
    IF (facility="Y")
     SET data->resrc[r].label[l].loc_facility_disp = uar_get_code_display(data->resrc[r].label[l].
      loc_facility_cd)
    ENDIF
    IF (location="Y")
     SET data->resrc[r].label[l].location_disp = uar_get_code_display(data->resrc[r].label[l].
      location_cd)
    ENDIF
    IF (nurse_unit="Y")
     SET data->resrc[r].label[l].loc_nurse_unit_disp = uar_get_code_display(data->resrc[r].label[l].
      loc_nurse_unit_cd)
    ENDIF
    IF (room="Y")
     SET data->resrc[r].label[l].loc_room_disp = uar_get_code_display(data->resrc[r].label[l].
      loc_room_cd)
    ENDIF
    IF (nurse_unit="Y"
     AND room="Y"
     AND bed="Y")
     SET data->resrc[r].label[l].loc_nurse_room_bed_disp = build(data->resrc[r].label[l].
      loc_nurse_unit_disp,data->resrc[r].label[l].loc_room_disp,data->resrc[r].label[l].loc_bed_disp)
    ENDIF
    IF (encounter_type="Y")
     SET data->resrc[r].label[l].encntr_type_disp = uar_get_code_display(data->resrc[r].label[l].
      encntr_type_cd)
     SET data->resrc[r].label[l].encntr_type_desc = uar_get_code_description(data->resrc[r].label[l].
      encntr_type_cd)
    ENDIF
    IF (specimen_display="Y")
     SET data->resrc[r].label[l].specimen_disp = uar_get_code_display(data->resrc[r].label[l].
      specimen_cd)
    ENDIF
    IF (received_fixative="Y")
     SET data->resrc[r].label[l].received_fixative_disp = uar_get_code_display(data->resrc[r].label[l
      ].received_fixative_cd)
     SET data->resrc[r].label[l].received_fixative_desc = uar_get_code_description(data->resrc[r].
      label[l].received_fixative_cd)
    ENDIF
    IF (fixative_added="Y")
     SET data->resrc[r].label[l].fixative_added_disp = uar_get_code_display(data->resrc[r].label[l].
      fixative_added_cd)
     SET data->resrc[r].label[l].fixative_added_desc = uar_get_code_description(data->resrc[r].label[
      l].fixative_added_cd)
    ENDIF
    IF (fixative="Y")
     SET data->resrc[r].label[l].fixative_disp = uar_get_code_display(data->resrc[r].label[l].
      fixative_cd)
     SET data->resrc[r].label[l].fixative_desc = uar_get_code_description(data->resrc[r].label[l].
      fixative_cd)
    ENDIF
    IF (validate(inventory_2dbarcode,"N")="Y")
     SET data->resrc[r].label[l].inventory_code = getinventorybarcode(data->resrc[r].label[l].
      accession_nbr,data->resrc[r].label[l].case_specimen_tag_seq,data->resrc[r].label[l].
      cassette_tag_seq,0,0)
     IF (textlen(trim(data->resrc[r].label[l].inventory_code))=0)
      SET error_count = (error_count+ 1)
     ENDIF
    ENDIF
  ENDFOR
 ENDFOR
 DECLARE space = c1 WITH protect, constant(" ")
 DECLARE header = c1 WITH protect, constant("$")
 DECLARE command = c1 WITH protect, constant("#")
 DECLARE new_line = c1 WITH protect, constant("N")
 DECLARE footer = c1 WITH protect, constant(char(13))
 DECLARE tower_1 = c2 WITH protect, constant("H1")
 DECLARE tower_2 = c2 WITH protect, constant("H2")
 DECLARE tower_3 = c2 WITH protect, constant("H3")
 DECLARE tower_4 = c2 WITH protect, constant("H4")
 DECLARE tower_5 = c2 WITH protect, constant("H5")
 DECLARE tower_6 = c2 WITH protect, constant("H6")
 DECLARE font_xl = c1 WITH protect, constant("1")
 DECLARE font_large = c1 WITH protect, constant("2")
 DECLARE font_medium = c1 WITH protect, constant("3")
 DECLARE font_small = c1 WITH protect, constant("4")
 DECLARE font_xs = c1 WITH protect, constant("5")
 DECLARE font_xl_cpl = i2 WITH protect, constant(8)
 DECLARE font_large_cpl = i2 WITH protect, constant(12)
 DECLARE font_medium_cpl = i2 WITH protect, constant(16)
 DECLARE font_small_cpl = i2 WITH protect, constant(20)
 DECLARE font_xs_cpl = i2 WITH protect, constant(32)
 DECLARE formatline(line=vc,font=c1) = vc WITH protect
 SUBROUTINE formatline(line,font)
   DECLARE outputline = vc WITH protect, noconstant(" ")
   CASE (font)
    OF font_xl:
     SET outputline = substring(1,font_xl_cpl,line)
    OF font_large:
     SET outputline = substring(1,font_large_cpl,line)
    OF font_medium:
     SET outputline = substring(1,font_medium_cpl,line)
    OF font_small:
     SET outputline = substring(1,font_small_cpl,line)
    OF font_xs:
     SET outputline = substring(1,font_xs_cpl,line)
   ENDCASE
   SET outputline = replace(trim(outputline),",",".",0)
   RETURN(outputline)
 END ;Subroutine
 DECLARE output = vc WITH protect, noconstant
 SELECT INTO value(reply->print_status_data.print_filename)
  FROM (dummyt d1  WITH seq = 1)
  HEAD REPORT
   max_r = 0, max_l = 0
  DETAIL
   max_r = size(data->resrc,5)
   FOR (r_index = 1 TO max_r)
    max_l = size(data->resrc[r_index].label,5),
    FOR (l_index = 1 TO max_l)
      accession = data->resrc[r_index].label[l_index].fmt_accession_nbr, spec_display = data->resrc[
      r_index].label[l_index].specimen_disp, spec_blk_tag_disp = data->resrc[r_index].label[l_index].
      spec_blk_tag_disp,
      row + 1, line1 = formatline(trim(accession),font_medium), line2 = formatline(concat(trim(
         spec_blk_tag_disp),space,trim(spec_display)),font_medium),
      output = concat(header,command,tower_1,command,font_medium,
       line1,command,new_line,line2,footer), row + 1, output
    ENDFOR
   ENDFOR
  WITH nocounter, format = undefined, noformfeed
 ;end select
END GO
