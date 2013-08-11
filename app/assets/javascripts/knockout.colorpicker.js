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
      el.val(val);
      el.click(function(e){
        $(this).next('.picker').show();
        e.stopPropagation();
        return false;        
      })
      el.after('<div class="picker"></div>') 
      el.next('.picker').farbtastic({
        color : val,
        width: 175,
        callback: function(color) {
          var newVal;
          newVal = color
          el.val(newVal);
          return valueAccessor()(newVal);
        }
      }).hide();

      return el.addClass('color').css('backgroundColor', val);
    },
    update: function(element, valueAccessor) {
      var newValue;
      newValue = valOf(valueAccessor);
      
      el = $(element);
      el.val(newValue);
      $.farbtastic(el.next('.picker')).setColor(newValue);

      el.css('backgroundColor', newValue);
      return newValue;
    }
  };

  ko.bindingHandlers.color = picker;

}).call(this);