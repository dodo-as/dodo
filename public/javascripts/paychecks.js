 $(document).ready(function() {
        paychecks.updateDisplay();    
        $("#paycheck_period_id")[0].onchange=function(e){
                                                        paychecks.updateDisplay();    
                                                    };
});

   
var paychecks = {

    getValues: function(date) {
        var result = [];
        for (var i=0; i<DODO.countiesList.length; i+=1) {
            if (DODO.countiesList[i][0] <= date) {
                result[0] = DODO.countiesList[i][1];
                for (var j=0; j<DODO.taxZonesList[i].length; j+=1) {
                    if (DODO.taxZonesList[i][j] != null && DODO.taxZonesList[i][j][0] <= date) {
                        result[1] = DODO.taxZonesList[i][j][1]
                        for (var k=0; k<DODO.taxRatesList[i][j].length; k+=1) {
                            if (DODO.taxRatesList[i][j][k][0] <= date) {
                                result[2] = DODO.taxRatesList[i][j][k][1]
                            }
                        }
                    }
                }
            }
        };
        return result
    },
        
    getDate: function() {
        result = $("#paycheck_period_id option:selected")[0].text.replace(" ", "-");
        result += "-01";
        return result ;
    },
    
    displayValues: function(values) {
        if (values[0] != null) {
            $(".dodo_county").text(values[0]);
        }
        else {
            $(".dodo_county").text("NONE");
        }
        if (values[1] != null) {
            $(".dodo_zone").text(values[1]);
        }
        else {
            $(".dodo_zone").text("NONE");
        }
        if (values[2] != null) {
            $(".dodo_rate").text(values[2]);
        }
        else {
            $(".dodo_rate").text("NONE");
        }
            
    },
    
    updateDisplay: function() {
        var date = paychecks.getDate();
        var values = paychecks.getValues(date);
        paychecks.displayValues(values)
    },
    
}
