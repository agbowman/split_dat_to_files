CREATE PROGRAM bhs_pat_disch:dba
 DECLARE beg_ind = i2 WITH noconstant(0)
 DECLARE end_ind = i2 WITH noconstant(0)
 DECLARE beg_dt_tm = dq8 WITH noconstant(cnvtdatetime(curdate,curtime))
 DECLARE end_dt_tm = dq8 WITH noconstant(cnvtdatetime(curdate,curtime))
 DECLARE x2 = c2 WITH noconstant("  ")
 DECLARE x3 = c3 WITH noconstant("   ")
 DECLARE abc = vc WITH noconstant(fillstring(25," "))
 DECLARE xyz = c21 WITH noconstant("  -   -       :  :  ")
 DECLARE tab = vc
 SUBROUTINE inserttabfromrtf(textin)
   SET pos1 = 0
   SET starttext = 0
   SET tablevel = 0
   SET tabval = 0
   SET containedtablevel = 0
   SET containedtabval = 0
   SET containedparagraph = 0
   SET exitcnt = 0
   SET endpos = 0
   SET textin = trim(textin)
   SET tabvalout = 0
   SET tablevelout = 0
   SET tabpos = 0
   SET spcstart = 0
   SET pos1 = (findstring("\par",textin,1) - 3)
   SET starttext = findstring(" ",textin,(pos1+ 4))
   CALL echo(build("pre loop pos1: ",pos1))
   WHILE (pos1 > 0
    AND pos1 < size(textin)
    AND exitcnt < 1000)
     SET exitcnt += 1
     SET starttext = findstring(" ",textin,(pos1+ 4))
     SET endpos = findstring("\par",textin,starttext)
     CALL echo(substring(pos1,(endpos - pos1),textin))
     CALL echo(build("containedParagraph Prior to set/reset: ",containedparagraph))
     IF (containedparagraph=1)
      IF (findstring("}",substring(pos1,(endpos - pos1),textin),1) > 0)
       SET containedparagraph = 0
       SET containedtabval = 0
       SET containedtablevel = 0
      ENDIF
     ELSEIF (findstring("{",substring(pos1,5,textin),1) > 0)
      SET containedparagraph = 1
     ENDIF
     CALL echo(build("containedParagraph post: ",containedparagraph))
     SET openbracketpos = 0
     SET closebracketpos = 0
     CALL echo(build("startBeforeRTFBracketSearch",starttext))
     SET openbracketpos = findstring("{",substring((pos1+ 6),(starttext - pos1),textin),1)
     CALL echo(build("openBracketPos:",openbracketpos))
     CALL echo(substring(((pos1+ openbracketpos)+ 2),7,textin))
     IF (openbracketpos > 0
      AND findstring("par",substring(((pos1+ openbracketpos)+ 2),7,textin),1)=0)
      SET openbracketpos = ((openbracketpos+ pos1)+ 6)
      CALL echo(substring((openbracketpos - 5),10,textin))
      SET closebracketpos = findstring("}",substring(openbracketpos,(endpos - pos1),textin),1)
      IF (closebracketpos > 0)
       SET closebracketpos += openbracketpos
       CALL echo("Found RTFcode that contains inner paragraph {} setting startText pos after }")
       CALL echo(substring(((pos1+ 6)+ openbracketpos),(endpos - pos1),textin))
       CALL echo(build("closeBracketPos:",closebracketpos))
       SET starttext = findstring(" ",textin,closebracketpos)
      ENDIF
     ELSE
      SET starttext = findstring(" ",textin,(pos1+ 4))
     ENDIF
     CALL echo(build("startAfterRTFBracketSearch",starttext))
     IF (containedparagraph < 1)
      CALL adjusttabs(tabval,tablevel)
      SET tabval = tabvalout
      SET tablevel = tablevelout
     ELSE
      CALL adjusttabs(containedtabval,containedtablevel)
      SET containedtabval = tabvalout
      SET containedtablevel = tablevelout
     ENDIF
     IF (endpos > 0)
      SET txtspc = fillstring(50," ")
      CALL echo(build("tabLevel:",tablevel,":",containedtablevel))
      IF (((tablevel+ containedtablevel) > 8))
       SET temptablevel1 = 8
       SET tempcontainedtablevel1 = 0
      ELSE
       SET temptablevel1 = tablevel
       SET tempcontainedtablevel1 = containedtablevel
      ENDIF
      FOR (x = 1 TO (temptablevel1+ tempcontainedtablevel1))
        CALL echo(build("Tabbing over: ",x))
        SET txtspc = concat(char(185),txtspc)
        CALL echo(txtspc)
      ENDFOR
      SET q = 0
      SET truestarttext = starttext
      FOR (q = 1 TO (endpos - starttext))
       SET tempchar = ichar(substring((starttext+ q),1,textin))
       IF (((tempchar BETWEEN 33 AND 126) OR (q > 40)) )
        SET truestarttext = (starttext+ q)
        SET q = (endpos - starttext)
       ENDIF
      ENDFOR
      CALL echo(build("trueStart:",truestarttext))
      SET textin = concat(substring(1,starttext,textin),trim(txtspc),substring(truestarttext,size(
         textin),textin))
      IF (tabpos > 0)
       CALL echo("\tab found adding tab")
       SET textin = concat(substring(1,starttext,textin),char(185),substring(starttext,size(textin),
         textin))
      ENDIF
     ENDIF
     SET endpos = findstring("\par",textin,starttext)
     CALL echo(substring(pos1,(endpos - pos1),textin))
     SET pos1 = findstring("\par",textin,starttext)
     CALL echo(build("new Pos1:",pos1))
     IF (((pos1 < 1) OR (exitcnt=1000)) )
      SET pos1 = size(textin)
     ENDIF
     CALL echo(build("***************************ExitCnt",exitcnt))
   ENDWHILE
   SET inserttabfromrtfout = textin
 END ;Subroutine
 SUBROUTINE adjusttabs(tabvalin,tablevelin)
   SET temptabvalin = 0
   SET tabvalout = 0
   SET tablevelout = 0
   SET lipos = 0
   SET tabpos = 0
   SET loseprepargformat = 0
   SET temptabval = 0
   SET truestart = 0
   CALL echo("adjustTabs subroutine")
   CALL echo(build("tabValIn: ",tabvalin))
   CALL echo(build("tabLevelIn: ",tablevelin))
   SET loseprepargformat = findstring("\pard",substring(pos1,(starttext - (pos1+ 4)),textin),1)
   CALL echo(build("New Paragraph(0 = no):",loseprepargformat))
   SET lipos = findstring("\li",substring(pos1,((starttext - pos1)+ 5),textin),1)
   SET tabpos = findstring("\tab",substring(pos1,(starttext - pos1),textin),1)
   CALL echo(build("LiPos:",lipos))
   CALL echo(build("tabPos: ",tabpos))
   IF (lipos > 0)
    SET lipos = ((lipos+ pos1)+ 2)
    SET spcstart = findstring(" ",textin,lipos)
    CALL echo(build("STARTSPACECNT:",truestart,"tabLevelIn:",tablevelin))
    IF (loseprepargformat < 1)
     SET tabvalin = ((tablevelin+ 1) * (tabvalin/ tablevelin))
     SET tablevelin += 1
    ELSE
     CALL echo(build("True li Pos:",lipos))
     IF (isnumeric(trim(substring(lipos,(findstring(" ",textin,lipos) - lipos),textin))))
      SET temptabvalin = cnvtint(substring(lipos,(findstring(" ",textin,lipos) - lipos),textin))
     ELSE
      SET temptabvalin = cnvtint(substring(lipos,(findstring("\",textin,lipos) - lipos),textin))
     ENDIF
     CALL echo(build("Found LI Tab:",temptabvalin))
     IF (temptabvalin > tabvalin)
      SET tablevelin += 1
     ELSEIF (tabvalin > 0
      AND tablevelin > 1)
      SET tablevelin -= 1
     ELSE
      IF (tabvalin=0)
       SET tablevelin = 0
      ENDIF
     ENDIF
     SET tabvalin = temptabvalin
    ENDIF
   ELSEIF (tabpos > 0)
    SET spcstart = findstring(" ",textin,tabpos)
    CALL echo("tabPos > 0  - ignore paragraph formats")
   ELSEIF (loseprepargformat > 1)
    SET truestart = 0
    SET spcstart = findstring(" ",textin,starttext)
    CALL echo("No Paragraph format found - reseting tabs")
    SET tabvalin = 0
    SET tablevelin = 0
   ENDIF
   SET spccnt = 0
   WHILE (ichar(substring((spcstart+ spccnt),1,textin))=32
    AND spccnt <= 8
    AND endpos > 0)
    SET spccnt += 1
    IF (spccnt=8)
     CALL echo("adding space tab")
     SET tabvalin = ((tablevelin+ 1) * (tabvalin/ tablevelin))
     SET tablevelin += 1
    ENDIF
   ENDWHILE
   SET tabvalout = tabvalin
   SET tablevelout = tablevelin
   CALL echo(build("tabValOut: ",tabvalout))
   CALL echo(build("tabLevelOut: ",tablevelout))
 END ;Subroutine
 SUBROUTINE convertrtftopostscript(blob_uncompressed,blob_return_len,blob_rtf,blobsize,
  blob_return_len2,int)
   DECLARE inserttabfromrtfout = vc WITH public, noconstant(" ")
   DECLARE blobtemp = vc WITH public, noconstant(" ")
   CALL inserttabfromrtf(blob_uncompressed)
   SET blobtemp = inserttabfromrtfout
   CALL echo("@*********************************************@")
   SET blobtemp = replace(blobtemp,"\b0",concat(char(222)))
   SET blobtemp = replace(blobtemp,"\b",concat(" ",char(225)))
   SET blobsize = size(blobtemp)
   CALL echo(blobtemp)
   CALL echo("!*********************************************!")
   CALL uar_rtf2(blobtemp,blobsize,blob_rtf,blobsize,blob_return_len2,
    int)
   CALL echo(blob_rtf)
   SET blob_out_detail = blob_rtf
   CALL echo("$$*****************************************************$$")
 END ;Subroutine
 FREE RECORD blob
 RECORD blob(
   1 line = vc
   1 cnt = i2
   1 qual[*]
     2 line = vc
     2 sze = i4
 )
 FREE RECORD pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 IF (validate(request->visit,"Z") != "Z")
  SET printer_name = request->output_device
  SET patient_cnt = size(request->visit,5)
  FOR (x = 1 TO request->nv_cnt)
    IF ((request->nv[x].pvc_name="BEG_DT_TM"))
     SET beg_ind = 1
     SET abc = trim(request->nv[x].pvc_value)
     SET stat = movestring(abc,7,xyz,1,2)
     SET x2 = substring(5,2,abc)
     IF (x2="01")
      SET x3 = "JAN"
     ELSEIF (x2="02")
      SET x3 = "FEB"
     ELSEIF (x2="03")
      SET x3 = "MAR"
     ELSEIF (x2="04")
      SET x3 = "APR"
     ELSEIF (x2="05")
      SET x3 = "MAY"
     ELSEIF (x2="06")
      SET x3 = "JUN"
     ELSEIF (x2="07")
      SET x3 = "JUL"
     ELSEIF (x2="08")
      SET x3 = "AUG"
     ELSEIF (x2="09")
      SET x3 = "SEP"
     ELSEIF (x2="10")
      SET x3 = "OCT"
     ELSEIF (x2="11")
      SET x3 = "NOV"
     ELSEIF (x2="12")
      SET x3 = "DEC"
     ENDIF
     SET stat = movestring(x3,1,xyz,4,3)
     SET stat = movestring(abc,1,xyz,8,4)
     SET stat = movestring(abc,9,xyz,13,2)
     SET stat = movestring(abc,11,xyz,16,2)
     SET stat = movestring(abc,13,xyz,19,2)
     SET beg_dt_tm = cnvtdatetime(xyz)
    ELSEIF ((request->nv[x].pvc_name="END_DT_TM"))
     SET end_ind = 1
     SET abc = trim(request->nv[x].pvc_value)
     SET stat = movestring(abc,7,xyz,1,2)
     SET x2 = substring(5,2,abc)
     IF (x2="01")
      SET x3 = "JAN"
     ELSEIF (x2="02")
      SET x3 = "FEB"
     ELSEIF (x2="03")
      SET x3 = "MAR"
     ELSEIF (x2="04")
      SET x3 = "APR"
     ELSEIF (x2="05")
      SET x3 = "MAY"
     ELSEIF (x2="06")
      SET x3 = "JUN"
     ELSEIF (x2="07")
      SET x3 = "JUL"
     ELSEIF (x2="08")
      SET x3 = "AUG"
     ELSEIF (x2="09")
      SET x3 = "SEP"
     ELSEIF (x2="10")
      SET x3 = "OCT"
     ELSEIF (x2="11")
      SET x3 = "NOV"
     ELSEIF (x2="12")
      SET x3 = "DEC"
     ENDIF
     SET stat = movestring(x3,1,xyz,4,3)
     SET stat = movestring(abc,1,xyz,8,4)
     SET stat = movestring(abc,9,xyz,13,2)
     SET stat = movestring(abc,11,xyz,16,2)
     SET stat = movestring(abc,13,xyz,19,2)
     SET end_dt_tm = cnvtdatetime(xyz)
    ENDIF
  ENDFOR
 ELSE
  SET printer_name =  $1
  SET encntr_to_search = 59409812
  SET patient_cnt = 1
  SET end_dt_tm = cnvtdatetime(sysdate)
  SET beg_dt_tm = cnvtdatetime((curdate - 5),0)
 ENDIF
 FOR (pds = 1 TO patient_cnt)
   IF (validate(request->visit,"Z") != "Z")
    SET encntr_to_search = request->visit[patient_cnt].encntr_id
   ENDIF
   FREE RECORD disch
   RECORD disch(
     1 qual = i4
     1 list[*]
       2 cd = f8
   )
   SET signed_cd = uar_get_code_by("MEANING",15750,"SIGNED")
   SET sign_cd = uar_get_code_by("MEANING",21,"SIGN")
   SET admitdoc = uar_get_code_by("MEANING",333,"ADMITDOC")
   SET mrn_cd = uar_get_code_by("MEANING",4,"MRN")
   SET ssn_cd = uar_get_code_by("MEANING",4,"SSN")
   SET fin_cd = uar_get_code_by("MEANING",319,"FIN NBR")
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.code_set=72
     AND cv.display_key IN ("PATIENTINSTRUCTIONSFORDISCHARGE", "PATIENTEDUCATIONINSTRUCTION")
     AND cv.active_ind=1
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1, stat = alterlist(disch->list,cnt), disch->list[cnt].cd = cv.code_value
    FOOT REPORT
     disch->qual = cnt
    WITH nocounter
   ;end select
   FREE RECORD pat
   RECORD pat(
     1 person_id = f8
     1 event_qual = i4
     1 list[*]
       2 parent_event_id = f8
   )
   DECLARE blob_size = i4
   DECLARE blob_out_detail = c64000
   DECLARE blob_compressed_trimmed = c64000
   DECLARE blob_uncompressed = c64000
   DECLARE blob_rtf = c64000
   DECLARE blob_out_detail = c64000
   DECLARE print_disp = vc
   SUBROUTINE uncompress_blob(blob_compressed,blob_length)
     SET blob_size = cnvtint(blob_length)
     SET blob_out_detail = fillstring(64000," ")
     SET blob_compressed_trimmed = fillstring(64000," ")
     SET blob_uncompressed = fillstring(64000," ")
     SET blob_rtf = fillstring(64000," ")
     SET blob_out_detail = fillstring(64000," ")
     SET blob_compressed_trimmed = trim(blob_compressed)
     SET blob_return_len = 0
     SET blob_return_len2 = 0
     CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),blob_uncompressed,
      size(blob_uncompressed),blob_return_len)
     SET i = 1
     WHILE (i <= blob_return_len)
      IF (ichar(substring(i,1,blob_uncompressed))=10)
       SET stat = movestring(" ",1,blob_uncompressed,i,1)
      ELSEIF (ichar(substring(i,1,blob_uncompressed))=13)
       SET stat = movestring(" ",1,blob_uncompressed,i,1)
      ELSEIF (((ichar(substring(i,1,blob_uncompressed)) < 32) OR (((ichar(substring(i,1,
        blob_uncompressed)) > 127) OR (ichar(substring(i,1,blob_uncompressed))=64)) )) )
       SET stat = movestring(" ",1,blob_uncompressed,i,1)
      ENDIF
      SET i += 1
     ENDWHILE
     SET blob_out_detail = blob_uncompressed
     CALL convertrtftopostscript(blob_uncompressed,blob_return_len,blob_rtf,size(blob_rtf),
      blob_return_len2,
      0)
     SET blob_compressed = fillstring(64000," ")
     SET blob_compressed_trimmed = fillstring(64000," ")
   END ;Subroutine
   CALL echo("here1")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(disch->qual)),
     clinical_event ce,
     scd_story s
    PLAN (ce
     WHERE ce.encntr_id=encntr_to_search
      AND ce.event_end_dt_tm BETWEEN cnvtdatetime(beg_dt_tm) AND cnvtdatetime(end_dt_tm)
      AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
     JOIN (d
     WHERE (disch->list[d.seq].cd=ce.event_cd))
     JOIN (s
     WHERE s.encounter_id=ce.encntr_id
      AND s.event_id=ce.parent_event_id
      AND s.story_completion_status_cd=signed_cd)
    ORDER BY ce.parent_event_id, ce.event_id
    HEAD REPORT
     event_cnt = 0
    HEAD ce.parent_event_id
     event_cnt += 1, stat = alterlist(pat->list,event_cnt), pat->list[event_cnt].parent_event_id = ce
     .parent_event_id
    DETAIL
     x = 0
    FOOT REPORT
     pat->event_qual = event_cnt
    WITH nocounter, nullreport
   ;end select
   IF (curqual < 1)
    CALL echo("no record found on scd_story")
   ENDIF
   DECLARE pcp_name = vc
   FREE RECORD att_phys
   RECORD att_phys(
     1 cnt = i4
     1 list[*]
       2 name = vc
   )
   SET att_phys->cnt = 0
   DECLARE attend_doc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
   DECLARE pcp_doc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"PCP"))
   CALL echo("here2")
   SELECT INTO "nl:"
    FROM encntr_prsnl_reltn epr,
     prsnl pr
    PLAN (epr
     WHERE epr.encntr_id=encntr_to_search
      AND epr.encntr_prsnl_r_cd IN (attend_doc_cd, pcp_doc_cd))
     JOIN (pr
     WHERE pr.person_id=epr.prsnl_person_id)
    ORDER BY epr.end_effective_dt_tm DESC
    HEAD REPORT
     row + 0
    DETAIL
     IF (epr.encntr_prsnl_r_cd=pcp_doc_cd
      AND pcp_name <= "")
      pcp_name = trim(pr.name_full_formatted)
     ELSE
      search_var = 0
      FOR (i = 1 TO size(att_phys->cnt))
        IF ((att_phys->list[i].name=pr.name_full_formatted))
         search_var = 1
        ENDIF
      ENDFOR
      IF (search_var=0)
       att_phys->cnt += 1
       IF (mod(att_phys->cnt,10)=1)
        stat = alterlist(att_phys->list,(att_phys->cnt+ 9))
       ENDIF
       att_phys->list[att_phys->cnt].name = pr.name_full_formatted
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(att_phys->list,att_phys->cnt)
    WITH nocounter
   ;end select
   IF (curqual < 1)
    CALL echo("no record found on encntr_prsn_reltn/ prsnl")
   ENDIF
   DECLARE allergy_disp = vc
   DECLARE cancelled_reaction_status_cd = f8
   SET cancelled_reaction_status_cd = uar_get_code_by("MEANING",12025,"CANCELED")
   CALL echo(cancelled_reaction_status_cd)
   CALL echo("here3")
   SELECT INTO "nl:"
    FROM encounter e,
     allergy a,
     nomenclature n
    PLAN (e
     WHERE e.encntr_id=encntr_to_search)
     JOIN (a
     WHERE a.person_id=e.person_id
      AND a.active_ind=1
      AND a.reaction_status_cd != cancelled_reaction_status_cd)
     JOIN (n
     WHERE n.nomenclature_id=a.substance_nom_id)
    HEAD REPORT
     allergy_disp = n.source_string, first_allergy = 1
    DETAIL
     IF (first_allergy=1)
      first_allergy = 0
     ELSE
      allergy_disp = concat(allergy_disp,"; ",trim(n.source_string))
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual < 1)
    CALL echo("no records found on allergies")
   ENDIF
   FREE RECORD med_recon_request
   RECORD med_recon_request(
     1 recon_type = c1
     1 encntr_id = f8
     1 pop1[*]
       2 order_id = f8
       2 catalog_cd = f8
       2 cki = vc
       2 order_mnemonic = vc
       2 order_detail_display_line = vc
       2 clinical_display_line = vc
       2 multum[*]
         3 class_1 = vc
         3 class_2 = vc
         3 class_3 = vc
       2 dose = vc
       2 dose_unit = f8
       2 prn = c3
       2 prn_reason = vc
       2 route = vc
       2 volume_dose = vc
       2 volume_dose_unit = f8
       2 frequency = f8
       2 status = c1
     1 pop2[*]
       2 order_id = f8
       2 catalog_cd = f8
       2 cki = vc
       2 order_mnemonic = vc
       2 order_detail_display_line = vc
       2 clinical_display_line = vc
       2 multum[*]
         3 class_1 = vc
         3 class_2 = vc
         3 class_3 = vc
       2 dose = vc
       2 dose_unit = f8
       2 prn = c3
       2 prn_reason = vc
       2 route = vc
       2 volume_dose = vc
       2 volume_dose_unit = f8
       2 frequency = f8
       2 status = c1
       2 info_line = vc
   )
   DECLARE pharmacy_act_type_cd = f8
   DECLARE ordered_order_status_cd = f8
   SET pharmacy_act_type_cd = uar_get_code_by("DISPLAYKEY",106,"PHARMACY")
   SET ordered_order_status_cd = uar_get_code_by("MEANING",6004,"ORDERED")
   DECLARE date_to_check = dq8
   DECLARE loc_facility_cd = f8
   CALL echo("here4")
   SELECT INTO "nl:"
    FROM encounter e
    PLAN (e
     WHERE e.encntr_id=encntr_to_search)
    DETAIL
     date_to_check = cnvtlookahead("1D",e.reg_dt_tm), loc_facility_cd = e.loc_facility_cd
    WITH nocounter
   ;end select
   DECLARE stop_count = i4
   SET stop_count = 0
   CALL echo(build2("facility: ",uar_get_code_display(loc_facility_cd)))
   IF ( NOT (uar_get_code_display(loc_facility_cd) IN ("BMC", "BMC INPTPSYCH", "FMC", "FMC INPTPSYCH",
   "MLH",
   "BFMC", "BFMC INPTPSYCH", "BMLH", "BWH", "BWHINPTPSYCH")))
    CALL echo("here5")
    SELECT INTO "nl:"
     FROM orders o,
      encounter e,
      order_action oa
     PLAN (e
      WHERE e.encntr_id=encntr_to_search)
      JOIN (o
      WHERE o.person_id=e.person_id
       AND o.orig_ord_as_flag IN (1, 2)
       AND o.template_order_flag IN (0, 1)
       AND o.activity_type_cd=pharmacy_act_type_cd)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_dt_tm < cnvtdatetime(date_to_check)
       AND oa.order_status_cd=ordered_order_status_cd
       AND  NOT ( EXISTS (
      (SELECT
       oa2.order_id
       FROM order_action oa2
       WHERE oa2.order_id=oa.order_id
        AND oa2.action_dt_tm > oa.action_dt_tm
        AND oa2.action_dt_tm < cnvtdatetime(date_to_check)))))
     ORDER BY o.catalog_cd, o.order_id
     HEAD REPORT
      cnt = 0
     HEAD o.order_id
      cnt += 1
      IF (mod(cnt,10)=1)
       stat = alterlist(med_recon_request->pop1,(cnt+ 9))
      ENDIF
      med_recon_request->pop1[cnt].order_id = o.order_id, med_recon_request->pop1[cnt].catalog_cd = o
      .catalog_cd, med_recon_request->pop1[cnt].cki = o.cki
      IF (o.hna_order_mnemonic=o.ordered_as_mnemonic)
       med_recon_request->pop1[cnt].order_mnemonic = o.order_mnemonic
      ELSE
       med_recon_request->pop1[cnt].order_mnemonic = concat(trim(o.ordered_as_mnemonic)," (",trim(o
         .hna_order_mnemonic),")")
      ENDIF
      med_recon_request->pop1[cnt].clinical_display_line = o.clinical_display_line, med_recon_request
      ->pop1[cnt].status = "S"
     FOOT REPORT
      stat = alterlist(med_recon_request->pop1,cnt)
     WITH nocounter
    ;end select
    IF (curqual < 1)
     CALL echo("nothing on orders")
    ENDIF
    CALL echo("here6")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(med_recon_request->pop1,5))),
      order_detail od
     PLAN (d)
      JOIN (od
      WHERE (od.order_id=med_recon_request->pop1[d.seq].order_id)
       AND od.oe_field_meaning IN ("VOLUMEDOSE", "VOLUMEDOSEUNIT", "FREQ", "STRENGTHDOSE",
      "STRENGTHDOSEUNIT",
      "RXROUTE", "FREETXTDOSE", "SPECINX", "SCH/PRN", "PRNINSTRUCTIONS"))
     DETAIL
      IF (od.oe_field_meaning="VOLUMEDOSE")
       med_recon_request->pop1[d.seq].volume_dose = trim(od.oe_field_display_value)
      ELSEIF (od.oe_field_meaning="STRENGTHDOSE")
       med_recon_request->pop1[d.seq].dose = trim(od.oe_field_display_value)
      ELSEIF (od.oe_field_meaning="FREETXTDOSE"
       AND od.oe_field_display_value != "See Instructions")
       med_recon_request->pop1[d.seq].dose = trim(od.oe_field_display_value)
      ELSEIF (od.oe_field_meaning="SPECINX")
       med_recon_request->pop1[d.seq].dose = trim(od.oe_field_display_value)
      ELSEIF (od.oe_field_meaning="VOLUMEDOSEUNIT")
       med_recon_request->pop1[d.seq].volume_dose_unit = cnvtreal(od.oe_field_value)
      ELSEIF (od.oe_field_meaning="STRENGTHDOSEUNIT")
       med_recon_request->pop1[d.seq].dose_unit = cnvtreal(od.oe_field_value)
      ELSEIF (od.oe_field_meaning="FREQ")
       med_recon_request->pop1[d.seq].frequency = cnvtreal(od.oe_field_value)
      ELSEIF (od.oe_field_meaning="RXROUTE")
       med_recon_request->pop1[d.seq].route = trim(od.oe_field_display_value)
      ELSEIF (od.oe_field_meaning="SCH/PRN")
       med_recon_request->pop1[d.seq].prn = trim(od.oe_field_display_value)
      ELSEIF (od.oe_field_meaning="PRNINSTRUCTIONS")
       med_recon_request->pop1[d.seq].prn_reason = trim(od.oe_field_display_value)
      ENDIF
     WITH nocounter
    ;end select
    DECLARE cnt = i4
    CALL echo("here7")
    SELECT INTO "nl:"
     FROM orders o,
      encounter e
     PLAN (e
      WHERE e.encntr_id=encntr_to_search)
      JOIN (o
      WHERE o.person_id=e.person_id
       AND o.orig_ord_as_flag IN (1, 2)
       AND o.template_order_flag IN (0, 1)
       AND o.activity_type_cd=pharmacy_act_type_cd
       AND ((o.order_status_cd+ 0)=2550))
     HEAD REPORT
      cnt = 0
     HEAD o.order_id
      cnt += 1
      IF (mod(cnt,10)=1)
       stat = alterlist(med_recon_request->pop2,(cnt+ 9))
      ENDIF
      med_recon_request->pop2[cnt].order_id = o.order_id, med_recon_request->pop2[cnt].catalog_cd = o
      .catalog_cd, med_recon_request->pop2[cnt].cki = o.cki
      IF (o.hna_order_mnemonic=o.ordered_as_mnemonic)
       med_recon_request->pop2[cnt].order_mnemonic = o.order_mnemonic
      ELSE
       med_recon_request->pop2[cnt].order_mnemonic = concat(trim(o.ordered_as_mnemonic)," (",trim(o
         .hna_order_mnemonic),")")
      ENDIF
      med_recon_request->pop2[cnt].clinical_display_line = o.clinical_display_line
     FOOT REPORT
      stat = alterlist(med_recon_request->pop2,cnt)
     WITH nocounter
    ;end select
    IF (curqual < 1)
     CALL echo("no current home meds")
    ENDIF
    CALL echo("here8")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(med_recon_request->pop2,5))),
      order_detail od
     PLAN (d)
      JOIN (od
      WHERE (od.order_id=med_recon_request->pop2[d.seq].order_id)
       AND od.oe_field_meaning IN ("VOLUMEDOSE", "VOLUMEDOSEUNIT", "FREQ", "STRENGTHDOSE",
      "STRENGTHDOSEUNIT",
      "RXROUTE", "FREETXTDOSE", "SPECINX", "SCH/PRN", "PRNINSTRUCTIONS"))
     DETAIL
      IF (od.oe_field_meaning="VOLUMEDOSE")
       med_recon_request->pop2[d.seq].volume_dose = trim(od.oe_field_display_value)
      ELSEIF (od.oe_field_meaning="STRENGTHDOSE")
       med_recon_request->pop2[d.seq].dose = trim(od.oe_field_display_value)
      ELSEIF (od.oe_field_meaning="VOLUMEDOSEUNIT")
       med_recon_request->pop2[d.seq].volume_dose_unit = cnvtreal(od.oe_field_value)
      ELSEIF (od.oe_field_meaning="FREETXTDOSE"
       AND od.oe_field_display_value != "See Instructions")
       med_recon_request->pop2[d.seq].dose = trim(od.oe_field_display_value)
      ELSEIF (od.oe_field_meaning="SPECINX")
       med_recon_request->pop2[d.seq].dose = trim(od.oe_field_display_value)
      ELSEIF (od.oe_field_meaning="STRENGTHDOSEUNIT")
       med_recon_request->pop2[d.seq].dose_unit = cnvtreal(od.oe_field_value)
      ELSEIF (od.oe_field_meaning="FREQ")
       med_recon_request->pop2[d.seq].frequency = cnvtreal(od.oe_field_value)
      ELSEIF (od.oe_field_meaning="RXROUTE")
       med_recon_request->pop2[d.seq].route = trim(od.oe_field_display_value)
      ELSEIF (od.oe_field_meaning="SCH/PRN")
       med_recon_request->pop2[d.seq].prn = trim(od.oe_field_display_value)
      ELSEIF (od.oe_field_meaning="PRNINSTRUCTIONS")
       med_recon_request->pop2[d.seq].prn_reason = trim(od.oe_field_display_value)
      ENDIF
     WITH nocounter
    ;end select
    CALL echorecord(med_recon_request)
    FOR (i = 1 TO size(med_recon_request->pop2,5))
     SET med_recon_request->pop2[i].status = "N"
     FOR (j = 1 TO size(med_recon_request->pop1,5))
       IF ((med_recon_request->pop2[i].catalog_cd=med_recon_request->pop1[j].catalog_cd))
        SET med_recon_request->pop2[i].info_line = ""
        SET med_recon_request->pop2[i].status = "C"
        SET med_recon_request->pop1[j].status = "C"
        IF ((((med_recon_request->pop1[j].dose != med_recon_request->pop2[i].dose)) OR ((
        med_recon_request->pop1[j].dose_unit != med_recon_request->pop2[i].dose_unit))) )
         SET med_recon_request->pop2[i].info_line = concat(" Dose Change (",med_recon_request->pop1[j
          ].dose," ",trim(uar_get_code_display(med_recon_request->pop1[j].dose_unit)),")")
        ELSEIF ((((med_recon_request->pop1[j].volume_dose != med_recon_request->pop2[i].volume_dose))
         OR ((med_recon_request->pop1[j].volume_dose_unit != med_recon_request->pop2[i].
        volume_dose_unit))) )
         SET med_recon_request->pop2[i].info_line = concat(" Dose Change (",med_recon_request->pop1[j
          ].volume_dose," ",trim(uar_get_code_display(med_recon_request->pop1[j].volume_dose_unit)),
          ")")
        ENDIF
        IF ((med_recon_request->pop1[j].route != med_recon_request->pop2[i].route))
         SET med_recon_request->pop2[i].info_line = concat(med_recon_request->pop2[i].info_line,
          " Route Change (",med_recon_request->pop1[j].route,")")
        ENDIF
        IF ((med_recon_request->pop1[j].frequency != med_recon_request->pop2[i].frequency))
         SET med_recon_request->pop2[i].info_line = concat(med_recon_request->pop2[i].info_line,
          " Frequency Change (",trim(uar_get_code_display(med_recon_request->pop1[j].frequency)),")")
        ENDIF
        IF ((med_recon_request->pop1[j].prn != med_recon_request->pop2[i].prn))
         SET med_recon_request->pop2[i].info_line = concat(med_recon_request->pop2[i].info_line,
          " PRN Change ")
        ENDIF
       ENDIF
     ENDFOR
    ENDFOR
    FOR (i = 1 TO size(med_recon_request->pop1,5))
      IF ((med_recon_request->pop1[i].status="S"))
       SET stop_count += 1
      ENDIF
    ENDFOR
   ENDIF
   DECLARE printstring = vc
   DECLARE tempstring = vc
   CALL echo("TEST")
   DECLARE i = i4
   FOR (agc = 1 TO pat->event_qual)
     SET file_name = concat("bhspatdisch",cnvtstring(encntr_to_search),cnvtstring(agc))
     SET i = 0
     SELECT INTO value(file_name)
      name = substring(1,50,p.name_full_formatted), dob = format(cnvtdatetimeutc(datetimezone(p
         .birth_dt_tm,p.birth_tz),1),"mm/dd/yyyy;;d"), admitdoc = substring(1,30,pl
       .name_full_formatted),
      admit_dt = format(e.reg_dt_tm,"mm/dd/yy;;d"), location = substring(1,20,uar_get_code_display(e
        .location_cd)), facility = uar_get_code_description(e.loc_facility_cd),
      room = substring(1,30,uar_get_code_display(e.loc_room_cd)), unit = substring(1,30,
       uar_get_code_display(e.loc_nurse_unit_cd)), bed = substring(1,30,uar_get_code_display(e
        .loc_bed_cd)),
      finnbr = decode(ea.seq,substring(1,20,cnvtalias(ea.alias,ea.alias_pool_cd))), mrn = cnvtalias(
       pa.alias,pa.alias_pool_cd), mrn_pool = uar_get_code_display(pa.alias_pool_cd),
      age = build(trim(cnvtage(cnvtdate(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)),
         curdate))), sex = build(trim(uar_get_code_display(p.sex_cd))), event_cd_disp = substring(1,
       40,uar_get_code_display(ce.event_cd)),
      event_title_text = substring(1,110,ce.event_title_text), event_tag = substring(1,50,ce
       .event_tag), event_id = ce.event_id,
      parent_event_id = ce.parent_event_id, event_date = substring(1,20,format(ce.event_end_dt_tm,
        "mm/dd/yyyy hh:mm;;d")), author = substring(1,40,pl2.name_full_formatted),
      author_dt = format(cep.action_dt_tm,"@LONGDATE;L"), author_wk = format(cep.action_dt_tm,
       "WWWWWWWWW;;d"), author_tm = format(cep.action_dt_tm,"hh:mm;;d")
      FROM clinical_event ce,
       ce_blob ceb,
       ce_event_prsnl cep,
       encounter e,
       person p,
       encntr_alias ea,
       person_alias pa,
       encntr_prsnl_reltn epr,
       prsnl pl,
       prsnl pl2
      PLAN (ce
       WHERE (ce.parent_event_id=pat->list[agc].parent_event_id)
        AND ce.event_end_dt_tm BETWEEN cnvtdatetime(beg_dt_tm) AND cnvtdatetime(end_dt_tm)
        AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
       JOIN (ceb
       WHERE ceb.event_id=ce.event_id
        AND ceb.valid_until_dt_tm > cnvtdatetime(sysdate))
       JOIN (cep
       WHERE (cep.event_id= Outerjoin(ce.event_id))
        AND (cep.valid_until_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00")))
        AND (cep.action_type_cd= Outerjoin(sign_cd)) )
       JOIN (pl2
       WHERE (pl2.person_id= Outerjoin(cep.action_prsnl_id))
        AND (pl2.active_ind= Outerjoin(1)) )
       JOIN (e
       WHERE e.encntr_id=ce.encntr_id)
       JOIN (p
       WHERE p.person_id=e.person_id
        AND p.active_ind=1)
       JOIN (pa
       WHERE (pa.person_id= Outerjoin(p.person_id))
        AND (pa.person_alias_type_cd= Outerjoin(mrn_cd))
        AND (pa.active_ind= Outerjoin(1)) )
       JOIN (ea
       WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
        AND (ea.encntr_alias_type_cd= Outerjoin(fin_cd))
        AND (ea.active_ind= Outerjoin(1)) )
       JOIN (epr
       WHERE (epr.encntr_id= Outerjoin(e.encntr_id))
        AND (epr.encntr_prsnl_r_cd= Outerjoin(admitdoc))
        AND (epr.active_ind= Outerjoin(1)) )
       JOIN (pl
       WHERE (pl.person_id= Outerjoin(epr.prsnl_person_id)) )
      ORDER BY ce.event_end_dt_tm, ceb.event_id
      HEAD REPORT
       MACRO (dcp_parse_text)
        lf = concat(char(13),char(10)), l = 0, h = 0,
        cr = 0, length = 0, check_blob = fillstring(32000," "),
        check_blob = blob_test2, max_length = max_length, check_blob = concat(trim(check_blob),lf),
        blob->cnt = 0, cr = findstring(lf,check_blob), length = textlen(check_blob)
        WHILE (cr > 0)
          blob->line = substring(1,(cr - 1),check_blob), check_blob = substring((cr+ 2),(length - (cr
           + 2)),check_blob), blob->cnt += 1,
          stat = alterlist(blob->qual,blob->cnt), blob->qual[blob->cnt].line = trim(blob->line), blob
          ->qual[blob->cnt].sze = textlen(trim(blob->line)),
          cr = findstring(lf,check_blob)
        ENDWHILE
        FOR (j = 1 TO blob->cnt)
          WHILE ((blob->qual[j].sze > max_length))
            h = l, c = max_length
            WHILE (c > 0)
             IF (substring(c,1,blob->qual[j].line) IN (" ", "-"))
              l += 1, stat = alterlist(pt->lns,l), pt->lns[l].line = substring(1,c,blob->qual[j].line
               ),
              blob->qual[j].line = substring((c+ 1),(blob->qual[j].sze - c),blob->qual[j].line), c =
              1
             ENDIF
             ,c -= 1
            ENDWHILE
            IF (h=l)
             l += 1, stat = alterlist(pt->lns,l), pt->lns[l].line = substring(1,max_length,blob->
              qual[j].line),
             blob->qual[j].line = substring((max_length+ 1),(blob->qual[j].sze - max_length),blob->
              qual[j].line)
            ENDIF
            blob->qual[j].sze = size(trim(blob->qual[j].line))
          ENDWHILE
          l += 1, stat = alterlist(pt->lns,l), pt->lns[l].line = substring(1,blob->qual[j].sze,blob->
           qual[j].line),
          pt->line_cnt = l
        ENDFOR
       ENDMACRO
       , xcol = 25, ycol = 75,
       name_disp = fillstring(10," "), name_disp = build(trim(name)), auth_disp_line = fillstring(110,
        " "),
       mrn_disp = concat(trim(mrn_pool),char(58),char(32),trim(mrn)), age_disp = concat("Age:",char(
         32),trim(age)), sex_disp = concat("Sex:",char(32),trim(sex)),
       fac_disp = build(trim(facility)), line1 = fillstring(84,"_"), line2 = fillstring(31,"_"),
       line3 = fillstring(100,"_"), instr_data = fillstring(300," "),
       MACRO (line_wrap)
        limit = 0, cr = char(13), lf = char(10)
        WHILE (tempstring > " "
         AND limit < 1000)
          ii = 0, limit += 1, pos = 0
          WHILE (pos=0)
           ii += 1,
           IF (substring((maxlen - ii),1,tempstring) IN (" ", ","))
            pos = (maxlen - ii)
           ELSEIF (ii=maxlen)
            pos = maxlen
           ENDIF
          ENDWHILE
          printstring = substring(1,pos,tempstring)
          IF (limit > 1)
           printstring = concat("   ",printstring)
          ENDIF
          lfloc = findstring(lf,printstring), crloc = findstring(cr,printstring)
          IF (lfloc=0
           AND crloc=0)
           CALL print(calcpos(xcol,ycol)), printstring, row + 1,
           ycol += 12, tempstring = substring((pos+ 1),9999,tempstring)
          ELSE
           IF (((crloc < lfloc
            AND crloc > 0) OR (lfloc=0)) )
            printstring = substring(1,(crloc - 1),printstring),
            CALL print(calcpos(xcol,ycol)), printstring,
            row + 1, ycol += 12, tempstring = substring((crloc+ 2),9999,tempstring)
           ELSEIF (((lfloc < crloc
            AND lfloc > 0) OR (crloc=0)) )
            printstring = substring(1,(lfloc - 1),printstring),
            CALL print(calcpos(xcol,ycol)), printstring,
            row + 1, ycol += 12, tempstring = substring((lfloc+ 2),9999,tempstring)
           ENDIF
           WHILE (substring(1,1,tempstring) IN (" ", cr, lf))
             tempstring = substring(2,9999,tempstring)
           ENDWHILE
          ENDIF
        ENDWHILE
       ENDMACRO
      HEAD PAGE
       "{f/8}{CPI/8}{pos/55/60}{color/20/120}", row + 1, "{f/8}{CPI/8}{pos/55/65}{color/20/120}",
       row + 1, "{f/8}{CPI/8}{pos/55/70}{color/20/120}", row + 1,
       "{f/8}{CPI/8}{pos/55/75}{color/20/120}", row + 1, "{f/8}{CPI/8}{pos/55/80}{color/20/120}",
       row + 1, "{f/8}{CPI/8}{pos/55/85}{color/20/120}", row + 1,
       "{f/8}{CPI/8}{pos/55/90}{color/20/120}", row + 1, "{f/8}{CPI/8}{pos/55/95}{color/20/120}",
       row + 1, ycol = 80, xcol = 55,
       "{pos/58/80}{f/8}{cpi/10}{b}PATIENT NAME: ", xcol = 155,
       CALL print(calcpos(xcol,ycol)),
       name, "{endb}", row + 1,
       xcol = 400,
       CALL print(calcpos(xcol,ycol)), "{b}Acct # ",
       finnbr, "{endb}", row + 1,
       ycol += 30, xcol = 55
       IF (curpage != 1)
        CALL print(calcpos(xcol,ycol)), "{f/4}{cpi/10}", ycol += 12
       ENDIF
      HEAD ce.event_id
       xcol = 55, ycol += 12
       IF (cep.action_type_cd=sign_cd)
        auth_disp_line = concat(trim(event_tag),char(32),"by",char(32),trim(author),
         char(32),"on",char(32),trim(author_wk,3),char(44),
         char(32),trim(author_dt,3),char(32),trim(author_tm,3))
       ELSE
        auth_disp_line = event_title_text
       ENDIF
       IF (size(auth_disp_line) < 120)
        CALL print(calcpos(xcol,ycol)), "{f/8}{cpi/11}{b}", auth_disp_line,
        "{ENDB}", row + 1, ycol += 12,
        CALL print(calcpos(xcol,ycol)), "{f/4}{cpi/10}", ycol += 12
       ELSE
        auth_disp_line_a = substring(1,findstring(" on ",auth_disp_line),auth_disp_line),
        auth_disp_line_b = substring(findstring(" on ",auth_disp_line),size(auth_disp_line),
         auth_disp_line),
        CALL print(calcpos(xcol,ycol)),
        "{f/8}{cpi/11}{b}", auth_disp_line_a, "{ENDB}",
        row + 1, ycol += 12,
        CALL print(calcpos(xcol,ycol)),
        "{f/8}{cpi/11}{b}", auth_disp_line_b, "{ENDB}",
        row + 1, ycol += 12,
        CALL print(calcpos(xcol,ycol)),
        "{f/4}{cpi/10}", ycol += 12
       ENDIF
       CALL uncompress_blob(ceb.blob_contents,ceb.blob_length), blob_test1 = replace(blob_out_detail,
        char(10),"|",0), blob_test1 = replace(blob_test1,"PRN","as needed",0),
       blob_test1 = replace(blob_test1,"Discharge Nursing Homes/Rehab Facilities",concat(char(225),
         "Discharge Nursing Homes/Rehab Facilities",char(222)),0), blob_test1 = replace(blob_test1,
        "Discharge Adult Day Health Care",concat(char(225),"Discharge Adult Day Health Care",char(222
          )),0), blob_test1 = replace(blob_test1,"Discharge Rest Homes/Residences/Shelters",concat(
         char(225),"Discharge Rest Homes/Residences/Shelters",char(222)),0),
       blob_test1 = replace(blob_test1,"Discharge VNA/Hospice/Home Care",concat(char(225),
         "Discharge VNA/Hospice/Home Care",char(222)),0), blob_test1 = replace(blob_test1,
        "Discharge Early Intervention Programs",concat(char(225),
         "Discharge Early Intervention Programs",char(222)),0), blob_test1 = replace(blob_test1,
        "Discharge Medical Equipment Companies",concat(char(225),
         "Discharge Medical Equipment Companies",char(222)),0),
       blob_test1 = replace(blob_test1,"Discharge Chronic Hospital",concat(char(225),
         "Discharge Chronic Hospital",char(222)),0), blob_test1 = replace(blob_test1,"Name of Agency",
        concat(char(225),"Name of Agency",char(222)),0), blob_test1 = replace(blob_test1,
        "Agency Contact Person",concat(char(225),"Agency Contact Person",char(222)),0),
       blob_test1 = replace(blob_test1,"Additional agency referral info",concat(char(225),
         "Additional agency referral info",char(222)),0), blob_test1 = replace(blob_test1,
        "Additional instructions to patient",concat(char(225),"Additional instructions to patient",
         char(222)),0), blob_test1 = replace(blob_test1,"Service Start Date and Time",concat(char(225
          ),"Service Start Date and Time",char(222)),0),
       blob_test1 = replace(blob_test1,"Service Categories",concat(char(225),"Service Categories",
         char(222)),0), blob_test1 = build(blob_test1,char(124)), eol = size(trim(blob_test1,1),1),
       delimiter = findstring(char(124),blob_test1)
       WHILE (delimiter > 0)
         IF (blob_test1="*TX_RTF32 9.0.310.500*")
          blob_test2 = concat(trim(substring(25,(delimiter - 1),blob_test1)))
         ELSE
          blob_test2 = concat(trim(substring(1,(delimiter - 1),blob_test1)))
         ENDIF
         stat = alterlist(blob->qual,1), blob->line = "", blob->cnt = 0,
         stat = alterlist(pt->lns,1), pt->line_cnt = 0, max_length = 90,
         tab = "", i = 1, xcnt = 0,
         space = " "
         WHILE (i <= size(trim(blob_test2)))
          IF (ichar(substring(i,1,trim(blob_test2)))=185)
           tab = concat(char(0),tab,"    ",char(0))
          ELSEIF (substring(i,1,trim(blob_test2))=char(225)
           AND i=1)
           xcnt = i
           WHILE (substring((xcnt+ 4),1,trim(blob_test2))=space
            AND xcnt < size(trim(blob_test2)))
             xcnt += 1
           ENDWHILE
           IF (xcnt > i)
            blob_test2 = concat(substring(1,i,trim(blob_test2)),substring((xcnt+ 3),size(trim(
                blob_test2)),blob_test2)),
            CALL echo(build("parseing spaces on bold",blob_test2))
           ENDIF
          ELSEIF (ichar(substring(i,1,trim(blob_test2))) BETWEEN 33 AND 126)
           i = size(trim(blob_test2))
          ENDIF
          ,i += 1
         ENDWHILE
         max_length -= size(tab), dcp_parse_text, line_cnt = 0,
         prevlinebold = 0
         FOR (line_cnt = 1 TO pt->line_cnt)
           xcol = 55,
           CALL echo(build("!!@@",concat(trim(pt->lns[line_cnt].line)),"!!@")), print_disp = concat(
            tab,trim(pt->lns[line_cnt].line)),
           print_disp = replace(print_disp,char(185),""), print_disp = replace(print_disp,char(222),
            "{ENDB}",0), print_disp = replace(print_disp,char(225),"{b}",0),
           print_disp = trim(print_disp)
           IF (line_cnt > 1)
            print_disp = concat("  ",print_disp)
           ENDIF
           IF (prevlinebold=1)
            print_disp = concat("{b}",print_disp)
           ENDIF
           CALL echo(build("JAD",concat(trim(pt->lns[line_cnt].line)),"!!@")),
           CALL print(calcpos(xcol,ycol)), "{f/8}{cpi/10}{lpi/12}",
           print_disp, row + 3, bfound = findstring("{b}",print_disp,1,1),
           endbfound = findstring("{ENDB}",print_disp,1,1)
           IF (((endbfound < bfound) OR (prevlinebold
            AND endbfound=0)) )
            prevlinebold = 1
           ELSE
            prevlinebold = 0
           ENDIF
           CALL echo(build("--",print_disp)), ycol += 12
           IF (ycol > 650)
            BREAK
           ENDIF
         ENDFOR
         blob_test1 = substring((delimiter+ 1),eol,blob_test1), eol = size(trim(blob_test1),1),
         delimiter = findstring("|",blob_test1),
         end_col = ycol
       ENDWHILE
      FOOT PAGE
       IF (curpage != 1)
        ycol = 664, xcol = 218,
        CALL print(calcpos(xcol,ycol)),
        "{f/4}{cpi/12}{lpi/8}",
        CALL print(calcpos(xcol,ycol)), "{b}",
        "****  Continued From Previous Page  ****", "{endb}", "{pos/55/660}",
        line2, row + 1, "{pos/410/660}",
        line2, row + 1
       ELSE
        "{pos/55/660}", line1, row + 1
       ENDIF
       "{f/4}{cpi/12}{lpi/8}{pos/260/687}", "{b/7}Patient: ", "{pos/297/687}",
       name, xxx = concat(trim(unit)," / ",trim(room)," / ",trim(bed)), "{pos/440/687}",
       "{b/8}Location: ", xxx, row + 1,
       "{pos/260/698}", "{b/6}Acct #: ", finnbr,
       row + 1, "{pos/440/698}", "{b/3}ADM: ",
       admit_dt, row + 1, "{pos/260/709}",
       "{b/7}", mrn_disp, row + 1,
       "{pos/370/709}", "{b/3}", age_disp,
       "{pos/440/709}", "{b/3}", sex_disp,
       row + 1
       IF (facility="BAYSTATE MEDICAL CENTER INPATIENT PSYCHIATRY")
        facility_out = "BAYSTATE MEDICAL CENTER"
       ELSEIF (facility="FRANKLIN MEDICAL CENTER INPATIENT PSYCHIATRY")
        facility_out = "FRANKLIN MEDICAL CENTER"
       ELSE
        facility_out = facility
       ENDIF
       "{pos/260/720}", "{b/12}Admitting MD: ", admitdoc,
       row + 1, "{pos/440/731}", "{b/6}Page # ",
       curpage, row + 1, "{cpi/10}{pos/55/693}{b}",
       facility_out, row + 1, "{cpi/10}{pos/55/708}{b}",
       "Patient Instructions for Discharge", "{f/8}{cpi/15}{lpi/10}{pos/55/720}", "BHS_PAT_DISCH",
       "{f/4}{cpi/12}{pos/55/732}{b/8}Printed: ", curdate, "  ",
       curtime, "{endb}", row + 1
      FOOT REPORT
       CALL echo(build2("****** ycol",ycol," ********"))
       IF (ycol > 400)
        BREAK
       ENDIF
       CALL print(calcpos(xcol,ycol)), "{f/8}{cpi/11}{b}", instr_data =
       "Smoking can increase your chances of developing chronic health problems or worsen",
       ycol += 15,
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1,
       CALL print(calcpos(xcol,ycol)), "{f/8}{cpi/11}{b}",
       instr_data = "conditions you already have.  If you smoke, you should quit.  Smoking cessation",
       ycol += 15,
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "{f/8}{cpi/11}{b}", instr_data =
       "information has been given to you for your review to help you quit. Medications to", ycol +=
       15,
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       CALL print(calcpos(xcol,ycol)), "{f/8}{cpi/11}{b}", instr_data =
       "help you quit are available.  Ask your doctor if you would like to receive these medications.",
       ycol += 15,
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1,
       CALL print(calcpos(xcol,ycol)), "{f/8}{cpi/11}{b}",
       instr_data = "Remember, smoking is not allowed at any Baystate Health facility.", ycol += 15,
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 2,
       CALL print(calcpos(xcol,ycol)),
       "{f/8}{cpi/11}{b}", ycol += 12, xcol = 55,
       CALL print(calcpos(xcol,ycol)), "{f/8}{cpi/11}", instr_data =
       "I HAVE EXPLAINED THE INSTRUCTIONS TO THE PATIENT/REPRESENTATIVE.",
       ycol += 30,
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, ycol += 24, instr_data = "{u/85}",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       xcol = 440, instr_data = "{u/40}",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, ycol += 15,
       xcol = 55, instr_data = "SIGNATURE OF NURSE/INTERPRETER",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, xcol = 440,
       instr_data = "DATE",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, xcol = 55, instr_data =
       "I WAS GIVEN A COPY OF THIS FORM AND I UNDERSTAND AND ACCEPT THIS INFORMATION.",
       ycol += 24,
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, ycol += 24, instr_data = "{u/85}",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       xcol = 440, instr_data = "{u/40}",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, ycol += 15,
       xcol = 55, instr_data = "SIGNATURE OF PATIENT/REPRESENTATIVE",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, xcol = 440,
       instr_data = "DATE",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, ycol += 24, xcol = 55,
       CALL print(calcpos(xcol,ycol)), "{f/8}{cpi/10}",
       CALL echo("ADAM"),
       BREAK, ycol += 15, xcol = 55,
       row 15, col 0, "{f/8}{cpi/10}",
       row 16, col 0,
       CALL center("{b}AN IMPORTANT NOTICE TO PATIENTS AND THEIR REPRESENTATIVES{endb}",1,110),
       row + 1, instr_data =
       "We at Baystate Health are interested in providing you with the highest quality services",
       ycol += 48,
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol += 12, instr_data =
       "available. Part of this goal is to provide you with a written discharge plan for your reference",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, instr_data = "after discharge.",
       ycol += 12,
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, ycol += 24, instr_data =
       "In the event you have questions about your discharge plan once you leave, please call:",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol += 24, instr_data = "{u/85}",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, xcol = 440,
       instr_data = "{u/35}",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, ycol += 15, xcol = 55,
       instr_data = "Name/Title",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, xcol = 440, instr_data = "Phone #",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol += 24, xcol = 55, instr_data =
       "If you do not agree with this Discharge Plan please notify the above mentioned person",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol += 12, instr_data =
       "immediately so that a meeting can be arranged with you or your representative, your physician",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, ycol += 12,
       instr_data = "and other care providers in order to develop a plan that is acceptable to you.",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, ycol += 24, instr_data =
       "{b/100}If you are a Medicare recipient and you do not believe that an acceptable plan has been",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol += 12, instr_data =
       "{b/100}reached as a result of the meeting you may file a request for review to the Department of",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, ycol += 12,
       instr_data = "{b/100}Public Health Advocacy Office at 1-800-462-5540.",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, ycol += 24, instr_data =
       "{b/100}If you are discharged home with no services and subsequently admitted to a visiting nurse ",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol += 12, instr_data =
       "{b/100}service or a  skilled nursing  facility  within the first three days following your discharge,",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, ycol += 12,
       instr_data = "{b/100}please contact your hospital's Case Management Office:",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, xcol = 225, ycol += 24,
       instr_data = "{b/100}Baystate Mary Lane Hospital",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, xcol = 440, instr_data = "{b/100}(413)-967-2205",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       xcol = 225, ycol += 12, instr_data = "{b/100}Baystate Medical Center",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       xcol = 440, instr_data = "{b/100}(413)-794-4040",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, xcol = 225,
       ycol += 12, instr_data = "{b/100}Baystate Franklin Medical Center",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, xcol = 440,
       instr_data = "{b/100}(413)-773-2303",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, xcol = 55, ycol += 24,
       instr_data =
       "Medication Instructions and follow-up appointments will be reviewed with you prior to discharge.",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, ycol += 24, instr_data =
       "Once you have received your discharge plan, we ask that you sign your name below to indicate",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol += 12, instr_data =
       "that you have participated in its development and have received a copy for your reference after",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, ycol += 12,
       instr_data = "discharge.",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, ycol += 24, instr_data =
       "Your signature does not necessarily indicate approval of the plan.",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol += 36, instr_data = "{u/85}",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, xcol = 440,
       instr_data = "{u/35}",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, ycol += 15, xcol = 55,
       instr_data = "Signature of Patient/Representative",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, xcol = 440, instr_data = "Date",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol += 36, xcol = 55, instr_data = "{u/85}",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol += 12, instr_data = "Relationship of Representative to Patient",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, "{f/4}{cpi/12}{lpi/8}",
       CALL print(calcpos(55,660)), line3, row + 1,
       "{f/4}{cpi/12}{lpi/8}",
       CALL print(calcpos(239,674)), "{b}",
       "****  END OF REPORT  ****", "{endb}", "{cpi/12}{pos/260/687}",
       "{b/7}Patient: ", "{pos/297/687}", name,
       xxx = concat(trim(unit)," / ",trim(room)," / ",trim(bed)), "{pos/440/687}", "{b/8}Location: ",
       xxx, row + 1, "{pos/260/698}",
       "{b/6}Acct #: ", finnbr, row + 1,
       "{pos/440/698}", "{b/3}ADM: ", admit_dt,
       row + 1, "{pos/260/709}", "{b/7}",
       mrn_disp, row + 1, "{pos/370/709}",
       "{b/3}", age_disp, "{pos/440/709}",
       "{b/3}", sex_disp, row + 1,
       "{pos/260/720}", "{b/12}Admitting MD: ", admitdoc,
       row + 1
       IF (facility="BAYSTATE MEDICAL CENTER INPATIENT PSYCHIATRY")
        facility_out = "BAYSTATE MEDICAL CENTER"
       ELSEIF (facility="FRANKLIN MEDICAL CENTER INPATIENT PSYCHIATRY")
        facility_out = "FRANKLIN MEDICAL CENTER"
       ELSE
        facility_out = facility
       ENDIF
       "{pos/440/731}", "{b/6}Page # ", curpage,
       row + 1, "{cpi/10}{pos/55/693}{b}", facility_out,
       row + 1, "{cpi/10}{pos/55/708}{b}", "Patient Instructions for Discharge",
       "{f/8}{cpi/15}{lpi/10}{pos/55/720}", "BHS_PAT_DISCH",
       "{f/4}{cpi/12}{pos/55/732}{b/8}Printed: ",
       curdate, "  ", curtime,
       "{endb}", row + 1
      WITH maxrow = 750, maxcol = 3200, dio = postscript,
       nullreport
     ;end select
     SET spool patstring(file_name) patstring(printer_name) WITH copy = 1
     SET spool patstring(file_name) patstring(printer_name) WITH copy = 1, deleted
   ENDFOR
 ENDFOR
 CALL echorecord(disch)
 CALL echorecord(pat)
 CALL echorecord(blob)
 CALL echorecord(pt)
END GO
