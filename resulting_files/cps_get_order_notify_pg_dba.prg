CREATE PROGRAM cps_get_order_notify_pg:dba
 SET modify = predeclare
 DECLARE ms_caused_clause = vc WITH protect, noconstant("")
 DECLARE ms_type_clause = vc WITH protect, noconstant("")
 DECLARE ms_n_search_clause = vc WITH protect, noconstant("")
 DECLARE ms_e_search_clause = vc WITH protect, noconstant("")
 DECLARE ms_p_search_clause = vc WITH protect, noconstant("")
 DECLARE ms_start_at_clause = vc WITH protect, noconstant("")
 DECLARE ms_inner_order_clause = vc WITH protect, noconstant("")
 DECLARE ms_outer_order_clause = vc WITH protect, noconstant("")
 DECLARE ms_select_statement = vc WITH protect, noconstant("")
 DECLARE ms_out_select_statement = vc WITH protect, noconstant("")
 DECLARE ms_primary_column = vc WITH protect, noconstant(" ")
 DECLARE md_date_limit = q8 WITH protect, noconstant
 DECLARE ms_echo_line = vc WITH protect, noconstant(fillstring(80,"-"))
 DECLARE mn_error_ind = i1 WITH protect, noconstant(0)
 DECLARE pn_stat = i1 WITH protect, noconstant(0)
 DECLARE max_nknt = i4 WITH public, noconstant(0)
 DECLARE iknt = i4 WITH public, noconstant(0)
 DECLARE causedbycnt = i4 WITH public, noconstant(0)
 DECLARE typecnt = i4 WITH public, noconstant(0)
 DECLARE nknt = i4 WITH public, noconstant(0)
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE ord_comment_cd = f8 WITH public, noconstant(0.0)
 DECLARE pharmacy_cd = f8 WITH public, noconstant(0.0)
 DECLARE intermittent_cd = f8 WITH public, noconstant(0.0)
 DECLARE soft_stop_cd = f8 WITH public, noconstant(0.0)
 DECLARE hard_stop_cd = f8 WITH public, noconstant(0.0)
 DECLARE doctor_stop_cd = f8 WITH public, noconstant(0.0)
 DECLARE ordered_cd = f8 WITH public, noconstant(0.0)
 DECLARE stat = i2 WITH public, noconstant(0)
 DECLARE x = i2 WITH protect, noconstant(0)
 DECLARE y = i2 WITH protect, noconstant(0)
 DECLARE z = i2 WITH protect, noconstant(0)
 DECLARE find_renew = i2 WITH protect, noconstant(0)
 DECLARE find_non_renew = i2 WITH protect, noconstant(0)
 DECLARE use_prsnl_table = i2 WITH protect, noconstant(0)
 DECLARE use_person_table = i2 WITH protect, noconstant(0)
 DECLARE ms_sort_join_clause = vc WITH protect, noconstant("")
 IF (validate(mn_debug_flag)=0)
  DECLARE mn_debug_flag = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(mn_col_type_string)=0)
  DECLARE mn_col_type_string = i2 WITH protect, constant(1)
  DECLARE mn_col_type_integer = i2 WITH protect, constant(2)
  DECLARE mn_col_type_double = i2 WITH protect, constant(3)
  DECLARE mn_col_type_date = i2 WITH protect, constant(4)
  DECLARE mn_direction_forward = i2 WITH protect, constant(1)
  DECLARE mn_direction_backward = i2 WITH protect, constant(2)
 ENDIF
 DECLARE sbr_get_primary_column_info(ps_primary_column=vc(ref)) = i1
 DECLARE sbr_build_caused_by_clause(ps_caused_clause=vc(ref)) = i1
 DECLARE sbr_build_type_clause(ps_type_clause=vc(ref)) = i1
 DECLARE sbr_create_n_search_clause(ps_on_search_clause=vc(ref)) = i1
 DECLARE sbr_create_e_search_clause(ps_e_search_clause=vc(ref)) = i1
 DECLARE sbr_create_p_search_clause(ps_p_search_clause=vc(ref)) = i1
 DECLARE sbr_create_order_clause(ps_inner_order_clause=vc(ref),ps_outer_order_clause=vc(ref)) = i1
 DECLARE sbr_create_start_at_clause(ps_start_at_clause=vc(ref)) = i1
 DECLARE sbr_check_error(ps_operation_name=vc) = i1
 RECORD internal(
   1 qual[*]
     2 order_notification_id = f8
     2 name_last_key = vc
 )
 SET code_set = 14
 SET cdf_meaning = "ORD COMMENT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,ord_comment_cd)
 IF (sbr_check_error("ORD COMMENT error")=1)
  GO TO exit_program
 ENDIF
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,pharmacy_cd)
 IF (sbr_check_error("PHARMACY CD error")=1)
  GO TO exit_program
 ENDIF
 SET code_set = 18309
 SET cdf_meaning = "INTERMITTENT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,intermittent_cd)
 IF (sbr_check_error("INTERMITTENT CD error")=1)
  GO TO exit_program
 ENDIF
 SET code_set = 4009
 SET cdf_meaning = "SOFT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,soft_stop_cd)
 IF (sbr_check_error("SOFT cd error")=1)
  GO TO exit_program
 ENDIF
 SET code_set = 4009
 SET cdf_meaning = "HARD"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,hard_stop_cd)
 IF (sbr_check_error("HARD cd error")=1)
  GO TO exit_program
 ENDIF
 SET code_set = 4009
 SET cdf_meaning = "DRSTOP"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,doctor_stop_cd)
 IF (sbr_check_error("doctor_stop_cd error")=1)
  GO TO exit_program
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,ordered_cd)
 IF (sbr_check_error("ordered_cd error")=1)
  GO TO exit_program
 ENDIF
 IF (validate(reply->page_context.n_more_ind)=0)
  RECORD reply(
    1 page_context
      2 n_more_ind = i2
    1 notification[*]
      2 order_notification_id = f8
      2 action_sequence = i4
      2 from_prsnl_id = f8
      2 notification_type_flag = i4
      2 notification_dt_tm = dq8
      2 caused_by_flag = i4
      2 notification_reason_cd = f8
      2 notification_reason_disp = c40
      2 notification_comment = vc
      2 notification_status_flag = i4
      2 status_change_dt_tm = dq8
      2 order_id = f8
      2 encntr_id = f8
      2 order_action_type_cd = f8
      2 order_action_type_disp = c40
      2 loc_facility_cd = f8
      2 last_updt_cnt = i4
      2 last_action_seq = i4
      2 last_ingred_action_seq = i4
      2 found_originator = i2
      2 oe_format_id = f8
      2 person_id = f8
      2 name_last_key = vc
      2 order_status_cd = f8
      2 drug_ingred_knt = i4
      2 drug_ingred[*]
        3 catalog_cd = f8
        3 cki = vc
        3 source_identifier = vc
        3 source_vocab_mean = vc
      2 orig_order_dt_tm = dq8
      2 orig_order_tz = i4
      2 stop_type_cd = f8
      2 projected_stop_dt_tm = dq8
      2 clinical_display_line = vc
      2 hna_order_mnemonic = vc
      2 ordered_as_mnemonic = vc
      2 order_mnemonic = vc
      2 med_order_type_cd = f8
      2 additive_count_for_ivpb = i4
      2 ingredient[*]
        3 hna_order_mnemonic = vc
        3 order_mnemonic = vc
        3 ordered_as_mnemonic = vc
        3 ingredient_type_flag = i2
        3 strength = f8
        3 strength_unit = f8
        3 volume = f8
        3 volume_unit = f8
        3 freetext_dose = vc
        3 freq_cd = f8
      2 catalog_cd = f8
      2 catalog_type_cd = f8
      2 originator_id = f8
      2 get_comment_ind = i2
      2 order_comment = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD ilist
 RECORD ilist(
   1 qual_knt = i4
   1 qual[*]
     2 n_index = i4
     2 order_id = i4
     2 action_sequence = i2
 )
 SET pn_stat = initrec(reply)
 IF (mn_debug_flag=1)
  CALL echorecord(request)
 ENDIF
 IF (sbr_get_primary_column_info(ms_primary_column)=0)
  GO TO exit_program
 ENDIF
 IF (sbr_build_caused_by_clause(ms_caused_clause)=0)
  GO TO exit_program
 ENDIF
 IF (sbr_build_type_clause(ms_type_clause)=0)
  GO TO exit_program
 ENDIF
 IF (sbr_create_n_search_clause(ms_n_search_clause)=0)
  GO TO exit_program
 ENDIF
 IF (sbr_create_e_search_clause(ms_e_search_clause)=0)
  GO TO exit_program
 ENDIF
 IF (sbr_create_p_search_clause(ms_p_search_clause)=0)
  GO TO exit_program
 ENDIF
 IF (sbr_create_start_at_clause(ms_start_at_clause)=0)
  GO TO exit_program
 ENDIF
 IF (sbr_create_order_clause(ms_inner_order_clause,ms_outer_order_clause)=0)
  GO TO exit_program
 ENDIF
 IF (mn_debug_flag=1)
  CALL echo(ms_echo_line)
  CALL echo("ms_caused_clause: ")
  CALL echo(ms_caused_clause)
  CALL echo("ms_type_clause: ")
  CALL echo(ms_type_clause)
  CALL echo("ms_n_search_clause: ")
  CALL echo(ms_n_search_clause)
  CALL echo(ms_echo_line)
  CALL echo("ms_start_at_clause: ")
  CALL echo(ms_start_at_clause)
  CALL echo(ms_echo_line)
  CALL echo(ms_echo_line)
  CALL echo("ms_inner_order_clause: ")
  CALL echo(ms_inner_order_clause)
  CALL echo("ms_outer_order_clause: ")
  CALL echo(ms_outer_order_clause)
  CALL echo(ms_echo_line)
 ENDIF
 SET ms_select_statement = concat(" select into 'nl:'"," from ","   ((select ",
  "         pn_row_number = row_number() over (order by ",ms_inner_order_clause,
  ")","         ,n.order_notification_id ","         ,n.notification_dt_tm ")
 IF (use_person_table=1)
  SET ms_select_statement = concat(ms_select_statement,", p.name_last_key, p.name_first_key ",
   ", fullname = concat(trim(p.name_last_key),',', trim(p.name_first_key)) ")
 ELSEIF (use_prsnl_table=1)
  SET ms_select_statement = concat(ms_select_statement,", pr.name_last_key, pr.name_first_key ",
   ", fullname = concat(trim(pr.name_last_key),',', trim(pr.name_first_key)) ")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"       from order_notification n ",
  "       , orders o ","		 , order_catalog oc ","       , encounter e ",
  "		 , person p ")
 IF (use_prsnl_table=1)
  SET ms_select_statement = concat(ms_select_statement,", prsnl pr ")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"        where (",ms_n_search_clause,")",
  "          and (",
  ms_e_search_clause,")","          and (",ms_p_search_clause,")",
  "          and (",ms_start_at_clause,")","       with sqltype('F8' ","                    ,'F8' ",
  "                    ,'DQ8' ")
 IF (((use_person_table=1) OR (use_prsnl_table)) )
  SET ms_select_statement = concat(ms_select_statement,",'VC', 'VC', 'VC' ")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"                    )) a) ",
  " where pn_row_number <= request->page_context->directives->n_page_size + 1"," order by ",
  ms_outer_order_clause,
  " head report ","   pn_notify_cnt = 0 "," 	 init = 0 "," detail ",
  "	if(pn_notify_cnt < request->page_context->directives->n_page_size) ",
  "		if (a.pn_row_number > request->page_context->directives->n_page_size ",
  "				and request->page_context->directives->n_page_direction = 2 ","				and init = 0 )",
  "			init = 1 "," 			reply->page_context->n_more_ind = 1 ",
  "		else ","   	pn_notify_cnt = pn_notify_cnt + 1 ",
  "   	if (pn_notify_cnt > size(internal->qual,5)) ",
  "     	stat = alterlist(internal->qual, pn_notify_cnt + 20) ","   	endif ",
  "      internal->qual[pn_notify_cnt].order_notification_id = a.order_notification_id ")
 IF (((use_person_table=1) OR (use_prsnl_table=1)) )
  SET ms_select_statement = concat(ms_select_statement,
   " internal->qual[pn_notify_cnt].name_last_key = a.fullname ")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"	endif ","	else ",
  " 		reply->page_context->n_more_ind = 1 ","	endif ",
  " foot report ","   stat = alterlist(internal->qual, pn_notify_cnt) ",
  "   max_nknt = pn_notify_cnt "," with nocounter go")
 SET ilist->qual_knt = iknt
 SET stat = alterlist(ilist->qual,iknt)
 IF (mn_debug_flag=1)
  CALL echo(ms_echo_line)
  CALL echo(ms_select_statement)
  CALL echo(ms_echo_line)
 ENDIF
 CALL parser(ms_select_statement)
 IF (max_nknt=0)
  GO TO exit_program
 ENDIF
 SET ms_out_select_statement = concat(" select into 'nl:' ",
  "  	from (dummyt d with seq = value(max_nknt)), ",
  "       order_notification n , orders o , order_action oa , encounter e ","   	plan d ",
  "   	join n",
  "   		where n.order_notification_id = internal->qual[d.seq].order_notification_id ","   	join o",
  "   		where o.order_id = n.order_id ","   	join e","   		where e.encntr_id = o.encntr_id ",
  "   	join oa","   		where oa.order_id = outerjoin(n.order_id) ",
  "			and oa.action_sequence = outerjoin(n.action_sequence) "," 	head report  ",
  "		stat = alterlist(reply->notification,max_nknt)   		 ",
  "	detail	 ","   	reply->notification[d.seq].order_notification_id      = n.order_notification_id ",
  "   	reply->notification[d.seq].order_id                   = n.order_id ",
  "   	reply->notification[d.seq].action_sequence            = n.action_sequence ",
  "   	reply->notification[d.seq].notification_type_flag     = n.notification_type_flag ",
  "   	reply->notification[d.seq].notification_dt_tm         = n.notification_dt_tm ",
  "   	reply->notification[d.seq].caused_by_flag             = n.caused_by_flag ",
  "   	reply->notification[d.seq].notification_reason_cd     = n.notification_reason_cd ",
  "   	if(n.notification_reason_cd > 0) ",
  "     		reply->notification[d.seq].notification_reason_disp = uar_get_code_display(n.notification_reason_cd) ",
  "  	endif ","   	reply->notification[d.seq].notification_comment       = n.notification_comment ",
  "   	reply->notification[d.seq].notification_status_flag   = n.notification_status_flag ",
  "   	reply->notification[d.seq].status_change_dt_tm        = n.status_change_dt_tm ",
  "   	reply->notification[d.seq].from_prsnl_id              = n.from_prsnl_id ",
  "   	reply->notification[d.seq].encntr_id                  = o.encntr_id ",
  "   	reply->notification[d.seq].loc_facility_cd            = e.loc_facility_cd ",
  "   	reply->notification[d.seq].last_updt_cnt              = o.updt_cnt ",
  "   	reply->notification[d.seq].oe_format_id               = o.oe_format_id ",
  "   	reply->notification[d.seq].person_id                  = o.person_id ",
  "    	reply->notification[d.seq].name_last_key       		  = internal->qual[d.seq].name_last_key ",
  "   	reply->notification[d.seq].order_status_cd            = o.order_status_cd ",
  "   	reply->notification[d.seq].orig_order_dt_tm           = o.orig_order_dt_tm ",
  "   	reply->notification[d.seq].orig_order_tz              = o.orig_order_tz ",
  "   	reply->notification[d.seq].stop_type_cd               = o.stop_type_cd ",
  "   	reply->notification[d.seq].projected_stop_dt_tm       = o.projected_stop_dt_tm ",
  "   	if(n.action_sequence > 0) ",
  "     		reply->notification[d.seq].clinical_display_line    = oa.clinical_display_line ",
  "     		reply->notification[d.seq].originator_id            = oa.action_personnel_id ",
  "     		reply->notification[d.seq].found_originator         = TRUE ",
  "   	else ","     		reply->notification[d.seq].clinical_display_line    = o.clinical_display_line ",
  "   	endif ","   	reply->notification[d.seq].last_action_seq            = o.last_action_sequence ",
  "   	reply->notification[d.seq].last_ingred_action_seq     = o.last_ingred_action_sequence ",
  "   	reply->notification[d.seq].hna_order_mnemonic         = o.hna_order_mnemonic ",
  "   	reply->notification[d.seq].ordered_as_mnemonic        = o.ordered_as_mnemonic ",
  "   	reply->notification[d.seq].order_mnemonic             = o.order_mnemonic ",
  "   	reply->notification[d.seq].med_order_type_cd          = o.med_order_type_cd ",
  "   	reply->notification[d.seq].catalog_cd                 = o.catalog_cd ",
  "   	reply->notification[d.seq].catalog_type_cd            = o.catalog_type_cd ",
  "   	reply->notification[d.seq].order_action_type_cd       = oa.action_type_cd ",
  "   	reply->notification[d.seq].order_action_type_disp     = uar_get_code_display(oa.action_type_cd) ",
  "   	if(band(o.comment_type_mask,1) = 1) ",
  "     		reply->notification[d.seq].get_comment_ind = TRUE ",
  "   	endif ","   	if (n.notification_type_flag = 2 and ",
  "       	o.med_order_type_cd = intermittent_cd and ",
  "       	(n.action_sequence > 0 and n.action_sequence < o.last_ingred_action_sequence)) ",
  "      	iknt = iknt + 1 ",
  "      	if (mod(iknt,10) = 1) ","         		stat = alterlist(ilist->qual,iknt + 9) ",
  "      	endif ","      	ilist->qual[iknt].n_index = nknt ",
  "      	ilist->qual[iknt].order_id = n.order_id ",
  "      	ilist->qual[iknt].action_sequence = n.action_sequence ",
  "   	elseif (n.notification_type_flag = 1) ",
  "     		reply->notification[d.seq].notification_type_flag   = n.notification_type_flag ",
  "   	endif  "," with nocounter go ")
 CALL parser(ms_out_select_statement)
 IF (sbr_check_error("Execute main query")=1)
  GO TO exit_program
 ENDIF
 CALL get_drug_interaction_info(null)
 IF (sbr_check_error("Get Drug Interaction Info")=1)
  GO TO exit_program
 ENDIF
 CALL get_originator_id(null)
 IF (sbr_check_error("Get Originator ID")=1)
  GO TO exit_program
 ENDIF
 CALL get_comments(null)
 IF (sbr_check_error("Get Comments")=1)
  GO TO exit_program
 ENDIF
 IF (iknt > 0)
  CALL get_iv_fields(null)
  IF (sbr_check_error("Get IV Fields")=1)
   GO TO exit_program
  ENDIF
 ENDIF
 SUBROUTINE sbr_create_start_at_clause(ps_start_at_clause)
   DECLARE mn_iteration_cnt = i2 WITH protect, noconstant(0)
   DECLARE mn_col_idx = i2 WITH protect, noconstant(0)
   DECLARE ms_clause_segment = vc WITH protect, noconstant("")
   DECLARE ms_start_at_clause = vc WITH protect, noconstant("")
   DECLARE mn_column_list_size = i2 WITH protect, noconstant(0)
   DECLARE ms_operand = vc WITH protect, noconstant("   ")
   DECLARE ms_start_at_value = vc WITH protect, noconstant("")
   DECLARE mn_page_threshold = i2 WITH protect, noconstant((request->page_context.directives.
    n_page_size+ 100))
   IF ((request->page_context.directives.n_initial_search_ind=1))
    SET ps_start_at_clause = " 0 = 0 "
    RETURN(1)
   ELSE
    SET mn_column_list_size = size(request->page_context.sort_columns,5)
    FOR (mn_iteration_cnt = 0 TO (mn_column_list_size - 1))
     SELECT INTO "nl:"
      pn_sort_index = request->page_context.sort_columns[d.seq].n_sort_index
      FROM (dummyt d  WITH seq = value(size(request->page_context.sort_columns,5)))
      PLAN (d
       WHERE (request->page_context.sort_columns[d.seq].n_sort_index <= (mn_column_list_size -
       mn_iteration_cnt)))
      ORDER BY pn_sort_index
      DETAIL
       IF ((request->page_context.sort_columns[d.seq].n_sort_index != (mn_column_list_size -
       mn_iteration_cnt)))
        ms_operand = " = "
       ELSE
        IF ((request->page_context.sort_columns[d.seq].n_descending_ind=1))
         IF ((request->page_context.directives.n_page_direction=mn_direction_forward))
          ms_operand = " < "
         ELSE
          ms_operand = " > "
         ENDIF
        ELSE
         IF ((request->page_context.directives.n_page_direction=mn_direction_forward))
          ms_operand = " > "
         ELSE
          ms_operand = " < "
         ENDIF
        ENDIF
       ENDIF
       CASE (request->page_context.sort_columns[d.seq].n_start_at_type)
        OF mn_col_type_string:
         IF ((request->page_context.sort_columns[d.seq].s_start_at_value=null))
          request->page_context.sort_columns[d.seq].s_start_at_value = " "
         ENDIF
         ,ms_start_at_value = build("cnvtupper(request->page_context->sort_columns[",d.seq,
          "].s_start_at_value)")
        OF mn_col_type_integer:
         ms_start_at_value = build("request->page_context->sort_columns[",d.seq,"].l_start_at_value")
        OF mn_col_type_double:
         ms_start_at_value = build("request->page_context->sort_columns[",d.seq,"].f_start_at_value")
        OF mn_col_type_date:
         IF ((request->page_context.sort_columns[d.seq].d_start_at_value=null))
          ms_start_at_value = build("null")
         ELSE
          ms_start_at_value = build("cnvtdatetime(request->page_context->sort_columns[",d.seq,
           "].d_start_at_value)")
         ENDIF
       ENDCASE
       IF (pn_sort_index=1)
        IF ((request->page_context.sort_columns[1].n_start_at_type=mn_col_type_string))
         IF (use_person_table)
          ms_clause_segment = concat("concat(trim(p.name_last_key),',', trim(p.name_first_key))",
           ms_operand,ms_start_at_value)
         ELSEIF (use_prsnl_table)
          ms_clause_segment = concat("concat(trim(pr.name_last_key),',', trim(pr.name_first_key))",
           ms_operand,ms_start_at_value)
         ELSE
          ms_clause_segment = concat("cnvtupper(",request->page_context.sort_columns[d.seq].
           s_table_alias,".",request->page_context.sort_columns[d.seq].s_column_name,")",
           ms_operand,ms_start_at_value)
         ENDIF
        ELSE
         ms_clause_segment = concat(request->page_context.sort_columns[d.seq].s_table_alias,".",
          request->page_context.sort_columns[d.seq].s_column_name,ms_operand,ms_start_at_value)
        ENDIF
       ELSE
        ms_clause_segment = concat(ms_clause_segment," and ",request->page_context.sort_columns[d.seq
         ].s_table_alias,".",request->page_context.sort_columns[d.seq].s_column_name,
         ms_operand,ms_start_at_value)
       ENDIF
      WITH nocounter
     ;end select
     IF (textlen(trim(ms_clause_segment)) > 0)
      IF (mn_iteration_cnt=0)
       SET ms_start_at_clause = concat("(",ms_clause_segment,")")
      ELSE
       SET ms_start_at_clause = concat(ms_start_at_clause," OR ","(",ms_clause_segment,")")
      ENDIF
     ENDIF
    ENDFOR
    SET ps_start_at_clause = ms_start_at_clause
    IF (sbr_check_error("sbr_create_start_at_clause")=1)
     RETURN(0)
    ELSE
     RETURN(1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_get_primary_column_info(ps_primary_column)
   DECLARE ms_primary_column = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(request->page_context.sort_columns,5)))
    PLAN (d
     WHERE (request->page_context.sort_columns[d.seq].n_sort_index=1))
    DETAIL
     IF ((request->page_context.sort_columns[d.seq].s_table_alias="pr"))
      use_prsnl_table = 1
     ENDIF
     IF ((request->page_context.sort_columns[d.seq].s_table_alias="p"))
      use_person_table = 1
     ENDIF
     IF (use_prsnl_table=1)
      ms_sort_join_clause = concat(" and ",request->page_context.sort_columns[d.seq].
       s_table_join_alias,".",request->page_context.sort_columns[d.seq].s_column_join_name," = ",
       request->page_context.sort_columns[d.seq].s_table_alias,".person_id ")
     ELSE
      ms_sort_join_clause = " and 0 = 0 "
     ENDIF
    WITH nocounter
   ;end select
   IF (sbr_check_error("sbr_get_primary_column_info")=1)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_create_n_search_clause(ps_n_search_clause)
   DECLARE primary_date_column = vc WITH protect, noconstant("")
   SET primary_date_column = concat(request->page_context.ranges.s_range_table_alias,".",request->
    page_context.ranges.s_range_column_name)
   IF (find_non_renew=1)
    SET ps_n_search_clause = concat("( n.to_prsnl_id = request->f_phys_id and ",
     " n.notification_status_flag = 1 and ",ms_type_clause)
    IF ((request->patient_id > 0))
     SET ps_n_search_clause = concat(ps_n_search_clause," o.person_id = request->patient_id and ")
    ENDIF
    SET ps_n_search_clause = concat(ps_n_search_clause,ms_caused_clause," ",value(primary_date_column
      )," between cnvtdatetime(request->page_context->ranges->d_earliest) ",
     " and cnvtdatetime(request->page_context->ranges->d_latest) "," and o.order_id = n.order_id ",
     " and oc.catalog_cd = o.catalog_cd )")
   ENDIF
   IF (find_non_renew=1
    AND find_renew=1)
    SET ps_n_search_clause = concat(ps_n_search_clause," or  ")
   ENDIF
   IF (find_renew=1)
    IF (find_non_renew=1)
     SET ps_n_search_clause = concat(ps_n_search_clause,"( n.to_prsnl_id = request->f_phys_id and ",
      "  n.notification_status_flag = 1 and ","  n.notification_type_flag = 1 and ")
    ELSE
     SET ps_n_search_clause = concat("( n.to_prsnl_id = request->f_phys_id and ",
      "  n.notification_status_flag = 1 and ","  n.notification_type_flag = 1 and ")
    ENDIF
    IF ((request->patient_id > 0))
     SET ps_n_search_clause = concat(ps_n_search_clause," o.person_id = request->patient_id and ")
    ENDIF
    SET ps_n_search_clause = concat(ps_n_search_clause,ms_caused_clause," ",value(primary_date_column
      )," between cnvtdatetime(request->page_context->ranges->d_earliest) ",
     " and cnvtdatetime(request->page_context->ranges->d_latest) ",
     " and n.notification_display_dt_tm <= cnvtdatetime(curdate,curtime3) ",
     " and o.order_id = n.order_id "," and oc.catalog_cd = o.catalog_cd ",
     " and oc.stop_type_cd > 0 ) ")
   ENDIF
   IF (sbr_check_error("sbr_create_n_search_clause")=1)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_build_caused_by_clause(ps_caused_clause)
   DECLARE caused_cd = f8 WITH noconstant(0.0)
   SET ps_caused_clause = concat(" n.caused_by_flag in ( ")
   SET causedbycnt = size(request->caused_by_flags,5)
   IF (causedbycnt > 0)
    SET caused_cd = request->caused_by_flags[1].caused_by_flag
    SET ps_caused_clause = build(ps_caused_clause,caused_cd)
    FOR (x = 2 TO causedbycnt)
     SET caused_cd = request->caused_by_flags[x].caused_by_flag
     SET ps_caused_clause = build(ps_caused_clause,",",caused_cd)
    ENDFOR
   ELSE
    SET ps_caused_clause = concat(ps_caused_clause,"0")
   ENDIF
   SET ps_caused_clause = concat(ps_caused_clause,") and ")
 END ;Subroutine
 SUBROUTINE sbr_build_type_clause(ps_type_clause)
   DECLARE type_cd = f8 WITH noconstant(0.0)
   SET ps_type_clause = concat(" n.notification_type_flag in ( ")
   SET typecnt = size(request->type_flags,5)
   SET z = 1
   FOR (y = 1 TO typecnt)
    SET type_cd = request->type_flags[y].type_flag
    IF (type_cd != 1)
     SET find_non_renew = 1
     IF (z=1)
      SET ps_type_clause = build(ps_type_clause,type_cd)
      SET z = (z+ 1)
     ELSE
      SET ps_type_clause = build(ps_type_clause,",",type_cd)
     ENDIF
    ELSE
     SET find_renew = 1
    ENDIF
   ENDFOR
   SET ps_type_clause = concat(ps_type_clause,") and ")
 END ;Subroutine
 SUBROUTINE sbr_create_e_search_clause(ps_e_search_clause)
  SET ps_e_search_clause = concat(" e.encntr_id = o.encntr_id ")
  IF (sbr_check_error("sbr_create_e_search_clause")=1)
   RETURN(0)
  ELSE
   RETURN(1)
  ENDIF
 END ;Subroutine
 SUBROUTINE sbr_create_p_search_clause(ps_p_search_clause)
   SET ps_p_search_clause = concat(" p.person_id = o.person_id ")
   SET ps_p_search_clause = concat(ps_p_search_clause,ms_sort_join_clause)
   IF (sbr_check_error("sbr_create_p_search_clause")=1)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_create_order_clause(ps_inner_order_clause,ps_outer_order_clause)
   DECLARE ms_inner_order_clause = vc WITH protect, noconstant("")
   DECLARE ms_outer_order_clause = vc WITH protect, noconstant("")
   DECLARE ms_sort_order_inner = vc WITH protect, noconstant("")
   DECLARE ms_sort_order_outer = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    pn_sort_index = request->page_context.sort_columns[d.seq].n_sort_index
    FROM (dummyt d  WITH seq = value(size(request->page_context.sort_columns,5)))
    PLAN (d)
    ORDER BY pn_sort_index
    DETAIL
     IF ((request->page_context.sort_columns[d.seq].n_descending_ind=1))
      IF ((request->page_context.directives.n_page_direction=mn_direction_forward))
       ms_sort_order_inner = " desc", ms_sort_order_outer = " desc"
      ELSE
       ms_sort_order_inner = " ", ms_sort_order_outer = " desc"
      ENDIF
     ELSE
      ms_sort_order_inner = " "
      IF ((request->page_context.directives.n_page_direction=mn_direction_forward))
       ms_sort_order_inner = " ", ms_sort_order_outer = " "
      ELSE
       ms_sort_order_inner = " desc", ms_sort_order_outer = " "
      ENDIF
     ENDIF
     IF (pn_sort_index=1)
      IF (cnvtlower(request->page_context.sort_columns[d.seq].s_column_name)="msg_subject")
       ms_outer_order_clause = concat(" cnvtlower(")
      ELSE
       ms_outer_order_clause = concat(" ")
      ENDIF
      ms_outer_order_clause = concat(ms_outer_order_clause,request->page_context.sort_columns[d.seq].
       s_column_name)
      IF (cnvtlower(request->page_context.sort_columns[d.seq].s_column_name)="msg_subject")
       ms_outer_order_clause = concat(ms_outer_order_clause,") ")
      ENDIF
      ms_outer_order_clause = concat(ms_outer_order_clause,ms_sort_order_outer)
      IF (cnvtlower(request->page_context.sort_columns[d.seq].s_column_name)="name_last_key")
       ms_outer_order_clause = concat(ms_outer_order_clause,", "), ms_outer_order_clause = concat(
        ms_outer_order_clause,"name_first_key "), ms_outer_order_clause = concat(
        ms_outer_order_clause,ms_sort_order_outer)
      ENDIF
      IF (cnvtlower(request->page_context.sort_columns[d.seq].s_column_name)="msg_subject")
       ms_inner_order_clause = concat(" cnvtlower(")
      ELSE
       ms_inner_order_clause = concat(" ")
      ENDIF
      ms_inner_order_clause = concat(ms_inner_order_clause,request->page_context.sort_columns[d.seq].
       s_table_alias,".",request->page_context.sort_columns[d.seq].s_column_name)
      IF (cnvtlower(request->page_context.sort_columns[d.seq].s_column_name)="msg_subject")
       ms_inner_order_clause = concat(ms_inner_order_clause,") ")
      ENDIF
      ms_inner_order_clause = concat(ms_inner_order_clause,ms_sort_order_inner)
      IF (cnvtlower(request->page_context.sort_columns[d.seq].s_column_name)="name_last_key")
       ms_inner_order_clause = concat(ms_inner_order_clause,", "), ms_inner_order_clause = concat(
        ms_inner_order_clause,request->page_context.sort_columns[d.seq].s_table_alias,".",
        "name_first_key "), ms_inner_order_clause = concat(ms_inner_order_clause,ms_sort_order_inner)
      ENDIF
     ELSE
      ms_outer_order_clause = concat(ms_outer_order_clause,", ",request->page_context.sort_columns[d
       .seq].s_column_name,ms_sort_order_outer), ms_inner_order_clause = concat(ms_inner_order_clause,
       ", ",request->page_context.sort_columns[d.seq].s_table_alias,".",request->page_context.
       sort_columns[d.seq].s_column_name,
       ms_sort_order_inner)
     ENDIF
    WITH nocounter
   ;end select
   SET ps_inner_order_clause = ms_inner_order_clause
   SET ps_outer_order_clause = ms_outer_order_clause
   IF (sbr_check_error("sbr_create_order_clause")=1)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_drug_interaction_info(null)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(max_nknt)),
     order_ingredient oi,
     order_catalog oc
    PLAN (d1
     WHERE d1.seq > 0
      AND (reply->notification[d1.seq].catalog_type_cd=pharmacy_cd))
     JOIN (oi
     WHERE (oi.order_id=reply->notification[d1.seq].order_id)
      AND (oi.action_sequence=reply->notification[d1.seq].last_ingred_action_seq))
     JOIN (oc
     WHERE oc.catalog_cd=oi.catalog_cd
      AND ((oc.cki=patstring("MUL.ORD!*")) OR (((oc.cki=patstring("MUL.MMDC!*")) OR (oc.cki=patstring
     ("GDDB.ACG*"))) )) )
    ORDER BY d1.seq
    HEAD d1.seq
     dum_var = 1, knt = 0
    DETAIL
     knt = (knt+ 1)
     IF (mod(knt,10)=1)
      stat = alterlist(reply->notification[d1.seq].drug_ingred,(knt+ 9))
     ENDIF
     reply->notification[d1.seq].drug_ingred[knt].catalog_cd = oc.catalog_cd, reply->notification[d1
     .seq].drug_ingred[knt].source_vocab_mean = trim(substring(1,(findstring("!",oc.cki) - 1),oc.cki)
      ), reply->notification[d1.seq].drug_ingred[knt].source_identifier = trim(substring((findstring(
        "!",oc.cki)+ 1),textlen(trim(oc.cki)),oc.cki)),
     reply->notification[d1.seq].drug_ingred[knt].cki = oc.cki
    FOOT  d1.seq
     reply->notification[d1.seq].drug_ingred_knt = knt, stat = alterlist(reply->notification[d1.seq].
      drug_ingred,knt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_originator_id(null)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(max_nknt)),
     orders o,
     order_action oa
    PLAN (d1
     WHERE d1.seq > 0
      AND (reply->notification[d1.seq].found_originator=false))
     JOIN (o
     WHERE (o.order_id=reply->notification[d1.seq].order_id))
     JOIN (oa
     WHERE oa.order_id=o.order_id
      AND oa.action_sequence=o.last_action_sequence)
    DETAIL
     reply->notification[d1.seq].originator_id = oa.action_personnel_id
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_comments(null)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(max_nknt)),
     order_comment oc,
     long_text lt
    PLAN (d1
     WHERE d1.seq > 0
      AND (reply->notification[d1.seq].get_comment_ind=true))
     JOIN (oc
     WHERE (oc.order_id=reply->notification[d1.seq].order_id)
      AND oc.comment_type_cd=ord_comment_cd)
     JOIN (lt
     WHERE lt.long_text_id=oc.long_text_id)
    ORDER BY oc.order_id, oc.action_sequence DESC
    HEAD oc.order_id
     found_comment = false
    DETAIL
     IF (found_comment=false)
      found_comment = true, reply->notification[d1.seq].order_comment = lt.long_text
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_iv_fields(null)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(iknt)),
     order_ingredient oi
    PLAN (d
     WHERE d.seq > 0)
     JOIN (oi
     WHERE (oi.order_id=ilist->qual[d.seq].order_id)
      AND (oi.action_sequence <= ilist->qual[d.seq].action_sequence)
      AND oi.ingredient_type_flag=3)
    ORDER BY d.seq, oi.order_id, oi.action_sequence DESC,
     oi.comp_sequence
    HEAD d.seq
     nknt = ilist->qual[d.seq].n_index, aknt = 0, stat = alterlist(reply->notification[nknt].
      ingredient,10),
     temp_iseq = oi.action_sequence, get_ingredient = true
    HEAD oi.action_sequence
     IF (temp_iseq != oi.action_sequence)
      get_ingredient = false
     ENDIF
    DETAIL
     IF (get_ingredient=true)
      aknt = (aknt+ 1)
      IF (mod(aknt,10)=1
       AND aknt != 1)
       stat = alterlist(reply->notification[nknt].ingredient,(aknt+ 9))
      ENDIF
      reply->notification[nknt].ingredient[aknt].hna_order_mnemonic = oi.hna_order_mnemonic, reply->
      notification[nknt].ingredient[aknt].order_mnemonic = oi.order_mnemonic, reply->notification[
      nknt].ingredient[aknt].ordered_as_mnemonic = oi.ordered_as_mnemonic,
      reply->notification[nknt].ingredient[aknt].ingredient_type_flag = oi.ingredient_type_flag,
      reply->notification[nknt].ingredient[aknt].strength = oi.strength, reply->notification[nknt].
      ingredient[aknt].strength_unit = oi.strength_unit,
      reply->notification[nknt].ingredient[aknt].volume = oi.volume, reply->notification[nknt].
      ingredient[aknt].volume_unit = oi.volume_unit, reply->notification[nknt].ingredient[aknt].
      freetext_dose = oi.freetext_dose,
      reply->notification[nknt].ingredient[aknt].freq_cd = oi.freq_cd
     ENDIF
    FOOT  oi.action_sequence
     row + 1
    FOOT  d.seq
     reply->notification[nknt].additive_count_for_ivpb = aknt, stat = alterlist(reply->notification[
      nknt].ingredient,aknt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE sbr_check_error(ps_operation_name)
  DECLARE ms_error_msg = vc WITH protect, noconstant("")
  IF (error(ms_error_msg,1) != 0)
   SET reply->status_data.subeventstatus[1].operationname = ps_operation_name
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Run time error"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = ms_error_msg
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
#exit_program
 IF (mn_error_ind=1)
  SET reply->status_data.status = "F"
 ELSE
  IF (size(reply->notification,5)=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
