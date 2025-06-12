CREATE PROGRAM dm_combine_triggers:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_drop TO 2999_drop_exit
 EXECUTE FROM 3000_build TO 3999_build_exit
 GO TO 9999_exit_program
 SUBROUTINE ocd_check(dummy)
   SET ocd_exist_flag = 0
   SET cur_env_id = 0
   SET combine_ocd_nbr = 6475
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_name="DM_ENV_ID"
     AND di.info_domain="DATA MANAGEMENT"
    DETAIL
     cur_env_id = di.info_number
    WITH nocounter
   ;end select
   IF (cur_env_id > 0)
    SELECT INTO "nl:"
     FROM dm_environment de
     WHERE de.environment_id=cur_env_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET cur_env_id = 0
    ENDIF
   ENDIF
   IF (cur_env_id)
    SELECT INTO "nl:"
     FROM dm_alpha_features daf,
      dm_alpha_features_env dafe
     PLAN (daf
      WHERE daf.product_area_number=8
       AND daf.alpha_feature_nbr >= combine_ocd_nbr)
      JOIN (dafe
      WHERE dafe.alpha_feature_nbr=daf.alpha_feature_nbr
       AND dafe.environment_id=cur_env_id)
     ORDER BY daf.alpha_feature_nbr DESC
     WITH nocounter
    ;end select
    IF (curqual)
     SET ocd_exist_flag = 1
    ELSE
     CALL echo("*************************************************************************")
     CALL echo("Combine Triggers will not be built in this Domain.                       ")
     CALL echo(build("Need to have Data Management OCD # ",combine_ocd_nbr,
       " or higher installed in this domain."))
     CALL echo("*************************************************************************")
     GO TO 9999_exit_program
    ENDIF
   ELSE
    CALL echo("***********************************************************")
    CALL echo("No Valid Environment ID Found")
    CALL echo("Combine Triggers will not be built in this Domain !!!")
    CALL echo("***********************************************************")
    GO TO 9999_exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE ct_column_exists(ce_table,ce_column)
   SET ce_flag = 0
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=cnvtupper(trim(ce_table,3))
     AND l.attr_name=cnvtupper(trim(ce_column,3))
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    DETAIL
     ce_flag = 1
    WITH nocounter
   ;end select
   RETURN(ce_flag)
 END ;Subroutine
 SUBROUTINE ct_exists(e_trigger)
   SET e_flag = 0
   SELECT INTO "nl:"
    t.trigger_name
    FROM user_triggers t
    WHERE t.trigger_name=cnvtupper(trim(e_trigger,3))
    DETAIL
     e_flag = 1
    WITH nocounter
   ;end select
   RETURN(e_flag)
 END ;Subroutine
 SUBROUTINE ct_kick(k_message)
   SET ct_error->message = k_message
   IF ( NOT (readme_data->readme_id))
    CALL echo(k_message)
   ENDIF
   SET readme_data->status = "F"
   SET readme_data->message = k_message
   EXECUTE dm_readme_status
   GO TO 9999_exit_program
 END ;Subroutine
 SUBROUTINE ct_push(p_text)
   SET p_i = (size(ct_data->buffer,5)+ 1)
   SET p_stat = alterlist(ct_data->buffer,p_i)
   SET ct_data->buffer[p_i].text = p_text
 END ;Subroutine
 SUBROUTINE ct_run(r_dummy)
   SET r_count = size(ct_data->buffer,5)
   IF (r_count)
    FOR (r_i = 1 TO r_count)
      IF (r_i=1)
       CALL parser(concat("rdb asis(^",ct_data->buffer[r_i].text,char(10),"^)"),1)
      ELSE
       CALL parser(concat("asis(^",ct_data->buffer[r_i].text,char(10),"^)"),1)
      ENDIF
    ENDFOR
    CALL parser("end go",1)
   ENDIF
   SET r_stat = alterlist(ct_data->buffer,0)
 END ;Subroutine
 SUBROUTINE ct_type(t_parent,t_child)
   CASE (t_child)
    OF "CHARGE":
     RETURN(ct_null)
    OF "CHARGE_EVENT":
     RETURN(ct_null)
    OF "INTERFACE_CHARGE":
     RETURN(ct_null)
    OF "OASIS_RECORD_SET":
     RETURN(ct_auto)
    OF "PC_485_OTHER":
     RETURN(ct_auto)
    OF "PC_DIET":
     RETURN(ct_auto)
    OF "PC_FORM_DETAIL":
     RETURN(ct_auto)
    OF "PC_IO_SECTION_DETAIL":
     RETURN(ct_auto)
    OF "PC_MED_LIST":
     RETURN(ct_auto)
    OF "PC_NOTE_COMMENT":
     RETURN(ct_auto)
    OF "PC_PLAN_SIGN":
     RETURN(ct_auto)
    OF "PC_PRSNL_INFO":
     RETURN(ct_auto)
    OF "PC_REC_PATTERN":
     RETURN(ct_auto)
    OF "PC_REFERRAL_LIST":
     RETURN(ct_auto)
    OF "PC_REMINDERS_LIST":
     RETURN(ct_auto)
    OF "PC_VISIT_AUTH":
     RETURN(ct_auto)
    OF "PC_VISIT_ORDER":
     RETURN(ct_auto)
    OF "PC_VISIT_ORDER_RELTN":
     RETURN(ct_auto)
    OF "PC_VISIT_SIGN":
     RETURN(ct_auto)
    OF "PPS_CUR_ANSWER":
     RETURN(ct_auto)
    OF "PPS_EPISODE":
     RETURN(ct_auto)
    OF "SCD_STORY":
     RETURN(ct_auto)
    OF "SURGICAL_CASE":
     RETURN(ct_auto)
    OF "ACT_PW_COMP":
     RETURN(ct_auto)
    OF "ALLERGY":
     RETURN(ct_auto)
    OF "CE_EVENT_PRSNL":
     RETURN(ct_auto)
    OF "CE_IO_RESULT":
     RETURN(ct_auto)
    OF "CE_MED_RESULT":
     RETURN(ct_auto)
    OF "CLINICAL_EVENT":
     RETURN(ct_auto)
    OF "CN_PATHWAY_ST":
     RETURN(ct_auto)
    OF "CN_PW_ORDER_ST":
     RETURN(ct_auto)
    OF "CN_PW_OUTCOME_ST":
     RETURN(ct_auto)
    OF "DCP_FORMS_ACTIVITY":
     RETURN(ct_auto)
    OF "DCP_PL_CUSTOM_ENTRY":
     RETURN(ct_auto)
    OF "DCP_PL_PRIORITIZATION":
     RETURN(ct_auto)
    OF "DCP_PL_PRIORITY":
     RETURN(ct_auto)
    OF "DCP_SHIFT_ASSIGNMENT":
     RETURN(ct_auto)
    OF "DIAGNOSIS":
     RETURN(ct_auto)
    OF "ENCNTR_PERSON_RELTN":
     RETURN(ct_auto)
    OF "ENCNTR_PRSNL_GRP_RELTN":
     RETURN(ct_auto)
    OF "ENCNTR_PRSNL_RELTN":
     RETURN(ct_auto)
    OF "NOMEN_ENTITY_RELTN":
     RETURN(ct_auto)
    OF "ORDER_DEMOG_HISTORY":
     RETURN(ct_auto)
    OF "ORDERS":
     RETURN(ct_auto)
    OF "PATHWAY":
     RETURN(ct_auto)
    OF "PERSON_PATIENT":
     RETURN(ct_auto)
    OF "PERSON_PRSNL_RELTN":
     RETURN(ct_auto)
    OF "PROBLEM":
     RETURN(ct_auto)
    OF "PROCEDURE":
     RETURN(ct_auto)
    OF "TASK_ACTIVITY":
     RETURN(ct_auto)
    OF "OMF_CHARGE_ST":
     RETURN(ct_null)
    OF "PFT_ENCNTR":
     RETURN(ct_null)
    OF "PFT_ENCNTR_CODE":
     RETURN(ct_auto)
    OF "PFT_ENCNTR_HIST":
     RETURN(ct_null)
    OF "UM_CHARGE_EVENT_ST":
     RETURN(ct_null)
    OF "ACCT_BALANCE":
     RETURN(ct_null)
    OF "AGED_TRIAL_BALANCE":
     RETURN(ct_null)
    OF "BATCH_TRANS_FILE":
     RETURN(ct_null)
    OF "CONS_BO_SCHED":
     RETURN(ct_null)
    OF "ICLASS_PERSON_RELTN":
     RETURN(ct_null)
    OF "FOLDER":
     RETURN(ct_null)
    ELSE
     SELECT INTO "nl:"
      e.child_entity
      FROM dm_cmb_exception e
      WHERE e.operation_type="COMBINE"
       AND e.parent_entity=t_parent
       AND e.child_entity=t_child
       AND cnvtupper(e.script_name)="NONE"
      WITH nocounter
     ;end select
     IF (curqual)
      RETURN(ct_null)
     ELSE
      RETURN(ct_default)
     ENDIF
   ENDCASE
 END ;Subroutine
#1000_initialize
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="INHOUSE DOMAIN"
  WITH nocounter
 ;end select
 IF ( NOT (curqual))
  CALL ocd_check(0)
 ENDIF
 IF ( NOT (validate(build_triggers,0)))
  SET build_triggers = 1
 ENDIF
 IF ( NOT (validate(ct_error,0)))
  FREE RECORD ct_error
  RECORD ct_error(
    1 message = vc
  )
 ENDIF
 SET ct_default = 0
 SET ct_auto = 1
 SET ct_null = 2
 FREE SET ct_data
 RECORD ct_data(
   1 trigger[*]
     2 name = vc
   1 person[*]
     2 child_table = vc
     2 child_column = vc
     2 child_pk = vc
     2 trigger_name = vc
     2 sequence = i2
     2 special = i2
     2 multiple = i2
     2 encntr_col = vc
     2 parent_entity_name = vc
   1 encntr[*]
     2 child_table = vc
     2 child_column = vc
     2 child_pk = vc
     2 trigger_name = vc
     2 sequence = i2
   1 buffer[*]
     2 text = vc
 )
 SET ct_i = 0
 SET ct_j = 0
#1999_initialize_exit
#2000_drop
 SET ct_i = 0
 SELECT INTO "nl:"
  t.trigger_name
  FROM user_triggers t
  WHERE t.trigger_name="TRG_?CMB?_*"
  DETAIL
   ct_i = (ct_i+ 1), stat = alterlist(ct_data->trigger,ct_i), ct_data->trigger[ct_i].name = t
   .trigger_name
  WITH nocounter
 ;end select
 FOR (ct_i = 1 TO size(ct_data->trigger,5))
   CALL parser(concat("rdb drop trigger ",ct_data->trigger[ct_i].name," go"),1)
 ENDFOR
 IF (validate(drop_only,0))
  GO TO 9999_exit_program
 ENDIF
#2999_drop_exit
#3000_build
 IF ( NOT (build_triggers))
  GO TO 3000_continue
 ENDIF
 SELECT INTO "nl:"
  c.child_table
  FROM dm_cmb_children c
  WHERE c.parent_table IN ("PERSON", "ENCOUNTER")
   AND c.child_column > " "
   AND c.child_pk > " "
  ORDER BY c.parent_table, c.child_table, c.child_column
  HEAD c.child_table
   ct_j = 0
  HEAD c.child_column
   ct_j = (ct_j+ 1)
   IF (c.parent_table="ENCOUNTER")
    ct_i = (size(ct_data->encntr,5)+ 1), stat = alterlist(ct_data->encntr,ct_i), ct_data->encntr[ct_i
    ].child_table = trim(cnvtupper(c.child_table),3),
    ct_data->encntr[ct_i].child_column = trim(cnvtupper(c.child_column),3), ct_data->encntr[ct_i].
    child_pk = trim(cnvtupper(c.child_pk),3), ct_data->encntr[ct_i].sequence = ct_j,
    ct_data->encntr[ct_i].trigger_name = concat("TRG_ECMB",trim(cnvtstring(ct_j),3),"_",substring(1,
      20,ct_data->encntr[ct_i].child_table))
   ELSE
    ct_i = (size(ct_data->person,5)+ 1), stat = alterlist(ct_data->person,ct_i), ct_data->person[ct_i
    ].child_table = cnvtupper(trim(c.child_table,3)),
    ct_data->person[ct_i].child_column = cnvtupper(trim(c.child_column,3)), ct_data->person[ct_i].
    child_pk = trim(cnvtupper(c.child_pk),3), ct_data->person[ct_i].sequence = ct_j,
    ct_data->person[ct_i].trigger_name = concat("TRG_PCMB",trim(cnvtstring(ct_j),3),"_",substring(1,
      20,ct_data->person[ct_i].child_table))
    IF (c.child_table="ENCNTR_PLAN_RELTN")
     ct_data->person[ct_i].multiple = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.child_table
  FROM dm_cmb_children c,
   (dummyt d  WITH seq = value(size(ct_data->person,5)))
  PLAN (d
   WHERE (((ct_data->person[d.seq].child_table != "OMF_ENCNTR_ST")) OR ((ct_data->person[d.seq].
   child_column != "PERSON_ID"))) )
   JOIN (c
   WHERE c.parent_table="PERSON"
    AND (c.child_table=ct_data->person[d.seq].child_table)
    AND (c.child_column != ct_data->person[d.seq].child_column))
  DETAIL
   ct_data->person[d.seq].multiple = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.child_column
  FROM dm_cmb_children c,
   (dummyt d  WITH seq = value(size(ct_data->person,5)))
  PLAN (d
   WHERE (ct_data->person[d.seq].multiple <= 0))
   JOIN (c
   WHERE c.parent_table="ENCOUNTER"
    AND (c.child_table=ct_data->person[d.seq].child_table)
    AND c.child_column > " ")
  DETAIL
   ct_data->person[d.seq].encntr_col = c.child_column
  WITH nocounter
 ;end select
 SET ct_i = (size(ct_data->person,5)+ 1)
 SET stat = alterlist(ct_data->person,ct_i)
 SET ct_data->person[ct_i].child_table = "ADDRESS"
 SET ct_data->person[ct_i].child_column = "PARENT_ENTITY_ID"
 SET ct_data->person[ct_i].parent_entity_name = "PARENT_ENTITY_NAME"
 SET ct_data->person[ct_i].sequence = 1
 SET ct_data->person[ct_i].trigger_name = "TRG_PCMB1_ADDRESS"
 SET ct_data->person[ct_i].special = 1
 SET ct_i = (size(ct_data->person,5)+ 1)
 SET stat = alterlist(ct_data->person,ct_i)
 SET ct_data->person[ct_i].child_table = "PHONE"
 SET ct_data->person[ct_i].child_column = "PARENT_ENTITY_ID"
 SET ct_data->person[ct_i].parent_entity_name = "PARENT_ENTITY_NAME"
 SET ct_data->person[ct_i].sequence = 1
 SET ct_data->person[ct_i].trigger_name = "TRG_PCMB1_PHONE"
 SET ct_data->person[ct_i].special = 1
 SET ct_i = (size(ct_data->person,5)+ 1)
 SET stat = alterlist(ct_data->person,ct_i)
 SET ct_data->person[ct_i].child_table = "CHART_REQUEST_AUDIT"
 SET ct_data->person[ct_i].child_column = "DEST_PE_ID"
 SET ct_data->person[ct_i].parent_entity_name = "DEST_PE_NAME"
 SET ct_data->person[ct_i].sequence = 1
 SET ct_data->person[ct_i].trigger_name = "TRG_PCMB1_CHART_REQUEST_AUDIT"
 SET ct_data->person[ct_i].special = 1
 SET ct_i = (size(ct_data->person,5)+ 1)
 SET stat = alterlist(ct_data->person,ct_i)
 SET ct_data->person[ct_i].child_table = "CHART_REQUEST_AUDIT"
 SET ct_data->person[ct_i].child_column = "REQUESTOR_PE_ID"
 SET ct_data->person[ct_i].parent_entity_name = "REQUESTOR_PE_NAME"
 SET ct_data->person[ct_i].sequence = 2
 SET ct_data->person[ct_i].trigger_name = "TRG_PCMB2_CHART_REQUEST_AUDIT"
 SET ct_data->person[ct_i].special = 1
 FOR (ct_i = 1 TO size(ct_data->person,5))
   IF (ct_column_exists(ct_data->person[ct_i].child_table,ct_data->person[ct_i].child_column))
    CASE (ct_type("PERSON",ct_data->person[ct_i].child_table))
     OF ct_default:
      CALL ct_push(concat("create or replace trigger ",ct_data->person[ct_i].trigger_name," after"))
      CALL ct_push(concat("  update or insert on ",ct_data->person[ct_i].child_table," for each row")
       )
      IF (ct_data->person[ct_i].special)
       CALL ct_push(concat("  when (new.",ct_data->person[ct_i].child_column," > 0"," and new.",
         ct_data->person[ct_i].parent_entity_name,
         " = 'PERSON')"))
      ELSE
       CALL ct_push(concat("  when (new.",ct_data->person[ct_i].child_column," > 0)"))
      ENDIF
      CALL ct_push("declare")
      CALL ct_push("  npi number;")
      CALL ct_push("  ci number;")
      CALL ct_push("  cpi number;")
      CALL ct_push("  str varchar2(255);")
      CALL ct_push("  done number;")
      CALL ct_push("  spi number;")
      CALL ct_push("begin")
      CALL ct_push(concat("  if inserting or updating('",ct_data->person[ct_i].child_column,"') then"
        ))
      IF (size(trim(ct_data->person[ct_i].encntr_col,3)))
       CALL ct_push(concat("    if :new.",ct_data->person[ct_i].encntr_col," > 0 then"))
       CALL ct_push("      begin")
       CALL ct_push("        ci := 0;")
       CALL ct_push("        select max(c.person_combine_id) into ci from person_combine c")
       CALL ct_push(concat("         where c.encntr_id = :new.",ct_data->person[ct_i].encntr_col))
       CALL ct_push("           and c.active_ind = 1;")
       CALL ct_push("        if ci > 0 then")
       CALL ct_push("          cpi := 0;")
       CALL ct_push("          select c.to_person_id into cpi from person_combine c")
       CALL ct_push("           where c.person_combine_id = ci")
       CALL ct_push("             and not exists(select x.from_person_id")
       CALL ct_push("                              from person_combine x")
       CALL ct_push("                             where x.from_person_id = c.to_person_id")
       CALL ct_push("                               and x.person_combine_id > c.person_combine_id")
       CALL ct_push("                               and x.active_ind = 1")
       CALL ct_push("                               and x.encntr_id = 0);")
       CALL ct_push(concat("          if cpi > 0 and :new.",ct_data->person[ct_i].child_column,
         " != cpi then"))
       CALL ct_push(concat("            str:='ENCOUNTER ID ' || to_char(:new.",ct_data->person[ct_i].
         encntr_col,") || "))
       CALL ct_push("                 ' has been moved to a new person with an ID of ' ||")
       CALL ct_push("                 to_char(cpi) || '. This transaction will be rolled back.';")
       CALL ct_push("            raise_application_error(-20500,str);")
       CALL ct_push("          end if;")
       CALL ct_push("        end if;")
       CALL ct_push("      exception")
       CALL ct_push("        when no_data_found then")
       CALL ct_push("          null;")
       CALL ct_push("      end;")
       CALL ct_push("    end if;")
      ENDIF
      CALL ct_push("    select pc.to_person_id into npi")
      CALL ct_push("      from person_combine pc")
      CALL ct_push(concat("     where pc.from_person_id = :new.",ct_data->person[ct_i].child_column))
      CALL ct_push("       and pc.encntr_id = 0")
      CALL ct_push("       and pc.active_ind = 1")
      CALL ct_push("       and rownum <= 1 order by pc.updt_dt_tm desc;")
      CALL ct_push("    done := 0;")
      CALL ct_push("    begin")
      CALL ct_push("      while done = 0 loop")
      CALL ct_push("        select pc.to_person_id into spi")
      CALL ct_push("          from person_combine pc")
      CALL ct_push("         where pc.from_person_id = npi")
      CALL ct_push("           and pc.encntr_id = 0")
      CALL ct_push("           and pc.active_ind = 1")
      CALL ct_push("           and rownum <= 1 order by pc.updt_dt_tm desc;")
      CALL ct_push("        if done = 0 then")
      CALL ct_push("          npi := spi;")
      CALL ct_push("        end if;")
      CALL ct_push("      end loop;")
      CALL ct_push("    exception")
      CALL ct_push("      when no_data_found then")
      CALL ct_push("        done := 1;")
      CALL ct_push("        null;")
      CALL ct_push("    end;")
      CALL ct_push(concat("    str:='PERSON ID ' || to_char(:new.",ct_data->person[ct_i].child_column,
        ") || "))
      CALL ct_push("        ' is or has been combined to a new PERSON ID of ' ||")
      CALL ct_push("        to_char(npi) || '. This transaction will be rolled back.';")
      CALL ct_push("    raise_application_error(-20500,str);")
      CALL ct_push("  end if;")
      CALL ct_push("exception")
      CALL ct_push("  when no_data_found then")
      CALL ct_push("    null;")
      CALL ct_push("end;")
      CALL ct_run(0)
      IF ( NOT (ct_exists(ct_data->person[ct_i].trigger_name)))
       CALL ct_kick(concat("Unable to build trigger (",ct_data->person[ct_i].trigger_name,")."))
      ENDIF
     OF ct_auto:
      CALL ct_push(concat("create or replace trigger ",ct_data->person[ct_i].trigger_name," before"))
      CALL ct_push(concat("  update or insert on ",ct_data->person[ct_i].child_table," for each row")
       )
      CALL ct_push(concat("  when (new.",ct_data->person[ct_i].child_column," > 0)"))
      CALL ct_push("declare")
      CALL ct_push("  n_id number;")
      CALL ct_push("  c_id number;")
      CALL ct_push("  p_id number;")
      CALL ct_push("  n_id2 number;")
      CALL ct_push("  c_id2 number;")
      CALL ct_push("  ci number;")
      CALL ct_push("  cmb_action number;")
      CALL ct_push("  active_status number;")
      CALL ct_push("  done number;")
      CALL ct_push("begin")
      CALL ct_push(concat("  if inserting or updating('",ct_data->person[ct_i].child_column,"') then"
        ))
      IF (size(trim(ct_data->person[ct_i].encntr_col,3)))
       CALL ct_push(concat("    if :new.",ct_data->person[ct_i].encntr_col," > 0 then"))
       CALL ct_push("      begin")
       CALL ct_push("        ci := 0;")
       CALL ct_push("        select max(c.person_combine_id) into ci from person_combine c")
       CALL ct_push(concat("         where c.encntr_id = :new.",ct_data->person[ct_i].encntr_col))
       CALL ct_push("           and c.active_ind = 1;")
       CALL ct_push("        if ci > 0 then")
       CALL ct_push("          p_id := 0;")
       CALL ct_push("          select c.to_person_id into p_id from person_combine c")
       CALL ct_push("           where c.person_combine_id = ci")
       CALL ct_push("             and not exists(select x.from_person_id")
       CALL ct_push("                              from person_combine x")
       CALL ct_push("                             where x.from_person_id = c.to_person_id")
       CALL ct_push("                               and x.person_combine_id > c.person_combine_id")
       CALL ct_push("                               and x.active_ind = 1")
       CALL ct_push("                               and x.encntr_id = 0);")
       CALL ct_push("          if p_id > 0 then")
       CALL ct_push(concat("            :new.",ct_data->person[ct_i].child_column," := p_id;"))
       CALL ct_push("          end if;")
       CALL ct_push("        end if;")
       CALL ct_push("      exception")
       CALL ct_push("        when no_data_found then")
       CALL ct_push("          null;")
       CALL ct_push("      end;")
       CALL ct_push("    end if;")
      ENDIF
      CALL ct_push("    select c.to_person_id, c.person_combine_id into n_id, c_id")
      CALL ct_push("      from person_combine c")
      CALL ct_push(concat("     where c.from_person_id = :new.",ct_data->person[ct_i].child_column))
      CALL ct_push("       and c.encntr_id = 0")
      CALL ct_push("       and c.active_ind = 1")
      CALL ct_push("       and rownum <= 1 order by c.updt_dt_tm desc;")
      CALL ct_push("    done := 0;")
      CALL ct_push("    begin")
      CALL ct_push("      while done = 0 loop")
      CALL ct_push("        select c.to_person_id, c.person_combine_id into n_id2, c_id2")
      CALL ct_push("          from person_combine c")
      CALL ct_push("         where c.from_person_id = n_id")
      CALL ct_push("           and c.encntr_id = 0")
      CALL ct_push("           and c.active_ind = 1")
      CALL ct_push("           and rownum <= 1 order by c.updt_dt_tm desc;")
      CALL ct_push("        if done = 0 then")
      CALL ct_push("          n_id := n_id2;")
      CALL ct_push("          c_id := c_id2;")
      CALL ct_push("        end if;")
      CALL ct_push("      end loop;")
      CALL ct_push("    exception")
      CALL ct_push("      when no_data_found then")
      CALL ct_push("        done := 1;")
      CALL ct_push("        null;")
      CALL ct_push("    end;")
      CALL ct_push("    select c.code_value into cmb_action")
      CALL ct_push("      from code_value c")
      CALL ct_push("     where c.cdf_meaning = 'UPT'")
      CALL ct_push("       and c.code_set   = 327")
      CALL ct_push("       and c.active_ind = 1")
      CALL ct_push("       and c.begin_effective_dt_tm <= sysdate")
      CALL ct_push("       and c.end_effective_dt_tm >= sysdate;")
      CALL ct_push("    select c.code_value into active_status")
      CALL ct_push("      from code_value c")
      CALL ct_push("     where c.cdf_meaning = 'ACTIVE'")
      CALL ct_push("       and c.code_set   = 48")
      CALL ct_push("       and c.active_ind = 1")
      CALL ct_push("       and c.begin_effective_dt_tm <= sysdate")
      CALL ct_push("       and c.end_effective_dt_tm >= sysdate;")
      CALL ct_push("    insert into person_combine_det")
      CALL ct_push("      (person_combine_det_id, person_combine_id,")
      CALL ct_push("       updt_cnt, updt_dt_tm, updt_id, updt_task, updt_applctx,")
      CALL ct_push(
       "       active_ind, active_status_cd, active_status_dt_tm, active_status_prsnl_id,")
      CALL ct_push("       entity_name, entity_id,")
      CALL ct_push("       combine_action_cd, attribute_name,")
      CALL ct_push("       prev_active_ind, prev_active_status_cd, prev_end_eff_dt_tm,")
      CALL ct_push("       combine_desc_cd, to_record_ind)")
      CALL ct_push("    values")
      CALL ct_push("      (person_combine_seq.nextval, c_id,")
      CALL ct_push("       0, sysdate, 0, 0, 0,")
      CALL ct_push("       1, active_status, sysdate, 0,")
      CALL ct_push(concat("       '",ct_data->person[ct_i].child_table,"', :new.",ct_data->person[
        ct_i].child_pk,","))
      CALL ct_push(concat("     cmb_action, '",ct_data->person[ct_i].child_column,"',"))
      CALL ct_push("       0, 0, null,")
      CALL ct_push("       0, 0);")
      CALL ct_push(concat("    :new.",ct_data->person[ct_i].child_column," := n_id;"))
      CALL ct_push("  end if;")
      CALL ct_push("exception")
      CALL ct_push("  when no_data_found then")
      CALL ct_push("    null;")
      CALL ct_push("end;")
      CALL ct_run(0)
      IF ( NOT (ct_exists(ct_data->person[ct_i].trigger_name)))
       CALL ct_kick(concat("Unable to build AUTOMATIC trigger (",ct_data->person[ct_i].trigger_name,
         ")."))
      ENDIF
     OF ct_null:
      CALL ct_push(concat("create or replace trigger ",ct_data->person[ct_i].trigger_name," after"))
      CALL ct_push(concat("  update or insert on ",ct_data->person[ct_i].child_table," for each row")
       )
      CALL ct_push("begin")
      CALL ct_push("  null;")
      CALL ct_push("end;")
      CALL ct_run(0)
      IF ( NOT (ct_exists(ct_data->person[ct_i].trigger_name)))
       CALL ct_kick(concat("Unable to build NULL trigger (",ct_data->person[ct_i].trigger_name,")."))
      ENDIF
    ENDCASE
   ENDIF
 ENDFOR
 FOR (ct_i = 1 TO size(ct_data->encntr,5))
   IF (ct_column_exists(ct_data->encntr[ct_i].child_table,ct_data->encntr[ct_i].child_column))
    CASE (ct_type("ENCOUNTER",ct_data->encntr[ct_i].child_table))
     OF ct_default:
      CALL ct_push(concat("create or replace trigger ",ct_data->encntr[ct_i].trigger_name," after"))
      CALL ct_push(concat("  update or insert on ",ct_data->encntr[ct_i].child_table," for each row")
       )
      CALL ct_push(concat("  when (new.",ct_data->encntr[ct_i].child_column," > 0)"))
      CALL ct_push("declare")
      CALL ct_push("  nei number;")
      CALL ct_push("  str varchar2(255);")
      CALL ct_push("  done number;")
      CALL ct_push("  sei number;")
      CALL ct_push("begin")
      CALL ct_push(concat("  if inserting or updating('",ct_data->encntr[ct_i].child_column,"') then"
        ))
      CALL ct_push("    select ec.to_encntr_id into nei")
      CALL ct_push("      from encntr_combine ec")
      CALL ct_push(concat("     where ec.from_encntr_id = :new.",ct_data->encntr[ct_i].child_column))
      CALL ct_push("       and ec.active_ind = 1")
      CALL ct_push("       and rownum <= 1 order by ec.updt_dt_tm desc;")
      CALL ct_push("    done := 0;")
      CALL ct_push("    begin")
      CALL ct_push("      while done = 0 loop")
      CALL ct_push("        select ec.to_encntr_id into sei")
      CALL ct_push("          from encntr_combine ec")
      CALL ct_push("         where ec.from_encntr_id = nei")
      CALL ct_push("           and ec.active_ind = 1")
      CALL ct_push("           and rownum <= 1 order by ec.updt_dt_tm desc;")
      CALL ct_push("        if done = 0 then")
      CALL ct_push("          nei := sei;")
      CALL ct_push("        end if;")
      CALL ct_push("      end loop;")
      CALL ct_push("    exception")
      CALL ct_push("      when no_data_found then")
      CALL ct_push("        done := 1;")
      CALL ct_push("        null;")
      CALL ct_push("    end;")
      CALL ct_push(concat("    str:='ENCNTR ID ' || to_char(:new.",ct_data->encntr[ct_i].child_column,
        ") || "))
      CALL ct_push("        ' is or has been combined to a new ENCNTR ID of ' ||")
      CALL ct_push("        to_char(nei) || '. This transaction will be rolled back.';")
      CALL ct_push("    raise_application_error(-20500,str);")
      CALL ct_push("  end if;")
      CALL ct_push("exception")
      CALL ct_push("  when no_data_found then")
      CALL ct_push("    null;")
      CALL ct_push("end;")
      CALL ct_run(0)
      IF ( NOT (ct_exists(ct_data->encntr[ct_i].trigger_name)))
       CALL ct_kick(concat("Unable to build trigger (",ct_data->encntr[ct_i].trigger_name,")."))
      ENDIF
     OF ct_auto:
      CALL ct_push(concat("create or replace trigger ",ct_data->encntr[ct_i].trigger_name," before"))
      CALL ct_push(concat("  update or insert on ",ct_data->encntr[ct_i].child_table," for each row")
       )
      CALL ct_push(concat("  when (new.",ct_data->encntr[ct_i].child_column," > 0)"))
      CALL ct_push("declare")
      CALL ct_push("  n_id number;")
      CALL ct_push("  c_id number;")
      CALL ct_push("  n_id2 number;")
      CALL ct_push("  c_id2 number;")
      CALL ct_push("  cmb_action number;")
      CALL ct_push("  active_status number;")
      CALL ct_push("  done number;")
      CALL ct_push("begin")
      CALL ct_push(concat("  if inserting or updating('",ct_data->encntr[ct_i].child_column,"') then"
        ))
      CALL ct_push("    select c.to_encntr_id, c.encntr_combine_id into n_id, c_id")
      CALL ct_push("      from encntr_combine c")
      CALL ct_push(concat("     where c.from_encntr_id = :new.",ct_data->encntr[ct_i].child_column))
      CALL ct_push("       and c.active_ind = 1")
      CALL ct_push("       and rownum <= 1 order by c.updt_dt_tm desc;")
      CALL ct_push("    done := 0;")
      CALL ct_push("    begin")
      CALL ct_push("      while done = 0 loop")
      CALL ct_push("        select c.to_encntr_id, c.encntr_combine_id into n_id2, c_id2")
      CALL ct_push("          from encntr_combine c")
      CALL ct_push("         where c.from_encntr_id = n_id")
      CALL ct_push("           and c.active_ind = 1")
      CALL ct_push("           and rownum <= 1 order by c.updt_dt_tm desc;")
      CALL ct_push("        if done = 0 then")
      CALL ct_push("          n_id := n_id2;")
      CALL ct_push("          c_id := c_id2;")
      CALL ct_push("        end if;")
      CALL ct_push("      end loop;")
      CALL ct_push("    exception")
      CALL ct_push("      when no_data_found then")
      CALL ct_push("        done := 1;")
      CALL ct_push("        null;")
      CALL ct_push("    end;")
      CALL ct_push("    select c.code_value into cmb_action")
      CALL ct_push("      from code_value c")
      CALL ct_push("     where c.cdf_meaning = 'UPT'")
      CALL ct_push("       and c.code_set   = 327")
      CALL ct_push("       and c.active_ind = 1")
      CALL ct_push("       and c.begin_effective_dt_tm <= sysdate")
      CALL ct_push("       and c.end_effective_dt_tm >= sysdate;")
      CALL ct_push("    select c.code_value into active_status")
      CALL ct_push("      from code_value c")
      CALL ct_push("     where c.cdf_meaning = 'ACTIVE'")
      CALL ct_push("       and c.code_set   = 48")
      CALL ct_push("       and c.active_ind = 1")
      CALL ct_push("       and c.begin_effective_dt_tm <= sysdate")
      CALL ct_push("       and c.end_effective_dt_tm >= sysdate;")
      CALL ct_push("    insert into encntr_combine_det")
      CALL ct_push("      (encntr_combine_det_id, encntr_combine_id,")
      CALL ct_push("       updt_cnt, updt_dt_tm, updt_id, updt_task, updt_applctx,")
      CALL ct_push(
       "       active_ind, active_status_cd, active_status_dt_tm, active_status_prsnl_id,")
      CALL ct_push("       entity_name, entity_id,")
      CALL ct_push("       combine_action_cd, attribute_name,")
      CALL ct_push("       prev_active_ind, prev_active_status_cd, prev_end_eff_dt_tm,")
      CALL ct_push("       combine_desc_cd, to_record_ind)")
      CALL ct_push("    values")
      CALL ct_push("      (encounter_combine_seq.nextval, c_id,")
      CALL ct_push("       0, sysdate, 0, 0, 0,")
      CALL ct_push("       1, active_status, sysdate, 0,")
      CALL ct_push(concat("       '",ct_data->encntr[ct_i].child_table,"', :new.",ct_data->encntr[
        ct_i].child_pk,","))
      CALL ct_push(concat("     cmb_action, '",ct_data->encntr[ct_i].child_column,"',"))
      CALL ct_push("       0, 0, null,")
      CALL ct_push("       0, 0);")
      CALL ct_push(concat("    :new.",ct_data->encntr[ct_i].child_column," := n_id;"))
      CALL ct_push("  end if;")
      CALL ct_push("exception")
      CALL ct_push("  when no_data_found then")
      CALL ct_push("    null;")
      CALL ct_push("end;")
      CALL ct_run(0)
      IF ( NOT (ct_exists(ct_data->encntr[ct_i].trigger_name)))
       CALL ct_kick(concat("Unable to build AUTOMATIC trigger (",ct_data->encntr[ct_i].trigger_name,
         ")."))
      ENDIF
     OF ct_null:
      CALL ct_push(concat("create or replace trigger ",ct_data->encntr[ct_i].trigger_name," after"))
      CALL ct_push(concat("  update or insert on ",ct_data->encntr[ct_i].child_table," for each row")
       )
      CALL ct_push("begin")
      CALL ct_push("  null;")
      CALL ct_push("end;")
      CALL ct_run(0)
      IF ( NOT (ct_exists(ct_data->encntr[ct_i].trigger_name)))
       CALL ct_kick(concat("Unable to build NULL trigger (",ct_data->encntr[ct_i].trigger_name,")."))
      ENDIF
    ENDCASE
   ENDIF
 ENDFOR
#3000_continue
 SET ct_i = 0
 SELECT INTO "nl:"
  ct_temp = count(*)
  FROM user_triggers t
  WHERE t.trigger_name="TRG_?CMB?_*"
  DETAIL
   ct_i = ct_temp
  WITH nocounter
 ;end select
 SET readme_data->status = "S"
 SET readme_data->message = concat("Combine triggers successfully built.  ",trim(cnvtstring(ct_i),3),
  " triggers exist.")
 EXECUTE dm_readme_status
 IF ( NOT (readme_data->readme_id))
  CALL echo(readme_data->message)
 ENDIF
#3999_build_exit
#9999_exit_program
END GO
