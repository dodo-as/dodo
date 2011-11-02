/*jslint white: true, onevar: true, undef: true, newcap: true, nomen: true, regexp: true, plusplus: true, bitwise: true, strict: true */
(function ($) {//
    "use strict";
    $.fn.validateField = function (newOptions) {
        var defaults, options, titleCase;
        defaults = {
            notEmpty: false,
            regExpMatch: false,
            numeric: false,
            minLength: false,
            changeCase: false,
            isValid: true,
            message: false,
            processValid: false,
            makeValid: false,
            runNow: false,
            validateOn: false,
            validateEvent: 'change',
            invalidClass: 'invalid',
            errorMessageElement: 'span',
            errorMessageClass: 'error-message',
            submitButtonSelector: 'input[type=submit],#submit'
        };
        options = $.extend(defaults, newOptions);
        options.get = function (option, value) {
            var func;
            if (typeof (options[option]) === "function") {
                func = options[option];
                return func(value);
            } else {
                return options[option];
            }
        };
        titleCase = function (str, force) {
            var i, chars, text;
            if (force === null) {
                force = true;
            }
            if ((str === str.toLowerCase() ||
                 str === str.toUpperCase() ||
                 force) && str !== "") {
                text = str.toLowerCase();
                chars = text.split('');
                chars[0] = chars[0].toUpperCase();
                for (i = 1; i < chars.length; i = i + 1) {
                    if (chars[i - 1] === ' ' || chars[i - 1] === '-') {
                        chars[i] = chars[i].toUpperCase();
                    }
                }
                return chars.join('');
            } else {
                return str;
            }
        };
        if ($.expr[':'].empty === 'undefined') {
            $.expr[':'].empty = function () {
                if (this.val() === '' || this.val() === undefined) {
                    return true;
                }
                return false;
            };
        }
        $.expr[':'].valid = function () {
            return !this.hasClass(options.invalidClass);
        };
        return this.each(function () {
            var valueProcess, runValidation, validateNow, input = this, validationNamespace, validateEvent, submitButton;
            valueProcess = function (value, element) {
                var changeCase;
                $(element).removeClass(options.get('invalidClass', value));
                $(element).next('.error-message').remove();
                if (options.processValid !== false) {
                    value = options.processValid(value);
                }
                changeCase = options.get('changeCase', value);
                if (changeCase === "upper") {
                    value = value.toUpperCase();
                } else if (changeCase === "lower") {
                    value = value.toLowerCase();
                } else if (changeCase === "title") {
                    value = titleCase(value, false);
                } else if (changeCase === "title-force") {
                    value = titleCase(value, true);
                }
                return value;
            };
            runValidation = function (value) {
                var regExpMatch, minLength;
                if (options.get('notEmpty', value) && value === '') {
                    return false;
                }
                if (value === '') {
                    return true;
                }
                regExpMatch = options.get('regExpMatch', value);
                minLength = options.get('minLength', value);
                if ((regExpMatch !== false && !value.match(regExpMatch)) ||
                    (minLength !== false && value.length < minLength)) {
                    return false;
                }
                return options.get('isValid', value);
            };
            validateNow = function (element) {
                var value = $.trim($(element).val()),
                    valid = false,
                    testValue;
                if (runValidation(value)) {
                    value = valueProcess(value, element);
                    valid = true;
                } else {
                    if (options.makeValid !== false) {
                        testValue = options.makeValid(value);
                        if (runValidation(testValue)) {
                            value = valueProcess(testValue, element);
                            valid = true;
                        }
                    }
                    if (valid === false) {
                        $(element).addClass(options.get('invalidClass', value));
                        if (options.get('message', value) !== false &&
                            $(element).next('.' + options.get('errorMessageClass', $(element).val())).size() === 0) {
                            $(element).after(
                                '<' + options.get('errorMessageElement', value) +
                                ' class="' + options.get('errorMessageClass', value) + '">' +
                                options.get('message', $(element).val()) + '</' + options.get('errorMessageElement', value) + '>'
                            );
                        }
                    }
                }
                $(element).val(value);
                return valid;
            };
            if (options.get('numeric', $(this).val()) &&
                options.regExpMatch === false) {
                options.regExpMatch = /^\d*$/;
            }
            if (options.get("runNow", $(input).val())) {
                validateNow(this);
            }
            if ($().closest !== undefined) {
                submitButton = $(this).closest('form').find(options.submitButtonSelector);
            }
            if (submitButton === undefined || !submitButton.size()) {
                submitButton = $(options.submitButtonSelector);
            }
            $(options.submitButtonSelector).bind('click', function (event) {
                if (!validateNow(input)) {
                    $('.' + options.invalidClass).first().focus();
                    event.preventDefault();
                    return false;
                }
            });
            $(this).unbind('blur.validateField');
            $(this).bind('blur.validateField', function (event) {
                validateNow(this);
            });
            if (options.validateOn !== false) {
                validationNamespace = '.validateField' + $(this).attr('name');
                validateEvent = options.validateEvent.replace(',', validationNamespace + ',') +
                    validationNamespace;
                $(options.validateOn).unbind(validateEvent);
                $(options.validateOn).bind(validateEvent, function (event) {
                    validateNow(input);
                });
            }
        });
    };
}(jQuery));