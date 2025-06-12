CREATE PROGRAM bhs_athn_procedure_hx
 DECLARE procedure_type_narrative = f8 WITH constant(2.0)
 FREE RECORD problem_procedure_hx
 RECORD problem_procedure_hx(
   1 person_id = f8
   1 procedure_hx[*]
     2 procedure_id = f8
     2 procedure_name = vc
     2 procedure_status = vc
     2 display_as = vc
     2 procedure_dt_tm = vc
     2 provider = vc
     2 location = vc
     2 cpt_code = vc
     2 vocabulary = vc
     2 beg_dt_tm = vc
     2 proc_dt_tm_prec_flag = vc
     2 proc_dt_tm_prec_disp = vc
     2 comments[*]
       3 comment_dt_tm = vc
       3 comment_added_by = vc
       3 comment_description = vc
 )
 DECLARE vcnt = i4
 DECLARE ccnt = i4
 DECLARE json = vc WITH protect, noconstant("")
 DECLARE mpersonid = f8 WITH protect, constant( $2)
 SET problem_procedure_hx->person_id = mpersonid
 SELECT INTO "nl:"
  p.procedure_id, proc_name =
  IF (n.source_string=" ") p.proc_ftdesc
  ELSE n.source_string
  ENDIF
  , p.procedure_note,
  proc_dt_tm = format(p.proc_dt_tm,"MM/DD/YYYY"), beg_dt_tm = format(p.beg_effective_dt_tm,
   "MM/DD/YYYY HH:MM"), p_proc_loc_disp = trim(replace(replace(replace(replace(replace(
        IF (p.proc_loc_cd != 0) uar_get_code_display(p.proc_loc_cd)
        ELSE p.proc_ft_loc
        ENDIF
        ,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  provider = trim(replace(replace(replace(replace(replace(
        IF (pp.prsnl_person_id != 0) pr.name_full_formatted
        ELSE pp.proc_ft_prsnl
        ENDIF
        ,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), comment =
  trim(replace(replace(replace(replace(replace(l.long_text,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
     "'","&apos;",0),'"',"&quot;",0),3), comment_added_by = pr1.name_full_formatted,
  comment_dt_tm = format(l.active_status_dt_tm,"MM/DD/YYYY HH:MM"), n.source_identifier,
  n_source_vocabulary_disp = uar_get_code_display(n.source_vocabulary_cd),
  p_proc_dt_tm_prec_flag =
  IF (p.proc_dt_tm_prec_flag=0) "Date and Time"
  ELSEIF (p.proc_dt_tm_prec_flag=1) "Week"
  ELSEIF (p.proc_dt_tm_prec_flag=2) "Month"
  ELSEIF (p.proc_dt_tm_prec_flag=3) "Year"
  ELSEIF (p.proc_dt_tm_prec_flag=4) ""
  ELSE ""
  ENDIF
  , p_proc_dt_tm_prec_disp = uar_get_code_display(p.proc_dt_tm_prec_cd)
  FROM encounter e,
   procedure p,
   nomenclature n,
   proc_prsnl_reltn pp,
   prsnl pr,
   long_text l,
   prsnl pr1
  PLAN (e
   WHERE e.person_id=mpersonid
    AND e.active_ind=1)
   JOIN (p
   WHERE p.encntr_id=e.encntr_id
    AND p.proc_type_flag=procedure_type_narrative)
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id)
   JOIN (pp
   WHERE (pp.procedure_id= Outerjoin(p.procedure_id))
    AND (pp.active_ind= Outerjoin(1)) )
   JOIN (pr
   WHERE (pr.person_id= Outerjoin(pp.prsnl_person_id)) )
   JOIN (l
   WHERE (l.parent_entity_id= Outerjoin(p.procedure_id))
    AND (l.parent_entity_name= Outerjoin("PROCEDURE")) )
   JOIN (pr1
   WHERE (pr1.person_id= Outerjoin(l.active_status_prsnl_id)) )
  ORDER BY p.procedure_id
  HEAD REPORT
   vcnt = 0
  HEAD p.procedure_id
   vcnt += 1, stat = alterlist(problem_procedure_hx->procedure_hx,vcnt), problem_procedure_hx->
   procedure_hx[vcnt].location = p_proc_loc_disp,
   problem_procedure_hx->procedure_hx[vcnt].provider = provider, problem_procedure_hx->procedure_hx[
   vcnt].procedure_dt_tm = proc_dt_tm, problem_procedure_hx->procedure_hx[vcnt].display_as = p
   .procedure_note,
   problem_procedure_hx->procedure_hx[vcnt].procedure_name = proc_name, problem_procedure_hx->
   procedure_hx[vcnt].procedure_id = p.procedure_id, problem_procedure_hx->procedure_hx[vcnt].
   cpt_code = n.source_identifier,
   problem_procedure_hx->procedure_hx[vcnt].vocabulary = n_source_vocabulary_disp,
   problem_procedure_hx->procedure_hx[vcnt].beg_dt_tm = beg_dt_tm
   IF (p.active_ind=1)
    problem_procedure_hx->procedure_hx[vcnt].procedure_status = "Active"
   ELSE
    problem_procedure_hx->procedure_hx[vcnt].procedure_status = "Inactive"
   ENDIF
   problem_procedure_hx->procedure_hx[vcnt].proc_dt_tm_prec_flag = p_proc_dt_tm_prec_flag,
   problem_procedure_hx->procedure_hx[vcnt].proc_dt_tm_prec_disp = p_proc_dt_tm_prec_disp, ccnt = 0
  DETAIL
   IF (l.long_text_id != 0)
    ccnt += 1, stat = alterlist(problem_procedure_hx->procedure_hx[vcnt].comments,ccnt),
    problem_procedure_hx->procedure_hx[vcnt].comments[ccnt].comment_added_by = comment_added_by,
    problem_procedure_hx->procedure_hx[vcnt].comments[ccnt].comment_description = comment,
    problem_procedure_hx->procedure_hx[vcnt].comments[ccnt].comment_dt_tm = comment_dt_tm
   ENDIF
  WITH nocounter, separator = " ", format,
   time = 30
 ;end select
 CALL echojson(problem_procedure_hx, $1)
 FREE RECORD problem_procedure_hx
END GO
