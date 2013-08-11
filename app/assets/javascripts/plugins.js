//= require jquery.masonry
//= require jquery.colorbox
//= require jquery.cycle.all
//= require jquery.hotkeys
//= require jquery.fontpicker
//= require jquery.bootstrap-select
//= require knockout/knockout
//= require knockout/knockout.mapping
//= require farbtastic
//= require knockout.colorpicker
//= require knockout.fontpicker
//= require knockout.jquery-ui-widgets
//= require dashboard
//= require scroller
//= require bootstrap.growl
//= require_self

/* ---- Begin integration of Underscore template engine with Knockout. Could go in a separate file of course. ---- */

    ko.underscoreTemplateEngine = function () {
        this['allowTemplateRewriting'] = false;
    }
    ko.underscoreTemplateEngine.prototype = new ko.templateEngine();

    ko.underscoreTemplateEngine.prototype['renderTemplateSource'] = function (templateSource, bindingContext, options) {
        // Precompile and cache the templates for efficiency
        var precompiled = templateSource['data']('precompiled');
        if (!precompiled) {
            precompiled = _.template("<% with($data) { %> " + templateSource.text() + " <% } %>");
            templateSource['data']('precompiled', precompiled);
        }
        // Run the template and parse its output into an array of DOM elements
        var renderedMarkup = precompiled(bindingContext).replace(/\s+/g, " ");
        return ko.utils.parseHtmlFragment(renderedMarkup);
    }
    ko.underscoreTemplateEngine.prototype['createJavaScriptEvaluatorBlock'] = function(script) {
        return "<%= " + script + " %>";
    }

    ko.underscoreTemplateEngine.instance = new ko.underscoreTemplateEngine();

    ko.setTemplateEngine(ko.underscoreTemplateEngine.instance);

    ko.exportSymbol('underscoreTemplateEngine', ko.underscoreTemplateEngine);


/* ---- End integration of Underscore template engine with Knockout ---- */
