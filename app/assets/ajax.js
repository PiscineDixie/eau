/*
 * This is a small generic code to replace forms submission with an AJAX request
 * that submits the form, accepts the response from the server
 * and replaces the content of the page with the form.
 * 
 */

/* Trigger on a form submit */
$(document).ready(function () {
  
  /* Handler for a submit button
   * Replaces the content of .content with what is rx from the server 
   * Supports: method, confirmation
   */
  $(document).on("click", 'input[type="submit2"]', function(event) {
    var $elem = $(this);
    var $form = $elem.closest('form');
    if ($form.data("remote") === undefined) {
      return;
    }
    
    var confirm = $elem.data("confirm");
    if (confirm !== undefined) {
      if (window.confirm(confirm) == false) {
        return;
      }
    }
    
    var method = $form.attr('method') || 'post';
    var url = $form.attr("action");
    $.ajax({
       type: method,
       url: url,
       data: $form.serialize()
     }).done(function(data) {
       $(".content").html(data);
     }).fail(function() {
       alert("Failed to submit form to server.");
     });
    event.preventDefault();
  });
  
  $(document).on('click', 'a2', function(event) {
    var $link = $(this);
    $.get($link.attr('href')).done(function (data) {
      $(".content").html(data);
    });
    event.preventDefault();
  });
});
