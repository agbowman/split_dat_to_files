CREATE PROGRAM dm_cmb_add_det_custom:dba
 FREE RECORD cmb_temp
 RECORD cmb_temp(
   1 list[*]
     2 row_exists = i4
 )
 SET stat = alterlist(cmb_temp->list,size(request->xxx_combine_det,5))
 SET dm_str = fillstring(132," ")
 SET cmb_det_exists_cnt = 0
 IF (dm_debug_cmb)
  SET mem1 = curmem
  CALL echo(build("mem_userd_rec=",(mem_save - mem1)))
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(request->xxx_combine_det,5))
  DETAIL
   request->xxx_combine_det[d.seq].xxx_combine_id = request->xxx_combine[icombine].xxx_combine_id,
   error_table = request->xxx_combine_det[d.seq].entity_name, cmb_temp->list[d.seq].row_exists = 0
  WITH nocounter
 ;end select
 IF (((recombining) OR ((request->cmb_mode="RE-CMB"))) )
  SET dm_str = "select into 'nl:' cdt.entity_id "
  CALL parser(dm_str)
  SET dm_str = concat("from ",trim(cmb_det_table),
   " cdt , (dummyt d with seq = size(cmb_temp->list,5)) ")
  CALL parser(dm_str)
  SET dm_str = "plan d "
  CALL parser(dm_str)
  SET dm_str = "join cdt "
  CALL parser(dm_str)
  SET dm_str = concat("where cdt.",trim(cmb_table_id),
   " = request->xxx_combine_det[d.seq]->xxx_combine_id ")
  CALL parser(dm_str)
  SET dm_str = "and cdt.entity_id = request->xxx_combine_det[d.seq]->entity_id "
  CALL parser(dm_str)
  SET dm_str = "and cdt.entity_name = request->xxx_combine_det[d.seq]->entity_name "
  CALL parser(dm_str)
  SET dm_str = "detail "
  CALL parser(dm_str)
  SET dm_str = "cmb_temp->list[d.seq].row_exists = 1 "
  CALL parser(dm_str)
  SET dm_str = "cmb_det_exists_cnt = cmb_det_exists_cnt + 1 "
  CALL parser(dm_str)
  SET dm_str = "if (dm_debug_cmb = 1) "
  CALL parser(dm_str)
  SET dm_str = 'call echo(build("entity_id=",request->xxx_combine_det[d.seq]->entity_id)) '
  CALL parser(dm_str)
  SET dm_str =
  'call echo(build(" on table=", request->xxx_combine_det[d.seq]->entity_name, " already exists...")) '
  CALL parser(dm_str)
  SET dm_str = "endif "
  CALL parser(dm_str)
  IF (cmb_det_table="PERSON_COMBINE_DET")
   SET dm_str = "with nocounter, ORAHINTCBO('INDEX(CDT XIE2PERSON_COMBINE_DET)') go"
  ELSEIF (cmb_det_table="ENCNTR_COMBINE_DET")
   SET dm_str = "with nocounter, ORAHINTCBO('INDEX(CDT XIE2ENCNTR_COMBINE_DET)') go"
  ENDIF
  CALL parser(dm_str,1)
 ENDIF
 SET dm_str = concat("insert into ",trim(cmb_det_table),
  " cdt, (dummyt d with seq = size(request->xxx_combine_det,5)) ")
 CALL parser(dm_str)
 SET dm_str = concat("set cdt.attribute_name= ","request->xxx_combine_det[d.seq]->attribute_name,")
 CALL parser(dm_str)
 SET dm_str = concat("cdt.combine_action_cd= ","request->xxx_combine_det[d.seq]->combine_action_cd,")
 CALL parser(dm_str)
 SET dm_str = concat("cdt.",trim(cmb_table_id)," = request->xxx_combine[ICOMBINE]->xxx_combine_id,")
 CALL parser(dm_str)
 SET dm_str = "cdt.entity_id=request->xxx_combine_det[d.seq]->entity_id,"
 CALL parser(dm_str)
 SET dm_str = "cdt.entity_name=request->xxx_combine_det[d.seq]->entity_name,"
 CALL parser(dm_str)
 SET dm_str = concat("cdt.",trim(cmb_det_table_id),"=seq(",trim(cmb_seq),", nextval),")
 CALL parser(dm_str)
 SET dm_str = "cdt.updt_cnt=INIT_UPDT_CNT,"
 CALL parser(dm_str)
 SET dm_str = "cdt.updt_dt_tm=cnvtdatetime(curdate, curtime3),"
 CALL parser(dm_str)
 SET dm_str = "cdt.updt_id=reqinfo->updt_id,"
 CALL parser(dm_str)
 SET dm_str = "cdt.updt_task=reqinfo->updt_task,"
 CALL parser(dm_str)
 SET dm_str = "cdt.updt_applctx=reqinfo->updt_applctx,"
 CALL parser(dm_str)
 SET dm_str = "cdt.active_ind=ACTIVE_ACTIVE_IND,"
 CALL parser(dm_str)
 SET dm_str = "cdt.active_status_cd=reqdata->active_status_cd,"
 CALL parser(dm_str)
 SET dm_str = "cdt.active_status_dt_tm=cnvtdatetime(curdate, curtime3),"
 CALL parser(dm_str)
 SET dm_str = "cdt.active_status_prsnl_id=reqinfo->updt_id,"
 CALL parser(dm_str)
 SET dm_str = concat("cdt.prev_active_ind = ","request->xxx_combine_det[d.seq]->prev_active_ind,")
 CALL parser(dm_str)
 SET dm_str = concat("cdt.combine_desc_cd = ","request->xxx_combine_det[d.seq]->combine_desc_cd,")
 CALL parser(dm_str)
 SET dm_str = concat("cdt.to_record_ind = ","request->xxx_combine_det[d.seq]->to_record_ind,")
 CALL parser(dm_str)
 SET dm_str = concat("cdt.prev_active_status_cd = ",
  "request->xxx_combine_det[d.seq]->prev_active_status_cd,")
 CALL parser(dm_str)
 SET dm_str = concat("cdt.prev_end_eff_dt_tm = ",
  "cnvtdatetime(request->xxx_combine_det[d.seq]->prev_end_eff_dt_tm) ")
 CALL parser(dm_str)
 SET dm_str = "plan d where cmb_temp->list[d.seq].row_exists = 0"
 CALL parser(dm_str)
 SET dm_str = "join cdt "
 CALL parser(dm_str)
 SET dm_str = " go "
 CALL parser(dm_str,1)
 IF (curqual > 0)
  SET dm_det_qual_ind = 1
 ENDIF
 SET custom_cmb_det_cnt = ((size(request->xxx_combine_det,5) - cmb_det_exists_cnt)+
 custom_cmb_det_cnt)
 IF (dm_debug_cmb)
  SET mem2 = curmem
  CALL echo(build("mem_used_parser=",(mem1 - mem2)))
 ENDIF
END GO
