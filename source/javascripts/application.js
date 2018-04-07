//= require 'libs/jquery.js'
//= require 'libs/jquery-ui.js'
//= require 'libs/bootstrap.min.js'
//= require 'libs/userreport.js'
//= require 'libs/FileSaver.js'
//= require 'threejs/three.js'
//= require_tree ./threejs/plugins

window.debounce = function(func, wait, immediate){
    if (!wait){ wait = 250 }
    var timeout;
    return function() {
        var context = this, args = arguments;
        var later = function() {
            timeout = null;
            if (!immediate) func.apply(context, args);
        };
        var callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
        if (callNow) func.apply(context, args);
    };
};