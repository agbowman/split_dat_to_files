CREATE PROGRAM bhs_st_hrt_intake_output:dba
 FREE RECORD iando
 RECORD iando(
   1 cnt_intake = i4
   1 cnt_outputs = i4
   1 croutputtot = f8
   1 crintaketot = f8
   1 crbalance = f8
   1 crbalancevc = vc
   1 toutputtot = f8
   1 tintaketot = f8
   1 tbalance = f8
   1 youtputtot = f8
   1 yintaketot = f8
   1 ybalance = f8
   1 rtf = vc
   1 oral_intake[*]
     2 event = vc
     2 date = vc
     2 result = f8
     2 tresultvol = f8
     2 yresultvol = f8
     2 crresultvol = f8
     2 unit = vc
   1 urine_output[*]
     2 event = vc
     2 date = vc
     2 result = f8
     2 tresultvol = f8
     2 yresultvol = f8
     2 crresultvol = f8
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 text = gvc
    1 status_data[1]
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE mn_intake = i2 WITH constant(1), protect
 DECLARE mn_output = i2 WITH constant(2), protect
 DECLARE mf_cs93_urineoutputsection_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",93,
   "URINEOUTPUTSECTION")), protect
 DECLARE mf_cs93_oralintakesection_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",93,
   "ORALINTAKESECTION")), protect
 DECLARE mf_cs93_output_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",93,"OUTPUT")), protect
 DECLARE mf_cs93_intake_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",93,"INTAKE")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 DECLARE mf_confirmed = f8 WITH constant(uar_get_code_by("MEANING",4000160,"CONFIRMED")), protect
 DECLARE print_out(header_text=vc,level=i2,required=i2,space_ind=i4) = null
 DECLARE beg_doc = vc WITH constant(
  "{\rtf1\ansi\deff0{\fonttbl{\f0\froman times new roman;}{\f1\fmodern courier new;}}")
 DECLARE end_doc = c1 WITH constant("}")
 DECLARE beg_lock = c44 WITH constant("{\*\txfieldstart\txfieldtype0\txfieldflags3}")
 DECLARE end_lock = c15 WITH constant("{\*\txfieldend}")
 DECLARE beg_bold = c4 WITH constant(" \b ")
 DECLARE end_bold = c5 WITH constant(" \b0 ")
 DECLARE beg_ital = c2 WITH constant("\i")
 DECLARE end_ital = c3 WITH constant("\i0")
 DECLARE beg_uline = c3 WITH constant("\ul ")
 DECLARE end_uline = c4 WITH constant("\ul0 ")
 DECLARE newline = c6 WITH constant(concat("\par",char(10)))
 DECLARE blank_return = c2 WITH constant(concat(char(10),char(13)))
 DECLARE end_para = c6 WITH constant("\pard ")
 DECLARE indent0 = c4 WITH constant("\li0")
 DECLARE indent1 = c6 WITH constant("\li288")
 DECLARE indent2 = c6 WITH constant("\li576")
 DECLARE indent3 = c6 WITH constant("\li864")
 DECLARE cell_t_brdr = vc WITH public, constant("\clbrdrt \brdrw20 \brdrs")
 DECLARE cell_b_brdr = vc WITH public, constant("\clbrdrb \brdrw20 \brdrs")
 DECLARE cell_l_brdr = vc WITH public, constant("\clbrdrl \brdrw20 \brdrs")
 DECLARE cell_r_brdr = vc WITH public, constant("\clbrdrr \brdrw20 \brdrs")
 DECLARE cell_t_brdr10 = vc WITH public, constant("\clbrdrt \brdrw10 \brdrs")
 DECLARE cell_b_brdr10 = vc WITH public, constant("\clbrdrb \brdrw10 \brdrs")
 DECLARE cell_l_brdr10 = vc WITH public, constant("\clbrdrl \brdrw10 \brdrs")
 DECLARE cell_r_brdr10 = vc WITH public, constant("\clbrdrr \brdrw10 \brdrs")
 DECLARE hcell_left_brdr = vc WITH public, constant(concat(cell_t_brdr,cell_b_brdr,cell_l_brdr))
 DECLARE hcell_right_brdr = vc WITH public, constant(concat(cell_t_brdr,cell_b_brdr,cell_r_brdr))
 DECLARE cell_all_brdr1 = vc WITH public, constant(concat(cell_t_brdr10,cell_b_brdr10,cell_l_brdr10,
   cell_r_brdr10))
 DECLARE header_tables = vc WITH constant(concat("\trowd",hcell_left_brdr,"\cellx3500",
   hcell_right_brdr,"\cellx5000 "))
 DECLARE other_tables = vc WITH constant(concat("\trowd",cell_all_brdr1,"\cellx3500",cell_all_brdr1,
   "\cellx5000 "))
 DECLARE start_cell = vc WITH constant("\intbl\ql ")
 DECLARE start_cell_r = c14 WITH constant("\intbl ")
 DECLARE end_cell = vc WITH constant(" \cell ")
 SET iando->rtf = build2(iando->rtf,blank_return)
 SELECT INTO "nl:"
  eventdisplay = build(trim(uar_get_code_display(ce.event_cd),3),ce.event_cd)
  FROM clinical_event ce,
   ce_intake_output_result cio
  PLAN (ce
   WHERE ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
   mf_cs8_active_cd)
    AND ce.valid_from_dt_tm < sysdate
    AND ce.valid_until_dt_tm > sysdate
    AND (ce.person_id=request->person.person_id)
    AND (ce.encntr_id=request->visit.encntr_id)
    AND ce.view_level=1)
   JOIN (cio
   WHERE cio.encntr_id=ce.encntr_id
    AND cio.event_id=ce.event_id)
  ORDER BY ce.encntr_id, cio.io_type_flag, eventdisplay
  HEAD ce.encntr_id
   null
  HEAD ce.event_cd
   null, stat = alterlist(iando->oral_intake,10), stat = alterlist(iando->urine_output,10)
  HEAD cio.io_type_flag
   IF (cio.io_type_flag=mn_intake)
    iando->cnt_intake += 1,
    CALL echo(iando->cnt_intake)
    IF (mod(iando->cnt_intake,10)=1
     AND (iando->cnt_intake > 1))
     stat = alterlist(iando->oral_intake,(iando->cnt_intake+ 9))
    ENDIF
   ELSEIF (cio.io_type_flag=mn_output)
    iando->cnt_outputs += 1,
    CALL echo(iando->cnt_outputs)
    IF (mod(iando->cnt_outputs,10)=1
     AND (iando->cnt_outputs > 1))
     stat = alterlist(iando->urine_output,(iando->cnt_outputs+ 9))
    ENDIF
   ENDIF
  DETAIL
   IF (cio.io_type_flag=mn_intake)
    iando->oral_intake[iando->cnt_intake].event = trim(uar_get_code_display(ce.event_cd),3), iando->
    oral_intake[iando->cnt_intake].crresultvol += cio.io_volume, iando->crintaketot += cio.io_volume
    IF (ce.event_end_dt_tm BETWEEN cnvtdatetime(curdate,700) AND cnvtdatetime((curdate+ 1),65959))
     iando->oral_intake[iando->cnt_intake].tresultvol += cio.io_volume, iando->tintaketot += cio
     .io_volume
    ELSEIF (ce.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 1),700) AND cnvtdatetime(curdate,65959
     ))
     iando->oral_intake[iando->cnt_intake].yresultvol += cio.io_volume, iando->yintaketot += cio
     .io_volume
    ENDIF
   ELSEIF (cio.io_type_flag=mn_output)
    iando->urine_output[iando->cnt_outputs].event = trim(uar_get_code_display(ce.event_cd),3), iando
    ->urine_output[iando->cnt_outputs].crresultvol += cio.io_volume, iando->croutputtot += cio
    .io_volume
    IF (ce.event_end_dt_tm BETWEEN cnvtdatetime(curdate,700) AND cnvtdatetime((curdate+ 1),65959))
     iando->urine_output[iando->cnt_outputs].tresultvol += cio.io_volume, iando->toutputtot += cio
     .io_volume
    ELSEIF (ce.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 1),700) AND cnvtdatetime(curdate,65959
     ))
     iando->urine_output[iando->cnt_outputs].yresultvol += cio.io_volume, iando->youtputtot += cio
     .io_volume
    ENDIF
   ENDIF
  FOOT  ce.event_cd
   null
  FOOT  ce.encntr_id
   iando->crbalance = (iando->crintaketot - iando->croutputtot), iando->tbalance = (iando->tintaketot
    - iando->toutputtot), iando->ybalance = (iando->yintaketot - iando->youtputtot),
   stat = alterlist(iando->urine_output,iando->cnt_outputs), stat = alterlist(iando->oral_intake,
    iando->cnt_intake)
  WITH nocounter
 ;end select
 IF ((((iando->tintaketot != 0)) OR ((iando->toutputtot != 0))) )
  SET iando->rtf = build2(iando->rtf,other_tables)
  IF ((iando->tintaketot != 0))
   SET iando->rtf = build2(iando->rtf,start_cell," Today's Intake Total",end_cell,start_cell_r,
    format(iando->tintaketot,"########"),end_cell," \row ")
  ENDIF
  IF ((iando->toutputtot != 0))
   SET iando->rtf = build2(iando->rtf,start_cell," Today's Output Total",end_cell,start_cell_r,
    format(iando->toutputtot,"########"),end_cell," \row ")
  ENDIF
  IF (size(iando->urine_output,5) > 0)
   FOR (x = 1 TO size(iando->urine_output,5))
     IF (x=1)
      IF ((iando->urine_output[x].tresultvol != 0))
       SET iando->rtf = build2(iando->rtf,start_cell," Today's ",trim(iando->urine_output[x].event,3),
        end_cell,
        start_cell_r,format(iando->urine_output[x].tresultvol,"########"),end_cell," \row ")
      ENDIF
     ELSE
      IF ((iando->urine_output[x].tresultvol != 0))
       SET iando->rtf = build2(iando->rtf,start_cell," Today's ",trim(iando->urine_output[x].event,3),
        end_cell,
        start_cell_r,format(iando->urine_output[x].tresultvol,"########"),end_cell," \row ")
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
  IF ((iando->tbalance != 0))
   SET iando->rtf = build2(iando->rtf,start_cell," Today's Balance",end_cell,start_cell_r,
    format(iando->tbalance,"########"),end_cell," \row ")
  ENDIF
 ENDIF
 IF ((((iando->yintaketot != 0)) OR ((iando->youtputtot != 0))) )
  SET iando->rtf = build2(iando->rtf,other_tables)
  IF ((iando->yintaketot != 0))
   SET iando->rtf = build2(iando->rtf,start_cell," Yesterday's Intake Total",end_cell,start_cell_r,
    format(iando->yintaketot,"########"),end_cell," \row ")
  ENDIF
  IF ((iando->youtputtot != 0))
   SET iando->rtf = build2(iando->rtf,start_cell," Yesterday's Output Total",end_cell,start_cell_r,
    format(iando->youtputtot,"########"),end_cell," \row ")
  ENDIF
  IF (size(iando->urine_output,5) != 0)
   FOR (x = 1 TO size(iando->urine_output,5))
     IF (x=1)
      IF ((iando->urine_output[x].yresultvol != 0))
       SET iando->rtf = build2(iando->rtf,start_cell," Yesterday's ",trim(iando->urine_output[x].
         event,3),end_cell,
        start_cell_r,format(iando->urine_output[x].yresultvol,"########"),end_cell," \row ")
      ENDIF
     ELSE
      IF ((iando->urine_output[x].yresultvol != 0))
       SET iando->rtf = build2(iando->rtf,start_cell," Yesterday's ",trim(iando->urine_output[x].
         event,3),end_cell,
        start_cell_r,format(iando->urine_output[x].yresultvol,"########"),end_cell," \row ")
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF ((iando->ybalance != 0))
  SET iando->rtf = build2(iando->rtf,start_cell," Yesterday's Balance",end_cell,start_cell_r,
   format(iando->ybalance,"########"),end_cell," \row ")
 ENDIF
 IF ((((iando->crintaketot != 0)) OR ((iando->croutputtot != 0))) )
  SET iando->rtf = build2(iando->rtf,other_tables)
  IF ((iando->crintaketot != 0))
   SET iando->rtf = build2(iando->rtf,start_cell," Clinical Range's Intake Total",end_cell,
    start_cell_r,
    format(iando->crintaketot,"########"),end_cell," \row ")
  ENDIF
  IF ((iando->croutputtot != 0))
   SET iando->rtf = build2(iando->rtf,start_cell," Clinical Range's Output Total",end_cell,
    start_cell_r,
    format(iando->croutputtot,"########"),end_cell," \row ")
  ENDIF
  IF (size(iando->urine_output,5) != 0)
   FOR (x = 1 TO size(iando->urine_output,5))
     IF (x=1)
      IF ((iando->urine_output[x].crresultvol != 0))
       SET iando->rtf = build2(iando->rtf,start_cell," Clinical Range's Total ",trim(iando->
         urine_output[x].event,3),end_cell,
        start_cell_r,format(iando->urine_output[x].crresultvol,"########"),end_cell," \row ")
      ENDIF
     ELSE
      IF ((iando->urine_output[x].crresultvol != 0))
       SET iando->rtf = build2(iando->rtf,start_cell," Clinical Range's Total ",trim(iando->
         urine_output[x].event,3),end_cell,
        start_cell_r,format(iando->urine_output[x].crresultvol,"########"),end_cell," \row ")
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
  IF ((iando->crbalance != 0))
   SET iando->rtf = build2(iando->rtf,start_cell," Clinical Range's Balance ",end_cell,start_cell_r,
    format(iando->crbalance,"########"),end_cell," \row ")
  ENDIF
 ENDIF
 SET iando->rtf = build(beg_doc,iando->rtf,end_doc)
 SET reply->text = iando->rtf
END GO
