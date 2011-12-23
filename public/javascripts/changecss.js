function stripCharacter(words,character) {
	//documentation for this script at http://www.shawnolson.net/a/499/
	  var spaces = words.length;
	  for(var x = 1; x<spaces; ++x){
	   words = words.replace(character, "");
	 }
	 return words;
    }

		function changecss(theClass,element,value) {
		//Last Updated on July 4, 2011
		//documentation for this script at
		//http://www.shawnolson.net/a/503/altering-css-class-attributes-with-javascript.html
		 var cssRules;


		 for (var S = 0; S < document.styleSheets.length; S++){


			  try{
			  	document.styleSheets[S].insertRule(theClass+' { '+element+': '+value+'; }',document.styleSheets[S][cssRules].length);

			  } catch(err){
			  		try{document.styleSheets[S].addRule(theClass,element+': '+value+';');

					}catch(err){

					 	try{
						    if (document.styleSheets[S]['rules']) {
							  cssRules = 'rules';
							 } else if (document.styleSheets[S]['cssRules']) {
							  cssRules = 'cssRules';
							 } else {
							  //no rules found... browser unknown
							 }

							  for (var R = 0; R < document.styleSheets[S][cssRules].length; R++) {
							   if (document.styleSheets[S][cssRules][R].selectorText == theClass) {
							    if(document.styleSheets[S][cssRules][R].style[element]){
							    document.styleSheets[S][cssRules][R].style[element] = value;
								break;
							    }
							   }
							  }
						  } catch (err){}



					}

			  }


		}
	}

	function checkUncheckAll(theElement) {
     var theForm = theElement.form, z = 0;
	 for(z=0; z<theForm.length;z++){
      if(theForm[z].type == 'checkbox' && theForm[z].name != 'checkall'){
	  theForm[z].checked = theElement.checked;
	  }
     }
    }
