CREATE PROGRAM bhs_prax_get_prob_assoc
 FREE RECORD result
 RECORD result(
   1 concepts[*]
     2 nomenclature_id = f8
     2 concept_cki = vc
     2 source_string = vc
     2 associations[*]
       3 cki = vc
       3 concept_name = vc
       3 nomenclatures[*]
         4 nomenclature_id = f8
         4 source_identifier = vc
         4 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req4174018
 RECORD req4174018(
   1 concept_cki[*]
     2 cki = vc
     2 preferred_nomenclature_flag = i2
     2 effective_dt_tm = dq8
     2 local_time_zone = i4
     2 target_vocabularies[*]
       3 target_vocabulary = f8
   1 mapping_direction_flag = i2
 ) WITH protect
 FREE RECORD rep4174018
 RECORD rep4174018(
   1 concepts[*]
     2 concept_cki = vc
     2 associations[*]
       3 target_concept
         4 cki = vc
         4 concept_identifier = vc
         4 concept_source_cd = f8
         4 concept_name = vc
         4 active_ind = i2
         4 nomenclatures[*]
           5 nomenclature_id = f8
           5 source_identifier = vc
           5 description = vc
           5 short_description = vc
           5 mnemonic = vc
           5 terminology_cd = f8
           5 terminology_axis_cd = f8
           5 principle_type_cd = f8
           5 language_cd = f8
           5 primary_vterm_ind = i2
           5 primary_cterm_ind = i2
           5 cki = vc
           5 active_ind = i2
           5 extensions[*]
             6 icd9[*]
               7 age = vc
               7 gender = vc
               7 billable = vc
             6 apc[*]
               7 minimum_unadjusted_coinsurance = f8
               7 national_unadjusted_coinsurance = f8
               7 payment_rate = f8
               7 status_indicator = vc
             6 drg[*]
               7 amlos = f8
               7 gmlos = f8
               7 drg_category = vc
               7 drg_weight = f8
               7 mdc_code = f8
           5 beg_effective_dt_tm = dq8
           5 end_effective_dt_tm = dq8
           5 concept_identifier = vc
           5 concept_source_cd = f8
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 extensions[*]
           5 extension_type_cd = f8
           5 extension_value = vc
       3 association_type_cd = f8
       3 group_sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callgetassociations(null) = i4
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE hdx = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 SET result->status_data.status = "F"
 IF (size(trim( $2,3)) <= 0)
  CALL echo("INVALID NOMENCLATURE ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 DECLARE nomenidparam = vc WITH protect, noconstant("")
 DECLARE startpos = i4 WITH protect, noconstant(0)
 DECLARE endpos = i4 WITH protect, noconstant(0)
 DECLARE param = vc WITH protect, noconstant("")
 DECLARE conceptcnt = i4 WITH protect, noconstant(0)
 SET startpos = 1
 SET nomenidparam = trim( $2,3)
 CALL echo(build2("NOMENIDPARAM IS: ",nomenidparam))
 WHILE (size(nomenidparam) > 0)
   SET endpos = (findstring(";",nomenidparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(nomenidparam)
   ENDIF
   CALL echo(build("ENDPOS:",endpos))
   IF (startpos < endpos)
    SET param = substring(1,endpos,nomenidparam)
    CALL echo(build("PARAM:",param))
    SET conceptcnt = (conceptcnt+ 1)
    SET stat = alterlist(result->concepts,conceptcnt)
    SET result->concepts[conceptcnt].nomenclature_id = cnvtreal(param)
   ENDIF
   SET nomenidparam = substring((endpos+ 2),(size(nomenidparam) - endpos),nomenidparam)
   CALL echo(build("NOMENIDPARAM:",nomenidparam))
   CALL echo(build("SIZE(NOMENIDPARAM):",size(nomenidparam)))
 ENDWHILE
 SELECT INTO "NL:"
  FROM nomenclature n
  PLAN (n
   WHERE expand(idx,1,size(result->concepts,5),n.nomenclature_id,result->concepts[idx].
    nomenclature_id)
    AND n.active_ind=1)
  ORDER BY n.nomenclature_id
  HEAD n.nomenclature_id
   pos = locateval(locidx,1,size(result->concepts,5),n.nomenclature_id,result->concepts[locidx].
    nomenclature_id)
   IF (pos > 0)
    result->concepts[pos].concept_cki = n.concept_cki, result->concepts[pos].source_string = n
    .source_string
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SET stat = callgetassociations(null)
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
  DECLARE v5 = vc WITH protect, noconstant("")
  DECLARE v6 = vc WITH protect, noconstant("")
  DECLARE v7 = vc WITH protect, noconstant("")
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
    col + 1, "<Concepts>", row + 1
    FOR (hdx = 1 TO size(result->concepts,5))
      col + 1, "<Concept>", row + 1,
      v5 = build("<NomenclatureId>",cnvtint(result->concepts[hdx].nomenclature_id),
       "</NomenclatureId>"), col + 1, v5,
      row + 1, v6 = build("<ConceptCki>",result->concepts[hdx].concept_cki,"</ConceptCki>"), col + 1,
      v6, row + 1, v7 = build("<SourceString>",trim(replace(replace(replace(replace(replace(result->
             concepts[hdx].source_string,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
         '"',"&quot;",0),3),"</SourceString>"),
      col + 1, v7, row + 1,
      col + 1, "<Associations>", row + 1
      FOR (idx = 1 TO size(result->concepts[hdx].associations,5))
        col + 1, "<Association>", row + 1,
        v1 = build("<ConceptCki>",result->concepts[hdx].associations[idx].cki,"</ConceptCki>"), col
         + 1, v1,
        row + 1, v2 = build("<ConceptName>",trim(replace(replace(replace(replace(replace(result->
               concepts[hdx].associations[idx].concept_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0
             ),"'","&apos;",0),'"',"&quot;",0),3),"</ConceptName>"), col + 1,
        v2, row + 1, col + 1,
        "<Nomenclatures>", row + 1
        FOR (jdx = 1 TO size(result->concepts[hdx].associations[idx].nomenclatures,5))
          col + 1, "<Nomenclature>", row + 1,
          v3 = build("<NomenclatureId>",cnvtint(result->concepts[hdx].associations[idx].
            nomenclatures[jdx].nomenclature_id),"</NomenclatureId>"), col + 1, v3,
          row + 1, v4 = build("<SourceIdentifier>",result->concepts[hdx].associations[idx].
           nomenclatures[jdx].source_identifier,"</SourceIdentifier>"), col + 1,
          v4, row + 1, v5 = build("<Description>",trim(replace(replace(replace(replace(replace(result
                 ->concepts[hdx].associations[idx].nomenclatures[jdx].description,"&","&amp;",0),"<",
                "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Description>"),
          col + 1, v5, row + 1,
          col + 1, "</Nomenclature>", row + 1
        ENDFOR
        col + 1, "</Nomenclatures>", row + 1,
        col + 1, "</Association>", row + 1
      ENDFOR
      col + 1, "</Associations>", row + 1,
      col + 1, "</Concept>", row + 1
    ENDFOR
    col + 1, "</Concepts>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req4174018
 FREE RECORD rep4174018
 SUBROUTINE callgetassociations(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(4171505)
   DECLARE requestid = i4 WITH protect, constant(4174018)
   DECLARE now = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
   DECLARE csize = i4 WITH protect, noconstant(0)
   DECLARE asize = i4 WITH protect, noconstant(0)
   DECLARE nsize = i4 WITH protect, noconstant(0)
   DECLARE acnt = i4 WITH protect, noconstant(0)
   DECLARE ncnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(req4174018->concept_cki,size(result->concepts,5))
   FOR (idx = 1 TO size(result->concepts,5))
     SET req4174018->concept_cki[idx].cki = result->concepts[idx].concept_cki
     SET req4174018->concept_cki[idx].preferred_nomenclature_flag = 2
     SET req4174018->concept_cki[idx].local_time_zone = app_tz
   ENDFOR
   CALL echorecord(req4174018)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req4174018,
    "REC",rep4174018,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep4174018)
   IF ((rep4174018->status_data.status != "F"))
    SET csize = size(rep4174018->concepts,5)
    FOR (hdx = 1 TO csize)
     SET pos = locateval(locidx,1,size(result->concepts,5),rep4174018->concepts[hdx].concept_cki,
      result->concepts[locidx].concept_cki)
     IF (pos > 0)
      SET acnt = 0
      SET asize = size(rep4174018->concepts[hdx].associations,5)
      FOR (idx = 1 TO asize)
        IF ((rep4174018->concepts[hdx].associations[idx].target_concept.active_ind=1)
         AND substring(1,5,rep4174018->concepts[hdx].associations[idx].target_concept.cki) != "ICD10"
        )
         SET acnt = (acnt+ 1)
         SET stat = alterlist(result->concepts[pos].associations,acnt)
         SET result->concepts[pos].associations[acnt].cki = rep4174018->concepts[hdx].associations[
         idx].target_concept.cki
         SET result->concepts[pos].associations[acnt].concept_name = rep4174018->concepts[hdx].
         associations[idx].target_concept.concept_name
         SET ncnt = 0
         SET nsize = size(rep4174018->concepts[hdx].associations[idx].target_concept.nomenclatures,5)
         FOR (jdx = 1 TO nsize)
           IF ((rep4174018->concepts[hdx].associations[idx].target_concept.nomenclatures[jdx].
           active_ind=1)
            AND (rep4174018->concepts[hdx].associations[idx].target_concept.nomenclatures[jdx].
           language_cd= $3)
            AND (now >= rep4174018->concepts[hdx].associations[idx].target_concept.nomenclatures[jdx]
           .beg_effective_dt_tm)
            AND (now <= rep4174018->concepts[hdx].associations[idx].target_concept.nomenclatures[jdx]
           .end_effective_dt_tm))
            SET ncnt = (ncnt+ 1)
            SET stat = alterlist(result->concepts[pos].associations[acnt].nomenclatures,ncnt)
            SET result->concepts[pos].associations[acnt].nomenclatures[ncnt].nomenclature_id =
            rep4174018->concepts[hdx].associations[idx].target_concept.nomenclatures[jdx].
            nomenclature_id
            SET result->concepts[pos].associations[acnt].nomenclatures[ncnt].source_identifier =
            rep4174018->concepts[hdx].associations[idx].target_concept.nomenclatures[jdx].
            source_identifier
            SET result->concepts[pos].associations[acnt].nomenclatures[ncnt].description = rep4174018
            ->concepts[hdx].associations[idx].target_concept.nomenclatures[jdx].description
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
     ENDIF
    ENDFOR
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
