/*
* Code pour le login/logout avec Google et facebook
*/

/* deferred loading du javascript de facebook */
(function(d, s, id){
   var js, fjs = d.getElementsByTagName(s)[0];
   if (d.getElementById(id)) {return;}
   js = d.createElement(s); js.id = id;
   js.src = "//connect.facebook.net/fr_CA/sdk.js";
   fjs.parentNode.insertBefore(js, fjs);
 }(document, 'script', 'facebook-jssdk'));

function getCookie(key) {
  var keyValue = document.cookie.match('(^|;) ?' + key + '=([^;]*)(;|$)');
  return keyValue ? keyValue[2] : null;
}

/* callback invoque apres le chargement du facebook js */
window.fbAsyncInit = function() {
  FB.init({
     /* appId      : '1548975615363971', dev account app */
     appId      : '377502229121424',  /* prod account app */
    xfbml      : false,
    version    : 'v3.2',
    cookie     : true
  });
};

/* helper pour logout de facebook */
var fbLogout = function() {
  FB.getLoginStatus (function (response) {
    if (response.authResponse) {
      FB.logout(function(response) {
        window.location = '/signout';
      });
    } else {
      window.location = '/signout';
    }
  });
};

var onGoogleSignin = function(googleUser) {
	document.cookie="login=google";
	var id_token = googleUser.getAuthResponse().id_token;
	var access_token = googleUser.getAuthResponse().access_token;
	$.post('/auth/google_oauth2/callback', {"access_token" : access_token})
	  .done(function(data) {
	    $('body').html(data);
	    socialInitHandlers();
	  })
	.fail(function(jqXHR, textStatus) {
	  alert("Failed auth processing on server. Please contact support. " + textStatus);
	});
};

var onGoogleSigninFailure = function() {
    $.post('/auth/failure', {provider: 'google', msg: authResult['error']}, function(data) {
        $('body').html(data);
        socialInitHandlers();
      });
}

var socialLogOut = function(event) {
  var scLg = getCookie('login');
  if (scLg == 'fb') {
    fbLogout();
    event.preventDefault();
  } else if (scLg == 'google') {
    gapi.auth2.getAuthInstance().signOut();
  }
};


var facebookSignin = function(event) {
  FB.login(function(response) {
    if (response.status === 'connected') {
      document.cookie="login=fb";
      $.post('/auth/facebook/callback', null)
      .done(function(data) {
        $('body').html(data);
        socialInitHandlers();
      })
      .fail(function(jqXHR, textStatus, errorThrown) {
         $('body').html(jqXHR.responseText); 
      });
    } else {
      var msg;
      if (response.status == 'not_authorized') {
        msg = "Vous devez permettre à l'application d'accéder votre courriel de Facebook.";
      } else {
        msg = "SVP ré-essayer de faire votre login Facebook.";
      }
      $.post('/auth/failure', {provider: 'facebook', msg: msg}, function(data) {
        $('body').html(data);
        socialInitHandlers();
      });
    }
  }, { scope: 'email'});
  event.preventDefault();
};

var socialInitHandlers = function() {
  gapi.load('auth2', function() {
	  var gparms = {
	    'client_id' : '1040962372599-s1m9rrdlgdo6bk12u4sjcuq877hvtvk6.apps.googleusercontent.com',
	    'cookiepolicy' : 'single_host_origin',
	    'scope' : 'profile email',
	  };
	  gapi.auth2.init(gparms);
	  $("#google_signin").click(function(event) {
			gapi.auth2.getAuthInstance().signIn().then(onGoogleSignin, onGoogleSigninFailure);
			event.preventDefault();
	  });
  });
  
  $('#facebook_signin').click(facebookSignin);
  $('#sign_out').click(socialLogOut);
};

$(document).ready(function () {
  socialInitHandlers();
});
