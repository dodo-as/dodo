var dodo = 
{
    copyAddress: function(from, to)
    {
	$.each(["street1", "street2", "postal_code", "town", "country"], function(key, val){
		console.log(to + "_address_attributes_" + val);
		$("#" + to + "_address_attributes_" + val)[0].value = 
		$("#" + from + "_address_attributes_" + val)[0].value;
	    }); 
    }
};

function $i (id) { return $("#" + id); }

function startswith (str, prefix) {
  return str.substring(0,prefix.length) == prefix;
}

function endswith (str, suffix) {
  return str.substring(this.length - suffix.length) == suffix;
}

function map(fn, seq) {
  var res = new Array();

  $.each(seq, function (x) { res.push(fn(seq[x])); })
  return res;
}

function reduce (fn, seq) {
  var pos = 1;
  var res = seq[0];

  for (; pos < seq.length; pos++)
    res = fn(res, seq[pos]);
  return res;
}

function add (x, y) { return x + y; }
function sub (x, y) { return x - y; }
function mul (x, y) { return x * y; }
function div (x, y) { return x / y; }

function sum (seq) { return reduce(add, seq); }
function avg (seq) { return sum(seq) / seq.length; }

function find (fn, seq) {
  for (var pos = 0; pos < seq.length; pos++)
    if (fn(seq[pos]))
      return seq[pos];
  return undefined;
}

function replaceIdsInDOM(id, name, templateId, dom) {
    var item_id;
    var item_name;
    $.each(dom, function () {
	if (this.nodeType == 1) {  // Node.ELEMENT_TYPE
	    if (   this.id !== undefined
		&& startswith(this.id, templateId)) {
		item_id = id + this.id.substring(templateId.length);
		item_name = name + this.id.substring(templateId.length);
            }
	    if (   this.name !== undefined
		&& startswith(this.name, templateId)) {
		item_name = name + this.name.substring(templateId.length);
            }
            if (item_id !== undefined)
                this.id = item_id;
            if (item_name !== undefined)
                this.name = item_name;
            item_id = item_name = undefined;
	}
    })
    if (dom.children().length > 0)
        replaceIdsInDOM(id, name, templateId, dom.children());
}

function makeTemplateInstance(id, name, templateId) {
    var res = $('#' + templateId).clone(true);
    replaceIdsInDOM(id, name, templateId, res);
    res[0].style.display = 'inherit';
    return res[0];
}

function decorateDOM(dom, decoration) {
    var value;
    for (member in decoration) {
	value = decoration[member];
        if (value.argumentNames === undefined) {
            $.each(dom, function (domitem) { domitem[member] = value; });
        } else {
            decorateDOM($('#' + member, dom), value);
        }
    }
}

/**
   Parse a text string as a float, while treating ',' (a comma) the
   same as a '.' (period). An empty string is interpreted as the
   number zero. If the entire string can not be parsed into a float,
   NaN is returned.
 */
function parseFloatNazi(str) 
{
    if (str == null || str == "") {
	return 0.0;
    }

    var str2 = str.replace(/,/g,'.');

    if (str2.match(/^[0-9]*\.?[0-9]+$/))
	return parseFloat(str2);
    return NaN;
}

/**
   Format a floating point number for output on screen, using comma as
   the decimal separator and two digits of precision.
 */
function toMoney (val) {
    if (isNaN(val)) {
	return '?';
    }
    return val.toFixed(2).replace(/\./g,',');
}


// this function is needed to work around 
// a bug in IE related to element attributes
function hasClass(obj) {
    var result = false;
    if (obj.getAttributeNode("class") != null) {
	result = obj.getAttributeNode("class").value;
    }
    return result;
}   

/**
   Stripe the specified table
 */
function stripe(id) {
		
    // the flag we'll use to keep track of 
    // whether the current row is odd or even
    var even = false;
		
    // obtain a reference to the desired tables
    // ... and iterate through them
    var table_list;
    if (id != null) {
	table_list = $(id);
    } else {
	table_list = $('.striped');
    }
    
    for(var tab=0; tab<table_list.length;tab++) {
		
	var table = table_list[tab];
	if (! table) { continue; }
		    
	// by definition, tables can have more than one tbody
	// element, so we'll have to get the list of child
	// &lt;tbody&gt;s 
	var tbodies = table.getElementsByTagName("tbody");
		    
	// and iterate through them...
	for (var h = 0; h < tbodies.length; h++) {
			
	    // find all the &lt;tr&gt; elements... 
	    var trs = tbodies[h].getElementsByTagName("tr");
			
	    // ... and iterate through them
	    for (var i = 0; i < trs.length; i++) {

		var parent = trs[i].parentNode;
		while(parent && parent.nodeName.toLowerCase() != 'tbody') 
		    {
			parent = parent.parentNode;
		    }
	
		if( parent != tbodies[h] ) 
		    {
			continue;
		    }
				
		    
		// avoid rows that have a class attribute
		// or backgroundColor style
		if (! hasClass(trs[i]) &&
		    ! trs[i].style.backgroundColor) {
 		  
		    // get all the cells in this row...
		    var tds = trs[i].getElementsByTagName("td");
		    var ths = trs[i].getElementsByTagName("th");
		    
		    // and iterate through them...
		    for (var j = 0; j < tds.length; j++) {
			
			var mytd = tds[j];
			
			mytd.className = even?' even':' odd';
			if (mytd.otherClassName) {
			    mytd.className += ' ' +mytd.otherClassName;
			}
		    }
		    for (var j = 0; j < ths.length; j++) {
			
			var myth = ths[j];
			
			myth.className = even?' even':' odd';
			if (myth.otherClassName) {
			    myth.className += ' '+ myth.otherClassName;
			}
		    }
		}
		// flip from odd to even, or vice-versa
		even =  ! even;
	    }
	}
    }
}

$(function()
{
    $.datepicker.setDefaults({"dateFormat": 'yy-mm-dd'});
    $( ".dodo-tab-group" ).tabs();
    $('.datepicker').datepicker({
	    changeMonth: true,
		changeYear: true,
		yearRange: '1900:c+10'
		});


    var valOpt = {
	submitButtonSelector: ".dodo-validate-submit",
	message: "Invalid field value"
    };

    // Integer number
    var valIntOpt = {
	regExpMatch:/^-?[0-9 ]*$/, 
	processValid:function(str){return str.replace(/ /g,"");},
	message: "Not a valid whole number"
    };

    // Floating point number
    var valFloatOpt = {
	regExpMatch:/^-?[0-9 ]*([,.])?[0-9 ]*$/, 
	processValid:function(str){return str.replace(/ /g,"").replace(",",".");},
	message: "Not a valid decimal number"
    };
    
    // Data validation
    var valDateOpt = {
	message: "Not a valid date",
	regExpMatch: /^[12][0-9]{3}-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])$/
    };
    
    // Permissive regexp to kill the most obviously wrong telephone
    // numbers
    var valPhoneOpt = {
	message: "Not a valid phone number",
	regExpMatch: /^ *\+?([-. ()]*[0-9x]){3,20}[-. ()]*$/
    };
    
    // This gargantuan monster of a regexp is supposedly the most
    // RFC compliant email validator konwn to man. Or something.
    // 
    // Source: http://www.ex-parrot.com/pdw/Mail-RFC822-Address.html
    //
    // Note: Egil is boring for insisting on this comment.
    var valEmailOpt = {
	message: "Not a valid email",

	regExpMatch: /(?:(?:\r\n)?[ \t])*(?:(?:(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*))*@(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*|(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*)*\<(?:(?:\r\n)?[ \t])*(?:@(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*(?:,@(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*)*:(?:(?:\r\n)?[ \t])*)?(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*))*@(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*\>(?:(?:\r\n)?[ \t])*)|(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*)*:(?:(?:\r\n)?[ \t])*(?:(?:(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*))*@(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*|(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*)*\<(?:(?:\r\n)?[ \t])*(?:@(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*(?:,@(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*)*:(?:(?:\r\n)?[ \t])*)?(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*))*@(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*\>(?:(?:\r\n)?[ \t])*)(?:,\s*(?:(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*))*@(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*|(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*)*\<(?:(?:\r\n)?[ \t])*(?:@(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*(?:,@(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*)*:(?:(?:\r\n)?[ \t])*)?(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|"(?:[^\"\r\\]|\\.|(?:(?:\r\n)?[ \t]))*"(?:(?:\r\n)?[ \t])*))*@(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*)(?:\.(?:(?:\r\n)?[ \t])*(?:[^()<>@,;:\\".\[\] \000-\031]+(?:(?:(?:\r\n)?[ \t])+|\Z|(?=[\["()<>@,;:\\".\[\]]))|\[([^\[\]\r\\]|\\.)*\](?:(?:\r\n)?[ \t])*))*\>(?:(?:\r\n)?[ \t])*))*)?;\s*)/
    };
    
    var valRequiredOpt = {
	message: "Field must not be empty",
	notEmpty:true
    };
    
    $('.dodo-validate-integer').validateField($.extend({}, valOpt, valIntOpt));
    $('.dodo-validate-float').validateField($.extend({}, valOpt, valFloatOpt));
    $('.dodo-validate-mandatory').validateField($.extend({}, valOpt, valRequiredOpt));
    $('.dodo-validate-date').validateField($.extend({}, valOpt, valDateOpt));
    $('.dodo-validate-email').validateField($.extend({}, valOpt, valEmailOpt));
    $('.dodo-validate-phone').validateField($.extend({}, valOpt, valPhoneOpt));
    
});
