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

function parseFloatNazi(str) 
{
    if (str == null || str == "") {
	return 0;
    }

    var str2 = str.replace(/,/g,'.');

    if (str2.match(/^[0-9]*\.?[0-9]+$/))
	return parseFloat(str2);
    return NaN;
}

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
			
			mytd.className = even?'even':'odd';
		    }
		    for (var j = 0; j < ths.length; j++) {
			
			var myth = ths[j];
			
			myth.className = even?'even':'odd';
		    }
		}
		// flip from odd to even, or vice-versa
		even =  ! even;
	    }
	}
    }
}
