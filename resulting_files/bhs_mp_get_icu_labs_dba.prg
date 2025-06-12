CREATE PROGRAM bhs_mp_get_icu_labs:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person Id:" = 0,
  "Encounter Id:" = 0
  WITH outdev, personid, encntrid
 FREE RECORD m_rec
 RECORD m_rec(
   1 list[*]
     2 s_list_name = vc
     2 labs[*]
       3 s_lab_name = vc
       3 l_sort = i4
       3 l_grouper = i4
       3 res[*]
         4 s_lab_result = vc
         4 s_lab_date = vc
         4 s_shortlab_date = vc
         4 s_lab_uom = vc
         4 s_lab_normalcy = vc
         4 s_lab_normalcy_color = vc
 ) WITH public
 RECORD putrequest(
   1 source_dir = vc
   1 source_filename = vc
   1 nbrlines = i4
   1 line[*]
     2 linedata = vc
   1 overflowpage[*]
     2 ofr_qual[*]
       3 ofr_line = vc
   1 isblob = c1
   1 document_size = i4
   1 document = gvc
 )
 DECLARE mf_inerror_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE mf_grp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"GRP"))
 DECLARE mf_person_id = f8 WITH protect, constant( $PERSONID)
 DECLARE mf_encntr_id = f8 WITH protect, constant( $ENCNTRID)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_json = vc WITH protect, noconstant(" ")
 DECLARE ms_admit_dt_tm = vc WITH protect, noconstant(" ")
 CALL echo(mf_person_id)
 CALL echo(mf_encntr_id)
 CALL echo("get admit_dt_tm")
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=mf_encntr_id
    AND e.active_ind=1)
  HEAD e.encntr_id
   ms_admit_dt_tm = trim(format(e.reg_dt_tm,"dd-mmm-yyyy hh:mm;;d"))
  WITH nocounter
 ;end select
 CALL echo("get lab results")
 SELECT INTO "nl:"
  ps_event_end_dt_tm = trim(format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;dq"),3),
  ps_short_event_end_dt_tm = trim(format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;dq"),3), ps_display =
  trim(uar_get_code_display(ce.event_cd)),
  ps_result = trim(ce.result_val,3), ps_normalcy_disp = trim(uar_get_code_display(ce.normalcy_cd),3),
  ps_result_units = trim(uar_get_code_display(ce.result_units_cd),3),
  pl_sort =
  IF (trim(uar_get_code_display(ce.normalcy_cd),3) IN ("CRIT", "C")) 1
  ELSEIF (trim(uar_get_code_display(ce.normalcy_cd),3) IN (">HHI", "HHI", "HH", "H")) 2
  ELSEIF (trim(uar_get_code_display(ce.normalcy_cd),3) IN ("<LLOW", "LLOW", "LL", "LOW", "L")) 3
  ELSE 4
  ENDIF
  FROM bhs_event_cd_list b,
   clinical_event ce
  PLAN (b
   WHERE b.active_ind=1
    AND b.listkey IN ("MP ICU - CHEM LABS", "MP ICU - HEMO LABS", "MP ICU - RESP LABS",
   "MP ICU - GI LABS"))
   JOIN (ce
   WHERE ce.person_id=mf_person_id
    AND ce.event_cd=b.event_cd
    AND ce.valid_until_dt_tm > sysdate
    AND ce.event_end_dt_tm BETWEEN cnvtlookbehind("72,H",sysdate) AND sysdate
    AND ce.result_status_cd != mf_inerror_cd
    AND ce.event_class_cd != mf_grp_cd)
  ORDER BY b.listkey, ce.event_cd, ce.event_end_dt_tm
  HEAD REPORT
   pl_list_cnt = 0, pl_lab_cnt = 0, pl_res_cnt = 0
  HEAD b.listkey
   pl_list_cnt = (pl_list_cnt+ 1), stat = alterlist(m_rec->list,pl_list_cnt), m_rec->list[pl_list_cnt
   ].s_list_name = trim(b.listkey),
   pl_lab_cnt = 0
  HEAD ce.event_cd
   pl_lab_cnt = (pl_lab_cnt+ 1), stat = alterlist(m_rec->list[pl_list_cnt].labs,pl_lab_cnt), m_rec->
   list[pl_list_cnt].labs[pl_lab_cnt].s_lab_name = trim(ps_display),
   m_rec->list[pl_list_cnt].labs[pl_lab_cnt].l_grouper = b.grouper_id, m_rec->list[pl_list_cnt].labs[
   pl_lab_cnt].l_sort = pl_sort, pl_res_cnt = 0
  DETAIL
   CALL echo(concat(ps_display," ",trim(cnvtstring(pl_sort))," ",trim(format(ce.event_end_dt_tm,
      "mm/dd/yy hh:mm;;d")),
    " ",trim(cnvtstring(b.grouper_id)))), m_rec->list[pl_list_cnt].labs[pl_lab_cnt].l_sort = pl_sort,
   pl_res_cnt = (pl_res_cnt+ 1),
   stat = alterlist(m_rec->list[pl_list_cnt].labs[pl_lab_cnt].res,pl_res_cnt), m_rec->list[
   pl_list_cnt].labs[pl_lab_cnt].res[pl_res_cnt].s_lab_result = trim(replace(trim(ps_result),"<"," ",
     0))
   IF (ps_event_end_dt_tm > "")
    m_rec->list[pl_list_cnt].labs[pl_lab_cnt].res[pl_res_cnt].s_lab_date = trim(ps_event_end_dt_tm),
    m_rec->list[pl_list_cnt].labs[pl_lab_cnt].res[pl_res_cnt].s_shortlab_date = trim(
     ps_short_event_end_dt_tm)
   ELSE
    m_rec->list[pl_list_cnt].labs[pl_lab_cnt].res[pl_res_cnt].s_lab_date = "DND", m_rec->list[
    pl_list_cnt].labs[pl_lab_cnt].res[pl_res_cnt].s_shortlab_date = "DND"
   ENDIF
   IF (ps_result_units > " ")
    m_rec->list[pl_list_cnt].labs[pl_lab_cnt].res[pl_res_cnt].s_lab_uom = trim(ps_result_units)
   ELSE
    m_rec->list[pl_list_cnt].labs[pl_lab_cnt].res[pl_res_cnt].s_lab_uom = "DND"
   ENDIF
   CALL echo(concat("normalcy: ",uar_get_code_display(ce.normalcy_cd))),
   CALL echo(concat("ps_normalcy: ",ps_normalcy_disp))
   IF (ps_normalcy_disp IN ("CRIT", "C", ">HHI", "HHI", "HH",
   "H", "<LLOW", "LLOW", "LL", "LOW",
   "L"))
    m_rec->list[pl_list_cnt].labs[pl_lab_cnt].res[pl_res_cnt].s_lab_normalcy = "critical", m_rec->
    list[pl_list_cnt].labs[pl_lab_cnt].res[pl_res_cnt].s_lab_normalcy_color = "red"
   ELSE
    m_rec->list[pl_list_cnt].labs[pl_lab_cnt].res[pl_res_cnt].s_lab_normalcy = "normal", m_rec->list[
    pl_list_cnt].labs[pl_lab_cnt].res[pl_res_cnt].s_lab_normalcy_color = "black"
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_json = "{}"
 ENDIF
 IF (size(m_rec->list,5) > 0)
  SELECT INTO "nl:"
   ps_list = m_rec->list[d1.seq].s_list_name, ps_lab_name = m_rec->list[d1.seq].labs[d2.seq].
   s_lab_name, pl_sort = m_rec->list[d1.seq].labs[d2.seq].l_sort,
   pl_grouper = m_rec->list[d1.seq].labs[d2.seq].l_grouper
   FROM (dummyt d1  WITH seq = value(size(m_rec->list,5))),
    dummyt d2
   PLAN (d1
    WHERE maxrec(d2,size(m_rec->list[d1.seq].labs,5)))
    JOIN (d2)
   ORDER BY ps_list, pl_grouper
   HEAD REPORT
    pl_cnt = 0, pl_key_cnt = 0, pl_cd_cnt = 0,
    pl_det_cnt = 0, ms_json = "{"
   HEAD ps_list
    IF (pl_key_cnt > 0)
     ms_json = concat(ms_json,",")
    ENDIF
    pl_key_cnt = (pl_key_cnt+ 1), pl_cd_cnt = 0, ms_json = concat(ms_json,'"',trim(m_rec->list[d1.seq
      ].s_list_name),'":[')
   HEAD ps_lab_name
    IF (pl_cd_cnt > 0)
     ms_json = concat(ms_json,",")
    ENDIF
    pl_cd_cnt = (pl_cd_cnt+ 1), pl_det_cnt = 0, ms_json = concat(ms_json,"{",'"lab_name":"',trim(
      ps_lab_name),'",',
     '"lab":[')
    FOR (pl_cnt = 0 TO size(m_rec->list[d1.seq].labs[d2.seq].res,5))
      pl_det_cnt = (pl_det_cnt+ 1)
      IF (pl_det_cnt > 1)
       ms_json = concat(ms_json,",")
      ENDIF
      ms_json = concat(ms_json,"{",'"lab_result":"',trim(replace(trim(m_rec->list[d1.seq].labs[d2.seq
          ].res[pl_cnt].s_lab_result),"<"," ",0)),'",')
      IF (trim(m_rec->list[d1.seq].labs[d2.seq].res[pl_cnt].s_lab_date) > "")
       ms_json = concat(ms_json,'"lab_date":"',trim(m_rec->list[d1.seq].labs[d2.seq].res[pl_cnt].
         s_lab_date),'",'), ms_json = concat(ms_json,'"shortlab_date":"',trim(m_rec->list[d1.seq].
         labs[d2.seq].res[pl_cnt].s_shortlab_date),'",')
      ELSE
       ms_json = concat(ms_json,'"lab_date":"DND",'), ms_json = concat(ms_json,
        '"shortlab_date":"DND",')
      ENDIF
      IF (trim(m_rec->list[d1.seq].labs[d2.seq].res[pl_cnt].s_lab_uom) > " ")
       ms_json = concat(ms_json,'"lab_uom":"',trim(m_rec->list[d1.seq].labs[d2.seq].res[pl_cnt].
         s_lab_uom),'",')
      ELSE
       ms_json = concat(ms_json,'"lab_uom":"DND",')
      ENDIF
      CALL echo(concat("normalcy2: ",m_rec->list[d1.seq].labs[d2.seq].res[pl_cnt].s_lab_normalcy))
      IF (trim(m_rec->list[d1.seq].labs[d2.seq].res[pl_cnt].s_lab_normalcy)="critical")
       ms_json = concat(ms_json,'"lab_normalcy_color":"red",'), ms_json = concat(ms_json,
        '"lab_normalcy":"critical"')
      ELSE
       ms_json = concat(ms_json,'"lab_normalcy_color":"black",'), ms_json = concat(ms_json,
        '"lab_normalcy":"normal"')
      ENDIF
      ms_json = concat(ms_json,"}")
    ENDFOR
   FOOT  ps_lab_name
    ms_json = concat(ms_json,"]}")
   FOOT  ps_list
    ms_json = concat(ms_json,"]")
   FOOT REPORT
    ms_json = concat(ms_json,"}")
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET ms_json = "{}"
  ENDIF
 ENDIF
 CALL echo(ms_json)
 SET putrequest->source_dir =  $OUTDEV
 SET putrequest->isblob = "1"
 SET putrequest->document = ms_json
 SET putrequest->document_size = size(putrequest->document)
 EXECUTE eks_put_source  WITH replace(request,putrequest), replace(reply,putreply)
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD putrequest
END GO
