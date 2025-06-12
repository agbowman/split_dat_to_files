CREATE PROGRAM aps_get_folder_entity_detail:dba
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
 SUBROUTINE (formatage(birth_dt_tm=f8,deceased_dt_tm=f8,policy=vc) =vc WITH protect)
   DECLARE eff_end_dt_tm = f8 WITH private, noconstant(0.0)
   SET eff_end_dt_tm = deceased_dt_tm
   IF (((eff_end_dt_tm=null) OR (eff_end_dt_tm=0.00)) )
    SET eff_end_dt_tm = cnvtdatetime(sysdate)
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
 RECORD reply(
   1 image_qual[*]
     2 entity_id = f8
     2 entity_type_flag = i2
     2 parent_entity_id = f8
     2 parent_entity_name = c32
     2 blob_ref_id = f8
     2 event_id = f8
     2 sequence_nbr = i4
     2 owner_cd = f8
     2 storage_cd = f8
     2 format_cd = f8
     2 blob_handle = vc
     2 blob_title = vc
     2 tbnl_long_blob_id = f8
     2 tbnl_format_cd = f8
     2 long_blob = vgc
     2 create_prsnl_id = f8
     2 create_prsnl_name = vc
     2 source_device_cd = f8
     2 source_device_disp = c40
     2 chartable_note = vc
     2 chartable_note_id = f8
     2 chartable_note_updt_cnt = i4
     2 non_chartable_note = vc
     2 non_chartable_note_id = f8
     2 non_chartable_note_updt_cnt = i4
     2 publish_flag = i2
     2 valid_from_dt_tm = dq8
     2 updt_id = f8
     2 updt_cnt = i4
     2 blob_foreign_ident = vc
   1 accession_qual[*]
     2 case_id = f8
     2 accession_nbr = c20
     2 encounter_id = f8
     2 case_collect_dt_tm = dq8
     2 responsible_pathologist_id = f8
     2 responsible_pathologist_name = vc
     2 person_id = f8
     2 person_name = vc
     2 person_num = c16
     2 sex_cd = f8
     2 sex_disp = c40
     2 birth_dt_tm = dq8
     2 deceased_dt_tm = dq8
     2 age = vc
     2 birth_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET entitycnt = cnvtint(size(request->entity_qual,5))
 SET entityindex = 0
 SET imagecnt = 0
 SET casecnt = 0
 SET caseindex = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET mrn_alias_type_cd = 0.0
 SET author_type_cd = 0.0
 SET deleted_status_cd = 0.0
 SET chartable_note_cd = 0.0
 SET non_chartable_note_cd = 0.0
 SET ocf_compression_cd = 0.0
 SET tempblobsize = 0
 SET ap_foreign_image_ident_note_cd = 0.0
 DECLARE outbufmaxsiz = i2
 DECLARE tblobin = c32000
 DECLARE tblobout = c32000
 DECLARE blobin = c32000
 DECLARE blobout = c32000
 SUBROUTINE decompress_text(tblobin)
   SET tblobout = fillstring(32000," ")
   SET blobout = fillstring(32000," ")
   SET outbufmaxsiz = 0
   SET blobin = trim(tblobin)
   CALL uar_ocf_uncompress(blobin,size(blobin),blobout,size(blobout),outbufmaxsiz)
   SET tblobout = blobout
   SET tblobin = fillstring(32000," ")
   SET blobin = fillstring(32000," ")
 END ;Subroutine
 SET code_set = 21
 SET cdf_meaning = "AUTHOR"
 EXECUTE cpm_get_cd_for_cdf
 SET author_type_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 SET code_set = 48
 SET cdf_meaning = "DELETED"
 EXECUTE cpm_get_cd_for_cdf
 SET deleted_status_cd = code_value
 SET code_set = 120
 SET cdf_meaning = "OCFCOMP"
 EXECUTE cpm_get_cd_for_cdf
 SET ocf_compression_cd = code_value
 SET code_set = 14
 SET cdf_meaning = "APIMGCHART"
 EXECUTE cpm_get_cd_for_cdf
 SET chartable_note_cd = code_value
 SET code_set = 14
 SET cdf_meaning = "APNOIMGCHART"
 EXECUTE cpm_get_cd_for_cdf
 SET non_chartable_note_cd = code_value
 SET code_set = 14
 SET cdf_meaning = "APIMGFRGNID"
 EXECUTE cpm_get_cd_for_cdf
 SET ap_foreign_image_ident_note_cd = code_value
 SELECT INTO "nl:"
  ce.event_id, cbr.event_id, cbs.ce_blob_summary_id,
  lb.long_blob_id, cep.action_prsnl_id, p.person_id,
  cen.ce_event_note_id, lt.long_blob_id
  FROM clinical_event ce,
   ce_blob_result cbr,
   ce_blob_summary cbs,
   long_blob lb,
   ce_event_prsnl cep,
   ce_event_note cen,
   long_blob lt,
   prsnl p,
   (dummyt d1  WITH seq = value(entitycnt)),
   (dummyt d2  WITH seq = 1)
  PLAN (d1)
   JOIN (ce
   WHERE (ce.event_id=request->entity_qual[d1.seq].parent_entity_id)
    AND (request->entity_qual[d1.seq].parent_entity_name="CLINICAL_EVENT")
    AND ce.valid_from_dt_tm < cnvtdatetime(sysdate)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.record_status_cd != deleted_status_cd)
   JOIN (cbr
   WHERE cbr.event_id=ce.event_id
    AND cbr.valid_from_dt_tm < cnvtdatetime(sysdate)
    AND cbr.valid_until_dt_tm > cnvtdatetime(sysdate))
   JOIN (cbs
   WHERE cbs.event_id=ce.event_id
    AND cbs.valid_from_dt_tm < cnvtdatetime(sysdate)
    AND cbs.valid_until_dt_tm > cnvtdatetime(sysdate))
   JOIN (lb
   WHERE lb.parent_entity_id=cbs.ce_blob_summary_id
    AND lb.parent_entity_name="CE_BLOB_SUMMARY")
   JOIN (cep
   WHERE cep.event_id=ce.event_id
    AND cep.valid_from_dt_tm < cnvtdatetime(sysdate)
    AND cep.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND cep.action_type_cd=author_type_cd)
   JOIN (p
   WHERE p.person_id=cep.action_prsnl_id)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (cen
   WHERE cen.event_id=ce.event_id
    AND cen.valid_from_dt_tm < cnvtdatetime(sysdate)
    AND cen.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND cen.record_status_cd != deleted_status_cd)
   JOIN (lt
   WHERE lt.parent_entity_id=cen.ce_event_note_id
    AND lt.parent_entity_name="CE_EVENT_NOTE")
  ORDER BY ce.event_id
  HEAD REPORT
   imagecnt = 0
  HEAD ce.event_id
   imagecnt += 1
   IF (mod(imagecnt,10)=1)
    stat = alterlist(reply->image_qual,(imagecnt+ 9))
   ENDIF
   reply->image_qual[imagecnt].entity_id = request->entity_qual[d1.seq].entity_id, reply->image_qual[
   imagecnt].entity_type_flag = request->entity_qual[d1.seq].entity_type_flag, reply->image_qual[
   imagecnt].parent_entity_id = request->entity_qual[d1.seq].parent_entity_id,
   reply->image_qual[imagecnt].parent_entity_name = request->entity_qual[d1.seq].parent_entity_name,
   reply->image_qual[imagecnt].blob_ref_id = ce.clinical_event_id, reply->image_qual[imagecnt].
   event_id = ce.event_id,
   reply->image_qual[imagecnt].sequence_nbr = cnvtint(ce.collating_seq), reply->image_qual[imagecnt].
   source_device_cd = cbr.device_cd, reply->image_qual[imagecnt].storage_cd = cbr.storage_cd,
   reply->image_qual[imagecnt].format_cd = cbr.format_cd, reply->image_qual[imagecnt].blob_handle =
   cbr.blob_handle, reply->image_qual[imagecnt].blob_title = ce.event_title_text,
   reply->image_qual[imagecnt].tbnl_long_blob_id = cbs.ce_blob_summary_id, reply->image_qual[imagecnt
   ].tbnl_format_cd = cbs.format_cd, reply->image_qual[imagecnt].create_prsnl_id = p.person_id,
   reply->image_qual[imagecnt].create_prsnl_name = p.name_full_formatted, reply->image_qual[imagecnt]
   .publish_flag = ce.publish_flag, reply->image_qual[imagecnt].valid_from_dt_tm = ce
   .valid_from_dt_tm
   IF (cbs.compression_cd=ocf_compression_cd)
    tempblobsize = 0, outbufmaxsiz = 0,
    CALL uar_ocf_uncompress(lb.long_blob,size(lb.long_blob),reply->image_qual[imagecnt].long_blob,
    tempblobsize,outbufmaxsiz)
   ELSE
    reply->image_qual[imagecnt].long_blob = lb.long_blob
   ENDIF
  DETAIL
   IF (cen.note_type_cd=chartable_note_cd)
    IF (cen.compression_cd=ocf_compression_cd)
     tempblobsize = 0, outbufmaxsiz = 0,
     CALL uar_ocf_uncompress(lt.long_blob,size(lt.long_blob),reply->image_qual[imagecnt].
     chartable_note,tempblobsize,outbufmaxsiz)
    ELSE
     reply->image_qual[imagecnt].chartable_note = substring(1,(size(trim(lt.long_blob)) - 8),lt
      .long_blob)
    ENDIF
    reply->image_qual[imagecnt].chartable_note_id = lt.long_blob_id, reply->image_qual[imagecnt].
    chartable_note_updt_cnt = lt.updt_cnt
   ELSEIF (cen.note_type_cd=non_chartable_note_cd)
    IF (cen.compression_cd=ocf_compression_cd)
     tempblobsize = 0, outbufmaxsiz = 0,
     CALL uar_ocf_uncompress(lt.long_blob,size(lt.long_blob),reply->image_qual[imagecnt].
     non_chartable_note,tempblobsize,outbufmaxsiz)
    ELSE
     reply->image_qual[imagecnt].non_chartable_note = substring(1,(size(trim(lt.long_blob)) - 8),lt
      .long_blob)
    ENDIF
    reply->image_qual[imagecnt].non_chartable_note_id = lt.long_blob_id, reply->image_qual[imagecnt].
    non_chartable_note_updt_cnt = lt.updt_cnt
   ELSEIF (cen.note_type_cd=ap_foreign_image_ident_note_cd)
    IF (cen.compression_cd=ocf_compression_cd)
     tempblobsize = 0, outbufmaxsiz = 0,
     CALL uar_ocf_uncompress(lt.long_blob,size(lt.long_blob),reply->image_qual[imagecnt].
     blob_foreign_ident,tempblobsize,outbufmaxsiz)
    ELSE
     reply->image_qual[imagecnt].blob_foreign_ident = substring(1,(size(trim(lt.long_blob)) - 8),lt
      .long_blob)
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->image_qual,imagecnt)
  WITH nocounter, memsort, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  br.blob_ref_id, bsr.blob_ref_id, p.person_id,
  lb.long_blob_id, lt.long_text_id, lt2.long_text_id
  FROM blob_reference br,
   blob_summary_ref bsr,
   prsnl p,
   long_blob lb,
   long_text lt,
   long_text lt2,
   (dummyt d1  WITH seq = value(entitycnt))
  PLAN (d1)
   JOIN (br
   WHERE (br.blob_ref_id=request->entity_qual[d1.seq].parent_entity_id)
    AND (request->entity_qual[d1.seq].parent_entity_name="BLOB_REFERENCE"))
   JOIN (bsr
   WHERE br.blob_ref_id=bsr.blob_ref_id)
   JOIN (p
   WHERE br.create_prsnl_id=p.person_id)
   JOIN (lb
   WHERE lb.long_blob_id=bsr.long_blob_id)
   JOIN (lt
   WHERE lt.long_text_id=br.chartable_note_id)
   JOIN (lt2
   WHERE lt2.long_text_id=br.non_chartable_note_id)
  DETAIL
   imagecnt += 1
   IF (mod(imagecnt,10))
    stat = alterlist(reply->image_qual,(imagecnt+ 9))
   ENDIF
   reply->image_qual[imagecnt].entity_id = request->entity_qual[d1.seq].entity_id, reply->image_qual[
   imagecnt].entity_type_flag = request->entity_qual[d1.seq].entity_type_flag, reply->image_qual[
   imagecnt].parent_entity_id = request->entity_qual[d1.seq].parent_entity_id,
   reply->image_qual[imagecnt].parent_entity_name = request->entity_qual[d1.seq].parent_entity_name,
   reply->image_qual[imagecnt].blob_ref_id = br.blob_ref_id, reply->image_qual[imagecnt].sequence_nbr
    = br.sequence_nbr,
   reply->image_qual[imagecnt].owner_cd = br.owner_cd, reply->image_qual[imagecnt].storage_cd = br
   .storage_cd, reply->image_qual[imagecnt].format_cd = br.format_cd,
   reply->image_qual[imagecnt].blob_handle = br.blob_handle, reply->image_qual[imagecnt].blob_title
    = br.blob_title, reply->image_qual[imagecnt].tbnl_long_blob_id = bsr.long_blob_id,
   reply->image_qual[imagecnt].tbnl_format_cd = bsr.format_cd, reply->image_qual[imagecnt].
   create_prsnl_id = br.create_prsnl_id, reply->image_qual[imagecnt].create_prsnl_name = p
   .name_full_formatted,
   reply->image_qual[imagecnt].source_device_cd = br.source_device_cd, reply->image_qual[imagecnt].
   chartable_note_id = lt.long_text_id
   IF (lt.long_text_id > 0)
    reply->image_qual[imagecnt].chartable_note = lt.long_text, reply->image_qual[imagecnt].
    chartable_note_updt_cnt = lt.updt_cnt
   ELSE
    reply->image_qual[imagecnt].chartable_note = "", reply->image_qual[imagecnt].
    chartable_note_updt_cnt = 0
   ENDIF
   reply->image_qual[imagecnt].non_chartable_note_id = lt2.long_text_id
   IF (lt2.long_text_id > 0)
    reply->image_qual[imagecnt].non_chartable_note = lt2.long_text, reply->image_qual[imagecnt].
    non_chartable_note_updt_cnt = lt2.updt_cnt
   ELSE
    reply->image_qual[imagecnt].non_chartable_note = "", reply->image_qual[imagecnt].
    non_chartable_note_updt_cnt = 0
   ENDIF
   reply->image_qual[imagecnt].publish_flag = br.publish_flag, reply->image_qual[imagecnt].
   valid_from_dt_tm = br.valid_from_dt_tm, reply->image_qual[imagecnt].updt_id = br.updt_id,
   reply->image_qual[imagecnt].updt_cnt = br.updt_cnt, reply->image_qual[imagecnt].long_blob = lb
   .long_blob, reply->image_qual[imagecnt].blob_foreign_ident = br.blob_foreign_ident
  FOOT REPORT
   stat = alterlist(reply->image_qual,imagecnt)
  WITH nocounter, memsort
 ;end select
 SELECT INTO "nl:"
  pc.case_id, p.person_id, pr1.person_id,
  ea.encntr_id, ea_ind = decode(ea.seq,1,0), frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
  FROM pathology_case pc,
   person p,
   prsnl pr1,
   (dummyt d1  WITH seq = value(entitycnt)),
   encntr_alias ea,
   (dummyt d2  WITH seq = 1)
  PLAN (d1)
   JOIN (pc
   WHERE (pc.case_id=request->entity_qual[d1.seq].parent_entity_id)
    AND (request->entity_qual[d1.seq].parent_entity_name="PATHOLOGY_CASE"))
   JOIN (p
   WHERE pc.person_id=p.person_id)
   JOIN (pr1
   WHERE pc.responsible_pathologist_id=pr1.person_id)
   JOIN (d2)
   JOIN (ea
   WHERE ea.encntr_id=pc.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  HEAD REPORT
   casecnt = 0, stat = alterlist(reply->accession_qual,10)
  DETAIL
   casecnt += 1
   IF (mod(casecnt,10)=1
    AND casecnt != 1)
    stat = alterlist(reply->accession_qual,(casecnt+ 9))
   ENDIF
   reply->accession_qual[casecnt].accession_nbr = pc.accession_nbr, reply->accession_qual[casecnt].
   encounter_id = pc.encntr_id, reply->accession_qual[casecnt].case_id = pc.case_id,
   reply->accession_qual[casecnt].case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm), reply->
   accession_qual[casecnt].person_id = p.person_id, reply->accession_qual[casecnt].person_name = p
   .name_full_formatted
   IF (ea_ind=1)
    reply->accession_qual[casecnt].person_num = frmt_mrn
   ELSE
    reply->accession_qual[casecnt].person_num = "Unknown"
   ENDIF
   reply->accession_qual[casecnt].sex_cd = p.sex_cd
   IF (curutc=1)
    reply->accession_qual[casecnt].age = formatage(datetimezone(p.birth_dt_tm,p.birth_tz),p
     .deceased_dt_tm,"CHRONOAGE")
   ELSE
    reply->accession_qual[casecnt].age = formatage(p.birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE")
   ENDIF
   reply->accession_qual[casecnt].birth_dt_tm = cnvtdatetime(p.birth_dt_tm), reply->accession_qual[
   casecnt].birth_tz = p.birth_tz, reply->accession_qual[casecnt].deceased_dt_tm = cnvtdatetime(p
    .deceased_dt_tm),
   reply->accession_qual[casecnt].responsible_pathologist_id = pc.responsible_pathologist_id, reply->
   accession_qual[casecnt].responsible_pathologist_name = pr1.name_full_formatted
  FOOT REPORT
   stat = alterlist(reply->accession_qual,casecnt)
  WITH nocounter, outerjoin = d2
 ;end select
 IF (((imagecnt+ casecnt)=0))
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PC And BR And CE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
