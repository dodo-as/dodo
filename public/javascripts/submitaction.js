var submitAction = {
    registerSubmitAction: function (controller, action, form) {

        $(controller)[0]['on' + action] = function (event) {
            $(form)[0].submit();
        };
    }
}
