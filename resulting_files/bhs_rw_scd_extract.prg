CREATE PROGRAM bhs_rw_scd_extract
 PROMPT
  "   Enter Scd_Story_ID: " = 0.00,
  "      Enter SCD title: " = "",
  "Enter Author username: " = ""
 FREE RECORD work
 RECORD work(
   1 s_cnt = i4
   1 stories[*]
     2 scd_story_id = f8
     2 title = vc
     2 story_type_cd = f8
     2 story_type_disp = vc
     2 shared_ind = c1
     2 author = vc
     2 create_dt_tm = dq8
     2 link_slot = i4
     2 p_cnt = i4
     2 patterns[*]
       3 scr_pattern_id = f8
       3 display = vc
   1 pg_cnt = i4
   1 paragraphs[*]
     2 scd_paragraph_id = f8
     2 scr_paragraph_type_id = f8
     2 paragraph_type = vc
     2 seq_nbr = i4
     2 link_slot = i4
   1 se_cnt = i4
   1 sentences[*]
     2 scd_sentence_id = f8
     2 scd_term_id = f8
     2 seq_nbr = i4
     2 display = vc
     2 truth_state_cd = f8
     2 truth_state_disp = vc
     2 link_slot = i4
     2 d_cnt = i4
     2 data[*]
       3 data_slot = i4
   1 t_cnt = i4
   1 terms[*]
     2 scd_term_id = f8
     2 seq_nbr = i4
     2 display = vc
     2 truth_state_cd = f8
     2 truth_state_disp = vc
     2 link_slot = i4
     2 d_cnt = i4
     2 data[*]
       3 data_slot = i4
   1 d_cnt = i4
   1 data[*]
     2 data_id = f8
     2 data_type_cd = f8
     2 data_type_disp = vc
     2 data_key = vc
     2 fkey_id = f8
     2 fkey_name = vc
     2 num = i4
     2 str = vc
     2 dt_tm = dq8
     2 dt_tm_os = f8
   1 l_cnt = i4
   1 links[*]
     2 parent_link_slot = i4
     2 child_link_slot = i4
     2 my_type = vc
     2 my_slot = i4
     2 depth = i4
     2 complete_ind = i2
     2 c_cnt = i4
     2 children[*]
       3 link_slot = i4
 )
 DECLARE var_scd_story_id = f8
 DECLARE var_scd_title = vc
 DECLARE var_author_id = f8
 IF (cnvtreal( $1) > 0.00)
  SET var_scd_story_id = cnvtreal( $1)
 ENDIF
 IF (trim( $2,3) > " ")
  SET var_scd_title =  $2
 ENDIF
 IF (trim( $3,4) > " ")
  SELECT INTO "NL:"
   pr.person_id
   FROM prsnl pr
   WHERE (pr.username= $3)
   DETAIL
    var_author_id = pr.person_id
   WITH nocounter
  ;end select
 ENDIF
 IF (var_scd_story_id <= 0.00
  AND var_scd_title <= " "
  AND var_author_id <= 0.00)
  CALL echo("No data given. Exitting Script")
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  ss.scd_story_id, ss.title, ss.story_type_cd,
  sp.scr_pattern_id, sp.display
  FROM scd_story ss,
   prsnl pr,
   scd_story_pattern ssp,
   scr_pattern sp
  PLAN (ss
   WHERE ((var_scd_story_id > 0.00
    AND var_scd_story_id=ss.scd_story_id) OR (var_scd_story_id <= 0.00))
    AND ((var_scd_title > " "
    AND ss.title=patstring(var_scd_title)) OR (var_scd_title <= " "))
    AND ((var_author_id > 0.00
    AND ss.active_status_prsnl_id=var_author_id) OR (var_author_id <= 0.00)) )
   JOIN (pr
   WHERE ss.active_status_prsnl_id=pr.person_id)
   JOIN (ssp
   WHERE outerjoin(ss.scd_story_id)=ssp.scd_story_id)
   JOIN (sp
   WHERE outerjoin(ssp.scr_pattern_id)=sp.scr_pattern_id)
  HEAD REPORT
   s_cnt = 0, l_cnt = 0, p_cnt = 0
  HEAD ss.scd_story_id
   s_cnt = (s_cnt+ 1), stat = alterlist(work->stories,s_cnt), work->s_cnt = s_cnt,
   work->stories[s_cnt].scd_story_id = ss.scd_story_id, work->stories[s_cnt].title = ss.title, work->
   stories[s_cnt].story_type_cd = ss.story_type_cd,
   work->stories[s_cnt].story_type_disp = uar_get_code_display(ss.story_type_cd), work->stories[s_cnt
   ].author = pr.name_full_formatted, work->stories[s_cnt].create_dt_tm = ss.active_status_dt_tm
   IF (ss.author_id > 0.00)
    work->stories[s_cnt].shared_ind = "N"
   ELSE
    work->stories[s_cnt].shared_ind = "Y"
   ENDIF
   l_cnt = (work->l_cnt+ 1), stat = alterlist(work->links,l_cnt), work->l_cnt = l_cnt,
   work->links[l_cnt].parent_link_slot = 0, work->links[l_cnt].child_link_slot = 0, work->links[l_cnt
   ].my_type = "S",
   work->links[l_cnt].my_slot = s_cnt, work->links[l_cnt].depth = 0, work->stories[s_cnt].link_slot
    = l_cnt,
   p_cnt = 0
  DETAIL
   p_cnt = (p_cnt+ 1), work->stories[s_cnt].p_cnt = p_cnt, stat = alterlist(work->stories[s_cnt].
    patterns,p_cnt),
   work->stories[s_cnt].patterns[p_cnt].scr_pattern_id = sp.scr_pattern_id, work->stories[s_cnt].
   patterns[p_cnt].display = sp.display
  WITH nocounter
 ;end select
 IF ((work->stories[1].scd_story_id=0.00))
  CALL echo("Story not found.  Exitting Script")
  GO TO exit_script
 ENDIF
 DECLARE cnt_s_e = i4
 DECLARE cnt_s_l = i4
 SELECT INTO "NL:"
  sp.scd_paragraph_id, sp.scr_paragraph_type_id, spt.display,
  sp.sequence_number, ss.scd_sentence_id, ss.sequence_number,
  st.scd_term_id, st.truth_state_cd, stt.display,
  std.scd_term_data_id, std.scd_term_data_type_cd, std.scd_term_data_key,
  std.fkey_id, std.fkey_entity_name, std.value_number,
  std.value_text, std.value_dt_tm, std.value_dt_tm_os
  FROM scd_paragraph sp,
   scr_paragraph_type spt,
   scd_sentence ss,
   scd_term st,
   scr_term_text stt,
   scd_term_data std
  PLAN (sp
   WHERE expand(cnt_s_e,1,work->s_cnt,sp.scd_story_id,work->stories[cnt_s_e].scd_story_id))
   JOIN (spt
   WHERE sp.scr_paragraph_type_id=spt.scr_paragraph_type_id)
   JOIN (ss
   WHERE sp.scd_story_id=ss.scd_story_id
    AND sp.scd_paragraph_id=ss.scd_paragraph_id)
   JOIN (st
   WHERE ss.scd_sentence_id=st.scd_sentence_id
    AND st.parent_scd_term_id=0.00)
   JOIN (stt
   WHERE st.scr_term_id=stt.scr_term_id)
   JOIN (std
   WHERE outerjoin(st.scd_term_data_id)=std.scd_term_data_id)
  ORDER BY sp.sequence_number, ss.sequence_number, st.sequence_number
  HEAD REPORT
   d_cnt = 0, s_cnt = 0, s_l_cnt = 0,
   pg_cnt = 0, pg_l_cnt = 0, se_cnt = 0,
   se_d_cnt = 0
  HEAD sp.scd_paragraph_id
   pg_cnt = (pg_cnt+ 1), stat = alterlist(work->paragraphs,pg_cnt), work->pg_cnt = pg_cnt,
   work->paragraphs[pg_cnt].scd_paragraph_id = sp.scd_paragraph_id, work->paragraphs[pg_cnt].
   scr_paragraph_type_id = spt.scr_paragraph_type_id, work->paragraphs[pg_cnt].paragraph_type = spt
   .display,
   work->paragraphs[pg_cnt].seq_nbr = sp.sequence_number, s_cnt = locateval(cnt_s_l,1,work->s_cnt,sp
    .scd_story_id,work->stories[cnt_s_l].scd_story_id), s_l_cnt = work->stories[s_cnt].link_slot,
   pg_l_cnt = (work->l_cnt+ 1), stat = alterlist(work->links,pg_l_cnt), work->l_cnt = pg_l_cnt,
   work->links[pg_l_cnt].parent_link_slot = s_l_cnt, work->links[pg_l_cnt].child_link_slot = (work->
   links[s_l_cnt].c_cnt+ 1), work->links[pg_l_cnt].my_type = "PG",
   work->links[pg_l_cnt].my_slot = pg_cnt, work->links[pg_l_cnt].depth = (work->links[s_l_cnt].depth
   + 1), work->paragraphs[pg_cnt].link_slot = pg_l_cnt,
   work->links[s_l_cnt].c_cnt = (work->links[s_l_cnt].c_cnt+ 1), stat = alterlist(work->links[s_l_cnt
    ].children,work->links[s_l_cnt].c_cnt), work->links[s_l_cnt].children[work->links[s_l_cnt].c_cnt]
   .link_slot = pg_l_cnt
  HEAD ss.scd_sentence_id
   se_cnt = (work->se_cnt+ 1), stat = alterlist(work->sentences,se_cnt), work->se_cnt = se_cnt,
   work->sentences[se_cnt].scd_sentence_id = ss.scd_sentence_id, work->sentences[se_cnt].scd_term_id
    = st.scd_term_id, work->sentences[se_cnt].seq_nbr = ss.sequence_number,
   work->sentences[se_cnt].truth_state_cd = st.truth_state_cd, work->sentences[se_cnt].
   truth_state_disp = uar_get_code_display(st.truth_state_cd)
   IF (trim(stt.display) > " ")
    work->sentences[se_cnt].display = trim(stt.display)
   ELSE
    work->sentences[se_cnt].display = "<blank>"
   ENDIF
   se_l_cnt = (work->l_cnt+ 1), stat = alterlist(work->links,se_l_cnt), work->l_cnt = se_l_cnt,
   work->links[se_l_cnt].parent_link_slot = pg_l_cnt, work->links[se_l_cnt].child_link_slot = (work->
   links[pg_l_cnt].c_cnt+ 1), work->links[se_l_cnt].my_type = "SE",
   work->links[se_l_cnt].my_slot = se_cnt, work->links[se_l_cnt].depth = (work->links[pg_l_cnt].depth
   + 1), work->sentences[se_cnt].link_slot = se_l_cnt,
   work->links[pg_l_cnt].c_cnt = (work->links[pg_l_cnt].c_cnt+ 1), stat = alterlist(work->links[
    pg_l_cnt].children,work->links[pg_l_cnt].c_cnt), work->links[pg_l_cnt].children[work->links[
   pg_l_cnt].c_cnt].link_slot = se_l_cnt
  DETAIL
   IF (std.scd_term_data_id > 0.00)
    d_cnt = (work->d_cnt+ 1), stat = alterlist(work->data,d_cnt), work->d_cnt = d_cnt,
    work->data[d_cnt].data_id = std.scd_term_data_id, work->data[d_cnt].data_type_cd = std
    .scd_term_data_type_cd, work->data[d_cnt].data_type_disp = uar_get_code_display(std
     .scd_term_data_type_cd),
    work->data[d_cnt].data_key = std.scd_term_data_key, work->data[d_cnt].fkey_id = std.fkey_id, work
    ->data[d_cnt].fkey_name = std.fkey_entity_name,
    work->data[d_cnt].num = std.value_number, work->data[d_cnt].str = std.value_text, work->data[
    d_cnt].dt_tm = std.value_dt_tm,
    work->data[d_cnt].dt_tm_os = std.value_dt_tm_os, se_d_cnt = (work->sentences[se_cnt].d_cnt+ 1),
    stat = alterlist(work->sentences[se_cnt].data,se_d_cnt),
    work->sentences[se_cnt].d_cnt = se_d_cnt, work->sentences[se_cnt].data[se_d_cnt].data_slot =
    d_cnt
   ENDIF
  WITH nocounter
 ;end select
 FREE SET cnt_s_e
 FREE SET cnt_s_l
 DECLARE cnt_se_e = i4
 DECLARE cnt_se_l = i4
 SELECT INTO "NL:"
  st.scd_term_id, st.scr_term_id, st.scd_term_data_id,
  st.sequence_number, stt.display, std.scd_term_data_type_cd,
  std.scd_term_data_key, std.fkey_id, std.fkey_entity_name,
  std.value_number, std.value_dt_tm, std.value_dt_tm_os,
  std.value_text
  FROM scd_term st,
   scr_term_text stt,
   scd_term_data std
  PLAN (st
   WHERE expand(cnt_se_e,1,work->se_cnt,st.parent_scd_term_id,work->sentences[cnt_se_e].scd_term_id))
   JOIN (stt
   WHERE st.scr_term_id=stt.scr_term_id)
   JOIN (std
   WHERE outerjoin(st.scd_term_data_id)=std.scd_term_data_id)
  ORDER BY st.sequence_number
  HEAD REPORT
   d_cnt = 0, se_cnt = 0, se_l_cnt = 0,
   t_cnt = 0, t_l_cnt = 0, t_d_cnt = 0
  HEAD st.scd_term_id
   t_cnt = (work->t_cnt+ 1), stat = alterlist(work->terms,t_cnt), work->t_cnt = t_cnt,
   work->terms[t_cnt].scd_term_id = st.scd_term_id, work->terms[t_cnt].seq_nbr = st.sequence_number,
   work->terms[t_cnt].truth_state_cd = st.truth_state_cd,
   work->terms[t_cnt].truth_state_disp = uar_get_code_display(st.truth_state_cd)
   IF (trim(stt.display,3) > " ")
    work->terms[t_cnt].display = stt.display
   ELSE
    work->terms[t_cnt].display = "<blank>"
   ENDIF
   se_cnt = locateval(cnt_se_l,1,work->se_cnt,st.parent_scd_term_id,work->sentences[cnt_se_l].
    scd_term_id), se_l_cnt = work->sentences[se_cnt].link_slot, t_l_cnt = (work->l_cnt+ 1),
   stat = alterlist(work->links,t_l_cnt), work->l_cnt = t_l_cnt, work->links[t_l_cnt].
   parent_link_slot = se_l_cnt,
   work->links[t_l_cnt].child_link_slot = (work->links[se_l_cnt].c_cnt+ 1), work->links[t_l_cnt].
   my_type = "T", work->links[t_l_cnt].my_slot = t_cnt,
   work->links[t_l_cnt].depth = (work->links[se_l_cnt].depth+ 1), work->terms[t_cnt].link_slot =
   t_l_cnt, work->links[se_l_cnt].c_cnt = (work->links[se_l_cnt].c_cnt+ 1),
   stat = alterlist(work->links[se_l_cnt].children,work->links[se_l_cnt].c_cnt), work->links[se_l_cnt
   ].children[work->links[se_l_cnt].c_cnt].link_slot = t_l_cnt
  DETAIL
   IF (std.scd_term_data_id > 0.00)
    d_cnt = (work->d_cnt+ 1), stat = alterlist(work->data,d_cnt), work->d_cnt = d_cnt,
    work->data[d_cnt].data_id = std.scd_term_data_id, work->data[d_cnt].data_type_cd = std
    .scd_term_data_type_cd, work->data[d_cnt].data_type_disp = uar_get_code_display(std
     .scd_term_data_type_cd),
    work->data[d_cnt].data_key = std.scd_term_data_key, work->data[d_cnt].fkey_id = std.fkey_id, work
    ->data[d_cnt].fkey_name = std.fkey_entity_name,
    work->data[d_cnt].num = std.value_number, work->data[d_cnt].str = std.value_text, work->data[
    d_cnt].dt_tm = std.value_dt_tm,
    work->data[d_cnt].dt_tm_os = std.value_dt_tm_os, t_d_cnt = (work->terms[t_cnt].d_cnt+ 1), stat =
    alterlist(work->terms[t_cnt].data,t_d_cnt),
    work->terms[t_cnt].d_cnt = t_d_cnt, work->terms[t_cnt].data[t_d_cnt].data_slot = d_cnt
   ENDIF
  WITH nocounter
 ;end select
 FREE SET cnt_se_e
 FREE SET cnt_se_l
 DECLARE tmp_t_cnt = i4
 DECLARE delayed_t_cnt = i4
 SET tmp_t_cnt = - (1)
 SET delayed_t_cnt = work->t_cnt
 WHILE ((tmp_t_cnt < work->t_cnt))
   IF ((tmp_t_cnt > - (1)))
    SET tmp_t_cnt = delayed_t_cnt
   ENDIF
   SET delayed_t_cnt = work->t_cnt
   SELECT INTO "NL:"
    st.scd_term_id, st.scr_term_id, st.scd_term_data_id,
    st.sequence_number, stt.display, std.scd_term_data_type_cd,
    std.scd_term_data_key, std.fkey_id, std.fkey_entity_name,
    std.value_number, std.value_dt_tm, std.value_dt_tm_os,
    std.value_text
    FROM (dummyt d  WITH seq = value(work->t_cnt)),
     scd_term st,
     scr_term_text stt,
     scd_term_data std
    PLAN (d
     WHERE d.seq > tmp_t_cnt)
     JOIN (st
     WHERE (work->terms[d.seq].scd_term_id=st.parent_scd_term_id))
     JOIN (stt
     WHERE st.scr_term_id=stt.scr_term_id)
     JOIN (std
     WHERE outerjoin(st.scd_term_data_id)=std.scd_term_data_id)
    ORDER BY d.seq, st.sequence_number
    HEAD REPORT
     d_cnt = 0, t_cnt = 0, t_pl_cnt = 0,
     t_cl_cnt = 0, t_d_cnt = 0
    HEAD st.scd_term_id
     t_cnt = (work->t_cnt+ 1), stat = alterlist(work->terms,t_cnt), work->t_cnt = t_cnt,
     work->terms[t_cnt].scd_term_id = st.scd_term_id, work->terms[t_cnt].seq_nbr = st.sequence_number,
     work->terms[t_cnt].truth_state_cd = st.truth_state_cd,
     work->terms[t_cnt].truth_state_disp = uar_get_code_display(st.truth_state_cd)
     IF (trim(stt.display,3) > " ")
      work->terms[t_cnt].display = stt.display
     ELSE
      work->terms[t_cnt].display = "<blank>"
     ENDIF
     t_pl_cnt = work->terms[d.seq].link_slot, t_cl_cnt = (work->l_cnt+ 1), stat = alterlist(work->
      links,t_cl_cnt),
     work->l_cnt = t_cl_cnt, work->links[t_cl_cnt].parent_link_slot = t_pl_cnt, work->links[t_cl_cnt]
     .child_link_slot = (work->links[t_pl_cnt].c_cnt+ 1),
     work->links[t_cl_cnt].my_type = "T", work->links[t_cl_cnt].my_slot = t_cnt, work->links[t_cl_cnt
     ].depth = (work->links[t_pl_cnt].depth+ 1),
     work->terms[t_cnt].link_slot = t_cl_cnt, work->links[t_pl_cnt].c_cnt = (work->links[t_pl_cnt].
     c_cnt+ 1), stat = alterlist(work->links[t_pl_cnt].children,work->links[t_pl_cnt].c_cnt),
     work->links[t_pl_cnt].children[work->links[t_pl_cnt].c_cnt].link_slot = t_cl_cnt
    DETAIL
     IF (std.scd_term_data_id > 0.00)
      d_cnt = (work->d_cnt+ 1), stat = alterlist(work->data,d_cnt), work->d_cnt = d_cnt,
      work->data[d_cnt].data_id = std.scd_term_data_id, work->data[d_cnt].data_type_cd = std
      .scd_term_data_type_cd, work->data[d_cnt].data_type_disp = uar_get_code_display(std
       .scd_term_data_type_cd),
      work->data[d_cnt].data_key = std.scd_term_data_key, work->data[d_cnt].fkey_id = std.fkey_id,
      work->data[d_cnt].fkey_name = std.fkey_entity_name,
      work->data[d_cnt].num = std.value_number, work->data[d_cnt].str = std.value_text, work->data[
      d_cnt].dt_tm = std.value_dt_tm,
      work->data[d_cnt].dt_tm_os = std.value_dt_tm_os, t_d_cnt = (work->terms[t_cnt].d_cnt+ 1), stat
       = alterlist(work->terms[t_cnt].data,t_d_cnt),
      work->terms[t_cnt].d_cnt = t_d_cnt, work->terms[t_cnt].data[t_d_cnt].data_slot = d_cnt
     ENDIF
    WITH nocounter
   ;end select
   IF ((tmp_t_cnt <= - (1)))
    SET tmp_t_cnt = delayed_t_cnt
   ENDIF
 ENDWHILE
 SELECT INTO "ryan_scd_extract_doc"
  FROM dummyt d
  HEAD REPORT
   indent_size = 4, tmp_indent = 0, print_header = 1,
   tmp_d_slot = 0,
   MACRO (print_story_info)
    col 0, "Story Info", row + 1,
    col 0, "Story_ID,Story Title,Story Type,Author,Shared,Create Date/Time", row + 1,
    col 0,
    CALL print(build2(work->stories[cur_my_slot].scd_story_id,",",'"',work->stories[cur_my_slot].
     title,'",',
     '"',work->stories[cur_my_slot].story_type_disp,'",','"',work->stories[cur_my_slot].author,
     '",','"',work->stories[cur_my_slot].shared_ind,'",',format(work->stories[cur_my_slot].
      create_dt_tm,"MM/DD/YYYY HH:MM;;D"))), row + 3
    IF ((work->stories[cur_my_slot].p_cnt <= 0))
     col 0, "Pattern Info,No pattern data found"
    ELSE
     col 0, "Pattern Info", row + 1,
     col 0, "Pattern_ID,Pattern Display"
     FOR (p = 1 TO work->stories[cur_my_slot].p_cnt)
       row + 1, col 0,
       CALL print(build2(work->stories[cur_my_slot].patterns[p].scr_pattern_id,",",'"',work->stories[
        cur_my_slot].patterns[p].display,'"'))
     ENDFOR
    ENDIF
    row + 3
   ENDMACRO
   ,
   MACRO (print_paragraph_info)
    IF (print_header=1)
     print_header = 0, col 0, "Layout & Data",
     row + 1, col 0, "Level,Display,Seq Nbr,Paragraph ID,Sentence ID,Term ID, Truth State,",
     col + 0, "Data Type,Data Key,FKEY ID,FKEY Name,Numeric Value,Date Value,Text Value"
    ENDIF
    row + 1, col 0, 'Paragraph,"',
    tmp_indent = (indent_size * work->links[cur_link_slot].depth), col + tmp_indent,
    CALL print(build2(work->paragraphs[cur_my_slot].paragraph_type,'",',work->paragraphs[cur_my_slot]
     .seq_nbr,",",work->paragraphs[cur_my_slot].scd_paragraph_id))
   ENDMACRO
   ,
   MACRO (print_sentence_info)
    row + 1, col 0, 'Sentence,"',
    tmp_indent = (indent_size * work->links[cur_link_slot].depth), col + tmp_indent,
    CALL print(build2(work->sentences[cur_my_slot].display,'",',work->sentences[cur_my_slot].seq_nbr,
     ",",",",
     work->sentences[cur_my_slot].scd_sentence_id,",",",",'"',work->sentences[cur_my_slot].
     truth_state_disp,
     '"'))
    IF ((work->sentences[cur_my_slot].d_cnt > 0))
     FOR (d = 1 TO work->sentences[cur_my_slot].d_cnt)
       IF (d=1)
        col + 0, ","
       ELSE
        row + 1, col 0, ",,,,,,,"
       ENDIF
       tmp_d_slot = work->sentences[cur_my_slot].data[d].data_slot, print_data_info
     ENDFOR
    ENDIF
   ENDMACRO
   ,
   MACRO (print_term_info)
    row + 1, col 0, 'Term,"',
    tmp_indent = (indent_size * work->links[cur_link_slot].depth), col + tmp_indent,
    CALL print(build2(work->terms[cur_my_slot].display,'",',work->terms[cur_my_slot].seq_nbr,",",",,",
     work->terms[cur_my_slot].scd_term_id,",",'"',work->terms[cur_my_slot].truth_state_disp,'"'))
    IF ((work->terms[cur_my_slot].d_cnt > 0))
     FOR (d = 1 TO work->terms[cur_my_slot].d_cnt)
       IF (d=1)
        col + 0, ","
       ELSE
        row + 1, col 0, ",,,,,,,"
       ENDIF
       tmp_d_slot = work->terms[cur_my_slot].data[d].data_slot, print_data_info
     ENDFOR
    ENDIF
   ENDMACRO
   ,
   MACRO (print_data_info)
    col + 0,
    CALL print(build2('"',work->data[tmp_d_slot].data_type_disp,'",','"',work->data[tmp_d_slot].
     data_key,
     '",',work->data[tmp_d_slot].fkey_id,",",'"',work->data[tmp_d_slot].fkey_name,
     '",',work->data[tmp_d_slot].num,",",format(work->data[tmp_d_slot].dt_tm,"MM/DD/YYYY HH:MM:SS;;D"
      ),",",
     '"',work->data[tmp_d_slot].str,'"'))
   ENDMACRO
  DETAIL
   FOR (s = 1 TO work->s_cnt)
     IF (s > 1)
      row + 3
     ENDIF
     print_header = 1, cur_s_link_slot = work->stories[s].link_slot, cur_link_slot = work->stories[s]
     .link_slot,
     cur_parent_slot = work->links[cur_link_slot].parent_link_slot, cur_child_slot = work->links[
     cur_link_slot].child_link_slot
     WHILE ((work->links[cur_link_slot].complete_ind=0))
       cur_my_slot = work->links[cur_link_slot].my_slot
       CASE (work->links[cur_link_slot].my_type)
        OF "S":
         print_story_info
        OF "PG":
         print_paragraph_info
        OF "SE":
         print_sentence_info
        OF "T":
         print_term_info
       ENDCASE
       IF ((work->links[cur_link_slot].c_cnt > 0))
        cur_link_slot = work->links[cur_link_slot].children[1].link_slot, cur_parent_slot = work->
        links[cur_link_slot].parent_link_slot, cur_child_slot = work->links[cur_link_slot].
        child_link_slot
       ELSE
        work->links[cur_link_slot].complete_ind = 1
        WHILE ((work->links[cur_link_slot].complete_ind=1)
         AND cur_link_slot != cur_s_link_slot)
          IF ((work->links[cur_parent_slot].c_cnt <= cur_child_slot))
           work->links[cur_parent_slot].complete_ind = 1, cur_link_slot = cur_parent_slot,
           cur_parent_slot = work->links[cur_link_slot].parent_link_slot,
           cur_child_slot = work->links[cur_link_slot].child_link_slot
          ELSE
           cur_link_slot = work->links[cur_parent_slot].children[(cur_child_slot+ 1)].link_slot,
           cur_parent_slot = work->links[cur_link_slot].parent_link_slot, cur_child_slot = work->
           links[cur_link_slot].child_link_slot
          ENDIF
        ENDWHILE
       ENDIF
     ENDWHILE
   ENDFOR
  WITH nocounter, maxrec = 1, maxcol = 32000,
   format = variable, formfeed = none
 ;end select
 CALL echorecord(work,"ryan_scd_extract_rs.dat")
#exit_script
END GO
