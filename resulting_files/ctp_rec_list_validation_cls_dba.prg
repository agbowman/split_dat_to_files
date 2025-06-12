CREATE PROGRAM ctp_rec_list_validation_cls:dba
 CREATE CLASS ctp_rec_list_validation_cls
 init
 DECLARE _::found = i1 WITH constant(1)
 DECLARE _::notfound = i1 WITH constant(2)
 DECLARE _::duplicate = i1 WITH constant(3)
 DECLARE _::reevaluate = i1 WITH constant(4)
 DECLARE _::empty = i1 WITH constant(5)
 DECLARE _::exactcase = i1 WITH constant(6)
 DECLARE _::numeric = i1 WITH constant(1)
 DECLARE _::txt = i1 WITH constant(2)
 IF ( NOT (validate(PRIVATE::failover)))
  DECLARE PRIVATE::failover = i2 WITH constant(0)
 ENDIF
 DECLARE _::key_data_type = i1 WITH noconstant(_::txt)
 DECLARE PRIVATE::id_only = i2 WITH noconstant(0)
 RECORD _::reference(
   1 list[*]
     2 display = vc
     2 id = f8
 )
 RECORD _::id(
   1 list[*]
     2 value = f8
     2 display = vc
     2 status_flag = i1
     2 reference_position = i4
 )
 SUBROUTINE (_::getstatus(idx=i4) =i1)
   RETURN(_::id->list[idx].status_flag)
 END ;Subroutine
 SUBROUTINE (_::copyreferencedata(record_name=vc,list_name=vc,field_id=vc,field_display=vc(value," ")
  ) =null)
   DECLARE rec_list = vc WITH protect, noconstant(build(record_name,"->",list_name))
   DECLARE rec_field_id = vc WITH protect, noconstant(build(rec_list,"[d.seq].",field_id))
   DECLARE rec_field_display = vc WITH protect, noconstant(build(rec_list,"[d.seq].",field_display))
   DECLARE rec_size = i4 WITH protect, noconstant(parser(build("size(",rec_list,",5)")))
   SET stat = initrec(_::reference)
   IF (rec_size=0)
    RETURN
   ENDIF
   IF (size(trim(field_display)) > 0)
    SET rec_field_display = build("substring(1,500,",rec_field_display,")")
   ELSE
    SET PRIVATE::id_only = true
    SET rec_field_display = "NULL"
   ENDIF
   SELECT INTO "nl:"
    id = parser(rec_field_id), display = parser(rec_field_display)
    FROM (dummyt d  WITH seq = rec_size)
    ORDER BY d.seq
    HEAD REPORT
     stat = alterlist(_::reference->list,rec_size)
    DETAIL
     _::reference->list[d.seq].id = id, _::reference->list[d.seq].display = display
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (_::evaluate(record_name=vc,list_name=vc,field_name=vc,option=i1(value,0)) =null)
   RECORD input_index(
     1 list[*]
       2 key_txt = vc
       2 key_id = f8
       2 empty_ind = i2
       2 instance[*]
         3 ptr = i4
   ) WITH protect
   RECORD reference_index(
     1 list[*]
       2 txt = vc
       2 id = f8
       2 display = vc
       2 duplicate_ind = i2
       2 position = i4
   ) WITH protect
   DECLARE reevaluate_ind = i1 WITH protect, noconstant(0)
   DECLARE rec_list_field = vc WITH protect, noconstant(build(record_name,"->",list_name,"[d.seq].",
     field_name))
   DECLARE rec_list = vc WITH protect, noconstant(build(record_name,"->",list_name))
   DECLARE rec_list_size = i4 WITH protect, noconstant(parser(build("size(",rec_list,",5)")))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE ptr = i4 WITH protect, noconstant(0)
   DECLARE item = i4 WITH protect, noconstant(0)
   DECLARE inst = i4 WITH protect, noconstant(0)
   IF ((((option=_::reevaluate)) OR (PRIVATE::id_only)) )
    SET _::key_data_type = _::numeric
   ELSE
    SET _::key_data_type = _::txt
   ENDIF
   SELECT
    IF ((option=_::reevaluate))
     key_value = parser(build("cnvtreal(",rec_list_field,")"))
     PLAN (d
      WHERE (_::id->list[d.seq].status_flag=_::reevaluate))
    ELSEIF (PRIVATE::id_only)
     key_value = parser(build("cnvtreal(",rec_list_field,")"))
    ELSEIF ((option=_::exactcase))
     key_value = parser(build("substring(1,500,",rec_list_field,")"))
    ELSE
    ENDIF
    INTO "nl:"
    key_value = parser(build("cnvtupper(substring(1,500,",rec_list_field,"))"))
    FROM (dummyt d  WITH seq = rec_list_size)
    PLAN (d)
    ORDER BY key_value
    HEAD REPORT
     k_cnt = 0
    HEAD key_value
     k_cnt += 1
     IF (k_cnt > size(input_index->list,5))
      stat = alterlist(input_index->list,(k_cnt+ 10000))
     ENDIF
     CALL PRIVATE::saveinputkey(0), p_cnt = 0
    DETAIL
     p_cnt += 1
     IF (p_cnt > size(input_index->list[k_cnt].instance,5))
      stat = alterlist(input_index->list[k_cnt].instance,(p_cnt+ 10000))
     ENDIF
     input_index->list[k_cnt].instance[p_cnt].ptr = d.seq
    FOOT  key_value
     stat = alterlist(input_index->list[k_cnt].instance,p_cnt)
    FOOT REPORT
     stat = alterlist(input_index->list,k_cnt)
    WITH nocounter
   ;end select
   IF (size(_::reference->list,5) > 0)
    SELECT
     IF ((_::key_data_type=_::numeric))
      key_value = _::reference->list[d.seq].id, id = _::reference->list[d.seq].id
     ELSEIF ((option=_::exactcase))
      key_value = substring(1,500,_::reference->list[d.seq].display), id = _::reference->list[d.seq].
      id
     ELSE
      key_value = cnvtupper(substring(1,500,_::reference->list[d.seq].display)), id = _::reference->
      list[d.seq].id
     ENDIF
     INTO "nl:"
     FROM (dummyt d  WITH seq = size(_::reference->list,5))
     ORDER BY key_value, id
     HEAD REPORT
      cnt = 0
     HEAD key_value
      cnt += 1
      IF (cnt > size(reference_index->list,5))
       stat = alterlist(reference_index->list,(cnt+ 999))
      ENDIF
      CALL PRIVATE::savereferencekey(0), reference_index->list[cnt].id = id, reference_index->list[
      cnt].display = _::reference->list[d.seq].display,
      reference_index->list[cnt].position = d.seq, instance_cnt = 0
     DETAIL
      instance_cnt += 1
     FOOT  key_value
      IF (instance_cnt > 1)
       reference_index->list[cnt].duplicate_ind = true
      ENDIF
      stat = alterlist(reference_index->list,cnt)
     WITH nocounter
    ;end select
   ENDIF
   IF ((option != _::reevaluate))
    SET stat = initrec(_::id)
    SET stat = alterlist(_::id->list,rec_list_size)
   ENDIF
   FOR (item = 1 TO size(input_index->list,5))
    IF ((_::key_data_type=_::numeric))
     SET pos = locatevalsort(idx,1,size(reference_index->list,5),input_index->list[item].key_id,
      reference_index->list[idx].id)
    ELSE
     SET pos = locatevalsort(idx,1,size(reference_index->list,5),input_index->list[item].key_txt,
      reference_index->list[idx].txt)
     IF (PRIVATE::failover
      AND pos <= 0)
      SET pos = locateval(idx,1,size(reference_index->list,5),input_index->list[item].key_txt,
       reference_index->list[idx].txt)
     ENDIF
    ENDIF
    FOR (inst = 1 TO size(input_index->list[item].instance,5))
     SET ptr = input_index->list[item].instance[inst].ptr
     IF (pos > 0)
      IF (input_index->list[item].empty_ind)
       SET _::id->list[ptr].status_flag = _::empty
      ELSEIF ( NOT (reference_index->list[pos].duplicate_ind))
       SET _::id->list[ptr].value = reference_index->list[pos].id
       SET _::id->list[ptr].display = reference_index->list[pos].display
       SET _::id->list[ptr].reference_position = reference_index->list[pos].position
       SET _::id->list[ptr].status_flag = _::found
      ELSE
       SET _::id->list[ptr].status_flag = _::duplicate
      ENDIF
     ELSE
      IF ((option != _::reevaluate)
       AND isnumeric(input_index->list[item].key_txt) > 0
       AND  NOT (PRIVATE::id_only))
       SET _::id->list[ptr].status_flag = _::reevaluate
       SET reevaluate_ind = true
      ELSEIF (input_index->list[item].empty_ind)
       SET _::id->list[ptr].status_flag = _::empty
      ELSE
       SET _::id->list[ptr].status_flag = _::notfound
      ENDIF
     ENDIF
    ENDFOR
   ENDFOR
   IF (reevaluate_ind)
    CALL _::evaluate(record_name,list_name,field_name,_::reevaluate)
   ELSE
    FOR (idx = 1 TO rec_list_size)
      IF ((_::id->list[idx].status_flag=0))
       SET _::id->list[idx].status_flag = _::notfound
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 DECLARE PRIVATE::saveinputkey(null) = null
 SUBROUTINE PRIVATE::saveinputkey(null)
   IF ((_::key_data_type=_::numeric))
    SET input_index->list[k_cnt].key_id = key_value
    IF (key_value=0)
     SET input_index->list[k_cnt].empty_ind = true
    ENDIF
   ELSE
    SET input_index->list[k_cnt].key_txt = key_value
    IF (size(trim(key_value))=0)
     SET input_index->list[k_cnt].empty_ind = true
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE PRIVATE::savereferencekey(null) = null
 SUBROUTINE PRIVATE::savereferencekey(null)
   IF ((_::key_data_type=_::numeric))
    SET reference_index->list[cnt].id = key_value
   ELSE
    SET reference_index->list[cnt].txt = key_value
   ENDIF
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
END GO
