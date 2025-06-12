CREATE PROGRAM aps_get_stains_resultlayout:dba
 RECORD reply(
   1 custom_response = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD tmp(
   1 case_id = f8
   1 ih_ind = i2
   1 ss_ind = i2
   1 ih[1]
     2 spec_cnt = i4
     2 spec[*]
       3 specimen_desc = vc
       3 specimen_tag = vc
       3 stain_cnt = i4
       3 stains[*]
         4 text = vc
       3 block_cnt = i4
       3 blocks[*]
         4 block_tag = vc
         4 stain_cnt = i4
         4 stains[*]
           5 text = vc
   1 ss[1]
     2 spec_cnt = i4
     2 spec[*]
       3 specimen_desc = vc
       3 specimen_tag = vc
       3 stain_cnt = i4
       3 stains[*]
         4 text = vc
       3 block_cnt = i4
       3 blocks[*]
         4 block_tag = vc
         4 stain_cnt = i4
         4 stains[*]
           5 text = vc
 )
 DECLARE verify_cd = f8 WITH constant(uar_get_code_by("MEANING",1305,"VERIFIED"))
 DECLARE ihc_cd = f8 WITH constant(uar_get_code_by("MEANING",4726128,"AP-IHCSTAIN"))
 DECLARE ss_cd = f8 WITH constant(uar_get_code_by("MEANING",4726128,"AP-SPECSTAIN"))
 DECLARE rtf_type = vc WITH constant(notrim(" \pard\partightenfactor0\f0\b0\fs20\i \cf0 "))
 DECLARE rtf_stain = vc WITH constant(notrim(" \pard\partightenfactor0\f1\b0\fs20\i0 \cf0 "))
 DECLARE rtf_crlf = vc WITH constant(notrim(" \par "))
 SET reply->custom_response = "{\rtf1\ansi\ansicpg1252\cocoartf2513"
 SET reply->custom_response = build2(reply->custom_response,"\cocoatextscaling0\cocoaplatform0")
 SET reply->custom_response = build2(reply->custom_response,
  "{\fonttbl\f0\fswiss\fcharset0 Arial-BoldMT;\f1\fswiss\fcharset0 ArialMT;}")
 SET reply->custom_response = build2(reply->custom_response,"{\colortbl;\red255\green255\blue255;}")
 SET reply->custom_response = build2(reply->custom_response,"{\*\expandedcolortbl;;}")
 SET reply->custom_response = build2(reply->custom_response,
  "\margl1440\margr1440\vieww10800\viewh8400\viewkind0")
 SUBROUTINE (build_rtf_content(type_cd=f8) =null WITH protect)
  IF (type_cd=ihc_cd)
   SET reply->custom_response = build2(reply->custom_response,rtf_type,
    "Immunohistochemistry Stains Performed:")
   SET curalias l1 tmp->ih[1]
   SET curalias l2 tmp->ih[1].spec[x]
   SET curalias l3 tmp->ih[1].spec[x].stains[y]
   SET curalias l3_1 tmp->ih[1].spec[x].blocks[y]
   SET curalias l4 tmp->ih[1].spec[x].blocks[y].stains[z]
  ELSEIF (type_cd=ss_cd)
   IF ((tmp->ih_ind=1))
    SET reply->custom_response = build2(reply->custom_response,"\par\par")
   ENDIF
   SET reply->custom_response = build2(reply->custom_response,rtf_type,"Special Stains Performed:")
   SET curalias l1 tmp->ss[1]
   SET curalias l2 tmp->ss[1].spec[x]
   SET curalias l3 tmp->ss[1].spec[x].stains[y]
   SET curalias l3_1 tmp->ss[1].spec[x].blocks[y]
   SET curalias l4 tmp->ss[1].spec[x].blocks[y].stains[z]
  ENDIF
  FOR (x = 1 TO l1->spec_cnt)
    SET reply->custom_response = build2(reply->custom_response,rtf_type,rtf_crlf,l2->specimen_tag,
     ": ",
     l2->specimen_desc,": ")
    FOR (y = 1 TO l2->stain_cnt)
      IF (y=1)
       SET reply->custom_response = build2(reply->custom_response,rtf_stain," ",l3->text)
      ELSEIF ((y=l2->stain_cnt)
       AND y != 1)
       SET reply->custom_response = build2(reply->custom_response,rtf_stain," and ",l3->text)
      ELSE
       SET reply->custom_response = build2(reply->custom_response,rtf_stain,", ",l3->text)
      ENDIF
    ENDFOR
    FOR (y = 1 TO l2->block_cnt)
     IF (y=1)
      IF ((l2->stain_cnt > 0))
       SET reply->custom_response = build2(reply->custom_response,";",rtf_type," Block ",l3_1->
        block_tag,
        ": ")
      ELSE
       SET reply->custom_response = build2(reply->custom_response,rtf_type," Block ",l3_1->block_tag,
        ": ")
      ENDIF
     ELSE
      SET reply->custom_response = build2(reply->custom_response,";",rtf_type," Block ",l3_1->
       block_tag,
       ": ")
     ENDIF
     FOR (z = 1 TO l3_1->stain_cnt)
       IF (z=1)
        SET reply->custom_response = build2(reply->custom_response,rtf_stain," ",l4->text)
       ELSEIF ((z=l3_1->stain_cnt)
        AND z != 1)
        SET reply->custom_response = build2(reply->custom_response,rtf_stain," and ",l4->text)
       ELSE
        SET reply->custom_response = build2(reply->custom_response,rtf_stain,", ",l4->text)
       ENDIF
     ENDFOR
    ENDFOR
  ENDFOR
 END ;Subroutine
 SELECT INTO "nl:"
  FROM report_task rt,
   case_report cr
  PLAN (rt
   WHERE (rt.editing_prsnl_id=request->updt_id)
    AND (rt.updt_applctx=request->appl_context))
   JOIN (cr
   WHERE cr.report_id=rt.report_id)
  HEAD REPORT
   x = 0
  DETAIL
   x += 1, tmp->case_id = cr.case_id
  FOOT REPORT
   IF (x > 1)
    tmp->case_id = - (1)
   ENDIF
  WITH nocounter
 ;end select
 IF ((tmp->case_id > 0))
  SELECT INTO "nl:"
   FROM processing_task pt,
    case_specimen cs,
    ap_task_assay_addl atad,
    ap_tag spec_disp,
    ap_tag block_disp
   PLAN (pt
    WHERE (pt.case_id=tmp->case_id)
     AND pt.status_cd=verify_cd
     AND pt.no_charge_ind=0
     AND pt.create_inventory_flag=0)
    JOIN (atad
    WHERE atad.task_assay_cd=pt.task_assay_cd
     AND atad.task_assay_type_cd IN (ihc_cd, ss_cd)
     AND atad.task_assay_type_cd > 0)
    JOIN (cs
    WHERE cs.case_specimen_id=pt.case_specimen_id)
    JOIN (spec_disp
    WHERE spec_disp.tag_id=pt.case_specimen_tag_id)
    JOIN (block_disp
    WHERE block_disp.tag_id=pt.cassette_tag_id)
   ORDER BY atad.task_assay_type_cd, spec_disp.tag_disp, block_disp.tag_disp,
    atad.task_assay_cd
   HEAD REPORT
    ih_spec_cnt = 0, ih_spec_stain_cnt = 0, ih_spec_block_cnt = 0,
    ih_spec_block_stain_cnt = 0, ss_spec_cnt = 0, ss_spec_stain_cnt = 0,
    ss_spec_block_cnt = 0, ss_spec_block_stain_cnt = 0
   HEAD atad.task_assay_type_cd
    IF (atad.task_assay_type_cd=ss_cd)
     tmp->ss_ind = 1
    ELSEIF (atad.task_assay_type_cd=ihc_cd)
     tmp->ih_ind = 1
    ENDIF
   HEAD spec_disp.tag_disp
    ih_spec_stain_cnt = 0, ih_spec_block_cnt = 0, ih_spec_block_stain_cnt = 0,
    ss_spec_stain_cnt = 0, ss_spec_block_cnt = 0, ss_spec_block_stain_cnt = 0
    IF (atad.task_assay_type_cd=ss_cd)
     ss_spec_cnt += 1, stat = alterlist(tmp->ss[1].spec,ss_spec_cnt), tmp->ss[1].spec_cnt =
     ss_spec_cnt,
     tmp->ss[1].spec[ss_spec_cnt].specimen_tag = spec_disp.tag_disp, tmp->ss[1].spec[ss_spec_cnt].
     specimen_desc = cs.specimen_description
    ELSEIF (atad.task_assay_type_cd=ihc_cd)
     ih_spec_cnt += 1, stat = alterlist(tmp->ih[1].spec,ih_spec_cnt), tmp->ih[1].spec_cnt =
     ih_spec_cnt,
     tmp->ih[1].spec[ih_spec_cnt].specimen_tag = spec_disp.tag_disp, tmp->ih[1].spec[ih_spec_cnt].
     specimen_desc = cs.specimen_description
    ENDIF
   HEAD block_disp.tag_disp
    ih_spec_block_stain_cnt = 0, ss_spec_block_stain_cnt = 0, ih_spec_stain_cnt = 0,
    ss_spec_stain_cnt = 0
    IF (trim(block_disp.tag_disp) != "")
     IF (atad.task_assay_type_cd=ss_cd)
      ss_spec_block_cnt += 1, stat = alterlist(tmp->ss[1].spec[ss_spec_cnt].blocks,ss_spec_block_cnt),
      tmp->ss[1].spec[ss_spec_cnt].block_cnt = ss_spec_block_cnt,
      tmp->ss[1].spec[ss_spec_cnt].blocks[ss_spec_block_cnt].block_tag = block_disp.tag_disp
     ELSEIF (atad.task_assay_type_cd=ihc_cd)
      ih_spec_block_cnt += 1, stat = alterlist(tmp->ih[1].spec[ih_spec_cnt].blocks,ih_spec_block_cnt),
      tmp->ih[1].spec[ih_spec_cnt].block_cnt = ih_spec_block_cnt,
      tmp->ih[1].spec[ih_spec_cnt].blocks[ih_spec_block_cnt].block_tag = block_disp.tag_disp
     ENDIF
    ENDIF
   HEAD atad.task_assay_cd
    IF (trim(block_disp.tag_disp)="")
     IF (atad.task_assay_type_cd=ss_cd)
      ss_spec_stain_cnt += 1, stat = alterlist(tmp->ss[1].spec[ss_spec_cnt].stains,ss_spec_stain_cnt),
      tmp->ss[1].spec[ss_spec_cnt].stain_cnt = ss_spec_stain_cnt,
      tmp->ss[1].spec[ss_spec_cnt].stains[ss_spec_stain_cnt].text = uar_get_code_description(atad
       .task_assay_cd)
     ELSEIF (atad.task_assay_type_cd=ihc_cd)
      ih_spec_stain_cnt += 1, stat = alterlist(tmp->ih[1].spec[ih_spec_cnt].stains,ih_spec_stain_cnt),
      tmp->ih[1].spec[ih_spec_cnt].stain_cnt = ih_spec_stain_cnt,
      tmp->ih[1].spec[ih_spec_cnt].stains[ih_spec_stain_cnt].text = uar_get_code_description(atad
       .task_assay_cd)
     ENDIF
    ELSE
     IF (atad.task_assay_type_cd=ss_cd)
      ss_spec_block_stain_cnt += 1, stat = alterlist(tmp->ss[1].spec[ss_spec_cnt].blocks[
       ss_spec_block_cnt].stains,ss_spec_block_stain_cnt), tmp->ss[1].spec[ss_spec_cnt].blocks[
      ss_spec_block_cnt].stain_cnt = ss_spec_block_stain_cnt,
      tmp->ss[1].spec[ss_spec_cnt].blocks[ss_spec_block_cnt].stains[ss_spec_block_stain_cnt].text =
      uar_get_code_description(atad.task_assay_cd)
     ELSEIF (atad.task_assay_type_cd=ihc_cd)
      ih_spec_block_stain_cnt += 1, stat = alterlist(tmp->ih[1].spec[ih_spec_cnt].blocks[
       ih_spec_block_cnt].stains,ih_spec_block_stain_cnt), tmp->ih[1].spec[ih_spec_cnt].blocks[
      ih_spec_block_cnt].stain_cnt = ih_spec_block_stain_cnt,
      tmp->ih[1].spec[ih_spec_cnt].blocks[ih_spec_block_cnt].stains[ih_spec_block_stain_cnt].text =
      uar_get_code_description(atad.task_assay_cd)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF ((tmp->ih_ind=1))
   CALL build_rtf_content(ihc_cd)
  ENDIF
  IF ((tmp->ss_ind=1))
   CALL build_rtf_content(ss_cd)
  ENDIF
 ENDIF
 IF ((tmp->case_id=0))
  SET reply->custom_response = build2(reply->custom_response,rtf_type,"No case found.")
  SET reply->status_data.status = "S"
 ELSEIF ((tmp->case_id=- (1)))
  SET reply->custom_response = build2(reply->custom_response,rtf_type,"Multiple cases found.")
  SET reply->status_data.status = "S"
 ELSEIF ((tmp->ih_ind=0)
  AND (tmp->ss_ind=0))
  SET reply->custom_response = build2(reply->custom_response,rtf_type,"No stains found.")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET reply->custom_response = build2(reply->custom_response,"}")
END GO
