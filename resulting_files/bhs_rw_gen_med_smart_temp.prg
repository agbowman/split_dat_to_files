CREATE PROGRAM bhs_rw_gen_med_smart_temp
 RECORD pt_info(
   1 person_id = f8
   1 encntr_id = f8
 )
 IF (reflect(parameter(1,0)) > " ")
  SET pt_info->encntr_id = cnvtreal( $1)
 ELSEIF (validate(request->visit[1].encntr_id,0.00) > 0.00)
  SET pt_info->encntr_id = request->visit[1].encntr_id
 ELSE
  CALL echo("No ENCNTR_ID given. Exitting Script")
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  e.person_id
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=pt_info->encntr_id))
  DETAIL
   pt_info->person_id = e.person_id
  WITH nocounter
 ;end select
 CALL echorecord(pt_info)
 RECORD work(
   1 p_cnt = i4
   1 problems[*]
     2 description = vc
   1 a_cnt = i4
   1 allergies[*]
     2 substance = vc
   1 d_cnt = i4
   1 diagnoses[*]
     2 description = vc
 )
 DECLARE cs12030_active_problem_cd = f8 WITH constant(uar_get_code_by("MEANING",12030,"ACTIVE"))
 DECLARE cs12025_active_reaction_cd = f8 WITH constant(uar_get_code_by("MEANING",12025,"ACTIVE"))
 SELECT INTO "NL:"
  p.problem_ftdesc, n.source_string
  FROM problem p,
   nomenclature n
  PLAN (p
   WHERE (p.person_id=pt_info->person_id)
    AND p.life_cycle_status_cd=cs12030_active_problem_cd
    AND p.active_ind=1)
   JOIN (n
   WHERE outerjoin(p.nomenclature_id)=n.nomenclature_id)
  DETAIL
   work->p_cnt = (work->p_cnt+ 1), stat = alterlist(work->problems,work->p_cnt)
   IF (n.nomenclature_id > 0.00)
    work->problems[work->p_cnt].description = n.source_string
   ELSE
    work->problems[work->p_cnt].description = p.problem_ftdesc
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  a.substance_ftdesc, n.source_string
  FROM allergy a,
   nomenclature n
  PLAN (a
   WHERE (a.person_id=pt_info->person_id)
    AND a.reaction_status_cd=cs12025_active_reaction_cd
    AND a.active_ind=1)
   JOIN (n
   WHERE outerjoin(a.substance_nom_id)=n.nomenclature_id)
  DETAIL
   work->a_cnt = (work->a_cnt+ 1), stat = alterlist(work->allergies,work->a_cnt)
   IF (n.nomenclature_id > 0.00)
    work->allergies[work->a_cnt].substance = n.source_string
   ELSE
    work->allergies[work->a_cnt].substance = a.substance_ftdesc
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  d.diagnosis_display
  FROM diagnosis d
  PLAN (d
   WHERE (d.encntr_id=pt_info->encntr_id)
    AND d.active_ind=1)
  DETAIL
   work->d_cnt = (work->d_cnt+ 1), stat = alterlist(work->diagnoses,work->d_cnt), work->diagnoses[
   work->d_cnt].description = d.diagnosis_display
  WITH nocounter
 ;end select
 IF (validate(reply->text,"A")="A"
  AND validate(reply->text,"Z")="Z")
  RECORD reply(
    1 text = vc
  )
 ENDIF
 DECLARE print_out(header_text=vc,level=i2,required=i2,space_ind=i4) = null
 DECLARE beg_doc = vc WITH constant(
  "{\rtf1\ansi\deff0{\fonttbl{\f0\fswiss Tahoma;}{\f1\fmodern Courier New;}}\fs16")
 DECLARE end_doc = c1 WITH constant("}")
 DECLARE beg_lock = c44 WITH constant("{\*\txfieldstart\txfieldtype0\txfieldflags3}")
 DECLARE end_lock = c15 WITH constant("{\*\txfieldend}")
 DECLARE beg_bold = c2 WITH constant("\b")
 DECLARE end_bold = c3 WITH constant("\b0")
 DECLARE beg_ital = c2 WITH constant("\i")
 DECLARE end_ital = c3 WITH constant("\i0")
 DECLARE beg_uline = c3 WITH constant("\ul")
 DECLARE end_uline = c4 WITH constant("\ul0")
 DECLARE newline = c6 WITH constant(concat("\par",char(10),char(13)))
 DECLARE blank_return = c2 WITH constant(concat(char(10),char(13)))
 DECLARE end_para = c5 WITH constant("\pard")
 DECLARE indent0 = c4 WITH constant("\li0")
 DECLARE indent1 = c6 WITH constant("\li288")
 DECLARE indent2 = c6 WITH constant("\li576")
 DECLARE indent3 = c6 WITH constant("\li864")
 DECLARE results_indent = c10 WITH constant("\tx2592\tx5184")
 SUBROUTINE print_out(header_text,level,required,space_ind)
  IF ((level=- (1)))
   SET reply->text = build2(reply->text,blank_return,header_text)
  ELSEIF (level=0)
   IF (required=1)
    SET reply->text = build2(reply->text,beg_lock,newline,header_text,end_lock)
   ELSE
    SET reply->text = build2(reply->text,newline,header_text)
   ENDIF
  ELSEIF (level=1)
   SET reply->text = build2(reply->text,end_para)
   IF (required=1)
    SET reply->text = build2(reply->text,beg_lock,newline,"\fs18",beg_bold,
     " ",header_text,end_bold,"\fs16",end_lock)
   ELSE
    SET reply->text = build2(reply->text,newline,beg_bold," ",header_text,
     end_bold)
   ENDIF
  ELSEIF (level=2)
   IF (required=1)
    SET reply->text = build2(reply->text,beg_lock,newline,indent1,beg_bold,
     " ",header_text,end_bold,end_lock)
   ELSE
    SET reply->text = build2(reply->text,newline,indent1,beg_bold," ",
     header_text,end_bold)
   ENDIF
  ELSEIF (level=3)
   IF (required=1)
    SET reply->text = build2(reply->text,beg_lock,newline,indent2," ",
     header_text,end_lock)
   ELSE
    SET reply->text = build2(reply->text,newline,indent2," ",header_text)
   ENDIF
  ELSEIF (level=4)
   IF (required=1)
    SET reply->text = build2(reply->text,beg_lock,newline,indent3," ",
     header_text,end_lock)
   ELSE
    SET reply->text = build2(reply->text,newline,indent3," ",header_text)
   ENDIF
  ENDIF
  FOR (x = 1 TO space_ind)
    SET reply->text = build2(reply->text,newline)
  ENDFOR
 END ;Subroutine
 SET reply->text = beg_doc
 CALL print_out("Chief Complaint",1,1,2)
 CALL print_out("HPI",1,1,2)
 CALL print_out("Past Medical History",1,1,0)
 CALL print_out("Problem List",2,0,0)
 IF ((work->p_cnt <= 0))
  CALL print_out("No Problems Recorded",3,0,2)
 ELSE
  FOR (p = 1 TO work->p_cnt)
    CALL print_out(work->problems[p].description,3,0,0)
  ENDFOR
  CALL print_out(null,0,0,1)
 ENDIF
 CALL print_out("Medications",2,0,0)
 EXECUTE bhs_st_rw_get_meds value(pt_info->person_id), 0.00
 IF ((med_info->r_cnt <= 0))
  CALL print_out("No Prescriptions Recorded",3,0,2)
 ELSE
  FOR (r = 1 TO med_info->r_cnt)
   CALL print_out(med_info->rx[r].ordered_as_mnemonic,3,0,0)
   IF (trim(med_info->rx[r].sig,3) > " ")
    CALL print_out(med_info->rx[r].sig,4,0,0)
   ENDIF
  ENDFOR
  CALL print_out(null,0,0,1)
 ENDIF
 CALL print_out("Allergies",2,0,0)
 IF ((work->a_cnt <= 0))
  CALL print_out("No Allergies Recorded",3,0,2)
 ELSE
  FOR (a = 1 TO work->a_cnt)
    CALL print_out(work->allergies[a].substance,3,0,0)
  ENDFOR
  CALL print_out(null,0,0,1)
 ENDIF
 CALL print_out("Family History",1,1,2)
 CALL print_out("Social History",1,1,2)
 CALL print_out("Review of Systems",1,1,2)
 CALL print_out("Physical Exam",1,1,0)
 CALL print_out("Vital Signs",2,0,0)
 EXECUTE bhs_st_rw_get_ce_results 0.00, value(pt_info->encntr_id), "VITALS",
 90, 0
 CALL print_out("\f1\fs18\tx2592\tx5850",0,0,0)
 IF ((result_info->d_cnt <= 0))
  CALL print_out("No Vital Results found for Last 90 Days",3,0,0)
 ELSE
  DECLARE tmp_str = vc
  FOR (d = 1 TO result_info->d_cnt)
    FOR (r = 1 TO result_info->dates[d].r_cnt)
      SET tmp_str = build2(result_info->dates[d].date_time)
      SET tmp_str = build2(tmp_str,"\tab ",substring(1,30,result_info->dates[d].results[r].display))
      SET tmp_str = build2(tmp_str,"\tab ",substring(1,20,result_info->dates[d].results[r].value))
      CALL print_out(tmp_str,3,0,0)
    ENDFOR
  ENDFOR
  FREE SET tmp_str
 ENDIF
 CALL print_out("\pard\f0\fs16",0,0,0)
 CALL print_out("General",2,0,1)
 CALL print_out("HEENT",2,0,1)
 CALL print_out("Chest/Breast/Axilla",2,0,1)
 CALL print_out("Cardiovascular",2,0,1)
 CALL print_out("Respiratory",2,0,1)
 CALL print_out("Abdomen/GI",2,0,1)
 CALL print_out("GU/Rectal",2,0,1)
 CALL print_out("Back",2,0,1)
 CALL print_out("Extremities",2,0,1)
 CALL print_out("Lymph Nodes",2,0,1)
 CALL print_out("Derm",2,0,1)
 CALL print_out("Neurologic",2,0,1)
 CALL print_out("Psychiatric",2,0,1)
 CALL print_out("Results Review",1,1,0)
 CALL print_out("Today's Results",2,0,0)
 EXECUTE bhs_st_rw_get_ce_results 0.00, value(pt_info->encntr_id), "PHYSICIANOFFICEFLOWSHEET",
 0, 0
 CALL print_out("\f1\fs18\tx2592\tx5850",0,0,0)
 IF ((result_info->d_cnt <= 0))
  CALL print_out("No Results found for Today",3,0,0)
 ELSE
  DECLARE tmp_str = vc
  FOR (d = 1 TO result_info->d_cnt)
    FOR (r = 1 TO result_info->dates[d].r_cnt)
      SET tmp_str = build2(result_info->dates[d].date_time)
      SET tmp_str = build2(tmp_str,"\tab ",substring(1,30,result_info->dates[d].results[r].display))
      SET tmp_str = build2(tmp_str,"\tab ",substring(1,20,result_info->dates[d].results[r].value))
      CALL print_out(tmp_str,3,0,0)
    ENDFOR
  ENDFOR
  FREE SET tmp_str
 ENDIF
 CALL print_out("\pard\f0\fs16",0,0,0)
 CALL print_out("Other Results",2,0,1)
 CALL print_out("Impression and Plan",1,1,0)
 CALL print_out("Diagnoses",2,0,0)
 IF ((work->d_cnt <= 0))
  CALL print_out("No Diagnoses Recorded",3,0,3)
 ELSE
  FOR (d = 1 TO work->d_cnt)
    CALL print_out(work->diagnoses[d].description,3,0,2)
  ENDFOR
  CALL print_out(end_para,0,0,2)
 ENDIF
 CALL print_out("Follow Up",1,1,2)
 SET reply->text = build2(reply->text,end_doc)
 SELECT INTO "RYAN_SMART_TEMP.DAT"
  FROM dummyt d
  DETAIL
   col 0, reply->text
  WITH maxcol = 32000, maxrow = 1, formfeed = none,
   format = variable
 ;end select
END GO
