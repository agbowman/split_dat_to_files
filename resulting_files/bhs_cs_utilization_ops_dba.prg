CREATE PROGRAM bhs_cs_utilization_ops:dba
 PROMPT
  "Output to File/Printer/MINE/Email" = "MINE",
  "Beginning Date:" = "SYSDATE",
  "Ending Date:" = "SYSDATE",
  "Care Set" = "",
  "Physician List" = "",
  "Detail Level:" = 1
  WITH outdev, begdate, enddate,
  careset, physlist, det_level
 EXECUTE bhs_sys_stand_subroutine
 DECLARE output_dest = vc
 IF (findstring("@", $OUTDEV) > 0)
  SET email_ind = 1
  SET output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(curdate,curtime3),
     "MMDDYYYYHHMMSS;;D")))
 ELSE
  SET email_ind = 0
  SET output_dest =  $OUTDEV
 ENDIF
 IF (( $BEGDATE="BOM"))
  SET beg_date_qual = datetimefind(cnvtdatetime((curdate - 20),0),"M","B","B")
 ELSE
  SET beg_date_qual = cnvtdatetime( $BEGDATE)
 ENDIF
 IF (( $ENDDATE="EOM"))
  SET end_date_qual = datetimefind(cnvtdatetime((curdate - 20),0),"M","E","E")
 ELSE
  SET end_date_qual = cnvtdatetime( $ENDDATE)
 ENDIF
 CALL echo(format(beg_date_qual,"MM/DD/YYYY ;;D"))
 CALL echo(format(end_date_qual,"MM/DD/YYYY ;;D"))
 FREE RECORD cs_util
 RECORD cs_util(
   1 list[*]
     2 cs_catalog_cd = f8
     2 cs_primary_mnemonic = vc
     2 cs_ordered = i4
     2 ord_synonym_id = f8
     2 ord_catalog_cd = f8
     2 ord_mnemonic = vc
     2 ord_comp_seq = i4
     2 ord_ordered = i4
 )
 DECLARE bocu_cnt = i4
 SET bocu_cnt = 0
 DECLARE cs_any_type = c1
 DECLARE phys_any_type = c1
 IF (textlen(trim( $CARESET))=1)
  SET cs_any_type = "C"
 ENDIF
 IF (textlen(trim( $PHYSLIST))=1)
  SET phys_any_type = "C"
 ENDIF
 FREE RECORD physicians
 RECORD physicians(
   1 list[*]
     2 name_full_formatted = vc
 )
 IF (phys_any_type != "C")
  SELECT INTO "nl:"
   FROM prsnl pr
   PLAN (pr
    WHERE pr.person_id=cnvtreal( $PHYSLIST))
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(physicians->list,(cnt+ 9))
    ENDIF
    physicians->list[cnt].name_full_formatted = pr.name_full_formatted
   FOOT REPORT
    stat = alterlist(physicians->list,cnt)
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD caresets
 RECORD caresets(
   1 list[*]
     2 careset_name = vc
 )
 IF (cs_any_type != "C")
  SELECT INTO "nl:"
   FROM order_catalog oc
   PLAN (oc
    WHERE oc.catalog_cd=cnvtreal( $CARESET))
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(caresets->list,(cnt+ 9))
    ENDIF
    caresets->list[cnt].careset_name = oc.primary_mnemonic
   FOOT REPORT
    stat = alterlist(caresets->list,cnt)
   WITH nocounter
  ;end select
 ENDIF
 DECLARE orderable_comp_type_cd = f8
 DECLARE order_order_action_cd = f8
 DECLARE physician_name = vc
 DECLARE outstring = vc
 SET orderable_comp_type_cd = uar_get_code_by("MEANING",6030,"ORDERABLE")
 SET order_order_action_cd = uar_get_code_by("MEANING",6003,"ORDER")
 IF (( $DET_LEVEL=1))
  FREE RECORD cs_detail
  RECORD cs_detail(
    1 list[*]
      2 pat_name = vc
      2 account_num = vc
      2 careset_name = vc
      2 date_ordered = dq8
      2 facility_cd = f8
      2 physician_name = vc
      2 ordering_position_cd = f8
  )
  SELECT
   IF (cs_any_type="C"
    AND phys_any_type="C")
    PLAN (bocu
     WHERE bocu.orig_order_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual))
     JOIN (o
     WHERE o.order_id=bocu.order_id)
     JOIN (oa
     WHERE oa.order_id=o.order_id
      AND oa.action_type_cd=order_order_action_cd)
     JOIN (pr
     WHERE pr.person_id=oa.order_provider_id)
     JOIN (pr2
     WHERE pr2.person_id=oa.action_personnel_id)
     JOIN (p
     WHERE p.person_id=o.person_id)
     JOIN (ea
     WHERE ea.encntr_id=o.encntr_id
      AND ea.encntr_alias_type_cd=1077
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ELSEIF (cs_any_type != "C"
    AND phys_any_type="C")
    PLAN (bocu
     WHERE bocu.orig_order_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
      AND bocu.catalog_cd=cnvtreal( $CARESET))
     JOIN (o
     WHERE o.order_id=bocu.order_id)
     JOIN (oa
     WHERE oa.order_id=o.order_id
      AND oa.action_type_cd=order_order_action_cd)
     JOIN (pr
     WHERE pr.person_id=oa.order_provider_id)
     JOIN (pr2
     WHERE pr2.person_id=oa.action_personnel_id)
     JOIN (p
     WHERE p.person_id=o.person_id)
     JOIN (ea
     WHERE ea.encntr_id=o.encntr_id
      AND ea.encntr_alias_type_cd=1077
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ELSEIF (cs_any_type="C"
    AND phys_any_type != "C")
    PLAN (bocu
     WHERE bocu.orig_order_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
      AND bocu.ordering_physician_id=cnvtreal( $PHYSLIST))
     JOIN (o
     WHERE o.order_id=bocu.order_id)
     JOIN (oa
     WHERE oa.order_id=o.order_id
      AND oa.action_type_cd=order_order_action_cd)
     JOIN (pr
     WHERE pr.person_id=oa.order_provider_id)
     JOIN (pr2
     WHERE pr2.person_id=oa.action_personnel_id)
     JOIN (p
     WHERE p.person_id=o.person_id)
     JOIN (ea
     WHERE ea.encntr_id=o.encntr_id
      AND ea.encntr_alias_type_cd=1077
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ELSEIF (cs_any_type != "C"
    AND phys_any_type != "C")
    PLAN (bocu
     WHERE bocu.orig_order_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
      AND bocu.ordering_physician_id=cnvtreal( $PHYSLIST)
      AND bocu.catalog_cd=cnvtreal( $CARESET))
     JOIN (o
     WHERE o.order_id=bocu.order_id)
     JOIN (oa
     WHERE oa.order_id=o.order_id
      AND oa.action_type_cd=order_order_action_cd)
     JOIN (pr
     WHERE pr.person_id=oa.order_provider_id)
     JOIN (pr2
     WHERE pr2.person_id=oa.action_personnel_id)
     JOIN (p
     WHERE p.person_id=o.person_id)
     JOIN (ea
     WHERE ea.encntr_id=o.encntr_id
      AND ea.encntr_alias_type_cd=1077
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ELSE
   ENDIF
   INTO value(output_dest)
   FROM bhs_ord_cs_utiliz bocu,
    prsnl pr,
    orders o,
    encntr_alias ea,
    order_action oa,
    prsnl pr2,
    person p
   HEAD REPORT
    begdate_disp1 = "          ", enddate_disp1 = "          ", outstring =
    ',"BHS Careset Utilization"',
    col 1, outstring, row + 1
    IF (cs_any_type="C")
     col 1, ',"All Caresets"', row + 1
    ELSE
     FOR (i = 1 TO size(caresets->list,5))
       IF (i=1)
        outstring = concat(',"Careset(s):","',caresets->list[i].careset_name,'"')
       ELSE
        outstring = concat(',"","',caresets->list[i].careset_name,'"')
       ENDIF
       col 1, outstring, row + 1
     ENDFOR
    ENDIF
    IF (phys_any_type="C")
     col 1, ',"All Physicians"', row + 1
    ELSE
     FOR (i = 1 TO size(physicians->list,5))
       IF (i=1)
        outstring = concat(',"Physician(s):","',physicians->list[i].name_full_formatted,'"')
       ELSE
        outstring = concat(',"","',physicians->list[i].name_full_formatted,'"')
       ENDIF
       col 1, outstring, row + 1
     ENDFOR
    ENDIF
    IF (( $DET_LEVEL=1))
     col 1, ',"Careset Level Detail"', row + 1
    ELSE
     col 1, ',"Order Level Summary"', row + 1
    ENDIF
    begdate_disp1 = format(beg_date_qual,"mm/dd/yyyy;;d"), enddate_disp1 = format(end_date_qual,
     "mm/dd/yyyy;;d"), outstring = concat(',"Beginning Date: ",',begdate_disp1),
    col 1, outstring, row + 1,
    outstring = concat(',"Ending Date: ",',enddate_disp1), col 1, outstring,
    row + 1, outstring = build(',"Patient Name","Account Number","Careset Name","Physician Name",',
     '"Order Date","Ordered by Position","Facility",'), col 1,
    outstring, row + 1
   DETAIL
    pat_name_disp = substring(1,30,p.name_full_formatted), fin_nbr_disp = substring(1,15,cnvtalias(ea
      .alias,ea.alias_pool_cd)), cs_name_disp = substring(1,50,uar_get_code_display(bocu.catalog_cd)),
    phys_name_disp = substring(1,30,pr.name_full_formatted), ord_date_disp = format(bocu
     .orig_order_dt_tm,"MM/DD/YYYY;;D"), ord_prsnl_pos_disp = substring(1,20,uar_get_code_display(pr2
      .position_cd)),
    fac_disp = substring(1,15,uar_get_code_display(bocu.facility_cd)), outstring = build(',"',
     pat_name_disp,'","',fin_nbr_disp,'","',
     cs_name_disp,'","',phys_name_disp,'",',ord_date_disp,
     ',"',ord_prsnl_pos_disp,'","',fac_disp,'",'), col 1,
    outstring, row + 1
   WITH maxcol = 180, format = variable, maxrow = 1,
    nullreport
  ;end select
  GO TO emailcheck
  GO TO endprogram
 ENDIF
 DECLARE primary_mnemonic_cd = f8
 SET primary_mnemonic_cd = uar_get_code_by("MEANING",6011,"PRIMARY")
 SELECT
  IF (cs_any_type="C")
   PLAN (ocs1
    WHERE ocs1.orderable_type_flag=6
     AND ocs1.active_ind=1
     AND ocs1.mnemonic_type_cd=primary_mnemonic_cd)
    JOIN (cc
    WHERE cc.catalog_cd=ocs1.catalog_cd
     AND cc.comp_type_cd=orderable_comp_type_cd)
    JOIN (ocs
    WHERE ocs.synonym_id=cc.comp_id)
  ELSE
   PLAN (ocs1
    WHERE ocs1.orderable_type_flag=6
     AND ocs1.active_ind=1
     AND ocs1.mnemonic_type_cd=primary_mnemonic_cd
     AND ocs1.catalog_cd=cnvtreal( $CARESET))
    JOIN (cc
    WHERE cc.catalog_cd=ocs1.catalog_cd
     AND cc.comp_type_cd=orderable_comp_type_cd)
    JOIN (ocs
    WHERE ocs.synonym_id=cc.comp_id)
  ENDIF
  INTO "nl:"
  FROM cs_component cc,
   order_catalog_synonym ocs,
   order_catalog_synonym ocs1
  ORDER BY ocs1.catalog_cd, ocs.catalog_cd
  HEAD REPORT
   row + 0
  HEAD ocs1.catalog_cd
   IF (( $DET_LEVEL=3))
    bocu_cnt = (bocu_cnt+ 1)
    IF (mod(bocu_cnt,10)=1)
     stat = alterlist(cs_util->list,(bocu_cnt+ 9))
    ENDIF
    cs_util->list[bocu_cnt].cs_catalog_cd = ocs1.catalog_cd, cs_util->list[bocu_cnt].
    cs_primary_mnemonic = ocs1.mnemonic, ocs_cnt = 0
   ENDIF
  HEAD ocs.catalog_cd
   IF (( $DET_LEVEL=2))
    bocu_cnt = (bocu_cnt+ 1)
    IF (mod(bocu_cnt,10)=1)
     stat = alterlist(cs_util->list,(bocu_cnt+ 9))
    ENDIF
    cs_util->list[bocu_cnt].cs_catalog_cd = ocs1.catalog_cd, cs_util->list[bocu_cnt].
    cs_primary_mnemonic = ocs1.mnemonic, ocs_cnt = 0,
    cs_util->list[bocu_cnt].ord_synonym_id = ocs.synonym_id, cs_util->list[bocu_cnt].ord_mnemonic =
    ocs.mnemonic, cs_util->list[bocu_cnt].ord_comp_seq = cc.comp_seq,
    cs_util->list[bocu_cnt].ord_catalog_cd = ocs.catalog_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(cs_util->list,bocu_cnt)
  WITH nocounter
 ;end select
 IF (( $DET_LEVEL=3))
  SELECT
   IF (cs_any_type="C"
    AND phys_any_type="C")
    PLAN (d)
     JOIN (bocu
     WHERE bocu.orig_order_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
      AND (bocu.catalog_cd=cs_util->list[d.seq].cs_catalog_cd))
   ELSEIF (cs_any_type="C"
    AND phys_any_type != "C")
    PLAN (d)
     JOIN (bocu
     WHERE bocu.orig_order_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
      AND (bocu.catalog_cd=cs_util->list[d.seq].cs_catalog_cd)
      AND bocu.ordering_physician_id=cnvtreal( $PHYSLIST))
   ELSEIF (cs_any_type != "C"
    AND phys_any_type="C")
    PLAN (d)
     JOIN (bocu
     WHERE bocu.orig_order_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
      AND (bocu.catalog_cd=cs_util->list[d.seq].cs_catalog_cd)
      AND bocu.catalog_cd=cnvtreal( $CARESET))
   ELSEIF (cs_any_type != "C"
    AND phys_any_type != "C")
    PLAN (d)
     JOIN (bocu
     WHERE bocu.orig_order_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
      AND (bocu.catalog_cd=cs_util->list[d.seq].cs_catalog_cd)
      AND bocu.ordering_physician_id=cnvtreal( $PHYSLIST)
      AND bocu.catalog_cd=cnvtreal( $CARESET))
   ELSE
   ENDIF
   INTO "nl:"
   sort_rec = cs_util->list[d.seq].cs_catalog_cd
   FROM bhs_ord_cs_utiliz bocu,
    (dummyt d  WITH seq = value(bocu_cnt))
   ORDER BY sort_rec
   DETAIL
    cs_util->list[d.seq].cs_ordered = (cs_util->list[d.seq].cs_ordered+ 1)
   WITH counter
  ;end select
 ENDIF
 IF (( $DET_LEVEL=2))
  SELECT
   IF (cs_any_type="C"
    AND phys_any_type="C")
    PLAN (d)
     JOIN (bocu
     WHERE bocu.orig_order_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
      AND (bocu.catalog_cd=cs_util->list[d.seq].cs_catalog_cd))
     JOIN (d2)
     JOIN (bocud
     WHERE bocud.cs_order_id=bocu.order_id
      AND (bocud.catalog_cd=cs_util->list[d.seq].ord_catalog_cd))
   ELSEIF (cs_any_type="C"
    AND phys_any_type != "C")
    PLAN (d)
     JOIN (bocu
     WHERE bocu.orig_order_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
      AND (bocu.catalog_cd=cs_util->list[d.seq].cs_catalog_cd))
     JOIN (d2)
     JOIN (bocud
     WHERE bocud.cs_order_id=bocu.order_id
      AND (bocud.catalog_cd=cs_util->list[d.seq].ord_catalog_cd)
      AND bocu.ordering_physician_id=cnvtreal( $PHYSLIST))
   ELSEIF (cs_any_type != "C"
    AND phys_any_type="C")
    PLAN (d)
     JOIN (bocu
     WHERE bocu.orig_order_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
      AND (bocu.catalog_cd=cs_util->list[d.seq].cs_catalog_cd))
     JOIN (d2)
     JOIN (bocud
     WHERE bocud.cs_order_id=bocu.order_id
      AND (bocud.catalog_cd=cs_util->list[d.seq].ord_catalog_cd)
      AND bocu.catalog_cd=cnvtreal( $CARESET))
   ELSEIF (cs_any_type != "C"
    AND phys_any_type != "C")
    PLAN (d)
     JOIN (bocu
     WHERE bocu.orig_order_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
      AND (bocu.catalog_cd=cs_util->list[d.seq].cs_catalog_cd))
     JOIN (d2)
     JOIN (bocud
     WHERE bocud.cs_order_id=bocu.order_id
      AND (bocud.catalog_cd=cs_util->list[d.seq].ord_catalog_cd)
      AND bocu.ordering_physician_id=cnvtreal( $PHYSLIST)
      AND bocu.catalog_cd=cnvtreal( $CARESET))
   ELSE
   ENDIF
   INTO "nl:"
   FROM bhs_ord_cs_utiliz bocu,
    bhs_ord_cs_utiliz_detail bocud,
    (dummyt d  WITH seq = value(bocu_cnt)),
    dummyt d2
   ORDER BY bocu.order_id, bocud.order_id, bocud.catalog_cd
   HEAD bocu.order_id
    cs_util->list[d.seq].cs_ordered = (cs_util->list[d.seq].cs_ordered+ 1)
   HEAD bocud.catalog_cd
    cs_util->list[d.seq].ord_ordered = (cs_util->list[d.seq].ord_ordered+ 1)
   WITH counter, outerjoin = d2
  ;end select
 ENDIF
 SELECT INTO value(output_dest)
  cs_catalog_cd = cs_util->list[d.seq].cs_catalog_cd, cs_comp_seq = cs_util->list[d.seq].ord_comp_seq
  FROM (dummyt d  WITH seq = value(bocu_cnt))
  ORDER BY cs_catalog_cd, cs_comp_seq
  HEAD REPORT
   outstring = ',"BHS Careset Utilization"', col 1, outstring,
   row + 1
   IF (cs_any_type="C")
    col 1, ',"All Caresets"', row + 1
   ELSE
    FOR (i = 1 TO size(caresets->list,5))
      IF (i=1)
       outstring = concat(',"Careset(s):","',caresets->list[i].careset_name,'"')
      ELSE
       outstring = concat(',"","',caresets->list[i].careset_name,'"')
      ENDIF
      col 1, outstring, row + 1
    ENDFOR
   ENDIF
   IF (phys_any_type="C")
    col 1, ',"All Physicians"', row + 1
   ELSE
    FOR (i = 1 TO size(physicians->list,5))
      IF (i=1)
       outstring = concat(',"Physician(s):","',physicians->list[i].name_full_formatted,'"')
      ELSE
       outstring = concat(',"","',physicians->list[i].name_full_formatted,'"')
      ENDIF
      col 1, outstring, row + 1
    ENDFOR
   ENDIF
   IF (( $DET_LEVEL=1))
    col 1, ',"Careset Level Detail"', row + 1
   ELSEIF (( $DET_LEVEL=2))
    col 1, ',"Order Level Summary"', row + 1
   ELSEIF (( $DET_LEVEL=3))
    col 1, ',"Careset Level Summary",', row + 1
   ENDIF
   outstring = concat(',"Beginning Date: ",',format(beg_date_qual,"MM/DD/YYYY;;D")), col 1, outstring,
   row + 1, outstring = concat(',"Ending Date: ",',format(end_date_qual,"MM/DD/YYYY;;D")), col 1,
   outstring, row + 1
   IF (( $DET_LEVEL=2))
    col 1, ',"Care Set","Order","Careset Count","Order Count","Percentage"'
   ELSEIF (( $DET_LEVEL=3))
    col 1, ',"Care Set ","Count",'
   ENDIF
   row + 1
  HEAD cs_catalog_cd
   IF (( $DET_LEVEL=3))
    outstring = build(',"',cs_util->list[d.seq].cs_primary_mnemonic,'",',cs_util->list[d.seq].
     cs_ordered,","), col 1, outstring,
    row + 1
   ENDIF
  DETAIL
   IF (bocu_cnt > 0
    AND ( $DET_LEVEL=2))
    percentage = ((cs_util->list[d.seq].cs_ordered * 100.00)/ (cs_util->list[d.seq].ord_ordered *
    1.00)), outstring = build(',"',cs_util->list[d.seq].cs_primary_mnemonic,'","',cs_util->list[d.seq
     ].ord_mnemonic,'",',
     cs_util->list[d.seq].ord_ordered,",",cs_util->list[d.seq].cs_ordered,",",format(percentage,
      "###.##%")), col 1,
    outstring, row + 1
   ENDIF
  FOOT  cs_catalog_cd
   IF (bocu_cnt > 0)
    row + 1
   ENDIF
   row + 0
  WITH nocounter, maxrow = 1, format = variable,
   maxcol = 200
 ;end select
#emailcheck
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"MMDDYYYY;;D"),".csv")
  SET dclcom = concat('sed "s/$/`echo \\\r`/" ',filename_in)
  CALL echo(dclcom)
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  CALL emailfile(filename_in,filename_out, $1,concat(trim(curprog),
    " - Baystate Medical Center Careset Utilization"),1)
 ENDIF
#endprogram
END GO
