CREATE PROGRAM conman_html_generator:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE PUBLIC::main(null) = null
 DECLARE PUBLIC::generatehtml(null) = null WITH protect
 SUBROUTINE PUBLIC::generatehtml(null)
   DECLARE content_root_path = vc WITH private, noconstant("")
   DECLARE i18n_file_str = vc WITH private, noconstant("")
   DECLARE root_dir = vc WITH private, constant("configuration-mgr")
   SET content_root_path = getstaticcontentroot("Configuration Manager",concat(root_dir,
     "/js/configuration-manager.js"))
   SET content_root_path = concat(content_root_path,root_dir)
   SET i18n_file_str = get_locale_data_sub("")
   SET _memory_reply_string = build2(
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">',
    "<html>","<head>","<META content=IE=edge http-equiv=X-UA-Compatible>",
    '<META content="text/html; charset=iso-8859-1" http-equiv=Content-Type>',
    '<meta content="CCLLINK" name="discern">','<link rel="stylesheet" type="text/css"','href="',
    content_root_path,'/css/configuration-manager.css">',
    '<script type ="text/javascript" src="',content_root_path,'/lib/jquery.js"></script>',
    '<script type ="text/javascript" src="',content_root_path,
    '/lib/pex-utils.js"></script>','<script type="text/javascript" src="',content_root_path,"/i18n/",
    i18n_file_str,
    '"></script>','<script type ="text/javascript" src="',content_root_path,
    '/js/configuration-manager.js"> ',"</script>",
    '<script type ="text/javascript">',"window.onload = function(){","var newConMan = new ConMan();",
    "newConMan.retrieveToolData();","}</script>",
    "<title>Configuration Manager</title>","</head>","<body>",
    '<div id="conMan" class="conman"></div>',"</body>",
    "</html>")
 END ;Subroutine
 SUBROUTINE PUBLIC::main(null)
  EXECUTE cnfg_mgr_tools_common_copy
  CALL generatehtml(null)
 END ;Subroutine
 CALL main(null)
#exit_script
 IF (validate(debug_ind,0)=1)
  CALL echo(_memory_reply_string)
 ENDIF
END GO
