CREATE PROGRAM abn_rpt_rules:dba
 RECORD reply(
   1 report_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE icnt = i2
 FREE SET sub_wrap_rec
 RECORD sub_wrap_rec(
   1 qual_cnt = i4
   1 qual[*]
     2 text = vc
   1 temp_str = vc
   1 new_str = vc
 )
 SUBROUTINE sub_wrap(input_str,str_width)
   SET cur1 = 0
   SET cur2 = 0
   SET sub_wrap_rec->qual_cnt = 0
   CALL str_scan(input_str)
   SET sub_wrap_rec->new_str = sub_wrap_rec->temp_str
   SET text_len = textlen(sub_wrap_rec->new_str)
   IF (text_len > str_width)
    WHILE (text_len > str_width)
      SET wrap_ind = 0
      SET cur1 = 1
      WHILE (wrap_ind=0)
        SET cur2 = findstring(" ",sub_wrap_rec->new_str,cur1)
        IF (cur2=0)
         SET cur2 = (str_width+ 1)
        ENDIF
        IF (cur1=1
         AND cur2 > str_width)
         SET sub_wrap_rec->qual_cnt += 1
         SET stat = alterlist(sub_wrap_rec->qual,sub_wrap_rec->qual_cnt)
         SET sub_wrap_rec->qual[sub_wrap_rec->qual_cnt].text = substring(1,str_width,sub_wrap_rec->
          new_str)
         SET sub_wrap_rec->new_str = substring((str_width+ 1),(text_len - str_width),sub_wrap_rec->
          new_str)
         SET wrap_ind = 1
        ELSEIF (cur2 > str_width)
         SET sub_wrap_rec->qual_cnt += 1
         SET stat = alterlist(sub_wrap_rec->qual,sub_wrap_rec->qual_cnt)
         SET sub_wrap_rec->qual[sub_wrap_rec->qual_cnt].text = trim(substring(1,(cur1 - 1),
           sub_wrap_rec->new_str))
         SET sub_wrap_rec->new_str = substring(cur1,((text_len - cur1)+ 1),sub_wrap_rec->new_str)
         SET wrap_ind = 1
        ENDIF
        SET cur1 = (cur2+ 1)
      ENDWHILE
      SET text_len = textlen(sub_wrap_rec->new_str)
    ENDWHILE
    SET sub_wrap_rec->qual_cnt += 1
    SET stat = alterlist(sub_wrap_rec->qual,sub_wrap_rec->qual_cnt)
    SET sub_wrap_rec->qual[sub_wrap_rec->qual_cnt].text = sub_wrap_rec->new_str
   ELSE
    SET sub_wrap_rec->qual_cnt += 1
    SET stat = alterlist(sub_wrap_rec->qual,sub_wrap_rec->qual_cnt)
    SET sub_wrap_rec->qual[sub_wrap_rec->qual_cnt].text = sub_wrap_rec->new_str
   ENDIF
 END ;Subroutine
 SUBROUTINE str_scan(input_str2)
   SET text_length = textlen(input_str2)
   SET sub_wrap_rec->temp_str = " "
   FOR (j = 1 TO text_length)
     SET temp_char = substring(j,1,input_str2)
     IF (temp_char=" ")
      SET temp_char = "^"
     ENDIF
     IF ( NOT (ichar(temp_char) IN (10, 13)))
      SET sub_wrap_rec->temp_str = concat(sub_wrap_rec->temp_str,temp_char)
     ENDIF
   ENDFOR
   SET sub_wrap_rec->temp_str = replace(sub_wrap_rec->temp_str,"^"," ",0)
 END ;Subroutine
 RECORD rules(
   1 fin_qual[*]
     2 fin_disp = c50
     2 encntr_qual[*]
       3 encntr_disp = c50
       3 cpt_qual[*]
         4 cpt_code = c10
         4 cpt_desc = vc
         4 cpt_nomen_id = f8
         4 diag_qual[*]
           5 diag_desc = c45
           5 diag_code = c10
           5 exclude_flag = c1
         4 proc_qual[*]
           5 proc_disp = c50
 )
 SET reply->status_data.status = "S"
 SET counter = 0
 SET row_counter = 0
 SET address_type = 0.0
 SET active_cd = 0.0
 SET primary_mnemonic_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(212,"BUSINESS",1,address_type)
 SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,active_cd)
 SET stat = uar_get_meaning_by_codeset(6011,"PRIMARY",1,primary_mnemonic_cd)
 IF (((address_type=0) OR (((active_cd=0) OR (primary_mnemonic_cd=0)) )) )
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_MEANING_BY_CODESET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
 ENDIF
 SET org_name = fillstring(50,"")
 SET addr1 = fillstring(50,"")
 SET addr2 = fillstring(50,"")
 SET addr3 = fillstring(50,"")
 SET addr4 = fillstring(50,"")
 SET city_display = fillstring(50,"")
 SET state_display = fillstring(2,"")
 SET zip_display = fillstring(10,"")
 SET x = 0
 SET y = 0
 SELECT INTO "nl:"
  org_disp = substring(1,50,trim(o.org_name)), od.lab_org_id, addr1_disp = substring(1,50,trim(a
    .street_addr)),
  addr2_disp = substring(1,50,trim(a.street_addr2)), addr3_disp = substring(1,50,trim(a.street_addr3)
   ), addr4_disp = substring(1,50,trim(a.street_addr4)),
  city_disp = substring(1,50,trim(a.city)), state_disp = substring(1,2,trim(a.state)), zip_disp =
  substring(1,10,trim(a.zipcode))
  FROM osm_defaults od,
   organization o,
   address a,
   dummyt d1,
   dummyt d2
  PLAN (od
   WHERE od.lab_org_id > 0)
   JOIN (o
   WHERE o.organization_id=od.lab_org_id)
   JOIN (d1)
   JOIN (a
   WHERE a.address_type_cd=address_type
    AND a.parent_entity_id=o.organization_id
    AND a.parent_entity_name="ORGANIZATION"
    AND a.active_ind=1)
   JOIN (d2)
  HEAD REPORT
   addr1 = addr1_disp, addr2 = addr2_disp, addr3 = addr3_disp,
   addr4 = addr4_disp, city_display = city_disp, state_display = state_disp,
   zip_display = zip_disp, org_name = org_disp
  FOOT REPORT
   row + 0
  WITH nocounter, dontcare = a
 ;end select
 IF ((request->fin_class_cd > 0)
  AND (request->encntr_type_cd > 0)
  AND (request->cpt_nomen_id > 0))
  SET where1 = "a.fin_class_cd = request->fin_class_cd"
  SET where2 = "a.encntr_type_cd = request->encntr_type_cd"
  SET where3 = "a.cpt_nomen_id = request->cpt_nomen_id"
 ELSEIF ((request->fin_class_cd > 0)
  AND (request->encntr_type_cd > 0))
  SET where1 = "a.fin_class_cd = request->fin_class_cd"
  SET where2 = "a.encntr_type_cd = request->encntr_type_cd"
  SET where3 = "a.cpt_nomen_id > 0"
 ELSEIF ((request->fin_class_cd > 0)
  AND (request->cpt_nomen_id > 0))
  SET where1 = "a.fin_class_cd = request->fin_class_cd"
  SET where2 = "a.encntr_type_cd > 0"
  SET where3 = "a.cpt_nomen_id = request->cpt_nomen_id"
 ELSEIF ((request->fin_class_cd > 0))
  SET where1 = "a.fin_class_cd = request->fin_class_cd"
  SET where2 = "a.encntr_type_cd > 0"
  SET where3 = "a.cpt_nomen_id > 0"
 ELSEIF ((request->encntr_type_cd > 0))
  SET where1 = "a.fin_class_cd > 0"
  SET where2 = "a.encntr_type_cd = request->encntr_type_cd"
  SET where3 = "a.cpt_nomen_id > 0"
 ELSEIF ((request->cpt_nomen_id > 0))
  SET where1 = "a.fin_class_cd > 0"
  SET where2 = "a.encntr_type_cd > 0"
  SET where3 = "a.cpt_nomen_id = request->cpt_nomen_id"
 ELSE
  SET where1 = "a.fin_class_cd > 0"
  SET where2 = "a.encntr_type_cd > 0"
  SET where3 = "a.cpt_nomen_id > 0"
 ENDIF
 SET sfiledate = format(curdate,"mmdd;;d")
 SET sfiletime = substring(1,4,format(curtime3,"hhmm;;s"))
 SET sfilename = build("ABNRep",sfiledate,sfiletime)
 SET addr_display = fillstring(62,"")
 SET fin_cnt = 0
 SET encntr_cnt = 0
 SET cpt_cnt = 0
 SET diag_cnt = 0
 SET proc_cnt = 0
 SET cpt_max = 0
 SET diag_max = 0
 SET proc_max = 0
 SET encntr_max = 0
 CALL echo("looking up rules and nomenclatures")
 SELECT INTO "nl:"
  fin_display = uar_get_code_display(a.fin_class_cd), encntr_display = uar_get_code_display(a
   .encntr_type_cd), cpt_code = substring(1,10,n.source_identifier),
  cpt_desc = n.source_string, diag_code = substring(1,10,n2.source_identifier), diag_desc = substring
  (1,60,n2.source_string),
  proc_disp = substring(1,20,ocs.mnemonic)
  FROM nomenclature n,
   nomenclature n2,
   abn_rule a,
   abn_cross_reference acr,
   order_catalog_synonym ocs
  PLAN (a
   WHERE parser(where1)
    AND parser(where2)
    AND parser(where3)
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
    AND a.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=a.cpt_nomen_id)
   JOIN (n2
   WHERE n2.nomenclature_id=a.icd9_nomen_id)
   JOIN (acr
   WHERE acr.cpt_nomen_id=a.cpt_nomen_id
    AND acr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND acr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
    AND acr.active_status_cd=active_cd
    AND acr.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=acr.catalog_cd
    AND ocs.mnemonic_type_cd=primary_mnemonic_cd
    AND ocs.active_status_cd=active_cd
    AND ocs.active_ind=1)
  ORDER BY fin_display, encntr_display, n.source_identifier,
   n2.source_identifier
  HEAD REPORT
   row + 0
  HEAD PAGE
   row + 0
  HEAD a.fin_class_cd
   CALL echo("---------------------------------head a.fin_class_cd"), fin_cnt += 1, stat = alterlist(
    rules->fin_qual,fin_cnt),
   rules->fin_qual[fin_cnt].fin_disp = fin_display,
   CALL echo(build("Financial class:",fin_display))
  HEAD a.encntr_type_cd
   CALL echo("---------------------------------head a.encntr_type_cd"), encntr_cnt += 1
   IF (encntr_max < encntr_cnt)
    encntr_max = encntr_cnt
   ENDIF
   stat = alterlist(rules->fin_qual[fin_cnt].encntr_qual,encntr_cnt), rules->fin_qual[fin_cnt].
   encntr_qual[encntr_cnt].encntr_disp = encntr_display, cpt_cnt = 0,
   CALL echo(build("Encounter Type:",encntr_display))
  HEAD n.source_identifier
   CALL echo("---------------------------------head n.source_identifier"), cpt_cnt += 1
   IF (cpt_max < cpt_cnt)
    cpt_max = cpt_cnt
   ENDIF
   stat = alterlist(rules->fin_qual[fin_cnt].encntr_qual[encntr_cnt].cpt_qual,cpt_cnt), rules->
   fin_qual[fin_cnt].encntr_qual[encntr_cnt].cpt_qual[cpt_cnt].cpt_desc = cpt_desc, rules->fin_qual[
   fin_cnt].encntr_qual[encntr_cnt].cpt_qual[cpt_cnt].cpt_code = cpt_code,
   rules->fin_qual[fin_cnt].encntr_qual[encntr_cnt].cpt_qual[cpt_cnt].cpt_nomen_id = a.cpt_nomen_id,
   CALL echo(build("CPT CD:",cpt_code)),
   CALL echo(build("CPT ID:",a.cpt_nomen_id)),
   diag_cnt = 0
  HEAD n2.source_identifier
   CALL echo("---------------------------------head n2.source_identifier"), diag_cnt += 1
   IF (diag_max < diag_cnt)
    diag_max = diag_cnt
   ENDIF
   stat = alterlist(rules->fin_qual[fin_cnt].encntr_qual[encntr_cnt].cpt_qual[cpt_cnt].diag_qual,
    diag_cnt)
   IF (a.valid_diag_flg=2)
    rules->fin_qual[fin_cnt].encntr_qual[encntr_cnt].cpt_qual[cpt_cnt].diag_qual[diag_cnt].diag_desc
     = "No Valid Diagnosis", rules->fin_qual[fin_cnt].encntr_qual[encntr_cnt].cpt_qual[cpt_cnt].
    diag_qual[diag_cnt].exclude_flag = "N"
   ELSEIF (a.valid_diag_flg=1)
    rules->fin_qual[fin_cnt].encntr_qual[encntr_cnt].cpt_qual[cpt_cnt].diag_qual[diag_cnt].
    exclude_flag = "Y", rules->fin_qual[fin_cnt].encntr_qual[encntr_cnt].cpt_qual[cpt_cnt].diag_qual[
    diag_cnt].diag_desc = diag_desc, rules->fin_qual[fin_cnt].encntr_qual[encntr_cnt].cpt_qual[
    cpt_cnt].diag_qual[diag_cnt].diag_code = diag_code
   ELSE
    rules->fin_qual[fin_cnt].encntr_qual[encntr_cnt].cpt_qual[cpt_cnt].diag_qual[diag_cnt].diag_desc
     = diag_desc, rules->fin_qual[fin_cnt].encntr_qual[encntr_cnt].cpt_qual[cpt_cnt].diag_qual[
    diag_cnt].diag_code = diag_code, rules->fin_qual[fin_cnt].encntr_qual[encntr_cnt].cpt_qual[
    cpt_cnt].diag_qual[diag_cnt].exclude_flag = "N"
   ENDIF
   CALL echo(build("diagnosis: ",diag_code)), proc_cnt = 0
  HEAD ocs.catalog_cd
   proc_cnt += 1
   IF (proc_max < proc_cnt)
    proc_max = proc_cnt
   ENDIF
   stat = alterlist(rules->fin_qual[fin_cnt].encntr_qual[encntr_cnt].cpt_qual[cpt_cnt].proc_qual,
    proc_cnt), rules->fin_qual[fin_cnt].encntr_qual[encntr_cnt].cpt_qual[cpt_cnt].proc_qual[proc_cnt]
   .proc_disp = proc_disp,
   CALL echo(build("proc_disp: ",proc_disp))
  FOOT  ocs.catalog_cd
   row + 0
  FOOT  n2.source_identifier
   row + 0
  FOOT  n.source_identifier
   row + 0
  FOOT  a.encntr_type_cd
   row + 0
  FOOT  a.fin_class_cd
   row + 0
  FOOT PAGE
   row + 0
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 CALL echo(build("ENCOUNTER MAX:  ",encntr_cnt))
 CALL echo(build("CPT MAX:  ",cpt_max))
 RECORD diag_row(
   1 qual[*]
     2 row_nbr = i4
     2 y_nbr = i4
 )
 SELECT INTO concat("cer_print:",trim(sfilename),".txt")
  FROM (dummyt d  WITH seq = value(size(rules->fin_qual,5))),
   (dummyt d1  WITH seq = value(encntr_max)),
   (dummyt d2  WITH seq = value(cpt_max)),
   (dummyt d3  WITH seq = value(diag_max)),
   (dummyt d4  WITH seq = value(proc_max)),
   dummyt d5
  PLAN (d)
   JOIN (d1
   WHERE d1.seq <= cnvtint(size(rules->fin_qual[d.seq].encntr_qual,5)))
   JOIN (d2
   WHERE d2.seq <= cnvtint(size(rules->fin_qual[d.seq].encntr_qual[d1.seq].cpt_qual,5)))
   JOIN (d3
   WHERE d3.seq <= cnvtint(size(rules->fin_qual[d.seq].encntr_qual[d1.seq].cpt_qual[d2.seq].diag_qual,
     5)))
   JOIN (d5)
   JOIN (d4
   WHERE d4.seq <= cnvtint(size(rules->fin_qual[d.seq].encntr_qual[d1.seq].cpt_qual[d2.seq].proc_qual,
     5)))
  HEAD REPORT
   "{color/30}", row 0, col 100,
   x = 250, y = 0,
   CALL print(calcpos(x,y)),
   "{CPI/10}{b/15}ABN Rule Report", row + 1, y += 12,
   col 0, x = 25,
   CALL print(calcpos(x,y)),
   "{CPI/18}", org_name, col 100,
   x = 250,
   CALL print(calcpos(x,y)), "{b/16}{cpi/18}Financial Class:",
   col + 2, x = 325
   IF ((request->fin_class_cd > 0))
    CALL print(calcpos(x,y)), "{cpi/18}", rules->fin_qual[1].fin_disp
   ELSE
    CALL print(calcpos(x,y)), "{cpi/18}ALL"
   ENDIF
   col 200, x = 500,
   CALL print(calcpos(x,y)),
   "{CPI/18}As of Date:", col + 2, curdate"mm/dd/yy;;d",
   row + 1, y += 12, col 100,
   x = 250,
   CALL print(calcpos(x,y)), "{b/15}{cpi/18}Encounter Type:",
   col + 2, x = 325
   IF ((request->encntr_type_cd > 0))
    CALL print(calcpos(x,y)), "{cpi/18}", rules->fin_qual[1].encntr_qual[1].encntr_disp
   ELSE
    CALL print(calcpos(x,y)), "{cpi/18}ALL"
   ENDIF
   col 200, x = 500,
   CALL print(calcpos(x,y)),
   "{CPI/18}As of Time:", col + 2, curtime"hh:mm;;m"
   IF (trim(addr1) > "")
    col 0, x = 25,
    CALL print(calcpos(x,y)),
    "{CPI/18}", addr1, row + 1,
    col 100, x = 250, y += 12,
    CALL print(calcpos(x,y)), "{b/9}{cpi/18}CPT Code:", col + 2,
    x = 325
    IF ((request->cpt_nomen_id > 0))
     CALL print(calcpos(x,y)), "{cpi/18}", rules->fin_qual[1].encntr_qual[1].cpt_qual[1].cpt_code
    ELSE
     CALL print(calcpos(x,y)), "{cpi/18}ALL"
    ENDIF
    IF (trim(addr2) > "")
     col 0, x = 25,
     CALL print(calcpos(x,y)),
     "{CPI/18}", addr2
     IF (trim(addr3) > "")
      col 0, row + 1, x = 25,
      y += 12,
      CALL print(calcpos(x,y)), "{CPI/18}",
      addr3
      IF (trim(addr4) > "")
       col 0, row + 1, x = 25,
       y += 12,
       CALL print(calcpos(x,y)), "{CPI/18}",
       addr4
      ENDIF
     ENDIF
    ELSE
     row- (1), y -= 12
    ENDIF
   ELSE
    col 100, row + 1, x = 250,
    y += 12,
    CALL print(calcpos(x,y)), "{b/9}{cpi/18}CPT Code:",
    col + 2, x = 325
    IF ((request->cpt_nomen_id > 0))
     CALL print(calcpos(x,y)), "{cpi/18}", rules->fin_qual[1].encntr_qual[1].cpt_qual[1].cpt_code
    ELSE
     CALL print(calcpos(x,y)), "{cpi/18}ALL"
    ENDIF
    y -= 24, row- (2)
   ENDIF
   col 0, row + 1, x = 25,
   y += 12
   IF (trim(city_display) > "")
    addr_display = concat(trim(city_display),",  ",trim(state_display),"  ",trim(zip_display)),
    CALL print(calcpos(x,y)), "{CPI/18}",
    addr_display
   ENDIF
   row + 1, y += 12, counter = 0
  HEAD PAGE
   CALL echo("---------------------------------head page")
   IF (curpage > 1)
    y = 0, row 0
   ENDIF
  HEAD d.seq
   CALL echo("---------------------------------head d.seq")
   IF (d.seq > 1)
    BREAK
   ENDIF
  HEAD d1.seq
   CALL echo("---------------------------------head d1.seq"), row + 1, y += 12
   IF (row > 55)
    BREAK
   ENDIF
   row + 1, y += 12
   IF (row > 55)
    BREAK
   ENDIF
   col 0, x = 0
   IF (y=24)
    y += 18
   ENDIF
   CALL echo(build("d1.seq x=",x," y = ",y," row = ",
    row," col = ",col)),
   CALL print(calcpos(x,y)), "{color/30}{box/140/2/0}",
   row + 1, y += 12, col 5,
   x = 25, row + 1,
   CALL print(calcpos(x,y)),
   "{cpi/14}{B}Financial Class: {ENDB}", col + 2, "{cpi/16}",
   rules->fin_qual[d.seq].fin_disp, col 75, x = 300,
   CALL print(calcpos(x,y)), "{cpi/14}{B}Encounter Type:  {ENDB}", col + 2,
   "{cpi/16}", rules->fin_qual[d.seq].encntr_qual[d1.seq].encntr_disp, col 0,
   row + 2, y += 24
   IF (row > 55)
    BREAK
   ENDIF
   CALL echo(build("Financial Class: ",rules->fin_qual[d.seq].fin_disp)),
   CALL echo(build("Encounter Type: ",rules->fin_qual[d.seq].encntr_qual[d1.seq].encntr_disp))
  HEAD d2.seq
   col 0, row + 1, y += 12
   IF (row > 55)
    BREAK
   ENDIF
   col 0, x = 25,
   CALL print(calcpos(x,y)),
   "{cpi/14}{B}{u}CPT Code:{endu}{ENDB}", col + 2, "{cpi/16}",
   rules->fin_qual[d.seq].encntr_qual[d1.seq].cpt_qual[d2.seq].cpt_code, row + 1, y += 12
   IF (row > 55)
    BREAK
   ENDIF
   col 0, x = 25,
   CALL print(calcpos(x,y)),
   "{cpi/14}{B}{u}Description:{endu}{ENDB}",
   CALL sub_wrap(rules->fin_qual[d.seq].encntr_qual[d1.seq].cpt_qual[d2.seq].cpt_desc,105), col + 2,
   "{cpi/16}", sub_wrap_rec->qual[1].text, icnt = 0
   FOR (icnt = 2 TO sub_wrap_rec->qual_cnt)
     row + 1, y += 12, col 16,
     x = 100,
     CALL print(calcpos(x,y)), sub_wrap_rec->qual[icnt].text
   ENDFOR
   row + 1, y += 12
   IF (row > 55)
    BREAK
   ENDIF
   col 0, x = 25, "{cpi/16}{B}",
   CALL print(calcpos(x,y)), "{u/8}Excluded", col 40,
   x = 75,
   CALL print(calcpos(x,y)), "{u/9}Diagnosis",
   col 125, x = 300,
   CALL print(calcpos(x,y)),
   "{u/10}Procedures", proc_counter = 0, diag_counter = 0,
   proc_size = size(rules->fin_qual[d.seq].encntr_qual[d1.seq].cpt_qual[d2.seq].proc_qual,5)
  HEAD d3.seq
   CALL echo("---------------------------------head d3.seq"), diag_counter += 1, row + 1,
   y += 12
   IF (row > 55)
    BREAK
   ENDIF
   col 3, x = 35, "{cpi/18}",
   CALL print(calcpos(x,y)), rules->fin_qual[d.seq].encntr_qual[d1.seq].cpt_qual[d2.seq].diag_qual[d3
   .seq].exclude_flag, col 40,
   x = 75,
   CALL print(calcpos(x,y)), rules->fin_qual[d.seq].encntr_qual[d1.seq].cpt_qual[d2.seq].diag_qual[d3
   .seq].diag_code
   IF (cnvtreal(rules->fin_qual[d.seq].encntr_qual[d1.seq].cpt_qual[d2.seq].diag_qual[d3.seq].
    diag_code) > 0.0)
    col 60, x = 100,
    CALL print(calcpos(x,y)),
    rules->fin_qual[d.seq].encntr_qual[d1.seq].cpt_qual[d2.seq].diag_qual[d3.seq].diag_desc
   ELSE
    col 60, x = 75,
    CALL print(calcpos(x,y)),
    rules->fin_qual[d.seq].encntr_qual[d1.seq].cpt_qual[d2.seq].diag_qual[d3.seq].diag_desc
   ENDIF
   IF (proc_size > proc_counter)
    proc_counter += 1, col 125, x = 300,
    CALL print(calcpos(x,y)), rules->fin_qual[d.seq].encntr_qual[d1.seq].cpt_qual[d2.seq].proc_qual[
    proc_counter].proc_disp
   ENDIF
   IF (proc_size=0)
    col 125, x = 300,
    CALL echo(
    "+++++++++++++++++++++++++++++++++++++++++++++++++ proc_size = 0 +++++++++++++++++++++++++++++++++++++++++++++++++"
    ),
    CALL print(calcpos(x,y)), "None", proc_size = - (1)
   ENDIF
  FOOT  d3.seq
   row + 0
  FOOT  d2.seq
   CALL echo("++++++++++++++++++++++++++++++++++"),
   CALL echo(build("proc_size = ",proc_size)),
   CALL echo(build("proc_counter = ",proc_counter)),
   CALL echo(build("diag_counter = ",diag_counter))
   IF (proc_size > proc_counter)
    idx = 0
    FOR (idx = (diag_counter+ 1) TO proc_size)
      CALL echo("========"),
      CALL echo(build("---idx = ",idx)), row + 1,
      y += 12,
      CALL echo(build("y = ",y))
      IF (row > 55)
       BREAK
      ENDIF
      CALL echo(build("y = ",y)), col 150, x = 300,
      CALL print(calcpos(x,y)), "{cpi/18}", rules->fin_qual[d.seq].encntr_qual[d1.seq].cpt_qual[d2
      .seq].proc_qual[idx].proc_disp
    ENDFOR
   ENDIF
   row + 1, y += 12
   IF (row > 55)
    BREAK
   ENDIF
  FOOT  d1.seq
   row + 0
  FOOT  d.seq
   row + 0
  FOOT PAGE
   row 57, y = 742, col 0,
   x = 25,
   CALL print(calcpos(x,y)), "{cpi/18}Page:  ",
   curpage"####", counter = 1
  FOOT REPORT
   col 0, x = 25, row + 1,
   y += 12,
   CALL print(calcpos(x,y)), "{cpi/18}Report Name:",
   sfilename, ".txt", col 150,
   x = 250,
   CALL print(calcpos(x,y)), "{cpi/18}* * * End of Report * * *"
  WITH dio = postscript, compress, outerjoin = d5,
   maxrow = 59, maxcol = 500
 ;end select
 IF (curqual > 0)
  SET reply->report_name = concat("CER_PRINT:",trim(sfilename),".txt")
  CALL echo(build("Report Name:  ",reply->report_name))
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
