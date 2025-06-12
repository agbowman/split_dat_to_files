CREATE PROGRAM apslabelspec1l:dba
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
     2 line[14]
       3 data = vc
 )
 RECORD row(
   1 qual[5]
     2 col[6]
       3 start = i2
 )
#script
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET mrn_alias_type_cd = 0.0
 SET encounter_alias_type_cd = 0.0
 SET epr_admit_doc_cd = 0.0
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET encounter_alias_type_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET epr_admit_doc_cd = code_value
 FOR (r = 1 TO size(data->resrc,5))
   FOR (l = 1 TO size(data->resrc[r].label,5))
     SELECT INTO "nl:"
      ea.encntr_id, pa.person_id, frmt_mrn = cnvtalias(pa.alias,pa.alias_pool_cd),
      alias_type = decode(pa.seq,"P",ea.seq,"E"," ")
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
       IF (alias_type="P")
        data->resrc[r].label[l].mrn_alias = frmt_mrn
       ELSEIF (alias_type="E")
        data->resrc[r].label[l].fin_nbr_alias = ea.alias
       ENDIF
      WITH nocounter, outerjoin = d, outerjoin = d1
     ;end select
     SELECT INTO "nl:"
      epr.prsnl_person_id, p.person_id
      FROM encntr_prsnl_reltn epr,
       prsnl p,
       dummyt d
      PLAN (d)
       JOIN (epr
       WHERE (epr.encntr_id=data->resrc[r].label[l].encntr_id)
        AND epr.encntr_prsnl_r_cd=epr_admit_doc_cd
        AND epr.active_ind=1
        AND epr.manual_create_ind IN (0, null)
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
     SELECT INTO "nl:"
      a.tag_disp
      FROM ap_tag a
      WHERE (data->resrc[r].label[l].case_specimen_tag_cd=a.tag_id)
      DETAIL
       data->resrc[r].label[l].case_specimen_tag_disp = a.tag_disp
      WITH nocounter
     ;end select
     SET data->resrc[r].label[l].acc_site_pre_yy_nbr = build(substring(1,5,data->resrc[r].label[l].
       accession_nbr),"-",substring(6,2,data->resrc[r].label[l].accession_nbr),"-",substring(10,2,
       data->resrc[r].label[l].accession_nbr),
      "-",substring(12,7,data->resrc[r].label[l].accession_nbr))
     SET data->resrc[r].label[l].acc_site = build(substring(1,5,data->resrc[r].label[l].accession_nbr
       ))
     SET data->resrc[r].label[l].acc_pre = build(substring(6,2,data->resrc[r].label[l].accession_nbr)
      )
     SET data->resrc[r].label[l].acc_yy = build(substring(10,2,data->resrc[r].label[l].accession_nbr)
      )
     SET data->resrc[r].label[l].acc_yyyy = build(substring(8,4,data->resrc[r].label[l].accession_nbr
       ))
     SET data->resrc[r].label[l].acc_nbr = build(substring(12,7,data->resrc[r].label[l].accession_nbr
       ))
     SELECT INTO "nl:"
      p.name_full_formatted
      FROM prsnl p
      WHERE (data->resrc[r].label[l].requesting_physician_id=p.person_id)
      DETAIL
       data->resrc[r].label[l].requesting_physician_name_full = p.name_full_formatted, data->resrc[r]
       .label[l].requesting_physician_name_last = p.name_last
      WITH nocounter
     ;end select
     SET data->resrc[r].label[l].case_collect_dt_tm_string = format(cnvtdatetime(data->resrc[r].
       label[l].case_collect_dt_tm),"mm/dd/yy;;d")
     SET data->resrc[r].label[l].birth_dt_tm_string = format(cnvtdatetime(data->resrc[r].label[l].
       birth_dt_tm),"mm/dd/yy;;d")
     SET data->resrc[r].label[l].age = formatage(data->resrc[r].label[l].birth_dt_tm,validate(data->
       resrc[r].label[l].deceased_dt_tm,0.0),"LABRPTAGE")
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].sex_cd)
     IF ((cdinfo->fail > 0))
      SET data->resrc[r].label[l].sex_disp = cdinfo->display
      SET data->resrc[r].label[l].sex_desc = cdinfo->description
     ENDIF
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].received_fixative_cd)
     IF ((cdinfo->fail > 0))
      SET data->resrc[r].label[l].received_fixative_disp = cdinfo->display
      SET data->resrc[r].label[l].received_fixative_desc = cdinfo->description
     ENDIF
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].fixative_added_cd)
     IF ((cdinfo->fail > 0))
      SET data->resrc[r].label[l].fixative_added_disp = cdinfo->display
      SET data->resrc[r].label[l].fixative_added_desc = cdinfo->description
     ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  d1.seq, d2.seq
  FROM (dummyt d1  WITH seq = value(size(data->resrc,5))),
   (dummyt d2  WITH seq = value(data->maxlabel))
  PLAN (d1
   WHERE 1 <= d1.seq)
   JOIN (d2
   WHERE d2.seq <= size(data->resrc[d1.seq].label,5))
  HEAD REPORT
   lcnt = 0
  DETAIL
   lcnt = (lcnt+ 1), stat = alterlist(label->qual,lcnt), label->qual[lcnt].line[1].data = data->
   resrc[d1.seq].label[d2.seq].mrn_alias,
   label->qual[lcnt].line[2].data = data->resrc[d1.seq].label[d2.seq].name_full_formatted, label->
   qual[lcnt].line[3].data = data->resrc[d1.seq].label[d2.seq].sex_disp, label->qual[lcnt].line[4].
   data = data->resrc[d1.seq].label[d2.seq].birth_dt_tm_string,
   label->qual[lcnt].line[5].data = data->resrc[d1.seq].label[d2.seq].age, label->qual[lcnt].line[6].
   data = data->resrc[d1.seq].label[d2.seq].acc_site_pre_yy_nbr, label->qual[lcnt].line[7].data =
   data->resrc[d1.seq].label[d2.seq].accession_nbr,
   label->qual[lcnt].line[8].data = data->resrc[d1.seq].label[d2.seq].case_specimen_tag_disp, label->
   qual[lcnt].line[9].data = data->resrc[d1.seq].label[d2.seq].specimen_description, label->qual[lcnt
   ].line[10].data = data->resrc[d1.seq].label[d2.seq].case_collect_dt_tm_string,
   label->qual[lcnt].line[11].data = data->resrc[d1.seq].label[d2.seq].received_fixative_disp, label
   ->qual[lcnt].line[12].data = data->resrc[d1.seq].label[d2.seq].fixative_added_disp, label->qual[
   lcnt].line[13].data = data->resrc[d1.seq].label[d2.seq].requesting_physician_name_full,
   label->qual[lcnt].line[14].data = substring(1,15,data->current_dt_tm_string)
  WITH nocounter
 ;end select
 EXECUTE cpm_create_file_name_logical "aps_labelspec1l", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO reply->print_status_data.print_filename
  x = 0
  DETAIL
   nlab = 0
   FOR (nlab = 1 TO size(label->qual,5))
     row + 2, col 5, "          ID: ",
     col 20, label->qual[nlab].line[1].data, row + 1,
     col 5, "     Patient: ", col 20,
     label->qual[nlab].line[2].data, row + 1, col 5,
     "      Gender: ", col 20, label->qual[nlab].line[3].data,
     col 30, "DOB: ", col 35,
     label->qual[nlab].line[4].data, col 47, "Age: ",
     col 53, label->qual[nlab].line[5].data, row + 1,
     col 5, "        Case: ", col 20,
     label->qual[nlab].line[6].data, col 41, "Collected: ",
     col 53, label->qual[nlab].line[10].data, row + 1,
     col 5, "    Specimen: ", col 20,
     label->qual[nlab].line[8].data, col 25, label->qual[nlab].line[9].data,
     row + 1, col 5, "    Fixative: ",
     col 20, label->qual[nlab].line[11].data, col 40,
     " / ", col 43, label->qual[nlab].line[12].data,
     row + 1, col 5, "Requested by: ",
     col 20, label->qual[nlab].line[13].data
   ENDFOR
  WITH nocounter, check, noformfeed
 ;end select
END GO
