CREATE PROGRAM dcp_upd_syn_witness_req_data:dba
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE syncnt = i4 WITH protect, noconstant(0)
 DECLARE lobjcnt = i4 WITH protect, noconstant(0)
 DECLARE parentseq = f8 WITH protect, noconstant(0.0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE logicaldomainind = i2 WITH protect, noconstant(0)
 DECLARE synlistcnt = i4 WITH protect, noconstant(0)
 DECLARE filtertype = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE temp_delete_cnt = i4 WITH protect, noconstant(0)
 DECLARE temp_insert_cnt = i4 WITH protect, noconstant(0)
 DECLARE temp_grp_id_cnt = i4 WITH protect, noconstant(0)
 DECLARE synobjcnt = i4 WITH protect, noconstant(0)
 DECLARE obj_insert_cnt = i4 WITH protect, noconstant(0)
 DECLARE delete_flag = i4 WITH protect, constant(1.0)
 DECLARE insert_flag = i4 WITH protect, constant(2.0)
 DECLARE modify_flag = i4 WITH protect, constant(3.0)
 RECORD temp_delete(
   1 temp_synonym_list_delete[*]
     2 grp_id = f8
     2 facility_cd = f8
     2 synonym_id = f8
 )
 RECORD temp_grp_id(
   1 grp_id_list[*]
     2 grp_id = f8
     2 syn_cnt = i4
     2 synonym_id_list[*]
       3 synonym_id = f8
 )
 RECORD temp_synlist(
   1 synonym_id_list[*]
     2 synonym_id = f8
     2 qual[*]
       3 facility_cd = f8
       3 group_id = f8
       3 col_name_cd = f8
       3 attrib_list[*]
         4 object_cd = f8
         4 object_type_cd = f8
 )
 RECORD temp_insert(
   1 temp_synonym_list_insert[*]
     2 synonym_id = f8
     2 facility_cd = f8
     2 col_name_cd = f8
     2 nvalue = f8
     2 strvalue = vc
     2 object_list[*]
       3 flex_obj_cd = f8
       3 flex_obj_type_cd = f8
     2 logical_domain_id = f8
     2 excepfilter_id = f8
 )
 DECLARE deletedata(null) = null
 DECLARE insertdata(null) = null
 DECLARE findlogicaldomainid(null) = null
 DECLARE deletedatawithlogicalid(null) = null
 DECLARE insertdatawithlogicalid(null) = null
 DECLARE deletedatawithgrpid(null) = null
 DECLARE insertdatawithgrpid(null) = null
 DECLARE removeduplicates(null) = null
 SET reply->status_data.status = "F"
 SET synlistcnt = size(request->synonym_list,5)
 CALL findlogicaldomainid(null)
 IF (validate(request->synonym_list[1].grp_id))
  IF ((request->is_catalog=1))
   CALL deletedata(null)
   CALL insertdatawithlogicalid(null)
  ELSE
   SET synlistcnt = size(request->synonym_list,5)
   FOR (num = 1 TO synlistcnt)
     SET filtertype = request->synonym_list[num].excepfilter_id
     IF (((filtertype=delete_flag) OR (filtertype=modify_flag)) )
      SET temp_delete_cnt += 1
      IF (mod(temp_delete_cnt,100)=1)
       SET stat = alterlist(temp_delete->temp_synonym_list_delete,(99+ temp_delete_cnt))
      ENDIF
      SET temp_delete->temp_synonym_list_delete[temp_delete_cnt].grp_id = request->synonym_list[num].
      grp_id
      SET temp_delete->temp_synonym_list_delete[temp_delete_cnt].facility_cd = request->synonym_list[
      num].facility_cd
      SET temp_delete->temp_synonym_list_delete[temp_delete_cnt].synonym_id = request->synonym_list[
      num].synonym_id
     ENDIF
     IF (((filtertype=insert_flag) OR (filtertype=modify_flag)) )
      SET temp_insert_cnt += 1
      IF (mod(temp_insert_cnt,100)=1)
       SET stat = alterlist(temp_insert->temp_synonym_list_insert,(99+ temp_insert_cnt))
      ENDIF
      SET temp_insert->temp_synonym_list_insert[temp_insert_cnt].synonym_id = request->synonym_list[
      num].synonym_id
      SET temp_insert->temp_synonym_list_insert[temp_insert_cnt].excepfilter_id = request->
      synonym_list[num].excepfilter_id
      SET temp_insert->temp_synonym_list_insert[temp_insert_cnt].col_name_cd = request->synonym_list[
      num].col_name_cd
      SET temp_insert->temp_synonym_list_insert[temp_insert_cnt].facility_cd = request->synonym_list[
      num].facility_cd
      SET temp_insert->temp_synonym_list_insert[temp_insert_cnt].nvalue = request->synonym_list[num].
      nvalue
      SET temp_insert->temp_synonym_list_insert[temp_insert_cnt].strvalue = request->synonym_list[num
      ].strvalue
      SET temp_insert->temp_synonym_list_insert[temp_insert_cnt].logical_domain_id = request->
      synonym_list[num].logical_domain_id
      SET synobjcnt = size(request->synonym_list[num].object_list,5)
      FOR (num_ins = 1 TO synobjcnt)
        SET obj_insert_cnt += 1
        IF (mod(obj_insert_cnt,100)=1)
         SET stat = alterlist(temp_insert->temp_synonym_list_insert[temp_insert_cnt].object_list,(99
          + obj_insert_cnt))
        ENDIF
        SET temp_insert->temp_synonym_list_insert[temp_insert_cnt].object_list[obj_insert_cnt].
        flex_obj_cd = request->synonym_list[num].object_list[num_ins].flex_obj_cd
        SET temp_insert->temp_synonym_list_insert[temp_insert_cnt].object_list[obj_insert_cnt].
        flex_obj_type_cd = request->synonym_list[num].object_list[num_ins].flex_obj_type_cd
      ENDFOR
      SET stat = alterlist(temp_insert->temp_synonym_list_insert[temp_insert_cnt].object_list,
       obj_insert_cnt)
      SET obj_insert_cnt = 0
     ENDIF
   ENDFOR
   SET stat = alterlist(temp_delete->temp_synonym_list_delete,temp_delete_cnt)
   SET stat = alterlist(temp_insert->temp_synonym_list_insert,temp_insert_cnt)
   IF (temp_delete_cnt > 0)
    CALL removeduplicates(null)
   ENDIF
   CALL deletedatawithgrpid(null)
   CALL insertdatawithgrpid(null)
  ENDIF
 ELSE
  IF (logicaldomainind=1)
   CALL deletedatawithlogicalid(null)
   CALL insertdatawithlogicalid(null)
  ELSE
   CALL deletedata(null)
   CALL insertdata(null)
  ENDIF
 ENDIF
#exit_script
 IF ((reply->status_data.status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 SET modify = nopredeclare
 SUBROUTINE deletedatawithgrpid(null)
   DELETE  FROM ocs_attr_xcptn oax,
     (dummyt d  WITH seq = size(temp_delete->temp_synonym_list_delete,5))
    SET oax.seq = 1
    PLAN (d)
     JOIN (oax
     WHERE (oax.ocs_attr_xcptn_group_id=temp_delete->temp_synonym_list_delete[d.seq].grp_id))
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("DD - ",errmsg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET reply->status_data.status = "Z"
    SET reply->status_data.subeventstatus.operationname = "Zero qual in Delete"
   ELSE
    SET reply->status_data.status = "S"
    SET reply->status_data.subeventstatus.operationname = "Success"
   ENDIF
 END ;Subroutine
 SUBROUTINE insertdatawithgrpid(null)
   SET parentseq = 0.0
   FOR (syncnt = 1 TO size(temp_insert->temp_synonym_list_insert,5))
    SELECT INTO "nl:"
     newseq = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      parentseq = newseq
     WITH nocounter
    ;end select
    FOR (lobjcnt = 1 TO size(temp_insert->temp_synonym_list_insert[syncnt].object_list,5))
      INSERT  FROM ocs_attr_xcptn oax
       SET oax.ocs_attr_xcptn_id =
        IF (lobjcnt=1) parentseq
        ELSE seq(reference_seq,nextval)
        ENDIF
        , oax.ocs_attr_xcptn_group_id = parentseq, oax.ocs_col_name_cd = temp_insert->
        temp_synonym_list_insert[syncnt].col_name_cd,
        oax.synonym_id = temp_insert->temp_synonym_list_insert[syncnt].synonym_id, oax.facility_cd =
        temp_insert->temp_synonym_list_insert[syncnt].facility_cd, oax.logical_domain_id =
        temp_insert->temp_synonym_list_insert[syncnt].logical_domain_id,
        oax.flex_nbr_value = temp_insert->temp_synonym_list_insert[syncnt].nvalue, oax
        .flex_str_value_txt = temp_insert->temp_synonym_list_insert[syncnt].strvalue, oax.flex_obj_cd
         = temp_insert->temp_synonym_list_insert[syncnt].object_list[lobjcnt].flex_obj_cd,
        oax.flex_obj_type_cd = temp_insert->temp_synonym_list_insert[syncnt].object_list[lobjcnt].
        flex_obj_type_cd, oax.updt_id = reqinfo->updt_id, oax.updt_task = reqinfo->updt_task,
        oax.updt_applctx = reqinfo->updt_applctx, oax.updt_cnt = 0, oax.updt_dt_tm = cnvtdatetime(
         sysdate)
       PLAN (oax)
       WITH nocounter
      ;end insert
      SET errcode = error(errmsg,1)
      IF (errcode > 0)
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus.operationname = concat("ID In - ",errmsg)
       GO TO exit_script
      ELSEIF (curqual=0)
       SET reply->status_data.status = "Z"
       SET reply->status_data.subeventstatus.operationname = "Zero qual in Insert"
      ELSE
       SET reply->status_data.status = "S"
       SET reply->status_data.subeventstatus.operationname = "Success"
      ENDIF
    ENDFOR
   ENDFOR
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("ID OT - ",errmsg)
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
    SET reply->status_data.subeventstatus.operationname = "Success"
   ENDIF
 END ;Subroutine
 SUBROUTINE removeduplicates(null)
   DECLARE grpexpandidx = i4 WITH protect, noconstant(0)
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE grp_id = f8 WITH protect, noconstant(0)
   DECLARE facility_cd = f8 WITH protect, noconstant(0)
   DECLARE synonym_id = f8 WITH protect, noconstant(0)
   DECLARE syncnt = i4 WITH protect, noconstant(0)
   DECLARE qualidx = i4 WITH protect, noconstant(0)
   DECLARE objidx = i4 WITH protect, noconstant(0)
   DECLARE synidx = i4 WITH protect, noconstant(0)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE cat_to_syn = i2 WITH protect, noconstant(0)
   FOR (num = 1 TO temp_delete_cnt)
     SET grp_id = temp_delete->temp_synonym_list_delete[num].grp_id
     SET facility_cd = temp_delete->temp_synonym_list_delete[num].facility_cd
     SET synonym_id = temp_delete->temp_synonym_list_delete[num].synonym_id
     IF (facility_cd=0)
      IF (temp_grp_id_cnt > 0)
       SET index = locateval(iterator,1,temp_grp_id_cnt,grp_id,temp_grp_id->grp_id_list[iterator].
        grp_id)
       IF (index=0)
        SET temp_grp_id_cnt += 1
        IF (mod(temp_grp_id_cnt,100)=1)
         SET stat = alterlist(temp_grp_id->grp_id_list,(99+ temp_grp_id_cnt))
        ENDIF
        SET temp_grp_id->grp_id_list[temp_grp_id_cnt].grp_id = grp_id
        SET stat = alterlist(temp_grp_id->grp_id_list[temp_grp_id_cnt].synonym_id_list,100)
        SET temp_grp_id->grp_id_list[temp_grp_id_cnt].synonym_id_list[1].synonym_id = synonym_id
        SET temp_grp_id->grp_id_list[temp_grp_id_cnt].syn_cnt = 1
       ELSEIF (locateval(iterator,1,size(temp_grp_id->grp_id_list[index].synonym_id_list,5),
        synonym_id,temp_grp_id->grp_id_list[index].synonym_id_list[iterator].synonym_id)=0)
        IF (cat_to_syn=0)
         SET cat_to_syn = 1
        ENDIF
        SET synidx = (temp_grp_id->grp_id_list[index].syn_cnt+ 1)
        IF (mod(synidx,100)=1)
         SET stat = alterlist(temp_grp_id->grp_id_list[index].synonym_id_list,(99+ synidx))
        ENDIF
        SET temp_grp_id->grp_id_list[index].synonym_id_list[synidx].synonym_id = synonym_id
        SET temp_grp_id->grp_id_list[index].syn_cnt = synidx
       ENDIF
      ELSE
       SET temp_grp_id_cnt += 1
       IF (mod(temp_grp_id_cnt,100)=1)
        SET stat = alterlist(temp_grp_id->grp_id_list,(99+ temp_grp_id_cnt))
       ENDIF
       SET temp_grp_id->grp_id_list[temp_grp_id_cnt].grp_id = grp_id
       SET stat = alterlist(temp_grp_id->grp_id_list[temp_grp_id_cnt].synonym_id_list,100)
       SET temp_grp_id->grp_id_list[temp_grp_id_cnt].synonym_id_list[1].synonym_id = synonym_id
       SET temp_grp_id->grp_id_list[temp_grp_id_cnt].syn_cnt = 1
      ENDIF
     ENDIF
   ENDFOR
   IF (temp_grp_id_cnt > 0)
    SET stat = alterlist(temp_grp_id->grp_id_list,temp_grp_id_cnt)
    SET synidx = 0
    IF (cat_to_syn)
     FOR (num = 1 TO temp_grp_id_cnt)
       SET syncnt = temp_grp_id->grp_id_list[num].syn_cnt
       SET stat = alterlist(temp_grp_id->grp_id_list[num].synonym_id_list,syncnt)
       DELETE  FROM ocs_attr_xcptn oax,
         (dummyt d  WITH seq = syncnt)
        SET oax.seq = 1
        PLAN (d)
         JOIN (oax
         WHERE (oax.synonym_id=temp_grp_id->grp_id_list[index].synonym_id_list[d.seq].synonym_id)
          AND oax.facility_cd=0.0)
        WITH nocounter
       ;end delete
     ENDFOR
    ELSE
     SELECT INTO "nl:"
      FROM ocs_attr_xcptn oax
      WHERE expand(grpexpandidx,1,temp_grp_id_cnt,oax.ocs_attr_xcptn_group_id,temp_grp_id->
       grp_id_list[grpexpandidx].grp_id)
      ORDER BY oax.ocs_attr_xcptn_group_id
      HEAD oax.synonym_id
       synidx += 1
       IF (mod(synidx,100)=1)
        stat = alterlist(temp_synlist->synonym_id_list,(synidx+ 99))
       ENDIF
       temp_synlist->synonym_id_list[synidx].synonym_id = oax.synonym_id
      HEAD oax.ocs_attr_xcptn_group_id
       qualidx += 1
       IF (mod(qualidx,100)=1)
        stat = alterlist(temp_synlist->synonym_id_list[synidx].qual,(qualidx+ 99))
       ENDIF
       temp_synlist->synonym_id_list[synidx].qual[qualidx].facility_cd = oax.facility_cd,
       temp_synlist->synonym_id_list[synidx].qual[qualidx].group_id = oax.ocs_attr_xcptn_group_id,
       temp_synlist->synonym_id_list[synidx].qual[qualidx].col_name_cd = oax.ocs_col_name_cd
      DETAIL
       objidx += 1
       IF (mod(objidx,100)=1)
        stat = alterlist(temp_synlist->synonym_id_list[synidx].qual[qualidx].attrib_list,(objidx+ 99)
         )
       ENDIF
       temp_synlist->synonym_id_list[synidx].qual[qualidx].attrib_list[objidx].object_cd = oax
       .flex_obj_cd, temp_synlist->synonym_id_list[synidx].qual[qualidx].attrib_list[objidx].
       object_type_cd = oax.flex_obj_type_cd
      FOOT  oax.ocs_attr_xcptn_group_id
       stat = alterlist(temp_synlist->synonym_id_list[synidx].qual[qualidx].attrib_list,objidx),
       objidx = 0
      FOOT  oax.synonym_id
       stat = alterlist(temp_synlist->synonym_id_list[synidx].qual,qualidx), qualidx = 0
      FOOT REPORT
       stat = alterlist(temp_synlist->synonym_id_list,synidx)
      WITH nocounter, expand = 2
     ;end select
     FOR (num = 1 TO synidx)
       FOR (num_2 = 1 TO size(temp_synlist->synonym_id_list[num].qual,5))
         DELETE  FROM ocs_attr_xcptn oax,
           (dummyt d  WITH seq = value(size(temp_synlist->synonym_id_list[num].qual[num_2].
             attrib_list,5)))
          SET oax.seq = 1
          PLAN (d)
           JOIN (oax
           WHERE (oax.synonym_id=temp_synlist->synonym_id_list[num].synonym_id)
            AND (oax.facility_cd=temp_synlist->synonym_id_list[num].qual[num_2].facility_cd)
            AND (oax.ocs_col_name_cd=temp_synlist->synonym_id_list[num].qual[num_2].col_name_cd)
            AND (oax.flex_obj_type_cd=temp_synlist->synonym_id_list[num].qual[num_2].attrib_list[d
           .seq].object_type_cd)
            AND (oax.flex_obj_cd=temp_synlist->synonym_id_list[num].qual[num_2].attrib_list[d.seq].
           object_cd))
          WITH nocounter
         ;end delete
       ENDFOR
     ENDFOR
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE deletedata(null)
   DELETE  FROM ocs_attr_xcptn oax,
     (dummyt d  WITH seq = value(size(request->synonym_list,5)))
    SET oax.seq = 1
    PLAN (d)
     JOIN (oax
     WHERE (oax.synonym_id=request->synonym_list[d.seq].synonym_id)
      AND (oax.facility_cd=request->synonym_list[d.seq].facility_cd)
      AND (oax.ocs_col_name_cd=request->synonym_list[d.seq].col_name_cd))
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("DD - ",errmsg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET reply->status_data.status = "Z"
    SET reply->status_data.subeventstatus.operationname = "Zero qual in Delete"
   ELSE
    SET reply->status_data.status = "S"
    SET reply->status_data.subeventstatus.operationname = "Success"
   ENDIF
 END ;Subroutine
 SUBROUTINE insertdata(null)
   SET parentseq = 0.0
   FOR (syncnt = 1 TO size(request->synonym_list,5))
    SELECT INTO "nl:"
     newseq = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      parentseq = newseq
     WITH nocounter
    ;end select
    FOR (lobjcnt = 1 TO size(request->synonym_list[syncnt].object_list,5))
      INSERT  FROM ocs_attr_xcptn oax
       SET oax.ocs_attr_xcptn_id =
        IF (lobjcnt=1) parentseq
        ELSE seq(reference_seq,nextval)
        ENDIF
        , oax.ocs_attr_xcptn_group_id = parentseq, oax.ocs_col_name_cd = request->synonym_list[syncnt
        ].col_name_cd,
        oax.synonym_id = request->synonym_list[syncnt].synonym_id, oax.facility_cd = request->
        synonym_list[syncnt].facility_cd, oax.flex_nbr_value = request->synonym_list[syncnt].nvalue,
        oax.flex_str_value_txt = request->synonym_list[syncnt].strvalue, oax.flex_obj_cd = request->
        synonym_list[syncnt].object_list[lobjcnt].flex_obj_cd, oax.flex_obj_type_cd = request->
        synonym_list[syncnt].object_list[lobjcnt].flex_obj_type_cd,
        oax.updt_id = reqinfo->updt_id, oax.updt_task = reqinfo->updt_task, oax.updt_applctx =
        reqinfo->updt_applctx,
        oax.updt_cnt = 0, oax.updt_dt_tm = cnvtdatetime(sysdate)
       PLAN (oax)
       WITH nocounter
      ;end insert
      SET errcode = error(errmsg,1)
      IF (errcode > 0)
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus.operationname = concat("ID In - ",errmsg)
       GO TO exit_script
      ELSEIF (curqual=0)
       SET reply->status_data.status = "Z"
       SET reply->status_data.subeventstatus.operationname = "Zero qual in Insert"
      ELSE
       SET reply->status_data.status = "S"
       SET reply->status_data.subeventstatus.operationname = "Success"
      ENDIF
    ENDFOR
   ENDFOR
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("ID OT - ",errmsg)
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
    SET reply->status_data.subeventstatus.operationname = "Success"
   ENDIF
 END ;Subroutine
 SUBROUTINE findlogicaldomainid(null)
   SELECT INTO "nl:"
    logical_id = validate(request->synonym_list[d.seq].logical_domain_id)
    FROM (dummyt d  WITH seq = value(synlistcnt))
    ORDER BY logical_id
    HEAD logical_id
     IF (validate(request->synonym_list[d.seq].logical_domain_id))
      logicaldomainind = 1
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE deletedatawithlogicalid(null)
   DELETE  FROM ocs_attr_xcptn oax,
     (dummyt d  WITH seq = value(synlistcnt))
    SET oax.seq = 1
    PLAN (d)
     JOIN (oax
     WHERE (oax.synonym_id=request->synonym_list[d.seq].synonym_id)
      AND (oax.facility_cd=request->synonym_list[d.seq].facility_cd)
      AND (oax.ocs_col_name_cd=request->synonym_list[d.seq].col_name_cd)
      AND (oax.logical_domain_id=request->synonym_list[d.seq].logical_domain_id))
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("DD - ",errmsg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET reply->status_data.status = "Z"
    SET reply->status_data.subeventstatus.operationname = "Zero qual in Delete"
   ELSE
    SET reply->status_data.status = "S"
    SET reply->status_data.subeventstatus.operationname = "Success"
   ENDIF
 END ;Subroutine
 SUBROUTINE insertdatawithlogicalid(null)
   SET parentseq = 0.0
   FOR (syncnt = 1 TO synlistcnt)
    SELECT INTO "nl:"
     newseq = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      parentseq = newseq
     WITH nocounter
    ;end select
    FOR (lobjcnt = 1 TO size(request->synonym_list[syncnt].object_list,5))
      INSERT  FROM ocs_attr_xcptn oax
       SET oax.ocs_attr_xcptn_id =
        IF (lobjcnt=1) parentseq
        ELSE seq(reference_seq,nextval)
        ENDIF
        , oax.ocs_attr_xcptn_group_id = parentseq, oax.ocs_col_name_cd = request->synonym_list[syncnt
        ].col_name_cd,
        oax.synonym_id = request->synonym_list[syncnt].synonym_id, oax.facility_cd = request->
        synonym_list[syncnt].facility_cd, oax.logical_domain_id = request->synonym_list[syncnt].
        logical_domain_id,
        oax.flex_nbr_value = request->synonym_list[syncnt].nvalue, oax.flex_str_value_txt = request->
        synonym_list[syncnt].strvalue, oax.flex_obj_cd = request->synonym_list[syncnt].object_list[
        lobjcnt].flex_obj_cd,
        oax.flex_obj_type_cd = request->synonym_list[syncnt].object_list[lobjcnt].flex_obj_type_cd,
        oax.updt_id = reqinfo->updt_id, oax.updt_task = reqinfo->updt_task,
        oax.updt_applctx = reqinfo->updt_applctx, oax.updt_cnt = 0, oax.updt_dt_tm = cnvtdatetime(
         sysdate)
       PLAN (oax)
       WITH nocounter
      ;end insert
      SET errcode = error(errmsg,1)
      IF (errcode > 0)
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus.operationname = concat("ID In - ",errmsg)
       GO TO exit_script
      ELSEIF (curqual=0)
       SET reply->status_data.status = "Z"
       SET reply->status_data.subeventstatus.operationname = "Zero qual in Insert"
      ELSE
       SET reply->status_data.status = "S"
       SET reply->status_data.subeventstatus.operationname = "Success"
      ENDIF
    ENDFOR
   ENDFOR
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("ID OT - ",errmsg)
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
    SET reply->status_data.subeventstatus.operationname = "Success"
   ENDIF
 END ;Subroutine
 SET last_mod = "004"
 SET mod_date = "04/22/2023"
END GO
