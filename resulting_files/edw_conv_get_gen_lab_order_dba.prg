CREATE PROGRAM edw_conv_get_gen_lab_order:dba
 RECORD tmptext(
   1 qual[*]
     2 text = vc
 )
 DECLARE format = i2
 DECLARE line_len = i2
 DECLARE outbuffer = c32000
 DECLARE rtftext = c32000
 DECLARE nortftext = c32000
 SET format = 0
 SET line_len = 0
 SUBROUTINE rtf_to_text_context(rtftext,format,line_len,context)
   SET all_len = 0
   SET start = 0
   SET len = 0
   SET pos = 0
   SET linecnt = 0
   SET inbuffer = fillstring(32000," ")
   SET outbufferlen = 0
   SET bfl = 0
   SET bfl2 = 1
   SET outbuffer = fillstring(32000," ")
   SET nortftext = fillstring(32000," ")
   IF (substring(1,5,rtftext)=asis("{\rtf"))
    SET inbuffer = trim(rtftext)
    CALL uar_rtf2(inbuffer,size(inbuffer),outbuffer,size(outbuffer),outbufferlen,
     context)
   ELSE
    SET outbuffer = trim(rtftext)
   ENDIF
   SET nortftext = trim(outbuffer)
   SET stat = alterlist(tmptext->qual,0)
   SET crchar = concat(char(13),char(10))
   SET lfchar = char(10)
   SET ffchar = char(12)
   IF (format > 0)
    SET all_len = cnvtint(size(trim(outbuffer)))
    SET tot_len = 0
    SET start = 1
    SET bigfirst = "Y"
    SET crstart = start
    WHILE (all_len > tot_len)
      SET crpos = crstart
      SET crfirst = "Y"
      SET loaded = "N"
      WHILE ((crpos <= ((crstart+ line_len)+ 1))
       AND loaded="N"
       AND all_len > tot_len)
       IF ((crpos=((crstart+ line_len)+ 1))
        AND crfirst="N")
        SET start = crstart
        SET first = "Y"
        SET pos = ((start+ line_len) - 1)
        IF (bigfirst="Y"
         AND pos >= all_len)
         SET pos = start
        ENDIF
        SET bigfirst = "N"
        WHILE (pos >= start
         AND all_len > tot_len)
          IF (pos=start)
           SET pos = ((start+ line_len) - 1)
           SET linecnt = (linecnt+ 1)
           SET stat = alterlist(tmptext->qual,linecnt)
           SET len = ((pos - start)+ 1)
           SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
           SET start = (pos+ 1)
           SET crstart = (pos+ 1)
           SET pos = 0
           SET tot_len = ((tot_len+ len) - 1)
           SET loaded = "Y"
          ELSE
           IF (substring(pos,1,outbuffer)=" ")
            SET len = (pos - start)
            IF (cnvtint(size(trim(substring(start,len,outbuffer)))) > 0)
             SET linecnt = (linecnt+ 1)
             SET stat = alterlist(tmptext->qual,linecnt)
             SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
             SET loaded = "Y"
            ENDIF
            SET start = (pos+ 1)
            SET crstart = (pos+ 1)
            SET pos = 0
            SET tot_len = (tot_len+ len)
           ELSE
            IF (first="Y")
             SET first = "N"
             SET tot_len = (tot_len+ 1)
            ENDIF
            SET pos = (pos - 1)
           ENDIF
          ENDIF
        ENDWHILE
       ELSE
        SET crfirst = "N"
        IF (((substring(crpos,1,outbuffer)=crchar) OR (((substring(crpos,1,outbuffer)=lfchar) OR (
        substring(crpos,1,outbuffer)=ffchar)) )) )
         SET crlen = (crpos - crstart)
         SET linecnt = (linecnt+ 1)
         SET stat = alterlist(tmptext->qual,linecnt)
         SET tmptext->qual[linecnt].text = substring(crstart,crlen,outbuffer)
         SET loaded = "Y"
         IF (substring(crpos,1,outbuffer)=crchar)
          SET crstart = (crpos+ textlen(crchar))
         ELSEIF (substring(crpos,1,outbuffer)=lfchar)
          SET crstart = (crpos+ textlen(lfchar))
         ELSEIF (substring(crpos,1,outbuffer)=ffchar)
          SET crstart = (crpos+ textlen(ffchar))
         ENDIF
         SET tot_len = (tot_len+ crlen)
        ENDIF
       ENDIF
       SET crpos = (crpos+ 1)
      ENDWHILE
    ENDWHILE
   ENDIF
   SET rtftext = fillstring(32000," ")
   SET inbuffer = fillstring(32000," ")
 END ;Subroutine
 DECLARE outbufmaxsiz = i2
 DECLARE tblobin = c32000
 DECLARE tblobout = c32000
 DECLARE blobin = c32000
 DECLARE blobout = c32000
 SUBROUTINE decompress_text(tblobin)
   SET tblobout = fillstring(32000," ")
   SET blobout = fillstring(32000," ")
   SET outbufmaxsiz = 0
   SET blobin = trim(tblobin)
   CALL uar_ocf_uncompress(blobin,size(blobin),blobout,size(blobout),outbufmaxsiz)
   SET tblobout = blobout
   SET tblobin = fillstring(32000," ")
   SET blobin = fillstring(32000," ")
 END ;Subroutine
 SUBROUTINE rtf_to_text(rtftext,format,line_len)
   CALL rtf_to_text_context(rtftext,format,line_len,0)
 END ;Subroutine
 DECLARE order_id_cnt = i4 WITH noconstant(size(gen_lab_keys->qual,5))
 DECLARE glb_act_type_cd = f8 WITH protect, constant(edwgetcodevaluefromcdfmeaning(106,"GLB"))
 DECLARE hlx_act_type_cd = f8 WITH protect, constant(edwgetcodevaluefromcdfmeaning(106,"HLX"))
 DECLARE inst_where_clause = vc WITH protect, noconstant("1 = 1")
 DECLARE glb_ordr_time_zone = f8 WITH protect, noconstant(0.0)
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 DECLARE new_list_size = i4 WITH noconstant(0)
 DECLARE cur_list_size = i4 WITH noconstant(0)
 DECLARE batch_size = i4 WITH constant(50)
 DECLARE nstart = i4
 DECLARE loop_cnt = i4
 DECLARE idx = i4
 DECLARE num = i4
 DECLARE driver_cnt = i4
 DECLARE temp_indx = i4 WITH noconstant(0)
 DECLARE keys_start = i4 WITH noconstant(0)
 DECLARE keys_end = i4 WITH noconstant(0)
 DECLARE keys_batch = i4 WITH constant(large_batch_size)
 SET stat = alterlist(gen_lab_info->qual,keys_batch)
 DECLARE in_buffer = vc WITH public, noconstant("")
 DECLARE in_buffer_len = i4 WITH public, noconstant(0)
 DECLARE out_buffer = c1000 WITH public, noconstant("")
 DECLARE out_buffer_len = i4 WITH public, noconstant(1000)
 DECLARE ret_buffer_len = i4 WITH public, noconstant(0)
 DECLARE lt_flag = i4 WITH protect, noconstant(0)
 IF (validate(pca_filter,0)=0)
  SELECT DISTINCT INTO "nl:"
   ol.order_id
   FROM order_laboratory ol
   PLAN (ol
    WHERE ol.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
   ORDER BY ol.order_id
   DETAIL
    order_id_cnt = (order_id_cnt+ 1)
    IF (mod(order_id_cnt,100)=1)
     stat = alterlist(gen_lab_keys->qual,(order_id_cnt+ 99))
    ENDIF
    gen_lab_keys->qual[order_id_cnt].order_id = ol.order_id
   WITH nocounter
  ;end select
  IF (pd_glb_long_text="Y")
   SELECT DISTINCT INTO "nl:"
    lt.long_text_id
    FROM long_text lt
    PLAN (lt
     WHERE lt.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
    ORDER BY lt.long_text_id
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,100)=1)
      stat = alterlist(long_text_ids->qual,(cnt+ 99))
     ENDIF
     long_text_ids->qual[cnt].long_text_id = lt.long_text_id
    FOOT REPORT
     driver_cnt = cnt, stat = alterlist(long_text_ids->qual,cnt)
    WITH nocounter
   ;end select
   SET nstart = 1
   SET loop_cnt = ceil((cnvtreal(driver_cnt)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(long_text_ids->qual,new_list_size)
   SELECT DISTINCT INTO "nl:"
    osrc.order_id
    FROM (dummyt d  WITH seq = value(loop_cnt)),
     v500_specimen v500,
     container c,
     order_serv_res_container osrc
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (v500
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),v500.long_text_id,long_text_ids->qual[idx].
      long_text_id)
      AND v500.long_text_id > 0)
     JOIN (c
     WHERE c.specimen_id=v500.specimen_id)
     JOIN (osrc
     WHERE osrc.container_id=c.container_id)
    ORDER BY osrc.order_id
    DETAIL
     order_id_cnt = (order_id_cnt+ 1)
     IF (mod(order_id_cnt,100)=1)
      stat = alterlist(gen_lab_keys->qual,(order_id_cnt+ 99))
     ENDIF
     gen_lab_keys->qual[order_id_cnt].order_id = osrc.order_id
    WITH nocounter
   ;end select
   FREE RECORD long_text_ids
  ENDIF
  IF (pd_glb_v500_spec="Y")
   SELECT DISTINCT INTO "nl:"
    v500.specimen_id
    FROM v500_specimen v500
    PLAN (v500
     WHERE v500.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
    ORDER BY v500.specimen_id
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,100)=1)
      stat = alterlist(specimen_ids->qual,(cnt+ 99))
     ENDIF
     specimen_ids->qual[cnt].specimen_id = v500.specimen_id
    FOOT REPORT
     driver_cnt = cnt, stat = alterlist(specimen_ids->qual,cnt)
    WITH nocounter
   ;end select
   SET nstart = 1
   SET loop_cnt = ceil((cnvtreal(driver_cnt)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(specimen_ids->qual,new_list_size)
   SELECT DISTINCT INTO "nl:"
    osrc.order_id
    FROM (dummyt d  WITH seq = value(loop_cnt)),
     container c,
     order_serv_res_container osrc
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (c
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),c.specimen_id,specimen_ids->qual[idx].
      specimen_id)
      AND c.specimen_id > 0)
     JOIN (osrc
     WHERE osrc.container_id=c.container_id)
    ORDER BY osrc.order_id
    DETAIL
     order_id_cnt = (order_id_cnt+ 1)
     IF (mod(order_id_cnt,100)=1)
      stat = alterlist(gen_lab_keys->qual,(order_id_cnt+ 99))
     ENDIF
     gen_lab_keys->qual[order_id_cnt].order_id = osrc.order_id
    WITH nocounter
   ;end select
   FREE RECORD specimen_ids
  ENDIF
  IF (pd_glb_container="Y")
   SELECT DISTINCT INTO "nl:"
    c.container_id
    FROM container c
    PLAN (c
     WHERE c.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
    ORDER BY c.container_id
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,100)=1)
      stat = alterlist(container_ids->qual,(cnt+ 99))
     ENDIF
     container_ids->qual[cnt].container_id = c.container_id
    FOOT REPORT
     driver_cnt = cnt, stat = alterlist(container_ids->qual,cnt)
    WITH nocounter
   ;end select
   SET nstart = 1
   SET loop_cnt = ceil((cnvtreal(driver_cnt)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(container_ids->qual,new_list_size)
   SELECT DISTINCT INTO "nl:"
    osrc.order_id
    FROM (dummyt d  WITH seq = value(loop_cnt)),
     order_serv_res_container osrc
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (osrc
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),osrc.container_id,container_ids->qual[idx].
      container_id)
      AND osrc.container_id > 0)
    ORDER BY osrc.order_id
    DETAIL
     order_id_cnt = (order_id_cnt+ 1)
     IF (mod(order_id_cnt,100)=1)
      stat = alterlist(gen_lab_keys->qual,(order_id_cnt+ 99))
     ENDIF
     gen_lab_keys->qual[order_id_cnt].order_id = osrc.order_id
    WITH nocounter
   ;end select
   FREE RECORD container_ids
  ENDIF
  IF (pd_glb_osrc="Y")
   SELECT DISTINCT INTO "nl:"
    osrc.order_id
    FROM order_serv_res_container osrc
    PLAN (osrc
     WHERE osrc.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
    ORDER BY osrc.order_id
    DETAIL
     order_id_cnt = (order_id_cnt+ 1)
     IF (mod(order_id_cnt,100)=1)
      stat = alterlist(gen_lab_keys->qual,(order_id_cnt+ 99))
     ENDIF
     gen_lab_keys->qual[order_id_cnt].order_id = osrc.order_id
    WITH nocounter
   ;end select
  ENDIF
  IF (pd_glb_ord_detl="Y")
   SELECT DISTINCT INTO "nl:"
    od.order_id
    FROM orders o,
     order_detail od
    PLAN (o
     WHERE o.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
     JOIN (od
     WHERE od.order_id=o.order_id
      AND od.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
    ORDER BY od.order_id
    DETAIL
     order_id_cnt = (order_id_cnt+ 1)
     IF (mod(order_id_cnt,100)=1)
      stat = alterlist(gen_lab_keys->qual,(order_id_cnt+ 99))
     ENDIF
     gen_lab_keys->qual[order_id_cnt].order_id = od.order_id
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SELECT DISTINCT INTO value(gen_lab_order_extractfile)
  order_id = o.order_id, encntr_id = o.encntr_id, loc_facility_cd = encounter.loc_facility_cd
  FROM (dummyt d  WITH seq = value(order_id_cnt)),
   orders o,
   encounter
  PLAN (d
   WHERE order_id_cnt > 0)
   JOIN (o
   WHERE (o.order_id=gen_lab_keys->qual[d.seq].order_id)
    AND o.activity_type_cd IN (
   (SELECT
    code_value
    FROM code_value c
    WHERE c.code_set=106
     AND c.cdf_meaning IN ("GLB", "HLX")
     AND c.active_ind=1
     AND  NOT (c.code_value IN (glb_act_type_cd, hlx_act_type_cd)))))
   JOIN (encounter
   WHERE encounter.encntr_id=o.encntr_id
    AND parser(inst_filter)
    AND parser(org_filter))
  ORDER BY order_id
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), gen_lab_keys->qual[cnt].order_id = order_id, gen_lab_keys->qual[cnt].encntr_id =
   encntr_id,
   gen_lab_keys->qual[cnt].loc_facility_cd = encounter.loc_facility_cd
  FOOT REPORT
   order_id_cnt = cnt, stat = alterlist(gen_lab_keys->qual,order_id_cnt)
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 IF (size(gen_lab_keys->qual,5)=0)
  SET order_id_cnt = 0
  SET stat = alterlist(gen_lab_keys->qual,order_id_cnt)
 ENDIF
 SET keys_start = 1
 SET keys_end = minval(((keys_start+ keys_batch) - 1),order_id_cnt)
 WHILE (keys_start <= keys_end)
   SET temp_indx = 0
   FOR (i = keys_start TO keys_end)
     SET temp_indx = (temp_indx+ 1)
     SET gen_lab_info->qual[temp_indx].gen_lab_order_sk = gen_lab_keys->qual[i].order_id
     SET gen_lab_info->qual[temp_indx].order_sk = gen_lab_keys->qual[i].order_id
     SET gen_lab_info->qual[temp_indx].encntr_id = gen_lab_keys->qual[i].encntr_id
     SET gen_lab_info->qual[temp_indx].loc_facility_cd = gen_lab_keys->qual[i].loc_facility_cd
   ENDFOR
   IF (temp_indx < keys_batch)
    SET cur_list_size = temp_indx
    SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
    SET new_list_size = (loop_cnt * batch_size)
    SET stat = alterlist(gen_lab_info->qual,new_list_size)
    FOR (i = temp_indx TO new_list_size)
      SET gen_lab_info->qual[i].gen_lab_order_sk = gen_lab_info->qual[temp_indx].gen_lab_order_sk
    ENDFOR
   ELSE
    SET cur_list_size = keys_batch
    SET loop_cnt = (cnvtreal(keys_batch)/ batch_size)
   ENDIF
   SET nstart = 1
   SELECT INTO "nl:"
    n_resource_route_level_flag = nullind(ol.resource_route_level_flag)
    FROM (dummyt d  WITH seq = value(loop_cnt)),
     order_laboratory ol
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (ol
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),ol.order_id,gen_lab_info->qual[idx].
      gen_lab_order_sk)
      AND ol.order_id > 0)
    DETAIL
     index = locateval(num,1,cur_list_size,ol.order_id,gen_lab_info->qual[num].gen_lab_order_sk),
     gen_lab_info->qual[index].collection_priority_ref = ol.collection_priority_cd, gen_lab_info->
     qual[index].route_level_flg = nullcheck(build(ol.resource_route_level_flag)," ",
      n_resource_route_level_flag)
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
   SET nstart = 1
   SELECT INTO "nl:"
    od.order_id, od.oe_field_meaning, od.action_sequence,
    od.detail_sequence, n_oe_field_value = nullind(od.oe_field_value)
    FROM (dummyt d  WITH seq = value(loop_cnt)),
     order_detail od
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (od
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),od.order_id,gen_lab_info->qual[idx].
      gen_lab_order_sk)
      AND od.order_id > 0
      AND od.oe_field_meaning IN ("SPECRECDBY", "COLLECTEDYN"))
    ORDER BY od.order_id, od.oe_field_meaning, od.action_sequence,
     od.detail_sequence
    HEAD od.order_id
     index = locateval(num,1,cur_list_size,od.order_id,gen_lab_info->qual[num].gen_lab_order_sk)
    HEAD od.oe_field_meaning
     row + 0
    FOOT  od.oe_field_meaning
     CASE (od.oe_field_meaning)
      OF "SPECRECDBY":
       gen_lab_info->qual[index].specimen_received_prsnl = nullcheck(cnvtstring(od.oe_field_value,16),
        "0",n_oe_field_value)
      OF "COLLECTEDYN":
       gen_lab_info->qual[index].collected_ind = nullcheck(cnvtstring(od.oe_field_value,16)," ",
        n_oe_field_value)
     ENDCASE
    FOOT  od.order_id
     row + 0
    WITH nocounter
   ;end select
   SET nstart = 1
   SELECT INTO "nl:"
    osrc.order_id, osrc.container_id, n_volume = nullind(c.volume),
    n_specimen_src_text = nullind(v500.specimen_src_text)
    FROM (dummyt d  WITH seq = value(loop_cnt)),
     order_serv_res_container osrc,
     container c,
     v500_specimen v500
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (osrc
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),osrc.order_id,gen_lab_info->qual[idx].
      gen_lab_order_sk)
      AND osrc.order_id > 0)
     JOIN (c
     WHERE c.container_id=osrc.container_id)
     JOIN (v500
     WHERE v500.specimen_id=c.specimen_id)
    ORDER BY osrc.order_id, c.specimen_id, osrc.container_id
    HEAD osrc.order_id
     temp_first_cntr_volume = nullcheck(build(c.volume)," ",n_volume), sz_first_cntr_volume = size(
      trim(replace(temp_first_cntr_volume,"0"," ",0),1)), first_cntr_volume = substring(1,
      sz_first_cntr_volume,temp_first_cntr_volume)
     IF (substring(size(trim(first_cntr_volume)),1,first_cntr_volume)=".")
      first_cntr_volume = substring(1,(size(trim(first_cntr_volume)) - 1),first_cntr_volume)
     ENDIF
     index = locateval(num,1,cur_list_size,osrc.order_id,gen_lab_info->qual[num].gen_lab_order_sk),
     gen_lab_info->qual[index].frst_perf_svc_res_dept_hier_sk = osrc.service_resource_cd,
     gen_lab_info->qual[index].cntr_first_in_lab_dt_tm = osrc.in_lab_dt_tm,
     gen_lab_info->qual[index].first_ctnr_drawn_dt_tm = c.drawn_dt_tm, gen_lab_info->qual[index].
     first_ctnr_received_dt_tm = c.received_dt_tm, gen_lab_info->qual[index].
     first_ctnr_coll_method_ref = c.collection_method_cd,
     gen_lab_info->qual[index].first_ctnr_type_ref = c.spec_cntnr_cd, gen_lab_info->qual[index].
     first_cntr_units_ref = c.units_cd, gen_lab_info->qual[index].first_cntr_volume =
     first_cntr_volume,
     gen_lab_info->qual[index].first_specimen_type_ref = v500.specimen_type_cd, gen_lab_info->qual[
     index].first_creation_dt_tm = validate(v500.creation_dt_tm,""), gen_lab_info->qual[index].
     first_specimen_entr_prsnl = validate(v500.creation_prsnl_id,0.0),
     gen_lab_info->qual[index].first_specimen_coll_prsnl = v500.drawn_id, gen_lab_info->qual[index].
     first_specimen_source_comment = nullcheck(replace(v500.specimen_src_text,str_find,str_replace,3),
      " ",n_specimen_src_text), gen_lab_info->qual[index].source_site_freetext_id = v500.long_text_id,
     cont_cnt = 0, spec_cnt = 0
    HEAD c.specimen_id
     row + 0
    HEAD osrc.container_id
     row + 0
    FOOT  osrc.container_id
     cont_cnt = (cont_cnt+ 1)
    FOOT  c.specimen_id
     spec_cnt = (spec_cnt+ 1)
    FOOT  osrc.order_id
     gen_lab_info->qual[index].nbr_of_containers = cont_cnt, gen_lab_info->qual[index].
     nbr_of_specimens = spec_cnt
    WITH nocounter
   ;end select
   SET nstart = 1
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(loop_cnt)),
     long_text lt
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (lt
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),lt.long_text_id,gen_lab_info->qual[idx].
      source_site_freetext_id)
      AND lt.long_text_id > 0)
    DETAIL
     index = locateval(num,1,cur_list_size,lt.long_text_id,gen_lab_info->qual[num].
      source_site_freetext_id)
     WHILE (index != 0)
       CALL rtf_to_text(trim(lt.long_text),0,0), gen_lab_info->qual[index].source_site_freetext =
       nortftext, index = locateval(num,(index+ 1),cur_list_size,lt.long_text_id,gen_lab_info->qual[
        idx].source_site_freetext_id)
     ENDWHILE
    WITH nocounter
   ;end select
   FOR (i = 1 TO cur_list_size)
     SET glb_ordr_time_zone = gettimezone(gen_lab_info->qual[i].loc_facility_cd,gen_lab_info->qual[i]
      .encntr_id)
     SET gen_lab_info->qual[i].first_ctnr_drawn_tm_zn = cnvtint(glb_ordr_time_zone)
     SET gen_lab_info->qual[i].first_ctnr_received_tm_zn = cnvtint(glb_ordr_time_zone)
     SET gen_lab_info->qual[i].cntr_first_in_lab_tm_zn = cnvtint(glb_ordr_time_zone)
     SET gen_lab_info->qual[i].first_creation_tm_zn = cnvtint(glb_ordr_time_zone)
   ENDFOR
   IF (error(err_msg,1) != 0)
    SET scripterror_ind = 1
   ENDIF
   EXECUTE edw_create_gen_lab_order_files
   SET keys_start = (keys_end+ 1)
   SET keys_end = minval(((keys_start+ keys_batch) - 1),order_id_cnt)
 ENDWHILE
 FREE RECORD gen_lab_info
 CALL edwupdatescriptstatus("GLB_ORDR",order_id_cnt,"1","0")
 CALL echo(build("GLB_ORDR Count = ",order_id_cnt))
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "001 05/16/10 RP019504"
END GO
