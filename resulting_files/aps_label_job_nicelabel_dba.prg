CREATE PROGRAM aps_label_job_nicelabel:dba
 DECLARE buildcommand(sr_idx=i4,lbl_idx=i4,fld_idx=i4) = vc WITH protect
 DECLARE buildjobcontent(format_file_name=vc,printer_name=vc,copies=i4) = gvc WITH protect
#script
 DECLARE mrn_alias_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE encounter_alias_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE epr_admit_doc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE prsnl_name_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE lserviceresourcedisplayindex = i4 WITH protect, constant(5)
 DECLARE lworklistnbrindex = i4 WITH protect, constant(6)
 DECLARE lrequestdttmindex = i4 WITH protect, constant(9)
 DECLARE lprioritydisplayindex = i4 WITH protect, constant(12)
 DECLARE lcasespecimentagdisplayindex = i4 WITH protect, constant(15)
 DECLARE lcassettetagdisplayindex = i4 WITH protect, constant(18)
 DECLARE lcassettesepdisplayindex = i4 WITH protect, constant(19)
 DECLARE lslidetagdisplayindex = i4 WITH protect, constant(23)
 DECLARE lslidesepdisplayindex = i4 WITH protect, constant(24)
 DECLARE lspecblkslidetagdisplayindex = i4 WITH protect, constant(26)
 DECLARE lspecblktagdisplayindex = i4 WITH protect, constant(27)
 DECLARE lblkslidetagdisplayindex = i4 WITH protect, constant(28)
 DECLARE laccsitepreyyindex = i4 WITH protect, constant(32)
 DECLARE laccsiteindex = i4 WITH protect, constant(33)
 DECLARE laccpreindex = i4 WITH protect, constant(34)
 DECLARE laccyyindex = i4 WITH protect, constant(35)
 DECLARE laccyyyyindex = i4 WITH protect, constant(36)
 DECLARE laccnbrindex = i4 WITH protect, constant(37)
 DECLARE lresponsiblepathologistnamefullindex = i4 WITH protect, constant(41)
 DECLARE lresponsiblepathologistnamelastindex = i4 WITH protect, constant(42)
 DECLARE lresponsiblepathologistnameinitialindex = i4 WITH protect, constant(43)
 DECLARE lresponsibleresidentnamefullindex = i4 WITH protect, constant(45)
 DECLARE lresponsibleresidentnamelastindex = i4 WITH protect, constant(46)
 DECLARE lresponsibleresidentnameinitialindex = i4 WITH protect, constant(47)
 DECLARE lrequestingphysiciannamefullindex = i4 WITH protect, constant(49)
 DECLARE lrequestingphysiciannamelastindex = i4 WITH protect, constant(50)
 DECLARE lcasereceiveddttmindex = i4 WITH protect, constant(52)
 DECLARE lcasecollectdttmindex = i4 WITH protect, constant(54)
 DECLARE lmrnaliasindex = i4 WITH protect, constant(55)
 DECLARE lfinnbraliasindex = i4 WITH protect, constant(56)
 DECLARE lbirthdttmindex = i4 WITH protect, constant(62)
 DECLARE lageindex = i4 WITH protect, constant(64)
 DECLARE lsexdispindex = i4 WITH protect, constant(66)
 DECLARE lsexdescindex = i4 WITH protect, constant(67)
 DECLARE ladmitdoctornameindex = i4 WITH protect, constant(68)
 DECLARE ladmitdoctornamelastindex = i4 WITH protect, constant(69)
 DECLARE lbedindex = i4 WITH protect, constant(72)
 DECLARE lbuildingindex = i4 WITH protect, constant(74)
 DECLARE lfacilityindex = i4 WITH protect, constant(76)
 DECLARE llocationindex = i4 WITH protect, constant(78)
 DECLARE lnurseunitindex = i4 WITH protect, constant(80)
 DECLARE lroomindex = i4 WITH protect, constant(82)
 DECLARE llocnurseroombedindex = i4 WITH protect, constant(83)
 DECLARE lencountertypedispindex = i4 WITH protect, constant(85)
 DECLARE lencountertypedescindex = i4 WITH protect, constant(86)
 DECLARE lspecimendispindex = i4 WITH protect, constant(90)
 DECLARE lreceivedfixativedispindex = i4 WITH protect, constant(93)
 DECLARE lreceivedfixativedescindex = i4 WITH protect, constant(94)
 DECLARE lfixativeaddeddispindex = i4 WITH protect, constant(96)
 DECLARE lfixativeaddeddescindex = i4 WITH protect, constant(97)
 DECLARE lfixativedispindex = i4 WITH protect, constant(99)
 DECLARE lfixativedescindex = i4 WITH protect, constant(100)
 DECLARE linventorycodeindex = i4 WITH protect, constant(107)
 IF ((label_job_data->fields[linventorycodeindex].size > 0))
  EXECUTE pcs_label_integration_util
 ENDIF
 IF ((((label_job_data->fields[lmrnaliasindex].size > 0)) OR ((label_job_data->fields[
 lfinnbraliasindex].size > 0))) )
  SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn_alias_type_cd)
  SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,encounter_alias_type_cd)
 ENDIF
 IF ((((label_job_data->fields[ladmitdoctornameindex].size > 0)) OR ((label_job_data->fields[
 ladmitdoctornamelastindex].size > 0))) )
  SET stat = uar_get_meaning_by_codeset(333,"ADMITDOC",1,epr_admit_doc_cd)
 ENDIF
 SET stat = uar_get_meaning_by_codeset(213,"PRSNL",1,prsnl_name_type_cd)
 FOR (r = 1 TO size(data->resrc,5))
  IF ((label_job_data->fields[lserviceresourcedisplayindex].size > 0))
   SET data->resrc[r].service_resource_disp = uar_get_code_display(data->resrc[r].service_resource_cd
    )
  ENDIF
  FOR (l = 1 TO size(data->resrc[r].label,5))
    IF ((((label_job_data->fields[lmrnaliasindex].size > 0)) OR ((label_job_data->fields[
    lfinnbraliasindex].size > 0))) )
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
        data->resrc[r].label[l].mrn_alias = "Unknown"
       ENDIF
       IF (alias_type="P")
        data->resrc[r].label[l].mrn_alias = cnvtalias(pa.alias,pa.alias_pool_cd)
       ELSEIF (alias_type="E")
        data->resrc[r].label[l].fin_nbr_alias = cnvtalias(ea.alias,ea.alias_pool_cd)
       ENDIF
      WITH nocounter, outerjoin = d1, outerjoin = d2
     ;end select
    ENDIF
    IF ((((label_job_data->fields[ladmitdoctornameindex].size > 0)) OR ((label_job_data->fields[
    ladmitdoctornamelastindex].size > 0))) )
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
    IF ((label_job_data->fields[lrequestdttmindex].size > 0))
     SET data->resrc[r].label[l].request_dt_tm_string = format(cnvtdatetime(data->resrc[r].label[l].
       request_dt_tm),"mm/dd/yy;;d")
    ENDIF
    IF ((label_job_data->fields[lprioritydisplayindex].size > 0))
     SET data->resrc[r].label[l].priority_disp = uar_get_code_display(data->resrc[r].label[l].
      priority_cd)
    ENDIF
    IF ((((label_job_data->fields[lcasespecimentagdisplayindex].size > 0)) OR ((((label_job_data->
    fields[lspecblkslidetagdisplayindex].size > 0)) OR ((((label_job_data->fields[
    lspecblktagdisplayindex].size > 0)) OR ((label_job_data->fields[linventorycodeindex].size > 0)))
    )) ))
     AND (data->resrc[r].label[l].case_specimen_tag_cd > 0.0))
     SELECT INTO "nl:"
      FROM ap_tag a
      WHERE (a.tag_id=data->resrc[r].label[l].case_specimen_tag_cd)
      DETAIL
       data->resrc[r].label[l].case_specimen_tag_disp = a.tag_disp, data->resrc[r].label[l].
       case_specimen_tag_seq = a.tag_sequence
      WITH nocounter
     ;end select
    ENDIF
    IF ((((label_job_data->fields[lcassettetagdisplayindex].size > 0)) OR ((((label_job_data->fields[
    lspecblkslidetagdisplayindex].size > 0)) OR ((((label_job_data->fields[lspecblktagdisplayindex].
    size > 0)) OR ((((label_job_data->fields[lblkslidetagdisplayindex].size > 0)) OR ((label_job_data
    ->fields[linventorycodeindex].size > 0))) )) )) ))
     AND (data->resrc[r].label[l].cassette_tag_cd > 0.0))
     SELECT INTO "nl:"
      FROM ap_tag a
      PLAN (a
       WHERE (a.tag_id=data->resrc[r].label[l].cassette_tag_cd))
      DETAIL
       data->resrc[r].label[l].cassette_tag_disp = a.tag_disp, data->resrc[r].label[l].
       cassette_tag_seq = a.tag_sequence
      WITH nocounter
     ;end select
    ENDIF
    IF ((((label_job_data->fields[lcassettesepdisplayindex].size > 0)) OR ((((label_job_data->fields[
    lspecblkslidetagdisplayindex].size > 0)) OR ((((label_job_data->fields[lspecblktagdisplayindex].
    size > 0)) OR ((label_job_data->fields[lblkslidetagdisplayindex].size > 0))) )) )) )
     SELECT INTO "nl:"
      FROM ap_prefix_tag_group_r aptgr
      WHERE (aptgr.prefix_id=data->resrc[r].label[l].prefix_cd)
       AND aptgr.tag_type_flag=2
      DETAIL
       data->resrc[r].label[l].cassette_sep_disp = aptgr.tag_separator
      WITH nocounter
     ;end select
    ENDIF
    IF ((((label_job_data->fields[lslidetagdisplayindex].size > 0)) OR ((((label_job_data->fields[
    lspecblkslidetagdisplayindex].size > 0)) OR ((((label_job_data->fields[lblkslidetagdisplayindex].
    size > 0)) OR ((label_job_data->fields[linventorycodeindex].size > 0))) )) ))
     AND (data->resrc[r].label[l].slide_tag_cd > 0.0))
     SELECT INTO "nl:"
      FROM ap_tag a
      PLAN (a
       WHERE (a.tag_id=data->resrc[r].label[l].slide_tag_cd))
      DETAIL
       data->resrc[r].label[l].slide_tag_disp = a.tag_disp, data->resrc[r].label[l].slide_tag_seq = a
       .tag_sequence
      WITH nocounter
     ;end select
    ENDIF
    IF ((((label_job_data->fields[lslidesepdisplayindex].size > 0)) OR ((((label_job_data->fields[
    lspecblkslidetagdisplayindex].size > 0)) OR ((label_job_data->fields[lblkslidetagdisplayindex].
    size > 0))) )) )
     SELECT INTO "nl:"
      FROM ap_prefix_tag_group_r aptgr
      WHERE (aptgr.prefix_id=data->resrc[r].label[l].prefix_cd)
       AND aptgr.tag_type_flag=3
      DETAIL
       data->resrc[r].label[l].slide_sep_disp = aptgr.tag_separator
      WITH nocounter
     ;end select
    ENDIF
    IF ((label_job_data->fields[linventorycodeindex].size > 0))
     SET data->resrc[r].label[l].inventory_code = getinventorybarcode(data->resrc[r].label[l].
      accession_nbr,data->resrc[r].label[l].case_specimen_tag_seq,data->resrc[r].label[l].
      cassette_tag_seq,data->resrc[r].label[l].slide_tag_seq,0)
    ENDIF
    IF ((label_job_data->fields[lspecblkslidetagdisplayindex].size > 0))
     SET data->resrc[r].label[l].spec_blk_sld_tag_disp = build(data->resrc[r].label[l].
      case_specimen_tag_disp,nullterm(data->resrc[r].label[l].cassette_sep_disp),nullterm(data->
       resrc[r].label[l].cassette_tag_disp),data->resrc[r].label[l].slide_sep_disp,data->resrc[r].
      label[l].slide_tag_disp)
    ENDIF
    IF ((label_job_data->fields[lspecblktagdisplayindex].size > 0))
     SET data->resrc[r].label[l].spec_blk_tag_disp = build(data->resrc[r].label[l].
      case_specimen_tag_disp,data->resrc[r].label[l].cassette_sep_disp,data->resrc[r].label[l].
      cassette_tag_disp)
    ENDIF
    IF ((label_job_data->fields[lblkslidetagdisplayindex].size > 0))
     SET data->resrc[r].label[l].blk_sld_tag_disp = build(data->resrc[r].label[l].cassette_sep_disp,
      data->resrc[r].label[l].cassette_tag_disp,data->resrc[r].label[l].slide_sep_disp,data->resrc[r]
      .label[l].slide_tag_disp)
    ENDIF
    IF ((label_job_data->fields[laccsitepreyyindex].size > 0))
     SET data->resrc[r].label[l].acc_site_pre_yy_nbr = build(substring(1,5,data->resrc[r].label[l].
       accession_nbr),"-",substring(6,2,data->resrc[r].label[l].accession_nbr),"-",substring(10,2,
       data->resrc[r].label[l].accession_nbr),
      "-",substring(12,7,data->resrc[r].label[l].accession_nbr))
    ENDIF
    IF ((label_job_data->fields[laccsiteindex].size > 0))
     SET data->resrc[r].label[l].acc_site = substring(1,5,data->resrc[r].label[l].accession_nbr)
    ENDIF
    IF ((label_job_data->fields[laccpreindex].size > 0))
     SET data->resrc[r].label[l].acc_pre = substring(6,2,data->resrc[r].label[l].accession_nbr)
    ENDIF
    IF ((label_job_data->fields[laccyyindex].size > 0))
     SET data->resrc[r].label[l].acc_yy = substring(10,2,data->resrc[r].label[l].accession_nbr)
    ENDIF
    IF ((label_job_data->fields[laccyyyyindex].size > 0))
     SET data->resrc[r].label[l].acc_yyyy = substring(8,4,data->resrc[r].label[l].accession_nbr)
    ENDIF
    IF ((label_job_data->fields[laccnbrindex].size > 0))
     SET data->resrc[r].label[l].acc_nbr = substring(12,7,data->resrc[r].label[l].accession_nbr)
    ENDIF
    IF ((((label_job_data->fields[lresponsiblepathologistnamefullindex].size > 0)) OR ((((
    label_job_data->fields[lresponsiblepathologistnamelastindex].size > 0)) OR ((label_job_data->
    fields[lresponsiblepathologistnameinitialindex].size > 0))) )) )
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
    IF ((((label_job_data->fields[lresponsibleresidentnamefullindex].size > 0)) OR ((((label_job_data
    ->fields[lresponsibleresidentnamelastindex].size > 0)) OR ((label_job_data->fields[
    lresponsibleresidentnameinitialindex].size > 0))) )) )
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
    IF ((((label_job_data->fields[lrequestingphysiciannamefullindex].size > 0)) OR ((label_job_data->
    fields[lrequestingphysiciannamelastindex].size > 0))) )
     SELECT INTO "nl:"
      FROM prsnl p
      WHERE (p.person_id=data->resrc[r].label[l].requesting_physician_id)
      DETAIL
       data->resrc[r].label[l].requesting_physician_name_full = p.name_full_formatted, data->resrc[r]
       .label[l].requesting_physician_name_last = p.name_last
      WITH nocounter
     ;end select
    ENDIF
    IF ((label_job_data->fields[lcasereceiveddttmindex].size > 0))
     SET data->resrc[r].label[l].case_received_dt_tm_string = format(cnvtdatetime(data->resrc[r].
       label[l].case_received_dt_tm),"mm/dd/yy;;d")
    ENDIF
    IF ((label_job_data->fields[lcasecollectdttmindex].size > 0))
     SET data->resrc[r].label[l].case_collect_dt_tm_string = format(data->resrc[r].label[l].
      case_collect_dt_tm,"mm/dd/yy;;d")
    ENDIF
    IF ((((label_job_data->fields[lbirthdttmindex].size > 0)) OR ((label_job_data->fields[lageindex].
    size > 0))) )
     SET data->resrc[r].label[l].birth_dt_tm_string = format(cnvtdatetime(data->resrc[r].label[l].
       birth_dt_tm),"mm/dd/yy;;d")
    ENDIF
    IF ((label_job_data->fields[lageindex].size > 0))
     SET age = cnvtage(cnvtdate2(format(data->resrc[r].label[l].birth_dt_tm,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),cnvtint(format(data->resrc[r].label[l].birth_dt_tm,"hhmm;;m")))
     SET data->resrc[r].label[l].age = age
    ENDIF
    IF ((((label_job_data->fields[lsexdispindex].size > 0)) OR ((label_job_data->fields[lsexdescindex
    ].size > 0))) )
     SET data->resrc[r].label[l].sex_disp = uar_get_code_display(data->resrc[r].label[l].sex_cd)
     SET data->resrc[r].label[l].sex_desc = uar_get_code_description(data->resrc[r].label[l].sex_cd)
    ENDIF
    IF ((((label_job_data->fields[lbedindex].size > 0)) OR ((label_job_data->fields[
    llocnurseroombedindex].size > 0))) )
     SET data->resrc[r].label[l].loc_bed_disp = uar_get_code_display(data->resrc[r].label[l].
      loc_bed_cd)
    ENDIF
    IF ((label_job_data->fields[lbuildingindex].size > 0))
     SET data->resrc[r].label[l].loc_building_disp = uar_get_code_display(data->resrc[r].label[l].
      loc_building_cd)
    ENDIF
    IF ((label_job_data->fields[lfacilityindex].size > 0))
     SET data->resrc[r].label[l].loc_facility_disp = uar_get_code_display(data->resrc[r].label[l].
      loc_facility_cd)
    ENDIF
    IF ((label_job_data->fields[llocationindex].size > 0))
     SET data->resrc[r].label[l].location_disp = uar_get_code_display(data->resrc[r].label[l].
      location_cd)
    ENDIF
    IF ((((label_job_data->fields[lnurseunitindex].size > 0)) OR ((label_job_data->fields[
    llocnurseroombedindex].size > 0))) )
     SET data->resrc[r].label[l].loc_nurse_unit_disp = uar_get_code_display(data->resrc[r].label[l].
      loc_nurse_unit_cd)
    ENDIF
    IF ((((label_job_data->fields[lroomindex].size > 0)) OR ((label_job_data->fields[
    llocnurseroombedindex].size > 0))) )
     SET data->resrc[r].label[l].loc_room_disp = uar_get_code_display(data->resrc[r].label[l].
      loc_room_cd)
    ENDIF
    IF ((label_job_data->fields[llocnurseroombedindex].size > 0))
     SET data->resrc[r].label[l].loc_nurse_room_bed_disp = build(data->resrc[r].label[l].
      loc_nurse_unit_disp,data->resrc[r].label[l].loc_room_disp,data->resrc[r].label[l].loc_bed_disp)
    ENDIF
    IF ((((label_job_data->fields[lencountertypedispindex].size > 0)) OR ((label_job_data->fields[
    lencountertypedescindex].size > 0))) )
     SET data->resrc[r].label[l].encntr_type_disp = uar_get_code_display(data->resrc[r].label[l].
      encntr_type_cd)
     SET data->resrc[r].label[l].encntr_type_desc = uar_get_code_description(data->resrc[r].label[l].
      encntr_type_cd)
    ENDIF
    IF ((label_job_data->fields[lspecimendispindex].size > 0))
     SET data->resrc[r].label[l].specimen_disp = uar_get_code_display(data->resrc[r].label[l].
      specimen_cd)
    ENDIF
    IF ((((label_job_data->fields[lreceivedfixativedispindex].size > 0)) OR ((label_job_data->fields[
    lreceivedfixativedescindex].size > 0))) )
     SET data->resrc[r].label[l].received_fixative_disp = uar_get_code_display(data->resrc[r].label[l
      ].received_fixative_cd)
     SET data->resrc[r].label[l].received_fixative_desc = uar_get_code_description(data->resrc[r].
      label[l].received_fixative_cd)
    ENDIF
    IF ((((label_job_data->fields[lfixativeaddeddispindex].size > 0)) OR ((label_job_data->fields[
    lfixativeaddeddescindex].size > 0))) )
     SET data->resrc[r].label[l].fixative_added_disp = uar_get_code_display(data->resrc[r].label[l].
      fixative_added_cd)
     SET data->resrc[r].label[l].fixative_added_desc = uar_get_code_description(data->resrc[r].label[
      l].fixative_added_cd)
    ENDIF
    IF ((((label_job_data->fields[lfixativedispindex].size > 0)) OR ((label_job_data->fields[
    lfixativedescindex].size > 0))) )
     SET data->resrc[r].label[l].fixative_disp = uar_get_code_display(data->resrc[r].label[l].
      fixative_cd)
     SET data->resrc[r].label[l].fixative_desc = uar_get_code_description(data->resrc[r].label[l].
      fixative_cd)
    ENDIF
  ENDFOR
 ENDFOR
 DECLARE writefiletobackend(filename=vc,content=gvc) = null WITH protect
 SUBROUTINE writefiletobackend(filename,content)
   IF ( NOT (validate(tmp_file_rec,0)))
    RECORD tmp_file_rec(
      1 file_desc = i4
      1 file_offset = i4
      1 file_dir = i4
      1 file_name = vc
      1 file_buf = vc
    )
   ENDIF
   DECLARE content_size = i4 WITH protect, noconstant(0)
   DECLARE chunk_size = i4 WITH protect, constant(65536)
   DECLARE nbr_of_chunks = i4 WITH protect, noconstant(0)
   DECLARE chunk_idx = i4 WITH protect, noconstant(0)
   SET content_size = size(content)
   IF (content_size > 0)
    SET nbr_of_chunks = ((content_size/ chunk_size)+ 1)
    SET tmp_file_rec->file_name = filename
    SET tmp_file_rec->file_buf = "wb"
    SET stat = cclio("OPEN",tmp_file_rec)
    IF ((tmp_file_rec->file_desc != 0))
     FOR (chunk_idx = 1 TO nbr_of_chunks)
       SET tmp_file_rec->file_offset = ((chunk_idx - 1) * chunk_size)
       IF (chunk_idx=nbr_of_chunks)
        SET tmp_file_rec->file_buf = notrim(substring((tmp_file_rec->file_offset+ 1),mod(content_size,
           chunk_size),content))
       ELSE
        SET tmp_file_rec->file_buf = notrim(substring((tmp_file_rec->file_offset+ 1),chunk_size,
          content))
       ENDIF
       SET stat = cclio("WRITE",tmp_file_rec)
     ENDFOR
    ENDIF
    SET stat = cclio("CLOSE",tmp_file_rec)
   ENDIF
 END ;Subroutine
 DECLARE getlabeljobdata(job_directory=vc,job_file_suffix=vc,format_file_name=vc,printer_name=vc,
  copies=i4) = null WITH protect
 SUBROUTINE getlabeljobdata(job_directory,job_file_suffix,format_file_name,printer_name,copies)
   DECLARE first_sep_pos = i4 WITH protect, noconstant(0)
   DECLARE last_dot_pos = i4 WITH protect, noconstant(0)
   SET reply->label_job_data.suppress_spool_ind = 1
   SET reply->label_job_data.job_directory = job_directory
   IF (cursys="AXP")
    SET first_sep_pos = findstring(":",reply->print_status_data.print_filename,1,0)
   ELSEIF (cursys="AIX")
    SET first_sep_pos = findstring("/",reply->print_status_data.print_filename,1,0)
   ENDIF
   IF (first_sep_pos > 0)
    SET reply->label_job_data.job_filename = substring((first_sep_pos+ 1),textlen(reply->
      print_status_data.print_filename),reply->print_status_data.print_filename)
   ELSE
    SET reply->label_job_data.job_filename = trim(reply->print_status_data.print_filename)
   ENDIF
   SET last_dot_pos = findstring(".",reply->label_job_data.job_filename,1,1)
   IF (last_dot_pos > 0)
    SET reply->label_job_data.job_filename = substring(1,(last_dot_pos - 1),reply->label_job_data.
     job_filename)
   ELSE
    SET reply->label_job_data.job_filename = build2(trim(reply->label_job_data.job_filename),".")
   ENDIF
   SET reply->label_job_data.job_filename = build2(trim(reply->label_job_data.job_filename),
    job_file_suffix)
   SET reply->label_job_data.job_dir_and_filename = build2(trim(reply->label_job_data.job_directory),
    trim(reply->label_job_data.job_filename))
   SET reply->label_job_data.job_content = notrim(buildjobcontent(format_file_name,printer_name,
     copies))
   IF (size(trim(reply->label_job_data.job_content))=0)
    SET reply->status_data.status = "Z"
   ELSE
    CALL writefiletobackend(reply->print_status_data.print_filename,reply->label_job_data.job_content
     )
   ENDIF
 END ;Subroutine
 CALL getlabeljobdata(label_job_data->job_directory,label_job_data->job_file_suffix,label_job_data->
  format_file_name,label_job_data->printer_name,label_job_data->copies)
 SUBROUTINE buildcommand(sr_idx,lbl_idx,fld_idx)
   DECLARE tmpbuffer = vc WITH protect, noconstant("")
   CASE (label_job_data->fields[fld_idx].name)
    OF "NBR_OF_LABELS":
     SET tmpbuffer = cnvtstring(size(data->resrc[sr_idx].label,5),32,0)
    OF "CURRENT_DT_TM_STRING":
     SET tmpbuffer = data->current_dt_tm_string
    OF "SERVICE_RESOURCE_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].service_resource_cd,32,2)
    OF "SERVICE_RESOURCE_DISP":
     SET tmpbuffer = data->resrc[sr_idx].service_resource_disp
    OF "LABEL_SEQ":
     SET tmpbuffer = cnvtstring(lbl_idx,32,0)
    OF "WORKLIST_NBR":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].worklist_nbr,32,0)
    OF "MNEMONIC":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].mnemonic
    OF "DESCRIPTION":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].description
    OF "REQUEST_DT_TM":
     SET tmpbuffer = format(cnvtdatetime(data->resrc[sr_idx].label[lbl_idx].request_dt_tm),
      "mm/dd/yy;;d")
    OF "REQUEST_DT_TM_STRING":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].request_dt_tm_string
    OF "PRIORITY_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].priority_cd,32,2)
    OF "PRIORITY_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].priority_disp
    OF "CASE_SPECIMEN_ID":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].case_specimen_id,32,2)
    OF "CASE_SPECIMEN_TAG_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].case_specimen_tag_cd,32,2)
    OF "CASE_SPECIMEN_TAG_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].case_specimen_tag_disp
    OF "CASSETTE_ID":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].cassette_id,32,2)
    OF "CASSETTE_TAG_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].cassette_tag_cd,32,2)
    OF "CASSETTE_TAG_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].cassette_tag_disp
    OF "CASSETTE_SEP_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].cassette_sep_disp
    OF "CASSETTE_ORIGIN_MODIFIER":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].cassette_origin_modifier
    OF "SLIDE_ID":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].slide_id,32,2)
    OF "SLIDE_TAG_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].slide_tag_cd,32,2)
    OF "SLIDE_TAG_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].slide_tag_disp
    OF "SLIDE_SEP_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].slide_sep_disp
    OF "SLIDE_ORIGIN_MODIFIER":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].slide_origin_modifier
    OF "SPEC_BLK_SLD_TAG_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].spec_blk_sld_tag_disp
    OF "SPEC_BLK_TAG_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].spec_blk_tag_disp
    OF "BLK_SLD_TAG_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].blk_sld_tag_disp
    OF "PREFIX_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].prefix_cd,32,2)
    OF "ACCESSION_NBR":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].accession_nbr
    OF "FMT_ACCESSION_NBR":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].fmt_accession_nbr
    OF "ACC_SITE_PRE_YY_NBR":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].acc_site_pre_yy_nbr
    OF "ACC_SITE":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].acc_site
    OF "ACC_PRE":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].acc_pre
    OF "ACC_YY":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].acc_yy
    OF "ACC_YYYY":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].acc_yyyy
    OF "ACC_NBR":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].acc_nbr
    OF "CASE_YEAR":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].case_year,32,0)
    OF "CASE_NUMBER":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].case_number,32,0)
    OF "RESPONSIBLE_PATHOLOGIST_ID":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].responsible_pathologist_id,32,2)
    OF "RESPONSIBLE_PATHOLOGIST_NAME_FULL":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].responsible_pathologist_name_full
    OF "RESPONSIBLE_PATHOLOGIST_NAME_LAST":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].responsible_pathologist_name_last
    OF "RESPONSIBLE_PATHOLOGIST_INITIAL":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].responsible_pathologist_initial
    OF "RESPONSIBLE_RESIDENT_ID":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].responsible_resident_id,32,2)
    OF "RESPONSIBLE_RESIDENT_NAME_FULL":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].responsible_resident_name_full
    OF "RESPONSIBLE_RESIDENT_NAME_LAST":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].responsible_resident_name_last
    OF "RESPONSIBLE_RESIDENT_INITIAL":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].responsible_resident_initial
    OF "REQUESTING_PHYSICIAN_ID":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].requesting_physician_id,32,2)
    OF "REQUESTING_PHYSICIAN_NAME_FULL":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].requesting_physician_name_full
    OF "REQUESTING_PHYSICIAN_NAME_LAST":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].requesting_physician_name_last
    OF "CASE_RECEIVED_DT_TM":
     SET tmpbuffer = format(cnvtdatetime(data->resrc[sr_idx].label[lbl_idx].case_received_dt_tm),
      "mm/dd/yy;;d")
    OF "CASE_RECEIVED_DT_TM_STRING":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].case_received_dt_tm_string
    OF "CASE_COLLECT_DT_TM":
     SET tmpbuffer = format(cnvtdatetime(data->resrc[sr_idx].label[lbl_idx].case_collect_dt_tm),
      "mm/dd/yy;;d")
    OF "CASE_COLLECT_DT_TM_STRING":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].case_collect_dt_tm_string
    OF "MRN_ALIAS":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].mrn_alias
    OF "FIN_NBR_ALIAS":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].fin_nbr_alias
    OF "ENCNTR_ID":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].encntr_id,32,2)
    OF "PERSON_ID":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].person_id,32,2)
    OF "NAME_FULL_FORMATTED":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].name_full_formatted
    OF "NAME_LAST":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].name_last
    OF "BIRTH_DT_TM":
     SET tmpbuffer = format(cnvtdatetime(data->resrc[sr_idx].label[lbl_idx].birth_dt_tm),
      "mm/dd/yy;;d")
    OF "BIRTH_DT_TM_STRING":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].birth_dt_tm_string
    OF "DECEASED_DT_TM":
     SET tmpbuffer = format(cnvtdatetime(data->resrc[sr_idx].label[lbl_idx].deceased_dt_tm),
      "mm/dd/yy;;d")
    OF "AGE":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].age
    OF "SEX_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].sex_cd,32,2)
    OF "SEX_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].sex_disp
    OF "SEX_DESC":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].sex_desc
    OF "ADMIT_DOC_NAME":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].admit_doc_name
    OF "ADMIT_DOC_NAME_LAST":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].admit_doc_name_last
    OF "ORGANIZATION_ID":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].organization_id,32,2)
    OF "LOC_BED_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].loc_bed_cd,32,2)
    OF "LOC_BED_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].loc_bed_disp
    OF "LOC_BUILDING_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].loc_building_cd,32,2)
    OF "LOC_BUILDING_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].loc_building_disp
    OF "LOC_FACILITY_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].loc_facility_cd,32,2)
    OF "LOC_FACILITY_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].loc_facility_disp
    OF "LOCATION_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].location_cd,32,2)
    OF "LOCATION_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].location_disp
    OF "LOC_NURSE_UNIT_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].loc_nurse_unit_cd,32,2)
    OF "LOC_NURSE_UNIT_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].loc_nurse_unit_disp
    OF "LOC_ROOM_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].loc_room_cd,32,2)
    OF "LOC_ROOM_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].loc_room_disp
    OF "LOC_NURSE_ROOM_BED_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].loc_nurse_room_bed_disp
    OF "ENCNTR_TYPE_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].encntr_type_cd,32,2)
    OF "ENCNTR_TYPE_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].encntr_type_disp
    OF "ENCNTR_TYPE_DESC":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].encntr_type_desc
    OF "ADEQUACY_IND":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].adequacy_ind,32,0)
    OF "ADEQUACY_STRING":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].adequacy_string
    OF "SPECIMEN_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].specimen_cd,32,2)
    OF "SPECIMEN_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].specimen_disp
    OF "SPECIMEN_DESCRIPTION":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].specimen_description
    OF "RECEIVED_FIXATIVE_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].received_fixative_cd,32,2)
    OF "RECEIVED_FIXATIVE_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].received_fixative_disp
    OF "RECEIVED_FIXATIVE_DESC":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].received_fixative_desc
    OF "FIXATIVE_ADDED_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].fixative_added_cd,32,2)
    OF "FIXATIVE_ADDED_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].fixative_added_disp
    OF "FIXATIVE_ADDED_DESC":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].fixative_added_desc
    OF "FIXATIVE_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].fixative_cd,32,2)
    OF "FIXATIVE_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].fixative_disp
    OF "FIXATIVE_DESC":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].fixative_desc
    OF "SUPPLEMENTAL_TAG":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].supplemental_tag
    OF "PIECES":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].pieces
    OF "SL_SUPPLEMENTAL_TAG":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].sl_supplemental_tag
    OF "STAIN_TASK_ASSAY_CD":
     SET tmpbuffer = cnvtstring(data->resrc[sr_idx].label[lbl_idx].stain_task_assay_cd,32,2)
    OF "STAIN_MNEMONIC":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].stain_mnemonic
    OF "STAIN_DESCRIPTION":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].stain_description
    OF "INVENTORY_CODE":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].inventory_code
    OF "LOCATION_CODE":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].location_code
    OF "COMPARTMENT_CODE":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].compartment_code
    OF "SPEC_TRACKING_LOC_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].spec_tracking_loc_disp
    OF "STORAGE_SHELF_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].storage_shelf_disp
    OF "COMPARTMENT_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].compartment_disp
    OF "ORGANIZATION_NAME":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].organization_name
    OF "DOMAIN":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].domain
    OF "IDENTIFIER_TYPE":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].identifier_type
    OF "IDENTIFIER_CODE":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].identifier_code
    OF "IDENTIFIER_DISP":
     SET tmpbuffer = data->resrc[sr_idx].label[lbl_idx].identifier_disp
   ENDCASE
   SET tmpbuffer = build2("SET ",label_job_data->fields[fld_idx].name,"=",quote,trim(substring(1,
      label_job_data->fields[fld_idx].size,tmpbuffer)),
    quote,cr,lf)
   RETURN(tmpbuffer)
 END ;Subroutine
 SUBROUTINE buildjobcontent(format_file_name,printer_name,copies)
   DECLARE quote = c1 WITH protect, constant(char(34))
   DECLARE cr = c1 WITH protect, constant(char(13))
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE job_content = gvc WITH protect, noconstant("")
   DECLARE label_display = vc WITH protect, noconstant("")
   DECLARE command_line = vc WITH protect, noconstant("")
   DECLARE service_resource_cnt = i4 WITH protect, noconstant(0)
   DECLARE label_cnt = i4 WITH protect, noconstant(0)
   DECLARE label_display_cnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE k = i4 WITH protect, noconstant(0)
   SET job_content = build2("LABEL ",quote,format_file_name,quote,cr,
    lf)
   SET job_content = build2(job_content,"PRINTER ",quote,printer_name,quote,
    cr,lf)
   SET job_content = build2(job_content,"SESSIONSTART",cr,lf)
   SET service_resource_cnt = size(data->resrc,5)
   FOR (i = 1 TO service_resource_cnt)
    SET label_cnt = size(data->resrc[i].label,5)
    FOR (j = 1 TO label_cnt)
      SET label_display = trim("")
      FOR (k = 1 TO field_cnt)
        IF ((label_job_data->fields[k].size > 0))
         SET command_line = buildcommand(i,j,k)
         IF (size(trim(label_display)) > 0)
          SET label_display = build2(label_display,command_line)
         ELSE
          IF (size(trim(command_line)) > 0)
           SET label_display = command_line
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      IF (size(trim(label_display)) > 0)
       SET label_display_cnt = (label_display_cnt+ 1)
       SET job_content = build2(job_content,label_display)
       SET job_content = build2(job_content,"SESSIONPRINT ",trim(cnvtstring(copies)),cr,lf)
      ENDIF
    ENDFOR
   ENDFOR
   IF (label_display_cnt > 0)
    SET job_content = build2(job_content,"SESSIONEND",cr,lf)
   ELSE
    SET job_content = trim("")
   ENDIF
   RETURN(job_content)
 END ;Subroutine
END GO
