CREATE PROGRAM apscassaudit:dba
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
 DECLARE formatage(birth_dt_tm=f8,deceased_dt_tm=f8,policy=vc) = vc WITH protect
 DECLARE susername = c50 WITH protect, noconstant("")
 DECLARE nstatus = i4 WITH protect, noconstant(0)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE sunknownstring = vc WITH protect, noconstant("")
 DECLARE sstillbornstring = vc WITH protect, noconstant("")
 SET nstatus = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET sunknownstring = uar_i18ngetmessage(i18nhandle,"UNKNOWN_AGE","Unknown")
 SET sstillbornstring = uar_i18ngetmessage(i18nhandle,"STILLBORN_AGE","Stillborn")
 SELECT INTO "nl:"
  FROM prsnl pl
  WHERE (person_id=reqinfo->updt_id)
  DETAIL
   susername = pl.username
  WITH nocounter
 ;end select
 SUBROUTINE formatage(birth_dt_tm,deceased_dt_tm,policy)
   DECLARE eff_end_dt_tm = f8 WITH private, noconstant(0.0)
   SET eff_end_dt_tm = deceased_dt_tm
   IF (((eff_end_dt_tm=null) OR (eff_end_dt_tm=0.00)) )
    SET eff_end_dt_tm = cnvtdatetime(curdate,curtime3)
   ENDIF
   IF (((birth_dt_tm > eff_end_dt_tm) OR (birth_dt_tm=null)) )
    RETURN(sunknownstring)
   ELSEIF (birth_dt_tm=deceased_dt_tm)
    RETURN(sstillbornstring)
   ELSE
    RETURN(cnvtage2(birth_dt_tm,eff_end_dt_tm,0,concat(policy,"/",trim(susername),"/",trim(cnvtstring
       (reqinfo->position_cd,32,2)))))
   ENDIF
 END ;Subroutine
 RECORD label(
   1 qual[*]
     2 field[*]
       3 data = c20
 )
 RECORD col(
   1 count = i2
   1 qual[*]
     2 xpos = i2
     2 ypos = i2
 )
 SET service_resource_display = "Y"
 SET worklist_nbr = "Y"
 SET request_dt_tm_string = "Y"
 SET priority_display = "Y"
 SET case_specimen_tag_display = "Y"
 SET cassette_tag_display = "Y"
 SET cassette_sep_display = "Y"
 SET slide_tag_display = "Y"
 SET slide_sep_display = "Y"
 SET spec_blk_slide_tag_display = "Y"
 SET spec_blk_tag_display = "Y"
 SET blk_slide_tag_display = "Y"
 SET acc_site_pre_yy_nbr = "Y"
 SET acc_site = "Y"
 SET acc_pre = "Y"
 SET acc_yy = "Y"
 SET acc_yyyy = "Y"
 SET acc_nbr = "Y"
 SET responsible_pathologist = "Y"
 SET responsible_resident = "Y"
 SET responsible_physician = "Y"
 SET case_received_dt_tm_string = "Y"
 SET case_collect_dt_tm_string = "Y"
 SET mrn_alias = "Y"
 SET fin_nbr_alias = "Y"
 SET birth_dt_tm_string = "Y"
 SET age = "Y"
 SET sex = "Y"
 SET admit_doctor = "Y"
 SET bed = "Y"
 SET building = "Y"
 SET facility = "Y"
 SET location = "Y"
 SET nurse_unit = "Y"
 SET room = "Y"
 SET encounter_type = "Y"
 SET specimen_display = "Y"
 SET received_fixative = "Y"
 SET fixative_added = "Y"
 SET fixative = "Y"
#script
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET mrn_alias_type_cd = 0.0
 SET encounter_alias_type_cd = 0.0
 SET epr_admit_doc_cd = 0.0
 IF (mrn_alias="Y")
  SET code_set = 4
  SET cdf_meaning = "MRN"
  EXECUTE cpm_get_cd_for_cdf
  SET mrn_alias_type_cd = code_value
 ENDIF
 IF (fin_nbr_alias="Y")
  SET code_set = 319
  SET cdf_meaning = "FIN NBR"
  EXECUTE cpm_get_cd_for_cdf
  SET encounter_alias_type_cd = code_value
 ENDIF
 IF (admit_doctor="Y")
  SET code_set = 333
  SET cdf_meaning = "ADMITDOC"
  EXECUTE cpm_get_cd_for_cdf
  SET epr_admit_doc_cd = code_value
 ENDIF
 FOR (r = 1 TO size(data->resrc,5))
  IF (service_resource_display="Y")
   EXECUTE aps_get__cd_info value(data->resrc[r].service_resource_cd)
   SET data->resrc[r].service_resource_disp = cdinfo->display
  ENDIF
  FOR (l = 1 TO size(data->resrc[r].label,5))
    IF (((mrn_alias="Y") OR (fin_nbr_alias="Y")) )
     SELECT INTO "nl:"
      ea.encntr_id, pa.person_id, alias_type = decode(pa.seq,"P",ea.seq,"E"," ")
      FROM org_alias_pool_reltn oa,
       person_alias pa,
       encntr_alias ea,
       (dummyt d  WITH seq = 1),
       (dummyt d1  WITH seq = 1),
       (dummyt d2  WITH seq = 1)
      PLAN (d)
       JOIN (oa
       WHERE (data->resrc[r].label[l].organization_id=oa.organization_id)
        AND ((oa.alias_entity_name="PERSON_ALIAS"
        AND oa.alias_entity_alias_type_cd=mrn_alias_type_cd) OR (oa.alias_entity_name="ENCNTR_ALIAS"
        AND oa.alias_entity_alias_type_cd=encounter_alias_type_cd))
        AND oa.active_ind=1
        AND oa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND ((oa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (oa.end_effective_dt_tm=
       null)) )
       JOIN (((d1
       WHERE 1=d1.seq)
       JOIN (pa
       WHERE oa.alias_entity_name="PERSON_ALIAS"
        AND (data->resrc[r].label[l].person_id=pa.person_id)
        AND oa.alias_pool_cd=pa.alias_pool_cd
        AND pa.active_ind=1
        AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND ((pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (pa.end_effective_dt_tm=
       null)) )
       ) ORJOIN ((d2
       WHERE 1=d2.seq)
       JOIN (ea
       WHERE oa.alias_entity_name="ENCNTR_ALIAS"
        AND (data->resrc[r].label[l].encntr_id=ea.encntr_id)
        AND oa.alias_pool_cd=ea.alias_pool_cd
        AND ea.active_ind=1
        AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND ((ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (ea.end_effective_dt_tm=
       null)) )
       ))
      DETAIL
       data->resrc[r].label[l].mrn_alias = "Unknown"
       IF (alias_type="P")
        data->resrc[r].label[l].mrn_alias = pa.alias
       ELSEIF (alias_type="E")
        data->resrc[r].label[l].fin_nbr_alias = ea.alias
       ENDIF
      WITH nocounter, outerjoin = d, outerjoin = d1
     ;end select
    ENDIF
    IF (admit_doctor="Y")
     SELECT INTO "nl:"
      epr.prsnl_person_id, p.person_id
      FROM encntr_prsnl_reltn epr,
       person p,
       dummyt d
      PLAN (d)
       JOIN (epr
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
     SET data->resrc[r].label[l].request_dt_tm_string = format(data->resrc[r].label[l].request_dt_tm,
      "@MEDIUMDATE")
    ENDIF
    IF (priority_display="Y")
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].priority_cd)
     SET data->resrc[r].label[l].priority_disp = cdinfo->display
    ENDIF
    IF (case_specimen_tag_display="Y")
     SELECT INTO "nl:"
      a.tag_disp
      FROM ap_tag a
      WHERE (data->resrc[r].label[l].case_specimen_tag_cd=a.tag_id)
      DETAIL
       data->resrc[r].label[l].case_specimen_tag_disp = a.tag_disp
      WITH nocounter
     ;end select
    ENDIF
    IF (cassette_tag_display="Y")
     SELECT INTO "nl:"
      a.tag_disp
      FROM ap_tag a
      PLAN (a
       WHERE (data->resrc[r].label[l].cassette_tag_cd=a.tag_id))
      DETAIL
       data->resrc[r].label[l].cassette_tag_disp = a.tag_disp
      WITH nocounter
     ;end select
    ENDIF
    IF (cassette_sep_display="Y")
     SELECT INTO "nl:"
      aptgr.tag_separator
      FROM ap_prefix_tag_group_r aptgr
      WHERE (data->resrc[r].label[l].prefix_cd=aptgr.prefix_id)
       AND 2=aptgr.tag_type_flag
      DETAIL
       data->resrc[r].label[l].cassette_sep_disp = aptgr.tag_separator
      WITH nocounter
     ;end select
    ENDIF
    IF (slide_tag_display="Y")
     SELECT INTO "nl:"
      a.tag_disp
      FROM ap_tag a
      PLAN (a
       WHERE (data->resrc[r].label[l].slide_tag_cd=a.tag_id))
      DETAIL
       data->resrc[r].label[l].slide_tag_disp = a.tag_disp
      WITH nocounter
     ;end select
    ENDIF
    IF (slide_sep_display="Y")
     SELECT INTO "nl:"
      aptgr.tag_separator
      FROM ap_prefix_tag_group_r aptgr
      WHERE (data->resrc[r].label[l].prefix_cd=aptgr.prefix_id)
       AND 3=aptgr.tag_type_flag
      DETAIL
       data->resrc[r].label[l].slide_sep_disp = aptgr.tag_separator
      WITH nocounter
     ;end select
    ENDIF
    IF (spec_blk_slide_tag_display="Y")
     SET data->resrc[r].label[l].spec_blk_sld_tag_disp = build(data->resrc[r].label[l].
      case_specimen_tag_disp,data->resrc[r].label[l].cassette_sep_disp,data->resrc[r].label[l].
      cassette_tag_disp,data->resrc[r].label[l].slide_sep_disp,data->resrc[r].label[l].slide_tag_disp
      )
    ENDIF
    IF (spec_blk_tag_display="Y")
     SET data->resrc[r].label[l].spec_blk_tag_disp = build(data->resrc[r].label[l].
      case_specimen_tag_disp,data->resrc[r].label[l].cassette_sep_disp,data->resrc[r].label[l].
      cassette_tag_disp)
    ENDIF
    IF (blk_slide_tag_display="Y")
     SET data->resrc[r].label[l].blk_sld_tag_disp = build(data->resrc[r].label[l].cassette_sep_disp,
      data->resrc[r].label[l].cassette_tag_disp,data->resrc[r].label[l].slide_sep_disp,data->resrc[r]
      .label[l].slide_tag_disp)
    ENDIF
    IF (acc_site_pre_yy_nbr="Y")
     SET data->resrc[r].label[l].acc_site_pre_yy_nbr = build(substring(1,5,data->resrc[r].label[l].
       accession_nbr),"-",substring(6,2,data->resrc[r].label[l].accession_nbr),"-",substring(10,2,
       data->resrc[r].label[l].accession_nbr),
      "-",substring(12,7,data->resrc[r].label[l].accession_nbr))
    ENDIF
    IF (acc_site="Y")
     SET data->resrc[r].label[l].acc_site = build(substring(1,5,data->resrc[r].label[l].accession_nbr
       ))
    ENDIF
    IF (acc_pre="Y")
     SET data->resrc[r].label[l].acc_pre = build(substring(6,2,data->resrc[r].label[l].accession_nbr)
      )
    ENDIF
    IF (acc_yy="Y")
     SET data->resrc[r].label[l].acc_yy = build(substring(10,2,data->resrc[r].label[l].accession_nbr)
      )
    ENDIF
    IF (acc_yyyy="Y")
     SET data->resrc[r].label[l].acc_yyyy = build(substring(8,4,data->resrc[r].label[l].accession_nbr
       ))
    ENDIF
    IF (acc_nbr="Y")
     SET data->resrc[r].label[l].acc_nbr = build(substring(12,7,data->resrc[r].label[l].accession_nbr
       ))
    ENDIF
    IF (responsible_pathologist="Y")
     SELECT INTO "nl:"
      p.name_full_formatted
      FROM person p
      WHERE (data->resrc[r].label[l].responsible_pathologist_id=p.person_id)
      DETAIL
       data->resrc[r].label[l].responsible_pathologist_name_full = p.name_full_formatted, data->
       resrc[r].label[l].responsible_pathologist_name_last = p.name_last, data->resrc[r].label[l].
       responsible_pathologist_initial = build(substring(1,1,p.name_first_key),substring(1,1,p
         .name_last_key))
      WITH nocounter
     ;end select
    ENDIF
    IF (responsible_resident="Y")
     SELECT INTO "nl:"
      p.name_full_formatted
      FROM person p
      WHERE (data->resrc[r].label[l].responsible_resident_id=p.person_id)
      DETAIL
       data->resrc[r].label[l].responsible_resident_name_full = p.name_full_formatted, data->resrc[r]
       .label[l].responsible_resident_name_last = p.name_last, data->resrc[r].label[l].
       responsible_resident_initial = build(substring(1,1,p.name_first_key),substring(1,1,p
         .name_last_key))
      WITH nocounter
     ;end select
    ENDIF
    IF (responsible_physician="Y")
     SELECT INTO "nl:"
      p.name_full_formatted
      FROM person p
      WHERE (data->resrc[r].label[l].requesting_physician_id=p.person_id)
      DETAIL
       data->resrc[r].label[l].requesting_physician_name_full = p.name_full_formatted, data->resrc[r]
       .label[l].requesting_physician_name_last = p.name_last
      WITH nocounter
     ;end select
    ENDIF
    IF (case_received_dt_tm_string="Y")
     SET data->resrc[r].label[l].case_received_dt_tm_string = format(cnvtdatetime(data->resrc[r].
       label[l].case_received_dt_tm),"mm/dd/yy;;d")
    ENDIF
    IF (case_collect_dt_tm_string="Y")
     SET data->resrc[r].label[l].case_collect_dt_tm_string = format(cnvtdatetime(data->resrc[r].
       label[l].case_collect_dt_tm),"mm/dd/yy;;d")
    ENDIF
    IF (birth_dt_tm_string="Y")
     SET data->resrc[r].label[l].birth_dt_tm_string = format(cnvtdatetime(data->resrc[r].label[l].
       birth_dt_tm),"mm/dd/yy;;d")
    ENDIF
    IF (age="Y")
     SET data->resrc[r].label[l].age = formatage(data->resrc[r].label[1].birth_dt_tm,validate(data->
       resrc[r].label[1].deceased_dt_tm,0.0),"LABRPTAGE")
    ENDIF
    IF (sex="Y")
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].sex_cd)
     SET data->resrc[r].label[l].sex_disp = cdinfo->display
     SET data->resrc[r].label[l].sex_desc = cdinfo->description
    ENDIF
    IF (bed="Y")
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].loc_bed_cd)
     SET data->resrc[r].label[l].loc_bed_disp = cdinfo->display
    ENDIF
    IF (building="Y")
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].loc_building_cd)
     SET data->resrc[r].label[l].loc_building_disp = cdinfo->display
    ENDIF
    IF (facility="Y")
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].loc_facility_cd)
     SET data->resrc[r].label[l].loc_facility_disp = cdinfo->display
    ENDIF
    IF (location="Y")
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].location_cd)
     SET data->resrc[r].label[l].location_disp = cdinfo->display
    ENDIF
    IF (nurse_unit="Y")
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].loc_nurse_unit_cd)
     SET data->resrc[r].label[l].loc_nurse_unit_disp = cdinfo->display
    ENDIF
    IF (room="Y")
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].loc_room_cd)
     SET data->resrc[r].label[l].loc_room_disp = cdinfo->display
    ENDIF
    IF (nurse_unit="Y"
     AND room="Y"
     AND bed="Y")
     SET data->resrc[r].label[l].loc_nurse_room_bed_disp = build(data->resrc[r].label[l].
      loc_nurse_unit_disp,data->resrc[r].label[l].loc_room_disp,data->resrc[r].label[l].loc_bed_disp)
    ENDIF
    IF (encounter_type="Y")
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].encntr_type_cd)
     SET data->resrc[r].label[l].encntr_type_disp = cdinfo->display
     SET data->resrc[r].label[l].encntr_type_desc = cdinfo->description
    ENDIF
    IF (specimen_display="Y")
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].specimen_cd)
     SET data->resrc[r].label[l].specimen_disp = cdinfo->display
    ENDIF
    IF (received_fixative="Y")
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].received_fixative_cd)
     SET data->resrc[r].label[l].received_fixative_disp = cdinfo->display
     SET data->resrc[r].label[l].received_fixative_desc = cdinfo->description
    ENDIF
    IF (fixative_added="Y")
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].fixative_added_cd)
     SET data->resrc[r].label[l].fixative_added_disp = cdinfo->display
     SET data->resrc[r].label[l].fixative_added_desc = cdinfo->description
    ENDIF
    IF (fixative="Y")
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].fixative_cd)
     SET data->resrc[r].label[l].fixative_disp = cdinfo->display
     SET data->resrc[r].label[l].fixative_desc = cdinfo->description
    ENDIF
  ENDFOR
 ENDFOR
 SELECT INTO value(reply->print_status_data.print_filename)
  data
  FROM (dummyt d1  WITH seq = 1)
  HEAD REPORT
   num_label = 0, max_r = 0, max_l = 0
  DETAIL
   max_r = size(data->resrc,5), row + 1, "data->maxlabel             = [",
   data->maxlabel, "]", row + 1,
   "data->current_dt_tm_string = [", data->current_dt_tm_string, "]"
   FOR (r_index = 1 TO max_r)
     max_l = size(data->resrc[r_index].label,5), row + 1, "r_index = [",
     r_index, "], max_r = [", max_r,
     "]", row + 1, "data->resrc[r_index].service_resource_cd   = [",
     data->resrc[r_index].service_resource_cd, "]", row + 1,
     "data->resrc[r_index].service_resource_disp = [", data->resrc[r_index].service_resource_disp,
     "]",
     row + 1
     FOR (l_index = 1 TO max_l)
       num_label = (num_label+ 1), row + 1, "num_label = [",
       num_label, "], l_index = [", l_index,
       "], max_l = [", max_l, "]",
       row + 1, "data->resrc[r_index].label[l_index].worklist_nbr               = [", data->resrc[
       r_index].label[l_index].worklist_nbr,
       "]", row + 1, "data->resrc[r_index].label[l_index].service_resource_cd        = [",
       data->resrc[r_index].label[l_index].service_resource_cd, "]", row + 1,
       "data->resrc[r_index].label[l_index].mnemonic                   = [", data->resrc[r_index].
       label[l_index].mnemonic, "]",
       row + 1, "data->resrc[r_index].label[l_index].description                = [", data->resrc[
       r_index].label[l_index].description,
       "]", row + 1, "data->resrc[r_index].label[l_index].request_dt_tm              = [",
       data->resrc[r_index].label[l_index].request_dt_tm, "]", row + 1,
       "data->resrc[r_index].label[l_index].request_dt_tm_string       = [", data->resrc[r_index].
       label[l_index].request_dt_tm_string, "]",
       row + 1, "data->resrc[r_index].label[l_index].priority_cd                = [", data->resrc[
       r_index].label[l_index].priority_cd,
       "]", row + 1, "data->resrc[r_index].label[l_index].priority_disp              = [",
       data->resrc[r_index].label[l_index].priority_disp, "]", row + 1,
       "data->resrc[r_index].label[l_index].case_specimen_id           = [", data->resrc[r_index].
       label[l_index].case_specimen_id, "]",
       row + 1, "data->resrc[r_index].label[l_index].case_specimen_tag_cd       = [", data->resrc[
       r_index].label[l_index].case_specimen_tag_cd,
       "]", row + 1, "data->resrc[r_index].label[l_index].case_specimen_tag_disp     = [",
       data->resrc[r_index].label[l_index].case_specimen_tag_disp, "]", row + 1,
       "data->resrc[r_index].label[l_index].cassette_id                = [", data->resrc[r_index].
       label[l_index].cassette_id, "]",
       row + 1, "data->resrc[r_index].label[l_index].cassette_tag_cd            = [", data->resrc[
       r_index].label[l_index].cassette_tag_cd,
       "]", row + 1, "data->resrc[r_index].label[l_index].cassette_tag_disp          = [",
       data->resrc[r_index].label[l_index].cassette_tag_disp, "]", row + 1,
       "data->resrc[r_index].label[l_index].cassette_sep_disp           = [", data->resrc[r_index].
       label[l_index].cassette_sep_disp, "]",
       row + 1, "data->resrc[r_index].label[l_index].cassette_origin_modifier    = [", data->resrc[
       r_index].label[l_index].cassette_origin_modifier,
       "]", row + 1, "data->resrc[r_index].label[l_index].slide_id                    = [",
       data->resrc[r_index].label[l_index].slide_id, "]", row + 1,
       "data->resrc[r_index].label[l_index].slide_tag_cd                = [", data->resrc[r_index].
       label[l_index].slide_tag_cd, "]",
       row + 1, "data->resrc[r_index].label[l_index].slide_tag_disp              = [", data->resrc[
       r_index].label[l_index].slide_tag_disp,
       "]", row + 1, "data->resrc[r_index].label[l_index].slide_sep_disp              = [",
       data->resrc[r_index].label[l_index].slide_sep_disp, "]", row + 1,
       "data->resrc[r_index].label[l_index].slide_origin_modifier       = [", data->resrc[r_index].
       label[l_index].slide_origin_modifier, "]",
       row + 1, "data->resrc[r_index].label[l_index].spec_blk_sld_tag_disp       = [", data->resrc[
       r_index].label[l_index].spec_blk_sld_tag_disp,
       "]", row + 1, "data->resrc[r_index].label[l_index].spec_blk_tag_disp           = [",
       data->resrc[r_index].label[l_index].spec_blk_tag_disp, "]", row + 1,
       "data->resrc[r_index].label[l_index].blk_sld_tag_disp            = [", data->resrc[r_index].
       label[l_index].blk_sld_tag_disp, "]",
       row + 1, "data->resrc[r_index].label[l_index].prefix_cd                   = [", data->resrc[
       r_index].label[l_index].prefix_cd,
       "]", row + 1, "data->resrc[r_index].label[l_index].accession_nbr               = [",
       data->resrc[r_index].label[l_index].accession_nbr, "]", row + 1,
       "data->resrc[r_index].label[l_index].fmt_accession_nbr           = [", data->resrc[r_index].
       label[l_index].fmt_accession_nbr, "]",
       row + 1, "data->resrc[r_index].label[l_index].acc_site_pre_yy_nbr         = [", data->resrc[
       r_index].label[l_index].acc_site_pre_yy_nbr,
       "]", row + 1, "data->resrc[r_index].label[l_index].acc_site                    = [",
       data->resrc[r_index].label[l_index].acc_site, "]", row + 1,
       "data->resrc[r_index].label[l_index].acc_pre                     = [", data->resrc[r_index].
       label[l_index].acc_pre, "]",
       row + 1, "data->resrc[r_index].label[l_index].acc_yy                      = [", data->resrc[
       r_index].label[l_index].acc_yy,
       "]", row + 1, "data->resrc[r_index].label[l_index].acc_yyyy                    = [",
       data->resrc[r_index].label[l_index].acc_yyyy, "]", row + 1,
       "data->resrc[r_index].label[l_index].acc_nbr                     = [", data->resrc[r_index].
       label[l_index].acc_nbr, "]",
       row + 1, "data->resrc[r_index].label[l_index].case_year                   = [", data->resrc[
       r_index].label[l_index].case_year,
       "]", row + 1, "data->resrc[r_index].label[l_index].case_number                 = [",
       data->resrc[r_index].label[l_index].case_number, "]", row + 1,
       "data->resrc[r_index].label[l_index].responsible_pathologist_id  = [", data->resrc[r_index].
       label[l_index].responsible_pathologist_id, "]",
       row + 1, "data->resrc[r_index].label[l_index].responsible_pathologist_name_full = [", data->
       resrc[r_index].label[l_index].responsible_pathologist_name_full,
       "]", row + 1, "data->resrc[r_index].label[l_index].responsible_pathologist_name_last = [",
       data->resrc[r_index].label[l_index].responsible_pathologist_name_last, "]", row + 1,
       "data->resrc[r_index].label[l_index].responsible_pathologist_initial   = [", data->resrc[
       r_index].label[l_index].responsible_pathologist_initial, "]",
       row + 1, "data->resrc[r_index].label[l_index].responsible_resident_id     = [", data->resrc[
       r_index].label[l_index].responsible_resident_id,
       "]", row + 1, "data->resrc[r_index].label[l_index].responsible_resident_name_full   = [",
       data->resrc[r_index].label[l_index].responsible_resident_name_full, "]", row + 1,
       "data->resrc[r_index].label[l_index].responsible_resident_name_last   = [", data->resrc[
       r_index].label[l_index].responsible_resident_name_last, "]",
       row + 1, "data->resrc[r_index].label[l_index].responsible_resident_initial = [", data->resrc[
       r_index].label[l_index].responsible_resident_initial,
       "]", row + 1, "data->resrc[r_index].label[l_index].requesting_physician_id     = [",
       data->resrc[r_index].label[l_index].requesting_physician_id, "]", row + 1,
       "data->resrc[r_index].label[l_index].requesting_physician_name_full   = [", data->resrc[
       r_index].label[l_index].requesting_physician_name_full, "]",
       row + 1, "data->resrc[r_index].label[l_index].requesting_physician_name_last   = [", data->
       resrc[r_index].label[l_index].requesting_physician_name_last,
       "]", row + 1, "data->resrc[r_index].label[l_index].case_received_dt_tm         = [",
       data->resrc[r_index].label[l_index].case_received_dt_tm, "]", row + 1,
       "data->resrc[r_index].label[l_index].case_received_dt_tm_string  = [", data->resrc[r_index].
       label[l_index].case_received_dt_tm_string, "]",
       row + 1, "data->resrc[r_index].label[l_index].case_collect_dt_tm          = [", data->resrc[
       r_index].label[l_index].case_collect_dt_tm,
       "]", row + 1, "data->resrc[r_index].label[l_index].case_collect_dt_tm_string   = [",
       data->resrc[r_index].label[l_index].case_collect_dt_tm_string, "]", row + 1,
       "data->resrc[r_index].label[l_index].mrn_alias                   = [", data->resrc[r_index].
       label[l_index].mrn_alias, "]",
       row + 1, "data->resrc[r_index].label[l_index].fin_nbr_alias               = [", data->resrc[
       r_index].label[l_index].fin_nbr_alias,
       "]", row + 1, "data->resrc[r_index].label[l_index].encntr_id                   = [",
       data->resrc[r_index].label[l_index].encntr_id, "]", row + 1,
       "data->resrc[r_index].label[l_index].person_id                   = [", data->resrc[r_index].
       label[l_index].person_id, "]",
       row + 1, "data->resrc[r_index].label[l_index].name_full_formatted         = [", data->resrc[
       r_index].label[l_index].name_full_formatted,
       "]", row + 1, "data->resrc[r_index].label[l_index].name_last                   = [",
       data->resrc[r_index].label[l_index].name_last, "]", row + 1,
       "data->resrc[r_index].label[l_index].birth_dt_tm                 = [", data->resrc[r_index].
       label[l_index].birth_dt_tm, "]",
       row + 1, "data->resrc[r_index].label[l_index].birth_dt_tm_string          = [", data->resrc[
       r_index].label[l_index].birth_dt_tm_string,
       "]", row + 1, "data->resrc[r_index].label[l_index].age                         = [",
       data->resrc[r_index].label[l_index].age, "]", row + 1,
       "data->resrc[r_index].label[l_index].sex_cd                      = [", data->resrc[r_index].
       label[l_index].sex_cd, "]",
       row + 1, "data->resrc[r_index].label[l_index].sex_disp                    = [", data->resrc[
       r_index].label[l_index].sex_disp,
       "]", row + 1, "data->resrc[r_index].label[l_index].sex_desc                    = [",
       data->resrc[r_index].label[l_index].sex_desc, "]", row + 1,
       "data->resrc[r_index].label[l_index].admit_doc_name              = [", data->resrc[r_index].
       label[l_index].admit_doc_name, "]",
       row + 1, "data->resrc[r_index].label[l_index].admit_doc_name_last         = [", data->resrc[
       r_index].label[l_index].admit_doc_name_last,
       "]", row + 1, "data->resrc[r_index].label[l_index].organization_id             = [",
       data->resrc[r_index].label[l_index].organization_id, "]", row + 1,
       "data->resrc[r_index].label[l_index].loc_bed_cd                  = [", data->resrc[r_index].
       label[l_index].loc_bed_cd, "]",
       row + 1, "data->resrc[r_index].label[l_index].loc_bed_disp                = [", data->resrc[
       r_index].label[l_index].loc_bed_disp,
       "]", row + 1, "data->resrc[r_index].label[l_index].loc_building_cd            = [",
       data->resrc[r_index].label[l_index].loc_building_cd, "]", row + 1,
       "data->resrc[r_index].label[l_index].loc_building_disp          = [", data->resrc[r_index].
       label[l_index].loc_building_disp, "]",
       row + 1, "data->resrc[r_index].label[l_index].loc_facility_cd            = [", data->resrc[
       r_index].label[l_index].loc_facility_cd,
       "]", row + 1, "data->resrc[r_index].label[l_index].loc_facility_disp          = [",
       data->resrc[r_index].label[l_index].loc_facility_disp, "]", row + 1,
       "data->resrc[r_index].label[l_index].location_cd                = [", data->resrc[r_index].
       label[l_index].location_cd, "]",
       row + 1, "data->resrc[r_index].label[l_index].location_disp              = [", data->resrc[
       r_index].label[l_index].location_disp,
       "]", row + 1, "data->resrc[r_index].label[l_index].loc_nurse_unit_cd          = [",
       data->resrc[r_index].label[l_index].loc_nurse_unit_cd, "]", row + 1,
       "data->resrc[r_index].label[l_index].loc_nurse_unit_disp        = [", data->resrc[r_index].
       label[l_index].loc_nurse_unit_disp, "]",
       row + 1, "data->resrc[r_index].label[l_index].loc_room_cd                = [", data->resrc[
       r_index].label[l_index].loc_room_cd,
       "]", row + 1, "data->resrc[r_index].label[l_index].loc_room_disp              = [",
       data->resrc[r_index].label[l_index].loc_room_disp, "]", row + 1,
       "data->resrc[r_index].label[l_index].loc_nurse_room_bed_disp    = [", data->resrc[r_index].
       label[l_index].loc_nurse_room_bed_disp, "]",
       row + 1, "data->resrc[r_index].label[l_index].encntr_type_cd             = [", data->resrc[
       r_index].label[l_index].encntr_type_cd,
       "]", row + 1, "data->resrc[r_index].label[l_index].encntr_type_disp           = [",
       data->resrc[r_index].label[l_index].encntr_type_disp, "]", row + 1,
       "data->resrc[r_index].label[l_index].encntr_type_desc           = [", data->resrc[r_index].
       label[l_index].encntr_type_desc, "]",
       row + 1, "data->resrc[r_index].label[l_index].adequacy_ind               = [", data->resrc[
       r_index].label[l_index].adequacy_ind,
       "]", row + 1, "data->resrc[r_index].label[l_index].adequacy_string            = [",
       data->resrc[r_index].label[l_index].adequacy_string, "]", row + 1,
       "data->resrc[r_index].label[l_index].specimen_cd                = [", data->resrc[r_index].
       label[l_index].specimen_cd, "]",
       row + 1, "data->resrc[r_index].label[l_index].specimen_disp              = [", data->resrc[
       r_index].label[l_index].specimen_disp,
       "]", row + 1, "data->resrc[r_index].label[l_index].specimen_description       = [",
       data->resrc[r_index].label[l_index].specimen_description, "]", row + 1,
       "data->resrc[r_index].label[l_index].received_fixative_cd       = [", data->resrc[r_index].
       label[l_index].received_fixative_cd, "]",
       row + 1, "data->resrc[r_index].label[l_index].received_fixative_disp     = [", data->resrc[
       r_index].label[l_index].received_fixative_disp,
       "]", row + 1, "data->resrc[r_index].label[l_index].received_fixative_desc     = [",
       data->resrc[r_index].label[l_index].received_fixative_desc, "]", row + 1,
       "data->resrc[r_index].label[l_index].fixative_added_cd          = [", data->resrc[r_index].
       label[l_index].fixative_added_cd, "]",
       row + 1, "data->resrc[r_index].label[l_index].fixative_added_disp        = [", data->resrc[
       r_index].label[l_index].fixative_added_disp,
       "]", row + 1, "data->resrc[r_index].label[l_index].fixative_added_desc        = [",
       data->resrc[r_index].label[l_index].fixative_added_desc, "]", row + 1,
       "data->resrc[r_index].label[l_index].fixative_cd                = [", data->resrc[r_index].
       label[l_index].fixative_cd, "]",
       row + 1, "data->resrc[r_index].label[l_index].fixative_disp              = [", data->resrc[
       r_index].label[l_index].fixative_disp,
       "]", row + 1, "data->resrc[r_index].label[l_index].fixative_desc              = [",
       data->resrc[r_index].label[l_index].fixative_desc, "]", row + 1,
       "data->resrc[r_index].label[l_index].supplemental_tag           = [", data->resrc[r_index].
       label[l_index].supplemental_tag, "]",
       row + 1, "data->resrc[r_index].label[l_index].pieces                     = [", data->resrc[
       r_index].label[l_index].pieces,
       "]", row + 1, "data->resrc[r_index].label[l_index].stain_task_assay_cd        = [",
       data->resrc[r_index].label[l_index].stain_task_assay_cd, "]", row + 1,
       "data->resrc[r_index].label[l_index].stain_mnemonic             = [", data->resrc[r_index].
       label[l_index].stain_mnemonic, "]",
       row + 1, "data->resrc[r_index].label[l_index].stain_description           = [", data->resrc[
       r_index].label[l_index].stain_description,
       "]", row + 1
     ENDFOR
   ENDFOR
  WITH nocounter, maxcol = 255
 ;end select
END GO
