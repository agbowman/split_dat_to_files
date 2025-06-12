CREATE PROGRAM dcp_order_sheet2:dba
 RECORD request(
   1 person_id = f8
   1 encntr_id = f8
   1 conversation_id = f8
   1 print_prsnl_id = f8
   1 order_qual[*]
     2 order_id = f8
   1 printer_name = c50
 )
 SET count1 = size(request->order_qual,5)
 RECORD data(
   1 person_id = f8
   1 name_full_formatted = c100
   1 birth_dt_tm = dq8
   1 sex_cd = f8
   1 mrn = c200
   1 cmrn = c200
   1 encntr_id = f8
   1 fin = c200
   1 admit_physcn_name = c100
   1 encntr_type_cd = f8
   1 facility_cd = f8
   1 building_cd = f8
   1 unit_cd = f8
   1 room_cd = f8
   1 bed_cd = f8
   1 admit_dt_tm = dq8
   1 disch_dt_tm = dq8
   1 org_id = f8
   1 org_name = c100
   1 org_addr1 = c100
   1 org_addr2 = c100
   1 org_addr3 = c100
   1 org_addr4 = c100
   1 org_city = c100
   1 org_state_cd = f8
   1 org_zip = c25
   1 org_country_cd = f8
   1 print_prsnl_name = c100
   1 ord_comm_type_cd = f8
   1 ord_entry_prsnl_name = c100
   1 ord_physcn_name = c100
   1 ord_action_dt_tm = dq8
   1 ord_cnt = i4
   1 ord_qual[count1]
     2 ord_mnem = c100
     2 ord_stat_disp = c40
     2 ord_detail = c255
     2 ord_comment_ind = i1
     2 ord_comment = vc
     2 ord_convs_seq = i4
 )
 RECORD outstr(
   1 o_ht = f8
   1 od_ht = f8
   1 oc_ht = f8
   1 o_qual[*]
     2 o_tot_ht = f8
     2 o_str = vc
     2 od_qual[*]
       3 od_str = vc
     2 oc_qual[*]
       3 oc_str = vc
 )
 DECLARE 333_admitdoc = f8 WITH constant(uar_get_code_by("MEANING",333,"ADMITDOC"))
 DECLARE 319_fin_nbr = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE 4_mrn = f8 WITH constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE 4_cmrn = f8 WITH constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE o_str = vc
 DECLARE od_str = vc
 DECLARE oc_str = vc
 DECLARE o_line_len = i2
 DECLARE od_line_len = i2
 DECLARE oc_line_len = i2
 DECLARE doc_max_row = i4
 DECLARE end_msg1_len = i4
 DECLARE end_msg2_len = i4
 DECLARE od_cntr = i4
 DECLARE oc_cntr = i4
 DECLARE od_max_row = i4
 DECLARE oc_max_row = i4
 DECLARE o_ht = i4
 DECLARE od_ht = i4
 DECLARE oc_ht = i4
 DECLARE max_ypos = i4
 DECLARE ypos_strt = i4
 DECLARE xpos_o = i4
 DECLARE xpos_od = i4
 DECLARE xpos_oc = i4
 SET od_max_row = 5
 SET oc_max_row = 5
 SET max_ypos = 630
 SET ypos_strt = 75
 SET xpos_o = 18
 SET xpos_od = 30
 SET xpos_oc = 30
 SET o_line_len = 90
 SET od_line_len = 100
 SET oc_line_len = 100
 SET o_ht = 16
 SET od_ht = 12
 SET oc_ht = 12
 SET doc_max_row = 85
 SET end_msg1 =
 "{f/27}  *** Not all order details displayed.  Check online for full order details. ***"
 SET end_msg1_len = size(trim(end_msg1,3))
 SET end_msg2 = "{f/27}  *** Excessive comment length.  View entire comment online. ***"
 SET end_msg2_len = size(trim(end_msg2,3))
 SET line = fillstring(130,"_")
 SELECT INTO "NL:"
  p1.name_full_formatted, p1.person_id, p1.birth_dt_tm,
  p1.sex_cd, pa1.alias, pa2.alias,
  e.encntr_id, e.loc_facility_cd, e.loc_building_cd,
  e.loc_nurse_unit_cd, e.loc_room_cd, e.loc_bed_cd,
  e.reg_dt_tm, e.disch_dt_tm, e.encntr_type_cd,
  ea1.alias, p2.name_full_formatted, p3.name_full_formatted,
  org.organization_id, org.org_name, adr.street_addr,
  adr.street_addr2, adr.street_addr3, adr.street_addr4,
  adr.city, adr.state_cd, adr.zipcode,
  adr.country
  FROM person p1,
   prsnl p2,
   prsnl p3,
   person_alias pa1,
   person_alias pa2,
   encounter e,
   encntr_alias ea1,
   encntr_prsnl_reltn epr,
   organization org,
   address adr,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1),
   (dummyt d5  WITH seq = 1),
   (dummyt d6  WITH seq = 1),
   (dummyt d7  WITH seq = 1)
  PLAN (p1
   WHERE (p1.person_id=request->person_id))
   JOIN (e
   WHERE e.person_id=p1.person_id
    AND (e.encntr_id=request->encntr_id))
   JOIN (d1)
   JOIN (pa1
   WHERE p1.person_id=pa1.person_id
    AND pa1.person_alias_type_cd=4_mrn)
   JOIN (d2)
   JOIN (pa2
   WHERE p1.person_id=pa2.person_id
    AND pa2.person_alias_type_cd=4_cmrn)
   JOIN (d3)
   JOIN (ea1
   WHERE e.encntr_id=ea1.encntr_id
    AND ea1.encntr_alias_type_cd=319_fin_nbr)
   JOIN (d4)
   JOIN (org
   WHERE e.organization_id=org.organization_id)
   JOIN (d5)
   JOIN (adr
   WHERE e.organization_id=adr.parent_entity_id)
   JOIN (d6)
   JOIN (epr
   WHERE e.encntr_id=epr.encntr_id
    AND epr.encntr_prsnl_r_cd=333_admitdoc)
   JOIN (p2
   WHERE epr.prsnl_person_id=p2.person_id)
   JOIN (d7)
   JOIN (p3
   WHERE (request->print_prsnl_id=p3.person_id))
  DETAIL
   data->person_id = request->person_id, data->name_full_formatted = p1.name_full_formatted, data->
   birth_dt_tm = p1.birth_dt_tm,
   data->sex_cd = p1.sex_cd, data->mrn = pa1.alias, data->cmrn = pa2.alias,
   data->encntr_id = request->encntr_id, data->fin = ea1.alias, data->admit_physcn_name = p2
   .name_full_formatted,
   data->encntr_type_cd = e.encntr_type_cd, data->facility_cd = e.loc_facility_cd, data->building_cd
    = e.loc_building_cd,
   data->unit_cd = e.loc_nurse_unit_cd, data->room_cd = e.loc_room_cd, data->bed_cd = e.loc_bed_cd,
   data->admit_dt_tm = e.reg_dt_tm, data->disch_dt_tm = e.disch_dt_tm, data->org_id = org
   .organization_id,
   data->org_name = org.org_name, data->org_addr1 = adr.street_addr, data->org_addr2 = adr
   .street_addr2,
   data->org_addr3 = adr.street_addr3, data->org_addr4 = adr.street_addr4, data->org_city = adr.city,
   data->org_state_cd = adr.state_cd, data->org_zip = adr.zipcode, data->org_country_cd = adr
   .country_cd,
   data->print_prsnl_name = p3.name_full_formatted
  WITH outerjoin = d1, outerjoin = d2, outerjoin = d3,
   outerjoin = d4, outerjoin = d5, outerjoin = d6,
   outerjoin = d7, dontcare = pa1, dontcare = pa2,
   dontcare = ea1, dontcare = org, dontcare = adr,
   dontcare = epr, dontcare = p2
 ;end select
 FOR (x = 1 TO size(request->order_qual,5))
   SELECT INTO "NL:"
    o.order_mnemonic, o.clinical_display_line, o.order_comment_ind,
    oa.order_status_cd, oa.order_communication_type_cd, oa.order_convs_seq,
    lt.long_text, p1.name_full_formatted, p2.name_full_formatted
    FROM orders o,
     order_action oa,
     order_comment oc,
     long_text lt,
     prsnl p1,
     prsnl p2,
     (dummyt d1  WITH seq = 1),
     (dummyt d2  WITH seq = 1),
     (dummyt d3  WITH seq = 1)
    PLAN (o
     WHERE (o.order_id=request->order_qual[x].order_id)
      AND o.template_order_id=0)
     JOIN (oa
     WHERE oa.order_id=o.order_id
      AND (oa.order_conversation_id=request->conversation_id))
     JOIN (d1)
     JOIN (oc
     WHERE oa.order_id=oc.order_id
      AND oa.action_sequence=oc.action_sequence)
     JOIN (lt
     WHERE oc.long_text_id=lt.long_text_id)
     JOIN (d2)
     JOIN (p1
     WHERE oa.action_personnel_id=p1.person_id)
     JOIN (d3)
     JOIN (p2
     WHERE oa.order_provider_id=p2.person_id)
    HEAD REPORT
     data->ord_entry_prsnl_name = p1.name_full_formatted, data->ord_physcn_name = p2
     .name_full_formatted, data->ord_action_dt_tm = oa.action_dt_tm,
     data->ord_comm_type_cd = oa.communication_type_cd
    DETAIL
     data->ord_qual[x].ord_mnem = o.order_mnemonic, data->ord_qual[x].ord_stat_disp =
     uar_get_code_display(o.order_status_cd), data->ord_qual[x].ord_detail = o.clinical_display_line,
     data->ord_qual[x].ord_comment_ind = o.order_comment_ind, data->ord_qual[x].ord_comment = trim(lt
      .long_text,3), data->ord_qual[x].ord_convs_seq = oa.order_convs_seq,
     data->ord_cnt = x
    WITH outerjoin = d1, outerjoin = d2, outerjoin = d3
   ;end select
 ENDFOR
 SELECT INTO "NL:"
  FROM dummyt d
  DETAIL
   outstr->o_ht = o_ht, outstr->od_ht = od_ht, outstr->oc_ht = oc_ht
   FOR (x = 1 TO size(data->ord_qual,5))
     stat = alterlist(outstr->o_qual,size(data->ord_qual,5)), outstr->o_qual[x].o_str = concat(
      "{CPI/9}{f/9}",trim(data->ord_qual[x].ord_mnem,3),"{CPI/11}{f/24}","  -  ","{CPI/11}{f/24}",
      trim(data->ord_qual[x].ord_stat_disp,3)), outstr->o_qual[x].o_tot_ht = (outstr->o_qual[x].
     o_tot_ht+ (o_ht * 1)),
     od_cntr = 1, source_str = trim(data->ord_qual[x].ord_detail,3), line_len = od_line_len,
     last_time = 0, curr_line_end = 0, last_source_str_brk_pos = 0
     IF (source_str="")
      stat = alterlist(outstr->o_qual[x].od_qual,1), outstr->o_qual[x].od_qual[1].od_str =
      "{f/24}{cpi/11}  *** No order detail. ***"
     ELSE
      WHILE (last_time < 1)
        last_source_str_brk_pos = ((curr_line_end+ 1)+ last_source_str_brk_pos), curr_srch_str = trim
        (substring(last_source_str_brk_pos,line_len,source_str),3)
        IF (((line_len+ (last_source_str_brk_pos - 1)) < size(trim(source_str,3),1)))
         IF (od_cntr >= od_max_row)
          curr_line_end = (findstring(" ",trim(curr_srch_str,3),1,1) - 1), stat = alterlist(outstr->
           o_qual[x].od_qual,od_cntr), outstr->o_qual[x].od_qual[od_cntr].od_str = trim(concat(
            "{f/24}{cpi/11}",substring(last_source_str_brk_pos,(curr_line_end - end_msg1_len),
             source_str),end_msg1,"{f/24}"),3),
          last_time = 1, od_cntr = (od_cntr+ 1)
         ELSE
          curr_line_end = (findstring(" ",trim(curr_srch_str,3),1,1) - 1), stat = alterlist(outstr->
           o_qual[x].od_qual,od_cntr), outstr->o_qual[x].od_qual[od_cntr].od_str = trim(concat(
            "{f/24}{cpi/11}",substring(last_source_str_brk_pos,curr_line_end,source_str)),3),
          last_time = 0, od_cntr = (od_cntr+ 1)
         ENDIF
        ELSE
         IF (size(trim(source_str,3),1) > 253)
          curr_line_end = (findstring(" ",trim(curr_srch_str,3),1,1) - 1), stat = alterlist(outstr->
           o_qual[x].od_qual,od_cntr), outstr->o_qual[x].od_qual[od_cntr].od_str = trim(concat(
            "{f/24}{cpi/11}",substring(last_source_str_brk_pos,(curr_line_end - end_msg1_len),
             source_str),end_msg1,"{f/24}"),3),
          last_time = 1, od_cntr = (od_cntr+ 1)
         ELSE
          curr_line_end = size(trim(curr_srch_str,3),1), stat = alterlist(outstr->o_qual[x].od_qual,
           od_cntr), outstr->o_qual[x].od_qual[od_cntr].od_str = trim(concat("{f/24}{cpi/11}",
            substring(last_source_str_brk_pos,(curr_line_end+ last_source_str_brk_pos),source_str)),3
           ),
          last_time = 1
         ENDIF
        ENDIF
      ENDWHILE
     ENDIF
     outstr->o_qual[x].o_tot_ht = (outstr->o_qual[x].o_tot_ht+ (od_ht * od_cntr)), source_str = "",
     oc_cntr = 1,
     oc_max_row = (oc_max_row+ 1)
     IF ((data->ord_qual[x].ord_comment_ind=1))
      stat = alterlist(outstr->o_qual[x].oc_qual,oc_cntr), outstr->o_qual[x].oc_qual[oc_cntr].oc_str
       = "{cpi/11}{u}Order Comment:{endu}", oc_cntr = (oc_cntr+ 1),
      source_str_vc = trim(data->ord_qual[x].ord_comment,3), line_len = oc_line_len, curr_line_end =
      0,
      last_time = 0, last_source_str_brk_pos = 0
      IF (source_str_vc="")
       stat = alterlist(outstr->o_qual[x].oc_qual,oc_cntr), outstr->o_qual[x].oc_qual[1].oc_str =
       "{f/24}{cpi/11}  *** No order comment. ***", oc_cntr = (oc_cntr+ 1)
      ELSE
       WHILE (last_time < 1)
         last_source_str_brk_pos = ((curr_line_end+ 1)+ last_source_str_brk_pos), curr_srch_str =
         trim(substring(last_source_str_brk_pos,line_len,source_str_vc),3)
         IF (((line_len+ (last_source_str_brk_pos - 1)) < size(trim(source_str_vc,3),1)))
          IF (oc_cntr >= oc_max_row)
           curr_line_end = (findstring(" ",trim(curr_srch_str,3),1,1) - 1), stat = alterlist(outstr->
            o_qual[x].oc_qual,oc_cntr), outstr->o_qual[x].oc_qual[oc_cntr].oc_str = trim(concat(
             substring(last_source_str_brk_pos,(cnvtint(curr_line_end) - cnvtint(end_msg2_len)),
              source_str_vc),end_msg2,"{f/24}"),3),
           last_time = 1, oc_cntr = (oc_cntr+ 1)
          ELSE
           curr_line_end = (findstring(" ",trim(curr_srch_str,3),1,1) - 1), stat = alterlist(outstr->
            o_qual[x].oc_qual,oc_cntr), outstr->o_qual[x].oc_qual[oc_cntr].oc_str = trim(concat(
             "{f/24}{cpi/11}",substring(last_source_str_brk_pos,curr_line_end,source_str_vc)),3),
           last_time = 0, oc_cntr = (oc_cntr+ 1)
          ENDIF
         ELSE
          prnt_line = fillstring(100," "), curr_line_end = size(trim(curr_srch_str,3),1), stat =
          alterlist(outstr->o_qual[x].oc_qual,oc_cntr),
          outstr->o_qual[x].oc_qual[oc_cntr].oc_str = trim(concat("{f/24}{cpi/11}",substring(
             last_source_str_brk_pos,(curr_line_end+ last_source_str_brk_pos),source_str_vc)),3),
          last_time = 1, oc_cntr = (oc_cntr+ 1)
         ENDIF
       ENDWHILE
       oc_cntr = (oc_cntr+ 1)
      ENDIF
     ENDIF
     outstr->o_qual[x].o_tot_ht = (outstr->o_qual[x].o_tot_ht+ (oc_ht * oc_cntr))
   ENDFOR
  WITH counter
 ;end select
 SELECT INTO request->printer_name
  FROM dummyt d
  HEAD REPORT
   age = cnvtage(cnvtdate2(format(data->birth_dt_tm,"MM/DD/YYYY;;D"),"MM/DD/YYYY"),cnvtint(format(
      data->birth_dt_tm,"HHMM;;M"))), sex = substring(1,1,uar_get_code_display(data->sex_cd)),
   unit_room_bed = trim(concat(trim(uar_get_code_display(data->unit_cd),3)," / ",trim(
      uar_get_code_display(data->room_cd),3)," / ",trim(uar_get_code_display(data->bed_cd),3)),3),
   mrn = substring(1,15,data->mrn), cmrn = substring(1,15,data->cmrn), admit_physcn_name = substring(
    1,50,data->admit_physcn_name),
   ord_physcn_name = substring(1,50,data->ord_physcn_name), ord_entry_prsnl_name = substring(1,50,
    data->ord_entry_prsnl_name), pt_name = substring(1,50,data->name_full_formatted),
   encntr_type_disp = substring(1,10,uar_get_code_display(data->encntr_type_cd)), fin = substring(1,
    15,data->fin), facility = substring(1,20,uar_get_code_display(data->facility_cd)),
   building = substring(1,20,uar_get_code_display(data->building_cd)), org_name = substring(1,50,data
    ->org_name), org_address = trim(data->org_addr1,3),
   org_city_st_zip = trim(concat(trim(data->org_city,3),", ",trim(uar_get_code_display(data->
       org_state_cd),3)," ",trim(data->org_zip),
     " ",trim(uar_get_code_display(data->org_country_cd),3)),3), ord_comm_type_disp = substring(1,20,
    uar_get_code_display(data->ord_comm_type_cd)), print_prsnl_name = substring(1,35,data->
    print_prsnl_name),
   ypos = ypos_strt, "{IPC}", row + 1
  HEAD PAGE
   IF (curpage=1)
    "{pos/36/32}{font/9}{CPI/4}", "NEW ORDERS", row + 1
   ENDIF
   "{pos/320/6}{CPI/13}{f/8}", "Ordered by:", row + 1,
   "{pos/320/18}", "Ordered for:", row + 1,
   "{pos/320/30}", "Communication Type:", row + 1,
   "{pos/320/42}", "Order Action Date/Time:", row + 1,
   "{pos/436/6}", ord_entry_prsnl_name, row + 1,
   "{pos/436/18}", ord_physcn_name, row + 1,
   "{pos/436/30}", ord_comm_type_disp, row + 1,
   "{pos/436/42}", ord_action_dt_tm_short = trim(format(data->ord_action_dt_tm,
     "MMM DD, YYYY  HH:MM;;Q"),3), ord_action_dt_tm_short,
   row + 1, "{pos/5/49}{CPI/11}{f/11}", line,
   row + 1, "{pos/198/67}", "NOT A PERMANENT CHART DOCUMENT",
   row + 1, "{pos/5/74}", line,
   row + 1
  DETAIL
   FOR (p = 1 TO size(outstr->o_qual,5))
     IF (((outstr->o_qual[p].o_tot_ht+ ypos) > max_ypos))
      "{pos/306/649}{f/27}{cpi/11}*** cont'd ***", ypos = ypos_strt, BREAK,
      o_str = concat("{pos/",trim(cnvtstring(xpos_o),3),"/",trim(cnvtstring((ypos+ o_ht)),3),"}",
       outstr->o_qual[p].o_str), o_str, row + 1,
      ypos = (ypos+ o_ht)
      FOR (q = 1 TO size(outstr->o_qual[p].od_qual,5))
        od_str = concat("{pos/",trim(cnvtstring(xpos_od),3),"/",trim(cnvtstring((ypos+ od_ht)),3),"}",
         outstr->o_qual[p].od_qual[q].od_str), od_str, row + 1,
        ypos = (ypos+ od_ht)
      ENDFOR
      ypos = (ypos+ od_ht)
      FOR (r = 1 TO size(outstr->o_qual[p].oc_qual,5))
        oc_str = concat("{pos/",trim(cnvtstring(xpos_oc),3),"/",trim(cnvtstring((ypos+ oc_ht)),3),"}",
         outstr->o_qual[p].oc_qual[r].oc_str), oc_str, row + 1,
        ypos = (ypos+ oc_ht)
      ENDFOR
      ypos = (ypos+ oc_ht)
     ELSE
      o_str = concat("{pos/",trim(cnvtstring(xpos_o),3),"/",trim(cnvtstring((ypos+ o_ht)),3),"}",
       outstr->o_qual[p].o_str), o_str, row + 1,
      ypos = (ypos+ o_ht)
      FOR (q = 1 TO size(outstr->o_qual[p].od_qual,5))
        od_str = concat("{pos/",trim(cnvtstring(xpos_od),3),"/",trim(cnvtstring((ypos+ od_ht)),3),"}",
         outstr->o_qual[p].od_qual[q].od_str), od_str, row + 1,
        ypos = (ypos+ od_ht)
      ENDFOR
      ypos = (ypos+ od_ht)
      FOR (r = 1 TO size(outstr->o_qual[p].oc_qual,5))
        oc_str = concat("{pos/",trim(cnvtstring(xpos_oc),3),"/",trim(cnvtstring((ypos+ oc_ht)),3),"}",
         outstr->o_qual[p].oc_qual[r].oc_str), oc_str, row + 1,
        ypos = (ypos+ oc_ht)
      ENDFOR
      ypos = (ypos+ oc_ht)
     ENDIF
   ENDFOR
  FOOT PAGE
   "{pos/5/659}{CPI/11}{f/11}", line, row + 1,
   "{pos/18/671}{CPI/13}{f/8}", "Patient Name:", row + 1,
   "{pos/18/683}", "DOB/Sex/Age:", row + 1,
   "{pos/18/695}", "CMRN/MRN:", row + 1,
   "{pos/18/707}", "Admitting Physician:", row + 1,
   "{pos/18/719}", "Account Number:", row + 1,
   "{pos/18/731}", "Encounter Type:", row + 1,
   "{pos/18/743}", "Unit/Room/Bed:", row + 1,
   "{pos/18/755}", "Admit/Disch Date:", row + 1,
   "{pos/360/671}", "Baystate Health System", row + 1,
   "{pos/360/743}", "Printed by:", row + 1,
   "{pos/360/755}", "Print Dt/Tm:", row + 1,
   "{pos/108/671}{b}", data->name_full_formatted, row + 1,
   "{pos/108/683}{endb}", birth_dt_tm_short = trim(format(data->birth_dt_tm,"MMM DD, YYYY;;Q"),3),
   dob_sex_age_str = concat(birth_dt_tm_short," / ",sex," / ",age),
   dob_sex_age_str, row + 1, "{pos/108/695}",
   cmrn_mrn = concat(trim(cmrn,3)," / ",trim(mrn,3)), cmrn_mrn, row + 1,
   "{pos/108/707}", admit_physcn_name, row + 1,
   "{pos/108/719}", fin, row + 1,
   "{pos/108/731}", encntr_type_disp, row + 1,
   "{pos/108/743}", unit_room_bed, row + 1,
   "{pos/108/755}", admit_disch_dt_tm = concat(trim(format(data->admit_dt_tm,"MMM DD, YYYY;;Q"),3),
    " - ",trim(format(data->disch_dt_tm,"MMM DD, YYYY;;Q"),3)), admit_disch_dt_tm,
   row + 1, "{pos/360/683}", org_name,
   row + 1, "{pos/360/695}", org_address,
   row + 1, "{pos/360/707}", org_city_st_zip,
   row + 1, "{pos/415/743}", print_prsnl_name,
   row + 1, "{pos/415/755}", print_dt_tm_short = trim(format(cnvtdatetime(curdate,curtime),
     "MMM DD, YYYY  HH:MM;;Q"),3),
   print_dt_tm_short, row + 1, "{pos/280/743}",
   page_nbr = concat("Page ",format(curpage,"##;R;I")), page_nbr, row + 1
  FOOT REPORT
   end_str = concat("{pos/280/",trim(cnvtstring((ypos+ od_ht)),3),"}{f/27}{cpi/11}","*** END ***"),
   end_str, "{pos/280/755}{CPI/13}{f/8}LAST"
  WITH counter, dio = 08, maxcol = 12000,
   maxrow = 500
 ;end select
END GO
