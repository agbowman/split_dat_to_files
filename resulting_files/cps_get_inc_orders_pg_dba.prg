CREATE PROGRAM cps_get_inc_orders_pg:dba
 SET modify = predeclare
 RECORD internal(
   1 qual[*]
     2 order_id = f8
     2 name_last_key = vc
 )
 DECLARE ms_search_clause = vc WITH protect, noconstant("")
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
 DECLARE order_cnt = i4 WITH protect, noconstant(0)
 DECLARE use_person_table = i2 WITH protect, noconstant(0)
 DECLARE use_prsnl_table = i2 WITH protect, noconstant(0)
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
 DECLARE incomplete_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE pharmacy_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE sbr_divide_date(pd_first_date=q8,pd_second_date=q8) = q8
 DECLARE sbr_parse_where_clause(dummy=i1) = vc
 DECLARE sbr_get_primary_column_info(ps_primary_column=vc(ref)) = i1
 DECLARE sbr_create_search_clause(ps_search_clause=vc(ref)) = i1
 DECLARE sbr_create_order_clause(ps_inner_order_clause=vc(ref),ps_outer_order_clause=vc(ref)) = i1
 DECLARE sbr_create_start_at_clause(ps_start_at_clause=vc(ref)) = i1
 DECLARE sbr_check_error(ps_operation_name=vc) = i1
 RECORD reply(
   1 page_context
     2 n_more_ind = i2
   1 qual_knt = i4
   1 qual[*]
     2 order_id = f8
     2 person_id = f8
     2 name_last_key = vc
     2 encntr_id = f8
     2 order_status_cd = f8
     2 order_status_disp = c40
     2 order_status_mean = c12
     2 order_mnemonic = vc
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 activity_type_desc = c60
     2 activity_type_mean = c12
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 last_update_provider_id = f8
     2 order_detail_display_line = vc
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 catalog_type_disp = c40
     2 catalog_type_desc = c60
     2 catalog_type_mean = c12
     2 synonym_id = f8
     2 oe_format_id = f8
     2 ref_text_mask = i4
     2 last_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET pn_stat = initrec(reply)
 IF (mn_debug_flag=1)
  CALL echorecord(request)
 ENDIF
 IF (sbr_get_primary_column_info(ms_primary_column)=0)
  GO TO exit_program
 ENDIF
 IF (sbr_create_search_clause(ms_search_clause)=0)
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
  CALL echo("ms_search_clause: ")
  CALL echo(ms_search_clause)
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
  ")","		,o.order_id ","		,o.orig_order_dt_tm ","		,o.person_id ")
 IF (use_person_table=1)
  SET ms_select_statement = concat(ms_select_statement,", p.name_last_key, p.name_first_key ",
   ", fullname = concat(trim(p.name_last_key),',', trim(p.name_first_key)) ")
 ELSEIF (use_prsnl_table=1)
  SET ms_select_statement = concat(ms_select_statement,", pr.name_last_key, pr.name_first_key ",
   ", fullname = concat(trim(pr.name_last_key),',', trim(pr.name_first_key)) ")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"       from orders o ")
 IF (use_person_table=1)
  SET ms_select_statement = concat(ms_select_statement,", person p ")
 ELSEIF (use_prsnl_table=1)
  SET ms_select_statement = concat(ms_select_statement,", prsnl pr ")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"        where (",ms_search_clause,")",
  "          and (",
  ms_start_at_clause,")","       with sqltype('F8' ","                    ,'F8' ",
  "                    ,'DQ8' ",
  "                    ,'F8' ")
 IF (((use_person_table=1) OR (use_prsnl_table)) )
  SET ms_select_statement = concat(ms_select_statement,",'VC', 'VC', 'VC' ")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement," )) a ) ",
  " where pn_row_number <= request->page_context->directives->n_page_size + 1"," order by ",
  ms_outer_order_clause,
  " head report ","    knt = 0 "," 	 init = 0 ","    stat = alterlist (internal->qual,10) ",
  " detail ",
  "	if(knt < request->page_context->directives->n_page_size) ",
  "		if (a.pn_row_number > request->page_context->directives->n_page_size ",
  "				and request->page_context->directives->n_page_direction = 2 ","				and init = 0 )",
  "			init = 1 ",
  " 			reply->page_context->n_more_ind = 1 ","		else ","    	knt = knt + 1 ",
  "    	if (mod(knt,10) = 1 and knt != 1) ","       	stat = alterlist (internal->qual,knt + 9) ",
  "    	endif ","            internal->qual[knt].order_id = a.order_id ")
 IF (((use_person_table=1) OR (use_prsnl_table=1)) )
  SET ms_select_statement = concat(ms_select_statement,
   " internal->qual[knt].name_last_key = a.fullname ")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"		endif ","	else ",
  " 		reply->page_context->n_more_ind = 1 ","	endif ",
  " foot report ","    order_cnt = knt , ","    stat = alterlist (internal->qual,knt) ",
  " with nocounter go")
 IF (mn_debug_flag=1)
  CALL echo(ms_echo_line)
  CALL echo(ms_select_statement)
  CALL echo(ms_echo_line)
 ENDIF
 CALL parser(ms_select_statement)
 IF (order_cnt > 0)
  SET ms_out_select_statement = concat(" select into 'nl:' ",
   "  	from (dummyt d with seq = value(order_cnt)), ","    	orders o ","   	plan d ","   	join o",
   "   		where o.order_id = internal->qual[d.seq].order_id "," 	head report  ",
   "		stat = alterlist(reply->qual,order_cnt)   		 ","	detail	 ",
   "    	reply->qual[d.seq].order_id                    = o.order_id ",
   "    	reply->qual[d.seq].person_id                   = o.person_id ",
   "    	reply->qual[d.seq].encntr_id                   = o.encntr_id ",
   "    	reply->qual[d.seq].order_status_cd             = o.order_status_cd ",
   "    	reply->qual[d.seq].order_mnemonic              = o.order_mnemonic ",
   "    	reply->qual[d.seq].activity_type_cd            = o.activity_type_cd ",
   "    	reply->qual[d.seq].orig_order_dt_tm            = cnvtdatetime(o.orig_order_dt_tm) ",
   "    	reply->qual[d.seq].orig_order_tz               = o.orig_order_tz",
   "    	reply->qual[d.seq].last_update_provider_id     = o.last_update_provider_id ",
   "    	reply->qual[d.seq].order_detail_display_line   = o.order_detail_display_line ",
   "    	reply->qual[d.seq].catalog_cd                  = o.catalog_cd ",
   "    	reply->qual[d.seq].catalog_type_cd             = o.catalog_type_cd ",
   "    	reply->qual[d.seq].synonym_id                  = o.synonym_id ",
   "    	reply->qual[d.seq].oe_format_id                = o.oe_format_id ",
   "    	reply->qual[d.seq].ref_text_mask               = o.ref_text_mask ",
   "    	reply->qual[d.seq].last_updt_cnt               = o.updt_cnt ",
   "    	reply->qual[d.seq].name_last_key         = internal->qual[d.seq].name_last_key",
   " with nocounter go ")
 ENDIF
 CALL parser(ms_out_select_statement)
 IF (sbr_check_error("Execute main query")=1)
  GO TO exit_program
 ENDIF
 IF (mn_debug_flag=1)
  CALL echorecord(reply)
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
     IF ((request->page_context.sort_columns[d.seq].s_table_alias="p"))
      use_person_table = 1
     ENDIF
     IF ((request->page_context.sort_columns[d.seq].s_table_alias="pr"))
      use_prsnl_table = 1
     ENDIF
     IF (((use_person_table=1) OR (use_prsnl_table=1)) )
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
 SUBROUTINE sbr_create_search_clause(ps_search_clause)
   SET ps_search_clause = concat(" o.last_update_provider_id = request->phys_id ",
    "and o.order_status_cd = incomplete_cd ","and o.order_mnemonic != ' ' ",
    "and ((o.catalog_type_cd = pharmacy_cd ","and o.template_order_flag in (0,1,5)) ",
    "or o.catalog_type_cd != pharmacy_cd) ","and o.active_ind = 1 ")
   SET ps_search_clause = concat(ps_search_clause,ms_sort_join_clause)
   SET ps_search_clause = concat(ps_search_clause,
    " and o.orig_order_dt_tm between cnvtdatetime(request->page_context->ranges->d_earliest) ",
    " and cnvtdatetime(request->page_context->ranges->d_latest)")
   IF ((request->person_id > 0))
    SET ps_search_clause = concat(ps_search_clause,"and o.person_id = request->person_id ")
   ENDIF
   IF (sbr_check_error("sbr_create_search_clause")=1)
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
        ms_inner_order_clause,"name_first_key "), ms_inner_order_clause = concat(
        ms_inner_order_clause,ms_sort_order_inner)
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
  IF (size(reply->qual,5)=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
