CREATE PROGRAM ccl_prompt_chk_prgexist
 RECORD request(
   1 programname = vc
   1 groupno = i2
 )
 RECORD reply(
   1 result = i2
 )
 SET reply->result = 0
 SELECT INTO "nl:"
  FROM ccl_prompt_definitions cpd
  WHERE cpd.program_name=cnvtupper(request->programname)
   AND (cpd.group_no=request->groupno)
   AND cpd.position=0
  DETAIL
   reply->result = (reply->result+ 2)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dprotect d
  WHERE d.object_name=cnvtupper(request->programname)
   AND (d.group=request->groupno)
   AND d.object="P"
  DETAIL
   reply->result = (reply->result+ 1)
  WITH nocounter
 ;end select
 RETURN
END GO
