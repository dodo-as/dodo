
var paymentRuns = {

  validate: function(){
    $('.pr-user-form').each(
      function(){
	var amount = 0;
	var empty = true;
	$('input', this).each(
	  function(){
//	    console.log("Checking box;");
//	    console.log(this);
	    if(this.checked){
	      empty = false;
	      amount += paymentRuns.amounts[this.value];
	    }
	  });
	$('button', this).attr('disabled',((amount != 0) || empty));
	$('span.amount', this).text(amount);
      });
  }
};

$(function(){
    paymentRuns.validate();
  }
 );