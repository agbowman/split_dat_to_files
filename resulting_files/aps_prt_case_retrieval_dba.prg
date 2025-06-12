CREATE PROGRAM aps_prt_case_retrieval:dba
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
 IF (validate(reply->status_data.status,null)=null)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 print_status_data
      2 print_directory = c19
      2 print_filename = c40
      2 print_dir_and_filename = c60
  )
 ENDIF
 RECORD case_struct(
   1 accession_qual[*]
     2 accession_nbr = c20
     2 patient_mrn = vc
     2 patient_cmrn = vc
     2 patient_fin = vc
     2 patient_ssn = vc
     2 person_id = f8
     2 encntr_id = f8
     2 section_qual[*]
       3 event_id = f8
       3 title_text = c80
       3 blob_qual[*]
         4 blob_text = vc
         4 compression_cd = f8
       3 coded_result_qual[*]
         4 grouping_nbr = i4
         4 source_identifier = vc
         4 source_string = vc
 )
 RECORD patient_param_lines(
   1 line_qual[5]
     2 line_text = c121
 )
 RECORD case_param_lines(
   1 line_qual[5]
     2 line_text = c121
 )
 RECORD report_param_lines(
   1 line_qual[5]
     2 line_text = c121
 )
 RECORD criteria_param_lines(
   1 line_qual[5]
     2 line_text = vc
 )
 RECORD param_info(
   1 param_qual[*]
     2 param_name = vc
     2 param_value = vc
     2 param_type = i2
 )
 SET reply->status_data.status = "F"
 SET val_dt_tm1 = cnvtdatetime(sysdate)
 DECLARE blob_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",25,"BLOB"))
 DECLARE blobout = gvc WITH protect, noconstant("")
 DECLARE query_type = i2
 DECLARE temp_value = i2
 DECLARE case_index = i2
 DECLARE max_section = i4
 DECLARE section_index = i2
 DECLARE section_cnt = i2
 DECLARE begdttm = c11
 DECLARE enddttm = c11
 DECLARE spatientname = c25
 DECLARE sdocname = c25
 DECLARE sverdocname = c25
 DECLARE site = c5
 DECLARE prefix = c2
 DECLARE year = c2
 DECLARE seq = c7
 DECLARE scuraccession = c22
 DECLARE stemp_criteria = vc
 DECLARE x = i2
 DECLARE z = i2
 DECLARE patient_line_cnt = i2
 DECLARE max_patient_line_cnt = i4 WITH protect, noconstant(5)
 DECLARE case_line_cnt = i2
 DECLARE max_case_line_cnt = i4 WITH protect, noconstant(5)
 DECLARE report_line_cnt = i2
 DECLARE max_report_line_cnt = i4 WITH protect, noconstant(5)
 DECLARE criteria_line_cnt = i2
 DECLARE max_criteria_line_cnt = i4 WITH protect, noconstant(5)
 DECLARE nmaxpatdisplaycnt = i4 WITH protect, noconstant(1)
 DECLARE bfirst = c1 WITH protect, noconstant("T")
 DECLARE space_string = c1 WITH protect, constant(" ")
 DECLARE startedprsnlstring = vc
 DECLARE nbr_params = i2 WITH protect, constant(cnvtint(size(request->param_qual,5)))
 DECLARE nbr_accessions = i2 WITH protect, constant(cnvtint(size(request->accession_qual,5)))
 DECLARE comma_or_string = c5 WITH protect, constant(", or ")
 DECLARE four_space_string = c4 WITH protect, constant("    ")
 DECLARE to_string = c4
 DECLARE dt_type_string = c6
 DECLARE temp_param_name = c20
 DECLARE temp_param_prefix = c8
 DECLARE temp_string = vc
 DECLARE patient_string = vc
 DECLARE case_string = vc
 DECLARE criteria_string = vc
 DECLARE ce_where = vc
 DECLARE temp_accprefix = vc
 DECLARE temp_casetype = vc
 DECLARE temp_client = vc
 DECLARE temp_coldate = vc
 DECLARE temp_taskassay = vc
 DECLARE temp_verdate = vc
 DECLARE temp_verid = vc
 DECLARE temp_queryresult = vc
 DECLARE temp_reqphys = vc
 DECLARE temp_resppath = vc
 DECLARE temp_respresi = vc
 DECLARE temp_specimen = vc
 DECLARE temp_diagcode1 = vc
 DECLARE temp_diagcode2 = vc
 DECLARE temp_diagcode3 = vc
 DECLARE temp_diagcode4 = vc
 DECLARE temp_diagcode5 = vc
 DECLARE temp_diagcode6 = vc
 DECLARE temp_freetext = vc
 DECLARE temp_synoptic = vc
 DECLARE temp_user_display = vc
 DECLARE temp_agecoldate = vc
 DECLARE temp_agecurdate = vc
 DECLARE temp_birthdate = vc
 DECLARE temp_ethnicgroup = vc
 DECLARE temp_gender = vc
 DECLARE temp_race = vc
 DECLARE temp_species = vc
 DECLARE temp_military = vc
 DECLARE temp_imagetaskassay = vc
 DECLARE temp_len = i2
 DECLARE bnotfound = c1 WITH protect, noconstant("T")
 DECLARE dotted_line1 = c130 WITH protect, constant(fillstring(130,"-"))
 DECLARE today = c15
 DECLARE max_section_size = i4
 DECLARE nimagesearchtype = i2
 DECLARE code_value = f8
 DECLARE cdf_meaning = c12
 DECLARE spatientaliasflag = c1 WITH protect, noconstant(" ")
 DECLARE ssnomedcodeflag = c1 WITH protect, noconstant(" ")
 DECLARE ncodedresultcnt = i4 WITH protect, noconstant(0)
 DECLARE nmaxcoded = i4 WITH protect, noconstant(0)
 DECLARE nmaxcodedcnt = i4 WITH protect, noconstant(0)
 DECLARE nsnomedlastgrp = i4 WITH protect, noconstant(0)
 DECLARE dpatientmrncode = f8 WITH protect, noconstant(0.0)
 DECLARE dpatientcmrncode = f8 WITH protect, noconstant(0.0)
 DECLARE dpatientfincode = f8 WITH protect, noconstant(0.0)
 DECLARE dpatientssncode = f8 WITH protect, noconstant(0.0)
 DECLARE spatientmrn = vc WITH protect, noconstant(" ")
 DECLARE spatientcmrn = vc WITH protect, noconstant(" ")
 DECLARE spatientfin = vc WITH protect, noconstant(" ")
 DECLARE spatientssn = vc WITH protect, noconstant(" ")
 DECLARE bprintind = c1 WITH protect, noconstant(" ")
 DECLARE ssnomedgrp = c1 WITH protect, noconstant(" ")
 DECLARE npatheadprintedind = i4 WITH protect, noconstant(0)
 DECLARE nnocasesind = i2 WITH protect, noconstant(0)
 DECLARE nfooter = i2 WITH protect, constant(7)
 DECLARE nsnomedheader = i2 WITH protect, constant(2)
 DECLARE nsnomed = i2 WITH protect, constant(1)
 DECLARE noneprocedure = i2 WITH protect, constant(2)
 DECLARE nblobtext = i2 WITH protect, constant(2)
 DECLARE nnotext = i2 WITH protect, constant(2)
 DECLARE nprintheader = i2 WITH protect, constant(2)
 DECLARE nsub = i2 WITH protect, noconstant(0)
 DECLARE nparaminfocnt = i4 WITH protect, noconstant(0)
 DECLARE stempstring = vc WITH protect, noconstant(" ")
 DECLARE squeryresultname = vc WITH protect, noconstant(" ")
 IF (validate(request->query_result_name)=1)
  SET squeryresultname = request->query_result_name
 ENDIF
 DECLARE text = c100
 DECLARE real = f8
 DECLARE six = i2
 DECLARE pos = i2
 DECLARE startpos2 = i2
 DECLARE len = i4
 DECLARE endstring = c2
 SUBROUTINE get_text(startpos,textstring,delimit)
   SET siz = size(trim(textstring),1)
   SET pos = startpos
   SET endstring = "F"
   WHILE (pos <= siz)
    IF (substring(pos,1,trim(textstring))=delimit)
     IF (pos=siz)
      SET endstring = "T"
     ENDIF
     SET len = (pos - startpos)
     SET text = substring(startpos,len,trim(textstring))
     SET real = cnvtreal(trim(text))
     SET startpos = (pos+ 1)
     SET startpos2 = (pos+ 1)
     SET pos = siz
    ENDIF
    SET pos += 1
   ENDWHILE
 END ;Subroutine
 RECORD tmptext(
   1 qual[*]
     2 text = vc
 )
 DECLARE uar_get_ceblobsize(p1=f8(ref),p2=vc(ref)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblobsize", persist
 DECLARE uar_get_ceblob(p1=f8(ref),p2=vc(ref),p3=vc(ref),p4=i4(value)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblob", persist
 RECORD recdate(
   1 datetime = dq8
 ) WITH protect
 DECLARE format = i2
 DECLARE outbuffer = vc
 DECLARE nortftext = vc
 SET format = 0
 DECLARE txt_pos = i4
 DECLARE start = i4
 DECLARE len = i4
 DECLARE linecnt = i4
 SUBROUTINE (rtf_to_text(rtftext=vc,format=i2,line_len=i2) =null)
   SET all_len = 0
   SET start = 0
   SET len = 0
   SET text_pos = 0
   SET linecnt = 0
   SET inbuffer = fillstring(value(size(rtftext))," ")
   SET outbufferlen = 0
   SET bfl = 0
   SET bfl2 = 1
   SET outbuffer = ""
   SET nortftext = ""
   SET stat = memrealloc(outbuffer,1,build("C",value(size(rtftext))))
   SET stat = memrealloc(nortftext,1,build("C",value(size(rtftext))))
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
        SET text_pos = ((start+ line_len) - 1)
        IF (bigfirst="Y"
         AND text_pos >= all_len)
         SET text_pos = start
        ENDIF
        SET bigfirst = "N"
        WHILE (text_pos >= start
         AND all_len > tot_len)
          IF (text_pos=start)
           SET text_pos = ((start+ line_len) - 1)
           SET linecnt += 1
           SET stat = alterlist(tmptext->qual,linecnt)
           SET len = ((text_pos - start)+ 1)
           SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
           SET start = (text_pos+ 1)
           SET crstart = (text_pos+ 1)
           SET text_pos = 0
           SET tot_len = ((tot_len+ len) - 1)
           SET loaded = "Y"
          ELSE
           IF (substring(text_pos,1,outbuffer)=" ")
            SET len = (text_pos - start)
            IF (cnvtint(size(trim(substring(start,len,outbuffer)))) > 0)
             SET linecnt += 1
             SET stat = alterlist(tmptext->qual,linecnt)
             SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
             SET loaded = "Y"
            ENDIF
            SET start = (text_pos+ 1)
            SET crstart = (text_pos+ 1)
            SET text_pos = 0
            SET tot_len += len
           ELSE
            IF (first="Y")
             SET first = "N"
             SET tot_len += 1
            ENDIF
            SET text_pos -= 1
           ENDIF
          ENDIF
        ENDWHILE
       ELSE
        SET crfirst = "N"
        IF (((substring(crpos,1,outbuffer)=crchar) OR (((substring(crpos,1,outbuffer)=lfchar) OR (
        substring(crpos,1,outbuffer)=ffchar)) )) )
         SET crlen = (crpos - crstart)
         SET linecnt += 1
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
         SET tot_len += crlen
        ENDIF
       ENDIF
       SET crpos += 1
      ENDWHILE
    ENDWHILE
   ENDIF
   SET rtftext = fillstring(value(size(rtftext))," ")
   SET inbuffer = fillstring(value(size(rtftext))," ")
 END ;Subroutine
 DECLARE outbufmaxsiz = i2
 DECLARE tblobin = c32000
 DECLARE tblobout = c32000
 DECLARE blobin = c32000
 DECLARE blobout = c32000
 SUBROUTINE (decompress_text(tblobin=vc) =null)
   SET tblobout = fillstring(32000," ")
   SET blobout = fillstring(32000," ")
   SET outbufmaxsiz = 0
   SET blobin = trim(tblobin)
   CALL uar_ocf_uncompress(blobin,size(blobin),blobout,size(blobout),outbufmaxsiz)
   SET tblobout = blobout
   SET tblobin = fillstring(32000," ")
   SET blobin = fillstring(32000," ")
 END ;Subroutine
 RECORD captions(
   1 rpt = vc
   1 title = vc
   1 ana = vc
   1 dt = vc
   1 tm = vc
   1 dir = vc
   1 path = vc
   1 bye = vc
   1 pg = vc
   1 sel = vc
   1 pat = vc
   1 no = vc
   1 cse = vc
   1 cri = vc
   1 cas = vc
   1 nm = vc
   1 req = vc
   1 col = vc
   1 ver = vc
   1 bby = vc
   1 no_txt = vc
   1 pro = vc
   1 cont = vc
   1 inv = vc
   1 no_cse = vc
   1 tot = vc
   1 cas_qual = vc
   1 coll = vc
   1 an = vc
   1 cur = vc
   1 bd = vc
   1 eth = vc
   1 gen = vc
   1 rc = vc
   1 spe = vc
   1 acc = vc
   1 tsk = vc
   1 ver_dt = vc
   1 req_ph = vc
   1 res_pa = vc
   1 res_res = vc
   1 dig_cd = vc
   1 ft = vc
   1 doc = vc
   1 par = vc
   1 summ = vc
   1 docsumm = vc
   1 too = vc
   1 ver_id = vc
   1 c_tp = vc
   1 mil = vc
   1 clnt = vc
   1 spcmn = vc
   1 qry = vc
   1 age_coll = vc
   1 mrn = vc
   1 cmrn = vc
   1 fin = vc
   1 id = vc
   1 snomed = vc
   1 synoptic = vc
   1 queryname = vc
   1 more = vc
 )
 SET captions->rpt = uar_i18ngetmessage(i18nhandle,"t1","REPORT:")
 SET captions->title = uar_i18ngetmessage(i18nhandle,"t2","APS_PRT_CASE_RETRIEVAL.PRG")
 SET captions->ana = uar_i18ngetmessage(i18nhandle,"t3","Anatomic Pathology")
 SET captions->dt = uar_i18ngetmessage(i18nhandle,"t4","DATE:")
 SET captions->tm = uar_i18ngetmessage(i18nhandle,"t5","TIME:")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"t6","DIRECTORY:")
 SET captions->path = uar_i18ngetmessage(i18nhandle,"t7","PATHOLOGY CASE RETRIEVAL")
 SET captions->bye = uar_i18ngetmessage(i18nhandle,"t8","BY:")
 SET captions->pg = uar_i18ngetmessage(i18nhandle,"t9","PAGE:")
 SET captions->sel = uar_i18ngetmessage(i18nhandle,"t10","SELECTED:")
 SET captions->pat = uar_i18ngetmessage(i18nhandle,"t11","PATIENT:")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"t12","None")
 SET captions->cse = uar_i18ngetmessage(i18nhandle,"t13","CASE:")
 SET captions->cri = uar_i18ngetmessage(i18nhandle,"t14","CRITERIA:")
 SET captions->cas = uar_i18ngetmessage(i18nhandle,"t15","CASE")
 SET captions->nm = uar_i18ngetmessage(i18nhandle,"t16","NAME")
 SET captions->req = uar_i18ngetmessage(i18nhandle,"t17","REQUESTED BY")
 SET captions->col = uar_i18ngetmessage(i18nhandle,"t18","COLLECTED")
 SET captions->ver = uar_i18ngetmessage(i18nhandle,"t19","VERIFIED")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"t20","BY")
 SET captions->no_txt = uar_i18ngetmessage(i18nhandle,"t21","No text found for case.")
 SET captions->pro = uar_i18ngetmessage(i18nhandle,"t22","Procedure:")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"t23","CONTINUED...")
 SET captions->inv = uar_i18ngetmessage(i18nhandle,"t24","Invalid Free-text Search String Entered.")
 SET captions->no_cse = uar_i18ngetmessage(i18nhandle,"t25","No Cases Qualify.")
 SET captions->tot = uar_i18ngetmessage(i18nhandle,"t26","TOTAL:")
 SET captions->cas_qual = uar_i18ngetmessage(i18nhandle,"t27","CASES QUALIFIED")
 SET captions->coll = uar_i18ngetmessage(i18nhandle,"t28","Collection date:")
 SET captions->an = uar_i18ngetmessage(i18nhandle,"t29","and ")
 SET captions->cur = uar_i18ngetmessage(i18nhandle,"t30","Current date:")
 SET captions->bd = uar_i18ngetmessage(i18nhandle,"t31","Birthdate:")
 SET captions->eth = uar_i18ngetmessage(i18nhandle,"t32","Ethnic group:")
 SET captions->gen = uar_i18ngetmessage(i18nhandle,"t33","Gender:")
 SET captions->rc = uar_i18ngetmessage(i18nhandle,"t34","Race:")
 SET captions->spe = uar_i18ngetmessage(i18nhandle,"t35","Species:")
 SET captions->acc = uar_i18ngetmessage(i18nhandle,"t36","Accession prefix:")
 SET captions->tsk = uar_i18ngetmessage(i18nhandle,"t37","REPORT:")
 SET captions->ver_dt = uar_i18ngetmessage(i18nhandle,"t38","Verification date:")
 SET captions->res_pa = uar_i18ngetmessage(i18nhandle,"t40","Responsible pathologist:")
 SET captions->res_res = uar_i18ngetmessage(i18nhandle,"t41","Responsible resident:")
 SET captions->dig_cd = uar_i18ngetmessage(i18nhandle,"t42","Diagnostic codes:")
 SET captions->ft = uar_i18ngetmessage(i18nhandle,"t43","Free-text:")
 SET captions->doc = uar_i18ngetmessage(i18nhandle,"t44","(Document)")
 SET captions->par = uar_i18ngetmessage(i18nhandle,"t45","(Paragraph)")
 SET captions->summ = uar_i18ngetmessage(i18nhandle,"t46","(Summary)")
 SET captions->docsumm = uar_i18ngetmessage(i18nhandle,"t47","(Document w/Summary)")
 SET captions->too = uar_i18ngetmessage(i18nhandle,"t48"," to ")
 SET captions->ver_id = uar_i18ngetmessage(i18nhandle,"t49","Verification Id:")
 SET captions->c_tp = uar_i18ngetmessage(i18nhandle,"t50","Case type:")
 SET captions->mil = uar_i18ngetmessage(i18nhandle,"t51","Military:")
 SET captions->clnt = uar_i18ngetmessage(i18nhandle,"t52","Client:")
 SET captions->spcmn = uar_i18ngetmessage(i18nhandle,"t53","Specimen:")
 SET captions->qry = uar_i18ngetmessage(i18nhandle,"t54","Query Result:")
 SET captions->age_coll = uar_i18ngetmessage(i18nhandle,"t55",
  "Age range, based on age at case collection date:")
 SET captions->req_ph = uar_i18ngetmessage(i18nhandle,"t56","Requesting physician:")
 SET captions->mrn = uar_i18ngetmessage(i18nhandle,"t57","MRN:")
 SET captions->cmrn = uar_i18ngetmessage(i18nhandle,"t58","CMRN:")
 SET captions->fin = uar_i18ngetmessage(i18nhandle,"t59","FIN:")
 SET captions->id = uar_i18ngetmessage(i18nhandle,"t60","ID:")
 SET captions->snomed = uar_i18ngetmessage(i18nhandle,"t61","SNOMED CODES:")
 SET captions->synoptic = uar_i18ngetmessage(i18nhandle,"t62","Synpoptic criteria:")
 SET captions->queryname = uar_i18ngetmessage(i18nhandle,"t63","QUERY RESULT NAME:")
 SET captions->more = uar_i18ngetmessage(i18nhandle,"t64","...(more)")
 SET to_string = captions->too
 SET stat = uar_get_meaning_by_codeset(4,"CMRN",1,dpatientcmrncode)
 SET stat = uar_get_meaning_by_codeset(4,"SSN",1,dpatientssncode)
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,dpatientmrncode)
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,dpatientfincode)
 SET stat = alterlist(case_struct->accession_qual,nbr_accessions)
 IF (nbr_accessions=0)
  SET nnocasesind = 1
 ELSEIF (nbr_accessions=1
  AND (request->accession_qual[1].accession_nbr="NOCASES"))
  SET nnocasesind = 1
 ENDIF
 CALL createparamstrings(patient_string,case_string,criteria_string)
 CALL createparamlines(1)
 IF (nbr_accessions > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(nbr_accessions))
   DETAIL
    case_struct->accession_qual[d1.seq].accession_nbr = request->accession_qual[d1.seq].accession_nbr
   WITH nocounter
  ;end select
  IF (nnocasesind=0)
   IF (spatientaliasflag="Y")
    SELECT INTO "nl:"
     alias_found = evaluate(nullind(pa.person_id),0,1,0)
     FROM (dummyt d1  WITH seq = value(nbr_accessions)),
      (dummyt d2  WITH seq = 1),
      person_alias pa,
      pathology_case pc
     PLAN (d1)
      JOIN (pc
      WHERE (pc.accession_nbr=case_struct->accession_qual[d1.seq].accession_nbr))
      JOIN (d2
      WHERE d2.seq=1)
      JOIN (pa
      WHERE pa.person_id=pc.person_id
       AND pa.person_alias_type_cd IN (dpatientcmrncode, dpatientssncode)
       AND cnvtdatetime(sysdate) BETWEEN pa.beg_effective_dt_tm AND pa.end_effective_dt_tm)
     ORDER BY d1.seq
     HEAD d1.seq
      case_struct->accession_qual[d1.seq].person_id = pc.person_id, case_struct->accession_qual[d1
      .seq].encntr_id = pc.encntr_id
     DETAIL
      IF (alias_found=1)
       CASE (pa.person_alias_type_cd)
        OF dpatientcmrncode:
         case_struct->accession_qual[d1.seq].patient_cmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
        OF dpatientssncode:
         case_struct->accession_qual[d1.seq].patient_ssn = cnvtalias(pa.alias,pa.alias_pool_cd)
       ENDCASE
      ENDIF
     WITH nocounter, outerjoin = d2
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(nbr_accessions)),
      encntr_alias ea
     PLAN (d1)
      JOIN (ea
      WHERE (ea.encntr_id=case_struct->accession_qual[d1.seq].encntr_id)
       AND ea.encntr_alias_type_cd IN (dpatientmrncode, dpatientfincode)
       AND cnvtdatetime(sysdate) BETWEEN ea.beg_effective_dt_tm AND ea.end_effective_dt_tm)
     DETAIL
      CASE (ea.encntr_alias_type_cd)
       OF dpatientmrncode:
        case_struct->accession_qual[d1.seq].patient_mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
       OF dpatientfincode:
        case_struct->accession_qual[d1.seq].patient_fin = cnvtalias(ea.alias,ea.alias_pool_cd)
      ENDCASE
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->report_type=2))
    SET ce_where = "0=0"
    IF ((request->report_history_grping > 0))
     SELECT INTO "nl:"
      rhgr.grouping_cd
      FROM report_history_grouping_r rhgr
      WHERE (rhgr.grouping_cd=request->report_history_grping)
      HEAD REPORT
       ce_where = "ce.task_assay_cd in ("
      DETAIL
       ce_where = concat(trim(ce_where),cnvtstring(rhgr.task_assay_cd,32,2),",")
      FOOT REPORT
       templen = textlen(trim(ce_where)), ce_where = concat(substring(1,(templen - 1),trim(ce_where)),
        ")")
      WITH nocounter
     ;end select
    ENDIF
    SELECT INTO "nl:"
     ce.event_id, ceb.event_id, d1.seq
     FROM clinical_event ce,
      ce_blob_result ceb,
      (dummyt d1  WITH seq = value(nbr_accessions))
     PLAN (d1)
      JOIN (ce
      WHERE (ce.accession_nbr=case_struct->accession_qual[d1.seq].accession_nbr)
       AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
       AND (ce.record_status_cd != reqdata->deleted_cd)
       AND parser(trim(ce_where)))
      JOIN (ceb
      WHERE ceb.event_id=ce.event_id
       AND ceb.valid_until_dt_tm > cnvtdatetime(sysdate)
       AND ceb.storage_cd=blob_cd)
     ORDER BY d1.seq, ceb.event_id
     HEAD d1.seq
      section_cnt = 0, stat = alterlist(case_struct->accession_qual[d1.seq].section_qual,10)
     HEAD ceb.event_id
      section_cnt += 1
      IF (mod(section_cnt,10)=1
       AND section_cnt != 1)
       stat = alterlist(case_struct->accession_qual[d1.seq].section_qual,(section_cnt+ 9))
      ENDIF
      IF (section_cnt > max_section_size)
       max_section_size = section_cnt
      ENDIF
      case_struct->accession_qual[d1.seq].section_qual[section_cnt].title_text = ce.event_title_text,
      case_struct->accession_qual[d1.seq].section_qual[section_cnt].event_id = ce.event_id, stat =
      alterlist(case_struct->accession_qual[d1.seq].section_qual[section_cnt].blob_qual,1),
      recdate->datetime = cnvtdatetimeutc(ceb.valid_from_dt_tm), blobsize = uar_get_ceblobsize(ceb
       .event_id,recdate), blobout = ""
      IF (blobsize > 0)
       stat = memrealloc(blobout,1,build("C",blobsize)), status = uar_get_ceblob(ceb.event_id,recdate,
        blobout,blobsize)
      ENDIF
      case_struct->accession_qual[d1.seq].section_qual[section_cnt].blob_qual[1].blob_text = blobout
     FOOT  ceb.event_id
      row + 0
     FOOT  d1.seq
      stat = alterlist(case_struct->accession_qual[d1.seq].section_qual,section_cnt)
     WITH nocounter, memsort
    ;end select
    IF (ssnomedcodeflag="Y")
     SELECT INTO "nl:"
      FROM ce_coded_result ccr,
       nomenclature nm,
       (dummyt d1  WITH seq = value(nbr_accessions)),
       (dummyt d2  WITH seq = value(max_section_size))
      PLAN (d1)
       JOIN (d2
       WHERE d2.seq <= size(case_struct->accession_qual[d1.seq].section_qual,5))
       JOIN (ccr
       WHERE (ccr.event_id=case_struct->accession_qual[d1.seq].section_qual[d2.seq].event_id)
        AND ccr.valid_until_dt_tm > cnvtdatetime(sysdate))
       JOIN (nm
       WHERE nm.nomenclature_id=ccr.nomenclature_id)
      ORDER BY ccr.event_id, ccr.group_nbr, nm.source_identifier
      HEAD ccr.event_id
       coded_result_cnt = 0
      DETAIL
       coded_result_cnt += 1
       IF (mod(coded_result_cnt,10)=1)
        stat = alterlist(case_struct->accession_qual[d1.seq].section_qual[d2.seq].coded_result_qual,(
         coded_result_cnt+ 9))
       ENDIF
       case_struct->accession_qual[d1.seq].section_qual[d2.seq].coded_result_qual[coded_result_cnt].
       grouping_nbr = ccr.group_nbr, case_struct->accession_qual[d1.seq].section_qual[d2.seq].
       coded_result_qual[coded_result_cnt].source_identifier = nm.source_identifier, case_struct->
       accession_qual[d1.seq].section_qual[d2.seq].coded_result_qual[coded_result_cnt].source_string
        = nm.source_string
      FOOT  ccr.event_id
       stat = alterlist(case_struct->accession_qual[d1.seq].section_qual[d2.seq].coded_result_qual,
        coded_result_cnt)
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl p
  WHERE (p.person_id=request->started_prsnl_id)
  DETAIL
   startedprsnlstring = trim(p.username)
  WITH nocounter
 ;end select
 IF ((request->export_report_xml=1))
  EXECUTE cpm_create_file_name_logical "aps_case_retriev", "xml", "x"
  SET reply->print_status_data.print_directory = ""
  SET reply->print_status_data.print_filename = ""
  SET reply->print_status_data.print_dir_and_filename = ""
  SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
  SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
  SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
  IF (spatientaliasflag="Y")
   SET nmaxpatdisplaycnt = 2
  ELSE
   SET nmaxpatdisplaycnt = 1
  ENDIF
  SELECT INTO value(reply->print_status_data.print_filename)
   d1.seq, pc.case_id, p.person_id,
   pc.accession_nbr, pc_accession_nbr = decode(pc.seq,uar_fmt_accession(pc.accession_nbr,size(pc
      .accession_nbr,1)),""), p1.person_id,
   cr.case_id, main_report_complete_ind = evaluate(nullind(pc.main_report_cmplete_dt_tm),0,1,0),
   prr_exists = decode(prr.seq,1,0)
   FROM pathology_case pc,
    (dummyt d1  WITH seq = value(nbr_accessions)),
    person p,
    prsnl p1,
    case_report cr,
    prefix_report_r prr,
    prsnl p2,
    (dummyt d2  WITH seq = 1)
   PLAN (d1)
    JOIN (pc
    WHERE (case_struct->accession_qual[d1.seq].accession_nbr=pc.accession_nbr))
    JOIN (p
    WHERE pc.person_id=p.person_id)
    JOIN (p1
    WHERE pc.requesting_physician_id=p1.person_id)
    JOIN (cr
    WHERE pc.case_id=cr.case_id)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (prr
    WHERE cr.catalog_cd=prr.catalog_cd
     AND pc.prefix_id=prr.prefix_id
     AND prr.primary_ind=1)
    JOIN (p2
    WHERE cr.status_prsnl_id=p2.person_id)
   ORDER BY pc.accession_nbr, prr_exists DESC
   HEAD REPORT
    MACRO (convertspecialcharacterstempstring)
     stempstring = replace(stempstring,"&","&amp;",0), stempstring = replace(stempstring,"<","&lt;",0
      ), stempstring = replace(stempstring,">","&gt;",0),
     stempstring = replace(stempstring,'"',"&quot;",0), stempstring = replace(stempstring,"'",
      "&apos;",0), stempstring
    ENDMACRO
    , x = x, col 0,
    "<?xml version='1.0' encoding='ISO-8859-1'?>", row + 1, col 0,
    "<Pathology_case_retrieval_report>", row + 1, col 2,
    "<REPORT_INFO>", row + 1, col 4,
    "<DATE>", curdate"@SHORTDATE;;D", "</DATE>",
    row + 1, col 4, "<TIME>",
    curtime"@TIMENOSECONDS;;M", "</TIME>", row + 1,
    stempstring = startedprsnlstring, col 4, "<BY>",
    convertspecialcharacterstempstring, "</BY>", stempstring = cnvtstring(nbr_accessions),
    row + 1, col 4, "<CASES_QUALIFIED>",
    convertspecialcharacterstempstring, "</CASES_QUALIFIED>", row + 2,
    col 4, "<SELECTED_CRITERIA>"
    IF (nparaminfocnt > 0)
     FOR (x = 1 TO nparaminfocnt)
       row + 1, col 6, "<PARAM>",
       row + 1, stempstring = param_info->param_qual[x].param_name, col 8,
       "<NAME>", convertspecialcharacterstempstring, "</NAME>",
       row + 1, stempstring = param_info->param_qual[x].param_value, col 8,
       "<VALUE>", convertspecialcharacterstempstring, "</VALUE>",
       row + 1
       IF ((param_info->param_qual[x].param_type=1))
        col 8, "<TYPE>Patient</TYPE>"
       ELSEIF ((param_info->param_qual[x].param_type=2))
        col 8, "<TYPE>Case</TYPE>"
       ELSEIF ((param_info->param_qual[x].param_type=3))
        col 8, "<TYPE>Criteria</TYPE>"
       ENDIF
       row + 1, col 6, "</PARAM>"
     ENDFOR
    ENDIF
    row + 1, col 4, "</SELECTED_CRITERIA>",
    row + 1, col 2, "</REPORT_INFO>"
   HEAD pc.accession_nbr
    IF (prr_exists=1
     AND main_report_complete_ind=1)
     sverdocname = p2.name_full_formatted
    ELSE
     sverdocname = ""
    ENDIF
    row + 1, col 2, "<CASE>",
    stempstring = trim(pc_accession_nbr), row + 1, col 4,
    "<CASE_ACCESSION>", convertspecialcharacterstempstring, "</CASE_ACCESSION>",
    row + 1, col 4, "<CASE_DETAILS>",
    stempstring = p.name_full_formatted, row + 1, col 6,
    "<PATIENT_NAME>", convertspecialcharacterstempstring, "</PATIENT_NAME>",
    stempstring = p1.name_full_formatted, row + 1, col 6,
    "<REQUESTED_BY>", convertspecialcharacterstempstring, "</REQUESTED_BY>",
    row + 1, col 6, "<COLLECTED_DATE>",
    pc.case_collect_dt_tm"@SHORTDATE;;D", "</COLLECTED_DATE>", row + 1,
    col 6, "<VERIFIED_DATE>", pc.main_report_cmplete_dt_tm"@SHORTDATE;;D",
    "</VERIFIED_DATE>", stempstring = trim(sverdocname), row + 1,
    col 6, "<VERIFIED_BY>", convertspecialcharacterstempstring,
    "</VERIFIED_BY>", spatientmrn = nullterm(trim(case_struct->accession_qual[d1.seq].patient_mrn)),
    spatientcmrn = nullterm(trim(case_struct->accession_qual[d1.seq].patient_cmrn)),
    spatientfin = nullterm(trim(case_struct->accession_qual[d1.seq].patient_fin)), spatientssn =
    nullterm(trim(case_struct->accession_qual[d1.seq].patient_ssn))
    IF (spatientaliasflag="Y")
     IF (textlen(trim(spatientmrn)) > 0)
      row + 1, col 6, "<MRN>",
      spatientmrn, "</MRN>"
     ENDIF
     IF (textlen(trim(spatientcmrn)) > 0)
      row + 1, col 6, "<CMRN>",
      spatientcmrn, "</CMRN>"
     ENDIF
     IF (textlen(trim(spatientfin)) > 0)
      row + 1, col 6, "<FIN>",
      spatientfin, "</FIN>"
     ENDIF
     IF (textlen(trim(spatientssn)) > 0)
      row + 1, col 6, "<ID>",
      spatientssn, "</ID>"
     ENDIF
    ENDIF
    row + 1, col 4, "</CASE_DETAILS>",
    row + 1, col 4, "<CASE_REPORT>"
    IF (size(case_struct->accession_qual[d1.seq].section_qual) > 0)
     max_section = cnvtint(size(case_struct->accession_qual[d1.seq].section_qual,5))
     FOR (section_index = 1 TO max_section)
       row + 1, col 6, "<REPORT_SECTION>",
       stempstring = case_struct->accession_qual[d1.seq].section_qual[section_index].title_text, row
        + 1, col 8,
       "<TITLE>", convertspecialcharacterstempstring, "</TITLE>",
       CALL rtf_to_text(trim(case_struct->accession_qual[d1.seq].section_qual[section_index].
        blob_qual[1].blob_text),1,100), isub = size(tmptext->qual,5)
       WHILE (isub > 0
        AND textlen(trim(tmptext->qual[isub].text))=0)
         isub -= 1
       ENDWHILE
       row + 1, col 8, "<TEXT>"
       FOR (z = 1 TO isub)
         stempstring = tmptext->qual[z].text, row + 1, col 10,
         convertspecialcharacterstempstring
       ENDFOR
       row + 1, col 8, "</TEXT>",
       nmaxcodedcnt = size(case_struct->accession_qual[d1.seq].section_qual[section_index].
        coded_result_qual,5)
       IF (nmaxcodedcnt > 0)
        nsnomedlastgrp = 0, row + 1, col 8,
        "<SNOMED_CODES>"
        FOR (code_index = 1 TO nmaxcodedcnt)
          ssnomedgrp = cnvtstring(case_struct->accession_qual[d1.seq].section_qual[section_index].
           coded_result_qual[code_index].grouping_nbr), row + 1, col 10,
          "<SNOMED_CODE>", row + 1, col 12,
          "<GROUPING>", ssnomedgrp, "</GROUPING>",
          stempstring = case_struct->accession_qual[d1.seq].section_qual[section_index].
          coded_result_qual[code_index].source_identifier, row + 1, col 12,
          "<SOURCE_IDENTIFIER>", convertspecialcharacterstempstring, "</SOURCE_IDENTIFIER>",
          row + 1, stempstring = case_struct->accession_qual[d1.seq].section_qual[section_index].
          coded_result_qual[code_index].source_string, col 12,
          "<SOURCE_STRING>", convertspecialcharacterstempstring, "</SOURCE_STRING>",
          row + 1, col 10, "</SNOMED_CODE>"
        ENDFOR
        row + 1, col 8, "</SNOMED_CODES>"
       ENDIF
       row + 1, col 6, "</REPORT_SECTION>"
     ENDFOR
     row + 1, col 4, "</CASE_REPORT>"
    ENDIF
    row + 1, col 2, "</CASE>"
   FOOT REPORT
    row + 1, col 0, "</Pathology_case_retrieval_report>",
    reply->status_data.status = "S"
   WITH nocounter, nullreport, maxrow = 1,
    maxcol = 35000, outerjoin = d2, compress,
    format = stream, formfeed = none
  ;end select
 ELSE
  EXECUTE cpm_create_file_name_logical "aps_case_retriev", "dat", "x"
  SET reply->print_status_data.print_directory = ""
  SET reply->print_status_data.print_filename = ""
  SET reply->print_status_data.print_dir_and_filename = ""
  SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
  SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
  SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
  IF (spatientaliasflag="Y")
   SET nmaxpatdisplaycnt = 2
  ELSE
   SET nmaxpatdisplaycnt = 1
  ENDIF
  SELECT INTO value(reply->print_status_data.print_filename)
   d1.seq, pc.case_id, p.person_id,
   pc.accession_nbr, pc_accession_nbr = decode(pc.seq,uar_fmt_accession(pc.accession_nbr,size(pc
      .accession_nbr,1)),""), p1.person_id,
   cr.case_id, main_report_complete_ind = evaluate(nullind(pc.main_report_cmplete_dt_tm),0,1,0),
   prr_exists = decode(prr.seq,1,0)
   FROM pathology_case pc,
    (dummyt d1  WITH seq = value(nbr_accessions)),
    person p,
    prsnl p1,
    case_report cr,
    prefix_report_r prr,
    prsnl p2,
    (dummyt d2  WITH seq = 1)
   PLAN (d1)
    JOIN (pc
    WHERE (case_struct->accession_qual[d1.seq].accession_nbr=pc.accession_nbr))
    JOIN (p
    WHERE pc.person_id=p.person_id)
    JOIN (p1
    WHERE pc.requesting_physician_id=p1.person_id)
    JOIN (cr
    WHERE pc.case_id=cr.case_id)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (prr
    WHERE cr.catalog_cd=prr.catalog_cd
     AND pc.prefix_id=prr.prefix_id
     AND prr.primary_ind=1)
    JOIN (p2
    WHERE cr.status_prsnl_id=p2.person_id)
   ORDER BY pc.accession_nbr, prr_exists DESC
   HEAD REPORT
    x = x,
    MACRO (print_header)
     scuraccession = pc_accession_nbr, spatientname = substring(1,25,p.name_full_formatted), sdocname
      = substring(1,25,p1.name_full_formatted)
     IF (prr_exists=1
      AND main_report_complete_ind=1)
      sverdocname = substring(1,25,p2.name_full_formatted)
     ELSE
      sverdocname = " "
     ENDIF
     row + 1, col 0, scuraccession,
     col 21, spatientname, col 48,
     sdocname, col 75, pc.case_collect_dt_tm"@SHORTDATE;;D",
     col 86, pc.main_report_cmplete_dt_tm"@SHORTDATE;;D", col 96,
     sverdocname, spatientmrn = nullterm(trim(case_struct->accession_qual[d1.seq].patient_mrn)),
     spatientcmrn = nullterm(trim(case_struct->accession_qual[d1.seq].patient_cmrn)),
     spatientfin = nullterm(trim(case_struct->accession_qual[d1.seq].patient_fin)), spatientssn =
     nullterm(trim(case_struct->accession_qual[d1.seq].patient_ssn)), bprintind = "F",
     row + 1
     IF (spatientaliasflag="Y")
      IF (textlen(trim(spatientmrn)) > 0)
       col 21, captions->mrn, col + 2,
       spatientmrn, bprintind = "T"
      ENDIF
      IF (textlen(trim(spatientcmrn)) > 0)
       IF (bprintind="T")
        col + 4
       ELSE
        col 21
       ENDIF
       captions->cmrn, col + 2, spatientcmrn,
       bprintind = "T"
      ENDIF
      IF (textlen(trim(spatientfin)) > 0)
       IF (bprintind="T")
        col + 4
       ELSE
        col 21
       ENDIF
       captions->fin, col + 2, spatientfin,
       bprintind = "T"
      ENDIF
      IF (textlen(trim(spatientssn)) > 0)
       IF (bprintind="T")
        col + 4
       ELSE
        col 21
       ENDIF
       captions->id, col + 2, spatientssn,
       bprintind = "T"
      ENDIF
      IF (bprintind="T")
       row + 1
      ENDIF
     ENDIF
    ENDMACRO
   HEAD PAGE
    row + 1, col 0, captions->rpt,
    col 8, captions->title,
    CALL center(captions->ana,0,132),
    col 110, captions->dt, col 117,
    curdate"@SHORTDATE;;D", row + 1, col 0,
    captions->dir, col 110, captions->tm,
    col 117, curtime"@TIMENOSECONDS;;M", row + 1,
    col 5,
    CALL center(captions->path,0,132), col 112,
    captions->bye, col 117, startedprsnlstring"##############",
    row + 1, col 110, captions->pg,
    col 117, curpage"###", row + 1
    IF (textlen(trim(squeryresultname)) > 0)
     col 0, captions->queryname, col 20,
     squeryresultname, row + 1
    ENDIF
    col 0, captions->sel, row + 1,
    col 0, captions->pat
    IF (max_patient_line_cnt > 0)
     FOR (x = 1 TO max_patient_line_cnt)
       IF (x=1)
        col 10, patient_param_lines->line_qual[x].line_text
       ELSE
        row + 1, col 3, patient_param_lines->line_qual[x].line_text
       ENDIF
     ENDFOR
    ELSE
     col 10, captions->no
    ENDIF
    row + 1, col 0, captions->cse
    IF (max_case_line_cnt > 0)
     FOR (x = 1 TO max_case_line_cnt)
       IF (x=1)
        col 10, case_param_lines->line_qual[x].line_text
       ELSE
        row + 1, col 3, case_param_lines->line_qual[x].line_text
       ENDIF
     ENDFOR
    ELSE
     col 10, captions->no
    ENDIF
    row + 1, col 0, captions->tsk
    IF (max_report_line_cnt > 0)
     col 10, report_param_lines->line_qual[1].line_text
    ELSE
     col 10, captions->no
    ENDIF
    row + 1, col 0, captions->cri
    IF (max_criteria_line_cnt > 0)
     FOR (x = 1 TO max_criteria_line_cnt)
       IF (x=1)
        col 10, criteria_param_lines->line_qual[x].line_text
       ELSE
        row + 1, col 3, criteria_param_lines->line_qual[x].line_text
       ENDIF
     ENDFOR
    ELSE
     col 10, captions->no
    ENDIF
    row + 2, col 0, captions->cas,
    col 21, captions->nm, col 48,
    captions->req, col 75, captions->col,
    col 86, captions->ver, col 96,
    captions->bby, row + 1, col 0,
    "------------------", col 21, "-------------------------",
    col 48, "-------------------------", col 75,
    "---------", col 86, "--------",
    col 96, "-------------------------"
    IF (curpage > 1)
     print_header, npatheadprintedind = 1
    ENDIF
   HEAD pc.accession_nbr
    npatheadprintedind = 0
    IF ((((request->report_type=1)) OR ((request->report_type=2)))
     AND ((((row+ nmaxpatdisplaycnt)+ nfooter)+ nprintheader) > maxrow))
     BREAK
    ENDIF
    IF (npatheadprintedind=0)
     print_header
    ENDIF
    IF ((request->report_type=2))
     bnotfound = "F"
     IF (size(case_struct->accession_qual[d1.seq].section_qual)=0)
      bnotfound = "T"
     ENDIF
     IF (bnotfound="T")
      IF ((((row+ nfooter)+ nnotext) > maxrow))
       BREAK
      ENDIF
      row + 1,
      CALL center(captions->no_txt,0,132)
     ELSE
      max_section = cnvtint(size(case_struct->accession_qual[d1.seq].section_qual,5))
      FOR (section_index = 1 TO max_section)
        IF ((((row+ nfooter)+ noneprocedure) > maxrow))
         BREAK
        ENDIF
        col 9, captions->pro, col 21,
        case_struct->accession_qual[d1.seq].section_qual[section_index].title_text,
        CALL rtf_to_text(trim(case_struct->accession_qual[d1.seq].section_qual[section_index].
         blob_qual[1].blob_text),1,100), isub = size(tmptext->qual,5)
        WHILE (isub > 0
         AND textlen(trim(tmptext->qual[isub].text))=0)
          isub -= 1
        ENDWHILE
        FOR (z = 1 TO isub)
          IF ((((row+ nfooter)+ nblobtext) > maxrow))
           BREAK
          ENDIF
          row + 1, col 24, tmptext->qual[z].text
        ENDFOR
        IF (ssnomedcodeflag="Y")
         nmaxcodedcnt = size(case_struct->accession_qual[d1.seq].section_qual[section_index].
          coded_result_qual,5), nsnomedlastgrp = 0
         FOR (code_index = 1 TO nmaxcodedcnt)
           IF ((((((row+ nfooter)+ nsnomedheader) > maxrow)
            AND code_index=1) OR ((((row+ nfooter)+ nsnomed) > maxrow))) )
            BREAK
           ENDIF
           IF (code_index=1)
            row + 1, col 21, captions->snomed,
            row + 1
           ENDIF
           IF ((nsnomedlastgrp != case_struct->accession_qual[d1.seq].section_qual[section_index].
           coded_result_qual[code_index].grouping_nbr))
            nsnomedlastgrp = case_struct->accession_qual[d1.seq].section_qual[section_index].
            coded_result_qual[code_index].grouping_nbr, ssnomedgrp = cnvtstring(nsnomedlastgrp), col
            21,
            ssnomedgrp
           ENDIF
           col 24, case_struct->accession_qual[d1.seq].section_qual[section_index].coded_result_qual[
           code_index].source_identifier, col 32,
           case_struct->accession_qual[d1.seq].section_qual[section_index].coded_result_qual[
           code_index].source_string
           IF (code_index != nmaxcodedcnt)
            row + 1
           ENDIF
         ENDFOR
        ENDIF
        IF ((((row+ nfooter)+ noneprocedure) > maxrow))
         BREAK
        ELSEIF (section_index != max_section)
         row + 2
        ELSE
         row + 1
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   FOOT PAGE
    IF (row < 59)
     row 59, col 0, dotted_line1
    ELSE
     row + 1, col 0, dotted_line1
    ENDIF
    row + 1, col 0, captions->rpt,
    col + 1, captions->path, dy = format(curdate,"@MEDIUMDATE4YR;;D"),
    wk = format(curdate,"@WEEKDAYABBREV;;D"), today = concat(wk," ",dy), col 53,
    CALL center(today,0,132), col 110, captions->pg,
    col 117, curpage"###"
    IF (curendreport != 1)
     row + 1, col 52,
     CALL center(captions->cont,0,132)
    ENDIF
   FOOT REPORT
    IF (nnocasesind=1)
     IF ((request->illegal_operator_ind=1))
      row + 2, col 52,
      CALL center(captions->inv,0,132)
     ELSE
      row + 2, col 52,
      CALL center(captions->no_cse,0,132)
     ENDIF
    ELSE
     row + 2, col 0, captions->tot,
     col 9, nbr_accessions"######", col 16,
     captions->cas_qual
    ENDIF
    row + 2, col 52,
    CALL center("##########  ",0,132),
    reply->status_data.status = "S"
   WITH nocounter, nullreport, maxrow = 65,
    maxcol = 132, outerjoin = d2, compress
  ;end select
 ENDIF
 SUBROUTINE parseparam(prefix_string,param_string,ppparamtype)
   IF ((request->export_report_xml=1))
    SET nparaminfocnt += 1
    SET stat = alterlist(param_info->param_qual,nparaminfocnt)
    SET param_info->param_qual[nparaminfocnt].param_type = ppparamtype
    SET param_info->param_qual[nparaminfocnt].param_name = replace(replace(prefix_string,"and ","",1),
     ":","",2)
    SET param_info->param_qual[nparaminfocnt].param_value = param_string
   ENDIF
   IF (textlen(trim(prefix_string)) > 0)
    SET temp_string = concat(trim(prefix_string),space_string,space_string,trim(param_string))
   ELSE
    SET temp_string = trim(param_string)
   ENDIF
   IF (textlen(temp_string) > 121)
    SET temp_string = concat(substring(1,111,trim(temp_string))," ",captions->more)
   ENDIF
   CASE (ppparamtype)
    OF 1:
     SET patient_line_cnt += 1
     IF (patient_line_cnt > max_patient_line_cnt)
      SET stat = alter(patient_param_lines->line_qual,(patient_line_cnt+ 4))
      SET max_patient_line_cnt = (patient_line_cnt+ 4)
     ENDIF
    OF 2:
     SET case_line_cnt += 1
     IF (case_line_cnt > max_case_line_cnt)
      SET stat = alter(case_param_lines->line_qual,(case_line_cnt+ 4))
      SET max_case_line_cnt = (case_line_cnt+ 4)
     ENDIF
    OF 3:
     SET criteria_line_cnt += 1
     IF (criteria_line_cnt > max_criteria_line_cnt)
      SET stat = alter(criteria_param_lines->line_qual,(criteria_line_cnt+ 4))
      SET max_criteria_line_cnt = (criteria_line_cnt+ 4)
     ENDIF
    OF 4:
     SET report_line_cnt += 1
     IF (report_line_cnt > max_report_line_cnt)
      SET stat = alter(report_param_lines->line_qual,(report_line_cnt+ 4))
      SET max_report_line_cnt = (report_line_cnt+ 4)
     ENDIF
   ENDCASE
   CASE (ppparamtype)
    OF 1:
     SET patient_param_lines->line_qual[patient_line_cnt].line_text = trim(temp_string)
    OF 2:
     SET case_param_lines->line_qual[case_line_cnt].line_text = trim(temp_string)
    OF 3:
     SET criteria_param_lines->line_qual[criteria_line_cnt].line_text = trim(temp_string)
    OF 4:
     SET report_param_lines->line_qual[report_line_cnt].line_text = trim(temp_string)
   ENDCASE
 END ;Subroutine
 SUBROUTINE createparamlines(ppsdummyvar)
   SET bfirst = "T"
   IF (textlen(trim(temp_agecoldate)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->age_coll,trim(temp_agecoldate),1)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->age_coll),trim(temp_agecoldate),1)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_agecurdate)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->cur,trim(temp_agecurdate),1)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->cur),trim(temp_agecurdate),1)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_birthdate)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->bd,trim(temp_birthdate),1)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->bd),trim(temp_birthdate),1)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_ethnicgroup)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->eth,trim(temp_ethnicgroup),1)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->eth),trim(temp_ethnicgroup),1)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_gender)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->gen,trim(temp_gender),1)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->gen),trim(temp_gender),1)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_race)) != 0)
    IF (bfirst="T")
     CALL parsepram(captions->rc,trim(temp_race),1)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->rc),trim(temp_race),1)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_species)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->spe,trim(temp_species),1)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->spe),trim(temp_species),1)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_military)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->mil,trim(temp_military),1)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->mil),trim(temp_military),1)
    ENDIF
   ENDIF
   SET bfirst = "T"
   IF (textlen(trim(temp_accprefix)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->acc,trim(temp_accprefix),2)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->acc),trim(temp_accprefix),2)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_casetype)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->c_tp,trim(temp_casetype),2)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->c_tp),trim(temp_casetype),2)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_client)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->clnt,trim(temp_client),2)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->clnt),trim(temp_client),2)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_coldate)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->coll,trim(temp_coldate),2)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->coll),trim(temp_coldate),2)
    ENDIF
   ENDIF
   CASE (nimagesearchtype)
    OF 1:
     IF (bfirst="T")
      CALL parseparam("Image at any level:","search case and all report sections",2)
      SET bfirst = "F"
     ELSE
      CALL parseparam("and Image at any level:","search case and all report sections",2)
     ENDIF
    OF 2:
     IF (bfirst="T")
      CALL parseparam("Image at case level","",2)
      SET bfirst = "F"
     ELSE
      CALL parseparam("and Image at case level","",2)
     ENDIF
    OF 3:
     IF (bfirst="T")
      CALL parseparam("Image at section level not using default:",trim(temp_imagetaskassay),2)
      SET bfirst = "F"
     ELSE
      CALL parseparam("and Image at section level not using default:",trim(temp_imagetaskassay),2)
     ENDIF
    OF 4:
     IF (bfirst="T")
      CALL parseparam("Image at case level and image at section level not using default:",trim(
        temp_imagetaskassay),2)
      SET bfirst = "F"
     ELSE
      CALL parseparam("and Image at case level and image at section level not using default:",trim(
        temp_imagetaskassay),2)
     ENDIF
    OF 5:
     IF (bfirst="T")
      CALL parseparam("Image at section level using default:","search sections from Case criteria",2)
      SET bfirst = "F"
     ELSE
      CALL parseparam("and Image at section level using default:",
       "search sections from Case criteria",2)
     ENDIF
    OF 6:
     IF (bfirst="T")
      CALL parseparam("Image at case level and image at section level using default:",
       "search sections from Case criteria",2)
      SET bfirst = "F"
     ELSE
      CALL parseparam("and Image at case level and image at section level using default:",
       "search sections from Case criteria",2)
     ENDIF
   ENDCASE
   IF (textlen(trim(temp_taskassay)) != 0)
    CALL parseparam("",trim(temp_taskassay),4)
   ENDIF
   IF (textlen(trim(temp_verdate)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->ver_dt,trim(temp_verdate),2)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->ver_dt),trim(temp_verdate),2)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_verid)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->ver_id,trim(temp_verid),2)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->ver_id),trim(temp_verid),2)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_queryresult)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->qry,trim(temp_queryresult),2)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->qry),trim(temp_queryresult),2)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_reqphys)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->req_ph,trim(temp_reqphys),2)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->req_ph),trim(temp_reqphys),2)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_resppath)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->res_pa,trim(temp_resppath),2)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->res_pa),trim(temp_resppath),2)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_respresi)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->res_res,trim(temp_respresi),2)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->res_res),trim(temp_respresi),2)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_specimen)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->spcmn,trim(temp_specimen),2)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->spcmn),trim(temp_specimen),2)
    ENDIF
   ENDIF
   SET bfirst = "T"
   IF (textlen(trim(temp_diagcode1)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->dig_cd,trim(temp_diagcode1),3)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->dig_cd),trim(temp_diagcode1),3)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_diagcode2)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->dig_cd,trim(temp_diagcode2),3)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->dig_cd),trim(temp_diagcode2),3)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_diagcode3)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->dig_cd,trim(temp_diagcode3),3)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->dig_cd),trim(temp_diagcode3),3)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_diagcode4)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->dig_cd,trim(temp_diagcode4),3)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->dig_cd),trim(temp_diagcode4),3)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_diagcode5)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->dig_cd,trim(temp_diagcode5),3)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->dig_cd),trim(temp_diagcode5),3)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_diagcode6)) != 0)
    IF (bfirst="T")
     CALL parseparam(captions->dig_cd,trim(temp_diagcode6),3)
     SET bfirst = "F"
    ELSE
     CALL parseparam(concat(captions->an," ",captions->dig_cd),trim(temp_diagcode6),3)
    ENDIF
   ENDIF
   IF (textlen(trim(temp_freetext)) != 0)
    IF (bfirst="T")
     CASE (query_type)
      OF 1:
       CALL parseparam(concat(captions->ft,captions->doc),trim(temp_freetext),3)
      OF 2:
       CALL parseparam(concat(captions->ft,captions->doc),trim(temp_freetext),3)
      OF 3:
       CALL parseparam(concat(captions->ft,captions->par),trim(temp_freetext),3)
      OF 4:
       CALL parseparam(concat(captions->ft,captions->summ),trim(temp_freetext),3)
      OF 5:
       CALL parseparam(concat(captions->ft,captions->docsumm),trim(temp_freetext),3)
      OF 6:
       CALL parseparam(concat(captions->ft,captions->docsumm),trim(temp_freetext),3)
     ENDCASE
     SET bfirst = "F"
    ELSE
     CASE (query_type)
      OF 1:
       CALL parseparam(concat(captions->an," ",captions->ft,captions->doc),trim(temp_freetext),3)
      OF 2:
       CALL parseparam(concat(captions->an," ",captions->ft,captions->doc),trim(temp_freetext),3)
      OF 3:
       CALL parseparam(concat(captions->an," ",captions->ft,captions->par),trim(temp_freetext),3)
      OF 4:
       CALL parseparam(concat(captions->an," ",captions->ft,captions->summ),trim(temp_freetext),3)
      OF 5:
       CALL parseparam(concat(captions->an," ",captions->ft,captions->docsumm),trim(temp_freetext),3)
      OF 6:
       CALL parseparam(concat(captions->an," ",captions->ft,captions->docsumm),trim(temp_freetext),3)
     ENDCASE
    ENDIF
   ENDIF
   IF (textlen(trim(temp_synoptic)) != 0)
    CALL parseparam(captions->synoptic,trim(temp_synoptic),3)
   ENDIF
   SET max_patient_line_cnt = patient_line_cnt
   SET stat = alter(patient_param_lines->line_qual,max_patient_line_cnt)
   SET max_case_line_cnt = case_line_cnt
   SET stat = alter(case_param_lines->line_qual,max_case_line_cnt)
   SET max_report_line_cnt = report_line_cnt
   SET stat = alter(report_param_lines->line_qual,max_report_line_cnt)
   SET max_criteria_line_cnt = criteria_line_cnt
   SET stat = alter(criteria_param_lines->line_qual,max_criteria_line_cnt)
 END ;Subroutine
 SUBROUTINE createparamstrings(cpspatient_string,cpscase_string,cpscriteria_string)
   SELECT INTO "nl:"
    param_name = request->param_qual[d1.seq].param_name, cv.code_value
    FROM (dummyt d1  WITH seq = value(nbr_params)),
     code_value cv
    PLAN (d1)
     JOIN (cv
     WHERE (cv.code_value=request->param_qual[d1.seq].source_vocabulary_cd))
    ORDER BY param_name, request->param_qual[d1.seq].beg_value_disp
    HEAD param_name
     IF ((request->param_qual[d1.seq].param_name != temp_param_name))
      temp_param_name = request->param_qual[d1.seq].param_name
     ENDIF
    DETAIL
     CASE (trim(temp_param_name))
      OF "CASE_ACCPREFIX":
       IF (textlen(trim(temp_accprefix))=0)
        temp_accprefix = concat(trim(request->param_qual[d1.seq].beg_value_disp))
       ELSE
        temp_accprefix = concat(trim(temp_accprefix),comma_or_string,trim(request->param_qual[d1.seq]
          .beg_value_disp))
       ENDIF
      OF "CASE_CASETYPE":
       IF (textlen(trim(temp_casetype))=0)
        temp_casetype = concat(trim(request->param_qual[d1.seq].beg_value_disp))
       ELSE
        temp_casetype = concat(trim(temp_casetype),comma_or_string,trim(request->param_qual[d1.seq].
          beg_value_disp))
       ENDIF
      OF "CASE_COLDATE":
       CASE (request->param_qual[d1.seq].date_type_flag)
        OF 1:
         begdttm = format(cnvtdatetime(request->param_qual[d1.seq].beg_value_dt_tm),
          "@MEDIUMDATE4YR;;D"),enddttm = format(cnvtdatetime(request->param_qual[d1.seq].
           end_value_dt_tm),"@MEDIUMDATE4YR;;D")
        OF 2:
         temp_value = request->param_qual[d1.seq].beg_value_id,val_dt_tm1 = cnvtagedatetime(0,0,0,
          temp_value),begdttm = format(cnvtdatetime(val_dt_tm1),"@MEDIUMDATE4YR;;D"),
         enddttm = format(cnvtdatetime(sysdate),"@MEDIUMDATE4YR;;D")
        OF 3:
         temp_value = request->param_qual[d1.seq].beg_value_id,val_dt_tm1 = cnvtagedatetime(0,
          temp_value,0,0),begdttm = format(cnvtdatetime(val_dt_tm1),"@MEDIUMDATE4YR;;D"),
         enddttm = format(cnvtdatetime(sysdate),"@MEDIUMDATE4YR;;D")
        OF 4:
         temp_value = request->param_qual[d1.seq].beg_value_id,val_dt_tm1 = cnvtagedatetime(
          temp_value,0,0,0),begdttm = format(cnvtdatetime(val_dt_tm1),"@MEDIUMDATE4YR;;D"),
         enddttm = format(cnvtdatetime(sysdate),"@MEDIUMDATE4YR;;D")
       ENDCASE
       ,temp_coldate = concat(begdttm,to_string,enddttm)
      OF "CASE_IMAGEANYLEVEL":
       nimagesearchtype = 1
      OF "CASE_IMAGECASELEVEL":
       IF (((nimagesearchtype=3) OR (nimagesearchtype=4)) )
        nimagesearchtype = 4
       ELSEIF (((nimagesearchtype=5) OR (nimagesearchtype=6)) )
        nimagesearchtype = 6
       ELSE
        nimagesearchtype = 2
       ENDIF
      OF "CASE_IMAGETASKASSAY":
       IF (((nimagesearchtype=2) OR (nimagesearchtype=4)) )
        nimagesearchtype = 4
       ELSE
        nimagesearchtype = 3
       ENDIF
       ,
       IF (textlen(trim(temp_imagetaskassay))=0)
        temp_imagetaskassay = concat("search ",trim(request->param_qual[d1.seq].beg_value_disp))
       ELSE
        temp_imagetaskassay = concat(temp_imagetaskassay,comma_or_string,trim(request->param_qual[d1
          .seq].beg_value_disp))
       ENDIF
      OF "CASE_IMAGEUSEDEFAULT":
       IF (((nimagesearchtype=2) OR (nimagesearchtype=6)) )
        nimagesearchtype = 6
       ELSE
        nimagesearchtype = 5
       ENDIF
      OF "CASE_TASKASSAY":
       IF (textlen(trim(temp_taskassay))=0)
        temp_taskassay = concat(trim(request->param_qual[d1.seq].beg_value_disp))
       ELSE
        temp_taskassay = concat(trim(temp_taskassay),comma_or_string,trim(request->param_qual[d1.seq]
          .beg_value_disp))
       ENDIF
      OF "CASE_VERDATE":
       CASE (request->param_qual[d1.seq].date_type_flag)
        OF 1:
         begdttm = format(cnvtdatetime(request->param_qual[d1.seq].beg_value_dt_tm),
          "@MEDIUMDATE4YR;;D"),enddttm = format(cnvtdatetime(request->param_qual[d1.seq].
           end_value_dt_tm),"@MEDIUMDATE4YR;;D")
        OF 2:
         temp_value = request->param_qual[d1.seq].beg_value_id,val_dt_tm1 = cnvtagedatetime(0,0,0,
          temp_value),begdttm = format(cnvtdatetime(val_dt_tm1),"@MEDIUMDATE4YR;;D"),
         enddttm = format(cnvtdatetime(sysdate),"@MEDIUMDATE4YR;;D")
        OF 3:
         temp_value = request->param_qual[d1.seq].beg_value_id,val_dt_tm1 = cnvtagedatetime(0,
          temp_value,0,0),begdttm = format(cnvtdatetime(val_dt_tm1),"@MEDIUMDATE4YR;;D"),
         enddttm = format(cnvtdatetime(sysdate),"@MEDIUMDATE4YR;;D")
        OF 4:
         temp_value = request->param_qual[d1.seq].beg_value_id,val_dt_tm1 = cnvtagedatetime(
          temp_value,0,0,0),begdttm = format(cnvtdatetime(val_dt_tm1),"@MEDIUMDATE4YR;;D"),
         enddttm = format(cnvtdatetime(sysdate),"@MEDIUMDATE4YR;;D")
       ENDCASE
       ,temp_verdate = concat(begdttm,to_string,enddttm)
      OF "CASE_VERID":
       IF (textlen(trim(temp_verid))=0)
        temp_verid = concat(trim(request->param_qual[d1.seq].beg_value_disp))
       ELSE
        temp_verid = concat(trim(temp_verid),comma_or_string,trim(request->param_qual[d1.seq].
          beg_value_disp))
       ENDIF
      OF "CASE_REQPHYS":
       IF (textlen(trim(temp_reqphys))=0)
        temp_reqphys = concat(trim(request->param_qual[d1.seq].beg_value_disp))
       ELSE
        temp_reqphys = concat(trim(temp_reqphys),comma_or_string,trim(request->param_qual[d1.seq].
          beg_value_disp))
       ENDIF
      OF "CASE_RESPPATH":
       IF (textlen(trim(temp_resppath))=0)
        temp_resppath = concat(trim(request->param_qual[d1.seq].beg_value_disp))
       ELSE
        temp_resppath = concat(trim(temp_resppath),comma_or_string,trim(request->param_qual[d1.seq].
          beg_value_disp))
       ENDIF
      OF "CASE_RESPRESI":
       IF (textlen(trim(temp_respresi))=0)
        temp_respresi = concat(trim(request->param_qual[d1.seq].beg_value_disp))
       ELSE
        temp_respresi = concat(trim(temp_respresi),comma_or_string,trim(request->param_qual[d1.seq].
          beg_value_disp))
       ENDIF
      OF "CASE_CLIENT":
       IF (textlen(trim(temp_client))=0)
        temp_client = concat(trim(request->param_qual[d1.seq].beg_value_disp))
       ELSE
        temp_client = concat(trim(temp_client),comma_or_string,trim(request->param_qual[d1.seq].
          beg_value_disp))
       ENDIF
      OF "CASE_SPECIMEN":
       IF (textlen(trim(temp_specimen))=0)
        temp_specimen = concat(trim(request->param_qual[d1.seq].beg_value_disp))
       ELSE
        temp_specimen = concat(trim(temp_specimen),comma_or_string,trim(request->param_qual[d1.seq].
          beg_value_disp))
       ENDIF
      OF "CASE_QUERYRESULT":
       IF (textlen(trim(temp_queryresult))=0)
        temp_queryresult = concat(trim(request->param_qual[d1.seq].beg_value_disp))
       ELSE
        temp_queryresult = concat(trim(temp_queryresult),comma_or_string,trim(request->param_qual[d1
          .seq].beg_value_disp))
       ENDIF
      OF "CRITERIA_DIAGCODE1":
       IF (textlen(trim(temp_diagcode1))=0)
        temp_diagcode1 = concat("(",trim(cv.display),")",space_string,trim(request->param_qual[d1.seq
          ].beg_value_disp))
       ELSE
        temp_diagcode1 = concat(trim(temp_diagcode1),comma_or_string,"(",trim(cv.display),")",
         space_string,trim(request->param_qual[d1.seq].beg_value_disp))
       ENDIF
       ,
       IF (trim(request->param_qual[d1.seq].beg_value_disp) != trim(request->param_qual[d1.seq].
        end_value_disp))
        temp_diagcode1 = concat(trim(temp_diagcode1),to_string,trim(request->param_qual[d1.seq].
          end_value_disp))
       ENDIF
      OF "CRITERIA_DIAGCODE2":
       IF (textlen(trim(temp_diagcode2))=0)
        temp_diagcode2 = concat("(",trim(cv.display),")",space_string,trim(request->param_qual[d1.seq
          ].beg_value_disp))
       ELSE
        temp_diagcode2 = concat(trim(temp_diagcode2),comma_or_string,"(",trim(cv.display),")",
         space_string,trim(request->param_qual[d1.seq].beg_value_disp))
       ENDIF
       ,
       IF (trim(request->param_qual[d1.seq].beg_value_disp) != trim(request->param_qual[d1.seq].
        end_value_disp))
        temp_diagcode2 = concat(trim(temp_diagcode2),to_string,trim(request->param_qual[d1.seq].
          end_value_disp))
       ENDIF
      OF "CRITERIA_DIAGCODE3":
       IF (textlen(trim(temp_diagcode3))=0)
        temp_diagcode3 = concat("(",trim(cv.display),")",space_string,trim(request->param_qual[d1.seq
          ].beg_value_disp))
       ELSE
        temp_diagcode3 = concat(trim(temp_diagcode3),comma_or_string,"(",trim(cv.display),")",
         space_string,trim(request->param_qual[d1.seq].beg_value_disp))
       ENDIF
       ,
       IF (trim(request->param_qual[d1.seq].beg_value_disp) != trim(request->param_qual[d1.seq].
        end_value_disp))
        temp_diagcode3 = concat(trim(temp_diagcode3),to_string,trim(request->param_qual[d1.seq].
          end_value_disp))
       ENDIF
      OF "CRITERIA_DIAGCODE4":
       IF (textlen(trim(temp_diagcode4))=0)
        temp_diagcode4 = concat("(",trim(cv.display),")",space_string,trim(request->param_qual[d1.seq
          ].beg_value_disp))
       ELSE
        temp_diagcode4 = concat(trim(temp_diagcode4),comma_or_string,"(",trim(cv.display),")",
         space_string,trim(request->param_qual[d1.seq].beg_value_disp))
       ENDIF
       ,
       IF (trim(request->param_qual[d1.seq].beg_value_disp) != trim(request->param_qual[d1.seq].
        end_value_disp))
        temp_diagcode4 = concat(trim(temp_diagcode4),to_string,trim(request->param_qual[d1.seq].
          end_value_disp))
       ENDIF
      OF "CRITERIA_DIAGCODE5":
       IF (textlen(trim(temp_diagcode5))=0)
        temp_diagcode5 = concat("(",trim(cv.display),")",space_string,trim(request->param_qual[d1.seq
          ].beg_value_disp))
       ELSE
        temp_diagcode5 = concat(trim(temp_diagcode5),comma_or_string,"(",trim(cv.display),")",
         space_string,trim(request->param_qual[d1.seq].beg_value_disp))
       ENDIF
       ,
       IF (trim(request->param_qual[d1.seq].beg_value_disp) != trim(request->param_qual[d1.seq].
        end_value_disp))
        temp_diagcode5 = concat(trim(temp_diagcode5),to_string,trim(request->param_qual[d1.seq].
          end_value_disp))
       ENDIF
      OF "CRITERIA_INTERNAL":
       IF (textlen(trim(temp_diagcode6))=0)
        temp_diagcode6 = concat("(",trim(cv.display),")",space_string,trim(request->param_qual[d1.seq
          ].beg_value_disp))
       ELSE
        temp_diagcode6 = concat(trim(temp_diagcode6),comma_or_string,"(",trim(cv.display),")",
         space_string,trim(request->param_qual[d1.seq].beg_value_disp))
       ENDIF
       ,
       IF (trim(request->param_qual[d1.seq].beg_value_disp) != trim(request->param_qual[d1.seq].
        end_value_disp))
        temp_diagcode6 = concat(trim(temp_diagcode6),to_string,trim(request->param_qual[d1.seq].
          end_value_disp))
       ENDIF
      OF "CRITERIA_FREETEXT":
       temp_freetext = concat(trim(request->param_qual[d1.seq].freetext_query)),
       CASE (request->param_qual[d1.seq].freetext_query_flag)
        OF 0:
         IF ((request->query_type=1))
          query_type = 1
         ELSE
          query_type = 2
         ENDIF
        OF 1:
         query_type = 3
        OF 2:
         query_type = 4
        OF 3:
         IF ((request->query_type=1))
          query_type = 5
         ELSE
          query_type = 6
         ENDIF
       ENDCASE
      OF "CRITERIA_SYNOPTIC":
       temp_synoptic = trim(request->param_qual[d1.seq].synoptic_xml_query),start_pos = findstring(
        "<UserTextualDisplay>",temp_synoptic),end_pos = findstring("</UserTextualDisplay",
        temp_synoptic),
       temp_user_display = trim(substring((start_pos+ 20),(end_pos - (start_pos+ 20)),temp_synoptic)),
       temp_synoptic = trim(temp_user_display),temp_synoptic = replace(temp_synoptic,"&lt;","<",0),
       temp_synoptic = replace(temp_synoptic,"&gt;",">",0),temp_synoptic = replace(temp_synoptic,
        "&quot;",'"',0),temp_synoptic = replace(temp_synoptic,"&apos;","'",0),
       temp_synoptic = replace(temp_synoptic,"&amp;","&",0)
      OF "PATIENT_AGECOLDATE":
       CASE (request->param_qual[d1.seq].date_type_flag)
        OF 2:
         dt_type_string = "days"
        OF 3:
         dt_type_string = "months"
        OF 4:
         dt_type_string = "years"
       ENDCASE
       ,
       IF (textlen(trim(temp_agecoldate))=0)
        temp_agecoldate = concat(trim(cnvtstring(request->param_qual[d1.seq].beg_value_id,32,2)),
         to_string,trim(cnvtstring(request->param_qual[d1.seq].end_value_id,32,2)),space_string,
         dt_type_string)
       ELSE
        temp_agecoldate = concat(trim(temp_agecoldate),comma_or_string,trim(cnvtstring(request->
           param_qual[d1.seq].beg_value_id,32,2)),to_string,trim(cnvtstring(request->param_qual[d1
           .seq].end_value_id,32,2)),
         space_string,dt_type_string)
       ENDIF
      OF "PATIENT_AGECURDATE":
       CASE (request->param_qual[d1.seq].date_type_flag)
        OF 2:
         dt_type_string = "days"
        OF 3:
         dt_type_string = "months"
        OF 4:
         dt_type_string = "years"
       ENDCASE
       ,
       IF (textlen(trim(temp_agecurdate))=0)
        temp_agecurdate = concat(trim(cnvtstring(request->param_qual[d1.seq].beg_value_id,32,2)),
         to_string,trim(cnvtstring(request->param_qual[d1.seq].end_value_id,32,2)),space_string,
         dt_type_string)
       ELSE
        temp_agecurdate = concat(trim(temp_agecurdate),comma_or_string,trim(cnvtstring(request->
           param_qual[d1.seq].beg_value_id,32,2)),to_string,trim(cnvtstring(request->param_qual[d1
           .seq].end_value_id,32,2)),
         space_string,dt_type_string)
       ENDIF
      OF "PATIENT_BIRTHDATE":
       CASE (request->param_qual[d1.seq].date_type_flag)
        OF 1:
         begdttm = format(cnvtdatetime(request->param_qual[d1.seq].beg_value_dt_tm),
          "@MEDIUMDATE4YR;;D"),enddttm = format(cnvtdatetime(request->param_qual[d1.seq].
           end_value_dt_tm),"@MEDIUMDATE4YR;;D")
        OF 2:
         temp_value = request->param_qual[d1.seq].beg_value_id,val_dt_tm1 = cnvtagedatetime(0,0,0,
          temp_value),begdttm = format(cnvtdatetime(val_dt_tm1),"@MEDIUMDATE4YR;;D"),
         enddttm = format(cnvtdatetime(sysdate),"@MEDIUMDATE4YR;;D")
        OF 3:
         temp_value = request->param_qual[d1.seq].beg_value_id,val_dt_tm1 = cnvtagedatetime(0,
          temp_value,0,0),begdttm = format(cnvtdatetime(val_dt_tm1),"@MEDIUMDATE4YR;;D"),
         enddttm = format(cnvtdatetime(sysdate),"@MEDIUMDATE4YR;;D")
        OF 4:
         temp_value = request->param_qual[d1.seq].beg_value_id,val_dt_tm1 = cnvtagedatetime(
          temp_value,0,0,0),begdttm = format(cnvtdatetime(val_dt_tm1),"@MEDIUMDATE4YR;;D"),
         enddttm = format(cnvtdatetime(sysdate),"@MEDIUMDATE4YR;;D")
       ENDCASE
       ,temp_birthdate = concat(begdttm,to_string,enddttm)
      OF "PATIENT_ETHNICGROUP":
       IF (textlen(trim(temp_ethnicgroup))=0)
        temp_ethnicgroup = concat(trim(request->param_qual[d1.seq].beg_value_disp))
       ELSE
        temp_ethnicgroup = concat(trim(temp_ethnicgroup),comma_or_string,trim(request->param_qual[d1
          .seq].beg_value_disp))
       ENDIF
      OF "PATIENT_GENDER":
       IF (textlen(trim(temp_gender))=0)
        temp_gender = concat(trim(request->param_qual[d1.seq].beg_value_disp))
       ELSE
        temp_gender = concat(trim(temp_gender),comma_or_string,trim(request->param_qual[d1.seq].
          beg_value_disp))
       ENDIF
      OF "PATIENT_RACE":
       IF (textlen(trim(temp_race))=0)
        temp_race = concat(trim(request->param_qual[d1.seq].beg_value_disp))
       ELSE
        temp_race = concat(trim(temp_race),comma_or_string,trim(request->param_qual[d1.seq].
          beg_value_disp))
       ENDIF
      OF "PATIENT_SPECIES":
       IF (textlen(trim(temp_species))=0)
        temp_species = concat(trim(request->param_qual[d1.seq].beg_value_disp))
       ELSE
        temp_species = concat(trim(temp_species),comma_or_string,trim(request->param_qual[d1.seq].
          beg_value_disp))
       ENDIF
      OF "PATIENT_MILITARY":
       IF (textlen(trim(temp_species))=0)
        temp_military = concat(trim(request->param_qual[d1.seq].beg_value_disp))
       ELSE
        temp_military = concat(trim(temp_military),comma_or_string,trim(request->param_qual[d1.seq].
          beg_value_disp))
       ENDIF
      OF "PATIENTALIASFLAG":
       IF (textlen(trim(request->param_qual[d1.seq].beg_value_disp)) > 0)
        spatientaliasflag = trim(request->param_qual[d1.seq].beg_value_disp)
       ELSE
        spatientaliasflag = "N"
       ENDIF
      OF "SNOMEDCODEFLAG":
       IF (textlen(trim(request->param_qual[d1.seq].beg_value_disp)) > 0)
        ssnomedcodeflag = trim(request->param_qual[d1.seq].beg_value_disp)
       ELSE
        ssnomedcodeflag = "N"
       ENDIF
     ENDCASE
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 FREE RECORD case_struct
 FREE RECORD patient_param_lines
 FREE RECORD case_param_lines
 FREE RECORD report_param_lines
 FREE RECORD criteria_param_lines
 FREE RECORD param_info
END GO
