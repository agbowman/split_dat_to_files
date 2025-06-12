CREATE PROGRAM aps_get_health_facts_info:dba
 SET modify = predeclare
 RECORD ap_specimens(
   1 qual[*]
     2 specimen_id = f8
     2 case_index = i4
 )
 RECORD ap_events(
   1 qual[*]
     2 event_id = f8
     2 case_index = i4
     2 report_index = i4
 )
 RECORD icd9_list(
   1 qual[*]
     2 icd9_code = vc
 )
 RECORD case_icd9(
   1 cases[*]
     2 case_id = f8
     2 clinical_codes[*]
       3 icd9_code = vc
     2 billing_codes[*]
       3 icd9_code = vc
 )
 IF ( NOT (validate(scd_request,0)))
  RECORD scd_request(
    1 source_vocabulary_cd = f8
    1 qual[*]
      2 scd_story_id = f8
      2 index = i4
      2 other_data = vc
  )
 ENDIF
 IF ( NOT (validate(scd_reply,0)))
  RECORD scd_reply(
    1 max_term_cnt = i4
    1 qual[*]
      2 scd_story_id = f8
      2 index = i4
      2 other_data = vc
      2 terms[*]
        3 term_truth_cd = f8
        3 value_dt_tm = dq8
        3 value_number = f8
        3 value_text = vc
        3 value_units_cd = f8
        3 source_identifier = vc
        3 source_vocabulary_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 RECORD tmptext(
   1 qual[*]
     2 text = vc
 )
 DECLARE rtf_to_text(rtftext=vc,format=i2,line_len=i2) = null
 DECLARE format = i2
 DECLARE line_len = i2
 DECLARE outbuffer = c32000
 DECLARE rtftext = c32000
 DECLARE nortftext = c32000
 SET format = 0
 SET line_len = 0
 SUBROUTINE rtf_to_text(rtftext,format,line_len)
   SET all_len = 0
   SET start = 0
   SET len = 0
   SET pos = 0
   SET linecnt = 0
   SET inbuffer = fillstring(32000," ")
   SET outbufferlen = 0
   SET bfl = 0
   SET bfl2 = 1
   SET outbuffer = fillstring(32000," ")
   SET nortftext = fillstring(32000," ")
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
        SET pos = ((start+ line_len) - 1)
        IF (bigfirst="Y"
         AND pos >= all_len)
         SET pos = start
        ENDIF
        SET bigfirst = "N"
        WHILE (pos >= start
         AND all_len > tot_len)
          IF (pos=start)
           SET pos = ((start+ line_len) - 1)
           SET linecnt = (linecnt+ 1)
           SET stat = alterlist(tmptext->qual,linecnt)
           SET len = ((pos - start)+ 1)
           SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
           SET start = (pos+ 1)
           SET crstart = (pos+ 1)
           SET pos = 0
           SET tot_len = ((tot_len+ len) - 1)
           SET loaded = "Y"
          ELSE
           IF (substring(pos,1,outbuffer)=" ")
            SET len = (pos - start)
            IF (cnvtint(size(trim(substring(start,len,outbuffer)))) > 0)
             SET linecnt = (linecnt+ 1)
             SET stat = alterlist(tmptext->qual,linecnt)
             SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
             SET loaded = "Y"
            ENDIF
            SET start = (pos+ 1)
            SET crstart = (pos+ 1)
            SET pos = 0
            SET tot_len = (tot_len+ len)
           ELSE
            IF (first="Y")
             SET first = "N"
             SET tot_len = (tot_len+ 1)
            ENDIF
            SET pos = (pos - 1)
           ENDIF
          ENDIF
        ENDWHILE
       ELSE
        SET crfirst = "N"
        IF (((substring(crpos,1,outbuffer)=crchar) OR (((substring(crpos,1,outbuffer)=lfchar) OR (
        substring(crpos,1,outbuffer)=ffchar)) )) )
         SET crlen = (crpos - crstart)
         SET linecnt = (linecnt+ 1)
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
         SET tot_len = (tot_len+ crlen)
        ENDIF
       ENDIF
       SET crpos = (crpos+ 1)
      ENDWHILE
    ENDWHILE
   ENDIF
   SET rtftext = fillstring(32000," ")
   SET inbuffer = fillstring(32000," ")
 END ;Subroutine
 DECLARE decompress_text(tblobin=vc) = null
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
 DECLARE nsubdummy = i2 WITH protect, noconstant(0)
 DECLARE dverifiedstatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE dcorrectedstatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE daccnicdcd = f8 WITH protect, noconstant(0.0)
 DECLARE ddoceventcd = f8 WITH protect, noconstant(0.0)
 DECLARE dcompressedcd = f8 WITH protect, noconstant(0.0)
 DECLARE dsnomedctcd = f8 WITH protect, noconstant(0.0)
 DECLARE lx = i4 WITH protect, noconstant(0)
 DECLARE lidx1 = i4 WITH protect, noconstant(0)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 DECLARE lbegidx = i4 WITH protect, noconstant(0)
 DECLARE lendidx = i4 WITH protect, noconstant(0)
 DECLARE lreplycnt = i4 WITH protect, noconstant(0)
 DECLARE lreplybatchcnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE addicd9toreply(reply_case_idx=i4,icd9_to_add=vc) = null WITH private
 DECLARE ap_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"AP"))
 DECLARE billcode_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13019,"BILL CODE"))
 DECLARE deleted_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"DELETED"))
 DECLARE icd9_filename = c30 WITH protect, constant("CER_DATA_DATA:hf_icd9_list.txt")
 DECLARE icd9_indx = i4 WITH protect, noconstant(0)
 DECLARE case_icd9_indx = i4 WITH protect, noconstant(0)
 DECLARE case_icd9_cnt = i4 WITH protect, noconstant(0)
 DECLARE clin_icd9_cnt = i2 WITH protect, noconstant(0)
 DECLARE bill_icd9_cnt = i2 WITH protect, noconstant(0)
 DECLARE reply_icd9_cnt = i2 WITH protect, noconstant(0)
 DECLARE icd9_list_cnt = i2 WITH protect, noconstant(0)
 DECLARE icd9_to_find = c50 WITH protect, noconstant("")
 DECLARE found_indx = i4 WITH protect, noconstant(0)
 DECLARE dummy_indx = i4 WITH protect, noconstant(0)
 DECLARE codevalue = f8 WITH protect, noconstant(0.0)
 DECLARE icd9_code_values = vc WITH protect, noconstant("")
 DECLARE meaningval = vc WITH protect, constant("ICD9")
 DECLARE codeset = i4 WITH protect, constant(14002)
 DECLARE cvct = i4 WITH protect, noconstant(0)
 DECLARE iret = i4 WITH protect, noconstant(0)
 DECLARE napmillenium = i2 WITH protect, constant(3)
 DECLARE ssystemgenerated = c10 WITH protect, constant("SYSTEM")
 DECLARE saccession = c10 WITH protect, constant("ACCESSION")
 DECLARE ncompleted = i2 WITH protect, constant(2)
 DECLARE lmaxtextsize = i4 WITH protect, constant(31000)
 DECLARE lbatchsize = i4 WITH protect, constant(100)
 SET stat = uar_get_meaning_by_codeset(1305,"VERIFIED",1,dverifiedstatuscd)
 IF (stat=1)
  CALL subevent_add("UAR","F","UAR","CODE_VALUE (1305 - VERIFIED)")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"CORRECTED",1,dcorrectedstatuscd)
 IF (stat=1)
  CALL subevent_add("UAR","F","UAR","CODE_VALUE (1305 - CORRECTED)")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(23549,"ACCNICD9",1,daccnicdcd)
 IF (stat=1)
  CALL subevent_add("UAR","F","UAR","CODE_VALUE (23549 - ACCNICD)")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(53,"DOC",1,ddoceventcd)
 IF (stat=1)
  CALL subevent_add("UAR","F","UAR","CODE_VALUE (53 - DOC)")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,dcompressedcd)
 IF (stat=1)
  CALL subevent_add("UAR","F","UAR","CODE_VALUE (120 - OCFCOMP)")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(400,"SNMCT",1,dsnomedctcd)
 IF (stat=1)
  CALL subevent_add("UAR","F","UAR","CODE_VALUE (400 - SNMCT)")
  GO TO exit_script
 ENDIF
 SET modify = cnvtage(7,5,36)
 SET reply->extract_dt_tm = cnvtdatetime(curdate,curtime3)
 SET reply->source_cd = napmillenium
 CALL retrievereports(0)
 SET lreplycnt = size(reply->cases,5)
 IF (lreplycnt > 0)
  SET lreplybatchcnt = (((lreplycnt - 1)/ lbatchsize)+ 1)
  CALL retrievecaseinfo(0)
  CALL retrievespecimens(0)
  CALL retrievesynoptic(0)
  FREE RECORD ap_specimens
 ENDIF
 IF (size(reply->cases,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 DECLARE retrievereports(nsubdummy) = null WITH private
 SUBROUTINE retrievereports(nsubdummy)
   DECLARE lbatchcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    cr.event_id
    FROM case_report cr,
     clinical_event ce,
     ce_blob ceb
    PLAN (cr
     WHERE cr.status_dt_tm BETWEEN cnvtdatetime(date_range->beg_dt_tm) AND cnvtdatetime(date_range->
      end_dt_tm)
      AND cr.status_cd IN (dverifiedstatuscd, dcorrectedstatuscd))
     JOIN (ce
     WHERE ce.parent_event_id=cr.event_id
      AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND ce.event_class_cd=ddoceventcd
      AND ce.record_status_cd != deleted_cd)
     JOIN (ceb
     WHERE ceb.event_id=ce.event_id
      AND ceb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    ORDER BY cr.case_id, cr.report_id, ce.event_id,
     ceb.blob_seq_num
    HEAD REPORT
     lcasecnt = 0, lreportcnt = 0, lsectioncnt = 0,
     leventcnt = 0
    HEAD cr.case_id
     lreportcnt = 0, lcasecnt = (lcasecnt+ 1)
     IF (size(reply->cases,5) < lcasecnt)
      stat = alterlist(reply->cases,(lcasecnt+ 9))
     ENDIF
     reply->cases[lcasecnt].case_id = cr.case_id
    HEAD cr.report_id
     lsectioncnt = 0, lreportcnt = (lreportcnt+ 1)
     IF ((lreportcnt > reply->max_report_cnt))
      reply->max_report_cnt = lreportcnt
     ENDIF
     stat = alterlist(reply->cases[lcasecnt].reports,lreportcnt), reply->cases[lcasecnt].reports[
     lreportcnt].report_id = cr.report_id, reply->cases[lcasecnt].reports[lreportcnt].order_nbr = cr
     .catalog_cd,
     reply->cases[lcasecnt].reports[lreportcnt].report_type_cd = cr.catalog_cd, reply->cases[lcasecnt
     ].reports[lreportcnt].report_verified_dt_tm = cr.status_dt_tm, reply->cases[lcasecnt].reports[
     lreportcnt].report_sequence = cr.report_sequence
    HEAD ce.event_id
     lsectioncnt = (lsectioncnt+ 1)
     IF (size(reply->cases[lcasecnt].reports[lreportcnt].sections,5) < lsectioncnt)
      stat = alterlist(reply->cases[lcasecnt].reports[lreportcnt].sections,(lsectioncnt+ 5))
     ENDIF
     reply->cases[lcasecnt].reports[lreportcnt].sections[lsectioncnt].section_type_cd = ce
     .task_assay_cd, leventcnt = (leventcnt+ 1)
     IF (size(ap_events->qual,5) < leventcnt)
      stat = alterlist(ap_events->qual,(leventcnt+ 9))
     ENDIF
     ap_events->qual[leventcnt].event_id = ce.event_id, ap_events->qual[leventcnt].case_index =
     lcasecnt, ap_events->qual[leventcnt].report_index = lreportcnt
    DETAIL
     IF (ceb.compression_cd=dcompressedcd)
      CALL decompress_text(ceb.blob_contents)
     ELSE
      tblobout = substring(1,textlen(trim(ceb.blob_contents)),ceb.blob_contents)
     ENDIF
     CALL rtf_to_text(trim(tblobout),0,0), reply->cases[lcasecnt].reports[lreportcnt].sections[
     lsectioncnt].section_text = substring(1,lmaxtextsize,concat(reply->cases[lcasecnt].reports[
       lreportcnt].sections[lsectioncnt].section_text,nortftext))
    FOOT  ce.event_id
     stat = alterlist(reply->cases[lcasecnt].reports[lreportcnt].sections,lsectioncnt)
    FOOT  cr.case_id
     stat = alterlist(reply->cases[lcasecnt].reports,lreportcnt)
    FOOT REPORT
     stat = alterlist(reply->cases,lcasecnt), stat = alterlist(ap_events->qual,leventcnt)
    WITH nocounter, memsort
   ;end select
   SET lbatchcnt = (((size(ap_events->qual,5) - 1)/ lbatchsize)+ 1)
   FOR (lx = 1 TO lbatchcnt)
     SET lbegidx = (((lx - 1) * lbatchsize)+ 1)
     SET lendidx = minval(((lbegidx+ lbatchsize) - 1),size(ap_events->qual,5))
     SELECT INTO "nl:"
      ccr.event_id
      FROM ce_coded_result ccr,
       nomenclature nom
      PLAN (ccr
       WHERE expand(lidx1,lbegidx,lendidx,ccr.event_id,ap_events->qual[lidx1].event_id,
        lbatchsize)
        AND ccr.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
       JOIN (nom
       WHERE nom.nomenclature_id=ccr.nomenclature_id)
      ORDER BY ccr.event_id
      HEAD REPORT
       lcaseidx = 0, lreportidx = 0, lsnomedcnt = 0
      HEAD ccr.event_id
       lidx2 = locateval(lidx1,lbegidx,lendidx,ccr.event_id,ap_events->qual[lidx1].event_id),
       lcaseidx = ap_events->qual[lidx2].case_index, lreportidx = ap_events->qual[lidx2].report_index,
       lsnomedcnt = size(reply->cases[lcaseidx].reports[lreportidx].snomed,5)
      DETAIL
       lsnomedcnt = (lsnomedcnt+ 1)
       IF (size(reply->cases[lcaseidx].reports[lreportidx].snomed,5) < lsnomedcnt)
        stat = alterlist(reply->cases[lcaseidx].reports[lreportidx].snomed,(lsnomedcnt+ 3))
       ENDIF
       reply->cases[lcaseidx].reports[lreportidx].snomed[lsnomedcnt].snomed_source_vocab_cd = nom
       .source_vocabulary_cd, reply->cases[lcaseidx].reports[lreportidx].snomed[lsnomedcnt].
       snomed_code = nom.source_identifier, reply->cases[lcaseidx].reports[lreportidx].snomed[
       lsnomedcnt].snomed_group_nbr = build(cnvtint(ccr.event_id),"^",ccr.group_nbr)
       IF (ccr.descriptor=ssystemgenerated)
        reply->cases[lcaseidx].reports[lreportidx].snomed[lsnomedcnt].auto_code_flag = 1
       ELSE
        reply->cases[lcaseidx].reports[lreportidx].snomed[lsnomedcnt].auto_code_flag = 0
       ENDIF
      FOOT  ccr.event_id
       stat = alterlist(reply->cases[lcaseidx].reports[lreportidx].snomed,lsnomedcnt)
      WITH nocounter
     ;end select
   ENDFOR
   FREE RECORD ap_events
 END ;Subroutine
 DECLARE retrievecaseinfo(nsubdummy) = null WITH private
 SUBROUTINE retrievecaseinfo(nsubdummy)
  FOR (lx = 1 TO lreplybatchcnt)
    SET lbegidx = (((lx - 1) * lbatchsize)+ 1)
    SET lendidx = minval(((lbegidx+ lbatchsize) - 1),lreplycnt)
    SELECT INTO "nl:"
     qa_ind = evaluate(nullind(qa.case_id),0,1,0), icd_ind = evaluate(nullind(ner.parent_entity_id),0,
      1,0)
     FROM pathology_case pc,
      encounter enc,
      person per,
      ap_qa_info qa,
      nomen_entity_reltn ner,
      nomenclature nom
     PLAN (pc
      WHERE expand(lidx1,lbegidx,lendidx,pc.case_id,reply->cases[lidx1].case_id,
       lbatchsize))
      JOIN (enc
      WHERE enc.encntr_id=pc.encntr_id)
      JOIN (per
      WHERE per.person_id=enc.person_id)
      JOIN (qa
      WHERE qa.case_id=outerjoin(pc.case_id)
       AND qa.active_ind=outerjoin(1))
      JOIN (ner
      WHERE ner.parent_entity_name=outerjoin(saccession)
       AND ner.parent_entity_id=outerjoin(pc.case_id)
       AND ner.active_ind=outerjoin(1)
       AND ner.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND ner.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
       AND ner.reltn_type_cd=outerjoin(daccnicdcd))
      JOIN (nom
      WHERE nom.nomenclature_id=outerjoin(ner.nomenclature_id))
     ORDER BY pc.case_id
     HEAD REPORT
      licdcnt = 0
     HEAD pc.case_id
      licdcnt = 0, lidx2 = locateval(lidx1,lbegidx,lendidx,pc.case_id,reply->cases[lidx1].case_id),
      reply->cases[lidx2].encntr_id = pc.encntr_id,
      reply->cases[lidx2].case_type_cd = pc.case_type_cd, reply->cases[lidx2].case_collect_dt_tm = pc
      .case_collect_dt_tm, reply->cases[lidx2].requesting_physician_id = pc.requesting_physician_id,
      reply->cases[lidx2].result_interpreter_id = pc.responsible_pathologist_id, reply->cases[lidx2].
      case_nbr = uar_fmt_accession(pc.accession_nbr,size(pc.accession_nbr,1)), reply->cases[lidx2].
      disch_dt_tm = enc.disch_dt_tm,
      reply->cases[lidx2].prefix_id = pc.prefix_id
      IF (qa_ind=1)
       reply->cases[lidx2].normalcy_cd = qa.flag_type_cd
      ENDIF
      IF (per.birth_dt_tm != null
       AND pc.case_collect_dt_tm != null
       AND per.birth_dt_tm <= pc.case_collect_dt_tm)
       age = cnvtupper(cnvtage(per.birth_dt_tm,pc.case_collect_dt_tm,0)), units_pos = findstring(
        "YEARS",age)
       IF (units_pos > 0)
        reply->cases[lidx2].age_in_years = cnvtint(substring(1,(units_pos - 2),age))
       ELSE
        reply->cases[lidx2].age_in_days = cnvtint(datetimediff(pc.case_collect_dt_tm,per.birth_dt_tm)
         )
        IF (findstring("M",age) > 0)
         IF (cnvtint(substring(1,3,age)) >= 24)
          reply->cases[lidx2].age_in_years = 2
         ELSEIF (cnvtint(substring(1,3,age)) > 11
          AND cnvtint(substring(1,3,age)) < 24)
          reply->cases[lidx2].age_in_years = 1
         ELSE
          reply->cases[lidx2].age_in_years = 0
         ENDIF
        ELSE
         reply->cases[lidx2].age_in_years = 0
        ENDIF
       ENDIF
      ENDIF
      clin_icd9_cnt = 0
     DETAIL
      IF (icd_ind=1)
       IF (clin_icd9_cnt=0)
        case_icd9_cnt = (case_icd9_cnt+ 1)
        IF (mod(case_icd9_cnt,10)=1)
         stat = alterlist(case_icd9->cases,(case_icd9_cnt+ 9))
        ENDIF
        case_icd9->cases[case_icd9_cnt].case_id = reply->cases[lidx2].case_id
       ENDIF
       clin_icd9_cnt = (clin_icd9_cnt+ 1), stat = alterlist(case_icd9->cases[case_icd9_cnt].
        clinical_codes,clin_icd9_cnt), case_icd9->cases[case_icd9_cnt].clinical_codes[clin_icd9_cnt].
       icd9_code = nom.source_identifier
      ENDIF
     WITH nocounter, orahint("first_rows")
    ;end select
  ENDFOR
  SELECT INTO "nl:"
   cr.case_id
   FROM (dummyt d  WITH seq = value(size(reply->cases,5))),
    case_report cr,
    prsnl p,
    prefix_report_r prr
   PLAN (d
    WHERE (reply->cases[d.seq].result_interpreter_id=0.0))
    JOIN (prr
    WHERE (prr.prefix_id=reply->cases[d.seq].prefix_id)
     AND prr.primary_ind=1)
    JOIN (cr
    WHERE cr.catalog_cd=prr.catalog_cd
     AND (cr.case_id=reply->cases[d.seq].case_id))
    JOIN (p
    WHERE p.person_id=cr.status_prsnl_id
     AND p.physician_ind=1)
   DETAIL
    reply->cases[d.seq].result_interpreter_id = cr.status_prsnl_id
   WITH nocounter
  ;end select
 END ;Subroutine
 SET stat = findfile(icd9_filename)
 IF (stat=0)
  SET icd9_list_cnt = 0
 ELSE
  FREE DEFINE rtl2
  DEFINE rtl2 value(icd9_filename)
  SELECT INTO "nl:"
   FROM rtl2t t
   HEAD REPORT
    icd9_list_cnt = 0
   DETAIL
    icd9_list_cnt = (icd9_list_cnt+ 1)
    IF (mod(icd9_list_cnt,10)=1)
     stat = alterlist(icd9_list->qual,(icd9_list_cnt+ 9))
    ENDIF
    icd9_list->qual[icd9_list_cnt].icd9_code = t.line
   FOOT REPORT
    stat = alterlist(icd9_list->qual,icd9_list_cnt)
   WITH nocounter, maxcol = 2000
  ;end select
 ENDIF
 SET cvct = 1
 SET iret = uar_get_meaning_by_codeset(codeset,nullterm(meaningval),cvct,codevalue)
 IF (iret=0)
  SET icd9_code_values = build(cnvtint(codevalue))
 ENDIF
 IF (cvct > 1)
  FOR (cvct2 = 2 TO cvct)
    SET i = cvct2
    SET iret = uar_get_meaning_by_codeset(codeset,nullterm(meaningval),i,codevalue)
    IF (iret=0)
     SET icd9_code_values = build(icd9_code_values,",",cnvtint(codevalue))
    ENDIF
  ENDFOR
 ENDIF
 FOR (lx = 1 TO lreplybatchcnt)
   SET lbegidx = (((lx - 1) * lbatchsize)+ 1)
   SET lendidx = minval(((lbegidx+ lbatchsize) - 1),lreplycnt)
   SELECT INTO "nl:"
    FROM pathology_case pc,
     charge_event ce,
     charge c,
     charge_mod cm
    PLAN (pc
     WHERE expand(lidx1,lbegidx,lendidx,pc.case_id,reply->cases[lidx1].case_id,
      lbatchsize))
     JOIN (ce
     WHERE ce.accession=trim(pc.accession_nbr)
      AND ce.active_ind=1)
     JOIN (c
     WHERE c.charge_event_id=ce.charge_event_id
      AND c.activity_type_cd=ap_cd
      AND c.active_ind=1)
     JOIN (cm
     WHERE cm.charge_item_id=c.charge_item_id
      AND cm.charge_mod_type_cd=billcode_cd
      AND parser(concat("cm.field1_id in(",icd9_code_values,")"))
      AND cm.active_ind=1)
    ORDER BY pc.case_id
    HEAD pc.case_id
     case_icd9_indx = locateval(dummy_indx,1,case_icd9_cnt,pc.case_id,case_icd9->cases[dummy_indx].
      case_id)
     IF (case_icd9_indx=0)
      case_indx = locateval(dummy_indx,1,size(reply->cases,5),pc.case_id,reply->cases[dummy_indx].
       case_id), case_icd9_cnt = (case_icd9_cnt+ 1)
      IF (mod(case_icd9_cnt,10)=1)
       stat = alterlist(case_icd9->cases,(case_icd9_cnt+ 9))
      ENDIF
      case_icd9->cases[case_icd9_cnt].case_id = reply->cases[case_indx].case_id, case_icd9_indx =
      case_icd9_cnt
     ENDIF
     bill_icd9_cnt = 0
    DETAIL
     bill_icd9_cnt = (bill_icd9_cnt+ 1), stat = alterlist(case_icd9->cases[case_icd9_indx].
      billing_codes,bill_icd9_cnt), case_icd9->cases[case_icd9_indx].billing_codes[bill_icd9_cnt].
     icd9_code = cm.field6
    WITH nocounter
   ;end select
 ENDFOR
 SET stat = alterlist(case_icd9->cases,case_icd9_cnt)
 FOR (i = 1 TO lreplycnt)
   SET case_icd9_indx = locateval(dummy_indx,1,case_icd9_cnt,reply->cases[i].case_id,case_icd9->
    cases[dummy_indx].case_id)
   SET reply_icd9_cnt = 0
   IF (icd9_list_cnt > 0)
    IF (case_icd9_indx > 0)
     SET icd9_indx = 1
     SET clin_icd9_cnt = size(case_icd9->cases[case_icd9_indx].clinical_codes,5)
     WHILE (reply_icd9_cnt < 3
      AND icd9_indx <= clin_icd9_cnt)
       SET icd9_to_find = trim(case_icd9->cases[case_icd9_indx].clinical_codes[icd9_indx].icd9_code)
       SET found_indx = locateval(dummy_indx,1,icd9_list_cnt,icd9_to_find,icd9_list->qual[dummy_indx]
        .icd9_code)
       IF (found_indx > 0)
        SET found_indx = locateval(dummy_indx,1,reply_icd9_cnt,icd9_to_find,reply->cases[i].icd9[
         dummy_indx].icd9_code)
        IF (found_indx=0)
         CALL addicd9toreply(i,case_icd9->cases[case_icd9_indx].clinical_codes[icd9_indx].icd9_code)
        ENDIF
       ENDIF
       SET icd9_indx = (icd9_indx+ 1)
     ENDWHILE
    ENDIF
    IF (case_icd9_indx > 0)
     SET icd9_indx = 1
     SET bill_icd9_cnt = size(case_icd9->cases[case_icd9_indx].billing_codes,5)
     WHILE (reply_icd9_cnt < 3
      AND icd9_indx <= bill_icd9_cnt)
       SET icd9_to_find = case_icd9->cases[case_icd9_indx].billing_codes[icd9_indx].icd9_code
       SET found_indx = locateval(dummy_indx,1,icd9_list_cnt,icd9_to_find,icd9_list->qual[dummy_indx]
        .icd9_code)
       IF (found_indx > 0)
        SET found_indx = locateval(dummy_indx,1,reply_icd9_cnt,icd9_to_find,reply->cases[i].icd9[
         dummy_indx].icd9_code)
        IF (found_indx=0)
         CALL addicd9toreply(i,case_icd9->cases[case_icd9_indx].billing_codes[icd9_indx].icd9_code)
        ENDIF
       ENDIF
       SET icd9_indx = (icd9_indx+ 1)
     ENDWHILE
    ENDIF
   ENDIF
   IF (case_icd9_indx > 0)
    SET icd9_indx = 1
    SET clin_icd9_cnt = size(case_icd9->cases[case_icd9_indx].clinical_codes,5)
    WHILE (reply_icd9_cnt < 3
     AND icd9_indx <= clin_icd9_cnt)
      SET icd9_to_find = case_icd9->cases[case_icd9_indx].clinical_codes[icd9_indx].icd9_code
      SET found_indx = locateval(dummy_indx,1,reply_icd9_cnt,icd9_to_find,reply->cases[i].icd9[
       dummy_indx].icd9_code)
      IF (found_indx=0)
       CALL addicd9toreply(i,case_icd9->cases[case_icd9_indx].clinical_codes[icd9_indx].icd9_code)
      ENDIF
      SET icd9_indx = (icd9_indx+ 1)
    ENDWHILE
   ENDIF
   IF (case_icd9_indx > 0)
    SET icd9_indx = 1
    SET bill_icd9_cnt = size(case_icd9->cases[case_icd9_indx].billing_codes,5)
    WHILE (reply_icd9_cnt < 3
     AND icd9_indx <= bill_icd9_cnt)
      SET icd9_to_find = case_icd9->cases[case_icd9_indx].billing_codes[icd9_indx].icd9_code
      SET found_indx = locateval(dummy_indx,1,reply_icd9_cnt,icd9_to_find,reply->cases[i].icd9[
       dummy_indx].icd9_code)
      IF (found_indx=0)
       CALL addicd9toreply(i,case_icd9->cases[case_icd9_indx].billing_codes[icd9_indx].icd9_code)
      ENDIF
      SET icd9_indx = (icd9_indx+ 1)
    ENDWHILE
   ENDIF
 ENDFOR
 SUBROUTINE addicd9toreply(reply_case_idx,icd9_to_add)
   SET reply_icd9_cnt = (size(reply->cases[reply_case_idx].icd9,5)+ 1)
   SET stat = alterlist(reply->cases[reply_case_idx].icd9,reply_icd9_cnt)
   SET reply->cases[reply_case_idx].icd9[reply_icd9_cnt].icd9_code = icd9_to_add
 END ;Subroutine
 DECLARE retrievespecimens(nsubdummy) = null WITH private
 SUBROUTINE retrievespecimens(nsubdummy)
   DECLARE lspeccnt = i4 WITH protect, noconstant(0)
   FOR (lx = 1 TO lreplybatchcnt)
     SET lbegidx = (((lx - 1) * lbatchsize)+ 1)
     SET lendidx = minval(((lbegidx+ lbatchsize) - 1),lreplycnt)
     SELECT INTO "nl:"
      join_path = decode(c.case_specimen_id,"C",s.case_specimen_id,"S"," "), slide_id = evaluate(
       nullind(pt.slide_id),0,pt.slide_id,0)
      FROM case_specimen cs,
       ap_tag tg1,
       cassette c,
       ap_tag tg2,
       slide s,
       processing_task pt,
       profile_task_r ptr,
       dummyt d1,
       dummyt d2
      PLAN (cs
       WHERE expand(lidx1,lbegidx,lendidx,cs.case_id,reply->cases[lidx1].case_id,
        lbatchsize)
        AND cs.cancel_cd IN (null, 0.0))
       JOIN (tg1
       WHERE tg1.tag_id=cs.specimen_tag_id)
       JOIN (((d1)
       JOIN (c
       WHERE c.case_specimen_id=cs.case_specimen_id)
       JOIN (tg2
       WHERE tg2.tag_id=c.cassette_tag_id)
       ) ORJOIN ((d2)
       JOIN (pt
       WHERE pt.case_specimen_id=cs.case_specimen_id
        AND pt.task_assay_cd != 0.0
        AND pt.cancel_cd=0.0)
       JOIN (s
       WHERE s.slide_id=pt.slide_id
        AND s.stain_task_assay_cd=pt.task_assay_cd)
       JOIN (ptr
       WHERE ptr.task_assay_cd=pt.task_assay_cd
        AND ptr.beg_effective_dt_tm <= pt.request_dt_tm
        AND ((ptr.end_effective_dt_tm >= pt.request_dt_tm) OR (ptr.end_effective_dt_tm=null)) )
       ))
      ORDER BY cs.case_id, cs.case_specimen_id, slide_id
      HEAD REPORT
       lcasespeccnt = 0, lblockcnt = 0, lproccnt = 0,
       lcatalogcnt = 0
      HEAD cs.case_id
       lcasespeccnt = 0
      HEAD cs.case_specimen_id
       lblockcnt = 0, lproccnt = 0, lcasespeccnt = (lcasespeccnt+ 1)
       IF ((lcasespeccnt > reply->max_specimen_cnt))
        reply->max_specimen_cnt = lcasespeccnt
       ENDIF
       lidx2 = locateval(lidx1,lbegidx,lendidx,cs.case_id,reply->cases[lidx1].case_id), stat =
       alterlist(reply->cases[lidx2].specimens,lcasespeccnt), reply->cases[lidx2].specimens[
       lcasespeccnt].specimen_id = cs.case_specimen_id,
       reply->cases[lidx2].specimens[lcasespeccnt].specimen_cd = cs.specimen_cd
       IF (cs.specimen_description != uar_get_code_description(cs.specimen_cd))
        reply->cases[lidx2].specimens[lcasespeccnt].specimen_description = cs.specimen_description
       ENDIF
       reply->cases[lidx2].specimens[lcasespeccnt].specimen_fixative = cs.received_fixative_cd, reply
       ->cases[lidx2].specimens[lcasespeccnt].specimen_identifier = tg1.tag_disp, lspeccnt = (
       lspeccnt+ 1)
       IF (size(ap_specimens->qual,5) < lspeccnt)
        stat = alterlist(ap_specimens->qual,(lspeccnt+ 9))
       ENDIF
       ap_specimens->qual[lspeccnt].specimen_id = cs.case_specimen_id, ap_specimens->qual[lspeccnt].
       case_index = lidx2
      HEAD slide_id
       lcatalogcnt = 0
      DETAIL
       CASE (join_path)
        OF "C":
         lblockcnt = (lblockcnt+ 1),stat = alterlist(reply->cases[lidx2].specimens[lcasespeccnt].
          blocks,lblockcnt),reply->cases[lidx2].specimens[lcasespeccnt].blocks[lblockcnt].block_id =
         c.cassette_id,
         reply->cases[lidx2].specimens[lcasespeccnt].blocks[lblockcnt].block_modifier = c
         .origin_modifier,reply->cases[lidx2].specimens[lcasespeccnt].blocks[lblockcnt].
         block_identifier = tg2.tag_disp
        OF "S":
         lcatalogcnt = (lcatalogcnt+ 1),
         IF (lcatalogcnt=1)
          lproccnt = (lproccnt+ 1), stat = alterlist(reply->cases[lidx2].specimens[lcasespeccnt].
           processing,lproccnt), reply->cases[lidx2].specimens[lcasespeccnt].processing[lproccnt].
          processing_verified_dt_tm = pt.status_dt_tm,
          reply->cases[lidx2].specimens[lcasespeccnt].processing[lproccnt].processing_id = pt
          .processing_task_id, reply->cases[lidx2].specimens[lcasespeccnt].processing[lproccnt].
          processing_block_id = pt.cassette_id, reply->cases[lidx2].specimens[lcasespeccnt].
          processing[lproccnt].processing_test_method = ptr.catalog_cd
         ENDIF
       ENDCASE
      WITH nocounter, outerjoin = d1
     ;end select
   ENDFOR
   SET stat = alterlist(ap_specimens->qual,lspeccnt)
 END ;Subroutine
 DECLARE retrievesynoptic(nsubdummy) = null WITH private
 SUBROUTINE retrievesynoptic(nsubdummy)
   DECLARE lbatchcnt = i4 WITH protect, noconstant(0)
   DECLARE lstorycnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    u.column_name
    FROM user_tab_columns u
    WHERE u.table_name="AP_CASE_SYNOPTIC_WS"
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN
   ENDIF
   SET lbatchcnt = (((size(ap_specimens->qual,5) - 1)/ lbatchsize)+ 1)
   FOR (lx = 1 TO lbatchcnt)
     SET lbegidx = (((lx - 1) * lbatchsize)+ 1)
     SET lendidx = minval(((lbegidx+ lbatchsize) - 1),size(ap_specimens->qual,5))
     SELECT INTO "nl:"
      syn.case_specimen_id
      FROM ap_case_synoptic_ws syn
      PLAN (syn
       WHERE expand(lidx1,lbegidx,lendidx,syn.case_specimen_id,ap_specimens->qual[lidx1].specimen_id,
        lbatchsize)
        AND syn.status_flag=ncompleted)
      DETAIL
       lstorycnt = (lstorycnt+ 1)
       IF (mod(lstorycnt,10)=1)
        stat = alterlist(scd_request->qual,(lstorycnt+ 9))
       ENDIF
       lidx2 = locateval(lidx1,lbegidx,lendidx,syn.case_specimen_id,ap_specimens->qual[lidx1].
        specimen_id), scd_request->qual[lstorycnt].scd_story_id = syn.scd_story_id, scd_request->
       qual[lstorycnt].other_data = cnvtstring(ap_specimens->qual[lidx2].specimen_id),
       scd_request->qual[lstorycnt].index = ap_specimens->qual[lidx2].case_index
      WITH nocounter
     ;end select
   ENDFOR
   SET stat = alterlist(scd_request->qual,lstorycnt)
   SET scd_request->source_vocabulary_cd = dsnomedctcd
   EXECUTE scd_get_story_terms  WITH replace("REQUEST","SCD_REQUEST"), replace("REPLY","SCD_REPLY")
   IF ((scd_reply->status_data.status="S"))
    SET reply->max_concept_cnt = scd_reply->max_term_cnt
    SELECT INTO "nl:"
     index = scd_reply->qual[d1.seq].index
     FROM (dummyt d1  WITH seq = value(size(scd_reply->qual,5))),
      (dummyt d2  WITH seq = value(scd_reply->max_term_cnt))
     PLAN (d1)
      JOIN (d2
      WHERE d2.seq <= size(scd_reply->qual[d1.seq].terms,5))
     ORDER BY d1.seq
     HEAD REPORT
      ltermcnt = 0
     HEAD d1.seq
      ltermcnt = size(reply->cases[index].synoptic_concepts,5)
     DETAIL
      ltermcnt = (ltermcnt+ 1), stat = alterlist(reply->cases[index].synoptic_concepts,ltermcnt),
      reply->cases[index].synoptic_concepts[ltermcnt].concept_specimen_id = cnvtreal(scd_reply->qual[
       d1.seq].other_data),
      reply->cases[index].synoptic_concepts[ltermcnt].concept_group_id = scd_reply->qual[d1.seq].
      scd_story_id, reply->cases[index].synoptic_concepts[ltermcnt].concept_truth_cd = scd_reply->
      qual[d1.seq].terms[d2.seq].term_truth_cd, reply->cases[index].synoptic_concepts[ltermcnt].
      concept = scd_reply->qual[d1.seq].terms[d2.seq].source_identifier,
      reply->cases[index].synoptic_concepts[ltermcnt].concept_value_units_cd = scd_reply->qual[d1.seq
      ].terms[d2.seq].value_units_cd, reply->cases[index].synoptic_concepts[ltermcnt].
      concept_source_vocab_cd = scd_reply->qual[d1.seq].terms[d2.seq].source_vocabulary_cd
      IF ((scd_reply->qual[d1.seq].terms[d2.seq].value_text != null))
       reply->cases[index].synoptic_concepts[ltermcnt].concept_value = scd_reply->qual[d1.seq].terms[
       d2.seq].value_text
      ELSEIF ((scd_reply->qual[d1.seq].terms[d2.seq].value_number != null))
       reply->cases[index].synoptic_concepts[ltermcnt].concept_value = format(scd_reply->qual[d1.seq]
        .terms[d2.seq].value_number,"#########.######;L")
      ELSEIF ((scd_reply->qual[d1.seq].terms[d2.seq].value_dt_tm != null))
       reply->cases[index].synoptic_concepts[ltermcnt].concept_value = format(scd_reply->qual[d1.seq]
        .terms[d2.seq].value_dt_tm,"mm/dd/yyyy hh:mm;;D")
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SET modify = nopredeclare
 SET script_version = "007 12/13/06 MG010594"
END GO
