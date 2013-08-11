(function() {
  var picker, valOf;

  valOf = function(va) {
    return ko.utils.unwrapObservable(va()) || '';
  };

  picker = {
    init: function(element, valueAccessor) {

      var el, val;
      val = valOf(valueAccessor);

      el = $(element);
      el.addClass('.selector')
      el.val(val);

      el.googleFontPicker({ 
        defaultFont: val, 
        callbackFunc: function(font){
          var value = valueAccessor();
          value(font)
        }
      });
    },

    update: function(element, valueAccessor) {
      var newValue;
      newValue = valOf(valueAccessor);
      el = $(element);
      el.val(newValue);
      return newValue;
    }
  };

  ko.bindingHandlers.font = picker;

}).call(this);
