CREATE PROGRAM bhs_prax_procedure_hx
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
     2 comments[*]
       3 comment_dt_tm = vc
       3 comment_added_by = vc
       3 comment_description = vc
 )
 DECLARE vcnt = i4
 DECLARE ccnt = i4
 DECLARE json = vc WITH protect, noconstant("")
 DECLARE moutputdevice = vc WITH protect, constant(request->output_device)
 DECLARE mpersonid = f8 WITH protect, constant(request->person[1].person_id)
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
  n_source_vocabulary_disp = uar_get_code_display(n.source_vocabulary_cd)
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
    AND p.proc_type_flag=2.00)
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id)
   JOIN (pp
   WHERE pp.procedure_id=outerjoin(p.procedure_id))
   JOIN (pr
   WHERE pr.person_id=outerjoin(pp.prsnl_person_id))
   JOIN (l
   WHERE l.parent_entity_id=outerjoin(p.procedure_id)
    AND l.parent_entity_name=outerjoin("PROCEDURE"))
   JOIN (pr1
   WHERE pr1.person_id=outerjoin(l.active_status_prsnl_id))
  ORDER BY p.procedure_id
  HEAD REPORT
   vcnt = 0
  HEAD p.procedure_id
   vcnt = (vcnt+ 1), stat = alterlist(problem_procedure_hx->procedure_hx,vcnt), problem_procedure_hx
   ->procedure_hx[vcnt].location = p_proc_loc_disp,
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
   ccnt = 0
  DETAIL
   IF (l.long_text_id != 0)
    ccnt = (ccnt+ 1), stat = alterlist(problem_procedure_hx->procedure_hx[vcnt].comments,ccnt),
    problem_procedure_hx->procedure_hx[vcnt].comments[ccnt].comment_added_by = comment_added_by,
    problem_procedure_hx->procedure_hx[vcnt].comments[ccnt].comment_description = comment,
    problem_procedure_hx->procedure_hx[vcnt].comments[ccnt].comment_dt_tm = comment_dt_tm
   ENDIF
  WITH nocounter, separator = " ", format,
   time = 30
 ;end select
 SET json = cnvtrectojson(problem_procedure_hx)
 CALL echo(json)
 SELECT INTO value(moutputdevice)
  json
  FROM dummyt d
  WITH format, separator = " "
 ;end select
 FREE RECORD problem_procedure_hx
END GO
