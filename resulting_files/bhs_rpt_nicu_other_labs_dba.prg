CREATE PROGRAM bhs_rpt_nicu_other_labs:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Enter Organism" = "CANDIDA ALBICANS"
  WITH outdev, start_date, end_date,
  s_organism
 FREE RECORD drec
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 FREE RECORD blob
 RECORD blob(
   1 person_id = f8
   1 cntblob = i4
   1 list[*]
     2 encntr_id = f8
     2 fin = vc
     2 mrn = vc
     2 person_id = f8
     2 event_cd = f8
     2 result_status_cd = f8
     2 result_dt = vc
     2 collect_dt = vc
     2 discharge_dt = vc
     2 dob = vc
     2 parent_event_id = f8
     2 event_id = f8
     2 blob_contents = vc
     2 source = vc
     2 organism = vc
     2 birth_wt = vc
     2 test_stat = i4
     2 compression_cd = f8
     2 gestage = i4
 )
 DECLARE mf_cs93_microbiology = f8 WITH constant(uar_get_code_by("DISPLAYKEY",93,"MICROBIOLOGY")),
 protect
 DECLARE mf_cs93_bacteriology = f8 WITH constant(uar_get_code_by("DISPLAYKEY",93,"BACTERIOLOGY")),
 protect
 DECLARE mf_cs53_doc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"DOC")), protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_cs48_active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 SELECT INTO "nl:"
  textlen_ceb_blob_contents = textlen(ceb.blob_contents)
  FROM clinical_event c,
   encounter e,
   code_value cv,
   encntr_alias ea,
   encntr_alias mrn,
   ce_specimen_coll ces,
   v500_event_set_explode ese,
   ce_blob ceb,
   person p
  PLAN (c
   WHERE c.event_class_cd=mf_cs53_doc
    AND c.event_tag != "In Error"
    AND c.valid_until_dt_tm > sysdate
    AND c.event_end_dt_tm BETWEEN cnvtdatetime( $START_DATE) AND cnvtdatetime( $END_DATE)
    AND c.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
   mf_cs8_active_cd))
   JOIN (ceb
   WHERE ceb.event_id=c.event_id
    AND ceb.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ceb.compression_cd=728.00)
   JOIN (ces
   WHERE ces.event_id=c.parent_event_id)
   JOIN (ese
   WHERE ese.event_set_cd IN (mf_cs93_microbiology, mf_cs93_bacteriology)
    AND ese.event_cd=c.event_cd
    AND ese.event_set_level=1)
   JOIN (e
   WHERE e.encntr_id=c.encntr_id
    AND e.active_status_cd=mf_cs48_active_cd)
   JOIN (cv
   WHERE cv.code_set=220
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate
    AND cv.display IN ("NICU")
    AND cv.code_value=e.loc_nurse_unit_cd)
   JOIN (ea
   WHERE ea.encntr_id=c.encntr_id
    AND ea.encntr_alias_type_cd=mf_cs319_fin_cd
    AND ea.end_effective_dt_tm > sysdate)
   JOIN (mrn
   WHERE mrn.encntr_id=c.encntr_id
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd
    AND mrn.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=c.person_id)
  ORDER BY c.person_id, c.encntr_id
  HEAD REPORT
   stat = alterlist(blob->list,10)
  DETAIL
   blob->cntblob += 1
   IF (mod(blob->cntblob,10)=1
    AND (blob->cntblob > 1))
    stat = alterlist(blob->list,(blob->cntblob+ 9))
   ENDIF
   blob->list[blob->cntblob].encntr_id = c.encntr_id, blob->list[blob->cntblob].mrn = trim(mrn.alias,
    3), blob->list[blob->cntblob].fin = trim(ea.alias,3),
   blob->list[blob->cntblob].event_cd = c.event_cd, blob->list[blob->cntblob].result_status_cd = c
   .result_status_cd, blob->list[blob->cntblob].result_dt = format(c.clinsig_updt_dt_tm,
    "@SHORTDATETIMENOSEC"),
   blob->list[blob->cntblob].collect_dt = format(ces.collect_dt_tm,"@SHORTDATETIMENOSEC"), blob->
   list[blob->cntblob].discharge_dt = format(e.disch_dt_tm,"@SHORTDATETIMENOSEC"), blob->list[blob->
   cntblob].parent_event_id = c.parent_event_id,
   blob->list[blob->cntblob].event_id = c.event_id, blob->list[blob->cntblob].source = trim(
    uar_get_code_display(ces.source_type_cd),3), blob->list[blob->cntblob].dob = trim(datebirthformat
    (p.birth_dt_tm,p.birth_tz,p.birth_prec_flag,"@SHORTDATETIME"),3)
   IF (ceb.compression_cd=uar_get_code_by("MEANING",120,"OCFCOMP"))
    blob->list[blob->cntblob].compression_cd = ceb.compression_cd, blobout = fillstring(32000," "),
    blob_return_len = 0,
    CALL uar_ocf_uncompress(ceb.blob_contents,textlen_ceb_blob_contents,blobout,size(blobout),
    blob_return_len), blobout = substring(findstring("CULTURE :",blobout,1,0),32000,blobout), blobout
     = substring(1,(findstring(char(10),blobout,1,0) - 1),blobout)
    IF (findstring("This",blobout,1,0) > 0)
     blobout = substring(1,(findstring("This",blobout,1,0) - 1),blobout)
    ELSEIF (findstring(".",blobout,1,0) > 0)
     blobout = substring(1,(findstring(".",blobout,1,0) - 1),blobout)
    ELSEIF (findstring("These ",blobout,1,0) > 0)
     blobout = substring(1,(findstring(".",blobout,1,0) - 1),blobout)
    ENDIF
    blob->list[blob->cntblob].blob_contents = blobout, blob->list[blob->cntblob].organism = replace(
     replace(substring(textlen("{CULTURE : "),255,blobout),char(10),""),char(13),"")
    IF (((findstring("NO GROWTH",blob->list[blob->cntblob].organism,1,0) > 0) OR ((((blob->list[blob
    ->cntblob].organism=null)) OR (((findstring("NO ANAEROBES ISOLATED",blob->list[blob->cntblob].
     organism,1,0) > 0) OR (findstring("No significant microorganisms isolated",blob->list[blob->
     cntblob].organism,1,0) > 0)) )) )) )
     blob->list[blob->cntblob].test_stat = 0
    ELSE
     blob->list[blob->cntblob].test_stat = 1
    ENDIF
   ELSE
    len = findstring("ocf_blob",trim(ceb.blob_contents),1,0)
    IF (len > 0)
     blobout = trim(substring(1,(len - 1),trim(ceb.blob_contents)))
    ELSE
     blobout = trim(ceb.blob_contents)
    ENDIF
    blobout = substring(findstring("CULTURE :",blobout,1,0),32000,blobout), blobout = substring(1,(
     findstring(".",blobout,1,0) - 1),blobout), blob->list[blob->cntblob].blob_contents = blobout
   ENDIF
  FOOT REPORT
   stat = alterlist(blob->list,blob->cntblob)
  WITH nocounter, time = 300
 ;end select
 CALL echorecord(blob)
 SELECT INTO  $OUTDEV
  mrn = substring(1,30,blob->list[d1.seq].mrn), dob = blob->list[d1.seq].dob, source = substring(1,30,
   blob->list[d1.seq].source),
  collection_date = substring(1,30,blob->list[d1.seq].collect_dt), result_date = substring(1,30,blob
   ->list[d1.seq].result_dt), organism = substring(1,100,blob->list[d1.seq].organism),
  discharge_date = substring(1,30,blob->list[d1.seq].discharge_dt)
  FROM (dummyt d1  WITH seq = size(blob->list,5))
  PLAN (d1
   WHERE (blob->list[d1.seq].test_stat=1)
    AND cnvtupper(blob->list[d1.seq].organism)=concat("*",cnvtupper( $S_ORGANISM),"*"))
  WITH nocounter, separator = " ", format
 ;end select
END GO
