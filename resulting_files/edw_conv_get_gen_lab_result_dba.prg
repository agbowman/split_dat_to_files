CREATE PROGRAM edw_conv_get_gen_lab_result:dba
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
 DECLARE gen_lab_rslt_cnt = i4 WITH noconstant(0)
 DECLARE result_id_cnt = i4 WITH noconstant(size(gen_lab_result_keys->qual,5))
 DECLARE gen_lab_result_parent_cnt = i4 WITH noconstant(0)
 DECLARE glb_act_type_cd = f8 WITH protect, constant(edwgetcodevaluefromcdfmeaning(106,"GLB"))
 DECLARE hlx_act_type_cd = f8 WITH protect, constant(edwgetcodevaluefromcdfmeaning(106,"HLX"))
 DECLARE verf_event_type_cd = f8 WITH protect, constant(edwgetcodevaluefromcdfmeaning(1901,"VERIFIED"
   ))
 DECLARE corr_event_type_cd = f8 WITH protect, constant(edwgetcodevaluefromcdfmeaning(1901,
   "CORRECTED"))
 DECLARE auto_event_type_cd = f8 WITH protect, constant(edwgetcodevaluefromcdfmeaning(1901,
   "AUTOVERIFIED"))
 DECLARE ref_resource_type_cd = f8 WITH protect, constant(edwgetcodevaluefromcdfmeaning(202,"REF_LAB"
   ))
 DECLARE inst_where_clause = vc WITH protect, noconstant("1 = 1")
 DECLARE glb_rslt_time_zone = f8 WITH protect, noconstant(0.0)
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 DECLARE new_list_size = i4 WITH noconstant(0)
 DECLARE cur_list_size = i4 WITH noconstant(0)
 DECLARE batch_size = i4 WITH constant(60)
 DECLARE nstart = i4
 DECLARE loop_cnt = i4
 DECLARE idx = i4
 DECLARE num = i4
 DECLARE temp_indx = i4 WITH noconstant(0)
 DECLARE keys_start = i4 WITH noconstant(0)
 DECLARE keys_end = i4 WITH noconstant(0)
 DECLARE keys_batch = i4 WITH constant(large_batch_size)
 DECLARE in_buffer = vc WITH public, noconstant("")
 DECLARE in_buffer_len = i4 WITH public, noconstant(0)
 DECLARE out_buffer = c1000 WITH public, noconstant("")
 DECLARE out_buffer_len = i4 WITH public, noconstant(1000)
 DECLARE ret_buffer_len = i4 WITH public, noconstant(0)
 DECLARE lt_flag = i4 WITH protect, noconstant(0)
 IF (validate(pca_filter,0)=0)
  SELECT DISTINCT INTO "nl:"
   r.result_id
   FROM result r
   PLAN (r
    WHERE r.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
   DETAIL
    result_id_cnt = (result_id_cnt+ 1)
    IF (mod(result_id_cnt,100)=1)
     stat = alterlist(gen_lab_result_keys->qual,(result_id_cnt+ 99))
    ENDIF
    gen_lab_result_keys->qual[result_id_cnt].result_id = r.result_id
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   pr.result_id
   FROM perform_result pr
   PLAN (pr
    WHERE pr.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
   DETAIL
    result_id_cnt = (result_id_cnt+ 1)
    IF (mod(result_id_cnt,100)=1)
     stat = alterlist(gen_lab_result_keys->qual,(result_id_cnt+ 99))
    ENDIF
    gen_lab_result_keys->qual[result_id_cnt].result_id = pr.result_id
   WITH nocounter
  ;end select
  IF (pd_glb_result_event="Y")
   SELECT DISTINCT INTO "nl:"
    re.result_id
    FROM result_event re
    PLAN (re
     WHERE re.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
    DETAIL
     result_id_cnt = (result_id_cnt+ 1)
     IF (mod(result_id_cnt,100)=1)
      stat = alterlist(gen_lab_result_keys->qual,(result_id_cnt+ 99))
     ENDIF
     gen_lab_result_keys->qual[result_id_cnt].result_id = re.result_id
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET cnt = - (1)
 SELECT DISTINCT INTO value(gen_lab_result_extractfile)
  result_id = r.result_id, order_id = o.order_id, encntr_id = o.encntr_id,
  loc_facility_cd = encounter.loc_facility_cd
  FROM (dummyt d  WITH seq = value(result_id_cnt)),
   result r,
   orders o,
   encounter
  PLAN (d
   WHERE result_id_cnt > 0)
   JOIN (r
   WHERE (r.result_id=gen_lab_result_keys->qual[d.seq].result_id))
   JOIN (o
   WHERE o.order_id=r.order_id
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
  ORDER BY order_id, result_id
  HEAD REPORT
   cnt = 0, gen_lab_result_parent_cnt = 0
  HEAD order_id
   gen_lab_result_parent_cnt = (gen_lab_result_parent_cnt+ 1)
   IF (mod(gen_lab_result_parent_cnt,100)=1)
    stat = alterlist(gen_lab_result_parent_keys->qual,(gen_lab_result_parent_cnt+ 99))
   ENDIF
   gen_lab_result_parent_keys->qual[gen_lab_result_parent_cnt].order_id = order_id
  DETAIL
   cnt = (cnt+ 1), gen_lab_result_keys->qual[cnt].result_id = result_id, gen_lab_result_keys->qual[
   cnt].order_id = order_id,
   gen_lab_result_keys->qual[cnt].encntr_id = encntr_id, gen_lab_result_keys->qual[cnt].
   loc_facility_cd = encounter.loc_facility_cd
  FOOT REPORT
   result_id_cnt = cnt, stat = alterlist(gen_lab_result_keys->qual,result_id_cnt), stat = alterlist(
    gen_lab_result_parent_keys->qual,gen_lab_result_parent_cnt)
  WITH noheading, nocounter, format = lfstream,
   maxcol = 35000, maxrow = 1, append
 ;end select
 IF (size(gen_lab_result_keys->qual,5)=0)
  SET result_id_cnt = 0
  SET stat = alterlist(gen_lab_result_keys->qual,result_id_cnt)
 ENDIF
 SET keys_start = 1
 SET keys_end = minval(((keys_start+ keys_batch) - 1),result_id_cnt)
 WHILE (keys_start <= keys_end)
   SET stat = alterlist(gen_lab_result_info->qual,keys_batch)
   IF (debug="Y")
    CALL echo(concat("Looping from keys_start = ",build(keys_start)," to keys_end = ",build(keys_end)
      ))
   ENDIF
   SET temp_indx = 0
   FOR (i = keys_start TO keys_end)
     SET temp_indx = (temp_indx+ 1)
     SET gen_lab_result_info->qual[temp_indx].encntr_id = gen_lab_result_keys->qual[i].encntr_id
     SET gen_lab_result_info->qual[temp_indx].loc_facility_cd = gen_lab_result_keys->qual[i].
     loc_facility_cd
     SET gen_lab_result_info->qual[temp_indx].gen_lab_order_sk = gen_lab_result_keys->qual[i].
     order_id
     SET gen_lab_result_info->qual[temp_indx].gen_lab_result_sk = gen_lab_result_keys->qual[i].
     result_id
   ENDFOR
   IF (temp_indx < keys_batch)
    SET cur_list_size = temp_indx
    SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
    SET new_list_size = (loop_cnt * batch_size)
    SET stat = alterlist(gen_lab_result_info->qual,new_list_size)
    FOR (i = temp_indx TO new_list_size)
      SET gen_lab_result_info->qual[i].gen_lab_result_sk = gen_lab_result_info->qual[temp_indx].
      gen_lab_result_sk
    ENDFOR
   ELSE
    SET cur_list_size = keys_batch
    SET loop_cnt = (cnvtreal(keys_batch)/ batch_size)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(cur_list_size)),
     result r
    PLAN (d)
     JOIN (r
     WHERE (r.result_id=gen_lab_result_info->qual[d.seq].gen_lab_result_sk))
    HEAD REPORT
     gen_lab_rslt_cnt = 0
    HEAD r.result_id
     gen_lab_rslt_cnt = (gen_lab_rslt_cnt+ 1)
    DETAIL
     gen_lab_result_info->qual[d.seq].task_assay_sk = r.task_assay_cd, gen_lab_result_info->qual[d
     .seq].biological_category_ref = validate(r.biological_category_cd,0.0), gen_lab_result_info->
     qual[d.seq].result_status_ref = r.result_status_cd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    pr.result_id, pr.result_status_cd, pr.perform_dt_tm,
    n_result_value_numeric = nullind(pr.result_value_numeric), n_numeric_raw_value = nullind(pr
     .numeric_raw_value), n_dilution_factor = nullind(pr.dilution_factor),
    n_interface_flag = nullind(pr.interface_flag), n_interp_override_ind = nullind(pr
     .interp_override_ind), n_less_great_flag = nullind(pr.less_great_flag),
    n_normal_high = nullind(pr.normal_high), n_normal_low = nullind(pr.normal_low)
    FROM (dummyt d  WITH seq = value(cur_list_size)),
     perform_result pr
    PLAN (d)
     JOIN (pr
     WHERE (pr.result_id=gen_lab_result_info->qual[d.seq].gen_lab_result_sk)
      AND (pr.result_status_cd=gen_lab_result_info->qual[d.seq].result_status_ref))
    ORDER BY pr.result_id, pr.perform_dt_tm
    DETAIL
     gen_lab_result_info->qual[d.seq].long_text_id = pr.long_text_id, gen_lab_result_info->qual[d.seq
     ].result_value_formatted = pr.ascii_text, gen_lab_result_info->qual[d.seq].codified_result_nomen
      = pr.nomenclature_id,
     gen_lab_result_info->qual[d.seq].result_raw_value_txt = pr.raw_result_str, gen_lab_result_info->
     qual[d.seq].result_value_txt = pr.result_value_alpha, gen_lab_result_info->qual[d.seq].
     result_value_dt_tm = pr.result_value_dt_tm,
     gen_lab_result_info->qual[d.seq].result_value_numeric = nullcheck(build(pr.result_value_numeric),
      " ",n_result_value_numeric), gen_lab_result_info->qual[d.seq].result_raw_value_numeric =
     nullcheck(build(pr.numeric_raw_value)," ",n_numeric_raw_value), gen_lab_result_info->qual[d.seq]
     .result_value_unit_ref = pr.units_cd,
     gen_lab_result_info->qual[d.seq].critical_ref = pr.critical_cd, gen_lab_result_info->qual[d.seq]
     .feasible_ref = pr.feasible_cd, gen_lab_result_info->qual[d.seq].linear_ref = pr.linear_cd,
     gen_lab_result_info->qual[d.seq].normal_ref = pr.normal_cd, gen_lab_result_info->qual[d.seq].
     qc_override_ref = validate(pr.qc_override_cd,0.0), gen_lab_result_info->qual[d.seq].review_ref
      = pr.review_cd,
     gen_lab_result_info->qual[d.seq].delta_ref = pr.delta_cd, gen_lab_result_info->qual[d.seq].
     dilution_factor = nullcheck(build(pr.dilution_factor)," ",n_dilution_factor),
     gen_lab_result_info->qual[d.seq].interface_flg = nullcheck(build(pr.interface_flag)," ",
      n_interface_flag),
     gen_lab_result_info->qual[d.seq].interp_override_ind = nullcheck(build(pr.interp_override_ind),
      " ",n_interp_override_ind), gen_lab_result_info->qual[d.seq].qual_operator_flg = nullcheck(
      build(pr.less_great_flag)," ",n_less_great_flag), gen_lab_result_info->qual[d.seq].normal_alpha
      = pr.normal_alpha,
     gen_lab_result_info->qual[d.seq].normal_high = nullcheck(build(pr.normal_high)," ",n_normal_high
      ), gen_lab_result_info->qual[d.seq].normal_low = nullcheck(build(pr.normal_low)," ",
      n_normal_low), gen_lab_result_info->qual[d.seq].perform_dt_tm = pr.perform_dt_tm,
     gen_lab_result_info->qual[d.seq].perform_prsnl = pr.perform_personnel_id, gen_lab_result_info->
     qual[d.seq].perform_tm_zn = validate(pr.perform_tz,0), gen_lab_result_info->qual[d.seq].
     reference_range_factor_sk = pr.reference_range_factor_id,
     gen_lab_result_info->qual[d.seq].repeat_seq = pr.repeat_nbr, gen_lab_result_info->qual[d.seq].
     result_type_ref = pr.result_type_cd, gen_lab_result_info->qual[d.seq].
     perform_svc_res_dept_hier_sk = pr.service_resource_cd
    WITH nocounter
   ;end select
   SET nstart = 1
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(loop_cnt)),
     long_text lt
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (lt
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),lt.long_text_id,gen_lab_result_info->qual[idx
      ].long_text_id)
      AND lt.long_text_id > 0)
    DETAIL
     index = locateval(num,1,cur_list_size,lt.long_text_id,gen_lab_result_info->qual[num].
      long_text_id)
     WHILE (index != 0)
       CALL rtf_to_text(trim(lt.long_text),0,0), gen_lab_result_info->qual[index].
       result_value_formatted = nortftext, index = locateval(num,(index+ 1),cur_list_size,lt
        .long_text_id,gen_lab_result_info->qual[num].long_text_id)
     ENDWHILE
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    r.result_id, re.event_sequence
    FROM (dummyt d  WITH seq = value(cur_list_size)),
     result r,
     perform_result pr,
     result_event re
    PLAN (d)
     JOIN (r
     WHERE (r.result_id=gen_lab_result_info->qual[d.seq].gen_lab_result_sk)
      AND r.result_id > 0)
     JOIN (pr
     WHERE pr.result_id=r.result_id
      AND pr.result_status_cd=r.result_status_cd)
     JOIN (re
     WHERE re.result_id=pr.result_id
      AND re.perform_result_id=pr.perform_result_id
      AND re.event_type_cd IN (verf_event_type_cd, corr_event_type_cd, auto_event_type_cd))
    ORDER BY r.result_id, re.event_sequence
    HEAD r.result_id
     row + 0
    FOOT  r.result_id
     gen_lab_result_info->qual[d.seq].verified_prsnl = re.event_personnel_id, gen_lab_result_info->
     qual[d.seq].verified_dt_tm = re.event_dt_tm
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(cur_list_size)),
     organization_resource org
    PLAN (d)
     JOIN (org
     WHERE (org.service_resource_cd=gen_lab_result_info->qual[d.seq].perform_svc_res_dept_hier_sk)
      AND org.ref_lab_ind=1
      AND org.org_resource_type_cd=ref_resource_type_cd)
    DETAIL
     gen_lab_result_info->qual[d.seq].reference_lab = org.ref_lab_description
    WITH nocounter
   ;end select
   FOR (i = 1 TO gen_lab_rslt_cnt)
     SET glb_rslt_time_zone = gettimezone(gen_lab_result_info->qual[i].loc_facility_cd,
      gen_lab_result_info->qual[i].encntr_id)
     SET gen_lab_result_info->qual[i].result_value_tm_zn = cnvtint(glb_rslt_time_zone)
     SET gen_lab_result_info->qual[i].perform_tm_zn = evaluate(gen_lab_result_info->qual[i].
      perform_tm_zn,0,cnvtint(glb_rslt_time_zone),gen_lab_result_info->qual[i].perform_tm_zn)
     SET gen_lab_result_info->qual[i].verified_tm_zn = cnvtint(glb_rslt_time_zone)
   ENDFOR
   IF (error(err_msg,1) != 0)
    SET scripterror_ind = 1
   ENDIF
   EXECUTE edw_create_gen_lab_result_file
   SET stat = alterlist(gen_lab_result_info->qual,0)
   SET keys_start = (keys_end+ 1)
   SET keys_end = minval(((keys_start+ keys_batch) - 1),result_id_cnt)
 ENDWHILE
 FREE RECORD gen_lab_result_info
 FREE RECORD gen_lab_result_keys
 CALL edwupdatescriptstatus("GLB_RSLT",result_id_cnt,"1","0")
 CALL echo(build("GLB_RSLT Count = ",result_id_cnt))
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "001 05/16/10 RP019504"
END GO
