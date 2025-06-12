CREATE PROGRAM aps_get_proposed_protocol:dba
 RECORD protocol(
   1 prefix_cd = f8
   1 pathologist_id = f8
   1 max_task_cnt = i2
   1 spec[*]
     2 specimen_cd = f8
     2 case_specimen_id = f8
     2 fixative_cd = f8
     2 priority_cd = f8
     2 priority_disp = c40
     2 protocol_id = f8
     2 task[*]
       3 catalog_cd = f8
       3 task_assay_cd = f8
       3 begin_section = i4
       3 begin_level = i4
       3 create_inventory_flag = i4
       3 stain_ind = i2
       3 t_no_charge_ind = i2
       3 task_type_flag = i2
       3 catalog_type_cd = f8
 )
 RECORD task_hold(
   1 qual[*]
     2 task_offset = i4
 )
#script
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET reqspeccnt = 0
 SET reqspeccnt = size(request->spec_qual,5)
 SET stat = alterlist(protocol->spec,reqspeccnt)
 SET protocol->prefix_cd = request->prefix_id
 SET protocol->pathologist_id = request->path_id
 FOR (x = 1 TO reqspeccnt)
   SET protocol->spec[x].specimen_cd = request->spec_qual[x].spec_cd
   SET protocol->spec[x].case_specimen_id = request->spec_qual[x].case_spec_id
   SET protocol->spec[x].fixative_cd = request->spec_qual[x].fixative_cd
   SET protocol->spec[x].priority_cd = request->spec_qual[x].priority_cd
   SET protocol->spec[x].priority_disp = ""
   SET protocol->spec[x].protocol_id = 0
 ENDFOR
 EXECUTE aps_load_specimen_protocol
 SET cass_tag_group = 0.0
 SET slide_tag_group = 0.0
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(size(reply->tag_qual,5)))
  PLAN (d
   WHERE (reply->tag_qual[d.seq].tag_type_flag > 0))
  DETAIL
   CASE (reply->tag_qual[d.seq].tag_type_flag)
    OF 2:
     cass_tag_group = reply->tag_qual[d.seq].tag_group_cd
    OF 3:
     slide_tag_group = reply->tag_qual[d.seq].tag_group_cd
   ENDCASE
  WITH nocounter
 ;end select
 SET maxpsccnt = 0
 SET maxpsslcnt = 0
 SET maxpscslcnt = 0
 SET p_s_cnt = size(reply->spec_qual,5)
 SELECT INTO "nl:"
  d.seq, d2.seq, create_inventory = protocol->spec[d.seq].task[d2.seq].create_inventory_flag,
  ncreateblock = evaluate(protocol->spec[d.seq].task[d2.seq].create_inventory_flag,1,1,2,0,
   3,1,0,0), ncreateslide = evaluate(protocol->spec[d.seq].task[d2.seq].create_inventory_flag,1,0,2,1,
   3,1,0,0), begin_section = protocol->spec[d.seq].task[d2.seq].begin_section,
  begin_level = protocol->spec[d.seq].task[d2.seq].begin_level
  FROM (dummyt d  WITH seq = value(reqspeccnt)),
   (dummyt d2  WITH seq = 1)
  PLAN (d
   WHERE maxrec(d2,size(protocol->spec[d.seq].task,5)))
   JOIN (d2)
  ORDER BY d.seq, begin_section, ncreateblock DESC,
   begin_level, ncreateslide DESC, d2.seq
  HEAD REPORT
   maxpsccnt = 0, maxpsslcnt = 0, maxpscslcnt = 0
  HEAD d.seq
   p_s_cnt = (p_s_cnt+ 1), stat = alterlist(reply->spec_qual,p_s_cnt), reply->spec_ctr = p_s_cnt,
   reply->spec_qual[p_s_cnt].spec_cd = protocol->spec[d.seq].specimen_cd, reply->spec_qual[p_s_cnt].
   case_specimen_id = protocol->spec[d.seq].case_specimen_id, psccnt = 0
  DETAIL
   CASE (protocol->spec[d.seq].task[d2.seq].create_inventory_flag)
    OF 1:
     psccnt = protocol->spec[d.seq].task[d2.seq].begin_section,
     IF (psccnt > maxpsccnt)
      maxpsccnt = psccnt
     ENDIF
     ,stat = alterlist(reply->spec_qual[p_s_cnt].cass_qual,psccnt),reply->spec_qual[p_s_cnt].s_c_ctr
      = psccnt,reply->spec_qual[p_s_cnt].cass_qual[psccnt].cass_seq = psccnt,
     reply->spec_qual[p_s_cnt].cass_qual[psccnt].cass_task_assay_cd = protocol->spec[d.seq].task[d2
     .seq].task_assay_cd,reply->spec_qual[p_s_cnt].cass_qual[psccnt].cass_task_assay_inv_flag = 1,
     reply->spec_qual[p_s_cnt].cass_qual[psccnt].cass_pieces = "1",
     reply->spec_qual[p_s_cnt].cass_qual[psccnt].cass_fixative_cd = protocol->spec[d.seq].fixative_cd
    OF 2:
     IF ((protocol->spec[d.seq].task[d2.seq].begin_section=0))
      psslcnt = protocol->spec[d.seq].task[d2.seq].begin_level
      IF (psslcnt > maxpsslcnt)
       maxpsslcnt = psslcnt
      ENDIF
      stat = alterlist(reply->spec_qual[p_s_cnt].slide_qual,psslcnt), reply->spec_qual[p_s_cnt].
      s_slide_ctr = psslcnt, reply->spec_qual[p_s_cnt].slide_qual[psslcnt].sl_task_assay_cd =
      protocol->spec[d.seq].task[d2.seq].task_assay_cd,
      reply->spec_qual[p_s_cnt].slide_qual[psslcnt].sl_seq = psslcnt
      IF ((protocol->spec[d.seq].task[d2.seq].stain_ind=1))
       reply->spec_qual[p_s_cnt].slide_qual[psslcnt].sl_stain_task_assay_cd = protocol->spec[d.seq].
       task[d2.seq].task_assay_cd
      ENDIF
     ELSEIF ((protocol->spec[d.seq].task[d2.seq].begin_section > 0))
      pscslcnt = protocol->spec[d.seq].task[d2.seq].begin_level
      IF (pscslcnt > maxpscslcnt)
       maxpscslcnt = pscslcnt
      ENDIF
      stat = alterlist(reply->spec_qual[p_s_cnt].cass_qual[psccnt].slide_qual,pscslcnt), reply->
      spec_qual[p_s_cnt].cass_qual[psccnt].s_c_slide_ctr = pscslcnt, reply->spec_qual[p_s_cnt].
      cass_qual[psccnt].slide_qual[pscslcnt].s_task_assay_cd = protocol->spec[d.seq].task[d2.seq].
      task_assay_cd,
      reply->spec_qual[p_s_cnt].cass_qual[psccnt].slide_qual[pscslcnt].s_seq = pscslcnt
      IF ((protocol->spec[d.seq].task[d2.seq].stain_ind=1))
       reply->spec_qual[p_s_cnt].cass_qual[psccnt].slide_qual[pscslcnt].s_stain_task_assay_cd =
       protocol->spec[d.seq].task[d2.seq].task_assay_cd
      ENDIF
     ENDIF
    OF 3:
     psccnt = protocol->spec[d.seq].task[d2.seq].begin_section,
     IF (psccnt > maxpsccnt)
      maxpsccnt = psccnt
     ENDIF
     ,stat = alterlist(reply->spec_qual[p_s_cnt].cass_qual,psccnt),reply->spec_qual[p_s_cnt].s_c_ctr
      = psccnt,reply->spec_qual[p_s_cnt].cass_qual[psccnt].cass_seq = psccnt,
     reply->spec_qual[p_s_cnt].cass_qual[psccnt].cass_task_assay_cd = protocol->spec[d.seq].task[d2
     .seq].task_assay_cd,reply->spec_qual[p_s_cnt].cass_qual[psccnt].cass_task_assay_inv_flag = 3,
     reply->spec_qual[p_s_cnt].cass_qual[psccnt].cass_pieces = "1",
     reply->spec_qual[p_s_cnt].cass_qual[psccnt].cass_fixative_cd = protocol->spec[d.seq].fixative_cd,
     pscslcnt = protocol->spec[d.seq].task[d2.seq].begin_level,
     IF (pscslcnt > maxpscslcnt)
      maxpscslcnt = pscslcnt
     ENDIF
     ,stat = alterlist(reply->spec_qual[p_s_cnt].cass_qual[psccnt].slide_qual,pscslcnt),reply->
     spec_qual[p_s_cnt].cass_qual[psccnt].s_c_slide_ctr = pscslcnt,reply->spec_qual[p_s_cnt].
     cass_qual[psccnt].slide_qual[pscslcnt].s_task_assay_cd = protocol->spec[d.seq].task[d2.seq].
     task_assay_cd,
     reply->spec_qual[p_s_cnt].cass_qual[psccnt].slide_qual[pscslcnt].s_seq = pscslcnt,
     IF (((protocol->spec[d.seq].task[d2.seq].stain_ind=1)=1))
      reply->spec_qual[p_s_cnt].cass_qual[psccnt].slide_qual[pscslcnt].s_stain_task_assay_cd =
      protocol->spec[d.seq].task[d2.seq].task_assay_cd
     ENDIF
   ENDCASE
   IF ((protocol->spec[d.seq].task[d2.seq].begin_section=0)
    AND (protocol->spec[d.seq].task[d2.seq].begin_level=0))
    pstcnt = (size(reply->spec_qual[p_s_cnt].t_qual,5)+ 1), stat = alterlist(reply->spec_qual[p_s_cnt
     ].t_qual,pstcnt), reply->spec_qual[p_s_cnt].s_t_ctr = pstcnt,
    reply->spec_qual[p_s_cnt].t_qual[pstcnt].t_task_assay_cd = protocol->spec[d.seq].task[d2.seq].
    task_assay_cd, reply->spec_qual[p_s_cnt].t_qual[pstcnt].t_status_cd = 0, reply->spec_qual[p_s_cnt
    ].t_qual[pstcnt].t_create_inv_flag = create_inventory,
    reply->spec_qual[p_s_cnt].t_qual[pstcnt].t_priority_cd = protocol->spec[d.seq].priority_cd, reply
    ->spec_qual[p_s_cnt].t_qual[pstcnt].t_no_charge_ind = protocol->spec[d.seq].task[d2.seq].
    t_no_charge_ind, reply->spec_qual[p_s_cnt].t_qual[pstcnt].t_task_type_flag = protocol->spec[d.seq
    ].task[d2.seq].task_type_flag
   ENDIF
   IF ((protocol->spec[d.seq].task[d2.seq].begin_section=0)
    AND (protocol->spec[d.seq].task[d2.seq].begin_level > 0))
    pssltcnt = (size(reply->spec_qual[p_s_cnt].slide_qual[psslcnt].t_qual,5)+ 1), stat = alterlist(
     reply->spec_qual[p_s_cnt].slide_qual[psslcnt].t_qual,pssltcnt), reply->spec_qual[p_s_cnt].
    slide_qual[psslcnt].s_s_t_ctr = pssltcnt,
    reply->spec_qual[p_s_cnt].slide_qual[psslcnt].t_qual[pssltcnt].t_task_assay_cd = protocol->spec[d
    .seq].task[d2.seq].task_assay_cd, reply->spec_qual[p_s_cnt].slide_qual[psslcnt].t_qual[pssltcnt].
    t_status_cd = 0, reply->spec_qual[p_s_cnt].slide_qual[psslcnt].t_qual[pssltcnt].t_create_inv_flag
     = create_inventory,
    reply->spec_qual[p_s_cnt].slide_qual[psslcnt].t_qual[pssltcnt].t_priority_cd = protocol->spec[d
    .seq].priority_cd, reply->spec_qual[p_s_cnt].slide_qual[psslcnt].t_qual[pssltcnt].t_no_charge_ind
     = protocol->spec[d.seq].task[d2.seq].t_no_charge_ind, reply->spec_qual[p_s_cnt].slide_qual[
    psslcnt].t_qual[pssltcnt].t_stain_ind = protocol->spec[d.seq].task[d2.seq].stain_ind,
    reply->spec_qual[p_s_cnt].slide_qual[psslcnt].t_qual[pssltcnt].t_task_type_flag = protocol->spec[
    d.seq].task[d2.seq].task_type_flag
   ENDIF
   IF ((protocol->spec[d.seq].task[d2.seq].begin_section > 0)
    AND (protocol->spec[d.seq].task[d2.seq].begin_level=0))
    IF ((protocol->spec[d.seq].task[d2.seq].begin_section=psccnt))
     psctcnt = (size(reply->spec_qual[p_s_cnt].cass_qual[psccnt].t_qual,5)+ 1), stat = alterlist(
      reply->spec_qual[p_s_cnt].cass_qual[psccnt].t_qual,psctcnt), reply->spec_qual[p_s_cnt].
     cass_qual[psccnt].s_c_t_ctr = psctcnt,
     reply->spec_qual[p_s_cnt].cass_qual[psccnt].t_qual[psctcnt].t_task_assay_cd = protocol->spec[d
     .seq].task[d2.seq].task_assay_cd, reply->spec_qual[p_s_cnt].cass_qual[psccnt].t_qual[psctcnt].
     t_status_cd = 0, reply->spec_qual[p_s_cnt].cass_qual[psccnt].t_qual[psctcnt].t_create_inv_flag
      = create_inventory,
     reply->spec_qual[p_s_cnt].cass_qual[psccnt].t_qual[psctcnt].t_priority_cd = protocol->spec[d.seq
     ].priority_cd, reply->spec_qual[p_s_cnt].cass_qual[psccnt].t_qual[psctcnt].t_no_charge_ind =
     protocol->spec[d.seq].task[d2.seq].t_no_charge_ind, reply->spec_qual[p_s_cnt].cass_qual[psccnt].
     t_qual[psctcnt].t_task_type_flag = protocol->spec[d.seq].task[d2.seq].task_type_flag
    ENDIF
   ENDIF
   IF ((protocol->spec[d.seq].task[d2.seq].begin_section > 0)
    AND (protocol->spec[d.seq].task[d2.seq].begin_level > 0))
    pscsltcnt = (size(reply->spec_qual[p_s_cnt].cass_qual[psccnt].slide_qual[pscslcnt].t_qual,5)+ 1),
    stat = alterlist(reply->spec_qual[p_s_cnt].cass_qual[psccnt].slide_qual[pscslcnt].t_qual,
     pscsltcnt), reply->spec_qual[p_s_cnt].cass_qual[psccnt].slide_qual[pscslcnt].s_c_s_t_ctr =
    pscsltcnt,
    reply->spec_qual[p_s_cnt].cass_qual[psccnt].slide_qual[pscslcnt].t_qual[pscsltcnt].
    t_task_assay_cd = protocol->spec[d.seq].task[d2.seq].task_assay_cd, reply->spec_qual[p_s_cnt].
    cass_qual[psccnt].slide_qual[pscslcnt].t_qual[pscsltcnt].t_status_cd = 0, reply->spec_qual[
    p_s_cnt].cass_qual[psccnt].slide_qual[pscslcnt].t_qual[pscsltcnt].t_create_inv_flag =
    create_inventory,
    reply->spec_qual[p_s_cnt].cass_qual[psccnt].slide_qual[pscslcnt].t_qual[pscsltcnt].t_priority_cd
     = protocol->spec[d.seq].priority_cd, reply->spec_qual[p_s_cnt].cass_qual[psccnt].slide_qual[
    pscslcnt].t_qual[pscsltcnt].t_no_charge_ind = protocol->spec[d.seq].task[d2.seq].t_no_charge_ind,
    reply->spec_qual[p_s_cnt].cass_qual[psccnt].slide_qual[pscslcnt].t_qual[pscsltcnt].t_stain_ind =
    protocol->spec[d.seq].task[d2.seq].stain_ind,
    reply->spec_qual[p_s_cnt].cass_qual[psccnt].slide_qual[pscslcnt].t_qual[pscsltcnt].
    t_task_type_flag = protocol->spec[d.seq].task[d2.seq].task_type_flag
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(size(reply->spec_qual,5))),
   (dummyt d2  WITH seq = value(maxpsccnt)),
   ap_tag ap
  PLAN (d)
   JOIN (d2
   WHERE d2.seq <= size(reply->spec_qual[d.seq].cass_qual,5))
   JOIN (ap
   WHERE cass_tag_group=ap.tag_group_id
    AND (reply->spec_qual[d.seq].cass_qual[d2.seq].cass_seq=ap.tag_sequence)
    AND ap.active_ind=1)
  DETAIL
   reply->spec_qual[d.seq].cass_qual[d2.seq].cass_tag = ap.tag_disp
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(size(reply->spec_qual,5))),
   (dummyt d2  WITH seq = value(maxpsslcnt)),
   ap_tag ap
  PLAN (d)
   JOIN (d2
   WHERE d2.seq <= size(reply->spec_qual[d.seq].slide_qual,5))
   JOIN (ap
   WHERE slide_tag_group=ap.tag_group_id
    AND (reply->spec_qual[d.seq].slide_qual[d2.seq].sl_seq=ap.tag_sequence)
    AND ap.active_ind=1)
  DETAIL
   reply->spec_qual[d.seq].slide_qual[d2.seq].sl_tag = ap.tag_disp
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(size(reply->spec_qual,5))),
   (dummyt d2  WITH seq = value(maxpsccnt)),
   (dummyt d3  WITH seq = value(maxpscslcnt)),
   ap_tag ap
  PLAN (d)
   JOIN (d2
   WHERE d2.seq <= size(reply->spec_qual[d.seq].cass_qual,5))
   JOIN (d3
   WHERE d3.seq <= size(reply->spec_qual[d.seq].cass_qual[d2.seq].slide_qual,5))
   JOIN (ap
   WHERE slide_tag_group=ap.tag_group_id
    AND (reply->spec_qual[d.seq].cass_qual[d2.seq].slide_qual[d3.seq].s_seq=ap.tag_sequence)
    AND ap.active_ind=1)
  DETAIL
   reply->spec_qual[d.seq].cass_qual[d2.seq].slide_qual[d3.seq].s_tag = ap.tag_disp
  WITH nocounter
 ;end select
 GO TO exit_script
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (error_cnt > 0)
  SET reqinfo->commit_ind = 0
  CALL echo("<<<<< ROLLBACK <<<<<")
  CALL echo(error_cnt)
  CALL echo(reply->status_data.subeventstatus[1].operationname)
  CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo(">>>>> COMMIT >>>>>")
 ENDIF
END GO
