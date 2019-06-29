// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery3
//= require rails-ujs
//= require popper
//= require bootstrap
//= require axios.min
//= require lib/axios_config
//= require activestorage
//= require AdminLTE-3.0.0-alpha.2/adminlte
//= require site/main
//
//
$(function(){
  $(".dismissible").on("click", function(){
    $("body").removeClass("flash-on");
  })
})
