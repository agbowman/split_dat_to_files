CREATE PROGRAM bed_get_serv_res_hier:dba
 SET modify = predeclare
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 institutions[*]
      2 service_resource_cd = f8
      2 service_resource_disp = vc
      2 service_resource_mean = c12
      2 departments[*]
        3 service_resource_cd = f8
        3 service_resource_disp = vc
        3 service_resource_mean = c12
        3 sections[*]
          4 service_resource_cd = f8
          4 service_resource_disp = vc
          4 service_resource_mean = c12
          4 subsections[*]
            5 service_resource_cd = f8
            5 service_resource_disp = vc
            5 service_resource_mean = c12
            5 instr_benchs[*]
              6 service_resource_cd = f8
              6 service_resource_disp = vc
              6 service_resource_mean = c12
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp(
   1 service_resources[*]
     2 service_resource_cd = f8
     2 service_resource_type_cd = f8
 ) WITH protect
 DECLARE error_check = i4 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE cur_size = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE expand_idx = i4 WITH protect, noconstant(0)
 DECLARE new_size = i4 WITH protect, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(0)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE instrument = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"INSTRUMENT"))
 DECLARE bench = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"BENCH"))
 DECLARE general_lab = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"GENERAL LAB"))
 DECLARE subsection = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"SUBSECTION"))
 DECLARE section = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"SECTION"))
 DECLARE department = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"DEPARTMENT"))
 DECLARE institution = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"INSTITUTION"))
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM service_resource sr
  PLAN (sr
   WHERE ((sr.service_resource_type_cd=instrument) OR (sr.service_resource_type_cd=bench))
    AND sr.discipline_type_cd=general_lab
    AND (sr.activity_type_cd=request->activity_type_cd)
    AND sr.active_ind=1
    AND sr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND sr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(temp->service_resources,(cnt+ 9))
   ENDIF
   temp->service_resources[cnt].service_resource_cd = sr.service_resource_cd, temp->
   service_resources[cnt].service_resource_type_cd = sr.service_resource_type_cd
  FOOT REPORT
   stat = alterlist(temp->service_resources,cnt)
  WITH nocounter
 ;end select
 IF (size(temp->service_resources,5)=0)
  GO TO exit_script
 ENDIF
 SET cur_size = size(temp->service_resources,5)
 IF (cur_size < 100)
  SET batch_size = cur_size
 ELSE
  SET batch_size = 100
 ENDIF
 SET loop_cnt = ceil((cnvtreal(cur_size)/ batch_size))
 SET new_size = (loop_cnt * batch_size)
 SET start = 1
 SET stat = alterlist(temp->service_resources,new_size)
 FOR (idx = (cur_size+ 1) TO new_size)
  SET temp->service_resources[idx].service_resource_cd = temp->service_resources[cur_size].
  service_resource_cd
  SET temp->service_resources[idx].service_resource_type_cd = temp->service_resources[cur_size].
  service_resource_type_cd
 ENDFOR
 SELECT INTO "nl:"
  institution_disp = cnvtupper(uar_get_code_display(rg_dept.parent_service_resource_cd)),
  department_disp = cnvtupper(uar_get_code_display(rg_dept.child_service_resource_cd)), section_disp
   = cnvtupper(uar_get_code_display(rg_sect.child_service_resource_cd)),
  subsection_disp = cnvtupper(uar_get_code_display(rg_subsect.child_service_resource_cd)),
  instr_bench_disp = cnvtupper(uar_get_code_display(rg_sr.child_service_resource_cd))
  FROM (dummyt d  WITH seq = value(loop_cnt)),
   resource_group rg_sr,
   service_resource sr_subsect,
   resource_group rg_subsect,
   service_resource sr_sect,
   resource_group rg_sect,
   resource_group rg_dept
  PLAN (d
   WHERE initarray(start,evaluate(d.seq,1,1,(start+ batch_size))))
   JOIN (rg_sr
   WHERE expand(expand_idx,start,((start+ batch_size) - 1),rg_sr.child_service_resource_cd,temp->
    service_resources[expand_idx].service_resource_cd)
    AND ((rg_sr.root_service_resource_cd+ 0)=0.0)
    AND rg_sr.active_ind=1
    AND rg_sr.resource_group_type_cd=subsection)
   JOIN (sr_subsect
   WHERE sr_subsect.service_resource_cd=rg_sr.parent_service_resource_cd
    AND sr_subsect.discipline_type_cd=general_lab
    AND (sr_subsect.activity_type_cd=request->activity_type_cd))
   JOIN (rg_subsect
   WHERE rg_subsect.child_service_resource_cd=sr_subsect.service_resource_cd
    AND ((rg_subsect.root_service_resource_cd+ 0)=0.0)
    AND rg_subsect.active_ind=1
    AND rg_subsect.resource_group_type_cd=section)
   JOIN (sr_sect
   WHERE sr_sect.service_resource_cd=rg_subsect.parent_service_resource_cd
    AND sr_sect.discipline_type_cd=general_lab
    AND (sr_sect.activity_type_cd=request->activity_type_cd))
   JOIN (rg_sect
   WHERE rg_sect.child_service_resource_cd=sr_sect.service_resource_cd
    AND ((rg_sect.root_service_resource_cd+ 0)=0.0)
    AND rg_sect.active_ind=1
    AND rg_sect.resource_group_type_cd=department)
   JOIN (rg_dept
   WHERE rg_dept.child_service_resource_cd=rg_sect.parent_service_resource_cd
    AND ((rg_dept.root_service_resource_cd+ 0)=0.0)
    AND rg_dept.active_ind=1
    AND rg_dept.resource_group_type_cd=institution)
  ORDER BY institution_disp, department_disp, section_disp,
   subsection_disp, instr_bench_disp
  HEAD PAGE
   cnt = 0
  HEAD institution_disp
   cnt1 = 0, cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->institutions,(cnt+ 9))
   ENDIF
   reply->institutions[cnt].service_resource_cd = rg_dept.parent_service_resource_cd
  HEAD department_disp
   cnt2 = 0, cnt1 = (cnt1+ 1)
   IF (mod(cnt1,10)=1)
    stat = alterlist(reply->institutions[cnt].departments,(cnt1+ 9))
   ENDIF
   reply->institutions[cnt].departments[cnt1].service_resource_cd = rg_dept.child_service_resource_cd
  HEAD section_disp
   cnt3 = 0, cnt2 = (cnt2+ 1)
   IF (mod(cnt2,10)=1)
    stat = alterlist(reply->institutions[cnt].departments[cnt1].sections,(cnt2+ 9))
   ENDIF
   reply->institutions[cnt].departments[cnt1].sections[cnt2].service_resource_cd = rg_sect
   .child_service_resource_cd
  HEAD subsection_disp
   cnt4 = 0, cnt3 = (cnt3+ 1)
   IF (mod(cnt3,10)=1)
    stat = alterlist(reply->institutions[cnt].departments[cnt1].sections[cnt2].subsections,(cnt3+ 9))
   ENDIF
   reply->institutions[cnt].departments[cnt1].sections[cnt2].subsections[cnt3].service_resource_cd =
   rg_subsect.child_service_resource_cd
  HEAD instr_bench_disp
   cnt4 = (cnt4+ 1)
   IF (mod(cnt4,10)=1)
    stat = alterlist(reply->institutions[cnt].departments[cnt1].sections[cnt2].subsections[cnt3].
     instr_benchs,(cnt4+ 9))
   ENDIF
   reply->institutions[cnt].departments[cnt1].sections[cnt2].subsections[cnt3].instr_benchs[cnt4].
   service_resource_cd = rg_sr.child_service_resource_cd
  DETAIL
   row + 0
  FOOT  instr_bench_disp
   row + 0
  FOOT  subsection_disp
   stat = alterlist(reply->institutions[cnt].departments[cnt1].sections[cnt2].subsections[cnt3].
    instr_benchs,cnt4)
  FOOT  section_disp
   stat = alterlist(reply->institutions[cnt].departments[cnt1].sections[cnt2].subsections,cnt3)
  FOOT  department_disp
   stat = alterlist(reply->institutions[cnt].departments[cnt1].sections,cnt2)
  FOOT  institution_disp
   stat = alterlist(reply->institutions[cnt].departments,cnt1)
  FOOT REPORT
   stat = alterlist(reply->institutions,cnt)
  WITH nocounter
 ;end select
#exit_script
 SET error_check = error(error_msg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
 ELSEIF (size(reply->institutions,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET modify = nopredeclare
END GO
