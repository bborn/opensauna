/***
@title:
Google Font Picker

@version:
1.0

@author:
Tinus Guichelaar

@date:
2011-01-09

@url:
http://www.visualmedia.nl/html5/fontpicker/

@license:
http://creativecommons.org/licenses/by/3.0/

@copyright:
2011 VisualMedia BV (visualmedia.nl)

@requires:
jquery, jquery.googlefontpicker.js, index.htm, googlefontpicker.css

@does:
This plugin provides a selector for all Google Fonts.

@exampleJS:
$('#fontselector').googleFontPicker({ 
  defaultFont: 'Allan', 
  callbackFunc: changeFont
});

***/

(function( $ ){
jQuery.fn.googleFontPicker = function(settings) {

var fonts = new Array(
'Allan',
'Allerta',
'Allerta Stencil',
'Anonymous Pro',
'Arimo',
'Arvo',
'Bentham',
'Buda',
'Cabin',
'Calligraffitti',
'Cantarell',
'Cardo',
'Cherry Cream Soda',
'Chewy',
'Coda',
'Coming Soon',
'Copse',
'Corben',
'Cousine',
'Covered By Your Grace',
'Crafty Girls',
'Crimson Text',
'Crushed',
'Cuprum',
'Droid Sans',
'Droid Sans Mono',
'Droid Serif',
'Fontdiner Swanky',
'GFS Didot',
'GFS Neohellenic',
'Geo',
'Gruppo',
'Hanuman',
'Helvetica',
'Homemade Apple',
'IM Fell DW Pica',
'IM Fell DW Pica SC',
'IM Fell Double Pica',
'IM Fell Double Pica SC',
'IM Fell English',
'IM Fell English SC',
'IM Fell French Canon',
'IM Fell French Canon SC',
'IM Fell Great Primer',
'IM Fell Great Primer SC',
'Inconsolata',
'Irish Growler',
'Josefin Sans',
'Josefin Slab',
'Just Another Hand',
'Just Me Again Down Here',
'Kenia',
'Kranky',
'Kristi',
'Lato',
'Lekton',
'Lobster',
'Luckiest Guy',
'Merriweather',
'Molengo',
'Mountains of Christmas',
'Neucha',
'Neuton',
'Nobile',
'OFL Sorts Mill Goudy TT',
'Old Standard TT',
'Orbitron',
'PT Sans',
'PT Sans Caption',
'PT Sans Narrow',
'Permanent Marker',
'Philosopher',
'Puritan',
'Quicksand',
'Raleway',
'Reenie Beanie',
'Rock Salt',
'Schoolbell',
'Slackey',
'Sniglet',
'Sunshiney',
'Syncopate',
'Tangerine',
'Tinos',
'Ubuntu',
'UnifrakturCook',
'UnifrakturMaguntia',
'Unkempt',
'Vibur',
'Vollkorn',
'Walter Turncoat',
'Yanone Kaffeesatz'
);

return this.each(function() {

    var config = $.extend({
      defaultFont: 'Tahoma',              // default font to display in selector
      id:      'fontbox'+this.id,   // id of font picker container
      selid:     this.id,       // id of font selector field
      fontclass:   'font'+this.id,    // class for the font divs
      speed:     100          // speed of dialog animation, default is fast
    }, settings);

    var fontPicker = $('#' + config.id);    

    if (!fontPicker.length) {
      fontPicker = $('<div id="'+config.id+'" class="fontbox" ></div>').appendTo(document.body).hide();

      $(document.body).click(function(event) {                  
          if ($(event.target).is('#'+config.selid) || $(event.target).is('#'+config.id)) return;          
          fontPicker.slideUp(config.speed);   
      });
    }

    $(this).click(function () {
      if (fontPicker.is(':hidden'))
      {
        fontPicker.css({
          position: 'absolute', 
          left: $(this).offset().left + 'px', 
          top: ($(this).offset().top + $(this).height() + 3) + 'px'
        });       
        fontPicker.slideDown(config.speed);
      }
      else
        fontPicker.slideUp(config.speed);   
    });
    
    if (config.defaultFont.length)
    {
       $(this).css('fontFamily', config.defaultFont);
       $(this).val(config.defaultFont);
    }

    $.each(fonts, function(i, item) {     
      fontPicker.append('<a class="'+config.fontclass+'" style="font-family: '+item+';" value="' + item + '"> ' + item.split(',')[0] + '</a>');
    });
    
    $('.'+config.fontclass).click(function() {        
      $('#'+config.selid).val($(this).text());
      var fontFamily = ($(this).attr('value'));     
      $('#'+config.selid).css('fontFamily', fontFamily);
      
      config.callbackFunc(fontFamily);
    });
    
  }); 
}
})( jQuery );