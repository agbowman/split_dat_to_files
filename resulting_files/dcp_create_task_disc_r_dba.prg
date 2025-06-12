CREATE PROGRAM dcp_create_task_disc_r:dba
 RECORD temp(
   1 cr_cnt = i2
   1 cr_list[*]
     2 reference_task_id = f8
     2 task_assay_cd = f8
     2 sequence = i4
     2 required_ind = i2
     2 create_ind = i2
 )
 RECORD grp_temp(
   1 grp_cnt = i2
   1 grp_list[*]
     2 reference_task_id = f8
     2 group_cd = f8
     2 group_version_nbr = i4
 )
 SET count1 = 0
 SET count2 = 0
 SET dta_seq = 0
 SET cr_ind = 0
 SET no_upd = 0
 SET to_upd = 0
 SET did_upd = 0
 SELECT INTO "nl:"
  o.reference_task_id, f.input_form_cd, i.input_form_version_nbr,
  d.input_form_version_nbr, d.input_form_def_seq, d.task_assay_cd,
  d.required_flag
  FROM order_task o,
   form_association f,
   input_form_reference i,
   input_form_definition d
  PLAN (o
   WHERE o.active_ind=1)
   JOIN (f
   WHERE o.reference_task_id=f.reference_task_id)
   JOIN (i
   WHERE f.input_form_cd=i.input_form_cd
    AND i.active_ind=1)
   JOIN (d
   WHERE i.input_form_cd=d.input_form_cd
    AND i.input_form_version_nbr=d.input_form_version_nbr)
  ORDER BY o.reference_task_id, d.task_assay_cd
  HEAD REPORT
   count1 = 0, count2 = 0
  HEAD o.reference_task_id
   col 0, dta_seq = 0
  HEAD d.task_assay_cd
   IF (d.task_assay_cd > 0)
    count1 = (count1+ 1)
    IF (count1 > size(temp->cr_list,5))
     stat = alterlist(temp->cr_list,(count1+ 100))
    ENDIF
    dta_seq = (dta_seq+ 1), temp->cr_list[count1].reference_task_id = o.reference_task_id, temp->
    cr_list[count1].task_assay_cd = d.task_assay_cd,
    temp->cr_list[count1].sequence = dta_seq, temp->cr_list[count1].required_ind = d.required_flag
   ELSEIF (d.group_cd > 0)
    count2 = (count2+ 1)
    IF (count2 > size(grp_temp->grp_list,5))
     stat = alterlist(grp_temp->grp_list,(count2+ 50))
    ENDIF
    grp_temp->grp_list[count2].reference_task_id = o.reference_task_id, grp_temp->grp_list[count2].
    group_cd = d.group_cd, grp_temp->grp_list[count2].group_version_nbr = d.group_version_nbr
   ENDIF
  DETAIL
   row + 0
  FOOT REPORT
   temp->cr_cnt = count1, stat = alterlist(temp->cr_list,count1), grp_temp->grp_cnt = count2,
   stat = alterlist(grp_temp->grp_list,count2)
  WITH nocounter
 ;end select
 CALL echo(build("COUNT1:",count1))
 CALL echo(build("COUNT2:",count2))
 FOR (x = 1 TO grp_temp->grp_cnt)
   SELECT INTO "nl:"
    g.task_assay_cd
    FROM group_definition g
    PLAN (g
     WHERE (g.group_cd=grp_temp->grp_list[x].group_cd)
      AND (g.group_version_nbr=grp_temp->grp_list[x].group_version_nbr))
    HEAD REPORT
     dta_seq = 0
    DETAIL
     count1 = (count1+ 1)
     IF (count1 > size(temp->cr_list,5))
      stat = alterlist(temp->cr_list,(count1+ 100))
     ENDIF
     dta_seq = (dta_seq+ 1), temp->cr_list[count1].reference_task_id = grp_temp->grp_list[x].
     reference_task_id, temp->cr_list[count1].task_assay_cd = g.task_assay_cd,
     temp->cr_list[count1].sequence = dta_seq, temp->cr_list[count1].required_ind = g.required_flag
    WITH nocounter
   ;end select
 ENDFOR
 SET stat = alterlist(temp->cr_list,count1)
 SET temp->cr_cnt = count1
 FOR (x = 1 TO temp->cr_cnt)
   SET cr_ind = 1
   SELECT INTO "nl:"
    t.reference_task_id, t.task_assay_cd
    FROM task_discrete_r t
    PLAN (t
     WHERE (t.reference_task_id=temp->cr_list[x].reference_task_id)
      AND (t.task_assay_cd=temp->cr_list[x].task_assay_cd))
    ORDER BY t.reference_task_id
    HEAD REPORT
     cr_ind = 1
    DETAIL
     cr_ind = 0, no_upd = (no_upd+ 1)
    WITH nocounter
   ;end select
   SET temp->cr_list[x].create_ind = cr_ind
 ENDFOR
 SET to_upd = (temp->cr_cnt - no_upd)
 FOR (x = 1 TO temp->cr_cnt)
   IF ((temp->cr_list[x].create_ind=1))
    INSERT  FROM task_discrete_r t
     SET t.reference_task_id = temp->cr_list[x].reference_task_id, t.task_assay_cd = temp->cr_list[x]
      .task_assay_cd, t.sequence = temp->cr_list[x].sequence,
      t.required_ind = temp->cr_list[x].required_ind, t.active_ind = 1, t.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      t.updt_id = 0, t.updt_task = 0, t.updt_cnt = 0,
      t.updt_applctx = 0
     WITH nocounter
    ;end insert
    UPDATE  FROM order_task_xref o
     SET o.order_task_type_flag = 2
     WHERE (o.reference_task_id=temp->cr_list[x].reference_task_id)
     WITH nocounter
    ;end update
    SET did_upd = (did_upd+ 1)
   ENDIF
 ENDFOR
 IF (did_upd > 0)
  COMMIT
 ENDIF
 CALL echo(build("total cnt:",temp->cr_cnt))
 CALL echo(build("to updt cnt:",to_upd))
 CALL echo(build("did updt cnt:",did_upd))
END GO
