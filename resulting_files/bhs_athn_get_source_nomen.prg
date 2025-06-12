CREATE PROGRAM bhs_athn_get_source_nomen
 FREE RECORD result
 RECORD result(
   1 target_nomenclature
     2 nomenclature_id = f8
     2 source_string = vc
     2 concept_cki = vc
     2 source_identifier = vc
   1 items[*]
     2 nomenclature_id = f8
     2 source_string = vc
     2 concept_cki = vc
     2 source_identifier = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD vocabularies
 RECORD vocabularies(
   1 vocabularycnt = i4
   1 list[*]
     2 code_value = f8
     2 meaning = vc
 ) WITH protect
 DECLARE getsourcenomen(null) = i4
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE itemcnt = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID TARGET NOMENCLATURE ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 DECLARE sourcevocabparam = vc WITH protect, noconstant("")
 DECLARE startpos = i4 WITH protect, noconstant(0)
 DECLARE endpos = i4 WITH protect, noconstant(0)
 DECLARE param = vc WITH protect, noconstant("")
 DECLARE source_vocabulary_cd = f8 WITH protect, noconstant(0.0)
 IF (textlen(trim( $3,3)) > 0)
  SET startpos = 1
  SET sourcevocabparam = trim( $3,3)
  CALL echo(build2("SOURCEVOCABPARAM IS: ",sourcevocabparam))
  WHILE (size(sourcevocabparam) > 0)
    SET endpos = (findstring(";",sourcevocabparam,1) - 1)
    IF (endpos <= 0)
     SET endpos = size(sourcevocabparam)
    ENDIF
    CALL echo(build("ENDPOS:",endpos))
    IF (startpos < endpos)
     SET param = substring(1,endpos,sourcevocabparam)
     CALL echo(build("PARAM:",param))
     SET vocabularies->vocabularycnt = (vocabularies->vocabularycnt+ 1)
     SET stat = alterlist(vocabularies->list,vocabularies->vocabularycnt)
     SET vocabularies->list[vocabularies->vocabularycnt].meaning = trim(param,3)
    ENDIF
    SET sourcevocabparam = substring((endpos+ 2),(size(sourcevocabparam) - endpos),sourcevocabparam)
    CALL echo(build("SOURCEVOCABPARAM:",sourcevocabparam))
    CALL echo(build("SIZE(SOURCEVOCABPARAM):",size(sourcevocabparam)))
  ENDWHILE
  FOR (idx = 1 TO vocabularies->vocabularycnt)
    SET source_vocabulary_cd = uar_get_code_by("MEANING",400,vocabularies->list[idx].meaning)
    IF (source_vocabulary_cd <= 0.0)
     CALL echo("INVALID SOURCE VOCABULARY PARAMETER...EXITING")
     GO TO exit_script
    ENDIF
    SET vocabularies->list[idx].code_value = source_vocabulary_cd
  ENDFOR
  CALL echorecord(vocabularies)
 ENDIF
 SET stat = getsourcenomen(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v0 = vc WITH protect, noconstant("")
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM (dummyt d  WITH seq = value(1))
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v0 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v0, row + 1
   DETAIL
    col + 1, "<TargetNomenclature>", row + 1,
    v1 = build("<NomenclatureId>",cnvtint(result->target_nomenclature.nomenclature_id),
     "</NomenclatureId>"), col + 1, v1,
    row + 1, v2 = build("<SourceString>",trim(replace(replace(replace(replace(replace(result->
           target_nomenclature.source_string,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
        0),'"',"&quot;",0),3),"</SourceString>"), col + 1,
    v2, row + 1, v3 = build("<SourceIdentifier>",trim(replace(replace(replace(replace(replace(result
           ->target_nomenclature.source_identifier,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
        "&apos;",0),'"',"&quot;",0),3),"</SourceIdentifier>"),
    col + 1, v3, row + 1,
    v4 = build("<ConceptCki>",trim(replace(replace(replace(replace(replace(result->
           target_nomenclature.concept_cki,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
       '"',"&quot;",0),3),"</ConceptCki>"), col + 1, v4,
    row + 1, col + 1, "</TargetNomenclature>",
    row + 1, col + 1, "<SourceNomenclatures>",
    row + 1
    FOR (idx = 1 TO size(result->items,5))
      col + 1, "<Nomenclature>", row + 1,
      v1 = build("<NomenclatureId>",cnvtint(result->items[idx].nomenclature_id),"</NomenclatureId>"),
      col + 1, v1,
      row + 1, v2 = build("<SourceString>",trim(replace(replace(replace(replace(replace(result->
             items[idx].source_string,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
         "&quot;",0),3),"</SourceString>"), col + 1,
      v2, row + 1, v3 = build("<SourceIdentifier>",trim(replace(replace(replace(replace(replace(
             result->items[idx].source_identifier,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
          "&apos;",0),'"',"&quot;",0),3),"</SourceIdentifier>"),
      col + 1, v3, row + 1,
      v4 = build("<ConceptCki>",trim(replace(replace(replace(replace(replace(result->items[idx].
             concept_cki,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3
        ),"</ConceptCki>"), col + 1, v4,
      row + 1, col + 1, "</Nomenclature>",
      row + 1
    ENDFOR
    col + 1, "</SourceNomenclatures>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD vocabularies
 SUBROUTINE getsourcenomen(null)
   DECLARE c_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
   DECLARE now = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
   SELECT INTO "NL:"
    FROM nomenclature nt,
     cmt_cross_map ccm,
     nomenclature ns
    PLAN (nt
     WHERE (nt.nomenclature_id= $2)
      AND nt.active_ind=1
      AND nt.active_status_cd=c_active_cd
      AND nt.beg_effective_dt_tm < cnvtdatetime(now)
      AND nt.end_effective_dt_tm >= cnvtdatetime(now))
     JOIN (ccm
     WHERE ccm.target_concept_cki=nt.concept_cki
      AND ccm.active_ind=1
      AND ccm.beg_effective_dt_tm < cnvtdatetime(now)
      AND ccm.end_effective_dt_tm >= cnvtdatetime(now))
     JOIN (ns
     WHERE ns.concept_cki=ccm.concept_cki
      AND ns.active_ind=1
      AND ns.active_status_cd=c_active_cd
      AND ns.beg_effective_dt_tm < cnvtdatetime(now)
      AND ns.end_effective_dt_tm >= cnvtdatetime(now))
    ORDER BY ns.source_string
    HEAD nt.nomenclature_id
     result->target_nomenclature.nomenclature_id = nt.nomenclature_id, result->target_nomenclature.
     source_string = nt.source_string, result->target_nomenclature.concept_cki = nt.concept_cki,
     result->target_nomenclature.source_identifier = nt.source_identifier
    HEAD ns.nomenclature_id
     pos = locateval(locidx,1,vocabularies->vocabularycnt,ns.source_vocabulary_cd,vocabularies->list[
      locidx].code_value)
     IF (((pos > 0) OR ((vocabularies->vocabularycnt=0))) )
      itemcnt = (itemcnt+ 1), stat = alterlist(result->items,itemcnt), result->items[itemcnt].
      nomenclature_id = ns.nomenclature_id,
      result->items[itemcnt].source_string = ns.source_string, result->items[itemcnt].concept_cki =
      ns.concept_cki, result->items[itemcnt].source_identifier = ns.source_identifier
     ENDIF
    WITH nocounter, time = 30
   ;end select
   RETURN(success)
 END ;Subroutine
END GO
