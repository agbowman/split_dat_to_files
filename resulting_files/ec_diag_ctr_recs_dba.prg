CREATE PROGRAM ec_diag_ctr_recs:dba
 PROMPT
  "Enter Output Directory: " = "",
  "Run Detail Reports on Failed Recommendations (Y/N): " = "",
  "Output (1 = CSV, 2 = XML): " = 1
  WITH outdev, runrecs, output
 DECLARE icnt = i4 WITH noconstant(0)
 DECLARE icnt2 = i4 WITH noconstant(0)
 DECLARE iloop_cnt = i4 WITH noconstant(0)
 DECLARE istart = i4 WITH noconstant(0)
 DECLARE iexpandidx = i4 WITH noconstant(0)
 DECLARE ibatch_size = i4 WITH constant(50)
 DECLARE sprogname = vc WITH noconstant(" ")
 DECLARE ipos = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE qualcnt = i4 WITH noconstant(0)
 DECLARE progcnt = i4 WITH noconstant(0)
 DECLARE souttext = vc WITH noconstant(" ")
 DECLARE scrlf = vc WITH constant(char(10))
 DECLARE stopic = vc WITH noconstant(" ")
 DECLARE ssolution = vc WITH noconstant(" ")
 DECLARE sxslloc = vc WITH constant(build(
   '<?xml-stylesheet type="text/xsl" href="http://scm.sc-ec.cerner.corp/svn/trunk/',
   'com.cerner.sc-ec.silverback/src/main/webapp/css/diag_ctr_recs_detail.xsl"?>'))
 DECLARE runscript(sscriptname=vc) = null
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH noconstant(" ")
 ENDIF
 SET last_mod = "001"
 FREE RECORD brrecinfo
 RECORD brrecinfo(
   1 reccnt = i4
   1 recs[*]
     2 program_name = vc
     2 detail_program_name = vc
     2 rec_id = f8
     2 rec_mean = vc
     2 category = vc
     2 subcategory = vc
     2 topics = vc
     2 solutions = vc
     2 short_desc = vc
     2 long_desc = vc
     2 design_decision = vc
     2 rationale = vc
     2 recommendation = vc
     2 resolution = vc
     2 code_level = vc
     2 status = i2
     2 script_status = i2
     2 override_ind = i2
 )
 FREE RECORD detailprog
 RECORD detailprog(
   1 progs_cnt = i4
   1 progs[*]
     2 detail_program_name = vc
     2 qual_cnt = i4
     2 qual[*]
       3 rec_mean = vc
 )
 FREE RECORD outfiles
 RECORD outfiles(
   1 qualcnt = i4
   1 qual[*]
     2 file_name = vc
 )
 SELECT INTO "nl:"
  FROM br_rec b,
   br_name_value nv,
   dummyt d
  PLAN (b
   WHERE b.active_ind=1)
   JOIN (d)
   JOIN (nv
   WHERE nv.br_name IN (b.category_mean, b.subcategory_mean)
    AND nv.br_nv_key1 IN ("DIAGNOSTICCATEGORIES", "DIAGNOSTICSUBCATEGORIES"))
  ORDER BY b.category_mean, b.subcategory_mean, b.rec_id,
   nv.br_value
  HEAD REPORT
   cnt = 0
  HEAD b.rec_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(brrecinfo->recs,(cnt+ 9))
   ENDIF
   brrecinfo->recs[cnt].program_name = trim(b.program_name,3), brrecinfo->recs[cnt].
   detail_program_name = trim(b.detail_program_name,3), brrecinfo->recs[cnt].rec_id = b.rec_id,
   brrecinfo->recs[cnt].rec_mean = trim(b.rec_mean,3), brrecinfo->recs[cnt].short_desc = trim(b
    .short_desc,3), brrecinfo->recs[cnt].long_desc = trim(b.long_desc,3),
   brrecinfo->recs[cnt].override_ind = b.override_ind
  DETAIL
   IF (nv.br_nv_key1="DIAGNOSTICCATEGORIES")
    brrecinfo->recs[cnt].category = trim(nv.br_value,3)
   ELSEIF (nv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
    brrecinfo->recs[cnt].subcategory = trim(nv.br_value,3)
   ENDIF
  FOOT REPORT
   stat = alterlist(brrecinfo->recs,cnt), brrecinfo->reccnt = cnt
  WITH nocounter, outerjoin = d
 ;end select
 SET iloop_cnt = ceil((cnvtreal(brrecinfo->reccnt)/ ibatch_size))
 SET istart = 1
 SET iexpandidx = 0
 SELECT INTO "nl:"
  FROM br_rec_r brr,
   br_name_value nv1,
   br_name_value nv2,
   (dummyt d  WITH seq = value(iloop_cnt))
  PLAN (d
   WHERE initarray(istart,evaluate(d.seq,1,1,(istart+ ibatch_size))))
   JOIN (brr
   WHERE expand(iexpandidx,istart,minval((istart+ (ibatch_size - 1)),brrecinfo->reccnt),brr.rec_id,
    brrecinfo->recs[iexpandidx].rec_id)
    AND ((brr.solution_mean > " ") OR (brr.topic_mean > " ")) )
   JOIN (nv1
   WHERE nv1.br_name=outerjoin(brr.solution_mean)
    AND nv1.br_nv_key1=outerjoin("DIAGNOSTICSOLUTIONS"))
   JOIN (nv2
   WHERE nv2.br_name=outerjoin(brr.topic_mean)
    AND nv2.br_nv_key1=outerjoin("DIAGNOSTICTOPICS"))
  ORDER BY brr.rec_id
  HEAD brr.rec_id
   stopic = "", ssolution = "", ipos = locateval(idx,1,brrecinfo->reccnt,brr.rec_id,brrecinfo->recs[
    idx].rec_id)
  DETAIL
   IF (nv1.br_nv_key1="DIAGNOSTICSOLUTIONS")
    ssolution = build(ssolution,nv1.br_value,";")
   ELSEIF (nv2.br_nv_key1="DIAGNOSTICTOPICS")
    stopic = build(stopic,nv2.br_value,";")
   ENDIF
  FOOT  brr.rec_id
   IF (ipos > 0)
    brrecinfo->recs[ipos].topics = substring(1,(textlen(stopic) - 1),stopic), brrecinfo->recs[ipos].
    solutions = substring(1,(textlen(ssolution) - 1),ssolution)
   ENDIF
  WITH nocounter
 ;end select
 SET istart = 1
 SET iexpandidx = 0
 SELECT INTO "nl:"
  FROM br_rec b,
   br_long_text lt1,
   br_long_text lt2,
   br_long_text lt3,
   br_long_text lt4,
   br_long_text lt5
  PLAN (b
   WHERE b.active_ind=1)
   JOIN (lt1
   WHERE lt1.long_text_id=b.design_decision_txt_id)
   JOIN (lt2
   WHERE lt2.long_text_id=b.rationale_txt_id)
   JOIN (lt3
   WHERE lt3.long_text_id=b.recommendation_txt_id)
   JOIN (lt4
   WHERE lt4.long_text_id=b.resolution_txt_id)
   JOIN (lt5
   WHERE lt5.long_text_id=b.code_lvl_txt_id)
  DETAIL
   ipos = locateval(idx,1,brrecinfo->reccnt,b.rec_id,brrecinfo->recs[idx].rec_id)
   IF (ipos > 0)
    brrecinfo->recs[ipos].design_decision = lt1.long_text, brrecinfo->recs[ipos].rationale = lt2
    .long_text, brrecinfo->recs[ipos].recommendation = lt3.long_text,
    brrecinfo->recs[ipos].resolution = lt4.long_text, brrecinfo->recs[ipos].code_level = lt5
    .long_text
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  FOR (icnt = 1 TO size(brrecinfo->recs,5))
    FREE SET reply
    RECORD reply(
      1 run_status_flag = i2
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c15
          3 operationstatus = c1
          3 targetobjectname = c15
          3 targetobjectvalue = c100
    )
    IF (checkprg(brrecinfo->recs[icnt].program_name) > 0)
     CALL echo(build2("Running: ",brrecinfo->recs[icnt].program_name))
     CALL runscript(brrecinfo->recs[icnt].program_name)
     IF ((reply->status_data.status="S"))
      SET brrecinfo->recs[icnt].script_status = reply->run_status_flag
      IF ((reply->run_status_flag != 3))
       SET brrecinfo->recs[icnt].status = 1
      ELSE
       IF ((brrecinfo->recs[icnt].override_ind=1))
        SET brrecinfo->recs[icnt].status = 2
       ELSE
        SET brrecinfo->recs[icnt].status = 0
       ENDIF
       IF ((detailprog->progs_cnt > 0))
        SET ipos = locateval(idx,1,size(detailprog->progs,5),brrecinfo->recs[icnt].
         detail_program_name,detailprog->progs[idx].detail_program_name)
        IF (ipos=0)
         SET progcnt = (detailprog->progs_cnt+ 1)
         SET detailprog->progs_cnt = progcnt
         SET stat = alterlist(detailprog->progs,progcnt)
         SET detailprog->progs[progcnt].detail_program_name = brrecinfo->recs[icnt].
         detail_program_name
         SET ipos = progcnt
        ENDIF
       ELSE
        SET progcnt = (detailprog->progs_cnt+ 1)
        SET detailprog->progs_cnt = progcnt
        SET stat = alterlist(detailprog->progs,progcnt)
        SET detailprog->progs[progcnt].detail_program_name = brrecinfo->recs[icnt].
        detail_program_name
        SET ipos = progcnt
       ENDIF
       SET qualcnt = (detailprog->progs[ipos].qual_cnt+ 1)
       SET detailprog->progs[ipos].qual_cnt = qualcnt
       SET stat = alterlist(detailprog->progs[ipos].qual,qualcnt)
       SET detailprog->progs[ipos].qual[qualcnt].rec_mean = brrecinfo->recs[icnt].rec_mean
      ENDIF
     ELSE
      CALL echo(build("Script failure: ",brrecinfo->recs[icnt].program_name))
      SET brrecinfo->recs[icnt].status = 3
     ENDIF
    ELSE
     CALL echo(build("Script was not found: ",brrecinfo->recs[icnt].program_name))
     SET brrecinfo->recs[icnt].status = 4
    ENDIF
  ENDFOR
 ELSE
  CALL echo("No recomendations found the the br_rec table")
 ENDIF
 IF (( $OUTPUT=1))
  SELECT INTO value(concat( $OUTDEV,"ec_diag_ctr_dashboard.csv"))
   status =
   IF ((brrecinfo->recs[d.seq].status=0)) "Fail"
   ELSEIF ((brrecinfo->recs[d.seq].status=1)) "Pass"
   ELSEIF ((brrecinfo->recs[d.seq].status=2)) "Override"
   ELSEIF ((brrecinfo->recs[d.seq].status=3)) "Script Failure"
   ELSEIF ((brrecinfo->recs[d.seq].status=4)) "Script Not Found"
   ENDIF
   FROM (dummyt d  WITH seq = brrecinfo->reccnt)
   PLAN (d)
   HEAD REPORT
    souttext = build(
     '"Category","Subcategory","Solution(s)","Topic(s)","Check Name","Pass/Fail/Override"'), souttext
     = build(souttext,
     ',"Long Desc","Detail Output File","Design Decision","Rationale","Recommendation"'), souttext =
    build(souttext,',"Resolution","Code Level"'),
    col 0, souttext
   DETAIL
    souttext = build('"',brrecinfo->recs[d.seq].category,'",'), souttext = build(souttext,'"',
     brrecinfo->recs[d.seq].subcategory,'",'), souttext = build(souttext,'"',brrecinfo->recs[d.seq].
     solutions,'",'),
    souttext = build(souttext,'"',brrecinfo->recs[d.seq].topics,'",'), souttext = build(souttext,'"',
     brrecinfo->recs[d.seq].short_desc,'",'), souttext = build(souttext,'"',status,'",'),
    souttext = build(souttext,'"',brrecinfo->recs[d.seq].long_desc,'",'), souttext = build(souttext,
     '"',"ec_",cnvtlower(brrecinfo->recs[d.seq].rec_mean),"_detail.csv",
     '",'), souttext = build(souttext,'"',brrecinfo->recs[d.seq].design_decision,'",'),
    souttext = build(souttext,'"',brrecinfo->recs[d.seq].rationale,'",'), souttext = build(souttext,
     '"',brrecinfo->recs[d.seq].recommendation,'",'), souttext = build(souttext,'"',brrecinfo->recs[d
     .seq].resolution,'",'),
    souttext = build(souttext,'"',brrecinfo->recs[d.seq].code_level,'"'), row + 1, souttext
   WITH nocounter, format = variable, maxcol = 20000,
    formfeed = none
  ;end select
 ELSEIF (( $OUTPUT=2))
  SELECT INTO value(concat( $OUTDEV,"ec_diag_ctr_dashboard.csv"))
   status =
   IF ((brrecinfo->recs[d.seq].status=0)) "Fail"
   ELSEIF ((brrecinfo->recs[d.seq].status=1)) "Pass"
   ELSEIF ((brrecinfo->recs[d.seq].status=2)) "Override"
   ELSEIF ((brrecinfo->recs[d.seq].status=3)) "Script Failure"
   ELSEIF ((brrecinfo->recs[d.seq].status=4)) "Script Not Found"
   ENDIF
   FROM (dummyt d  WITH seq = brrecinfo->reccnt)
   PLAN (d)
   HEAD REPORT
    souttext = build(
     '"Check Meaning","Status","Pass/Fail/Override","Rec Script Status","Detail Output File"'), col 0,
    souttext
   DETAIL
    souttext = build('"',brrecinfo->recs[d.seq].rec_mean,'",'), souttext = build(souttext,'"',
     brrecinfo->recs[d.seq].status,'",'), souttext = build(souttext,'"',status,'",'),
    souttext = build(souttext,'"',brrecinfo->recs[d.seq].script_status,'",'), souttext = build(
     souttext,'"',"ec_",cnvtlower(brrecinfo->recs[d.seq].rec_mean),"_detail.xml",
     '"'), row + 1,
    souttext
   WITH nocounter, format = variable, maxcol = 20000,
    formfeed = none
  ;end select
 ENDIF
 IF (cnvtupper( $RUNRECS)="Y")
  SET idx = 0
  FOR (icnt = 1 TO size(detailprog->progs,5))
    FOR (icnt2 = 1 TO size(detailprog->progs[icnt].qual,5))
      FREE RECORD request
      RECORD request(
        1 program_name = vc
        1 output_filename = vc
        1 paramlist[*]
          2 meaning = vc
      )
      FREE RECORD reply
      RECORD reply(
        1 collist[*]
          2 header_text = vc
          2 data_type = i2
          2 hide_ind = i2
        1 rowlist[*]
          2 celllist[*]
            3 date_value = dq8
            3 nbr_value = i4
            3 double_value = f8
            3 string_value = vc
            3 display_flag = i2
        1 high_volume_flag = i2
        1 output_filename = vc
        1 run_status_flag = i2
        1 statlist[*]
          2 statistic_meaning = vc
          2 status_flag = i2
          2 qualifying_items = i4
          2 total_items = i4
        1 status_data
          2 status = c1
          2 subeventstatus[1]
            3 operationname = c25
            3 operationstatus = c1
            3 targetobjectname = c25
            3 targetobjectvalue = vc
      )
      SET request->program_name = detailprog->progs[icnt].detail_program_name
      SET stat = alterlist(request->paramlist,1)
      SET request->paramlist[1].meaning = detailprog->progs[icnt].qual[icnt2].rec_mean
      IF (checkprg(detailprog->progs[icnt].detail_program_name) > 0)
       CALL echo(build("Running detail script for: ",detailprog->progs[icnt].qual[icnt2].rec_mean))
       CALL runscript(detailprog->progs[icnt].detail_program_name)
       IF ((reply->status_data.status="S"))
        IF (( $OUTPUT=1))
         SET request->output_filename = build("ec_",cnvtlower(detailprog->progs[icnt].qual[icnt2].
           rec_mean),"_detail.csv")
         EXECUTE bed_rpt_file  WITH replace("PCFORMAT","VARIABLE")
        ELSEIF (( $OUTPUT=2))
         SET request->output_filename = build("ec_",cnvtlower(detailprog->progs[icnt].qual[icnt2].
           rec_mean),"_detail.xml")
         SET trace = nocost
         SET message = noinformation
         SET trace = nocallecho
         SELECT INTO value(request->output_filename)
          FOOT REPORT
           col 0, sxslloc
          WITH nocounter, format = variable, maxcol = 10000,
           formfeed = none
         ;end select
         SET trace = cost
         SET message = information
         SET trace = callecho
         CALL echoxml(reply,request->output_filename,1)
        ENDIF
        SET idx = (idx+ 1)
        SET outfiles->qualcnt = idx
        SET stat = alterlist(outfiles->qual,idx)
        SET outfiles->qual[idx].file_name = build( $OUTDEV,request->output_filename)
       ELSE
        CALL echo(build("Detail program failed: ",detailprog->progs[icnt].detail_program_name))
       ENDIF
      ELSE
       CALL echo(build("Detail program missing: ",detailprog->progs[icnt].detail_program_name))
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(outfiles->qualcnt))
  WHERE (outfiles->qual[d.seq].file_name != "")
  HEAD REPORT
   CALL echo("******************************************"),
   CALL echo(" Files created"),
   CALL echo("******************************************"),
   CALL echo(build( $OUTDEV,"ec_diag_ctr_dashboard.csv"))
  DETAIL
   CALL echo(outfiles->qual[d.seq].file_name)
  WITH nocounter
 ;end select
 SUBROUTINE runscript(sscriptname)
   SET trace = nocost
   SET message = noinformation
   SET trace = nocallecho
   EXECUTE value(sscriptname)
   SET trace = cost
   SET message = information
   SET trace = callecho
 END ;Subroutine
END GO
