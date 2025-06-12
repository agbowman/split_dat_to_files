CREATE PROGRAM dm_child_records:dba
 SET childcount1 = 0
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET rchildren
 RECORD rchildren(
   1 qual1[100]
     2 child_table = c50
     2 person_constraint = c50
     2 encntr_constraint = c50
     2 fk_attribute = c50
     2 pk_attribute = c50
     2 fk_encntr_attribute = c50
     2 count_of_froms = f8
     2 count_of_tos = f8
 )
 IF ((request->parent_table="PERSON")
  AND (request->xxx_combine[1].encntr_id != 0))
  SELECT INTO "nl:"
   b.table_name, b.constraint_name, e.constraint_name
   FROM user_constraints e,
    user_constraints d,
    user_constraints b,
    user_constraints a
   WHERE a.owner="V500"
    AND a.owner=b.owner
    AND a.constraint_name=b.r_constraint_name
    AND a.table_name="PERSON"
    AND a.constraint_type="P"
    AND b.constraint_type="R"
    AND d.owner=a.owner
    AND d.table_name="ENCOUNTER"
    AND d.constraint_type="P"
    AND d.constraint_name=e.r_constraint_name
    AND e.table_name=b.table_name
    AND e.constraint_type="R"
   DETAIL
    childcount1 += 1
    IF (mod(childcount1,100)=1
     AND childcount1 != 1)
     stat = alter(rchildren->qual1,(childcount1+ 99))
    ENDIF
    rchildren->qual1[childcount1].child_table = b.table_name, rchildren->qual1[childcount1].
    person_constraint = b.constraint_name, rchildren->qual1[childcount1].encntr_constraint = e
    .constraint_name
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   b.table_name, b.constraint_name
   FROM user_constraints b,
    user_constraints a
   WHERE a.owner="V500"
    AND a.owner=b.owner
    AND a.constraint_name=b.r_constraint_name
    AND (a.table_name=request->parent_table)
    AND a.constraint_type="P"
    AND b.constraint_type="R"
   DETAIL
    childcount1 += 1
    IF (mod(childcount1,100)=1
     AND childcount1 != 1)
     stat = alter(rchildren->qual1,(childcount1+ 99))
    ENDIF
    rchildren->qual1[childcount1].child_table = b.table_name, rchildren->qual1[childcount1].
    person_constraint = b.constraint_name
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->parent_table="PERSON")
  AND (request->xxx_combine[1].encntr_id != 0))
  SELECT INTO "nl:"
   c.*
   FROM user_cons_columns c,
    user_cons_columns f,
    user_constraints uc,
    user_cons_columns ucc,
    (dummyt d  WITH seq = value(childcount1))
   PLAN (d)
    JOIN (c
    WHERE c.owner="V500"
     AND c.position=1
     AND (c.constraint_name=rchildren->qual1[d.seq].person_constraint))
    JOIN (f
    WHERE f.owner="V500"
     AND f.position=1
     AND (f.constraint_name=rchildren->qual1[d.seq].encntr_constraint))
    JOIN (uc
    WHERE uc.owner="V500"
     AND uc.constraint_type="P"
     AND (uc.table_name=rchildren->qual1[d.seq].child_table))
    JOIN (ucc
    WHERE ucc.owner="V500"
     AND ucc.constraint_name=uc.constraint_name
     AND ucc.position=1)
   DETAIL
    rchildren->qual1[d.seq].fk_attribute = c.column_name, rchildren->qual1[d.seq].pk_attribute = ucc
    .column_name, rchildren->qual1[d.seq].fk_encntr_attribute = f.column_name
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   c.*
   FROM user_cons_columns c,
    user_constraints uc,
    user_cons_columns ucc,
    (dummyt d  WITH seq = value(childcount1))
   PLAN (d)
    JOIN (c
    WHERE c.owner="V500"
     AND c.position=1
     AND (c.constraint_name=rchildren->qual1[d.seq].person_constraint))
    JOIN (uc
    WHERE uc.owner="V500"
     AND uc.constraint_type="P"
     AND (uc.table_name=rchildren->qual1[d.seq].child_table))
    JOIN (ucc
    WHERE ucc.owner="V500"
     AND ucc.constraint_name=uc.constraint_name
     AND ucc.position=1)
   DETAIL
    rchildren->qual1[d.seq].fk_attribute = c.column_name, rchildren->qual1[d.seq].pk_attribute = ucc
    .column_name
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->parent_table="PERSON")
  AND (request->xxx_combine[1].encntr_id != 0))
  FOR (n = 1 TO childcount1)
    IF (trim(rchildren->qual1[n].fk_attribute) != "")
     CALL parser(concat("select into 'nl:' x.",trim(rchildren->qual1[n].fk_attribute)))
     CALL parser(concat("from ",trim(rchildren->qual1[n].child_table)," x"))
     CALL parser(build("where x.",trim(rchildren->qual1[n].fk_attribute)," = ",request->xxx_combine[1
       ].from_xxx_id))
     CALL parser(build("and x.",trim(rchildren->qual1[n].fk_encntr_attribute)," = ",request->
       xxx_combine[1].encntr_id))
     CALL parser("head report")
     CALL parser("rChildren->qual1[n]->count_of_froms = 0")
     CALL parser("detail")
     CALL parser("rChildren->qual1[n]->count_of_froms = rChildren->qual1[n]->count_of_froms + 1")
     CALL parser("with nocounter go")
    ENDIF
  ENDFOR
  FOR (m = 1 TO childcount1)
    IF (trim(rchildren->qual1[m].fk_attribute) != "")
     CALL parser(concat("select into 'nl:' x.",trim(rchildren->qual1[m].fk_attribute)))
     CALL parser(concat("from ",trim(rchildren->qual1[m].child_table)," x"))
     CALL parser(build("where x.",trim(rchildren->qual1[m].fk_attribute)," = ",request->xxx_combine[1
       ].to_xxx_id))
     CALL parser(build("and x.",trim(rchildren->qual1[m].fk_encntr_attribute)," = ",request->
       xxx_combine[1].encntr_id))
     CALL parser("head report")
     CALL parser("rChildren->qual1[m]->count_of_tos = 0")
     CALL parser("detail")
     CALL parser("rChildren->qual1[m]->count_of_tos = rChildren->qual1[m]->count_of_tos + 1")
     CALL parser("with nocounter go")
    ENDIF
  ENDFOR
 ELSE
  FOR (n = 1 TO childcount1)
    IF (trim(rchildren->qual1[n].fk_attribute) != "")
     CALL parser(concat("select into 'nl:' x.",trim(rchildren->qual1[n].fk_attribute)))
     CALL parser(concat("from ",trim(rchildren->qual1[n].child_table)," x"))
     CALL parser(build("where x.",trim(rchildren->qual1[n].fk_attribute)," = ",request->xxx_combine[1
       ].from_xxx_id))
     CALL parser("head report")
     CALL parser("rChildren->qual1[n]->count_of_froms = 0")
     CALL parser("detail")
     CALL parser("rChildren->qual1[n]->count_of_froms = rChildren->qual1[n]->count_of_froms + 1")
     CALL parser("with nocounter go")
    ENDIF
  ENDFOR
  FOR (m = 1 TO childcount1)
    IF (trim(rchildren->qual1[m].fk_attribute) != "")
     CALL parser(concat("select into 'nl:' x.",trim(rchildren->qual1[m].fk_attribute)))
     CALL parser(concat("from ",trim(rchildren->qual1[m].child_table)," x"))
     CALL parser(build("where x.",trim(rchildren->qual1[m].fk_attribute)," = ",request->xxx_combine[1
       ].to_xxx_id))
     CALL parser("head report")
     CALL parser("rChildren->qual1[m]->count_of_tos = 0")
     CALL parser("detail")
     CALL parser("rChildren->qual1[m]->count_of_tos = rChildren->qual1[m]->count_of_tos + 1")
     CALL parser("with nocounter go")
    ENDIF
  ENDFOR
 ENDIF
 SET childcount2 = childcount1
 IF ((request->parent_table="PERSON")
  AND (request->xxx_combine[1].encntr_id=0))
  SET dummy_var = 0
  CALL address_sub(dummy_var)
  CALL phone_sub(dummy_var)
  CALL encntr_prsnl_reltn_sub(dummy_var)
  CALL prsnl_alias_sub(dummy_var)
  CALL prsnl_group_reltn_sub(dummy_var)
  CALL prsnl_info_sub(dummy_var)
  CALL custom_pt_list_sub(dummy_var)
  CALL priv_loc_reltn_sub(dummy_var)
 ELSE
  SET dummy_var = 0
  CALL encntr_prsnl_reltn_sub(dummy_var)
  CALL encounter_sub(dummy_var)
 ENDIF
 SELECT INTO child_rec_log
  d.seq
  FROM (dummyt d  WITH seq = value(childcount2))
  ORDER BY rchildren->qual1[d.seq].child_table
  HEAD REPORT
   col 1, "Child tables of ", request->parent_table,
   row + 1, col 1, "From_xxx_id : ",
   request->xxx_combine[1].from_xxx_id, row + 1, col 1,
   "To_xxx_id   : ", request->xxx_combine[1].to_xxx_id, row + 1,
   col 1, "Encntr_id   : ", request->xxx_combine[1].encntr_id,
   row + 1, col 1, " ",
   row + 1, col 1, " ",
   row + 1
  DETAIL
   IF ((((rchildren->qual1[d.seq].count_of_froms > 0)) OR ((rchildren->qual1[d.seq].count_of_tos > 0)
   )) )
    col 1, "Table: ", rchildren->qual1[d.seq].child_table,
    " Froms: ", rchildren->qual1[d.seq].count_of_froms, " Tos: ",
    rchildren->qual1[d.seq].count_of_tos, row + 1
   ENDIF
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading
 ;end select
 SUBROUTINE address_sub(main_dummy)
   SET childcount2 += 1
   SET rchildren->qual1[childcount2].child_table = "ADDRESS"
   SELECT INTO "nl:"
    x.parent_entity_id
    FROM address x
    WHERE (x.parent_entity_id=request->xxx_combine[1].from_xxx_id)
     AND (x.parent_entity_name=request->parent_table)
    HEAD REPORT
     rchildren->qual1[childcount2].count_of_froms = 0
    DETAIL
     rchildren->qual1[childcount2].count_of_froms += 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x.parent_entity_id
    FROM address x
    WHERE (x.parent_entity_id=request->xxx_combine[1].to_xxx_id)
     AND (x.parent_entity_name=request->parent_table)
    HEAD REPORT
     rchildren->qual1[childcount2].count_of_tos = 0
    DETAIL
     rchildren->qual1[childcount2].count_of_tos += 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE phone_sub(main_dummy)
   SET childcount2 += 1
   SET rchildren->qual1[childcount2].child_table = "PHONE"
   SELECT INTO "nl:"
    x.parent_entity_id
    FROM phone x
    WHERE (x.parent_entity_id=request->xxx_combine[1].from_xxx_id)
     AND (x.parent_entity_name=request->parent_table)
    HEAD REPORT
     rchildren->qual1[childcount2].count_of_froms = 0
    DETAIL
     rchildren->qual1[childcount2].count_of_froms += 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x.parent_entity_id
    FROM phone x
    WHERE (x.parent_entity_id=request->xxx_combine[1].to_xxx_id)
     AND (x.parent_entity_name=request->parent_table)
    HEAD REPORT
     rchildren->qual1[childcount2].count_of_tos = 0
    DETAIL
     rchildren->qual1[childcount2].count_of_tos += 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE encntr_prsnl_reltn_sub(main_dummy)
   IF ((request->xxx_combine[1].encntr_id=0))
    SET childcount2 += 1
    SET rchildren->qual1[childcount2].child_table = "ENCNTR_PRSNL_RELTN"
    SELECT INTO "nl:"
     x.prsnl_person_id
     FROM encntr_prsnl_reltn x
     WHERE (x.prsnl_person_id=request->xxx_combine[1].from_xxx_id)
     HEAD REPORT
      rchildren->qual1[childcount2].count_of_froms = 0
     DETAIL
      rchildren->qual1[childcount2].count_of_froms += 1
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     x.prsnl_person_id
     FROM encntr_prsnl_reltn x
     WHERE (x.prsnl_person_id=request->xxx_combine[1].to_xxx_id)
     HEAD REPORT
      rchildren->qual1[childcount2].count_of_tos = 0
     DETAIL
      rchildren->qual1[childcount2].count_of_tos += 1
     WITH nocounter
    ;end select
   ELSE
    SET childcount2 += 1
    SET rchildren->qual1[childcount2].child_table = "ENCNTR_PRSNL_RELTN"
    SELECT INTO "nl:"
     x.prsnl_person_id
     FROM encntr_prsnl_reltn x
     WHERE (x.prsnl_person_id=request->xxx_combine[1].from_xxx_id)
      AND (x.encntr_id=request->xxx_combine[1].encntr_id)
     HEAD REPORT
      rchildren->qual1[childcount2].count_of_froms = 0
     DETAIL
      rchildren->qual1[childcount2].count_of_froms += 1
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     x.prsnl_person_id
     FROM encntr_prsnl_reltn x
     WHERE (x.prsnl_person_id=request->xxx_combine[1].to_xxx_id)
      AND (x.encntr_id=request->xxx_combine[1].encntr_id)
     HEAD REPORT
      rchildren->qual1[childcount2].count_of_tos = 0
     DETAIL
      rchildren->qual1[childcount2].count_of_tos += 1
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE prsnl_alias_sub(main_dummy)
   SET childcount2 += 1
   SET rchildren->qual1[childcount2].child_table = "PRSNL_ALIAS"
   SELECT INTO "nl:"
    x.person_id
    FROM prsnl_alias x
    WHERE (x.person_id=request->xxx_combine[1].from_xxx_id)
    HEAD REPORT
     rchildren->qual1[childcount2].count_of_froms = 0
    DETAIL
     rchildren->qual1[childcount2].count_of_froms += 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x.person_id
    FROM prsnl_alias x
    WHERE (x.person_id=request->xxx_combine[1].to_xxx_id)
    HEAD REPORT
     rchildren->qual1[childcount2].count_of_tos = 0
    DETAIL
     rchildren->qual1[childcount2].count_of_tos += 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE prsnl_group_reltn_sub(main_dummy)
   SET childcount2 += 1
   SET rchildren->qual1[childcount2].child_table = "PRSNL_GROUP_RELTN"
   SELECT INTO "nl:"
    x.person_id
    FROM prsnl_group_reltn x
    WHERE (x.person_id=request->xxx_combine[1].from_xxx_id)
    HEAD REPORT
     rchildren->qual1[childcount2].count_of_froms = 0
    DETAIL
     rchildren->qual1[childcount2].count_of_froms += 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x.person_id
    FROM prsnl_group_reltn x
    WHERE (x.person_id=request->xxx_combine[1].to_xxx_id)
    HEAD REPORT
     rchildren->qual1[childcount2].count_of_tos = 0
    DETAIL
     rchildren->qual1[childcount2].count_of_tos += 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE prsnl_info_sub(main_dummy)
   SET childcount2 += 1
   SET rchildren->qual1[childcount2].child_table = "PRSNL_INFO"
   SELECT INTO "nl:"
    x.person_id
    FROM prsnl_info x
    WHERE (x.person_id=request->xxx_combine[1].from_xxx_id)
    HEAD REPORT
     rchildren->qual1[childcount2].count_of_froms = 0
    DETAIL
     rchildren->qual1[childcount2].count_of_froms += 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x.person_id
    FROM prsnl_info x
    WHERE (x.person_id=request->xxx_combine[1].to_xxx_id)
    HEAD REPORT
     rchildren->qual1[childcount2].count_of_tos = 0
    DETAIL
     rchildren->qual1[childcount2].count_of_tos += 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE custom_pt_list_sub(main_dummy)
   SET childcount2 += 1
   SET rchildren->qual1[childcount2].child_table = "CUSTOM_PT_LIST"
   SELECT INTO "nl:"
    x.person_id
    FROM custom_pt_list x
    WHERE (x.person_id=request->xxx_combine[1].from_xxx_id)
    HEAD REPORT
     rchildren->qual1[childcount2].count_of_froms = 0
    DETAIL
     rchildren->qual1[childcount2].count_of_froms += 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x.person_id
    FROM custom_pt_list x
    WHERE (x.person_id=request->xxx_combine[1].to_xxx_id)
    HEAD REPORT
     rchildren->qual1[childcount2].count_of_tos = 0
    DETAIL
     rchildren->qual1[childcount2].count_of_tos += 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE priv_loc_reltn_sub(main_dummy)
   SET childcount2 += 1
   SET rchildren->qual1[childcount2].child_table = "PRIV_LOC_RELTN"
   SELECT INTO "nl:"
    x.person_id
    FROM priv_loc_reltn x
    WHERE (x.person_id=request->xxx_combine[1].from_xxx_id)
    HEAD REPORT
     rchildren->qual1[childcount2].count_of_froms = 0
    DETAIL
     rchildren->qual1[childcount2].count_of_froms += 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x.person_id
    FROM priv_loc_reltn x
    WHERE (x.person_id=request->xxx_combine[1].to_xxx_id)
    HEAD REPORT
     rchildren->qual1[childcount2].count_of_tos = 0
    DETAIL
     rchildren->qual1[childcount2].count_of_tos += 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE encounter_sub(main_dummy)
   SET childcount2 += 1
   SET rchildren->qual1[childcount2].child_table = "ENCOUNTER"
   SELECT INTO "nl:"
    x.person_id
    FROM encounter x
    WHERE (x.person_id=request->xxx_combine[1].from_xxx_id)
     AND (x.encntr_id=request->xxx_combine[1].encntr_id)
    HEAD REPORT
     rchildren->qual1[childcount2].count_of_froms = 0
    DETAIL
     rchildren->qual1[childcount2].count_of_froms += 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x.person_id
    FROM encounter x
    WHERE (x.person_id=request->xxx_combine[1].to_xxx_id)
    HEAD REPORT
     rchildren->qual1[childcount2].count_of_tos = 0
    DETAIL
     rchildren->qual1[childcount2].count_of_tos += 1
    WITH nocounter
   ;end select
 END ;Subroutine
END GO
